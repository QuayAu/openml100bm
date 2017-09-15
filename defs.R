#definitions for the benchmark study are saved in this file
MEASURES = list(mmce, ber, auc)

LEARNERS = listLearners("classif", properties = c("twoclass", "multiclass", "prob"), create = TRUE)
LEARNERS = setNames(lapply(LEARNERS, function(lrn) {
  lrn = setPredictType(lrn, predict.type = "prob")
  if (grepl("^classif.xgboost", getLearnerId(lrn)))
    lrn = setHyperPars(lrn, nrounds = 100)
  # impute if necessary
  lrn = makeImputeWrapper(lrn, classes = list("factor" = imputeConstant("Missing"), "numeric" = imputeHist()))
  # add dummy feature wrapper if learner can't handle factors
  if ("factors" %nin% getLearnerProperties(lrn))
    lrn = makeDummyFeaturesWrapper(lrn)
  # remove almost constant features
  makeRemoveConstantFeaturesWrapper(lrn, perc = 0.01)
}), vcapply(LEARNERS, getLearnerId))

#alle learner
#nur probabilities
#classification und multiclass
#nur die, die faktoren supporten, mit defaults laufen lassen mit predict.type = prob
#bei svm 3 learner (kerne)
#xgboost
#glm ridge, lasso
