test_that("`envvar_get_integer()` works as expected", {
  withr::local_envvar(
    list(
      "ENVVAR_TEST_INT1" = 14,
      "ENVVAR_TEST_INT2" = -36,
      "ENVVAR_TEST_DBL" = 1.234,
      "ENVVAR_TEST_INT_NOTSET" = NA
    )
  )

  expect_true(is.integer(envvar_get_integer("ENVVAR_TEST_INT1")))
  expect_equal(envvar_get_integer("ENVVAR_TEST_INT1"), 14)

  expect_error(
    envvar_get_integer("ENVVAR_TEST_INT_NOTSET", use_default = FALSE)
  )
  # `default` should be integer-like
  expect_error(
    envvar_get_integer("ENVVAR_TEST_INT_NOTSET", default = 23.31),
    class = "envvar_invalid_default"
  )
  expect_no_error(
    suppressMessages(
      envvar_get_integer("ENVVAR_TEST_INT_NOTSET", default = 90210)
    )
  )
  expect_message(envvar_get_integer("ENVVAR_TEST_INT_NOTSET", default = 90210))
  expect_error(envvar_get_integer("ENVVAR_TEST_INT_NOTSET"))
  expect_equal(
    suppressMessages(
      envvar_get_integer("ENVVAR_TEST_INT_NOTSET", default = 90210)
    ),
    90210
  )

  expect_error(envvar_get_integer("ENVVAR_TEST_INT2", validate = \(x) x >= 0))
  expect_no_error(
    envvar_get_integer("ENVVAR_TEST_INT1", validate = \(x) x >= 0)
  )
  expect_error(
    suppressMessages(
      envvar_get_integer(
        "ENVVAR_TEST_INT_NOTSET",
        default = 90210,
        validate = \(x) x < 100
      )
    )
  )
})

test_that("`envvar_get_integer()` warnings for non-integerish things", {
  withr::local_envvar(
    list(
      "TEST_DBL" = 1.23
    )
  )
  # Invalid values produce an error
  expect_error(envvar_get_integer("TEST_DBL"))
  expect_snapshot(envvar_get_integer("TEST_DBL"), error = TRUE)
})


test_that("`envvar_get_numeric()` works as expected", {
  withr::local_envvar(
    list(
      "ENVVAR_TEST_NUM1" = 12.34,
      "ENVVAR_TEST_NUM2" = -34.56,
      "ENVVAR_TEST_NUM_NOTSET" = NA_real_,
      "ENVVAR_TEST_NOTNUM" = "not_a_number"
    )
  )

  expect_true(is.numeric(envvar_get_numeric("ENVVAR_TEST_NUM1")))
  expect_equal(envvar_get_numeric("ENVVAR_TEST_NUM1"), 12.34)

  expect_error(envvar_get_numeric("ENVVAR_TEST_NUM_NOTSET"))
  expect_error(envvar_get_numeric("ENVVAR_TEST_NOTNUM"))
  expect_error(
    envvar_get_numeric("ENVVAR_TEST_NUM_NOTSET", default = "not_a_number"),
    class = "envvar_invalid_default"
  )
  expect_no_error(
    suppressMessages(
      envvar_get_numeric("ENVVAR_TEST_NUM_NOTSET", default = 1.23)
    )
  )
  expect_equal(
    suppressMessages(
      envvar_get_numeric("ENVVAR_TEST_NUM_NOTSET", default = 123.45)
    ),
    123.45
  )

  expect_error(envvar_get_numeric("ENVVAR_TEST_NUM2", validate = \(x) x >= 0))
  expect_no_error(
    envvar_get_numeric("ENVVAR_TEST_NUM1", validate = \(x) x >= 0)
  )
  expect_error(
    suppressMessages(
      envvar_get_numeric(
        "ENVVAR_TEST_NUM_NOTSET",
        default = 902.10,
        validate = \(x) x < 100
      )
    )
  )
})


test_that("`envvar_get_logical()` works as expected", {
  withr::local_envvar(
    list(
      "TEST_LOGICAL1" = TRUE,
      "TEST_LOGICAL2" = FALSE,
      "TEST_LOGICAL3" = 0,
      "TEST_LOGICAL4" = "True",
      "TEST_LOGICAL_BAD" = "yep",
      "TEST_NOTSET" = NA
    )
  )

  expect_true(rlang::is_logical(envvar_get_logical("TEST_LOGICAL1")))
  expect_true(envvar_get_logical("TEST_LOGICAL1"))
  expect_false(envvar_get_logical("TEST_LOGICAL2"))
  expect_false(envvar_get_logical("TEST_LOGICAL3"))
  expect_true(envvar_get_logical("TEST_LOGICAL4"))

  expect_error(envvar_get_logical("TEST_NOTSET"))
  expect_error(
    envvar_get_logical("TEST_LOGICAL1", default = 123.4),
    class = "envvar_invalid_default"
  )
  expect_true(
    suppressMessages(envvar_get_logical("TEST_NOTSET", default = TRUE))
  )
  expect_false(
    suppressMessages(envvar_get_logical("TEST_NOTSET", default = FALSE))
  )
  expect_message(envvar_get_logical("TEST_NOTSET", default = TRUE))

  expect_true(
    envvar_get_logical(
      "TEST_LOGICAL1",
      validate = is.logical
    )
  )
  expect_error(
    envvar_get_logical(
      "TEST_LOGICAL1",
      validate = is.numeric
    )
  )

  expect_no_error(
    suppressMessages(
      envvar_get_logical(
        "TEST_NOTSET",
        default = TRUE,
        validate = is.logical
      )
    )
  )

  expect_error(envvar_get_logical("TEST_LOGICAL_BAD"))
  expect_snapshot(envvar_get_logical("TEST_LOGICAL_BAD"), error = TRUE)
})


