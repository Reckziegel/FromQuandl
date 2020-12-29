# library(FromQuandl)
#
# context("fq_wb")
#
# # development indicators
# test1 <- fq_wb('United States', 'EG_ELC_ACCS_ZS')
# test2 <- fq_wb("USA", "EG_ELC_ACCS_ZS", order = 'desc')
# test3 <- fq_wb('USA', 'EG_ELC_ACCS_ZS', start_date = '2010-01-01', end_date = '2012-01-01')
#
# # governance indicators
# # test5 <- fq_wb('United States', 'CC_EST')
# # test6 <- fq_wb("USA", "CC_EST")
# # test7 <- fq_wb("USA", "CC_EST", order = 'desc')
# # test8 <- fq_wb('USA', 'CC_EST', start_date = '2010-01-01', end_date = '2012-01-01')
# #
# # # poverty indicatores
# # test9  <- fq_wb('United States', 'SI_POV_NOP1')
# # test10 <- fq_wb("USA", "SI_POV_NOP1")
# # test11 <- fq_wb("USA", "SI_POV_NOP1", order = 'desc')
# # test12 <- fq_wb('USA', 'SI_POV_NOP1', start_date = '2010-01-01', end_date = '2012-01-01')
#
#
# test_that("It contains the correct data structure", {
#
#   # It is tibble
#   expect_is(test1, 'tbl')
#   #expect_is(test5, 'tbl')
#   #expect_is(test9, 'tbl')
#
#   # It has 4 columns
#   expect_equal(ncol(test1), 4)
#   #expect_equal(ncol(test5), 4)
#   #expect_equal(ncol(test9), 4)
#
#   # Date is Date
#   expect_is(test1$date, "Date")
#   #expect_is(test5$date, "Date")
#   #expect_is(test9$date, "Date")
#
#   # Country is factor
#   expect_is(test1$country, "factor")
#   #expect_is(test5$country, "factor")
#   #expect_is(test9$country, "factor")
#
#   # Indicator is factor
#   expect_is(test1$indicator, "factor")
#   #expect_is(test5$indicator, "factor")
#   #expect_is(test9$indicator, "factor")
#
#   # Value is numeric
#   expect_is(test1$value, "numeric")
#   #expect_is(test5$value, "numeric")
#   #expect_is(test9$value, "numeric")
#
#   # The names match
#   expect_named(test1, c("date", "country", "indicator", "value"))
#   #expect_named(test5, c("date", "country", "indicator", "value"))
#   #expect_named(test9, c("date", "country", "indicator", "value"))
#
#   # dates are organized in the ascending order
#   expect_true(tail(test1$date, 1) > head(test1$date, 1))
#   #expect_true(tail(test5$date, 1) > head(test5$date, 1))
#   #expect_true(tail(test9$date, 1) > head(test9$date, 1))
#
#
# })
#
#
#
# test_that("The same output is returned if country names or ISO codes are used", {
#
#   expect_equal(test1, test2)
#   #expect_equal(test5, test6)
#   #expect_equal(test9, test10)
#
# })
#
#
#
# test_that("It sends a warning if order = 'desc' is used in ...", {
#
#   # warning
#   #expect_warning(test3, "To keep consistency with ")
#
#   # dates are organized in the ascending order
#   expect_true(tail(test3$date, 1)  > head(test3$date, 1))
#   #expect_true(tail(test7$date, 1)  > head(test7$date, 1))
#   #expect_true(tail(test11$date, 1) > head(test11$date, 1))
#
# })
#
#
#
# test_that("Additional argumets passed through ... works properly", {
#
#   # starts at 2010
#   expect_equal(test3$date[[1]], lubridate::date('2010-12-31'))
#   #expect_equal(test4$date[[2]], lubridate::date('2011-12-31'))
#
#
# })
#
#
#
# test_that("Calling indicators from vectors of strings or lists of strings yields the same output", {
#
#   expect_equal(
#     fq_wb("USA", c("EG_ELC_ACCS_ZS", "NY_ADJ_NNTY_KD")),
#     fq_wb("USA", list("EG_ELC_ACCS_ZS", "NY_ADJ_NNTY_KD"))
#   )
#
#
# })


