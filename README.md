# Generischer "All in One" Meshviewer-Server 
## Allgemein
Durch das Dockerfile wird ein generischer "All in One" Meshviewer-Server bereitgestellt (Map Build-Server,  Web-Server und ggf. ein Tiles-Proxy).

Der Container stellt in der Default-Konfiguration die Regensburger Map bereit.  

Durch einen individuell angepassten Docker-Aufruf kann jedoch jeglicher Clone des [Regensburger Meshviewer-GitRepos](https://github.com/ffrgb/meshviewer) eingebunden werden.  

Der Container aktualisiert bei jedem Start per `apt` alle System-Packages. Gefolgt wird ein Meshviewer-GitRepo in das Container-interne Verzeichnis `/meshviewer` geklont. Mit `yarn gulp` wird der Meshviewer automatisch gebaut und über einen Webserver (nginx) bereitgestellt. Es handelt sich um einen reinen Wegwerf-Container. Es werden keine Mounts oder Volumes verwendet.

Der Container kann zusätzlich als Tiles-Server verwendet werden. Der Container wird dann als Proxy für Tiles eines Servers von OpenStreetMap.org verwendet. In diesem Fall sind die [Nutzungsvoraussetzungen von OpenStreetMap](https://wiki.openstreetmap.org/wiki/DE:Tile_usage_policy) einzuhalten.

Der Meshviewer-Server liefert seinen Content über HTTP aus un sollte immer hinter einem Reverse-Proxy betrieben werden.  

## Docker-Umgebungsvariablen
Die default Dockerfile-Umgebungsvariablen sind beispielhaft für die Regensburger Map ausgelegt.  
Die Umgebungsvariablen können jedoch bei dem Starten des Docker-Containers individuell mittels `--env` angepasst/überschrieben werden (siehe Magdeburger Anwendungsbeispiele weiter unten).

- `MeshviewerRepo = "https://github.com/ffrgb/meshviewer.git --branch develop"`  
In der Docker-Umgebungsvariable `MeshviewerRepo` wird der Link zu dem Git-Repo angegeben, in welchem eure Meshviewer-Konfiguration enthalten ist. Optional kann der zu nutzende Git-Branch mit angegeben werden.

- `LoopHookCMD = ""`  
In dem Container wird letztlich eine Endlosschleife mit einer Sleep-Time von 1 Minute gestartet.  
Innerhalb dieser Schleife wird eine Hook-Befehlsfolge aus der Docker-Umgebungsvariable `LoopHookCMD` zyklisch aufgerufen.  
Mittels `LoopHookCMD` könnte z.B. die `meshviewer.json` eigenständig und zyklisch selber durch den Meshviewer-Server geladen und in dem Ordner `/var/www/html/data/` abgelegt werden. Der Meshviewer-Server könnte dann alleinig allen Content aus einer Hand ausliefern.  
Hierdurch erspart man sich, wegen CORS-Fehlern, zusätzlichen Konfigurationsaufwand bezüglich Access-Control-Allow-Origin beim Reverse-Proxy.

## Tiles-Proxy
 - Soll der Container als Tiles-Proxy der OpenStreetMap.org-Server fungieren, dann muß in der Meshviewer-Konfiguration `(config.js)` für den Tiles-Server-Link folgender Eintrag verwendet werden:

```
'mapLayers': [
   {
   ...
   "url": "/tiles-cache/{z}/{x}/{y}.png"
   ...
   }
```
 - Die Tiles-Server von OpenStreetMap.org werden intern über HTTP (nicht HTTPS) angesprochen.

## Anwenden
### Image lokal bauen

```
git clone https://github.com/FreifunkMD/meshviewer-server-docker.git .
docker build -t meshviewer-server .
```

### Container ausführen

#### Beispiel: Regensburger Map (default Beispielkonfiguration)
- Ausführen des lokal gebauten Containers, unter Verwendung von Port 8080, durch:

```
docker run --name meshviewer-server \
           --detach \
           --rm \
           -p 8080:80 \
           meshviewer-server
```

- Oder Ausführen des auf Docker Hub bereitgestellten Containers, mit Verwendung von Port 8080, durch:

```
docker run --name meshviewer-server \
           --detach \
           --rm \
           -p 8080:80 \
           ffmd/meshviewer-server:latest
```

Achtung:  
Bei der Regensburger Demo ist der Zugriff auf die Regensburger Tiles-Server gesperrt.

#### Beispiel: Magdeburger Babel Map (individuell)
- Ausführen des lokal gebauten Containers, unter Verwendung von Port 8080, durch:

```
docker run --name meshviewer-server \
           --detach \
           --rm \
           -p 8080:80 \
           --env MeshviewerRepo="https://github.com/FreifunkMD/Meshviewer --branch ffmd" \
           --env LoopHookCMD="wget https://map.md.freifunk.net/data/meshviewer.json \
                              -O /var/www/html/data/meshviewer.json" \
           meshviewer-server
```

- Oder ausführen des auf Docker Hub bereitgestellten Containers, unter Verwendung von Port 8080, durch:

```
docker run --name meshviewer-server \
           --detach \
           --rm \
           -p 8080:80 \
           --env MeshviewerRepo="https://github.com/FreifunkMD/Meshviewer --branch ffmd" \
           --env LoopHookCMD="wget https://map.md.freifunk.net/data/meshviewer.json \
                              -O /var/www/html/data/meshviewer.json" \
           ffmd/meshviewer-server:latest
```

### Map anzeigen
Nach dem Start ca. 1-2 Minuten warten und dann die Map durch einen Browser-Aufruf von http://xyz:8080 oder http://localhost:8080 anzeigen lassen.

## Sonstiges

- OS: Debian Buster  
- Node.js: v12  
- Intern genutzter Port: 80  
- Workdir: /meshviewer  
- Webdir: /var/www/html  
- Tiles-Cache: /var/www/cache, 5GB, 7 Tage

## Links
Docker Hub: https://hub.docker.com/r/ffmd/meshviewer-server  
Git-Repo dieses Projektes: https://github.com/FreifunkMD/meshviewer-server-docker
