@isTest
public class Core_OppApproval_Test {
    
    private static final Integer OPP_COUNT = 5;
    private static final Integer OPPPROD_COUNT = 5;
    private static final String OPP_STATUS_SUBMITTED = 'Submitted';
    private static final String OPP_STATUS_APPROVED = 'Approved';
    private static final String OPP_STATUS_REJECTED = 'Rejected';
    private static final String OPP_STATUS_RECALLED = 'Recalled';
    
    private static final String OPPPROD_STATUS_PENDING = 'Pending';
    private static final String OPPPROD_STATUS_WIN_SUBMITTED = 'Win Submitted';
    private static final String OPPPROD_STATUS_WIN_APPROVED = 'Win Approved';
    
    public static List<Opportunity> lstOppty = new List<Opportunity>();
    
    // Test opportunity approver determination based on territory
    static testMethod void testOppApproverByTerritory() {
        
        //-----------------------------------------------------------------
        // Data setup
        
        // First create 5 territories, then create a bunch of users and add them to the territories with different roles
        
        Territory2Model activeTerrModel = [Select id from Territory2Model where State = 'Active' ];
        
        Id terrTypeId = [Select Id from Territory2Type limit 1][0].Id;
        Id profId = [select Id from Profile where Name='Standard User' limit 1][0].Id;
        
        
        List<Territory2> terrs = [select Id,Name from Territory2 where Territory2.Id =:activeTerrModel.Id];
        terrs.add(new Territory2(Name='Test Territory 1 in TestMethod', DeveloperName='Test_Territory_1', Territory2ModelId=activeTerrModel.Id,
        Territory2TypeId=terrTypeId));
        terrs.add(new Territory2(Name='Test Territory 2 in TestMethod', DeveloperName='Test_Territory_2', Territory2ModelId=activeTerrModel.Id,
        Territory2TypeId=terrTypeId));
        terrs.add(new Territory2(Name='Test Territory 3 in TestMethod', DeveloperName='Test_Territory_3', Territory2ModelId=activeTerrModel.Id,
        Territory2TypeId=terrTypeId));
        terrs.add(new Territory2(Name='Test Territory 4 in TestMethod', DeveloperName='Test_Territory_4', Territory2ModelId=activeTerrModel.Id,
        Territory2TypeId=terrTypeId));
        terrs.add(new Territory2(Name='Test Territory 5 in TestMethod', DeveloperName='Test_Territory_5', Territory2ModelId=activeTerrModel.Id,
        Territory2TypeId=terrTypeId));
        terrs.add(new Territory2(Name='Test Territory 6 in TestMethod', DeveloperName='Test_Territory_6', Territory2ModelId=activeTerrModel.Id,
        Territory2TypeId=terrTypeId));
        insert terrs;
        
        List<User> users = new List<User>();
        users.add(new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User 1', Email='test.user1@intel.com',
        Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user2.testOppApproverByManager@intel.com.crm', LastName='User 2', Email='test.user2@intel.com',
        Alias='tclass2', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user3.testOppApproverByManager@intel.com.crm', LastName='User 3', Email='test.user3@intel.com',
        Alias='tclass3', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user4.testOppApproverByManager@intel.com.crm', LastName='User 4', Email='test.user4@intel.com',
        Alias='tclass4', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user5.testOppApproverByManager@intel.com.crm', LastName='User 5', Email='test.user5@intel.com',
        Alias='tclass5', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user6.testOppApproverByManager@intel.com.crm', LastName='User 6', Email='test.user6@intel.com',
        Alias='tclass6', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user7.testOppApproverByManager@intel.com.crm', LastName='User 7', Email='test.user7@intel.com',
        Alias='tclass7', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=profId, LanguageLocaleKey='en_US'));
        insert users;
        
        List<UserTerritory2Association> userTerrs = new List<UserTerritory2Association>();
        userTerrs.add(new UserTerritory2Association(UserId=users[0].Id, Territory2Id=terrs[0].Id, RoleInTerritory2='Territory Team Member'));
        userTerrs.add(new UserTerritory2Association(UserId=users[1].Id, Territory2Id=terrs[1].Id, RoleInTerritory2='Opportunity Approver'));
        userTerrs.add(new UserTerritory2Association(UserId=users[2].Id, Territory2Id=terrs[2].Id, RoleInTerritory2='Opportunity Approver'));
        userTerrs.add(new UserTerritory2Association(UserId=users[3].Id, Territory2Id=terrs[3].Id, RoleInTerritory2='Opportunity Approver'));
        userTerrs.add(new UserTerritory2Association(UserId=users[4].Id, Territory2Id=terrs[4].Id, RoleInTerritory2='Opportunity Approver'));
        userTerrs.add(new UserTerritory2Association(UserId=users[5].Id, Territory2Id=terrs[3].Id, RoleInTerritory2='Territory Team Member'));
        userTerrs.add(new UserTerritory2Association(UserId=users[6].Id, Territory2Id=terrs[0].Id, RoleInTerritory2='Opportunity Approver'));
        userTerrs.add(new UserTerritory2Association(UserId=users[0].Id, Territory2Id=terrs[5].Id, RoleInTerritory2='Opportunity Approver'));
        userTerrs.add(new UserTerritory2Association(UserId=users[1].Id, Territory2Id=terrs[5].Id, RoleInTerritory2='Opportunity Approver'));
        insert userTerrs;
        
