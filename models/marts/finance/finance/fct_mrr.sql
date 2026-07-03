with month_spine as (

    {{ dbt_utils.date_spine(
        datepart="month",
        start_date="cast('2024-06-01' as date)",
        end_date="cast('2026-07-01' as date)"
    ) }}

),

months as (

    select
        cast(date_month as date) as reporting_month

    from month_spine

),

customer_mrr_by_month as (

    select
        months.reporting_month,
        periods.customer_id,
        periods.mrr_amount

    from months

    left join {{ ref('int_subscription_periods') }} as periods
        on months.reporting_month >= periods.period_start_date
        and months.reporting_month < periods.period_end_date
        and periods.is_active_period = true

),

with_previous_month as (

    select
        reporting_month,
        customer_id,
        coalesce(mrr_amount, 0) as current_mrr,

        lag(coalesce(mrr_amount, 0)) over (
            partition by customer_id
            order by reporting_month
        ) as previous_mrr

    from customer_mrr_by_month
    where customer_id is not null

),

classified as (

    select
        reporting_month,
        customer_id,
        current_mrr,
        previous_mrr,

        case
            when previous_mrr = 0 and current_mrr > 0 then current_mrr
            else 0
        end as new_mrr,

        case
            when previous_mrr > 0 and current_mrr > previous_mrr
            then current_mrr - previous_mrr
            else 0
        end as expansion_mrr,

        case
            when previous_mrr > 0 and current_mrr > 0 and current_mrr < previous_mrr
            then current_mrr - previous_mrr
            else 0
        end as contraction_mrr,

        case
            when previous_mrr > 0 and current_mrr = 0 then -previous_mrr
            else 0
        end as churned_mrr

    from with_previous_month

)

select
    reporting_month,
    sum(current_mrr) as total_mrr,
    sum(new_mrr) as new_mrr,
    sum(expansion_mrr) as expansion_mrr,
    sum(contraction_mrr) as contraction_mrr,
    sum(churned_mrr) as churned_mrr,
    count(distinct case when current_mrr > 0 then customer_id end) as active_customers

from classified

group by reporting_month

order by reporting_month