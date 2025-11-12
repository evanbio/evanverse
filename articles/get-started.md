# Welcome to evanverse

``` r
library(evanverse)
```

## 👋 Welcome to `evanverse`

**`evanverse`** is a lightweight, modular R toolkit designed to assist
your everyday development workflow — with functions that are simple,
practical, and elegant.

Whether you’re installing packages, building logical filters, or writing
expressive scripts, `evanverse` offers convenience functions that *just
work*.

## 🚀 Installation

``` r
# Recommended installation via GitHub
install.packages("devtools")
devtools::install_github("evanbio/evanverse")
```

## 🔧 Core Functions at a Glance

### `%p%` — String concatenation operator

``` r
"Good" %p% "morning"
#> [1] "Good morning"
#> [1] "Good morning"
```

### `combine_logic()` — Combine logical vectors in parallel

``` r
combine_logic(c(TRUE, FALSE), c(TRUE, TRUE))
#> [1]  TRUE FALSE
#> [1] TRUE FALSE
```

## 📦 Full Function Overview

| Function                                                                            | Description                            |
|-------------------------------------------------------------------------------------|----------------------------------------|
| `%p%`                                                                               | Concatenates strings with space        |
| `%is%`                                                                              | Expressive conditional matching        |
| [`combine_logic()`](https://evanbio.github.io/evanverse/reference/combine_logic.md) | Combines multiple logical vectors      |
| [`remind()`](https://evanbio.github.io/evanverse/reference/remind.md)               | Random reminders for better mood       |
| [`with_timer()`](https://evanbio.github.io/evanverse/reference/with_timer.md)       | Time any function easily               |
| [`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md)           | Install packages from multiple sources |
| [`update_pkg()`](https://evanbio.github.io/evanverse/reference/update_pkg.md)       | Update all packages (CRAN/Bio/GitHub)  |

## 📘 Additional Resources

- 📄 [README on GitHub](https://github.com/evanbio/evanverse)

- 🌐 [Documentation site](https://evanbio.github.io/evanverse/)

- ❔ View all functions: `?evanverse` or
  [`help(package = "evanverse")`](https://evanbio.github.io/evanverse/reference)

## 💬 A note from the author

> You’re building your own verse in R — let this toolkit help you move
> faster, smoother, and a little happier along the way.

—— Evan Zhou
