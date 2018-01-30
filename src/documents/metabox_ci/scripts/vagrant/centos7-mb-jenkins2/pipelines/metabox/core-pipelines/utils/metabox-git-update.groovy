

node("metabox") {

    // metabox system init - start
    def mbSrcPath           = env.METABOX_SRC_PATH == null ? "src" : env.METABOX_SRC_PATH;
    def mbVagrantBuildPath  = env.METABOX_VAGRANT_BUILD_DIR 
    def mbUtils             = load "$mbVagrantBuildPath/scripts/vagrant/centos7-mb-jenkins2/pipelines_shared/metabox-utils.groovy"
    // metabox system init - end

    // use default or custom one to update to
    def branch              = env.METABOX_GIT_BRANCH

    stage("env sanity") {        
        mbUtils.runMetaboxEnvironmentCheck(mbSrcPath);
    }

    stage("git latest $branch") {
        mbUtils.runCmd "cd \"$mbSrcPath\\..\\\" && git reset --hard HEAD && git fetch --all && git checkout $branch && git pull"
    }

    stage("git status") {
        mbUtils.runCmd "cd \"$mbSrcPath\\..\\\" && git status"
    }

    stage("resource:generate") {
        mbUtils.runCmd "cd \"$mbSrcPath\" && rake resource:generate"
    }

}