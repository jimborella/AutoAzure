# AutoAzure
Scripts that can automate different work flows or bulk actions needed within AzureAD and Azure Resources

<b>Security group Automation</b>
  A script that will create 3 security groups, per management Group, and Subscription the operating user has access to.
  <ul>
    <li>the 3 groups created per resource will have Owner, Contributor, Reader RBAC roles, have be named accordingly.</li>
    <li>Recommeneded to Run as a Global Admin with the Owner RBAC role on the Tenant Root level.</li>
    <li>Must run in PowerShell for interactive signon, could be modified to run non-interactively with an App registration, and Client Secret/Certificate.</li>
    <li>Naming scheme is SG-< management Group ID / Subsciption Display Name >-< RBAC role > EX: SG-TenantRoot-Owner.</li>
    <li>The Root Management group, will be renamed "TenantRoot" as the deafault name is the tenant ID.</li>
  </ul>
