library(mlr)
library(BBmisc)
library(parallelMap)
library(batchtools)
library(OpenML)
setOMLConfig(server = "https://www.openml.org/api/v1")
source("defs4.R")

if (!file.exists("OpenML100.RData")) {
  task.list = getOMLStudy(study = "OpenML100")
  tasks = lapply(task.list$tasks$task.id, getOMLTask)
  save(tasks, file = "OpenML100.RData")
} else {
  load("OpenML100.RData")
}

# use only 2 class
task.list = listOMLTasks(tag = "OpenML100")
bin.task.list = listOMLTasks(tag = "OpenML100", number.of.classes = 2)
bin.tasks = lapply(tasks[which(task.list$task.id %in% bin.task.list$task.id)], function(x) x)
# get maximal number of factor levels for each dataset
max.levels = vnapply(bin.tasks, function(tsk) sum(sapply(as.data.frame(tsk), function(x) nlevels(x))))
# remove tasks with big factor levels
bin.tasks = bin.tasks[max.levels < 500]
oml.tasks = setNames(bin.tasks, vcapply(bin.tasks, function(x) x$input$data.set$desc$name))

# create registry
unlink("experiments", recursive = TRUE)
reg = makeExperimentRegistry("experiments", 
  packages = c("OpenML", "mlr", "parallelMap", "BBmisc", "methods", "checkmate"),
  seed = 123, source = "defs4.R")
tmpl = "/home/hpc/pr74ze/ri89coc2/lrz_configs/config_files/batchtools/slurm_lmulrz.tmpl"
reg$cluster.functions = makeClusterFunctionsSlurm(template = tmpl, clusters = "serial")

getLearnerFunction = function(lrn) {
  getLearnerSpecificParamSet = function(task, lrn) {
    library(parallelMap)
    library(ParamHelpers)
    n = mlr::getTaskSize(task)
    p = mlr::getTaskNFeats(task)
    
    ps = list(
      classif.rpart = makeParamSet(
        makeNumericParam("cp", lower = -4, upper = -1, trafo = function(x) 10^x),
        makeIntegerParam("minsplit", lower = 1, upper = min(7, floor(log2(n))), trafo = function(x) 2^x),
        makeIntegerParam("minbucket", lower = 0, upper = min(6, floor(log2(n))), trafo = function(x) 2^x)
      ),
      classif.ranger = makeParamSet(
        makeNumericParam("mtry", lower = 0.1, upper = 0.9, trafo = function(x) floor(max(1, p^x)))
      ),
      classif.RRF = makeParamSet(
        makeNumericParam("mtry", lower = 0.1, upper = 0.9, trafo = function(x) floor(max(1, p^x))),
        makeNumericParam("coefReg", lower = 0, upper = 1)
      )
    )
    ps[[lrn$id]]
  }
  
  force(lrn)
  
  function(job, data, ...) {
    mlr = convertOMLTaskToMlr(data)
    
    # sample hyperpars
    ps = getLearnerSpecificParamSet(mlr$mlr.task, lrn)
    d = length(ps$pars)
    pars = unique(generateRandomDesign(10*d, ps, trafo = TRUE))
    par.list = convertRowsToList(pars, name.vector = TRUE)
    
    # make learner
    cl = list(numeric = imputeHist(), factor = imputeConstant("Missing"))
    lrn = makeImputeWrapper(lrn, classes = cl, dummy.classes = c("numeric", "factor"))
    lrn = makeDummyFeaturesWrapper(lrn)
    lrn = makeRemoveConstantFeaturesWrapper(lrn, perc = 0.01, na.ignore = FALSE)
    lrn = setPredictType(lrn, predict.type = "prob")
    
    if (nrow(pars) > 1)
      lrn.list = lapply(par.list, function(x) setHyperPars(lrn, par.vals = x)) else 
        lrn.list = list(setHyperPars(lrn, par.vals = unlist(unname(par.list), recursive = FALSE)))
 
    # run learners
    run = lapply(lrn.list, function(l) try(runTaskMlr(data, l, measures = list(mmce, ber, auc), models = FALSE)))
    run.id = lapply(run, function(r) try(uploadOMLRun(r, confirm.upload = FALSE, tags = "irt_benchmark50")))
    return(run)
  }
}

# add problems
tn = names(oml.tasks)
for (i in seq_along(tn)) {
  addProblem(name = tn[i], data = oml.tasks[[tn[i]]], seed = i)
}

# add algorithms
for (learner in learners) {
  addAlgorithm(name = learner$id, fun = getLearnerFunction(learner))
}

for (i in seq_along(learners3)) {
  addAlgorithm(name = paste0(learners3[[i]]$id, i), fun = function(data, lrn, ...) {
    learner = learners3[[i]]
    run = runTaskMlr(task = data, learner = learner, measures = list(mmce, ber, auc), models = FALSE)
    run.id = try(uploadOMLRun(run, confirm.upload = FALSE, tags = "irt_benchmark50"))
    return(list(run = run, run.id = run.id))
  })
}

addExperiments()

#submit
resources = list(walltime = 3*3600, memory = 4*1024, measure.memory = TRUE) #, ntasks = 10)
submitJobs(ids = findNotSubmitted(), resources = resources, reg = reg)
