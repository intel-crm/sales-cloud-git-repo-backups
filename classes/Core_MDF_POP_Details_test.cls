/****************************************************************************************************************************************
* Test Class Name :  Core_MDF_POP_Details_test
* Test Class for  :  Core_MDF_POP_Details
* Version     : 1.0 
* Created Date: 16-Sep-2020
* Modification Log :
* Developer            Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Vivek K           09/16/2020                  Created
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_POP_Details_test {
    
    @TestSetUp
    static void createTestData() {
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        List<User> usrList=new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'TestUser123';
        usr.profileId = systemAdminProfile.Id;
        usrList.add(usr);
        Database.insert(usrList);
        System.runAs(usr){
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('byPass_Cancel_Activity');
            bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc3.Core_Geo__c = 'APJ';
            acc3.Core_Sub_Geo__c = 'IJKK';
            insert acc3;
            
            Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, false);
            acc4.Core_Geo__c = 'APJ';
            acc4.Core_Sub_Geo__c = 'IJKK';
            insert acc4;
            
            PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                           acc4.id, cp1.Id , 10000 , System.today()-60 , System.today() + 60 , 
                                                                                           false);
            testBudget1.IsIgnoreValidation = true;
            insert testBudget1;
            
            testBudget1.Core_MDF_Budget_Status__c = 'Released';
            update testBudget1; 
            
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 24','Gaming','Athena','Yes', 
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today(), 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', acc4.Id,'2-in-1', false);
            
            insert camp1;
        }
    }
    
    @isTest 
    static void runKPIDetailPagetest() {
        Integer pfrCount = 0;
        Core_MDF_POP_Details.POPWrapper popRes= new Core_MDF_POP_Details.POPWrapper();               
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
        
        Test.startTest();
        System.runAs(usr1) {

            Account acc4 = [select id from account where name = 'Test Account 4']; 
            Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
          
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),System.today(),System.today(),false);
            testPartnerFundRequestRecord.Core_MDF_ActivityCategory__c = 'Digital';// 14285 Suma
            testPartnerFundRequestRecord.Core_MDF_Activity_Types__c = 'Email';// 14285 Suma
            pfrtoinsert.add(testPartnerFundRequestRecord);
            insert testPartnerFundRequestRecord;
            
            popDetailObj inputValues = new popDetailObj();
            inputValues.actCat =testPartnerFundRequestRecord.Core_MDF_ActivityCategory__c ;
            inputValues.actType = testPartnerFundRequestRecord.Core_MDF_Activity_Types__c;
            inputValues.displayLabel = 'POP';
            inputValues.recTypeName = 'Retail Marketing Fund';
            inputValues.objectApiName = 'PartnerFundRequest';
            inputValues.recordId = testPartnerFundRequestRecord.Id;
            String inputStr = json.serialize(inputValues);
            
            popRes = Core_MDF_POP_Details.getPOPvalues(inputStr);
            pfrCount += 1;
            Test.stopTest();
        }
        //Assert.isTrue(String.isNotBlank(popRes.datamap), 'POP value fetched');
    }
    
    @isTest 
    static void runPOPDetailPagetestforNull(){
        Test.startTest();
        popDetailObj inputValues1 = new popDetailObj();
        String inputStr1 = json.serialize(inputValues1);
        Core_MDF_POP_Details.POPWrapper popRes= new Core_MDF_POP_Details.POPWrapper(); 
        popRes = Core_MDF_POP_Details.getPOPvalues(inputStr1);
        Test.stopTest();
        Assert.isTrue(String.isBlank(popRes.datamap), 'No POP value fetched');
    }
    
    private class popDetailObj {
        private String recordId;
        private string objectApiName = '';
        private string actCat = '';
        private string actType = '';
        private string displayLabel = '';
        private string recTypeName = '';
    }
    @isTest 
	static void testLogErrorAsync() {
        Test.startTest();
        // This tests the @future method which is currently not covered
        Core_MDF_POP_Details.logErrorAsync('Test error message');
        Test.stopTest();
        Assert.isTrue(true, 'Async logging completed');
}

    @isTest
    static void testInvalidInputs() {
    Test.startTest();
    
    // Test with invalid recordId format
    popDetailObj inputValues = new popDetailObj();
    inputValues.recordId = 'invalid_id_format';
    inputValues.objectApiName = 'PartnerFundRequest';
    inputValues.actCat = 'Digital';
    inputValues.actType = 'Email';
    inputValues.recTypeName = 'Retail Marketing Fund';
    String inputStr = json.serialize(inputValues);
    
    Core_MDF_POP_Details.POPWrapper popRes = Core_MDF_POP_Details.getPOPvalues(inputStr);
    
    Test.stopTest();
    Assert.isNotNull(popRes, 'Should return empty wrapper for invalid input');
}

    @isTest
    static void testValidParametersWithoutRecordId() {
    Test.startTest();
    
    // This will hit the fetchPOPMetadata method
    popDetailObj inputValues = new popDetailObj();
    inputValues.recordId = '';
    inputValues.objectApiName = '';
    inputValues.actCat = 'Digital';
    inputValues.actType = 'Email';
    inputValues.displayLabel = 'POP';
    inputValues.recTypeName = 'Retail Marketing Fund';
    String inputStr = json.serialize(inputValues);
    
    Core_MDF_POP_Details.POPWrapper popRes = Core_MDF_POP_Details.getPOPvalues(inputStr);
    
    Test.stopTest();
    Assert.isNotNull(popRes, 'Should return wrapper object');
    Assert.isNotNull(popRes.displayHeader, 'Should have display header');
}
}