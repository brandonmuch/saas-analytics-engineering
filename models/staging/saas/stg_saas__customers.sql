with source as (

    select * from {{ source('saas', 'customers') }}

),

renamed as (

    select
        customer_id,
        company_name,
        signup_date,
        region,
        industry,
        initial_plan_tier,
        current_plan_tier,
        status as customer_status,
        churn_date

    from source

)

select * from renamed