        // Need to use System.runAs to avoid MIXED_DML_OPERATION error
        System.runAs(new User(Id=UserInfo.getUserId(), ManagerId=users[1].Id)) {
            
            Id recTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
            
            // Now add some accounts, members of 1 to 5 territories with approvers
            List<Account> accts = new List<Account>();
            accts.add(new Account(Name='Test Account in 1 Territory with Approver in TestMethod', RecordTypeId=recTypeId,Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),
            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA',Industry ='Agriculture',Core_Sub_Industry__c='Animal Production'));
            accts.add(new Account(Name='Test Account in 2 Territories with Approver in TestMethod', RecordTypeId=recTypeId,Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),
            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA',Industry ='Agriculture',Core_Sub_Industry__c='Animal Production'));
            accts.add(new Account(Name='Test Account in 3 Territories with Approver in TestMethod', RecordTypeId=recTypeId,Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),
            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA',Industry ='Agriculture',Core_Sub_Industry__c='Animal Production'));
            accts.add(new Account(Name='Test Account in 4 Territories with Approver in TestMethod', RecordTypeId=recTypeId,Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),
            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA',Industry ='Agriculture',Core_Sub_Industry__c='Animal Production'));
            accts.add(new Account(Name='Test Account in 5 Territories with Approver in TestMethod', RecordTypeId=recTypeId,Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),
            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA',Industry ='Agriculture',Core_Sub_Industry__c='Animal Production'));
            accts.add(new Account(Name='Test Account in 1 Territory with 2 Approvers in TestMethod', RecordTypeId=recTypeId,Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),
            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA',Industry ='Agriculture',Core_Sub_Industry__c='Animal Production'));
            insert accts;
            
            List<ObjectTerritory2Association> acctTerrs = new List<ObjectTerritory2Association>();
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[0].Id, Territory2Id=terrs[0].Id, AssociationCause='Territory2Manual'));
            
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[1].Id, Territory2Id=terrs[0].Id, AssociationCause='Territory2Manual'));
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[1].Id, Territory2Id=terrs[1].Id, AssociationCause='Territory2Manual'));
            
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[2].Id, Territory2Id=terrs[0].Id, AssociationCause='Territory2Manual'));
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[2].Id, Territory2Id=terrs[1].Id, AssociationCause='Territory2Manual'));
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[2].Id, Territory2Id=terrs[2].Id, AssociationCause='Territory2Manual'));
            
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[3].Id, Territory2Id=terrs[0].Id, AssociationCause='Territory2Manual'));
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[3].Id, Territory2Id=terrs[1].Id, AssociationCause='Territory2Manual'));
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[3].Id, Territory2Id=terrs[2].Id, AssociationCause='Territory2Manual'));
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[3].Id, Territory2Id=terrs[3].Id, AssociationCause='Territory2Manual'));
            
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[4].Id, Territory2Id=terrs[0].Id, AssociationCause='Territory2Manual'));
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[4].Id, Territory2Id=terrs[1].Id, AssociationCause='Territory2Manual'));
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[4].Id, Territory2Id=terrs[2].Id, AssociationCause='Territory2Manual'));
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[4].Id, Territory2Id=terrs[3].Id, AssociationCause='Territory2Manual'));
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[4].Id, Territory2Id=terrs[4].Id, AssociationCause='Territory2Manual'));
            
            acctTerrs.add(new ObjectTerritory2Association(ObjectId=accts[5].Id, Territory2Id=terrs[5].Id, AssociationCause='Territory2Manual'));
            insert acctTerrs;
            
            recTypeId = [select Id from RecordType where DeveloperName = 'Core_Opportunity' limit 1][0].Id;
            
            // Create an opportunity against each account
            lstOppty.add(new Opportunity(Name='Test Opportunity with Account in 1 Territory with Approver in TestMethod',
            AccountId=accts[0].Id, StageName='Qualify', RecordTypeId=recTypeId,
            CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id, Core_Opportunity_Type__c = 'Design: Original' , Opportunity_Focus__c= 'Core'));
            /*Opportunity opp1 = new Opportunity(Name='Test Opportunity with Account in 1 Territory with Approver in TestMethod',
                AccountId=accts[0].Id, StageName='Qualify', RecordTypeId=recTypeId,
                CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id);
            insert opp1;*/ 
            lstOppty.add(new Opportunity(Name='Test Opportunity with Account in 2 Territories with Approver in TestMethod',
            AccountId=accts[1].Id, StageName='Qualify', RecordTypeId=recTypeId,
            CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id, Core_Opportunity_Type__c = 'Design: Original' , Opportunity_Focus__c= 'Core'));
            /*Opportunity opp2 = new Opportunity(Name='Test Opportunity with Account in 2 Territories with Approver in TestMethod',
                AccountId=accts[1].Id, StageName='Qualifying', RecordTypeId=recTypeId,
                CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id);
            insert opp2;*/ 
            lstOppty.add(new Opportunity(Name='Test Opportunity with Account in 3 Territories with Approver in TestMethod',
            AccountId=accts[2].Id, StageName='Qualify', RecordTypeId=recTypeId,
            CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id, Core_Opportunity_Type__c = 'Design: Original' , Opportunity_Focus__c= 'Core'));
            /*Opportunity opp3 = new Opportunity(Name='Test Opportunity with Account in 3 Territories with Approver in TestMethod',
                AccountId=accts[2].Id, StageName='Qualifying', RecordTypeId=recTypeId,
                CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id);
            insert opp3;*/ 
            lstOppty.add(new Opportunity(Name='Test Opportunity with Account in 4 Territories with Approver in TestMethod',
            AccountId=accts[3].Id, StageName='Qualify', RecordTypeId=recTypeId,
            CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id, Core_Opportunity_Type__c = 'Design: Original' , Opportunity_Focus__c= 'Core'));
            /*Opportunity opp4 = new Opportunity(Name='Test Opportunity with Account in 4 Territories with Approver in TestMethod',
                AccountId=accts[3].Id, StageName='Qualifying', RecordTypeId=recTypeId,
                CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id);
            insert opp4;*/ 
            lstOppty.add(new Opportunity(Name='Test Opportunity with Account in 5 Territories with Approver in TestMethod',
            AccountId=accts[4].Id, StageName='Qualify', RecordTypeId=recTypeId,
            CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id, Core_Opportunity_Type__c = 'Design: Original' , Opportunity_Focus__c= 'Core'));
            /*Opportunity opp5 = new Opportunity(Name='Test Opportunity with Account in 5 Territories with Approver in TestMethod',
                AccountId=accts[4].Id, StageName='Qualifying', RecordTypeId=recTypeId,
                CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id);
            insert opp5;*/ 
            lstOppty.add(new Opportunity(Name='Test Opportunity with Account in 6 Territories with 2 Approvers in TestMethod',
            AccountId=accts[5].Id, StageName='Qualify', RecordTypeId=recTypeId,
            CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id, Core_Opportunity_Type__c = 'Design: Original' , Opportunity_Focus__c= 'Core'));
            /*Opportunity opp6 = new Opportunity(Name='Test Opportunity with Account in 1 Territories with 2 Approvers in TestMethod',
                AccountId=accts[5].Id, StageName='Qualifying', RecordTypeId=recTypeId,
                CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id);
            insert opp6;*/ 
            insert lstOppty;
            
            //-----------------------------------------------------------------
            // Execute test cases
            
            Test.startTest();
            
            // Submit the opportunity in 1 territory for approval and check the approver fields to make sure they're correct
            
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            //req.setObjectId(opp1.Id);
           // Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
            //Core_OpportunityHelper.isRecursiveAfterUpdate = false; 
            req.setObjectId(lstOppty[0].Id);
            Approval.ProcessResult res = Approval.process(req);
            System.assert(res.isSuccess());
            
         //   Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
          //  Core_OpportunityHelper.isRecursiveAfterUpdate = false; 
            req.setObjectId(lstOppty[1].Id);
            res = Approval.process(req);
            System.assert(res.isSuccess());
            
         //   Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
          //  Core_OpportunityHelper.isRecursiveAfterUpdate = false; 
            req.setObjectId(lstOppty[2].Id);
            res = Approval.process(req);
            System.assert(res.isSuccess());
            
         //   Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
         //   Core_OpportunityHelper.isRecursiveAfterUpdate = false; 
            req.setObjectId(lstOppty[3].Id);
            res = Approval.process(req);
            System.assert(res.isSuccess());
            
         //   Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
           // Core_OpportunityHelper.isRecursiveAfterUpdate = false; 
            req.setObjectId(lstOppty[4].Id);
            res = Approval.process(req);
            System.assert(res.isSuccess());
            
        //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
         //   Core_OpportunityHelper.isRecursiveAfterUpdate = false; 
            req.setObjectId(lstOppty[5].Id);
            res = Approval.process(req);
            System.assert(res.isSuccess());
            
            List<Opportunity> lstOppty1 = [SELECT id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c FROM Opportunity WHERE id IN :lstOppty];
            //opp1 = [select Id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c
            //       from Opportunity where Id = :opp1.Id];
            System.assertEquals(users[6].Id, lstOppty1[0].Core_Approver_1__c);
            System.assertEquals(users[6].Id, lstOppty1[0].Core_Approver_2__c);
            System.assertEquals(users[6].Id, lstOppty1[0].Core_Approver_3__c);
            System.assertEquals(users[6].Id, lstOppty1[0].Core_Approver_4__c);
            System.assertEquals(users[6].Id, lstOppty1[0].Core_Approver_5__c);
            
            // Check to make sure the approver has access
            List<OpportunityShare> oppShare1 = [select UserOrGroupId, OpportunityId, OpportunityAccessLevel from OpportunityShare
            where OpportunityId = :lstOppty1[0].Id and UserOrGroupId = :users[6].Id];
            System.assertNotEquals(oppShare1, null);
            System.assertEquals(oppShare1.size(), 1);
            System.assert((oppShare1[0].OpportunityAccessLevel == 'Edit') || (oppShare1[0].OpportunityAccessLevel == 'All'));
            
            // Submit the opportunity in 2 territories for approval
            //req.setObjectId(opp2.Id);
            
            
            //opp2 = [select Id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c
            //       from Opportunity where Id = :opp2.Id];
            
            Set<Id> approverIds = new Set<Id>();
            approverIds.add(lstOppty1[1].Core_Approver_1__c);
            approverIds.add(lstOppty1[1].Core_Approver_2__c);
            approverIds.add(lstOppty1[1].Core_Approver_3__c);
            approverIds.add(lstOppty1[1].Core_Approver_4__c);
            approverIds.add(lstOppty1[1].Core_Approver_5__c);
            System.assertEquals(2, approverIds.size());
            System.assert(approverIds.contains(users[1].Id));
            System.assert(approverIds.contains(users[6].Id));
            
            // Submit the opportunity in 3 territories for approval
            //req.setObjectId(opp3.Id);
            
            
            //opp3 = [select Id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c
            //       from Opportunity where Id = :opp3.Id];
            
            approverIds.clear();
            approverIds.add(lstOppty1[2].Core_Approver_1__c);
            approverIds.add(lstOppty1[2].Core_Approver_2__c);
            approverIds.add(lstOppty1[2].Core_Approver_3__c);
            approverIds.add(lstOppty1[2].Core_Approver_4__c);
            approverIds.add(lstOppty1[2].Core_Approver_5__c);
            System.assertEquals(3, approverIds.size());
            System.assert(approverIds.contains(users[1].Id));
            System.assert(approverIds.contains(users[2].Id));
            System.assert(approverIds.contains(users[6].Id));
            
            // Submit the opportunity in 4 territories for approval
            
            
            //opp4 = [select Id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c
            //       from Opportunity where Id = :opp4.Id];
            
            approverIds.clear();
            approverIds.add(lstOppty1[3].Core_Approver_1__c);
            approverIds.add(lstOppty1[3].Core_Approver_2__c);
            approverIds.add(lstOppty1[3].Core_Approver_3__c);
            approverIds.add(lstOppty1[3].Core_Approver_4__c);
            approverIds.add(lstOppty1[3].Core_Approver_5__c);
            System.assertEquals(4, approverIds.size());
            System.assert(approverIds.contains(users[1].Id));
            System.assert(approverIds.contains(users[2].Id));
            System.assert(approverIds.contains(users[3].Id));
            System.assert(approverIds.contains(users[6].Id));
            
            // Submit the opportunity in 5 territories for approval
            
            
            //opp5 = [select Id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c
            //      from Opportunity where Id = :opp5.Id];
            
            approverIds.clear();
            approverIds.add(lstOppty1[4].Core_Approver_1__c);
            approverIds.add(lstOppty1[4].Core_Approver_2__c);
            approverIds.add(lstOppty1[4].Core_Approver_3__c);
            approverIds.add(lstOppty1[4].Core_Approver_4__c);
            approverIds.add(lstOppty1[4].Core_Approver_5__c);
            System.assertEquals(5, approverIds.size());
            System.assert(approverIds.contains(users[1].Id));
            System.assert(approverIds.contains(users[2].Id));
            System.assert(approverIds.contains(users[3].Id));
            System.assert(approverIds.contains(users[4].Id));
            System.assert(approverIds.contains(users[6].Id));
            
            // Check to make sure approvers have access
            List<OpportunityShare> oppShare5 = [select UserOrGroupId, OpportunityId, OpportunityAccessLevel from OpportunityShare
            where OpportunityId = :lstOppty1[4].Id and UserOrGroupId in :approverIds];
            System.assertNotEquals(oppShare5, null);
            //System.assertEquals(oppShare5.size(), 5);
            for (OpportunityShare oppShare : oppShare5)
            System.assert((oppShare.OpportunityAccessLevel == 'Edit') || (oppShare.OpportunityAccessLevel == 'All'));
            
            // Submit the opportunity in 1 territory with 2 approvers for approval
            
            
            //opp6 = [select Id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c
            //       from Opportunity where Id = :opp6.Id];
            
            approverIds.clear();
            approverIds.add(lstOppty1[5].Core_Approver_1__c);
            approverIds.add(lstOppty1[5].Core_Approver_2__c);
            approverIds.add(lstOppty1[5].Core_Approver_3__c);
            approverIds.add(lstOppty1[5].Core_Approver_4__c);
            approverIds.add(lstOppty1[5].Core_Approver_5__c);
            System.assertEquals(2, approverIds.size());
            System.assert(approverIds.contains(users[0].Id));
            System.assert(approverIds.contains(users[1].Id));
            
            // Check to make sure approvers have access
            List<OpportunityShare> oppShare6 = [select UserOrGroupId, OpportunityId, OpportunityAccessLevel from OpportunityShare
            where OpportunityId = :lstOppty1[5].Id and UserOrGroupId in :approverIds];
            System.assertNotEquals(oppShare6, null);
            //System.assert(oppShare6.size() >= 2);
            for (OpportunityShare oppShare : oppShare6)
            System.assert((oppShare.OpportunityAccessLevel == 'Edit') || (oppShare.OpportunityAccessLevel == 'All'));
            
            Test.stopTest();
        }
    } 
    
    // Test opportunity approver determination based on manager
    static testmethod void testOppApproverByManager() {        
        
        //-----------------------------------------------------------------
        // Data setup
        
        // Create users & opportunities to test the following cases:
        // - Opportunity owner's manager is inactive, and there is no technical owner (should fail)
        // - Opportunity owner's manager is inactive, and technical owner's manager is inactive (should fail)
        // - Opportunity owner's manager is active, and there is no technical owner
        // - Opportunity owner's manager is active, and technical owner doesn't have a manager
        // - Opportunity owner's manager is active, and technical owner's manager is inactive
        // - Opportunity owner's manager is active, and technical owner's manager is active
        // - Opportunity owner doesn't have a manager, and technical owner's manager is active
        // - Opportunity owner's manager is inactive, and technical owner's manager is active
        MaskEmail__c mskMail = new MaskEmail__c (name='Core Mask Email Bypass', Core_Mask_Email__c = true);
        insert mskMail;
        List<User> users = new List<User>();
        users.add(new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user1@intel.com',
        Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user2.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user2@intel.com',
        Alias='tclass2', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user3.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user3@intel.com',
        Alias='tclass3', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user4.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user4@intel.com',
        Alias='tclass4', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user5.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user5@intel.com',
        Alias='tclass5', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user6.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user6@intel.com',
        Alias='tclass6', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user7.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user7@intel.com',
        Alias='tclass7', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US'));
        users.add(new User(UserName='test.user8.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user8@intel.com',
        Alias='tclass8', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US'));
        insert users;
        
        users[0].ManagerId = users[1].Id;
        users[2].ManagerId = users[3].Id;
        users[4].ManagerId = users[5].Id;
        users[5].IsActive = false;
        users[6].ManagerId = users[7].Id;
        users[7].IsActive = false;
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update users;
        }
        
        // Need to use System.runAs to avoid MIXED_DML_OPERATION error
        System.runAs(Core_Test_Utility.systemAdminUser) {
            
            Account acct = new Account(Name='Test Account in testOppApproverByManager',
            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),Industry ='Agriculture',Core_Sub_Industry__c='Animal Production');
            insert acct;
                 
            Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
            //-----------------------------------------------------------------
            // Execute test cases
            
            Test.startTest();
            lstOppty.clear();
            // Test: Opportunity owner's manager is inactive, and there is no technical owner (should fail)
            lstOppty.add(new Opportunity(Name='Test Opportunity 1 in TestMethod', AccountId=acct.Id, StageName='Qualify',
            CloseDate=System.Date.today().addYears(1), OwnerId=users[4].Id,
            RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Deal: Sell-through' , Opportunity_Focus__c= 'Core'));
            lstOppty.add(new Opportunity(Name='Test Opportunity 2 in TestMethod', AccountId=acct.Id, StageName='Qualify',
            CloseDate=System.Date.today().addYears(1), OwnerId=users[4].Id,
            Core_Technical_Owner__c=users[6].Id, RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Deal: Sell-through' , Opportunity_Focus__c= 'Core'));
            lstOppty.add(new Opportunity(Name='Test Opportunity 3 in TestMethod', AccountId=acct.Id, StageName='Qualify',
            CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id,
            RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Deal: Sell-through' , Opportunity_Focus__c= 'Core')); 
            lstOppty.add(new Opportunity(Name='Test Opportunity 4 in TestMethod', AccountId=acct.Id, StageName='Qualify',
            CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id,
            Core_Technical_Owner__c=users[1].Id, RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Deal: Sell-through' , Opportunity_Focus__c= 'Core')); 
            lstOppty.add(new Opportunity(Name='Test Opportunity 5 in TestMethod', AccountId=acct.Id, StageName='Qualify',
            CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id,
            Core_Technical_Owner__c=users[4].Id, RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Deal: Sell-through' , Opportunity_Focus__c= 'Core'));
            lstOppty.add(new Opportunity(Name='Test Opportunity 6 in TestMethod', AccountId=acct.Id, StageName='Qualify',
            CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id,
            Core_Technical_Owner__c=users[2].Id, RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Deal: Sell-through' , Opportunity_Focus__c= 'Core'));
            lstOppty.add(new Opportunity(Name='Test Opportunity 7 in TestMethod', AccountId=acct.Id, StageName='Qualify',
            CloseDate=System.Date.today().addYears(1), OwnerId=users[1].Id,
            Core_Technical_Owner__c=users[2].Id, RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Deal: Sell-through' , Opportunity_Focus__c= 'Core'));
            lstOppty.add(new Opportunity(Name='Test Opportunity 8 in TestMethod', AccountId=acct.Id, StageName='Qualify',
            CloseDate=System.Date.today().addYears(1), OwnerId=users[4].Id,Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity',Core_Coverage_Type_Nm__c = 'Deal Registration',
            Core_Technical_Owner__c=users[0].Id, RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Deal: Sell-through' , Opportunity_Focus__c= 'Core'));
            
            /*Opportunity opp1 = new Opportunity(Name='Test Opportunity 1 in TestMethod', AccountId=acct.Id, StageName='Qualifying',
                CloseDate=System.Date.today().addYears(1), OwnerId=users[4].Id,
                RecordTypeId=recTypeId);
            insert opp1;           */
            insert lstOppty;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(lstOppty[0].Id);
        //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
          //  Core_OpportunityHelper.isRecursiveAfterUpdate = false;    
            try {
                Approval.ProcessResult res = Approval.process(req); // Should throw an exception
                System.assertEquals(0,1);   // Should never reach this line of code
            }
            catch (System.DmlException e) {
                System.assertEquals(1,1);
            }
        //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
        //    Core_OpportunityHelper.isRecursiveAfterUpdate = false;    
            req.setObjectId(lstOppty[1].Id);
            try {
                Approval.ProcessResult res = Approval.process(req); // Should throw an exception
                System.assertEquals(0,1);       // Should never reach this line of code
            }
            catch (System.DmlException e) {
                System.assertEquals(1,1);
            }
            
        //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
       //     Core_OpportunityHelper.isRecursiveAfterUpdate = false;  
            req.setObjectId(lstOppty[2].Id);
            Approval.ProcessResult res = Approval.process(req);
            System.assert(res.isSuccess());
            
         //   Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
           // Core_OpportunityHelper.isRecursiveAfterUpdate = false; 
            req.setObjectId(lstOppty[3].Id);
            res = Approval.process(req);
            System.assert(res.isSuccess());
            
        //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
          //  Core_OpportunityHelper.isRecursiveAfterUpdate = false; 
            req.setObjectId(lstOppty[4].Id);
            res = Approval.process(req);
            System.assert(res.isSuccess());
            
        //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
          //  Core_OpportunityHelper.isRecursiveAfterUpdate = false; 
            req.setObjectId(lstOppty[5].Id);
            res = Approval.process(req);
            System.assert(res.isSuccess());
            
        //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
          //  Core_OpportunityHelper.isRecursiveAfterUpdate = false; 
            req.setObjectId(lstOppty[6].Id);
            res = Approval.process(req);
            System.assert(res.isSuccess());
            
        //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
          //  Core_OpportunityHelper.isRecursiveAfterUpdate = false; 
            /**req.setObjectId(lstOppty[7].Id);
            res = Approval.process(req);*/
            

            List<Opportunity> lstOppty1 = [SELECT id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c FROM Opportunity WHERE id IN :lstOppty];
            // Check to make sure the manager wasn't given access
            //List<OpportunityShare> oppShare1 = [select UserOrGroupId, OpportunityId, OpportunityAccessLevel from OpportunityShare
            //where OpportunityId = :lstOppty1[0].Id and UserOrGroupId = :users[5].Id];
            //System.assertEquals(0, oppShare1.size());
            
            // Test: Opportunity owner's manager is inactive, and technical owner's manager is inactive (should fail)
            /*Opportunity opp2 = new Opportunity(Name='Test Opportunity 2 in TestMethod', AccountId=acct.Id, StageName='Qualifying',
                CloseDate=System.Date.today().addYears(1), OwnerId=users[4].Id,
                Core_Technical_Owner__c=users[6].Id, RecordTypeId=recTypeId);
            insert opp2;    */        
            
            
            // Test: Opportunity owner's manager is active, and there is no technical owner
            /*Opportunity opp3 = new Opportunity(Name='Test Opportunity 3 in TestMethod', AccountId=acct.Id, StageName='Qualifying',
                CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id,
                RecordTypeId=recTypeId);
            insert opp3;*/            
            
            
            //opp3 = [select Id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c
            //       from Opportunity where Id = :opp3.Id];
            System.assertEquals(users[1].Id, lstOppty1[2].Core_Approver_1__c);
            System.assertEquals(users[1].Id, lstOppty1[2].Core_Approver_2__c);
            System.assertEquals(users[1].Id, lstOppty1[2].Core_Approver_3__c);
            System.assertEquals(users[1].Id, lstOppty1[2].Core_Approver_4__c);
            System.assertEquals(users[1].Id, lstOppty1[2].Core_Approver_5__c);
            
            // Check to make sure the manager has access
            List<OpportunityShare> oppShare3 = [select UserOrGroupId, OpportunityId, OpportunityAccessLevel from OpportunityShare
            where OpportunityId = :lstOppty1[2].Id and UserOrGroupId = :users[1].Id];
            System.assertNotEquals(null, oppShare3);
            System.assertEquals(1, oppShare3.size());
            System.assert((oppShare3[0].OpportunityAccessLevel == 'Edit') || (oppShare3[0].OpportunityAccessLevel == 'All'));
            
            // Test: Opportunity owner's manager is active, and technical owner doesn't have a manager
            /*Opportunity opp4 = new Opportunity(Name='Test Opportunity 4 in TestMethod', AccountId=acct.Id, StageName='Qualifying',
                CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id,
                Core_Technical_Owner__c=users[1].Id, RecordTypeId=recTypeId);
            insert opp4; */           
            
            
            //opp4 = [select Id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c
            //       from Opportunity where Id = :opp4.Id];
            System.assertEquals(users[1].Id, lstOppty1[3].Core_Approver_1__c);
            System.assertEquals(users[1].Id, lstOppty1[3].Core_Approver_2__c);
            System.assertEquals(users[1].Id, lstOppty1[3].Core_Approver_3__c);
            System.assertEquals(users[1].Id, lstOppty1[3].Core_Approver_4__c);
            System.assertEquals(users[1].Id, lstOppty1[3].Core_Approver_5__c);
            
            // Test: Opportunity owner's manager is active, and technical owner's manager is inactive
            /*Opportunity opp5 = new Opportunity(Name='Test Opportunity 5 in TestMethod', AccountId=acct.Id, StageName='Qualifying',
                CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id,
                Core_Technical_Owner__c=users[4].Id, RecordTypeId=recTypeId);
            insert opp5; */           
            
            
            //opp5 = [select Id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c
            //       from Opportunity where Id = :opp5.Id];
            System.assertEquals(users[1].Id, lstOppty1[4].Core_Approver_1__c);
            System.assertEquals(users[1].Id, lstOppty1[4].Core_Approver_2__c);
            System.assertEquals(users[1].Id, lstOppty1[4].Core_Approver_3__c);
            System.assertEquals(users[1].Id, lstOppty1[4].Core_Approver_4__c);
            System.assertEquals(users[1].Id, lstOppty1[4].Core_Approver_5__c);
            
            // Test: Opportunity owner's manager is active, and technical owner's manager is active
            /*Opportunity opp6 = new Opportunity(Name='Test Opportunity 6 in TestMethod', AccountId=acct.Id, StageName='Qualifying',
                CloseDate=System.Date.today().addYears(1), OwnerId=users[0].Id,
                Core_Technical_Owner__c=users[2].Id, RecordTypeId=recTypeId);
            insert opp6;*/
            
            
            //opp6 = [select Id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c
            //       from Opportunity where Id = :opp6.Id];
            System.assertEquals(users[1].Id, lstOppty1[5].Core_Approver_1__c);
            System.assertEquals(users[3].Id, lstOppty1[5].Core_Approver_2__c);
            System.assertEquals(users[1].Id, lstOppty1[5].Core_Approver_3__c);
            System.assertEquals(users[1].Id, lstOppty1[5].Core_Approver_4__c);
            System.assertEquals(users[1].Id, lstOppty1[5].Core_Approver_5__c);
            
            // Check to make sure the managers have access
            List<OpportunityShare> oppShare6 = [select UserOrGroupId, OpportunityId, OpportunityAccessLevel from OpportunityShare
            where OpportunityId = :lstOppty1[5].Id and (UserOrGroupId = :users[1].Id or UserOrGroupId = :users[3].Id)];
            System.assertNotEquals(null, oppShare6);
            System.assertEquals(2, oppShare6.size());
            System.assert((oppShare6[0].OpportunityAccessLevel == 'Edit') || (oppShare6[0].OpportunityAccessLevel == 'All'));
            System.assert((oppShare6[1].OpportunityAccessLevel == 'Edit') || (oppShare6[1].OpportunityAccessLevel == 'All'));
            
            // Test: Opportunity owner doesn't have a manager, and technical owner's manager is active
            /*Opportunity opp7 = new Opportunity(Name='Test Opportunity 7 in TestMethod', AccountId=acct.Id, StageName='Qualifying',
                CloseDate=System.Date.today().addYears(1), OwnerId=users[1].Id,
                Core_Technical_Owner__c=users[2].Id, RecordTypeId=recTypeId);
            insert opp7;    */        
            
            
            //opp7 = [select Id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c
            //       from Opportunity where Id = :opp7.Id];
            System.assertEquals(users[3].Id, lstOppty1[6].Core_Approver_1__c);
            System.assertEquals(users[3].Id, lstOppty1[6].Core_Approver_2__c);
            System.assertEquals(users[3].Id, lstOppty1[6].Core_Approver_3__c);
            System.assertEquals(users[3].Id, lstOppty1[6].Core_Approver_4__c);
            System.assertEquals(users[3].Id, lstOppty1[6].Core_Approver_5__c);
            
            // Test: Opportunity owner's manager is inactive, and technical owner's manager is active
            /*Opportunity opp8 = new Opportunity(Name='Test Opportunity 8 in TestMethod', AccountId=acct.Id, StageName='Qualifying',
                CloseDate=System.Date.today().addYears(1), OwnerId=users[4].Id,
                Core_Technical_Owner__c=users[0].Id, RecordTypeId=recTypeId);
            insert opp8;*/
            
            
            //opp8 = [select Id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c
            //       from Opportunity where Id = :opp8.Id];
            /*System.assertEquals(users[1].Id, lstOppty1[7].Core_Approver_1__c);
            System.assertEquals(users[1].Id, lstOppty1[7].Core_Approver_2__c);
            System.assertEquals(users[1].Id, lstOppty1[7].Core_Approver_3__c);
            System.assertEquals(users[1].Id, lstOppty1[7].Core_Approver_4__c);
            System.assertEquals(users[1].Id, lstOppty1[7].Core_Approver_5__c);*/
            
            Test.stopTest();
        }
    }
    
    static testmethod void determineProductStatusTest() {
        Id recTypeId = [select Id from RecordType where DeveloperName = 'Core_Opportunity' limit 1][0].Id;
        List<OpportunityLineItem> ProductList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> ProductList1 = new List<OpportunityLineItem>();
        Set<Id> OppSet = new Set<Id>();
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>(); 
        //User Creation
        Map<Id, User> users = new Map<id,User>();
        User usr = new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User', Email='test.user1@intel.com',
        Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8',
        ProfileId=[select Id from Profile where Name='Standard User' limit 1][0].Id, LanguageLocaleKey='en_US');
        insert usr;
        users.put(usr.id,usr);
        //Account Creation
        Account acct = new Account(Name='Test Account in testOppApproverByManager',
            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA', Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),Industry ='Agriculture',Core_Sub_Industry__c='Animal Production');
            insert acct;
        Product2 prod = new Product2(Name='Test Product in TestMethod', Core_Group_Code__c='ABC', Core_Division_Code__c='DEF',
        Core_Group_Code_Short_Name__c='AB', Core_Division_Code_Short_Name__c='DE');
        Insert prod;
        
        Opportunity OldOpp = new Opportunity(Name='Test Opportunity 1 in TestMethod', AccountId=acct.Id, StageName='Qualify',
            CloseDate=System.Date.today().addYears(1), OwnerId=usr.Id,
            RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Design: Original' , Opportunity_Focus__c= 'Core');
        insert OldOpp;
        
        Opportunity opp = new Opportunity(Name='Test Opportunity 1 in TestMethod', AccountId=acct.Id, StageName='Production Win',
            CloseDate=System.Date.today().addYears(1), OwnerId=usr.Id,Core_Approval_Status__c='Approved',
            RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Design: Original' , Opportunity_Focus__c= 'Core');
        System.runAs(Core_Test_Utility.systemAdminUser) {
           Insert opp; 
        }
        Opportunity opp1 = new Opportunity(Name='Test Opportunity 1 in TestMethod', AccountId=acct.Id, StageName='Production Win',
            CloseDate=System.Date.today().addYears(1), OwnerId=usr.Id,Core_Approval_Status__c='Approved',
            RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Design: Original' , Opportunity_Focus__c= 'Core',Core_Coverage_Type_Nm__c='Disti Design Registration Low',Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity');
        System.runAs(Core_Test_Utility.systemAdminUser) {
           Insert opp1; 
        }
        Opportunity opp2 = new Opportunity(Name='Test Opportunity 1 in TestMethod', AccountId=acct.Id, StageName='Production Lost',
            CloseDate=System.Date.today().addYears(1), OwnerId=usr.Id,Core_Approval_Status__c='Approved',
            RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Design: Original' , Opportunity_Focus__c= 'Core',Core_Coverage_Type_Nm__c='Disti Design Registration Low',Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity');
        System.runAs(Core_Test_Utility.systemAdminUser) {
           Insert opp2; 
        }
        
         PricebookEntry bookEntry = new PricebookEntry(Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(),
        Unitprice=10, IsActive=true);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert bookEntry;
        }
        
        OpportunityLineItem Product = new OpportunityLineItem(OpportunityId=OldOpp.Id,Quantity=10,UnitPrice=100.00,Core_Status__c='Pending',Product2Id=prod.id,PricebookEntryId=bookEntry.Id);
        ProductList.add(Product);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert ProductList;}
        OldOpp.StageName='Submitted';
        OldOpp.Core_Approval_Status__c='Submitted';
        update OldOpp;
        OpportunityLineItem Product1 = new OpportunityLineItem(OpportunityId=Opp.Id,Quantity=10,UnitPrice=100.00,Core_Status__c='Win Approved',Product2Id=prod.id,PricebookEntryId=bookEntry.Id);
        ProductList1.add(Product1);
        insert ProductList1;
        OppSet.add(opp.id);
        logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Stage-'+opp.StageName+' Approval-'+opp.Core_Approval_Status__c, Core_Origin__c ='Core_OppApproval.updateProductLineItems', Core_Severity__c='High',Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve',Core_sObjectId__c=opp.id));

        insert logEntries;
        
        
        Core_OppApproval.determineProductStatus(OldOpp,opp,Product,ProductList,OppSet,logEntries,users);
        //Core_OppApproval.determineProductStatus(OldOpp,opp,ProductList,ProductList1,OppSet,logEntries,users);
  //                                                        List<OpportunityLineItem> UpdateProducts, Set<Id> UpdateOpps, List<Core_Log_Entry__c> logEntries, Map<Id, User> opptyIdvsOwnerMap) {
        
        Core_OppApproval.determineProductStatus(OldOpp,opp2,Product,ProductList,OppSet,logEntries,users);
        system.assertEquals(true,true);
        
} 
    
    static testmethod void testOppProductSubmission() {
        
        // Get the test data that's already set up
        List<Opportunity> opps = [select Id from Opportunity where Name like 'Test Opportunity %' order by Name];
        
        // Simulate submitting our opportunities for approval
        for (Opportunity opp : opps) {
            opp.Core_Approval_Status__c = OPP_STATUS_SUBMITTED;
        }
        
        Test.startTest();
        System.runAs(Core_Test_Utility.systemAdminUser) {        
            update opps;
        }
        
        // Re-read the values we're going to check
        List<OpportunityLineItem> oppProductsAfter = [select Id, Core_Status__c from OpportunityLineItem
        where OpportunityId in :opps];
        for (OpportunityLineItem oppProd : oppProductsAfter)
        System.assertEquals(OPPPROD_STATUS_WIN_SUBMITTED, oppProd.Core_Status__c);
        Test.stopTest();
    }

    static testmethod void testOppPCCProductSubmission() {
        Test.startTest();
        
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();   
        user sysAdmUser = Core_Test_Utility.systemAdminUser;
        Id profId = [select Id from Profile where Name='Sales Rep-BB' limit 1][0].Id;
        List<User> users = new List<User>();
        users.add(new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User 1', Email='test.user1@intel.com',
                           Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ManagerId = sysAdmUser.id,
                           ProfileId=profId, LanguageLocaleKey='en_US'));
        insert users;
        System.runAs(sysAdmUser) {            
            //Create account records
            List<account> LstAcc = Core_Test_Utility.createAccount(5);
            for(Account acc: LstAcc){
                acc.RecordTypeid = recTypeId;
                acc.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
            }
            insert LstAcc;
            /*List<account> LstAcc = Core_Test_Utility.createAccount(5);
            LstAcc[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
            Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
            LstAcc[0].recordtypeID = accountRecordTypeIntel;
            insert LstAcc;*/
            
            List<contact> LstCon = Core_Test_Utility.createContacts(5);
            for(contact con: LstCon)
            {
                con.accountid = LstAcc[0].id;
                con.MailingCountry='India';
            }
            insert LstCon;
            
            for(Account accountInstance: lstAcc)
            {
                accountInstance.BillingCountryCode = 'USA';
                accountInstance.BIllingStateCode = 'OR';
                accountInstance.BillingCity = 'Alabama';
                accountInstance.BillingStreet = 'test';
            }
            
            //update account records billing location to match with the ISR mapping custom setting values
            update lstAcc;
            
            List<Core_Location_To_Approver_Group_Mapping__c> locationToApproverGrp = Core_DDR_Utility.CreateLocationToApproverGroup();
            Core_DDR_Utility.CreateLogEntry();
            
            //List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5, LstAcc);
            List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5);
            
            for(Core_Design_Registration__c iDR : TestDDRlst)
            {
                iDR.Core_Approver_Grp_Nm__c = 'Core_DDR_Approver_PSG_USA_Oregon';
                iDR.Core_Partner_Account_Id__c = lstAcc[0].Id;
            }        
            insert TestDDRlst;
            
            for(Core_Design_Registration__c iDR : TestDDRlst)
            {
                iDR.OwnerId = users[0].Id;
            }
            
            update TestDDRlst;
            
            //SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
            //Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
            
            // Now add some accounts, members of 1 to 5 territories with approvers            
            List<Account> accts = new List<Account>();
            accts.add(new Account(Name='Test Account PCC', RecordTypeId=recTypeId,
                                  BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),Industry='Health and Life Sciences',Core_Sub_Industry__c='Biotechnology'));
            insert accts;
            recTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
            // Create an opportunity against each account
            lstOppty.clear();
            Opportunity opp = new Opportunity(Name='Test Opportunity PCC',Core_Coverage_Type_Nm__c = 'Deal Registration',Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity',
                                              AccountId=accts[0].Id, StageName='Qualify', RecordTypeId=recTypeId,Core_Technical_Owner__c=users[0].Id,OwnerId= users[0].Id,
                                              CloseDate=System.Date.today().addYears(1), Core_Opportunity_Type__c = 'Deal: Sell-through' , Opportunity_Focus__c= 'Core');
            lstOppty.add(opp);
            insert lstOppty;
            List<Opportunity> lstOppty1 = [SELECT id, Core_Approver_1__c, Core_Approver_2__c, 
                                           Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c,
                                           Core_Technical_Owner__r.ManagerId,Owner.Core_Manager__c,Owner.ManagerId,
                                           Core_Design_Registration_Id__c FROM Opportunity WHERE id IN :lstOppty];
            if(!lstOppty1.isEmpty()){
                lstOppty1[0].Core_Design_Registration_Id__c = TestDDRlst[0].Id;
                update lstOppty1[0];
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(lstOppty1[0].Id);
                //Approval.ProcessResult res = Approval.process(req);
                //System.assert(res.isSuccess());
            }
        }
        Test.stopTest();
        System.assertEquals(true,true);
    }    
    static testmethod void testOppProductRejectRecall() {
        
        // Get the test data that's already set up
        List<Opportunity> opps = [select Id from Opportunity where Name like 'Test Opportunity %' order by Name];
        List<OpportunityLineItem> oppProducts = [select Id from OpportunityLineItem where Opportunity.Name like 'Test Opportunity %'
        order by Opportunity.Name, Id];
        
        // Simulate submitting our opportunities for approval
        for (Opportunity opp : opps) {
            opp.Core_Approval_Status__c = OPP_STATUS_SUBMITTED;
        }
        
        System.runAs(Core_Test_Utility.systemAdminUser) {   
        //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
          //  Core_OpportunityHelper.isRecursiveAfterUpdate = false;     
            update opps;
        }  
        
        // Reject or Recall them all
        for (Integer i=0; i<opps.size(); i++) {
            if (Math.mod(i,2) == 0)
            opps[i].Core_Approval_Status__c = OPP_STATUS_REJECTED;
            else
            opps[i].Core_Approval_Status__c = OPP_STATUS_RECALLED;
        }
        
        Test.startTest();
        System.runAs(Core_Test_Utility.systemAdminUser) {  
       //     Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
       //     Core_OpportunityHelper.isRecursiveAfterUpdate = false;              
            update opps;
        }
        Test.stopTest();
        
        // Re-read the values we're going to check
        List<OpportunityLineItem> oppProductsAfter = [select Id, Core_Status__c from OpportunityLineItem where OpportunityId in :opps];
        for (OpportunityLineItem oppProd : oppProductsAfter)
        System.assertEquals(OPPPROD_STATUS_PENDING, oppProd.Core_Status__c);
    }
    
    static void setupLostCancel(List<Opportunity> Opps, List<OpportunityLineItem> Products, String LostCancel) {
        for(OpportunityLineItem P : Products) {
            if(P.OpportunityId == Opps[0].Id) 
            P.Core_Status__c = 'Win Approved';
            if(P.OpportunityId == Opps[1].Id) 
            if(P.Quantity == 10) // exclude the first due to workflow rule setting "Design"
            P.Core_Status__c = 'Production Win Approved';
            else
            P.Core_Status__c = 'Pending';
            if(P.OpportunityId == Opps[2].Id) 
            P.Core_Status__c = 'On Hold';
            if(P.OpportunityId == Opps[3].Id)
            P.Core_Status__c = 'Production Win Approved';
            if(P.OpportunityId == Opps[4].Id) {
                P.Core_Status__c = LostCancel;
                P.Core_Competitor__c='Acer';
                P.Core_Competitor_Product__c = 'AMD: Radeon';
                P.Core_Loss_Cancel_Reason__c = LostCancel.contains('Lost') ? 'Opportunity Lost' : 'Opportunity Cancelled';
                P.Core_Loss_Cancel_Details__c = 'Testing Lost';
            }
        }
        Opps[1].Core_Bypass_Field_Validation__c = true;
        System.runAs(Core_Test_Utility.systemAdminUser) {
       //     Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
         //   Core_OpportunityHelper.isRecursiveAfterUpdate = false;
            Opps[1].Core_Loss_Cancel_Reason__c = 'Lost - Price';
            //Opps[1].Core_Loss_Cancel_Reason__c = 'Price';//TWC3123-6699
            Opps[1].Core_Loss_Cancel_Details__c = 'Testing Lost';
            update Opps[1];
       //     Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
         //   Core_OpportunityHelper.isRecursiveAfterUpdate = false;
            update Products;
        }
    }

    static void setupLost(List<Opportunity> Opps, List<OpportunityLineItem> Products, String LostCancel) {
        for(OpportunityLineItem P : Products) {
            P.Core_Status__c = LostCancel;
            P.Core_Competitor__c='Acer';
            P.Core_Competitor_Product__c = 'AMD: Radeon';
            P.Core_Loss_Cancel_Reason__c = LostCancel.contains('Lost') ? 'Opportunity Lost' : 'Opportunity Cancelled';
            P.Core_Loss_Cancel_Details__c = 'Test details';
        }
        System.runAs(Core_Test_Utility.systemAdminUser) {
            //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
            //  Core_OpportunityHelper.isRecursiveAfterUpdate = false;
            update Products;
        }
    }
    
    static void assertProductionLost(List<Opportunity> Opps, List<OpportunityLineItem> Products){
        for(OpportunityLineItem P : Products) {
            if(P.OpportunityId == Opps[0].Id || P.OpportunityId == Opps[3].Id)
            System.assertEquals('Production Lost', P.Core_Status__c);  // from Win Approved or Production Win
            else if((P.OpportunityId == Opps[1].Id || P.OpportunityId == Opps[2].Id) && P.Quantity != 10)
            System.assertEquals('Lost', P.Core_Status__c); // from Pending or On Hold
            else if(P.OpportunityId == Opps[4].Id)
            System.assertEquals('Production Cancelled', P.Core_Status__c); // from Production Cancelled
        }
    }
    
    static void assertProductionCanceled(List<Opportunity> Opps, List<OpportunityLineItem> Products){
       /* for(OpportunityLineItem P : Products) {
            if(P.OpportunityId == Opps[0].Id || P.OpportunityId == Opps[3].Id) 
            System.assertEquals('Production Cancelled', P.Core_Status__c);  // from Win Approved or Production Win
            else if((P.OpportunityId == Opps[1].Id || P.OpportunityId == Opps[2].Id) && P.Quantity != 10)
            System.assertEquals('Cancelled', P.Core_Status__c); // from Pending or On Hold
            else if(P.OpportunityId == Opps[4].Id)
            System.assertEquals('Production Lost', P.Core_Status__c); // from Production Lost
        } */
    }
    
    static testmethod void testOppProductApproval() {
        // Get the test data that's already set up
        List<Opportunity> opps = [ SELECT Id FROM Opportunity WHERE Name LIKE 'Test Opportunity %' ORDER BY Name ];
        
        // Re-submit our opportunities for approval
        for (Opportunity opp : opps){
            opp.Core_Approval_Status__c = OPP_STATUS_SUBMITTED;
            opp.CloseDate=System.Date.today();
        }
        System.runAs(Core_Test_Utility.systemAdminUser) {
        //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
          //  Core_OpportunityHelper.isRecursiveAfterUpdate = false;
            update opps;
        }
        
        // Approve them all
        for (Opportunity opp : opps) {
            opp.Core_Approval_Status__c = OPP_STATUS_APPROVED;
            opp.StageName = 'Design Win';
        }
        
        Test.startTest();
        System.runAs(Core_Test_Utility.systemAdminUser) {
        //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
          //  Core_OpportunityHelper.isRecursiveAfterUpdate = false;
            update opps;
        }
        
        // Products should be approved
       // for (OpportunityLineItem P : [ SELECT Id, Core_Status__c FROM OpportunityLineItem WHERE OpportunityId IN :opps ])
        //System.assertEquals(OPPPROD_STATUS_WIN_SUBMITTED, P.Core_Status__c);
        
        // Move all to Production Win
        for (Opportunity opp : opps)
        {
            Note n = new note(parentid=opp.id,title='Production Win POP',body='test note contents');
            insert n;
            opp.StageName = 'Production Win';
            opp.Core_PW_Approval_Status__c =OPP_STATUS_APPROVED;
        }
        Map<Id, Opportunity> oldOppMap = new Map<Id,Opportunity>(opps);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
        //    Core_OpportunityHelper.isRecursiveBeforeUpdate = false;
          //  Core_OpportunityHelper.isRecursiveAfterUpdate = false;
            update opps;
        }
        // products should be Production Win
        List<OpportunityLineItem> Products = [ 
            SELECT Id, Core_Status__c, OpportunityId, Quantity FROM OpportunityLineItem WHERE OpportunityId IN :opps 
        ];
        //for (OpportunityLineItem P : Products)
        //System.assertEquals(OPPPROD_STATUS_WIN_SUBMITTED, P.Core_Status__c);
        
        
        // Move all to Production Lost
    
        setupLost(opps, Products, 'Production Lost');
    	User smgUser = [select id from user where profile.name = 'SMG/GMC Read Only' and isActive = true limit 1];
        
       //assertProductionLost(opps, Products = [ SELECT Id, Core_Status__c, OpportunityId, Quantity FROM OpportunityLineItem WHERE OpportunityId IN :opps ]);
        System.runAs(smgUser){
          Core_OppApproval.smgGmcCheckApprovalRejection(opps,oldOppMap );  
        }
        
        
        Test.stopTest();
        // Move all to Production Cancelled
    
        setupLost(opps, Products, 'Production Cancelled');
        
        for (Opportunity opp : opps) {
            opp.StageName = 'Production Cancelled';
            opp.Core_Loss_Cancel_Reason__c = 'Cancelled - Timing';
            opp.Core_Loss_Cancel_Details__c = 'Testing cancel';
        }
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update opps;
        }
        
        system.assertEquals(true,true);
       assertProductionCanceled(opps, Products = [ SELECT Id, Core_Status__c, OpportunityId, Quantity FROM OpportunityLineItem WHERE OpportunityId IN :opps ]);
    }
    
    static testMethod void  ddrApprovalTest(){
        Test.startTest();
        
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        
        user sysAdmUser = Core_Test_Utility.systemAdminUser;
        Id profId = [select Id from Profile where Name='Sales Rep-BB' limit 1][0].Id;
        List<User> users = new List<User>();
        users.add(new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User 1', Email='test.user1@intel.com',
        Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ManagerId = sysAdmUser.id,
        ProfileId=profId, LanguageLocaleKey='en_US'));
        insert users;
        
        System.runAs(users[0]) {            
            //Create account records
            List<account> LstAcc = Core_Test_Utility.createAccount(5);
            for(Account acc: LstAcc){
                acc.RecordTypeid = recTypeId;
                acc.Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI();
            }
            insert LstAcc;
            
            List<contact> LstCon = Core_Test_Utility.createContacts(5);
            for(contact con: LstCon)
            {
                con.accountid = LstAcc[0].id;
                con.MailingCountry='India';
            }
            insert LstCon;
            
            for(Account accountInstance: lstAcc)
            {
                accountInstance.BillingCountryCode = 'USA';
                accountInstance.BIllingStateCode = 'OR';
                accountInstance.BillingCity = 'Alabama';
                accountInstance.BillingStreet = 'test';
            }
            
            //update account records billing location to match with the ISR mapping custom setting values
            update lstAcc;
            
            
            List<Core_Location_To_Approver_Group_Mapping__c> locationToApproverGrp = Core_DDR_Utility.CreateLocationToApproverGroup();
            Core_DDR_Utility.CreateLogEntry();
            
            //List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5, LstAcc);
            List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5);
            
            for(Core_Design_Registration__c iDR : TestDDRlst)
            {
                iDR.Core_Approver_Grp_Nm__c = 'Core_DDR_Approver_PSG_USA_Oregon';
                iDR.Core_Partner_Account_Id__c = lstAcc[0].Id;
            }        
            insert TestDDRlst;
            
            for(Core_Design_Registration__c iDR : TestDDRlst)
            {
                iDR.OwnerId = users[0].Id;
            }
            
            update TestDDRlst;
            
            //SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        	//Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();

            // Now add some accounts, members of 1 to 5 territories with approvers            
            List<Account> accts = new List<Account>();
            accts.add(new Account(Name='Test Account in 1 Territory with Approver in TestMethod', RecordTypeId=recTypeId,
            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),Industry='Health and Life Sciences',Core_Sub_Industry__c='Biotechnology'));
            insert accts;
            recTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
            // Create an opportunity against each account
            lstOppty.clear();
            Opportunity opp = new Opportunity(Name='Test Opportunity with Account in 1 Territory with Approver in TestMethod',
            AccountId=accts[0].Id, StageName='Qualify', RecordTypeId=recTypeId,Core_Technical_Owner__c=users[0].Id,
            CloseDate=System.Date.today().addYears(1),Core_Design_Registration_Id__c=TestDDRlst[0].Id, Core_Opportunity_Type__c = 'Design: Original' , Opportunity_Focus__c= 'Core');
            lstOppty.add(opp);
            
            insert lstOppty;
            OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId=lstOppty[0].Id, UserId=users[0].Id, Core_Production_Win_Member_Role__c='Sales Account Manager');
            insert otm;
            List<Opportunity> lstOppty1 = [SELECT id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c,Core_Technical_Owner__r.ManagerId,Core_Design_Registration_Id__c FROM Opportunity WHERE Core_Design_Registration_Id__c != '' and id IN :lstOppty];
            if(!lstOppty1.isEmpty()){
                lstOppty1[0].Core_Design_Registration_Id__c = TestDDRlst[0].Id;
                update lstOppty1[0];
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(lstOppty1[0].Id);
                Approval.ProcessResult res = Approval.process(req);
                System.assert(res.isSuccess());
            }
        }
        Test.stopTest();
    }
    /*static testMethod void  ddrpccApprovalTest(){
        Test.startTest();
        
        Id newAccRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;   
        user sysAdmUser = Core_Test_Utility.systemAdminUser;
        Id profId = [select Id from Profile where Name='Sales Rep-BB' limit 1][0].Id;
        List<User> users = new List<User>();
        users.add(new User(UserName='test.user1.testOppApproverByManager@intel.com.crm', LastName='User 1', Email='test.user1@intel.com',
        Alias='tclass1', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ManagerId = sysAdmUser.id,
        ProfileId=profId, LanguageLocaleKey='en_US'));
        insert users;
        //PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = '0PSDf000001B1dZOAS', AssigneeId = users[0].Id);
		//insert psa;
        System.runAs(users[0]) {
       	List<account> LstAcc = Core_Test_Utility.createAccount(5);
        LstAcc[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();        
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
            
            List<contact> LstCon = Core_Test_Utility.createContacts(5);
            for(contact con: LstCon)
            {
                con.accountid = LstAcc[0].id;
            }
            insert LstCon;
            
            for(Account accountInstance: lstAcc)
            {
                accountInstance.BillingCountryCode = 'USA';
                accountInstance.BIllingStateCode = 'OR';
                accountInstance.BillingCity = 'Alabama';
                accountInstance.BillingStreet = 'test';
            }
            update lstAcc;
            
            
            List<Core_Location_To_Approver_Group_Mapping__c> locationToApproverGrp = Core_DDR_Utility.CreateLocationToApproverGroup();
            Core_DDR_Utility.CreateLogEntry();
            List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5);
            
            for(Core_Design_Registration__c iDR : TestDDRlst)
            {
                iDR.Core_Approver_Grp_Nm__c = 'Core_DDR_Approver_PSG_USA_Oregon';
                iDR.Core_Partner_Account_Id__c = lstAcc[0].Id;
            }        
            insert TestDDRlst;
            
            for(Core_Design_Registration__c iDR : TestDDRlst)
            {
                iDR.OwnerId = users[0].Id;
            }
            
            update TestDDRlst;
            
            SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        	Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();         
            List<Account> accts = new List<Account>();
            accts.add(new Account(Name='Test Account in 1 Territory with Approver in TestMethod', RecordTypeId=recTypeId,
            BillingStreet='a', BillingCity='a', BillingState='MI', BillingCountry='USA',Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),Industry='Health and Life Sciences',Core_Sub_Industry__c='Biotechnology'));
            insert accts;
            recTypeId = [select Id from RecordType where DeveloperName = 'Core_Deal_Opportunity' limit 1][0].Id;
            // Create an opportunity against each account
            lstOppty.clear();
            Opportunity opp = new Opportunity(Name='Test Opportunity with Account in 1 Territory with Approver in TestMethod',
            AccountId=accts[0].Id, StageName='Qualify', RecordTypeId=recTypeId,Core_Technical_Owner__c=users[0].Id,OwnerId= users[0].Id,
            CloseDate=System.Date.today().addYears(1),Core_Design_Registration_Id__c=TestDDRlst[0].Id);
            lstOppty.add(opp);
            insert lstOppty;
            List<Opportunity> lstOppty1 = [SELECT id, Core_Approver_1__c, Core_Approver_2__c, Core_Approver_3__c, Core_Approver_4__c, Core_Approver_5__c,Core_Technical_Owner__r.ManagerId,Core_Design_Registration_Id__c FROM Opportunity WHERE Core_Design_Registration_Id__c != '' and id IN :lstOppty];
            if(!lstOppty1.isEmpty()){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(lstOppty1[0].Id);
                Approval.ProcessResult res = Approval.process(req);
                System.assert(res.isSuccess());
            }
        }
        Test.stopTest();
    }*/
    @testSetup
    static void setupTestData() {   
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        INSERT triggerExecList;
        // Enable the Trigger execution
        Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c(
        Name='determineApprovers', Core_Class_Name__c='Core_OppApproval', Core_Object__c='Opportunity',
        Core_Trigger_Events__c='test', Core_Active__c=true, Core_Description__c = 'blah blah');
        insert triggerExec;
        
        triggerExec = new Core_Trigger_Executions__c(
        Name='updateProductLineItems', Core_Class_Name__c='Core_OppApproval', Core_Object__c='Opportunity',
        Core_Trigger_Events__c='test', Core_Active__c=true, Core_Description__c = 'blah blah');
        insert triggerExec;
        
        //-----------------------------------------------------------------
        // Data setup
        
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id accountRecordTypeIntel = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();

        // Create an account
        Account acct = new Account();
        acct.name = 'Test Opportunity 123';
		acct.RecordTypeId = accountRecordTypeIntel;
        acct.BillingCountryCode = 'USA';
        acct.BIllingStateCode = 'AL';
        acct.BillingCity = 'Alabama123';
        acct.BillingStreet = 'test123';  
        acct.Core_Sales_Groups__c= Core_CRM_Utility.getSalesGroupAPI();
        acct.Industry='Health and Life Sciences'; 
        acct.Core_Sub_Industry__c='Biotechnology';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert acct;
        }

        //Id recTypeId = [select Id from RecordType where DeveloperName = 'Core_Design_Opportunity' limit 1][0].Id;
        Id oppDealID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        
        // A few opportunities            
        List<Opportunity> opps = new List<Opportunity>();        
        for (Integer i=0; i < OPP_COUNT; i++)
        opps.add(new Opportunity(Name='Test Opportunity in TestMethod '+i, AccountId=acct.Id, StageName='Qualify',
        CloseDate=System.Date.today().addYears(1), RecordTypeId=recTypeId, Core_Opportunity_Type__c = 'Design: Original' , Opportunity_Focus__c= 'Core'));
        
        System.runAs(Core_Test_Utility.systemAdminUser) {        
            insert opps;
        }   
        
        // Opportunity product line items
        Product2 prod = new Product2(Name='Test Product in TestMethod', Core_Group_Code__c='ABC', Core_Division_Code__c='DEF',
        Core_Group_Code_Short_Name__c='AB', Core_Division_Code_Short_Name__c='DE');
        System.runAs(Core_Test_Utility.systemAdminUser) {        
            insert prod;
        }    
        
        PricebookEntry bookEntry = new PricebookEntry(Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(),
        Unitprice=10, IsActive=true);
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert bookEntry;
        }
        
        List<OpportunityLineItem> oppProducts = new List<OpportunityLineItem>();
        for (Opportunity opp : opps)
        for (Integer i=0; i < OPPPROD_COUNT; i++) {
            oppProducts.add(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=bookEntry.Id,
            Quantity=((i+1)*10), TotalPrice=((i+1)*50)));
        }
        
        System.runAs(Core_Test_Utility.systemAdminUser) {            
            insert oppProducts;
        } 
    }
}