## SG-MG script #### V3 ##############################################################################
######################################################################################################
# By James Immer #####################################################################################
# Assoicate Consulting Engineer - CDW ##### 11/12/2021 ###############################################

#Settings
$tenant_id = #<'Tenant-ID'>
$Groups_for_ManGrps = #<$true or $false>
$Groups_for_subs = #<$true or $false>

    #connects to Azure tenant
        Write-Host 'Connecting to Azure'
        Connect-AzAccount -Tenant $tenant_id
        $auth_token = Get-AzContext
        Connect-AzureAD -TenantId $auth_token.Tenant.TenantId -AccountId $auth_token.Account.Id    
    
    #Adding Security groups to Management Groups
    if($Groups_for_ManGrps -eq $true){

        #gets Management Groups, Stores in Array $MgGp
        write-host 'Getting Management Groups'
        $MgGp = Get-AzManagementGroup


        #creates 3 Security Groups & assigns to Management Groups
        foreach($name in $MgGp.name){
            
            #root MG adjustment
                if($name -eq $tenant_id){
                    #create Security groups for Tenant Root
                    #Owner group
                    write-host 'Creating Owner Group'
                    $owner_name = 'SG-TenantRoot-Owner'
                    $Owner_group = New-AzureADGroup -DisplayName $owner_name -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        
                    #Contributor Group
                    write-host 'Creating Contributor Group'
                    $contr_name = 'SG-TenantRoot-Contributor'
                    $contr_group = New-AzureADGroup -DisplayName $contr_name -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"

                    #Reader group
                    write-host 'Creating Reader Group'
                    $readr_name = 'SG-TenantRoot-Reader'
                    $readr_group = New-AzureADGroup -DisplayName $readr_name -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
                }else{
                    #create Security groups for all other MGs
                    #Owner group
                    write-host 'Creating Owner Group'
                    $owner_name = 'SG-'+$name+'-Owner'
                    $Owner_group = New-AzureADGroup -DisplayName $owner_name -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        
                    #Contributor Group
                    write-host 'Creating Contributor Group'
                    $contr_name = 'SG-'+$name+'-Contributor'
                    $contr_group = New-AzureADGroup -DisplayName $contr_name -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"

                    #Reader group
                    write-host 'Creating Reader Group'
                    $readr_name = 'SG-'+$name+'-Reader'
                    $readr_group = New-AzureADGroup -DisplayName $readr_name -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
                }

            #attach SGs to Management Group
            
                #wait for Security group propagation
                write-host 'Waiting for Securiy Group Propagation within AzureAD'
                Start-Sleep -Seconds 20

                #create scope path
                $MG_scope = ('/providers/Microsoft.Management/managementGroups/'+$name)

                    #Owner
                    write-host 'Assigning' $owner_group.displayname 'to' $name
                    New-AzRoleAssignment -ObjectId $Owner_group.objectid -RoleDefinitionName Owner -scope $MG_scope
                    #Contr
                    write-host 'Assigning' $contr_group.displayname 'to' $name
                    New-AzRoleAssignment -ObjectId $contr_group.objectid -RoleDefinitionName Contributor -scope $MG_scope
                    #Readr
                    write-host 'Assigning' $readr_group.displayname 'to' $name
                    New-AzRoleAssignment -ObjectId $readr_group.objectid -RoleDefinitionName Reader -scope $MG_scope

                    #clear varibles
                    Clear-Variable -name 'readr*','contr*','Owner*'
    }}else{
    Write-Host -ForegroundColor Red 'Security Group assignment for Management Groups is set to be skipped.'
    Write-Host -ForegroundColor Red 'If this is a mistake, re-run the script with $Groups_for_ManGrps = $true.'
    }


    #Adding Security groups to Subscribtions
    if($Groups_for_subs -eq $true){

        #gets Management Groups, Stores in Array $MgGp
        write-host 'Getting Subscribtions'
        $subs = Get-AzSubscription -TenantId $tenant_id


        #creates 3 Security Groups & assigns to Management Groups
        foreach($name in $subs.name){

            #create Security groups
                #Owner group
                write-host 'Creating Owner Group'
                $owner_name = 'SG-'+$name+'-Owner'
                $Owner_group = New-AzureADGroup -DisplayName $owner_name -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
        
                #Contributor Group
                write-host 'Creating Contributor Group'
                $contr_name = 'SG-'+$name+'-Contributor'
                $contr_group = New-AzureADGroup -DisplayName $contr_name -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"

                #Reader group
                write-host 'Creating Reader Group'
                $readr_name = 'SG-'+$name+'-Reader'
                $readr_group = New-AzureADGroup -DisplayName $readr_name -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"

            #attach SGs to Subscriptions
            
                #wait for Security group propagation
                write-host 'Waiting for Securiy Group Propagation within AzureAD'
                Start-Sleep -Seconds 20

                #create scope path
                    #get sub ID from Sub name
                    $sub_id = Get-AzSubscription -SubscriptionName $name -TenantId $tenant_id
                    #create Scope from $Sub_id.id
                    $Sub_scope = ('/subscriptions/'+$sub_id)

                    #Owner
                    write-host 'Assigning' $owner_group.displayname 'to' $name
                    New-AzRoleAssignment -ObjectId $Owner_group.objectid -RoleDefinitionName Owner -scope $Sub_scope
                    #Contr
                    write-host 'Assigning' $contr_group.displayname 'to' $name
                    New-AzRoleAssignment -ObjectId $contr_group.objectid -RoleDefinitionName Contributor -scope $Sub_scope
                    #Readr
                    write-host 'Assigning' $readr_group.displayname 'to' $name
                    New-AzRoleAssignment -ObjectId $readr_group.objectid -RoleDefinitionName Reader -scope $Sub_scope

                    #clear varibles
                    Clear-Variable -name 'readr*','contr*','Owner*'
    }}else{
    Write-Host -ForegroundColor Red 'Security Group assignment for Subscribtions is set to be skipped.'
    Write-Host -ForegroundColor Red 'If this is a mistake, re-run the script with $Groups_for_subs = $true.'
    }

#end
Write-host -foreground Green 'Script Complete'