\name{pred.robustgam}
\alias{pred.robustgam}
\title{
Prediction method for robustgam
}

\description{
A prediction function for output of \code{\link{robustgam}}.
}

\usage{
pred.robustgam(fit, data, type="response")
}

\arguments{
\item{fit}{fit object of \code{\link{robustgam}}}
\item{data}{a data.frame object. Call the variable \code{X} if there is only one covariate. Otherwise, call the first variable \code{X1}, the second one \code{X2}, and so on.}
\item{type}{type of output}
}

\value{
\item{predict.comp}{a matrix containing the individual additive components for each covariates.}
\item{predict.values}{the type of output required by \code{type}. For example, if \code{type="response"}, the predicted values of the data is outputed.}
}

\references{
Raymond K. W. Wong, Fang Yao and Thomas C. M. Lee (2013) \emph{Robust Estimation for Generalized Additive Models}. \emph{Journal of Graphical and Computational Statistics}, to appear.
}

\author{
Raymond K. W. Wong <raymondkww.dev@gmail.com>
}

\seealso{
\code{\link{robustgam}}
}

\examples{
# load library
library(robustgam)

# test function
test.fun <- function(x, ...) {
  return(2*sin(2*pi*(1-x)^2))
}

# some setting
set.seed(1234)
true.family <- poisson()
out.prop <- 0.05
n <- 100

# generating dataset for poisson case
x <- runif(n)
x <- x[order(x)]
true.eta <- test.fun(x)
true.mu <- true.family$linkinv(test.fun(x))
y <- rpois(n, true.mu) # for poisson case

# create outlier for poisson case
out.n <- trunc(n*out.prop)
out.list <- sample(1:n, out.n, replace=FALSE)
y[out.list] <- round(y[out.list]*runif(out.n,min=3,max=5)^(sample(c(-1,1),out.n,TRUE)))

# robust GAM fit
robustfit <- robustgam(x, y, family=true.family, p=3, c=1.6, sp=0.000143514, show.msg=FALSE,
  smooth.basis='tp')

# ordinary GAM fit
nonrobustfit <- gam(y~s(x, bs="tp", m=3),family=true.family) # m = p for 'tp'

# prediction
x.new <- seq(range(x)[1], range(x)[2], len=1000)
robustfit.new <- pred.robustgam(robustfit, data.frame(X=x.new))$predict.values
nonrobustfit.new <- as.vector(predict.gam(nonrobustfit,data.frame(x=x.new),type="response"))

# plot
plot(x, y)
lines(x.new, true.family$linkinv(test.fun(x.new)), col="blue")
lines(x.new, robustfit.new, col="red")
lines(x.new, nonrobustfit.new, col="green")
legend(0.6, 23, c("true mu", "robust fit", "nonrobust fit"), col=c("blue","red","green"),
  lty=c(1,1,1))
}
