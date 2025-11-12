# Data Processing & Transformation

## 🔄 Data Processing & Transformation with evanverse

This guide covers the comprehensive data processing and transformation
capabilities of evanverse, with special focus on void value handling and
data manipulation utilities.

``` r
library(evanverse)
library(dplyr)
```

### 🕳️ Understanding Void Values

In data analysis, “void” values are elements that represent missing or
absent data. The evanverse package provides a comprehensive system for
handling these values.

#### What Are Void Values?

Void values in evanverse include: - `NA` (missing values) - `NULL` (null
values) - `""` (empty strings)

``` r
# Examples of void values
void_examples <- list(
  numbers = c(1, NA, 3, 4),
  strings = c("A", "", "C", NA),
  mixed = c("text", NA, "", "data")
)

print("Examples of data with void values:")
#> [1] "Examples of data with void values:"
str(void_examples)
#> List of 3
#>  $ numbers: num [1:4] 1 NA 3 4
#>  $ strings: chr [1:4] "A" "" "C" NA
#>  $ mixed  : chr [1:4] "text" NA "" "data"
```

### 🔍 Detecting Void Values

#### Single Value Checks

``` r
# Check if individual values are void
print(is_void(NA))           # TRUE
#> [1] TRUE
print(is_void(""))           # TRUE
#> [1] TRUE
print(is_void(NULL))         # TRUE
#> [1] TRUE
print(is_void("hello"))      # FALSE
#> [1] FALSE
print(is_void(0))            # FALSE
#> [1] FALSE
```

#### Vector Checks

``` r
# Check if any element in a vector is void
test_vector <- c("A", "", "C", NA, "E")
print(any_void(test_vector))  # TRUE
#> [1] TRUE

# Example with no void values
clean_vector <- c("A", "B", "C")
print(any_void(clean_vector))  # FALSE
#> [1] FALSE
```

#### Data Frame Analysis

``` r
# Create sample data with various void patterns
sample_data <- data.frame(
  id = 1:6,
  name = c("Alice", "", "Charlie", NA, "Eve", "Frank"),
  age = c(25, 30, NA, 35, 28, 32),
  city = c("NYC", "LA", "", "Chicago", NA, "Boston"),
  stringsAsFactors = FALSE
)

print("Sample data with void values:")
#> [1] "Sample data with void values:"
print(sample_data)
#>   id    name age    city
#> 1  1   Alice  25     NYC
#> 2  2          30      LA
#> 3  3 Charlie  NA        
#> 4  4    <NA>  35 Chicago
#> 5  5     Eve  28    <NA>
#> 6  6   Frank  32  Boston

# Identify columns with void values
void_cols <- cols_with_void(sample_data)
print(paste("Columns with void values:", paste(void_cols, collapse = ", ")))
#> [1] "Columns with void values: name, age, city"

# Identify rows with void values
void_rows <- rows_with_void(sample_data)
print(paste("Rows with void values:", paste(void_rows, collapse = ", ")))
#> [1] "Rows with void values: FALSE, TRUE, TRUE, TRUE, TRUE, FALSE"
```

### 🔧 Replacing Void Values

#### Basic Replacement

``` r
# Replace all void values with a single replacement
messy_vector <- c("A", "", "C", NA, "E")
clean_vector <- replace_void(messy_vector, value = "MISSING")

print("Original vector:")
#> [1] "Original vector:"
print(messy_vector)
#> [1] "A" ""  "C" NA  "E"
print("After replacement:")
#> [1] "After replacement:"
print(clean_vector)
#> [1] "A"       "MISSING" "C"       "MISSING" "E"
```

#### Selective Replacement

``` r
# Replace only specific types of void values
mixed_data <- c("A", "", "C", NA, "E")

# Replace only empty strings
only_empty <- replace_void(mixed_data,
                          value = "EMPTY",
                          include_na = FALSE,
                          include_empty_str = TRUE)

print("Replace only empty strings:")
#> [1] "Replace only empty strings:"
print(only_empty)
#> [1] "A"     "EMPTY" "C"     NA      "E"

# Replace only NA values
only_na <- replace_void(mixed_data,
                       value = "NOT_AVAILABLE",
                       include_na = TRUE,
                       include_empty_str = FALSE)

print("Replace only NA values:")
#> [1] "Replace only NA values:"
print(only_na)
#> [1] "A"             ""              "C"             "NOT_AVAILABLE"
#> [5] "E"
```

#### Data Frame Replacement

``` r
# Apply replacement column by column
clean_data <- sample_data
clean_data$name <- replace_void(sample_data$name, value = "UNKNOWN")
clean_data$city <- replace_void(sample_data$city, value = "UNKNOWN")

print("Data after void replacement:")
#> [1] "Data after void replacement:"
print(clean_data)
#>   id    name age    city
#> 1  1   Alice  25     NYC
#> 2  2 UNKNOWN  30      LA
#> 3  3 Charlie  NA UNKNOWN
#> 4  4 UNKNOWN  35 Chicago
#> 5  5     Eve  28 UNKNOWN
#> 6  6   Frank  32  Boston
```

