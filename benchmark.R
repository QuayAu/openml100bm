# getting the data
# openml 100 data sets: study_14
library(OpenML)
#setOMLConfig(apikey = "1536489644f7a7872e7d0d5c89cb6297")# batchtools experiment
library(BBmisc)
library(parallelMap)
library(batchtools)
source("defs.R")

datasets = listOMLTasks(tag = "study_14")
#datasets = datasets[1:10, ]
populateOMLCache(task.ids = datasets$task.id)
oml.tasks = lapply(datasets$task.id, function(x) try(getOMLTask(task.id = x)))
oml.tasks = oml.tasks[!vlapply(oml.tasks, is.error)]
oml.tasks = setNames(oml.tasks, vcapply(oml.tasks, function(x) x$input$data.set$desc$name))

# create registry
unlink("openml100bm", recursive = TRUE)
reg = makeExperimentRegistry("openml100bm", packages = c("OpenML", "mlr", "parallelMap"),
  source = "defs.R", seed = 123)
tmpl = "/home/hpc/pr74ze/ri89coc2/lrz_configs/config_files/batchtools/slurm_lmulrz.tmpl"
reg$cluster.functions = makeClusterFunctionsSlurm(template = tmpl, clusters = "mpp2")

# add problems
for (tn in names(oml.tasks)) {
  task = oml.tasks[[tn]]
  addProblem(name = tn, data = task)
}

# add algorithms
addAlgorithm(name = "algorithm", fun = function(data, lrn, ...) {
  learner = makeRemoveConstantFeaturesWrapper(LEARNERS[[lrn]])
  parallelStartMulticore(10, level = "mlr.resample")
  run = runTaskMlr(task = data, learner = learner, measures = MEASURES)
  run.id = try(uploadOMLRun(run, confirm.upload = FALSE, tags = "mlr_defauls_openml100"))
  parallelStop()
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
resources = list(walltime = 3*3600, memory = 2*1024, measure.memory = TRUE, ntasks = 10)
submitJobs(ids = findNotSubmitted(), resources = resources, reg = reg)
