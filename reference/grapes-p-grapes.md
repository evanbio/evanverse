# `%p%`: paste two strings with a single space

An infix operator for string concatenation with one space between `lhs`
and `rhs`. Inspired by the readability of `%>%`, intended for expressive
text building.

## Usage

``` r
lhs %p% rhs
```

## Arguments

- lhs:

  A character vector on the left-hand side.

- rhs:

  A character vector on the right-hand side.

## Value

A character vector, concatenating `lhs` and `rhs` with a single space.

## Examples

``` r
"Hello" %p% "world"
#> [1] "Hello world"
"Good" %p% "job"
#> [1] "Good job"
c("hello", "good") %p% c("world", "morning")   # vectorized
#> [1] "hello world"  "good morning"
```
