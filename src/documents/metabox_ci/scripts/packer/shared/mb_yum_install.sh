echo "Installing common packages: [$METABOX_YUM_PACKAGES]"

packages=(${METABOX_YUM_PACKAGES//,/ })

for package_id in "${packages[@]}"; do

    echo "installing package: [$package_id]"
    yum install -y $package_id

done