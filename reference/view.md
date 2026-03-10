# Quick interactive table viewer (reactable)

Quickly view a data.frame or tibble as an interactive table in the
Viewer pane.

## Usage

``` r
view(
  data,
  page_size = 10,
  searchable = TRUE,
  filterable = TRUE,
  striped = TRUE,
  highlight = TRUE,
  compact = FALSE
)
```

## Arguments

- data:

  A data.frame or tibble to display.

- page_size:

  Number of rows per page (default = 10).

- searchable:

  Whether to enable search (default = TRUE).

- filterable:

  Whether to enable column filters (default = TRUE).

- striped:

  Whether to show striped rows (default = TRUE).

- highlight:

  Whether to highlight rows on hover (default = TRUE).

- compact:

  Whether to use a compact layout (default = FALSE).

## Value

A reactable widget rendered in the Viewer pane.

## Examples

``` r
if (requireNamespace("reactable", quietly = TRUE)) {
  view(iris)
  view(mtcars, page_size = 20, striped = TRUE, filterable = TRUE)
}

{"x":{"tag":{"name":"Reactable","attribs":{"data":{".rownames":["Mazda RX4","Mazda RX4 Wag","Datsun 710","Hornet 4 Drive","Hornet Sportabout","Valiant","Duster 360","Merc 240D","Merc 230","Merc 280","Merc 280C","Merc 450SE","Merc 450SL","Merc 450SLC","Cadillac Fleetwood","Lincoln Continental","Chrysler Imperial","Fiat 128","Honda Civic","Toyota Corolla","Toyota Corona","Dodge Challenger","AMC Javelin","Camaro Z28","Pontiac Firebird","Fiat X1-9","Porsche 914-2","Lotus Europa","Ford Pantera L","Ferrari Dino","Maserati Bora","Volvo 142E"],"mpg":[21,21,22.8,21.4,18.7,18.1,14.3,24.4,22.8,19.2,17.8,16.4,17.3,15.2,10.4,10.4,14.7,32.4,30.4,33.9,21.5,15.5,15.2,13.3,19.2,27.3,26,30.4,15.8,19.7,15,21.4],"cyl":[6,6,4,6,8,6,8,4,4,6,6,8,8,8,8,8,8,4,4,4,4,8,8,8,8,4,4,4,8,6,8,4],"disp":[160,160,108,258,360,225,360,146.7,140.8,167.6,167.6,275.8,275.8,275.8,472,460,440,78.7,75.7,71.1,120.1,318,304,350,400,79,120.3,95.1,351,145,301,121],"hp":[110,110,93,110,175,105,245,62,95,123,123,180,180,180,205,215,230,66,52,65,97,150,150,245,175,66,91,113,264,175,335,109],"drat":[3.9,3.9,3.85,3.08,3.15,2.76,3.21,3.69,3.92,3.92,3.92,3.07,3.07,3.07,2.93,3,3.23,4.08,4.93,4.22,3.7,2.76,3.15,3.73,3.08,4.08,4.43,3.77,4.22,3.62,3.54,4.11],"wt":[2.62,2.875,2.32,3.215,3.44,3.46,3.57,3.19,3.15,3.44,3.44,4.07,3.73,3.78,5.25,5.424,5.345,2.2,1.615,1.835,2.465,3.52,3.435,3.84,3.845,1.935,2.14,1.513,3.17,2.77,3.57,2.78],"qsec":[16.46,17.02,18.61,19.44,17.02,20.22,15.84,20,22.9,18.3,18.9,17.4,17.6,18,17.98,17.82,17.42,19.47,18.52,19.9,20.01,16.87,17.3,15.41,17.05,18.9,16.7,16.9,14.5,15.5,14.6,18.6],"vs":[0,0,1,1,0,1,0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,1,0,1,0,0,0,1],"am":[1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1],"gear":[4,4,4,3,3,3,3,4,4,4,4,3,3,3,3,3,3,4,4,4,3,3,3,3,3,4,5,5,5,5,5,4],"carb":[4,4,1,1,2,1,4,2,2,4,4,3,3,3,4,4,4,1,2,1,1,2,2,4,2,1,2,2,4,6,8,2]},"columns":[{"id":".rownames","name":"","type":"character","sortable":false,"filterable":false,"rowHeader":true},{"id":"mpg","name":"mpg","type":"numeric"},{"id":"cyl","name":"cyl","type":"numeric"},{"id":"disp","name":"disp","type":"numeric"},{"id":"hp","name":"hp","type":"numeric"},{"id":"drat","name":"drat","type":"numeric"},{"id":"wt","name":"wt","type":"numeric"},{"id":"qsec","name":"qsec","type":"numeric"},{"id":"vs","name":"vs","type":"numeric"},{"id":"am","name":"am","type":"numeric"},{"id":"gear","name":"gear","type":"numeric"},{"id":"carb","name":"carb","type":"numeric"}],"resizable":true,"filterable":true,"searchable":true,"defaultPageSize":20,"showPageInfo":true,"highlight":true,"bordered":true,"striped":true,"theme":{"borderColor":"#dee2e6","stripedColor":"#f6f8fa","highlightColor":"#e8f4fa","headerStyle":{"fontWeight":"bold","fontSize":"14px","backgroundColor":"#f7f7f8","color":"#333333","borderBottom":"2px solid #dee2e6"},"cellStyle":{"fontSize":"13px","color":"#555555","padding":"8px 12px"}},"dataKey":"5b3b1b9433e88dd26cbc4c3644e92607"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}
```
