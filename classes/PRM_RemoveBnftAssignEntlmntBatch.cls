public class PRM_RemoveBnftAssignEntlmntBatch implements Database.Batchable<SObject>{
    
    public static Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('');
    }
    
    public static void execute(Database.BatchableContext bc, List<SObject> dataList){
        
    }
    
    public static void finish(Database.BatchableContext bc){
        
    }

}