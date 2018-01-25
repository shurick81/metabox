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
       
        // stand up SQL14
        mbUtils.runMetaboxVagrantStackVMUp(mbSrcPath,      "regression-win2016::sql14");

        // stand up SP2016 RTM
        mbUtils.runMetaboxVagrantStackVMUp(mbSrcPath,      "regression-win2016::sp16rtm");
        mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2016::sp16rtm");

        // stand up SP2016 FP2
        mbUtils.runMetaboxVagrantStackVMUp(mbSrcPath,      "regression-win2016::sp16fp2");
        mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2016::sp16fp2");   

        // clean up all
        // mbUtils.runMetaboxVagrantStackDestroyAll(mbSrcPath) 
    } finally {
        mbUtils.runMetaboxVagrantStackVMHalt(mbSrcPath,    "regression-win2016::sql14");

        mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2016::sp16rtm");
        mbUtils.runMetaboxVagrantStackVMDestroy(mbSrcPath, "regression-win2016::sp16fp2");

    } 
}
