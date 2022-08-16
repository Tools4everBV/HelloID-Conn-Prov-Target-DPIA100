#Initialize default properties
$p = $person | ConvertFrom-Json
$success = $False;
$auditMessage = "for person " + $p.DisplayName
$config = $configuration | ConvertFrom-Json

#Change mapping here
$account = [PSCustomObject]@{
    externalId = $p.ExternalId
    mail = $p.Accounts.MicrosoftActiveDirectory.mail
}

#Default variables for export
$user = $config.dpia100.creatiegebruiker
$path = $config.dpia100.path
$prefix = $config.dpia100.fileprefix
$personFileMode = [System.Convert]::ToBoolean($config.dpia100.personfile)
$stam = $config.dpia100.stam
$processcode = $config.dpia100.procescode

if ($personFileMode) {
    $suffix = $account.externalId
} else {
    $suffix = Get-Date -Format ddMMyyy
}
$outFile = $path + "\" + $prefix + $suffix + ".txt"

$currentDate = Get-Date -Format ddMMyyyy
$productionTypeDate = Get-Date -Format MMyyyy

#Building fixed length fields
$processcode = "$processcode $(" " * 3)".Substring(0,3)
$indication= "$stam $(" " * 1)".Substring(0,1) # V for Variable S for Stam
$exportDate = "$currentDate $(" " * 11)".Substring(0,11)
$startDate = "$currentDate $(" " * 11)".Substring(0,11)
$creationUser = "$user $(" " * 16)".Substring(0,16)
$productionType = "NOR$productionTypeDate $(" " * 9)".Substring(0,9)
$spaces = "$(" " * 30)".Substring(0,30)

#Input Variables from HelloID
$objectId = "$($account.externalId) $(" " * 50)".Substring(0,50)
$rubrieksCode = "P01035 $(" " * 6)".Substring(0,6)
$value = "$($account.mail) $(" " * 50)".Substring(0,50)

$output = "$processcode" + "$rubriekscode" + "$objectId" + "$indication" + "$exportDate" + "$creationUser" + "$value" + "$startDate" + "$spaces" + "$productionType"

if(-Not($dryRun -eq $True)) {
    #Export DPIA100
    Try{
        if ($personFileMode) {
            Write-Output $output | Out-File $OutFile -Encoding ascii
        } else {
            Write-Output $output | Out-File $OutFile -Encoding ascii -Append
        }
        $success = $True
        $auditMessage = "for person " + $p.DisplayName + " DPIA100 successfully to $outFile"
    }
    Catch{
        $auditMessage = "for person " + $p.DisplayName + " DPIA100 failed to $outFile $_"
    }
} else {
    Write-Verbose -Verbose "Dry mode: $output"
}


#build up result
$result = [PSCustomObject]@{ 
	Success = $success
	AccountReference = $account.externalId
	AuditDetails = $auditMessage
    Account = $account

    # Optionally return data for use in other systems
    ExportData = [PSCustomObject]@{}
};

#send result back
Write-Output $result | ConvertTo-Json -Depth 10
