@isTest
public class Core_MDF_ClmRecovery_ServiceHandlerTest {
    public static Id channelProgramId;
    
    @TestSetup static void setUpData() {
        
      
        //System Admin
        User systemAdm = Core_MDF_CCP_TestDataUtility.createUser(false);
        systemadm.Email = 'systemadm@example.com';
        insert systemAdm;
        
        
        // Creating channel program with utility class
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        channelProgramId = cp.Id;
         
        
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
        acc.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
        Database.insert(acc);  
          
        // Creating Contact with utility class
        Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
        con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
        Database.insert(con);
        //Role
        //UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
        
        List<User> userList = new List<User>();
        
        // Creating User with utility class 
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        //usr1.UserRoleId= usRole.id;
        usr1.ProfileId = partnerProfile.Id;
        usr1.ContactId = con.Id;
        insert usr1;
        
        //userList.add(usr1);
        // Creating User with utility class 
        User paymentAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
        paymentAdmin.LastName = 'Payment Admin';
        //paymentAdmin.UserRoleId = usRole.Id;
        insert paymentAdmin;
       
        // Creating campaigns using utility class
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 'yes',
                                                                    Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                    'Client CoMarketing Fund',System.today().addDays(-5) ,
                                                                    System.today().addDays(200), 2000, 'Test',acc.Id,'2-in-1', false);
        camp.Core_MDF_Activity_Category_Type__c=null;
        insert camp;
        Core_MDF_Configuration__c confign = new Core_MDF_Configuration__c();
		confign.Core_MDF_Value__c = '1000';
        confign.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
		insert confign;
        