### ✂️ Removing Void Values

#### Drop Elements with Void Values

``` r
# For vectors, drop_void removes void elements
test_vector <- c("A", "", "C", NA, "E")
clean_vector <- drop_void(test_vector)

print("Original vector:")
#> [1] "Original vector:"
print(test_vector)
#> [1] "A" ""  "C" NA  "E"
print("After dropping void elements:")
#> [1] "After dropping void elements:"
print(clean_vector)
#> [1] "A" "C" "E"

# For data analysis, we can identify problematic rows/columns
print("Rows with void values:")
#> [1] "Rows with void values:"
print(rows_with_void(sample_data))
#> [1] FALSE  TRUE  TRUE  TRUE  TRUE FALSE
print("Columns with void values:")
#> [1] "Columns with void values:"
print(cols_with_void(sample_data))
#> [1] "name" "age"  "city"
```

### 📊 Data Transformation

#### Converting Data Frames to Lists

``` r
# Group data by a key column and create lists
mtcars_subset <- mtcars[1:12, c("cyl", "mpg", "hp", "wt")]

# Group by cylinder count, focusing on MPG values
grouped_cars <- df2list(
  data = mtcars_subset,
  key_col = "cyl",
  value_col = "mpg"
)

print("Cars grouped by cylinder count (MPG values):")
#> [1] "Cars grouped by cylinder count (MPG values):"
str(grouped_cars)
#> List of 3
#>  $ 4: num [1:3] 22.8 24.4 22.8
#>  $ 6: num [1:6] 21 21 21.4 18.1 19.2 17.8
#>  $ 8: num [1:3] 18.7 14.3 16.4

# Access specific groups
print("4-cylinder cars MPG values:")
#> [1] "4-cylinder cars MPG values:"
print(grouped_cars[["4"]])
#> [1] 22.8 24.4 22.8
```

#### Column Mapping

``` r
# Map values in a column using a named vector
grades_data <- data.frame(
  student = c("Alice", "Bob", "Charlie", "Diana"),
  grade_letter = c("A", "B", "A", "C")
)

# Create mapping for letter grades to numbers
grade_mapping <- c("A" = 4.0, "B" = 3.0, "C" = 2.0, "D" = 1.0, "F" = 0.0)

# Apply mapping using the correct parameters
result <- map_column(
  query = grades_data,
  by = "grade_letter",
  map = grade_mapping,
  to = "grade_numeric"
)
#>   student grade_letter grade_numeric
#> 1   Alice            A             4
#> 2     Bob            B             3
#> 3 Charlie            A             4
#> 4   Diana            C             2

print("Grades with numeric mapping:")
#> [1] "Grades with numeric mapping:"
print(result)
#>   student grade_letter grade_numeric
#> 1   Alice            A             4
#> 2     Bob            B             3
#> 3 Charlie            A             4
#> 4   Diana            C             2
```

### 💾 Advanced File Operations

#### Flexible Table Reading

``` r
# Read various file formats with automatic detection
data1 <- read_table_flex("data.csv")
data2 <- read_table_flex("data.tsv", sep = "\t")
data3 <- read_table_flex("data.txt", header = TRUE)

# Read Excel files with flexibility
excel_data <- read_excel_flex("workbook.xlsx", sheet = "Sheet1")
```

#### File Information and Management

``` r
# Get comprehensive file information
info <- file_info("myfile.csv")
print(info)

# Extract file extensions
files <- c("data.csv", "analysis.R", "report.pdf")
extensions <- sapply(files, get_ext)
print(extensions)

# Display directory structure
file_tree(".", max_depth = 2)
```

### ⚡ Custom Operators for Data Processing

#### String Operations

``` r
# Paste operator for clean string concatenation
full_name <- "John" %p% " " %p% "Doe"
print(full_name)
#> [1] "John   Doe"

file_path <- "data" %p% "/" %p% "analysis" %p% ".csv"
print(file_path)
#> [1] "data / analysis .csv"
```

#### Logical Operations

``` r
# Enhanced "not in" operator
fruits <- c("apple", "banana", "orange")
check_fruits <- c("apple", "grape", "banana", "kiwi")

# Find fruits not in our list
missing_fruits <- check_fruits[check_fruits %nin% fruits]
print(paste("Missing fruits:", paste(missing_fruits, collapse = ", ")))
#> [1] "Missing fruits: grape, kiwi"

# Enhanced identity checking
print(5 %is% 5)        # TRUE
#> [1] TRUE
print("a" %is% "a")    # TRUE
#> [1] TRUE
print(5 %is% "5")      # FALSE
#> [1] FALSE
```

