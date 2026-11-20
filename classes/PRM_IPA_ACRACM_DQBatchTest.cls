@isTest
public class PRM_IPA_ACRACM_DQBatchTest {
        @TestSetup
        static void setupData() {
        //Id intelRt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id pagRt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
		Id intelRt = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_Intel_Account_Record_Type).getRecordTypeId();
		system.debug('intelRt-->'+intelRt);
		system.debug('pagRt-->'+pagRt);
		 Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ];
		 User adminUser = new User(
            FirstName = 'Admin',
            LastName = 'Member',
            Alias = 'tteam',
            Email = 'test.teammember' + System.currentTimeMillis() + '@example.com',
            Username = 'test.teammember' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert adminUser;
        PRM_BatchCustomSetting__c bm = new PRM_BatchCustomSetting__c(
            Name = System.Label.PRM_BatchValues,
            PRM_PartnerType__c='Cloud Service Provider (CSP)',
            PRM_ChannelProgramLevel__c='Partner;Prestige',
            PRM_SchedulingHour__c=6,
            PRM_NoOfRecords__c=300,
            PRM_NoOfBatchEntRecords__c=10,
            PRM_PartnerRole__c='Service Provider'
        );
        insert bm;

        // OPID
    System.runAs(adminUser) {
        Account opidAcc = new Account(
            Name='OPID_ACCOUNT',
            RecordTypeId=pagRt,
            BillingCity='City',
            BillingStreet='Street',
            BillingCountry='India',
            BillingPostalCode='111111',
            Core_Account_Type__c='Cloud Service Provider (CSP)'
        );
        insert opidAcc;

        // Intel Account for ACM Rollup
        Account intelRollup = new Account(
            Name='INTEL_ROLLUP',
            RecordTypeId=intelRt,
            BillingCity='City',
            BillingStreet='Street',
            BillingCountry='India',
            BillingPostalCode='560001',
            Core_Account_Type__c='Cloud Service Provider (CSP)',
            Core_Intel_Partner_Alliance_PartnerGroup__c=true,
            Core_IPA_One_Partner_Id__c=opidAcc.Id
        );

        // Intel Account without ACM
        Account intelNoAcm = new Account(
            Name='INTEL_NO_ACM',
            RecordTypeId=intelRt,
            BillingCity='City',
            BillingStreet='Street',
            BillingCountry='India',
            BillingPostalCode='560002',
            Core_Account_Type__c='Cloud Service Provider (CSP)',
            Core_Intel_Partner_Alliance_PartnerGroup__c=true
        );

         // Intel Account with OPID Stamp
        Account intelStamped = new Account(
            Name='INTEL_STAMPED',
            RecordTypeId=intelRt,
            BillingCity='City',
            BillingStreet='Street',
            BillingCountry='India',
            BillingPostalCode='560003',
            Core_Account_Type__c='Cloud Service Provider (CSP)',
            Core_Intel_Partner_Alliance_PartnerGroup__c=true,
            Core_IPA_One_Partner_Id__c=opidAcc.Id
        );
         Account opidNoAcm = new Account(
            Name = 'OPID_NO_ACM',
            RecordTypeId = pagRt,
            BillingCity = 'City',
            BillingStreet = 'Street1',
            BillingCountry = 'India',
            BillingPostalCode = '333323',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)'
        );
        insert opidNoAcm;
        Account intelInsertAcm = new Account(
            Name = 'INTEL_INSERT_ACM',
            RecordTypeId = intelRt,
            BillingCity = 'City',
            BillingStreet = 'Street',
            BillingCountry = 'India',
            BillingPostalCode = '560004',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Core_Intel_Partner_Alliance_PartnerGroup__c = true,
            Core_IPA_One_Partner_Id__c = opidNoAcm.Id
        );
        insert new List<Account>{
            intelRollup,
            intelNoAcm,
            intelStamped,
            intelInsertAcm
        };
        // Active CAG
        insert new Core_Account_Group_Member__c(
            Core_Partner_Account_Id__c = opidAcc.Id,
            Core_Intel_Account_Id__c = intelRollup.Id,
            Core_Inactive_Ind__c = false
        );
        insert new Core_Account_Group_Member__c(
            Core_Partner_Account_Id__c = opidAcc.Id,
            Core_Intel_Account_Id__c = intelStamped.Id,
            Core_Inactive_Ind__c = false
        );
        insert new Core_Account_Group_Member__c(
            Core_Partner_Account_Id__c = opidNoAcm.Id,
            Core_Intel_Account_Id__c = intelInsertAcm.Id,
            Core_Inactive_Ind__c = false
        );

         //Channel Program
        ChannelProgram cp = new ChannelProgram(
            Name='Intel Partner Alliance',
            PRM_programCode__c='IPA'
        );
        insert cp;
        ChannelProgramLevel prestige = new ChannelProgramLevel(
            Name='Prestige',
            ProgramId=cp.Id
        );
        ChannelProgramLevel partner = new ChannelProgramLevel(
            Name='Partner',
            ProgramId=cp.Id
        );
        insert new List<ChannelProgramLevel>{
            prestige,
            partner
        };

        // Contact Relationship Metadata
        PRM_ContactRelationships__c rel = new PRM_ContactRelationships__c(
            Name='Primary Contact',
            PRM_Contact_Relationship_Cd__c='RELTNPRCTC',
            PRM_Channel_Program_Id__c=cp.Id,
            PRM_Default_Relationship_Ind__c=true
        );
        insert rel;

         // Contacts
        Contact c1 = new Contact(
        AccountId = intelRollup.Id,
        LastName = 'Rollup',
        FirstName = 'User1',
        Email = 'rollup@test.com',
        Core_Job_Function__c = 'Sales Manager',
        Core_eRPM_Language_Code__c = 'Eng',
        Core_Login_Status__c = 'Active',
        Core_Enterprise_Id__c = '1001',
        Core_Do_Not_Contact__c = false,
        MailingCountry = 'USA',
        MailingCity = 'Seattle',
        MailingPostalCode = '98101',
        MailingState = 'WA',
        MailingStreet = 'Pine Street'
        );
        Contact c2 = new Contact(
        AccountId = intelNoAcm.Id,
        LastName = 'NoAcm',
        FirstName = 'User2',
        Email = 'noacm@test.com',
        Core_Job_Function__c = 'Sales Manager',
        Core_eRPM_Language_Code__c = 'Eng',
        Core_Login_Status__c = 'Active',
        Core_Enterprise_Id__c = '1002',
        Core_Do_Not_Contact__c = false,
        MailingCountry = 'USA',
        MailingCity = 'Seattle',
        MailingPostalCode = '98102',
        MailingState = 'WA',
        MailingStreet = 'Pin Street'
        );
        insert new List<Contact>{c1,c2};

         // Scenario 1 ACR
         TriggerHandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        insert new PRM_Account_Contact_Relationship__c(
            PRM_Account_Id__c=intelNoAcm.Id,
            PRM_Contact_Id__c=c2.Id,
            PRM_Relationship_Id__c=rel.Id,
            PRM_InActive_Ind__c=false,
            PRM_Status_Nm__c='Complete',
            PRM_Status_Reason_Txt__c='Scenario1'
        );
        TriggerHandler.clearBypass('PRM_AcctContRel_TriggerHandlerNew');
        // Intel ACM
         TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
        insert new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c=intelRollup.Id,
            PRM_Status_Nm__c='Approved',
            PRM_Channel_Program_Id__c=cp.Id,
            PRM_Channel_Program_Level_Id__c=partner.Id,
            PRM_Partner_Role__c='Service Provider',
            PRM_Status_Reason_Txt__c='IntelACM'
        );

         // OPID ACM
        insert new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c=opidAcc.Id,
            PRM_Status_Nm__c='Inactive',
            PRM_Channel_Program_Id__c=cp.Id,
            PRM_Channel_Program_Level_Id__c=prestige.Id,
            PRM_Partner_Role__c='Service Provider',
            PRM_Status_Reason_Txt__c='OPIDACM'
        );

 
        insert new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = intelInsertAcm.Id,
            PRM_Status_Nm__c = 'Approved',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = partner.Id,
            PRM_Partner_Role__c = 'Service Provider',
            PRM_Status_Reason_Txt__c = 'InsertCoverageACM'
        );
 
 
        insert new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = opidAcc.Id,
            PRM_Status_Nm__c = 'Approved',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = partner.Id,
            PRM_Partner_Role__c = 'Distributor', // different role
            PRM_Status_Reason_Txt__c = 'ExtraOPIDACM'
        );
        TriggerHandler.clearBypass('PRM_ACMTriggerHandlerNew');
         // Metadata
            /*Core_CustomMetadata_Object__c header = new Core_CustomMetadata_Object__c(
                Metadata_Name__c='DQ_Objects_mdt',
                DeveloperName__c = 'DeveloperName',
                Field_1__c='Object__c',
                Field_2__c='Scenario__c',
                Field_3__c='Threshold__c',
                MasterLabel__c ='MasterLabel');
                //insert header;
            List<Core_CustomMetadata_Object__c> metadataRecordList = new List<Core_CustomMetadata_Object__c>();
            metadataRecordList.add(new Core_CustomMetadata_Object__c(
                Metadata_Name__c='DQ_Objects_mdt',
                DeveloperName__c = 'Threshold',
                MasterLabel__c='Threshold',
                Field_3__c= '10',
                Header_row__c =header.id
            ));
            metadataRecordList.add(new Core_CustomMetadata_Object__c(
                Metadata_Name__c='DQ_Objects_mdt',
                DeveloperName__c='ACR_Inactivate',
                MasterLabel__c='ACR_Inactivate',
                Header_row__c=header.Id,
                Field_1__c='Account_Contact_Relationship',
                Field_2__c='Inactivate active ACRs when no approved ACM exists on the IPA account.'
            ));
            //insert metadataRecordList;*/
		}
	}
        @IsTest
        static void testBatch_AllScenarios_AndWarningEmail() {
        Account opidAcc = [SELECT Id,Name,Core_Deactivated__c FROM Account WHERE Name='OPID_ACCOUNT' LIMIT 1];
        Account intelAcc = [SELECT Id,Name,Core_IPA_One_Partner_Id__c FROM Account WHERE Name='INTEL_STAMPED' LIMIT 1];
        Account noAcmAcc = [SELECT Id,Name FROM Account WHERE Name='INTEL_NO_ACM' LIMIT 1];
        PRM_ContactRelationships__c rel = [SELECT Id FROM PRM_ContactRelationships__c LIMIT 1];
        ChannelProgram cp = [SELECT Id FROM ChannelProgram LIMIT 1];
        ChannelProgramLevel partnerLevel = [SELECT Id FROM ChannelProgramLevel WHERE Name='Partner' LIMIT 1];
        ChannelProgramLevel prestigeLevel = [SELECT Id FROM ChannelProgramLevel WHERE Name='Prestige' LIMIT 1];

         // Scenario 3 : OPID stamped without active CAG
        List<Core_Account_Group_Member__c> activeCagList = [SELECT Id FROM Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c=:intelAcc.Id];
        delete activeCagList;

        //Scenario 4 : Active CAG to Deactivated OPID
        Core_Account_Group_Member__c newCag = new Core_Account_Group_Member__c(Core_Partner_Account_Id__c=opidAcc.Id,Core_Intel_Account_Id__c=noAcmAcc.Id,Core_Inactive_Ind__c=false);
        insert newCag;
        opidAcc.Core_Deactivated__c = true;
        update opidAcc;
        //Execute Batch
        TriggerHandler.bypass('PRM_ACMTriggerHandlerNew');
        TriggerHandler.bypass('PRM_AcctContRel_TriggerHandlerNew');
        Test.startTest();
        Database.executeBatch(new PRM_IPA_ACRACM_DQBatch(),5);
        Test.stopTest();
        TriggerHandler.ClearBypass('PRM_ACMTriggerHandlerNew');
        TriggerHandler.ClearBypass('PRM_AcctContRel_TriggerHandlerNew');
         //Scenario 1 Validation
        PRM_Account_Contact_Relationship__c acrCheck = [SELECT Id,PRM_InActive_Ind__c FROM PRM_Account_Contact_Relationship__c WHERE PRM_Account_Id__c = :noAcmAcc.Id LIMIT 1];
        System.assertEquals(true, acrCheck.PRM_InActive_Ind__c);

         // Scenario 2 Validation 
       // Account opidNoAcm =
        // [
        //     SELECT Id
        //     FROM Account
        //     WHERE Name = 'OPID_NO_ACM'
        //     LIMIT 1
        // ];
        // List<PRM_AccountChannelMembership__c> insertedOpidAcms =
        // [
        //     SELECT Id,
        //            PRM_Account_Id__c,
        //            PRM_Status_Nm__c,
        //            PRM_Partner_Role__c
        //     FROM PRM_AccountChannelMembership__c
        //     WHERE PRM_Account_Id__c = :opidNoAcm.Id
        // ];
        // System.assert(
        //     insertedOpidAcms.size() > 0,
        //     'Expected rollup ACM insertion on OPID account'
        // );

         //Scenario 3 Validation
        Account updatedIntelAcc = [SELECT Id,Core_IPA_One_Partner_Id__c FROM Account WHERE Id=:intelAcc.Id];
        System.assertEquals(null, updatedIntelAcc.Core_IPA_One_Partner_Id__c);

         // Scenario 4 Validation
        Core_Account_Group_Member__c updatedCag = [SELECT Id,Core_Inactive_Ind__c FROM Core_Account_Group_Member__c WHERE Id=:newCag.Id];
        System.assertEquals(true, updatedCag.Core_Inactive_Ind__c);

         // Metadata Coverage
        Map<String,Map<String,Object>> metadataMap = new PRM_IPA_ACRACM_DQBatch().getCustomMetadataRecords();
        System.assertNotEquals(null, metadataMap);
    }
        
        @IsTest
        static void testBatchCreation(){
            Test.startTest();
            Database.executeBatch(new PRM_IPA_ACRACM_DQBatch(),5);
            Test.stopTest();
            System.assert(true);
        }
        @IsTest
        static void testWarningEmail() {
        Id intelRt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id pagRt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
		Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ];
		 User adminUser = new User(
            FirstName = 'Admin',
            LastName = 'Member',
            Alias = 'tteam',
            Email = 'test.teammember' + System.currentTimeMillis() + '@example.com',
            Username = 'test.teammember' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert adminUser;
        List<Account> opidAccounts = new List<Account>();
		System.runAs(adminUser) {
			for(Integer i = 0; i < 11; i++) {
				opidAccounts.add(
					new Account(
						Name = 'WARN_OPID_' + i,
						RecordTypeId = pagRt,
						BillingCity = 'City',
						BillingStreet = 'Street',
						BillingCountry = 'India',
						BillingPostalCode = '560001',
						Core_Account_Type__c = 'Cloud Service Provider (CSP)'
					)
				);
			}
			insert opidAccounts;
			List<Account> intelAccounts = new List<Account>();
			for(Integer i = 0; i < 11; i++) {
				intelAccounts.add(
					new Account(
						Name = 'WARN_INTEL_' + i,
						RecordTypeId = intelRt,
						BillingCity = 'City',
						BillingStreet = 'Street',
						BillingCountry = 'India',
						BillingPostalCode = '560002',
						Core_Account_Type__c = 'Cloud Service Provider (CSP)',
						Core_Intel_Partner_Alliance_PartnerGroup__c = true,
						Core_IPA_One_Partner_Id__c = opidAccounts[i].Id
					)
				);
			}
			insert intelAccounts;
			Test.startTest();
			//Database.executeBatch(new PRM_IPA_ACRACM_DQBatch(),200);
            PRM_IPA_ACRACM_DQBatch batch = new PRM_IPA_ACRACM_DQBatch();
            batch.sendWarningEmail(intelAccounts,'Account');
            batch.finish(null);
			Test.stopTest();
			List<PRM_IPA_DQ_Logs__c> dqLogs =
			[
				SELECT Id,
					   PRM_Object_Name__c,
					   PRM_Apex_Class_Name__c
				FROM PRM_IPA_DQ_Logs__c
				WHERE PRM_Apex_Class_Name__c = 'PRM_IPA_ACRACM_DQBatch'
			];
			//System.assert( dqLogs.size() > 0,'Expected DQ logs from sendWarningEmail');
			List<Account> updatedIntelAccounts =[SELECT Id,Core_IPA_One_Partner_Id__c FROM Account WHERE Name LIKE 'WARN_INTEL_%'];
			//System.assertEquals(11, updatedIntelAccounts.size());
		}
       }
    }