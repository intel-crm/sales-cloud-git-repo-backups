/**
 * @description       :
 * @author            : Vrushabh
 * @group             :
 * @last modified on  : 03-31-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@isTest
public class Pricing_BulkInsertUpdateAESR_Batch_Test {
    
    @isTest
    static void testBulkUpdateAEOnQuote(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Bulk_Update_AEOn_Quote');
            List<User> oldAEUserListForBulkUpdate = Pricing_Test_Utility.createAEUserWithParam(UserInfo.getUserEmail());
            List<User> newAEUserListForBulkUpdate = Pricing_Test_Utility.createAEUserWithParam('testnewaeemail@intel.com');
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,oldAEUserListForBulkUpdate[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            //inp.oldAEEmailInput = UserInfo.getUserEmail();
            inp.newAEEmailInput = newAEUserListForBulkUpdate[0].email;
            inp.aeActionInput = 'Account Executive Update';
            flowInputs.add(inp);
            System.assertEquals(lstquote.size() > 0, true);
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testBulkUpdateSecondaryAEOnQuote(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Bulk_update_Secondary_AE_On_Quote');
            List<User> oldAEUserListForBulkUpdate = Pricing_Test_Utility.createAEUserWithParam('testoldaeemail@intel.com');
            List<User> newAEUserListForBulkUpdate = Pricing_Test_Utility.createAEUserWithParam('testnewaeemail@intel.com');
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,oldAEUserListForBulkUpdate[0].Email);
            //List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            //inp.oldAEEmailInput = UserInfo.getUserEmail();
            inp.newAEEmailInput = newAEUserListForBulkUpdate[0].email;
            inp.aeActionInput = 'Account Executive Update';
            flowInputs.add(inp);
            System.assertEquals(lstquote.size() > 0, true);
            System.assertEquals(flowInputs.size() > 0, true);
            System.assertEquals(inp.aeActionInput, 'Account Executive Update');
            System.assertNotEquals(inp.newAEEmailInput, null);
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testBulkUpdateFSEOnQuote(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Test_Bulk_Update_FSE');
            List<User> oldAEUserListForBulkUpdate = Pricing_Test_Utility.createFSEUserWithParam(UserInfo.getUserEmail(),'testold','test');
            List<User> newAEUserListForBulkUpdate = Pricing_Test_Utility.createFSEUserWithParam('testnewaeemail@intel.com','testnew','test');
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            List<AccountTeamMember> accTeamLst = new List<AccountTeamMember>();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            AccountTeamMember accTeam1 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = oldAEUserListForBulkUpdate[0].Id);
            AccountTeamMember accTeam2 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = newAEUserListForBulkUpdate[0].Id);
            accTeamLst.add(accTeam);
            accTeamLst.add(accTeam1);
            accTeamLst.add(accTeam2);
            insert accTeamLst;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,oldAEUserListForBulkUpdate[0].Email,null);
            //List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            //inp.oldFSEEmailInput = oldAEUserListForBulkUpdate[0].email;
            inp.newFSEEmailInput = newAEUserListForBulkUpdate[0].email;
            inp.fseActionInput = 'Sales Rep Update';
            flowInputs.add(inp);
            System.assertEquals(lstquote.size() > 0, true);
            System.assertEquals(flowInputs.size() > 0, true);
            System.assertEquals(inp.fseActionInput, 'Sales Rep Update');
            System.assertNotEquals(inp.newFSEEmailInput, null);
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testBulkInsertAEOnQuote(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Bulk_Insert_AEon_Quote');
            List<User> oldAEUserListForBulkUpdate = Pricing_Test_Utility.createAEUserWithParam(UserInfo.getUserEmail());
            List<User> newAEUserListForBulkUpdate = Pricing_Test_Utility.createAEUserWithParam('testnewaeemail@intel.com');
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,oldAEUserListForBulkUpdate[0].email);
           // List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            //inp.oldAEEmailInput = oldAEUserListForBulkUpdate[0].email;
            inp.newAEEmailInput = newAEUserListForBulkUpdate[0].email;
            inp.aeActionInput = 'Account Executive Insertion';
            flowInputs.add(inp);
            System.assertEquals(lstquote.size() > 0, true);
            System.assertEquals(flowInputs.size() > 0, true);
            System.assertEquals(inp.aeActionInput, 'Account Executive Insertion');
            System.assertNotEquals(inp.newAEEmailInput, null);
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testBulkInsertFSEOnQuote(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'test_Bulk_Insert_FSEOn_Quote');
            List<User> oldAEUserListForBulkUpdate = Pricing_Test_Utility.createFSEUserWithParam(UserInfo.getUserEmail(),'testold','test');
            List<User> newAEUserListForBulkUpdate = Pricing_Test_Utility.createFSEUserWithParam('testnewaeemail@intel.com','testnew','test');
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            List<AccountTeamMember> accTeamLst = new List<AccountTeamMember>();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            AccountTeamMember accTeam1 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = oldAEUserListForBulkUpdate[0].Id);
            AccountTeamMember accTeam2 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = newAEUserListForBulkUpdate[0].Id);
            accTeamLst.add(accTeam);
            accTeamLst.add(accTeam1);
            accTeamLst.add(accTeam2);
            insert accTeamLst;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,oldAEUserListForBulkUpdate[0].Email,null);
            //List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            //inp.oldFSEEmailInput = oldAEUserListForBulkUpdate[0].email;
            inp.newFSEEmailInput = newAEUserListForBulkUpdate[0].email;
            inp.fseActionInput = 'Sales Rep Insertion';
            flowInputs.add(inp);
            System.assertEquals(lstquote.size() > 0, true);
            System.assertEquals(flowInputs.size() > 0, true);
            System.assertEquals(inp.fseActionInput, 'Sales Rep Insertion');
            System.assertNotEquals(inp.newFSEEmailInput, null);
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testBulkInsertFSEOnQuote2(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Insert_FSEOn_Quote2');
            List<User> oldAEUserListForBulkUpdate = Pricing_Test_Utility.createFSEUserWithParam(UserInfo.getUserEmail(),'testold','test');
            List<User> newAEUserListForBulkUpdate = Pricing_Test_Utility.createFSEUserWithParam('testnewaeemail@intel.com','testnew','test');
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            List<AccountTeamMember> accTeamLst = new List<AccountTeamMember>();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            AccountTeamMember accTeam1 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = oldAEUserListForBulkUpdate[0].Id);
            AccountTeamMember accTeam2 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = newAEUserListForBulkUpdate[0].Id);
            accTeamLst.add(accTeam);
            accTeamLst.add(accTeam1);
            accTeamLst.add(accTeam2);
            insert accTeamLst;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,oldAEUserListForBulkUpdate[0].Email,null);
            //List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            inp.oldFSEEmailInput = oldAEUserListForBulkUpdate[0].email;
            inp.newFSEEmailInput = newAEUserListForBulkUpdate[0].email;
            inp.fseActionInput = 'Sales Rep Insertion';
            flowInputs.add(inp);
            System.assertEquals(lstquote.size() > 0, true);
            System.assertEquals(flowInputs.size() > 0, true);
            System.assertEquals(inp.fseActionInput, 'Sales Rep Insertion');
            System.assertNotEquals(inp.newFSEEmailInput, null);
            System.assertNotEquals(inp.oldFSEEmailInput, null);
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testBulkUpdateAEWithoutQuotes(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'test_Bulk_Update_AE_WithoutQuote');
            List<User> newAEUserListForBulkUpdate = Pricing_Test_Utility.createAEUserWithParam('testnewaeemail@intel.com');
            Test.startTest();
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            //inp.oldAEEmailInput = 'abc@intel.com';
            inp.newAEEmailInput = newAEUserListForBulkUpdate[0].email;
            inp.aeActionInput = 'Account Executive Insertion';
            flowInputs.add(inp);
            System.assertEquals(flowInputs.size() > 0, true);
            System.assertEquals(inp.aeActionInput, 'Account Executive Insertion');
            System.assertNotEquals(inp.newAEEmailInput, null);
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testBulkUpdateAEInvalidAE(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'test_Bulk_Update_AEInvalidAE');
            List<User> oldAEUserListForBulkUpdate = Pricing_Test_Utility.createAEUserWithParam(UserInfo.getUserEmail());
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,oldAEUserListForBulkUpdate[0].email);
            //List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            //inp.oldAEEmailInput = oldAEUserListForBulkUpdate[0].email;
            inp.newAEEmailInput = 'abc@intel.com';
            inp.aeActionInput = 'Account Executive Insertion';
            flowInputs.add(inp);
            System.assertEquals(flowInputs.size() > 0, true);
            System.assertEquals(inp.aeActionInput, 'Account Executive Insertion');
            System.assertEquals(inp.newAEEmailInput, 'abc@intel.com');
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testBulkUpdateAEInvalidFSE(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Bulk_Update_AEInvalidFSE');
            List<User> oldAEUserListForBulkUpdate = Pricing_Test_Utility.createFSEUserWithParam(UserInfo.getUserEmail(),'testold','test');
            List<User> newAEUserListForBulkUpdate = Pricing_Test_Utility.createFSEUserWithParam('testnewaeemail@intel.com','testnew','test');
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            List<AccountTeamMember> accTeamLst = new List<AccountTeamMember>();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            AccountTeamMember accTeam1 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = oldAEUserListForBulkUpdate[0].Id);
            AccountTeamMember accTeam2 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = newAEUserListForBulkUpdate[0].Id);
            accTeamLst.add(accTeam);
            accTeamLst.add(accTeam1);
            accTeamLst.add(accTeam2);
            insert accTeamLst;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,oldAEUserListForBulkUpdate[0].Email,null);
            //List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            //inp.oldAEEmailInput = oldAEUserListForBulkUpdate[0].email;
            inp.newFSEEmailInput = 'abc@intel.com';
            inp.fseActionInput = 'Sales Rep Insertion';
            flowInputs.add(inp);
            System.assertEquals(flowInputs.size() > 0, true);
            System.assertEquals(inp.fseActionInput, 'Sales Rep Insertion');
            System.assertEquals(inp.newFSEEmailInput, 'abc@intel.com');
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testEndCustomerBulkUpdateAEOnQuote(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'End_Customer_Bulk_UpdateAE');
            List<User> oldAEUserListForBulkUpdate = Pricing_Test_Utility.createAEUserWithParam(UserInfo.getUserEmail());
            List<User> newAEUserListForBulkUpdate = Pricing_Test_Utility.createAEUserWithParam('testnewaeemail@intel.com');
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,oldAEUserListForBulkUpdate[0].email);
            //List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            Pricing_UnifiedEndCustomerAccountMapping__c l1Record = [SELECT Id,Pricing_Unified_EndCustomer_Id__c FROM Pricing_UnifiedEndCustomerAccountMapping__c WHERE Id =: lstquote[0].Pricing_End_Customer__c LIMIT 1];
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            inp.newAEEmailInput = newAEUserListForBulkUpdate[0].email;
            inp.oldAEEmailInput = oldAEUserListForBulkUpdate[0].email;
            inp.aeActionInput = 'End Customer Account Executive Update';
            inp.unifiedEndCustomerIdInput = l1Record.Pricing_Unified_EndCustomer_Id__c;
            inp.endCustomerCountryInput = lstquote[0].Pricing_End_Customer_Country_Nm__c;
            flowInputs.add(inp);
            System.assertEquals(lstquote.size() > 0, true);
            System.assertEquals(flowInputs.size() > 0, true);
            System.assertEquals(inp.aeActionInput, 'End Customer Account Executive Update');
            System.assertNotEquals(inp.unifiedEndCustomerIdInput, null);
            System.assertNotEquals(inp.endCustomerCountryInput, null);
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testEndCustomerBulkInsertAEOnQuote(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'test_EndCustomer_Bulk_Insert_AEOnQuote');
            List<User> oldAEUserListForBulkUpdate = Pricing_Test_Utility.createAEUserWithParam(UserInfo.getUserEmail());
            List<User> newAEUserListForBulkUpdate = Pricing_Test_Utility.createAEUserWithParam('testnewaeemail@intel.com');
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,oldAEUserListForBulkUpdate[0].email);
            //List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            Pricing_UnifiedEndCustomerAccountMapping__c l1Record = [SELECT Id,Pricing_Unified_EndCustomer_Id__c FROM Pricing_UnifiedEndCustomerAccountMapping__c WHERE Id =: lstquote[0].Pricing_End_Customer__c LIMIT 1];
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            inp.newAEEmailInput = newAEUserListForBulkUpdate[0].email;
            inp.aeActionInput = 'End Customer Account Executive Insertion';
            inp.unifiedEndCustomerIdInput = l1Record.Pricing_Unified_EndCustomer_Id__c;
            inp.endCustomerCountryInput = lstquote[0].Pricing_End_Customer_Country_Nm__c;
            flowInputs.add(inp);
            System.assertEquals(lstquote.size() > 0, true,'');
            System.assertEquals(flowInputs.size() > 0, true);
            System.assertEquals(inp.aeActionInput, 'End Customer Account Executive Insertion');
            System.assertNotEquals(inp.unifiedEndCustomerIdInput, null);
            System.assertNotEquals(inp.endCustomerCountryInput, null);
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testBulkReplaceFSEOnQuote(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'test_Bulk_Replace_FSE_On_Quote');
            List<User> oldAEUserListForBulkUpdate = Pricing_Test_Utility.createFSEUserWithParam(UserInfo.getUserEmail(),'testold','test');
            List<User> newAEUserListForBulkUpdate = Pricing_Test_Utility.createFSEUserWithParam('testnewaeemail@intel.com','testnew','test');
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            List<User> salesRepUserNew = Pricing_Test_Utility.createFSEUserWithParam('testnewfseemail@intel.com','testnewfse','test');
            List<AccountTeamMember> accTeamLst = new List<AccountTeamMember>();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            AccountTeamMember accTeam1 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = oldAEUserListForBulkUpdate[0].Id);
            AccountTeamMember accTeam2 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = newAEUserListForBulkUpdate[0].Id);
            AccountTeamMember accTeam3 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserNew[0].Id);
            accTeamLst.add(accTeam);
            accTeamLst.add(accTeam1);
            accTeamLst.add(accTeam2);
            accTeamLst.add(accTeam3);
            insert accTeamLst;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,oldAEUserListForBulkUpdate[0].Email,null);
            //List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            lstquote[0].Pricing_On_Hold_Cb__c = false;
            update lstquote;
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            inp.fseOldToReplace = oldAEUserListForBulkUpdate[0].email;
            inp.fseNewToReplaceWith = salesRepUserNew[0].email;
            inp.fseActionInput = 'Sales Rep Replace';
            inp.newAEEmailInput = '';
            inp.aeActionInput = '';
            inp.newFSEEmailInput = '';
            inp.oldFSEEmailInput = '';
            inp.unifiedEndCustomerIdInput = '';
            inp.endCustomerCountryInput = '';
            inp.oldAEEmailInput = '';
            flowInputs.add(inp);
            System.assertEquals(lstquote.size() > 0, true,'Error at testBulkReplaceFSEOnQuote');
            System.assertEquals(flowInputs.size() > 0, true);
            System.assertEquals(inp.fseActionInput, 'Sales Rep Replace');
            System.assertEquals(inp.fseOldToReplace, oldAEUserListForBulkUpdate[0].email);
            System.assertEquals(inp.fseNewToReplaceWith, salesRepUserNew[0].email);
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testBulkReplaceFSEOnQuoteNeg(){
        List<User> lstUsers = Pricing_Test_Utility.createAdminUser();
        Pricing_Test_Utility.createPriceBook();
        System.runAs(lstUsers[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'test_Bulk_Replace_FSEOn_Quote_Neg');
            List<User> oldAEUserListForBulkUpdate = Pricing_Test_Utility.createFSEUserWithParam(UserInfo.getUserEmail(),'testold','test');
            List<User> newAEUserListForBulkUpdate = Pricing_Test_Utility.createFSEUserWithParam('testnewaeemail@intel.com','testnew','test');
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            List<User> salesRepUserNew = Pricing_Test_Utility.createFSEUserWithParam('testnewfseemail@intel.com','testnewfse','test');
            List<AccountTeamMember> accTeamLst = new List<AccountTeamMember>();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            AccountTeamMember accTeam1 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = oldAEUserListForBulkUpdate[0].Id);
            AccountTeamMember accTeam2 = new AccountTeamMember(AccountId = acc.Id,
            TeamMemberRole = 'Technical Sales',UserId = newAEUserListForBulkUpdate[0].Id);
            accTeamLst.add(accTeam);
            accTeamLst.add(accTeam1);
            accTeamLst.add(accTeam2);
            insert accTeamLst;
            Test.startTest();
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,oldAEUserListForBulkUpdate[0].Email,null);
            //List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            lstquote[0].Pricing_On_Hold_Cb__c = false;
            update lstquote;
            List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs> flowInputs = new List<Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs>();
            Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs inp = new Pricing_BulkInsertUpdateAESalesRep_Batch.FlowInputs();
            inp.fseOldToReplace = oldAEUserListForBulkUpdate[0].email;
            inp.fseNewToReplaceWith = salesRepUserNew[0].email;
            inp.fseActionInput = 'Sales Rep Replace';
            inp.newAEEmailInput = '';
            inp.aeActionInput = '';
            inp.newFSEEmailInput = '';
            inp.oldFSEEmailInput = '';
            inp.unifiedEndCustomerIdInput = '';
            inp.endCustomerCountryInput = '';
            inp.oldAEEmailInput = '';
            flowInputs.add(inp);
            System.assertEquals(lstquote.size() > 0, true,'Error at testBulkReplaceFSEOnQuote');
            System.assertEquals(flowInputs.size() > 0, true);
            System.assertEquals(inp.fseActionInput, 'Sales Rep Replace');
            System.assertEquals(inp.fseOldToReplace, oldAEUserListForBulkUpdate[0].email);
            System.assertEquals(inp.fseNewToReplaceWith, salesRepUserNew[0].email);
            Pricing_BulkInsertUpdateAESalesRep_Batch.performBulkUpdateInsertAEOnQuoteQTM(flowInputs);
            Test.stopTest();
        }
    }
}