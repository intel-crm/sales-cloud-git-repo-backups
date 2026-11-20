@isTest(seeAllData=FALSE)
public class Core_MDF_ProcessEntitlements_Test{
    @isTest static void testProcessEntitlements()
    {   
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        /*
        List<String> bypassFunctionKeys = new List<String>(); 
            bypassFunctionKeys.add('checkDuplicateAccount');
            bypassFunctionKeys.add('MergeContactEntitlements');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
         List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        */
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c validateAdditionToGroup = [select id,Core_Status__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c='Client USER'];
        validateAdditionToGroup.Core_Status__c = 'Complete';
        
        Core_Contact_Entitlement__c validateDeletionFromGroup = [select id,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c='Datacenter USER' and Core_Selected__c=true];
        validateDeletionFromGroup.Core_Selected__c = false;

        Core_Contact_Entitlement__c validateMultipleAgency = [select id,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c='RMF USER'];
        validateMultipleAgency.Core_Selected__c = true;

        Core_Contact_Entitlement__c validateAdditionFallout = [select id,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c='CCF BOOST USER'];
        validateAdditionFallout.Core_Selected__c = true;

        Core_Contact_Entitlement__c validateDeletionFallout = [select id,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c='SPCF USER'];
        validateDeletionFallout.Core_Selected__c = false;
        
        Core_Contact_Entitlement__c validateMarketingUser = [select id,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c='Proposal Manager'];
        
        validateMarketingUser.Core_Selected__c = true;
        
        Core_Contact_Entitlement__c validateIPAUser = [select id,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Entitlement_Nm__c='IPA MDF USER'];
        validateIPAUser.Core_Selected__c = true;
        test.startTest();
        ceList.add(validateAdditionToGroup);
        ceList.add(validateDeletionFromGroup);
        ceList.add(validateMultipleAgency);
        ceList.add(validateAdditionFallout);
        celist.add(validateDeletionFallout);
        ceList.add(validateMarketingUser);
        
        
        Database.update(ceList);  
        test.stopTest(); 
        
        Core_MDF_ProcessEntitlementsSchedulable test = new Core_MDF_ProcessEntitlementsSchedulable();
        test.execute(null);
       
        List<Core_MDF_UserGroupMapping_Log__c> logrecords= [select id,Core_MDF_Action_nm__c from Core_MDF_UserGroupMapping_Log__c where Core_MDF_Status_nm__c='Action Required'];
       
        system.assertEquals(0, logrecords.size());
        Core_MDF_UGMLog controller = new Core_MDF_UGMLog(logrecords);

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
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.Name = 'Core_MDF_ProcessEntitlements_Class';
            config.Core_MDF_Value__c = 'Core_MDF_ProcessEntitlements';
            insert config;
            
                     
            //Create Intel Account
            Account starkAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Stark Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account starkAgencyAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Stark Agency Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account detectiveCAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Detective C Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            Account marvelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Marvel Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);

