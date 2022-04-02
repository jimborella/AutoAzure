# AutoAzure
Scripts that can automate different work flows or bulk actions needed within AzureAD and Azure Resources

<b>Instant Linux VM</b>
  <br>
  Deploys an Azure Virtual Machine to a given Resource Group, in a Subcription.
  <br>
  <ul>
    <li>This script was designed to be used with an App Regstration in Azure AD, acting as a Service Principal.</li>
    <li>Automaticly SSH's into the VM, when VM is provisioned and booted with a Public IP. Keys are saved in the current user's /.ssh/ folder.</li>
    <li>VM image can be configured in the Script's Parameters.</li>
    <li>Automatically finds a VM size in the RG's region. Size choosen will be the closest to the provided charateristics (vCPUs, RAM Amount)</li>
    <li>Script only supports Linux VMs</li>
    <li>Network resources (vNET, SubNTs, Etc) are auto-generated, and can't be configured.</li>
  </ul>
