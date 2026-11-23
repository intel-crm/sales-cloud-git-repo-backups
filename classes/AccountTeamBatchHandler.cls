public class AccountTeamBatchHandler{
    
    public static DateTime getLastRunDateTime(String batchClassName){
        Core_Batch_header__c batchHeader = [Select id,Last_Run_Date_Time__c from Core_Batch_Header__c where name = :batchClassName limit 1];
        if(batchHeader!=null && batchHeader.Last_Run_Date_Time__c!=null){
            return batchHeader.Last_Run_Date_Time__c;
        }else{
            //Added batch class name filter - US209202    //Added Start Date Time null check in query - US248473
            List<Core_Batch_Processing__c> lastprocessedRecord = [Select id,Core_Start_Date_Time__c from Core_Batch_Processing__c WHERE Batch_Header__r.Name=:batchClassName AND Core_Start_Date_Time__c!=null order by lastModifieddate desc limit 1];
            if(lastProcessedRecord!=null && lastprocessedRecord.size()>0) { //lastprocessedRecord.Core_Start_Date_Time__c!=null){
                return lastprocessedRecord[0].Core_Start_Date_Time__c;
            }else{
                return null;
            }
        }
    }
    
    public static Core_Batch_header__c getHeader(String batchClassName){
        Core_Batch_header__c batchHeader = [Select id,Last_Run_Date_Time__c,Email_Distribution_List__c from Core_Batch_Header__c where name = :batchClassName limit 1];
        return batchHeader;
    }
    
}