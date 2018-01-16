jenkins_server="http://localhost:8080"

jenkins_cli_dir="/home/vagrant/bin"
jenkins_cli_path="$jenkins_cli_dir/jenkins-cli.jar"

jenkins_user=admin
jenkins_user_password=$(cat /var/lib/jenkins/secrets/initialAdminPassword)

echo "Restrating Jenkins2..."
java -jar $jenkins_cli_path -s $jenkins_server restart --username $jenkins_user --password $jenkins_user_password

echo "Completed!"

function wait_juntil_j2_online() {

    echo "Waiting until Jenkins2 API is online..."

    jenkins_cli_path=$1
    jenkins_server=$2
    jenkins_user=$3
    jenkins_user_password=$4

    echo "Calling J2 API..."
    result=$( java -jar $jenkins_cli_path -s $jenkins_server who-am-i --username $jenkins_user --password $jenkins_user_password )

    echo "Result: [$result]"

    while [[ $result != *"Authenticated as"* ]];do
        
        echo "Sleeping for 5s..."
        sleep 5s

        echo "Calling J2 API..."
        result=$( java -jar $jenkins_cli_path -s $jenkins_server who-am-i --username $jenkins_user --password $jenkins_user_password )
        #echo "Result: [$result]"
    done

    echo "Jenkins API is online!: Continue script..."
}

wait_juntil_j2_online $jenkins_cli_path $jenkins_server $jenkins_user $jenkins_user_password