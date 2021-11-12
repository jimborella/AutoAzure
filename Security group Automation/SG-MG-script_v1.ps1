## SG-MG script #### V1 ##############################################################################
######################################################################################################
# By James Immer #####################################################################################
# Assoicate Consulting Engineer - CDW ################################################################

    #connects to Azure tenant
        Write-Host 'Connecting to Azure'
        Connect-AzAccount 
        $auth_token = Get-AzContext
        Connect-AzureAD -TenantId $auth_token.Tenant.TenantId -AccountId $auth_token.Account.Id

    #gets Management Groups, Stores in Array $MgGp
    write-host 'Getting Management Groups'
    $MgGp = Get-AzManagementGroup


    #creates 3 Security Groups & assigns to Management Groups
    foreach($name in $MgGp.name){

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

        #attach SGs to Management Group
            
            #wait for Security group propigation
            write-host '20 Second Wait for SG prop'
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
    }