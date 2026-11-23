@isTest(SeeAllData=false)
public class Core_MDF_SubscriptionUtility_Test {
    @TestSetup static void setUpData(){ 
        

         Map<String,Id> profileToId = new Map<String,Id>();
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','Partner','CCP - Core Access')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        //User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        User usr2 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                                 UserPermissionsMarketingUser = TRUE);  
        usr2.Email='testPayment@intel.com';
        usr2.LastName='ProgAdmUser';
        usr2.profileId = profileToId.get('System Administrator');
        usr2.IsActive = true;
        Insert usr2;
       // Highlight: Unused Local Variable - Indira
      //  User usr = [Select ID from User where Email ='testPayment@intel.com' Limit 1];
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_CSC_Claim_Submitter' LIMIT 1];
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Generic_Access' LIMIT 1];
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_L3_Maintenance' LIMIT 1];
        
        Insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = ps.Id);
        Insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = ps1.Id);
        Insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = ps2.Id);
        
    }
    @isTest static void testSubscriptionMethods(){
        User usr = [Select ID from User where Email ='testPayment@intel.com' Limit 1];
            List<Core_MDF_SubUnsub_Notifications_Utility.subsUnsubsDataWrapper> wrapperList = new List<Core_MDF_SubUnsub_Notifications_Utility.subsUnsubsDataWrapper>();
            Core_MDF_SubUnsub_Notifications_Utility.subsUnsubsDataWrapper wrapper = new Core_MDF_SubUnsub_Notifications_Utility.subsUnsubsDataWrapper();
            wrapper.objectName ='PFC - PartnerFundClaim';
            wrapper.notificationName ='PFC_PIC_FAIL_RESUB_REQ';
            wrapper.response = false;
            //wrapper.subsRecId ='a6aDz000000LanyIAC';
         
            //Core_MDF_SubUnsub_Notifications_Utility.addOrRemoveUserSubscriptionRecord(wrapperList);
            //String str=  '{"objectName":"PFR - PartnerFundRequest","notificationName":"PFR_ACT_APP_REQ","response":false,"subsRecId":"a6aDz000000LamvIAC"}';
            //List<String> subsUnsubsData = new List<String>();
            //subsUnsubsData.add(str);  
            wrapperList.add(wrapper);
            Core_MDF_SubUnsub_Notifications_Utility.addOrRemoveUserSubscriptionRecord(wrapperList);
            
        system.runAS(usr) {
             Core_MDF_Subscription_Notification_Type__c  sub = new Core_MDF_Subscription_Notification_Type__c ();
            sub.Core_MDF_Active_Ind__c = true;
            sub.Core_MDF_Project_Application_nm__c = 'Co-Marketing Platform';
            sub.Core_MDF_Object_API_nm__c = 'PFC - PartnerFundClaim';
            sub.Core_MDF_Object_Label_txt__c = 'Claim';
            sub.Core_MDF_Notification_Type_API_nm__c ='PFC_WKLY_EMAIL_PAID_CLMS';
            sub.Core_MDF_Notification_Type_Label_txt__c = 'Weekly email for the paid claims';
            sub.Core_MDF_Help_Text_txt__c = 'Test';
            sub.Core_MDF_Applicable_PermissionSets_nm__c ='Core_MDF_CCP_CSC_Claim_Submitter';
            sub.Core_MDF_Mandate_PermissionSets_nm__c   = 'Core_MDF_CCP_CSC_Claim_Submitter';
            sub.Core_MDF_Mandate_Profiles_nm__c   = 'System Administrator';
            
            Insert sub;
        
            List<Core_MDF_SubUnsub_Notifications_Utility.notificationData> finalWrapperList = new List<Core_MDF_SubUnsub_Notifications_Utility.notificationData>();
            finalWrapperList = Core_MDF_SubUnsub_Notifications_Utility.getSubscriptionDetails(usr.id,'Co-Marketing Platform');
            assert.areNotEqual(finalWrapperList, null);
       
            
        }
 
        
    }
    
    @isTest static void testFilterUserBasedOnSubscription(){ 
        User usr = [Select ID from User where Email ='testPayment@intel.com' Limit 1];
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(True);
       // List<Id> userIdLst = new List<Id>();
        List<Id> userIdLst = new List<Id>{usr.Id,usr2.Id};
        Set<Id> userIdSet = new Set<Id>(userIdLst);
          Core_MDF_Subscription_Notification_Type__c  sub = new Core_MDF_Subscription_Notification_Type__c ();
        sub.Core_MDF_Active_Ind__c = true;
        sub.Core_MDF_Project_Application_nm__c = 'Co-Marketing Platform';
        sub.Core_MDF_Object_API_nm__c = 'PFC - PartnerFundClaim';
        sub.Core_MDF_Object_Label_txt__c = 'Claim';
        sub.Core_MDF_Notification_Type_API_nm__c ='PFC_WKLY_EMAIL_PAID_CLMS';
        sub.Core_MDF_Notification_Type_Label_txt__c = 'Weekly email for the paid claims';
        sub.Core_MDF_Help_Text_txt__c = 'Test';
        sub.Core_MDF_Applicable_PermissionSets_nm__c ='Core_MDF_CCP_CSC_Claim_Submitter';
        sub.Core_MDF_Mandate_PermissionSets_nm__c   = 'Core_MDF_CCP_CSC_Claim_Submitter';
        sub.Core_MDF_Mandate_Profiles_nm__c   = 'System Administrator';
            
       Insert sub;
   
        
        Pricing_IQR_Email_Preferences__c emailPref = new Pricing_IQR_Email_Preferences__c();
        emailPref.Core_MDF_Module_Nm__c = 'PFC - PartnerFundClaim';
        emailPref.Pricing_Notification_Name_Nm__c = 'PFC_PIC_FAIL_RESUB_REQ';
        emailPref.Pricing_User__c = usr.Id;
        emailPref.Core_MDF_Subscription_Notification_Type__c = sub.Id;
        
        insert emailPref;
        Test.startTest();
        List<Id> excludedUserIdSet = Core_MDF_SubUnsub_Notifications_Utility.filterUserBasedOnSubscription(emailPref.Pricing_Notification_Name_Nm__c,emailPref.Core_MDF_Module_Nm__c,userIdSet);
        assert.areNotEqual(excludedUserIdSet, null);
        Test.stopTest();
        
    }
    @isTest static void testGetUserList() {
        
        List<Core_MDF_SubUnsub_Notifications_Utility.SObjectResult> userResult = Core_MDF_SubUnsub_Notifications_Utility.getUserList('ProgAdmUser','Co-Marketing Platform');
        assert.areNotEqual(userResult, null);
    }
    
    @isTest static void checkEmulationAccessAndGetAppList() {
        Core_MDF_SubUnsub_Notifications_Utility.EmulationWrapper emulationWrapper = Core_MDF_SubUnsub_Notifications_Utility.checkEmulationAccessAndGetAppList();
        assert.areNotEqual(emulationWrapper, null);
    }
    
    @isTest static void checkUserExclusion(){    
        
        Test.startTest();
        User usr = [Select ID from User where Email ='testPayment@intel.com' Limit 1];
        Core_MDF_Subscription_Notification_Type__c  sub = new Core_MDF_Subscription_Notification_Type__c ();
        sub.Core_MDF_Active_Ind__c = true;
        sub.Core_MDF_Project_Application_nm__c = 'Co-Marketing Platform';
        sub.Core_MDF_Object_API_nm__c = 'PFC - PartnerFundClaim';
        sub.Core_MDF_Object_Label_txt__c = 'Claim';
        sub.Core_MDF_Notification_Type_API_nm__c ='PFC_PIC_FAIL_RESUB_REQ';
        sub.Core_MDF_Notification_Type_Label_txt__c = 'Weekly email for the paid claims';
        sub.Core_MDF_Help_Text_txt__c = 'Test';
        sub.Core_MDF_Applicable_PermissionSets_nm__c ='Core_MDF_CCP_CSC_Claim_Submitter';
        sub.Core_MDF_Mandate_PermissionSets_nm__c   = 'Core_MDF_CCP_CSC_Claim_Submitter';
        sub.Core_MDF_Mandate_Profiles_nm__c   = 'System Administrator';
            
       Insert sub;
        
        Pricing_IQR_Email_Preferences__c emailPref = new Pricing_IQR_Email_Preferences__c();
        emailPref.Core_MDF_Module_Nm__c = 'PFC - PartnerFundClaim';
        emailPref.Pricing_Notification_Name_Nm__c = 'PFC_PIC_FAIL_RESUB_REQ';
        emailPref.Pricing_User__c = usr.Id;
        emailPref.Pricing_Opt_In_Ind__c = false;
        emailPref.Core_MDF_Subscription_Notification_Type__c = sub.id;
        
        insert emailPref;
        
         List<Core_MDF_SubUnsub_Notifications_Utility.MailParams> mailParamsWrapperList = new List<Core_MDF_SubUnsub_Notifications_Utility.MailParams>();
          //Create object and notification type list
           String claimObjForEmailPreferences = 'PFC - PartnerFundClaim';
           String notificationType =  'PFC_PIC_FAIL_RESUB_REQ';    
           
           List<String> notificationTypeList = new List<String>{notificationType};
           
           List<String> objectTypeList = new List<String>{claimObjForEmailPreferences};
           
           //Create Subscription mailparams wrapper
           Core_MDF_SubUnsub_Notifications_Utility.MailParams paramsWrapper= new  Core_MDF_SubUnsub_Notifications_Utility.MailParams();
           paramsWrapper.notificationName = notificationTypeList ;
           paramsWrapper.objectName = objectTypeList;

           mailParamsWrapperList.add(paramsWrapper);
           
           //Call Subscription utility class to get excluded users Id list. //change below var name like excluded user list
        List<List<Core_MDF_FlowMapClass>> finalFlowMapList = Core_MDF_SubUnsub_Notifications_Utility.getExcludedUserList(mailParamsWrapperList);
        assert.areNotEqual(finalFlowMapList, null);
        Test.stopTest();
             
    }
    
}