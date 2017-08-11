## ========================
## Require:
## apt-get install graphviz
## apt-get install inkscape
## ========================
library(TMB)
formals(compile)$tracesweep <- TRUE
formals(compile)$flags <- "-O0 -g"
source("makeDot.R")

compile("examp.cpp")
dyn.load(dynlib("examp"))
obj <- MakeADFun(data=list(),
                 parameters=list(u=rep(0,8)),
                 type=c("ADFun","ADGrad"),
                 DLL="examp")

value <- dumpstack(obj, "value")
makeDot(value,
        rank_operators=TRUE)

grad <- dumpstack(obj, "gradient")
makeDot(grad,
        bold=c(seq(16,28,by=2),29),
        filled=c(2,3,4,10,11,25,23,26),
        rank_operators=TRUE)

obj$env$random <- 1:8
h <- obj$env$spHess()

system("inkscape -f value.svg -A value.pdf")
system("inkscape -f grad.svg -A grad.pdf")

## Parallel examp
compile("examp_parallel.cpp")
dyn.load(dynlib("examp_parallel"))
openmp(2)
obj <- MakeADFun(data=list(),
                 parameters=list(u=rep(0,8)),
                 DLL="examp_parallel")

value_parallel <- dumpstack(obj)

## Split in the two tapes
value_parallel1 <- splitDump(value_parallel)[[1]]
value_parallel2 <- splitDump(value_parallel)[[2]]

makeDot(value_parallel1,
        bold=16,
        rank_operators=TRUE)
makeDot(value_parallel2,
        bold=17,
        rank_operators=TRUE)

system("inkscape -f value_parallel1.svg -A value_parallel1.pdf")
system("inkscape -f value_parallel2.svg -A value_parallel2.pdf")

## Linear regression - one data point
library(TMB)
compile("linreg.cpp")
dyn.load(dynlib("linreg"))
data <- list(Y = 1.234, x=5.678)
parameters <- list(a=0, b=0, logSigma=0)

## Linear regression *without* tape optimization
config(optimize.instantly=0, DLL="linreg") ## Disable tape optimizer
obj <- MakeADFun(data, parameters, DLL="linreg")
linreg <- dumpstack(obj)
makeDot(linreg, filled=quote(c(input,output)) )

## Linear regression *with* tape optimization
config(optimize.instantly=1, DLL="linreg") ## Enable tape optimizer
obj <- MakeADFun(data, parameters, DLL="linreg")
linreg_opt <- dumpstack(obj)
makeDot(linreg_opt, filled=quote(c(input,output)) )

## Linear regression gradient *with* tape optimization
config(optimize.instantly=1, DLL="linreg") ## Enable tape optimizer
obj <- MakeADFun(data, parameters, DLL="linreg", type=c("ADFun","ADGrad"))
linreg_grad_opt <- dumpstack(obj, "gradient")
makeDot(linreg_grad_opt, filled=quote(c(input,output)) )

## Multivariate normal: demonstrate atomic functions
library(TMB)
compile("mvnorm.cpp")
dyn.load(dynlib("mvnorm"))
data <- list()
parameters <- list(u=rep(0,3),S=diag(3))
data <- list(atomic=0)
obj <- MakeADFun(data, parameters, DLL="mvnorm", type=c("ADFun","ADGrad"))
mvnorm <- dumpstack(obj)
makeDot(mvnorm, filled=quote(c(input,output)) )

data <- list(atomic=1)
obj <- MakeADFun(data, parameters, DLL="mvnorm", type=c("ADFun","ADGrad"))
mvnorm_atomic <- dumpstack(obj)
makeDot(mvnorm_atomic, filled=quote(c(input,output)) )
