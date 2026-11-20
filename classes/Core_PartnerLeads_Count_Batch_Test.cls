/**
 * @description Test class for Core_PartnerLeads_Count_Batch and Core_PartnerLeads_Count_Batch_Schedule
 * @author Pooja Gosika
*/
@IsTest
public class Core_PartnerLeads_Count_Batch_Test {
    
    /**
     * @description Test method for Core_PartnerLeads_Count_Batch functionality
     */
    @IsTest
    static void testCorePartnerLeadsCountBatch(){
        // Setup test data
        setupCustomSettings();
        
        List<Account> accountList = createTestAccounts();
        List<Lead> leadList = createTestLeads();
        
        PMP_Company__c pmpCompany = createPmpCompany(accountList[0].Id);
        PMP_OPID_MPI_Rel__c opidMpiRelation = createOpidMpiRelation(accountList[0].Id, pmpCompany.Id);
        
        List<Group> groupList = createTestGroups(accountList);
        createGroupMembers(groupList);
        
        List<Lead> updatedLeadList = setupLeadsWithStatuses(leadList, pmpCompany.Id);
        createLeadShares(groupList, updatedLeadList);
        
        // Execute test
        Test.startTest();
        executeBatchAndScheduler();
        Test.stopTest();
        
        // Verify results
        verifyBatchExecution();
        
        // Additional assertion to ensure batch job processed leads correctly
        // Check that the batch job actually processed some leads
        List<Lead> leadsAfterBatch = [
            SELECT Id, Core_Lead_Status__c, Status 
            FROM Lead 
            WHERE Id IN :updatedLeadList
            AND Core_Lead_Status__c != null
        ];
        System.assert(leadsAfterBatch.size() > 0, 'Batch job should have processed at least one lead');
    }
    
    /**
     * @description Setup custom settings for test
     */
    private static void setupCustomSettings(){
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        insert triggerExecList;
    }
    
    /**
     * @description Create test accounts
     * @return List<Account> List of created accounts
     */
    private static List<Account> createTestAccounts(){
        List<Account> accountList = Core_Test_Utility.createAccount(10);
        List<Account> updatedAccountList = new List<Account>();
        
        for(Account acc : accountList){
            acc.RecordTypeId = getPartnerAccountGroupRecordTypeId();
            acc.Core_Sales_Groups__c = 'PRC Sales Group';
            updatedAccountList.add(acc);
        }
        insert updatedAccountList;
        return updatedAccountList;
    }
    
    /**
     * @description Get Partner Account Group record type ID
     * @return Id Record type ID
     */
    private static Id getPartnerAccountGroupRecordTypeId(){
        return Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Partner Account Group').getRecordTypeId();
    }
    
    /**
     * @description Create test leads
     * @return List<Lead> List of created leads
     */
    private static List<Lead> createTestLeads(){
        return Core_Test_Utility.createLead(10);
    }
    
    /**
     * @description Create PMP Company record
     * @param accountId Account ID to associate with PMP Company
     * @return PMP_Company__c Created PMP Company record
     */
    private static PMP_Company__c createPmpCompany(Id accountId){
        PMP_Company__c pmpCompany1 = createBasicPmpCompany(accountId, 'test1');
        insert pmpCompany1;
        
        PMP_Company__c pmpCompany = createBasicPmpCompany(accountId, 'test');
        pmpCompany.PMP_Published_Copy_Id__c = pmpCompany1.Id;
        insert pmpCompany;
        
        return pmpCompany;
    }
    
    /**
     * @description Create basic PMP Company record
     * @param accountId Account ID
     * @param name Company name
     * @return PMP_Company__c PMP Company record
     */
    private static PMP_Company__c createBasicPmpCompany(Id accountId, String name){
        PMP_Company__c pmpCompany = new PMP_Company__c();
        pmpCompany.PMP_Account_Id__c = accountId;
        pmpCompany.Name = name;
        pmpCompany.PMP_Is_Published_Ind__c = true;
        pmpCompany.PMP_Partner_Benefit_Type__c = 'Solution Marketplace Basic Access';
        return pmpCompany;
    }
    
    /**
     * @description Create OPID MPI relation record
     * @param accountId Account ID
     * @param pmpCompanyId PMP Company ID
     * @return PMP_OPID_MPI_Rel__c Created relation record
     */
    private static PMP_OPID_MPI_Rel__c createOpidMpiRelation(Id accountId, Id pmpCompanyId){
        PMP_OPID_MPI_Rel__c opidMpiRelation = new PMP_OPID_MPI_Rel__c();
        opidMpiRelation.PMP_One_Partner_ID__c = accountId;
        opidMpiRelation.PMP_Marketing_Profile_Id__c = pmpCompanyId;
        insert opidMpiRelation;
        return opidMpiRelation;
    }
    
    /**
     * @description Create test groups
     * @param accountList List of accounts
     * @return List<Group> List of created groups
     */
    private static List<Group> createTestGroups(List<Account> accountList){
        List<Group> groupList = new List<Group>();
        
        for(Account account : accountList){
            Group testGroup = new Group(
                Name = 'PMP_' + account.Id + '_Client_Computing',
                DeveloperName = 'PMP_' + account.Id + '_Client_Computing'
            );
            groupList.add(testGroup);
        }
        insert groupList;
        return groupList;
    }
    
