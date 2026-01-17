{#
  Drops stale tables/views that haven't been modified in a specified number of days.
  
  This macro queries information_schema to find tables/views older than the threshold
  and drops them. Useful for cleaning up old test tables, scratch models, or unused objects.
  
  Args:
      older_than_days (integer): Drop tables not modified in this many days (default: 30)
                                 Set to 0 to drop all tables modified today or earlier
      database (string): Database to search for stale models (default: target.database)
      schema (string): Schema to search for stale models (default: target.schema)
  
  Returns:
      Logs showing:
      - Number of stale models found
      - Each DROP statement being executed
      - Total count of dropped models
  
  Safety:
      - Uses DROP IF EXISTS to avoid errors if tables don't exist
      - Only affects the specified schema
      - Logs all actions for audit trail
  
  Usage:
      uv run dbt run-operation clean_stale_models --args '{older_than_days: 5}'
      uv run dbt run-operation clean_stale_models --args '{older_than_days: 30, schema: "dev_scratch"}'
  
  Example Output:
      Cleaning models older than 5 days
      Generating drop statements...
      Dropping 3 models...
      Executing: DROP TABLE IF EXISTS analytics.local.old_test;
      Executing: DROP VIEW IF EXISTS analytics.local.temp_view;
      Executing: DROP TABLE IF EXISTS analytics.local.scratch_2024;
      Models dropped successfully!
#}

{% macro clean_stale_models(older_than_days=30, database=target.database, schema=target.schema) %}
    {# Calculate the drop date. If older_than_days is 0, we want to drop today records. #}
    {% if older_than_days == 0 %}
        {% set drop_date = (modules.datetime.date.today() + modules.datetime.timedelta(days=1)).strftime('%Y-%m-%d') %}
    {% else %}
        {% set drop_date = (modules.datetime.date.today() - modules.datetime.timedelta(days=older_than_days)).strftime('%Y-%m-%d') %}
    {% endif %}

    {% set sql %}
        use database {{ database }};
        select
            case when table_type = 'VIEW' then 'VIEW' else 'TABLE' end as object_type,
            'DROP ' || object_type || ' IF EXISTS ' || table_schema || '.' || table_name || ';' as drop_statement
        from {{ database }}.information_schema.tables
        where table_schema = upper('{{ schema }}')
            and last_altered < '{{ drop_date }}'::timestamp
    {% endset %}

    {{ log('Cleaning models older than ' ~ older_than_days ~ ' days (before ' ~ drop_date ~ ')', info=True) }}
    {{ log('\nGenerating drop statements...\n', info=True) }}
    {% set drop_statements = run_query(sql).columns[1].values() %}

    {# Check if anything to drop #}
    {% set num_models_to_drop = drop_statements | length %}
    {% if num_models_to_drop == 0 %}
        {{ log('No stale models found older than ' ~ older_than_days ~ ' days. Aborting...\n', info=True) }}
    {% else %}
        {{ log('\nDropping ' ~ num_models_to_drop ~ ' model(s)...\n', info=True) }}
        {% for statement in drop_statements %}
            {{ log('Executing: ' ~ statement, info=True) }}
            {% do run_query(statement) %}
        {% endfor %}

        {{ log('\nSuccessfully dropped ' ~ num_models_to_drop ~ ' model(s)!\n', info=True) }}
    {% endif %}
    {{ log('Operation complete.\n', info=True) }}

{% endmacro %}
