# NGINX Compiled with [NBS System](https://github.com/nbs-system/naxsi) NAXSI module

This image is based on the official `nginx:stable` image ([see on Dockehub](https://hub.docker.com/_/nginx/)) and recompiled with the same `./configure` options from vanilla NGINX sources with the addition of `--add-module=naxsi`.

NBS System's [NAXSI module](https://github.com/nbs-system/naxsi) is used;

* NAXSI means [NGINX](http://nginx.org/) Anti [XSS](https://www.owasp.org/index.php/Cross-site_Scripting_%28XSS%29) & [SQL Injection](https://www.owasp.org/index.php/SQL_injection).

## Acknowledgements

The compilation method for extra NGINX modules is taken from [procraft/nginx-purge-docker](https://github.com/procraft/nginx-purge-docker).
