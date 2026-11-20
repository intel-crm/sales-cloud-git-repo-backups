/**************************************************************************************
Apex Class Name:  Core_IPS_Backend_SchBatchReProcessTest 
Version     : 1.0 
Created Date: 24 05 2016
Function    : Test class for the scheduler class for batch to REPROCESS 'error' log entries.
Author      : Tanvi Chauhan
Modification Log :
* Change#           Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* IPS Cloud Rel1   Tanvi Chauhan          24/05/2016              Original Version
*
*************************************************************************************/
@isTest
public class Core_IPS_Backend_SchBatchReProcessTest {

    static testMethod void testSchedulerMethod(){

        //Inserting custom setting data
        List<Core_IPSBackendPromoteReprocesing__c> customSettings = new List<Core_IPSBackendPromoteReprocesing__c>();
        Core_IPSBackendPromoteReprocesing__c cs1 = new Core_IPSBackendPromoteReprocesing__c(Name = 'IPS_ReProcessBatchDate', Core_Translate_Value__c = '7' );
        Core_IPSBackendPromoteReprocesing__c cs2 = new Core_IPSBackendPromoteReprocesing__c(Name = 'IPS_Batch_SendToAddress', Core_Translate_Value__c = 'tanvix.chauhan@intel.com');
        customSettings.add(cs1);
        customSettings.add(cs2);  
        Database.insert(customSettings);
        
        //inserting Product to be associated to Case rec
        Product2 testProduct = Core_IPS_Backend_TestClass_Utility.getProduct();
        testProduct.Core_Product_Org__c='IPS';
        Database.insert(testProduct);
        
        //Inserting Support Org & Backend System
        Core_IPS_Product_Organization__c suppOrg = Core_IPS_Backend_TestClass_Utility.getSupportOrg();
        Database.insert(suppOrg);
        
        Core_IPS_Backend_System__c backendSystem = Core_IPS_Backend_TestClass_Utility.getBackendSystem();
        backendSystem.name='Test Backend System';
        backendSystem.Core_IPS_Support_Org__c=suppOrg.id;
        Database.insert(backendSystem);
        
        
        //inserting Case records for log entries
        List<Case> testCaseRecords = Core_IPS_Backend_TestClass_Utility.getListOfCases(1, 'IPS No Assigned Contact Case', testProduct, backendSystem);
        Database.insert(testCaseRecords);
        System.assertEquals(1, testCaseRecords.size());
        
        //inserting Log entry records to be deleted
        List<Core_Log_Entry__c> testDeleteRecords = getLogEntriesToBeDeleted(50, testCaseRecords);
        database.insert(testDeleteRecords);
        System.assertEquals(50, testDeleteRecords.size());
        
        //inserting Log entry records to be updated
        List<Core_Log_Entry__c> testUpdateRecords = Core_IPS_Backend_TestClass_Utility.getListOfLogEntries(50, testCaseRecords );
        database.insert(testUpdateRecords);
        System.assertEquals(50, testUpdateRecords.size());
        
        Test.startTest();
            Core_IPS_Backend_ScheduleBatchReProcess scheduleReprocess = new Core_IPS_Backend_ScheduleBatchReProcess();
            String sch = '0 0 6 * * ? ';
            System.schedule('Test Batch Status Check', sch, scheduleReprocess);
        Test.stopTest();
        
    }
    
    
    /*********************************************************************************************************
    Method Info : getLogEntriesToBeDeleted Method returns List Of Log entries that are eligible to be deleted
    **********************************************************************************************************/
    
    public static List<Core_Log_Entry__c> getLogEntriesToBeDeleted(integer NumOfRec, List<Case> caseRecords){
        List<Core_Log_Entry__c> ListOfLogEntries = new List<Core_Log_Entry__c> ();
        
        for(Case c: caseRecords){
            for(Integer i=1;i<=NumOfRec;i++){
                Core_Log_Entry__c LogEntryRecord = new Core_Log_Entry__c(
                    Core_Message__c = 'Log Entry Delete'+i,
                    CreatedDate = System.today().addDays(-8),
                    Core_Project__c = 'IPS Cloud',
                    Core_Origin__c = 'Test',
                    Core_sObjectType__c= 'sf:Case',
                    Core_sObjectId__c = c.id,
                    Core_Severity__c = 'Test Severity',
                    Core_When__c = Datetime.now()
                );
                ListOfLogEntries.add(LogEntryRecord);
            }
        }
        
        return ListOfLogEntries;
    }

    
}