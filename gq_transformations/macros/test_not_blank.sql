{% test not_blank(model, column_name) %}
    SELECT * FROM {{ model }} WHERE {{ column_name }} SIMILAR TO '^\s*$'
{% endtest %}
