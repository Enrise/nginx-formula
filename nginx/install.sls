include:
  - .repo

# Install NGINX Package from the repo
nginx:
  pkg.installed:
    - require:
      - pkgrepo: nginx_repo
