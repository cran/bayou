#' Loads a bayou object
#'
#' \code{load.bayou} loads a bayouFit object that was created using \code{bayou.mcmc()}
#'
#' @param bayouFit An object of class \code{bayouFit} produced by the function \code{bayou.mcmc()}
#' @param saveRDS A logical indicating whether the resulting chains should be saved as an *.rds file
#' @param file An optional filename (possibly including path) for the saved *.rds file
#' @param cleanup A logical indicating whether the files produced by \code{bayou.mcmc()} should be removed.
#' @param ref A logical indicating whether a reference function is also in the output
#' @param verbose Determines whether information is outputted to the console for the user to view
#'
#' @details If both \code{save.Rdata} is \code{FALSE} and \code{cleanup} is \code{TRUE}, then \code{load.bayou} will trigger a
#' warning and ask for confirmation. In this case, if the results of \code{load.bayou()} are not stored in an object,
#' the results of the MCMC run will be permanently deleted.
#'
#'
#' @return
#' A list of class `"bayouMCMC"` containing:
#' \describe{
#'   \item{gen}{A numeric vector of sampled MCMC generations.}
#'   \item{lnL}{A numeric vector of log-likelihood values.}
#'   \item{prior}{A numeric vector of prior probabilities.}
#'   \item{sb}{A list of shift locations sampled across the MCMC chain.}
#'   \item{loc}{A list of relative shift locations on branches.}
#'   \item{t2}{A list of new optima values after shifts.}
#'   \item{rjpars}{A list of reversible-jump parameters sampled at each step.}
#'   \item{(Other parameters)}{Additional parameters specific to the model used in `bayou.mcmc()`.}
#' }
#'
#'
#' @export
load.bayou <- function(bayouFit, saveRDS=TRUE, file=NULL, cleanup=FALSE, ref=FALSE, verbose=TRUE){
  tree <- bayouFit$tree
  dat <- bayouFit$dat
  outname <- bayouFit$outname
  model <- bayouFit$model
  model.pars <- bayouFit$model.pars
  startpar <- bayouFit$startpar
  dir <- bayouFit$dir
  outpars <- model.pars$parorder[!(model.pars$parorder %in% model.pars$rjpars)]
  rjpars <- model.pars$rjpars
  #mapsr2 <- read.table(file="mapsr2.dta",header=FALSE)
  #mapsb <- read.table(file="mapsb.dta",header=FALSE)
  #mapst2 <- read.table(file="mapst2.dta",header=FALSE)
  mapsr2 <- scan(file=paste(dir,outname,".loc",sep=""),what="",sep="\n",quiet=TRUE,blank.lines.skip=FALSE)
  mapsb <- scan(file=paste(dir,outname,".sb",sep=""),what="",sep="\n",quiet=TRUE,blank.lines.skip=FALSE)
  mapst2 <- scan(file=paste(dir,outname,".t2",sep=""),what="",sep="\n",quiet=TRUE,blank.lines.skip=FALSE)
  pars.out <- scan(file=paste(dir,outname,".pars",sep=""),what="",sep="\n",quiet=TRUE,blank.lines.skip=FALSE)
  rjpars.out <- scan(file=paste(dir,outname,".rjpars",sep=""),what="",sep="\n",quiet=TRUE,blank.lines.skip=FALSE)
  rjpars.out <- lapply(strsplit(rjpars.out,"[[:space:]]+"),as.numeric)
  pars.out <- lapply(strsplit(pars.out,"[[:space:]]+"),as.numeric)
  mapsr2 <- lapply(strsplit(mapsr2,"[[:space:]]+"),as.numeric)
  mapsb <- lapply(strsplit(mapsb,"[[:space:]]+"),as.numeric)
  mapst2 <- lapply(strsplit(mapst2,"[[:space:]]+"),as.numeric)
  chain <- list()
  chain$gen <- sapply(pars.out,function(x) x[1])
  chain$lnL <- sapply(pars.out,function(x) x[2])
  chain$prior <- sapply(pars.out,function(x) x[3])
  if(ref==TRUE){
    chain$ref <- sapply(pars.out, function(x) x[4])
  }
  parLs <- lapply(startpar, length)[outpars]
  j=4+as.numeric(ref)
  if(length(outpars) > 0){
    for(i in 1:length(outpars)){
      chain[[outpars[i]]] <- lapply(pars.out, function(x) as.vector(x[j:(j+parLs[[i]]-1)]))#unlist(res[[4]][,j:(j+parLs[[i]]-1)],F,F)
      if(parLs[[i]]==1) chain[[outpars[i]]]=unlist(chain[[outpars[i]]])
      j <- j+1+parLs[[i]]-1
    }
  }
  chain$sb <- mapsb
  chain$loc <- mapsr2
  chain$t2 <- mapst2
  #j=4
  #if(length(outpars) > 0){
  #  for(i in 1:length(outpars)){
  #    chain[[outpars[i]]] <- sapply(pars.out, function(x) x[j])
  #    j <- j+1
  #  }
  #}
  if(length(rjpars >0)){
    nrjpars <- length(rjpars)
    for(i in 1:length(rjpars)){
      chain[[rjpars[i]]] <- lapply(rjpars.out, function(x) unlist((x[(1+length(x)/nrjpars*(i-1)):(1+i*length(x)/nrjpars-1)]),F,F))
    }
  }
  attributes(chain)$model <- model
  attributes(chain)$model.pars <- model.pars
  attributes(chain)$tree <- tree
  attributes(chain)$dat <- dat
  class(chain) <- c("bayouMCMC", "list")
  if(saveRDS==FALSE & cleanup==TRUE){
    ans <- toupper(readline("Warning: You have selected to delete all created MCMC files and not to save them as an .rds file.
                    Your mcmc results will not be saved on your hard drive. If you do not output to a object, your results will be lost.
                    Continue? (Y or N):"))
    cleanup <- ifelse(ans=="Y", TRUE, FALSE)
  }
  if(saveRDS){
    if(is.null(file)){
      saveRDS(chain, file=paste(bayouFit$dir, outname, ".chain.rds",sep=""))
      if(verbose) {
        cat(paste("file saved to", paste(bayouFit$dir,"/",outname,".chain.rds\n",sep="")))
      }
    } else {
      saveRDS(chain, file=file)
      if(verbose) {
      cat(paste("file saved to", file))
      }
    }
  }
  if(cleanup){
    if(bayouFit$tmpdir){
      unlink(dir,T,T)
      if(verbose) {
        cat(paste("deleting temporary directory", dir))
      }
    } else {
      file.remove(paste(dir, outname, ".loc", sep=""))
      file.remove(paste(dir, outname, ".t2", sep=""))
      file.remove(paste(dir, outname, ".sb", sep=""))
      file.remove(paste(dir, outname, ".pars", sep=""))
      file.remove(paste(dir, outname, ".rjpars", sep=""))
    }
    }
  return(chain)
}

#' Calculate Gelman's R statistic
#'
#' @param parameter The name or number of the parameter to calculate the statistic on
#' @param chain1 The first bayouMCMC chain
#' @param chain2 The second bayouMCMC chain
#' @param freq The interval between which the diagnostic is calculated
#' @param start The first sample to calculate the diagnostic at
#' @param plot A logical indicating whether the results should be plotted
#' @param ... Optional arguments passed to \code{gelman.diag(...)} from the \code{coda} package
#' @return A data frame with two columns giving the R statistic and its 95 percent upper CI.
#' @export
gelman.R <- function(parameter,chain1,chain2,freq=20,start=1,
                     plot=TRUE, ...){
  R <- NULL
  R.UCI <- NULL
  int <- seq(start,length(chain1[[parameter]]),freq)
  for(i in 1:length(int)){
    chain.list <- mcmc.list(mcmc(chain1[[parameter]][1:int[i]]),mcmc(chain2[[parameter]][1:int[i]]))
    GD <- gelman.diag(chain.list)
    R[i] <- GD$psrf[1]
    R.UCI[i] <- GD$psrf[2]
  }
  if(plot==TRUE){
    plot(chain1$gen[int],R,main=paste("Gelman's R:",parameter),xlab="Generation",ylab="R", ...)
    lines(chain1$gen[int],R,lwd=2)
    lines(chain1$gen[int],R.UCI,lty=2)
  }
  return(data.frame("R"=R,"UCI.95"=R.UCI))
}

# Function for calculation of the posterior quantiles. Only needed for simulation study, not generally called by the user.
.posterior.Q <- function(parameter,chain1,chain2,pars,burnin=0.3){
  postburn <- round(burnin*length(chain1$gen),0):length(chain1$gen)
  chain <- mcmc.list(mcmc(chain1[[parameter]][postburn]),mcmc(chain2[[parameter]][postburn]))
  posterior.q <- summary(chain,quantiles=seq(0,1,0.005))$quantiles
  q <- which(names(sort(c(pars[[parameter]],posterior.q)))=="")
  Q <- ((q-1)/2-0.25)/100#((q-1)+(simpar$pars$alpha-posterior.q[q-1])/(posterior.q[q+1]-posterior.q[q-1]))/100
  Q
}

#' Return a posterior of shift locations
#'
#' @param chain A bayouMCMC chain
#' @param tree A tree of class 'phylo'
#' @param burnin A value giving the burnin proportion of the chain to be discarded
#' @param simpar An optional bayou formatted parameter list giving the true values (if data were simulated)
#' @param mag A logical indicating whether the average magnitude of the shifts should be returned
#'
#' @return A data frame with rows corresponding to postordered branches. \code{pp} indicates the
#' posterior probability of the branch containing a shift. \code{magnitude of theta2} gives the average
#' value of the new optima after a shift. \code{naive SE of theta2} gives the standard error of the new optima
#' not accounting for autocorrelation in the MCMC and \code{rel location} gives the average relative location
#' of the shift on the branch (between 0 and 1 for each branch).
#'
#' @export
Lposterior <- function(chain,tree,burnin=0, simpar=NULL,mag=TRUE){
  pb.start <- ifelse(burnin>0,round(length(chain$gen)*burnin,0),1)
  postburn <- pb.start:length(chain$gen)
  chain <- lapply(chain, function(x) x[postburn])
  ntips <- length(tree$tip.label)
  shifts <- t(sapply(chain$sb,function(x) as.numeric(1:nrow(tree$edge) %in% x)))
  theta <- sapply(1:length(chain$theta),function(x) chain$theta[[x]][chain$t2[[x]]])
  branch.shifts <- chain$sb
  theta.shifts <- tapply(unlist(theta),unlist(branch.shifts),mean)
  theta.locs <- tapply(unlist(chain$loc), unlist(branch.shifts), mean)
  thetaSE <- tapply(unlist(theta),unlist(branch.shifts),function(x) sd(x)/sqrt(length(x)))
  N.theta.shifts <- tapply(unlist(branch.shifts),unlist(branch.shifts),length)
  root.theta <- sapply(chain$theta,function(y) y[1])
  OS <- rep(NA,length(tree$edge[,1]))
  OS[as.numeric(names(theta.shifts))] <- theta.shifts
  SE <- rep(NA,length(tree$edge[,1]))
  SE[as.numeric(names(thetaSE))] <- thetaSE
  locs <- rep(NA,length(tree$edge[,1]))
  locs[as.numeric(names(theta.locs))] <- theta.locs
  shifts.tot <- apply(shifts,2,sum)
  shifts.prop <- shifts.tot/length(chain$gen)
  all.branches <- rep(0,nrow(tree$edge))
  Lpost <- data.frame("pp"=shifts.prop,"magnitude of theta2"=OS, "naive SE of theta2"=SE,"rel location"=locs/tree$edge.length)
  return(Lpost)
}

# Discards burnin
#
.discard.burnin <- function(chain,burnin.prop=0.3){
  lapply(chain,function(x) x[(burnin.prop*length(x)):length(x)])
}

# Tuning function, not currently used.
#.tune.D <- function(D,accept,accept.type){
#  tuning.samp <- (length(accept)/2):length(accept)
#  acc <- tapply(accept[tuning.samp],accept.type[tuning.samp],mean)
#  acc.length <- tapply(accept[tuning.samp],accept.type[tuning.samp],length)
#  acc.tune <- acc/0.25
#  acc.tune[acc.tune<0.5] <- 0.5
#  acc.tune[acc.tune>2] <- 2
#  D$ak <- acc.tune['alpha']*D$ak
#  D$sk <- acc.tune['sig2']*D$sk
#  D$tk <- acc.tune['theta']*D$tk
#  D$bk <- D$tk*2
#  D <- lapply(D,function(x){ names(x) <- NULL; x})
#  return(list("D"=D,"acc.tune"=acc.tune))
#}

#' Utility function for retrieving parameters from an MCMC chain
#'
#' @param i An integer giving the sample to retrieve
#' @param chain A bayouMCMC chain
#' @param model The parameterization used, either "OU", "QG" or "OUrepar"
#'
#' @return A bayou formatted parameter list
#'
#' @export pull.pars
pull.pars <- function(i,chain,model="OU"){
  if(is.character(model)){
    model.pars <- switch(model, "OU"=model.OU, "QG"=model.QG, "OUrepar"=model.OUrepar)#, "bd"=model.bd)
  } else {
    model.pars <- model
    model <- "Custom"
  }
  parorder <- c(model.pars$parorder, model.pars$shiftpars)
  pars <- lapply(parorder,function(x) chain[[x]][[i]])
  names(pars) <- parorder
  return(pars)
}


#' Combine mcmc chains
#'
#' @param chain.list The first chain to be combined
#' @param thin A number or vector specifying the thinning interval to be used. If a single value,
#' then the same proportion will be applied to all chains.
#' @param burnin.prop A number or vector giving the proportion of burnin from each chain to be
#' discarded. If a single value, then the same proportion will be applied to all chains.
#'
#' @return A combined bayouMCMC chain
#'
#' @export
combine.chains <- function(chain.list, thin=1, burnin.prop=0){
  nns <- lapply(chain.list, function(x) names(x))
  if(length(burnin.prop) == 1){
    burnins <- rep(burnin.prop, length(chain.list))
  } else burnins <- burnin.prop
  if(length(thin) == 1){
    thins <- rep(thin, length(chain.list))
  }
  Ls <- sapply(chain.list, function(x) length(x$gen))
  if(!all(sapply(nns, function(x) setequal(nns[[1]], x)))){
    stop ("Not all chains have the same named elements and cannot be combined")
  } else {
    nn <- nns[[1]]
  }
  for(i in 1:length(chain.list)) chain.list[[i]]$gen <- chain.list[[i]]$gen + 0.1*i
  postburns <- lapply(1:length(chain.list), function(x) seq(max(c(floor(burnins[x]*Ls[x]),1)), Ls[x], thins[x]))
  chains <- setNames(vector("list", length(nns[[1]])), nns[[1]])
  attributes(chains) <- attributes(chain.list[[1]])
  for(i in 1:length(nn)){
    chains[[nn[i]]] <- do.call(c, lapply(1:length(chain.list), function(x) chain.list[[x]][[nn[i]]][postburns[[x]]]))
  }
  attributes(chains)$burnin <- 0
  return(chains)
}


#' S3 method for printing bayouMCMC objects
#'
#' @param x A mcmc chain of class 'bayouMCMC' produced by the function bayou.mcmc and loaded into the environment using load.bayou
#' @param ... Additional arguments
#'
#' @return **No return value**, called for **side effects**.
#' This function prints a summary of a **bayouMCMC** object, including
#' details about the MCMC run, burn-in proportion, and key parameter statistics.

#' @export
#' @method print bayouMCMC
print.bayouMCMC <- function(x, ...){

  cat("bayouMCMC object \n")

  nn <- names(x)
  if("model.pars" %in% names(attributes(x))){
    model.pars <- attributes(x)$model.pars
    cat("shift-specific/reversible-jump parameters: ", model.pars$rjpars, "\n", sep="")
    o <- match(c("gen", "lnL", "prior", model.pars$parorder, model.pars$shiftpars), names(x))
  } else {
    message("No model specification found in attributes", "\n")
    o <- 1:length(x)
  }
  for(i in o){
    cat("$", nn[i], "     ", sep="")
    cat(class(x[[i]]), " with ", length(x[[i]]), " elements", "\n", sep="")
    if(inherits(x[[i]], "numeric") & length(x[[i]]) > 0) cat(x[[i]][1:min(c(length(x[[i]]), 5))])
    if(inherits(x[[i]], "list") & length(x[[i]]) > 0) print(x[[i]][1:min(c(length(x[[i]]), 2))])
    if(inherits(x[[i]], "numeric") & length(x[[i]]) > 5) cat(" ...", "\n")
    if(inherits(x[[i]], "list") & length(x[[i]]) > 2) cat(" ...", "\n")
    cat("\n")
  }
}

.buildControl <- function(pars, prior, move.weights=list("alpha"=4,"sig2"=2,"theta"=4, "slide"=2,"k"=10)){
  splitmergepars <- attributes(prior)$splitmergepars
  ct <- unlist(move.weights)
  total.weight <- sum(ct)
  ct <- ct/sum(ct)
  ct <- as.list(ct)
  if(move.weights$k > 0){
    bmax <- attributes(prior)$parameters$dsb$bmax
    nbranch <- 2*attributes(prior)$parameters$dsb$ntips-2
    prob <- attributes(prior)$parameters$dsb$prob
    if(length(prob)==1){
      prob <- rep(prob, nbranch)
      prob[bmax==0] <- 0
    }
    if(length(bmax)==1){
      bmax <- rep(bmax, nbranch)
      bmax[prob==0] <- 0
    }
    type <- max(bmax)
    if(type == Inf){
      maxK <- attributes(prior)$parameters$dk$kmax
      maxK <- ifelse(is.null(maxK), attributes(prior)$parameters$dsb$ntips*2, maxK)
      maxK <- ifelse(!is.finite(maxK), attributes(prior)$parameters$dsb$ntips*2, maxK)
      bdFx <- attributes(prior)$functions$dk
      bdk <- 1-sqrt(cumsum(c(0,bdFx(0:maxK,log=FALSE))))*0.9
    }
    if(type==1){
      maxK <- nbranch-sum(bmax==0)
      bdk <- (maxK - 0:maxK)/maxK
    }
    ct$bk <- bdk
    ct$dk <- (1-bdk)
    ct$sb <- list(bmax=bmax, prob=prob)
  }
  if("k" %in% names(move.weights) & "slide" %in% names(move.weights)){
    if(move.weights$slide > 0 & move.weights$k ==0){
      bmax <- attributes(prior)$parameters$dsb$bmax
      prob <- attributes(prior)$parameters$dsb$prob
      ct$sb <- list(bmax=bmax, prob=prob)
      }
  }
  attributes(ct)$splitmergepars <- splitmergepars
  return(ct)
}

#bdFx <- function(ct,max,pars,...){
#  dk <- cumsum(c(0,dpois(0:max,pars$lambda*T)))
#  bk <- 0.9-dk+0.1
#  return(list(bk=bk,dk=dk))
#}

.updateControl <- function(ct, pars, fixed){
  if(pars$k==0){
    ctM <- ct
    R <- sum(unlist(ctM[names(ctM) %in% c("slide","pos")],F,F))
    ctM[names(ctM) == "slide"] <- 0
    nR <- !(names(ctM) %in% c(fixed, "bk","dk","slide", "sb"))
    ctM[nR] <-lapply(ct[names(ctM)[nR]],function(x) x+R/sum(nR))
    ct <- ctM
  }
  return(ct)
}


.store.bayou <- function(i, pars, ll, pr, store, samp, chunk, parorder, files){
  if(i%%samp==0){
    j <- (i/samp)%%chunk
    if(j!=0 & i>0){
      store$sb[[j]] <- pars$sb
      store$t2[[j]] <- pars$t2
      store$loc[[j]] <- pars$loc
      parline <- unlist(pars[parorder])
      store$out[[j]] <- c(i,ll,pr,parline)
    } else {
      #chunk.mapst1[chunk,] <<- maps$t1
      #chunk.mapst2[chunk,] <<- maps$t2
      #chunk.mapsr2[chunk,] <<- maps$r2
      store$sb[[chunk]] <- pars$sb
      store$t2[[chunk]] <- pars$t2
      store$loc[[chunk]] <- pars$loc
      parline <- unlist(pars[parorder])
      store$out[[chunk]] <- c(i,ll,pr,parline)
      #write.table(chunk.mapst1,file=mapst1,append=TRUE,col.names=FALSE,row.names=FALSE)
      #write.table(chunk.mapst2,file=mapst2,append=TRUE,col.names=FALSE,row.names=FALSE)
      #write.table(chunk.mapsr2,file=mapsr2,append=TRUE,col.names=FALSE,row.names=FALSE)
      lapply(store$out,function(x) cat(c(x,"\n"),file=files$pars.output,append=TRUE))
      lapply(store$sb,function(x) cat(c(x,"\n"),file=files$mapsb,append=TRUE))
      lapply(store$t2,function(x) cat(c(x,"\n"),file=files$mapst2,append=TRUE))
      lapply(store$loc,function(x) cat(c(x,"\n"),file=files$mapsloc,append=TRUE))
      #chunk.mapst1 <<- matrix(0,ncol=dim(oldmap)[1],nrow=chunk)
      #chunk.mapst2 <<- matrix(0,ncol=dim(oldmap)[1],nrow=chunk)
      #chunk.mapsr2 <<- matrix(0,ncol=dim(oldmap)[1],nrow=chunk)
      #out <<- list()
      store$sb <- list()
      store$t2 <- list()
      store$loc <- list()
      store$out <- list()
    }
  }
  return(store)
}

#' S3 method for printing bayouFit objects
#'
#' @param x A 'bayouFit' object produced by \code{bayou.mcmc}
#' @param ... Additional parameters passed to \code{print}
#'
#' @return **No return value**, called for **side effects**.
#' This function prints a summary of a **bayou model fit**, including
#' posterior probabilities, model parameters, and key statistics.
#'
#' @export
#' @method print bayouFit
print.bayouFit <- function(x, ...){

  cat("bayou modelfit\n")
  cat(paste(x$model, " parameterization\n\n",sep=""))
  cat("Results are stored in directory\n")

  out<-(paste(x$dir, x$outname,".*",sep=""))

  cat(out,"\n")
  cat(paste("To load results, use 'load.bayou(bayouFit)'\n\n",sep=""))
  cat(paste(length(x$accept), " generations were run with the following acceptance probabilities:\n"))

  accept.prob <- round(tapply(x$accept,x$accept.type,mean),2)
  prop.N <- tapply(x$accept.type,x$accept.type,length)
  print(accept.prob, ...)
  cat(" Total number of proposals of each type:\n")
  print(prop.N, ...)

}

#' Set the burnin proportion for bayouMCMC objects
#'
#' @param chain A bayouMCMC chain or an ssMCMC chain
#' @param burnin The burnin proportion of samples to be discarded from downstream analyses.
#'
#' @return A bayouMCMC chain or ssMCMC chain with burnin proportion stored in the attributes.
#'
#' @export
set.burnin <- function(chain, burnin=0.3){
  cl <- class(chain)[1]
  attributes(chain)$burnin = burnin
  if(cl=="bayouMCMC") {
    class(chain) <- c("bayouMCMC", "list")
  }
  if(cl=="ssMCMC"){
    class(chain) <- c("ssMCMC", "list")
  }
  return(chain)
}

#' S3 method for summarizing bayouMCMC objects
#'
#' @param object A bayouMCMC object
#' @param ... Additional arguments passed to \code{print}
#'
#' @return An invisible list with two elements: \code{statistics} which provides
#' summary statistics for a bayouMCMC chain, and \code{branch.posteriors} which summarizes
#' branch specific data from a bayouMCMC chain.
#'
#' @export
#' @method summary bayouMCMC
summary.bayouMCMC <- function(object, ...){
  tree <- attributes(object)$tree
  model <- attributes(object)$model
  model.pars <- attributes(object)$model.pars
  if(is.null(attributes(object)$burnin)){
    start <- 1
  } else {
    start <- round(attributes(object)$burnin*length(object$gen),0)
  }
  if(is.null(attributes(object)$pp.cutoff)){
    pp.cutoff <- 0.1
  } else {
    pp.cutoff <- attributes(object)$pp.cutoff
  }
  cat("bayou MCMC chain:", max(object$gen), "generations\n")
  cat(length(object$gen), "samples, first", eval(start), "samples discarded as burnin\n")
  postburn <- start:length(object$gen)
  object <- lapply(object,function(x) x[postburn])
  parorder <- c("lnL", "prior", model.pars$parorder)
  outpars <- parorder[!(parorder %in% model.pars$rjpars)]
  summat <- matrix(unlist(object[outpars]),ncol=length(outpars))
  colnames(summat) <- outpars
  if(length(model.pars$rjpars) > 0){
    for(i in model.pars$rjpars){
      summat <- cbind(summat, sapply(object[[i]],function(x) x[1]))
      colnames(summat)[ncol(summat)] <- paste("root.",i,sep="")
    }
    sum.rjpars <- lapply(model.pars$rjpars, function(x) summary(coda::mcmc(unlist(object[[x]]))))
  } else {
    sum.rjpars <- NULL
  }
  #summat <- cbind(summat, "root"=sapply(object$theta,function(x) x[1]))
  sum.1vars <- summary(coda::mcmc(summat))
  HPDs <- apply(summat,2,function(x) HPDinterval(mcmc(x), 0.95))
  statistics <- rbind(cbind(sum.1vars$statistics, "Effective Size" = effectiveSize(summat), "HPD95Lower"=HPDs[1,], "HPD95Upper"=HPDs[2,]))
  if(length(model.pars$rjpars) > 0){
    for(i in 1:length(model.pars$rjpars)){
      statistics <- rbind(statistics,c(sum.rjpars[[i]]$statistics[1:2],rep(NA,5)))
      rownames(statistics)[nrow(statistics)] <- paste("all", model.pars$rjpars[i],sep=" ")
    }
  }
  cat("\n\nSummary statistics for parameters:\n")
  print(statistics, ...)
  Lpost <- Lposterior(object, tree)
  Lpost.sorted <- Lpost[order(Lpost[,1],decreasing=TRUE),]
  cat("\n\nBranches with posterior probabilities higher than ", pp.cutoff, ":\n")
  print(Lpost.sorted[Lpost.sorted[,1]>pp.cutoff,], ...)
  out <- list(statistics=statistics, branch.posteriors=Lpost)
  invisible(out)
}

# Stores a flat file
.store.bayou2 <- function(i, pars, outpars, rjpars, ll, pr, store, samp, chunk, parorder, files, ref=numeric(0)){
  if(i%%samp==0){
    j <- (i/samp)%%chunk
    if(j!=0 & i>0){
      store$sb[[j]] <- pars$sb
      store$t2[[j]] <- pars$t2
      store$loc[[j]] <- pars$loc
      parline <- unlist(pars[outpars])
      store$out[[j]] <- c("gen"=i, "lik"=ll, "prior"=pr, "ref"=ref, parline)
      store$rjpars[[j]] <- unlist(pars[rjpars])
    } else {
      store$sb[[chunk]] <- pars$sb
      store$t2[[chunk]] <- pars$t2
      store$loc[[chunk]] <- pars$loc
      parline <- unlist(pars[outpars])
      store$out[[chunk]] <- c("gen"=i, "lik"=ll, "prior"=pr, "ref"=ref, parline)
      store$rjpars[[chunk]] <- unlist(pars[rjpars])
      lapply(store$out,function(x) cat(c(x,"\n"), file=files$pars.output,append=TRUE))
      lapply(store$rjpars,function(x) cat(c(x,"\n"),file=files$rjpars,append=TRUE))
      lapply(store$sb,function(x) cat(c(x,"\n"),file=files$mapsb,append=TRUE))
      lapply(store$t2,function(x) cat(c(x,"\n"),file=files$mapst2,append=TRUE))
      lapply(store$loc,function(x) cat(c(x,"\n"),file=files$mapsloc,append=TRUE))
      store <- list()
    }
  }
  return(store)
}
