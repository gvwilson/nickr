#' Verify conditions on data in tidyverse pipelines.
#'
#' This package provides functions that can be inserted between stages of a
#' pipeline to check that data satisfies user-specified conditions without
#' modifying the data.  Users can specify conditions on rows, columns, or groups
#' as expressions, control the way that error reports are logged, and enable or
#' disable filters selectively so that they can be left in place in production.
#'
#' nickr is inspired by Stochastic Solutions' "test-driven data analysis"
#' \url{http://www.tdda.info/} and Poisson Consulting's checkr package
#' \url{https://poissonconsulting.github.io/checkr/}.
#'
#' @name nickr
#' @author Greg Wilson, \email{greg.wilson@rstudio.com}
#' @docType package
#'
#' @examples
#' \dontrun{
#' # This example is not run because it deliberately raises errors.
#'
#' # Settings that checks might rely on.
#' IN.PRODUCTION <- TRUE
#' MIN_AGE <- 18
#' MAX_AGE <- 100
#'
#' # Example data for illustrative purposes only.
#' data <- tribble(
#'   ~record_id, ~person_id, ~age,
#'   100,         "alpha",    17,
#'   200,         "alpha",    34,
#'   300,         "beta",     21,
#'   400,         "gamma",    NA,
#'   500,         "gamma",    26
#' )
#'
#' # How the functions in this package might be used in analysis.
#' data %>%
#'
#'   # Always check that age is greater than or equal to 18.
#'   # (Would raise error in this example because of record 100.)
#'   nickr_col(age >= 18) %>%
#'
#'   # Only check that age lies between minimum and maximum when not in production.
#'   # (Would not raise an error in this example because 'active' would be FALSE.)
#'   nickr_col((MIN_AGE <= age) && (age <= MAX_AGE), active = !IN.PRODUCTION)
#'
#'   filter(person_id != "alpha") %>%
#'
#'   # Generate a warning if there are any surviving NAs in age.
#'   # (Would generate a warning in this example because of record 400.)
#'   nickr_row(is.na(age), logger = warning) %>%
#'
#'   group_by(person_id) %>%
#'
#'   # Check that there are exactly two records for each person.
#'   # (Would raise an error in this example because there is only one record for "beta".)
#'   nickr_group(n() == 2, msg = "Expected two records per person.") %>%
#'
#'   summarize(midpoint = mean(age))
#' }
NULL
