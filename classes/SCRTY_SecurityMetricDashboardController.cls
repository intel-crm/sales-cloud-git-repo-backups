public class SCRTY_SecurityMetricDashboardController{    
    @AuraEnabled
    public static list<sObject> executeSOQL(String soql,list<Id> ids,String condition){
        system.debug('conField'+condition); 
        if(condition != null){
            soql = soql + condition + 'ids Limit 50000';
        }
        List<sObject> result = Database.query(soql);
        return result;
    }
}