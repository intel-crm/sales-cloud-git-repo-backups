@IsTest(SeeAllData=false)
public class Core_MDF_Display_Approval_Details_Test {
    @TestSetup static void testDataSetup(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User User1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        User1.LastName ='Admin User';
        User1.UserRoleId=usRole1.id;
        insert User1;
        System.runAs(User1){
        // Creating Intel Recordtype Account with utility class
        List<Account> accList = new List<Account>();
        // Creating Intel Account with utility class
        Account accRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Intel Test Account ', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        accRecord.BillingCity = 'Test City';         
        accRecord.BillingCountry= 'AUS';
        accRecord.BillingStreet= 'Test Street';
        Database.insert(accRecord);   
        accRecord.isPartner = true;
        accList.add(accRecord);
        
        // Creating channel program with utility class
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        // Creating Intel Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_MDF_CoMarketingActive__c = true;
        acc1.Core_Account_Type__c = 'Reseller';
        //acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
        acc1.Industry = 'Food & Beverage';
        acc1.Core_MDF_Channel_Program__c = cp.Id;
        insert acc1; 
        
        // Creating Co-marketing Account with utility class
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        acc.Core_MDF_CoMarketingActive__c = true;
        insert acc;
        
        // Creating campaigns using utility class
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today().addDays(-25) , System.today().addYears(+1), 2000, 'Unite', acc.Id,'2-in-1', true);
        Test.startTest();

        //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        	bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
             List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);

        
                    
        PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData',Core_MDF_CCP_TestDataUtility.budget_Record_Type, acc.id, cp.Id , 100000000 , System.today() - 25 , System.today() + 45 , false);
        testBudget.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
        insert testBudget;
        
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',testBudget,acc,2000.0,true);
        PartnerFundRequest testPartnerFundRequestObj = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),
                                                                                                                   Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                                   string.valueof(acc.id),
                                                                                                                   NULL,NULL,'ALBANIA','Consumer',
                                                                                                                   'Desktop','Intel® Corporate Logo',
                                                                                                                   'Broadcast','Radio',
                                                                                                                   'Draft',false,true,
                                                                                                                   'Others','Test Other CP');
        testPartnerFundRequestObj.Core_MDF_Start_Date__c = System.today().addDays(-6);
        testPartnerFundRequestObj.Core_MDF_End_Date__c = System.today().addDays(+10);
        testPartnerFundRequestObj.RequestedAmount=100000000;
        testPartnerFundRequestObj.Core_MDF_Reimbursement_Rate_txt__c='100%';
        testPartnerFundRequestObj.Title = 'testClassTest';
        testPartnerFundRequestObj.status='Approved';
        testPartnerFundRequestObj.budgetid=testBudget.Id;
        testPartnerFundRequestObj.allocationid=allocation.Id;
        testPartnerFundRequestObj.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        testPartnerFundRequestObj.Core_MDF_ActivityCategory__c='';//14285 //Suma
        testPartnerFundRequestObj.Core_MDF_Activity_Types__c='';//14285 //Suma
        insert(testPartnerFundRequestObj);
        }
    }
    
    @isTest
    static void testApprovalDisplay(){
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PartnerFundRequest pfr = [select id from PartnerFundRequest WHERE Title = 'testClassTest' limit 1];
        Core_MDF_Display_Approval_Details.getApprovalDetails(pfr.id);
        
        Core_MDF_Display_Approval_Details.InputData inputData =  new Core_MDF_Display_Approval_Details.InputData();
        inputData.Program = Core_MDF_CCP_ConstantClass.CCF_PROGRAM;
        inputData.BudgetType = 'CCF 1.0';
        inputData.Status = 'Pending Review';
        inputData.SPIFCheck = false;
        inputData.PORCheck = false;
        inputData.CreatedByExternalUser = false;
        inputData.currentApprovalStage = 'L1 Approval';
        inputData.AmountRange = 100000; 
        inputData.AdditionalReview = false;
        inputData.ActivityClassification = 'None';
        inputData.CreatedByInternalUserType = 'None';
        inputData.IntelOwnerSelected = false;
        Core_MDF_Display_Approval_Details.getBREConfigData(inputData);
        
        Core_MDF_Display_Approval_Details.OutputData outputData =  new Core_MDF_Display_Approval_Details.OutputData();
        outputData.Stage1 = 'Stage1';
        outputData.Stage2 = 'Stage2';
        outputData.Stage3 = 'Stage3';
        outputData.Stage4 = 'Stage4';
        outputData.Stage5 = 'Stage5';
        outputData.Stage6 = 'Stage6';
        outputData.Stage7 = 'Stage7';
        outputData.Stage8 = 'Stage8';
        outputData.Stage9 = 'Stage9';
        outputData.Stage10 = 'Stage10';
        List<Core_MDF_Display_Approval_Details.OutputWrapper> outputWrapList = new list<Core_MDF_Display_Approval_Details.OutputWrapper>();
        Core_MDF_Display_Approval_Details.OutputWrapper outputWrap = new Core_MDF_Display_Approval_Details.OutputWrapper();
        outputWrap.outputValues = outputData;
        outputWrapList.add(outputWrap);
        Core_MDF_Display_Approval_Details.InputData input = new Core_MDF_Display_Approval_Details.InputData();
        input.currentApprovalStage = 'Stage8';
        Core_MDF_Display_Approval_Details.ContentResultBRE breResult = Core_MDF_Display_Approval_Details.getOutputContent(outputWrapList,input);
        Assert.areNotEqual(outputWrapList, null);
    }
    
}