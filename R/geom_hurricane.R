########################################################################
#                                                                      #
#  Author :  Anderson Hitoshi Uyekita                                  #
#  Project:  Coursera - Building Data Visualization Tools              #
#  Date   :  2018-nov-24                                               #
#                                                                      #
########################################################################

#' The geom_hurricane function aims to plot a new form of data visualization, based on Wind Radius Speed
#' this geom will plot a graphich with "rose" format which will represent the area of the wind speed. All
#' plot must be created from a ggplot2 or ggmaps graphic.
#'
#' @param mapping pirir
#'
#' @param data p irir
#'
#' @param stat pirir
#'
#' @param na.rm pirir
#'
#' @param show.legend  pirir
#'
#' @param inherit.aes pirir
#'
#' @return The output of this geom will be a pie style of graphic varying the radius to show the intense
#'         of the wind speed.
#'
#' @importFrom ggplot2 layer
#'
#' @examples
#'
#' \dontrun{ggplot() + geom_hurricane(data, aes(x = longitude,
#'                                              y = latitude,
#'                                              r_ne = ne,
#'                                              r_se = se,
#'                                              r_nw = nw,
#'                                              r_sw = sw,
#'                                              fill = wind_speed,
#'                                              color = wind_speed))}
#'
#' @export
# Default functions
geom_hurricane <- function(mapping = NULL,
                           data = NULL,
                           stat = "identity",
                           position = "identity",
                           na.rm = FALSE,
                           show.legend = NA,
                           inherit.aes = TRUE, ...){

       ggplot2::layer(geom = GeomHurricane,
                      mapping = mapping,
                      data = data,
                      stat = stat,
                      position = position,
                      show.legend = show.legend,
                      inherit.aes = inherit.aes,
                      params = list(na.rm = na.rm,...)
       )
}
