# Library with macro's to make the code more readable

# Serializes dicts into sequenced data
{%- macro serialize(data) -%}
    {%- if data is mapping -%}
        {%- set ret = [] -%}
        {%- for key, value in data.items() -%}
            {%- set value = serialize(value)|load_json() -%}
            {%- do ret.append({key: value}) -%}
        {%- endfor -%}
    {%- elif data is iterable and data is not string -%}
        {%- set ret = [] -%}
        {%- for value in data -%}
            {%- set value = serialize(value)|load_json() -%}
            {%- do ret.append(value) -%}
        {%- endfor -%}
    {%- else -%}
        {% set ret = data %}
    {%- endif -%}

    {{ ret|json() }}
{%- endmacro -%}
