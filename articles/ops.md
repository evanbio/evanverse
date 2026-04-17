# Custom Infix Operators

## Overview

The ops module provides five infix operators that cover four common
tasks:

| Task                      | Operators          |
|---------------------------|--------------------|
| String concatenation      | `%p%`              |
| Set membership            | `%nin%`            |
| Case-insensitive matching | `%match%`, `%map%` |
| Strict equality           | `%is%`             |

``` r
library(evanverse)
```

> **Note:** All code examples in this vignette are static
> (`eval = FALSE`). Output is hand-written to reflect the current
> implementation. If you modify the operators, re-verify the examples
> manually or switch chunks to `eval = TRUE`.

All operators that accept character input validate their arguments and
raise an informative error for non-character or `NA` inputs. `%match%`
and `%map%` also reject empty strings. `%nin%` and `%is%` are
unrestricted — they mirror base R behaviour for any type.

------------------------------------------------------------------------

## 1 String Concatenation

### `%p%` — Paste with a space

Concatenates two character vectors element-wise with a single space.
Equivalent to `paste(lhs, rhs, sep = " ")` but reads more naturally in
pipelines.

``` r
"Hello" %p% "world"
#> [1] "Hello world"

c("good", "hello") %p% c("morning", "world")
#> [1] "good morning" "hello world"
```

A length-1 operand is recycled over the longer vector in the usual R
fashion:

``` r
"Gene:" %p% c("TP53", "BRCA1", "MYC")
#> [1] "Gene: TP53"  "Gene: BRCA1" "Gene: MYC"
```

Other unequal lengths are rejected rather than recycled silently:

``` r
c("a", "b", "c") %p% c("x", "y")
#> Error in `%p%()`:
#> ! `lhs` and `rhs` must have equal lengths, or one side must have length 1.
```

Empty strings are valid — the space is always inserted:

``` r
"" %p% "world"
#> [1] " world"
```

`NA` values and non-character inputs are rejected:

``` r
"Hello" %p% NA
#> Error in `%p%()`:
#> ! `rhs` must be a non-empty character vector without NA values.

123 %p% "world"
#> Error in `%p%()`:
#> ! `lhs` must be a non-empty character vector without NA values.
```

------------------------------------------------------------------------

## 2 Set Membership

### `%nin%` — Not-in operator

Returns `TRUE` for every element of `x` that is **not** present in
`table`. A concise alternative to `!(x %in% table)`.

``` r
c("A", "B", "C") %nin% c("B", "D")
#> [1]  TRUE FALSE  TRUE

1:5 %nin% c(2, 4)
#> [1]  TRUE FALSE  TRUE FALSE  TRUE
```

`%nin%` mirrors `%in%` exactly — it accepts any type and follows base R
semantics for `NA` and type coercion:

``` r
# NA matches NA in the table
NA %nin% c(NA, 1)
#> [1] FALSE

# NA does not match non-NA elements
NA %nin% c(1, 2)
#> [1] TRUE
```

R coerces types before comparing, so character strings can match numeric
values by their printed representation:

``` r
c("1", "2") %nin% c(1, 2)
#> [1] FALSE FALSE
```

Empty vectors return zero-length results without error:

``` r
c("a", "b") %nin% character(0)   # nothing to be in
#> [1] TRUE TRUE

character(0) %nin% c("a", "b")
#> logical(0)
```

------------------------------------------------------------------------

## 3 Case-Insensitive Matching

Both `%match%` and `%map%` lower-case both sides before comparing, so
`"tp53"` and `"TP53"` are treated as the same string. Both require
non-`NA`, non-empty character vectors on both sides, and both reject
empty strings.

### `%match%` — Return match indices

