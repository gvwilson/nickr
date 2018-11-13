context("Test checks between pipeline stages")

make_fixture <- function() {
  tibble::tribble(
    ~a,   ~b,  ~c,
    1.1,  2.2,  3.3,
    4.4,  5.5,  6.6
  )
}

test_that("a simple expression works without error", {
  fixture <- make_fixture()
  result <- nickr(fixture, a < b, 'should not appear')
  expect_equal(fixture, result)
})

test_that("a simple invalid expression produces an error", {
  fixture <- make_fixture()
  msg <- 'test failed'
  expect_error(nickr(fixture, a > b, msg), msg)
})

test_that("a simple invalid expression produces a warning if told to", {
  fixture <- make_fixture()
  msg <- 'test failed'
  expect_warning(nickr(fixture, a > b, msg, logger = warning), msg)
})

test_that("a complex expression works without error", {
  fixture <- make_fixture()
  result <- nickr(fixture, (a < b) & (b < c), 'should not appear')
  expect_equal(fixture, result)
})

test_that("a simple expression in a pipe without error", {
  expected <- make_fixture() %>%
    dplyr::transmute(a)
  result <- make_fixture() %>%
    nickr(a < b, 'should not appear') %>%
    dplyr::transmute(a)
  expect_equal(expected, result)
})

test_that("a simple expression in a pipe with an error", {
  msg <- 'pipe error'
  expect_error(make_fixture() %>%
                 nickr(a > b, msg) %>%
                 dplyr::transmute(a),
               msg)
})

test_that("a simple expression in a pipe with a warning", {
  msg <- 'pipe error'
  expect_warning(make_fixture() %>%
                   nickr(a > b, msg, logger = warning) %>%
                   dplyr::transmute(a),
               msg)
})
