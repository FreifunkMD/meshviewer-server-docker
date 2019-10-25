FROM node:12-slim

ENV MeshviewerRepo="https://github.com/ffrgb/meshviewer.git --branch develop"
ENV LoopHookCMD=""

WORKDIR /meshviewer

EXPOSE 80

RUN apt update && apt install -y --no-install-recommends \
    nginx \
    git

CMD rm -rf /var/www/html/* ; \
    mkdir -p /var/www/html/data ; \
    service nginx start ; \
    echo "<html><head><meta http-equiv="refresh" content="5"></head> <body><h1>Meshviewer wird frisch geklont und neu gebaut.</h1><h1>Bitte 1-2 Minuten warten...</h1></body></html>" > /var/www/html/index.html ; \
    apt update && apt upgrade -y --no-install-recommends; \
    sh -c "git clone $MeshviewerRepo ." ; \
    yarn ; \
    yarn gulp ; \
    sh -c "$LoopHookCMD" ; \
    cp -R -f build/* /var/www/html ; \
    while true; do sleep 1m; sh -c "$LoopHookCMD" ; done
