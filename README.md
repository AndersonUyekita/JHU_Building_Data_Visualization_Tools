
<!-- README.md is generated from README.Rmd. Please edit that file -->
Peer-graded Assignment: Build a New Geom
========================================

> This is a deliverable of the *Building Data Visualization Tools* course, the 4th course of the *Mastering Software Development in R* offered by the Johns Hopkins University.

In this project I have created a new `geom_*` of the `ggplot2` package. This `geom_*` offers a new approach of data visualization.

Development of a `geom_*`
-------------------------

This project was a bit difficult due to the lack of information passed in class (it means: Reading the <a href="https://bookdown.org/rdpeng/RProgDA/" target="_blank">"Mastering Software Development in R"</a>). However, it is possible to accomplish this assignment reading *many* times (until internalize the knowledge behind the `ggproto`).

### Understanding the new `geom_*`

The objective of this `geom_*` is to plot a *pie-like-chart* of wind speed for each hurricane given its latitude and longitude.

    +------+------+
    |      |      |
    |  Q2  |  Q1  |
    |      |      |
    +------O------+
    |      |      |
    |  Q3  |  Q4  |
    |      |      |
    +------+------+

Where,

-   O : center of the hurricane;
-   Q1, Q2, Q3 and Q4: Quadrant.

The new `geom_*` must use the center of the hurricane (O) as the center of the plot, and each quadrant has your own values of wind speed. Mind to the quadrant beacuse there are 3 values of wind speed (*categories*), this shows the area covered by those wind speed.

### The `geosphere` package tip

Reading the *vignette* of this package, the most relevant function to the assignment is the `destPoint()`. This function calculates a "circle" around a coordinate (x,y).

An example using the package `geosphere` and `ggplot2`.

``` r
# Loading the Packages
library(geosphere)
library(dplyr)
library(ggplot2)
library(geomhurricane)

# Generating the points
destPoint(c(0,0),          # Center of the hurricane
          b=1:360,         # 360 degrees (a complete circle)
          d=10000) %>%     # radius in meters
              as_tibble() %>%   # Converting the output of destPoint to tibble

# Plotting the results       
ggplot(aes(x = lon,
           y = lat)) +geom_polygon()
```

<img src="man/figures/README-unnamed-chunk-1-1.png" width="100%" />

An other example going further to explore a quarter of circle.

``` r
# Generating the points
destPoint(c(0,0),          # Center of the hurricane
          b=1:90,          # 360 degrees (a complete circle)
          d=10000) %>%     # radius in meters
              as_tibble() %>%   # Converting the output of destPoint to tibble

# Plotting the results       
ggplot(aes(x = lon,
           y = lat)) + geom_polygon(fill = "tomato3")
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

The result is a little bit weird, but almost there. Now, other example adding the center of the circle.

``` r
# Generating the points
destPoint(c(0,0),          # Center of the hurricane
          b=1:90,          # 360 degrees (a complete circle)
          d=10000) %>%     # radius in meters
       
              as_tibble() %>%   # Converting the output of destPoint to tibble
       
                     rbind(c(0,0)) %>% # Adding the center
# Plotting the results       
ggplot(aes(x = lon,
           y = lat)) + geom_polygon(fill = "tomato3")
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

This is what I expected, but let's try something diferent, a composition of 4 sector with distincts radius.

