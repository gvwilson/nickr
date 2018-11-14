context("Test checks between pipeline stages")

make_fixture <- function() {
  tibble::tribble(
    ~a,   ~b,  ~c,
    1.1,  2.2,  3.3,
    4.4,  5.5,  6.6
  )
}

test_that("a correct simple expression works without reporting an error", {
  fixture <- make_fixture()
  result <- nickr_col(fixture, a < b, msg = "should not appear")
  expect_equal(fixture, result)
})

test_that("a false simple expression produces an error", {
  fixture <- make_fixture()
  msg <- "test failed"
  expect_error(nickr_col(fixture, a > b, msg = msg),
               regexp = msg)
})

test_that("a false simple expression produces a warning instead of an error if told to", {
  fixture <- make_fixture()
  msg <- "test failed"
  expect_warning(nickr_col(fixture, a > b, msg = msg, logger = warning),
                 regexp = msg)
})

test_that("a correct multi-part expression works without error", {
  fixture <- make_fixture()
  result <- nickr_col(fixture, (a < b) & (b < c), msg = "should not appear")
  expect_equal(fixture, result)
})

test_that("multiple correct conditions work without error", {
  fixture <- make_fixture()
  result <- nickr_col(fixture, a < b, b < c, 0 < c, msg = "should not appear")
  expect_equal(fixture, result)
})

test_that("a correct simple expression in a pipe works without error", {
  expected <- make_fixture() %>%
    dplyr::transmute(a)
  result <- make_fixture() %>%
    nickr_col(a < b, msg = "should not appear") %>%
    dplyr::transmute(a)
  expect_equal(expected, result)
})

test_that("a false expression in a pipe produces an error", {
  msg <- "pipe error"
  fixture <- make_fixture()
  expect_error(fixture %>%
                 nickr_col(a > b, msg = msg) %>%
                 dplyr::transmute(a),
               regexp = msg)
})

test_that("a false expression in a pipe produces a warning and the correct result", {
  msg <- "pipe warning"
  expected <- make_fixture() %>%
    dplyr::transmute(a)
  expect_warning(result <- make_fixture() %>%
                   nickr_col(a > b, msg = msg, logger = warning) %>%
                   dplyr::transmute(a),
                 regexp = msg)
  expect_equal(expected, result)
})

test_that("all failing conditions show up in the error message in order", {
  msg <- "pipe error"
  fixture <- make_fixture()
  expect_error(fixture %>%
                 nickr_col(a < 0, b < 0, c < 0, msg = msg) %>%
                 dplyr::transmute(a),
               regexp = "pipe error: a < 0, b < 0, c < 0")
})

test_that("only failing conditions show up in the error message", {
  msg <- "pipe error"
  fixture <- make_fixture()
  expect_error(fixture %>%
                 nickr_col(0 < b, c < 0, msg = msg) %>%
                 dplyr::transmute(a),
               regexp = "pipe error: c < 0")
})

test_that("default error message shows up if nothing else provided", {
  fixture <- make_fixture()
  expect_error(fixture %>% nickr_col(b < 0),
               regexp = "nickr: b < 0")
})

test_that("user-defined logging function is not called if nothing goes wrong", {
  captured_msg <- NULL
  local_logger <- function(text) {
    captured_msg <<- text
  }
  fixture <- make_fixture()
  result <- fixture %>% nickr_col(0 < b, logger = local_logger)
  expect_equal(fixture, result)
  expect_equal(captured_msg, NULL)
})

test_that("user-defined logging function is called if something goes wrong", {
  captured_msg <- NULL
  local_logger <- function(text) {
    captured_msg <<- text
  }
  fixture <- make_fixture()
  result <- fixture %>% nickr_col(b < 0, msg = "pipe error", logger = local_logger)
  expect_equal(fixture, result)
  expect_equal(captured_msg, "pipe error: b < 0")
})

test_that("a single inactive test is not run", {
  fixture <- make_fixture()
  expected <- make_fixture() %>%
    dplyr::transmute(a)
  result <- fixture %>%
    nickr_col(b < 0, active = FALSE) %>%
    dplyr::transmute(a)
  expect_equal(expected, result)
})

test_that("disabling one test does not disable other tests", {
  fixture <- make_fixture()
  expect_error(fixture %>%
                 nickr_col(b < 0, msg = "check b", active = FALSE) %>%
                 nickr_col(c < 0, msg = "check c"),
               regexp = "check c: c < 0")
})

test_that("execution halts at the first error-level report", {
  fixture <- make_fixture()
  expect_error(fixture %>%
                 nickr_col(b < 0, msg = "check b") %>%
                 nickr_col(c < 0, msg = "check c"),
               regexp = "check b: b < 0$")
})

test_that("multiple warning-level reports appear", {
  fixture <- make_fixture()
  expect_warning(fixture %>%
                   nickr_col(b < 0, msg = "check b", logger = warning) %>%
                   nickr_col(c < 0, msg = "check c", logger = warning),
                 regexp = "(check b: b < 0)|(check c: c < 0)",
                 all = TRUE)
})
