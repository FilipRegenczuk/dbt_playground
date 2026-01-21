with 

source as (

    select * from {{ source('jaffle_shop', 'orders') }}

),

renamed as (

    select
        id as order_id,
        user_id as customer_id,
        order_date,
        row_number() over (partition by user_id order by order_date) as order_number,
        status as order_status

    from source

)

select * from renamed