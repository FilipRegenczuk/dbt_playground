{% macro dummy_macro() %}
    {% set my_cool_var = "Hello, World!" %}

    {% set colors = ['red', 'green', 'blue'] %}

    {% for color in colors %}
        {{ color }}
    {% endfor %}
{% endmacro %}