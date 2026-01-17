{% macro template_example() %}

    {% set sql %}
        select true as boolean
    {% endset %}

    {% if execute %}
        {% set result = run_query(sql).columns[0].values()[0] %}
    {% else %}
        {% set result = false %}
    {% endif %}

    {{ log("Result: " ~ result, info=True) }}

    select {{ result }} as is_real

{% endmacro %}