``` r
# Creating a list
df_example <- list()

# My loop to create the 4 data set
for (i in 1:4)
       {
       # Generating the points
       destPoint(c(0, 0),          # Center of the hurricane
                 b=((i-1)*90):(90*i),  # 360 degrees (a complete circle)
                 d=2000 - 200 * i) %>%   # radius
              
              rbind(c(0, 0)) %>% # Adding center/origins
              
                     as_tibble() -> df_example[[i]]
       }

# Ploting in ggplot2
ggplot() + 
       geom_polygon(data = df_example[[1]], # First sector NE
                    aes(x = lon, y = lat),
                    fill = "lightblue") +
       
       geom_polygon(data = df_example[[2]], # Second sector SE
                    aes(x = lon, y = lat),
                    fill = "tomato3") +
       
       geom_polygon(data = df_example[[3]], # Third sector SW
                    aes(x = lon, y = lat),
                    fill = "lightgreen") +
       
       geom_polygon(data = df_example[[4]], # Fourth sector NW
                    aes(x = lon, y = lat),
                    fill = "orange")
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

Becareful with the radius because if you try with a high number of radius (more than 1000000) your are going to be in trouble due to the distortion (image of page 6 from the vignette of geosphere - blue circle).

### Radius

The data base is based on the nautical miles, to convert to meters it is just to multiply by 1.852.

<https://en.wikipedia.org/wiki/Knot_(unit)>

### Function Structure

Before build any `geom_*`, I will try to create a simple function as a first step forward to the `geom_*`. Accordling to the instructions, the inputs of the geom are:

-   data = data
-   x = longitude
-   y = latitude
-   r\_ne = ne
-   r\_se = se
-   r\_nw = nw
-   r\_sw = sw
-   fill = wind\_speed
-   color = wind\_speed

``` r
# Function geom_beta
geom_beta <- function(data,
                      x = longitude,
                      y = latitude,
                      r_ne = ne,
                      r_se = se,
                      r_nw = nw,
                      r_sw = sw,
                      fill = wind_speed,
                      color = wind_speed)
       {
# Creating a list to allocate the data frames from ne, se, sw, and nw.
df_example <- list()

# Center of the hurricane
center <- cbind(data$longitude,
                data$latitude)

# Storing the speed in data frame
r_cardinal <- cbind(data$ne,
                    data$se,
                    data$sw,
                    data$nw)

# Loop to create the 4 data set (ne, se, sw, and nw)
for (i in 1:4)
       {
       # Generating the points using destPoint
       destPoint(center[1,],                    # Centering
                 b=((i-1)*90):(90*i),           # 360 degrees (a complete circle)
                 d=r_cardinal[1,i] * 1852) %>%  # radius
              
              rbind(center) %>% # Adding center/origins
              
                     as_tibble() -> df_example[[i]]
       }

# Binds all data frames (ne, se, sw, and nw)
bind_rows(df_example[[1]],
          df_example[[2]],
          df_example[[3]],
          df_example[[4]]) %>%
       
       ggplot() + # Ploting in ggplot2
       
              geom_polygon(data = df_example[[1]], # First sector NE
                           aes(x = lon, y = lat),
                           fill = data$wind_speed[1],
                           color = data$wind_speed[1],
                           alpha = 0.5) +
              
              geom_polygon(data = df_example[[2]], # Second sector SE
                           aes(x = lon, y = lat),
                           fill = data$wind_speed[1],
                           color = data$wind_speed[1],
                           alpha = 0.5) +
              
              geom_polygon(data = df_example[[3]], # Third sector SW
                           aes(x = lon, y = lat),
                           fill = data$wind_speed[1],
                           color = data$wind_speed[1],
                           alpha = 0.5) +
              
              geom_polygon(data = df_example[[4]], # Fourth sector NW
                           aes(x = lon, y = lat),
                           fill = data$wind_speed[1],
                           color = data$wind_speed[1],
                           alpha = 0.5)
}
```

Now, let's test this `geom_beta` function.

``` r
# Importing dataset
data_manipulation(data_import()) %>%
       
       filter(storm_id %in% "KATRINA-2005",                                # Filtering an example
              date %in% lubridate::ymd_hm("2005-08-29-12-00")) -> katrina  # KATRINA 2005

# Using the function
geom_beta(data = katrina)
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

This graphic is far diferent from the instruction. So, I will add the radii speed to produce a complete solution.

### Function Structure + Radii Speed

