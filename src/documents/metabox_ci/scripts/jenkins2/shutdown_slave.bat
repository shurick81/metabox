echo 'Killing all Swarm slaves...'
ps | grep "swarm-client-3.5.jar" | grep -v grep | $(awk '{print "kill -9 " $1}')