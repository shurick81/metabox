node("metabox") {

    def mbUtils = null;
    
    def mbSrcPath = env.METABOX_SRC_PATH == null ? "src" : env.METABOX_SRC_PATH;
    def mbGit = env.METABOX_GIT_URL == null ? "https://github.com/SubPointSolutions/metabox.git" : env.METABOX_GIT_URL;
    def mbGitBranch = env.METABOX_GIT_BRANCH == null ? "master" : env.METABOX_GIT_BRANCH;
    
    stage("git checkout") {
      if(mbSrcPath.startsWith("src")) { echo "Using branch [$mbGitBranch] fron [$mbGit]" git url: "$mbGit", branch: "$mbGitBranch"  }
      else { echo "Using local src folder: [$mbSrcPath]" }
     
      mbUtils = load "$mbSrcPath/documents/scripts/vagrant/centos7-mb-jenkins2/pipelines_shared/metabox-utils.groovy"
    }
    
    stage("env sanity") {        
        mbUtils.runMetaboxEnvironmentCheck(mbSrcPath);
    }
}