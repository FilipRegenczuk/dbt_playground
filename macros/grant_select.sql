{#
  Grants SELECT privileges and USAGE on a schema to a specific role.
  
  This macro provides read-only access to all tables in a schema.
  Useful for setting up analyst or reporting roles.
  
  Args:
      schema (string): The schema to grant privileges on (default: target.schema)
      role (string): The role to grant privileges to (default: target.role)
      database (string): The database containing the schema (default: target.database)
  
  Usage:
      Run from terminal:
      uv run dbt run-operation grant_select --args '{schema: "analytics", role: "analyst_role"}'
  
  Example:
      {{ grant_select('analytics', 'analyst_role', 'production') }}
#}

{% macro grant_select(schema=target.schema, role=target.role, database=target.database) %}

    {% set sql %}
        use database {{ database }};
        grant usage on schema {{ schema }} to role {{ role }};
        grant select on all tables in schema {{ schema }} to role {{ role }};
    {% endset %}

    {{ log('Granting SELECT and USAGE to ' ~ role ~ ' on ' ~ schema ~ ' in ' ~ database, info=True) }}
    {% do run_query(sql) %}
    {{ log('SELECT privileges granted successfully', info=True) }}

{% endmacro %}