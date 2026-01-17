{#
  Grants multiple specified privileges to a specific role on a schema.
  
  This macro grants schema-level permissions (not table-level).
  Useful for granting permissions like USAGE, CREATE TABLE, CREATE VIEW, MODIFY on schemas.
  Required for roles that need to create or manage objects within a schema.
  
  Args:
      privileges (list): List of schema-level privileges to grant
                        Common values:
                        - USAGE: Basic schema access
                        - CREATE TABLE: Ability to create tables
                        - CREATE VIEW: Ability to create views
                        - MODIFY: Ability to modify schema objects
                        - CREATE STAGE: Ability to create stages
                        - CREATE FILE FORMAT: Ability to create file formats
      schema (string): The schema to grant privileges on (default: target.schema)
      role (string): The role to grant privileges to (default: target.role)
      database (string): The database containing the schema (default: target.database)
  
  Usage:
      Run from terminal:
      uv run dbt run-operation grant_schema_privileges --args '{
        privileges: ["USAGE", "CREATE TABLE"],
        schema: "analytics",
        role: "transformer"
      }'
  
  Example:
      {{ grant_schema_privileges(['USAGE', 'CREATE TABLE', 'CREATE VIEW'], 'analytics', 'data_engineer') }}
#}

{% macro grant_schema_privileges(privileges, schema=target.schema, role=target.role, database=target.database) %}

    {% set sql %}
        use database {{ database }};
        {% for privilege in privileges %}
            grant {{ privilege }} on schema {{ schema }} to role {{ role }};
        {% endfor %}
    {% endset %}

    {{ log('Granting schema privileges ' ~ privileges | join(', ') ~ ' to ' ~ role ~ ' on schema ' ~ database ~ '.' ~ schema, info=True) }}
    {% do run_query(sql) %}
    {{ log('Schema privileges granted successfully', info=True) }}

{% endmacro %}
