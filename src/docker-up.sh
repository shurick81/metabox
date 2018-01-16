docker build . --tag subpoint/metabox:latest
docker run -i -t -v $(pwd):/metabox --entrypoint=/bin/bash subpoint/metabox:latest