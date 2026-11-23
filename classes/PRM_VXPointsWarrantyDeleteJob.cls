/**************************************************************************************************************************************************************************
Apex Class Name     : PRM_VXPointsWarrantyDeleteJob 
Version             : 1.0
Created Date        : October 2024
Function            : Batch class to delete VXData, VXStage, Points, Warranty.
Maximum Batch Size  : 200
Modification Log    :
* Developer                         Date                           Description
* ----------------------------------------------------------------------------------------------------------------------------------------------
UTKARSH                            4-OCT-2024                   Batch class to delete VXData, VXStage, Points, Warranty.
***************************************************************************************************************************************************************************/

public class PRM_VXPointsWarrantyDeleteJob implements Database.Batchable<SObject>,Database.Stateful{
    
    public static List<Core_Log_Entry__c> listLogEntries = new List<Core_Log_Entry__c>();
    
    public static List<sObject> start(Database.BatchableContext BC) {
        
        // Query 1: Query on the VXSTAGE object 
        String vxStageQuery = 'SELECT Id, Name FROM PRM_Value_Exchange_Data__c';
        
        // Query 2: Query on the VXDATA object 
        String vxDataQuery = 'SELECT Id, Name FROM PRM_Value_Exchange_Data__c';
        
        // Query 3: Query on the points object
        String pointsQuery = 'SELECT Id, Name FROM PRM_Points_Data__c';
        
        // Query 4: Query on the warranty object
        String warrantyQuery = 'SELECT Id, Name FROM PRM_Warranty_Data__c';

        // Combine the results from both queries (as separate lists or sets)
        // This requires separate handling of results within the execute method
        List<SObject> combinedResults = new List<SObject>();
        
        combinedResults.addAll(Database.query(vxStageQuery));
        combinedResults.addAll(Database.query(vxDataQuery));
        combinedResults.addAll(Database.query(pointsQuery));
        combinedResults.addAll(Database.query(warrantyQuery));

        //return Database.getQueryLocator(combinedResults);
        return combinedResults;
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        // Process the results
        try{
            if(scope!=null && !scope.isEmpty()){
                  Database.delete(scope,false);  
            } 
        }
        catch(Exception e) {
            Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'Batch Job to delete VX, Points and Warranty tables', Core_Severity__c = 'Low', Core_When__c = System.Now(), Core_Project__c = 'Batch Job to delete VX, Points and Warranty tables', Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
            listLogEntries.add(ExcepLog);
        }
        finally{
            if(listLogEntries.size()>0) {
                database.upsert(listLogEntries,false);
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        try{
        List<PRM_EmailUtility.EmailNotification> emailList = new List<PRM_EmailUtility.EmailNotification>();
        PRM_EmailUtility.EmailNotification email = new PRM_EmailUtility.EmailNotification();
        String businessEvent = 'VX_Tables_Deletion_Email';
        email.businessEvent = businessEvent;
        emailList.add(email);
        //PRM_EmailUtility.customPlaceholdersMap = placeHolderMap;
        PRM_EmailUtility.sendEmailUtil(emailList);
        }
        catch(Exception e) {
            Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'Batch Job to delete VX, Points and Warranty tables', Core_Severity__c = 'Low', Core_When__c = System.Now(), Core_Project__c = 'Batch Job to delete VX, Points and Warranty tables', Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString());
            listLogEntries.add(ExcepLog);
        }
        finally{
            if(listLogEntries.size()>0) {
                database.upsert(listLogEntries,false);
            }
        }
    }
}