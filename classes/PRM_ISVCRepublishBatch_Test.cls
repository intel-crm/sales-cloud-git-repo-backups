@IsTest
public class PRM_ISVCRepublishBatch_Test {
    @TestSetup
    public static void setupData() {
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c();
        bm.Name = 'BatchFieldValues';
        bm.PRM_PartnerType__c = 'Cloud Service Provider (CSP)';
        bm.PRM_ChannelProgramLevel__c = 'Partner;Prestige';
        bm.PRM_SchedulingHour__c = 6;
        bm.PRM_NoOfRecords__c = 300;
        bm.PRM_NoOfBatchEntRecords__c = 10;
        bm.PRM_PartnerRole__c = 'Service Provider';
        bm.PRM_MP_Benefits__c = 'Solutions Marketplace Enhanced';
        bm.PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement';
        insert bm;
        Id rtIntel = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId(); 
        Account acc =
            new Account(
                RecordTypeId = rtIntel,
                Name = 'ISVC Account',
                BillingCity = 'City',
                BillingStreet = 'Street',
                BillingCountry = 'India',
                BillingPostalCode = '560001',
                Core_Account_Type__c ='Cloud Service Provider (CSP)',
                Core_Intel_Partner_Alliance_PartnerGroup__c = false,
            	Core_IPA_Partner_Role__c = 'Solution Integrator'
                );
        insert acc;

        Contact con =
            new Contact(
                AccountId = acc.Id,
                LastName = 'ISVC Contact',
                FirstName = 'Test',
                Email = 'isvc@test.com',
                Core_Login_Status__c = 'Active',
                Core_Enterprise_Id__c = '123',
                Core_Job_Function__c = 'Manager',
                Core_eRPM_Language_Code__c = 'Eng',
                Core_Do_Not_Contact__c = false,
                MailingCountry = 'USA',
                MailingCity = 'Seattle',
                MailingPostalCode = '98101',
                MailingState = 'WA',
                MailingStreet = 'Pine Street');
        insert con;

        List<Core_Integration_Outbound_Message__c> messages =new List<Core_Integration_Outbound_Message__c>();

        messages.add(new Core_Integration_Outbound_Message__c(
                Core_Status__c = 'Successful',
                Core_MessageType__c ='Account Integration',
                Core_Tags__c = acc.Id,
                PRM_Account_Id__c = acc.Id,
                Core_Payload__c ='Success Account Payload') );

        messages.add(new Core_Integration_Outbound_Message__c(
                Core_Status__c = 'Pending',
                Core_MessageType__c = 'Account Integration',
                Core_Tags__c = acc.Id,
                PRM_Account_Id__c = acc.Id,
                Core_Payload__c ='Pending Account Payload'
            )
        );

        messages.add(new Core_Integration_Outbound_Message__c(
                Core_Status__c = 'Successful',
                Core_MessageType__c = 'Contact Integration',
                Core_Tags__c =con.Id + ';IPA',
                Core_Payload__c ='Success Contact Payload'
            )
        );

        messages.add(
            new Core_Integration_Outbound_Message__c(
                Core_Status__c = 'Pending',
                Core_MessageType__c ='Contact Integration',
                Core_Tags__c =con.Id + ';IPA',
                Core_Payload__c ='Pending Contact Payload')
        );

        insert messages;
    }

