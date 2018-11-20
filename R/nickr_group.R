#' Check that a condition holds on groups of data between pipe stages.
#'
#' @param .data Incoming data (omitted if in pipe).
#' @param cond Condition written using column names and `.r` for the row index.
#' @param msg User message to display if test fails.
#' @param active Is this check turned on (default TRUE). Set FALSE to disable test (e.g., in production).
#' @param logger Function to call with message (e.g., `warning` or `stop`).
#'
#' @return Input data without modification.
#'
#' @export

nickr_group <- function(.data, cond, msg = "nickr_row", active = TRUE, logger = stop) {

  if (active) {
    cond <- rlang::enquo(cond)
    if (!all(dplyr::pull(dplyr::summarize(.data, !!cond)))) {
      logger(msg)
    }
  }

  # Return data for the next stage in the pipe.
  invisible(.data)
}
