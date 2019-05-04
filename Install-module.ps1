$Modules = @('xPSDesiredStateConfiguration', 'xNetworking', 'StorageDsc', 'ComputerManagementDsc')
foreach ($Module in $Modules) {
    if (!(Get-Module $Module)) {
        Install-Module -Verbose $Module -Force
    }
}