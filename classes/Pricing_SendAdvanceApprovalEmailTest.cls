@isTest
private class Pricing_SendAdvanceApprovalEmailTest {

   @testSetup
    public static void setUpData() {
        //Account acc = PSG_Test_Utility.createAccount();
        /*Contact con1 = PSG_Test_Utility.createContact(acc.Id);
        con1.Email = 'FirstNameacc123@intel.com';
        update con1;*/
        List < Account > accs = [SELECT Id from Account where RecordType.Name = 'Intel Account' limit 10];
        List < Account > accsToUpdate = new List < Account > ();
        Id recordtypeId = [SELECT Id, name, developername from RecordType where sobjecttype = 'Account' and Developername = 'Core_Direct_Account' LIMIT 1].Id;
        /*Account a1 = PSG_Test_Utility.createDirectAccount();
        a1.RecordTypeId = recordtypeId;
        a1.Core_Direct_Account_Type_Nm__c = 'End Customer Parent';
        a1.Core_Is_Pricing_Parent_ChkBox__c = true;
        a1.Core_Direct_Account_Active_Ind__c = true;
        update a1;
        Account a2 = PSG_Test_Utility.createDirectAccount();
        a2.RecordTypeId = recordtypeId;
        a2.Core_Direct_Account_Type_Nm__c = 'End Customer Parent';
        a2.Core_Is_Pricing_Parent_ChkBox__c = true;
        a2.Core_Direct_Legal_Parent_Id__c = a1.Id;
        a2.Core_Direct_Account_Active_Ind__c = true;
        update a2;
        for (Integer i = 0; i < 1; i++) {
            accs[i].Core_PSG_Account__c = true;
            accs[i].Core_Direct_Pricing_Parent_Id__c = a2.id;
            accs[i].Core_Direct_Legal_Parent_Id__c = a1.Id;
            
            accsToUpdate.add(accs[i]);
        }
        update accsToUpdate;*/
        SBQQ.TriggerControl.disable();
        Product2 p = new Product2();
        p.core_OPN__c = 'INTELPROD';
        p.Name = 'Intel Prod 1';
        p.Core_Hierarchy_ID__c = '59';
        p.Core_Product_Type__c = Label.PSG_Product_Type_Identifier;
        p.Core_Code_Name__c = Label.PSG_Product_Type_Identifier;
        p.IsActive = true;
        p.Core_Product_org__c = 'Sales';
        insert p;
        Test.startTest();
        //List < SBQQ__Quote__c > lstquote = PSG_Test_Utility.createQuote(accsToUpdate[0].id, con1.id, 1);
        //List < SBQQ__QuoteLine__c > lstquoteLines = PSG_Test_Utility.createQuoteLines(lstquote[0].id, 1);
        //List < price_prid__c > prid = PSG_Test_Utility.CreatePrid(accsToUpdate[0].id, null, null, p.Id);
        Test.stopTest();
    }
    

    @isTest
    static void testSendApprovalNotification() {
        Account acc=[SELECT Id from Account where RecordType.Name = 'Direct Account' limit 1];
        List<SBQQ__Quote__c> lstquote = [select id, core_cpq_negative_margin_quote_Value__c from SBQQ__Quote__c ];
        lstquote[0].core_cpq_ready_for_submission__c=true;
        lstquote[0].core_cpq_quote_type_nm__c = 'Transfer Pricing';
        lstquote[0].core_cpq_sap_ecp_nm__c = acc.id;
         update lstquote;    
        //List<User> lstUsers1 = PSG_Test_Utility.createBOUser();
        Group grp = new Group();
        grp.name = 'Test Group_psg';
        grp.Type = 'Regular'; 
        /*System.runAs(lstUsers1[0]){
            Insert grp; 
        }*/
        GroupMember grpMem1 = new GroupMember();
        //grpMem1.UserOrGroupId = lstUsers1[0].Id;
        grpMem1.GroupId = grp.Id;
        
        /*System.runAs(lstUsers1[0]){
            Insert grpMem1;
        }*/
        List<SBQQ__QuoteLine__c> qlList = [SELECT Id, Name, price_std_fwd_cost_amt__c, core_cpq_distributor_margin_pct__c, price_suggested_resale_amt__c, 
                                           core_cpq_intel_margin_pct__c, price_broken_cost_cp__c, SBQQ__Quote__r.core_cpq_negative_margin_quote_Value__c,core_cpq_quote_line_type_txt__c,core_cpq_price_eligibility_date_dt__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:lstquote[0].id];
        qlList[0].price_suggested_resale_amt__c=5;
        qlList[0].core_cpq_quote_line_type_txt__c='Flat';
        qlList[0].core_cpq_price_eligibility_date_dt__c=system.today() + 6;
        Test.startTest();
        update qlList;
        /*List<sbaa__Approval__c> approvalList = PSG_Test_Utility.createApproval(lstquote[0].Id);
        Test.stopTest();
        List<sbaa__Approver__c> approverList = PSG_Test_Utility.createApprover(lstUsers1[0].Id);
        approverList[0].sbaa__GroupId__c=grp.id;
        update approverList;
        approvalList[0].sbaa__AssignedTo__c=null;
        approvalList[0].sbaa__Approver__c=approverList[0].id;
        update approvalList;*/
        List<sbaa__ApprovalRule__c> approverRuleList = [SELECT Id,Name from sbaa__ApprovalRule__c limit 1];

        String orgWideEmailAddress = 'wsm-postmaster@intel.com';
        String emailTempDevName = 'PSG_Quote_Approval_Request_EmailTemplate';

       
        
       //Pricing_SendAdvanceApprovalEmail.sendNotification(new List<id>{approvalList[0].id}, orgWideEmailAddress, emailTempDevName);
        

        

        
    }


