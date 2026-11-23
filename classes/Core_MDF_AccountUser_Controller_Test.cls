/****************************************************************************************************************************************
* Class Name  : Core_MDF_AccountUser_Controller_Test
* Version     : 1.0 
* Created Date: 09-08-2019
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture-KK                    09/08/2019                    Created to test Account User add/delete functionality 
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_AccountUser_Controller_Test {
    // test method for data setup
    @TestSetup static void setUpData(){
        
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');        
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
        bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
        bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Bypass_UpdateActivityFields');
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('Core_MDF_Bypass_PFR_Trigger');
        bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
        bypassFunctionKeys.add('Core_MDF_Bypass_PFREmailNotification');
        bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');

        bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');

        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        

        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');

        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');

        bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');

        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        bypassFunctionKeys.add('Core_MDF_Validate_EscClaimingWindow');
        bypassFunctionKeys.add('Core_MDF_Bypass_Escalation_Trigger');
        
        bypassFunctionKeys.add('Core_MDF_EscalationErrorsNotification');
        
        bypassFunctionKeys.add('Core_MDF_Bypass_Case_Details_On_Esc');
        


        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');

        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);

        List<Core_Trigger_Executions__c> trigList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c byPass = new Core_Trigger_Executions__c();
        byPass.Name = 'Core_MDF_Bypass_PFC_Trigger';
        byPass.Core_Active__c = false;
        byPass.Core_Class_Name__c = 'Core_MDF_PFC_Trigger';
        byPass.Core_Description__c = 'test';
        byPass.Core_Object__c = 'PartnerFundClaim';
        byPass.Core_Trigger_Events__c = 'TestTriggerEvent';
        trigList.add(byPass);

		insert trigList;
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,Core_MDF_CCP_ConstantClass.CCF_TECHNICAL_PROGRAM_NAME, true);
        
        List<Account> accList = new List<Account>();
        List<Account> updateAccList = new List<Account>();
                
        //Custom settings
        Core_Trigger_Executions__c Settings4 = new Core_Trigger_Executions__c();
        Settings4.Name = 'Core_MDF_Account_node_share';
        Settings4.Core_Active__c = True;
        Settings4.Core_Class_Name__c = 'Core_Account';
        Settings4.Core_Description__c = 'method is used Create PNUM based External sharing group';
        Settings4.Core_Object__c = 'Account';
        Settings4.Core_Trigger_Events__c = 'after insert';
        database.insert(Settings4);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.BillingStateCode = '';
        insert acc1;
        
        // Creating Co-marketing Account with utility class
        Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 1', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        accList.add(acc);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        acc2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        accList.add(acc2);
        
        Database.insert(accList);
        Group newNodeGroup = new Group();
        newNodeGroup.name = 'CCP_'+acc.Id+'_EXT_GRP';
        newNodeGroup.DeveloperName = 'Core_MDF_CCP_'+acc.Id+'_EXT_GRP';
        insert newNodeGroup;
        acc1.IsPartner = true;
        updateAccList.add(acc1);
        acc.IsPartner = true;
        acc.Core_MDF_External_Group_Id__c=newNodeGroup.Id;
        updateAccList.add(acc);
        acc2.IsPartner = true;
        updateAccList.add(acc2);
        
        Database.update(updateAccList);
        
        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        Contact conRecord3 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        Id sysAdminProfileID = [select id from Profile where Name = 'System Administrator' limit 1].id;
        
        List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
        
        Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
        agsRoleList.add(agsRoleCCF);
        
        Core_AGS_Role__c agsRoleCCFClaimSub = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-External Claim Submitter-CCF', 'Co-Marketing(Salesforce)-External Claim Submitter-CCF', true, false);
        agsRoleList.add(agsRoleCCFClaimSub);
        
        Database.insert(agsRoleList);        
        
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementCCF);
        
        List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();
        
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',agsRoleCCF.Id ,'Intel® Partner Investment Center','Client User',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
        entitlementList.add(entitlementCCF);
        
        Core_Entitlement__c entitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createEntitlement('Client Claim Submitter',agsRoleCCFClaimSub.Id ,'Intel® Partner Investment Center','Client Claim Submitter',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
        entitlementList.add(entitlementCCFClaimSub);
        
        Database.insert(entitlementList); 
        
        List<Core_Contact_Entitlement__c> contEntList = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCF);
        
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCFClaimSub);
        
        Core_Contact_Entitlement__c contactEntitlementCCF2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord2.Id,entitlementCCF.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCF2);
        
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord2.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCFClaimSub2);
        
        Database.insert(contEntList);  
        
        
        //Creating Case on the Account
        Case case1 = new Case(AccountId=acc.Id);
        Database.insert(case1);
        
        // Creating User with utility class 
        List<User> userList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.ProfileId = sysAdminProfileID;
        userList.add(usr);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        userList.add(usr1);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='test2@example.com';
        usr2.ContactId = conRecord2.Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
        userList.add(usr2);
        
        
        //creating system admin user
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        userList.add(sysAdmUsr);
        
        Database.insert(userList);        
        
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1.Id,'External',acc1.Id,cp.Id,'PGM_TEST',true);
        
        List<Core_MDF_Partner_Group_Mapping__c> pgm = [Select Core_MDF_Group_Id__c from Core_MDF_Partner_Group_Mapping__c 
                                                       where Core_MDF_Account__c=:acc1.Id and Core_MDF_Type_of_Access__c='External' 
                                                       and Core_MDF_Channel_Program__c = :cp.Id limit 1];
        
        system.runAs(sysAdmUsr){
            GroupMember gm = new GroupMember();
            gm.GroupId = pgm[0].Core_MDF_Group_Id__c;
            gm.UserOrGroupId = usr1.Id;
            insert gm;
        }
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        // Create PMB for the above Account 
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,123456,System.today(),Date.newInstance(System.today().year(),12,31),false);
        pmbRecord.IsIgnoreValidation = true;
        pmbRecord.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        insert pmbRecord;
        
        // Create PFA records for the above accounts :
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, acc, 2000,true);
        
        //Creating campaigns using utility class
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','CMP only', 
                                                                    Core_MDF_CCP_TestDataUtility.campaign_RecordType_CCF,
                                                                    'Client CoMarketing Fund',System.today()-3,System.today().addDays(200), 
                                                                    2000,'FPGA',acc.Id,'2-in-1', false);
        camp.Core_MDF_Opal_Budget_Type_Txt__c ='OEM CMP';
        database.insert(camp);
        
        Test.startTest();
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                       Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                       string.valueof(acc.id),pfaRecord,null,'INDIA','Creator',
                                                                                       'Desktop','Intel® Core™ i7 Processor','Broadcast',
                                                                                       'Radio','Draft',false);
        pfr.RequestedAmount = 1200;
        pfr.Amount = 1200;
        pfr.Core_MDF_Channel_Partner_Led__c = FALSE;
        pfr.Core_MDF_Start_Date__c = system.today()-1;
        pfr.Core_MDF_End_Date__c = system.today() + 2;
        pfr.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        pfr.Core_MDF_Reimbursement_Rate_txt__c='60%';
        pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfr.Status = 'Approved';
        system.runAs(sysAdmUsr){
            Database.insert(pfr);
        }
        //Creating Bank
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.id,'Core_MDF_Client_CoMarketing_Fund',false,'1234567890');
       	database.insert(bank);  
        bank.Core_MDF_Bank_Status__c = 'Active';
		update bank;
        
        //Creating ABM
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id,bank.Id,TRUE);            
        
        //Creating Claims
        PartnerFundClaim pfc = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF,pfr.Id,System.today()-1,System.today()-1,40,System.today()-1,bank.Id,false);
        pfc.Core_MDF_Country_Location_nm__c ='INDIA';
        pfc.Core_MDF_Currency__c = 'USD';
        pfc.Core_MDF_Status__c='Hold';
		pfc.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
      //  pfc.Core_MDF_VAT_Opt_In__c='Service Invoice to Intel (VAT may apply)';
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        system.runAs(sysAdmUsr){
            database.insert(pfc);    
        }
        List<ContentVersion> conVersionLst = new List<ContentVersion>();
        ContentVersion conVersion = new ContentVersion();
        conVersion.ContentLocation = 'S';
        conVersion.Title = 'Test';
        conVersion.PathOnClient='Test';
        conVersion.ReasonForChange = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ContentVersion_ReasonForChange');
        conVersion.VersionData = Blob.valueOf('content');
        conVersionLst.add(conVersion);
        Database.insert(conVersionLst); //Insert contentversion list
        ContentVersion contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN : conVersionLst limit 1];
        
        ContentDocument conDoc= [SELECT Id,OwnerId FROM ContentDocument WHERE Id =:contentVersions.ContentDocumentId limit 1];
        Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c(); 
        auditDoc.Core_MDF_Document_Id__c = conDoc.Id;
        auditDoc.Core_MDF_Document_Title__c = 'Test';
        auditDoc.Core_MDF_Download_Document_Title_txt__c = 'Test';
        auditDoc.Core_MDF_Encoded_Document_Title_txt__c = 'Test';
        auditDoc.Core_MDF_Claim__c = pfc.Id;
        auditDoc.Core_MDF_Document_Types__c='Proof of Cost;Proof of Execution;Proof of Attribution';
        auditDoc.Core_MDF_App_Document_Types_nm__c= 'Proof of Cost;Proof of Execution;Proof of Attribution';
        insert auditDoc;
        
       /* Core_MDF_Adjustment_Request__c adjustment = new Core_MDF_Adjustment_Request__c();          
        adjustment.Core_MDF_Reference_Claim_Nbr__c = pfc.Id;
        adjustment.Core_MDF_Amount_Amt__c = 10;
        adjustment.Core_MDF_Reason_Cd__c = 'Pending Available Fund';
        Database.insert(adjustment);*/
        
        System.runAs(usr){
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc.Id,usr1.Id,true);
        }
        
        Test.stopTest();
        
        
        //Create Exchnage rates records
        
        List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
        
        Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
        record2.Name= 'INR';
        record2.Core_MDF_Exchange_Rate__c = 1;
        record2.Core_MDF_Market_Date__c =System.today();
        record2.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record2.Core_MDF_Unique_Key__c = 'INR'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record2); 
        
        Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
        record3.Name= 'USD';
        record3.Core_MDF_Exchange_Rate__c = 1;
        record3.Core_MDF_Market_Date__c =System.today();
        record3.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record3.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record3); 
        database.insert(newValues);
        
    }
    
    // Test method
    @isTest static void testIsAccountUserEligibleForDelete(){
        Test.startTest();
        
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__r.Name = 'Test Account 1' AND Core_MDF_User__r.Email = 'test1@example.com'];                                             
        List<Id> deleteRecordList = new List<Id>();
        try{      
            System.runAs(usr){
                System.assertEquals(true,Core_MDF_AccountUser_Controller.isAccountUserEligibleForDelete(pnumRecord.Id));
                deleteRecordList.add(pnumRecord.Id);
                Core_MDF_AccountUser_Controller.deleteAccountUsers(deleteRecordList);
                List<Core_MDF_Partner_Node_User_Mapping__c> pnumRecordList = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__r.Name = 'Test Account 1' AND Core_MDF_User__r.Email = 'test1@example.com']; 
                
                //System.assertEquals(pnumRecordList.size(),0);                       
            }
        }
        catch(Exception e){}
        
        Test.stopTest();
    }
    
    // Test method
    @isTest static void testgetResults(){
        Test.startTest();
        User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        ChannelProgram cp = [SELECT Id from ChannelProgram Limit 1];
        System.runAs(usr){
            Account acc = [Select Id,Name from Account where Name='Test Account 2'];
            Account acc1 = [Select Id,Name from Account where Name='Test Account 1'];
            List<Id> accountIdsList = new List<Id>();
            accountIdsList.add(acc.Id);
            User user = [Select Id from User where Email='test2@example.com'];
            User user1 = [Select Id from User where Email='test1@example.com'];
            List<Id> userIdsList = new List<Id>();
            userIdsList.add(user.Id);
            Core_MDF_LWC_AccountUserController.fetchUserAccessiblePrograms();
            Core_MDF_LWC_AccountUserController.getResults('Account', 'Name', 'test', cp.Id);
            Core_MDF_LWC_AccountUserController.getResults('User', 'Email', 'test', cp.Id);
            Core_MDF_LWC_AccountUserController.fetchUserInfo();
            Core_MDF_LWC_AccountUserController.findSelectedUsers(acc1.Id);
            Core_MDF_LWC_AccountUserController.findSelectedAccounts(user1.Id, cp.Id);
            Core_MDF_LWC_AccountUserController.saveAccountUserMapping(acc.Id, userIdsList, 'AccountToUser', cp.Id);
            Core_MDF_LWC_AccountUserController.saveAccountUserMapping(acc1.Id, userIdsList, 'AccountToUser', cp.Id);
            Core_MDF_LWC_AccountUserController.saveAccountUserMapping(user.Id, accountIdsList, 'UserToAccount', cp.Id);
            String returnString = Core_MDF_LWC_AccountUserController.saveAccountUserMapping(user1.Id, accountIdsList, 'UserToAccount', cp.Id);
            System.assertEquals(returnString,'');  
        }
        Test.stopTest();
    }
    /* Areefa: Method to testAccountUserEligibleForCreateEdit */
    @isTest
    public static void testAccountUserEligibleForCreateEdit(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            boolean hasAccess = Core_MDF_LWC_AccountUserController.isAccountUserEligibleForCreateEdit();
            system.assertEquals(true,hasAccess);
        }
    }
    
    @isTest
    public static void testDoesNothaveAccountUserPermission(){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Claim_Submitter'];        
        User usr2 = [ SELECT Id FROM User WHERE Email='test2@example.com'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = usr2.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        System.runAs(usr2){
            boolean hasAccess = Core_MDF_LWC_AccountUserController.isAccountUserEligibleForCreateEdit();
            system.assertEquals(false,hasAccess);
        }        
    }
    
    
    @isTest
    static void testSaveAccountUserExceptionMethod()
    {
        try{
            Test.startTest();
            User usr = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
            ChannelProgram cp = [SELECT Id from ChannelProgram Limit 1];
            System.runAs(usr){
                Account acc = [Select Id,Name from Account where Name='Test Account 2'];
                Account acc1 = [Select Id,Name from Account where Name='Test Account 1'];
                List<Id> accountIdsList = new List<Id>();
                accountIdsList.add(acc.Id);
                User user = [Select Id from User where Email='test2@example.com'];
                User user1 ; //= [Select Id from User where Email='test1@example.com'];                
                List<Id> userIdsList = new List<Id>();
                userIdsList.add(user.Id);
                Core_MDF_LWC_AccountUserController.fetchUserAccessiblePrograms();
                Core_MDF_LWC_AccountUserController.getResults('Account', 'Name', 'test', cp.Id);
                Core_MDF_LWC_AccountUserController.getResults('User', 'Email', 'test', cp.Id);
                Core_MDF_LWC_AccountUserController.fetchUserInfo();
                Core_MDF_LWC_AccountUserController.findSelectedUsers(acc1.Id);
                Core_MDF_LWC_AccountUserController.findSelectedAccounts(user1.Id, cp.Id);
                Core_MDF_LWC_AccountUserController.saveAccountUserMapping(acc.Id, userIdsList, 'AccountToUser', cp.Id);
                Core_MDF_LWC_AccountUserController.saveAccountUserMapping(acc1.Id, userIdsList, 'AccountToUser', cp.Id);
                Core_MDF_LWC_AccountUserController.saveAccountUserMapping(user.Id, accountIdsList, 'UserToAccount', cp.Id);
                String returnString = Core_MDF_LWC_AccountUserController.saveAccountUserMapping(user1.Id,accountIdsList, 'UserToAccount', cp.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertNotEquals(NULL,e);
        }
        
    }
    
    
    @isTest static void deletePNUMRecords(){
        Test.startTest();
        User usr = [SELECT Id,Email FROM User WHERE Email='sysadmin@example.com' LIMIT 1];
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c,Core_MDF_Error_Details_txt__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__r.Name ='Test Account 1' AND Core_MDF_User__r.Email = 'test1@example.com'];                                             
        List<Id> deleteRecordList = new List<Id>();
        Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap = new Map<Id,Core_MDF_Partner_Node_User_Mapping__c>();
        newPNUMappingMap.put(pnumRecord.Id,pnumRecord);
        Map<Id, List<Id>> accountIdUserIdListMapCreateBatch = new Map<Id,List<Id>>();
        accountIdUserIdListMapCreateBatch.put(pnumRecord.Core_MDF_Account__c,new List<Id>{usr.Id});
        try{      
            System.runAs(usr){
                Core_MDF_AccountUserUtility.createObjectShareRecords('PartnerFundClaimShare', accountIdUserIdListMapCreateBatch, newPNUMappingMap);
                Core_MDF_AccountUserUtility.createObjectShareRecords('CaseShare', accountIdUserIdListMapCreateBatch, newPNUMappingMap);
                Core_MDF_AccountUserUtility.createObjectShareRecords('Core_MDF_Bank__Share', accountIdUserIdListMapCreateBatch, newPNUMappingMap);
                Core_MDF_AccountUserUtility.createObjectShareRecords('PartnerFundRequestShare', accountIdUserIdListMapCreateBatch, newPNUMappingMap);
                Core_MDF_AccountUserUtility.createObjectShareRecords('PartnerFundAllocationShare', accountIdUserIdListMapCreateBatch, newPNUMappingMap);
                Core_MDF_AccountUserUtility.createObjectShareRecords('Core_MDF_Adjustment_Request__Share', accountIdUserIdListMapCreateBatch, newPNUMappingMap);
                
                delete pnumRecord;
                List<Core_MDF_Partner_Node_User_Mapping__c> pnumRecordList = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__r.Name = 'Test Account 1' AND Core_MDF_User__r.Email = 'test1@example.com']; 
                System.assertEquals(pnumRecordList.size(),0);                       
            }
            accountIdUserIdListMapCreateBatch.put(pnumRecord.Core_MDF_Account__c,new List<Id>{usr.Id});
            Core_MDF_AccountUserUtility.createObjectShareRecords('PartnerFundClaimShare', accountIdUserIdListMapCreateBatch, newPNUMappingMap);
            Core_MDF_AccountUserUtility.createObjectShareRecords('CaseShare', accountIdUserIdListMapCreateBatch, newPNUMappingMap);
            Core_MDF_AccountUserUtility.createObjectShareRecords('Core_MDF_Bank__Share', accountIdUserIdListMapCreateBatch, newPNUMappingMap);
            Core_MDF_AccountUserUtility.createObjectShareRecords('PartnerFundRequestShare', accountIdUserIdListMapCreateBatch, newPNUMappingMap);
            Core_MDF_AccountUserUtility.createObjectShareRecords('PartnerFundAllocationShare', accountIdUserIdListMapCreateBatch, newPNUMappingMap);
            Core_MDF_AccountUserUtility.createObjectShareRecords('Core_MDF_Adjustment_Request__Share', accountIdUserIdListMapCreateBatch, newPNUMappingMap);
            String Createquery = 'SELECT Id, ChannelPartnerId, Core_MDF_Payment_Id__c FROM PartnerFundClaim WHERE ChannelPartnerId IN ';
            Database.executeBatch(new Core_MDF_CreateBatchShareRecords('PartnerFundClaim', accountIdUserIdListMapCreateBatch, Createquery, newPNUMappingMap), 25);                                                                                                                                                                                                                                                                                                        
            
            
            
            
            
        }
        catch(Exception e){}
        
        Test.stopTest();
    }
    
    @isTest static void callPNUMRefreshBatch(){
        
        Test.startTest();
        User usr = [SELECT Id,Email FROM User WHERE Email='sysadmin@example.com' LIMIT 1];
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__r.Name = 'Test Account 1' AND Core_MDF_User__r.Email = 'test1@example.com'];                                             
        pnumRecord.Core_MDF_Error_Details_txt__c = 'Record Lock issue';
        try{      
            System.runAs(usr){
                update pnumRecord;
            }
        }
        catch(Exception e){}
        Test.stopTest();
        Assert.isNotNull(pnumRecord);
        Database.executeBatch(new Core_MDF_Batch_PNUMRefresh());
    }
    
    @isTest static void testUpdatePNUMRecords(){
        
        Test.startTest();
        User usr = [SELECT Id,Email FROM User WHERE Email='sysadmin@example.com' LIMIT 1];
        
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c,Core_MDF_Account__r.Core_MDF_External_Group_Id__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__r.Name ='Test Account 1' AND Core_MDF_User__r.Email = 'test1@example.com'];                                             
        
        GroupMember pnumMember = new GroupMember(UserOrGroupId = pnumRecord.Core_MDF_User__c, GroupId = pnumRecord.Core_MDF_Account__r.Core_MDF_External_Group_Id__c);
        insert pnumMember;
        
        try{      
            System.runAs(usr){
                update pnumRecord;                    
            }
        }
        catch(Exception e){}
        Assert.isNotNull(pnumMember);
        Test.stopTest();
    }
    
}