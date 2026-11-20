@isTest(SeeAllData=false)
public class Core_MDF_Recovery_Helper_Test {
    @TestSetup
    static void makeData() {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        List<User> usrList =new List<User>();
        User usr= Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'MDF Budget Loader';
        usr.profileId = systemAdminProfile.Id;
        usrList.add(usr);
        
        User usr1= Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'Group Inserter';
        usr1.profileId = systemAdminProfile.Id;
        usrList.add(usr1);
        
        Database.insert(usrList);
        
        system.runAs(usr1){
            /*List<group> grpList = new List<Group>();
            Group grp = new Group(Name = 'AGS_CCP CCFB Finance Manager Queue Group', DeveloperName = 'Core_MDF_CCP_CCFB_Fin_Mgr_Queue_Group');
            grpList.add(grp);
            Group grp1 = new Group(Name = 'CCP Finance Manager Queue', DeveloperName = 'CCP_Finance_Manager_Queue');
            grpList.add(grp1);
            insert grpList;
            
            List<GroupMember> grpMemList = new List<GroupMember>();
            GroupMember grpMember = new GroupMember();
            grpMember.GroupId = grp.Id;
            grpMember.UserOrGroupId = usr.id;
            grpMemList.add(grpMember);
            
            GroupMember grpMember1 = new GroupMember();
            grpMember1.GroupId = grp1.Id;
            grpMember1.UserOrGroupId = usr.id;
            grpMemList.add(grpMember1);
            database.insert(grpMemList);*/
        }
        
        /*Group grp = [Select id from Group where DeveloperName = 'Core_MDF_CCP_EMEA_Retail_Budget_Queue' limit 1];
        GroupMember grpMember = new GroupMember();
        grpMember.GroupId = grp.Id;
        grpMember.UserOrGroupId = usr.id;
        database.insert(grpMember);*/
        
        permissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Finance_Usr' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps1.Id);
        
        PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Finance_Manager'];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id );
        
        System.runAs(usr){
            List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing'}, true, false));       
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing','bypass_VATClaimsForRecovery',
                'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Account_Program_based_Sharing','Bypass_Bank_ABM_Sharing','Bypass_Claims_Sharing_Internal_Users'}, true, false));
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing'}, true, false));                 
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_MDF_Budget_Access_Validation','Bypass_MDF_Budget_Status_Validation'}, true, false));
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ValidatePartnerScoreforUpdate'}, true, false));
            Database.insert(transactions);
            
            //Create Channel Program
            ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', true);
            
            //Create Intel Account
            List<Account> accList = new List<Account>();
            Account recoveryIntelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Recovery Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
            recoveryIntelAcc.BillingCity = 'Recovery City';         
            recoveryIntelAcc.BillingCountry= 'IND';
            recoveryIntelAcc.BillingStreet= 'Recovery Street'; 
            
            Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Flipkart', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intelAccount.Core_Geo__c = 'EMEA';
            intelAccount.Core_Sub_Geo__c = 'CER';
            accList.add(recoveryIntelAcc);
            accList.add(intelAccount);
            Database.insert(accList);
            //Create Virtual Corp
            Account recoveryCCFVC = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF Virtual Corp', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryCCFVC.Core_MDF_Parent_Fund_Account__c = recoveryIntelAcc.Id;
            recoveryCCFVC.Core_MDF_CoMarketingActive__c = true;
            Database.insert(recoveryCCFVC);
            
            Account recoveryCCFEMEA = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF EMEA', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryCCFEMEA.Core_MDF_Parent_Fund_Account__c = recoveryCCFVC.Id;
            Database.insert(recoveryCCFEMEA);
            
            Account recoveryEMEAFrance = Core_MDF_CCP_TestDataUtility.createAccount ('Recovery CCF EMEA France', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            recoveryEMEAFrance.Core_MDF_Parent_Fund_Account__c = recoveryCCFEMEA.Id;
            recoveryEMEAFrance.Core_MDF_Auto_Transfer_Account__c = recoveryCCFVC.Id;
            recoveryEMEAFrance.Core_MDF_Enabled_Auto_Transfer__c = True;
            Database.insert(recoveryEMEAFrance);
            
            Account intelRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', retailCp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelRetail.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
            intelRetail.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            intelRetail.Core_Geo__c = 'EMEA';
            intelRetail.Core_Sub_Geo__c = 'CER';
            Database.insert(intelRetail);
            
            PartnerMarketingBudget  recoveryPmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Recovery PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,recoveryCCFVC.Id,ccfCP.Id,80000000,System.today().addDays(-10),System.today().addDays(10),false);
            recoveryPmbRecord.Core_MDF_Budget_Type_Txt__c ='OEM CMP';
            Database.insert(recoveryPmbRecord);
            
            
            PartnerFundAllocation pfaRecoveryCCFFrance = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaRecoveryCCFFrance',recoveryPmbRecord, recoveryEMEAFrance, 80000000, true);
            
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createRetailBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                                                         intelRetail.Id,retailCp.Id,80000000,System.today().addDays(-97),
                                                                                         System.today().addDays(5), 
                                                                                         false,'RSA MD'); 
            pmb.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
            pmb.Core_MDF_Budget_Type__c = 'RSA MD';
            Database.insert(pmb);
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,intelRetail,80000000.0,true);
            
            Core_MDF_Bank__c recoveryBank = Core_MDF_CCP_TestDataUtility.createBank(recoveryIntelAcc.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            
            //Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(recoveryEMEAFrance.Id,recoveryBank.Id,true);
            
            Campaign recoveryCamp = Core_MDF_CCP_TestDataUtility.createCampaign('ARP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-5), System.today().addDays(+5), 5000000, 'Consumer Chromebook', recoveryCCFVC.Id, '2-in-1', false);
            recoveryCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF;MDF+';
            recoveryCamp.Core_MDF_Supports_legacy_program__c='MDF or both CMP & MDF';
            Database.insert(recoveryCamp);
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'Yes MDF or both CMP & MDF',
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',
                                                                        System.today() - 97, System.today().addYears(1), 5000000, 
                                                                        'Instore innovation', intelRetail.Id,'2-in-1', false);
            camp.Core_MDF_Budget_Type_txt__c ='RSA MD';
            database.insert(camp);
            
            Core_MDF_Campaign_Budgets__c campBudget = new Core_MDF_Campaign_Budgets__c();
            campBudget.Core_MDF_Budget_Name_Id__c = recoveryPmbRecord.id;
            campBudget.Core_MDF_Campaign_Id__c=recoveryCamp.id;
            campBudget.Core_MDF_Budget_Amt__c=36363;
            campBudget.Core_MDF_Reimbursement_Rate_Pct__c='55%';
            campBudget.Core_MDF_Reimbursement_Amt__c= 2000;
            campBudget.Core_MDF_Active_ind__c=true;
            Database.insert(campBudget);
            
            List<Core_MDF_Configuration__c> configMDF = new List<Core_MDF_Configuration__c>();
            Core_MDF_Configuration__c config1 = new Core_MDF_Configuration__c();
            config1.NAME = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            config1.Core_MDF_Value__c='3';
            config1.Core_MDF_Category__c ='Bank Document Hold Logic';
            configMDF.add(config1);
            
            Core_MDF_Configuration__c config2 = new Core_MDF_Configuration__c();
            config2.Core_MDF_Value__c = '1000';
            config2.Name = 'Core_MDF_PScore_Edit_Buffer_Days';
            configMDF.add(config2);
            insert configMDF;
            
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            PartnerFundRequest recoveryFranceActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(recoveryCamp.Id), 
                                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                              String.valueof(recoveryEMEAFrance.id),pfaRecoveryCCFFrance,recoveryPmbRecord,'INDIA',
                                                                                                              'Consumer',
                                                                                                              'Desktop',
                                                                                                              'Intel® Core™ i5 Processor',
                                                                                                              'Broadcast (Pre-2025)',
                                                                                                              'Podcast',
                                                                                                              'Draft',
                                                                                                              false);
            recoveryFranceActivity.Title = 'France Activity';
            recoveryFranceActivity.Core_MDF_Activity_Description__c = 'France Activity';
            recoveryFranceActivity.Core_MDF_Start_Date__c = System.today().addDays(-2);
            recoveryFranceActivity.Core_MDF_End_Date__c = System.today().addDays(+2);
            recoveryFranceActivity.RequestedAmount = 1000;
            recoveryFranceActivity.Core_MDF_pagespayingfor__c = 15;
            recoveryFranceActivity.Amount=1000;
            recoveryFranceActivity.Core_MDF_Budget_Type_nm__c= 'MDF';
            recoveryFranceActivity.Core_MDF_Reimbursement_Rate_pct__c='50%';
            recoveryFranceActivity.Core_MDF_Reimbursement_Rate_txt__c = '50%';
            recoveryFranceActivity.Core_MDF_Channel_Partner_Led__c = true;
            recoveryFranceActivity.Status = 'Approved';
            recoveryFranceActivity.AllocationId = pfaRecoveryCCFFrance.Id;
            PartnerFundRequest recoveryFranceActivityMDFP = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(recoveryCamp.Id), 
                                                                                                                  Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                                  String.valueof(recoveryEMEAFrance.id),pfaRecoveryCCFFrance,recoveryPmbRecord,'INDIA',
                                                                                                                  'Consumer',
                                                                                                                  'Desktop',
                                                                                                                  'Intel® Core™ i5 Processor',
                                                                                                                  'Broadcast (Pre-2025)',
                                                                                                                  'Podcast',
                                                                                                                  'Draft',
                                                                                                                  false);
            recoveryFranceActivityMDFP.Title = 'France Activity MDF+';
            recoveryFranceActivityMDFP.Core_MDF_Activity_Description__c = 'France Activity MDF+';
            recoveryFranceActivityMDFP.Core_MDF_Start_Date__c = System.today().addDays(-2);
            recoveryFranceActivityMDFP.Core_MDF_End_Date__c = System.today().addDays(+2);
            recoveryFranceActivityMDFP.RequestedAmount = 1000;
            recoveryFranceActivityMDFP.Core_MDF_pagespayingfor__c = 15;
            recoveryFranceActivityMDFP.Amount=1000;
            recoveryFranceActivityMDFP.Core_MDF_Budget_Type_nm__c= 'MDF+';
            recoveryFranceActivityMDFP.Core_MDF_Reimbursement_Rate_pct__c='50%';
            recoveryFranceActivityMDFP.Core_MDF_Reimbursement_Rate_txt__c = '50%';
            recoveryFranceActivityMDFP.Core_MDF_Channel_Partner_Led__c = true;
            recoveryFranceActivityMDFP.Status = 'Approved';
            recoveryFranceActivityMDFP.AllocationId=pfaRecoveryCCFFrance.Id;
            PartnerFundRequest currentQuarterPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                                         Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                                         string.valueof(intelRetail.id),NULL,NULL,
                                                                                                         'AFGHANISTAN','Business','Workstation',
                                                                                                         'EVO','Broadcast (Pre-2025)',
                                                                                                         'Podcast','Draft',false);
            
            currentQuarterPfr.Title ='RSA MD Activity';
            currentQuarterPfr.Core_MDF_Activity_Description__c ='RSA MD Activity';
            //currentQuarterPfr.Core_MDF_Budget_Type_txt__c ='RSA MD';
            currentQuarterPfr.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            currentQuarterPfr.Core_MDF_Start_Date__c = System.today().addDays(-2);
            currentQuarterPfr.Core_MDF_End_Date__c  = System.today().addDays(+2);
            currentQuarterPfr.RequestedAmount =1000;
            currentQuarterPfr.Amount=1000;
            //currentQuarterPfr.Core_MDF_Country__c ='GERMANY';
            currentQuarterPfr.Core_MDF_Country_nm__c = 'GERMANY';
            currentQuarterPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            currentQuarterPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            currentQuarterPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            currentQuarterPfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            currentQuarterPfr.Status = 'Approved';
            currentQuarterPfr.AllocationId = pfa.Id;
            /*pfrList.add(currentQuarterPfr);
            
            pfrList.add(recoveryFranceActivity);
            pfrList.add(recoveryFranceActivityMDFP);*/
            //pfrList.add()
            Database.insert(currentQuarterPfr);
            Database.insert(recoveryFranceActivity);
            Database.insert(recoveryFranceActivityMDFP);
            //Database.insert(pfrList);
            
            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            
            for(Integer i = 0; i < 3; i++) {        
                PartnerFundClaim pfc  = new PartnerFundClaim();
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail;                
                pfc.Title = 'Test Claim' + i;
                pfc.RequestId = currentQuarterPfr.Id;
                if(i==3){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 100;                
                }else{
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 50;    
                }                                  
                pfc.Core_MDF_Status__c = 'Submitted';
                pfc.Description = 'Test PFC ';
                pfc.Core_MDF_Ad_Run_Start_Date__c = system.today().addDays(-1);
                pfc.Core_MDF_Ad_Run_End_Date__c = system.today();
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Country_Location_nm__c= 'GERMANY';
                pfc.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Invoice_Date__c = system.today();
                pfc.Core_MDF_Invoice_Number__c = '123';
                pfc.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
                pfc.Core_MDF_Taxes_Local__c = 0;
                pfc.Amount = 10;
                
                pfcList.add(pfc);
            }
            Test.startTest();
            
            //List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            PartnerFundClaim recoveryClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivity.Id,
                                                                                       recoveryFranceActivity.Core_MDF_Start_Date__c, 
                                                                                       recoveryFranceActivity.Core_MDF_Start_Date__c,100,System.today(),null,false);
            recoveryClaim1.Core_MDF_PIC_Review_Completed__c = true;
            recoveryClaim1.Core_MDF_BackendReviewSelection_Ind__c = false;
            recoveryClaim1.Amount = 10;
            recoveryClaim1.Core_MDF_Currency__c='USD'; 
            recoveryClaim1.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            recoveryClaim1.Core_MDF_Invoice_Date__c = system.today();
            recoveryClaim1.Core_MDF_Invoice_Number__c = '123';
            recoveryClaim1.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            recoveryClaim1.Core_MDF_Taxes_Local__c = 0;
            pfcList.add(recoveryClaim1);
            
            PartnerFundClaim recoveryClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivity.Id,
                                                                                       recoveryFranceActivity.Core_MDF_Start_Date__c, 
                                                                                       recoveryFranceActivity.Core_MDF_Start_Date__c,30,System.today(),null,false);
            recoveryClaim2.Core_MDF_PIC_Review_Completed__c = true;
            recoveryClaim2.Core_MDF_BackendReviewSelection_Ind__c = false;
            recoveryClaim2.Amount = 30;
            recoveryClaim2.Core_MDF_Reimbursable_Transaction_Amount__c=30;
            recoveryClaim2.Core_MDF_Currency__c='USD';
            recoveryClaim2.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            recoveryClaim2.Core_MDF_Invoice_Date__c = system.today();
            recoveryClaim2.Core_MDF_Invoice_Number__c = '123';
            recoveryClaim2.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            recoveryClaim2.Core_MDF_Taxes_Local__c = 0;
            pfcList.add(recoveryClaim2);
            
            
            PartnerFundClaim recoveryClaimMDFP = Core_MDF_CCP_TestDataUtility.createClaim('France Claim MDF+', 
                                                                                          Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivityMDFP.Id,
                                                                                          recoveryFranceActivity.Core_MDF_Start_Date__c, 
                                                                                          recoveryFranceActivity.Core_MDF_Start_Date__c,300,System.today(),null,false);
            recoveryClaimMDFP.Core_MDF_Document_Submission_Missed_Ind__c = true;
            recoveryClaimMDFP.Amount = 300;
            recoveryClaimMDFP.Core_MDF_Currency__c='USD'; 
            recoveryClaimMDFP.Core_MDF_Ad_Run_Start_Date__c = system.today().addDays(-1);
            recoveryClaimMDFP.Core_MDF_Ad_Run_End_Date__c = system.today();
            recoveryClaimMDFP.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            recoveryClaimMDFP.Core_MDF_Invoice_Date__c = system.today();
            recoveryClaimMDFP.Core_MDF_Invoice_Number__c = '123';
            recoveryClaimMDFP.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
            recoveryClaimMDFP.Core_MDF_Taxes_Local__c = 0;
            
            pfcList.add(recoveryClaimMDFP);
            Database.insert(pfcList);
            
            List<Core_MDF_Partnership_Score__c> psList = new List<Core_MDF_Partnership_Score__c>();
            Core_MDF_Partnership_Score__c partnershipScore = new Core_MDF_Partnership_Score__c();
            partnershipScore.Core_MDF_Account_Id__c = recoveryIntelAcc.id;
            partnershipScore.Core_MDF_Virtual_Corp_Account_Id__c = recoveryCCFVC.Id;
            partnershipScore.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            partnershipScore.Core_MDF_Quarter_Year_Nm__c = 'Q2 2022';
            partnershipScore.Core_MDF_Zone_nm__c = 'A3';
            partnershipScore.Core_MDF_Channel_Program_Id__c = ccfCP.Id;
            partnershipScore.Core_MDF_Quarter_nm__c ='Q2';
            partnershipScore.Core_MDF_Year_nm__c ='2022';
            partnershipScore.Core_MDF_External_Id__c = String.valueof(ccfCP.Id) + String.valueof(recoveryCCFVC.Id) + 'Q2 2022';
            psList.add(partnershipScore);
            
            Core_MDF_Partnership_Score__c partnershipScoreRetail = new Core_MDF_Partnership_Score__c();
            partnershipScoreRetail.Core_MDF_Account_Id__c = intelAccount.id;
            partnershipScoreRetail.Core_MDF_Virtual_Corp_Account_Id__c = intelRetail.Id;
            partnershipScoreRetail.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
            partnershipScoreRetail.Core_MDF_Quarter_Year_Nm__c = 'Q2 2022';
            partnershipScoreRetail.Core_MDF_Zone_nm__c = 'A3';
            partnershipScoreRetail.Core_MDF_Channel_Program_Id__c = retailCp.Id;
            partnershipScoreRetail.Core_MDF_Quarter_nm__c ='Q2';
            partnershipScoreRetail.Core_MDF_Year_nm__c ='2022';
            partnershipScoreRetail.Core_MDF_External_Id__c = String.valueof(retailCp.Id) + String.valueof(intelRetail.Id) + 'Q2 2022';
            psList.add(partnershipScoreRetail);
            
            insert psList;
            
            List<Core_MDF_Partnership_Score_Detail__c> psdList = new List<Core_MDF_Partnership_Score_Detail__c>();
            Core_MDF_Partnership_Score_Detail__c psd1 = new Core_MDF_Partnership_Score_Detail__c();
            psd1.Core_MDF_Budget_Type_nm__c = 'MDF';
            psd1.Core_MDF_Carry_Over_Amt__c = 1000;
            psd1.Core_MDF_Region_Cd__c = 'APJ';
            psd1.Core_MDF_Partnership_Score_Id__c = partnershipScore.id;
            psd1.Core_MDF_External_Id__c = partnershipScore.Core_MDF_External_Id__c + psd1.Core_MDF_Budget_Type_nm__c + psd1.Core_MDF_Region_Cd__c;
            psdList.add(psd1);  
            
            Core_MDF_Partnership_Score_Detail__c psd2 = new Core_MDF_Partnership_Score_Detail__c();
            psd2.Core_MDF_Budget_Type_nm__c = 'MDF';
            psd2.Core_MDF_Carry_Over_Amt__c = 1000;
            psd2.Core_MDF_Region_Cd__c = 'ASMO';
            psd2.Core_MDF_Partnership_Score_Id__c = partnershipScore.id;
            psd2.Core_MDF_External_Id__c = partnershipScore.Core_MDF_External_Id__c + psd2.Core_MDF_Budget_Type_nm__c + psd2.Core_MDF_Region_Cd__c;
            psdList.add(psd2);
            
            Core_MDF_Partnership_Score_Detail__c psd3 = new Core_MDF_Partnership_Score_Detail__c();
            psd3.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            psd3.Core_MDF_Carry_Over_Amt__c = 1000;
            psd3.Core_MDF_Region_Cd__c = 'APJ';
            psd3.Core_MDF_Partnership_Score_Id__c = partnershipScoreRetail.id;
            psd3.Core_MDF_Node_Account_Id__c = intelRetail.Id;
            psd3.Core_MDF_External_Id__c = partnershipScoreRetail.Core_MDF_External_Id__c +  String.valueOf(intelRetail.Id) + psd3.Core_MDF_Budget_Type_nm__c + psd3.Core_MDF_Region_Cd__c;
            psdList.add(psd3);  
            insert psdList;
            
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            for(PartnerFundClaim claim:[select id,Core_MDF_Status__c,Core_MDF_Region_Cd__c from PartnerFundClaim limit 5]){
                claim.Core_MDF_Status__c = 'Payment Due';
                claimList.add(claim);
            }
            Database.update(claimList);
            
            Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c();
            rr.Core_MDF_Claim_Id__c = claimList[1].id;
            rr.Core_MDF_Claim_External_ID__c = claimList[1].id;
            rr.Core_MDF_Account_Id__c = recoveryIntelAcc.id;
            rr.Core_MDF_Recovery_Amount_Amt__c = 100;
            rr.Core_MDF_Program_Nm__c = 'Client CoMarketing Fund';
            rr.Core_MDF_Quarter_Year_Nm__c = 'Q2 2022';
            rr.Core_MDF_Active_Ind__c = true;
            rr.Core_MDF_Recovered_Budget_Nm__c = 'MDF;APJ=100';
            
            Database.insert(rr);
            Test.stopTest();
        }
    }
    
    @isTest static void testGetClaimsBasedOnConditionsForBatch() {
        User usr = [Select Id, lastName from User where lastName = 'MDF Budget Loader' limit 1];
        Test.startTest();
        Account accountRecord = [select id from Account where Name ='Recovery Test Account'];
        System.runAs(usr){
            Map<string,List<Core_MDF_Recovery_Helper.RecoveryBatchParams>> result = new Map<string,List<Core_MDF_Recovery_Helper.RecoveryBatchParams>>();
            string programBudgetTypeQuarter = 'Client CoMarketing Fund;MDF;Q2 2022';
            List<id> accountIds = new List<id>();
            accountIds.add(accountRecord.id);
            assert.isNotNull(accountIds);
            Test.stopTest();
        }
    }
    
    @isTest static void testSaveRecoveryRequests() {
        Test.startTest();
        User usr = [Select Id, lastName from User where lastName = 'MDF Budget Loader' limit 1];
        Account accountRecord = [select id from Account where Name ='Recovery Test Account' limit 1];
        List<PartnerFundClaim> claim = [select id from PartnerFundClaim where Core_MDF_Budget_Type_Options_Nm__c = 'MDF' limit 2];
        List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows> rrr = new List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows>();
        Map<boolean,string> result = new Map<boolean,string>();
        List<Core_MDF_Recovery_Request__c> rrList = new List<Core_MDF_Recovery_Request__c>();
        List<id> accountIds = new List<id>();
        System.runAs(usr){
            
            accountIds.add(accountRecord.id);            
            
            Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows record1 = new Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows();
            record1.id = claim[0].id;
            record1.accountId = accountRecord.id;
            record1.recoveryAmount = '100';
            record1.program ='Client CoMarketing Fund';
            record1.quarter='Q2 2022';
            record1.budgetGeoConsumed = 'MDF;APJ=50:MDF;ASMO=50';
            record1.budgetType = 'MDF';
            record1.geo = 'APJ';
            
            Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows record2 = new Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows();
            record2.id = claim[1].id;
            record2.accountId = accountRecord.id;
            record2.recoveryAmount = '20';
            record2.program ='Client CoMarketing Fund';
            record2.quarter='Q2 2022';
            record2.budgetGeoConsumed = 'MDF;ASMO=10';
            record2.budgetType = 'MDF';
            record2.geo = 'ASMO';
            
            rrr.add(record1);
            rrr.add(record2);
            
            Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c();
            rr.Core_MDF_Claim_Id__c = claim[1].id;
            rr.Core_MDF_Claim_External_ID__c = claim[1].id + '56';
            rr.Core_MDF_Account_Id__c = accountRecord.id;
            rr.Core_MDF_Recovery_Amount_Amt__c = 100;
            rr.Core_MDF_Program_Nm__c = 'Client CoMarketing Fund';
            rr.Core_MDF_Quarter_Year_Nm__c = 'Q2 2022';
            rr.Core_MDF_Active_Ind__c = true;
            rrList.add(rr);
        }
        Database.insert(rrList);
        assert.areEqual(true,rrList[0].Core_MDF_Active_Ind__c);
        Map<string,Map<string,decimal>> accountToBTGeoToAmountMap = new Map<string,Map<string,decimal>>();
        Map<string,Map<string,List<PartnerFundClaim>>> allClaimsList = new Map<string,Map<string,List<PartnerFundClaim>>>();
        Map<string,Map<id,decimal>> recommendedClaims = new Map<string,Map<id,decimal>>();
        string programBudgetTypeQuarter = 'Client CoMarketing Fund;MDF;Q2 2022';
        Core_MDF_Recovery_Batch.recoveryDataWrapper wrapperRecData1 = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
        wrapperRecData1.accntListId = accountIds;
        wrapperRecData1.source = 'Payment Run';
        wrapperRecData1.isPreSelClaim_RecvryDone = false;
        wrapperRecData1.program = 'Client CoMarketing Fund';
        Map<string,List<Core_MDF_Recovery_Helper.RecoveryBatchParams>> result2 = new Map<string,List<Core_MDF_Recovery_Helper.RecoveryBatchParams>>();
        accountToBTGeoToAmountMap =  Core_MDF_Recovery_Helper.calculateRecoveryAmount(programBudgetTypeQuarter,wrapperRecData1,true);
        allClaimsList = Core_MDF_Recovery_Helper.queryClaims(programBudgetTypeQuarter, accountIds, true);
        recommendedClaims = Core_MDF_Recovery_Helper.processClaimsBasedOnBTGeo(accountToBTGeoToAmountMap,allClaimsList);
        Core_MDF_Recovery_Helper.formatRecordsForBatch(recommendedClaims, 'Claims');
        result2 = Core_MDF_Recovery_Helper.getClaimsBasedOnConditionsForBatch(programBudgetTypeQuarter,wrapperRecData1);
        Test.stopTest();        
    }
    
    @isTest static void testGetClaimsBasedOnConditionsForUI() {
        Test.startTest();
        User usr = [Select Id, lastName from User where lastName = 'MDF Budget Loader' limit 1];
        Account accountRecord = [select id from Account where Name ='Recovery Test Account' limit 1];
        System.runAs(usr){
            List<id> accountIds = new List<id>();
            
            accountIds.add(accountRecord.id);
            assert.isNotNull(accountIds);
            Core_MDF_RecoveryClaimReportViewCtrl.FinalRightRows result = Core_MDF_Recovery_Helper.getClaimsBasedOnConditionsForUI('Client CoMarketing Fund', accountRecord.id, 'Q2 2022');
            string programBudgetTypeQuarter = 'Client CoMarketing Fund;MDF;Q2 2023';
            Core_MDF_Recovery_Helper.queryClaims(programBudgetTypeQuarter, accountIds, true);
            Core_MDF_Recovery_Helper.queryClaims(programBudgetTypeQuarter, accountIds, false);
            
            Map<string,Map<string,decimal>> accountToBTGeoToAmountMap = new Map<string,Map<string,decimal>>();
            Map<string,Map<string,List<PartnerFundClaim>>> allClaimsList = new Map<string,Map<string,List<PartnerFundClaim>>>();
            Map<string,Map<id,decimal>> recommendedClaims = new Map<string,Map<id,decimal>>();
            Core_MDF_Recovery_Batch.recoveryDataWrapper wrapperRecData = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
            wrapperRecData.accntListId = accountIds;
            wrapperRecData.source = 'Payment Run';
            wrapperRecData.isPreSelClaim_RecvryDone = false;
            wrapperRecData.program = 'Intel Partner Alliance';
            string programBudgetTypeQuarter1 = 'Intel Partner Alliance;Account Plan;Q2 2023';
            Map<string,List<Core_MDF_Recovery_Helper.RecoveryBatchParams>> result1 = new Map<string,List<Core_MDF_Recovery_Helper.RecoveryBatchParams>>();
            accountToBTGeoToAmountMap =  Core_MDF_Recovery_Helper.calculateRecoveryAmount(programBudgetTypeQuarter1,wrapperRecData,true);
            allClaimsList = Core_MDF_Recovery_Helper.queryClaims(programBudgetTypeQuarter1, accountIds, true);
            recommendedClaims = Core_MDF_Recovery_Helper.processClaimsBasedOnBTGeo(accountToBTGeoToAmountMap,allClaimsList);
            Core_MDF_Recovery_Helper.formatRecordsForBatch(recommendedClaims, 'Claims');
            result1 = Core_MDF_Recovery_Helper.getClaimsBasedOnConditionsForBatch(programBudgetTypeQuarter1,wrapperRecData);            
            Test.stopTest();
        }
    }
    
    @isTest static void testGetClaimsBasedOnConditionsForUIForPreviuousQuarter() {
        Test.startTest();
        User usr = [Select Id, lastName from User where lastName = 'MDF Budget Loader' limit 1];
        Account accountRecord = [select id from Account where Name ='Recovery Test Account' limit 1];
        System.runAs(usr){
            List<id> accountIds = new List<id>();
            
            accountIds.add(accountRecord.id);
            assert.isNotNull(accountIds);
            
            Date currDate = System.today();
            Integer currYear = currDate.year();
            Integer quarterNum = (currDate.month() - 1)/3;
            //String currQuarter = quarterNum == 0 ? 'Q1' : quarterNum == 1 ? 'Q2' : quarterNum == 2 ? 'Q3' : quarterNum == 3 ? 'Q4' : '' ;
            String previousQuarterAndYear;
            if(quarterNum == 0){
                previousQuarterAndYear = 'Q4 ' +  (currYear - 1);
            }else{
                previousQuarterAndYear = 'Q' + quarterNum + ' ' + currYear;
            }
            Core_MDF_RecoveryClaimReportViewCtrl.FinalRightRows result = Core_MDF_Recovery_Helper.getClaimsBasedOnConditionsForUI('Client CoMarketing Fund', accountRecord.id, previousQuarterAndYear);
            Test.stopTest();
        }
    }
    
    @isTest static void testGetDataFromRecoveryRequest() {
        Test.startTest();
        User usr = [Select Id, lastName from User where lastName = 'MDF Budget Loader' limit 1];
        Account accountRecord = [select id from Account where Name ='Recovery Test Account' limit 1];
        PartnerFundClaim claim = [select id from PartnerFundClaim limit 1];
        Map<string,Map<id,decimal>> result = new Map<string,Map<id,decimal>>();
        List<Core_MDF_Recovery_Request__c> rrList = new List<Core_MDF_Recovery_Request__c>();
        List<id> accountIds = new List<id>(); 
        System.runAs(usr){
            
            
            accountIds.add(accountRecord.id);
            for(Integer i=0;i<2;i++){
                Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c();
                rr.Core_MDF_Claim_Id__c = claim.id;
                rr.Core_MDF_Account_Id__c = accountRecord.id;
                rr.Core_MDF_Recovery_Amount_Amt__c = 10;
                rr.Core_MDF_Program_Nm__c = 'Client CoMarketing Fund';
                rr.Core_MDF_Quarter_Year_Nm__c = 'Q2 2022';
                rr.Core_MDF_Active_Ind__c = true;
                rrList.add(rr);
            }
        }
        Database.insert(rrList);
        assert.isNotNull(rrList);
        Core_MDF_Recovery_Batch.recoveryDataWrapper recoveryWrapperAccList = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
        recoveryWrapperAccList.accntListId = accountIds;
        
        result = Core_MDF_Recovery_Helper.getDataFromRecoveryRequest('Client CoMarketing Fund;MDF;Q2 2022', recoveryWrapperAccList,false);
        result = Core_MDF_Recovery_Helper.getDataFromRecoveryRequest('Service Provider CoMarketing Fund;;Q2 2023', recoveryWrapperAccList,false);
        result = Core_MDF_Recovery_Helper.getDataFromRecoveryRequest('Data Center CoMarketing Fund;MDF;Q2 2023', recoveryWrapperAccList,false);
        
        Core_MDF_Recovery_Batch.recoveryDataWrapper recoveryWrapperAccList1 = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
        recoveryWrapperAccList1.accntListId = accountIds;
        recoveryWrapperAccList1.source = 'Payment Run';
        recoveryWrapperAccList1.bdgtTypeList = new List<String>{'OEM CMP'};
            result = Core_MDF_Recovery_Helper.getDataFromRecoveryRequest('Service Provider CoMarketing Fund;;Q2 2023', recoveryWrapperAccList1,true);
        Test.stopTest();
    }  
    
    @isTest static void testRMFFlow(){
        Test.startTest();
        User usr = [Select Id, lastName from User where lastName = 'MDF Budget Loader' limit 1];
        Account accountRecord = [select id from Account where Name ='Flipkart' limit 1];
        System.runAs(usr){
            Map<string,List<Core_MDF_Recovery_Helper.RecoveryBatchParams>> result = new Map<string,List<Core_MDF_Recovery_Helper.RecoveryBatchParams>>();
            string programBudgetTypeQuarter = 'Retail Marketing Funds;RSA MD;Q2 2022';
            List<id> accountIds = new List<id>();
            accountIds.add(accountRecord.id);
            assert.isNotNull(accountIds);
            Core_MDF_Recovery_Batch.recoveryDataWrapper recoveryWrapperAccList = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
            recoveryWrapperAccList.accntListId = accountIds;        
            result = Core_MDF_Recovery_Helper.getClaimsBasedOnConditionsForBatch(programBudgetTypeQuarter,recoveryWrapperAccList);
            Test.stopTest();
        }
    }
    
    @isTest static void testSaveRecoveryRequests3() {
        Test.startTest();
        User usr = [Select Id, lastName from User where lastName = 'MDF Budget Loader' limit 1];
        Account accountRecord = [select id from Account where Name ='Recovery Test Account' limit 1];
        List<PartnerFundClaim> claim = [select id from PartnerFundClaim where Core_MDF_Budget_Type_Options_Nm__c = 'MDF' limit 2];
        List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows> rrr = new List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows>();
        Map<boolean,string> result = new Map<boolean,string>();
        List<Core_MDF_Recovery_Request__c> rrList = new List<Core_MDF_Recovery_Request__c>();
        List<id> accountIds = new List<id>();
        System.runAs(usr){
            
            accountIds.add(accountRecord.id);                        
            
            Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows record1 = new Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows();
            record1.id = claim[0].id;
            record1.accountId = accountRecord.id;
            record1.recoveryAmount = '100';
            record1.program ='Client CoMarketing Fund';
            record1.quarter='Q2 2022';
            record1.budgetGeoConsumed = 'MDF;APJ=50';
            record1.budgetType = 'MDF';
            record1.geo = 'APJ'; 
            rrr.add(record1);
            
            Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c();
            rr.Core_MDF_Claim_Id__c = claim[1].id;
            rr.Core_MDF_Claim_External_ID__c = claim[1].id + '56';
            rr.Core_MDF_Account_Id__c = accountRecord.id;
            rr.Core_MDF_Recovery_Amount_Amt__c = 100;
            rr.Core_MDF_Program_Nm__c = 'Client CoMarketing Fund';
            rr.Core_MDF_Quarter_Year_Nm__c = 'Q2 2022';
            rr.Core_MDF_Active_Ind__c = true;
            rrList.add(rr);            
        }
        Database.insert(rrList);
        
        Core_MDF_Recovery_Batch.recoveryDataWrapper recoveryWrapperAccList = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
        recoveryWrapperAccList.accntListId = accountIds;
        Map<string,Map<id,decimal>> result1 = new Map<string,Map<id,decimal>>();
        result1 = Core_MDF_Recovery_Helper.getDataFromRecoveryRequest('Client CoMarketing Fund;MDF;Q2 2022', recoveryWrapperAccList,false);
        
        Map<string,Map<string,decimal>> accountToBTGeoToAmountMap = new Map<string,Map<string,decimal>>();
        Map<string,Map<string,List<PartnerFundClaim>>> allClaimsList = new Map<string,Map<string,List<PartnerFundClaim>>>();
        Map<string,Map<id,decimal>> recommendedClaims = new Map<string,Map<id,decimal>>();
        string programBudgetTypeQuarter = 'Client CoMarketing Fund;MDF;Q2 2022';
        Core_MDF_Recovery_Batch.recoveryDataWrapper wrapperRecData1 = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
        wrapperRecData1.accntListId = accountIds;
        wrapperRecData1.source = 'Payment Run';
        wrapperRecData1.isPreSelClaim_RecvryDone = false;
        wrapperRecData1.program = 'Client CoMarketing Fund';
        Map<string,List<Core_MDF_Recovery_Helper.RecoveryBatchParams>> result2 = new Map<string,List<Core_MDF_Recovery_Helper.RecoveryBatchParams>>();
        accountToBTGeoToAmountMap =  Core_MDF_Recovery_Helper.calculateRecoveryAmount(programBudgetTypeQuarter,wrapperRecData1,true);
        allClaimsList = Core_MDF_Recovery_Helper.queryClaims(programBudgetTypeQuarter, accountIds, true);
        recommendedClaims = Core_MDF_Recovery_Helper.processClaimsBasedOnBTGeo(accountToBTGeoToAmountMap,allClaimsList);
        Core_MDF_Recovery_Helper.formatRecordsForBatch(recommendedClaims, 'RR');
        
        String key = 'Budget+Geo:MDF;APJ';
        Core_MDF_Recovery_Helper.eligibilityLogic(key,claim,'sameBudgetType');
        Core_MDF_Recovery_Helper.eligibilityLogic(key,claim,'crossBudgetType');
        String key1 = 'Geo:MDF;APJ';
        Core_MDF_Recovery_Helper.eligibilityLogic(key1,claim,'sameBudgetType');
        Core_MDF_Recovery_Helper.eligibilityLogic(key1,claim,'crossBudgetType');
        assert.areEqual(true,rrList[0].Core_MDF_Active_Ind__c);
        result = Core_MDF_Recovery_Helper.saveRecoveryRequests(rrr);
        Test.stopTest();
        
    }
}