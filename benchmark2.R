# getting the data
# openml 100 data sets: study_14
library(OpenML)
setOMLConfig(server = "https://www.openml.org/api/v1")
#setOMLConfig(apikey = "1536489644f7a7872e7d0d5c89cb6297")# batchtools experiment
library(mlr)
library(BBmisc)
library(parallelMap)
library(batchtools)
source("defs.R")

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
unlink("mlr_defaults_openml50", recursive = TRUE)
reg = makeExperimentRegistry("mlr_defaults_openml50", 
  packages = c("OpenML", "mlr", "parallelMap"),
  source = "defs.R", seed = 123)
tmpl = "/home/hpc/pr74ze/ri89coc2/lrz_configs/config_files/batchtools/slurm_lmulrz.tmpl"
reg$cluster.functions = makeClusterFunctionsSlurm(template = tmpl, clusters = "serial")

# add problems
tn = names(oml.tasks)
for (i in seq_along(tn)) {
  addProblem(name = tn[i], data = oml.tasks[[tn[i]]], seed = i)
}

# add algorithms
addAlgorithm(name = "algorithm", fun = function(data, lrn, ...) {
  learner = LEARNERS[[lrn]]
  #parallelStartMulticore(10, level = "mlr.resample")
  run = runTaskMlr(task = data, learner = learner, measures = MEASURES, models = FALSE)
  run.id = try(uploadOMLRun(run, confirm.upload = FALSE, tags = "mlr_defaults_openml50"))
  #parallelStop()
  return(list(run = run, run.id = run.id))
})

# make algorithm design
algo.designs = list(
  algorithm = data.frame(lrn = names(LEARNERS))
)

# add Experiments
addExperiments(algo.designs = algo.designs)
summarizeExperiments()

#submit
resources = list(walltime = 10*3600, memory = 4*1024, measure.memory = TRUE) #, ntasks = 10)
submitJobs(ids = findNotSubmitted(), resources = resources, reg = reg)
