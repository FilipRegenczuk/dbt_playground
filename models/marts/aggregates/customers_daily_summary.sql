with daily_orders as (
    select
        customer_id,
        date_trunc('day', order_date) as order_date,
        count(*) as num_orders,
        sum(amount) as total_amount
    from {{ ref('fact_orders') }}
    group by 1, 2
),

customers as (
    select * from {{ ref('dim_customers') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['customers.customer_id', 'daily_orders.order_date']) }} as summary_id,
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        daily_orders.order_date,
        daily_orders.num_orders,
        daily_orders.total_amount
    from customers
    left join daily_orders using (customer_id)
)

select * from final