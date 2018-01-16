$ProgressPreference="SilentlyContinue"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

@('c:\unattend.xml', 'c:\windows\panther\unattend\unattend.xml', 'c:\windows\panther\unattend.xml', 'c:\windows\system32\sysprep\unattend.xml') | %{
	if (test-path $_){
		write-host "Removing $($_)"
		remove-item $_ > $null
	}	
}

if (!(test-path 'c:\windows\panther\unattend')) {
	write-host "Creating directory $($_)"
    New-Item -path 'c:\windows\panther\unattend' -type directory > $null
}

if (Test-Path 'a:\Autounattend_sysprep.xml'){
	write-host "Copying a:\Autounattend_sysprep.xml to c:\windows\panther\unattend\unattend.xml"
	Copy-Item 'a:\Autounattend_sysprep.xml' 'c:\windows\panther\unattend\unattend.xml' > $null
} elseif (Test-Path 'c:\Autounattend_sysprep.xml'){
	write-host "Copying c:\Autounattend_sysprep.xml to c:\windows\panther\unattend\unattend.xml"
	Copy-Item 'c:\Autounattend_sysprep.xml' 'c:\windows\panther\unattend\unattend.xml' > $null
} elseif (Test-Path 'e:\Autounattend_sysprep.xml'){
	write-host "Copying e:\Autounattend_sysprep.xml to c:\windows\panther\unattend\unattend.xml"
	Copy-Item 'e:\Autounattend_sysprep.xml' 'c:\windows\panther\unattend\unattend.xml' > $null
} else {
	write-host "Copying f:\Autounattend_sysprep.xml to c:\windows\panther\unattend\unattend.xml"
	Copy-Item 'f:\Autounattend_sysprep.xml' 'c:\windows\panther\unattend\unattend.xml'> $null
}

&c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /mode:vm /quiet /quit /unattend:c:\windows\panther\unattend\unattend.xml

Write-Host "sysprep exit code was $LASTEXITCODE"

write-host "Running shutdown"
&shutdown -s
Write-Host "shutdown exit code was $LASTEXITCODE"

write-host "Return exit 0"
exit 0 