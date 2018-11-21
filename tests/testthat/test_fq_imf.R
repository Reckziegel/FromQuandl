library(FromQuandl)

context("fq_imf")

test1 <- fq_imf('United States', 'NGAP_NPGDP')
test2 <- fq_imf("USA", "NGAP_NPGDP")
test3 <- fq_imf("USA", "NGAP_NPGDP", order = 'desc')
test4 <- fq_imf('USA', 'NGAP_NPGDP', start_date = '2010-01-01', end_date = '2012-01-01')

test_that("It contains the correct data structure", {

          # It is tibble
          expect_is(test1, 'tbl')

          # It has 4 columns
          expect_equal(ncol(test1), 4)

          # Date is Date
          expect_is(test1$date, "Date")

          # Country is factor
          expect_is(test1$country, "factor")

          # Indicator is factor
          expect_is(test1$indicator, "factor")

          # Value is numeric
          expect_is(test1$value, "numeric")

          # The names match
          expect_named(test1, c("date", "country", "indicator", "value"))

          # dates are organized in the ascending order
          expect_true(tail(test1$date, 1) > head(test1$date, 1))

})



test_that("The same output is returned if country names or ISO codes are used", {

  expect_equal(test1, test2)

})



test_that("It sends a warning if order = 'desc' is used in ...", {

  # warning
  #expect_warning(test3, "To keep consistency with ")

  # dates are organized in the ascending order
  expect_true(tail(test3$date, 1) > head(test3$date, 1))

})



test_that("Additional argumets passed through ... works properly", {

  # starts at 2010
  expect_equal(test4$date[[1]], lubridate::date('2010-12-31'))
  expect_equal(test4$date[[2]], lubridate::date('2011-12-31'))


})



test_that("Calling indicators from vectors of strings or lists of strings yields the same output", {

  expect_equal(
    fq_imf("USA", c("LP", "LUR")),
    fq_imf("USA", list("LP", "LUR"))
  )


})
