{#
  Unions multiple tables with the same prefix into a single result set.
  
  This macro dynamically finds all tables in a schema that start with a given prefix
  and unions them together using UNION ALL. Useful for combining similarly structured
  tables (e.g., sharded tables, date-partitioned tables, or tables from different sources).
  
  Args:
      prefix (string): The prefix to search for (e.g., 'stg_', 'raw_', 'orders_')
                      Required parameter - must be provided
      database (string): The database to search in (default: target.database)
      schema (string): The schema to search in (default: target.schema)
  
  Returns:
      A UNION ALL query combining all matching tables
  
  Requirements:
      - dbt_utils package must be installed (uses dbt_utils.get_relations_by_prefix)
      - All tables with the prefix must have compatible schemas (same columns)
  
  Usage:
      In a model file:
      {{ union_tables_by_prefix('stg_jaffle_') }}
  
  Example:
      -- Union all staging tables starting with 'raw_orders_'
      {{ union_tables_by_prefix('raw_orders_', database='raw', schema='jaffle_shop') }}
#}

{% macro union_tables_by_prefix(prefix, database=target.database, schema=target.schema) %}

    {% set tables = dbt_utils.get_relations_by_prefix(database=database, schema=schema, prefix=prefix) %}

    {% for table in tables %}
        {%- if not loop.first -%}
            union all
        {% endif %}
        select * from {{ table.database }}.{{ table.schema }}.{{ table.name }}
    {% endfor %}

{% endmacro %}