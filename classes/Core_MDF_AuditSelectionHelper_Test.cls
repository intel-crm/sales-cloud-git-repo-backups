/****************************************************************************************************************************************
* Class Name  : Core_MDF_AuditSelectionHelper_Test 
* Version     : 1.0 
* Created Date: 8-23-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Harika P        10/23/2018                    Created to test Random Audit Selection. 
* NP(11630236)                05-03-2020                    Added ABM
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_AuditSelectionHelper_Test{
    @isTest 
    static void getCodeCoverageForMainClass(){
         Test.startTest();
         Core_MDF_AuditSelectionHelper.getCodeCoverage();
         Core_MDF_Batch_AuditRetry.getCodeCoverage();
         Test.stopTest();
    }
/****************************************************************************************************************************************
Method Name:                                   setUpData
Description:                                   Created setUpData() to prepare data for testing 
Added By:                                      Accenture – Harika P  -  10/23/2018
Modified By:                  Date:            Changes: 
Accenture – Harika P        10/23/2018         Created.
*****************************************************************************************************************************************/
    
   /*@TestSetup static void setUpData(){                
        
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        Map<String,Profile> nameToProfile = new Map<String,Profile>();
        for(Profile ccpCoreProfile : [SELECT Id,Name FROM Profile WHERE Name IN ('CCP - Core Access','Partner') LIMIT 2]){
            nameToProfile.put(ccpCoreProfile.Name,ccpCoreProfile);
        }
        for(PermissionSet clmCaseRevPS : [SELECT Id, Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_Claim_Case_Reviewer','Core_MDF_CCP_External_Claim_Submitter') LIMIT 2]){
            nameToPerSet.put(clmCaseRevPS.Name,clmCaseRevPS);
        }

        List<User> usrList = new List<User>();
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        //Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        //database.insert(usr);
        usrList.add(usr);
        
        User usr1;
        User usrClaimSub;
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName='Claim Case User';
        usr2.profile=nameToProfile.get('CCP - Core Access');
        usrList.add(usr2);
        
        Database.insert(usrList);
        
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();        
        assignPermissionSetObj.AssigneeId = usr2.Id;
        PermissionSet ccpPSclmCaseRev = nameToPerSet.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer');
        assignPermissionSetObj.PermissionSetId = ccpPSclmCaseRev.Id;           
        
        System.runAs(usr){
            Database.insert(assignPermissionSetObj);
                        
            //Create Exchnage rates records
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
            
            // Creating channel program with utility class
            List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', false);
            ChannelProgram ipaCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Intel Partner Alliance', false);
            channelProgramList.add(cp);
            channelProgramList.add(retailCp);
            channelProgramList.add(ipaCp);
            Database.insert(channelProgramList);
            
            // Creating IntelAccount with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_MDF_CoMarketingAgency__c = TRUE;
            acc1.Core_Geo__c = 'EMEA';
            acc1.Core_Sub_Geo__c = 'META';
            Database.insert(acc1);  
            
            // Creating Co-marketing Account with utility class
            List<Account> listOfAccounts = new List<Account>();
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            listOfAccounts.add(acc);
            Account intelRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', retailCp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelRetail.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            intelRetail.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
            intelRetail.Core_Geo__c = 'EMEA';
            intelRetail.Core_Sub_Geo__c = 'META';
            listOfAccounts.add(intelRetail);
            
            Account ipaAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('IPA Virtual Account', ipaCp.Id,
                                                                                        Core_MDF_CCP_TestDataUtility.Account_Record_Type,
                                                                                        acc1.id,false);
            ipaAccount.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            ipaAccount.Core_MDF_CoMarketing_Ultimate_Account__c = acc1.Id;
           // ipaAccount.Core_Geo__c = 'EMEA';
            listOfAccounts.add(ipaAccount);
            
            Database.insert(listOfAccounts);            
            
            // Creating Contact with utility class
            List<Contact> contlist = new List<Contact>();
            
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (acc1.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            contlist.add(con);
            
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false); 
            conRecord1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            contlist.add(conRecord1);
            
            Database.insert(contlist);
            
            
            // Creating User with utility class 
            List<User> usrList1 = new List<User>();
            usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = nameToProfile.get('Partner').Id;
            usr1.ContactId = con.Id;
            usrList1.add(usr1);
            
            usrClaimSub = Core_MDF_CCP_TestDataUtility.createUser(false);        
            usrClaimSub.Email='claimSub@example.com';
            usrClaimSub.ContactId = conRecord1.Id;
            usrClaimSub.ProfileId = nameToProfile.get('Partner').Id;
            usrClaimSub.isActive = true; 
            usrList1.add(usrClaimSub);
            
            Database.insert(usrList1);
            
            PermissionSetAssignment assignPermissionSetObjClaimSub = new PermissionSetAssignment();
            assignPermissionSetObjClaimSub.AssigneeId = usrClaimSub.Id;
            assignPermissionSetObjClaimSub.PermissionSetId = nameToPerSet.get('Core_MDF_CCP_External_Claim_Submitter').Id;
            database.insert(assignPermissionSetObjClaimSub);
            
            /*Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
            Database.insert(agsRoleCCF);
            
            Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
            database.insert(erpmEngagementCCF);
            
            Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('CCF Claim Submitter',agsRoleCCF.Id ,'Consolidated Co-marketing Platform','CCF User',erpmEngagementCCF.Id , true,'Client Co-Marketing Fund (CCF)',false);
            database.insert(entitlementCCF);
            
            Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
            database.insert(contactEntitlementCCF);*/
            
            /*string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaAccount);
            
            //Addeed by Areefa
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution.Name = 'enableClaimsVATEligible';
            claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
            Database.insert(claimFunctionalityNameTriggerExecution);           
            
            // Creating Bank
            List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund;',false,'1234567890');
            bank.Core_MDF_Bank_Status__c = 'Active';
            Core_MDF_Bank__c ipaBank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Intel_Partner_Alliance;',false,'1234567899');
            ipaBank.Core_MDF_Intel_Company_Code__c = '150';
            ipaBank.Core_MDF_Currency_cd__c = 'USD';
            ipaBank.Core_MDF_Tax_codes_cd__c = 'I0';
            ipaBank.Core_MDF_Bank_Status__c = 'Active';
            bankList.add(bank);
            bankList.add(ipaBank);
            Database.insert(bankList);
            
            List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
            Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.id, bank.Id, false);
            Core_MDF_Account_Bank_Mapping__c ipaAbm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(ipaAccount.Id,ipaBank.Id,false);  
            abmList.add(abmCCF1);
            abmList.add(ipaAbm);
                        

            Database.insert(abmList);
            
            Group ipaGrp = new Group();
            ipaGrp.Name = 'Core CCP IPA Internal';
            ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_Internal';
            Database.insert(ipaGrp);
     
            GroupMember ipaGrpMem = new GroupMember();
            ipaGrpMem.UserOrGroupId = usr.Id;
            ipaGrpMem.GroupId = ipaGrp.Id;
            system.runAs(usr){
                Database.insert(ipaGrpMem);
            }
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_Internal';
            pgm1.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgm1.Core_MDF_Group_Id__c = ipaGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = ipaCp.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_Region_cd__C = 'APJ';
            pgm1.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_IPA_Internal';
            Database.insert(pgm1);

            // Creating campaigns using utility class
            List<Campaign> listOfCampaign = new List<Campaign>();
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','Yes', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                        'Client CoMarketing Fund',System.today()-10,
                                                                        System.today().addDays(200), 2000, 'Unite',acc.Id,'2-in-1', false);
           
            camp.Core_MDF_Reimbursement_Amt__c=1000;
            camp.Core_MDF_Opal_Budget_Type_Txt__c='OEM CMP';
            //camp.Core_MDF_Budget_Type_txt__c='CCF 1.0';
                                                                        
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena','MDF or both CMP & MDF', 
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',
                                                                        System.today() - 45, System.today().addYears(1), 20000000, 
                                                                        'Instore innovation', intelRetail.Id,'2-in-1', false);
            camp1.Core_MDF_Budget_Type_txt__c ='RSA MD';
            camp1.Core_MDF_Opal_Budget_Type_Txt__c='RSA MD';
            
                       camp1.Core_MDF_Reimbursement_Amt__c=10000000;

            
            Campaign ipaCamp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',ipaAccount.Id, 
                                                                              System.today()-10, System.today().addDays(300),
                                                                              'Business Client Acceleration - MDF', 99999.00, 'AFGHANISTAN','Channel Partner',
                                                                              'Coffee Lake','Pending Review', 
                                                                              false);
            ipaCamp.Core_MDF_Reimbursement_Amt__c=100000;

        
            listOfCampaign.add(ipaCamp);
            listOfCampaign.add(camp);
            listOfCampaign.add(camp1);
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
           
            database.insert(listOfCampaign); 
            
            List<PartnerMarketingBudget> listOfBudget = new List<PartnerMarketingBudget>();
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   acc.Id,cp.Id,50000000,System.today()-100,System.today().addDays(110), 
                                                                                   false);
            pmb.Core_MDF_Budget_Type_Txt__c='OEM CMP';
            listOfBudget.add(pmb);                                                                     
                                                                                        
                                                                                   
            PartnerMarketingBudget pmb1 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Retail TestBudget',
                                                                                          Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                                                          intelRetail.Id,retailCp.Id,500000000,
                                                                                          System.today().addDays(-50),System.today().addDays(5), 
                                                                                          false,'RSA MD');                                                                      
            
            listOfBudget.add(pmb1); 
            Database.insert(listOfBudget);
            

            
            
            
            
            // Creating Allocation using utility class
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,10000000.0,false);
            PartnerFundAllocation pfa1 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb1,intelRetail,10000000.0,false); //repalce pmb with pmb1
            PartnerFundAllocation pfa2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation IPA',pmb,ipaAccount,10000000.0,false);
            pfaList.add(pfa);
            pfaList.add(pfa1);
            pfaList.add(pfa2);
             Test.startTest();
            //StartTestwasHere
            Database.insert(pfaList); 

                       
            
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            // Creating activities using utility class
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           string.valueof(acc.id),pfa,pmb,'INDIA','Small and Medium Business',
                                                                                           'Desktop','Intel® Core™ i7 Processor','Broadcast',
                                                                                           'Radio','Draft',false);
            pfr.RequestedAmount = 90;
            pfr.Title='TestOwnerChange';
            pfr.Amount = 22.5; //test by Sushma update from 90 to 22.5
            pfr.Status = 'Approved';
            pfr.AllocationId = pfa.Id;
            pfr.Core_MDF_Activity_Description__c = 'Test Description';
            pfr.BudgetId = pmb.Id;
            pfr.Core_MDF_Start_Date__c = system.today()-5;
            pfr.Core_MDF_End_Date__c = system.today()+2;
            pfr.Core_MDF_Reimbursement_Rate_txt__c='25%';
            pfr.Core_MDF_Reimbursement_Rate_txt__c = '25%';
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            insert pfr;
            pfr.Core_MDF_Fund_Request_Status__c = 'Closed';
            update pfr;
            //pfrList.add(pfr);
            
            PartnerFundRequest currentQuarterPfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),                                                                                                         
                                                                                                         string.valueof(intelRetail.id),NULL,NULL,
                                                                                                         false);
            currentQuarterPfr.Title ='RSA MD Activity';
            currentQuarterPfr.Core_MDF_Activity_Description__c ='RSA MD Activity';
            currentQuarterPfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
            currentQuarterPfr.Core_MDF_Start_Date__c = System.today() - 5;
            currentQuarterPfr.Core_MDF_End_Date__c  = System.today()+2 ;
            currentQuarterPfr.RequestedAmount =50;
            currentQuarterPfr.Amount=50; 
            //currentQuarterPfr.Core_MDF_Country__c ='GERMANY';
            currentQuarterPfr.Core_MDF_Country_nm__c = 'GERMANY';
            currentQuarterPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            currentQuarterPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            currentQuarterPfr.Core_MDF_Reimbursement_Rate_pct__c='25%';
            currentQuarterPfr.Core_MDF_Reimbursement_Rate_txt__c='25%';
            pfrList.add(currentQuarterPfr);
            
            PartnerFundRequest asmoPfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),                                                                                                         
                                                                                                         string.valueof(intelRetail.id),NULL,NULL,
                                                                                                         false);
            
            asmoPfr.Title ='RSA MD ASMO Activity';
            asmoPfr.Core_MDF_Activity_Description__c ='RSA MD ASMO Activity';
            asmoPfr.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            asmoPfr.Core_MDF_Start_Date__c = System.today() - 5;
            asmoPfr.Core_MDF_End_Date__c  = System.today()+2 ;
            asmoPfr.RequestedAmount =40;
            asmoPfr.Amount=40;
            //asmoPfr.Core_MDF_Country__c ='United States';
            asmoPfr.Core_MDF_Country_nm__c = 'United States';
            asmoPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            asmoPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            asmoPfr.Core_MDF_Reimbursement_Rate_pct__c='25%';
            asmoPfr.Core_MDF_Reimbursement_Rate_txt__c = '25%';
            pfrList.add(asmoPfr);
            
            PartnerFundRequest ipaPfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCamp.Id,ipaAccount.Id,
                                                                                                     System.today()-2,System.today()+2,
                                                                                                     false);
            ipaPfr.Core_MDF_Reimbursement_Rate_pct__c ='25%'; 
            ipaPfr.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            ipaPfr.RequestedAmount =150; 
            ipaPfr.AllocationId = pfa2.Id;
            ipaPfr.Core_MDF_Reimbursement_Rate_txt__c = '25%';
            pfrList.add(ipaPfr);
            
            database.insert(pfrList);
            
                                

            
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
            
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            Test.stopTest();
        }
    }
    
    @isTest static void testOwnerChange(){
        Test.startTest();
        
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution3.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
        claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before upate, after update';
        claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution3.Name = 'checkAndSendClaimsToAudit';
        claimFunctionalityNameTriggerExecution3.Core_Description__c = 'test';
        database.insert(claimFunctionalityNameTriggerExecution3);
        
        User usr = [select id from user where LastName='Claim Case User'];
        User usrClaimSub = [select id from user where email='claimSub@example.com'];
        Account acc1 = [Select id from account where Name='Test Account 1'];
        Core_MDF_Bank__c bnk = [select id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c ='1234567890'];
        PartnerFundRequest pfr = [select id from PartnerFundRequest where Title='TestOwnerChange'];        
        PartnerFundClaim pfc = new PartnerFundClaim();
        PartnerFundClaim pfc1 = new PartnerFundClaim();
        system.runAs(usr){
            pfc = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,pfr.Id,System.today(),System.today(),20000,System.today(),bnk.Id,false);
            pfc.Core_MDF_Country_Location_nm__c ='INDIA';
            pfc.Core_MDF_Currency__c = 'USD';
            pfc.Core_MDF_Claim_Submitter_Id__c = usrClaimSub.id;
            pfc.Core_MDF_Escalation_Id__c =NULL;
            //pfc.OwnerId =usrClaimSub.id;
            Database.insert(pfc);  
            pfc1 = [select id,OwnerId,Core_MDF_Claim_Submitter_Id__c from partnerfundclaim where id=:pfc.id];
            system.assertEquals(usrClaimSub.id,pfc1.Core_MDF_Claim_Submitter_Id__c);
        } 
        
        Test.stopTest(); 
    }
    
    /****************************************************************************************************************************************
    Method Name:                                   testAuditSelectionMethod
    Description:                                   Created to test random audit
    Added By:                                      Accenture – Harika P  -  10/23/2018
    Modified By:                  Date:            Changes: 
    Accenture – Harika P        10/23/2018         Created.
    *****************************************************************************************************************************************/  
    /*@isTest static void testAuditSelectionMethod(){
        // To cover exception in randomAuditSelection method
        // Excluded Core_MDF_Total_Invoice_Amount_Local__c field in below SOQL
        Test.startTest();
        List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();
        
        PartnerFundRequest pfr = [SELECT Id, RequestedAmount,Core_MDF_Start_Date__c, Core_MDF_Activity_Number__c 
                                  FROM PartnerFundRequest 
                                  WHERE RequestedAmount = 900000 limit 1];
        System.assert(pfr != NULL);
        Core_MDF_Bank__c bank = [SELECT Id, Core_MDF_Program__c
                                 FROM Core_MDF_Bank__c 
                                 WHERE Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund' limit 1];
        
            
            // Creating claims
            for(Integer i = 0; i < 11; i++) {        
                PartnerFundClaim pfc  = new PartnerFundClaim();
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
                pfc.Title = 'Test Claim' + i;
                pfc.RequestId = pfr.Id;
                if(i>=3 && i<=8){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
                }
                if(i<3){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 400;
                }
                
                if(i==9){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 200000;
                }
                if(i==10){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
                    pfc.Core_MDF_IsClaimReviewEscalation_Ind__c = true;
                }                    
                pfc.Core_MDF_Status__c = 'Submitted';
                pfc.Description = 'Test PFC ';
                pfc.Core_MDF_Ad_Run_Start_Date__c = System.today();
                pfc.Core_MDF_Ad_Run_End_Date__c = system.today();
                pfc.Core_MDF_Invoice_Date__c = System.today();
                pfc.Core_MDF_Invoice_Number__c = '1121';
                pfc.Core_MDF_Media_Vehicle__c = 'test';
                pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
                pfc.Core_MDF_Taxes_Local__c = 0;
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Exchange_rate__c = 1;
                pfc.Core_MDF_Bank__c = bank.Id;
                pfc.amount = 25000;
                pfc.Core_MDF_Country_Location_nm__c='UNITED KINGDOM'; //'BRAZIL';
                newClmList.add(pfc);
            }
               // Creating claims
            for(Integer i = 0; i < 2; i++) {        
                PartnerFundClaim pfc1  = new PartnerFundClaim();
                pfc1.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
                pfc1.Title = 'Testing Claim' + i;
                pfc1.RequestId = pfr.Id;
                if(i>=3 && i<=8){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 3000;
                }
                if(i<3){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 400;
                }
                
                if(i==9){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 3000;
                }
                if(i==10){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 3000;
                    pfc1.Core_MDF_IsClaimReviewEscalation_Ind__c = false;
                }                    
                pfc1.Description = 'Test PFC ';
                pfc1.Core_MDF_Ad_Run_Start_Date__c = System.today();
                pfc1.Core_MDF_Ad_Run_End_Date__c = system.today();
                pfc1.Core_MDF_Invoice_Date__c = System.today();
                pfc1.Core_MDF_Invoice_Number__c = '1121';
                pfc1.Core_MDF_Media_Vehicle__c = 'test';
                pfc1.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
                pfc1.Core_MDF_Taxes_Local__c = 0;
                pfc1.Core_MDF_Currency__c = 'USD';
                pfc1.Core_MDF_Exchange_rate__c = 1;
                pfc1.Core_MDF_Bank__c = bank.Id;
                pfc1.amount = 10000;
                pfc1.Core_MDF_Country_Location_nm__c='UNITED KINGDOM'; //'BRAZIL';
                pfc1.Core_MDF_FlaggedForAudit__c =false;
                pfc1.Core_MDF_Audit_Hold__c = false;
                pfc1.Core_MDF_Status__c ='Submitted';
                newClmList.add(pfc1);
            }   
            
             
            
            PartnerFundClaim pfc2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim New', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                               pfr.Id, 
                                                                               System.today(), System.today(), 
                                                                               3000, 
                                                                               pfr.Core_MDF_Start_Date__c, bank.ID, false);
            pfc2.Core_MDF_Currency__c = 'USD';
            pfc2.Core_MDF_Taxes_Local__c = 0;            
            newClmList.add(pfc2);
            
              
        
        
       // System.runAs(usr1){
            Database.insert(newClmList); 
        //} 
        
        
        list<PartnerFundClaim> exceptionPFC = [SELECT Id,Amount, Core_MDF_Claim_Ref_Number__c,CreatedDate,Title,Core_MDF_AccountCompany__c,
                                               Core_MDF_Activity_Category__c,Core_MDF_Country_Location_nm__c,Core_MDF_Activity_Types__c, 
                                               Core_MDF_Program__c,Core_MDF_Exchange_rate__c, Core_MDF_Budget_Type_Nm__c 
                                               FROM PartnerFundClaim];
        Core_MDF_AuditSelectionHelper.randomAuditSelection(exceptionPFC);

        PartnerFundClaim isEscalationTypeClm = new PartnerFundClaim();
        PartnerFundClaim isEscalationTypeClm1 = new PartnerFundClaim();

        //Restting static variable so that it will
        if(Core_MDF_AuditSelectionHelper.isError){
            Core_MDF_AuditSelectionHelper.isError = false;
        }

        /*List<PartnerFundRequest> partnerFndActivityNumber = [SELECT Id, RequestedAmount, Core_MDF_Activity_Number__c 
                                                             FROM PartnerFundRequest 
                                                             WHERE RequestedAmount = 900000 limit 1];*/
        
        /*Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
        Core_MDF_Escalation__c esc = new Core_MDF_Escalation__c();
        esc.Core_MDF_Escalation_Status_nm__c='Pending Review';
        esc.Core_MDF_Escalation_Name_txt__c='Test1';
        esc.Core_MDF_Total_Dollar_Impact_amt__c= 56;
        esc.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
        esc.Core_MDF_Co_Marketing_Activity_id__c = pfr.Id;
        esc.recordtypeid= claimRecType;
        Database.insert(esc); 
        
        List<PartnerFundClaim> claimToBeUpdated = new List<PartnerFundClaim>();
        List<PartnerFundClaim> clm = [SELECT Id,Core_MDF_IsClaimReviewEscalation_Ind__c, Core_MDF_Pred_PredictionResult__c,
                                      Core_MDF_AuditSelectionInProgress__c,Core_MDF_FlaggedForAudit__c,Core_MDF_Audit_Type__c,Title, 
                                      Core_MDF_Program__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Exchange_rate__c,
                                      CreatedById,Core_MDF_Country_Location_nm__c,Core_MDF_Claim_Ref_Number__c,CreatedDate,
                                      Core_MDF_AccountCompany__c,Core_MDF_Activity_Category__c,Amount,Core_MDF_Audit_Hold__c,Core_MDF_Status__c,
                                      Core_MDF_Activity_Types__c,Core_MDF_Predictive_Audit_Error__c,Core_MDF_Predictive_Audit_Retries__c, 
                                      Core_MDF_Budget_Type_Nm__c,Core_MDF_Escalation_Id__c, Core_MDF_Escalation_Id__r.RecordTypeId 
                                      FROM PartnerFundClaim 
                                      WHERE Title LIKE 'Testing Claim%' LIMIT 1];
        
        clm[0].Core_MDF_Escalation_Id__c = esc.Id;
        clm[0].Core_MDF_Audit_Type__c ='Manual';
        clm[0].Core_MDF_FlaggedForAudit__c =true;
        clm[0].Core_MDF_Audit_Hold__c = true;
        clm[0].Core_MDF_Status__c ='Hold';
        claimToBeUpdated.add(clm[0]);
        //update clm;
        
        list<PartnerFundClaim> pfcList = [SELECT Id,Core_MDF_IsClaimReviewEscalation_Ind__c,Core_MDF_Pred_PredictionResult__c,
                                          Core_MDF_AuditSelectionInProgress__c, Core_MDF_FlaggedForAudit__c,Core_MDF_Audit_Type__c,Title, 
                                          Core_MDF_Program__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Exchange_rate__c,CreatedById,
                                          Core_MDF_Country_Location_nm__c,Core_MDF_Claim_Ref_Number__c,CreatedDate,Core_MDF_AccountCompany__c,
                                          Core_MDF_Activity_Category__c,Amount,Core_MDF_Audit_Hold__c,Core_MDF_Status__c,
                                          Core_MDF_Activity_Types__c,Core_MDF_Predictive_Audit_Error__c,Core_MDF_Predictive_Audit_Retries__c, 
                                          Core_MDF_Budget_Type_Nm__c,Core_MDF_Escalation_Id__c, Core_MDF_Escalation_Id__r.RecordTypeId 
                                          FROM PartnerFundClaim 
                                          WHERE Title LIKE 'Test Claim%' LIMIT 11];
        pfcList[0].Core_MDF_Escalation_Id__c =esc.Id;
        claimToBeUpdated.add(pfcList[0]);
        update claimToBeUpdated;

        
        Core_MDF_AuditSelectionHelper auditSelection = new Core_MDF_AuditSelectionHelper(pfcList);
      
        
        PartnerFundClaim clm1 = [Select Id, Amount,Core_MDF_Status__c from PartnerFundClaim where Title = 'India Claim New' limit 1];
        clm1.Core_MDF_Status__c = 'Hold';
        update clm1;
        
        
        // Invoke mock respnse
        Test.setMock(HttpCalloutMock.class, new Core_MDF_MockHttpResponseGenerator_Test());
        System.enqueueJob(auditSelection);
        
        Map<PartnerFundClaim,String> claimToBeChecked = new Map<PartnerFundClaim,String>();
        claimToBeChecked.put(pfcList[0],'Random');
        claimToBeChecked.put(pfcList[1],'Random');
        claimToBeChecked.put(pfcList[2],'Random');
        claimToBeChecked.put(pfcList[3],'Predictive');
        claimToBeChecked.put(pfcList[4],'Predictive');
        claimToBeChecked.put(pfcList[5],'Predictive');
                
        User partnerUser = [SELECT Id, User.Name,LastName,email FROM User WHERE LastName='User Test1'];
        
        //Prepare xml and put it in map
        
        Map<Id,String> xmlClaimMapping = new Map<Id,String>{};
        String tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcList[3],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);
        xmlClaimMapping.put(pfcList[3].Id,tempString);        

        
        Map<Id,boolean> claimWithBoolean = new Map<Id,boolean>{};
        claimWithBoolean.put(pfcList[3].Id,true);
        claimWithBoolean.put(pfcList[4].Id,true);
        claimWithBoolean.put(pfcList[5].Id,true);
        claimWithBoolean.put(pfcList[0].Id,false);
        claimWithBoolean.put(pfcList[1].Id,false);
        claimWithBoolean.put(pfcList[2].Id,false);
        Core_MDF_AuditSelectionHelper.predictiveAuditSelection(pfcList,xmlClaimMapping,claimWithBoolean);
        Core_MDF_AuditSelectionHelper.predictiveAuditSelection(clm,xmlClaimMapping,claimWithBoolean);

        //Calling recheckCliam method
        Core_MDF_AuditSelectionHelper.recheckClaims(claimToBeChecked,xmlClaimMapping,claimWithBoolean);
        
        
        //Create fake response
        String response = '<AdvancedBI>'+
                        '<header>'+
                        '<CycleID>07122018032444</CycleID>'+
                        '<RecordsNumber>1</RecordsNumber>'+
                        '<PredictionTimeStamp>2018-12-09T20:45:22</PredictionTimeStamp>'+
                        '</header>'+
                        '<Request>'+
                        '<Line Number="1">'+
                        '<ProjectId ID="118">'+
                        '<RequestID>'+pfcList[0].Core_MDF_Claim_Ref_Number__c+'</RequestID>'+
                        '<Program>'+Core_MDF_CCP_ConstantClass.CCF_PROGRAM+'</Program>'+
                        '<PredictionResult>Non-compliant High</PredictionResult>'+
                        '<PredictionScore>0.921954</PredictionScore>'+
                        '<ThresholdFlag>Yes</ThresholdFlag>'+
                        '<Probability>0.5666667</Probability>'+
                        '<ModelTimeStamp>11/1/2018 3:17:30 PM</ModelTimeStamp>'+
                        '<IdealModelResult>Non-Compliant</IdealModelResult>'+
                        '</ProjectId>'+
                        '</Line>'+
                        '</Request>'+
                        '</AdvancedBI>';
    //Response with Core_MDF_Pred_ThresholdFlag__c as 'No' to cover else part in readXmlResponseAfterCAPSApiCall method.
    String response1 = '<AdvancedBI>'+
                        '<header>'+
                        '<CycleID>07122018032444</CycleID>'+
                        '<RecordsNumber>1</RecordsNumber>'+
                        '<PredictionTimeStamp>2018-12-09T20:45:22</PredictionTimeStamp>'+
                        '</header>'+
                        '<Request>'+
                        '<Line Number="1">'+
                        '<ProjectId ID="118">'+
                        '<RequestID>'+pfcList[0].Core_MDF_Claim_Ref_Number__c+'</RequestID>'+
                        '<Program>'+Core_MDF_CCP_ConstantClass.CCF_PROGRAM+'</Program>'+
                        '<PredictionResult>Non-compliant High</PredictionResult>'+
                        '<PredictionScore>0.921954</PredictionScore>'+
                        '<ThresholdFlag>No</ThresholdFlag>'+
                        '<Probability>0.5666667</Probability>'+
                        '<ModelTimeStamp>11/1/2018 3:17:30 PM</ModelTimeStamp>'+
                        '<IdealModelResult>Non-Compliant</IdealModelResult>'+
                        '</ProjectId>'+
                        '</Line>'+
                        '</Request>'+
                        '</AdvancedBI>';
        String response2 = NULL;
        //Reading xml response
        Core_MDF_AuditSelectionHelper.readXmlResponseAfterCAPSApiCall(response,pfcList);
        Core_MDF_AuditSelectionHelper.readXmlResponseAfterCAPSApiCall(response1,pfcList);
        Core_MDF_AuditSelectionHelper.readXmlResponseAfterCAPSApiCall(response2,clm);

        

       //Restting static variable so that it will
        if(Core_MDF_AuditSelectionHelper.isError){
            Core_MDF_AuditSelectionHelper.isError = false;
        }
         
        // Covering exception of all the method by passing negative data 
        list<PartnerFundClaim> pfcExceptionList = [SELECT Id, Title, Core_MDF_Program__c, Core_MDF_Total_Invoice_Amount_Local__c,
                                                   Core_MDF_Exchange_rate__c,Amount,CreatedById,Core_MDF_Predictive_Audit_Error__c,
                                                   Core_MDF_Predictive_Audit_Retries__c 
                                                   FROM PartnerFundClaim
                                                   WHERE Title LIKE 'Test Claim%' LIMIT 11];
                                            
        
        Map<PartnerFundClaim,String> claimToBeChecked1 = new Map<PartnerFundClaim,String>();
        claimToBeChecked1.put(pfcExceptionList[0],'Random');
        claimToBeChecked1.put(pfcExceptionList[1],'Random');
        claimToBeChecked1.put(pfcExceptionList[2],'Random');
        claimToBeChecked1.put(pfcExceptionList[3],'Predictive');
        claimToBeChecked1.put(pfcExceptionList[4],'Predictive');
        claimToBeChecked1.put(pfcExceptionList[5],'Predictive');            
        
        //Prepare xml and put it in map
        
        Map<Id,String> xmlClaimMapping1 = new Map<Id,String>{};
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[3],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);
        xmlClaimMapping1.put(pfcExceptionList[3].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[4],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping1.put(pfcExceptionList[4].Id,tempString);
        tempString = Core_MDF_AuditSelectionHelper.formXmlForPredAuditCheck(pfcExceptionList[5],'Test Agency','Test Geo', partnerUser.Name,partnerUser.email);           
        xmlClaimMapping1.put(pfcExceptionList[5].Id,tempString);
        String res = Core_MDF_AuditSelectionHelper.callCAPSApi(pfcList,xmlClaimMapping);
        Core_MDF_AuditSelectionHelper.callCAPSApi(pfcList,null);        
        
        Map<Id,boolean> claimWithBoolean1 = new Map<Id,boolean>{};
        claimWithBoolean1.put(pfcExceptionList[3].Id,true);
        claimWithBoolean1.put(pfcExceptionList[4].Id,true);
        claimWithBoolean1.put(pfcExceptionList[5].Id,true);
        claimWithBoolean1.put(pfcExceptionList[0].Id,false);
        claimWithBoolean1.put(pfcExceptionList[1].Id,false);
        claimWithBoolean1.put(pfcExceptionList[2].Id,false);
        
        //Calling recheckCliam method
        Core_MDF_AuditSelectionHelper.recheckClaims(claimToBeChecked1,xmlClaimMapping1,claimWithBoolean1);
        Core_MDF_AuditSelectionHelper.recheckClaims(claimToBeChecked1,xmlClaimMapping1,null);

        //Reading xml response
        Core_MDF_AuditSelectionHelper.readXmlResponseAfterCAPSApiCall(response,pfcExceptionList);    
        
        Test.stopTest();
       
    }
    
    /****************************************************************************************************************************************
    Method Name:                                   testAuditSelectionMethod
    Description:                                   Created to test random audit
    Added By:                                      Accenture – Harika P  -  10/23/2018
    Modified By:                  Date:            Changes: 
    Accenture – Harika P        10/23/2018         Created.
    *****************************************************************************************************************************************/  
    /*@isTest static void testAuditSelectionMethod1(){
        // To cover exception in randomAuditSelection method
        // Excluded Core_MDF_Total_Invoice_Amount_Local__c field in below SOQL
        Test.startTest();
        List<PartnerFundClaim> newClmList = new List<PartnerFundClaim>();
        
        PartnerFundRequest pfr = [SELECT Id, RequestedAmount,Core_MDF_Start_Date__c, Core_MDF_Activity_Number__c 
                                  FROM PartnerFundRequest 
                                  WHERE RequestedAmount = 900000 limit 1];
                                     
        Core_MDF_Bank__c bank = [SELECT Id, Core_MDF_Program__c
                                 FROM Core_MDF_Bank__c 
                                 WHERE Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund' limit 1];
        
            
            // Creating claims
            for(Integer i = 0; i < 11; i++) {        
                PartnerFundClaim pfc  = new PartnerFundClaim();
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
                pfc.Title = 'Test Claim' + i;
                pfc.RequestId = pfr.Id;
                if(i>=3 && i<=8){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
                }
                if(i<3){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 400;
                }
                
                if(i==9){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 200000;
                }
                if(i==10){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 20000;
                    pfc.Core_MDF_IsClaimReviewEscalation_Ind__c = true;
                }                    
                pfc.Core_MDF_Status__c = 'Submitted';
                pfc.Description = 'Test PFC ';
                pfc.Core_MDF_Ad_Run_Start_Date__c = System.today();
                pfc.Core_MDF_Ad_Run_End_Date__c = system.today();
                pfc.Core_MDF_Invoice_Date__c = System.today();
                pfc.Core_MDF_Invoice_Number__c = '1121';
                pfc.Core_MDF_Media_Vehicle__c = 'test';
                pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
                pfc.Core_MDF_Taxes_Local__c = 0;
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Exchange_rate__c = 1;
                pfc.Core_MDF_Bank__c = bank.Id;
                pfc.amount = 25000;
                pfc.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; //BRAZIL';
                newClmList.add(pfc);
            }
               // Creating claims
            for(Integer i = 0; i < 2; i++) {        
                PartnerFundClaim pfc1  = new PartnerFundClaim();
                pfc1.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF;
                pfc1.Title = 'Testing Claim' + i;
                pfc1.RequestId = pfr.Id;
                if(i>=3 && i<=8){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 3000;
                }
                if(i<3){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 400;
                }
                
                if(i==9){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 3000;
                }
                if(i==10){
                    pfc1.Core_MDF_Total_Invoice_Amount_Local__c = 3000;
                    pfc1.Core_MDF_IsClaimReviewEscalation_Ind__c = false;
                }                    
                pfc1.Description = 'Test PFC ';
                pfc1.Core_MDF_Ad_Run_Start_Date__c = System.today();
                pfc1.Core_MDF_Ad_Run_End_Date__c = system.today();
                pfc1.Core_MDF_Invoice_Date__c = System.today();
                pfc1.Core_MDF_Invoice_Number__c = '1121';
                pfc1.Core_MDF_Media_Vehicle__c = 'test';
                pfc1.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
                pfc1.Core_MDF_Taxes_Local__c = 0;
                pfc1.Core_MDF_Currency__c = 'USD';
                pfc1.Core_MDF_Exchange_rate__c = 1;
                pfc1.Core_MDF_Bank__c = bank.Id;
                pfc1.amount = 10000;
                pfc1.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM';//'BRAZIL';
                pfc1.Core_MDF_FlaggedForAudit__c =false;
                pfc1.Core_MDF_Audit_Hold__c = false;
                pfc1.Core_MDF_Status__c ='Submitted';
                newClmList.add(pfc1);
            }   
            
             
            
            PartnerFundClaim pfc2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim New', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                               pfr.Id, 
                                                                               pfr.Core_MDF_Start_Date__c, pfr.Core_MDF_Start_Date__c, 
                                                                               3000, 
                                                                               pfr.Core_MDF_Start_Date__c, bank.ID, false);
            pfc2.Core_MDF_Currency__c = 'USD';
            pfc2.Core_MDF_Taxes_Local__c = 0;            
            newClmList.add(pfc2);
            
             PartnerFundClaim pfc3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim New123', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                               pfr.Id, 
                                                                               pfr.Core_MDF_Start_Date__c, pfr.Core_MDF_Start_Date__c, 
                                                                               3000, 
                                                                               pfr.Core_MDF_Start_Date__c, bank.ID, false);
            pfc3.Core_MDF_Currency__c = 'USD';
            pfc3.Core_MDF_Taxes_Local__c = 0;        
            pfc3.Core_MDF_Type_Txt__c ='Claim';
            pfc3.Core_MDF_Currency__c='USD';
            pfc3.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM';
            //pfc3.Core_MDF_VAT_Eligibility_Ind__c= true;
            newClmList.add(pfc3);
              
        
        
       // System.runAs(usr1){
            Database.insert(newClmList); 
        //} 
        
        //VAT
        PartnerFundClaim claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Program__c from PartnerFundClaim where Title = 'India Claim New123' limit 1];
        system.assertEquals(claimins.Core_MDF_VAT_Eligibility_Ind__c, false); // for CCF claim Eligiblity will be false
        //Restting static variable so that it will
        if(Core_MDF_AuditSelectionHelper.isError){
            Core_MDF_AuditSelectionHelper.isError = false;
        }
        
        Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
        Core_MDF_Escalation__c esc = new Core_MDF_Escalation__c();
        esc.Core_MDF_Escalation_Status_nm__c='Pending Review';
        esc.Core_MDF_Escalation_Name_txt__c='Test1';
        esc.Core_MDF_Total_Dollar_Impact_amt__c= 56;
        esc.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
        esc.Core_MDF_Co_Marketing_Activity_id__c = pfr.Id;
        esc.recordtypeid= claimRecType;
        Database.insert(esc); 
        
        List<PartnerFundClaim> claimToBeUpdated = new List<PartnerFundClaim>();
        List<PartnerFundClaim> clm = [SELECT Id,Core_MDF_IsClaimReviewEscalation_Ind__c, Core_MDF_Pred_PredictionResult__c,
                                      Core_MDF_AuditSelectionInProgress__c,Core_MDF_FlaggedForAudit__c,Core_MDF_Audit_Type__c,Title, 
                                      Core_MDF_Program__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Exchange_rate__c,
                                      CreatedById,Core_MDF_Country_Location_nm__c,Core_MDF_Claim_Ref_Number__c,CreatedDate,
                                      Core_MDF_AccountCompany__c,Core_MDF_Activity_Category__c,Amount,Core_MDF_Audit_Hold__c,Core_MDF_Status__c,
                                      Core_MDF_Activity_Types__c,Core_MDF_Predictive_Audit_Error__c,Core_MDF_Predictive_Audit_Retries__c, 
                                      Core_MDF_Budget_Type_Nm__c,Core_MDF_Escalation_Id__c, Core_MDF_Escalation_Id__r.RecordTypeId 
                                      FROM PartnerFundClaim 
                                      WHERE Title LIKE 'Testing Claim%' LIMIT 1];
        
        clm[0].Core_MDF_Escalation_Id__c = esc.Id;
        clm[0].Core_MDF_Audit_Type__c ='Manual';
        clm[0].Core_MDF_FlaggedForAudit__c =true;
        clm[0].Core_MDF_Audit_Hold__c = true;
        clm[0].Core_MDF_Status__c ='Hold';
        claimToBeUpdated.add(clm[0]);
        //update clm;
        
        list<PartnerFundClaim> pfcList = [SELECT Id,Core_MDF_IsClaimReviewEscalation_Ind__c,Core_MDF_Pred_PredictionResult__c,
                                          Core_MDF_AuditSelectionInProgress__c, Core_MDF_FlaggedForAudit__c,Core_MDF_Audit_Type__c,Title, 
                                          Core_MDF_Program__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Exchange_rate__c,CreatedById,
                                          Core_MDF_Country_Location_nm__c,Core_MDF_Claim_Ref_Number__c,CreatedDate,Core_MDF_AccountCompany__c,
                                          Core_MDF_Activity_Category__c,Amount,Core_MDF_Audit_Hold__c,Core_MDF_Status__c,
                                          Core_MDF_Activity_Types__c,Core_MDF_Predictive_Audit_Error__c,Core_MDF_Predictive_Audit_Retries__c, 
                                          Core_MDF_Budget_Type_Nm__c,Core_MDF_Escalation_Id__c, Core_MDF_Escalation_Id__r.RecordTypeId 
                                          FROM PartnerFundClaim 
                                          WHERE Title LIKE 'Test Claim%' LIMIT 11];
        pfcList[0].Core_MDF_Escalation_Id__c =esc.Id;
        claimToBeUpdated.add(pfcList[0]);
        update claimToBeUpdated;

        

        //to cover Exception
        Core_MDF_AuditSelectionHelper.groupClaimsBasedOnAuditType(null,null);
        Core_MDF_AuditSelectionHelper.predictiveAuditSelection(null,null,null);        
        
        list<PartnerFundClaim> claims = new list<PartnerFundClaim>();
        PartnerFundClaim clm1 = [Select Id, Amount,Core_MDF_Status__c from PartnerFundClaim where Title = 'India Claim New' limit 1]; 
        update clm1;       
       
                
        User partnerUser = [SELECT Id, User.Name,LastName,email FROM User WHERE LastName='User Test1'];

        Map<PartnerFundClaim,String> claimToBeChecked2 = new Map<PartnerFundClaim,String>();
        claimToBeChecked2.put(pfcList[0],'Predictive');
        Core_MDF_AuditSelectionHelper.setAuditStatus(claimToBeChecked2);
        
        Map<PartnerFundClaim,String> claimToBeChecked4 = new Map<PartnerFundClaim,String>();
        claimToBeChecked4.put(clm[0],'Manual');
        Core_MDF_AuditSelectionHelper.setAuditStatus(claimToBeChecked4);
        

        String outputResult = Core_MDF_AuditSelectionHelper.getValueForAuditTypePicklist('Predictive');
        System.AssertEquals('CAP',outputResult);
        outputResult = Core_MDF_AuditSelectionHelper.getValueForAuditTypePicklist('Random');
        System.AssertEquals('Random',outputResult);
        outputResult = Core_MDF_AuditSelectionHelper.getValueForAuditTypePicklist('Manual');
        System.AssertEquals('Manual',outputResult);
        outputResult = Core_MDF_AuditSelectionHelper.getValueForAuditTypePicklist(NULL);        

       //Restting static variable so that it will
        if(Core_MDF_AuditSelectionHelper.isError){
            Core_MDF_AuditSelectionHelper.isError = false;
        }
            
        Core_MDF_AuditSelectionHelper.getDateTimeForString('11/1/2018 3:17:30 PM ');
        Core_MDF_AuditSelectionHelper.getDateTimeForString('11-1-2018 3:17:30:20 PM ');
        Core_MDF_AuditSelectionHelper.setAuditStatus(null);
        
        Test.stopTest();
       
    }
    
@isTest
    static void retailEmeaAuditValidations(){
        
        test.startTest();
         Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
        
        PartnerFundRequest retailEmeaPfr = [SELECT Id FROM PartnerFundRequest WHERE Title = 'RSA MD Activity' limit 1];
        System.Assert(retailEmeaPfr != NULL); 
        List<PartnerFundClaim> claimListToInsert = new List<PartnerFundClaim>();
        
        for(Integer i = 0; i < 3; i++) {        
            PartnerFundClaim pfcl  = new PartnerFundClaim();
            pfcl.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail;                
            pfcl.Title = 'Test Claim EMEA' ;
            pfcl.RequestId = retailEmeaPfr.Id;
            if(i==0){
                pfcl.Core_MDF_Total_Invoice_Amount_Local__c = 10500;
            }else if(i==1){
                pfcl.Core_MDF_Total_Invoice_Amount_Local__c = 25000;
            }else if(i==2){
                pfcl.Core_MDF_Total_Invoice_Amount_Local__c = 100;
            }                                  
            pfcl.Core_MDF_Status__c = 'Submitted';
            pfcl.Description = 'Test PFC' + i;
            pfcl.Core_MDF_Ad_Run_Start_Date__c = System.today();
            pfcl.Core_MDF_Ad_Run_End_Date__c = system.today();
            pfcl.Core_MDF_Currency__c = 'USD';
            pfcl.Core_MDF_Country_Location_nm__c= 'GERMANY';
            pfcl.Core_MDF_Invoice_Date__c = System.today();
        pfcl.Core_MDF_Invoice_Number__c = '1234';
        pfcl.Core_MDF_Media_Vehicle__c='Test';
        pfcl.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        pfcl.Core_MDF_Taxes_Local__c = 0;
       // pfcl.Core_MDF_Bank__c = bank1.Id;    
            claimListToInsert.add(pfcl);
        }
        
        database.insert(claimListToInsert);
        
        list<PartnerFundClaim> randomClaimList = [SELECT Id,Amount, Core_MDF_Claim_Ref_Number__c,CreatedDate,Title,Core_MDF_Region_Cd__c,
                                                  Core_MDF_AccountCompany__c,Core_MDF_Activity_Category__c,Core_MDF_Country_Location_nm__c,
                                                  ChannelPartnerId,Core_MDF_Activity_Types__c, Core_MDF_Program__c,Core_MDF_Exchange_rate__c, 
                                                  Core_MDF_Budget_Type_Nm__c 
                                                  FROM PartnerFundClaim 
                                                  WHERE Title LIKE 'Test Claim EMEA'];
        Core_MDF_AuditSelectionHelper.randomAuditSelection(randomClaimList);
        Core_MDF_AuditSelectionHelper auditSelection = new Core_MDF_AuditSelectionHelper(randomClaimList);
        System.enqueueJob(auditSelection);
        test.stopTest();
    }
    
     @isTest
    static void retailAsmoAuditValidations(){
        
        test.startTest();
        Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            
        
        PartnerFundRequest retailAsmoPfr = [SELECT Id FROM PartnerFundRequest WHERE Title = 'RSA MD ASMO Activity' limit 1];
        System.Assert(retailAsmoPfr != NULL);        
        List<PartnerFundClaim> claimListToInsert = new List<PartnerFundClaim>();
        
        for(Integer i = 0; i < 3; i++) {        
            PartnerFundClaim pfcl  = new PartnerFundClaim();
            pfcl.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail;                
            pfcl.Title = 'Test Claim ASMO' ;
            pfcl.RequestId = retailAsmoPfr.Id;
            if(i==0){
                pfcl.Core_MDF_Total_Invoice_Amount_Local__c = 5000;
            }else if(i==1){
                pfcl.Core_MDF_Total_Invoice_Amount_Local__c = 25000;
            }else if(i==2){
                pfcl.Core_MDF_Total_Invoice_Amount_Local__c = 100;
            }                                  
            pfcl.Core_MDF_Status__c = 'Submitted';
            pfcl.Description = 'Test PFC' + i;
            pfcl.Core_MDF_Ad_Run_Start_Date__c = System.today();
            pfcl.Core_MDF_Ad_Run_End_Date__c = system.today();
            pfcl.Core_MDF_Currency__c = 'USD';
            pfcl.Core_MDF_Country_Location_nm__c= 'United States';
            pfcl.Core_MDF_Invoice_Date__c = System.today();
        pfcl.Core_MDF_Invoice_Number__c = '1234';
        pfcl.Core_MDF_Media_Vehicle__c='Test';
        pfcl.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        pfcl.Core_MDF_Taxes_Local__c = 0;
        //pfcl.Core_MDF_Bank__c=bank1.Id;
            
            claimListToInsert.add(pfcl);
        }
        
        database.insert(claimListToInsert);
        
        list<PartnerFundClaim> randomClaimList = [SELECT Id,Amount, Core_MDF_Claim_Ref_Number__c,CreatedDate,Title,Core_MDF_Region_Cd__c,
                                                  Core_MDF_AccountCompany__c,Core_MDF_Activity_Category__c,Core_MDF_Country_Location_nm__c,
                                                  ChannelPartnerId,Core_MDF_Activity_Types__c, Core_MDF_Program__c,Core_MDF_Exchange_rate__c, 
                                                  Core_MDF_Budget_Type_Nm__c 
                                                  FROM PartnerFundClaim 
                                                  WHERE Title LIKE 'Test Claim ASMO'];
        Core_MDF_AuditSelectionHelper.randomAuditSelection(randomClaimList);
        test.stopTest();
    }
    
    /*@isTest
    static void ipaAuditValidations(){
        test.startTest();
        Account ipaAccount = [SELECT Id, Name,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c FROM Account WHERE Name = 'IPA Virtual Account'];
        
        Campaign ipaCamp = [SELECT Id, Status FROM Campaign WHERE Name = 'Test IPA Camp'];       
        
    PartnerFundRequest ipaPfr = [SELECT Id FROM PartnerFundRequest WHERE CampaignId =: ipaCamp.Id];       
        System.Assert(ipaPfr != NULL);
        ipaCamp.Status = 'Proposal Accepted';
        
        database.update(ipaCamp);
        
        Core_MDF_Bank__c bank = [Select Id from Core_MDF_Bank__c where Core_MDF_Program__c = 'Core_MDF_Intel_Partner_Alliance' limit 1];
        
        List<PartnerFundClaim> ipaClaimList = new List<PartnerFundClaim>();
        PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA,
                                                                                   ipaPfr.Id, System.today(), System.today(),10000.00, bank.Id, false); 
        claim1.Core_MDF_Type_Txt__c ='Claim';
        claim1.Core_MDF_Currency__c='USD';
        claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
        claim1.Core_MDF_Campaign_Id__c = ipaCamp.Id;
        ipaClaimList.add(claim1);
        
        /*PartnerFundClaim claim2 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim 2',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA,
                                                                                   ipaPfr.Id, System.today(), System.today(),1000.00, bank.Id, false); 
        claim2.Core_MDF_Type_Txt__c ='Claim';
        claim2.Core_MDF_Currency__c='USD';
        claim2.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
        claim2.Core_MDF_Campaign_Id__c = ipaCamp.Id;
        ipaClaimList.add(claim2);
        
        PartnerFundClaim claim3 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim 3',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA,
                                                                                   ipaPfr.Id, System.today(), System.today(),1000.00, bank.Id, false); 
        claim3.Core_MDF_Type_Txt__c ='Claim';
        claim3.Core_MDF_Currency__c='USD';
        claim3.Core_MDF_Country_Location_nm__c= 'AUSTRALIA'; 
        claim3.Core_MDF_Campaign_Id__c = ipaCamp.Id;
        ipaClaimList.add(claim3);
        
        database.insert(ipaClaimList);
        
        list<PartnerFundClaim> randomClaimList = [SELECT Id,Amount, Core_MDF_Claim_Ref_Number__c,CreatedDate,Title,Core_MDF_Region_Cd__c,
                                                  Core_MDF_AccountCompany__c,Core_MDF_Activity_Category__c,Core_MDF_Country_Location_nm__c,
                                                  ChannelPartnerId,Core_MDF_Activity_Types__c, Core_MDF_Program__c,Core_MDF_Exchange_rate__c, 
                                                  Core_MDF_Budget_Type_Nm__c 
                                                  FROM PartnerFundClaim];
        //Core_MDF_AuditSelectionHelper.randomAuditSelection(randomClaimList);
        Core_MDF_AuditSelectionHelper auditSelection = new Core_MDF_AuditSelectionHelper(randomClaimList);
        System.enqueueJob(auditSelection);
        test.stopTest();
        }*/
}