test_that("`envvar_get_version()` works as expected", {
  withr::local_envvar(
    list(
      "TEST_VERSION" = "1.2.3",
      "TEST_NOTSET" = NA
    )
  )

  expect_true(is.numeric_version(envvar_get_version("TEST_VERSION")))
  expect_equal(envvar_get_version("TEST_VERSION"), numeric_version("1.2.3"))

  expect_error(envvar_get_version("TEST_NOTSET"))
  expect_error(
    envvar_get_version("TEST_NOTSET", default = "not_a_version"),
    class = "envvar_invalid_default"
  )
  expect_no_error(
    suppressMessages(envvar_get_version("TEST_NOTSET", default = "1.2.3"))
  )
  expect_message(envvar_get_version("TEST_NOTSET", default = "1.2.3"))
  expect_true(
    is.numeric_version(
      suppressMessages(envvar_get_version("TEST_NOTSET", default = "1.2.3"))
    )
  )

  expect_no_error(
    envvar_get_version(
      "TEST_VERSION",
      validate = \(x) x > as.numeric_version("1.2.2")
    )
  )
  expect_error(
    envvar_get_version(
      "TEST_VERSION",
      validate = \(x) x > as.numeric_version("1.2.4")
    )
  )
})


test_that("`envvar_get_date() works as expected", {
  withr::local_envvar(
    list(
      "TEST_DATE" = "2023-01-02",
      "TEST_NOTSET" = NA
    )
  )

  # Error raised if ... are bad
  expect_error(envvar_get_date("TEST_DATE", defaults = "2023-01-02"))

  expect_true(lubridate::is.Date(envvar_get_date("TEST_DATE")))
  expect_equal(envvar_get_date("TEST_DATE"), lubridate::as_date("2023-01-02"))

  expect_error(envvar_get_date("TEST_NOTSET"))
  expect_no_error(
    suppressMessages(envvar_get_date("TEST_NOTSET", default = "2023-09-09"))
  )
  expect_message(envvar_get_date("TEST_NOTSET", default = "2023-09-09"))
  expect_true(
    lubridate::is.Date(
      suppressMessages(envvar_get_date("TEST_NOTSET", default = "2023-09-09"))
    )
  )

  expect_equal(lubridate::year(envvar_get_date("TEST_DATE")), 2023)
  expect_no_error(
    envvar_get_date("TEST_DATE", validate = \(x) lubridate::year(x) >= 2022)
  )
  expect_error(
    envvar_get_date("TEST_DATE", validate = \(x) lubridate::month(x) > 3)
  )

  expect_no_error(
    suppressMessages(
      envvar_get_date(
        "TEST_NOTSET",
        default = "2023-04-05",
        validate = \(x) lubridate::year(x) >= 2022
      )
    )
  )

  expect_error(
    suppressMessages(
      envvar_get_date(
        "TEST_NOTSET",
        default = "2023-02-05",
        validate = \(x) lubridate::month(x) >= 3
      )
    )
  )
})


test_that("`envvar_get_datetime() works as expected", {
  withr::local_envvar(
    list(
      "TEST_DATETIME" = "2023-01-02 04:05:05 UTC",
      "TEST_NOTSET" = NA
    )
  )

  # Error raised if ... are bad
  expect_error(
    envvar_get_datetime("TEST_DATETIME", default = "2023-01-01", extra = TRUE)
  )

  expect_true(lubridate::is.POSIXct(envvar_get_datetime("TEST_DATETIME")))
  expect_equal(
    envvar_get_datetime("TEST_DATETIME"),
    lubridate::as_datetime("2023-01-02 04:05:05 UTC")
  )

  expect_error(envvar_get_datetime("TEST_NOTSET"))
  expect_no_error(
    suppressMessages(envvar_get_datetime("TEST_NOTSET", default = "2023-09-09"))
  )
  expect_message(envvar_get_datetime("TEST_NOTSET", default = "2023-09-09"))
  expect_true(
    lubridate::is.POSIXct(
      suppressMessages(
        envvar_get_datetime("TEST_NOTSET", default = "2023-09-09")
      )
    )
  )

  expect_equal(lubridate::year(envvar_get_datetime("TEST_DATETIME")), 2023)
  expect_no_error(
    envvar_get_datetime(
      "TEST_DATETIME",
      validate = \(x) lubridate::year(x) >= 2022
    )
  )
  expect_error(
    envvar_get_datetime(
      "TEST_DATETIME",
      validate = \(x) lubridate::month(x) > 3
    )
  )

  expect_no_error(
    suppressMessages(
      envvar_get_datetime(
        "TEST_NOTSET",
        default = "2023-04-05 12:01:42 UTC",
        validate = \(x) lubridate::year(x) >= 2022
      )
    )
  )

  expect_error(
    suppressMessages(
      envvar_get_datetime(
        "TEST_NOTSET",
        default = "2023-02-05 12:01:42 UTC",
        validate = \(x) lubridate::month(x) >= 3
      )
    )
  )
})
