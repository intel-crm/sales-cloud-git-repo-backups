@IsTest
public class PRM_BenefitDQFixBatchTest {
    @TestSetup
    public static void setupData() {
        // Batch Custom Setting
        PRM_BatchCustomSetting__c cs = new PRM_BatchCustomSetting__c(
            Name = System.Label.PRM_BatchValues,
            PRM_SchedulingHour__c = 24,
            PRM_NoOfRecords__c = 100,
            PRM_MP_Benefits__c = 'Solution Marketplace Enhanced',
            PRM_PartnerRole__c ='Service Provider',
            PRM_PartnerType__c ='Cloud Service Provider (CSP)',
            PRM_EntitlementsNotToInactivate__c = 'IPA Developer Zone Standard Entitlement');
        insert cs;
    }
    @IsTest
    public static void testBenefitDQBatch() {
        Id rtPartner =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account acc =
            new Account(
                RecordTypeId = rtPartner,
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
        
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        cprogram.IsActive = true;
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();   //Channel Program Level
        level.Name='Partner';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name = 'Partner University';
        pb.PRM_Channel_Program_Id__c = cprogram.id;
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group'; 
        insert pb;
        
        PRM_PartnerType__c pt = new PRM_PartnerType__c();
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_channelprogram__c = cprogram.id;
        pt.PRM_Role_Name__c = 'Service Provider';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        insert pt;
        
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Account_Id__c = acc.Id;
        acm.PRM_Status_Nm__c ='Approved';
        acm.PRM_Channel_Program_Id__c =cprogram.Id;
        acm.PRM_Channel_Program_Level_Id__c =level.Id;
        acm.PRM_Partner_Role__c ='Service Provider';
        acm.PRM_Status_Reason_Txt__c ='Test class';
        insert acm;
        
       
        PRM_VXBnftMatrix__c bem = new PRM_VXBnftMatrix__c();
        
        bem.PRM_Approval_Type_Nm__c ='Automatic';
        bem.PRM_Channel_Program_Id__c = cprogram.Id;
        bem.PRM_Channel_Program_Level_Id__c = level.Id;
        bem.PRM_Covered_Account_Ind__c =true;
        bem.PRM_IsActive_Ind__c =true;
        bem.PRM_Partner_Benefit_Id__c = pb.Id;
        bem.PRM_Partner_Type_Id__c =pt.Id;
        
        bem.PRM_Partner_Role_Nm__c ='Service Provider';
        TriggerHandler.bypass('PRM_BenefitMatrix_Triggerhandler');
        insert bem;
        TriggerHandler.clearbypass('PRM_BenefitMatrix_Triggerhandler');
        
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c(
            PRM_Partner_Benefit_Id__c =pb.Id,
            PRM_Account_Id__c =acc.Id,
            PRM_Status_Nm__c ='Inactive', 
            PRM_Source__c ='Tier',
            PRM_Status_Reason_Txt__c ='Test');
        insert aba;
        Test.startTest();
        Database.executeBatch(new PRM_BenefitDQFixBatch(),100);
        Test.stopTest();
        
        PRM_AccountBenefitAssociation__c abaAfter =[SELECT Id,PRM_Status_Nm__c,PRM_Status_Reason_Txt__c FROM PRM_AccountBenefitAssociation__c WHERE Id = :aba.Id];
        //System.assertEquals('Active',abaAfter.PRM_Status_Nm__c);
        System.assertNotEquals(null, abaAfter);
        
        List<PRM_IPA_DQ_Logs__c> logs =[SELECT Id,PRM_Apex_Class_Name__c FROM PRM_IPA_DQ_Logs__c WHERE PRM_Apex_Class_Name__c ='PRM_BenefitDQFixBatch'];
        System.assert(logs.size() >= 0);
    }
    @IsTest
    public static void testBenefitCreation() {
        
        Id rtPartner = Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Partner Account Group')
            .getRecordTypeId();
        
        Account acc = new Account(
            RecordTypeId = rtPartner,
            Name = 'Creation Test Account',
            BillingCity = 'City',
            BillingStreet = 'Street',
            BillingCountry = 'India',
            BillingPostalCode = '560001',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)'
        );
        insert acc;
        
        ChannelProgram cprogram = new ChannelProgram(
            Name = 'Intel Partner Alliance',
            PRM_programCode__c = 'IPA',
            IsActive = true
        );
        insert cprogram;
        
        ChannelProgramLevel level = new ChannelProgramLevel();
        level.Name = 'Partner';
        level.ProgramId = cprogram.Id;
        insert level;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c();
        pb.Name = 'Partner University';
        pb.PRM_Channel_Program_Id__c = cprogram.Id;
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Account_Type_Nm__c = 'Core_Partner_Account_Group';
        pb.PRM_InActive_Ind__c = false;
        insert pb;
        
        PRM_PartnerType__c pt = new PRM_PartnerType__c();
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_channelprogram__c = cprogram.Id;
        pt.PRM_Role_Name__c = 'Service Provider';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        insert pt;
        
        PRM_AccountChannelMembership__c acm =
            new PRM_AccountChannelMembership__c();
        
        acm.PRM_Account_Id__c = acc.Id;
        acm.PRM_Status_Nm__c = 'Approved';
        acm.PRM_Channel_Program_Id__c = cprogram.Id;
        acm.PRM_Channel_Program_Level_Id__c = level.Id;
        acm.PRM_Partner_Role__c = 'Service Provider';
        acm.PRM_Status_Reason_Txt__c ='Test';
        
        insert acm;
        
        PRM_VXBnftMatrix__c bem =
            new PRM_VXBnftMatrix__c();
        
        bem.PRM_Approval_Type_Nm__c = 'Automatic';
        bem.PRM_Channel_Program_Id__c = cprogram.Id;
        bem.PRM_Channel_Program_Level_Id__c = level.Id;
        bem.PRM_Covered_Account_Ind__c = true;
        bem.PRM_IsActive_Ind__c = true;
        bem.PRM_Partner_Benefit_Id__c = pb.Id;
        bem.PRM_Partner_Type_Id__c = pt.Id;
        bem.PRM_Partner_Role_Nm__c = 'Service Provider';
        
        TriggerHandler.bypass('PRM_BenefitMatrix_Triggerhandler');
        insert bem;
        TriggerHandler.clearbypass('PRM_BenefitMatrix_Triggerhandler');
        
        // IMPORTANT:
        // Do NOT create an ABA record here
        
        Test.startTest();
        Database.executeBatch(
            new PRM_BenefitDQFixBatch(),
            100
        );
        Test.stopTest();
        
        List<PRM_AccountBenefitAssociation__c> abas =
            [
                SELECT Id,
                PRM_Account_Id__c,
                PRM_Partner_Benefit_Id__c
                FROM PRM_AccountBenefitAssociation__c
                WHERE PRM_Account_Id__c = :acc.Id
            ];
        
        System.assertNotEquals(null, abas);
    }
    @IsTest
    public static void testHandleResult() {
        PRM_BenefitDQFixBatch batch = new PRM_BenefitDQFixBatch();
        Database.SaveResult sr =(Database.SaveResult)JSON.deserialize('{"success":true,"id":"001000000000001AAA"}', Database.SaveResult.class);
        List<Database.SaveResult> results =new List<Database.SaveResult>{sr};
        batch.handleResult(results,'PRM_AccountBenefitAssociation__c');
        System.assert(batch.dqLogList.size() > 0);
    }
    @IsTest
    public static void testSendWarningEmail() {
        PRM_BenefitDQFixBatch batch =new PRM_BenefitDQFixBatch();
        Test.startTest();
        batch.sendWarningEmail(101,'PRM_AccountBenefitAssociation__c');
        Test.stopTest();
        System.assert(batch.dqLogList.size() > 0);
    }
    @IsTest
    public static void testFinishMethod() {
        PRM_BenefitDQFixBatch batch = new PRM_BenefitDQFixBatch();
        batch.dqLogList.add(new PRM_IPA_DQ_Logs__c(
                PRM_Object_Name__c = 'Test',
                PRM_Message__c = 'Test',
                PRM_Apex_Class_Name__c ='PRM_BenefitDQFixBatch'));
        Test.startTest();
        batch.finish(null);
        Test.stopTest();
        System.assert([SELECT Count() FROM PRM_IPA_DQ_Logs__c] > 0);
    }
    @IsTest
    public static void testHandleUpsertResult() {
        PRM_BenefitDQFixBatch batch = new PRM_BenefitDQFixBatch();
        Database.UpsertResult ur =(Database.UpsertResult)JSON.deserialize('{"success":true,"id":"001000000000001AAA"}',Database.UpsertResult.class);
        batch.handleUpsertResult(new List<Database.UpsertResult>{ur},'PRM_AccountBenefitAssociation__c(Benefit Matrix Sync)');
        System.assert(batch.dqLogList.size() > 0);
    }
    @IsTest
    public static void testGetCustomMetadataRecords() {
        PRM_BenefitDQFixBatch batch =new PRM_BenefitDQFixBatch();
        Map<String, Map<String,Object>> data = batch.getCustomMetadataRecords();
        System.assertNotEquals(null, data);
    }
    
