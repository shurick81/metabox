
jenkins_server="http://localhost:8080"

jenkins_cli_dir="/home/vagrant/bin"
jenkins_cli_path="$jenkins_cli_dir/jenkins-cli.jar"

jenkins_user=admin
jenkins_user_password=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
SCRIPT="/vagrant//scripts/vagrant/centos7-mb-jenkins2/pipelines_shared/import-pipelines.groovy"

echo "Updating initial Jenkins2 pipelines..."
echo "  executing: $SCRIPT"

java -jar $jenkins_cli_path -remoting -s $jenkins_server groovy $SCRIPT --username $jenkins_user --password $jenkins_user_password 

function validate_exit_code()
{
    CODE=$1
    MGS=$2
 
    [ $CODE -eq 0 ] && echo "Exit code is 0, continue..."
    [ $CODE -ne 0 ] && echo "Exising with non-zero code [$CODE] - $MGS" && exit $CODE
}

validate_exit_code $? "Failed to import initial pipelines"
exit 0