with subscription_events as (

    select * from {{ ref('stg_saas__subscriptions') }}

),

with_period_end as (

    select
        subscription_id,
        customer_id,
        event_date as period_start_date,
        event_type,
        plan_tier,
        mrr_amount,

        lead(event_date) over (
            partition by customer_id
            order by event_date
        ) as period_end_date

    from subscription_events

)

select
    subscription_id,
    customer_id,
    period_start_date,
    coalesce(period_end_date, current_date()) as period_end_date,
    event_type,
    plan_tier,
    mrr_amount,

    case
        when event_type = 'cancellation' then false
        else true
    end as is_active_period

from with_period_end