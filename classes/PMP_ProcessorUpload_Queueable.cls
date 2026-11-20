/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_ProcessorUpload_Queueable
* Version     : 1.0 
* Created Date: 8th Dec, 2020
* Modification Log :
* Developer                             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Raj Yadav                            08/12/2020               Created for queueing leaf nodes of processor JSON to create Spec-SpecValue association records
******************************************************************************************************************************************************************************************************/
public with sharing class PMP_ProcessorUpload_Queueable implements Queueable {
    
    private List<List<Map<String, Object>>> leafLevelNodes = new List<List<Map<String, Object>>>();// List of modified static resources
    
    public PMP_ProcessorUpload_Queueable(List<List<Map<String, Object>>> leafNodeBatches){
        this.leafLevelNodes = leafNodeBatches;
    }
    
    public void execute(QueueableContext context){
        if(!leafLevelNodes.isEmpty()){
            List<Map<String, Object>> batchToBeProcessed = leafLevelNodes[0];
            PMP_CreateProcessorValueAssoc.createSpecValueAssociations(batchToBeProcessed);
            leafLevelNodes.remove(0);
            if(!Test.isRunningTest()){
            	System.enqueueJob(new PMP_ProcessorUpload_Queueable(leafLevelNodes));
            }
        }
    }

}