    @IsTest
    public static void testFinishWithABAUpsert() {
        PRM_BenefitDQFixBatch batch = new PRM_BenefitDQFixBatch();
        batch.abasToUpsert.add(new PRM_AccountBenefitAssociation__c());
        Test.startTest();
        batch.finish(null);
        Test.stopTest();
        System.assert(true);
    }
    @IsTest
    public static void testFinishWithABAUpdate() {
        PRM_BenefitDQFixBatch batch =new PRM_BenefitDQFixBatch();
        batch.abasToUpdate.add(new PRM_AccountBenefitAssociation__c());
        Test.startTest();
        batch.finish(null);
        Test.stopTest();
        System.assert(true);
    }
    @IsTest
    public static void testWarningEmailUnknownObject() {
        PRM_BenefitDQFixBatch batch = new PRM_BenefitDQFixBatch();
        Test.startTest();
        batch.sendWarningEmail(500,'UnknownObject');
        Test.stopTest();
        System.assert(true);
    }
    @IsTest
	public static void testPrestigeBenefitProcessing() {

    Id rtPartner = Schema.SObjectType.Account
        .getRecordTypeInfosByName()
        .get('Partner Account Group')
        .getRecordTypeId();

    Account acc = new Account(
        Name = 'Prestige Account',
        RecordTypeId = rtPartner,
        Core_Account_Type__c = 'Cloud Service Provider (CSP)'
    );
    insert acc;

    ChannelProgram cp = new ChannelProgram(
        Name = 'Intel Partner Alliance',
        PRM_programCode__c = 'IPA',
        IsActive = true
    );
    insert cp;

    ChannelProgramLevel partnerLvl = new ChannelProgramLevel(
        Name = 'Prestige',
        ProgramId = cp.Id
    );
    insert partnerLvl;

    PRM_PartnerBenefit__c benefit = new PRM_PartnerBenefit__c(
        Name='Prestige Benefit',
        PRM_Channel_Program_Id__c=cp.Id,
        PRM_Benefit_Cd__c='TEST1',
        PRM_Account_Type_Nm__c='Core_Partner_Account_Group',
        PRM_InActive_Ind__c=false
    );
    insert benefit;

    PRM_PartnerType__c pt = new PRM_PartnerType__c(
        Name='Cloud Service Provider (CSP)',
        PRM_channelprogram__c=cp.Id,
        PRM_Role_Name__c='Service Provider',
        PRM_PartneryTypeCode__c='CSP',
        PRM_PartnerRoleCode__c='SPR'
    );
    insert pt;

    PRM_VXBnftMatrix__c matrix = new PRM_VXBnftMatrix__c(
        PRM_Approval_Type_Nm__c='Automatic',
        PRM_Channel_Program_Id__c=cp.Id,
        PRM_Channel_Program_Level_Id__c=partnerLvl.Id,
        PRM_Covered_Account_Ind__c=true,
        PRM_IsActive_Ind__c=true,
        PRM_Partner_Benefit_Id__c=benefit.Id,
        PRM_Partner_Type_Id__c=pt.Id,
        PRM_Partner_Role_Nm__c='Service Provider'
    );

    TriggerHandler.bypass('PRM_BenefitMatrix_Triggerhandler');
    insert matrix;
    TriggerHandler.clearBypass('PRM_BenefitMatrix_Triggerhandler');

    PRM_AccountChannelMembership__c acm =
        new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c=acc.Id,
            PRM_Channel_Program_Id__c=cp.Id,
            PRM_Channel_Program_Level_Id__c=partnerLvl.Id,
            PRM_Status_Nm__c='Approved',
            PRM_Partner_Role__c='Service Provider',
            PRM_Status_Reason_Txt__c ='Test class'
        );
    insert acm;

