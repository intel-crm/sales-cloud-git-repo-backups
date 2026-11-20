/***************************************************************************************************** 
Class Name :    Core_UserFieldTrackerRecordDeleter
Description:    This class is to perform the delete activity, it will delete Core_User_Field_Change_History__c records which will be older than 9 months
Added By   :    Accenture - Raushan Singh 
Modified By:                      Date:29/01/2019                     Changes:None  
*****************************************************************************************************/

global class Core_UserFieldTrackerRecordDeleter implements Database.Batchable<sObject>,Schedulable{
    global static Database.QueryLocator start(Database.BatchableContext context)
    {
        //Fetching custom label value 
        String customLabelValue = System.Label.Core_User_Field_Change_History_Record_Deletion;
        Integer strtToIntvalue = Integer.valueOf(customLabelValue.trim());
        Date dateVal= System.today()-strtToIntvalue;
        Date dateLimit = dateVal+1;
        
       //Getting those records older than number of days stored in the custom label
       return Database.getQueryLocator('SELECT ID FROM Core_User_Field_Change_History__c WHERE  CreatedDate>=:dateVal AND CreatedDate<:dateLimit');
    }
    
	// Deleting records
    global void execute(Database.BatchableContext context, List<SObject> records)
    {
        Database.delete (records);
        DataBase.emptyRecycleBin(records);
    }

    global void finish(Database.BatchableContext context){
        
    }
    //Scheduling and deleting the record in chunk
    global void execute(SchedulableContext ctx) 
    {
        Database.executeBatch(new Core_UserFieldTrackerRecordDeleter(),150);
       
    }
 }