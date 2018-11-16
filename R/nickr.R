#' Verify conditions on data in tidyverse pipelines.
#'
#' This package provides functions that can be inserted between stages of a
#' tidyverse pipeline to check that data satisfies user-specified conditions
#' without modifying the data.  Users can specify conditions on rows or columns
#' as expressions, control the way that error reports are logged, and enable or
#' disable filters selectively so that they can be left in place in production.
#'
#' nickr is inspired by Stochastic Solutions' "test-driven data analysis"
#' \url{http://www.tdda.info/}. Please see their site for more discussion and a
#' full-featured Python implementation of these ideas.
#'
#' @examples
#' \dontrun{
#' data %>% mutate(...) %>%
#'   nickr_col(18 <= age)
#'   summarize(...) %>%
#'   nickr_col((min_age <= age) && (age <= max_age), active = !IN.PRODUCTION)
#'   filter(...) %>%
#'   nickr_col(!is.null(cohort) && cohort %in% COHORTS, logger = warning) %>%
#'   ggplot(...)
#' }
#'
#' @author Greg Wilson, \email{greg.wilson@rstudio.com}
#' @docType package
#' @name nickr
NULL
