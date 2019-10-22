# Generischer "All in One" Meshviewer-Server 
## Allgemein
Durch das Dockerfile wird ein generischer "All in One" Meshviewer-Server bereitgestellt (Build- wie auch Web-Server).

Der Container stellt in der Default-Konfiguration die Regensburger Map bereit.  

Durch einen individuell angepassten Docker-Aufruf kann jedoch jeglicher Fork des [Regensburger Meshviewer-GitRepos](https://github.com/ffrgb/meshviewer) verwendet werden.  

Der Container aktualisiert bei jedem Start per `apt` alle System-Packages. Gefolgt wird ein Meshviewer-GitRepo in das Verzeichnis `/meshviewer` geklont. Mit `yarn gulp` wird der Meshviewer gebaut und über einen Webserver (nginx) per http-Webseite bereitgestellt.

Der Meshviewer-Server sollte immer hinter einem Reverse-Proxy angesiedelt sein.

## Docker-Umgebungsvariablen
Die default Dockerfile-Umgebungsvariablen sind für die Regensburger Map ausgelegt.  
Die Umgebungsvariablen können jedoch bei dem Starten des Docker-Containers individuell mittels `--env` angepasst werden.

- `MeshviewerRepo = "https://github.com/ffrgb/meshviewer.git --branch develop"`  
In der Docker-Umgebungsvariable `MeshviewerRepo` wird der Link zu dem Git-Repo angegeben, in welchem der zu verwendende Meshviewer enthalten ist. Optional kann der zu nutzende Git-Branch mit angegeben werden.

- `LoopHookCMD = ""`  
In dem Container wird letztlich eine Endlosschleife mit einer Sleep-Time von 1 Minute gestartet.  
Innerhalb dieser Schleife wird der Hook-Befehl aus der Docker-Umgebungsvariable `LoopHookCMD` zyklisch aufgerufen.  
Mittels `LoopHookCMD` könnte z.B. die `meshviewer.json` eigenständig und zyklisch selber durch den Meshviewer-Server geladen und in dem Ordner `/var/www/html/data/` abgelegt werden. Der Meshviewer-Server könnte dann alleinig allen Content aus einer Hand ausliefern.  
Hierdurch erspart man sich, wegen CORS-Fehlern, zusätzlichen Konfigurationsaufwand bezüglich Access-Control-Allow-Origin beim Reverse-Proxy.


## Anwenden
### Image lokal bauen

`docker build -t meshviewer-server .`

### Container ausführen

#### Beispiel: Regensburger Map (default)
Ausführen des Containers, mit Verwendung von Port 8080, durch:

```
docker run --name meshviewer-server \
           --detach \
           --rm \
           -p 8080:80 \
           meshviewer-server
```

oder per Docker Hub:

```
docker run --name meshviewer-server \
           --detach \
           --rm \
           -p 8080:80 \
           ffmd/meshviewer-server:latest
```

Achtung:  
Bei der Regensburger Demo ist der Zugriff auf den verwendeten Tiles-Server gesperrt.

#### Beispiel: Magdeburger Babel Map (individuell)
Ausführen des Containers, mit Verwendung von Port 8080, durch:

```
docker run --name meshviewer-server \
           --detach \
           --rm \
           -p 8080:80 \
           --env MeshviewerRepo="https://github.com/FreifunkMD/Meshviewer --branch ffmd" \
           --env LoopHookCMD="wget http://gw01.babel.md.freifunk.net:8080/data/meshviewer.json \
                              -O /var/www/html/data/meshviewer.json" \
           meshviewer-server
```

oder per Docker Hub:

```
docker run --name meshviewer-server \
           --detach \
           --rm \
           -p 8080:80 \
           --env MeshviewerRepo="https://github.com/FreifunkMD/Meshviewer --branch ffmd" \
           --env LoopHookCMD="wget http://gw01.babel.md.freifunk.net:8080/data/meshviewer.json \
                              -O /var/www/html/data/meshviewer.json" \
           ffmd/meshviewer-server:latest
```

### Map anzeigen
Nach dem Start ca. 1-2 Minuten warten und dann die Map durch einen Browser-Aufruf von http://xyz:8080 oder http://localhost:8080 anzeigen lassen.

## Sonstiges
Workdir: /meshviewer  
Interner Port: 80  
Webdir: /var/www/html  
Node.js: v12  
OS: Debian Buster

## Links
Docker Hub: https://hub.docker.com/r/ffmd/meshviewer-server  
Git-Repo dieses Projektes: https://github.com/FreifunkMD/meshviewer-server-docker
