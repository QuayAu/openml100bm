library(OpenML)
library(farff)
runs = listOMLRunEvaluations(tag = "mlr_defauls_openml100")
save(runs, file = "runs.RData")
writeARFF(runs, path = "runs.arff")
