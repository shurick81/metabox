boolean isWindows() {
    return env.OS == 'Windows_NT'
}


void runCmd(String cmd, String winCmd = null) {
    if(isWindows()) {
        if(winCmd != null) {
            bat winCmd
        } else {
            bat cmd
        }
    } else {
        sh cmd
    }
}

String[] getEnvironmentVariables() {
    result = []

    if(isWindows()) {

        def windowsPath = "PATH=" + [
            "C:/windows/system32",
            "C:/HashiCorp/Vagrant/bin",
            "C:/tools/cygwin/bin",
            "C:/Windows/System32/WindowsPowerShell/v1.0",
            "C:/ProgramData/chocolatey/bin"
        ].join(";");

        result.Add(windowsPath);
    } else {
        
    }

    return result;
}

void runRakeTask(String customMetaboxPath, String rakeTask, String packerFileName = null) {

    def rakeBuildCmd = ""

    if(packerFileName != null) {
        rakeBuildCmd = "cd $customMetaboxPath && rake $rakeTask[$packerFileName]"
    } else {
        rakeBuildCmd = "cd $customMetaboxPath && rake $rakeTask"
    }

    echo "Running: [${rakeBuildCmd}]"
    
    runCmd rakeBuildCmd
 }
 

void getMetaboxPath(customMetaboxPath) {

    if(customMetaboxPath == null) {
        echo "Fetching branch [$gitBranch] from: $gitUrl"
        git branch: "$gitBranch", url: "$gitUrl"
        customMetaboxPath = "src"
    } else {
        echo "Running on custom, local src folder:[$customMetaboxPath]"
    }

    echo "Final metabox src folder:[$customMetaboxPath]"

    return customMetaboxPath;
}

void checkEnvironmentVariable(name) {
    
    value = env."${name}"

    if(value == null) {
        error "${name} is null or empty"
    } else {
        echo "${name}: ${value}"
    }
}

void runMetaboxEnvironmentCheck(mbSrcPath) {

    // src folder exist?
    runCmd "if [ ! -d \"$mbSrcPath\" ]; then echo 'Folder does not exist: [$mbSrcPath]' exit 0; fi", "IF NOT EXIST \"$mbSrcPath\" exit 1;"

    // we better kbow that
    runCmd 'whoami'

    // env set
    runCmd 'printenv | sort', 'SET'

    // METABOX_ related vars
    runCmd 'printenv | grep METABOX_ | sort', 'SET'

    // packer
    runCmd 'which packer', 'where packer'
    runCmd 'packer --version'

    // vagrant  
    runCmd 'which vagrant', 'where vagrant'
    runCmd 'vagrant --version'

    // ruby
    runCmd 'which ruby', 'where ruby'
    runCmd 'ruby --version'

    runCmd 'which rake', 'where rake'
    runCmd 'rake --version'
    
    runCmd 'which gem', 'where gem'
    runCmd 'gem --version'
    runCmd 'gem list | sort', 'gem list'

    // git
    runCmd 'which git', 'where git'
    runCmd 'git --version'
    runCmd 'echo $METABOX_WORKING_DIR'
    runCmd 'echo $METABOX_GIT_BRANCH'
    
    // 7z
    runCmd 'which 7z', 'where 7z'

    // wget
    runCmd 'which wget', 'where wget.exe'

    // empty metabox run
    runCmd "cd $METABOX_SRC_PATH && rake"

    // empty metabox run with version
    runCmd "cd $METABOX_SRC_PATH && rake metabox:version"
}

void runMetaboxMachinePreparation(mbSrcPath) {
    runMetaboxEnvironmentCheck(mbSrcPath)
    
}

void runMetaboxPackerBoxClean(mbSrcPath) {
    runRakeTask(mbSrcPath, "packer:clean", "box")
}

void runMetaboxPackerOutputClean(mbSrcPath) {
    runRakeTask(mbSrcPath, "packer:clean", "output")
}