``` r
# Function geom_beta2
geom_beta2 <- function(data = data,
                      x = longitude,
                      y = latitude,
                      r_ne = ne,
                      r_se = se,
                      r_nw = nw,
                      r_sw = sw,
                      fill = wind_speed,
                      color = wind_speed)
       {
# Creating a list
df_example <- as_tibble()

# Center of the hurricane
center <- cbind(data$longitude,
                data$latitude)

# Storing the speed in data frame
r_cardinal <- cbind(data$ne, # Atention to the sequence of the sector!
                    data$se, # Must be in this order to be correct.
                    data$sw, # Clockwise starting in 12 o'clock as zero degrees
                    data$nw) #

# My loop to create the for quadrants
for (i in 1:4)
       {
       # Loop to create the 34, 50 and 64 knot areas
       for (j in 1:nrow(data))
              {
              # Generating the points
              destPoint(center[j,],
                        b=((i-1)*90):(90*i),           # 360 degrees (a complete circle)
                        d=r_cardinal[j,i] * 1852) %>%  # radius
                     
                     rbind(center) %>% # Adding center/origins
                     
                            as_tibble() %>% # Converting regular data frame to tibble
                     
                                   mutate(i = i,      # Adding columns i and j
                                          j = j) %>%  # Later I will use to filter
                                          
                                          bind_rows(df_example) -> df_example
              }
       }

       # Ploting with ggplot2
       ggplot() + 
              
              geom_polygon(data = (df_example %>%    # Sector NE
                                  filter(i %in% 1,   # 64 knot
                                         j %in% 1)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[1]),
                           alpha = 0.5) +
              
              geom_polygon(data = (df_example %>%    # Sector SE
                                  filter(i %in% 2,   # 64 knot
                                         j %in% 1)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[1]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SW
                                  filter(i %in% 3,   # 64 knot
                                         j %in% 1)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[1]),
                           alpha = 0.5) +
              
              geom_polygon(data = (df_example %>%    # Sector NW
                                  filter(i %in% 4,   # 64 knot
                                         j %in% 1)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[1]),
                           alpha = 0.5)+ 
              
              geom_polygon(data = (df_example %>%    # Sector NE
                                  filter(i %in% 1,   # 50 knot
                                         j %in% 2)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[2]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SE
                                  filter(i %in% 2,   # 50 knot
                                         j %in% 2)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[2]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SW
                                  filter(i %in% 3,   # 50 knot
                                         j %in% 2)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[2]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector NW
                                  filter(i %in% 4,   # 50 knot
                                         j %in% 2)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[2]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector NE
                                  filter(i %in% 1,   # 34 knot
                                         j %in% 3)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[3]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SE
                                  filter(i %in% 2,   # 34 knot
                                         j %in% 3)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[3]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SW
                                  filter(i %in% 3,   # 34 knot
                                         j %in% 3)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[3]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector NW
                                  filter(i %in% 4,   # 34 knot
                                         j %in% 3)),
                           aes(x = lon, y = lat,
                               fill = data$wind_speed[3]),
                           alpha = 0.5)
}
```

The same example using data of Katrina hurricane.

``` r
# Using the function
geom_beta2(data = katrina)
```

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

The same example of Katrina 2005 using additional configuration.

``` r
# Importing dataset
data_manipulation(data_import()) %>%
       
       filter(storm_id %in% "KATRINA-2005",                                # Filtering an example
              date %in% lubridate::ymd_hm("2005-08-29-12-00")) -> katrina  # KATRINA 2005

# Using the function
geom_beta2(data = katrina) +
       
       scale_color_manual(name = "Wind speed (kts)",
                          values = c("red",
                                     "orange",
                                     "yellow")) +
       
       scale_fill_manual(name = "Wind speed (kts)",
                         values = c("red",
                               "orange",
                               "yellow"))
```

<img src="man/figures/README-unnamed-chunk-9-1.png" width="100%" />

### `geom_beta2` with `ggmap`

To perform this I need to create a new function called geom\_beta\_map.

