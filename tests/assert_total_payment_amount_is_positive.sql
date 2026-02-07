select
    order_id,
    sum(amount) as total_amount
from {{ ref('fact_orders') }}
group by 1
having total_amount <= 0 or total_amount is null