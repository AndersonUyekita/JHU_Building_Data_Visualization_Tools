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
#' @param Geom_harry_kane pirir
#'
#' @param required_aes p irir
#'
#' @param default_aes pirir
#'
#' @param draw_key pirir
#'
#' @param draw_group pirir
#'
#' @return The output of this geom will be a pie style of graphic varying the radius to show the intense
#'         of the wind speed.
#'
#' @importFrom ggplot2 ggproto aes draw_key_polygon Geom layer
#'
#' @importFrom geosphere destPoint
#'
#' @importFrom grid polygonGrob gpar
#'
#'
#' @examples
#'
#' \dontrun{data_manipulation("ebtrk_atlc_1988_2015.txt")}
#'
#' \dontrun{data_manipulation("ebtrk_atlc_1988_2017.txt")}
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
