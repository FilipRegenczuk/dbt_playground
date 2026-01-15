{#
  Converts a column value from cents to dollars.
  
  This macro divides the input by 100 and rounds to the specified decimal places.
  Useful for formatting monetary values stored as integers (cents).
  
  Args:
      column_name (string): The column name or expression to convert
      decimals (integer): Number of decimal places to round to (default: 2)
  
  Returns:
      A numeric expression representing the value in dollars
  
  Example:
      SELECT {{ cents_to_dollars('amount') }} as amount_dollars FROM orders
      SELECT {{ cents_to_dollars('total_cents', 4) }} as precise_dollars FROM transactions
#}

{% macro cents_to_dollars(column_name, decimals=2) %}
    round({{ column_name }} * 1.0 / 100, {{ decimals }})
{% endmacro %}