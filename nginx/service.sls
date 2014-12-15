{% from "nginx/map.jinja" import nginx as nginx_map with context %}

# Extend nginx to include a service, and ensure its always running
extend:
  nginx:
    service.running:
      - enable: True
      - reload: True
      - watch:
        - file: {{ nginx_map.dirs.config }}/conf.d/*
        - pkg: nginx
      - require:
        - pkg: nginx
