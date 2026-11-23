public class Core_MDF_MetadataDeploymentCls implements Metadata.DeployCallback{
    //public static boolean recursionFlag = true;
    //public organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug(' success : '+ result);            
            Core_MDF_Batch_MaskClmBatchForP2PRefresh myBatchObject = new Core_MDF_Batch_MaskClmBatchForP2PRefresh(20);
            Database.executeBatch(myBatchObject);                 
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
        
            Core_MDF_MetadataDeploymentCls callback = new Core_MDF_MetadataDeploymentCls();
        
            // Enqueue custom metadata deployment
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        
    }

}