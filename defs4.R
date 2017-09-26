library(mlr)
library(BBmisc)

learners = list(
  makeLearner("classif.rpart"),
  makeLearner("classif.ranger", num.trees = 500),
  makeLearner("classif.RRF", ntree = 500)
)

# other learners
learners2 = list(
  makeLearner(id = "classif.svm.radial", "classif.svm", kernel = "radial"),
  makeLearner(id = "classif.svm.polynomial", "classif.svm", kernel = "polynomial"),
  makeLearner(id = "classif.svm.linear", "classif.svm", kernel = "linear"),
  makeLearner("classif.gbm"),
  makeLearner("classif.kknn"),
  makeLearner("classif.naiveBayes"),
  makeLearner(id = "classif.glmnet.lasso", "classif.glmnet", alpha = 1),
  makeLearner(id = "classif.glmnet.ridge", "classif.glmnet", alpha = 0),
  makeLearner("classif.C50"),
  makeLearner("classif.featureless")
)
# paramset for other learners
ps = list(
  classif.svm.radial = makeParamSet(
    makeNumericParam("cost", lower = -12, upper = 12, trafo = function(x) 2^x),
    makeNumericParam("gamma", lower = -12, upper = 12, trafo = function(x) 2^x)
  ),
  classif.svm.polynomial = makeParamSet(
    makeNumericParam("cost", lower = -12, upper = 12, trafo = function(x) 2^x),
    makeIntegerParam("degree", lower = 1, upper = 5)
  ),
  classif.svm.linear = makeParamSet(
    makeNumericParam("cost", lower = -12, upper = 12, trafo = function(x) 2^x)
  ),
  classif.gbm = makeParamSet(
    makeNumericParam("shrinkage", lower = -4, upper = -1, trafo = function(x) 10^x),
    makeIntegerParam("interaction.depth", lower = 1, upper = 5),
    makeIntegerParam("n.trees", lower = 500, upper = 10000)
  ),
  classif.kknn = makeParamSet(
    makeIntegerParam("k", lower = 1, upper = 50)
  ),
  classif.naiveBayes = makeParamSet(),
  classif.glmnet.lasso = makeParamSet(
    makeNumericParam("s", lower = -12, upper = 12, trafo = function(x) 2^x)
  ),
  classif.glmnet.ridge = makeParamSet(
    makeNumericParam("s", lower = -12, upper = 12, trafo = function(x) 2^x)
  ),
  classif.C50 = makeParamSet(
    makeIntegerParam("trials", lower = 1, upper = 100),
    makeLogicalParam("winnow")
  ),
  classif.featureless = makeParamSet()
)

learners3 = unlist(lapply(learners2, function(lrn) {
  ps = ps[[lrn$id]]
  d = length(ps$pars)
  
  # make learner
  cl = list(numeric = imputeHist(), factor = imputeConstant("Missing"))
  lrn = makeImputeWrapper(lrn, classes = cl, dummy.classes = c("numeric", "factor"))
  lrn = makeDummyFeaturesWrapper(lrn)
  lrn = makeRemoveConstantFeaturesWrapper(lrn, perc = 0.01, na.ignore = FALSE)
  lrn = setPredictType(lrn, predict.type = "prob")
  
  if (d == 0) return(list(lrn))
  pars = unique(generateRandomDesign(10*d, ps, trafo = TRUE))
  par.list = convertRowsToList(pars, name.vector = TRUE)
  
  if (nrow(pars) > 1)
    lrn.list = lapply(par.list, function(x) setHyperPars(lrn, par.vals = x)) else 
      lrn.list = list(setHyperPars(lrn, par.vals = unlist(unname(par.list), recursive = FALSE)))
}), recursive = FALSE)