``` r
# Function geom_beta2
geom_beta_map <- function(data = data,
                      x = longitude,
                      y = latitude,
                      r_ne = ne,
                      r_se = se,
                      r_nw = nw,
                      r_sw = sw,
                      fill = wind_speed,
                      color = wind_speed)
       {
# Creating a list
df_example <- as_tibble()

# Center of the hurricane
center <- cbind(data$longitude,
                data$latitude)

# Storing the speed in data frame
r_cardinal <- cbind(data$ne, # Atention to the sequence of the sector!
                    data$se, # Must be in this order to be correct.
                    data$sw, # Clockwise starting in 12 o'clock as zero degrees
                    data$nw) #

# My loop to create the for quadrants
for (i in 1:4)
       {
       # Loop to create the 34, 50 and 64 knot areas
       for (j in 1:nrow(data))
              {
              # Generating the points
              destPoint(center[j,],
                        b=((i-1)*90):(90*i),           # 360 degrees (a complete circle)
                        d=r_cardinal[j,i] * 1852) %>%  # radius
                     
                     rbind(center) %>% # Adding center/origins
                     
                            as_tibble() %>% # Converting regular data frame to tibble
                     
                                   mutate(i = i,      # Adding columns i and j
                                          j = j) %>%  # Later I will use to filter
                                          
                                          bind_rows(df_example) -> df_example
              }
       }

# Loading ggmap package
library(ggmap)

# API Key
register_google(key = "AIzaSyB0fKSElDN-a0LpvhvvWlFNP5CWCFf3jZM")

# Google Maps/Stratmen
get_map("Louisiana",
        zoom = 6,
        maptype = "toner-background") %>%
       
       # Ploting with ggmap
       ggmap(extent = "device") + 

              geom_polygon(data = (df_example %>%    # Sector NE
                                  filter(i %in% 1,   # 64 knot
                                         j %in% 1)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[1]),
                           alpha = 0.5) +
              
              geom_polygon(data = (df_example %>%    # Sector SE
                                  filter(i %in% 2,   # 64 knot
                                         j %in% 1)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[1]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SW
                                  filter(i %in% 3,   # 64 knot
                                         j %in% 1)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[1]),
                           alpha = 0.5) +
              
              geom_polygon(data = (df_example %>%    # Sector NW
                                  filter(i %in% 4,   # 64 knot
                                         j %in% 1)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[1]),
                           alpha = 0.5)+ 
              
              geom_polygon(data = (df_example %>%    # Sector NE
                                  filter(i %in% 1,   # 50 knot
                                         j %in% 2)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[2]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SE
                                  filter(i %in% 2,   # 50 knot
                                         j %in% 2)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[2]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SW
                                  filter(i %in% 3,   # 50 knot
                                         j %in% 2)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[2]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector NW
                                  filter(i %in% 4,   # 50 knot
                                         j %in% 2)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[2]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector NE
                                  filter(i %in% 1,   # 34 knot
                                         j %in% 3)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[3]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SE
                                  filter(i %in% 2,   # 34 knot
                                         j %in% 3)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[3]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SW
                                  filter(i %in% 3,   # 34 knot
                                         j %in% 3)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[3]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector NW
                                  filter(i %in% 4,   # 34 knot
                                         j %in% 3)),
                           aes(x = lon, y = lat,
                               fill = data$wind_speed[3]),
                           alpha = 0.5)
}
```

The same example using a map as background.

``` r
# Using the function
geom_beta_map(data = katrina) +
       
       scale_color_manual(name = "Wind speed (kts)",
                          values = c("red",
                                     "orange",
                                     "yellow")) +
       
       scale_fill_manual(name = "Wind speed (kts)",
                         values = c("red",
                               "orange",
                               "yellow"))
```

<img src="man/figures/README-unnamed-chunk-11-1.png" width="100%" />

### Adding the `scale_radii`

