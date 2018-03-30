packages_string=$METABOX_JENKINS2_PLUGINS

echo "Updating plugins [$packages_string]"

j2_plugins=(${packages_string//,/ })

jenkins_server="http://localhost:8080"

jenkins_cli_dir="/home/vagrant/bin"
jenkins_cli_path="$jenkins_cli_dir/jenkins-cli.jar"

jenkins_user=admin
jenkins_user_password=$(cat /var/lib/jenkins/secrets/initialAdminPassword)

for plugin_id in "${j2_plugins[@]}"; do

    echo "Updating plugin: [$plugin_id] with user [$jenkins_user] and password:[$jenkins_user_password]"
    if java -jar $jenkins_cli_path -s $jenkins_server install-plugin $plugin_id --username $jenkins_user --password $jenkins_user_password; then
        echo "  - completed!"
    else
        echo "  - failed!"
    fi

done

echo "Restrating Jenkins2..."
java -jar $jenkins_cli_path -s $jenkins_server restart --username $jenkins_user --password $jenkins_user_password

echo "Completed!"

exit 0