       system.runAs(systemAdm){
           
        //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');

            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);

            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        // Creating Budget using utility class
        PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                               acc.Id,cp.Id,5000000,System.today().addDays(-5),System.today(), 
                                                                               false);
        pmb.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
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
        //pfr.Core_MDF_Ultimate_Account_Name__c = acc1.Id;
        pfr.Core_MDF_Start_Date__c = System.today().addDays(-5);
        pfr.Core_MDF_End_Date__c = System.today();
        Database.insert(pfr);
        Test.startTest();
        // Creating Bank using Utility class
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',true,'1234567890');
        
        List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
        Core_MDF_Account_Bank_Mapping__c abmCCF = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id, bank.Id, FALSE);
        abmCCF.Core_MDF_Active_ind__c = TRUE;
        insert abmCCF;
        
        PartnerFundRequestShare pfrShare = new PartnerFundRequestShare();
        pfrShare.ParentId = pfr.Id;
        pfrShare.UserOrGroupId = paymentAdmin.id;
        pfrShare.AccessLevel = 'Edit';
        Database.insert(pfrShare);
        
        Core_MDF_Bank__Share bankShare  = new Core_MDF_Bank__Share();
        bankShare.ParentId = bank.Id;
        bankShare.UserOrGroupId =paymentAdmin.id;
        bankShare.AccessLevel = 'Edit';
        Database.insert(bankShare);
        List<Core_MDF_Configuration__c> configList = new List<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
        config.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        config.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
        configList.add(config);
        database.insert(configList);
        // Creating claims 
        PartnerFundClaim pfc  = new PartnerFundClaim();
        pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
        pfc.Title = 'Test Claim';
        pfc.RequestId = pfr.Id;
        pfc.Core_MDF_Total_Invoice_Amount_Local__c = 200;        
        pfc.Core_MDF_Audit_Hold__c = true;                 
        pfc.Core_MDF_Status__c = 'Submitted';
        pfc.Description = 'Test PFC';
        pfc.Amount=100;
        pfc.Core_MDF_Type_Txt__c='Claim';
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
        pfc.Core_MDF_Country_Location_nm__c = 'INDIA';
        insert pfc;
        pfc.Core_MDF_Status__c='Payment Due';
        update pfc;
        
        PartnerFundClaim pfc2  = new PartnerFundClaim();
        pfc2.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
        pfc2.Title = 'Test Claim1';
        pfc2.RequestId = pfr.Id;
        pfc2.Core_MDF_Total_Invoice_Amount_Local__c = 200;        
        pfc2.Core_MDF_Audit_Hold__c = true;                 
        pfc2.Core_MDF_Status__c = 'Submitted';
        pfc2.Description = 'Test PFC';
        pfc2.Amount=100;
        pfc2.Core_MDF_Type_Txt__c='Claim';
        pfc2.Core_MDF_Ad_Run_Start_Date__c = System.today();
        pfc2.Core_MDF_Ad_Run_End_Date__c = System.today();
        pfc2.Core_MDF_Invoice_Date__c = System.today();
        pfc2.Core_MDF_Invoice_Number__c = '1121';
        pfc2.Core_MDF_Media_Vehicle__c = 'test';
        pfc2.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        pfc2.Core_MDF_Taxes_Local__c = 0;
        pfc2.Core_MDF_Currency__c = 'USD';
        pfc2.Core_MDF_Exchange_rate__c = 1;
        pfc2.Core_MDF_Bank__c = bank.Id;
        pfc2.Core_MDF_Country_Location_nm__c = 'INDIA';
        insert pfc2;
        
        Core_MDF_Partnership_Score__c ptgm=new Core_MDF_Partnership_Score__c();
        ptgm.Core_MDF_Account_Id__c=acc1.id;
        ptgm.Core_MDF_Channel_Program_Id__c =cp.Id;
        ptgm.Core_MDF_Quarter_nm__c='Q2';
        ptgm.Core_MDF_Quarter_Year_Nm__c='Q2 2022';
        ptgm.Core_MDF_Year_nm__c='2022';
        //ptgm.Core_MDF_Partnership_Score_Nbr__c=2;
        ptgm.Core_MDF_Program_nm__c='Client CoMarketing Fund';
        //ptgm.Core_MDF_Partnership_Grade_Nbr__c=1;
        insert ptgm;
        system.debug('test::'+ptgm);
        
       
           
           
        /*list<Core_MDF_Partnership_Score__c> pscList = new list<Core_MDF_Partnership_Score__c>();
        Core_MDF_Partnership_Score__c PSC1=new Core_MDF_Partnership_Score__c();
        PSC1.Core_MDF_Account_Id__c=acc1.id;
        PSC1.Core_MDF_Channel_Program_Id__c =cp.Id;
        PSC1.Core_MDF_Program_nm__c ='Retail Marketing Funds';
        PSC1.Core_MDF_Quarter_Year_Nm__c = 'Q1 2022';
        PSC1.Core_MDF_Quarter_nm__c='Q1';
        PSC1.Core_MDF_Year_nm__c='2022';
        PSC1.Core_MDF_Partnership_Score_Nbr__c=0.0;*/
        
        List<Core_MDF_Recovery__c> claimRecoveryList=new List<Core_MDF_Recovery__c>();
        
        Core_MDF_Recovery__c cr1=new Core_MDF_Recovery__c();
        cr1.Core_MDF_Claim_Id__c=pfc.Id;
        cr1.Core_MDF_Amount_Amt__c=90;
        cr1.Core_MDF_PartnershipGradeMaintenance_Nbr__c=ptgm.Id;
        claimRecoveryList.add(cr1);
        
        Core_MDF_Recovery__c cr2=new Core_MDF_Recovery__c();
        cr2.Core_MDF_Claim_Id__c=pfc.Id;
        cr2.Core_MDF_Amount_Amt__c=10;
        cr2.Core_MDF_PartnershipGradeMaintenance_Nbr__c=ptgm.Id;
        claimRecoveryList.add(cr2);
       
        Database.insert(claimRecoveryList);
        system.debug('claimrecovery List1'+claimRecoveryList);
        Test.stopTest();
        }
    }
    @isTest Static Void updateclmAmountOnClmRecovery(){
        list<Core_MDF_Recovery__c> clmRecoveryList = new list<Core_MDF_Recovery__c>();
        list<Core_MDF_Recovery__c> clmRecoveryList1 = new list<Core_MDF_Recovery__c>();
       String statusError=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Recovery_Status_Error');
         test.startTest();
        Account acc1=[select id, name from account where name=:'Test Account 1'];
        //Core_MDF_Partnership_Score__c ptgm=[select id,Core_MDF_Program_nm__c from Core_MDF_Partnership_Score__c where Core_MDF_Program_nm__c='Client CoMarketing Fund'];
        Core_MDF_Partnership_Score__c ptgm=[select id,Core_MDF_Program_nm__c from Core_MDF_Partnership_Score__c where Core_MDF_Account_Id__c=:acc1.id];

        Core_MDF_Recovery__c cr=[select Core_MDF_Claim_Id__c,Core_MDF_Amount_Amt__c,Core_MDF_PartnershipGradeMaintenance_Nbr__c from Core_MDF_Recovery__c where Core_MDF_PartnershipGradeMaintenance_Nbr__c=:ptgm.Id LIMIT 1];
        
        clmRecoveryList.add(cr);
        Core_MDF_ClaimRecovery_ServiceHandler.updateClmAmtOnClaimRecoveryIns(clmRecoveryList);
       
        PartnerFundClaim pfcs=[Select id from PartnerFundClaim where Title='Test Claim1' Limit 1];
        Core_MDF_Recovery__c cr2=new Core_MDF_Recovery__c();
        cr2.Core_MDF_Claim_Id__c=pfcs.Id;
        cr2.Core_MDF_Amount_Amt__c=10;
        cr2.Core_MDF_PartnershipGradeMaintenance_Nbr__c=ptgm.Id;
        try{
            insert cr2;
             test.stopTest();
        }catch(exception e){
             Boolean expectedExceptionThrown =  e.getMessage().contains(statusError) ? true : false;
                System.Debug('errormsg-> '+expectedExceptionThrown);
                System.assertEquals(expectedExceptionThrown, true);
        }
        /*clmRecoveryList1.add(cr2);
        system.assertEquals(Core_MDF_ClaimRecovery_ServiceHandler.validateClmAmtOrStatusOnClmRecoveryIns(clmRecoveryList1),statusError);*/
       
       
    }
}