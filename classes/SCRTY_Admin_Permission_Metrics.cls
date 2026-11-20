public class SCRTY_Admin_Permission_Metrics{
    @AuraEnabled
    public static list<sObject> executeSOQL(String soql,list<Id> ids,String condition){
        system.debug('conField'+condition); 
        if(condition != null){
            soql = soql + condition + 'ids';
        }
        /*List<sObject> result = new List<sObject>();
        for(List<sObject> sObj : Database.query(soql)){
            result.addAll(sObj);
        }*/
        List<sObject> result = Database.query(soql);
       System.debug('result::'+result.size());
        return result;
    }
   
        }