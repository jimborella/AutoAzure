# Azure AD User Audit 
# 
# By James Immer | Associate Consulting Engineer | CDW - 4/1/2022
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# [Notes]
# - Evaluates user for:
#   - Recent Sign-ins
#   - If Account is Enabled
#   - If Account has Licenses
#   - If Account has a MailBox
# - Recommends Account Removal based on above criteria
#
# # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# [Parameters]
#
# Tenant-ID
$TNT_ID = "<Tenant-ID>"
#
# Output Directory
$output = ".\useraudit.csv"
#
# Verbose Console Output
$verbose = $true
#
# # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# [Validation]
# Module Validation - Azure AD Preview
if ($null -eq (get-command -Module azureadpreview)) { Write-Error -Message "Azure AD Preview Module not Loaded into Powershell. Please run 'Import-module Azureadpreview', and reload Powershell"; exit }
# [Prep]
# Connection to Azure AD
Connect-AzureAD -TenantId $TNT_ID
#Timetrack
$time_track = (get-date).timeofday
# Generate table
$table_object = new-object system.data.datatable 'User Analysis'
$table_headers = 'Name', 'UPN' , 'Enabled', 'Signins', 'Licenses', 'Mailbox', 'Source', 'RecommendRemove'
foreach ($column in $table_headers) {
    $column_name = new-object system.data.datacolumn $column
    $table_object.Columns.Add($column_name)
}
# User Count
$count = 0
# [Main Loop]
# Recursive loop | Filters out Guest Users and Sync Service Principals
foreach ($user in (get-azureaduser -all $true | where-object { ($_.usertype -notmatch "Guest") -and ($_.DisplayName -notmatch "On-Premises Directory Synchronization Service Account") } )) {
    # User Count
    $count += 1
    # Creates Row Object
    $new_row = $table_object.newrow()
    if ($verbose -eq $true) { write-host $user.DisplayName $count }
    # Injects User name into table
    $new_row.Name = $user.DisplayName
    $new_row.UPN = $user.UserPrincipalName
    # Gets user Signins (from past 30 days)
    $signins = Get-AzureADAuditSignInLogs -filter ("UserPrincipalName eq '" + $user.UserPrincipalName + "'")
    if ($null -ne ($signins)) { $new_row.Signins = (($signins | select-object -first 1).CreatedDateTime) }
    else { $new_row.Signins = $false }
    # Gets user Licenses
    $licensePlanList = Get-AzureADSubscribedSku
    $user_licenses = $user | select-object -ExpandProperty AssignedLicenses | select-object SkuID | ForEach-object { $licensePlanList }
    if ($null -ne $user_licenses) { $new_row.Licenses = $true }
    else { $new_row.Licenses = $false }   
    # Gets user mailboxes
    if ($null -ne ($user.mail)) { $new_row.Mailbox = $true }
    else { $new_row.Mailbox = $false } 
    # gets user source
    if (($user.dirsyncenabled) -eq $true ) { $new_row.source = "Sync" }
    else { $new_row.source = "Cloud" }
    # User Accont enabled
    $new_row.enabled = ($user.accountenabled)
    # Recommend Remove of user
    if (($new_row.Signins -eq $false) -and ($new_row.Licenses -eq $false) -and ($new_row.Mailbox -eq $false)) { $new_row.RecommendRemove = $true }
    else { $new_row.RecommendRemove = $false }
    # Compile object
    $table_object.Rows.Add($new_row)
    #Anti-throttle - per User
    start-sleep -Seconds 1
    #Extra Anti-throttle - User Count over 150
    if (($count % 150) -eq 0) { if ($verbose -eq $true) { write-host "Anti-Throttle 30 Second Sleep" } ; start-sleep -Seconds 30 }
}
# [Output]
# Generate CSV
$table_object | export-csv -Path $output -NoTypeInformation
# user table output to console
if ($verbose -eq $true) { 
    if ($count -gt 50) { Write-Host "Too many users to display to console" }
    else { $table_object }
}
# Time track 2 - electric boogaloo
$time_track = (get-date).timeofday - $time_track
# Final Output
if ($verbose -eq $true) { write-host "Users Analyzed:" $count }
Write-Host "Completed in "$time_track.Hours" Hours, "$time_track.Minutes" Minutes, "$time_track.Seconds" Seconds"
Write-Host "Output Exported to" $output
