# SaaS Analytics Engineering Project

A dbt project built on BigQuery that models synthetic SaaS subscription data into a
staging, intermediate, and marts architecture. The project calculates Monthly
Recurring Revenue (MRR), customer churn, and customer lifetime value, and includes
automated testing, documentation, and a scheduled production deployment.

This project was built to demonstrate Analytics Engineering skills covered in the
dbt Fundamentals course, applied to an original dataset rather than the standard
course exercise.

## Project Architecture

Raw data (customers, subscriptions, billing events) is loaded into BigQuery, then
transformed through three layers:

- **Staging**: light cleaning and renaming of raw source columns, one model per
  source table (`stg_saas__customers`, `stg_saas__subscriptions`,
  `stg_saas__billing_events`).
- **Intermediate**: `int_subscription_periods` derives the exact time period each
  customer spent on a given plan, using a window function over the subscription
  event log.
- **Marts**: `fct_mrr` calculates Monthly Recurring Revenue broken down into new,
  expansion, contraction, and churned revenue for each calendar month. `dim_customers`
  provides one row per customer with plan history and total lifetime value.

## Key Design Decision: Window Functions Over SCD Type 2

Subscription history in this project is derived using window functions in the
intermediate layer, rather than SCD Type 2 snapshots. This keeps the transformation
logic within the standard staging-to-marts modeling pattern, since SCD Type 2
snapshots require dbt's snapshot feature, which is outside this project's scope.
This is a deliberate, documented trade-off rather than an oversight.

## Data Source

The dataset is synthetic, generated with Python (Faker + custom churn modeling) to
simulate 420 SaaS customers across 24 months, with realistic churn patterns
(elevated early churn, a honeymoon period, and gradual contract fatigue), plan
upgrades/downgrades, and a small percentage of failed or refunded payments.

## Testing

- Generic tests: uniqueness and not-null checks on primary keys, accepted values on
  customer status, and a range check confirming Monthly Recurring Revenue is never
  negative.
- A singular test confirms no month in `fct_mrr` shows a negative total.

## Documentation

Model and column descriptions are written in YAML, with a shared doc block explaining
Monthly Recurring Revenue, referenced across multiple models rather than duplicated.

## Deployment

A scheduled production job runs `dbt build` (including source freshness checks)
every 12 hours against a dedicated production schema, separate from the development
schema used during local model building.

## Tools Used

- dbt (Fusion engine)
- BigQuery
- Python (synthetic data generation)
- Git / GitHub (feature-branch workflow with pull requests)

## Skills Demonstrated

Source configuration and freshness monitoring, staging/intermediate/marts modeling
patterns, the `ref()` and `source()` macros, window functions, generic and singular
data testing, documentation as code, materialization strategy configuration, and
scheduled production deployment.
