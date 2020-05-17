
#' @title Dynamic Network Updates
#'
#' @description This function handles all calls to the network object contained
#'              on the master dat object handled in \code{netsim}..
#'
#' @param dat Master list object containing a full \code{networkDynamic} object
#'        or networkLite edgelist (if using tergmLite), and other initialization
#'        information passed from \code{\link{netsim}}.
#' @param at Current time step.
#'
#' @export
#'
nwupdate.net <- function(dat, at) {

  groups <- get_param(dat, "groups")
  vital <- get_param(dat, "vital")
  tergmLite <- get_control(dat, "tergmLite")
  status <- get_attr(dat, "status")
  infTime <- get_attr(dat, "infTime")
  active <- get_attr(dat, "active")
  exitTime <- get_attr(dat, "exitTime")

  ## Vital Dynamics

  if (vital == TRUE) {

    ## Arrivals
    if (groups == 1) {
      nArrivals <- get_epi(dat, "a.flow", at)
    } else {
      nArrivals <- c(get_epi(dat, "a.flow", at),
                     get_epi(dat, "a.flow.g2", at))
    }
    if (sum(nArrivals) > 0) {
      index <- at - 1
      nCurr <- get_epi(dat, "num", index)
      newNodes <- (nCurr + 1):(nCurr + sum(nArrivals))
      nwterms <- dat$temp$nwterms
      if (!is.null(nwterms)) {
        curr.tab <- get_attr_prop(dat, nwterms)
        dat <- auto_update_attr(dat, newNodes, curr.tab)
      }
      if (length(unique(sapply(dat$attr, length))) != 1) {
        stop("Attribute list of unequal length. Check arrivals.net module.\n",
             print(cbind(sapply(get_attr_list(dat), length))))
      }
      if (tergmLite == FALSE) {
        dat$nw[[1]] <- add.vertices(dat$nw[[1]], nv = sum(nArrivals))
        dat$nw[[1]] <- activate.vertices(dat$nw[[1]], onset = at, terminus = Inf, v = newNodes)
        dat <- copy_datattr_to_nwattr(dat)
        dat$nw[[1]] <- activate.vertex.attribute(dat$nw[[1]], prefix = "testatus",
                                                 value = status[newNodes],
                                                 onset = at, terminus = Inf,
                                                 v = newNodes)
      }
      if (tergmLite == TRUE) {
        dat$el[[1]] <- add_vertices(dat$el[[1]], nv = sum(nArrivals))
      }
    }


    ## Departures
    inactive <- which(active == 0 & exitTime == at)
    if (length(inactive) > 0) {
      if (tergmLite == FALSE) {
        dat$nw[[1]] <- deactivate.vertices(dat$nw[[1]], onset = at, terminus = Inf,
                                           v = inactive, deactivate.edges = TRUE)
      }
      if (tergmLite == TRUE) {
        dat <- delete_attr(dat, inactive)
        dat$el[[1]] <- delete_vertices(dat$el[[1]], inactive)
      }
    }
  }

  ## Infection
  if (tergmLite == FALSE) {
    idsNewInf <- which(status == "i" & infTime == at)
    if (length(idsNewInf) > 0) {
      dat$nw[[1]] <- activate.vertex.attribute(dat$nw[[1]], prefix = "testatus",
                                               value = "i", onset = at,
                                               terminus = Inf, v = idsNewInf)
    }
  }

  ## Recovery
  if (tergmLite == FALSE) {
    type <- get_control(dat, "type")
    if (type %in% c("SIS", "SIR")) {
      index <- at - 1
      nCurr <- get_epi(dat, "num", index)
      recovState <- ifelse(type == "SIR", "r", "s")
      attr.status <- which(status == recovState)
      nw.status <- which(get_vertex_attribute(dat$nw[[1]], "status") == recovState)
      idsRecov <- setdiff(attr.status, nw.status)
      if (length(idsRecov) > 0) {
        dat$nw[[1]] <- activate.vertex.attribute(dat$nw[[1]], prefix = "testatus",
                                                 value = recovState, onset = at,
                                                 terminus = Inf, v = idsRecov)
      }
    }
  }

  ## Output
  return(dat)
}