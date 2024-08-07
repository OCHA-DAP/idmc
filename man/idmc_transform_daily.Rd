% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/idmc_transform_daily.R
\name{idmc_transform_daily}
\alias{idmc_transform_daily}
\title{Transform displacement event data to daily data}
\usage{
idmc_transform_daily(
  df,
  min_date = as.Date("2018-01-01"),
  max_date = Sys.Date(),
  filter_min_date = TRUE
)
}
\arguments{
\item{df}{Event displacement data frame, generated from \code{\link[=idmc_get_data]{idmc_get_data()}}.}

\item{min_date}{Date to backfill displacement data to. By default, \code{min_date}
is set the first day of 2018. Only a few observations of the IDMC data
are from before 2018, spanning back to 2011.
If \code{NULL}, no backfilling is done, and the first reported
case in the IDMC database is taken as the earliest.}

\item{max_date}{Date to extrapolate all data to, filling with \code{0}. If the
The latest date in the data frame is used if later than \code{max_date}.
If \code{NULL}, no extrapolation is done.}

\item{filter_min_date}{If \code{TRUE}, the default, filters the data to only
contain data from \code{min_date} onward. Ensures that the few countries with
observations from 2011 but nothing until 2018 do not skew results.}
}
\value{
Data frame of daily displacement with the following columns:
\describe{
\item{iso3}{Country ISO3 code.}
\item{country}{Country or area name.}
\item{displacement_type}{Type of displacement.}
\item{date}{Date.}
\item{displacement_daily}{Daily level of displacement.}
}
}
\description{
\code{idmc_transform_daily()} transforms event data from the IDMC API (accessed
through \code{\link[=idmc_get_data]{idmc_get_data()}}). For each event, identified by an \code{event_id},
potentially duplicated data is filtered out. If there are \verb{Recommended figure}
rows based on the \code{role} column, then only those are kept. If there are no
recommended figures, then only the latest update to the \code{event_id} data is
kept, using \code{created_at} to find latest updates.
}
\details{
The data for each event is spread out between
the start and end date, with the total displacement uniformly distributed
across all days. For each country and displacement type (conflict, disaster,
or other), all displacement on a day is summed up to create a total
daily displacement figure.

By default, data is backfilled for all countries and displacement types to
the first reported date in the IDMC dataset. Data is always infilled with 0
between start and end dates.
}
\examples{
\dontshow{if (!is.na(Sys.getenv("IDMC_API", unset = NA))) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
idmc_get_data() \%>\%
  idmc_transform_daily()
\dontshow{\}) # examplesIf}
}