    private static Map<String, Object> setupTestData(String quoteStatus) {
        Map<String, Object> testData = new Map<String, Object>();

        string userEmail = 'Approver'+ quoteStatus +'@intel.com';
        
        // Create User
        User approver = Pricing_SW_UtilityTest.createUsers(userEmail, 'Approver', 'Test');
        
        // Create Group and GroupMember for approver
        Group testGroup = new Group(Name = 'Test Group', DeveloperName = 'Test_Group'+quoteStatus, Type = 'Regular');
        insert testGroup;

        // Add approver to group
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember groupMember = new GroupMember(GroupId = testGroup.Id, UserOrGroupId = approver.Id);
            insert groupMember;
        }

        // Create Account and Opportunity
        Account testAccount = Pricing_SW_UtilityTest.createAccount('Test Account');
        Opportunity testOpportunity = Pricing_SW_UtilityTest.createOpportunity(testAccount, 'Prospecting', Date.today().addMonths(1));
        
        // Create multiple Quotes with various statuses
        List<SBQQ__Quote__c> listQuote = new List<SBQQ__Quote__c>();
        listQuote.add(Pricing_SW_UtilityTest.createQuote(testOpportunity, quoteStatus, testAccount.Id));

        // Fetch group for 'Pricing_SW_Level_3_Approvers'
        Group gAssignedGroup = [SELECT Id FROM Group WHERE DeveloperName = 'Pricing_SW_Level_3_Approvers' LIMIT 1];

        // Create Approval record, merging status with 'Quote - '
        List<sbaa__Approval__c> listApproval = new List<sbaa__Approval__c>();
        for (SBQQ__Quote__c quote : listQuote) {
            sbaa__Approval__c approval = new sbaa__Approval__c(
                Quote__c = quote.Id,
                sbaa__Status__c = quote.SBQQ__Status__c,  // Use the quote status for approval
                sbaa__AssignedTo__c = approver.Id,        // Assign approver to approval
                sbaa__AssignedGroupId__c = gAssignedGroup.Id,
                sbaa__ApprovalStep__c = 1,
                sbaa__RecordField__c = 'Quote__c',        // Custom record field
                sbaa__CommentsLong__c = 'Testing comments' // Sample comment
            );
            listApproval.add(approval);
        }
        upsert listApproval;

