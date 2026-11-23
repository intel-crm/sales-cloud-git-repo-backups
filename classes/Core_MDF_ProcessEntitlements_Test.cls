@isTest(seeAllData=FALSE)
public class Core_MDF_ProcessEntitlements_Test {
    @isTest static void testProcessEntitlements()
    {
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c validateAdditionToGroup = [select id,Core_Status__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c='CCF USER'];
        validateAdditionToGroup.Core_Status__c = 'Complete';
        
        Core_Contact_Entitlement__c validateDeletionFromGroup = [select id,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c='DCF USER' and Core_Selected__c=true];
        validateDeletionFromGroup.Core_Selected__c = false;

        Core_Contact_Entitlement__c validateMultipleAgency = [select id,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c='RMF USER'];
        validateMultipleAgency.Core_Selected__c = true;

        Core_Contact_Entitlement__c validateAdditionFallout = [select id,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c='CCF BOOST USER'];
        validateAdditionFallout.Core_Selected__c = true;

        Core_Contact_Entitlement__c validateDeletionFallout = [select id,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c='SPCF USER'];
        validateDeletionFallout.Core_Selected__c = false;

        ceList.add(validateAdditionToGroup);ceList.add(validateDeletionFromGroup);ceList.add(validateMultipleAgency);ceList.add(validateAdditionFallout);celist.add(validateDeletionFallout);

        test.startTest();
        Database.update(ceList);  
        test.stopTest(); 
        
        Core_MDF_ProcessEntitlementsSchedulable test = new Core_MDF_ProcessEntitlementsSchedulable();
		test.execute(null);

        List<Core_MDF_UserGroupMapping_Log__c> logrecords= [select id,Core_MDF_Action_nm__c from Core_MDF_UserGroupMapping_Log__c where Core_MDF_Status_nm__c='Action Required'];
        //system.debug('logrecords' +logrecords);
        system.assertEquals(0, logrecords.size());

    }

    @TestSetup
    static void createTestData(){
        
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        // Creating User with utility class 
        User sysAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmin.profileId = sysAdminProfile.Id;
        sysAdmin.UserRoleId = portalRole.Id;
        Database.insert(sysAdmin);

        //List<Core_Trigger_Executions__c> triggerExes = new List<Core_Trigger_Executions__c>();

        System.runAs(sysAdmin)
        { 
            //Create Intel Account
            Account starkAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Stark Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account starkAgencyAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Stark Agency Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account detectiveCAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Detective C Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account marvelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Marvel Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);

            //Create Channel Program
            ChannelProgram ccf = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            ChannelProgram dcf = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
            ChannelProgram ccfb = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund Boost','Client CoMarketing Fund Boost', true);
            ChannelProgram spcf = Core_MDF_CCP_TestDataUtility.createProgram ('Service Provider Co-Marketing Fund','Service Provider CoMarketing Fund', true);
            ChannelProgram rmf = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);

            //Create a Co-Marketing Account
            Account starkCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Stark Co-Marketing Account', dcf.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,starkAccount.id, false);
            starkCoMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c = starkAccount.id;
            Database.insert(starkCoMarketingAccount);  
            
