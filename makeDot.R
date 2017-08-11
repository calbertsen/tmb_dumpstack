dumpstack <- function(obj, type = c("value", "gradient"), ...) {
    type <- c("value"="ADdouble", "gradient"="ADGrad")[match.arg(type)]
    threads.old <- openmp()
    on.exit(openmp(threads.old))
    openmp(1)
    ans <- capture.output( out <- obj$env$f(dumpstack=TRUE, type=type) )
    attr(ans, "ninput") <- length(obj$env$par)
    attr(ans, "noutput") <- length(out)
    ans
}

makeDot <- function(dump,
                    file = as.character(substitute(dump)),
                    bold=NULL,
                    filled=NULL,
                    dotfile=paste0(file,".dot"),
                    svgfile=paste0(file,".svg"),
                    forward=TRUE,
                    rank_operators=FALSE,
                    remap_atomic=TRUE) {
    d <- dump
    d <- d[d != ""]
    d <- sub("^o=[^ ]*[ ]*","",d)
    d <- gsub(" +"," ",d)
    d <- strsplit(d," ")
    node <- sub("v=","",sapply(d,function(x)x[1]))
    op <- sub("op=","",sapply(d,function(x)x[2]))
    ## Remove 'End' operator
    keep <- (op != "End")
    d <- d[keep]
    node <- node[keep]
    op <- op[keep]
    ## Some operators do not produce a variable
    remap <- as.character(seq_len(length(node)))
    names(remap) <- node
    node <- as.character(seq_len(length(node)))
    ## Atomic functions
    if(remap_atomic) {
        usr <- as.logical(cumsum(op=="User") %% 2)
        usr <- xor(usr, op=="User")
        newremap <- cumsum(!usr)
        remap[] <- newremap
        node[]  <- as.character(newremap)
    }
    ## Calc dependencies (and account for remapping)
    parseDep <- function(x){
        ans <- sub(".*=","",grep("v.=|.v=|v=",x,value=TRUE))
        ans <- ans[-1]
        ans <- remap[ans]
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
    input <- head(node, attr(dump, "ninput"))
    output <- tail(node, attr(dump, "noutput"))
    if(!is.null(bold))bold <- paste(eval(bold),"[style=dashed]")
    if(!is.null(filled))filled <- paste(eval(filled),"[style=filled]")
    group <- function(x,rank="same")c("{",paste0("rank=",rank),x,"}")
    spl <- split(node[op!="End"],op[op!="End"])
    graph <- c(
        "digraph graphname {",
        if(rank_operators)unlist(lapply(spl,group)) else NULL,
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

splitDump <- function(dump) {
    spl <- split(dump, cumsum(dump == ""))
    spl <- spl[sapply(spl, length) > 1]
    names(spl) <- NULL
    spl <- lapply(spl, function(x){attributes(x) <- attributes(dump);x})
    spl
}
