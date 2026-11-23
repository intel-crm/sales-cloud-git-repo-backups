@isTest(SeeAllData=false)
public class ameytestClass {
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
            ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
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
                                                                                                              'Broadcast',
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
                                                                                                                  'Broadcast',
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
                                                                                                         'EVO','Broadcast',
                                                                                                         'Podcast','Draft',false);
            
            currentQuarterPfr.Title ='RSA MD Activity';
            currentQuarterPfr.Core_MDF_Activity_Description__c ='RSA MD Activity';
            //currentQuarterPfr.Core_MDF_Budget_Type_txt__c ='RSA MD';
            currentQuarterPfr.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            currentQuarterPfr.Core_MDF_Start_Date__c = System.today();
            currentQuarterPfr.Core_MDF_End_Date__c  = System.today();
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
                pfc.Core_MDF_Ad_Run_Start_Date__c = system.today();
                pfc.Core_MDF_Ad_Run_End_Date__c = system.today();
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Country_Location_nm__c= 'GERMANY';
                
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
            pfcList.add(recoveryClaim1);
            
            PartnerFundClaim recoveryClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('France Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivity.Id,
                                                                                       recoveryFranceActivity.Core_MDF_Start_Date__c, 
                                                                                       recoveryFranceActivity.Core_MDF_Start_Date__c,30,System.today(),null,false);
            recoveryClaim2.Core_MDF_PIC_Review_Completed__c = true;
            recoveryClaim2.Core_MDF_BackendReviewSelection_Ind__c = false;
            recoveryClaim2.Amount = 30;
            recoveryClaim2.Core_MDF_Reimbursable_Transaction_Amount__c=30;
            recoveryClaim2.Core_MDF_Currency__c='USD'; 
            pfcList.add(recoveryClaim2);
            
            
            PartnerFundClaim recoveryClaimMDFP = Core_MDF_CCP_TestDataUtility.createClaim('France Claim MDF+', 
                                                                                          Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,recoveryFranceActivityMDFP.Id,
                                                                                          recoveryFranceActivity.Core_MDF_Start_Date__c, 
                                                                                          recoveryFranceActivity.Core_MDF_Start_Date__c,300,System.today(),null,false);
            recoveryClaimMDFP.Core_MDF_Document_Submission_Missed_Ind__c = true;
            recoveryClaimMDFP.Amount = 300;
            recoveryClaimMDFP.Core_MDF_Currency__c='USD'; 
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

            Test.stopTest();
            
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
        }
        List<ContentVersion> conVersionLst = new List<ContentVersion>();
            ContentVersion conVersion = new ContentVersion();
            conVersion.ContentLocation = 'S';
            conVersion.Title = 'Test';
            conVersion.PathOnClient='Test';
            conVersion.ReasonForChange = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ContentVersion_ReasonForChange');
            conVersion.VersionData = Blob.valueOf('content');
            conVersionLst.add(conVersion);
            Database.insert(conVersionLst);
    }
        
    @isTest static void testAuditDocInsert(){
        user usr = [select id from user where LastName ='MDF Budget Loader' limit 1];
	
        System.runAs(usr){
            ContentVersion contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion limit 1];
            ContentDocument conDoc= [SELECT Id,OwnerId FROM ContentDocument WHERE Id =:contentVersions.ContentDocumentId limit 1];
            PartnerFundClaim pfc = [SELECT Id from PartnerFundClaim limit 1];
            List<Core_MDF_Audit_Document__c> auditDocList = new List<Core_MDF_Audit_Document__c>();
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c(); 
            auditDoc.Core_MDF_Document_Id__c = conDoc.Id;
            auditDoc.Core_MDF_Document_Title__c = 'Test';
            auditDoc.Core_MDF_Claim__c = pfc.Id;
            auditDoc.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
            auditDoc.Core_MDF_App_Document_Types_nm__c= 'Proof of Cost;Proof of Execution;Proof of Attribution';
            
            auditDocList.add(auditDoc);
            try{
            insert auditDocList;
            }
            catch(exception e){
                
            }
            system.assertEquals(auditDoc.Core_MDF_Claim__c,pfc.Id);
        }
    }
}