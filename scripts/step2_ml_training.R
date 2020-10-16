library(randomForest)
library(caret)
library(keras)

metric <- function(tbl) {
    if (nrow(tbl) < 2) {
        print(tbl)
        return(NULL)
    }
    recall    <- recall(tbl, relevant = "1")
    precision <- precision(tbl, relevant  = "1") # 预测结果中正确部分
    listk(recall, precision)
}

set.seed(1)
# data <- d
data <- d
data$y %<>% as.factor()
preProcValues  <- preProcess(data, method = c("medianImpute","center","scale"))
data_processed <- predict(preProcValues, data)
preProcValues$y %<>% as.numeric() %>% subtract(1)

predictors <- colnames(data)[-1]
response   <- c("y")
npredict   <- length(predictors)

index <- createDataPartition(last(data_processed), p = 0.75, list=FALSE)
trainSet <- data_processed[ index,]
testSet  <- data_processed[-index,]

x_train <- data_processed[index, ..predictors] %>% as.matrix()
y_train <- data_processed[index, ..response, drop = F]  %>% as.matrix()
x_test  <- data_processed[-index, ..predictors]  %>% as.matrix()
y_test  <- data_processed[-index, ..response, drop = F] %>% as.matrix()

y_train <- to_categorical(y_train, 2)
y_test <- to_categorical(y_test, 2)

formula <- sprintf("%s~%s", response, paste(predictors, collapse = "+")) %>% as.formula()
# m <- randomForest(formula, trainSet)

# performance
# table(fit = m$predicted, ref = trainSet$y) %>% recall(relevant = "1")
# res <- predict(m, testSet)
# GOF(testSet$CYA_sum, res)

# keras -------------------------------------------------------------------
# reshape
x_train <- array_reshape(x_train, c(nrow(x_train), npredict))
x_test  <- array_reshape(x_test, c(nrow(x_test), npredict))

# rescale
# x_train <- x_train / 255
# x_test <- x_test / 255

# ------------------------------------------------------------------------
# y_train <- to_categorical(y_train, 10)
# y_test  <- to_categorical(y_test, 10)

# ------------------------------------------------------------------------

{
    model <- keras_model_sequential()
    activation <- "relu"

    model %>%
        layer_dense(units = 7, activation = activation, input_shape = c(npredict)) %>%
        layer_dropout(rate = 0.2) %>%
        # layer_dense(units = 5, activation = activation) %>%
        layer_dense(units = 4, activation = activation) %>%
        # layer_dense(units = 10, activation = activation, input_shape = c(npredict)) %>%
        # layer_dense(units = 4, activation = activation) %>%
        layer_dense(units = 2, activation = "softmax")
    # layer_dense(units = 4, activation = activation) # %>%
    # layer_dropout(rate = 0.3) %>%
    # layer_dropout(rate = 0.4) %>%
    # layer_dense(units = 10, activation = 'softmax')

    # ------------------------------------------------------------------------
    summary(model)
    # ------------------------------------------------------------------------
    model %>% compile(
        # loss = 'mse',
        # optimizer = optimizer_rmsprop()
        loss = 'binary_crossentropy',
        optimizer = optimizer_rmsprop(),
        metrics = c('accuracy')
    )

    # ---- results='hide'-----------------------------------------------------
    history <- model %>% fit(
        x_train, y_train,
        epochs = 30, batch_size = 500,
        validation_split = 0.4
    )

    ## 所有数据均不行，
    x_all <- data_processed[, -1] %>% as.matrix()
    tbl <- table(fit = predict_classes(model, x_all), ref = data_processed$y )
    metric(tbl) %>% str()
    tbl
}


# ------------------------------------------------------------------------
plot(history)

# ---- results = 'hide'---------------------------------------------------
model %>% evaluate(x_test, y_test)

# ---- results = 'hide'---------------------------------------------------
z <- model %>% predict(x_test)
# GOF(y_test, z)

# res <- model %>% { cbind(ref = d[index, y], fit = predict_classes(., x_train)) }
# tbl <- model %>% { table(fit = predict_classes(., x_train), ref = d[index, y] ) }