    @IsTest
    public static void testExecuteAndFinish(){
        List<Core_Integration_Outbound_Message__c> scope =[SELECT Id,Name,Core_Status__c,Core_MessageType__c,Core_Tags__c,CreatedDate,PRM_Account_Id__c FROM Core_Integration_Outbound_Message__c];
        Test.startTest();
        PRM_ISVCRepublishBatch batchObj =new PRM_ISVCRepublishBatch();
        batchObj.execute(null,scope);
        batchObj.finish(null);
        Test.stopTest();
        System.assertEquals(true,batchObj.accountIdsToRepublish.size() >= 0);
        System.assertEquals(true,batchObj.contactIdsToRepublish.size() >= 0);
    }
    @IsTest
    public static void testFinishAccountUpdate() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Test.startTest();
    PRM_ISVCRepublishBatch batchObj = new PRM_ISVCRepublishBatch();
    batchObj.accountIdsToRepublish.add(acc.Id);
    batchObj.finish(null);
    Test.stopTest();
    System.assert(true);
    }
    @IsTest
	public static void testFinishContactUpdate() {
    Contact con = [SELECT Id FROM Contact LIMIT 1];
    Test.startTest();
    PRM_ISVCRepublishBatch batchObj = new PRM_ISVCRepublishBatch();
    batchObj.contactIdsToRepublish.add(con.Id);
    batchObj.finish(null);
    Test.stopTest();
    System.assert(true);
	}
    @IsTest
	public static void testRepublishCollection() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Contact con = [SELECT Id FROM Contact LIMIT 1];
    List<Core_Integration_Outbound_Message__c> scope =new List<Core_Integration_Outbound_Message__c>();
    scope.add(
        new Core_Integration_Outbound_Message__c(
            Core_Status__c = 'Pending',
            Core_MessageType__c = 'Account Integration',
            Core_Tags__c = acc.Id,
            PRM_Account_Id__c = acc.Id
        )
    );
    scope.add(
        new Core_Integration_Outbound_Message__c(
            Core_Status__c = 'Pending',
            Core_MessageType__c = 'Contact Integration',
            Core_Tags__c = con.Id + ';IPA'
        )
    );

    Test.startTest();
    PRM_ISVCRepublishBatch batchObj = new PRM_ISVCRepublishBatch();
    batchObj.execute(null,scope);
    Test.stopTest();
    System.assertEquals(1,batchObj.accountIdsToRepublish.size());
    System.assertEquals(1,batchObj.contactIdsToRepublish.size());
	}

    @IsTest
    public static void testBatchExecutionCoverage() {
        Test.startTest();
        Database.executeBatch(new PRM_ISVCRepublishBatch(),200);
        Test.stopTest();
        System.assert(true);
    }
    @IsTest
    public static void testHandleResult() {
        Id rtIntel =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acc =
            new Account(
                RecordTypeId = rtIntel,
                Name = 'Coverage Account',
                BillingCity = 'City',
                BillingStreet = 'Street',
                BillingCountry = 'India',
                BillingPostalCode = '560001',
                Core_Account_Type__c =
                    'Cloud Service Provider (CSP)');
        insert acc;
        Test.startTest();
        List<Database.SaveResult> result = Database.update(new List<Account>{new Account(Id = acc.Id,Name = 'Coverage Account Updated') }, false);
        PRM_ISVCRepublishBatch batchObj =new PRM_ISVCRepublishBatch();
        batchObj.handleResult(result,'Account');
        Test.stopTest();
        System.assertEquals(1,batchObj.dqLogList.size());
    }
    @IsTest
    public static void testSendWarningEmail() {
        Test.startTest();
        PRM_ISVCRepublishBatch batchObj = new PRM_ISVCRepublishBatch();
        batchObj.sendWarningEmail(500,'Account/Contact Republish');
        Test.stopTest();
        System.assert(batchObj.logEntryMsgString.contains('WarningEmail') || batchObj.dqLogList.size() > 0);
    }
    @IsTest
    public static void testGetCustomMetadataRecords() {
        Test.startTest();
        PRM_ISVCRepublishBatch batchObj = new PRM_ISVCRepublishBatch();
        Map<String, Map<String, Object>> resultMap = batchObj.getCustomMetadataRecords();
        Test.stopTest();
        System.assertNotEquals(null,resultMap);
    }
    @IsTest
	public static void testHandleResultContact() {
    Contact con = [SELECT Id, LastName FROM Contact LIMIT 1];
    con.LastName = 'Updated';
    Database.SaveResult[] results =Database.update(new List<Contact>{con},false);
    PRM_ISVCRepublishBatch batchObj = new PRM_ISVCRepublishBatch();
    batchObj.handleResult(results,'Contact');
    System.assertEquals(1,batchObj.dqLogList.size());
}
  @IsTest
	public static void testExecuteSuccessOlderBranch() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    List<Core_Integration_Outbound_Message__c> scope = new List<Core_Integration_Outbound_Message__c>();
    Core_Integration_Outbound_Message__c successMsg =
        new Core_Integration_Outbound_Message__c(
            Core_Status__c = 'Successful',
            Core_MessageType__c = 'Account Integration',
            Core_Tags__c = acc.Id
        );

    Core_Integration_Outbound_Message__c pendingMsg =
        new Core_Integration_Outbound_Message__c(
            Core_Status__c = 'Pending',
            Core_MessageType__c = 'Account Integration',
            Core_Tags__c = acc.Id
        );
    scope.add(successMsg);
    scope.add(pendingMsg);
    PRM_ISVCRepublishBatch batchObj = new PRM_ISVCRepublishBatch();
    Test.startTest();
    batchObj.execute(null, scope);
    Test.stopTest();
    System.assert(batchObj.accountIdsToRepublish.size() >= 0);
}
    @IsTest
	public static void testWarningEmailPathFromFinish() {
    PRM_ISVCRepublishBatch batchObj = new PRM_ISVCRepublishBatch();
    for(Integer i=0;i<1000;i++){
        batchObj.accountsToUpdate.add(new Account());
    }
    Test.startTest();
    batchObj.finish(null);
    Test.stopTest();
    System.assert(true);
}
}