``` r
# Function geom_beta2
geom_beta_map_scale <- function(data = data,
                      x = longitude,
                      y = latitude,
                      r_ne = ne,
                      r_se = se,
                      r_nw = nw,
                      r_sw = sw,
                      fill = wind_speed,
                      color = wind_speed,
                      scale_radii = 1)
       {
# Creating a data frame
df_example <- as_tibble()

# Center of the hurricane
center <- cbind(data$longitude,
                data$latitude)

# Storing the speed in data frame
r_cardinal <- cbind(data$ne * scale_radii, # Atention to the sequence of the sector!
                    data$se * scale_radii, # Must be in this order to be correct.
                    data$sw * scale_radii, # Clockwise starting in 12 o'clock as zero degrees
                    data$nw * scale_radii) #

# My loop to create the for quadrants
for (i in 1:4)
       {
       # Loop to create the 34, 50 and 64 knot areas
       for (j in 1:nrow(data))
              {
              # Generating the points
              destPoint(center[j,],
                        b=((i-1)*90):(90*i),           # 360 degrees (a complete circle)
                        d=r_cardinal[j,i] * 1852) %>%  # radius
                     
                     rbind(center) %>% # Adding center/origins
                     
                            as_tibble() %>% # Converting regular data frame to tibble
                     
                                   mutate(i = i,      # Adding columns i and j
                                          j = j) %>%  # Later I will use to filter
                                          
                                          bind_rows(df_example) -> df_example
              }
       }

# Loading ggmap package
library(ggmap)

# API Key
register_google(key = "AIzaSyB0fKSElDN-a0LpvhvvWlFNP5CWCFf3jZM")

# Google Maps/Stratmen
get_map("Louisiana",
        zoom = 6,
        maptype = "toner-background") %>%
       
       # Ploting with ggmap
       ggmap(extent = "device") + 

              geom_polygon(data = (df_example %>%    # Sector NE
                                  filter(i %in% 1,   # 64 knot
                                         j %in% 1)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[1]),
                           alpha = 0.5) +
              
              geom_polygon(data = (df_example %>%    # Sector SE
                                  filter(i %in% 2,   # 64 knot
                                         j %in% 1)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[1]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SW
                                  filter(i %in% 3,   # 64 knot
                                         j %in% 1)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[1]),
                           alpha = 0.5) +
              
              geom_polygon(data = (df_example %>%    # Sector NW
                                  filter(i %in% 4,   # 64 knot
                                         j %in% 1)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[1]),
                           alpha = 0.5)+ 
              
              geom_polygon(data = (df_example %>%    # Sector NE
                                  filter(i %in% 1,   # 50 knot
                                         j %in% 2)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[2]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SE
                                  filter(i %in% 2,   # 50 knot
                                         j %in% 2)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[2]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SW
                                  filter(i %in% 3,   # 50 knot
                                         j %in% 2)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[2]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector NW
                                  filter(i %in% 4,   # 50 knot
                                         j %in% 2)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[2]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector NE
                                  filter(i %in% 1,   # 34 knot
                                         j %in% 3)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[3]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SE
                                  filter(i %in% 2,   # 34 knot
                                         j %in% 3)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[3]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector SW
                                  filter(i %in% 3,   # 34 knot
                                         j %in% 3)),
                           aes(x = lon, y = lat,
                           fill = data$wind_speed[3]),
                           alpha = 0.5) + 
              
              geom_polygon(data = (df_example %>%    # Sector NW
                                  filter(i %in% 4,   # 34 knot
                                         j %in% 3)),
                           aes(x = lon, y = lat,
                               fill = data$wind_speed[3]),
                           alpha = 0.5)
}
```

The same example using a map as background.

``` r
# Using the function
geom_beta_map_scale(data = katrina,scale_radii = 0.5) +
       
       scale_color_manual(name = "Wind speed (kts)",
                          values = c("red",
                                     "orange",
                                     "yellow")) +
       
       scale_fill_manual(name = "Wind speed (kts)",
                         values = c("red",
                               "orange",
                               "yellow")) +
       
       ggtitle(label = "scale_radii = 0.5") -> gp_half

# Using the function
geom_beta_map_scale(data = katrina,scale_radii = 1.0) +
       
       scale_color_manual(name = "Wind speed (kts)",
                          values = c("red",
                                     "orange",
                                     "yellow")) +
       
       scale_fill_manual(name = "Wind speed (kts)",
                         values = c("red",
                               "orange",
                               "yellow")) +
       
       ggtitle(label = "scale_radii = 1.0") -> gp_plain

# Loading package
library(gridExtra)

# Ploting in a grid style
grid.arrange(gp_plain, # First column scale_radii  = 1.0
             gp_half,  # Second column scale_radii = 0.5
             ncol = 2)
```

<img src="man/figures/README-unnamed-chunk-13-1.png" width="100%" />

Now the output is the same of the instructions, but all made using functions. Let's create a new `geom_*`.

Creating the `ggproto`
----------------------

Before creating any `geom_*` I need to create the class of this `geom_*` will be inherit. For this reason, I must create the Geom class.

