#collect results
library(batchtools)
library(dplyr)
library(mlr)

#save benchmark results
reg = loadRegistry("openml100bm/", work.dir = "./")
results = reduceResultsList(ids = findDone())
bmr = mergeBenchmarkResults(lapply(results, function(x) x$bmr))