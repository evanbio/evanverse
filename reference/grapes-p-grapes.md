# Paste two strings with a single space

An infix operator for string concatenation with one space between `lhs`
and `rhs`.

## Usage

``` r
lhs %p% rhs
```

## Arguments

- lhs:

  A character vector.

- rhs:

  A character vector.

## Value

A character vector of concatenated strings.

## Note

Both `lhs` and `rhs` must be non-`NA` character vectors; `NA` values and
non-character inputs (including `NULL`) raise an error. Lengths must be
equal, or one side must have length 1.

## Examples

``` r
"Hello" %p% "world"
#> [1] "Hello world"
c("hello", "good") %p% c("world", "morning")
#> [1] "hello world"  "good morning"
```
