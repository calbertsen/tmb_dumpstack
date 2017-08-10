## ========================
## Require:
## apt-get install graphviz
## apt-get install inkscape
## ========================
library(TMB)
compile("examp.cpp")
dyn.load("examp.so")
obj <- MakeADFun(data=list(),parameters=list(u=rep(0,8)),type=c("ADFun","ADGrad"))

sink("value")
qw <- obj$env$f(dumpstack=TRUE)
sink()
sink("grad")
qw <- obj$env$f(type="ADGrad",dumpstack=TRUE)
sink()
makeDot <- function(file,bold=NULL,filled=NULL,dotfile=paste0(file,".dot"),svgfile=paste0(file,".svg"),
                    forward=TRUE){
  d <- readLines(file)
  d <- gsub(" +"," ",d)
  d <- strsplit(d," ")
  node <- sub("i=","",sapply(d,function(x)x[1]))
  op <- sub("op=","",sapply(d,function(x)x[2]))
  parseDep <- function(x){
    ans <- sub(".*=","",grep("v.=|.v=",x,value=TRUE))  
    ##unique(ans)
    ans
  }
  args <- lapply(d,parseDep)
  if(!forward){
      edges <- unlist(Map(paste,node,args,sep=" -> ")[sapply(args,length)>0])
  } else {
      edges <- unlist(Map(paste,args,node,sep=" -> ")[sapply(args,length)>0])
  }
  lab <- paste(op,node)
  labels <- paste0(node," [label=\"",lab,"\"]")
  labels <- labels[op!="End"]
  if(!is.null(bold))bold <- paste(bold,"[style=dashed]")
  if(!is.null(filled))filled <- paste(filled,"[style=filled]")
  group <- function(x,rank="same")c("{",paste0("rank=",rank),x,"}")
  spl <- split(node[op!="End"],op[op!="End"])
  graph <- c(
             "digraph graphname {",
             unlist(lapply(spl,group)),
             edges,
             labels,
             filled,
             bold,
             "}")
  cat("Writing",dotfile,"\n")  
  writeLines(graph,dotfile)
  cat("Writing",svgfile,"\n")
  system(paste("dot -Tsvg",dotfile,">",svgfile))
}

makeDot("grad",bold=c(seq(16,28,by=2),29),filled=c(2,3,4,10,11,25,23,26))
makeDot("value")##,bold=24)

obj$env$random <- 1:8
h <- obj$env$spHess()

system("inkscape -f value.svg -A value.pdf")
system("inkscape -f grad.svg -A grad.pdf")


## sink("hess")
## qw <- local(.Call("EvalADFunObject", ADHess$ptr, obj$env$par, control = list(order = as.integer(0), 
##     hessiancols = integer(0), hessianrows = integer(0), sparsitypattern = as.integer(0), 
##     rangecomponent = as.integer(1), dumpstack = as.integer(1)), 
##     PACKAGE = obj$env$DLL),environment(obj$env$spHess))
## sink()
## makeDot("hess")


## Parallel examp
compile("examp_parallel.cpp")
dyn.load("examp_parallel.so")
openmp(2)
obj <- MakeADFun(data=list(),parameters=list(u=rep(0,8)),DLL="examp_parallel")
openmp(1)
sink("value_parallel")
qw <- obj$env$f(dumpstack=TRUE)
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

