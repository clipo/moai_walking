# R Style Guide for Moai Walking Hypothesis Project

This guide defines the coding standards and conventions used throughout the R analysis scripts in this project.

## Package Management

### 1. Use Explicit Namespace Notation
Always use `package::function()` notation instead of relying on attached packages:

```r
# GOOD
data <- readxl::read_excel("file.xlsx")
plot <- ggplot2::ggplot(data, ggplot2::aes(x = x, y = y))

# AVOID
library(readxl)
data <- read_excel("file.xlsx")
```

### 2. Load Packages Without Attaching
Use `requireNamespace()` to check for packages without attaching them:

```r
# Check and install if needed
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}
```

### 3. Exception for Pipe Operator
The pipe operator `%>%` from dplyr/magrittr can be used without prefix for readability:

```r
# ACCEPTABLE
data %>%
  dplyr::filter(x > 0) %>%
  dplyr::mutate(y = x * 2)
```

## Benefits of This Approach

1. **Clarity**: Always clear which package a function comes from
2. **Avoid Conflicts**: No namespace collisions (e.g., `dplyr::filter()` vs `stats::filter()`)
3. **Reproducibility**: Explicit dependencies make it easier to understand requirements
4. **Debugging**: Easier to identify source of functions when debugging

## Common Package Prefixes Used

| Package | Common Functions | Usage |
|---------|-----------------|--------|
| `readxl::` | `read_excel()` | Reading Excel files |
| `ggplot2::` | `ggplot()`, `aes()`, `geom_*()`, `ggsave()` | Visualization |
| `dplyr::` | `filter()`, `mutate()`, `select()`, `summarise()` | Data manipulation |
| `tidyr::` | `gather()`, `spread()`, `pivot_*()` | Data reshaping |
| `stats::` | `t.test()`, `cor.test()`, `lm()` | Statistical tests |
| `base::` | Usually not needed (default) | Base R functions |
| `utils::` | `write.csv()`, `read.csv()` | File I/O |
| `grDevices::` | `png()`, `pdf()`, `dev.off()` | Graphics devices |
| `svglite::` | `svglite()` | SVG output for publication |

## Example Script Structure

```r
#!/usr/bin/env Rscript
# Script description

# Check for required packages
required_packages <- c("readxl", "ggplot2", "dplyr")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# Main analysis
data <- readxl::read_excel("data.xlsx")
result <- data %>%
  dplyr::filter(value > 0) %>%
  dplyr::summarise(mean = mean(value))

# Visualization
plot <- ggplot2::ggplot(data, ggplot2::aes(x = x, y = y)) +
  ggplot2::geom_point()

# Save output
ggplot2::ggsave("output.png", plot)
```

## Exceptions

Some functions are so fundamental they don't need prefixes:
- Basic operators: `+`, `-`, `*`, `/`, `<-`, `=`
- Control flow: `if`, `for`, `while`, `function`
- Basic functions: `c()`, `list()`, `data.frame()`, `print()`, `cat()`
- The pipe operator: `%>%`

## File Organization

### Script Location
- All R scripts reside in the `scripts/` directory
- Data files are accessed from `../data/` relative to scripts
- Outputs are saved to `../figures/` relative to scripts

### Figure Naming Convention
- Use format: `Figure_N_description` where N is the figure number
- Always include three formats: SVG, PNG (600 dpi), and preview PNG (150 dpi)
- Example: `Figure_2_moai_ratio_comparison.svg`

### Data Processing
- Use real data only - never generate synthetic/demo data
- Provide clear error messages when data is missing
- Document data sources in script headers

## Statistical Reporting

### Required Elements
- Always report test statistic, p-value, and sample sizes
- Use Welch's t-test for group comparisons (accounts for unequal variances)
- Include confidence intervals where appropriate
- Set random seed to 42 for reproducibility

### Example Format
```r
# Perform statistical test
test_result <- stats::t.test(group1, group2, var.equal = FALSE)

# Report results
cat(sprintf("t = %.3f, p = %.3f, n1 = %d, n2 = %d\n",
            test_result$statistic,
            test_result$p.value,
            length(group1),
            length(group2)))
```

## Migration Strategy

When updating existing scripts:
1. Remove all `library()` calls except for essential ones
2. Add package checks at the beginning
3. Prefix all package-specific functions
4. Test to ensure functionality is preserved
5. Document any special dependencies