public with sharing class POC_ProcessorQueueable implements Queueable {
    
    private List<List<Map<String, Object>>> leafLevelNodes = new List<List<Map<String, Object>>>();// Lst of modified static resources
    
    public POC_ProcessorQueueable(List<List<Map<String, Object>>> leafNodeBatches){
        this.leafLevelNodes = leafNodeBatches;
    }
    
    public void execute(QueueableContext context){
        if(!leafLevelNodes.isEmpty()){
            List<Map<String, Object>> batchToBeProcessed = leafLevelNodes[0];
            POC_CreateProcessorAssoc.createSpecValueAssociations(batchToBeProcessed);
            leafLevelNodes.remove(0);
            System.enqueueJob(new POC_ProcessorQueueable(leafLevelNodes));
        }
    }

}