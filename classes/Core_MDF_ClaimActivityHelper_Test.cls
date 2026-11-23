@isTest
public class Core_MDF_ClaimActivityHelper_Test {
    @TestSetup 
    static void setUpData(){
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        List<PartnerFundRequest> testPartnerFundRequestRecordList = new List<PartnerFundRequest>();
        List<Account> accountList = new List<Account>();
        List<Campaign> campaignList = new List<Campaign>();
        List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
        List<PartnerMarketingBudget> budgetList= new List<PartnerMarketingBudget>();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        // Highlight: Unused Local Variable 
      //  PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        List<User> userList= new List<User>();
        
        // Creating User with utility class
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.profileId = adminProfile.Id;
        usr.UserRoleId = usRole.Id;
        userList.add(usr);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName='Claim Case User';
        usr2.profile=ccpCoreProfile;
        userList.add(usr2);
        
        /*User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
usr1.Email='testexmpl2@intel.com';
usr1.profileId=ccpCoreProfile.Id;
usr1.UserPermissionsMarketingUser=true;
usr1.isActive=true;
userList.add(usr1);*/
        Database.insert(userList); 
       
        /*PermissionSet ccfPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
PermissionSet dcfPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_DCF_Payment_Adm' LIMIT 1];
PermissionSet claimCaseUser = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];*/
        
        Map<String,Id> psMap = new Map<String,Id>();
        for(PermissionSet ps : [SELECT Id, Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_Claim_Case_Reviewer','Core_MDF_CCP_Internal_CCF_Payment_Adm','Core_MDF_CCP_Internal_DCF_Payment_Adm','Core_MDF_CCP_External_Claim_Submitter','Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader')]){
            psMap.put(ps.Name, ps.Id);
        }
        
        List<PermissionSetAssignment> assignPermissionList = new List<PermissionSetAssignment>();    
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = usr.Id;
        assignPermissionSetObj.PermissionSetId = psMap.get('Core_MDF_CCP_Internal_CCF_Payment_Adm');
        assignPermissionList.add(assignPermissionSetObj);
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr.Id;
        assignPermissionSetObj1.PermissionSetId = psMap.get('Core_MDF_CCP_Internal_DCF_Payment_Adm');
        assignPermissionList.add(assignPermissionSetObj1);
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = usr2.Id;
        assignPermissionSetObj2.PermissionSetId = psMap.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer');
        assignPermissionList.add(assignPermissionSetObj2);
    
        PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();        
        assignPermissionSetObj3.AssigneeId = usr.Id;
        assignPermissionSetObj3.PermissionSetId = psMap.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer');
    
        
        System.runAs(usr){
            //Custom setting records needed for insertion of claim
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            Database.insert(assignPermissionList);
            
            // Creating channel program with utility class
            ChannelProgram cpCCF = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
            channelProgramList.add(cpCCF);
            //Creating DCF channel program 
            ChannelProgram cpDCF = Core_MDF_CCP_TestDataUtility.createProgram ('Datacenter','Data Center CoMarketing Fund', false);
            channelProgramList.add(cpDCF);
            ChannelProgram cpRMF = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false); 
            channelProgramList.add(cpRMF);
            //test code begins
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            channelProgramList.add(ipaCP);
            //test code ends
            database.insert(channelProgramList);
            
            List<Account> intelAccounts = new List<Account>();
            // Creating Intel Account with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Account_Type__c = 'Reseller';
            //acc1.Core_Sales_Groups__c = 'US Sales Group';
            acc1.Industry = 'Food & Beverage';
            //acc1.Core_MDF_Channel_Program__c = cpCCF.Id;
            acc1.Core_MDF_CoMarketingActive__c = true;
            intelAccounts.add(acc1); 
            
            //test case begins
            Account ipaUltimateAccountPFR = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account PFR',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ipaUltimateAccountPFR.Core_MDF_Channel_Program__c = ipaCP.Id;
            ipaUltimateAccountPFR.Core_Account_Type__c = 'Reseller';            
            ipaUltimateAccountPFR.Industry = 'Food & Beverage';
            intelAccounts.add(ipaUltimateAccountPFR);
            //test case ends
            
            // Creating Intel Account with utility class
            Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount('Dell Corporation',cpRMF.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            dellCorpAccount.BillingCity = 'Test City';         
            dellCorpAccount.BillingCountry= 'RUS';
            dellCorpAccount.BillingStreet= 'Test Street';
            dellCorpAccount.BillingState= 'MOS';
            dellCorpAccount.Core_Geo__c= 'EMEA';
            intelAccounts.add(dellCorpAccount);
            database.insert(intelAccounts);
            // Creating Co-marketing Account with utility class
            Account accCCF = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account CCF', cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accCCF.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accCCF.Core_MDF_CoMarketingActive__c = true;
            //insert accCCF;
            accountList.add(accCCF);
            
            //Creating DCF CO-marketing Account
            Account accDCF = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account DCF', cpDCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accDCF.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accDCF.Core_MDF_CoMarketingActive__c = true;
            //insert accDCF;
            accountList.add(accDCF);
            
            Account accOpal = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Opal', cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accOpal.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accOpal.Core_MDF_CoMarketingActive__c = true;
            accountList.add(accOpal);
            
            //Creating RMF Account with utility class
            Account dellRMFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell RMF Virtual Corp', cpRMF.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
            dellRMFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
            dellRMFVirtualCorp.Core_Geo__c = 'EMEA';
            accountList.add(dellRMFVirtualCorp);
            
            //test code begins
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createAccount('IPA Virtual PFR', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
            ipaCoMarketingAccount.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccountPFR.Id;
            ipaCoMarketingAccount.Core_Geo__c='';
        ipaCoMarketingAccount.Core_Sub_Geo__c='';
        
            accountList.add(ipaCoMarketingAccount);
            //test code ends
            database.insert(accountList);
            
            Account dellRMFAccount1 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Dell RMF Account 1', cpRMF.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, dellRMFVirtualCorp.Id, false);
            dellRMFAccount1.Core_Geo__c = 'EMEA';
            
            database.insert(dellRMFAccount1);
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false); 
            conRecord1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            insert conRecord1;
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            User usrClaimSub = Core_MDF_CCP_TestDataUtility.createUser(false);        
            usrClaimSub.Email='claimSub@example.com';
            usrClaimSub.ContactId = conRecord1.Id;
            usrClaimSub.ProfileId = partnerProfile.Id;
            // usrClaimSub.UserRoleId = usRole.Id;
            usrClaimSub.isActive = true; 
            insert usrClaimSub;
            
            PermissionSetAssignment assignPermissionSetObjClaimSub = new PermissionSetAssignment();
            assignPermissionSetObjClaimSub.AssigneeId = usrClaimSub.Id;
            assignPermissionSetObjClaimSub.PermissionSetId = psMap.get('Core_MDF_CCP_External_Claim_Submitter');
            database.insert(assignPermissionSetObjClaimSub);
            
            List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing','Bypass_MDF_Budget_Access','Bypass_MDF_Budget_Access_Validation','Bypass_MDF_Budget_Status_Validation','Bypass_ShareActivityWithUsers','Bypass_Activity_ApprovalProcess','Bypass_ShareActivityWithAccNodeGroup','ShareActivityWithInternalUsers_Bypass','Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing','ByPass_BlockLegacyBudgetCreation','Core_MDF_Bypass_BudgetApvrNotification'
                ,'Core_MDF_Bypass_ATFBatchUpdate','Bypass_geoLeadApprovalProcess'}, true, false));
            Database.insert(transactions);
            
