jenkins_server="http://localhost:8080"

jenkins_cli_dir="/home/vagrant/bin"
jenkins_cli_path="$jenkins_cli_dir/jenkins-cli.jar"

jenkins_user=admin
jenkins_user_password=$(cat /var/lib/jenkins/secrets/initialAdminPassword)

echo "Creating Jenkins2 'metabox' user with -remoting option... Ensure that Enable CLI "

(
cat <<EOF
import jenkins.*
import jenkins.model.*
import hudson.*
import hudson.model.*
import hudson.security.*

def instance = Jenkins.getInstance();
def hudsonRealm = new HudsonPrivateSecurityRealm(false);
hudsonRealm.createAccount("metabox","metabox");

instance.setSecurityRealm(hudsonRealm);
instance.save();
def strategy = new GlobalMatrixAuthorizationStrategy();

strategy.add(Jenkins.ADMINISTER, "metabox");
strategy.add(Jenkins.ADMINISTER, "admin");

instance.setAuthorizationStrategy(strategy);
EOF
) | java -jar $jenkins_cli_path -remoting -s $jenkins_server groovy =  --username $jenkins_user --password $jenkins_user_password

echo "Completed!"