makeDot <- function(file,
                    bold=NULL,
                    filled=NULL,
                    dotfile=paste0(file,".dot"),
                    svgfile=paste0(file,".svg"),
                    forward=TRUE){
    d <- readLines(file)
    d <- d[d != ""]
    d <- sub("^o=[^ ]*[ ]*","",d)
    d <- gsub(" +"," ",d)
    d <- strsplit(d," ")
    node <- sub("i=","",sapply(d,function(x)x[1]))
    node <- sub("v=", "", node)
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
