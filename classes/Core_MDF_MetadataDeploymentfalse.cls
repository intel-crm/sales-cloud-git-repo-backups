public class Core_MDF_MetadataDeploymentfalse implements Metadata.DeployCallback{
    //public organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug(' success : '+ result);           
        } else {
            System.debug(' fail : '+ result);
        }
        
    }
    public void createUpdateMetadata(boolean Check){
        
            Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
            customMetadata.fullName = 'Trigger_Execution__mdt.Core_MDF_claimStageProcessOnAfterUpdate'; 
            customMetadata.label = 'Core_MDF_claimStageProcessOnAfterUpdate';
        
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();            
            customField.field = 'Active__c';            
            customField.value = check;  //Setting false to disable trigger logic                           
            customMetadata.values.add(customField);
        
            Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
            mdContainer.addMetadata(customMetadata);
            // Setup deploy callback, MyDeployCallback implements
        
            Core_MDF_MetadataDeploymentfalse callback = new Core_MDF_MetadataDeploymentfalse();
        
            // Enqueue custom metadata deployment
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        
    }

}