The structure of the Geom class (fragment of the Course Book):

    GeomNEW <- ggproto("GeomNEW", Geom,
            required_aes = <a character vector of required aesthetics>,
            default_aes = aes(<default values for certain aesthetics>),
            draw_key = <a function used to draw the key in the legend>,
            draw_panel = function(data, panel_scales, coord) {
                    ## Function that returns a grid grob that will 
                    ## be plotted (this is where the real work occurs)
            }
    )

I will analyze each (of this 4) arguments separetaly, and I will define each one with standard values or creating a complete function.

### required\_aes

As the name says, what is the requerid aesthetics to perform this plot. Requirements.

``` r
# Requeriments 
required_aes = c("x",   # x = longitude
               "y",     # y = latitude
               "r_ne",  # Northeast radius
               "r_se",  # Southeast radius
               "r_sw",  # Southwest radius
               "r_nw")  # Northwest readius
```

### default\_aes

Defaults values to easy the use of the `geom_*`.

``` r
default_aes = aes(colour      = "black", # Line color
                  fill        = "black", # Standard Fill color
                  linetype    = 0,       # No line
                  alpha       = 0.65,    # Transparency
                  scale_radii = 1.0)     # Default value (no reduction)
```

### draw\_key

I'm going to plot a polygon, so I use the appropiated draw\_key called draw\_key\_*polygon*. (You can find more information in ?draw\_key, remember draw\_key is a part of the `ggplot2` package).

``` r
# Defining the draw_key
draw_key = draw_key_polygon
```

### ~~draw\_panel~~ (draw\_group)

I did not find anything clarifying the types of the draw\_panel in the Course Book. Searching in the internet I found in the CRAN Website a good *vignette* about "extending" the ggplot2.

<https://cran.r-project.org/web/packages/ggplot2/vignettes/extending-ggplot2.html>

> **draw\_panel()** is where the magic happens. This function takes three arguments and returns a grid grob. It is called once for each panel. It’s the most complicated part and is described in more detail below.

Keep reading the *vignette* and you will reach the subchapter *Collective geoms*.

> Overriding draw\_panel() is most appropriate if there is one graphic element per row. In other cases, you want graphic element per group. For example, take polygons: each row gives one vertex of a polygon. In this case, you should instead override draw\_group().

This is what we need to know to our `geom_*` development. Keep in mind that:

-   data: a data frame with one column for each aesthetic.
-   panel\_params: a list of per-panel parameters generated by the coord. You should consider this an opaque data structure: don’t look inside it, just pass along to coord methods.
-   coord: an object describing the coordinate system.

``` r
# Building the draw_group
draw_group = function(data,         # a data frame with one column for each aesthetic.
                     panel_params,  # don’t look inside it, just pass along to coord methods.
                     coord) {       # coordinate system.
       
# Creating a data frame
df_example <- as_tibble()

# Center of the hurricane
center <- cbind(data$longitude,
                data$latitude)

# Storing the speed in data frame
r_cardinal <- cbind(data$ne * scale_radii, # Atention to the sequence of the sector!
                    data$se * scale_radii, # Must be in this order to be correct.
                    data$sw * scale_radii, # Clockwise starting in 12 o'clock as zero degrees
                    data$nw * scale_radii) #

# My loop to create the for quadrants
for (i in 1:4)
       {
       # Loop to create the 34, 50 and 64 knot areas
       for (j in 1:nrow(data))
              {
              # Generating the points
              destPoint(center[j,],
                        b=((i-1)*90):(90*i),           # 360 degrees (a complete circle)
                        d=r_cardinal[j,i] * 1852) %>%  # radius covertion to meters
                     
                     rbind(center) %>% # Adding center/origins
                     
                            as_tibble() %>% # Converting regular data frame to tibble
                     
                                   mutate(i = i,      # Adding columns i and j
                                          j = j) %>%  # Later I will use to filter
                                          
                                          bind_rows(df_example) -> df_example
              }
       }
         
       grid::polygonGrob(x = coords$x,
                      y = coords$y,
                      gp = grid::gpar(col = color,
                                      fill = fill,
                                      alpha = alpha))
       }
```

