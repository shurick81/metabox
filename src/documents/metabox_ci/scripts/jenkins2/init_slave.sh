DIR=$(dirname "$0")
NAME=${1:-metabox-default-slave}
PORT=${2:-8082}

echo "Running Swarm client from folder: $DIR"
java -jar "$DIR/swarm-client-3.5.jar" -name "$NAME" \
    -disableSslVerification \
    -master "http://localhost:$PORT" \
    -username metabox \
    -password metabox \
    -labels metabox