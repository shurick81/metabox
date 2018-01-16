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

&c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /mode:vm /quiet /quit 

Write-Host "sysprep exit code was $LASTEXITCODE"

write-host "Running shutdown"
&shutdown -s
Write-Host "shutdown exit code was $LASTEXITCODE"

write-host "Return exit 0"
exit 0 