public with sharing class POCPlatformEventsLogging {
    
    public static void testSOQL(){
        try{
            Account a = [select name,Core_Data_Simplified_Account_Nm__c,Core_Sales_Assist_Count__c from account limit 1];    
            publish(JSON.serialize(a), false);           
        }catch(Exception ex){
            publish(ex.getMessage(), true);
        }
        
    }
    
    static void publish(String info, boolean error){
        PMP_Error_Logging__e eventLog = new PMP_Error_Logging__e();
        eventLog.PMP_Information_Message__c = info;
        eventLog.PMP_Record_Id__c = null;
        eventLog.PMP_Transaction_Error__c = error;
        eventLog.Execution_Context__c ='Apex Class - POCPlatformEventsLogging |  Method - testSOQL';
        Database.SaveResult dr = EventBus.publish(eventLog);   
    }  
    
    
}