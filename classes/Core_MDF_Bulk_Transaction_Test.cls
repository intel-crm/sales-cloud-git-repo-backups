/* Test class Name - Core_MDF_Bulk_Transaction_Test
 * Test class for - Core_MDF_BulkTransactionTriggerHandler, Core_MDF_Bulk_TransactionServiceHandler
 * 
 */
@isTest(seeAllData=false)
private class Core_MDF_Bulk_Transaction_Test {
    
    @TestSetUp
    static void createTestData(){
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = adminRole.Id;
        insert usr;
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
        
        System.runAs(usr){
            //adding bypass feature to bypass access validation
			List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            
            
            Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Flipkart', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intelAccount.Core_Geo__c = 'EMEA';
            intelAccount.Core_Sub_Geo__c = 'CER';
            database.insert(intelAccount);
            
            Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            database.insert(ccpIntelAccount);

            Account intelRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', retailCp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelRetail.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
            intelRetail.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            intelRetail.Core_Geo__c = 'EMEA';
            intelRetail.Core_Sub_Geo__c = 'CER';
            Database.insert(intelRetail);
            
            /*Account ccfVc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', ccfCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfVc.Core_MDF_Parent_Fund_Account__c = ccpIntelAccount.Id;
            database.insert(ccfVc);*/
            
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (ccpIntelAccount.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            database.insert(con);
            
            //Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, true);
            Core_AGS_Role__c agsRoleRMF = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-RMF User', 'Co-Marketing(Salesforce)-RMF User', true, true);
            Core_AGS_Role__c agsRoleRMF_CS = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-External Retail Claim Submitter', 'Co-Marketing(Salesforce)-External Retail Claim Submitter', true, true);
            
            //Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, true);
            Core_ERPM_Engagement__c erpmEngagementRMF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('RPS_Retailer', 'RPS_Retailer', 'DEDUPGPRET', 'SEC', true, true);
            
            //Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('CCF User',agsRoleCCF.Id ,'Consolidated Co-marketing Platform','CCF User',erpmEngagementCCF.Id , true,'Client Co-Marketing Fund (CCF)',true);
            Core_Entitlement__c entitlementRMF = Core_MDF_CCP_TestDataUtility.createEntitlement('RMF User',agsRoleRMF.Id ,'Intel® Partner Investment Center','RMF User',erpmEngagementRMF.Id , true,'Retail Marketing Funds (RMF)',true);
            Core_Entitlement__c entitlementRMF_CS= Core_MDF_CCP_TestDataUtility.createEntitlement('RMF External Claim Submitter',agsRoleRMF_CS.Id ,'Intel® Partner Investment Center','RMF External Claim Submitter',erpmEngagementRMF.Id , true,'Retail Marketing Funds (RMF)',true);
            
            //Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con.Id,entitlementCCF.Id ,true,'Complete', true);
            Core_Contact_Entitlement__c contactEntitlementRMF_C1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con.Id,entitlementRMF.Id ,true,'Complete', true);
            Core_Contact_Entitlement__c contactEntitlementRMF_CS_C1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(con.Id,entitlementRMF_CS.Id ,true,'Complete', true);
            
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            usr1.ProfileId = partnerProfile.Id;
            usr1.email = 'xyz@mail.com';
            usr1.ContactId = con.Id;
            database.insert(usr1);
            
            PermissionSet retailClaimSubmitterPS = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Retail_Claim_Submitter' LIMIT 1];
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = retailClaimSubmitterPS.Id, AssigneeId = usr1.Id);
            database.insert(psa3);
            
            
            Group grp1 = new Group();
            grp1.name = 'PGM_TEST';
            database.insert(grp1);
            
            GroupMember gm = new GroupMember();
            gm.GroupId = grp1.Id;
            gm.UserOrGroupId = usr1.Id;
            database.insert(gm);
            
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = intelAccount.Id;
            pgm.Core_MDF_Group_Name__c = 'PGM_TEST';
            pgm.Core_MDF_Type_of_Access__c = 'Internal';
            pgm.Core_MDF_Group_Id__c = grp1.Id;                
            pgm.Core_MDF_Channel_Program__c = retailCp.Id;
            pgm.Core_MDF_Region_cd__c='WW';
            pgm.Core_MDF_Source_Txt__c = 'test';
            pgm.Core_MDF_AccountIdGroupName__c = intelAccount.Id+'PGM_TEST';
            database.insert(pgm);
            
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(intelRetail.Id,usr1.Id,true);
            
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createRetailBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                                                   intelRetail.Id,retailCp.Id,500000000,System.today().addDays(-97),
                                                                                   System.today().addDays(5), 
                                                                                   false,'RSA MD'); 
            pmb.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
            pmb.Core_MDF_Budget_Type__c = 'RSA MD';
            Database.insert(pmb);
            
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,intelRetail,1000000.0,true);
            
            /*Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            PartnerMarketingBudget opalbudget = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,ccfVc.Id,ccfCp.Id,12345678,System.today().addDays(-90),System.today().addDays(+90),false);
            opalbudget.Core_MDF_Budget_Type__c='MDF';
            opalbudget.Core_MDF_Budget_Type_Txt__c='MDF';
            insert opalbudget;

            
            PartnerFundAllocation pfaRecordOpal = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudget, ccfVc, 199999, true);*/
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'Yes MDF or both CMP & MDF',
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',
                                                                        System.today() - 97, System.today().addYears(1), 2000, 
                                                                        'Instore innovation', intelRetail.Id,'2-in-1', false);
            camp.Core_MDF_Budget_Type_txt__c ='RSA MD';
            database.insert(camp);
            
            /*List<Campaign> campList=new List<Campaign>();
            Campaign MDFcamp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampOpal','Consumer','Intel® Corporate Logo', 'MDF or both CMP & MDF',
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today()-250 , 
                                                                           System.today()+90, 2000, 'Unite', ccfVc.Id,'2-in-1', false);
            MDFcamp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF;OEM CMP'; 
            MDFcamp.Core_MDF_Market__c = 'AFGHANISTAN';
            campList.add(MDFcamp);
            insert campList;
            
            Core_MDF_Campaign_Budgets__c oemcmpBudget = new Core_MDF_Campaign_Budgets__c();
            oemcmpBudget.Core_MDF_Budget_Name_Id__c = opalbudget.id;
            oemcmpBudget.Core_MDF_Campaign_Id__c=MDFcamp.id;
            oemcmpBudget.Core_MDF_Budget_Amt__c=363636;
            oemcmpBudget.Core_MDF_Reimbursement_Rate_Pct__c='100%';
            oemcmpBudget.Core_MDF_Reimbursement_Amt__c= 200000;
            oemcmpBudget.Core_MDF_Active_ind__c=true;
            insert oemcmpBudget;*/
            
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            
            test.startTest();
            PartnerFundRequest currentQuarterPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                                         Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                                         string.valueof(intelRetail.id),pfa,NULL,
                                                                                                         'AFGHANISTAN','Business','Workstation',
                                                                                                         'EVO','Broadcast',
                                                                                                         'Podcast','Draft',false);
            
            currentQuarterPfr.Title ='RSA MD Activity';
            currentQuarterPfr.Core_MDF_Activity_Description__c ='RSA MD Activity';
            currentQuarterPfr.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            currentQuarterPfr.Core_MDF_Start_Date__c = System.today();
            currentQuarterPfr.Core_MDF_End_Date__c  = System.today();
            currentQuarterPfr.RequestedAmount =100000000;
            currentQuarterPfr.Amount=10000000;
            //currentQuarterPfr.Core_MDF_Country__c ='GERMANY';
            currentQuarterPfr.Core_MDF_Country_nm__c = 'GERMANY';
            currentQuarterPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            currentQuarterPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            currentQuarterPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            currentQuarterPfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
            pfrList.add(currentQuarterPfr);
            
            PartnerFundRequest lastQuarterPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                                      Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                                      string.valueof(intelRetail.id),pfa,NULL,
                                                                                                      'AFGHANISTAN','Business','Workstation',
                                                                                                      'EVO','Broadcast',
                                                                                                      'Podcast','Draft',false);
            
            lastQuarterPfr.Title ='RSA MD Activity';
            lastQuarterPfr.Core_MDF_Activity_Description__c ='RSA MD Activity';
            lastQuarterPfr.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            lastQuarterPfr.Core_MDF_Start_Date__c = System.today() - 96;
            lastQuarterPfr.Core_MDF_End_Date__c  = System.today() - 93;
            lastQuarterPfr.RequestedAmount =100000000;
            lastQuarterPfr.Amount=10000000;
            //lastQuarterPfr.Core_MDF_Country__c ='GERMANY';
            lastQuarterPfr.Core_MDF_Country_nm__c = 'GERMANY';
            lastQuarterPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            lastQuarterPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            lastQuarterPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            lastQuarterPfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
            lastQuarterPfr.Status = 'Approved';
            pfrList.add(lastQuarterPfr);
            
            PartnerFundRequest escPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                                      Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                                      string.valueof(intelRetail.id),pfa,NULL,
                                                                                                      'AFGHANISTAN','Business','Workstation',
                                                                                                      'EVO','Broadcast',
                                                                                                      'Podcast','Draft',false);
            
            escPfr.Title ='RSA MD Activity';
            escPfr.Core_MDF_Activity_Description__c ='RSA MD Activity';
            escPfr.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            escPfr.Core_MDF_Start_Date__c = System.today() - 96;
            escPfr.Core_MDF_End_Date__c  = System.today() - 93;
            escPfr.RequestedAmount =100000000;
            escPfr.Amount=10000000;
            //lastQuarterPfr.Core_MDF_Country__c ='GERMANY';
            escPfr.Core_MDF_Country_nm__c = 'GERMANY';
            escPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            escPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            escPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            escPfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
            escPfr.Status = 'Approved';
            pfrList.add(escPfr);
            
            /*PartnerFundRequest MDFpfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(ccfVc.id),null,null,'INDIA','Small Business','Desktop',
                                                                                              'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr.Title = 'Test Activity';
            MDFpfr.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr.Core_MDF_Start_Date__c = system.today()-90;
            MDFpfr.Core_MDF_End_Date__c =  system.today()-30;
            MDFpfr.BudgetId = opalbudget.Id;
            MDFpfr.AllocationId = pfaRecordOpal.Id;
            MDFpfr.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr.Core_MDF_Approval_Step_Completed__c = 1;
            MDFpfr.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            MDFpfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            //MDFpfr.Core_MDF_Intel_Activity_Owner_Id__c=systemAdmin.id;
            MDFpfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            MDFpfr.Core_MDF_MDFReimbursement_Amt__c = 1000;
            MDFpfr.RequestedAmount = 1000;
            pfrList.add(MDFpfr);*/
            
            
            database.insert(pfrList);
            escPfr.Core_MDF_Fund_Request_Status__c = 'Closed';
            database.update(escPfr);
            
            
            List<Core_MDF_Escalation__c> escList = new List<Core_MDF_Escalation__c>();
            Core_MDF_Escalation__c esc3 = new Core_MDF_Escalation__c();
            esc3.RecordTypeId=Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
            esc3.Core_MDF_Escalation_Name_txt__c='Test212';
            esc3.Core_MDF_Total_Dollar_Impact_amt__c= 1;
            esc3.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
            esc3.Core_MDF_Do_not_Auto_Create_Claim_Ind__c = false;
            esc3.Core_MDF_Co_Marketing_Activity_id__c = escPfr.id;
            esc3.Core_MDF_Claim_Submitter_Id__c	=  usr1.Id;
            esc3.Core_MDF_Escalation_Status_nm__c = 'Approved';
            escList.add(esc3);
            database.insert(escList);
            
            List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
            
            for(Integer i = 0; i < 30; i++) {        
                PartnerFundClaim pfc  = new PartnerFundClaim();
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail;                
                pfc.Title = 'Test Claim' + i;
                pfc.RequestId = currentQuarterPfr.Id;
                if(i==3){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 55000;
                }else{
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 25000;
                }                                  
                pfc.Core_MDF_Status__c = 'Submitted';
                pfc.Description = 'Test PFC ';
                pfc.Core_MDF_Ad_Run_Start_Date__c = system.today();
                pfc.Core_MDF_Ad_Run_End_Date__c = system.today();
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Country_Location_nm__c= 'GERMANY';
                
                pfcList.add(pfc);
            }  
            
            for(Integer i = 0; i < 20; i++) {        
                PartnerFundClaim pfc  = new PartnerFundClaim();
                pfc.RecordTypeId = Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail;                
                pfc.Title = 'Test LQ Claim' + i;
                pfc.RequestId = LastQuarterPfr.Id;
                if(i==3){
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 55000+(i*2);
                    pfc.Core_MDF_Audit_Type__c = 'Random';            
                    pfc.Core_MDF_FlaggedForAudit__c = TRUE;
                    pfc.Core_MDF_Status__c = 'Hold';
                    pfc.Core_MDF_Audit_Hold__c = TRUE;
                }else{
                    pfc.Core_MDF_Total_Invoice_Amount_Local__c = 25000;
                    pfc.Core_MDF_Status__c = 'Submitted';
                }                                                  
                pfc.Description = 'Test PFC ';
                pfc.Core_MDF_Ad_Run_Start_Date__c = system.today().addDays(-94);
                pfc.Core_MDF_Ad_Run_End_Date__c = system.today().addDays(-94);
                pfc.Core_MDF_Currency__c = 'USD';
                pfc.Core_MDF_Country_Location_nm__c= 'GERMANY';
                
                pfcList.add(pfc);
            }
            
            /*PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Paid Claim CCF', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, MDFpfr.Id, MDFpfr.Core_MDF_Start_Date__c, MDFpfr.Core_MDF_End_Date__c, 500.00, System.today(), null, false);
            claim1.Core_MDF_Invoice_Date__c = System.today().addDays(-1);
            //claim1.Status = Label.Core_MDF_Status_Submitted;
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'India'; 
            claim1.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
            claim1.Core_MDF_VAT_Eligibility_Ind__c = false;
            claim1.Core_MDF_To_Be_Audited_Ind__c=false;
            claim1.Core_MDF_Region_Cd__c='APJ';
            claim1.Core_MDF_Status__c ='PIC Pending';
            claim1.Core_MDF_PIC_Review_Completed__c = false;
            claim1.Core_MDF_Bank_Doc_Hold_Ind__c = false;
            Claim1.Core_MDF_Escalation_Id__c = esc3.id;
            pfcList.add(Claim1);*/
            database.insert(pfcList);
            
            test.stopTest();
            Datetime createdate = Datetime.now().addDays(-93);
            Test.setCreatedDate(LastQuarterPfr.Id, createdate);
        }
        
    }
    
    @isTest
    private static void upsertRecordsTest() {
        
            User usr = [SELECT Id,UserPermissionsMarketingUser FROM User WHERE LastName = 'User Test' LIMIT 1];
            List<Core_MDF_Bulk_Transaction__e> updateRecordList = new List<Core_MDF_Bulk_Transaction__e>();
        Test.startTest();
            
        List<PartnerFundClaim> claimListForAudit = [SELECT Id FROM PartnerFundClaim];
            Core_MDF_Escalation__c escClaim = [Select id from Core_MDF_Escalation__c where Core_MDF_Escalation_Name_txt__c='Test212' Limit 1];
            for(PartnerFundClaim claim : claimListForAudit){   
                
                Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e(); 
                
                PartnerFundClaim pfc = new PartnerFundClaim();
                pfc.Id = claim.Id;
                pfc.Core_MDF_Status__c = 'Hold';
                pfc.Core_MDF_Audit_Hold__c = true;
                pfc.Core_MDF_Audit_Type__c = 'Random';
                pfc.Core_MDF_Budget_Type_Options_Nm__c = 'MDF+';
                pfc.Core_MDF_Escalation_Id__c = escClaim.id;
                //Add Claim Data in JSON for processing   
                evtObj.Core_MDF_JSON_Data__c = JSON.serialize(pfc); 
                evtObj.Core_MDF_Object_Name__c = 'PartnerFundClaim';
                evtObj.Core_MDF_Action_Name__c = 'Cancelled Claim';
                
                //Core_MDF_Bulk_Transaction__e evtObj1 = new Core_MDF_Bulk_Transaction__e(); 
                updateRecordList.add(evtObj);
                
            } 
            if(!updateRecordList.isEmpty()){              
                
                List<Database.SaveResult> results = EventBus.publish(updateRecordList);
                System.assert(results != null);
            }
        
                Test.stopTest();  
    }
    
    @isTest
    private static void upsertRecordsTest2() {
        User usr = [SELECT Id,UserPermissionsMarketingUser FROM User WHERE LastName = 'User Test' LIMIT 1];
         List<Core_MDF_Bulk_Transaction__e> toBeUpdatedUserRecordList = new List<Core_MDF_Bulk_Transaction__e>();
         Core_MDF_Bulk_Transaction__e evtObj2 = new Core_MDF_Bulk_Transaction__e(); 
             User userInstance = new User();
             userInstance.Id = usr.Id;
             userInstance.UserPermissionsMarketingUser = true;
             evtObj2.Core_MDF_JSON_Data__c = JSON.serialize(userInstance); 
             evtObj2.Core_MDF_Object_Name__c = 'User';
             toBeUpdatedUserRecordList.add(evtObj2);
        	
             Test.startTest();
             List<Database.SaveResult> results = EventBus.publish(toBeUpdatedUserRecordList);
             System.assert(results != null);
             Test.stopTest();  
              
    }
}