Like [`base::match()`](https://rdrr.io/r/base/match.html), but
case-insensitive. Returns an integer vector of positions; unmatched
elements become `NA`.

``` r
c("tp53", "BRCA1", "egfr") %match% c("TP53", "EGFR", "MYC")
#> [1]  1 NA  2
```

When `table` contains duplicates after case normalisation, the index of
the **first** match is returned with a warning:

``` r
c("x") %match% c("X", "x", "X")
#> Warning: `table` contains duplicated value after case normalization: "x".
#> Using the first match.
#> [1] 1
```

Duplicate elements in `x` are each matched independently:

``` r
c("tp53", "tp53") %match% c("TP53", "EGFR")
#> [1] 1 1
```

Non-character inputs, `NA` values, and empty vectors are rejected on
both sides:

``` r
# empty x
character(0) %match% c("TP53")
#> Error in `%match%()`:
#> ! `x` must be a non-empty character vector without NA values.

# NA in x
c("tp53", NA) %match% c("TP53")
#> Error in `%match%()`:
#> ! `x` must be a non-empty character vector without NA values.

# empty table
c("tp53") %match% character(0)
#> Error in `%match%()`:
#> ! `table` must be a non-empty character vector without NA values.

# NA in table
c("tp53") %match% c("TP53", NA)
#> Error in `%match%()`:
#> ! `table` must be a non-empty character vector without NA values.

# empty string in x
c("tp53", "") %match% c("TP53")
#> Error in `%match%()`:
#> ! `x` must not contain NA or empty string values.
```

------------------------------------------------------------------------

### `%map%` — Return a named character vector

Like `%match%`, but returns a **named character vector** instead of
indices. Names are the canonical entries from `table`; values are the
original elements from `x`. Unmatched entries are silently dropped.
Output order follows `x`.

``` r
c("tp53", "brca1", "egfr") %map% c("TP53", "EGFR", "MYC")
#>   TP53   EGFR
#> "tp53" "egfr"
```

Output order follows `x`, not `table`:

``` r
c("egfr", "tp53") %map% c("TP53", "EGFR")
#>   EGFR   TP53
#> "egfr" "tp53"
```

Unmatched elements are dropped rather than returned as `NA`:

``` r
c("akt1", "tp53") %map% c("TP53", "EGFR")
#>   TP53
#> "tp53"
```

When nothing matches, an empty named character vector is returned:

``` r
c("none1", "none2") %map% c("TP53", "EGFR")
#> named character(0)
```

Duplicate elements in `x` that match are both retained:

``` r
c("tp53", "tp53") %map% c("TP53", "EGFR")
#>   TP53   TP53
#> "tp53" "tp53"
```

Duplicate values in `table` after case normalisation warn and use the
first canonical entry:

``` r
c("tp53") %map% c("TP53", "tp53")
#> Warning: `table` contains duplicated value after case normalization: "tp53".
#> Using the first match.
#>   TP53
#> "tp53"
```

The same error rules as `%match%` apply on both sides:

``` r
# empty x
character(0) %map% c("TP53")
#> Error in `%map%()`:
#> ! `x` must be a non-empty character vector without NA values.

# NA in x
c("tp53", NA) %map% c("TP53")
#> Error in `%map%()`:
#> ! `x` must be a non-empty character vector without NA values.

# empty table
c("tp53") %map% character(0)
#> Error in `%map%()`:
#> ! `table` must be a non-empty character vector without NA values.

# NA in table
c("tp53") %map% c("TP53", NA)
#> Error in `%map%()`:
#> ! `table` must be a non-empty character vector without NA values.

# empty string in table
c("tp53") %map% c("TP53", "")
#> Error in `%map%()`:
#> ! `table` must not contain NA or empty string values.
```

------------------------------------------------------------------------

## 4 Strict Equality

### `%is%` — Identical comparison

Wraps [`base::identical()`](https://rdrr.io/r/base/identical.html).
Returns a single `TRUE` or `FALSE` with no tolerance for type or
attribute differences.

``` r
1:3 %is% 1:3
#> [1] TRUE

"hello" %is% "hello"
#> [1] TRUE

list(a = 1) %is% list(a = 1)
#> [1] TRUE
```

Unlike `==`, `%is%` distinguishes types, names, and storage mode:

``` r
1:3 %is% c(1, 2, 3)          # integer vs double
#> [1] FALSE

c(a = 1, b = 2) %is% c(b = 1, a = 2)   # same values, different names
#> [1] FALSE
```

`NULL` and `NA` variants are handled correctly:

``` r
NULL %is% NULL
#> [1] TRUE

NA %is% NA
#> [1] TRUE

NA %is% NA_real_   # logical NA vs double NA
#> [1] FALSE
```

`%is%` accepts any type — there is no input restriction.

------------------------------------------------------------------------

## 5 A Combined Workflow

The operators compose naturally in bioinformatics pipelines. The example
below filters a gene table to canonical symbols, maps aliases to their
official form, then labels each gene’s match status.

``` r
library(evanverse)

canonical <- c("TP53", "BRCA1", "EGFR", "MYC", "PTEN")
query     <- c("tp53", "brca1", "AKT1", "egfr", "unknown")

# 1. Which queries are not in the canonical set (case-insensitive)?
missing_idx <- which(is.na(query %match% canonical))
query[missing_idx]
#> [1] "AKT1"    "unknown"

# 2. Map matched queries to their canonical names
query %map% canonical
#>    TP53   BRCA1    EGFR
#> "tp53" "brca1"  "egfr"

# 3. Build an annotation column using %p%
anno <- "Gene:" %p% canonical
anno
#> [1] "Gene: TP53"  "Gene: BRCA1" "Gene: EGFR"  "Gene: MYC"   "Gene: PTEN"

# 4. Check that the canonical list hasn't changed
canonical %is% c("TP53", "BRCA1", "EGFR", "MYC", "PTEN")
#> [1] TRUE
```

------------------------------------------------------------------------

## Getting Help

- [`?"%p%"`](https://evanbio.github.io/evanverse/reference/grapes-p-grapes.md),
  [`?"%nin%"`](https://evanbio.github.io/evanverse/reference/grapes-nin-grapes.md),
  [`?"%match%"`](https://evanbio.github.io/evanverse/reference/grapes-match-grapes.md),
  [`?"%map%"`](https://evanbio.github.io/evanverse/reference/grapes-map-grapes.md),
  [`?"%is%"`](https://evanbio.github.io/evanverse/reference/grapes-is-grapes.md)
- [GitHub Issues](https://github.com/evanbio/evanverse/issues)
