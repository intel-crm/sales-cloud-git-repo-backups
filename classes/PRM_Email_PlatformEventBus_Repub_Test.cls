/******************************************************************************************************************************
Apex Class Name:  PRM_Email_PlatformEventBus_Repub_Test
Version     : 1.0 
Created Date: 01 JUN 2021
Function    : Test Class for PRM_Email_Log_PlatformEventBus_Republish 

Modification Log :
* Developer                     Date                    Description
* ----------------------------------------------------------------------------------------------------------------------------
* GopiKrishna Vankadari       01/06/2021               Test Class for PRM_Email_Log_PlatformEventBus_Republish 

*******************************************************************************************************************************/
@isTest
public class PRM_Email_PlatformEventBus_Repub_Test {
    
    static testMethod void platformEventBus_Republish(){
        Test.startTest();
        
        PRM_EmailLog__c emaillog = new PRM_EmailLog__c();
        emaillog.PRM_Subject__c='Congratulations on Your New Intel® Cloud Insider Status';
        emaillog.PRM_ToEmailID__c='ebert123@mailinator.com';
        emaillog.PRM_EmailContent__c='htmlbody';
        emaillog.Email_Template_Name__c='SCRRENGENRLREV';
        emaillog.Language__c='ENG';
        emaillog.PRM_Read__c=false;
        emaillog.CreatedDate=System.now();
        insert emaillog;
        
        System.assertEquals(false, emaillog.PRM_Read__c);
        
        String recordId =[SELECT Name from PRM_EmailLog__c ].Name;
        List<Core_Platform_Event_Log__c>  eventLogList = new List<Core_Platform_Event_Log__c>();
        Core_Platform_Event_Log__c eventLog = new Core_Platform_Event_Log__c();
        eventLog.Core_IsActive__c=True;
        eventLog.Core_Message__c=recordId;
        eventLog.Core_Number_Of_Attempts__c=0;
        eventLog.Core_Object_API_Name__c='PRM_Email_Log__c';
        eventLog.Core_Status__c='failed';
        
        eventLogList.add(eventLog);
        insert eventLogList;
        
        Core_Platform_Event_Attempts__c platformEventAttempts = new Core_Platform_Event_Attempts__c();
        platformEventAttempts.Core_Days_To_Purge_Until__c=-30;
        platformEventAttempts.Core_Number_Of_Attempts__c=1;
        platformEventAttempts.Core_Batch_Size__c=1;
        platformEventAttempts.Core_IPA_Support_Email_Address__c='abcd@intel.com,abcd@intel.com';
        insert platformEventAttempts;
        
        
        PRM_Email_Log_PlatformEventBus_Republish bc = new PRM_Email_Log_PlatformEventBus_Republish();
        database.executebatch(bc,30);
        PRM_Email_Log_PlatformEventBus_Republish.executePlatformEventBusRepublishBatch();
        
        Test.stopTest();
    }
}