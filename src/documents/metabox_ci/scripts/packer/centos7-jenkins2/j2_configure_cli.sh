echo "Configuring Jenkins2 CLI..."

jenkins_server="http://localhost:8080"
jenkins_cli_url="$jenkins_server/jnlpJars/jenkins-cli.jar"

jenkins_cli_dir="/home/vagrant/bin"
jenkins_cli_path="$jenkins_cli_dir/jenkins-cli.jar"

mkdir -p $jenkins_cli_dir
rm -rf $jenkins_cli_dir/jenkins-cli*

echo "Saving [$jenkins_cli_url] -> [$jenkins_cli_dir]"
wget -q $jenkins_cli_url -P $jenkins_cli_dir

echo "Updating permissions.."
chmod 755 $jenkins_cli_path

echo "Completed!"

exit 0