
#Initialize default properties
$p = $person | ConvertFrom-Json;
$m = $manager | ConvertFrom-Json;
$aRef = $accountReference | ConvertFrom-Json;
$mRef = $managerAccountReference | ConvertFrom-Json;
$success = $False;
$auditMessage = $p.DisplayName;

#Change mapping here
$account = [PSCustomObject]@{
}

#Default variables for export
$User = "<Beaufort user>"
$CurrentDate = Get-Date -Format ddMMyyyy
$DatForFile = Get-Date -Format ddMMyyy_Hmm
$OutFile = "C:\DPIA100_Export_HelloID\dpia100_siza_helloid_" + $DatForFile + ".txt"

#Building fixed length fields
$Processcode = "IMP $(" " * 3)".Substring(0,3)
$Indication= "V $(" " * 1)".Substring(0,1) # V for Variable S for Stam
$ExportDate = "$CurrentDate $(" " * 11)".Substring(0,11)
$StartDate = "$CurrentDate $(" " * 11)".Substring(0,11)
$creationUser = "$User $(" " * 16)".Substring(0,16)


#Input Variables from HelloID
$userExternalID = $p.externalId
$userMail = $p.Accounts.MicrosoftAzureADSizanl.mail
$Object_id = "$userExternalID $(" " * 50)".Substring(0,50)
$Rubriekscode = "P01035 $(" " * 6)".Substring(0,6)
$Value = "$userMail $(" " * 50)".Substring(0,50) 

if(-Not($dryRun -eq $False)) {
    #Export DPIA100
    Try{
        $output = "$Processcode" + "$Rubriekscode" + "$Object_id" + "$Indication" + "$ExportDate" + "$creationUser" + "$Value" + "$StartDate"
        Write-Output $output | Out-File $OutFile;    
        $success = $True;
        $auditMessage = "for person " + $p.DisplayName + " DPIA100 successfully";   
    }
    Catch{
        $auditMessage = "for person " + $p.DisplayName + " DPIA100 failed";
    }
}

#build up result
$result = [PSCustomObject]@{ 
	Success= $success;
	AuditDetails=$auditMessage;
    AccountReference= $aRef;
    Account = $account;
    
    # Optionally update the data for use in other systems
    ExportData = [PSCustomObject]@{
        displayName = $account.DisplayName;
        userName = $account.UserName;
    };
};

Write-Output $result | ConvertTo-Json -Depth 10;
