import jenkins.*
import jenkins.model.*
import hudson.*
import hudson.model.*
import hudson.security.*
import com.cloudbees.hudson.plugins.folder.*;
import com.cloudbees.hudson.plugins.folder.properties.*;
import org.jenkinsci.plugins.workflow.job.WorkflowJob

import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.plugins.git.GitSCM
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition

import groovy.io.FileType

def defaultPipelineFolderPath() {
    return "/vagrant/scripts/vagrant/centos7-mb-jenkins2/pipelines"
} 

def log(msg) {
   println "\u001B[32mMETABOX: pipeline import: ${msg}\u001B[0m"
}

def getPipelineFolderPath() {

    def env = System.getenv()
    def result = env['METABOX_PIPELINES_FOLDER']

    if(result == null) {
        log "using default pipeline folder path: ${defaultPipelineFolderPath()}"
        result = defaultPipelineFolderPath()
    } else {
        log "using custom pipeline folder path from ENV var 'METABOX_PIPELINES_FOLDER': ${defaultPipelineFolderPath}"
    }
   
    return result
}

def getPipelineFiles() {

    log "fetching pipeline files..."

    def result = []
    def pipelineFolderPath = getPipelineFolderPath()

    def dir = new File(pipelineFolderPath)
    dir.eachFileRecurse (FileType.FILES) { file ->
        if(file.name.endsWith('.groovy')) {
            result << file
        }
    }

    return result
}

def getOrCreateNewProject(parentFolder, name, script) {
    log "creating new pipeline with name: ${name}"

    def result = null
    
    if (parentFolder == null)
    {
        parentFolder = Jenkins.instance
    }

    parentFolder.getItems().each {it ->
        if(it.fullName.endsWith(name)) {
            result = it
        }
    }
  
    if(result == null) {
        if( parentFolder == null) {
            result = Jenkins.instance.createProject(WorkflowJob, name)
        } else {
            result = parentFolder.createProject(WorkflowJob, name)
        }
    }
    
    def flow = new CpsFlowDefinition(script, true)
    result.definition = flow
    
    return result
}

def findFolder(parentFolder, name) {
    def result = null
    
    parentFolder.getItems().each {it ->
        if(it.fullName.endsWith(name)) {
            result = it
        }
    }

    return result
}

def getOrCreateNewFolder(parentFolder, name) {

    if(parentFolder == null) {
        def existing = findFolder(Jenkins.instance, name)

        if(existing != null)
        {
            log "   - folder exists: ${name}"
            return existing
        }

        log "   - creating new folder: ${name}"
        return Jenkins.instance.createProject(Folder, name)
    } else {

        def existing = findFolder(parentFolder, name)

        if(existing != null)
        {
            log "   - folder exists: ${name}"
            return existing
        }

        log "   - creating new folder: ${name}"
        return parentFolder.createProject(Folder, name)
    }
    
}

def importPipelineFile(relativeFilePath, fileContent)
{
    log "importing file: ${relativeFilePath}"
    def folders = relativeFilePath.split('/')
    
    Folder folder = null

    folders.each { name ->
        if( name != '') {
            log "Prossing path: ${name}"

            if (!name.contains('.groovy')) {
                log "   - folder: ${name}"
                folder = getOrCreateNewFolder(folder, name)   
            } else {
                def fileName = name.take(name.lastIndexOf('.'))

                log "   - pipeline: ${fileName}"
                getOrCreateNewProject(folder, fileName, fileContent) 
            }
        }  
    }    
}

def importPipelines(files) {

    def pipelinesFolder = getPipelineFolderPath()

    files.each { file ->
        def fileContent = new File(file.path).text
        def fileName = file.name.take(file.name.lastIndexOf('.'))

        def relativePath = file.path.replace(pipelinesFolder, '')

        importPipelineFile(relativePath, fileContent)
    }
}

log "tricking the system!"
println ACL.impersonate(User.get("METABOX").impersonate())

log "importing pipelines..."
def pipelineFiles = getPipelineFiles()
importPipelines(pipelineFiles)

log "importing pipelines completed!"