### Binding

I have tried to use the draw\_params, but the outcome of the draw\_panel() function is always a single row. Later, I changed to panel\_scales.

``` r
# Defining the Geom class
GeomHurricane <- ggplot2::ggproto("GeomHurricane",
        Geom,
        required_aes = c("x",  # x = longitude
                      "y",     # y = latitude
                      "r_ne",  # Northeast radius
                      "r_se",  # Southeast radius
                      "r_sw",  # Southwest radius
                      "r_nw"), # Northwest radius
        
        default_aes = ggplot2::aes(colour  = "black",  # Line color
                               fill        = "black",  # Standard Fill color
                               linetype    = 0,        # No line
                               alpha       = 0.65,     # Transparency
                               scale_radii = 1.0),     # Default value (no reduction)
        
        draw_key = draw_key_polygon,
        
        draw_group = function(data,
                              panel_scales,
                              coord) {
# Creating a data frame
df_hurricane <- dplyr::as_tibble()
center       <- dplyr::as_tibble()

# Adding new columns to de data
data %>% dplyr::mutate(fill = fill,     # Creating columns to assign variables
                       colour = colour) #

# Center of the hurricane
data %>% dplyr::select(lon = x,           # longitude
                       lat = y) -> center # latitude

# Calculating the area/radius
data %>% dplyr::select(r_ne,       # 
                       r_se,       # Subsetting
                       r_sw,       #
                       r_nw) %>%   #
       
              dplyr::mutate(r_ne = data$scale_radii * r_ne * 1852, # Converting nautical knots 
                            r_se = data$scale_radii * r_se * 1852, # to meters : knots * 1852
                            r_sw = data$scale_radii * r_sw * 1852, # scale_radii : scale variable
                            r_nw = data$scale_radii * r_nw * 1852) -> radius

# Loop to create the for quadrants (columns)
for (i in 1:4)
{
       # For each quadrant: Loop to create the 34, 50 and 64 knot areas (rows)
       for (j in 1:nrow(data))
       {
              # Generating the points
              geosphere::destPoint(c(x = center[j,1],        # Center of the "circle"
                                     y = center[j,2]),       # 
                                     b = ((i-1)*90):(90*i),  # 360 degrees (a complete circle)
                                     d = radius[j,i]) %>%    # radius
                     
                     rbind(c(x = center[j,1],       # Longitude
                             y = center[j,2])) %>%  # Latitude
                     
                     rbind(df_hurricane) -> df_hurricane # Output: Will be stacked over iteration
       }

# Data Manipulation
df_hurricane %>% 
       
       dplyr::as_tibble() %>% # Converting to tibble
       
              dplyr::rename(x = lon,      # Renaming columns
                            y = lat) %>%  # The ouput of destPoint() function has lon and lat as names.
       
                            coord$transform(panel_scales) -> quadrant_points # Cleaned data redy to plot
}

# Plot the polygon
grid::polygonGrob(x = quadrant_points$x,   # Longitude
                  y = quadrant_points$y,   # Latitude
                  default.units = "native",
                  gp = grid::gpar(col = data$colour,  # Using line color given
                                  fill = data$fill,   # Using fill color given
                                  alpha = data$alpha, # Default value
                                  lty = 1,            # Default value
                                  scale_radii = data$scale_radii))   # scale_radii       
        }
)

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
```

### 2005 Katrina Hurricane

``` r
# Loading ggmap package
library(ggmap)

# API Key
register_google(key = "AIzaSyB0fKSElDN-a0LpvhvvWlFNP5CWCFf3jZM")

# Google Maps/Stratmen
get_map("Louisiana",
        zoom = 6,
        maptype = "toner-background") %>%
       
       # Ploting with ggmap
       ggmap(extent = "device") + 
       
       geom_hurricane(data= katrina,
                          aes(x = longitude,
                          y = latitude,
                          r_ne = ne,
                          r_se = se,
                          r_nw = nw,
                          r_sw = sw,
                          fill = wind_speed,
                          color = wind_speed)) +
       
       scale_color_manual(name = "Wind speed (kts)",
                          values = c("red",
                                     "orange",
                                     "yellow")) +
       
       scale_fill_manual(name = "Wind speed (kts)",
                         values = c("red",
                                    "orange",
                                    "yellow"))
```

