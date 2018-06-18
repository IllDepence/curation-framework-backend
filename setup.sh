#!/bin/bash

externalurl=http://136.187.82.133

# NOTE: services are expected to be accessible at
# - JSONkeeper: <externalurl>/curation
# - Canvas Indexer: <externalurl>/ci
# - Curation Finder: <externalurl>/search
# - Curation Viewer: <externalurl>/view
# from outside (web/intranet/...)
# and will be exposed by docker at
# - JSONkeeper: http://127.0.0.1:8001
# - Canvas Indexer: http://127.0.0.1:8002
# - Curation Finder: http://127.0.0.1:8003
# - Curation Viewer: http://127.0.0.1:8004

exturlesc="${externalurl//\//\\/}"

# Jk and CI
rm -rf JSONkeeper
rm -rf Canvas-Indexer
git clone https://github.com/IllDepence/JSONkeeper.git
git clone https://github.com/IllDepence/Canvas-Indexer.git
cp -v jk/.dockerignore jk/Dockerfile jk/gunicorn_config.py jk/config.ini JSONkeeper
cp -v ci/.dockerignore ci/Dockerfile ci/gunicorn_config.py ci/config.ini ci/log.txt Canvas-Indexer
sed -i -E "s/server_url =.+/server_url = $exturlesc\/curation/" JSONkeeper/config.ini
sed -i -E "s/as_sources =.+/as_sources = $exturlesc\/curation\/as\/collection.json/" Canvas-Indexer/config.ini

# CV and CF
rm -rf IIIFCurationViewer
rm -rf IIIFCurationFinder
cp -r cv/IIIFCurationViewer .
cp -r cf/IIIFCurationFinder .
cp -v cv/.dockerignore cv/Dockerfile IIIFCurationViewer
cp -v cf/.dockerignore cf/Dockerfile IIIFCurationFinder
sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: '$exturlesc\/curation\/api'/" IIIFCurationViewer/index.js
sed -i -E "s/curationJsonExportUrl: '.+'/curationJsonExportUrl: '$exturlesc\/curation\/api'/" IIIFCurationFinder/index.js
sed -i -E "s/curationViewerUrl: '.+'/curationViewerUrl: '$exturlesc\/view\/'/" IIIFCurationFinder/index.js
sed -i -E "s/searchEndpointUrl: '.+'/searchEndpointUrl: '$exturlesc\/ci\/api'/" IIIFCurationFinder/index.js
sed -i -E "s/facetsEndpointUrl: '.+'/facetsEndpointUrl: '$exturlesc\/ci\/facets'/" IIIFCurationFinder/index.js
sed -i -E "s/redirectUrl: '.+'/redirectUrl: '$exturlesc\/view\/'/" IIIFCurationFinder/exportJsonKeeper.js

./reset.sh
