# getting the data
# openml 100 data sets: study_14
library(OpenML)
library(BBmisc)
setOMLConfig(apikey = "1536489644f7a7872e7d0d5c89cb6297")
datasets = listOMLTasks(tag = "study_14")
datasets = datasets[1:10, ]
populateOMLCache(task.ids = datasets$task.id)
oml.tasks = lapply(datasets$task.id, function(x) getOMLTask(task.id = x))
oml.tasks = setNames(oml.tasks, vcapply(oml.tasks, function(x) x$input$data.set$desc$name))

# batchtools experiment
library(batchtools)
source("defs.R")

# create registry
unlink("openml100bm", recursive = TRUE)
reg = makeExperimentRegistry("openml100bm", packages = "mlr", source = "defs.R", seed = 123)

# add problems
for (tn in names(oml.tasks)) {
  task = oml.tasks[[tn]]
  addProblem(name = tn, data = task)
}

# add algorithms
addAlgorithm(name = "algorithm", fun = function(data, lrn, ...) {
  learner = LEARNERS[[lrn]]
  runTaskMlr(task = data, learner = learner, measures = MEASURES)
})

# make algorithm design
algo.designs = list(
  algorithm = data.frame(lrn = names(LEARNERS))
)

# add Experiments
addExperiments(algo.designs = algo.designs)
summarizeExperiments()


#submit
submitJobs()

