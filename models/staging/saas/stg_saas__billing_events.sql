with source as (

    select * from {{ source('saas', 'billing_events') }}

),

renamed as (

    select
        billing_event_id,
        customer_id,
        subscription_id,
        billing_date,
        plan_tier,
        amount_billed,
        amount_charged,
        payment_status

    from source

)

select * from renamed