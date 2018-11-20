library(tidyverse)

context("Test checks on groups between pipeline stages")

fixture <- function() {
  tibble::tribble(
    ~person, ~month, ~sanity,
    "A",     "Jan",   5,
    "A",     "Mar",   6,
    "B",     "Jan",   4,
    "B",     "Feb",   4,
    "C",     "Feb",   9,
    "C",     "Mar",   8,
    "C",     "Mar",   7
  )
}

captured_msg <- NULL
local_logger <- function(text) {
  captured_msg <<- text
}

test_that("a correct simple expression works without reporting an error", {
  fx <- fixture() %>%
    filter(person != "C")
  result <- fx %>%
    group_by(person) %>%
    nickr_group(n() == 2, msg = "should not appear")
  expect_equal(fx, result)
})

test_that("a false simple expression works without reporting an error", {
  msg <- "test failed"
  expect_error(fixture() %>%
                 group_by(person) %>%
                 nickr_group(n() == 2, msg = msg),
               regexp = msg)
})

test_that("a simple expression produces a warning instead of an error if told to", {
  msg <- "test failed"
  expect_warning(fixture() %>%
                 group_by(person) %>%
                 nickr_group(n() == 2, msg = msg, logger = warning),
               regexp = msg)
})

test_that("a correct expression in a pipe works without error", {
  expect_silent(fixture() %>%
                  group_by(person) %>%
                  nickr_group(min(sanity) > 3, msg = "should not appear") %>%
                  summarize(least = min(sanity)))
})

test_that("a false expression in a pipe works produces an error", {
  msg <- "the error message"
  expect_error(fixture() %>%
                 group_by(person) %>%
                 nickr_group(min(sanity) < 3, msg = msg) %>%
                 summarize(least = min(sanity)),
               regexp = msg)
})

test_that("a false expression in a pipe works produces a warning and the correct result", {
  fx <- fixture()
  expected <- fx %>% group_by(person) %>% summarize(least = min(sanity))
  msg <- "the error message"
  expect_warning(result <- fixture() %>%
                   group_by(person) %>%
                   nickr_group(min(sanity) < 3, msg = msg, logger = warning) %>%
                   summarize(least = min(sanity)),
                 regexp = msg)
  expect_equal(expected, result)
})

test_that("user-defined logging function is not called if nothing goes wrong", {
  captured_msg <<- NULL
  result <- fixture() %>%
    group_by(person) %>%
    nickr_group(min(sanity) > 3, msg = "should not appear", logger = local_logger) %>%
    summarize(least = min(sanity))
  expect_equal(captured_msg, NULL)
})

test_that("user-defined logging function is called if something goes wrong", {
  captured_msg <<- NULL
  msg <- "the error message"
  expect_silent(fixture() %>%
                  group_by(person) %>%
                  nickr_group(min(sanity) < 3, msg = msg, logger = local_logger) %>%
                  summarize(least = min(sanity)))
  expect_equal(captured_msg, msg)
})

test_that("a single inactive test is not run", {
  msg <- "the error message"
  expect_silent(fixture() %>%
                  group_by(person) %>%
                  nickr_group(min(sanity) < 3, msg = msg, active = FALSE) %>%
                  summarize(least = min(sanity)))
})