void runMetaboxFilesetDownload(mbSrcPath) {

    jobParts = env.JOB_NAME.split('/').last().split("\\+")
    
    filesetName  = jobParts[0]
    resourceName = jobParts[1]

    resourceFullName = filesetName + "::" + resourceName
    
    stage("fileset:download") {
        runCmd("cd $mbSrcPath && rake fileset:download[$resourceFullName]")
    }
}

void runMetaboxPackerBuild(mbSrcPath, String packerFileName = null) {

    resourceName = env.JOB_NAME.split('/').last()

    try {

        stage ("resource:generate") {
            runRakeTask(mbSrcPath, "resource:generate")
        }

        stage ("resource:list") {
            runRakeTask(mbSrcPath, "resource:list")
        }

        stage ("packer:build") {
            runRakeTask(mbSrcPath, "packer:build[${resourceName},--force]")
        }

        stage ("vagrant:add") {
            runRakeTask(mbSrcPath, "vagrant:add[${resourceName},--force]")
        }

        stage ("vagrant:list") {
            runRakeTask(mbSrcPath, "vagrant:box_list")
        }

    } catch(e) {
        echo "Failed to run build: ERROR - $e"
        throw e
     } finally {
        echo "Running packer:clean task..."
        //runRakeTask(mbSrcPath, "packer:clean", packerFileName)
    }

}

void runMetaboxVagrantGlobalStatus(mbSrcPath)
{
    runRakeTask(mbSrcPath, "vagrant:global_status")
}

void runMetaboxVagrantStackDestroyAll(mbSrcPath) 
{
    // meaning, second from the 'last'
    stackName = env.JOB_NAME.split('/')[-2]

    try {

        stage ("resource:generate") {
            runRakeTask(mbSrcPath, "resource:generate")
        }

        stage ("resource:list") {
            runRakeTask(mbSrcPath, "resource:list")
        }

        stage ("vagrant:destroy[$stackName::_all,--force]") {
            runRakeTask(mbSrcPath, "vagrant:destroy[$stackName::_all,--force]")
        }
       
    } catch(e) {
        echo "Failed to run build: ERROR - $e"
        throw e
     } finally {
     
     }
}

void runMetaboxVagrantStackUpAll(mbSrcPath) 
{
    // meaning, second from the 'last'
    stackName = env.JOB_NAME.split('/')[-2]

    try {

        stage ("resource:generate") {
            runRakeTask(mbSrcPath, "resource:generate")
        }

        stage ("resource:list") {
            runRakeTask(mbSrcPath, "resource:list")
        }

        stage ("vagrant:up[$stackName::_all]") {
            runRakeTask(mbSrcPath, "vagrant:up[$stackName::_all]")
        }
       
    } catch(e) {
        echo "Failed to run build: ERROR - $e"
        throw e
     } finally {
     
     }
}

void runMetaboxVagrantStackHaltAll(mbSrcPath) 
{
    // meaning, second from the 'last'
    stackName = env.JOB_NAME.split('/')[-2]

    try {

        stage ("resource:generate") {
            runRakeTask(mbSrcPath, "resource:generate")
        }

        stage ("resource:list") {
            runRakeTask(mbSrcPath, "resource:list")
        }

        stage ("vagrant:halt[$stackName::_all]") {
            runRakeTask(mbSrcPath, "vagrant:halt[$stackName::_all]")
        }
       
    } catch(e) {
        echo "Failed to run build: ERROR - $e"
        throw e
     } finally {
     
     }
}



void runMetaboxVagrantStackVMUp(mbSrcPath) 
{
    // meaning, second from the 'last'
    stackName    = env.JOB_NAME.split('/')[-2]
    resourceName = env.JOB_NAME.split('/').last().split('up-').last()
    
    try {

        stage ("resource:generate") {
            runRakeTask(mbSrcPath, "resource:generate")
        }

        stage ("resource:list") {
            runRakeTask(mbSrcPath, "resource:list")
        }

        stage ("vagrant:up[$stackName::$resourceName]") {
            runRakeTask(mbSrcPath, "vagrant:up[$stackName::$resourceName]")
        }
       
    } catch(e) {
        echo "Failed to run build: ERROR - $e"
        throw e
     } finally {
     
     }
}

return this;