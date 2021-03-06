% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/net.utils.R
\name{copy_nwattr_to_datattr}
\alias{copy_nwattr_to_datattr}
\title{Copies Vertex Attributes From Network to dat List}
\usage{
copy_nwattr_to_datattr(dat)
}
\arguments{
\item{dat}{Master data object passed through \code{netsim} simulations.}
}
\description{
Copies the vertex attributes stored on the network object to the
             master attr list in the dat data object.
}
\seealso{
\code{\link{get_formula_term_attr}}, \code{\link{get_attr_prop}},
         \code{\link{auto_update_attr}}, and \code{\link{copy_datattr_to_nwattr}}.
}
\keyword{internal}
\keyword{netUtils}
