ccd <- function(df, continuous = TRUE, depth = 3, significance = 0.05,
    verbose = FALSE, java.parameters = NULL, priorKnowledge = NULL){
    
    params <- list(NULL)
    
    if(!is.null(java.parameters)){
        options(java.parameters = java.parameters)
        params <- c(java.parameters = java.parameters)
    }

    # Data Frame to Independence Test
    indTest = NULL
    if(continuous){
    	tetradData <- loadContinuousData(df)
    	indTest <- .jnew("edu/cmu/tetrad/search/IndTestFisherZ", tetradData, significance)
    }else{
    	tetradData <- loadDiscreteData(df)
    	indTest <- .jnew("edu/cmu/tetrad/search/IndTestChiSquare", tetradData, 
    		significance)
    }
    
	indTest <- .jcast(indTest, "edu/cmu/tetrad/search/IndependenceTest")

    ccd <- list()
    class(ccd) <- "ccd"

    ccd$datasets <- deparse(substitute(df))

    cat("Datasets:\n")
    cat(deparse(substitute(df)),"\n\n")

    # Initiate CCD
    ccd_instance <- .jnew("edu/cmu/tetrad/search/Ccd", indTest)
    .jcall(ccd_instance, "V", "setDepth", as.integer(depth))
    .jcall(ccd_instance, "V", "setVerbose", verbose)

    if(!is.null(priorKnowledge)){
        .jcall(ccd_instance, "V", "setKnowledge", priorKnowledge)
    }

    params <- c(params, continuous = as.logical(continuous))
    params <- c(params, depth = as.integer(depth))
    params <- c(params, significance = significance)
    params <- c(params, verbose = as.logical(verbose))

    if(!is.null(priorKnowledge)){
        params <- c(params, prior = priorKnowledge)
    }
    ccd$parameters <- params

    cat("Graph Parameters:\n")
    cat("continuous = ", continuous,"\n")
    cat("depth = ", as.integer(depth),"\n")
    cat("significance = ", as.numeric(significance),"\n")
    cat("verbose = ", verbose,"\n")

    # Search
    tetrad_graph <- .jcall(ccd_instance, "Ledu/cmu/tetrad/graph/Graph;", 
        "search")

    V <- extractTetradNodes(tetrad_graph)

    ccd$nodes <- V

    # extract edges
    ccd_edges <- extractTetradEdges(tetrad_graph)

    ccd$edges <- ccd_edges

    return(ccd)
}