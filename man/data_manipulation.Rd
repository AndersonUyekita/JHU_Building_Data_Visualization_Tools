% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_man.R
\name{data_manipulation}
\alias{data_manipulation}
\title{Data Manipulation Function - Although this is not a deliverable of the course I made
a great effor to pratice/apply the lesson from the last Course. This function creates
the data frame used as of the geom_hurricane.}
\usage{
data_manipulation(dt_import)
}
\arguments{
\item{file_path}{The path to reach the file "ebtrk_atlc_1988_2015.txt".}
}
\value{
The outuput of this function is a data frame with storm_id, date, latitude,
        longitude, wind_speed, ne, nw, se, and sw.
}
\description{
Data Manipulation Function - Although this is not a deliverable of the course I made
a great effor to pratice/apply the lesson from the last Course. This function creates
the data frame used as of the geom_hurricane.
}
\examples{

\dontrun{data_manipulation("ebtrk_atlc_1988_2015.txt")}

\dontrun{data_manipulation("ebtrk_atlc_1988_2017.txt")}

}
