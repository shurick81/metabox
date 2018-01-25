
jenkins_package=$METABOX_JENKINS2_PACKAGE

echo "Installing jenkins_package:[$jenkins_package]"

echo "Ensuring Jenkins repo..."
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key

#echo "Listing Jenkins versions..."
#yum --showduplicates list jenkins | expand

echo "Installing Jenkins package:[$jenkins_package]..."
yum install -y $jenkins_package

echo "Configiring and starting Jenkins service..."
chkconfig jenkins on

echo "Configiring iptables..."
iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT

echo "service jenkins start..."
service jenkins start

echo "Waiting 2 minutes until jenkins2 is up..."
sleep 120s

echo "Reporting Jenskins status"
service jenkins status

n=0
until [ $n -ge 5 ]
do
    cat /var/lib/jenkins/secrets/initialAdminPassword
    RETVAL=$?
    [ $RETVAL -eq 0 ] && echo "All good, continue..."
    [ $RETVAL -ne 0 ] && echo "Can't read initialAdminPassword for Jenkins2, sleeping 60s.." 

    n=$[$n+1]
    sleep 60s
done

[ $RETVAL -eq 0 ] && echo "All good, continue..."
[ $RETVAL -ne 0 ] && echo "Can't read initialAdminPassword for Jenkins2" && exit 1

exit 0