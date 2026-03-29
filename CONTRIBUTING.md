# Contributing to evanverse

## Reporting Issues

Please check [existing
issues](https://github.com/evanbio/evanverse/issues) before filing a new
one. Include a reproducible example (`reprex::reprex()`) and
[`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html) output.

## Contributing Code

1.  Fork the repo and create a branch from `main`
2.  Add tests for new functionality
3.  Ensure
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    passes with 0 errors and 0 warnings
4.  Submit a pull request

## Development

``` r
devtools::load_all()   # load package
devtools::test()       # run tests
devtools::document()   # update docs
devtools::check()      # full check
```

## Commit Style

    <emoji> <type>: <description>

Common types: `✨ feat` · `🐛 fix` · `📝 docs` · `♻️ refactor` ·
`✅ test` · `🔧 chore`

## CRAN Guidelines

- Use [`tempdir()`](https://rdrr.io/r/base/tempfile.html) in examples;
  never write to the working directory
- Wrap slow/network examples in `\dontrun{}` or add `skip_on_cran()`
- No non-ASCII characters in code

## License

Contributions are licensed under the [MIT
License](https://evanbio.github.io/evanverse/LICENSE.md).
