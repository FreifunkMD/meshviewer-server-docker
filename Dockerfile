FROM node:12-slim

ENV MeshviewerRepo="https://github.com/ffrgb/meshviewer.git --branch develop"
ENV LoopHookCMD=""

WORKDIR /meshviewer

EXPOSE 80

RUN apt update \
    && apt install -y --no-install-recommends \
           nginx \
           git

COPY nginx-site.default /etc/nginx/sites-available/default

CMD rm -rf /var/www/html/* ; \
    mkdir -p /var/www/html/data ; \
    echo "<html><head><meta http-equiv="refresh" content="5"></head> <body><h1>Meshviewer wird frisch geklont und neu gebaut.</h1><h1>Bitte 1-2 Minuten warten...</h1></body></html>" > /var/www/html/index.html ; \
    service nginx start ; \
    apt update && apt upgrade -y --no-install-recommends; \
    sh -c "git clone $MeshviewerRepo ." ; \
    yarn ; \
    yarn gulp ; \
    yarn cache clean ; \
    rm -rf node_modules ; \
    sh -c "$LoopHookCMD" ; \
    cp -R -f build/* /var/www/html ; \
    while true; do sleep 1m; sh -c "$LoopHookCMD" ; done
