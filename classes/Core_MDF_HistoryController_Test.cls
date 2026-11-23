@isTest(SeeAllData=false)
private class Core_MDF_HistoryController_Test {

@TestSetup static void setUpData(){

    UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
    //Creating User with utility class
    User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
    usr.LastName = 'User Test';
    usr.UserRoleId = usRole.Id;
    Database.insert(usr);
    
    List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();

        PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Payment_Adm' LIMIT 1];
    PermissionSet ccfAccManagerPS1 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
    PermissionSet dcfAccManagerPS2 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1];
        
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = usr.Id);
        permissionSetAssignmentList.add(psa);
        
        PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = dcfAccManagerPS.Id, AssigneeId = usr.Id);
        permissionSetAssignmentList.add(psa2);
    
     PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS1.Id, AssigneeId = usr.Id);
        permissionSetAssignmentList.add(psa3);
        
        PermissionSetAssignment psa4 = new PermissionSetAssignment(PermissionSetId = dcfAccManagerPS2.Id, AssigneeId = usr.Id);
        permissionSetAssignmentList.add(psa4);

        insert permissionSetAssignmentList;
    
    List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();

    System.runAs(usr){
        
            List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            config.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
            insert config;
        // Creating channel program with utility class
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);

        // Creating IntelAccount with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,
                                                                        false);
        acc1.Core_Account_Type__c = 'Reseller';
        //acc1.Core_Sales_Groups__c = 'Automotive Sales Group';
        acc1.Industry = 'Food & Beverage';
        acc1.Core_MDF_Channel_Program__c = cp.Id;
        acc1.Core_MDF_CoMarketingAgency__c=true;
        Database.insert(acc1);

        // Creating Co-marketing Account with utility class
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                  Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        Database.insert(acc);

        // Creating Contact with utility class
        Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
        con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
        Database.insert(con);

        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];

        // Creating User with utility class
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.ProfileId = partnerProfile.Id;
        usr1.ContactId = con.Id;
        Database.insert(usr1);

        // Creating campaigns using utility class
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','MDF or both CMP & MDF',
                                                                    Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                    'Client CoMarketing Fund',System.today(),
                                                                    System.today().addDays(10), 2000, 'Small Business',acc.Id,'2-in-1', false);
         camp.Core_MDF_Opal_Budget_Type_Txt__c= 'MDF';
         insert camp;                                                          

        // Creating Budget using utility class
        PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                               acc.Id,cp.Id,5000000,System.today(),System.today().addDays(110),
                                                                               false);
        pmb.Core_MDF_Budget_Type_Txt__c = 'MDF';
        insert pmb;
        // Creating Allocation using utility class
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);

        // Creating activities using utility class
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                       Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                       string.valueof(acc.id),pfa,pmb,'INDIA','Small Business',
                                                                                       'Desktop','Intel® Core™ i7 Processor','Broadcast',
                                                                                       'Radio','Draft',false);
        pfr.RequestedAmount = 900000;
        pfr.Amount = 900000;
        pfr.Status = 'Approved';
        pfr.AllocationId = pfa.Id;
        pfr.BudgetId = pmb.Id;
        pfr.Core_MDF_Start_Date__c = system.today();
        pfr.Core_MDF_End_Date__c = system.today();
        pfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
        Database.insert(pfr);

        pfr.RequestedAmount = 912000.00;
        pfr.Amount = 900000.1234;
        pfr.Status = 'Approved';
        pfr.Core_MDF_Start_Date__c = system.today();
        pfr.Core_MDF_End_Date__c = system.today().addDays(1);
        update pfr;

        test.startTest();
        // Creating Bank
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');

        //creating ABM for bank1
            // Highlight: Unused Local Variable 
           // Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,true);
        
        PartnerFundRequestShare pfrShare = new PartnerFundRequestShare();
        pfrShare.ParentId = pfr.Id;
        pfrShare.UserOrGroupId = usr1.id;
        pfrShare.AccessLevel = 'Edit';
        Database.insert(pfrShare);

        Core_MDF_Bank__Share bankShare  = new Core_MDF_Bank__Share();
        bankShare.ParentId = bank.Id;
        bankShare.UserOrGroupId = usr1.id;
        bankShare.AccessLevel = 'Edit';
        Database.insert(bankShare);


        PartnerFundClaim pfc  = new PartnerFundClaim();
        pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
        pfc.Title = 'Test Claim';
        pfc.RequestId = pfr.Id;
        pfc.Core_MDF_Total_Invoice_Amount_Local__c = 400;
        pfc.Core_MDF_Status__c = 'Submitted';
        pfc.Description = 'Test PFC ';
        pfc.Core_MDF_Ad_Run_Start_Date__c = System.today();
        pfc.Core_MDF_Ad_Run_End_Date__c = System.today();
        pfc.Core_MDF_Invoice_Date__c = System.today();
        pfc.Core_MDF_Invoice_Number__c = '1121';
        pfc.Core_MDF_Media_Vehicle__c = 'test';
        pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        pfc.Core_MDF_Taxes_Local__c = 0;
        pfc.Core_MDF_Currency__c = 'USD';
        pfc.Core_MDF_Exchange_rate__c = 1;
        pfc.Core_MDF_Bank__c = bank.Id;
        pfc.Core_MDF_Claim_Comments__c = '123.4567';
        pfc.Core_MDF_Country_Location_nm__c='UNITED STATES';
        pfc.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';        
        newClmList.add(pfc);
            // Highlight: Unused Local Variable 
           // User partnerUser = [SELECT Id, LastName FROM User WHERE LastName='User Test1'];
        //Creating claims as partner user
       // System.runAs(partnerUser){
            Database.insert(newClmList);
            
        //}

         PartnerFundClaim clm = [SELECT Id,Core_MDF_Claim_Comments__c,Core_MDF_Status__c,OwnerId FROM PartnerFundClaim LIMIT 1];    
         clm.Core_MDF_Status__c = 'Payment Due';
         clm.OwnerId = usr.Id;
         update clm;
          
            // Highlight: Unused Local Variable 
            // List<sObject> historyDatafromQuery = [SELECT Id, CreatedById, format(CreatedDate), toLabel(Field), toLabel(OldValue), toLabel(NewValue),PartnerFundClaimId FROM PartnerFundClaimHistory where PartnerFundClaimId = :clm.Id order by CreatedDate desc];
    
       
        
        List<Core_MDF_HistoryController.History> h = new List<Core_MDF_HistoryController.History>();
        
        h = Core_MDF_HistoryController.loadData(acc1.Id,'Account','Intel System User','Owner');
        
        Core_MDF_HistoryController.loadData(clm.Id,'PartnerFundClaim','Intel System User','Owner');

        List<Core_MDF_HistoryController.History> h1 = new List<Core_MDF_HistoryController.History>();
        //h1 = Core_MDF_HistoryController.loadData(bank.Id,'Core_MDF_Bank__c','Intel System User');
        h1 = Core_MDF_HistoryController.loadData(newClmList[0].Id,'PartnerFundClaim','Intel System User','Owner');
