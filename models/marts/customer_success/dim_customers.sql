with customers as (

    select * from {{ ref('stg_saas__customers') }}

),

customer_lifetime_value as (

    select
        customer_id,
        sum(mrr_amount) as lifetime_value

    from {{ ref('int_subscription_periods') }}
    where is_active_period = true
    group by customer_id

),

final as (

    select
        customers.customer_id,
        customers.company_name,
        customers.signup_date,
        customers.region,
        customers.industry,
        customers.initial_plan_tier,
        customers.current_plan_tier,
        customers.customer_status,
        customers.churn_date,
        coalesce(customer_lifetime_value.lifetime_value, 0) as lifetime_value

    from customers

    left join customer_lifetime_value
        on customers.customer_id = customer_lifetime_value.customer_id

)

select * from final