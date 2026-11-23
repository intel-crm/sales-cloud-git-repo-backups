public class testclass_Vivek implements Database.Batchable<sObject>{
   
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String strQuery = 'select Id,User__r.Name,Total_Points__c, Rank__c,User__c from Trailhead_User__c order by User__r.Name';
        return Database.getQueryLocator(strQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Trailhead_User__c> lstuser){
    	
        for(Trailhead_User__c obj:lstuser){
            obj.Total_Points__c = obj.Total_Points__c + 1;
        }
        
        Database.update(lstuser);
    }
    

    public void finish(Database.BatchableContext bc) {}
}