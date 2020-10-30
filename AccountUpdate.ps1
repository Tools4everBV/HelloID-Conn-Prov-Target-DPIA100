
#Initialize default properties
$p = $person | ConvertFrom-Json;
$m = $manager | ConvertFrom-Json;
$success = $False;
$auditMessage = "for person " + $p.DisplayName;

$account_guid = $p.Accounts.MicrosoftAzureADSizanl.userPrincipalName

#Change mapping here
$account = [PSCustomObject]@{
}

#Default variables for export
$User = "<Beaufort user>"
$CurrentDate = Get-Date -Format ddMMyyyy
$DatForFile = Get-Date -Format ddMMyyy
$ProductionTypeDate = Get-Date -Format MMyyyy
$OutFile = "C:\DPIA100_Export_HelloID\dpia100_siza_helloid_" + $DatForFile + ".txt"

#Building fixed length fields
$Processcode = "IMP $(" " * 3)".Substring(0,3)
$Indication= "V $(" " * 1)".Substring(0,1) # V for Variable S for Stam
$ExportDate = "$CurrentDate $(" " * 11)".Substring(0,11)
$StartDate = "$CurrentDate $(" " * 11)".Substring(0,11)
$creationUser = "$User $(" " * 16)".Substring(0,16)
$ProductionType = "NOR$ProductionTypeDate $(" " * 9)".Substring(0,9)
$Spaces = "$(" " * 30)".Substring(0,30)

#Input Variables from HelloID
$userExternalID = $p.externalId
$userMail = $p.Accounts.MicrosoftAzureADSizanl.mail
$Object_id = "$userExternalID $(" " * 50)".Substring(0,50)
$Rubriekscode = "P01035 $(" " * 6)".Substring(0,6)
$Value = "$userMail $(" " * 50)".Substring(0,50) 

if(-Not($dryRun -eq $True)) {
    #Export DPIA100
    Try{
        $output = "$Processcode" + "$Rubriekscode" + "$Object_id" + "$Indication" + "$ExportDate" + "$creationUser" + "$Value" + "$StartDate" + "$Spaces" + "$ProductionType"
        Write-Output $output | Out-File $OutFile -Encoding ascii -Append;    
        $success = $True;
        $auditMessage = "for person " + $p.DisplayName + " DPIA100 successfully ";   
    }
    Catch{
        $auditMessage = "for person " + $p.DisplayName + " DPIA100 failed";
    }
}

#build up result
$result = [PSCustomObject]@{ 
	Success= $success;
	AccountReference= $account_guid;
	AuditDetails=$auditMessage;
    Account = $account;

    # Optionally return data for use in other systems
    ExportData = [PSCustomObject]@{
        displayName = $account.DisplayName;
        userName = $account.UserName;
        externalId = $account_guid;
    };
};

#send result back
Write-Output $result | ConvertTo-Json -Depth 10