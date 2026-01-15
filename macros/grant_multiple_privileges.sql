{#
  Grants multiple specified privileges to a specific role for all tables in a schema.
  
  This macro allows batch granting of permissions for role-based access control.
  Useful for setting up roles with specific combinations of privileges.
  
  Args:
      privileges (list): List of privileges to grant (e.g., ['SELECT', 'INSERT', 'UPDATE'])
                        Common values: SELECT, INSERT, UPDATE, DELETE, TRUNCATE
      schema (string): The schema to grant privileges on (default: target.schema)
      role (string): The role to grant privileges to (default: target.role)
      database (string): The database containing the schema (default: target.database)
  
  Usage:
      Run from terminal:
      uv run dbt run-operation grant_multiple_privileges --args '{
        privileges: ["SELECT", "INSERT"],
        schema: "analytics",
        role: "data_engineer"
      }'
  
  Example:
      {{ grant_multiple_privileges(['SELECT', 'UPDATE'], 'analytics', 'analyst_role') }}
#}

{% macro grant_multiple_privileges(privileges, schema=target.schema, role=target.role, database=target.database) %}

    {% set sql %}
        use database {{ database }};
        {% for privilege in privileges %}
            grant {{ privilege }} on all tables in schema {{ schema }} to role {{ role }};
        {% endfor %}
    {% endset %}

    {{ log('Granting ' ~ privileges | join(', ') ~ ' to ' ~ role ~ ' on ' ~ schema ~ ' in ' ~ database, info=True) }}
    {% do run_query(sql) %}
    {{ log('Privileges granted successfully', info=True) }}

{% endmacro %}