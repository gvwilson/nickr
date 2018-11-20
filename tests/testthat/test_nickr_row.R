context("Test checks on rows between pipeline stages")

fixture <- function() {
  tibble::tribble(
    ~a,   ~b,  ~c,
    10,  100,  0.1,
    20,  200,  0.2,
    30,  300,  0.3
  )
}

captured_msg <- NULL
local_logger <- function(text) {
  captured_msg <<- text
}

test_that("every row passes a test that always passes", {
  fx <- fixture()
  result <- nickr_row(fx, TRUE)
  expect_equal(fx, result)
})

test_that("every row fails a test that always fails", {
  expect_error(nickr_row(fixture(), FALSE),
               regexp = "nickr_row with 'FALSE' rows: 1 2 3")
})

test_that("all rows pass a successful test on a single column", {
  fx <- fixture()
  result <- nickr_row(fx, a > 0)
  expect_equal(fx, result)
})

test_that("only some rows pass a mixed test on a single column", {
  expect_error(nickr_row(fixture(), a > 10),
               regexp = "nickr_row with 'a > 10' rows: 1")
})

test_that("only some rows pass a mixed test on multiple columns", {
  expect_error(nickr_row(fixture(), (a < b) && (c < 0.3)),
               regexp = "nickr_row with '\\(a < b\\) && \\(c < 0.3\\)' rows: 3")
})

test_that("only some rows pass a test on the row index", {
  expect_error(nickr_row(fixture(), .r != 2),
               regexp = "nickr_row with '.r != 2' rows: 2")
})

test_that("a false expression in a pipe produces an error", {
  msg <- "pipe error"
  fx <- fixture()
  expect_error(fx %>%
                 nickr_row(a > b, msg = msg) %>%
                 dplyr::transmute(a),
               regexp = "pipe error with 'a > b' rows: 1 2 3")
})

test_that("a false expression in a pipe produces a warning and the correct result", {
  msg <- "pipe warning"
  fx <- fixture()
  expected <- fx %>%
    dplyr::transmute(a)
  expect_warning(result <- fx %>%
                   nickr_row(c > 0.2, msg = msg, logger = warning) %>%
                   dplyr::transmute(a),
                 regexp = "pipe warning with 'c > 0.2' rows: 1 2")
  expect_equal(expected, result)
})

test_that("user-defined logging function is not called if nothing goes wrong", {
  captured_msg <<- NULL
  fx <- fixture()
  result <- fx %>% nickr_row(TRUE, logger = local_logger)
  expect_equal(fx, result)
  expect_equal(captured_msg, NULL)
})

test_that("user-defined logging function is called if something goes wrong", {
  captured_msg <<- NULL
  fixture() %>% nickr_row(a > 10, msg = "pipe error", logger = local_logger)
  expect_equal(captured_msg, "pipe error with 'a > 10' rows: 1")
})

test_that("a single inactive test is not run", {
  fx <- fixture()
  expected <- fixture() %>%
    dplyr::transmute(a)
  result <- fx %>%
    nickr_row(FALSE, active = FALSE) %>%
    dplyr::transmute(a)
  expect_equal(expected, result)
})

test_that("disabling one test does not disable other tests", {
  expect_error(fixture() %>%
                 nickr_row(FALSE, msg = "check b", active = FALSE) %>%
                 nickr_row(c != 0.3, msg = "check c"),
               regexp = "check c with 'c != 0.3' rows: 3")
})

test_that("external values in conditions are captured correctly", {
  threshold <- 20
  expect_error(fixture() %>%
                 nickr_row(a <= threshold),
               regexp = "nickr_row with 'a <= threshold' rows: 3")
})
