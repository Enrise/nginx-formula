# Configure the official nginx repo
{%- set lsb_codename = salt['grains.get']('lsb_distrib_codename') %}
{%- set mainline = salt['pillar.get']('nginx:package:mainline', False) %}

# Install Nginx repository
nginx_repo:
  pkgrepo.managed:
    - humanname: Nginx PPA
    {%- if mainline == True %}
    - name: deb http://nginx.org/packages/mainline/{{ grains['os']|lower }}/ {{ lsb_codename }} nginx
    {%- else %}
    - name: deb http://nginx.org/packages/{{ grains['os']|lower }}/ {{ lsb_codename }} nginx
    {%- endif %}
    - dist: {{ lsb_codename }}
    - file: /etc/apt/sources.list.d/nginx.list
    - keyid: 7BD9BF62
    - key_url: http://nginx.org/keys/nginx_signing.key
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - pkg: nginx
