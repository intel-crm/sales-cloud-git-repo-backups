public class Core_MDF_MetadataBatch implements Queueable, Metadata.DeployCallback{
    public boolean check;
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug(' success : '+ result);           
        } else {
            System.debug(' fail : '+ result);
        }
    }
    public Core_MDF_MetadataBatch(boolean check){
        this.check = check;
    }
    
    public void execute(QueueableContext qc)
    {
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
        
            Core_MDF_MetadataBatch callback = new Core_MDF_MetadataBatch(true);
        
            // Enqueue custom metadata deployment
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
    }
}