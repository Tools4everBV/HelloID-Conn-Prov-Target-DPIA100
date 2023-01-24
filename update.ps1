#####################################################
# HelloID-Conn-Prov-Target-Raet-DPIA100-Update
#
# Version: 1.1.0
#####################################################
# Initialize default values
$c = $configuration | ConvertFrom-Json
$p = $person | ConvertFrom-Json
$aRef = $AccountReference | ConvertFrom-Json
$success = $false # Set to false at start, at the end, only when no error occurs it is set to true
$auditLogs = [System.Collections.Generic.List[PSCustomObject]]::new()

# Set debug logging
switch ($($c.isDebug)) {
    $true { $VerbosePreference = 'Continue' }
    $false { $VerbosePreference = 'SilentlyContinue' }
}
$InformationPreference = "Continue"
$WarningPreference = "Continue"

# used to define for export file
$useSingleFilePerPerson = [System.Convert]::ToBoolean($c.useSingleFilePerPerson)
$filePath = $c.filePath
$filenamePrefix = $c.filenamePrefix
$updateUser = $c.updateUser
$processCode = $c.processCode
$indication = $c.indication

#region Change mapping here
$currentDate = Get-Date

if ($useSingleFilePerPerson -eq $true) {
    $fileName = "$($filenamePrefix)" + "$($p.ExternalId)" + ".txt"
}
else {
    $fileName = "$($filenamePrefix)" + "$($currentDate.toString("yyyyMMdd"))" + ".txt"
}

$account = [PSCustomObject]@{
    'objectId'   = $p.ExternalId
    'filePath'   = "$($filePath)\$($fileName)"
    'properties' = [PSCustomObject]@{
        # Business Email address
        'P01035' = $p.Accounts.MicrosoftActiveDirectory.mail
        # Login name
        'E02544' = $p.Accounts.MicrosoftActiveDirectory.samAccountName
        # Identity (for Youforce SSO)
        'E02850' = $p.Accounts.MicrosoftActiveDirectory.userPrincipalName
    }
}

$currentAccount = [PSCustomObject]@{
    'properties' = [PSCustomObject]@{
        # Business Email address
        'P01035' = $p.Contact.Business.Email
        # Login name
        'E02544' = $account.properties.E02544 # Not possible to check on current value as this is not in the source data
        # Identity (for Youforce SSO)
        'E02850' = $account.properties.E02850 # Not possible to check on current value as this is not in the source data
    }
}
#endregion Change mapping here

# Troubleshooting
# $account = [PSCustomObject]@{
#     'objectId'   = '12345678'
#     'filePath'   = "$($filePath)\$($fileName)"
#     'properties' = [PSCustomObject]@{
#         # Business Email address
#         'P01035' = 'john.doe@enyoi.nl'
#         # Login name
#         'E02544' = 'j.doe'
#         # Identity (for Youforce SSO)
#         'E02850' = '12345678@enyoi.nl'
#     }
# }

# $currentAccount = [PSCustomObject]@{
#     'properties' = [PSCustomObject]@{
#         # Business Email address
#         'P01035' = 'j.doe@enyoi.nl'
#         # Login name
#         'E02544' = $account.properties.E02544 # Not possible to check on current value as this is not in the source data
#         # Identity (for Youforce SSO)
#         'E02850' = $account.properties.E02850 # Not possible to check on current value as this is not in the source data
#     }
# }

# $dryRun = $false

try {
    # Verify if update action required
    $splatCompareProperties = @{
        ReferenceObject  = @($currentAccount.properties.PSObject.Properties)
        DifferenceObject = @($account.properties.PSObject.Properties)
    }
    $propertiesChanged = (Compare-Object @splatCompareProperties -PassThru).Where( { $_.SideIndicator -eq '=>' })

    if ($propertiesChanged) {
        Write-Verbose "Update required, properties changed: [$($propertiesChanged.name -join ",")]"

        # Build fixed length fields
        $processCode = "$processCode $(" " * 3)".Substring(0, 3)
        $objectId = "$($account.objectId) $(" " * 50)".Substring(0, 50)
        $indication = "$indication $(" " * 1)".Substring(0, 1) # V for Variable S for Stam
        $exportDate = "$($currentDate.toString("ddMMyyyy")) $(" " * 11)".Substring(0, 11)
        $startDate = "$($currentDate.toString("ddMMyyyy")) $(" " * 11)".Substring(0, 11)
        $creationUser = "$updateUser $(" " * 16)".Substring(0, 16)
        $productionType = "NOR$($currentDate.toString("MMyyyy")) $(" " * 9)".Substring(0, 9)
        $spaces = "$(" " * 30)".Substring(0, 30)

        # Export data to file
        try {
            foreach ($property in $account.properties.PSObject.Properties) {
                if (-Not($dryRun -eq $True)) {
                    $rubrieksCode = "$($property.Name) $(" " * 6)".Substring(0, 6)
                    $value = "$($property.Value) $(" " * 50)".Substring(0, 50)

                    $fileContent = "$processcode" + "$rubriekscode" + "$objectId" + "$indication" + "$exportDate" + "$creationUser" + "$value" + "$startDate" + "$spaces" + "$productionType"

                    Write-Verbose "Exporting rubriek '$($rubrieksCode)' to DPIA100 file '$($account.filePath)'. File content: $($fileContent|ConvertTo-Json)"

                    $fileContent | Out-File -FilePath $account.filePath -Encoding UTF8 -Force -Confirm:$false -Append

                    $auditLogs.Add([PSCustomObject]@{
                            Message = "Successfully exported rubriek '$($rubrieksCode)' to DPIA100 file '$($account.filePath)'"
                            IsError = $false
                        })
                }
                else {
                    Write-Warning "DryRun: Would export rubriek '$($rubrieksCode)' to DPIA100 file '$($account.filePath)'. File content: $($fileContent|ConvertTo-Json)"
                }
            }
        }
        catch {
            # Clean up error variables
            $verboseErrorMessage = $null
            $auditErrorMessage = $null

            $ex = $PSItem
            # If error message empty, fall back on $ex.Exception.Message
            if ([String]::IsNullOrEmpty($verboseErrorMessage)) {
                $verboseErrorMessage = $ex.Exception.Message
            }
            if ([String]::IsNullOrEmpty($auditErrorMessage)) {
                $auditErrorMessage = $ex.Exception.Message
            }

            Write-Verbose "Error at Line '$($ex.InvocationInfo.ScriptLineNumber)': $($ex.InvocationInfo.Line). Error: $($verboseErrorMessage)"

            $auditLogs.Add([PSCustomObject]@{
                    Message = "Error exporting rubriek '$($rubrieksCode)' to DPIA100 file '$($account.filePath)'. File content: $($fileContent|ConvertTo-Json). Error Message: $auditErrorMessage"
                    IsError = $True
                })
        }
    }
    else {
        # No action required
    }
}
finally {
    # Check if auditLogs contains errors, if no errors are found, set success to true
    if (-NOT($auditLogs.IsError -contains $true)) {
        $success = $true
    }

    # Dynamically build ExportDate based on defined properties
    $exportData = [PSCustomObject]::new()
    foreach ($property in $account.properties.PSObject.Properties) {
        $exportData | Add-Member -MemberType NoteProperty -Name "$($property.Name)" -Value "$($property.Value)" -Force
    }

    # Send results
    $result = [PSCustomObject]@{
        Success          = $success
        AccountReference = $aRef
        AuditLogs        = $auditLogs
        Account          = $account

        # Optionally return data for use in other systems
        ExportData       = $exportData
    }

    Write-Output ($result | ConvertTo-Json -Depth 10)
}