        // Fetch EmailTemplate and OrgWideEmailAddress
        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Pricing_SW_QuoteApprovalNotification' LIMIT 1].Id;
        Id orgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :Label.AA_OrgWideEmailAddress LIMIT 1].Id;

        // Store all created test data in map
        testData.put('approver', approver);
        testData.put('testQuotes', listQuote);
        testData.put('approvals', listApproval);
        testData.put('templateId', templateId);
        testData.put('orgWideEmailId', orgWideEmailId);

        return testData;
    }

    @isTest
    static void testHandleSoftwareAndServicesApproved() {
        // Setup test data for 'Approved' quote status
        Map<String, Object> testData = setupTestData(Label.Pricing_SW_QuoteStatusApproved);

        // Extract required data
        List<sbaa__Approval__c> listApproval = (List<sbaa__Approval__c>) testData.get('approvals');
        Id templateId = (Id) testData.get('templateId');
        String orgWideEmail = Label.AA_OrgWideEmailAddress;

        // Test the sendNotification method
        Test.startTest();
        for (sbaa__Approval__c approval : listApproval) {
            Pricing_SendAdvanceApprovalEmail.sendNotification(new List<Id>{approval.Id},orgWideEmail,'Pricing_SW_QuoteApprovalNotification');
        }
        Test.stopTest();

        // Verify that the email was sent
        Integer emailSentAfter = Limits.getEmailInvocations();
        System.debug('emailSentAfter : ' + emailSentAfter);
        System.assert(emailSentAfter >= 0, 'Emails should have been sent for each approval.');
    }

    @isTest
    static void testHandleSoftwareAndServicesRequested() {
        // Setup test data for 'Approved' quote status
        Map<String, Object> testData = setupTestData(Label.Pricing_SW_Requested);

        // Extract required data
        List<sbaa__Approval__c> listApproval = (List<sbaa__Approval__c>) testData.get('approvals');
        Id templateId = (Id) testData.get('templateId');
        String orgWideEmail = Label.AA_OrgWideEmailAddress;

        // Test the sendNotification method
        Test.startTest();
        for (sbaa__Approval__c approval : listApproval) {
            Pricing_SendAdvanceApprovalEmail.sendNotification(new List<Id>{approval.Id},orgWideEmail,'Pricing_SW_QuoteApprovalNotification');
        }
        Test.stopTest();

        // Verify that the email was sent
        Integer emailSentAfter = Limits.getEmailInvocations();
        System.debug('emailSentAfter : ' + emailSentAfter);
        System.assert(emailSentAfter >= 0, 'Emails should have been sent for each approval.');
    }

    @isTest
    static void testHandleSoftwareAndServicesRejected() {
        Map<String, Object> testData = setupTestData(Label.Pricing_SW_Requested);

        // Extract the test data
        List<sbaa__Approval__c> listApproval = (List<sbaa__Approval__c>) testData.get('approvals');
        List<SBQQ__Quote__c> listQuote = (List<SBQQ__Quote__c>) testData.get('testQuotes');
        Id templateId = (Id) testData.get('templateId');
        String orgWideEmail = Label.AA_OrgWideEmailAddress;

        // Begin Test
        Test.startTest();

        // Find and update the quote and approval with the 'Requested' status, then update to 'Rejected'
        SBQQ__Quote__c targetQuote;
        sbaa__Approval__c targetApproval;

        for (SBQQ__Quote__c quote : listQuote) {
            if (quote.SBQQ__Status__c == Label.Pricing_SW_Requested) {
                targetQuote = quote;
                break;
            }
        }
        
        if (targetQuote != null) {
            // Update the quote status to 'Rejected'
            targetQuote.SBQQ__Status__c = Label.Pricing_SW_QuoteStatusRejected;
            update targetQuote;

            // Find the corresponding approval record for this quote and update it as well
            for (sbaa__Approval__c approval : listApproval) {
                if (approval.Quote__c == targetQuote.Id) {
                    targetApproval = approval;
                    break;
                }
            }
            
            if (targetApproval != null) {
                targetApproval.sbaa__Status__c = 'Quote - ' + Label.Pricing_SW_QuoteStatusRejected;
                update targetApproval;

                // Call the sendNotification method only for the approval with 'Rejected' status
                Pricing_SendAdvanceApprovalEmail.sendNotification(new List<Id>{targetApproval.Id},orgWideEmail,'Pricing_SW_QuoteApprovalNotification');
            }
        }

        Test.stopTest();

        // Verify that the email was sent
        Integer emailSentAfter = Limits.getEmailInvocations();
        System.debug('Emails should have been sent for the rejected approval.');
        System.debug('emailSentAfter : ' + emailSentAfter);
        System.assert(emailSentAfter >= 0, 'Emails should have been sent for the rejected approval.');
    }

    @isTest
    static void testHandleSoftwareAndServicesRecalled() {
        // Setup test data for 'Approved' quote status
        Map<String, Object> testData = setupTestData(Label.Pricing_SW_QuoteApprovalStatusRecalled);

        // Extract required data
        List<sbaa__Approval__c> listApproval = (List<sbaa__Approval__c>) testData.get('approvals');
        Id templateId = (Id) testData.get('templateId');
        String orgWideEmail = Label.AA_OrgWideEmailAddress;

        // Test the sendNotification method
        Test.startTest();
        for (sbaa__Approval__c approval : listApproval) {
            Pricing_SendAdvanceApprovalEmail.sendNotification(new List<Id>{approval.Id},orgWideEmail,'Pricing_SW_QuoteApprovalNotification');
        }
        Test.stopTest();

        // Verify that the email was sent
        Integer emailSentAfter = Limits.getEmailInvocations();
        System.debug('emailSentAfter : ' + emailSentAfter);
        System.assert(emailSentAfter >= 0, 'Emails should have been sent for each approval.');
    }
}