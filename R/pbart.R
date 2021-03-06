
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

pbart=function( 
x.train, y.train, x.test=matrix(0.0,0,0),
k=2.0, power=2.0, base=.95,
binaryOffset=NULL,
ntree=200L, numcut=100L,
ndpost=1000L, nskip=100L,
keepevery=1L,
nkeeptrain=ndpost%/%keepevery, nkeeptest=ndpost%/%keepevery,
nkeeptestmean=ndpost%/%keepevery, nkeeptreedraws=ndpost%/%keepevery,
printevery=100, transposed=FALSE,
treesaslists=FALSE
)
{
#--------------------------------------------------
nd = ndpost
burn = nskip
#--------------------------------------------------
#data 
n = length(y.train)

if(length(binaryOffset)==0) binaryOffset <- 0
##else binaryOffset=qnorm(mean(y.train))

if(!transposed) {
    x.train = t(x.train)
    x.test = t(x.test)
}

if(n!=ncol(x.train))
    stop('The length of y.train and the number of rows in x.train must be identical')

p = nrow(x.train)
np = ncol(x.test)

#--------------------------------------------------
#set  nkeeps for thinning
if((nkeeptrain!=0) & ((ndpost %% nkeeptrain) != 0)) {
   nkeeptrain=ndpost
   cat('*****nkeeptrain set to ndpost\n')
}
if((nkeeptest!=0) & ((ndpost %% nkeeptest) != 0)) {
   nkeeptest=ndpost
   cat('*****nkeeptest set to ndpost\n')
}
if((nkeeptestmean!=0) & ((ndpost %% nkeeptestmean) != 0)) {
   nkeeptestmean=ndpost
   cat('*****nkeeptestmean set to ndpost\n')
}
if((nkeeptreedraws!=0) & ((ndpost %% nkeeptreedraws) != 0)) {
   nkeeptreedraws=ndpost
   cat('*****nkeeptreedraws set to ndpost\n')
}
#--------------------------------------------------
#prior
## nu=sigdf
## if(is.na(lambda)) {
##    if(is.na(sigest)) {
##       if(p < n) {
##          df = data.frame(t(x.train),y.train)
##          lmf = lm(y.train~.,df)
##          rm(df)
##          sigest = summary(lmf)$sigma
##       } else {
##          sigest = sd(y.train)
##       }
##    }
##    qchi = qchisq(1.0-sigquant,nu)
##    lambda = (sigest*sigest*qchi)/nu #lambda parameter for sigma prior
## } 

## if(is.na(sigmaf)) {
##    tau=(max(y.train)-min(y.train))/(2*k*sqrt(ntree));
## } else {
##    tau = sigmaf/sqrt(ntree)
## }
#--------------------------------------------------
#call
res = .Call("cpbart",
            n,  #number of observations in training data
            p,  #dimension of x
            np, #number of observations in test data
            x.train,   #p*n training data x
            y.train,   #n*1 training data y
            x.test,    #p*np test data x
            ntree,
            numcut,
            nd,
            burn,
            power,
            base,
            binaryOffset, 
            3/(k*sqrt(ntree)),
            #nu,
            #lambda,
            #sigest,
            #w,
            nkeeptrain,
            nkeeptest,
            nkeeptestmean,
            nkeeptreedraws,
            printevery,
            treesaslists
)
res$binaryOffset=binaryOffset
res$yhat.train.mean = res$yhat.train.mean+binaryOffset
res$yhat.train = res$yhat.train+binaryOffset
res$yhat.test.mean = res$yhat.test.mean+binaryOffset
res$yhat.test = res$yhat.test+binaryOffset
##res$nkeeptreedraws=nkeeptreedraws
return(res)
}
