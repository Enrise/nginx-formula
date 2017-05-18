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

{%- macro configurable(options, key, default_value) -%}
{%- if options is not mapping -%}
{#- The option parameter is not a mapping, returning default value -#}
{{- default_value -}}
{%- elif options is defined and options is mapping %}
{#- The option parameter is a mapping, retrieve the value or return its default -#}
{{- options.get(key, default_value) -}}
{%- endif -%}
{%- endmacro %}
