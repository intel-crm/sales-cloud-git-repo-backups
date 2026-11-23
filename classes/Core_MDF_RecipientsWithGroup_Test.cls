@isTest(SeeAllData=false)
public class Core_MDF_RecipientsWithGroup_Test {
    @TestSetUp
    static void createTestData(){
        test.startTest();
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = adminRole.Id;
        insert usr;
        
        System.runAs(usr){
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');

            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);

            Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            Core_Trigger_Executions__c groupIdForAccountNode = new Core_Trigger_Executions__c();
            groupIdForAccountNode.name = 'Core_MDF_createGroupForAccountNode';
            groupIdForAccountNode.Core_Object__c = 'Account';
            groupIdForAccountNode.Core_Trigger_Events__c = 'After Insert';
            groupIdForAccountNode.Core_Active__c = TRUE;
            groupIdForAccountNode.Core_Description__c = 'To Create Group for each account';
            groupIdForAccountNode.Core_Class_Name__c = 'Core_AccountHandler';
            insert groupIdForAccountNode;
            
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Flipkart', 
                                                                                   Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intelAccount.Core_Geo__c = 'APJ';
            intelAccount.Core_Sub_Geo__c = 'ROA';
            database.insert(intelAccount);
            
            Account intelRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', retailCp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelRetail.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
            intelRetail.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            intelRetail.Core_Geo__c = 'APJ';
            intelRetail.Core_Sub_Geo__c = 'ROA';
            Database.insert(intelRetail);
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            PermissionSet retailAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            //PermissionSet reviewerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1];
            PermissionSet claimSubmitterPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Retail_Claim_Submitter' LIMIT 1];
            
            List<User> userList = new List<User>();
            
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
             
            User retailAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            retailAccountManager.profileId = ccpCoreProfile.Id;
            retailAccountManager.LastName = 'Retail Acc Manager';
            retailAccountManager.Email = 'testUser1@intel.com';
            userList.add(retailAccountManager);
            
            User accountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            accountManager.profileId = ccpCoreProfile.Id;
            accountManager.LastName = 'Acc Manager';
            retailAccountManager.Email = 'testUser2@intel.com';
            userList.add(accountManager);
            
            insert userList;
            
            Contact externalUser = Core_MDF_CCP_TestDataUtility.createContact(intelAccount.Id,false);
            externalUser.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            database.insert(externalUser);
            
            /*externalUser.Core_Audience_List__c = 'RMF User';
            database.update(externalUser);*/           
           
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            // Creating User with utility class 
            User extUser = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUser.LastName = 'Claim Submitter';
            extUser.ProfileId = partnerProfile.Id;
            extUser.email = 'xyz@mail.com';
            extUser.ContactId = externalUser.Id;
            extUser.isActive = true;
            Database.insert(extUser);
            
            Core_AGS_Role__c agsRoleRMF = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-RMF User', 'Co-Marketing(Salesforce)-RMF User', true, true);
            Core_ERPM_Engagement__c erpmEngagementRMF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('RPS_Retailer', 'RPS_Retailer', 'DEDUPGPRET', 'SEC', true, true);
            Core_Entitlement__c entitlementRMF = Core_MDF_CCP_TestDataUtility.createEntitlement('RMF User',agsRoleRMF.Id ,'Intel® Partner Investment Center','RMF User',erpmEngagementRMF.Id , true,'Retail Marketing Funds (RMF)',true);
           // Highlight: Unused Local Variable - Indira
           // Core_Contact_Entitlement__c contactEntitlementRMF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(externalUser.Id,entitlementRMF.Id ,true,'Complete', true);
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = retailAccManagerPS.Id, AssigneeId = retailAccountManager.Id);
            permissionSetAssignmentList.add(psa1);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = retailAccManagerPS.Id, AssigneeId = accountManager.Id);
            permissionSetAssignmentList.add(psa2); 
            
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = claimSubmitterPS.Id, AssigneeId = extUser.Id);
            permissionSetAssignmentList.add(psa3);
            
            insert permissionSetAssignmentList;            
            
            Group extGroup = new Group();
            extGroup.Name = 'CCP External Group';
            extGroup.DeveloperName = 'Core_MDF_CCP_External_Group';
            database.insert(extGroup);
            
            Core_MDF_Partner_Group_Mapping__c pgmRecord = new Core_MDF_Partner_Group_Mapping__c();
            pgmRecord.Core_MDF_Account__c = intelAccount.id;
            pgmRecord.Core_MDF_Channel_Program__c = retailCp.id;
            pgmRecord.Core_MDF_Type_of_Access__c ='External';
            pgmRecord.Core_MDF_Group_Name__c = 'Core_MDF_CCP_External_Group';
            pgmRecord.Core_MDF_Source_Txt__c = 'Test';
            pgmRecord.Core_MDF_AccountIdGroupName__c = intelAccount.Id+'Core_MDF_CCP_External_Group';
            database.insert(pgmRecord);
        
            GroupMember gm = new GroupMember();
            gm.GroupId = extGroup.Id;
            gm.UserOrGroupId = extUser.Id;
            database.insert(gm);
            
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();            
            Id retailIUPGMRecordTypeId = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            //Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(intelRetail.Id,extUser.Id,true);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.recordTypeId = retailIUPGMRecordTypeId;
            iupgm.Core_MDF_Account_id__c = intelRetail.Id;
            iupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
            iupgm.Core_MDF_User_id__c = retailAccountManager.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Retail_Account_Manager';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgm);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm2.recordTypeId = retailIUPGMRecordTypeId;
            iupgm2.Core_MDF_Account_id__c = intelRetail.Id;
            iupgm2.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
            iupgm2.Core_MDF_User_id__c = accountManager.Id;
            iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Retail_Account_Manager';
            iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgm2);
            
            database.insert(iupgmList);
            
            //Custom setting records needed for insertion of claim
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            test.stopTest();            
        }
    }
    
    @isTest
    static void sendEmailTest(){
        
        User user = [SELECT Id FROM User WHERE LastName = 'User Test' limit 1];
        
        ChannelProgram retailCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Retail Marketing Funds' limit 1];
        
        Account intelRetail = [SELECT Id, Name,Core_MDF_Parent_Fund_Account__c,Core_MDF_CoMarketing_Ultimate_Account__c,Core_Geo__c,
                               Core_MDF_Group_Id__c
                               FROM Account WHERE Name = 'Co-marketing Test Account' limit 1];
        // Highlight: Unused Local Variable - Indira
       // Id groupId = intelRetail.Core_MDF_Group_Id__c;
        //System.assert(groupId != NULL);
        List<Core_MDF_Partner_Group_Mapping__c> pgmRecords = [Select Id,Core_MDF_Group_Id__c from Core_MDF_Partner_Group_Mapping__c];
        System.runAs(user){
           //   PartnerMarketingBudget  pmb = Core_MDF_CCP_TestDataUtility.createRetailBudget('RSABudget',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,intelRetail.Id,retailCp.Id,5000000,System.today(),
                                                                          //         System.today(),false, 'RSA MD');
     //   pmbRecord2.IsIgnoreValidation = true;
   //     pmbRecord2.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
      //  pmbList.add(pmbRecord2);
            
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                                                   intelRetail.Id,retailCp.Id,5000000,System.today(),
                                                                                   System.today(), false);
            pmb.IsIgnoreValidation = true;
        //    pmb.Core_MDF_Budget_Type__c = 'RSA MD';
            pmb.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
            insert pmb;
            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,intelRetail,1000000.0,true);            
        

            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena','MDF or both CMP & MDF',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                         'Retail Marketing Funds',
                                                                         System.today(), System.today().addYears(1), 2000, 
                                                                         'Instore innovation', intelRetail.Id,'2-in-1', false);
            camp1.Core_MDF_Budget_Type_txt__c ='RSA MD';
            database.insert(camp1);
              
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp1.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                           string.valueof(intelRetail.id),NULL,NULL,
                                                                                           'AFGHANISTAN','Business','Workstation',
                                                                                           'EVO','Audio',
                                                                                           'Podcast','Draft',false);
            
            pfr.Title ='Retail MDF Activity';
            pfr.Core_MDF_Activity_Description__c ='Retail MDF Activity';
            pfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c  = System.today();
            pfr.RequestedAmount =1000;
            pfr.Amount=1000;
            //pfr.Core_MDF_Country__c ='AFGHANISTAN';
            pfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            pfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
            pfr.AllocationId = pfa.Id;
            pfr.status = 'Approved';
            database.insert(pfr);
              test.startTest();
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(intelRetail.Core_MDF_CoMarketing_Ultimate_Account__c, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            bank.Core_MDF_Bank_Alias_Name__c='Test';
            bank.Core_MDF_Bank_Status__c ='Active'; 
            bank.Core_MDF_Intel_Company_Code__c = '150';
            bank.Core_MDF_Tax_codes_cd__c = 'I0';
            Database.insert(bank);
            //Do Account Bank Mapping for 'bank' and ABM is applicaple only for "Retail MDF" record type
            // Highlight: Unused Local Variable - Indira
           // Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(intelRetail.ID,bank.Id,true);
            PartnerFundClaim pfc = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail,
                                                                                       pfr.Id, System.today(), System.today(), 50.00, false);
            pfc.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            pfc.Title = 'Retail RSA MD Claim';
            database.insert(pfc);
            
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
            cs.Status = 'Closed';
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = intelRetail.Id;
            cs.Origin = 'Random Selection'; 
            cs.Core_MDF_Region_SubRegion_txt__c = 'APJ';
            cs.Core_MDF_Claim_ID__c = pfc.Id;
            insert cs; 
            
            Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
            Core_MDF_Escalation__c esc = new Core_MDF_Escalation__c();
            esc.Core_MDF_Escalation_Status_nm__c='Pending Review';
            esc.Core_MDF_Escalation_Name_txt__c='Test2';
            esc.Core_MDF_Total_Dollar_Impact_amt__c= 1; //7917343
            esc.Core_MDF_Root_Cause_nm__c = 'Claim Score Appeal';
            esc.Core_MDF_Case_ID_Number_id__c = cs.Id;
            esc.Core_MDF_Channel_Program_id__c = retailCp.Id;
            esc.recordtypeid = caseRecType;
            database.insert(esc);            
            
            
            System.assertEquals('Closed', cs.Status);
                  
            List<Core_MDF_DetermineRecipientsWithGroup.InputsWithGroupList> inputList = new List<Core_MDF_DetermineRecipientsWithGroup.InputsWithGroupList>();
            
            
            Core_MDF_DetermineRecipientsWithGroup.InputsWithGroupList accMgr = new Core_MDF_DetermineRecipientsWithGroup.InputsWithGroupList();
            accMgr.recordId = esc.id;
            accMgr.templateName = 'Core_MDF_LateClaimEscalationApproved';
            accMgr.recipients = 'InternalUsers';
            accMgr.permissionSetName = 'Core_MDF_CCP_Internal_Retail_Account_Manager';
            accMgr.sendDiff = FALSE;
            accMgr.pgmRecords = pgmRecords;
            inputList.add(accMgr);
            
            Core_MDF_DetermineRecipientsWithGroup.determineRecipients(inputList);


            test.stopTest();
        }
    }
}