            //Creating Budget using utility class
            PartnerMarketingBudget testBudgetCCF = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetDataCCF',Core_MDF_CCP_TestDataUtility.budget_Record_Type, 
                                                                                             string.valueof(accCCF.id), cpCCF.Id , 10000 , System.today() - 25 , 
                                                                                             System.today() + 30 , false);
           
            testBudgetCCF.IsIgnoreValidation = true;
            testBudgetCCF.Core_MDF_Budget_Type_Txt__c = 'MDF';
            budgetList.add(testBudgetCCF);
            
            /* PartnerMarketingBudget testBudgetCCF1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetDataCCF',Core_MDF_CCP_TestDataUtility.budget_Record_Type, 
string.valueof(dellRMFVirtualCorp.id), cpRMF.Id , 10000 , System.today() - 25 , 
System.today() + 30 , false);
testBudgetCCF1.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
testBudgetCCF1.IsIgnoreValidation = true;
testBudgetCCF1.Core_MDF_Budget_Status__c = 'Released';
budgetList.add(testBudgetCCF1);*/
            
            //Creating Budget using utility class
            PartnerMarketingBudget testBudgetDCF = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetDataDCF',Core_MDF_CCP_TestDataUtility.budget_Record_Type, 
                                                                                             string.valueof(accDCF.id), cpDCF.Id , 10000 , System.today() - 25 , 
                                                                                             System.today() + 120 , false);
            testBudgetDCF.Core_MDF_Budget_Type_Txt__c = 'MDF';
            testBudgetDCF.IsIgnoreValidation = true;
            budgetList.add(testBudgetDCF);                        
            
            //Creating RMF PMB using utility class
            PartnerMarketingBudget  pmbRecord1 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Dell RMF PMB',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,cpRMF.Id,1000000,
                                                                                                 System.today()-10,System.today()+10,false, 'RSA MD');
            pmbRecord1.IsIgnoreValidation = true;
            budgetList.add(pmbRecord1);
            PartnerMarketingBudget  pmbRecord2 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Dell RMF PMB-2',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,cpRMF.Id,1000000,
                                                                                                 System.today()-25,System.today()+30,false, 'RSA MD');
            pmbRecord2.IsIgnoreValidation = true;
            pmbRecord2.Core_MDF_Budget_Status__c = 'Released';
            // pmbRecord2.TotalAllocatedAmount = 10;
            budgetList.add(pmbRecord2);
            
            PartnerMarketingBudget opalbudgetMDF = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,accOpal.Id,cpCCF.Id,123456,System.today().addDays(1),System.today().addDays(150),false);
            opalbudgetMDF.IsIgnoreValidation = true;
            opalbudgetMDF.Core_MDF_Budget_Type_Txt__c='OEM CMP';
            budgetList.add(opalbudgetMDF);    
                    PartnerMarketingBudget budgetIPA = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_IPA_TestDataUtility.budgetIPA_ProposalBased_Record_Type,ipaCoMarketingAccount.Id,ipaCP.Id,200000,System.today().addDays(-20),System.today(), false);
        //budget.Core_MDF_Budget_Type__c='Data Centric Acceleration - MDF';
        budgetIPA.Core_MDF_Budget_Type_Txt__c='Data Centric Acceleration - MDF';
            budgetList.add(budgetIPA);
            database.insert(budgetList);  
            // Highlight: Unused Local Variable 
           // PartnerFundAllocation pfaIPA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',budgetIPA,ipaCoMarketingAccount, 100000,true);
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 'CMP Only',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund',System.today(), 
                                                                        System.today().addDays(20), 2000, 'Unite', accCCF.Id,'2-in-1', 
                                                                        false);
            //test code begins
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
            camp.Core_MDF_Technology__c = 'Intel vPro';
            //test code ends
            campaignList.add(camp);
            Test.startTest();
            // Creating campaigns using utility class
            Campaign campDcf = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampdcf','Reseller','Intel® Xeon® Platinum Processor', 'CMP Only',
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 
                                                                           'Data Center CoMarketing Fund',System.today() , 
                                                                           System.today().addDays(20), 2000, 'Advanced Analytics', 
                                                                           accDCF.Id,'Server', false);
            //test code begins
            campDcf.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
            campDcf.Core_MDF_Technology__c = 'SmartEdge';
            //test code ends
            campaignList.add(campDcf);     
            //Creating Retail Campaign using utility class
            Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','9ᵗʰ Gen','MDF or both CMP & MDF', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-10), System.today().addDays(10), 100000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
            retailCampaign.Core_MDF_Budget_Type_txt__c ='RSA MD';
            retailCampaign.Core_MDF_Opal_Budget_Type_Txt__c='RSA MD';
            retailCampaign.Core_MDF_Activity_Category_Type__c =null;
            retailCampaign.Core_MDF_Technology__c = 'ACPC';
            //retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
           // retailCampaign.Core_MDF_Technology__c = 'Intel vPro®';
            
            //test code begins
            Campaign opalCamp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampOpal','Consumer','Intel® Corporate Logo', 'CMP Only',
                                                                            Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today(), 
                                                                            System.today()+25, 2000000000, 'Unite', accCCF.Id,'2-in-1', false);
            
            opalCamp.Core_MDF_Opal_Budget_Type_Txt__c ='OEM CMP';
            opalCamp.Core_MDF_Technology__c = 'Intel vPro';
            campaignList.add(opalCamp);  
            string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
            budgetType = 'Data Centric Acceleration - MDF';
             Campaign campIPA = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',ipaCoMarketingAccount.Id, System.today(), System.today().addDays(300),budgetType,
                                                                           1234.00, 'AFGHANISTAN','Consumer','','Planned', false);
            campIPA.Core_MDF_Region_cd__c = 'APJ';
            campIPA.Core_MDF_Budget_Type_txt__c = budgetType;
            campIPA.Core_MDF_Budget__c = budgetIPA.Id;
            campIPA.Core_MDF_Reimbursement_Amt__c = 10000;
            //campIPA.Core_MDF_Technology__c = 'FPGA';
            campaignList.add(campIPA); 
            //test code ends
            
            campaignList.add(retailCampaign);
            database.insert(campaignList);
            
            
            //Create PFA using utility class
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            PartnerFundAllocation retailAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('retailAlloc',pmbRecord1,dellRMFVirtualCorp,20000.0,false);
            pfaList.add(retailAlloc);      
            PartnerFundAllocation dcfAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',testBudgetDCF,accDCF,10000.0,false);
          pfaList.add(dcfAlloc);
            PartnerFundAllocation testOpalAllocation = new PartnerFundAllocation(Title = 'Opal Allocation',
                                                                                 BudgetId = opalbudgetMDF.Id, 
                                                                                 ChannelPartnerId = accOpal.Id, 
                                                                                 Amount = 100000);            
            pfaList.add(testOpalAllocation);
            //PartnerFundAllocation pfaIPA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',budgetIPA,ipaCoMarketingAccount, 100000,false);
          //pfaList.add(pfaIPA);
            database.insert(pfaList);
            //Create retail bank using utility class
            List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
            Core_MDF_Bank__c retailBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            retailBank.Core_MDF_Intel_Company_Code__c = '650';
            retailBank.name = 'retailBank';
            retailBank.Core_MDF_Currency_cd__c = 'USD';
            retailBank.Core_MDF_Payment_Currency_Cd__c = 'USD';
            retailBank.Core_MDF_Tax_codes_cd__c = 'I0';
            retailBank.Core_MDF_Bank_Status__c = 'Active';   
            retailBank.Core_MDF_Supplier_Country_txt__c = 'US';  
            retailBank.Core_MDF_Supplier_City_txt__c = 'New York';  
            retailBank.Core_MDF_Supplier_Region_txt__c = 'New York';  
            retailBank.Core_MDF_Supplier_Postal_Code_cd__c = '728378';  
            //retailBank.Core_MDF_VAT_pct__c = '10';
            bankList.add(retailBank);
            //test code begins
            Core_MDF_Bank__c ipaBank = Core_MDF_CCP_TestDataUtility.createBank(ipaUltimateAccountPFR.Id, 'Core_MDF_Intel_Partner_Alliance', false,'1731241230');
            ipaBank.Core_MDF_Intel_Company_Code__c = '650';
            ipaBank.name = 'IPABank';
            ipaBank.Core_MDF_Currency_cd__c = 'USD';
            ipaBank.Core_MDF_Payment_Currency_Cd__c = 'USD';
            ipaBank.Core_MDF_Tax_codes_cd__c = 'I0';
            ipaBank.Core_MDF_Bank_Status__c = 'Active';   
            ipaBank.Core_MDF_Supplier_Country_txt__c = 'US';  
            ipaBank.Core_MDF_Supplier_City_txt__c = 'New York';  
            ipaBank.Core_MDF_Supplier_Region_txt__c = 'New York';  
            ipaBank.Core_MDF_Supplier_Postal_Code_cd__c = '728378';  
            bankList.add(ipaBank);
             Core_MDF_Bank__c dcfBank = Core_MDF_CCP_TestDataUtility.createBank(Acc1.Id, 'Core_MDF_Data_Center_CoMarketing_Fund', false,'1234567892');
             dcfBank.name = 'dcfBank';
            bankList.add(dcfBank);
            //test code ends
            Database.insert(bankList);
            //Create ABM record using utility class
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellRMFVirtualCorp.Id,retailBank.Id,false);
            insert abm1;
            Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accDCF.Id,dcfBank.Id,false);
            insert abm2;
            // Highlight: Unused Local Variable 
           // Core_MDF_Account_Bank_Mapping__c abm3 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(ipaCoMarketingAccount.Id,ipaBank.Id,true);
           
            // Creating Activity with budget using utility class
            /*   PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),
Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
string.valueof(accCCF.id),
NULL,NULL,'ALBANIA','Consumer',
'Desktop','Intel® Corporate Logo',
'Event','Channel Partner Owned Event',
'Draft',false,true,
'Others','Test Other cpCCF'); */
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                                                    Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                                    string.valueof(accCCF.id),
                                                                                                                    NULL,NULL,'ALBANIA','Consumer',
                                                                                                                    'Desktop','Intel® Corporate Logo',
                                                                                                                    'Event','Third Party Event',
                                                                                                                    'Draft',false);
            
            testPartnerFundRequestRecord.RequestedAmount=10;
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today();
            // testPartnerFundRequestRecord.AllocationId = testOpalAllocation.Id;
            //test code begins
            testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'MDF';
            //test code ends
            testPartnerFundRequestRecordList.add(testPartnerFundRequestRecord);
            
            //Test.startTest();
            //DCF pfr with Budget
            /*   PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(campDcf.Id),
Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
string.valueof(accDCF.id),
NULL,NULL,'ALBANIA','Reseller',
'Server','Intel® Xeon® Platinum Processor',
'Event','Channel Partner Owned Event',
'Draft',false,true,
'Others','Test Other cpDCF'); */
            PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(campDcf.Id),
                                                                                                                     Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
                                                                                                                     string.valueof(accDCF.id),
                                                                                                                     dcfAlloc,NULL,'ALBANIA','Reseller',
                                                                                                                     'Server','Intel® Xeon® Platinum Processor',
                                                                                                                     'Event','Third Party Event',
                                                                                                                     'Draft',false);
            
            testPartnerFundRequestRecord1.Title = 'dcfLegacyActivity';
            testPartnerFundRequestRecord1.RequestedAmount=10000;
            testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = 'Planned';
            //testPartnerFundRequestRecord1.status = 'Draft';
            testPartnerFundRequestRecord1.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequestRecord1.Core_MDF_End_Date__c = system.today();
            //test code begins
            testPartnerFundRequestRecord1.Core_MDF_Budget_Type_nm__c = 'MDF';
            testPartnerFundRequestRecord1.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            //test code ends
            testPartnerFundRequestRecordList.add(testPartnerFundRequestRecord1);
            
            //Create retail partnerFundRequest
            PartnerFundRequest indiaActivity4 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(retailCampaign.Id),string.valueof(dellRMFVirtualCorp.id),
                                                                                                  System.today()-2,System.today()+2,false);
            indiaActivity4.Title = 'indiaActivity4';
            indiaActivity4.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            indiaActivity4.Core_MDF_Country_nm__c = 'INDIA';
            indiaActivity4.Core_MDF_Reimbursement_Rate_pct__c = '100%'; 
            indiaActivity4.Core_MDF_Reimbursement_Rate_txt__c  = '100%';
            indiaActivity4.RequestedAmount =1000;
            indiaActivity4.Amount=1000;
            indiaActivity4.Core_MDF_Product_Category_txt__c ='Desktop';
            indiaActivity4.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            indiaActivity4.AllocationId = retailAlloc.Id;
            testPartnerFundRequestRecordList.add(indiaActivity4);
            
            PartnerFundRequest indiaActivity5 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(retailCampaign.Id),string.valueof(dellRMFAccount1.id),
                                                                                                  System.today()-2,System.today()+2,false);
            indiaActivity5.Title = 'indiaActivity5';
            indiaActivity5.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            indiaActivity5.Core_MDF_Country_nm__c = 'INDIA';
            indiaActivity5.Core_MDF_Reimbursement_Rate_pct__c = '100%'; 
            indiaActivity5.Core_MDF_Reimbursement_Rate_txt__c  = '100%';
            indiaActivity5.RequestedAmount =1000;
            indiaActivity5.Amount=1000;
            indiaActivity5.Core_MDF_Product_Category_txt__c ='Desktop';
            indiaActivity5.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            indiaActivity5.Status = 'Approved';
            indiaActivity5.AllocationId=retailAlloc.id;
            testPartnerFundRequestRecordList.add(indiaActivity5);
            
            
            
            /*    PartnerFundRequest opalPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(opalCamp.Id),
Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
string.valueof(accOpal.id),
NULL,NULL,'ALBANIA','Consumer',
'Desktop','Intel® Corporate Logo',
'Event','Channel Partner Owned Event',
'Draft',false,true,
'Others','Test Other cpCCF'); */
            PartnerFundRequest opalPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(opalCamp.Id),
                                                                                                                    Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                                    string.valueof(accOpal.id),
                                                                                                                    NULL,NULL,'ALBANIA','Consumer',
                                                                                                                    'Desktop','Intel® Corporate Logo',
                                                                                                                    'Event','Third Party Event',
                                                                                                                    'Draft',false);
            
            opalPartnerFundRequestRecord.RequestedAmount=100;
            opalPartnerFundRequestRecord.Amount = 100;
            opalPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Planned';
            opalPartnerFundRequestRecord.Status = 'Draft';  
            opalPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today();
            opalPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today()+25;           
            opalPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            //opalPartnerFundRequestRecord.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            opalPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_pct__c = '100%'; 
            opalPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c  = '100%';
            opalPartnerFundRequestRecord.AllocationId = testOpalAllocation.Id;
            testPartnerFundRequestRecordList.add(opalPartnerFundRequestRecord);
            PartnerFundRequest pfrIPA = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(campIPA.Id,ipaCoMarketingAccount.Id,System.today(),System.today().addDays(20),false);
        pfrIPA.Core_MDF_BU_Split__c ='CCG';
        pfrIPA.Core_MDF_BU1_Split_Percent_nbr__c=100;
        pfrIPA.amount = 500;
        pfrIPA.Core_MDF_Reimbursement_Rate_txt__c='60%';
        //pfr.Core_MDF_Budget_Type_nm__c = 'SOEM Client MDF';
        //pfrIPA.Core_MDF_Budget_Type_txt__c = 'SOEM Client MDF';
        testPartnerFundRequestRecordList.add(pfrIPA);
            
            database.insert(testPartnerFundRequestRecordList);
            
            List<PartnerMarketingBudget> updateBudgets = new List<PartnerMarketingBudget>();
            testBudgetCCF.Core_MDF_Budget_Status__c = 'Released';
            updateBudgets.add(testBudgetCCF);
            
            testBudgetDCF.Core_MDF_Budget_Status__c = 'Released';
            //updateBudgets.add(testBudgetDCF);
            Database.update(updateBudgets);
            campIPA.Status = 'Proposal Accepted';
        Database.update(campIPA);
        pfrIPA.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfrIPA.Core_MDF_Reimbursement_Rate_pct__c ='100%';
        pfrIPA.AllocationId = testOpalAllocation.Id;
        Database.update(pfrIPA);
            
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testProcessCCFActivities(){  
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.starttest();
            // Highlight: Unused Local Variable
           // Campaign camp = [SELECT ID FROM CAMPAIGN WHERE Name='TestCamp' LIMIT 1];
            Account acc1 = [SELECT Id,Name FROM Account WHERE Name='Test Account 1' LIMIT 1];
            Account accCCF = [SELECT Id, Name
                              FROM Account
                              WHERE Name = 'Co-marketing Test Account CCF'];
            PartnerMarketingBudget pmb = [SELECT Id
                                          FROM PartnerMarketingBudget
                                          WHERE Title = 'TestBudgetDataCCF'
                                          LIMIT 1];
            PartnerFundAllocation testPartnerFundAllocation = new PartnerFundAllocation(Title = 'CCF Allocation',
                                                                                        BudgetId = pmb.Id, 
                                                                                        ChannelPartnerId = accCCF.Id, 
                                                                                        Amount = 10);
            
            // Highlight: Unused Local Variable 
           // String ccfPfrID =  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF;  
            //PartnerFundRequest indiaActivity = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,RecordTypeId,BudgetId,Status,Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE RecordTypeId=:ccfPfrID and Core_MDF_Fund_Request_Status__c = 'Planned'  LIMIT 1];
            PartnerFundRequest indiaActivity = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,RecordTypeId,BudgetId,Status,Core_MDF_Fund_Request_Status__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c FROM PartnerFundRequest WHERE Core_MDF_Budget_Type_nm__c='OEM CMP'  LIMIT 1];
            //PartnerFundRequest indiaActivity = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,RecordTypeId,BudgetId,Status,Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE Title=''  LIMIT 1];
            Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            
            
            //creating ABM for bank1
            // Highlight: Unused Local Variable 
           // Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accCCF.Id,indiaBank.Id,true);
            
            
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   100, 
                                                                                   System.today(), indiaBank.ID, false);
            indiaClaim.Core_MDF_Currency__c = 'USD';
            indiaClaim.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            insert indiaClaim;
            Test.stoptest();
            // Unit Test Method should include System.Assert 
            System.assertEquals('USD', indiaClaim.Core_MDF_Currency__c, 'Claim currency should be USD');
        }  
    }
    
    /*@isTest
    static void testNoBudgetActivities() {
        User sysAdminUser = [SELECT Id, Email from User where Email = 'sysadmin@example.com' limit 1];
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change', 'Bypass_UpdateActivityFields'}, true, true);
        ////PartnerFundRequest retailActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Fund_Request_Status__c, Status  from PartnerFundRequest where Title='indiaActivity5' limit 1];
        PartnerFundRequest dcfLegacyActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Fund_Request_Status__c, Status  from PartnerFundRequest where Title='dcfLegacyActivity' limit 1];
        Core_MDF_Bank__c dcfBank = [Select ID from Core_MDF_Bank__c where name = 'dcfBank' limit 1];
        System.runAs(sysAdminUser) {
            PermissionSet claimCaseReviewerPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = claimCaseReviewerPermissionSet.Id, AssigneeId = sysAdminUser.Id);
            insert psa;
            PartnerFundClaim dcfLegacyClaim = Core_MDF_CCP_TestDataUtility.createClaim('dcfLegacyClaim', Core_MDF_CCP_TestDataUtility.claim_RecordType_DCF, dcfLegacyActivity.Id, System.today(), System.today(), 50.00,System.today(),dcfBank.Id, false);
            dcfLegacyClaim.Title = 'dcfLegacyClaim';
            //dcfLegacyClaim.Core_MDF_Budget_Type_Options_Nm__c = 'DCF 1.0';
            dcfLegacyClaim.Core_MDF_Type_Txt__c ='Claim';
            dcfLegacyClaim.Core_MDF_Currency__c='USD';
            dcfLegacyClaim.Core_MDF_Country_Location_nm__c= 'ALBANIA'; 
            dcfLegacyClaim.Core_MDF_Quarter_Year_Txt__c = 'Q1-2021';
            dcfLegacyClaim.Core_MDF_Region_cd__c='EMEA';  
            insert dcfLegacyClaim;
            Test.starttest();
            dcfLegacyActivity.Status = 'Approved';
            database.update(dcfLegacyActivity);
            
            PartnerFundClaim dcfLegacyClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('dcfLegacyClaim', Core_MDF_CCP_TestDataUtility.claim_RecordType_DCF, dcfLegacyActivity.Id, System.today(), System.today(), 40.00,System.today(),dcfBank.Id, false);
            dcfLegacyClaim2.Title = 'dcfLegacyClaim2';
            dcfLegacyClaim2.Core_MDF_Type_Txt__c ='Claim';
            dcfLegacyClaim2.Core_MDF_Currency__c='USD';
            dcfLegacyClaim2.Core_MDF_Country_Location_nm__c= 'ALBANIA'; 
            dcfLegacyClaim2.Core_MDF_Quarter_Year_Txt__c = 'Q1-2021';
            dcfLegacyClaim2.Core_MDF_Region_cd__c='EMEA';
            try{
                insert dcfLegacyClaim2;
            }
            catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);throw e;}
        }
        Test.stopTest();
    }*/
    
    
    @isTest
    static void testOpalActivities(){ 
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Test.starttest();
            // Highlight: Unused Local Variable 
          //  Campaign camp = [SELECT ID FROM CAMPAIGN WHERE Name='TestCamp' LIMIT 1];
            Account acc1 = [SELECT Id,Name FROM Account WHERE Name='Test Account 1' LIMIT 1];
            Account accOpal = [SELECT Id, Name
                               FROM Account
                               WHERE Name = 'Co-marketing Test Account Opal'];
            
            PartnerMarketingBudget pmb = [SELECT Id
                                          FROM PartnerMarketingBudget
                                          WHERE Title = 'TestOpalPMB'
                                          LIMIT 1];
            PartnerFundAllocation testPartnerFundAllocation = new PartnerFundAllocation(Title = 'Opal Allocation',
                                                                                        BudgetId = pmb.Id, 
                                                                                        ChannelPartnerId = accOpal.Id, 
                                                                                        Amount = 10);
            
            // Highlight: Unused Local Variable 
          //  String ccfPfrID = Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF;  
            PartnerFundRequest indiaActivity = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,RecordTypeId,BudgetId,Status,Core_MDF_Fund_Request_Status__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c FROM PartnerFundRequest WHERE Core_MDF_Budget_Type_nm__c='OEM CMP'  LIMIT 1];
            Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            
            
            //creating ABM for bank1
           // Highlight: Unused Local Variable
          //  Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accOpal.Id,indiaBank.Id,true);
            
            
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   100, 
                                                                                   System.today(), indiaBank.ID, false);
            indiaClaim.Core_MDF_Currency__c = 'USD';
            //indiaClaim.Core_MDF_Reimbursable_TransactionAmt_Loc__c = 5;
            indiaClaim.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            insert indiaClaim;
            Test.stoptest();
            // Unit Test Method should include System.Assert
           System.assertNotEquals(null, accOpal.Id, 'Opal Account should exist');  
        }
    }
    
    @isTest static void testOwnerChange(){
        Test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            PartnerFundClaim pfc1 = new PartnerFundClaim();
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution3.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'Before Insert';
            claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution3.Name = 'Core_MDF_UpdateOwner_To_ClaimSubmitter';
            claimFunctionalityNameTriggerExecution3.Core_Description__c = 'The switch for the owner update method on PFC Service Handler';
            database.insert(claimFunctionalityNameTriggerExecution3);
            
            //User usr = [select id from user where LastName='Claim Case User'];
            User usrClaimSub = [select id from user where email='claimSub@example.com'];
           // Highlight: Unused Local Variable 
          //  Campaign camp = [SELECT ID FROM CAMPAIGN WHERE Name='TestCamp' LIMIT 1];
            //Creating PFA using testData Utility
            PartnerMarketingBudget pmb = [SELECT Id
                                          FROM PartnerMarketingBudget
                                          WHERE Title = 'TestBudgetDataCCF'
                                          LIMIT 1];
            //pmb.IsIgnoreValidation = true;
            //pmb.Core_MDF_Budget_Status__c = 'Released';
            //update pmb;
            Account acc1 = [SELECT Id,Name FROM Account WHERE Name='Test Account 1' LIMIT 1];
            Account accCCF = [SELECT Id, Name
                              FROM Account
                              WHERE Name = 'Co-marketing Test Account CCF'];
            PartnerFundAllocation testPartnerFundAllocation = new PartnerFundAllocation(Title = 'CCF Allocation',
                                                                                        BudgetId = pmb.Id, 
                                                                                        ChannelPartnerId = accCCF.Id, 
                                                                                        Amount = 10);
            
            
            //insert testPartnerFundAllocation;
            // Highlight: Unused Local Variable 
           // String ccfPfrID = Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF;  
            //PartnerFundRequest indiaActivity = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,RecordTypeId,BudgetId,Status,Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE RecordTypeId=:ccfPfrID and Core_MDF_Fund_Request_Status__c = 'Planned'  LIMIT 1];
            PartnerFundRequest indiaActivity = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,RecordTypeId,BudgetId,Status,Core_MDF_Fund_Request_Status__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c FROM PartnerFundRequest WHERE Core_MDF_Budget_Type_nm__c='OEM CMP'  LIMIT 1];
            Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            
            
            //creating ABM for bank1
          // Highlight: Unused Local Variable 
          //  Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accCCF.Id,indiaBank.Id,true);
            // Highlight: Unused Local Variable 
          //  Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
          
            /*    Core_MDF_Escalation__c esc = new Core_MDF_Escalation__c();
esc.Core_MDF_Escalation_Status_nm__c='Approved';
esc.Core_MDF_Escalation_Name_txt__c='Test1';
esc.Core_MDF_Total_Dollar_Impact_amt__c= 5;
esc.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
esc.Core_MDF_Co_Marketing_Activity_id__c = indiaActivity.Id;
esc.Core_MDF_Claim_Submitter_Id__c = usrClaimSub.id;
esc.recordtypeid= claimRecType;
Database.insert(esc); */
            
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   100, 
                                                                                   System.today(), indiaBank.ID, false);
            indiaClaim.Core_MDF_Currency__c = 'USD';
            indiaClaim.Core_MDF_Country_Location_nm__c = 'INDIA';
            indiaClaim.Core_MDF_Claim_Submitter_Id__c = usrClaimSub.id;
            indiaClaim.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            claimList.add(indiaClaim);
            
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim2.Core_MDF_Currency__c = 'USD';
            indiaClaim2.Core_MDF_Country_Location_nm__c = 'INDIA';
            //indiaClaim2.Core_MDF_Escalation_Id__c = esc.Id;
            //indiaClaim2.Core_MDF_Claim_Submitter_Id__c = usrClaimSub.id;
            indiaClaim2.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            claimList.add(indiaClaim2);
            Database.insert(claimList);
            pfc1 = [select id,OwnerId,Core_MDF_Claim_Submitter_Id__c from partnerfundclaim where id=:indiaClaim.id];
            system.assertEquals(usrClaimSub.id,pfc1.Core_MDF_Claim_Submitter_Id__c);
            Test.stopTest();
        }
    } 
    
    @isTest
    static void testClaimsForBankDocHold(){
        Test.starttest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PartnerFundRequest retailActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity4' limit 1];
        // Highlight: Unused Local Variable
       // List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        System.runAs(sysAdminUser){
            
            PartnerFundClaim rmfMdfClaim = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim( Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, retailActivity.Core_MDF_Start_Date__c, retailActivity.Core_MDF_Start_Date__c, 50.00, false);
            rmfMdfClaim.Title = 'RMF MDF Claim';
            rmfMdfClaim.Core_MDF_Type_Txt__c ='Claim';
            rmfMdfClaim.Core_MDF_Currency__c='USD';
            rmfMdfClaim.Core_MDF_Country_Location_nm__c= 'RUSSIAN FEDERATION'; 
            rmfMdfClaim.Core_MDF_Quarter_Year_Txt__c = 'Q1-2021';
            rmfMdfClaim.Core_MDF_Region_cd__c='EMEA';
            rmfMdfClaim.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            //rmfMdfClaim.Core_MDF_Bank__c = '';
            
            try{
                // Database.insert(claimListToBeProcessed);
                insert rmfMdfClaim;}
            catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);throw e;} 
            
            rmfMdfClaim.Core_MDF_Total_Invoice_Amount_Local__c=60;
            Update rmfMdfClaim;
            List<PartnerFundClaim> pfcLst =[Select id,title,Core_MDF_Region_cd__c,Core_MDF_Program__c,Core_MDF_Status__c from PartnerFundClaim];
            
            Core_MDF_ClaimReminderNotification.updatePaymentAdminReminderDateAsync(pfcLst);
            //System.assertEquals('Hold',claimListToBeProcessed[1].Core_MDF_Status__c);
            System.assertEquals('Submitted',rmfMdfClaim.Core_MDF_Status__c);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testMultipleClaimsActivities() 
    {
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        System.runAs(sysAdminUser){
            Campaign campDcf = [SELECT ID FROM CAMPAIGN WHERE Name='TestCampdcf' LIMIT 1];
            //Creating PFA using testData Utility
            Set<Id> campSet = new Set<Id>();
            campSet.add(campDcf.Id);
            
            PartnerMarketingBudget pmb = [SELECT Id,Core_MDF_Budget_Type_Txt__c
                                          FROM PartnerMarketingBudget
                                          WHERE Title = 'TestBudgetDataDCF'
                                          LIMIT 1];
            Account acc1 = [SELECT Id,Name FROM Account WHERE Name='Test Account 1' LIMIT 1];
            Account accDCF = [SELECT Id, Name
                              FROM Account
                              WHERE Name = 'Co-marketing Test Account DCF'];
            // Highlight: Unused Local Variable 
           // String dcfPfrID = Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF;
            
            Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Data_Center_CoMarketing_Fund', true,'1231231230');
            
            //creating ABM for bank1
            // Highlight: Unused Local Variable 
          //  Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accDCF.Id,indiaBank.Id,true);
            
            Test.startTest();
            
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            List<PartnerFundRequest> requestList= new List<PartnerFundRequest>();
            Set<Id> pfrSet = new Set<Id>();
            PartnerFundAllocation pfa = [Select Id, ChannelPartnerId, Amount from PartnerFundAllocation where BudgetId = :pmb.Id];
            PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(campDcf.Id),
                                                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
                                                                                                                           string.valueof(accDCF.id),
                                                                                                                           NULL,NULL,'ALBANIA','Reseller',
                                                                                                                           'Server','Intel® Xeon® Platinum Processor',
                                                                                                                           'Event','Third Party Event',
                                                                                                                           'Draft',false,true,
                                                                                                                           'Others','Test Other cpDCF');
            testPartnerFundRequestRecord1.RequestedAmount=10000;
            testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestRecord1.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequestRecord1.Core_MDF_End_Date__c = system.today(); 
            testPartnerFundRequestRecord1.Core_MDF_Budget_Type_nm__c = 'MDF';
            testPartnerFundRequestRecord1.Title = 'Test PFR 1';
            requestList.add(testPartnerFundRequestRecord1);
            pfrSet.add(testPartnerFundRequestRecord1.Id);
            //database.insert(testPartnerFundRequestRecord1);
            PartnerFundRequest testPartnerFundRequestRecord3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(campDcf.Id),
                                                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
                                                                                                                           string.valueof(accDCF.id),
                                                                                                                           NULL,NULL,'ALBANIA','Reseller',
                                                                                                                           'Server','Intel® Xeon® Platinum Processor',
                                                                                                                           'Event','Third Party Event',
                                                                                                                           'Draft',false,true,
                                                                                                                           'Others','Test Other cpDCF');
            testPartnerFundRequestRecord3.RequestedAmount=10000;
            testPartnerFundRequestRecord3.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestRecord3.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequestRecord3.Core_MDF_End_Date__c = system.today();
            testPartnerFundRequestRecord3.Title = 'Test PFR 3';
            requestList.add(testPartnerFundRequestRecord3);
            PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(campDcf.Id),
                                                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
                                                                                                                           string.valueof(accDCF.id),
                                                                                                                           NULL,NULL,'ALBANIA','Reseller',
                                                                                                                           'Server','Intel® Xeon® Platinum Processor',
                                                                                                                           'Event','Third Party Event',
                                                                                                                           'Draft',false,true,
                                                                                                                           'Others','Test Other cpDCF');
            testPartnerFundRequestRecord2.RequestedAmount=10000;
            testPartnerFundRequestRecord2.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestRecord2.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequestRecord2.Core_MDF_End_Date__c = system.today();
            testPartnerFundRequestRecord2.Title = 'Test PFR 2';
            testPartnerFundRequestRecord2.status = 'Approved';
            testPartnerFundRequestRecord2.AllocationId = pfa.Id;
            requestList.add(testPartnerFundRequestRecord2);

            pfrSet.add(testPartnerFundRequestRecord2.Id);
            database.insert(requestList);
            
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    testPartnerFundRequestRecord1.Id, 
                                                                                    testPartnerFundRequestRecord1.Core_MDF_Start_Date__c, testPartnerFundRequestRecord1.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today().addDays(1), indiaBank.ID, false);
            indiaClaim2.Core_MDF_Currency__c = 'USD';
            PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim 3', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    testPartnerFundRequestRecord1.Id, 
                                                                                    testPartnerFundRequestRecord1.Core_MDF_Start_Date__c, testPartnerFundRequestRecord1.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today().addDays(1), indiaBank.ID, false);
            indiaClaim3.Core_MDF_Currency__c = 'USD';
            
            claimList.add(indiaClaim2);
            claimList.add(indiaClaim3);            
            
            
            PartnerFundClaim indiaClaim4 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim 4', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    testPartnerFundRequestRecord2.Id, 
                                                                                    testPartnerFundRequestRecord2.Core_MDF_Start_Date__c, testPartnerFundRequestRecord2.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim4.Core_MDF_Currency__c = 'USD';
            testPartnerFundRequestRecord3.Core_MDF_Fund_Request_Status__c = 'Closed';
            testPartnerFundRequestRecord3.status = 'Draft';
            update testPartnerFundRequestRecord3;
            PartnerFundClaim indiaClaim5 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim 5', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    testPartnerFundRequestRecord2.Id, 
                                                                                    testPartnerFundRequestRecord2.Core_MDF_Start_Date__c, testPartnerFundRequestRecord2.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim5.Core_MDF_Currency__c = 'USD';
            PartnerFundClaim indiaClaim6 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim 6', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    testPartnerFundRequestRecord3.Id, 
                                                                                    testPartnerFundRequestRecord3.Core_MDF_Start_Date__c, testPartnerFundRequestRecord3.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim6.Core_MDF_Currency__c = 'USD';
            claimList.add(indiaClaim4);
            claimList.add(indiaClaim5);
            claimList.add(indiaClaim6);
            database.insert(claimList, false);
            System.assert(true, claimList.size()!= null);
            Core_MDF_ClaimActivityHelper.checkPFRPMBBudgetType(pmb, testPartnerFundRequestRecord1);
            Core_MDF_ClaimActivityHelper.checkPFRPMBBudgetType(pmb, testPartnerFundRequestRecord2);
            List<PartnerFundRequest> pfrList = [Select Id, Status, Core_MDF_Fund_Request_Status__c, AllocationId, BudgetId, CampaignId, Core_MDF_Start_Date__c, Core_MDF_End_Date__c, RecordTypeId,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c, ChannelPartner.Core_MDF_Channel_Program__c, RecordType.DeveloperName, Core_MDF_Program__c, Core_MDF_Budget_Type_nm__c, ChannelPartnerId from PartnerFundRequest where Title in ('Test PFR 1','Test PFR 2')];
            Core_MDF_ClaimActivityHelper.checkIfBudgetExistsForActivity(claimList,pfrList);
            Core_MDF_ClaimActivityHelper.checkIfBudgetExistsForActivity(claimList,requestList);
            Core_MDF_ClaimActivityHelper.checkIfBudgetExistsForActivity(claimList,new List<PartnerFundRequest>());
            Core_MDF_ClaimActivityHelper.checkAllocationOnActivityAndUpdateActivityStatus(claimList);
             ChannelProgram Cp1 = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Retail Marketing Funds'];
             Id budgetRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();
             Core_MDF_Escalation__c escCCP = new Core_MDF_Escalation__c();
             escCCP.Core_MDF_Escalation_Status_nm__c='Pending Review';
             escCCP.Core_MDF_Escalation_Name_txt__c='Test Budget CCP';
             escCCP.Core_MDF_Total_Dollar_Impact_amt__c= 56;
             escCCP.Core_MDF_Root_Cause_nm__c = 'Appeal of Budget';
             escCCP.Core_MDF_Budget_ID_Number_id__c = pmb.Id;
             escCCP.Core_MDF_Channel_Program_id__c = Cp1.Id;
             escCCP.recordtypeid= budgetRecType;
             List<Core_MDF_Escalation__c> eslst = new List<Core_MDF_Escalation__c>();
             eslst.add(escCCP);
             Database.insert(eslst);
             List<PartnerFundClaim> claimList1 = new List<PartnerFundClaim>();
             claimList1.add(claimList[0]);
             claimList1[0].Core_MDF_Escalation_Id__c=eslst[0].id;
             Core_MDF_ClaimActivityHelper.updateClaimOwner(claimList1);
            Test.stopTest(); 
            
        }
    }
    
    
    /* @isTest
static void testProcessDCFActivities() 
{
Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];

System.runAs(sysAdminUser){
Campaign campDcf = [SELECT ID FROM CAMPAIGN WHERE Name='TestCampdcf' LIMIT 1];
//Creating PFA using testData Utility

PartnerMarketingBudget pmb = [SELECT Id
FROM PartnerMarketingBudget
WHERE Title = 'TestBudgetDataDCF'
LIMIT 1];
Account acc1 = [SELECT Id,Name FROM Account WHERE Name='Test Account 1' LIMIT 1];
Account accDCF = [SELECT Id, Name
FROM Account
WHERE Name = 'Co-marketing Test Account DCF'];

String dcfPfrID = Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF;

Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Data_Center_CoMarketing_Fund', true,'1231231230');

//creating ABM for bank1
Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accDCF.Id,indiaBank.Id,true);

Test.startTest();

List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();

PartnerFundRequest indiaActivity2 = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,RecordTypeId,BudgetId,Status,Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE RecordTypeId=:dcfPfrID and Core_MDF_Fund_Request_Status__c = 'Planned'  LIMIT 1];

PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_DCF, 
indiaActivity2.Id, 
indiaActivity2.Core_MDF_Start_Date__c, indiaActivity2.Core_MDF_Start_Date__c, 
100, 
System.today(), indiaBank.ID, false);
indiaClaim2.Core_MDF_Currency__c = 'USD';            
claimList.add(indiaClaim2);
database.insert(claimList);
delete indiaClaim2;

PartnerFundAllocation pfa = [Select id,budgetId from PartnerFundAllocation where budgetId =:pmb.Id];
System.assertNotEquals(pfa.Id,NULL);
//test code begins
//test code ends
delete indiaActivity2;
//test code begins
//delete pfa;
//delete pmb;
Database.delete(pfa);
Database.delete(pmb);
//test code ends

PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(campDcf.Id),
Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
string.valueof(accDCF.id),
NULL,NULL,'ALBANIA','Reseller',
'Server','Intel® Xeon® Platinum Processor',
'Event','Channel Partner Owned Event',
'Draft',false,true,
'Others','Test Other cpCCF');
testPartnerFundRequestRecord.RequestedAmount=10000;
testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Revision Required';
testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today();
testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today();

insert testPartnerFundRequestRecord;   
//test code begins
//test code ends
PartnerFundClaim indiaClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_DCF, 
testPartnerFundRequestRecord.Id, 
testPartnerFundRequestRecord.Core_MDF_Start_Date__c, testPartnerFundRequestRecord.Core_MDF_Start_Date__c, 
100, 
System.today(), indiaBank.ID, false);
indiaClaim1.Core_MDF_Currency__c = 'USD';
try{
insert indiaClaim1; 
}catch(Exception e){
String emsg = e.getMessage();
//System.assert(emsg.contains(System.Label.Core_MDF_No_Budget_Exist));
Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.Core_MDF_No_Budget_Exist) ? true : false;
System.assertEquals(expectedExceptionThrown, true);
} 
Test.stopTest();            
}
}*/
    
    /*    @isTest
static void testIPAClaimsActivities() 
{

User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
System.runAs(sysAdminUser){

Test.starttest();

Account ipaCoMarketingAccountIPA = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
from Account
where Name= 'IPA Virtual PFR'];

Account ipaUltimateAccountPFR = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c 
from Account
where Name= 'IPA Intel Account PFR'];

//string bType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccountIPA);

Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',
ipaCoMarketingAccountIPA.id, 
System.today().addDays(3), System.today().adddays(30),
'Data Center Specialties MDF', 110000,'INDIA', 'Consumer', 
'Apollo Lake', 'Planned', true); 

//Campaign camp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',acc2.Id, System.today(), System.today().addDays(300),budgetType, 10000.00, 'THAILAND','Consumer','Coffee Lake','Pending Review', false);

//ipaCampaign.Core_MDF_Budget_Type_txt__c = 'Data Center Specialties MDF';

//update ipaCampaign;

Core_MDF_Bank__c ipaBank = Core_MDF_CCP_TestDataUtility.createBank(ipaUltimateAccountPFR.Id, 'Core_MDF_Intel_Partner_Alliance', false,'1731241230');
ipaBank.Core_MDF_Intel_Company_Code__c = '650';
ipaBank.name = 'IPABank';
ipaBank.Core_MDF_Currency_cd__c = 'USD';
ipaBank.Core_MDF_Payment_Currency_Cd__c = 'USD';
ipaBank.Core_MDF_Tax_codes_cd__c = 'I0';
ipaBank.Core_MDF_Bank_Status__c = 'Active';   
ipaBank.Core_MDF_Supplier_Country_txt__c = 'US';  
ipaBank.Core_MDF_Supplier_City_txt__c = 'New York';  
ipaBank.Core_MDF_Supplier_Region_txt__c = 'New York';  
ipaBank.Core_MDF_Supplier_Postal_Code_cd__c = '728378';  

insert ipaBank;



PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,ipaCoMarketingAccountIPA.id,
System.today().addDays(4),
System.today().addDays(10),
false);  

ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';                                                                                       

insert ipaPFR;

// Core_MDF_Bank__c ipaBank = [select id from Core_MDF_Bank__c where Name = 'IPABank'];

Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(ipaCoMarketingAccountIPA.Id,ipaBank.Id,false);
insert abm;

Id claim_RecordType_IPA = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();

PartnerFundClaim indiaClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', claim_RecordType_IPA, 
ipaPFR.Id, 
ipaPFR.Core_MDF_Start_Date__c, ipaPFR.Core_MDF_Start_Date__c, 
100, 
System.today(), ipaBank.ID, false);
indiaClaim1.Core_MDF_Currency__c = 'USD';

insert indiaClaim1;

Test.stopTest();
}

}*/
    
    /*  @isTest
Public static void callPFRUpdateBatchTest(){

Test.startTest() ;

//ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fundtestd','Client CoMarketing Fundtestd', true);

ChannelProgram cp1 = [Select id from ChannelProgram where Name=: 'Client Co-Marketing Fund' limit 1 ] ;       
// Creating Account with utility class
// Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);

Account acc1 = [Select id,Name from Account where Name=: 'Test Account 1'];

Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);

Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);

PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 200000, System.today().addDays(-15),System.today().addDays(15), false);
//pbm.IsIgnoreValidation = true;
pbm.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
insert pbm;

pbm.IsIgnoreValidation = true;
update pbm;

PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
//PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test Budget 2' limit 1];

Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 'Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', false);
camp.Core_MDF_Opal_Budget_Type_Txt__c = 'CCF 1.0';
database.insert(camp);

PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,String.valueof(acc2.Id),pfa,pbm,'INDIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Podcast','Draft',false);
testPartnerFundRequestRecord.Title = 'indiaActivity';
testPartnerFundRequestRecord.Core_MDF_Activity_Description__c = 'indiaActivity';
testPartnerFundRequestRecord.Core_MDF_Start_Date__c = System.today().addDays(-3);
testPartnerFundRequestRecord.Core_MDF_End_Date__c = System.today().addDays(+5);
testPartnerFundRequestRecord.RequestedAmount = 10000;
testPartnerFundRequestRecord.Core_MDF_Channel_Partner_Led__c = True;
testPartnerFundRequestRecord.Amount=10000;
testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';

insert testPartnerFundRequestRecord;

// PartnerFundRequest pfr = new PartnerFundRequest();
Set<ID> pfrToBeUpdated = new Set<ID>();
List<PartnerFundRequest> lstPFR = [SELECT ID,Core_MDF_Fund_Request_Status__c from PartnerFundRequest limit 2 ];
for(PartnerFundRequest pfrr : lstPFR){        
pfrToBeUpdated.add(pfrr.ID);
}


Core_MDF_ClaimActivityHelper.callPFRUpdateBatch(pfrToBeUpdated);
Test.stopTest();

}*/
 @isTest static void validateIPAClaim() { 
     Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
         'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
         'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
         'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);

     User claimCaseUser = [SELECT Id,Email from User where LastName='Claim Case User' limit 1];
            System.runAs(claimCaseUser)
            {
                
                Campaign camp  = [Select Id, Name, StartDate, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Channel_Program__c,
                                  Core_MDF_Budget_Type_txt__c,Core_MDF_Total_Campaign_Cost_Amt__c
                                  from Campaign where Name = 'Test IPA Camp' limit 1];
                            
                //Test.startTest(); 
                PartnerFundRequest pfr = [Select id,Core_MDF_Fund_Request_Status__c, Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where CampaignId=:camp.Id];
                //pfr.status ='Approved';
                //database.update(pfr);
                List<Campaign> campToBeUpdated = new List<Campaign>();
                campToBeUpdated.add(camp);
                // Highlight: Unused Local Variable 
               // List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>();
                // Highlight: Unused Local Variable 
               // Id recordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId(); 
                
                
                
                PartnerMarketingBudget pmb = [Select id,Title, Description, Core_MDF_Budget_Status__c, StartDate, EndDate, Amount, Core_MDF_Budget_Type_Txt__c,
                                              Core_MDF_Budget_Partner__c,Core_MDF_Program__c, RecordTypeId, IsIgnoreValidation From PartnerMarketingBudget where Id = :camp.Core_MDF_Budget__c];
                // Highlight: Unused Local Variable 
              //  PartnerFundAllocation pfa = [Select Id, ChannelPartnerId, Amount from PartnerFundAllocation where BudgetId = :pmb.Id];
                
                Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
                
                               
                //PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('IPA Claim', Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, System.today(), System.today(),50.00, System.today(), bank1.Id, false);
                Test.startTest();
                PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c , pfr.Core_MDF_Start_Date__c,50.00, bank1.Id, false); 
                claim1.Core_MDF_Type_Txt__c ='Claim';
                claim1.Core_MDF_Currency__c='USD';
                claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim1.Core_MDF_Campaign_Id__c = camp.Id;
                claim1.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
                /*POP mandatory for IPA*/
                List<String> documentIdWithTitle = new List<String>();
                list<String> tempString = new list<String>();
                list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
                Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList, null, null, false, null, false, null, false);
                String str1 = claim1.Id+';#'+'Test Doc1';
                String str2 = claim1.Id+';#'+'Test Doc2';
                
                documentIdWithTitle.add(str1);
                documentIdWithTitle.add(str2);
                
                for(String str: documentIdWithTitle){
                    tempString = str.split(';#');
                    Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                    auditDoc.Core_MDF_Document_Id__c = tempString[0];
                    auditDoc.Core_MDF_Document_Title__c = tempString[1];
                    auditDoc.Core_MDF_Claim__c = claim1.Id;
                    auditDoc.Core_MDF_Proof_of_Branding__c = true;
                    auditDoc.Core_MDF_Proof_of_Cost__c = true;
                    auditDoc.Core_MDF_Proof_of_Execution__c = true;  
                    auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
                    auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
                    auditDocList.add(auditDoc);
                }            
                
                if(auditDocList.size()>0){
                    Database.insert(auditDocList);                
                }
                
                Core_MDF_PartnerFundClaim.ClaimWrap iPAClaimRes = new Core_MDF_PartnerFundClaim.ClaimWrap();
                iPAClaimRes = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList, null, null, false, null, false, null, false); 
                //String iPAClaimRes = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);
                
                //System.assertEquals(claim1.ID,iPAClaimRes.claimDetail.Id);
                pfr.status = 'Approved';
                Database.update(pfr);
                
                
                
                List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
                PartnerFundClaim claim2 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim2',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c , pfr.Core_MDF_Start_Date__c,50.00, bank1.Id, false); 
                claim2.Core_MDF_Type_Txt__c ='Claim';
                claim2.Core_MDF_Currency__c='USD';
                claim2.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim2.Core_MDF_Campaign_Id__c = camp.Id;
                claim2.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
                claimList.add(claim2);
                    
                PartnerFundClaim claim3 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim3',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c , pfr.Core_MDF_Start_Date__c,30.00, bank1.Id, false); 
                claim3.Core_MDF_Type_Txt__c ='Claim';
                claim3.Core_MDF_Currency__c='USD';
                claim3.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim3.Core_MDF_Campaign_Id__c = camp.Id;
                claim3.Core_MDF_Status__c = 'Cancelled';
                claim3.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
                /*claim3.Core_MDF_Invoice_Date__c = System.today().addDays(-4);
                claim3.Core_MDF_Invoice_Number__c = 'INV1686';
                claim3.Core_MDF_Media_Vehicle__c = 'Test';
                claim3.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
                claim3.Core_MDF_Taxes_Local__c = 1;*/
                claimList.add(claim3);
                database.insert(claimList);
                
                String recordId = claim3.Id;
               Core_MDF_PartnerFundClaim_Edit.fetchClaimById(recordId);
                
                Core_MDF_Proposal_Based_Campaign_Process.queryPFCRecords(campToBeUpdated);
                
                pfr.Core_MDF_Fund_Request_Status__c = 'Closed';
                pfr.status = 'Draft';
                update pfr;
                                
                Test.stopTest();
                
                
            }
    } 
    
    @isTest
    static void testCheckAllocationOnActivityAndUpdateActivityStatus() {
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
        
            Campaign camp = [SELECT Id, Core_MDF_Budget__c FROM Campaign WHERE Name = 'Test IPA Camp' LIMIT 1];
            PartnerFundRequest pfr = [SELECT Id, Core_MDF_Start_Date__c, Core_MDF_End_Date__c FROM PartnerFundRequest WHERE CampaignId = :camp.Id LIMIT 1];
            Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Bank_Alias_Name__c = 'Test' LIMIT 1];
            
            PartnerFundClaim claim1 = Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim', Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c, pfr.Core_MDF_Start_Date__c, 50.00, bank1.Id, false); 
            claim1.Core_MDF_Type_Txt__c = 'Claim';
            claim1.Core_MDF_Currency__c = 'USD';
            claim1.Core_MDF_Country_Location_nm__c = 'AFGHANISTAN'; 
            claim1.Core_MDF_Campaign_Id__c = camp.Id;
            claim1.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
            insert claim1;
            
            Campaign camp2 = [SELECT Id, Core_MDF_Budget__c FROM Campaign WHERE Name = 'Test IPA Camp' LIMIT 1];
            PartnerFundRequest pfr2 = [SELECT Id, Core_MDF_Start_Date__c, Core_MDF_End_Date__c FROM PartnerFundRequest WHERE CampaignId = :camp.Id LIMIT 1];
            Core_MDF_Bank__c bank2 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Bank_Alias_Name__c = 'Test' LIMIT 1];
            
            PartnerFundClaim claim2 = Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim', Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, pfr.Core_MDF_Start_Date__c, pfr.Core_MDF_Start_Date__c, 50.00, bank1.Id, false); 
            claim2.Core_MDF_Type_Txt__c = 'Claim';
            claim2.Core_MDF_Currency__c = 'USD';
            claim2.Core_MDF_Country_Location_nm__c = 'AFGHANISTAN'; 
            claim2.Core_MDF_Campaign_Id__c = camp2.Id;
            claim2.Core_MDF_Processing_Preference_nm__c='Get paid, then settle';
            insert claim2;
            
            Test.startTest();
            
            Map<Id, PartnerFundRequest> resultMap = Core_MDF_ClaimActivityHelper.checkAllocationOnActivityAndUpdateActivityStatus(new List<PartnerFundClaim>{ claim1 });
            Map<Id, PartnerFundRequest> resultMap2 = Core_MDF_ClaimActivityHelper.checkAllocationOnActivityAndUpdateActivityStatus(new List<PartnerFundClaim>{ claim2 });
            Test.stopTest();
            
        }
        
    }  
    
    @isTest
    static void testProcessActivityOnClaims() {
    
        Test.startTest();
    
        PartnerFundRequest pfrIPA = [SELECT Id, CampaignId FROM PartnerFundRequest WHERE Core_MDF_Program__c = 'Intel Partner Alliance' LIMIT 1];
        Core_MDF_Bank__c ipaBank = [SELECT Id FROM Core_MDF_Bank__c WHERE Name = 'IPABank' LIMIT 1];
    
        Campaign ipaCamp = [SELECT StartDate, EndDate FROM Campaign WHERE Id = :pfrIPA.CampaignId LIMIT 1];
        ipaCamp.Core_MDF_Proposal_Based_Ind__c = true;
        ipaCamp.Core_MDF_Program__c = 'Intel Partner Alliance';
        update ipaCamp;
    
        PartnerFundClaim ipaClaim = Core_MDF_CCP_TestDataUtility.createClaim('IPAProposalBased', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, pfrIPA.Id, ipaCamp.StartDate, ipaCamp.StartDate, 300, System.today(), ipaBank.Id, false);
        ipaClaim.Core_MDF_Campaign_Id__c = pfrIPA.CampaignId;
        ipaClaim.Core_MDF_PIC_Review_Completed__c = true;
        ipaClaim.Core_MDF_BackendReviewSelection_Ind__c = false;
        ipaClaim.Core_MDF_Document_Submission_Missed_Ind__c = false;
        ipaClaim.Amount = 300;
        ipaClaim.Core_MDF_Currency__c = 'USD';
        ipaClaim.Core_MDF_Audit_Hold__c = true;
        ipaClaim.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
    
        insert ipaClaim;
        
        PartnerFundClaim ipaClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('IPAProposalBased', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, pfrIPA.Id, ipaCamp.StartDate, ipaCamp.StartDate, 300, System.today(), ipaBank.Id, false);
        ipaClaim1.Core_MDF_Campaign_Id__c = pfrIPA.CampaignId;
        ipaClaim1.Core_MDF_PIC_Review_Completed__c = true;
        ipaClaim1.Core_MDF_BackendReviewSelection_Ind__c = false;
        ipaClaim1.Core_MDF_Document_Submission_Missed_Ind__c = false;
        ipaClaim1.Amount = 300;
        ipaClaim1.Core_MDF_Currency__c = 'USD';
        ipaClaim1.Core_MDF_Audit_Hold__c = true;
        ipaClaim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';        
        insert ipaClaim1;
    
        Core_MDF_ClaimActivityHelper.processActivityOnClaims(new List<PartnerFundClaim>{ipaClaim,ipaClaim1});               
        Test.stopTest();
    }
}