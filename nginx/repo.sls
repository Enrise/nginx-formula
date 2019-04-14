# Configure the official nginx repo
{%- set lsb_codename = salt['grains.get']('lsb_distrib_codename') %}
{%- set mainline = salt['pillar.get']('nginx:package:mainline', False) %}

# Install Nginx repository
nginx_repo:
  pkgrepo.managed:
    - humanname: Nginx PPA
    {%- if mainline == True %}
    - name: deb [arch=amd64] https://nginx.org/packages/mainline/{{ grains['os']|lower }}/ {{ lsb_codename }} nginx
    {%- else %}
    - name: deb [arch=amd64] https://nginx.org/packages/{{ grains['os']|lower }}/ {{ lsb_codename }} nginx
    {%- endif %}
    - dist: {{ lsb_codename }}
    - file: /etc/apt/sources.list.d/nginx.list
    - key_url: https://nginx.org/keys/nginx_signing.key
    - require_in:
      - pkg: nginx
