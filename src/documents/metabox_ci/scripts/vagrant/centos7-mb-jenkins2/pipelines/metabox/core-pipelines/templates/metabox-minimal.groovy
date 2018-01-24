node("metabox") {

    // metabox system init - start
    def mbSrcPath           = env.METABOX_SRC_PATH == null ? "src" : env.METABOX_SRC_PATH;
    def mbVagrantBuildPath  = env.METABOX_VAGRANT_BUILD_DIR 
    def mbUtils             = load "$mbVagrantBuildPath/scripts/vagrant/centos7-mb-jenkins2/pipelines_shared/metabox-utils.groovy"
    // metabox system init - end
    
    stage("env sanity") {        
        mbUtils.runMetaboxEnvironmentCheck(mbSrcPath);
    }

    // add your stages here
    // always 'cd' to $mbSrcPath, then use 'rake task' as your normally use it in CLI
    
    // def vagrantEnvFolder = "win2012-r2-mb-bin-sp13-qa"

    // stage("dc12 up") {
    //     mbUtils.runCmd("cd $mbSrcPath && rake vagrant:up[$vagrantEnvFolder,ci-w12b13-dc]")
    // }

    // stage("sql12 up") {
    //     mbUtils.runCmd("cd $mbSrcPath && rake vagrant:up[$vagrantEnvFolder,ci-w12b13-sql]")
    // }

    // stage("sp1 up") {
    //     mbUtils.runCmd("cd $mbSrcPath && rake vagrant:up[$vagrantEnvFolder,ci-w12b13-sp1]")
    // }

}