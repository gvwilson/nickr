#' Check that a condition holds on the rows of data between pipe stages.
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

nickr_row <- function(.data, cond, msg = "nickr_row", active = TRUE, logger = stop) {

  # Only run check if active.
  if (active) {

    # Augment data with row index.
    augmented <- tibble::rowid_to_column(.data, ".r")

    # Check by row, negating so that 'problems' is TRUE where the condition failed.
    cond <- rlang::enquo(cond)
    problems <- purrr::pmap_lgl(augmented, function(...) {
      args <- list(...)
      rlang::eval_tidy(cond, args)
    })
    problems <- !problems # so that the negation is highly visible

    # Report.
    if (any(problems)) {
      msg <- paste0(msg, ": ", paste(augmented$.r[problems], collapse = " "))
      logger(msg)
    }
  }

  # Return data for the next stage in the pipe.
  invisible(.data)
}
