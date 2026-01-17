{% macro clean_stale_models(older_than_days=30, database=target.database, schema=target.schema) %}
    {# Calculate the drop date. If older_than_days is 0, we want to drop today records. #}
    {% if older_than_days == 0 %}
        {% set drop_date = (modules.datetime.date.today() + modules.datetime.timedelta(days=1)).strftime('%Y-%m-%d') %}
    {% else %}
        {% set drop_date = (modules.datetime.date.today() - modules.datetime.timedelta(days=older_than_days)).strftime('%Y-%m-%d') %}
    {% endif %}

    {% set sql %}
        use database {{ database }};
        {{ log('Cleaning models older than ' ~ older_than_days ~ ' days', info=True) }}
        select
            case when table_type = 'VIEW' then 'VIEW' else 'TABLE' end as object_type,
            'DROP ' || object_type || ' IF EXISTS ' || table_schema || '.' || table_name || ';' as drop_statement
        from {{ database }}.information_schema.tables
        where table_schema = upper('{{ schema }}')
            and last_altered < '{{ drop_date }}'::timestamp
    {% endset %}

    {{ log('\nGenerating drop statements...\n', info=True) }}
    {% set drop_statements = run_query(sql).columns[1].values() %}

    {# Check if anything to drop #}
    {% set num_models_to_drop = drop_statements | length %}
    {% if num_models_to_drop == 0 %}
        {{ log('No stale models found older than ' ~ older_than_days ~ ' days. Aborting...\n', info=True) }}
    {% else %}
        {{ log('\nDropping ' ~ num_models_to_drop ~ ' models...\n', info=True) }}
        {% for statement in drop_statements %}
            {{ log('Executing: ' ~ statement, info=True) }}
            {% do run_query(statement) %}
        {% endfor %}

        {{ log('\nModels dropped successfully!\n', info=True) }}
    {% endif %}
    {{ log('Operation complete.\n', info=True) }}

{% endmacro %}
