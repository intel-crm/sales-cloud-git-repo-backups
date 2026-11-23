@isTest(SeeAllData=false)
private class Core_MDF_SchNotificationHandler_Test {
         private static Id IPA_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
     private static Id CMDF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Channel_MDF').getRecordTypeId();
     private static Id RMF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
     private static Id EEF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
    @TestSetup static void createTestData() {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];                
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        System.runAs(usr){  
            Test.startTest();
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Update_Validation');
            bypassFunctionKeys.add('BypassRetailMDFBudgetValidation');
            bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
			bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
			bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            // Creating channel program with utility class
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            Channelprogram cpIPA = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            
            
            // Creating Intel Account for retail program
            List<Account> accIntelList = new List<Account>();          
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1Retail.Core_Account_Type__c = 'Reseller';
            acc1Retail.Industry = 'Food & Beverage';
            acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
            acc1Retail.Core_Geo__c = 'APJ';   
            acc1Retail.Core_Sub_Geo__c = 'ANZ';
            acc1Retail.BillingStateCode = '';
            acc1Retail.BillingCountryCode = '';
            accIntelList.add(acc1Retail);          
            Database.insert(accIntelList);
            
            // Creating Retail Account with utility class
            List<Account> accCoMarketingList = new List<Account>();         
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'APJ';
            accRetail.Core_Sub_Geo__c = 'ANZ';
            accCoMarketingList.add(accRetail);
            
            Account accRetail2 = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail2', cpRetail.Id,
                                                                             Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail2.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail2.Core_Geo__c = 'APJ';
            accRetail2.Core_Sub_Geo__c = 'ANZ';
            accCoMarketingList.add(accRetail2);
            
            // Creating IPA Account with Utility Class
            Account accIPA = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test IPA Account', cpIPA.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1Retail.Id, false);
            accCoMarketingList.add(accIPA);
            Database.insert(accCoMarketingList);
            
            //Creating External User for PNUM
            List<Contact> contactList = new List<Contact>();
            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact(acc1Retail.Id, false);
            contactList.add(con1);
            Contact con2 = Core_MDF_CCP_TestDataUtility.createContact(acc1Retail.Id, false);
            con2.Core_Audience_List__c = 'IPA User';
            contactList.add(con2);
            Database.insert(contactList);
            List<User> userExternalList = new List<User>();   
            Id partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
            User usrExt1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrExt1.Email='testexternaluser1@example.com';
            usrExt1.ProfileId = partnerProfile;
            usrExt1.isActive = true;
            usrExt1.ContactId = con1.id;
            userExternalList.add(usrExt1);
            User usrExt2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrExt2.Email='testexternaluser2@example.com';
            usrExt2.ProfileId = partnerProfile;
            usrExt2.isActive = true;
            usrExt2.ContactId = con2.Id;
            userExternalList.add(usrExt2);         
            Database.insert(userExternalList);
            List<User> userInternalList = new List<User>();         
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            User usrInt1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrInt1.Email='testinternaluser1@example.com';
            usrInt1.ProfileId = ccpCoreProfile.id;
            usrInt1.isActive = true;
            userInternalList.add(usrInt1);
            User usrInt2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrInt2.Email='testinternaluser2@example.com';
            usrInt2.ProfileId = ccpCoreProfile.id;
            usrInt2.isActive = true;
            userInternalList.add(usrInt2);
            Database.insert(userInternalList);
            Set<String> psNameSet = new Set<String> ();
            Map<string,String>  psNameVsIdMap = new Map<string,String>();
            psNameSet.add('Core_MDF_CCP_Internal_Retail_Account_Manager');
            psNameSet.add('Core_MDF_CCP_External_Activity_Approver');
            psNameSet.add('Core_MDF_CCP_Internal_IPA_Acct_Mgr');
            psNameSet.add('Core_MDF_CCP_External_IPA_Proposal_Manager');
            psNameVsIdMap = getPermissionSetIdbyName(psNameSet);
            String rmfMgr =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Retail_Account_Manager');
            String rmfExtAct =  psNameVsIdMap.get('Core_MDF_CCP_External_Activity_Approver');
            String ipaMgr =  psNameVsIdMap.get('Core_MDF_CCP_Internal_IPA_Acct_Mgr');
            String ipaProp =  psNameVsIdMap.get('Core_MDF_CCP_External_IPA_Proposal_Manager');
             List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            permissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = usrInt1.id, PermissionSetId =rmfMgr));   
            permissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = usrInt2.id, PermissionSetId =ipaMgr));
            permissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = usrExt1.id, PermissionSetId =rmfExtAct));
            permissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = usrExt2.id, PermissionSetId =ipaProp));
            
            Database.insert(permissionSetAssignmentList);
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name ='RPS_Retailer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='RPS_Retailer');
            insert cee;
			List< Core_Entitlement__c> entListVal = new List< Core_Entitlement__c>();
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='RMF User', Core_Category__c='Intel® Partner Investment Center',Core_Sub_Category__c='Web Order Management (WOM)',
                                                                 Core_Help_Text__c='Help text', Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test',Core_IsActive__c=true,
                                                                 Core_Permission_Set_API_Nm__c='Core_MDF_Retail_USER');
            
            entListVal.add(entitle);
            insert entListVal;
            List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con1.Id,
                                                                             Core_Entitlement_Id__c=entitle.id,
                                                                             Core_Selected__c=false);
             ceList.add(ce); 
            Database.insert(ceList);
            
            Group ccfAPJGrp1 = new Group();
            ccfAPJGrp1.Name = 'Core_MDF_Ext_CCF_APJ';
            ccfAPJGrp1.DeveloperName = 'Core_MDF_Ext_CCF_APJ';
            Database.insert(ccfAPJGrp1);
            
            GroupMember ccfGrpMem1 = new GroupMember();
            ccfGrpMem1.UserOrGroupId = usrExt1.Id;
            ccfGrpMem1.GroupId = ccfAPJGrp1.Id;
            Database.insert(ccfGrpMem1);
            Group ccfAPJGrp2 = new Group();
            ccfAPJGrp2.Name = 'Core_MDF_Ext_IPA_APJ';
            ccfAPJGrp2.DeveloperName = 'Core_MDF_Ext_IPA_APJ';
            Database.insert(ccfAPJGrp2);
             GroupMember ccfGrpMem2 = new GroupMember();
            ccfGrpMem2.UserOrGroupId = usrExt2.Id;
            ccfGrpMem2.GroupId = ccfAPJGrp2.Id;
            Database.insert(ccfGrpMem2);
             Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accRetail.Id,usrExt1.Id,true);  
            //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accIPA.Id, usrExt2.Id, true);
                                      
            //Creating IUPGM for Retail & IPA Account Manager
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            Core_MDF_Int_Users_Partner_Geo_Mapping__c rmfiupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            rmfiupgm.Core_MDF_Account_id__c = accRetail.Id;
            rmfiupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
            rmfiupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
            rmfiupgm.Core_MDF_User_id__c = usrInt1.Id;
            rmfiupgm.Core_MDF_All_Accounts_cd__c = 'No';
            rmfiupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Retail_Account_Manager';
             rmfiupgm.RecordTypeId=RMF_RecordType;
            iupgmList.add(rmfiupgm);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c ipaiupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            ipaiupgm.Core_MDF_Account_id__c = acc1Retail.Id;
            ipaiupgm.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            ipaiupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            ipaiupgm.Core_MDF_User_id__c = usrInt2.Id;
            ipaiupgm.Core_MDF_All_Accounts_cd__c = 'No';
            ipaiupgm.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_IPA_Acct_Mgr';
            ipaiupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Data Centric Acceleration - MDF;APJ->Data Centric Acceleration - MDF';
            ipaiupgm.RecordTypeId=IPA_RecordType;
            iupgmList.add(ipaiupgm);
            Database.insert(iupgmList);
            List<Campaign> campList = new List<Campaign>();
            Campaign campRmf = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(-3), 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', false); 
            campList.add(campRmf);
            Campaign campIpa = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',accIPA.id, System.today(), System.today().adddays(30),null, 
                                                                                           110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', false);
            campIpa.Core_MDF_Region_cd__c = 'APJ';
            campIpa.Core_MDF_Opal_Budget_Type_Txt__c ='Account Plan';
            campIpa.Core_MDF_Proposal_Based_Ind__c = false;
            campIpa.Core_MDF_Budget_Type_txt__c = 'Account Plan';
            campIpa.Status ='Planned' ;
            campList.add(campIpa);
            Database.insert(campList);
            list<PartnerFundRequest> pfrList = new list<PartnerFundRequest>();
             PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(campRmf.Id),string.valueof(accRetail.id),System.today(),System.today(),false); 
        pfr.Title ='Retail RSA MD Activity';
        pfr.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        pfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
        pfr.RequestedAmount =1000;
        pfr.Amount=1000;
        pfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
        pfr.Core_MDF_Budget_Currency_cd__c ='USD';
        pfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
        pfr.Core_MDF_ToBeClosedDate__c = System.today()+60;
          	PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(campIpa.id,accIPA.id,System.today().addDays(1),System.today().addDays(10),false);
            ipaPFR.Title='IPA Account Plan Activity';
            ipaPFR.Core_MDF_ToBeClosedDate__c = system.today() + 30 ;
            ipaPFR.Core_MDF_Fund_Request_Status__c ='Planned';
            ipaPFR.Core_MDF_Region_nm__c='APJ';
            pfrList.add(ipaPFR);
            Database.insert(pfrList);
            Test.stoptest();
        }
    }  
    static Map<string,String> getPermissionSetIdbyName(Set<String> psNameSet){
        Map<string,String>  resultMap = new Map<string,String>();
        for(permissionSet ps: [SELECT Id , Name
                               FROM PermissionSet
                               WHERE Name IN:psNameSet]){
             resultMap.put(ps.Name, ps.Id);
            
        }
    	return resultMap;
    }

    
    @isTest
    static void scheduledNotificatonTest(){
        User sysAdm = [SELECT Id FROM User WHERE lastname ='User Test' LIMIT 1];
        System.runAs(sysAdm){
        Test.startTest();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        Map<String, Id> accIDMap = new Map<String, Id>();
        Set<ID> japanRetailerAcctIds = new Set<ID>();
        Set<ID> NonJapanRetaileracctIds = new Set<ID>();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account Retail' LIMIT 1];
       // User user = [SELECT Id FROM User WHERE Email = 'testinternaluser1@example.com'];
        //Campaign cmp = [SELECT Id FROM Campaign WHERE Name = 'TestRetailCamp'];
        PartnerFundRequest pfr = [SELECT id,title,Core_MDF_Activity_Description__c,Core_MDF_Budget_Type_nm__c,RequestedAmount,Amount,
                                  Core_MDF_Country_nm__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Reimbursement_Rate_pct__c,
                                  Core_MDF_ToBeClosedDate__c from partnerfundrequest limit 1];
        /*PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(cmp.Id),string.valueof(acc.id),System.today(),System.today(),false); 
        pfr.Title ='Retail RSA MD Activity';
        pfr.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        pfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
        pfr.RequestedAmount =1000;
        pfr.Amount=1000;
        pfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        pfr.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
        pfr.Core_MDF_Budget_Currency_cd__c ='USD';
        pfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
        pfr.Core_MDF_ToBeClosedDate__c = System.today()+60;*/
         pfrList.add(pfr);
        accIDMap.put('2021-05-02', acc.id);
        accIDMap.put('closeDateJP', acc.id);
        accIDMap.put('closeDateNonJP', acc.id);
        japanRetailerAcctIds.add(acc.id);
        NonJapanRetaileracctIds.add(acc.id);
       // Core_MDF_ScheduledNotificationHandler.notifyRMFUsers(accIDMap, japanRetailerAcctIds, NonJapanRetaileracctIds);
        Test.stopTest();
        System.assertEquals(true, pfr!=null);
        }
    }
    @isTest
    static void scheduledNotificatonTestIpa(){
        User sysAdm = [SELECT Id FROM User WHERE lastname ='User Test' LIMIT 1];
        String notificationType = 'Proposal Approval Request';
        System.runAs(sysAdm){
         Test.startTest();
        Campaign cmp = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign - AP'];
        PartnerFundRequest ipaPFR =[select id,title,Core_MDF_ToBeClosedDate__c,ChannelPartnerId,Core_MDF_Fund_Request_Status__c,
                                       Core_MDF_Region_nm__c,Core_MDF_Ultimate_Account_Id__c,Core_MDF_Program__c from partnerfundrequest where title ='IPA Account Plan Activity' limit 1];
      	Set<ID> acc1 = new Set<ID>();
        acc1.add(ipaPFR.ChannelPartnerId);
        Set<ID> acc2 = new Set<ID>();
        acc2.add(ipaPFR.Core_MDF_Ultimate_Account_Id__c); 
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        pfrList.add(ipaPFR);
        Core_MDF_ScheduledNotificationHandler.notifyIPAUsers(acc1,acc2,pfrList,notificationType);
        System.assertEquals(true, ipaPFR!=null);
            
        Test.stopTest();
        }
    }
    @isTest
    static void getUsersToSendMailTest() {
        User sysAdm = [SELECT Id FROM User WHERE lastname ='User Test' LIMIT 1];
        System.runAs(sysAdm){
            Campaign cmp = [SELECT Id FROM Campaign WHERE Name = 'Test Campaign - AP'];
        	PartnerFundRequest ipaPFR =[select id,title,Core_MDF_ToBeClosedDate__c,ChannelPartnerId,Core_MDF_Fund_Request_Status__c,
                                       Core_MDF_Region_nm__c,Core_MDF_Ultimate_Account_Id__c,Core_MDF_Program__c from partnerfundrequest where title ='IPA Account Plan Activity' limit 1];
            Set<ID> usrId = new Set<ID>();
            usrId.add(sysAdm.id);
            Set<ID> acc1 = new Set<ID>();
        	acc1.add(ipaPFR.ChannelPartnerId);
	        Set<ID> acc2 = new Set<ID>();
        	acc2.add(ipaPFR.Core_MDF_Ultimate_Account_Id__c); 
            Set<string> progSet = new Set<string>();
            progSet.add(ipaPFR.Core_MDF_Program__c);
            Core_MDF_ScheduledNotificationHandler.InputWrapper inputWrap = new Core_MDF_ScheduledNotificationHandler.InputWrapper();
            inputWrap.userId = usrId;
            inputWrap.accountIdSet = acc2;
            inputWrap.progBTSet = progSet;
            InputWrap.channelPartnerIdSet = acc1;
            inputWrap.isNotifyInternalUsers = true;
            Core_MDF_ScheduledNotificationHandler.getUsersToSendMail(inputWrap);
            Core_MDF_ScheduledNotificationHandler.InputWrapper inputWrap1 = new Core_MDF_ScheduledNotificationHandler.InputWrapper();
            inputWrap1.userId = usrId;
            inputWrap1.accountIdSet= acc2;
            inputWrap1.progBTSet = progSet;
            inputWrap1.channelPartnerIdSet = acc1;
            inputWrap1.isNotifyExternalUsers = true;
             Core_MDF_ScheduledNotificationHandler.getUsersToSendMail(inputWrap1);
               System.assertEquals(true, inputWrap1!=null);
        }
    }
}