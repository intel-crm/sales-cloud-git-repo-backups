/****************************************************************************************************************************
Apex Class Name     : PRM_SendNotificationMessages_Test 
Version             : 1.0
Created Date        : 22 June 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Bharath Kumar       22 June 2020                Test class to cover PRM_SendNotificationMessages class

****************************************************************************************************************************/
@isTest
public class PRM_SendNotificationMessages_Test {
    @testSetup
    public static void testData(){
        Id pagAccountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Id intelRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id adhocRecordTypeId = Schema.SObjectType.PRM_Message__c.getRecordTypeInfosByName().get('Adhoc').getRecordTypeId();
        Id eventRecordTypeId = Schema.SObjectType.PRM_Message__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        
    	Account pagAccount1 = new Account();//Account
        pagAccount1.RecordTypeId = pagAccountRecordType;
        pagAccount1.Name='Johrt Rick';
        pagAccount1.BillingCity='City';
        pagAccount1.BillingStreet='Street';
        pagAccount1.BillingCountry='India';
        pagAccount1.BillingPostalCode='Postal code';
        pagAccount1.Core_IPA_Partner_Role__c = 'Distributor';	
        pagAccount1.Core_CNDA_Number__c='';
        pagAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert pagAccount1;
    
    	Account pagAccount2 = new Account();//Account
        pagAccount2.RecordTypeId = pagAccountRecordType;
        pagAccount2.Name='Johrt Ricky';
        pagAccount2.BillingCity='City';
        pagAccount2.BillingStreet='Street';
        pagAccount2.BillingCountry='India';
        pagAccount2.BillingPostalCode='Postal code';
        pagAccount2.Core_IPA_Partner_Role__c = 'Distributor';
        pagAccount2.Core_CNDA_Number__c='';
        pagAccount2.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert pagAccount2;
        
        Account intelAccount1 = new Account();//Account
        intelAccount1.RecordTypeId = intelRecordType;
        intelAccount1.Name='David Miller';
        intelAccount1.BillingCity='City';
        intelAccount1.BillingStreet='Street';
        intelAccount1.BillingCountry='India';
        intelAccount1.BillingPostalCode='Postal code';
        intelAccount1.Core_IPA_Partner_Role__c = 'Distributor';	
        intelAccount1.Core_CNDA_Number__c='';
        intelAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        intelAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert intelAccount1;
    
    	Account intelAccount2 = new Account();//Account
        intelAccount2.RecordTypeId = intelRecordType;
        intelAccount2.Name='John David';
        intelAccount2.BillingCity='City';
        intelAccount2.BillingStreet='Street';
        intelAccount2.BillingCountry='India';
        intelAccount2.BillingPostalCode='Postal code';
        intelAccount2.Core_IPA_Partner_Role__c = 'Distributor';
        intelAccount2.Core_CNDA_Number__c='';
        intelAccount2.Core_Account_Type__c='Cloud Service Provider (CSP)';
        intelAccount2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert intelAccount2;
        
        Contact con1 = new Contact();  //Contact
        con1.AccountId=intelAccount1.Id;
        con1.lastName='Grill';
        con1.FirstName='Adam';
        con1.email='AdamGrill@rediff.com';
        con1.Core_Job_Function__c='Branch Manager';
        con1.Core_eRPM_Language_Code__c='Eng';
        con1.Core_IPA_PartnerRole__c = 'Service Provider';
        con1.Core_Login_Id__c = 'abc';
        con1.MailingCountry='USA';
        insert con1;
        //TestData for Contact 
        Contact con2 =new Contact();
        con2.Email='test@intel.com';
        con2.AccountId=intelAccount2.Id;
        con2.FirstName='Test';
        con2.LastName='User';
        con2.Core_Job_Function__c='Branch Manager';
        con2.Core_eRPM_Language_Code__c='Eng';
        con2.Core_IPA_PartnerRole__c = 'Service Provider';
        con2.Core_Login_Id__c = 'Test';
        con2.MailingCountry='USA';
        insert con2;
        
        Test.startTest();
        List<Core_Account_Group_Member__c> cagmList = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c coreAccount = new Core_Account_Group_Member__c();
        coreAccount.Core_Partner_Account_Id__c = pagAccount1.Id;
        coreAccount.Core_Intel_Account_Id__c = intelAccount1.Id;
        coreAccount.Core_Inactive_Ind__c = false;
        cagmList.add(coreAccount);
        
        Core_Account_Group_Member__c coreAccount1 = new Core_Account_Group_Member__c();
        coreAccount1.Core_Partner_Account_Id__c = pagAccount1.Id;
        coreAccount1.Core_Intel_Account_Id__c = intelAccount2.Id;
        coreAccount1.Core_Inactive_Ind__c = false;
        cagmList.add(coreAccount1);
        insert cagmList;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;  
        insert cpl;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name='Solutions Marketplace Enhanced';
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Channel_Program_Id__c = cp.id;
        insert pb;
        
        PRM_VXBnftMatrix__c bm = new PRM_VXBnftMatrix__c(); //Benefit Matrix 
        bm.PRM_Partner_Benefit_Id__c = pb.id;
        bm.PRM_Channel_Program_Id__c = cp.id;
        bm.PRM_Channel_Program_Level_Id__c = cpl.id;
        bm.PRM_Partner_Role_Nm__c = 'Builder';
        bm.PRM_IsActive_Ind__c  = true;
        bm.PRM_Approval_Type_Nm__c = 'Manual';
        insert bm;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=intelAccount1.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cp.Id;
        acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acm.PRM_Partner_Role__c='Builder';
        acm.PRM_Status_Reason_Txt__c='Test';
        insert acm;
        
       // Test Data for Message
       	PRM_Message__c msg1= new PRM_Message__c();
        msg1.PRM_Title_Txt__c='Setup your store front';
        msg1.PRM_Message_Cd__c = 'MSGSTRFRNT';
        msg1.RecordTypeId = eventRecordTypeId;
        insert msg1;
        
        PRM_Message__c msg2= new PRM_Message__c();
        msg2.PRM_Title_Txt__c='Adhoc messgae';
        msg2.PRM_Message_Cd__c = 'ADHOC';
        msg2.RecordTypeId = Schema.SObjectType.PRM_Message__c.getRecordTypeInfosByName().get(System.Label.PRM_Adhoc).getRecordTypeId();
        insert msg2;                
        
        Core_AGS_Role__c agsRole1 = new Core_AGS_Role__c();
        agsRole1.Name = 'CSP Member';
        agsRole1.Core_Technical_Name__c = 'CIP General Partner';
        agsRole1.Core_IsActive__c = True;
        insert agsRole1;
        
        Core_AGS_Role__c agsRole2 = new Core_AGS_Role__c();
        agsRole2.Name = 'Sales-PRM-External-Offering Editor';
        agsRole2.Core_Technical_Name__c = 'Sales-PRM-External-Offering Editor';
        agsRole2.Core_IsActive__c = True;
        insert agsRole2;
        
        Core_ERPM_Engagement__c erpmEng1 = new Core_ERPM_Engagement__c();
        erpmEng1.Name = 'Access and Entitlements for Marketplace';
        erpmEng1.Core_Technical_Engagement_Code__c = 'MKTSMP';
        erpmEng1.Core_Engagement_Type__c = 'SMP';
        erpmEng1.Core_IsActive__c = True;
        insert erpmEng1;
        
        Core_ERPM_Engagement__c erpmEng2 = new Core_ERPM_Engagement__c();
        erpmEng2.Name = 'Access and Entitlements for Marketplace';
        erpmEng2.Core_Technical_Engagement_Code__c = 'MKTSMP';
        erpmEng2.Core_Engagement_Type__c = 'SMP';
        erpmEng2.Core_IsActive__c = True;
        insert erpmEng2;
       
        Core_Entitlement__c ed1 = new Core_Entitlement__c();
        ed1.Name = 'Partner Admin';
        ed1.Core_Display_Name__c = 'Partner Admin';
        ed1.Core_ERPM_Engagement_Id__c = erpmEng1.Id;
        ed1.Core_AGS_Role_Id__c = agsRole1.Id;
        insert ed1;
        
        Core_Entitlement__c ed2 = new Core_Entitlement__c();
        ed2.Name = 'Offering Editor';
        ed2.Core_Display_Name__c = 'Offering Editor';
        ed2.Core_ERPM_Engagement_Id__c = erpmEng2.Id;
        ed2.Core_AGS_Role_Id__c = agsRole2.Id;
        insert ed2;
        
       	PRM_Message_Entitlement_Association__c meEntiAss1 = new PRM_Message_Entitlement_Association__c();
        meEntiAss1.PRM_Message_Id__c = msg1.Id;
        meEntiAss1.PRM_Entitlement_Detail_Id__c = ed1.Id;
        insert meEntiAss1;
        
        PRM_Message_Entitlement_Association__c meEntiAss2 = new PRM_Message_Entitlement_Association__c();
        meEntiAss2.PRM_Message_Id__c = msg1.Id;
        meEntiAss2.PRM_Entitlement_Detail_Id__c = ed2.Id;
        insert meEntiAss2;
      
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
        ce.Core_Contact_Id__c = con1.Id;
        ce.Core_Entitlement_Id__c = ed1.Id;
        ce.Core_Selected__c = true;
        ce.Core_Status__c = 'Complete';
        ceList.add(ce);
        
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
        ce1.Core_Contact_Id__c = con2.Id;
        ce1.Core_Entitlement_Id__c = ed1.Id;
        ce1.Core_Selected__c = true;
        ce1.Core_Status__c = 'Complete';
        ceList.add(ce1);
        
        insert ceList;
        
        PRM_Contact_Group__c cg = new PRM_Contact_Group__c();
        cg.name = 'test group';
        insert cg; 
        
        PRM_Contact_Group_Contact_Association__c cgca = new PRM_Contact_Group_Contact_Association__c();
        cgca.PRM_Contact_Id__c = con1.id;
        cgca.PRM_Contact_Group_Id__c = cg.Id;
        insert cgca;

        
        PRM_Message_Contact_Group_Association__c mcga = new PRM_Message_Contact_Group_Association__c();
        mcga.PRM_Message_Id__c = msg2.id;
        mcga.PRM_Contact_Group_Id__c = cg.id;
        insert mcga;
        
        PRM_Message_log__c msglog = new PRM_Message_log__c();
        msgLog.PRM_Contact_Id__c = con1.id;
        msgLog.PRM_Message_Id__c = msg1.id;
        insert msgLog;
                        
        Test.stopTest();
    }
    
