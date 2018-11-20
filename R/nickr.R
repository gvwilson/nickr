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
#' @examples
#' \dontrun{
#' data %>% mutate(...) %>%
#'
#'   # Always check that age is greater than or equal to 18.
#'   nickr_col(age >= 18) %>%
#'
#'   # Only check that age lies between minimum and maximum when not in production.
#'   nickr_col((min_age <= age) && (age <= max_age), active = !IN.PRODUCTION)
#'
#'   filter(...) %>%
#'
#'   # Generate a warning if there is more than one NA in any given row.
#'   nickr_row(sum(is.na(...)) <= 1, logger = warning) %>%
#'
#'   group_by(person_id) %>%
#'
#'   # Check that there are exactly two records for each person.
#'   nickr_group(n() == 2, msg = "Expected two records per person.") %>%
#'
#'   ggplot(...)
#' }
#'
#' @author Greg Wilson, \email{greg.wilson@rstudio.com}
#' @docType package
#' @name nickr
NULL