<img src="man/figures/README-unnamed-chunk-19-1.png" width="100%" />

2008 Ike Hurricane
------------------

``` r
# Importing dataset
data_manipulation(data_import()) %>%
       
       filter(storm_id %in% "IKE-2008",
              date %in% lubridate::ymd_hm("2008-09-11 18:00")) -> ike_2008 # Data set with 2008 Ike values

# Loading ggmap package
library(ggmap)

# API Key
register_google(key = "AIzaSyB0fKSElDN-a0LpvhvvWlFNP5CWCFf3jZM")

# Google Maps/Stratmen
get_map(location = c(-88.9,25.8), # c(longitude,latitude)
        zoom = 5,
        maptype = "toner-background") %>%
       
       # Saving the map
       ggmap(extent = "device") -> base_map

# Ploting with ggmap
base_map + geom_hurricane(data= ike_2008,
                          aes(x = longitude,
                          y = latitude,
                          r_ne = ne,
                          r_se = se,
                          r_nw = nw,
                          r_sw = sw,
                          fill = wind_speed,
                          color = wind_speed)) +
       
       scale_color_manual(name = "Wind speed (kts)",
                          values = c("red",
                                     "orange",
                                     "yellow")) +
       
       scale_fill_manual(name = "Wind speed (kts)",
                         values = c("red",
                                    "orange",
                                    "yellow"))
```

<img src="man/figures/README-unnamed-chunk-20-1.png" width="100%" />

### 2008 Ike Hurricane using `scale_radii`

This is the output when the `scale_radii` varies from 1 to 0.5.

``` r
# scale_radii = 1.0
base_map + geom_hurricane(data= ike_2008,
                          aes(x = longitude,
                          y = latitude,
                          r_ne = ne,
                          r_se = se,
                          r_nw = nw,
                          r_sw = sw,
                          fill = wind_speed,
                          color = wind_speed)) +
       
       scale_color_manual(name = "Wind speed (kts)",
                          values = c("red",
                                     "orange",
                                     "yellow")) +
       
       scale_fill_manual(name = "Wind speed (kts)",
                         values = c("red",
                                    "orange",
                                    "yellow")) -> example_1

# scale_radii = 0.5
base_map + geom_hurricane(data= ike_2008,
                          aes(x = longitude,
                          y = latitude,
                          r_ne = ne,
                          r_se = se,
                          r_nw = nw,
                          r_sw = sw,
                          fill = wind_speed,
                          color = wind_speed,
                          scale_radii = 0.5)) + 
       
       scale_color_manual(name = "Wind speed (kts)",
                          values = c("red",
                                     "orange",
                                     "yellow")) +
       
       scale_fill_manual(name = "Wind speed (kts)",
                         values = c("red",
                                    "orange",
                                    "yellow")) -> example_2

# Loading package
library(gridExtra)

# Ploting in a grid style
grid.arrange(example_1,  # First column scale_radii  = 1.0
             example_2,  # Second column scale_radii = 0.5
             ncol = 2)
```

<img src="man/figures/README-unnamed-chunk-21-1.png" width="100%" />

### Assignment PNG file

This is the code to export the `png` file.

``` r
# Loading the png package
library(png)

# Creating the png file
png(filename = "assignment_upload.png") # File name

base_map + geom_hurricane(data= ike_2008,
                          aes(x = longitude,
                          y = latitude,
                          r_ne = ne,
                          r_se = se,
                          r_nw = nw,
                          r_sw = sw,
                          fill = wind_speed,
                          color = wind_speed)) +
       
       scale_color_manual(name = "Wind speed (kts)",
                          values = c("red",
                                     "orange",
                                     "yellow")) +
       
       scale_fill_manual(name = "Wind speed (kts)",
                         values = c("red",
                                    "orange",
                                    "yellow")) + 
       
       labs(title = "2008-09-11 18:00 UTC - Ike Hurricane",
            subtitle = "AH Uyekita")

dev.off() # Closing device
```
