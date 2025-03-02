targetScope = 'subscription'
 
var varRgName = 'rg-tfstatebootstrap-001'
var varTags = {
  WorkloadName: 'Terraform State File Storage'
  Criticality: 'high'
  Env: 'Dev'
  Control: 'Bicep'
}
var varStAccounts = [
  {
    name: 'statntfstate1'
    location: 'centralus'
    skuName: 'Standard_LRS'
    tags: varTags
    containers: [
      {
        name: '00-runners'
        publicAccess: 'None'
      }
    ]
  }
]
 
module modTfStateRg 'br/public:avm/res/resources/resource-group:0.4.1' = {
  name: 'modTfStateRg'
  params: {
    name: varRgName
    location: deployment().location
    tags: varTags
  }
}
 
module modTfStateSt 'br/public:avm/res/storage/storage-account:0.18.1' = [for st in varStAccounts: {
  scope: resourceGroup(varRgName)
  name: 'mod${st.name}'
  dependsOn: [
    modTfStateRg
  ]
  params: {
    name: st.name
    location: deployment().location
    skuName: st.skuName
    tags: varTags
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      // ipRules: [
      //   {
      //     action: 'Allow'
      //     value: '136.226.198.127' // Citrix Workstatation V00X8884 filip.vagner@rb.cz
      //   }
      // ]
    }
    allowBlobPublicAccess: false
    blobServices: {
      automaticSnapshotPolicyEnabled: true
      deleteRetentionPolicyDays: 100
      deleteRetentionPolicyEnabled: true
      containerDeleteRetentionPolicyDays: 60
      containerDeleteRetentionPolicyEnabled: true
      isVersioningEnabled: true
      lastAccessTimeTrackingPolicyEnabled: false
      containers: [for container in st.containers: {
          name: '${container.name}'
          publicAccess: 'None'
        }
      ]
    }
    roleAssignments: [
      {
        name: '532639c3-0eae-46a8-adfb-162c0089539a'
        principalId: '532639c3-0eae-46a8-adfb-162c0089539a'
        principalType: 'User'
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      }
    ]
    lock: {
      kind: 'CanNotDelete'
      name: '${st.name}-CanNotDelete'
    }
  }
}]
