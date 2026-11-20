/**************************************************************************************************************
Apex Class Name:  PRM_ProcessInboundOPIDLogEntriesTest
Version     : 1.0 
Created Date: 11 November 2020
Function    : Test class for PRM_ProcessInboundOPIDLogEntriesUtility. 
Modification Log : 
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Srishty Sharma       16/11/2020      Test class for PRM_ProcessInboundOPIDLogEntriesUtility.   
***************************************************************************************************************/
@isTest
public class PRM_ProcessInboundOPIDLogEntriesTest {
    
    @isTest
    private static void testProcessDatabaseSaveInsertResult(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        List<Account> accListToInsert = new List<Account>();
        
        //Intel Account ****************************************************
        Account accIntel = PRM_TestUtility.getAccount();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.AccountNumber = '435765';
        accIntel.Name='TestUser';
        accIntel.BillingCity='New Delhi';
        accIntel.BillingCountryCode='IND';
        accIntel.BillingStreet='Joshi Marg';
        accIntel.BillingPostalCode='65467';
        accIntel.BillingStateCode='KA';
        accIntel.Core_CIM_ID__c='234567';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Industry = 'Construction';
        accListToInsert.add(accIntel);
        
        Account accIntel1 = PRM_TestUtility.getAccount();
        accIntel1.RecordTypeId = accountRecordTypeIntel;
        accIntel1.AccountNumber = '435765';
        accIntel1.Name='TestUser';
        accIntel1.BillingCity='New Delhi';
        accIntel1.BillingCountryCode='IND';
        accIntel1.BillingStreet='Joshi Marg';
        accIntel1.BillingPostalCode='65467';
        accIntel1.BillingStateCode='KA';
        accIntel1.Core_CIM_ID__c='234567';
        accIntel1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel1.Industry = 'Construction';
        accIntel1.PRM_IPA_Integration_Status__c='Dummy';
        accListToInsert.add(accIntel1);        
        List<Database.SaveResult> saveResultInsertList= Database.insert(accListToInsert,false);
        
        Test.startTest();
        String logMsg = PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(accListToInsert,saveResultInsertList,'Account');
        Test.stopTest();
        System.assert(logMsg.containsIgnoreCase('Account'));
    }
    
    @isTest
    private static void testProcessDatabaseSaveUpdateResult(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        //Intel Account ****************************************************
        Account accIntel = PRM_TestUtility.getAccount();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.AccountNumber = '435765';
        accIntel.Name='TestUser';
        accIntel.BillingCity='New Delhi';
        accIntel.BillingCountryCode='IND';
        accIntel.BillingStreet='Joshi Marg';
        accIntel.BillingPostalCode='65467';
        accIntel.BillingStateCode='KA';
        accIntel.Core_CIM_ID__c='234567';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Industry = 'Construction';
        insert accIntel;
        List<Account> accList = new List<Account>();
        accIntel.PRM_IPA_Integration_Status__c='Dummy';
        accList.add(accIntel);
        List<Database.SaveResult> saveResultList= Database.update(accList,false);
        Test.startTest();
        String logMsg = PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(accList,saveResultList,'Account');
        Test.stopTest();
        System.assert(logMsg.containsIgnoreCase('Account'));
    }
    
