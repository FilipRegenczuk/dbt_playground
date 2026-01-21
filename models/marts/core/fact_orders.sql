{{ 
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='order_id'
    )
}}

with orders as  (
    select * from {{ ref ('stg_jaffle_shop__orders' )}}
),

payments as (
    select * from {{ ref ('stg_stripe__payments') }}
),


final as (
    select
        orders.order_id,
        orders.customer_id,
        payments.amount,
        payments.payment_status,
        orders.order_date,
    from orders
    left join payments using (order_id)
)

select * from final
{% if is_incremental() %}
    where order_date > (select max(order_date) from {{ this }})
{% endif %}
order by order_date desc
