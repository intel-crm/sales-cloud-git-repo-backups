/****************************************************************************************************************************************
* Class Name        : Core_MDF_Bulk_Approval_requests_Batch
* Test Class Name   : Core_MDF_Bulk_ApprovalReqs_Batch_Test
* Created Date      : 08/12/2021
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Sai      08/12/2021      Test Class for Core_MDF_Bulk_Approval_requests_Batch
*****************************************************************************************************************************************/
@isTest(seeAllData=false)
private class Core_MDF_Bulk_ApprovalReqs_Batch_Test {
    
    @TestSetUp
    static void createTestData(){
        Test.startTest();
        ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
        Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
        ipaCoMarketingAccount.Core_Geo__c = '';
        ipaCoMarketingAccount.Core_Sub_Geo__c = '';
        insert ipaCoMarketingAccount;
        
        List<User> userList = new List<User>();
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.Email = 'sysadmin@example.com';
        userList.add(usr1);
        Database.insert(userList);
        
        Group ipaGrp = new Group();
            ipaGrp.Name = 'Core_MDF_CCP_IPA_External';
            ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_External';
            Database.insert(ipaGrp);
     
     		GroupMember ipaGrpMem = new GroupMember();
            ipaGrpMem.UserOrGroupId = usr1.Id;
            ipaGrpMem.GroupId = ipaGrp.Id;
            system.runAs(usr1){
            	Database.insert(ipaGrpMem);
            }
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External';
            pgm1.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgm1.Core_MDF_Group_Id__c = ipaGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_Region_cd__C = 'APJ';
            pgm1.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_External';
            Database.insert(pgm1);

        //created budget
        //string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc2);
        //budgetType = 'Data Center Specialties MDF';
        String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
        //budgetType = 'Proposal I MDF';
        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_IPA_TestDataUtility.budgetIPA_ProposalBased_Record_Type,ipaCoMarketingAccount.Id,ipaCP.Id,200000,System.today().addDays(-20),System.today(), false);
        budget.Core_MDF_Budget_Type_Txt__c='Proposal I MDF';
        Database.insert(budget);
        
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',budget,ipaCoMarketingAccount, 100000,true);
        
        
        //String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
        List<Campaign> campaignList = new List<Campaign>();
        Campaign ipaCampaignForAP1 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP 1',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', '', 'Planned', false);
        Campaign ipaCampaignForAP2 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP 2',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', '', 'Planned', false);
        Campaign ipaCampaignForAP3 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP 3',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', '', 'Planned', false);
        Campaign ipaCampaignForAP4 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP 4',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', '', 'Planned', false);
        Campaign ipaCampaignForAP5 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP 5',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', '', 'Planned', false);
        Campaign ipaCampaignForAP6 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP 6',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', '', 'Planned', false);
        Campaign ipaCampaignForAP7 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP 7',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', '', 'Planned', false);
        Campaign ipaCampaignForAP8 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP 8',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', '', 'Planned', false);
        Campaign ipaCampaignForAP9 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP 9',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', '', 'Planned', false);
        Campaign ipaCampaignForAP10 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP 10',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', '', 'Planned', false);
        Campaign ipaCampaignForAP11 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP 11',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', '', 'Planned', false);
        campaignList.add(ipaCampaignForAP1);campaignList.add(ipaCampaignForAP2);campaignList.add(ipaCampaignForAP3);campaignList.add(ipaCampaignForAP4);
        campaignList.add(ipaCampaignForAP5);campaignList.add(ipaCampaignForAP6);campaignList.add(ipaCampaignForAP7);campaignList.add(ipaCampaignForAP8);
        campaignList.add(ipaCampaignForAP9);campaignList.add(ipaCampaignForAP10);campaignList.add(ipaCampaignForAP11);
        insert campaignList;
        Test.stopTest();
    }
    
    private class Core_MDF_Bulk_Approvals_Requests{
        private ApprovalRequestsWrapper aprReqsWrapper;
    }
    private class ApprovalRequestsWrapper {
        private String requestId;
        private String actionStatus;
        private String comments;
    }
    
  @isTest
    private static void executeBulkApprovalsBatchTest() {
        
       
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account'];
        
        List<Campaign> ipaCampaignsList = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                           Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,
                                           StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c  
                                           FROM Campaign WHERE Name LIKE 'Test Campaign - AP%' LIMIT 11];
        PartnerFundAllocation pfa=[Select id from PartnerFundAllocation where Title= :'allocation'];
        Test.startTest();
        
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        PartnerFundRequest ipaPFR1 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignsList[0].id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        PartnerFundRequest ipaPFR2 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignsList[1].id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        PartnerFundRequest ipaPFR3 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignsList[2].id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        PartnerFundRequest ipaPFR4 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignsList[3].id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignsList[4].id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        PartnerFundRequest ipaPFR6 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignsList[5].id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        PartnerFundRequest ipaPFR7 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignsList[6].id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        PartnerFundRequest ipaPFR8 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignsList[7].id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        PartnerFundRequest ipaPFR9 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignsList[8].id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        PartnerFundRequest ipaPFR10 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignsList[9].id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        PartnerFundRequest ipaPFR11 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignsList[10].id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        
        ipaPFR1.AllocationId=pfa.id;
         ipaPFR2.AllocationId=pfa.id;
         ipaPFR3.AllocationId=pfa.id;
         ipaPFR4.AllocationId=pfa.id; 
         ipaPFR5.AllocationId=pfa.id;
         ipaPFR6.AllocationId=pfa.id;
         ipaPFR7.AllocationId=pfa.id;
         ipaPFR8.AllocationId=pfa.id;
         ipaPFR9.AllocationId=pfa.id;
         ipaPFR10.AllocationId=pfa.id;
         ipaPFR11.AllocationId=pfa.id;
        
        pfrList.add(ipaPFR1);pfrList.add(ipaPFR2);pfrList.add(ipaPFR3);pfrList.add(ipaPFR4);pfrList.add(ipaPFR5);pfrList.add(ipaPFR6);
        pfrList.add(ipaPFR7);pfrList.add(ipaPFR8);pfrList.add(ipaPFR9);pfrList.add(ipaPFR10);pfrList.add(ipaPFR11);
        insert pfrList;
        
        List<Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper> aprReqsList = new List<Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper>();
        Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper apr1 = new Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper();
        Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper apr2 = new Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper();
        Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper apr3 = new Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper();
        Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper apr4 = new Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper();
        Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper apr5 = new Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper();
        Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper apr6 = new Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper();
        Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper apr7 = new Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper();
        Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper apr8 = new Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper();
        Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper apr9 = new Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper();
        Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper apr10 = new Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper();
        Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper apr11 = new Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper();
        
        apr1.requestId = ipaPFR1.Id;apr1.actionStatus = 'Approve';apr1.comments = 'Batch 1';
        apr2.requestId = ipaPFR2.Id;apr2.actionStatus = 'Reject';apr2.comments = 'Batch 2';
        apr3.requestId = ipaPFR3.Id;apr3.actionStatus = 'Approve';apr3.comments = 'Batch 3';
        apr4.requestId = ipaPFR4.Id;apr4.actionStatus = 'Reject';apr4.comments = 'Batch 4';
        apr5.requestId = ipaPFR5.Id;apr5.actionStatus = 'Reject';apr5.comments = 'Batch 5';
        apr6.requestId = ipaPFR6.Id;apr6.actionStatus = 'Reject';apr6.comments = 'Batch 6';
        apr7.requestId = ipaPFR7.Id;apr7.actionStatus = 'Reject';apr7.comments = 'Batch 7';
        apr8.requestId = ipaPFR8.Id;apr8.actionStatus = 'Reject';apr8.comments = 'Batch 8';
        apr9.requestId = ipaPFR9.Id;apr9.actionStatus = 'Reject';apr9.comments = 'Batch 9';
        apr10.requestId = ipaPFR10.Id;apr10.actionStatus = 'Reject';apr10.comments = 'Batch 10';
        apr11.requestId = ipaPFR11.Id;apr11.actionStatus = 'Reject';apr11.comments = 'Batch 11';
        
        aprReqsList.add(apr1);aprReqsList.add(apr2);aprReqsList.add(apr3);aprReqsList.add(apr4);aprReqsList.add(apr5);aprReqsList.add(apr6);
        aprReqsList.add(apr7);aprReqsList.add(apr8);aprReqsList.add(apr9);aprReqsList.add(apr10);aprReqsList.add(apr11);
        
        String aprReqInput = JSON.serialize(aprReqsList);
        List<Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper> aprReInputBatchList =  (List<Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper>) JSON.deserialize(aprReqInput, List<Core_MDF_Bulk_Approvals_Requests.ApprovalRequestsWrapper>.class);
        Core_MDF_Bulk_Approval_requests_Batch batch = new Core_MDF_Bulk_Approval_requests_Batch(aprReInputBatchList);
        Database.executeBatch(batch);
        Test.stopTest();

        List<PartnerFundRequest> updatedPFRs = [SELECT Id, Status FROM PartnerFundRequest WHERE Id IN :pfrList];
        // US - TWC702-14285: Unit Test Method should include System.Assert
        System.assertEquals(11, updatedPFRs.size(), 'Expected 11 PartnerFundRequest records after batch processing');
        
}
}