{% test is_positive_integer(model, column_name) %}
    SELECT * FROM {{ model }} WHERE {{ column_name }} < 1
{% endtest %}