    @isTest
    private static void testProcessDatabaseUpsertResult(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        List<Account> accListToUpsert = new List<Account>();
        
        //Intel Account ****************************************************
        Account accIntel = PRM_TestUtility.getAccount();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.AccountNumber = '435765';
        accIntel.Name='TestUser';
        accIntel.BillingCity='New Delhi';
        accIntel.BillingCountryCode='IND';
        accIntel.BillingStreet='Joshi Marg';
        accIntel.BillingPostalCode='65467';
        accIntel.BillingStateCode='KA';
        accIntel.Core_CIM_ID__c='234567';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Industry = 'Construction';
        insert accIntel;
        Account acc = [Select id from Account LIMIT 1];
        Account accountToUpdate = new Account(Id=acc.Id,Core_Intel_Partner_Alliance_PartnerGroup__c=false);
        accListToUpsert.add(accountToUpdate);
        
        Account accIntel1 = PRM_TestUtility.getAccount();
        accIntel1.RecordTypeId = accountRecordTypeIntel;
        accIntel1.AccountNumber = '435765';
        accIntel1.Name='TestUser';
        accIntel1.BillingCity='New Delhi';
        accIntel1.BillingCountryCode='IND';
        accIntel1.BillingStreet='Joshi Marg';
        accIntel1.BillingPostalCode='65467';
        accIntel1.BillingStateCode='KA';
        accIntel1.Core_CIM_ID__c='234567';
        accIntel1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel1.Industry = 'Construction';
        accIntel1.PRM_IPA_Integration_Status__c='Dummy';
        accListToUpsert.add(accIntel1);        
        List<Database.UpsertResult> upsertResultList= Database.upsert(accListToUpsert,false);
        
        Test.startTest();
        String logMsg = PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(accListToUpsert,upsertResultList,'Account');
        Test.stopTest();
        System.assert(logMsg.containsIgnoreCase('Account'));
    }
    @isTest
    private static void testProcessException(){
        try{
            Contact con = new Contact();
            con.FirstName='Test';
            insert con;
        }
        catch(Exception e){
            Test.startTest();
            String logMsg = PRM_ProcessInboundOPIDLogEntriesUtility.processException(e);
            Test.stopTest();
            System.assert(logMsg.containsIgnoreCase('Insert failed'));
        }
    }
    @isTest
    private static void testAddLogEntries(){
        String testString='This is a test string just for the purpose of testing';
        PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility = new PRM_ProcessInboundOPIDLogEntriesUtility();
        Test.startTest();
		logEntryUtility.addLogEntry(testString,30);        
        Test.stopTest();
        System.assert(logEntryUtility.logEntryList[0].containsIgnoreCase('To be continued'));
        
    }
    @isTest
    private static void testInboundInsertion(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        List<Account> accListToUpsert = new List<Account>();
        
        //Intel Account ****************************************************
        Account accIntel = PRM_TestUtility.getAccount();
        accIntel.RecordTypeId = accountRecordTypeIntel;
        accIntel.AccountNumber = '435765';
        accIntel.Name='TestUser';
        accIntel.BillingCity='New Delhi';
        accIntel.BillingCountryCode='IND';
        accIntel.BillingStreet='Joshi Marg';
        accIntel.BillingPostalCode='65467';
        accIntel.BillingStateCode='KA';
        accIntel.Core_CIM_ID__c='234567';
        accIntel.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        accIntel.Industry = 'Construction';
        insert accIntel;
        
        List<Core_OnePartner_Inbound_Message__c> listOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        List<Core_OnePartner_Inbound_Message__c> upsertListOfInbound = new List<Core_OnePartner_Inbound_Message__c>();
        Core_OnePartner_Inbound_Message__c inboundTable = new Core_OnePartner_Inbound_Message__c();
        inboundTable.Core_Status__c = 'NEW';
        inboundTable.Core_SalesCloud_AccountID__c = accIntel.Id;
        inboundTable.Core_OnePartnerID__c = 2001;
        inboundTable.Core_CIM_ID__c=2345987;
        inboundTable.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        listOfInbound.add(inboundTable);
        Core_OnePartner_Inbound_Message__c inboundTable1 = new Core_OnePartner_Inbound_Message__c();
        inboundTable1.Core_Status__c = 'NEW';
        inboundTable1.Core_SalesCloud_AccountID__c = accIntel.Id;
        inboundTable1.Core_OnePartnerID__c = 2001;
        inboundTable1.Core_CIM_ID__c=2345987;
        inboundTable1.Core_OnePartner_Account_Name__c = 'Crosswealth1';
        inboundTable1.Core_Status_Effective_End_Date_Time__c = System.now();
        listOfInbound.add(inboundTable1);
        List<Database.SaveResult> insertResult= Database.insert(listOfInbound,false);
        inboundTable.Core_OnePartnerID__c = 2002;
        upsertListOfInbound.add(inboundTable);
        List<Database.UpsertResult> upsertResultList= Database.upsert(upsertListOfInbound,false);
        
        Test.startTest();
        String logMsg = PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseSaveResult(listOfInbound,insertResult,'Core_OnePartner_Inbound_Message__c');
        String logMsg1 = PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(upsertListOfInbound,upsertResultList,'Core_OnePartner_Inbound_Message__c');
        Test.stopTest();
        System.assert(logMsg.containsIgnoreCase('Core_OnePartner_Inbound_Message__c'));
    }
    
}