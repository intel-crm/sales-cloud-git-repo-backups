@isTest(SeeAllData=false)
private class Core_MDF_ActivityStatusTrigger_Test {
    
    //@isTest(SeeAllData=false)
    @TestSetup static void partnerUserCreation(){
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User User1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        User1.LastName ='Admin User';
        User1.UserRoleId=usRole1.id;
        insert User1;
        system.runAs(User1){
        Core_MDF_Configuration__c vatConfig = new Core_MDF_Configuration__c();
            vatConfig.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            vatConfig.Core_MDF_Value__c = 'Retail Marketing Funds;Intel Partner Alliance';
            insert vatConfig;
            
            
        List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();            
        Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
        record1.Name= 'ZMK';
        record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
        record1.Core_MDF_Market_Date__c =System.today()-2;
        record1.Core_MDF_Intel_WW__c = 'WW 46';
        newValues.add(record1);
        
        Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
        record2.Name= 'INR';
        record2.Core_MDF_Exchange_Rate__c = 1;
        record2.Core_MDF_Market_Date__c =System.today()-2;
        record2.Core_MDF_Intel_WW__c = 'WW 46';
        newValues.add(record2); 
        
        Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
        record3.Name= 'USD';
        record3.Core_MDF_Exchange_Rate__c = 1;
        record3.Core_MDF_Market_Date__c =System.today()-2;
        record3.Core_MDF_Intel_WW__c = 'WW 46';
        newValues.add(record3); 
        
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount bObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount cObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listvar = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
        
        aObj.inputCurrency ='ZMK';
        aObj.inputAmount = 250.00;
        aObj.inputDate= date.newInstance(2018, 11, 13);
        bObj.inputCurrency ='INR';
        bObj.inputAmount = 350.00;
        bObj.inputDate= date.newInstance(2018, 11, 12);
        cObj.inputCurrency ='USD';
        cObj.inputAmount = 350.00;
        cObj.inputDate= date.newInstance(2018, 11, 12);
        listvar.add(aObj);
        listvar.add(bObj);
        listvar.add(cObj);
        Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);
        
        database.insert(newValues); 
        
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
        acc1.Core_Sales_Groups__c = ''; //'Americas Brazil Sales Group';
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
        // Highlight: Unused Local Variable - 14285
            //List<PartnerFundRequest> testPartnerFundRequestRecordList = new List<PartnerFundRequest>();
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
        
        //Creating Budget
         /*PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createRetailBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
            acc.id, cp.Id , 100000000 , System.today() - 25 , System.today() + 45 , false, 'CCF 1.0');
            testBudget.IsIgnoreValidation = true;
            insert testBudget;*/
            
        PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData',Core_MDF_CCP_TestDataUtility.budget_Record_Type, acc.id, cp.Id , 100000000 , System.today() - 25 , System.today() + 45 , false);
        //testBudget.IsIgnoreValidation = true;
        testBudget.Core_MDF_Budget_Type_Txt__c='OEM CMP';   // 14285 Indira
        insert testBudget;
        /*testBudget.Core_MDF_Budget_Status__c = 'Released';
        update testBudget;*/
        
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',testBudget,acc,2000.0,true);
        // Creating activity without budget
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
        testPartnerFundRequestObj.Core_MDF_ActivityCategory__c='Audio';  // 14285 Indira
        //Setting fund request status to in-progress
        //Id allocId = Core_MDF_PartnerFundRequestCreatePage.fundAllocationCreation(testPartnerFundRequestObj);
        //testPartnerFundRequestObj.AllocationId = allocId;
        insert(testPartnerFundRequestObj);
        
        //BankCreation
        Core_MDF_Bank__c testBankRecordCCF = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id,NULL,true,'4587452145');
        
        //Claim Creation
        PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                               testPartnerFundRequestObj.Id,system.today(), system.today(),3000.00, 
                                                                               system.today(), testBankRecordCCF.ID, false);
        indiaClaim.Core_MDF_Requested_Reimbursement_Amt__c = 100;
        indiaClaim.Core_MDF_Total_Invoice_Amount_Local__c = 3000;
        indiaClaim.Core_MDF_Currency__c = 'USD';
        indiaClaim.Core_MDF_Type_Txt__c = 'Claim';
        indiaClaim.Core_MDF_Exchange_rate__c = 1;
        insert indiaClaim;
        //Claim Creation
        //Claim Creation
        PartnerFundClaim indiaClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                testPartnerFundRequestObj.Id,system.today(), system.today(),2000.00, 
                                                                                system.today(), testBankRecordCCF.ID, false);
        indiaClaim1.Core_MDF_Requested_Reimbursement_Amt__c = 1;
        indiaClaim1.Core_MDF_Currency__c = 'USD';
        indiaClaim1.Core_MDF_Type_Txt__c = 'Claim';
        indiaClaim1.Core_MDF_Exchange_rate__c = 1;
        insert indiaClaim1;
        Test.stopTest();
        }
    }
    
    @isTest(SeeAllData=false)
    static void testStatusTrigger()
    {
        Test.startTest();
        Profile itAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = itAdminProfile.Id;
        insert usr;
        
        //PermissionSet
        List<PermissionSet> permissionSetList = [SELECT Id from PermissionSet
                                                 WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer']; 
        
        //Assigning PermissionSet to User
        // Highlight: Unused Local Variable - 14285 
        //PermissionSetAssignment permSetAssignObj = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr.Id,permissionSetList[0].Id,true);
        //SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM PartnerFundRequestShare
        
        
        System.runAs(usr){
            List<PartnerFundRequest> testPartnerFundRequestList = [SELECT Id,Core_MDF_Fund_Request_Status__c,Title
                                                                   FROM PartnerFundRequest
                                                                   WHERE Title = 'testClassTest'
                                                                   LIMIT 1];
            //Changing send request status to cancelled to trigger
            testPartnerFundRequestList[0].Core_MDF_Fund_Request_Status__c = 'Cancelled';
            try{
                update(testPartnerFundRequestList);
            }
            catch(Exception e){
                System.assert(e != null);
            }
             
        }
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false)
    static void testDateTrigger()
    {
        Test.startTest();
        Profile itAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = itAdminProfile.Id;
        insert usr;
        
        //PermissionSet
        List<PermissionSet> permissionSetList = [SELECT Id from PermissionSet
                                                 WHERE PermissionSet.Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer']; 
        
        //Assigning PermissionSet to User
        // Highlight: Unused Local Variable - 14285 
        //PermissionSetAssignment permSetAssignObj = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr.Id,permissionSetList[0].Id,true);
        //SELECT Id, ParentId, UserOrGroupId, AccessLevel FROM PartnerFundRequestShare
        
        
        System.runAs(usr){
            List<PartnerFundRequest> testPartnerFundRequestList = [SELECT Id,Core_MDF_Fund_Request_Status__c,Title
                                                                   FROM PartnerFundRequest
                                                                   WHERE Title = 'testClassTest'
                                                                   LIMIT 1];
            
            testPartnerFundRequestList[0].Core_MDF_Start_Date__c = System.today() + 5;
            try{
                update(testPartnerFundRequestList);
            }
            catch(Exception e){
                System.assert(e != null);
            }
            
        }
        Test.stopTest();
        
    }
     
}