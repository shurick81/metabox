echo "Enabling CLI..."
sed -i -e "s/<enabled>false<\/enabled>/<enabled>true<\/enabled>/g" /var/lib/jenkins/jenkins.CLI.xml

echo "Setting slave port to 33976..."
sed -i -e 's/<slaveAgentPort>-1<\/slaveAgentPort>/<slaveAgentPort>33976<\/slaveAgentPort>/g' /var/lib/jenkins/config.xml

exit 0
