@isTest
public class Core_Batch_PlatformEventBus_Repbsh_Test {

    static testMethod void platformEventBus_Republish(){
        Test.startTest();
        
        Account acc = new Account();
        acc.name='Test';
        //acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_Account_Legal_Name__c='asas';
        acc.Core_Sales_Segment__c='aa';
        acc.Core_Sales_Group__c='Global Accounts';
        acc.Fax='aaa';
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Phone='121212';
        acc.Industry = '';
        insert acc;
        
        List<Account> accList = new List<Account>();
        accList.add(acc);
        Core_Platform_Event_Producer.publish_On_Account_Update(accList);
        
        
        List<Core_Platform_Event_Log__c>  eventLogList = new List<Core_Platform_Event_Log__c>();
        Core_Platform_Event_Log__c eventLog = new Core_Platform_Event_Log__c();
        eventLog.Account__c=acc.id;
        eventLog.Core_IsActive__c=True;
        eventLog.Core_Message__c='<?xml/>';
        eventLog.Core_Number_Of_Attempts__c=0;
        eventLog.Core_Object_API_Name__c='Account';
        eventLog.Core_Status__c='failed';
        
        eventLogList.add(eventLog);
        insert eventLogList;


        Core_Platform_Event_Attempts__c platformEventAttempts = new Core_Platform_Event_Attempts__c();
        platformEventAttempts.Core_Days_To_Purge_Until__c=-30;
        platformEventAttempts.Core_Number_Of_Attempts__c=1;
        platformEventAttempts.Core_Batch_Size__c=1;
        platformEventAttempts.Core_Support_Email_Address__c='abcd@intel.com,abcd@intel.com';
        insert platformEventAttempts;
        
        Core_Batch_PlatformEventBus_Republish bc = new Core_Batch_PlatformEventBus_Republish();
        database.executebatch(bc,30);
        Core_Batch_PlatformEventBus_Republish.executePlatformEventBusRepublishBatch();
        
        Core_Platform_Event_Log__c eventLog1 = new Core_Platform_Event_Log__c();
        eventLog1.Account__c=acc.id;
        eventLog1.Core_IsActive__c=True;
        eventLog1.Core_Message__c='<?xml/>';
        eventLog1.Core_Number_Of_Attempts__c=0;
        eventLog1.Core_Object_API_Name__c='Account';
        eventLog1.Core_Status__c='success';
        insert eventLog1;
        

        Core_Batch_PlatformEventBus_PurgeRecords purgeRecords = new Core_Batch_PlatformEventBus_PurgeRecords();
        database.executebatch(purgeRecords,30);
        
        

        Core_Batch_PlatformEventBus_PurgeRecords.executePlatformEventBusPurgeBatch();
        
        
            
        Test.stopTest();
    }
}