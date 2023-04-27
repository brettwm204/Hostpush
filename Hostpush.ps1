#This tool is to help push hostfile to designated system
$date = get-date -format MM-dd-yyyy
$logfile = ".\robocopy-$date.log"
$rootfolder = "ScriptDIR"
$scriptrunner = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[-1]
$admingroup = "SGNamehere"
$validateaccess = Get-ADGroupMember -Identity $admingroup | Where samaccountname -eq $scriptrunner


function Check-Access {
    
    if ($validateaccess -eq $null){
        No-access
        }else{
        check-host
        }
}

function Check-host {
cls
$computername = read-host -prompt "Computername or IP (No spaces / add FQDN for non-dva systems)"
if(test-connection $computername -count 2 -erroraction SilentlyContinue) {Install-Hostfile
}else{
cls
Write-Host "Unable to ping system" -ForegroundColor Red | Pause | Check-host}
}


Function install-hostfile {
    cls
    Write-host "$computername is online pushing hostfile now"
    robocopy "$rootdir" "\\$computername\c$\windows\system32\drivers\etc" hosts /LOG+:"$logfile" /R:0
    cls
    Write-host "If there was any errors on $computername check $logfile"
$question = 'Do you want to push the Host file to another system?'

$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
    check-host
} else {
    exit
}

}

Function No-Access {
    Write-host "You do not have access to this application contact Brett Martin II"
    Read-host -prompt "Press any key to exit"
    Exit
}

check-access