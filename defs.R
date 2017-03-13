#definitions for the benchmark study are saved in this file
MEASURES = list(acc, mmce)

LEARNERS = listLearners("classif", properties = c("twoclass", "multiclass", "prob"), create = TRUE)
LEARNERS = setNames(lapply(LEARNERS, function(lrn) {
  lrn = setPredictType(lrn, predict.type = "prob")
  if (getLearnerId(lrn) == "classif.xgboost")
    lrn = setHyperPars(lrn, nrounds = 100)
  # add dummy feature wrapper if learner can't handle factors
  if ("factors" %nin% getLearnerProperties(lrn))
    lrn = makeDummyFeaturesWrapper(lrn)
  # remove almost constant features
  makeRemoveConstantFeaturesWrapper(lrn)
}), vcapply(LEARNERS, getLearnerId))

#alle learner
#nur probabilities
#classification und multiclass
#nur die, die faktoren supporten, mit defaults laufen lassen mit predict.type = prob
#bei svm 3 learner (kerne)
#xgboost
#glm ridge, lasso
