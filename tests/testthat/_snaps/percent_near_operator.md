# %near% throws informative error on length mismatch

    Code
      try(c(1, 2, 3) %near% c(1, 2), silent = TRUE)
    Message
      x Length mismatch: 3 vs 2
    Output
      [1] FALSE

# %near% warns on different column names in data.frame

    Code
      result <- try(df1 %near% df2, silent = TRUE)
    Message
      ! Column names differ: "x" vs "y"
    Code
      result
    Output
      [1] TRUE

# %near% throws error on unsupported types (character)

    Code
      result <- try(c("a", "b") %near% c("a", "b"), silent = TRUE)
    Message
      x Unsupported type for a: "character"
    Code
      result
    Output
      [1] FALSE

