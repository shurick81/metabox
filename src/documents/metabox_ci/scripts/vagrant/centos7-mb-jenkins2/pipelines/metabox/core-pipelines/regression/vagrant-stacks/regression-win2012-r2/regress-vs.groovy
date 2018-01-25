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
        
        try {
            mbUtils.runMetaboxVagrantStackVMUp(mbSrcPath,      "regression-win2012-r2::vs13");
            mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2012-r2::vs13");

            mbUtils.runMetaboxVagrantStackVMUp(mbSrcPath,      "regression-win2012-r2::vs15");
            mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2012-r2::vs15");

        } finally {
            mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2012-r2::vs13");
            mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2012-r2::vs15");
        }

    } finally {
        // mbUtils.runMetaboxVagrantStackDestroyAll(mbSrcPath) 
    } 
}
