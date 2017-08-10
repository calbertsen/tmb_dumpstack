## ========================
## Require:
## apt-get install graphviz
## apt-get install inkscape
## ========================
library(TMB)
source("makeDot.R")

compile("examp.cpp", libtmb=FALSE)
dyn.load(dynlib("examp"))
obj <- MakeADFun(data=list(),
                 parameters=list(u=rep(0,8)),
                 type=c("ADFun","ADGrad"),
                 DLL="examp")

sink("value")
dummy <- obj$env$f(dumpstack=TRUE)
sink()

sink("grad")
dummy <- obj$env$f(type="ADGrad", dumpstack=TRUE)
sink()

makeDot("grad",bold=c(seq(16,28,by=2),29),filled=c(2,3,4,10,11,25,23,26))
makeDot("value")##,bold=24)

obj$env$random <- 1:8
h <- obj$env$spHess()

system("inkscape -f value.svg -A value.pdf")
system("inkscape -f grad.svg -A grad.pdf")

## Parallel examp
compile("examp_parallel.cpp", libtmb=FALSE)
dyn.load(dynlib("examp_parallel"))
openmp(2)
obj <- MakeADFun(data=list(),
                 parameters=list(u=rep(0,8)),
                 DLL="examp_parallel")
openmp(1)
sink("value_parallel")
dummy <- obj$env$f(dumpstack=TRUE)
sink()
## Split in the two tapes
li <- readLines("value_parallel")
lineno <- grep("End",li)[1]
writeLines(li[(1:lineno)],"value_parallel1")
writeLines(li[-(1:lineno)],"value_parallel2")

makeDot("value_parallel1",bold=16)
makeDot("value_parallel2",bold=17)

system("inkscape -f value_parallel1.svg -A value_parallel1.pdf")
system("inkscape -f value_parallel2.svg -A value_parallel2.pdf")

## Linear regression - one data point

library(TMB)
compile("linreg.cpp", libtmb=FALSE)
dyn.load(dynlib("linreg"))
data <- list(Y = 1.234, x=5.678)
parameters <- list(a=0, b=0, logSigma=0)
config(optimize.instantly=0, DLL="linreg") ## Disable tape optimizer
obj <- MakeADFun(data, parameters, DLL="linreg")

sink("linreg")
dummy <- obj$env$f(dumpstack=TRUE)
sink()
makeDot("linreg")
