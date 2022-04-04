# AutoAzure
Scripts that can automate different work flows or bulk actions needed within AzureAD and Azure Resources

<b>Instant Linux VM 3/4/2022</b>
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
  
  <b>User Audit 4/1/2022</b>
  <br>
  Audits all "Memeber" users in an Azure AD Tenant, outputs findings and recommendations to a .CSV file.
  <br>
  <ul>
    <li>This Sctipt Evaluates for:</li>
      <ul>
        <li>Recent Sign-ins</li>
        <li>If Account is Enabled</li>
        <li>If Account has Licenses</li>
        <li>If Account has a MailBox</li>
      </ul>
    <li>Recommends Account Removal based on above criteria.</li>
    <li>Currently only analyzes a single tenant, per run.</li>
    <li>Configurable .CSV file output directory.</li>
    <li>Optional Verbose Logging to Console.</li>
    <li>Counts users evalutes, and Time taken to complete the analysis.</li>
  </ul>
