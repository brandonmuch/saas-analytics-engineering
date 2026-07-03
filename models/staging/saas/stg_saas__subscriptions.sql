with source as (

    select * from {{ source('saas', 'subscriptions') }}

),

renamed as (

    select
        subscription_id,
        customer_id,
        event_date,
        event_type,
        plan_tier,
        mrr_amount

    from source

)

select * from renamed