{# test to make sure every row in the customers model is unique #}

select
    customer_id,
    count(*) as duplicates_number
from {{ ref('dim_customers') }}
group by 1
having duplicates_number > 1