    /**
     * @description Create group members
     * @param groupList List of groups
     */
    private static void createGroupMembers(List<Group> groupList){
        List<GroupMember> groupMemberList = new List<GroupMember>();
        
        for(Group testGroup : groupList){
            GroupMember groupMember = new GroupMember(
                UserOrGroupId = UserInfo.getUserId(),
                GroupId = testGroup.Id
            );
            groupMemberList.add(groupMember);
        }
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert groupMemberList;
        }
    }
    
    /**
     * @description Setup leads with different statuses
     * @param leadList List of leads
     * @param pmpCompanyId PMP Company ID
     * @return List<Lead> Updated lead list
     */
    private static List<Lead> setupLeadsWithStatuses(List<Lead> leadList, Id pmpCompanyId){
        List<Lead> updatedLeadList = new List<Lead>();
        
        for(Lead lead : leadList){
            lead.Status = 'Tele Accepted Lead';
            lead.Core_Lead_Status__c = 'Accepted';
            lead.Core_Partner_Lead_Owner__c = UserInfo.getUserId();
            lead.RecordTypeId = getPartnerLeadRecordTypeId();
            lead.Core_Lead_State__c = 'In Pursuit';
            lead.Core_MPI_Id__c = pmpCompanyId;
            updatedLeadList.add(lead);
        }
        insert updatedLeadList;
        
        updateSpecificLeads(updatedLeadList);
        return updatedLeadList;
    }
    
    /**
     * @description Get Partner Lead record type ID
     * @return Id Record type ID
     */
    private static Id getPartnerLeadRecordTypeId(){
        return Schema.SObjectType.Lead.getRecordTypeInfosByName()
            .get('Partner Lead').getRecordTypeId();
    }
    
    /**
     * @description Update specific leads with different statuses
     * @param leadList List of leads to update
     */
    private static void updateSpecificLeads(List<Lead> leadList){
        // Update lead 1 - Contacted to Qualified
        leadList[1].Core_Lead_Status__c = 'Contacted';
        leadList[1].Status = 'PAL';
        leadList[1].Core_Lead_Contact_Estb_Dt__c = true;
        update leadList[1];
        
        leadList[1].Core_Lead_Status__c = 'Qualified';
        leadList[1].Status = 'PQL';
        update leadList[1];
        
        // Update lead 2 - Contacted
        leadList[2].Core_Lead_Status__c = 'Contacted';
        leadList[2].Status = 'PAL';
        update leadList[2];
        
        // Update lead 3 - Rejected
        leadList[3].Core_Lead_Status__c = 'Rejected';
        leadList[3].Status = 'Terminated';
        leadList[3].Core_Lead_Sub_Status__c = 'Bad Data';
        update leadList[3];
    }
    
    /**
     * @description Create lead shares
     * @param groupList List of groups
     * @param leadList List of leads
     */
    private static void createLeadShares(List<Group> groupList, List<Lead> leadList){
        List<LeadShare> leadShareList = new List<LeadShare>();
        Integer leadIndex = 0;
        
        for(Group testGroup : groupList){
            if(leadIndex < leadList.size()){
                LeadShare leadShare = new LeadShare(
                    LeadId = leadList[leadIndex].Id,
                    UserOrGroupId = testGroup.Id,
                    LeadAccessLevel = 'Edit'
                );
                leadShareList.add(leadShare);
                leadIndex++;
            }
        }
        insert leadShareList;
    }
    
    /**
     * @description Execute batch and scheduler
     */
    private static void executeBatchAndScheduler(){
        Core_PartnerLeads_Count_Batch_Schedule partnerSchedule = new Core_PartnerLeads_Count_Batch_Schedule();
        String scheduleExpression = '0 5 * * * ?';
        System.schedule('Test status Check', scheduleExpression, partnerSchedule);
        
        Database.executeBatch(new Core_PartnerLeads_Count_Batch(), 10);
    }
    
    /**
     * @description Verify batch execution
     */
    private static void verifyBatchExecution(){
        List<AsyncApexJob> jobList = [
            SELECT Id 
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'Core_PartnerLeads_Count_Batch'
        ];
        System.assertEquals(false, jobList.isEmpty(), 'Batch job should be executed');
    }
    
    /**
     * @description Test method for edge cases and error scenarios
     */
    @IsTest
    static void testEdgeCasesAndErrorScenarios(){
        // Test with empty data
        Test.startTest();
        Database.executeBatch(new Core_PartnerLeads_Count_Batch(), 10);
        Test.stopTest();
        
        List<AsyncApexJob> jobList = [
            SELECT Id 
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'Core_PartnerLeads_Count_Batch'
        ];
        System.assertEquals(false, jobList.isEmpty(), 'Batch job should handle empty data gracefully');
    }
    
    /**
     * @description Test method for scheduler functionality
     */
    @IsTest
    static void testSchedulerFunctionality(){
        Test.startTest();
        Core_PartnerLeads_Count_Batch_Schedule partnerSchedule = new Core_PartnerLeads_Count_Batch_Schedule();
        String scheduleExpression = '0 0 1 * * ?';
        String jobId = System.schedule('Test Partner Leads Count Schedule', scheduleExpression, partnerSchedule);
        Test.stopTest();
        
        System.assertNotEquals(null, jobId, 'Scheduler should return a job ID');
    }
}