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
        mbUtils.runMetaboxVagrantStackVMUp(mbSrcPath,      "regression-win2016::dc");
        
        try {
            mbUtils.runMetaboxVagrantStackVMUp(mbSrcPath,      "regression-win2016::sql12");
            mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2016::sql12");

            mbUtils.runMetaboxVagrantStackVMUp(mbSrcPath,      "regression-win2016::sql14");
            mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2016::sql14");

            mbUtils.runMetaboxVagrantStackVMUp(mbSrcPath,      "regression-win2016::sql16");
            mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2016::sql16");
        } finally {
            mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2016::sql12");
            mbUtils.runMetaboxVagrantStackVMHalt(mbSrcPath,    "regression-win2016::sql14");
            mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2016::sql16");
        }

    } finally {
        // mbUtils.runMetaboxVagrantStackDestroyAll(mbSrcPath) 
    } 
}
