node("metabox") {

    // metabox system init - start
    def mbSrcPath           = env.METABOX_SRC_PATH == null ? "src" : env.METABOX_SRC_PATH;
    def mbVagrantBuildPath  = env.METABOX_VAGRANT_BUILD_DIR 
    def mbUtils             = load "$mbVagrantBuildPath/scripts/vagrant/centos7-mb-jenkins2/pipelines_shared/metabox-utils.groovy"
    // metabox system init - end
    
    mbUtils.runMetaboxPrepareStages(mbSrcPath);
    
    mbUtils.runMetaboxPackerBuild(mbSrcPath, "centos7-mb-canary");
    mbUtils.runMetaboxPackerBuild(mbSrcPath, "centos7-mb-java8");
    mbUtils.runMetaboxPackerBuild(mbSrcPath, "centos7-mb-jenkins2");
}