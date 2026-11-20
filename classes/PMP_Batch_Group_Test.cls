@IsTest
public class PMP_Batch_Group_Test {

    @testSetup
    static void setup(){

           //PARTNER ACCOUNT
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;

        Account partnerAccount = new Account(Name = 'PartnerAccount_Test',RecordTypeId = partnerAccRecTypeId,Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c = 'CCG Sales Group',Industry = 'Agriculture',BillingCountry = 'India',Core_PMP_Membership_Change_Ind__c = true);
        insert partnerAccount;
        
          // CHANNEL PROGRAM + MEMBERSHIP
        ChannelProgram cp = new ChannelProgram(Name = 'Intel Partner Alliance',PRM_programCode__c = 'IPA');
        insert cp;

        ChannelProgramLevel cpl = new ChannelProgramLevel(Name = 'Titanium',ProgramId = cp.Id);
        insert cpl;

        insert new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = partnerAccount.Id,
  			PRM_Status_Nm__c = 'Approved',
            PRM_Status_Reason_Txt__c = 'batch test',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = cpl.Id,
            PRM_Partner_Role__c = 'Distributor'
        );

           //INTEL ACCOUNT
        Id intelAccRecTypeId =Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();

        Account intelAccount = new Account(Name = 'IntelAccount_Test',RecordTypeId = intelAccRecTypeId,Core_Account_Type__c = 'System Integrator',BillingStreet = 'Bellandur',BillingCity = 'Namma Bengaluru',Core_IPA_One_Partner_Id__c = partnerAccount.Id,BillingCountry = 'India');
        insert intelAccount;

           //CONTACT
        Contact con = new Contact(
            FirstName = 'Intel',
            LastName = 'Contact',
            Email = 'contact@test.com',
            MailingCountry = 'India',
            AccountId = intelAccount.Id,
            Core_IPA_Contact_Segment__c = 'Client Computing'
        );
        insert con;

           //PARTNER USER
        Profile partnerProfile =[SELECT Id FROM Profile WHERE Name = 'Partner' LIMIT 1];

        User usr = new User(
            ProfileId = partnerProfile.Id,
            Username = 'testuser' + System.now().getTime() + '@example.com',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Alias = 'ptest',
            LastName = 'User',
            ContactId = con.Id
        );
        insert usr;

           //ENTITLEMENTS
        Core_Entitlement__c empEntitlement = new Core_Entitlement__c(Name = 'Employee',Core_Display_Name__c = 'Employee');
        insert empEntitlement;

        Core_Entitlement__c partnerAdminEnt = new Core_Entitlement__c(Name = 'partner admin',Core_Display_Name__c = 'Partner Admin');
        insert partnerAdminEnt;

        insert new Core_Contact_Entitlement__c(
            Core_Contact_Id__c = con.Id,
            Core_Entitlement_Id__c = partnerAdminEnt.Id,
            Core_Selected__c = true,
            Core_Status__c = 'Complete'
        );

           //PUBLIC GROUP SETTINGS — ADD
        insert new PMP_Public_Group_Management_Settings__c(
            Name = 'PG_RULE_1',
            PMP_Action_Txt__c = 'Add',
            PMP_Contributing_Entitlement_Nm__c = 'Employee',
            PMP_Public_Group_Nm__c = 'PMP_<OPID>'
        );

           //PUBLIC GROUP SETTINGS — REMOVE 
        insert new PMP_Public_Group_Management_Settings__c(
            Name = 'PG_RULE_REMOVE',
            PMP_Action_Txt__c = 'Remove',
            PMP_Contributing_Entitlement_Nm__c = 'Employee',
     		PMP_Public_Group_Nm__c = 'PMP_<OPID>_LeadsOfEmployee');
    }

    @IsTest
    static void testBatchExecution() {

        Test.startTest();
        Database.executeBatch(new PMP_Batch_Group_Management_Scheduler(),50);
        Test.stopTest();

        //ASSERTION
        Account updatedAcc = [SELECT Core_PMP_Membership_Change_Ind__c FROM Account WHERE Name = 'PartnerAccount_Test' LIMIT 1];

        System.assertEquals(false,updatedAcc.Core_PMP_Membership_Change_Ind__c,'Membership change flag should be reset in finish()');
    }
}