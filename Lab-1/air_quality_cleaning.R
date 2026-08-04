
required_pkgs <- c("skimr")
for (p in required_pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p)
  }
}
library(skimr)


file_path <- "PRSA_Data_Aotizhongxin_20130301-20170228.csv"

import_dataset <- function(path) {
  tryCatch({
    if (!file.exists(path)) {
      stop("File not found at the given path.")
    }
    data <- read.csv(path, stringsAsFactors = FALSE)
    if (ncol(data) == 0) {
      stop("File format is incorrect: no columns detected.")
    }
    message("File imported successfully.")
    return(data)
  },
  error = function(e) {
    message("ERROR while importing dataset: ", conditionMessage(e))
    return(NULL)
  },
  warning = function(w) {
    message("WARNING while importing dataset: ", conditionMessage(w))
  })
}

air_data <- import_dataset(file_path)

if (!is.null(air_data)) {


  cat("\n----- First 6 records -----\n")
  print(head(air_data))

 
  cat("\n----- Structure of dataset -----\n")
  str(air_data)

  cat("\n----- Dimensions -----\n")
  cat("Rows:", nrow(air_data), " Columns:", ncol(air_data), "\n")

  cat("\n----- Missing values present? -----\n")
  cat(any(is.na(air_data)), "\n")

  cat("\n----- Total missing values -----\n")
  cat(sum(is.na(air_data)), "\n")

} else {
  stop("Dataset could not be loaded. Please check the file path and re-run.")
}


cat("\n============ TASK 2: NA vs NULL vs NaN ============\n")

temperature <- c(28, 30, NA, 32)
cat("temperature vector:", temperature, "\n")
cat("is.na(temperature):", is.na(temperature), "\n")


missing_object <- NULL
cat("\nmissing_object is NULL:", is.null(missing_object), "\n")
cat("length of NULL object:", length(missing_object), "\n")

undefined_value <- 0 / 0
cat("\nundefined_value (0/0):", undefined_value, "\n")
cat("is.nan(undefined_value):", is.nan(undefined_value), "\n")

cat("\nis.na(NaN):", is.na(undefined_value), " (TRUE - NaN is a special case of NA)\n")
cat("is.nan(NA):", is.nan(NA), " (FALSE - a plain NA is not NaN)\n")



missing_summary <- function(df, vars = NULL) {
  if (is.null(vars)) vars <- names(df)

  result <- data.frame(
    Variable = character(),
    Total_Records = integer(),
    Missing_Values = integer(),
    Missing_Percentage = numeric(),
    stringsAsFactors = FALSE
  )

  for (v in vars) {
    if (!v %in% names(df)) {
      message("Variable '", v, "' not found in dataset - skipped.")
      next
    }
    total <- nrow(df)
    missing_count <- sum(is.na(df[[v]]))
    missing_pct <- round((missing_count / total) * 100, 2)

    if (missing_pct > 20) {
      warning(paste0("Variable '", v, "' has more than 20% missing values (",
                      missing_pct, "%)."))
    }

    result <- rbind(result, data.frame(
      Variable = v,
      Total_Records = total,
      Missing_Values = missing_count,
      Missing_Percentage = missing_pct
    ))
  }
  return(result)
}

selected_vars <- c("PM2.5", "PM10", "SO2", "NO2", "TEMP", "WSPM", "wd")

cat("\n============ TASK 3: Missing Value Summary ============\n")
summary_before <- missing_summary(air_data, selected_vars)
print(summary_before)



cat("\n============ TASK 4: pollution_ratio checks ============\n")

air_data$pollution_ratio <- air_data$PM2.5 / air_data$PM10

cat("NA count in pollution_ratio:", sum(is.na(air_data$pollution_ratio)), "\n")
cat("NaN count in pollution_ratio:",
    sum(is.nan(air_data$pollution_ratio)), "\n")
cat("Positive Infinity count:",
    sum(is.infinite(air_data$pollution_ratio) & air_data$pollution_ratio > 0,
        na.rm = TRUE), "\n")
cat("Negative Infinity count:",
    sum(is.infinite(air_data$pollution_ratio) & air_data$pollution_ratio < 0,
        na.rm = TRUE), "\n")

air_data$pollution_ratio[is.nan(air_data$pollution_ratio)] <- NA
air_data$pollution_ratio[is.infinite(air_data$pollution_ratio)] <- NA

cat("After cleaning, remaining NA in pollution_ratio:",
    sum(is.na(air_data$pollution_ratio)), "\n")


cat("\n============ TASK 5: Loop-based numeric imputation ============\n")

numeric_variables <- c("PM2.5", "PM10", "SO2", "NO2", "TEMP", "WSPM")

