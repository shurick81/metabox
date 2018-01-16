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
    runCmd 'which packer'
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
    
    // empty metabox run
    runCmd "cd $METABOX_SRC_PATH && rake"
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

void runMetaboxPackerBuild(mbSrcPath, String packerFileName = null) {

    resourceName = env.JOB_NAME.split('metabox-packer-')[1]

    if(packerFileName == null) {
        packerFileName = resourceName + ".json";
    }

    try {

        stage ("document:generate") {
            runRakeTask(mbSrcPath, "document:generate")
        }

        stage ("document:list") {
            runRakeTask(mbSrcPath, "document:list")
        }

        stage ("packer:build") {
            runRakeTask(mbSrcPath, "packer:build[${resourceName}]")
        }

        stage ("vagrant:add") {
            runRakeTask(mbSrcPath, "vagrant:add[${resourceName}]")
        }

        stage ("vagrant:list") {
            runCmd("cd $mbSrcPath && rake vagrant:list")
        }

        // stage ("packer:clean") {
        //     //runRakeTask(mbSrcPath, "packer:clean", packerFileName)
        // }
    } catch(e) {
        echo "Failed to run build: ERROR - $e"
        throw e
     } finally {
        echo "Running packer:clean task..."
        //runRakeTask(mbSrcPath, "packer:clean", packerFileName)
    }

}

void runMetaboxVagrantGlobalstatus(mbSrcPath)
{
    runRakeTask(mbSrcPath, "vagrant:globalstatus", "output")
}

return this;