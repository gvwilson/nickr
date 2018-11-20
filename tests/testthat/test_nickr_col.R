context("Test checks on columns between pipeline stages")

fixture <- function() {
  tibble::tribble(
    ~a,   ~b,  ~c,
    1.1,  2.2,  3.3,
    4.4,  5.5,  6.6
  )
}

captured_msg <- NULL
local_logger <- function(text) {
  captured_msg <<- text
}

test_that("a correct simple expression works without reporting an error", {
  fx <- fixture()
  result <- nickr_col(fx, a < b, msg = "should not appear")
  expect_equal(fx, result)
})

test_that("a false simple expression produces an error", {
  fx <- fixture()
  msg <- "test failed"
  expect_error(nickr_col(fx, a > b, msg = msg),
               regexp = msg)
})

test_that("a false simple expression produces a warning instead of an error if told to", {
  fx <- fixture()
  msg <- "test failed"
  expect_warning(nickr_col(fx, a > b, msg = msg, logger = warning),
                 regexp = msg)
})

test_that("a correct multi-part expression works without error", {
  fx <- fixture()
  result <- nickr_col(fx, (a < b) & (b < c), msg = "should not appear")
  expect_equal(fx, result)
})

test_that("a correct simple expression in a pipe works without error", {
  expected <- fixture() %>%
    dplyr::transmute(a)
  result <- fixture() %>%
    nickr_col(a < b, msg = "should not appear") %>%
    dplyr::transmute(a)
  expect_equal(expected, result)
})

test_that("a false expression in a pipe produces an error", {
  msg <- "pipe error"
  fx <- fixture()
  expect_error(fx %>%
                 nickr_col(a > b, msg = msg) %>%
                 dplyr::transmute(a),
               regexp = msg)
})

test_that("a false expression in a pipe produces a warning and the correct result", {
  msg <- "pipe warning"
  expected <- fixture() %>%
    dplyr::transmute(a)
  expect_warning(result <- fixture() %>%
                   nickr_col(a > b, msg = msg, logger = warning) %>%
                   dplyr::transmute(a),
                 regexp = msg)
  expect_equal(expected, result)
})

test_that("only the first failing condition shows up", {
  msg <- "pipe error"
  fx <- fixture()
  expect_error(fx %>%
                 nickr_col(a < 0, msg = msg) %>%
                 nickr_col(b < 0, msg = msg) %>%
                 dplyr::transmute(a),
               regexp = "pipe error with 'a < 0' rows: 1 2")
})

test_that("only failing conditions show up in the error message", {
  msg <- "pipe error"
  fx <- fixture()
  expect_error(fx %>%
                 nickr_col(0 < b, msg = msg) %>%
                 nickr_col(c < 0, msg = msg) %>%
                 dplyr::transmute(a),
               regexp = "pipe error with 'c < 0' rows: 1 2")
})

test_that("default error message shows up if nothing else provided", {
  fx <- fixture()
  expect_error(fx %>% nickr_col(b < 0),
               regexp = "nickr_col with 'b < 0' rows: 1 2")
})

test_that("user-defined logging function is not called if nothing goes wrong", {
  captured_msg <<- NULL
  fx <- fixture()
  result <- fx %>% nickr_col(0 < b, logger = local_logger)
  expect_equal(fx, result)
  expect_equal(captured_msg, NULL)
})

test_that("user-defined logging function is called if something goes wrong", {
  captured_msg <<- NULL
  fx <- fixture()
  result <- fx %>% nickr_col(b < 0, msg = "pipe error", logger = local_logger)
  expect_equal(fx, result)
  expect_equal(captured_msg, "pipe error with 'b < 0' rows: 1 2")
})

test_that("a single inactive test is not run", {
  fx <- fixture()
  expected <- fixture() %>%
    dplyr::transmute(a)
  result <- fx %>%
    nickr_col(b < 0, active = FALSE) %>%
    dplyr::transmute(a)
  expect_equal(expected, result)
})

test_that("disabling one test does not disable other tests", {
  fx <- fixture()
  expect_error(fx %>%
                 nickr_col(b < 0, msg = "check b", active = FALSE) %>%
                 nickr_col(c < 0, msg = "check c"),
               regexp = "check c with 'c < 0' rows: 1 2")
})

test_that("execution halts at the first error-level report", {
  fx <- fixture()
  expect_error(fx %>%
                 nickr_col(b < 0, msg = "check b") %>%
                 nickr_col(c < 0, msg = "check c"),
               regexp = "check b with 'b < 0' rows: 1 2$")
})

test_that("multiple warning-level reports appear", {
  fx <- fixture()
  expect_warning(fx %>%
                   nickr_col(b < 0, msg = "check b", logger = warning) %>%
                   nickr_col(c < 0, msg = "check c", logger = warning),
                 regexp = "(check b with 'b < 0' rows: 1 2)|(check c with 'c < 0' rows: 1 2)",
                 all = TRUE)
})

test_that("external values in conditions are captured correctly", {
  threshold <- 5.0
  expect_error(fixture() %>%
                 nickr_col(b <= threshold),
               regexp = "nickr_col with 'b <= threshold' rows: 2")
})