#### Combinatorial Operations

``` r
# Generate combinations and permutations
items <- c("A", "B", "C", "D")

# Calculate combination numbers
combinations_count <- comb(4, 2)  # C(4,2) = 6
print(paste("Number of ways to choose 2 items from 4:", combinations_count))
#> [1] "Number of ways to choose 2 items from 4: 6"

# Calculate permutation numbers
permutations_count <- perm(4, 2)  # P(4,2) = 12
print(paste("Number of ways to arrange 2 items from 4:", permutations_count))
#> [1] "Number of ways to arrange 2 items from 4: 12"
```

### 🔗 Complex Data Processing Workflows

#### Real-world Example: Survey Data Cleaning

``` r
# Simulate messy survey data
survey_data <- data.frame(
  id = 1:8,
  age = c(25, "", 30, NA, "35", 28, 0, 45),
  income = c("50000", "", NA, "75000", "60000", "invalid", "80000", ""),
  satisfaction = c(5, 4, "", 3, NA, 5, 4, 2),
  stringsAsFactors = FALSE
)

print("Original messy survey data:")
#> [1] "Original messy survey data:"
print(survey_data)
#>   id  age  income satisfaction
#> 1  1   25   50000            5
#> 2  2                         4
#> 3  3   30    <NA>             
#> 4  4 <NA>   75000            3
#> 5  5   35   60000         <NA>
#> 6  6   28 invalid            5
#> 7  7    0   80000            4
#> 8  8   45                    2

# Step 1: Identify problematic data
cat("\nData quality assessment:\n")
#> 
#> Data quality assessment:
cat("Columns with void values:", paste(cols_with_void(survey_data), collapse = ", "), "\n")
#> Columns with void values: age, income, satisfaction
cat("Rows with void values:", paste(rows_with_void(survey_data), collapse = ", "), "\n")
#> Rows with void values: FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, TRUE

# Step 2: Clean the data
# Replace void values with appropriate defaults
survey_clean <- survey_data
survey_clean$age <- replace_void(survey_clean$age, value = "25")
survey_clean$income <- replace_void(survey_clean$income, value = "50000")
survey_clean$satisfaction <- replace_void(survey_clean$satisfaction, value = 3)

# Convert to appropriate types
survey_clean$age <- as.numeric(survey_clean$age)
survey_clean$income <- as.numeric(survey_clean$income)
survey_clean$satisfaction <- as.numeric(survey_clean$satisfaction)

# Handle special cases (e.g., age = 0, income = "invalid")
survey_clean$age[survey_clean$age == 0] <- 25
survey_clean$income[is.na(survey_clean$income)] <- 50000

print("Cleaned survey data:")
#> [1] "Cleaned survey data:"
print(survey_clean)
#>   id age income satisfaction
#> 1  1  25  50000            5
#> 2  2  25  50000            4
#> 3  3  30  50000            3
#> 4  4  25  75000            3
#> 5  5  35  60000            3
#> 6  6  28  50000            5
#> 7  7  25  80000            4
#> 8  8  45  50000            2
```

### 📈 Performance Tips

#### Efficient Void Handling

``` r
# For large datasets, check specific columns rather than entire data frame
large_data <- data.frame(
  col1 = sample(c(1:100, NA), 1000, replace = TRUE),
  col2 = sample(c(letters, ""), 1000, replace = TRUE),
  col3 = runif(1000)
)

# Check only columns likely to have voids
critical_cols <- c("col1", "col2")
void_status <- sapply(critical_cols, function(col) any_void(large_data[[col]]))
print("Void status for critical columns:")
#> [1] "Void status for critical columns:"
print(void_status)
#> col1 col2 
#> TRUE TRUE
```

### 🎯 Best Practices

1.  **Always inspect your data** before processing using
    [`cols_with_void()`](https://evanbio.github.io/evanverse/reference/void.md)
    and
    [`rows_with_void()`](https://evanbio.github.io/evanverse/reference/void.md)

2.  **Choose appropriate replacement values** that make sense in your
    domain context

3.  **Document your void handling strategy** for reproducibility

4.  **Use selective replacement** when different types of voids should
    be handled differently

5.  **Validate your results** after transformation to ensure data
    integrity

### 🔗 Next Steps

- Explore [Color Palettes
  guide](https://evanbio.github.io/evanverse/articles/color-palettes.md)
  for plotting cleaned data
- Check out [Bioinformatics
  Workflows](https://evanbio.github.io/evanverse/articles/bioinformatics-workflows.md)
  for domain-specific processing
- Visit the [Color Palettes
  guide](https://evanbio.github.io/evanverse/articles/color-palettes.md)
  for visualization styling

------------------------------------------------------------------------

*The evanverse data processing tools provide a robust foundation for
handling real-world messy data with confidence and efficiency.*
