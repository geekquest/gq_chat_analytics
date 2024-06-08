{% test in_range(model, column_name, min, max) %}
    SELECT * FROM {{ model }} WHERE {{ column_name }} < {{ min }} OR {{ column_name }} > {{ max }}
{% endtest %}
