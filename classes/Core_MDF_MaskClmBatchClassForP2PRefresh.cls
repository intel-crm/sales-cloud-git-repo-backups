/****************************************************************************************************************************************
* Class Name  : Core_MDF_MaskClmBatchClassForP2PRefresh 
* Version     : 1.0 
* Created Date: 12-05-2020
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Pranav         12-05-2020                   This class switches OFF the metadata and calls Batch to mask Claim Batch records     
*****************************************************************************************************************************************/
public class Core_MDF_MaskClmBatchClassForP2PRefresh implements Metadata.DeployCallback{
  
    /***************************************************************************************************** 
    Method Name:        handleResult
    @return  :          void
    @parameters:        Metadata.DeployResult, Metadata.DeployCallbackContext
    Description:        This is a Method to call Batch to mask Claim Batch records. 
    Added By:           Accenture - Pranav - 12-05-2020
    ******************************************************************************************************/  
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug(' success : '+ result);       
            // Batch call to Mask Claim Batch Supplier Number and Comments
            Core_MDF_Batch_MaskClmBatchForP2PRefresh myBatchObject = new Core_MDF_Batch_MaskClmBatchForP2PRefresh(200);
            Database.executeBatch(myBatchObject);                 
        } else {
            System.debug(' fail : '+ result);
        }
        
    }
    
  /***************************************************************************************************** 
    Method Name:        updateClaimStageMetadata
    @return  :          void
    @parameters:        Metadata.DeployResult, Metadata.DeployCallbackContext
    Description:        This is a Method to call Batch to mask Claim Batch records. 
    Added By:           Accenture - Pranav - 12-05-2020
    ******************************************************************************************************/     
  public void updateClaimStageMetadata(boolean Check){
        
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
        
            Core_MDF_MaskClmBatchClassForP2PRefresh callback = new Core_MDF_MaskClmBatchClassForP2PRefresh();
        
            // Enqueue custom metadata deployment
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        
    }

}