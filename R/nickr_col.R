#' Check that a condition holds on the columns of data between pipe stages.
#'
#' @param .data Incoming data (omitted if in pipe).
#' @param ... Column-wise condition expressions to test.
#' @param msg User message to display if test fails.
#' @param logger Function to call with message (e.g., `warning` or `stop`).
#' @param active Is this check turned on (default TRUE). Set FALSE to disable test (e.g., in production).
#'
#' @return Input data without modification.
#'
#' @export

nickr_col <- function(.data, ..., msg = "nickr", logger = stop, active = TRUE) {

  # If not active, return immediately.
  if (!active) {
    return(invisible(.data))
  }

  # Check.
  conditions <- rlang::enquos(...)
  specifics <- ""
  for (cond in conditions) {
    # Check this condition.
    cond_result <- all(rlang::eval_tidy(cond, .data))

    # Accumulate error messages.
    if (!cond_result) {
      this_msg <- deparse(rlang::quo_get_expr(cond))
      if (specifics == "") {
        specifics <- this_msg
      } else {
        specifics <- paste(specifics, this_msg, sep = ", ")
      }
    }
  }

  # Report.
  if (specifics != "") {
    msg <- paste0(msg, ": ", specifics)
    logger(msg)
  }

  # Return data for the next stage in the pipe.
  invisible(.data)
}
