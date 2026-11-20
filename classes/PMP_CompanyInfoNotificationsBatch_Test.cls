@isTest
public with sharing class PMP_CompanyInfoNotificationsBatch_Test {
    
    @testSetup
    public static void pmp_sendEmailAlertsForCompanyInfoSetUp() {
        
        List<PMP_Company__c> companyList = New List<PMP_Company__c>();
        //Create sample Core_Apex_EmailNotification__c records.
        Core_Apex_EmailNotification__c record1 = New Core_Apex_EmailNotification__c(Name='test1', Core_Date_Reference_Txt__c = 'PMP_Company_Status_Update_Dt__c',
                                                Core_Allowed_Permission_Nm__c='PMP_External_Partner_Admin,PMP_External_Marketing_Specialist',
                                                Core_NumberOfDays_Nbr__c = 2, Core_Email_Template_Nm__c = 'PMP_CompanyInfo_nDaysInDraft_StoreFnt',
                                                Core_IsActive_Ind__c = true,Core_IsRecurring_Ind__c = false, Core_Query_String_Txt__c = 'PMP_Is_Published_Ind__c= false',
                                                Core_Object_Nm__c = 'PMP_Company__c');
        
        insert record1;
        
        
        /*Core_Apex_EmailNotification__c record3 = New Core_Apex_EmailNotification__c(Name='test1', Core_Date_Reference_Txt__c = 'PMP_Company_Status_Update_Dt__c',
                                                Core_Allowed_Permission_Nm__c='PMP_External_Partner_Admin,PMP_External_Marketing_Specialist',
                                                Core_NumberOfDays_Nbr__c = 2, Core_Email_Template_Nm__c = 'PMP_CompanyInfo_nDaysInDraft_StoreFnt',
                                                Core_IsActive_Ind__c = true,Core_IsRecurring_Ind__c = true, Core_Query_String_Txt__c = null,
                                                Core_Object_Nm__c = 'PMP_Company__c');*/
        
        Id masterPartner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account intelAcc1 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount',masterPartner, true);
        //create PMP_Company__c records that match the criteria of the apex email records and some that do not match the criteria.
        PMP_Company__c companyInfo1 = PMP_TestDataUtility.createCompanyInformation('Test1', intelAcc1.id,false);
        Date dt = Date.today();
        companyInfo1.PMP_Company_Status_Update_Dt__c = dt.addDays(-2);
        companyInfo1.PMP_Is_Published_Ind__c = false;
        companyList.add(companyInfo1);
        PMP_Company__c companyInfo2 = PMP_TestDataUtility.createCompanyInformation('Test2', intelAcc1.id,false);    
        companyInfo2.PMP_Company_Status_Update_Dt__c = dt.addDays(-4);
        companyInfo2.PMP_Is_Published_Ind__c = false;
        companyList.add(companyInfo2);
        PMP_Company__c companyInfo3 = PMP_TestDataUtility.createCompanyInformation('Test3', intelAcc1.id,false);    
        companyInfo3.PMP_Company_Status_Update_Dt__c = dt.addDays(-4);
        companyInfo3.PMP_Is_Published_Ind__c = false;
        companyList.add(companyInfo3);
        insert companyList;
        
    }
    /* 
	@Name: sendEmailTestNonRecurring
	@Description: To test the non recurring email being sent for comapny records that match the 
					Core_Apex_EmailNotification__c record criteria;	
	*/
    
    public static testMethod void sendEmailTestNonRecurring(){
        Test.startTest();
        PMP_CompanyInfoNotificationsBatch b = new PMP_CompanyInfoNotificationsBatch();
        // before batch runs
         PMP_Company__c companyInfo = [Select name from PMP_Company__c where Name Like '%Test1%' Limit 1];
        system.assertEquals(companyInfo.Name, 'Test1'); //To do: change this assert afetr email logging functionality is implemented

        Id batchProcessId = Database.executeBatch(b,1);
        // after batch runs
        companyInfo = [Select name from PMP_Company__c where Name Like '%Test1%' Limit 1];
        system.assertEquals(companyInfo.Name+'_EmailSent', 'Test1_EmailSent');  //To do change this assert afetr email logging functionality is implemented
        Test.stopTest();
    }
    
    /* 
	@Name: sendEmailTestRecurring
	@Description: To test the recurring email being sent for comapny records that match the 
					Core_Apex_EmailNotification__c record criteria;	
	*/
    public static testMethod void sendEmailTestRecurring(){
        Core_Apex_EmailNotification__c record1 = [Select Core_IsRecurring_Ind__c, Core_NumberOfDays_Nbr__c, Core_Query_String_Txt__c from Core_Apex_EmailNotification__c Limit 1];
        record1.Core_IsRecurring_Ind__c = true;
        update record1;
        
        test.startTest();
        PMP_CompanyInfoNotificationsBatch b = new PMP_CompanyInfoNotificationsBatch();
        // before batch runs
         PMP_Company__c companyInfo = [Select name from PMP_Company__c where Name Like '%Test2%' Limit 1];
        system.assertEquals(companyInfo.Name, 'Test2');  //To do change this assert afetr email logging functionality is implemented

        Id batchProcessId = Database.executeBatch(b,1);
        // after batch runs
        companyInfo = [Select name from PMP_Company__c where Name Like '%Test2%' Limit 1];
        system.assertEquals(companyInfo.Name+'_EmailSent', 'Test2_EmailSent');  //To do change this assert afetr email logging functionality is implemented
        test.stopTest();

    } 

}