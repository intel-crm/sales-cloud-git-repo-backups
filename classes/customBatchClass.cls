public class customBatchClass implements Database.Batchable<Sobject>{
    
    public List<Sobject> start(Database.BatchableContext bc){
        return null;
    }
    
    public static void execute(Database.BatchableContext bc, List<Sobject> slt){
        
    }
    public static void finish(Database.BatchableContext bc){
        
    }
    

}