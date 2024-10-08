#' @rdname network
#' @title Environment variables for internet and network-related values
#' @description `envvar_get_url()` gets a URL value from an environment
#'   variable and parses it with [httr2::url_parse].
#' @inheritParams envvar_get
#' @return `envvar_get_url()` returns a URL: an S3 list with class `httr2_url`
#' and elements `scheme`, `hostname`, `port`, `path`, `fragment`, `query`,
#' `username`, `password`, where applicable.
#' @export
#' @examples
#'
#' # Get a URL value and ensure that it is https
#' envvar_set("TEST_URL" = "https://google.com:80/?a=1&b=2")
#' envvar_get_url("TEST_URL", validate = \(x) x$scheme == "https")
envvar_get_url <- function(x,
                           default = NULL,
                           validate = NULL,
                           warn_default = TRUE) {
  rlang::check_installed("httr2")

  envvar_get(
    x,
    default = default,
    transform = httr2::url_parse,
    validate = validate,
    warn_default = TRUE
  )
}

#' @rdname network
#' @description `envvar_get_ipaddress()` gets an IP address value from an
#'   environment variable
#' @return `envvar_get_ipaddress()` returns an `ip_address` vector
#' @export
#' @examples
#'
#' # Get an IP address value and ensure that it is IPv4
#' envvar_set("TEST_HOST" = "192.168.1.15")
#' envvar_get_ipaddress("TEST_HOST", validate = ipaddress::is_ipv4)
envvar_get_ipaddress <- function(x,
                                 default = NULL,
                                 validate = NULL,
                                 warn_default = TRUE) {
  rlang::check_installed("ipaddress")

  envvar_get(
    x,
    default = default,
    transform = function(x) {
      ip <- suppressWarnings(ipaddress::as_ip_address(x))
      if (is.na(ip)) {
        cli::cli_abort(
          message = "{.val {x}} is not a valid IP address",
          class = "envvar_invalid_ip_address"
        )
      }
      ip
    },
    validate = validate,
    warn_default = warn_default
  )
}
