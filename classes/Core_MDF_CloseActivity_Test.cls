@isTest(SeeAllData=false)
    public class Core_MDF_CloseActivity_Test {
        
        @TestSetUp
        static void createTestData(){
            
            
             User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);        
             System.runAs(testUser){
            Test.startTest();
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Core_MDF_beforeInsertIUPGM');
            bypassFunctionKeys.add('Core_MDF_beforeUpdateIUPGM');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
            Account acc3 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account', cp.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            acc3.BillingCity = 'Test City';         
            acc3.BillingCountry= 'AUS';
            acc3.BillingStreet= 'Test Street';
            Database.insert(acc3);
            
            List<Account> accList = new List<Account>();
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 3', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc3.Id;
            accList.add(acc);
            Database.insert(accList);
            
            List<Campaign> campList = new List<Campaign>();
                 Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor','Yes',
                                                                            Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                            'Client CoMarketing Fund', System.today(), 
                                                                            System.today().addDays(346), 10000, 'Always Connected PC', 
                                                                            acc.Id,'Desktop', false); 
            campList.add(camp);
            database.insert(campList);

            PartnerMarketingBudget pbm = new PartnerMarketingBudget();
            User usertest = Core_MDF_CCP_TestDataUtility.createUser(false);
            usertest.LastName = 'testUser';
            usertest.IsActive = true;
            insert usertest;
            system.runAs(usertest)
            {
                PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
                
                
                insert new PermissionSetAssignment(AssigneeId = usertest.id, PermissionSetId = ps.Id);
            }
            System.runAs(usertest){
                pbm = Core_MDF_CCP_TestDataUtility.createBudget('TEST2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc.Id, cp.Id, 200000, System.today(),System.today(), false);
                // pbm.IsIgnoreValidation = true;
                pbm.Core_MDF_Budget_Type_Txt__c = 'MDF';
                insert pbm;
                
                
            }
            
            PartnerFundAllocation pfaDellCCFIndia = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFIndia',pbm, acc, 10000,true);
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc.Id,pfaDellCCFIndia,
                                                                                            pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                            'Member Participation in Third-Party Event','Draft',false);
            pfr1.RequestedAmount = 20;
            pfr1.Title='TESTMDFDraft';
            pfr1.Core_MDF_Priorities__c = 'Always Connected PC';
            pfr1.Core_MDF_Budget_Amount_Local_amt__c = 20;
            pfr1.Core_MDF_Budget_Currency_cd__c = 'USD';
            pfr1.Core_MDF_Channel_Partner_Led__c = false;
            pfr1.Core_MDF_Channel_Partner__c = '';
            pfr1.Amount =20; 
            pfr1.Core_MDF_Fund_Request_Status__c='Planned';
            pfr1.RecordTypeId=Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF;
            pfr1.Core_MDF_Budget_Type_nm__c='MDF';
            pfr1.Core_MDF_Reimbursement_Rate_pct__c ='50%';
            pfr1.Core_MDF_Reimbursement_Rate_txt__c ='50%';
            //pfr1.Core_MDF_Reimbursement_Rate__c ='50%';
            pfr1.Core_MDF_Start_Date__c =System.today();
            pfr1.Core_MDF_End_Date__c = System.today();
            pfrList.add(pfr1);
            
            PartnerFundRequest pfr3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc.Id,pfaDellCCFIndia,
                                                                                            pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                            'Member Participation in Third-Party Event','Draft',false);
            pfr3.RequestedAmount = 20;
            pfr3.Title='TESTAmountMDF';
            pfr3.Core_MDF_Priorities__c = 'Always Connected PC';
            pfr3.Core_MDF_Budget_Amount_Local_amt__c = 20;
            pfr3.Core_MDF_Budget_Currency_cd__c = 'USD';
            pfr3.Core_MDF_Channel_Partner_Led__c = false;
            pfr3.Core_MDF_Channel_Partner__c = '';
            pfr3.Amount =20; 
            pfr3.Core_MDF_Fund_Request_Status__c='Planned';
            pfr3.RecordTypeId=Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF;
            pfr3.Core_MDF_Budget_Type_nm__c='MDF';
            pfr3.Core_MDF_Reimbursement_Rate_pct__c ='50%';
            pfr3.Core_MDF_Reimbursement_Rate_txt__c ='50%';
            //pfr1.Core_MDF_Reimbursement_Rate__c ='50%';
            pfr3.Core_MDF_Start_Date__c =System.today();
            pfr3.Core_MDF_End_Date__c = System.today();
            pfrList.add(pfr3);
           Database.insert(pfrList);
            
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc3.Id, 'Core_MDF_Client_CoMarketing_Fund', FALSE,'1231231230');
            bank.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund';
            bank.Core_MDF_Bank_Status__c = 'Active'; 
            insert(bank);
            
            Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id, bank.Id, FALSE);
            abmCCF1.Core_MDF_Active_ind__c = true;
            insert(abmCCF1);
            
              List<Core_MDF_Configuration__c> configMDF = new List<Core_MDF_Configuration__c>();
            Core_MDF_Configuration__c configPS = new Core_MDF_Configuration__c();
            
            configPS.Core_MDF_Value__c = '1000';
            
            configPS.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
            
            configMDF.add(configPS);
            
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.NAME = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            config.Core_MDF_Value__c='3';
            config.Core_MDF_Category__c ='Bank Document Hold Logic';
            configMDF.add(config);
            insert configMDF;
            
                 
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet dcfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            PermissionSet priceReviewerPS = [SELECT Id FROM PermissionSet WHERE Name =: 'Core_MDF_CCP_Internal_Price_Reviewer' LIMIT 1];

                        
            List<User> userList = new List<User>();
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            User dcfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            dcfAccountManager.profileId = ccpCoreProfile.Id;
            dcfAccountManager.LastName = 'DCF Acc Manager';
            userList.add(dcfAccountManager);
            
            User ccfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager.profileId = ccpCoreProfile.Id;
            ccfAccountManager.LastName = 'CCF Acc Manager';
            userList.add(ccfAccountManager);

            User priceRev = Core_MDF_CCP_TestDataUtility.createUser(false);
            priceRev.profileId = ccpCoreProfile.Id;
            priceRev.LastName = 'Price Reviewer';
            userList.add(priceRev);
                     
  
            Database.insert(userList);
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = ccfAccountManager.Id);
            permissionSetAssignmentList.add(psa1);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = dcfAccManagerPS.Id, AssigneeId = dcfAccountManager.Id);
            permissionSetAssignmentList.add(psa2);
            
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = priceReviewerPS.Id, AssigneeId = priceRev.Id);
            permissionSetAssignmentList.add(psa3);
            
            Database.insert(permissionSetAssignmentList);
                
            Test.stopTest();
            
             } 
            
        }    
        @isTest 
        static void runCloseActivityTest(){
            boolean hasAccess = false;
            
            PermissionSet accountManager = [SELECT Id FROM permissionset where name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' limit 1];
            PermissionSet claimcaseReviewerManagerPS = [SELECT Id FROM permissionset WHERE name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1];
            //Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
            
            // Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            Database.insert(usr1);
            
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = accountManager.Id, AssigneeId = usr1.Id);
            Database.upsert(psa);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = claimcaseReviewerManagerPS.Id, AssigneeId = usr1.Id);
            Database.upsert(psa2);
            System.runAs(usr1){
                Test.startTest();
                // Call user eligibility method
                Map<string,List<string>> permissionsetsMap = new Map<string,List<string>>();
                string permissionSetName = Label.Core_MDF_Close_Activity_Allowed_Roles;
                List<String> permissionSets = new List<String>();
                
                permissionSets = permissionSetName.split(',');
                permissionsetsMap.put('closeactivity', permissionSets);            
                hasAccess = Core_MDF_CloseActivity.userEligibilitytoIncloseActivity(permissionsetsMap); 
                Core_MDF_CloseActivity.activityCloseWrapper wrapper = new Core_MDF_CloseActivity.activityCloseWrapper();
               PartnerFundRequest pfr1 = [select id,Core_MDF_Start_Date__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where title =: 'TESTMDFDraft' and recordtypeid =: Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_CCF];
               wrapper = Core_MDF_CloseActivity.checkActivityEligibiltyForClose(pfr1.id);
                PartnerFundClaim claim1 = new PartnerFundClaim();
                claim1.Title ='Test Claim1';
                claim1.RequestId = pfr1.Id;
                claim1.Core_MDF_Status__c ='Submitted';
                //claim1.Core_MDF_Bank__c =bank.Id;
                claim1.Core_MDF_Country_Location_nm__c='ARGENTINA';
                claim1.Core_MDF_Ad_Run_Start_Date__c =system.today();
                //claim1.Core_MDF_Ad_Run_End_Date__c = system.today()+1;
                claim1.Core_MDF_Ad_Run_End_Date__c = system.today();
                claim1.Core_MDF_Currency__c='USD';
                claim1.Core_MDF_Total_Invoice_Amount_Local__c =10;
                claim1.Core_MDF_Invoice_Number__c='123';
                claim1.Core_MDF_Invoice_Date__c = system.today();
                claim1.Core_MDF_Currency__c = 'USD';
                claim1.Core_MDF_Bank_Doc_Hold_Ind__c = false;
                claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
                claim1.RecordTypeId=Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF;
               insert claim1;
               wrapper = Core_MDF_CloseActivity.checkClaims(pfr1.id);
                
               
                Test.stopTest();
                        
                
            }
            
            System.assert(hasAccess == true);
        }
        
         @isTest 
        static void runCloseActivityTestCCF(){
            boolean hasAccess = false;
            
            PermissionSet accountManager = [SELECT Id FROM permissionset where name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' limit 1];
            PermissionSet claimcaseReviewerManagerPS = [SELECT Id FROM permissionset WHERE name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1];
            //Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
            
            // Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            Database.insert(usr1);
            
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = accountManager.Id, AssigneeId = usr1.Id);
            Database.upsert(psa);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = claimcaseReviewerManagerPS.Id, AssigneeId = usr1.Id);
            Database.upsert(psa2);
            System.runAs(usr1){
                Test.startTest();
                // Call user eligibility method
                Map<string,List<string>> permissionsetsMap = new Map<string,List<string>>();
                string permissionSetName = Label.Core_MDF_Close_Activity_Allowed_Roles;
                List<String> permissionSets = new List<String>();
                
                permissionSets = permissionSetName.split(',');
                permissionsetsMap.put('closeactivity', permissionSets);            
                hasAccess = Core_MDF_CloseActivity.userEligibilitytoIncloseActivity(permissionsetsMap); 
                Core_MDF_CloseActivity.activityCloseWrapper wrapper = new Core_MDF_CloseActivity.activityCloseWrapper();
                PartnerFundRequest pfr1 = [select id,Core_MDF_Start_Date__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c,Core_MDF_Reimbursement_Rate__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Activity_Reimbursement_Amt_nbr__c from PartnerFundRequest where title =: 'TESTMDFDraft' and recordtypeid =: Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_CCF];
                pfr1.Core_MDF_Fund_Request_Status__c ='In-Progress';
                //pfr1.Core_MDF_Budget_Type_nm__c ='CCF 1.0';
                Database.update(pfr1);
                Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
                pfrMap.put(pfr1.Id,pfr1);
                Core_MDF_CloseActivity.closeActivityAmountCalculation(pfrMap,'Manual');
                Test.stopTest();
                        
                
            }
            
            System.assert(hasAccess == true);
        }
        
        @isTest 
        static void runCloseActivityAmountCalculation_Test(){
            boolean hasAccess = false;
            
            PermissionSet accountManager = [SELECT Id FROM permissionset where name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' limit 1];
            PermissionSet claimcaseReviewerManagerPS = [SELECT Id FROM permissionset WHERE name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1];
            //Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
            Map<id,AggregateResult> pfcAmountMap = new Map<id,AggregateResult>();
            // Creating User with utility class 
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            Database.insert(usr1);
            
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = accountManager.Id, AssigneeId = usr1.Id);
            Database.upsert(psa);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment (PermissionSetId = claimcaseReviewerManagerPS.Id, AssigneeId = usr1.Id);
            Database.upsert(psa2);
            System.runAs(usr1){
                Test.startTest();
                // Call user eligibility method
                Map<string,List<string>> permissionsetsMap = new Map<string,List<string>>();
                string permissionSetName = Label.Core_MDF_Close_Activity_Allowed_Roles;
                List<String> permissionSets = new List<String>();
                
                permissionSets = permissionSetName.split(',');
                permissionsetsMap.put('closeactivity', permissionSets);            
                hasAccess = Core_MDF_CloseActivity.userEligibilitytoIncloseActivity(permissionsetsMap); 
                Core_MDF_CloseActivity.activityCloseWrapper wrapper = new Core_MDF_CloseActivity.activityCloseWrapper();
                PartnerFundRequest pfr1 = [select id,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c,Core_MDF_Reimbursement_Rate__c, Core_MDF_Activity_Reimbursement_Amt_nbr__c,Core_MDF_ToBeClosedDate__c from PartnerFundRequest where title =: 'TESTAmountMDF' and recordtypeid =: Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_CCF];
                pfr1.Core_MDF_Fund_Request_Status__c ='In-Progress';
                update pfr1;
                Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
                pfrMap.put(pfr1.Id,pfr1);   
                PartnerFundClaim claim1 = new PartnerFundClaim();
                claim1.Title ='Test Claim1';
                claim1.RequestId = pfr1.Id;
                claim1.Core_MDF_Status__c ='Submitted';
                claim1.Amount =5;
                claim1.Core_MDF_Country_Location_nm__c='ARGENTINA';
                claim1.Core_MDF_Ad_Run_Start_Date__c =system.today();
                claim1.Core_MDF_Ad_Run_End_Date__c = system.today();
                claim1.Core_MDF_Currency__c='USD';
                claim1.Core_MDF_Total_Invoice_Amount_Local__c =5.00;
                claim1.Core_MDF_Invoice_Number__c='123';
                claim1.Core_MDF_Invoice_Date__c = system.today();
                claim1.RecordTypeId=Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF;
                claim1.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
                Insert claim1;
                claim1.Core_MDF_Status__c='Paid';
                update claim1;
              Core_MDF_CloseActivity.closeActivityAmountCalculation(pfrMap,'Manual');
              Test.stopTest();
                        
                
            }
            
            System.assert(hasAccess == true);
        }
        @istest
        static public void checkActivityEligibiltyForCloseRMF(){
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', True);
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                              false);
        acc1Retail.Core_Account_Type__c = 'Reseller';
        acc1Retail.Industry = 'Food & Beverage';
        acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
        acc1Retail.Core_Geo__c = 'APJ';            
        acc1Retail.Core_Sub_Geo__c = 'IJKK';
            insert acc1Retail;
            test.startTest();
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                        Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
        accRetail.Core_Geo__c = 'APJ';
        accRetail.Core_Sub_Geo__c = 'IJKK';
            insert accRetail;
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(-20), 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', true);
            PartnerFundRequest RetailPfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today()-10,System.today()-10,false); 
            RetailPfr.Title ='Retail RSA MD Activity';
            RetailPfr.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
            RetailPfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
            RetailPfr.RequestedAmount =1000;
            RetailPfr.Amount=1000;
            RetailPfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
            RetailPfr.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            RetailPfr.Core_MDF_Budget_Currency_cd__c ='USD';
            RetailPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            insert RetailPfr;
            RetailPfr.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            update RetailPfr;
            Core_MDF_CloseActivity.checkActivityEligibiltyForClose(RetailPfr.id);
            test.stopTest();
            
        }
        
    }