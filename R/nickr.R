#' Check conditions in pipelines, logging messages if tests fail.
#'
#' @author Greg Wilson, \email{greg.wilson@rstudio.com}
#' @docType package
#' @name nickr
NULL

#' Check that a condition holds in a pipe, logging if not.
#'
#' @param .data Incoming data (omitted if in pipe).
#' @param cond Column-wise condition to test.
#' @param message User message to display if test fails.
#' @param logger Function to call with message (e.g., `warning` or `stop`).
#'
#' @return Input data without modification.
#'
#' @export

nickr <- function(.data, cond, message, logger = stop) {
  cond <- rlang::enquo(cond)
  if (!all(dplyr::transmute(.data, !!cond)[[1]])) {
    message <- paste0(message, ': ', as.character(cond))
    if (is.null(logger)) {
      stop(message)
    } else {
      logger(message)
    }
  }
  invisible(.data)
}
