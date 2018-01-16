Describe 'Domain Controller' {

    Context "Domain membership" {
       
        It 'Should be part of domain' {
            (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain `
                | Should Be $true
        }

    }
    
}