missing_before_list <- list()
missing_after_list  <- list()

for (var in numeric_variables) {

  if (!var %in% names(air_data)) {
    message("Column '", var, "' does not exist - skipped.")
    next
  }

  missing_before <- sum(is.na(air_data[[var]]))
  med_value <- median(air_data[[var]], na.rm = TRUE)

  air_data[[var]][is.na(air_data[[var]])] <- med_value

  missing_after <- sum(is.na(air_data[[var]]))

  missing_before_list[[var]] <- missing_before
  missing_after_list[[var]]  <- missing_after

  cat("\nVariable:", var,
      "\n  Missing before treatment:", missing_before,
      "\n  Median used for replacement:", round(med_value, 3),
      "\n  Missing after treatment:", missing_after, "\n")
}



cat("\n============ TASK 6: Categorical (wd) imputation ============\n")

calculate_mode <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0) return(NA)
  freq_table <- table(x)
  mode_value <- names(freq_table)[which.max(freq_table)]
  return(mode_value)
}

wd_missing_before <- sum(is.na(air_data$wd))
wd_mode <- calculate_mode(air_data$wd)

air_data$wd[is.na(air_data$wd)] <- wd_mode

wd_missing_after <- sum(is.na(air_data$wd))

missing_before_list[["wd"]] <- wd_missing_before
missing_after_list[["wd"]]  <- wd_missing_after

cat("Mode of wd:", wd_mode, "\n")
cat("Missing before replacement:", wd_missing_before, "\n")
cat("Missing after replacement:", wd_missing_after, "\n")


cat("\n============ TASK 7: clean_variable() with error handling ============\n")

clean_variable <- function(df, var_name) {
  tryCatch({

    if (!var_name %in% names(df)) {
      stop(paste0("Variable '", var_name, "' does not exist in the dataset."))
    }

    variable <- df[[var_name]]

    if (!is.numeric(variable)) {
      stop(paste0("Variable '", var_name,
                   "' is categorical, not numerical. Cannot impute with median."))
    }

    if (all(is.na(variable))) {
      stop(paste0("Variable '", var_name, "' contains only missing values."))
    }

    med_value <- median(variable, na.rm = TRUE)

    if (is.na(med_value)) {
      stop(paste0("Median could not be calculated for '", var_name, "'."))
    }

    variable[is.na(variable)] <- med_value
    message("Variable '", var_name, "' cleaned successfully.")
    return(variable)

  },
  error = function(e) {
    message("Handled error for '", var_name, "': ", conditionMessage(e))
    return(NULL)
  })
}

test1 <- clean_variable(air_data, "PM2.5")          # valid numeric variable
test2 <- clean_variable(air_data, "wd")             # categorical -> handled error
test3 <- clean_variable(air_data, "NoSuchColumn")   # non-existent -> handled error



cat("\n============ TASK 8: Before vs After comparison ============\n")

comparison_vars <- c(numeric_variables, "wd")

comparison_table <- data.frame(
  Variable = comparison_vars,
  Missing_Before = sapply(comparison_vars, function(v) missing_before_list[[v]]),
  Missing_After  = sapply(comparison_vars, function(v) missing_after_list[[v]]),
  stringsAsFactors = FALSE
)
comparison_table$Values_Replaced <- comparison_table$Missing_Before -
                                     comparison_table$Missing_After

print(comparison_table)

cat("\nInterpretation: If 'Missing_After' is 0 for every variable in the table,",
    "\nall selected missing values have been successfully imputed",
    "\n(numerical variables via median substitution, 'wd' via mode substitution).\n")



cat("\n============ TASK 9: Missing-value bar chart ============\n")

png("missing_values_before_after.png", width = 900, height = 600)

bar_data <- t(as.matrix(comparison_table[, c("Missing_Before", "Missing_After")]))
colnames(bar_data) <- comparison_table$Variable

barplot(
  bar_data,
  beside = TRUE,
  col = c("firebrick", "forestgreen"),
  main = "Missing Values Before vs After Cleaning",
  xlab = "Variables",
  ylab = "Number of Missing Values",
  legend.text = c("Before Cleaning", "After Cleaning"),
  args.legend = list(x = "topright", bty = "n")
)

dev.off()
cat("Bar chart saved as 'missing_values_before_after.png'\n")



cat("\n============ TASK 10: Export cleaned dataset ============\n")

write.csv(air_data, "cleaned_air_quality_data.csv", row.names = FALSE)
cat("Cleaned dataset exported as 'cleaned_air_quality_data.csv'\n")


cat("\n============ Optional: skimr validation ============\n")
print(skim(air_data[, c(numeric_variables, "wd", "pollution_ratio")]))

cat("\n===================== SCRIPT COMPLETE =====================\n")














