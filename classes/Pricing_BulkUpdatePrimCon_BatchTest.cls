/**
 * @description       : Test class for Bulk Primary Contact update Batch class
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 03-31-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_BulkUpdatePrimCon_BatchTest {

    @testSetup
    static void dataSetup(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('bulkPrimaryContactUpdateAdmin');
        System.runAs(adminUserList[0]){
            
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();

            //another account.
            Account acc1 = new Account();
            acc1.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);      
            acc1.Name = 'Test Account 1';
            acc1.Core_Account_Type__c = 'Distributor';
            acc1.Industry = 'Banking';
            acc1.BillingCity = 'Texas';
            acc1.BillingCountry = 'USA';
            acc1.BillingStreet = 'G-210';
            acc1.Core_Sales_Groups__c = 'Americas Brazil Sales Group';
            insert acc1;

            List<Contact> contactListwithSameAccount = Pricing_Test_Utility.createPrimaryContact(acc.Id, 2);
            Contact contactwithDiffAccount = Pricing_Test_Utility.createPrimaryContactWithParam(acc1.Id,'Bulk_Update_Prim_Con_Batch');

            //Partner Users for Test Account
            User partnerUser = Pricing_Test_Utility.createPartnerUser(acc.Id);
            
            //Drafter Limited Contact
            List<Contact> drafterLimitedContact = Pricing_Test_Utility.createDrafterLimitedContact(acc.Id, 1);

            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            AccountTeamMember accTeam1 = new AccountTeamMember(AccountId = acc1.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);

            List<AccountTeamMember> atmList = new List<AccountTeamMember>();
            atmList.add(accTeam);
            atmList.add(accTeam1);
            insert atmList;
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, partnerUser.contactId, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            Test.stopTest();
        }
    }

    static testMethod void testInvalidContact(){

        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        Contact con1 = [SELECT Id,Email FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs flowInp = new Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs();
        flowInp.newPrimaryContactInput = con1.Email;
        flowInp.oldPrimaryContactInput = 'abc@malinator.com';

        List<String> errorMsg = Pricing_BulkUpdatePrimarycontact_Batch.performBulkUpdateonPrimaryContact(new List<Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs>{flowInp});
        System.assertEquals(errorMsg[0], Label.Pricing_BulkPrimaryContactUpdate_ErrorMsg);
        Test.stopTest();

    }

    static testMethod void testContactWithSameEmail(){

        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        Contact con = [SELECT Id,Email FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
        Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs flowInp = new Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs();
        flowInp.newPrimaryContactInput = con.Email;
        flowInp.oldPrimaryContactInput = con.Email;

        List<String> errorMsg = Pricing_BulkUpdatePrimarycontact_Batch.performBulkUpdateonPrimaryContact(new List<Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs>{flowInp});
        System.assertEquals(errorMsg[0], Label.Pricing_BulkPrimaryContactUpdate_ErrorMsg);
        Test.stopTest();

    }

    static testMethod void testContactWithDifferentAccount(){

        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        Account acc1 = [SELECT Id, Name FROM Account WHERE Name = 'Test Account 1'];
        User usr = [SELECT Id,ContactId,Contact.Email,AccountId,Email,(SELECT PermissionSet.Name,AssigneeId FROM PermissionSetAssignments 
                        WHERE PermissionSet.Name IN: Label.Pricing_Tender_PermissionSets_AllExternal.Split(':')) 
                        FROM User WHERE AccountId =: acc.Id AND isActive = true AND IsPortalEnabled = true LIMIT 1];
        Contact con1 = [SELECT Id,Email FROM Contact WHERE AccountId =: acc1.Id LIMIT 1];
        Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs flowInp = new Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs();
        flowInp.newPrimaryContactInput = usr.Contact.Email;
        flowInp.oldPrimaryContactInput = con1.Email;

        List<String> errorMsg = Pricing_BulkUpdatePrimarycontact_Batch.performBulkUpdateonPrimaryContact(new List<Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs>{flowInp});
        System.assertEquals(errorMsg[0], Label.Pricing_BulkPrimaryContactUpdate_ErrorMsg);
        Test.stopTest();

    }

    static testMethod void testwithValidContactfornoQuotes(){

        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        String newEmail;
        String oldEmail;
        List<User> usrList = [SELECT Id,ContactId,Contact.Email,AccountId,Email,(SELECT PermissionSet.Name,AssigneeId FROM PermissionSetAssignments 
                        WHERE PermissionSet.Name IN: Label.Pricing_Tender_PermissionSets_AllExternal.Split(':')) 
                        FROM User WHERE AccountId =: acc.Id AND isActive = true AND IsPortalEnabled = true];

        for(User usr: usrList){
            for(PermissionSetAssignment ps: usr.PermissionSetAssignments){
                if(ps.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderPartner){
                    newEmail = usr.Contact.Email;
                }
                if(ps.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderDrafterLimited){
                    oldEmail = usr.Contact.Email;
                }
            }
        }
        Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs flowInp = new Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs();
        flowInp.newPrimaryContactInput = newEmail;
        flowInp.oldPrimaryContactInput = oldEmail;

        List<String> errorMsg = Pricing_BulkUpdatePrimarycontact_Batch.performBulkUpdateonPrimaryContact(new List<Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs>{flowInp});
        System.assertEquals(errorMsg[0], Label.Pricing_BulkPrimaryContactUpdate_ErrorMsg);
        Test.stopTest();

    }

    static testMethod void testwithValidContactwithQuotes(){
        
        Test.startTest();
        User adminUser = [Select id from User where Email='bulkPrimaryContactUpdateAdmin@intel.com' LIMIT 1];
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
        String newEmail;
        String oldEmail;
        String drafterUser;
        List<User> usrList = [SELECT Id,ContactId,Contact.Email,AccountId,Email,(SELECT PermissionSet.Name,AssigneeId FROM PermissionSetAssignments 
                        WHERE PermissionSet.Name IN: Label.Pricing_Tender_PermissionSets_AllExternal.Split(':')) 
                        FROM User WHERE AccountId =: acc.Id AND isActive = true AND IsPortalEnabled = true];

        for(User usr: usrList){
            for(PermissionSetAssignment ps: usr.PermissionSetAssignments){
                if(ps.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderPartner){
                    oldEmail = usr.Contact.Email;
                }
                if(ps.PermissionSet.Name == Label.Pricing_Tender_PermissionSets_TenderDrafterLimited){
                    newEmail = usr.Contact.Email;
                    drafterUser = usr.ContactId;

                }
            }
        }

        System.runAs(adminUser){
            List<SBQQ__Quote__c> quoteList = [SELECT Id,SBQQ__Status__c FROM SBQQ__Quote__c WHERE SBQQ__Account__c =: acc.Id];
            quoteList[0].SBQQ__Status__c = 'Submitted';
            update quoteList;

            Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs flowInp = new Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs();
            flowInp.newPrimaryContactInput = newEmail;
            flowInp.oldPrimaryContactInput = oldEmail;

            List<String> errorMsg = Pricing_BulkUpdatePrimarycontact_Batch.performBulkUpdateonPrimaryContact(new List<Pricing_BulkUpdatePrimarycontact_Batch.FlowInputs>{flowInp});
            System.assertEquals(errorMsg.size() == 0, true);
        }
        Test.stopTest();

    }
}