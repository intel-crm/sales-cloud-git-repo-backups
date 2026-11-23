@isTest(SeeAllData=false)
public class Core_MDF_DetermineEmailRecipients_Test {
   @TestSetUp
    static void createTestData(){
        
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = adminRole.Id;
        insert usr;
        
        System.runAs(usr){
            ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Flipkart', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intelAccount.Core_Geo__c = 'APJ';
            database.insert(intelAccount);
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            PermissionSet retailAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            PermissionSet reviewerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1];
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
            
            externalUser.Core_Audience_List__c = 'RMF User';
            database.update(externalUser);           
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            
            // Creating User with utility class 
            User extUser = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUser.LastName = 'Claim Submitter';
            extUser.ProfileId = partnerProfile.Id;
            extUser.email = 'xyz@mail.com';
            extUser.ContactId = externalUser.Id;
            extUser.isActive = true;
            Database.insert(extUser);
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = retailAccManagerPS.Id, AssigneeId = retailAccountManager.Id);
            permissionSetAssignmentList.add(psa1);
            
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = retailAccManagerPS.Id, AssigneeId = accountManager.Id);
            permissionSetAssignmentList.add(psa2);
            
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = claimSubmitterPS.Id, AssigneeId = extUser.Id);
            permissionSetAssignmentList.add(psa3);
            
            insert permissionSetAssignmentList;            
            
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            
            test.startTest();
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = intelAccount.Id;
            iupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            iupgm.Core_MDF_User_id__c = retailAccountManager.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Retail_Account_Manager';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgm);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm2.Core_MDF_Account_id__c = intelAccount.Id;
            iupgm2.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
            iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            iupgm2.Core_MDF_User_id__c = accountManager.Id;
            iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Retail_Account_Manager';
            iupgm2.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(iupgm2);
            
            database.insert(iupgmList);  
            test.stopTest();            
        }
    }
    
    @isTest
    static void sendEmailTest(){
        
        User user = [SELECT Id FROM User WHERE LastName = 'User Test' limit 1];
        
        ChannelProgram retailCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Retail Marketing Funds' limit 1];
        
        Account intelAccount = [SELECT Id, Name FROM Account WHERE Name = 'Flipkart' limit 1];
        
        Core_MDF_Partner_Group_Mapping__c pgm = [SELECT Id,Core_MDF_Group_Id__c,Core_MDF_Region_cd__c
                                                 FROM Core_MDF_Partner_Group_Mapping__c
                                                 WHERE Core_MDF_Region_cd__c = 'APJ'];
        System.assert(pgm.Core_MDF_Group_Id__c != NULL);
        system.runAs(user){
            
            Account intelRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', retailCp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            intelRetail.Core_MDF_Parent_Fund_Account__c = intelAccount.Id;
            intelRetail.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
            intelRetail.Core_Geo__c = 'APJ';
            Database.insert(intelRetail);
            
            User extUser = [SELECT Id,LastName,email FROM User WHERE email = 'xyz@mail.com'];//LastName = 'Claim Submitter' limit 1];
            System.debug('extUser--' + extUser.Id + 'Name---' + extUser.LastName);
            Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(intelRetail.Id,extUser.Id,true);
            
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',
                                                                         System.today() - 45, System.today().addYears(1), 2000, 
                                                                         'Instore innovation', intelRetail.Id,'2-in-1', false);
            camp1.Core_MDF_Budget_Type_txt__c ='RSA MD';
            database.insert(camp1);
            
            PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                   intelRetail.Id,retailCp.Id,5000000,System.today().addDays(-5),
                                                                                   System.today().addDays(5), true);
            
            // Creating Allocation using utility class
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,intelRetail,1000000.0,true);
            
            test.startTest();
            PartnerFundRequest testPartnerFundRequest1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp1.Id),
                                                                                                               Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                                               string.valueof(intelRetail.id),NULL,NULL,
                                                                                                               'AFGHANISTAN','Business','Workstation',
                                                                                                               'EVO','Broadcast',
                                                                                                               'Podcast','Draft',false);
      
            testPartnerFundRequest1.Title ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Activity_Description__c ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Budget_Type_txt__c ='RSA MD';
            testPartnerFundRequest1.Core_MDF_Start_Date__c = System.today() - 4;
            testPartnerFundRequest1.Core_MDF_End_Date__c  = System.today();
            System.debug('activity start date'+testPartnerFundRequest1.Core_MDF_Start_Date__c);
            System.debug('activity end date'+testPartnerFundRequest1.Core_MDF_End_Date__c);
            testPartnerFundRequest1.RequestedAmount =1000;
            testPartnerFundRequest1.Amount=1000;
            testPartnerFundRequest1.Core_MDF_Country__c ='AFGHANISTAN';
            testPartnerFundRequest1.Core_MDF_Country_nm__c = 'AFGHANISTAN';
            testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequest1.Core_MDF_Budget_Currency_cd__c ='USD'; 
            testPartnerFundRequest1.Core_MDF_Reimbursement_Rate_pct__c='100%';
            database.insert(testPartnerFundRequest1);
      
            
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail,
                                                                                          testPartnerFundRequest1.Id, System.today(), System.today(), 50.00, false);
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim1.Title = 'Retail RSA MD Claim';
            database.insert(claim1);
            
            
            Case cs = new Case();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
            //cs.Id = pfc1.Core_MDF_Claim_Review_Case__c;
            cs.Status = 'Closed';
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = intelRetail.Id;
            cs.Core_MDF_Claim_ID__c = claim1.Id;
            insert cs;  
            
            Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
            Core_MDF_Escalation__c esc3 = new Core_MDF_Escalation__c();
            esc3.Core_MDF_Escalation_Status_nm__c='Pending Review';
            esc3.Core_MDF_Escalation_Name_txt__c='Test2';
            esc3.Core_MDF_Total_Dollar_Impact_amt__c= 1; //7917343
            esc3.Core_MDF_Root_Cause_nm__c = 'Creative';
            esc3.Core_MDF_Case_ID_Number_id__c = cs.Id;
            esc3.Core_MDF_Channel_Program_id__c = retailCp.Id;
            esc3.recordtypeid = caseRecType;
            database.insert(esc3);            
            
            Core_MDF_Escalation__c escInserted = [SELECT Id,Core_MDF_PGM_Internal_Group_Id_txt__c,
                                                  Core_MDF_Co_Marketing_Activity_id__r.ChannelPartner.Id
                                                  FROM Core_MDF_Escalation__c  LIMIT 1];
            System.assertEquals('Closed', cs.Status);
      
            List<Core_MDF_DetermineEmailRecipients.InitialInputs> inputList = new List<Core_MDF_DetermineEmailRecipients.InitialInputs>();
            
            Core_MDF_DetermineEmailRecipients.InitialInputs accMgr = new Core_MDF_DetermineEmailRecipients.InitialInputs();
            accMgr.recordId = esc3.id;
            accMgr.templateName = 'Core_MDF_LateClaimEscalationApproved';
            accMgr.recipients = 'InternalUsers';
            accMgr.permissionSetName = 'Core_MDF_CCP_Internal_Retail_Account_Manager';
            accMgr.sendDiff = FALSE;
            accMgr.groupId = pgm.Core_MDF_Group_Id__c;
            inputList.add(accMgr);
            
            Core_MDF_DetermineEmailRecipients.InitialInputs submitter = new Core_MDF_DetermineEmailRecipients.InitialInputs();
            submitter.recordId = esc3.id;
            submitter.templateName = 'Core_MDF_LateClaimEscalationApproved';
            submitter.recipients = 'ExternalUsers';
            submitter.permissionSetName = 'Core_MDF_CCP_External_Retail_Claim_Submitter';
            submitter.sendDiff = FALSE;
            submitter.accountId = intelRetail.Id;
            inputList.add(submitter);
            
      		Core_MDF_DetermineEmailRecipients.determineRecipients(inputList);
            
            List<Core_MDF_GenericClassToSendMail.MailParams> paramsList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
            
            //Send to group, not diff
            Core_MDF_GenericClassToSendMail.MailParams mailToGroup = new Core_MDF_GenericClassToSendMail.MailParams();
            mailToGroup.groupId = pgm.Core_MDF_Group_Id__c;
            mailToGroup.sendDiff = FALSE;
            mailToGroup.recordId = cs.Id;
            mailToGroup.templateName = 'Core_MDF_NotifyRSMOnMoreDocsRequest';
            paramsList.add(mailToGroup);
            
            //Send to group, diff
            Core_MDF_GenericClassToSendMail.MailParams mailToGroupDiff = new Core_MDF_GenericClassToSendMail.MailParams();
            mailToGroupDiff.groupId = pgm.Core_MDF_Group_Id__c;
            mailToGroupDiff.sendDiff = TRUE;
            mailToGroupDiff.recordId = cs.Id;
            mailToGroupDiff.templateName = 'Core_MDF_NotifyRSMOnMoreDocsRequest';
            paramsList.add(mailToGroupDiff);
            
            //Send to user, diff
            Core_MDF_GenericClassToSendMail.MailParams mailToUserDiff = new Core_MDF_GenericClassToSendMail.MailParams();
            List<Id> userIdsList = new List<Id>(); 
            for(User userId : [SELECT Id,LastName FROM USER WHERE LastName LIKE '%Manager%']){
                userIdsList.add(userId.Id);
            }   
            mailToUserDiff.userIdList = userIdsList;
            mailToUserDiff.sendDiff = TRUE;
            mailToUserDiff.recordId = cs.Id;
            mailToUserDiff.templateName = 'Core_MDF_NotifyRSMOnMoreDocsRequest';
            paramsList.add(mailToUserDiff);
            
            //Send to mail, not diff
            Core_MDF_GenericClassToSendMail.MailParams mailToEmailId = new Core_MDF_GenericClassToSendMail.MailParams();
            mailToEmailId.emailIds = 'test@intel.com';
            mailToEmailId.sendDiff = FALSE;
            mailToEmailId.recordId = cs.Id;
            mailToEmailId.templateName = 'Core_MDF_NotifyRSMOnMoreDocsRequest';
            paramsList.add(mailToEmailId);
            
            //Send to mail, diff
            Core_MDF_GenericClassToSendMail.MailParams mailToEmailIdDiff = new Core_MDF_GenericClassToSendMail.MailParams();
            String emailId = 'test@intel.com;test2@intel.com';
            mailToEmailIdDiff.emailIds = emailId;
            mailToEmailIdDiff.sendDiff = TRUE;
            mailToEmailIdDiff.recordId = cs.Id;
            mailToEmailIdDiff.templateName = 'Core_MDF_NotifyRSMOnMoreDocsRequest';
            paramsList.add(mailToEmailIdDiff);
            
            Core_MDF_GenericClassToSendMail.sendEmailMethod(paramsList);
            test.stopTest();
        }
    }
}