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
    
    // TODO!
    parallel p_7z1701: {
            stage("7z1701") {
                mbUtils.runCmd("cd $mbSrcPath && export METABOX_DOWNLOADS_PATH='/Users/avishnyakov/Downloads' && rake prepare:download[7z1701]")
            }
        },
        p_7z1604: {
            stage("7z1604") {
                mbUtils.runCmd("cd $mbSrcPath && export METABOX_DOWNLOADS_PATH='/Users/avishnyakov/Downloads' && rake prepare:download[7z1604]")
            }
        },
        p_SharePointDesigner2013_64: {
            stage("SharePointDesigner2013_64") {
                mbUtils.runCmd("cd $mbSrcPath && export METABOX_DOWNLOADS_PATH='/Users/avishnyakov/Downloads' && rake prepare:download[SharePointDesigner2013_64]")
            }
        },
        p_SharePointDesigner2013_32: {
            stage("SharePointDesigner2013_32") {
                mbUtils.runCmd("cd $mbSrcPath && export METABOX_DOWNLOADS_PATH='/Users/avishnyakov/Downloads' && rake prepare:download[SharePointDesigner2013_32]")
            }
        }
}