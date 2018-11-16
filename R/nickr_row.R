#' Check that a condition holds on the rows of data between pipe stages.
#'
#' @param .data Incoming data (omitted if in pipe).
#' @param cond Condition written as one-sided formula with `.x` as the row and `.y` as the row index, e.g., `~ .x$a < .x$b`
#' @param msg User message to display if test fails.
#' @param logger Function to call with message (e.g., `warning` or `stop`).
#' @param active Is this check turned on (default TRUE). Set FALSE to disable test (e.g., in production).
#'
#' @return Input data without modification.
#'
#' @export

nickr_row <- function(.data, cond, msg = "nickr_row", logger = stop, active = TRUE) {

  # Only run check if active.
  if (active) {

    # Convert one-sided formulas to functions.
    cond <- rlang::as_function(cond)

    # Check row by row, flagging problems.
    problems <- vector("logical", nrow(.data))
    ids <- 1:nrow(.data)
    for (i in ids) {
      r <- .data[i,]
      problems[i] <- !cond(r, i)
    }

    # Report.
    if (any(problems)) {
      msg <- paste0(msg, ": ", paste(ids[problems], collapse = " "))
      logger(msg)
    }
  }

  # Return data for the next stage in the pipe.
  invisible(.data)
}
