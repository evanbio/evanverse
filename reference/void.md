# Void Value Utilities

A comprehensive suite of functions for detecting, removing, and managing
"void" values (NA, NULL, and empty strings) in R objects.

## Usage

``` r
is_void(x, include_na = TRUE, include_null = TRUE, include_empty_str = TRUE)

any_void(x, include_na = TRUE, include_null = TRUE, include_empty_str = TRUE)

drop_void(x, include_na = TRUE, include_null = TRUE, include_empty_str = TRUE)

replace_void(
  x,
  value = NA,
  include_na = TRUE,
  include_null = TRUE,
  include_empty_str = TRUE
)

cols_with_void(
  data,
  include_na = TRUE,
  include_null = TRUE,
  include_empty_str = TRUE,
  return_names = TRUE
)

rows_with_void(
  data,
  include_na = TRUE,
  include_null = TRUE,
  include_empty_str = TRUE
)
```

## Arguments

- x:

  A vector or list.

- include_na:

  Logical. Detect `NA` if TRUE. Default: TRUE.

- include_null:

  Logical. Detect `NULL` if TRUE. Default: TRUE.

- include_empty_str:

  Logical. Detect empty strings `""` if TRUE. Default: TRUE.

- value:

  The replacement value to use for voids. Default: `NA`.

- data:

  A data.frame or tibble.

- return_names:

  Logical. If TRUE (default), return column names; else logical vector.

## Value

A logical vector indicating which elements are void.

- If `x` is `NULL`, returns a single `TRUE` (if include_null=TRUE) or
  `FALSE`.

- If `x` is an empty vector, returns `logical(0)`.

- If `x` is a list, evaluates each element recursively and returns a
  flattened logical vector.

- For atomic vectors, returns a logical vector of the same length.

A single logical value:

- `TRUE` if any void values are present.

- `FALSE` otherwise.

- For `NULL` input, returns `TRUE` if `include_null = TRUE`, else
  `FALSE`.

A cleaned vector or list of the same type as input, with void values
removed.

A cleaned vector or list with void values replaced.

A character vector (column names) or logical vector indicating void
presence per column.

A logical vector of length `nrow(data)` indicating whether each row
contains at least one void value.

## Details

The void utilities family consists of:

- `is_void`: Core detection function returning logical vector

- `any_void`: Check if any void value exists

- `drop_void`: Remove void values from vectors/lists

- `replace_void`: Replace void values with custom values

- `cols_with_void`: Detect columns containing void values

- `rows_with_void`: Detect rows containing void values

All functions support customizable void detection through three
parameters:

- `include_na`: Consider `NA` as void (default: TRUE)

- `include_null`: Consider `NULL` as void (default: TRUE)

- `include_empty_str`: Consider `""` as void (default: TRUE)

## is_void()

Check for Null / NA / Blank ("") Values

Determine whether input values are considered "void": `NULL`, `NA`, or
`""`. Each condition is controlled by a dedicated argument.

## any_void()

Check if Any Value is Void (NA / NULL / "")

Test whether any element in a vector or list is considered "void". Void
values include `NA`, `NULL`, and empty strings (`""`), and you can
customize which ones to consider.

## drop_void

Remove Void Values from a Vector or List

Removes elements from a vector or list that are considered "void": `NA`,
`NULL`, and empty strings (`""`). Each can be toggled via parameters.

## replace_void

Replace void values (NA / NULL / "")

Replace elements in a vector or list considered "void" with a specified
value. Void values include `NA`, `NULL`, and empty strings `""` (toggle
via flags).

## cols_with_void()

Detect Columns Containing Void Values

Scan a data.frame or tibble and identify columns that contain any "void"
values. Void values include `NA`, `NULL`, and `""`, which can be toggled
via parameters.

## rows_with_void

Detect rows containing void values (NA / NULL / "")

Scan a data.frame or tibble and identify rows that contain any "void"
values. Void values include `NA`, `NULL`, and empty strings `""` (toggle
via flags).

## Examples

``` r
is_void(c(NA, "", "text"))                  # TRUE TRUE FALSE
#> [1]  TRUE  TRUE FALSE
is_void(list(NA, "", NULL, "a"))            # TRUE TRUE TRUE FALSE
#> [1]  TRUE  TRUE  TRUE FALSE
is_void("NA", include_na = FALSE)           # FALSE
#> [1] FALSE
is_void(NULL)                               # TRUE
#> [1] TRUE
any_void(c("a", "", NA))                # TRUE
#> [1] TRUE
any_void(list("x", NULL, "y"))          # TRUE
#> [1] TRUE
any_void(c("a", "b", "c"))              # FALSE
#> [1] FALSE
any_void(NULL)                          # TRUE
#> [1] TRUE
any_void("", include_empty_str = FALSE) # FALSE
#> [1] FALSE
drop_void(c("apple", "", NA, "banana"))
#> [1] "apple"  "banana"
drop_void(list("A", NA, "", NULL, "B"))
#> [[1]]
#> [1] "A"
#> 
#> [[2]]
#> [1] "B"
#> 
drop_void(c("", NA), include_na = FALSE)
#> [1] NA
replace_void(c(NA, "", "a"), value = "N/A")
#> [1] "N/A" "N/A" "a"  
replace_void(list("A", "", NULL, NA), value = "missing")
#> [[1]]
#> [1] "A"
#> 
#> [[2]]
#> [1] "missing"
#> 
#> [[3]]
#> [1] "missing"
#> 
#> [[4]]
#> [1] "missing"
#> 
replace_void(c("", "b"), value = 0, include_empty_str = TRUE)
#> [1] "0" "b"
df <- data.frame(name = c("A", "", "C"), score = c(1, NA, 3), id = 1:3)
cols_with_void(df)
#> [1] "name"  "score"
cols_with_void(df, return_names = FALSE)
#>  name score    id 
#>  TRUE  TRUE FALSE 
cols_with_void(df, include_na = FALSE)
#> [1] "name"
df <- data.frame(id = 1:3, name = c("A", "", "C"), score = c(10, NA, 20))
rows_with_void(df)
#> [1] FALSE  TRUE FALSE
df[rows_with_void(df), ]
#>   id name score
#> 2  2         NA
```
