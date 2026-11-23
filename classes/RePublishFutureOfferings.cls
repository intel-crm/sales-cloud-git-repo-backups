public class RePublishFutureOfferings Implements BatchJobFramework{

    public static String getStartQuery(Apex_Batch_Job__c jobDetail){

        //Date todayDate = Date.today();
                
        String query = PMP_Utility.queryAllFields('PMP_Partner_Offering__c',true);
        
        //WHERE clause - which retrieves the offerings having status = Approved & start date = today and with/without pre-release items 
       /* query = query + ' where PMP_Partner_Offering_Lifecycle_Status_Nm__c=\'Approved\' and PMP_Partner_Offering_Start_Dt__c =:todayDate'
            +' and PMP_Pre_Release_Item_Count_Num__c=0 and PMP_Is_Notified_Ind__c=false'; */
        
        query = query + jobDetail.Query__c ;
       
        System.debug('query--->'+query);
        return query;  
    }

    public static void doExecute(List<sObject> offerings){
        System.debug('Processing');
    }
    public static void callExecute(Database.BatchableContext bc,List<sObject> offerings){
        System.debug('Processing');
    }
    public static void callFinish(Database.BatchableContext bc,List<sObject> offerings){
        System.debug('Processing');
    }
}