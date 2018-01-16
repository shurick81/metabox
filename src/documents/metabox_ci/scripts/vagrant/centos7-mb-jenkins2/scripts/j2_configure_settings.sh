port=$2

echo "Enabling CLI..."
sed -i -e "s/<enabled>false<\/enabled>/<enabled>true<\/enabled>/g" /var/lib/jenkins/jenkins.CLI.xml

echo "Setting slave port to [$port]..."
sed -i -e "s/<slaveAgentPort>-1<\/slaveAgentPort>/<slaveAgentPort>$port<\/slaveAgentPort>/g" /var/lib/jenkins/config.xml


