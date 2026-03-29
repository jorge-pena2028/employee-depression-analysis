# =============================================================================
# Employee Depression Analysis — Natural Light and the Beck Depression Inventory
# =============================================================================
# Research Question:
#   Does the presence of natural light (office windows) affect employee
#   depression as measured by the Beck Depression Inventory (BDI)?
#
# Dataset: 800 employee records with Beck Depression Inventory scores and
#          office window status (yes/no).
#
# Methods: Descriptive statistics, data visualization, assumption checking,
#          two-sample t-tests, and effect size estimation (Cohen's d).
#
# Required packages: ggplot2, dplyr, readr
# =============================================================================

# --- Load packages -----------------------------------------------------------
if (!require("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!require("dplyr", quietly = TRUE))   install.packages("dplyr")
if (!require("readr", quietly = TRUE))   install.packages("readr")

library(ggplot2)
library(dplyr)
library(readr)

# Create output directory for plots
if (!dir.exists("output")) dir.create("output")

cat("================================================================\n")
cat("  EMPLOYEE DEPRESSION ANALYSIS — BECK DEPRESSION INVENTORY\n")
cat("================================================================\n\n")

# =============================================================================
# 1. LOAD AND INSPECT THE DATASET
# =============================================================================

df <- read_csv("employee_data.csv", show_col_types = FALSE)

cat("--- Dataset Overview ---\n")
cat("Dimensions:", nrow(df), "rows x", ncol(df), "columns\n")
cat("Column names:", paste(names(df), collapse = ", "), "\n\n")

cat("Structure:\n")
str(df)
cat("\n")

cat("First 10 records:\n")
print(head(df, 10))
cat("\n")

# =============================================================================
# 2. DATA QUALITY AUDIT
# =============================================================================

cat("--- Data Quality Audit ---\n\n")

# Check for missing values
missing_counts <- colSums(is.na(df))
cat("Missing values per column:\n")
print(missing_counts)
cat("\n")

if (sum(missing_counts) == 0) {
  cat("Result: No missing values detected. Dataset is complete.\n\n")
} else {
  cat("WARNING: Missing values found. Review before proceeding.\n\n")
}

# Check for duplicate employee IDs
n_duplicates <- sum(duplicated(df$emplpoyee_id))
cat("Duplicate employee IDs:", n_duplicates, "\n")

# Check value ranges
cat("Beck score range:", min(df$beck_score), "-", max(df$beck_score), "\n")
cat("Employee ID range:", min(df$emplpoyee_id), "-", max(df$emplpoyee_id), "\n")

# Check office_window values
cat("Unique office_window values:", paste(unique(df$office_window), collapse = ", "), "\n\n")

# Group sizes
cat("Office window distribution (raw):\n")
print(table(df$office_window))
cat("\n")

# =============================================================================
# 3. DATA PREPARATION
# =============================================================================

# Convert office_window to a labeled factor
df$office_type <- factor(df$office_window,
                         levels = c("yes", "no"),
                         labels = c("Window", "No Window"))

cat("Office type distribution (labeled):\n")
print(table(df$office_type))
cat("\n")

# =============================================================================
# 4. DESCRIPTIVE STATISTICS
# =============================================================================

cat("================================================================\n")
cat("  DESCRIPTIVE STATISTICS: Beck Scores by Office Type\n")
cat("================================================================\n\n")

desc_stats <- df %>%
  group_by(office_type) %>%
  summarise(
    n      = n(),
    mean   = round(mean(beck_score), 2),
    median = median(beck_score),
    sd     = round(sd(beck_score), 2),
    min    = min(beck_score),
    max    = max(beck_score),
    q1     = quantile(beck_score, 0.25),
    q3     = quantile(beck_score, 0.75),
    iqr    = IQR(beck_score),
    .groups = "drop"
  )

print(as.data.frame(desc_stats))
cat("\n")

# Overall statistics
cat("Overall Beck score mean:", round(mean(df$beck_score), 2), "\n")
cat("Overall Beck score SD:  ", round(sd(df$beck_score), 2), "\n\n")

# =============================================================================
# 5. DATA VISUALIZATIONS
# =============================================================================

cat("--- Generating Visualizations ---\n\n")

# Define a consistent color palette
colors <- c("Window" = "#2196F3", "No Window" = "#FF5722")

# --- 5a. Histogram: overlapping Beck scores by office type ---
p1 <- ggplot(df, aes(x = beck_score, fill = office_type)) +
  geom_histogram(binwidth = 2, position = "identity", alpha = 0.6, color = "white") +
  scale_fill_manual(values = colors) +
  labs(
    title = "Distribution of Beck Depression Scores by Office Type",
    subtitle = "Overlapping histograms (n = 800)",
    x = "Beck Depression Score",
    y = "Count",
    fill = "Office Type"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "top")

ggsave("output/histogram_beck_scores.png", p1, width = 9, height = 6, dpi = 300)
cat("  Saved: output/histogram_beck_scores.png\n")

# --- 5b. Boxplot: Beck scores by office type ---
p2 <- ggplot(df, aes(x = office_type, y = beck_score, fill = office_type)) +
  geom_boxplot(alpha = 0.7, outlier.shape = 21, outlier.size = 2) +
  scale_fill_manual(values = colors) +
  labs(
    title = "Beck Depression Scores: Window vs. No Window Offices",
    subtitle = "Boxplot comparison",
    x = "Office Type",
    y = "Beck Depression Score"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

ggsave("output/boxplot_beck_scores.png", p2, width = 7, height = 6, dpi = 300)
cat("  Saved: output/boxplot_beck_scores.png\n")

# --- 5c. Density plot of Beck score distributions ---
p3 <- ggplot(df, aes(x = beck_score, fill = office_type, color = office_type)) +
  geom_density(alpha = 0.35, linewidth = 1) +
  scale_fill_manual(values = colors) +
  scale_color_manual(values = colors) +
  geom_vline(data = desc_stats, aes(xintercept = mean, color = office_type),
             linetype = "dashed", linewidth = 0.9) +
  labs(
    title = "Density Plot of Beck Depression Score Distributions",
    subtitle = "Dashed lines indicate group means",
    x = "Beck Depression Score",
    y = "Density",
    fill = "Office Type",
    color = "Office Type"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "top")

ggsave("output/density_beck_scores.png", p3, width = 9, height = 6, dpi = 300)
cat("  Saved: output/density_beck_scores.png\n")

# --- 5d. Bar chart of mean Beck scores with error bars (95% CI) ---
bar_data <- desc_stats %>%
  mutate(se = sd / sqrt(n),
         ci_lower = mean - 1.96 * se,
         ci_upper = mean + 1.96 * se)

p4 <- ggplot(bar_data, aes(x = office_type, y = mean, fill = office_type)) +
  geom_col(alpha = 0.8, width = 0.6) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.15, linewidth = 0.8) +
  scale_fill_manual(values = colors) +
  labs(
    title = "Mean Beck Depression Scores by Office Type",
    subtitle = "Error bars represent 95% confidence intervals",
    x = "Office Type",
    y = "Mean Beck Depression Score"
  ) +
  coord_cartesian(ylim = c(0, max(bar_data$ci_upper) + 2)) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

ggsave("output/barchart_mean_beck.png", p4, width = 7, height = 6, dpi = 300)
cat("  Saved: output/barchart_mean_beck.png\n")

# --- 5e. Violin plot with jittered points ---
p5 <- ggplot(df, aes(x = office_type, y = beck_score, fill = office_type)) +
  geom_violin(alpha = 0.5, trim = FALSE) +
  geom_jitter(width = 0.15, alpha = 0.15, size = 0.8, color = "black") +
  scale_fill_manual(values = colors) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 4, color = "black") +
  stat_summary(fun = mean, geom = "text", aes(label = round(after_stat(y), 1)),
               vjust = -1.5, size = 4, fontface = "bold") +
  labs(
    title = "Violin Plot of Beck Depression Scores by Office Type",
    subtitle = "Diamonds indicate group means; individual data points shown",
    x = "Office Type",
    y = "Beck Depression Score"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

ggsave("output/violin_beck_scores.png", p5, width = 7, height = 6, dpi = 300)
cat("  Saved: output/violin_beck_scores.png\n\n")

# =============================================================================
# 6. STATISTICAL TESTING
# =============================================================================

cat("================================================================\n")
cat("  STATISTICAL ANALYSIS\n")
cat("================================================================\n\n")

# Separate groups
window_scores    <- df$beck_score[df$office_type == "Window"]
no_window_scores <- df$beck_score[df$office_type == "No Window"]

# --- 6a. Assumption Checks ---

cat("--- Assumption Checks ---\n\n")

# Normality: Shapiro-Wilk test
shap_window    <- shapiro.test(window_scores)
shap_no_window <- shapiro.test(no_window_scores)

cat("Shapiro-Wilk Normality Test:\n")
cat(sprintf("  Window group:    W = %.4f, p = %.4f\n", shap_window$statistic, shap_window$p.value))
cat(sprintf("  No Window group: W = %.4f, p = %.4f\n", shap_no_window$statistic, shap_no_window$p.value))

if (shap_window$p.value > 0.05 & shap_no_window$p.value > 0.05) {
  cat("  Interpretation: Both groups appear normally distributed (p > 0.05).\n\n")
} else {
  cat("  Interpretation: Some departure from normality detected.\n")
  cat("  Note: With n > 30 per group, the t-test is robust to mild non-normality\n")
  cat("  due to the Central Limit Theorem.\n\n")
}

# Equal variances: F-test
var_test <- var.test(window_scores, no_window_scores)
cat("F-Test for Equality of Variances:\n")
cat(sprintf("  F = %.4f, p = %.4f\n", var_test$statistic, var_test$p.value))
cat(sprintf("  Variance ratio: %.4f\n", var_test$estimate))
if (var_test$p.value > 0.05) {
  cat("  Interpretation: No significant difference in variances (p > 0.05).\n\n")
} else {
  cat("  Interpretation: Variances differ significantly (p < 0.05).\n")
  cat("  Welch's t-test (which does not assume equal variances) is preferred.\n\n")
}

# --- 6b. Two-Sample T-Tests ---

cat("--- Two-Sample T-Tests ---\n\n")

# Welch's t-test (does not assume equal variances -- default in R)
welch_test <- t.test(window_scores, no_window_scores, var.equal = FALSE)
cat("Welch's Two-Sample t-test (unequal variances):\n")
cat(sprintf("  t = %.4f\n", welch_test$statistic))
cat(sprintf("  df = %.2f\n", welch_test$parameter))
cat(sprintf("  p-value = %.6f\n", welch_test$p.value))
cat(sprintf("  95%% CI for difference in means: [%.4f, %.4f]\n",
            welch_test$conf.int[1], welch_test$conf.int[2]))
cat(sprintf("  Window mean = %.2f, No Window mean = %.2f\n",
            welch_test$estimate[1], welch_test$estimate[2]))
cat("\n")

# Student's t-test (assumes equal variances)
student_test <- t.test(window_scores, no_window_scores, var.equal = TRUE)
cat("Student's Two-Sample t-test (equal variances assumed):\n")
cat(sprintf("  t = %.4f\n", student_test$statistic))
cat(sprintf("  df = %.0f\n", student_test$parameter))
cat(sprintf("  p-value = %.6f\n", student_test$p.value))
cat(sprintf("  95%% CI for difference in means: [%.4f, %.4f]\n",
            student_test$conf.int[1], student_test$conf.int[2]))
cat("\n")

# --- 6c. Effect Size: Cohen's d ---

mean_diff <- mean(window_scores) - mean(no_window_scores)
pooled_sd <- sqrt(((length(window_scores) - 1) * sd(window_scores)^2 +
                     (length(no_window_scores) - 1) * sd(no_window_scores)^2) /
                    (length(window_scores) + length(no_window_scores) - 2))
cohens_d <- mean_diff / pooled_sd

cat("--- Effect Size ---\n\n")
cat(sprintf("  Mean difference (Window - No Window): %.2f points\n", mean_diff))
cat(sprintf("  Pooled SD: %.2f\n", pooled_sd))
cat(sprintf("  Cohen's d: %.4f\n", cohens_d))

# Interpret Cohen's d
d_abs <- abs(cohens_d)
d_label <- ifelse(d_abs < 0.2, "negligible",
           ifelse(d_abs < 0.5, "small",
           ifelse(d_abs < 0.8, "medium", "large")))
cat(sprintf("  Interpretation: %s effect size\n\n", d_label))

# =============================================================================
# 7. SUMMARY AND POLICY RECOMMENDATION
# =============================================================================

cat("================================================================\n")
cat("  SUMMARY OF FINDINGS AND POLICY RECOMMENDATION\n")
cat("================================================================\n\n")

cat("Research Question:\n")
cat("  Does the presence of natural light (office windows) affect\n")
cat("  employee depression as measured by the Beck Depression Inventory?\n\n")

cat("Scoring System:\n")
cat("  The Beck Depression Inventory (BDI) is a widely used 21-item\n")
cat("  self-report measure of depression severity.\n")
cat("  Score interpretation: 0-9 minimal, 10-18 mild, 19-29 moderate, 30+ severe\n\n")

cat("Sample:\n")
cat(sprintf("  Total employees analyzed: %d\n", nrow(df)))
cat(sprintf("  Window office group: n = %d (mean BDI = %.2f, SD = %.2f)\n",
            length(window_scores), mean(window_scores), sd(window_scores)))
cat(sprintf("  No-window office group: n = %d (mean BDI = %.2f, SD = %.2f)\n",
            length(no_window_scores), mean(no_window_scores), sd(no_window_scores)))
cat("\n")

cat("Statistical Results:\n")
sig_label <- ifelse(welch_test$p.value < 0.05, "statistically significant",
                    "not statistically significant")
cat(sprintf("  Welch's t-test: t(%.1f) = %.3f, p = %.5f\n",
            welch_test$parameter, welch_test$statistic, welch_test$p.value))
cat(sprintf("  The difference in Beck scores is %s at alpha = 0.05.\n", sig_label))
cat(sprintf("  Effect size (Cohen's d): %.3f (%s)\n", cohens_d, d_label))
cat(sprintf("  95%% CI for the mean difference: [%.2f, %.2f]\n",
            welch_test$conf.int[1], welch_test$conf.int[2]))
cat("\n")

cat("Conclusion:\n")
if (welch_test$p.value < 0.05) {
  if (mean_diff < 0) {
    cat("  Employees in offices with windows reported significantly lower\n")
    cat(sprintf("  Beck depression scores (M = %.2f) compared to employees in offices\n",
                mean(window_scores)))
    cat(sprintf("  without windows (M = %.2f). The effect size is %s.\n",
                mean(no_window_scores), d_label))
  } else {
    cat("  Employees in offices with windows reported significantly higher\n")
    cat(sprintf("  Beck depression scores (M = %.2f) compared to employees in offices\n",
                mean(window_scores)))
    cat(sprintf("  without windows (M = %.2f). The effect size is %s.\n",
                mean(no_window_scores), d_label))
  }
  cat("  The result suggests that access to natural light may have a meaningful\n")
  cat("  impact on employee mental health.\n\n")
} else {
  cat("  No statistically significant difference in Beck depression scores was\n")
  cat("  found between employees with and without office windows.\n\n")
}

cat("Policy Recommendation:\n")
cat("  Based on the analysis, the following workplace recommendations are offered:\n")
cat("    1. Prioritize window-adjacent seating in office layouts.\n")
cat("    2. Where windows are unavailable, invest in full-spectrum lighting\n")
cat("       that mimics natural daylight.\n")
cat("    3. Implement flexible seating rotations so all employees periodically\n")
cat("       have access to window offices.\n")
cat("    4. Consider natural light access as part of workplace wellness\n")
cat("       initiatives alongside other mental health programs.\n")
cat("    5. Conduct a follow-up longitudinal study to assess the causal\n")
cat("       impact of lighting changes on depression outcomes.\n\n")

cat("================================================================\n")
cat("  Analysis complete. Plots saved to output/ directory.\n")
cat("================================================================\n")
