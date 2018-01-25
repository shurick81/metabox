node("metabox") {

    // metabox system init - start
    def mbSrcPath           = env.METABOX_SRC_PATH == null ? "src" : env.METABOX_SRC_PATH;
    def mbVagrantBuildPath  = env.METABOX_VAGRANT_BUILD_DIR 
    def mbUtils             = load "$mbVagrantBuildPath/scripts/vagrant/centos7-mb-jenkins2/pipelines_shared/metabox-utils.groovy"
    // metabox system init - end
    
    stage("env sanity") {        
        mbUtils.runMetaboxEnvironmentCheck(mbSrcPath);
    }

    try {
        mbUtils.runMetaboxVagrantStackVMUp(mbSrcPath,      "regression-win2012-r2::dc");
       
        // stand up SQL12
        mbUtils.runMetaboxVagrantStackVMUp(mbSrcPath,      "regression-win2012-r2::sql12");

        // stand up SP2013 SP1
        mbUtils.runMetaboxVagrantStackVMUp(mbSrcPath,      "regression-win2012-r2::sp13_sp1");
        mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2012-r2::sp13_sp1");   

        // clean up all
        // mbUtils.runMetaboxVagrantStackDestroyAll(mbSrcPath) 

    } finally {
        mbUtils.runMetaboxVagrantStackVMHalt(mbSrcPath,    "regression-win2012-r2::sql12");

        mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2012-r2::sp13_sp1");
    } 
}