            //Create Channel Program
            ChannelProgram ccf = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            ChannelProgram dcf = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', true);
            ChannelProgram ccfb = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCFB_PROGRAM,'Client CoMarketing Fund Boost', true);
            ChannelProgram spcf = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.SPCF_PROGRAM,'Service Provider CoMarketing Fund', true);
            ChannelProgram rmf = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', true);
            ChannelProgram ipa = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Intel Partner Alliance', true);
            
            Account starkDCFAccount = Core_MDF_CCP_TestDataUtility.createAccount('Stark DCF Test Account', 
                                                                         dcf.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            starkDCFAccount.Core_MDF_Parent_Fund_Account__c = starkAccount.Id;
            starkDCFAccount.Core_MDF_CoMarketing_Ultimate_Account__c=starkAccount.Id;
            Database.insert(starkDCFAccount);

            //Create a Co-Marketing Account
            Account starkCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Stark Co-Marketing Account', dcf.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,starkAccount.id, false);
            starkCoMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c = starkAccount.id;
            Database.insert(starkCoMarketingAccount);  
            
            //Create Contact
            List<Contact> contactList = new List<Contact>();
            Contact starkContact = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='StarkContact',Email='testcontact'+String.valueOf(Math.random())+'@CoreMDF.com',AccountId=starkAccount.Id,Phone='123456798',MailingCountry='India');
            //Contact starkContact = Core_MDF_CCP_TestDataUtility.createContact(starkAccount.Id, false);
            //starkContact.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            Contact starkAgencyContact = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='StarkAgency',Email='testcontact'+String.valueOf(Math.random())+'@CoreMDF.com',AccountId=starkAgencyAccount.Id,Phone='123456798',MailingCountry='India');      
            contactList.add(starkContact);
            contactList.add(starkAgencyContact);
            
            
            
            //starkContact.Core_Audience_List__c = 'DCF User';
            //conList.add(starkContact);
            
            Database.insert(contactList);
           

            //Create ERPM Engagement
            List<Core_ERPM_Engagement__c> engagementList = new List<Core_ERPM_Engagement__c>();
            Core_ERPM_Engagement__c ccfEngagement = new Core_ERPM_Engagement__c(Name='CCF',Core_Technical_Engagement_Code__c='CCF',Core_Engagement_Type__c='SEC',Core_IsActive__c=true);
            Core_ERPM_Engagement__c dcfEngagement = new Core_ERPM_Engagement__c(Name='DCF',Core_Technical_Engagement_Code__c='DCF',Core_Engagement_Type__c='SEC',Core_IsActive__c=true);
            Core_ERPM_Engagement__c ccfbEngagement = new Core_ERPM_Engagement__c(Name='CCFB',Core_Technical_Engagement_Code__c='CCFB',Core_Engagement_Type__c='SEC',Core_IsActive__c=true);
            Core_ERPM_Engagement__c spcfEngagement = new Core_ERPM_Engagement__c(Name='SPCF',Core_Technical_Engagement_Code__c='SPCF',Core_Engagement_Type__c='SEC',Core_IsActive__c=true);
            Core_ERPM_Engagement__c rmfEngagement = new Core_ERPM_Engagement__c(Name='RMF',Core_Technical_Engagement_Code__c='RMF',Core_Engagement_Type__c='SEC',Core_IsActive__c=true);
            Core_ERPM_Engagement__c proposalManagerEngagement = new Core_ERPM_Engagement__c(Name='Proposal Manager',Core_Technical_Engagement_Code__c='IPA',Core_Engagement_Type__c='SEC',Core_IsActive__c=true);
            Core_ERPM_Engagement__c IPAEngagement = new Core_ERPM_Engagement__c(Name='IPA MDF User',Core_Technical_Engagement_Code__c='IPA',Core_Engagement_Type__c='SEC',Core_IsActive__c=true);
            engagementList.add(ccfEngagement); 
            engagementList.add(dcfEngagement);
            engagementList.add(ccfbEngagement);
            engagementList.add(spcfEngagement);
            engagementList.add(rmfEngagement);
            engagementList.add(proposalManagerEngagement); 
            engagementList.add(IPAEngagement);
            Database.insert(engagementList);

            //Create Entitlement Detail
            List<Core_Entitlement__c> entitlementDetailList = new List<Core_Entitlement__c>();
            Core_Entitlement__c ccfEntitlementDetail = new Core_Entitlement__c(Name='Client USER',Core_Display_Name__c='CCF USER',Core_ERPM_Engagement_Id__c=ccfEngagement.id,Core_IsActive__c=true);
            //Core_Entitlement__c dcfEntitlementDetail = new Core_Entitlement__c(Name='DCF USER',Core_Display_Name__c='DCF USER',Core_ERPM_Engagement_Id__c=dcfEngagement.id,Core_IsActive__c=true);
            Core_Entitlement__c dcfEntitlementDetail = new Core_Entitlement__c (name ='Datacenter User', Core_Category__c='Intel® Partner Investment Center',Core_Sub_Category__c='Datacenter',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=dcfEngagement.id,Core_Display_Name__c='DCF User',Core_IsActive__c=true);
            Core_Entitlement__c ccfbEntitlementDetail = new Core_Entitlement__c(Name='CCF BOOST USER',Core_Display_Name__c='CCF BOOST USER',Core_ERPM_Engagement_Id__c=ccfbEngagement.id,Core_IsActive__c=true);
            Core_Entitlement__c spcfEntitlementDetail = new Core_Entitlement__c(Name='SPCF USER',Core_Display_Name__c='SPCF USER',Core_ERPM_Engagement_Id__c=spcfEngagement.id,Core_IsActive__c=true);
            Core_Entitlement__c rmfEntitlementDetail = new Core_Entitlement__c(Name='RMF USER',Core_Display_Name__c='RMF USER',Core_ERPM_Engagement_Id__c=rmfEngagement.id,Core_IsActive__c=true);
            Core_Entitlement__c proposalManagerEntitlementDetail = new Core_Entitlement__c(Name='Proposal Manager',Core_Display_Name__c='Proposal Manager',Core_ERPM_Engagement_Id__c=proposalManagerEngagement.id,Core_IsActive__c=true);
            Core_Entitlement__c ipaEntitlementDetail = new Core_Entitlement__c(Name='IPA MDF USER',Core_Display_Name__c='IPA MDF USER',Core_ERPM_Engagement_Id__c=IPAEngagement.id,Core_IsActive__c=true);
            entitlementDetailList.add(ccfEntitlementDetail);
            entitlementDetailList.add(dcfEntitlementDetail);
            entitlementDetailList.add(ccfbEntitlementDetail); 
            entitlementDetailList.add(spcfEntitlementDetail); 
            entitlementDetailList.add(rmfEntitlementDetail);
            entitlementDetailList.add(proposalManagerEntitlementDetail) ;
            entitlementDetailList.add(ipaEntitlementDetail);
            Database.insert(entitlementDetailList);

            //Create Contact Entitlement
            List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
            Core_Contact_Entitlement__c starkCCFCE= new Core_Contact_Entitlement__c(Core_Contact_Id__c=starkContact.id,Core_Entitlement_Id__c=ccfEntitlementDetail.id,Core_Selected__c=true, Core_Status__c='Pending');
            Core_Contact_Entitlement__c starkDCFCE= new Core_Contact_Entitlement__c(Core_Contact_Id__c=starkContact.id,Core_Entitlement_Id__c=dcfEntitlementDetail.id,Core_Selected__c=true, Core_Status__c='Complete');
            Core_Contact_Entitlement__c starkAgencyCE= new Core_Contact_Entitlement__c(Core_Contact_Id__c=starkAgencyContact.id,Core_Entitlement_Id__c=rmfEntitlementDetail.id,Core_Selected__c=false, Core_Status__c='Complete');
            Core_Contact_Entitlement__c starkCCFBCE= new Core_Contact_Entitlement__c(Core_Contact_Id__c=starkContact.id,Core_Entitlement_Id__c=ccfbEntitlementDetail.id,Core_Selected__c=false, Core_Status__c='Complete');
            Core_Contact_Entitlement__c starkSPCFCE= new Core_Contact_Entitlement__c(Core_Contact_Id__c=starkContact.id,Core_Entitlement_Id__c=spcfEntitlementDetail.id,Core_Selected__c=true, Core_Status__c='Complete');
            Core_Contact_Entitlement__c starkIPACE= new Core_Contact_Entitlement__c(Core_Contact_Id__c=starkContact.id,Core_Entitlement_Id__c=ipaEntitlementDetail.id,Core_Selected__c=false, Core_Status__c='Complete');
            Core_Contact_Entitlement__c starkProposalManagerCE= new Core_Contact_Entitlement__c(Core_Contact_Id__c=starkContact.id,Core_Entitlement_Id__c=proposalManagerEntitlementDetail.id,Core_Selected__c=false, Core_Status__c='Complete');
            ceList.add(starkCCFCE);
            ceList.add(starkDCFCE);
            ceList.add(starkAgencyCE);
            ceList.add(starkCCFBCE);
            ceList.add(starkSPCFCE);
            ceList.add(starkIPACE);
            ceList.add(starkProposalManagerCE);
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

            userList.add(starkUser);
            userList.add(starkAgencyUser);
            Database.insert(userList);
            
                       
            

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
            
            Group starkIPAGroup = new Group();
            starkIPAGroup.Name = 'Stark IPA Group External';
            starkIPAGroup.DeveloperName = 'Core_MDF_Stark_IPA_Group_External';
            
            groupList.add(starkCCFGroup);groupList.add(starkDCFGroup);groupList.add(marvelRMFGroup);groupList.add(detectiveDCFGroup);groupList.add(starkIPAGroup);
            Database.insert(groupList);

            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();

            Core_MDF_Partner_Group_Mapping__c starkCCFPGM = new Core_MDF_Partner_Group_Mapping__c();
            starkCCFPGM.Core_MDF_Account__c = starkAccount.Id;
            starkCCFPGM.Core_MDF_Channel_Program__c = ccf.Id; 
            starkCCFPGM.Core_MDF_Type_of_Access__c = 'External';
            starkCCFPGM.Core_MDF_Group_Name__c = 'Core_MDF_Stark_CCF_Group_External';
            
            Group starkExt = [select id from Group where Name = 'Stark DCF Group External'];
            
            

            Core_MDF_Partner_Group_Mapping__c starkDCFPGM = new Core_MDF_Partner_Group_Mapping__c();
            starkDCFPGM.Core_MDF_Account__c = starkAccount.Id;
            starkDCFPGM.Core_MDF_Channel_Program__c = dcf.Id; 
            starkDCFPGM.Core_MDF_Type_of_Access__c = 'External';
            starkDCFPGM.Core_MDF_Group_Name__c = 'Core_MDF_Stark_DCF_Group_External';
            //starkDCFPGM.Core_MDF_Group_Id__c = starkDCFGroup.id;
                starkDCFPGM.Core_MDF_AccountIdGroupName__c = starkAccount.Id + 'Core_MDF_Stark_DCF_Group_External';
            
            /*Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = intAcc.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_CCP_DCF_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = dcfgrp.Id;
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            pgm1.Core_MDF_AccountIdGroupName__c = intacc.Id+'Core_CCP_DCF_External';*/
            
            Core_MDF_Partner_Group_Mapping__c starkIPAPGM = new Core_MDF_Partner_Group_Mapping__c();
            starkIPAPGM.Core_MDF_Account__c = starkAccount.Id;
            starkIPAPGM.Core_MDF_Channel_Program__c = ipa.Id; 
            starkIPAPGM.Core_MDF_Type_of_Access__c = 'External';
            starkIPAPGM.Core_MDF_Group_Name__c = 'Core_MDF_Stark_IPA_Group_External';

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

            pgmList.add(starkCCFPGM);pgmList.add(starkDCFPGM);pgmList.add(starkCCFAgencyPGM);pgmList.add(starkDCFAgencyPGM);pgmList.add(starkIPAPGM);
            Database.insert(pgmList);

            GroupMember starkDcfGmRecord = new GroupMember();
            starkDcfGmRecord.UserOrGroupId = starkUser.Id;
            starkDcfGmRecord.GroupId = starkDCFGroup.Id;
            Database.insert(starkDcfGmRecord);
            
            


            List<Core_Trigger_Executions__c> triggerExecutionList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c execution1 = new Core_Trigger_Executions__c();
            execution1.Name = 'Core_MDF_ProcessEntitlementsFlag';
            execution1.Core_Active__c = true;
            execution1.Core_Class_Name__c = 'Core_MDF_ProcessEntitlements';
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
            execution4.Core_Class_Name__c = 'Core_MDF_ProcessEntitlements';
            execution4.Core_Description__c = 'Process CCP Contacts';
            execution4.Core_Object__c = 'Contact Entitlement';
            execution4.Core_Trigger_Events__c = 'After Update';
            
            Core_Trigger_Executions__c execution5 = new Core_Trigger_Executions__c();
            execution5.Name = 'Core_MDF_MarketingUser_Update';
            execution5.Core_Active__c = true;
            execution5.Core_Class_Name__c = 'Core_MDF_ProcessEntitlements';
            execution5.Core_Description__c = 'Process CCP Contacts';
            execution5.Core_Object__c = 'Contact Entitlement';
            execution5.Core_Trigger_Events__c = 'After Update';
            
            Core_Trigger_Executions__c execution6 = new Core_Trigger_Executions__c();
            execution6.Name = 'Core_MDF_PNUM_Addition';
            execution6.Core_Active__c = true;
            execution6.Core_Class_Name__c = 'Core_MDF_ProcessEntitlements';
            execution6.Core_Description__c = 'Process CCP Contacts';
            execution6.Core_Object__c = 'Contact Entitlement';
            execution6.Core_Trigger_Events__c = 'After Update';

            triggerExecutionList.add(execution1); 
            triggerExecutionList.add(execution2);
            triggerExecutionList.add(execution3);
            triggerExecutionList.add(execution4);
            triggerExecutionList.add(execution5);
            triggerExecutionList.add(execution6);

            Database.insert(triggerExecutionList);
            
            Core_MDF_Partner_Node_User_Mapping__c starkPNUM = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(starkDCFAccount.id,starkUser.id, true);
        }   
    } 
}