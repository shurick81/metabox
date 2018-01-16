
# fail on errors and include metabox helpers
$ErrorActionPreference = "Stop"
. "c:/Windows/Temp/_metabox_core.ps1"

Log-MbInfoMessage "Installing features required by SharePoint 2016..."	

Import-Module ServerManager 

# http://pcfromdc.blogspot.com.au/2015/08/download-and-install-prerequisites-for.html
$features = @(
    "FileAndStorage-Services"            
    "Storage-Services",                   
    "Web-Server",                         
    "Web-WebServer",                      
    "Web-Common-Http",                    
    "Web-Default-Doc",                    
    "Web-Dir-Browsing",                   
    "Web-Http-Errors",                    
    "Web-Static-Content",                 
    "Web-Health",                         
    "Web-Http-Logging",                   
    "Web-Log-Libraries",                  
    "Web-Request-Monitor",                
    "Web-Http-Tracing",                   
    "Web-Performance",                    
    "Web-Stat-Compression",               
    "Web-Dyn-Compression",     
    "Web-Security",
    "Web-Filtering",
    "Web-Basic-Auth",
    "Web-Client-Auth",
    "Web-Digest-Auth",
    "Web-Cert-Auth",
    "Web-IP-Security",
    "Web-Url-Auth",
    "Web-Windows-Auth",                
    "Web-App-Dev",                        
    "Web-Net-Ext",                        
    "Web-Net-Ext45",                      
    "Web-Asp-Net",                        
    "Web-Asp-Net45",                      
    "Web-ISAPI-Ext",                      
    "Web-ISAPI-Filter",                   
    "Web-Mgmt-Tools",                     
    "Web-Mgmt-Console",                   
    "Web-Mgmt-Compat",                    
    "Web-Metabase",                       
    "Web-Lgcy-Scripting",                 
    "Web-WMI",                            
    "NET-Framework-Features",            
    "NET-Framework-Core",                 
    "NET-HTTP-Activation",                
    "NET-Non-HTTP-Activ",                 
    "NET-Framework-45-Features",          
    "NET-Framework-45-Core",              
    "NET-Framework-45-ASPNET",            
    "NET-WCF-Services45",                 
    "NET-WCF-HTTP-Activation45",          
    "NET-WCF-Pipe-Activation45",          
    "NET-WCF-TCP-PortSharing45",                   
    "Server-Media-Foundation",            
    "FS-SMB1",                     
    "Windows-Identity-Foundation",        
    "PowerShellRoot",                     
    "PowerShell",                         
    "PowerShell-V2",                      
    "PowerShell-ISE",                     
    "WAS",                                
    "WAS-Process-Model",                  
    "WAS-NET-Environment",                
    "WAS-Config-APIs",                   
    "WoW64-Support",                      
    "XPS-Viewer"
)

foreach($feature in $features) {
    Log-MbInfoMessage "`tadding feature: $feature"	
    Add-WindowsFeature $feature
}