    @isTest
    public static void sendNotif(){
        
        Id pagaccntId =[Select Id from Account where Name = 'Johrt Rick' limit 1].Id;
        
        PRM_SendNotificationMessages.MessageWrapper[] msg = new PRM_SendNotificationMessages.MessageWrapper[]{};
        PRM_SendNotificationMessages.MessageWrapper mw = new PRM_SendNotificationMessages.MessageWrapper();
        mw.msgCd = 'MSGSTRFRNT';
        mw.accountId = pagaccntId;
        msg.add(mw);
        Test.startTest();
        PRM_SendNotificationMessages.sendNotifications(msg);
		Integer actualCount = [Select count() from PRM_Message_log__c];
		System.assertEquals(2, actualCount);
        
        PRM_Message_log__c mlogs = [Select Id,PRM_Message_Id__c,PRM_Contact_Id__c,PRM_Inactive_Ind__c,PRM_Message_Viewed_Ind__c from PRM_Message_log__c LIMIT 1];
        mlogs.PRM_Inactive_Ind__c = true;
        update mlogs;
        
        
        PRM_SendNotificationMessages.sendNotifications(msg);
		Integer actual = [Select count() from PRM_Message_log__c];
		System.assertEquals(2, actual);
		Test.stopTest();
		        
    }
   
    public class MessageWrapper{
        public String msgCd;
        public Id accountId;
    }
}