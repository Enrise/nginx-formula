# Manage core configuration for Nginx
{% from "nginx/lib.sls" import serialize %}
{% from "nginx/map.jinja" import nginx as nginx_map with context %}

# Remove default files
{%- if salt['pillar.get']('nginx:config:cleanup', True) %}
{% for filename in ('default', 'example_ssl') %}
{{ nginx_map.dirs.config }}/conf.d/{{ filename }}.conf:
  file.absent
{% endfor %}
{%- endif %}

################################################################################
# Generate DHParam if it doesn't exist
{%- if salt['pillar.get']('nginx:config:dhparam') %}
generate_dhparam:
  cmd.run:
    - name: "openssl dhparam -out /etc/ssl/private/dhparam_{{ salt['grains.get']('fqdn') }}.crt {{ salt['pillar.get']('nginx:config:dhparam_bits', 2048) }}"
    - creates: /etc/ssl/private/dhparam_{{ salt['grains.get']('fqdn') }}.crt
    - user: root
    - watch_in:
      - service: nginx
    - require:
      - pkg: nginx
{%- endif %}
################################################################################
# Manage nginx.conf if configured, otherwise use default
{%- if salt['pillar.get']('nginx:config:server:config_template') %}
{{ nginx_map.dirs.config }}/nginx.conf:
  file.managed:
  - source: {{ salt['pillar.get']('nginx:config:server:config_template') }}
  - template: {{ salt['pillar.get']('nginx:config:server:config_template_type', 'jinja') }}
  - watch_in:
    - service: nginx
  - require:
    - pkg: nginx
  - context:
    http: {{ salt['pillar.get']('nginx:config:server:config:http', {}) }}
    events: {{ salt['pillar.get']('nginx:config:server:config:events', {}) }}
{%- endif %}
################################################################################

# Ensure the "sites-enabled" are included
{%- if salt['pillar.get']('nginx:config:sites_enabled', True) %}
# We need to create (or ensure they exist) additional folders
{% for dir in ( nginx_map.dirs.sites_enabled, nginx_map.dirs.sites_available ) %}
{{ dir }}:
  file.directory:
    - user: root
    - group: root
    - require:
      - pkg: nginx
{% endfor -%}

{{ nginx_map.dirs.config }}/conf.d/http_include_sites.conf:
  file.managed:
    - contents: 'include {{ nginx_map.dirs.sites_enabled }}/*;'
    - require:
      - pkg: nginx
{%- endif %}

{%- if salt['pillar.get']('nginx:config:security', True) %}
# Lock down NGINX with a security sauce
{{ nginx_map.dirs.config }}/conf.d/http_security.conf:
  file.managed:
    - source: salt://nginx/files/security.conf
    - template: jinja
    - require:
      - pkg: nginx
{%- endif %}

# Fix fastcgi_params file causing issues with PHP-FPM usage
{{ nginx_map.dirs.config }}/fastcgi_params:
  file.append:
    - text: "fastcgi_param  SCRIPT_FILENAME    $request_filename;"
    - require:
      - pkg: nginx

################################################################################
# Install placeholder
{%- if salt['pillar.get']('nginx:placeholder:install', True) %}
install_placeholder:
  file.managed:
    - name: /usr/share/nginx/html/index.html
    - source: {{ salt['pillar.get']('nginx:placeholder:template', 'salt://nginx/templates/placeholder.html.jinja') }}
    - template: {{ salt['pillar.get']('nginx:placeholder:template_type', 'jinja') }}
    - mode: 644

# Install placeholder vhost
{{ nginx_map.dirs.config }}/sites-enabled/000-placeholder.conf:
  file.managed:
  - source: {{ salt['pillar.get']('nginx:placeholder:config_template', 'salt://nginx/templates/default.conf.jinja') }}
  - template: {{ salt['pillar.get']('nginx:placeholder:config_template_type', 'jinja') }}
  - watch_in:
    - service: nginx
  - require:
    - pkg: nginx
    - file: install_placeholder
  - webroot: /usr/share/nginx/html
  - php: False
  - index: index.html
  - domain: '_'
  - default_server: True
{%- if salt['pillar.get']('nginx:placeholder:enable_ssl', False) %}
  - ssl:
      cert: {{ salt['pillar.get']('nginx:placeholder:ssl_certificate') }}
      spdy: True
      key: {{ salt['pillar.get']('nginx:placeholder:ssl_key') }}
{%- endif %}

{%- endif %}