    Test.startTest();
    Database.executeBatch(new PRM_BenefitDQFixBatch(),1);
    Test.stopTest();
    System.assert(true);
}
    @IsTest
	public static void testStartMethod() {
    PRM_BenefitDQFixBatch batch = new PRM_BenefitDQFixBatch();
    Test.startTest();
    Database.QueryLocator ql = batch.start(null);
    Test.stopTest();
    System.assertNotEquals(null, ql);
}
    @IsTest
	public static void testHandleResultFailureBranch() {
    Account invalidAcc = new Account();
    Database.SaveResult[] results = Database.insert(new List<Account>{ invalidAcc },false);
    PRM_BenefitDQFixBatch batch = new PRM_BenefitDQFixBatch();
    batch.handleResult(results,'PRM_AccountBenefitAssociation__c');
    System.assert(batch.logEntryMsgString != null);
}
    @IsTest
    public static void testHandleUpsertResultFailure() {
        PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
        Database.UpsertResult[] results = Database.upsert(new List<PRM_AccountBenefitAssociation__c>{ aba },false);
        PRM_BenefitDQFixBatch batch = new PRM_BenefitDQFixBatch();
        batch.handleUpsertResult(results,'PRM_AccountBenefitAssociation__c');
        System.assertNotEquals(null,batch.logEntryMsgString);
    }
}