            //Create Contact
            List<Contact> contactList = new List<Contact>();
            Contact starkContact = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='StarkContact',Email='testcontact'+String.valueOf(Math.random())+'@CoreMDF.com',AccountId=starkAccount.Id,Phone='123456798');
            Contact starkAgencyContact = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='StarkAgency',Email='testcontact'+String.valueOf(Math.random())+'@CoreMDF.com',AccountId=starkAgencyAccount.Id,Phone='123456798');      
            contactList.add(starkContact);contactList.add(starkAgencyContact);
            Database.insert(contactList);

            //Create ERPM Engagement
            List<Core_ERPM_Engagement__c> engagementList = new List<Core_ERPM_Engagement__c>();
            Core_ERPM_Engagement__c ccfEngagement = new Core_ERPM_Engagement__c(Name='CCF',Core_Technical_Engagement_Code__c='CCF',Core_Engagement_Type__c='SEC',Core_IsActive__c=true);
            Core_ERPM_Engagement__c dcfEngagement = new Core_ERPM_Engagement__c(Name='DCF',Core_Technical_Engagement_Code__c='DCF',Core_Engagement_Type__c='SEC',Core_IsActive__c=true);
            Core_ERPM_Engagement__c ccfbEngagement = new Core_ERPM_Engagement__c(Name='CCFB',Core_Technical_Engagement_Code__c='CCFB',Core_Engagement_Type__c='SEC',Core_IsActive__c=true);
            Core_ERPM_Engagement__c spcfEngagement = new Core_ERPM_Engagement__c(Name='SPCF',Core_Technical_Engagement_Code__c='SPCF',Core_Engagement_Type__c='SEC',Core_IsActive__c=true);
            Core_ERPM_Engagement__c rmfEngagement = new Core_ERPM_Engagement__c(Name='RMF',Core_Technical_Engagement_Code__c='RMF',Core_Engagement_Type__c='SEC',Core_IsActive__c=true);
            engagementList.add(ccfEngagement); engagementList.add(dcfEngagement);engagementList.add(ccfbEngagement);engagementList.add(spcfEngagement);engagementList.add(rmfEngagement);
            Database.insert(engagementList);

            //Create Entitlement Detail
            List<Core_Entitlement__c> entitlementDetailList = new List<Core_Entitlement__c>();
            Core_Entitlement__c ccfEntitlementDetail = new Core_Entitlement__c(Name='CCF USER',Core_Display_Name__c='CCF USER',Core_ERPM_Engagement_Id__c=ccfEngagement.id,Core_IsActive__c=true);
            Core_Entitlement__c dcfEntitlementDetail = new Core_Entitlement__c(Name='DCF USER',Core_Display_Name__c='DCF USER',Core_ERPM_Engagement_Id__c=dcfEngagement.id,Core_IsActive__c=true);
            Core_Entitlement__c ccfbEntitlementDetail = new Core_Entitlement__c(Name='CCF BOOST USER',Core_Display_Name__c='CCF BOOST USER',Core_ERPM_Engagement_Id__c=ccfbEngagement.id,Core_IsActive__c=true);
            Core_Entitlement__c spcfEntitlementDetail = new Core_Entitlement__c(Name='SPCF USER',Core_Display_Name__c='SPCF USER',Core_ERPM_Engagement_Id__c=spcfEngagement.id,Core_IsActive__c=true);
            Core_Entitlement__c rmfEntitlementDetail = new Core_Entitlement__c(Name='RMF USER',Core_Display_Name__c='RMF USER',Core_ERPM_Engagement_Id__c=rmfEngagement.id,Core_IsActive__c=true);
            entitlementDetailList.add(ccfEntitlementDetail);entitlementDetailList.add(dcfEntitlementDetail);entitlementDetailList.add(ccfbEntitlementDetail); entitlementDetailList.add(spcfEntitlementDetail); entitlementDetailList.add(rmfEntitlementDetail);
            Database.insert(entitlementDetailList);

            //Create Contact Entitlement
            List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c starkCCFCE= new Core_Contact_Entitlement__c(Core_Contact_Id__c=starkContact.id,Core_Entitlement_Id__c=ccfEntitlementDetail.id,Core_Selected__c=true, Core_Status__c='Pending');
            Core_Contact_Entitlement__c starkDCFCE= new Core_Contact_Entitlement__c(Core_Contact_Id__c=starkContact.id,Core_Entitlement_Id__c=dcfEntitlementDetail.id,Core_Selected__c=true, Core_Status__c='Complete');
            Core_Contact_Entitlement__c starkAgencyCE= new Core_Contact_Entitlement__c(Core_Contact_Id__c=starkAgencyContact.id,Core_Entitlement_Id__c=rmfEntitlementDetail.id,Core_Selected__c=false, Core_Status__c='Complete');
            Core_Contact_Entitlement__c starkCCFBCE= new Core_Contact_Entitlement__c(Core_Contact_Id__c=starkContact.id,Core_Entitlement_Id__c=ccfbEntitlementDetail.id,Core_Selected__c=false, Core_Status__c='Complete');
            Core_Contact_Entitlement__c starkSPCFCE= new Core_Contact_Entitlement__c(Core_Contact_Id__c=starkContact.id,Core_Entitlement_Id__c=spcfEntitlementDetail.id,Core_Selected__c=true, Core_Status__c='Complete');
            ceList.add(starkCCFCE);ceList.add(starkDCFCE);
            ceList.add(starkAgencyCE);
            ceList.add(starkCCFBCE);ceList.add(starkSPCFCE);
            Database.insert(ceList);

            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            List<User> userList = new List<User>();
            User starkUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                 	EmailEncodingKey='UTF-8', LastName='Stark'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 	LocaleSidKey='en_US', ProfileId = partnerProfile.Id, ContactId = starkContact.Id,
                                 	TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                                    FirstName='Test',isActive=true);
            
            User starkAgencyUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                 	EmailEncodingKey='UTF-8', LastName='Stark'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 	LocaleSidKey='en_US', ProfileId = partnerProfile.Id, ContactId = starkAgencyContact.Id,
                                 	TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                                    FirstName='Test',isActive=true);

            userList.add(starkUser);userList.add(starkAgencyUser);
            Database.insert(userList);
            
            //Core_MDF_Partner_Node_User_Mapping__c starkPNUM = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(starkCoMarketingAccount.id,starkUser.id, true);

            List<Group> groupList = new List<Group>();
            
            Group starkCCFGroup = new Group();
            starkCCFGroup.Name = 'Stark CCF Group External';
            starkCCFGroup.DeveloperName = 'Core_MDF_Stark_CCF_Group_External';

            Group starkDCFGroup = new Group();
            starkDCFGroup.Name = 'Stark DCF Group External';
            starkDCFGroup.DeveloperName = 'Core_MDF_Stark_DCF_Group_External';
            
            Group marvelRMFGroup = new Group();
            marvelRMFGroup.Name = 'Marvel RMF Group External';
            marvelRMFGroup.DeveloperName = 'Core_MDF_Marvel_RMF_Group_External';
            
            Group detectiveDCFGroup = new Group();
            detectiveDCFGroup.Name = 'Detective DCF Group External';
            detectiveDCFGroup.DeveloperName = 'Core_MDF_Detective_DCF_Group_External';
            
            groupList.add(starkCCFGroup);groupList.add(starkDCFGroup);groupList.add(marvelRMFGroup);groupList.add(detectiveDCFGroup);
            Database.insert(groupList);

            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();

            Core_MDF_Partner_Group_Mapping__c starkCCFPGM = new Core_MDF_Partner_Group_Mapping__c();
            starkCCFPGM.Core_MDF_Account__c = starkAccount.Id;
            starkCCFPGM.Core_MDF_Channel_Program__c = ccf.Id; 
            starkCCFPGM.Core_MDF_Type_of_Access__c = 'External';
            starkCCFPGM.Core_MDF_Group_Name__c = 'Core_MDF_Stark_CCF_Group_External';

            Core_MDF_Partner_Group_Mapping__c starkDCFPGM = new Core_MDF_Partner_Group_Mapping__c();
            starkDCFPGM.Core_MDF_Account__c = starkAccount.Id;
            starkDCFPGM.Core_MDF_Channel_Program__c = dcf.Id; 
            starkDCFPGM.Core_MDF_Type_of_Access__c = 'External';
            starkDCFPGM.Core_MDF_Group_Name__c = 'Core_MDF_Stark_DCF_Group_External';

            Core_MDF_Partner_Group_Mapping__c starkCCFAgencyPGM = new Core_MDF_Partner_Group_Mapping__c();
            starkCCFAgencyPGM.Core_MDF_Account__c = starkAgencyAccount.Id;
            starkCCFAgencyPGM.Core_MDF_Works_For__c = marvelAccount.Id;
            starkCCFAgencyPGM.Core_MDF_Channel_Program__c = rmf.Id; 
            starkCCFAgencyPGM.Core_MDF_Type_of_Access__c = 'External';
            starkCCFAgencyPGM.Core_MDF_Group_Name__c = 'Core_MDF_Marvel_RMF_Group_External';

            Core_MDF_Partner_Group_Mapping__c starkDCFAgencyPGM = new Core_MDF_Partner_Group_Mapping__c();
            starkDCFAgencyPGM.Core_MDF_Account__c = starkAgencyAccount.Id;
            starkDCFAgencyPGM.Core_MDF_Works_For__c = detectiveCAccount.Id;
            starkDCFAgencyPGM.Core_MDF_Channel_Program__c = dcf.Id; 
            starkDCFAgencyPGM.Core_MDF_Type_of_Access__c = 'External';
            starkDCFAgencyPGM.Core_MDF_Group_Name__c = 'Core_MDF_Detective_DCF_Group_External';

            pgmList.add(starkCCFPGM);pgmList.add(starkDCFPGM);pgmList.add(starkCCFAgencyPGM);pgmList.add(starkDCFAgencyPGM);
            Database.insert(pgmList);

            GroupMember starkDcfGmRecord = new GroupMember();
            starkDcfGmRecord.UserOrGroupId = starkUser.Id;
            starkDcfGmRecord.GroupId = starkDCFGroup.Id;
            Database.insert(starkDcfGmRecord);


            List<Core_Trigger_Executions__c> triggerExecutionList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c execution1 = new Core_Trigger_Executions__c();
            execution1.Name = 'Core_MDF_ProcessEntitlementsFlag';
            execution1.Core_Active__c = true;
            execution1.Core_Class_Name__c = 'Core_ContactEntitlementHandler';
            execution1.Core_Description__c = 'Process CCP Contacts';
            execution1.Core_Object__c = 'Contact Entitlement';
            execution1.Core_Trigger_Events__c = 'After Update';

            Core_Trigger_Executions__c execution2 = new Core_Trigger_Executions__c();
            execution2.Name = 'pnumDeletionIndicator';
            execution2.Core_Active__c = true;
            execution2.Core_Class_Name__c = 'Core_MDF_UserGroupMapping_Deletion';
            execution2.Core_Description__c = 'Process CCP Contacts';
            execution2.Core_Object__c = 'Contact Entitlement';
            execution2.Core_Trigger_Events__c = 'After Update';

            Core_Trigger_Executions__c execution3 = new Core_Trigger_Executions__c();
            execution3.Name = 'callExternalUserSharingFromUGMDeletion';
            execution3.Core_Active__c = true;
            execution3.Core_Class_Name__c = 'Core_MDF_UserGroupMapping_Deletion';
            execution3.Core_Description__c = 'Process CCP Contacts';
            execution3.Core_Object__c = 'Contact Entitlement';
            execution3.Core_Trigger_Events__c = 'After Update';

            Core_Trigger_Executions__c execution4 = new Core_Trigger_Executions__c();
            execution4.Name = 'callExtUsrSharingFrmUGMAutomation';
            execution4.Core_Active__c = true;
            execution4.Core_Class_Name__c = 'Core_MDF_Process_CCP_Contacts';
            execution4.Core_Description__c = 'Process CCP Contacts';
            execution4.Core_Object__c = 'Contact Entitlement';
            execution4.Core_Trigger_Events__c = 'After Update';

            triggerExecutionList.add(execution1); triggerExecutionList.add(execution2);triggerExecutionList.add(execution3);triggerExecutionList.add(execution4);

            Database.insert(triggerExecutionList);
        }   
    } 

}