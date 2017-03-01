#definitions for the benchmark study are saved in this file
MEASURES = list(acc, mmce)

library(mlr)
LEARNERS = listLearners("classif", properties = c("twoclass", "multiclass", "prob", "factors"))
#LEARNERS = LEARNERS[LEARNERS$class %in% c("classif.rpart", "classif.OneR"), ]
LEARNERS = makeLearners(LEARNERS$class, predict.type = "prob")

#alle learner
#nur probabilities
#classification und multiclass
#nur die, die faktoren supporten, mit defaults laufen lassen mit predict.type = prob
#bei svm 3 learner (kerne)
#xgboost
#glm ridge, lasso
