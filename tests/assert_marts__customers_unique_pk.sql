select customer_id
from {{ ref('dim_customers') }}
group by 1
having count(*) > 1