test.stopTest();
    }
}

@IsTest
static void testHistoryDataDecimal(){
    Test.startTest();
    PartnerFundClaim clm = [SELECT Id,Core_MDF_Claim_Comments__c,Core_MDF_Invoice_Date__c,Core_MDF_StartTime_dtm__c,Core_MDF_Media_Vehicle__c FROM PartnerFundClaim LIMIT 1];    
    clm.Core_MDF_Claim_Comments__c = '1123.4567';
    clm.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
    clm.Core_MDF_StartTime_dtm__c = System.today().addDays(-5);
    clm.Core_MDF_Media_Vehicle__c = 'No';
    update clm;
    Test.stopTest();
    System.assertNotEquals(null, clm.Id);
    
    
}
    
    @IsTest
static void testHistoryHeaderForStandardObj(){
       
        Core_MDF_HistoryController.HistoryHeader hh =new Core_MDF_HistoryController.HistoryHeader();    
        hh = Core_MDF_HistoryController.getHistoryHeader('Account','0982345');
        System.AssertEquals('Account History',hh.objectName);           
}
    @IsTest
static void testHistoryHeaderForCustomObj(){
        
        Core_MDF_HistoryController.HistoryHeader hh1 =new Core_MDF_HistoryController.HistoryHeader();
        hh1 = Core_MDF_HistoryController.getHistoryHeader('Core_MDF_Partner_Node_User_Mapping__c','0982345');        
        String expectedHeaderString = 'Account User History';
    if(hh1.objectName != null){
        System.AssertEquals(expectedHeaderString.equalsIgnoreCase(hh1.objectName),true); 
    }
           
}

}