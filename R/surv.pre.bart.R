
## BART: Bayesian Additive Regression Trees
## Copyright (C) 2017 Robert McCulloch and Rodney Sparapani

## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program; if not, a copy is available at
## https://www.R-project.org/Licenses/GPL-2


## you call this function before surv.bart()
## this function takes traditional time/delta
## survival variables and regressors (if any)
## and it constructs the corresponding
## tx.train, y.train and tx.test appropriate
## for use with pbart()

surv.pre.bart <- function(
                      times,
                      ## vector of survival times
                      
                      delta,
                      ## vector of event indicators: 1 event, 0 censoring
    
                      x.train=NULL,
                      ## matrix of covariate regressors
                      ## can be NULL, i.e. KM analog
                      
                      x.test=NULL
                      ## matrix of covariate regressors at tx.test settings
                      ) {
    ## currently does not handle time dependent Xs
    ## can be extended later
    ## most likely via the alternative counting process notation

    binaryOffset <- qnorm(1-exp(-sum(delta)/sum(times)))

    N <- length(times)

    if(N!=length(delta))
        stop('The length of times and delta must be identical')

    if(length(x.train)>0 && N!=nrow(x.train))
        stop('The length of times and the number of rows in x.train, if any, must be identical')

    events <- unique(sort(times))
    ## time grid of events including censoring times

    K <- length(events)

    y.train <- integer(N) ## y.train is at least N long
            
    k <- 1
        
    for(i in 1:N) for(j in 1:K) if(events[j] <= times[i]) {
        y.train[k] <- delta[i]*(times[i] == events[j])

        k <- k+1
    }

    m <- length(y.train)

    if(length(x.train)==0) {
        p <- 0
        n <- 1
        
        X.train <- matrix(nrow=m, ncol=1, dimnames=list(NULL, 't'))
    } else {
        p <- ncol(x.train)
        
        if(length(x.test)>0) n <- nrow(x.test)
        
        X.train <- matrix(nrow=m, ncol=p+1)

        if(length(dimnames(x.train)[[2]])>0)
            dimnames(X.train)[[2]] <- c('t', dimnames(x.train)[[2]])
        else dimnames(X.train)[[2]] <- c('t', paste0('x', 1:p))
    }
    
    k <- 1
    
    for(i in 1:N) for(j in 1:K) if(events[j] <= times[i]) {
        if(p==0) X.train[k, ] <- c(events[j])
        else X.train[k, ] <- c(events[j], x.train[i, ])

        k <- k+1
    }

    if(p==0 | length(x.test)>0) {
        X.test <- matrix(nrow=K*n, ncol=p+1, dimnames=dimnames(X.train))

        for(i in 1:n) for(j in 1:K) {
            if(p==0) X.test[j, ] <- c(events[j])
            else X.test[(i-1)*K+j, ] <- c(events[j], x.test[i, ])
        }
    }
    else X.test <- matrix(nrow=0, ncol=0)*0
    
    return(list(y.train=y.train, tx.train=X.train, tx.test=X.test, times=events, K=K,
                binaryOffset=binaryOffset))
}
