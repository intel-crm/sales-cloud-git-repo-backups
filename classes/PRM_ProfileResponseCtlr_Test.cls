/*********************************************************************************************************************
Class Name    : PRM_ProfileResponseCtlr_Test
Version       : 1.0
Created Date  : JUNE 2019
Function      : Test Class for 'PRM_ProfileResponseCtlr'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Utkarsh                 03/06/2019              Test Class for 'PRM_ProfileResponseCtlr'

*********************************************************************************************************************/

@isTest
Public class PRM_ProfileResponseCtlr_Test{
    static testMethod void responseTestMethod(){
        Test.startTest();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
       Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();

        
        Account acc = new Account();
        acc.RecordTypeId = recordTypeIdAccount;
        acc.Name='John Rick';
        acc.BillingCity='City';
        acc.BillingStreet='Street';
        acc.BillingCountry='India';
        acc.BillingPostalCode='Postal code';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        //acc.PRM_PartnerType__c = 'Cloud Service Provider (CSP)';
        insert acc;
        
         Account acc1 = new Account();
        acc1.RecordTypeId = accountRTPartnerAccountGroup;
        acc1.Name='Partner Account';
        acc1.Core_Account_Type__c ='Distributor';
        acc1.Industry='Agriculture';
        acc1.BillingCity='New Delhi';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,New Road';
        acc1.BillingPostalCode='110037';
        acc1.BillingStateCode='KA';
        insert acc1;
        
          Account acc2 = new Account();
        acc2.Name='Intel Account - Two';
        acc2.RecordTypeId = recordTypeIdAccount;
        acc2.Core_Account_Type__c ='Distributor';
        acc2.Industry='Agriculture';
        acc2.BillingCity='Chennai';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='4th Floor,New Road';
        acc2.BillingPostalCode='110037';
        acc2.BillingStateCode='TN';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        insert acc2;
        
        Core_Account_Group_Member__c agm2 = new Core_Account_Group_Member__c();
        agm2.Core_Partner_Account_Id__c = acc1.Id;
        agm2.Core_Intel_Account_Id__c = acc2.Id;
        agm2.Core_Inactive_Ind__c = false;
        insert agm2;
        
        Contact con = PRM_TestUtility.getContact();
        con.AccountId = acc.Id;
        insert con;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        
        ChannelProgramLevel cpl = new ChannelProgramLevel(); 
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_AccountChannelMembership__c acctChnlMem = new PRM_AccountChannelMembership__c(); 
        acctChnlMem.PRM_Account_Id__c=acc.Id;
        acctChnlMem.PRM_Channel_Program_Id__c=cp.Id;
        acctChnlMem.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acctChnlMem.PRM_Status_Nm__c = 'Approved';
        acctChnlMem.PRM_Partner_Role__c='Guest';
        acctChnlMem.PRM_Status_Reason_Txt__c='Test01';
        insert acctChnlMem;
        
        
        PRM_PartnerType__c pt = new PRM_PartnerType__c();
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        //pt.PRM_Role_Name__c = 'Service Provider';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        pt.PRM_channelprogram__c = cp.Id;
        insert pt;
        
        PRM_Profile_Questions__c pq = new PRM_Profile_Questions__c();
        pq.PRM_Channel_Program_Id__c = cp.Id;
        //pq.PRM_Partner_Type_Id__c = pt.Id;
        //pq.PRM_Partner_Role__c='Service Provider';
        pq.PRM_Question_Type_Nm__c = 'Text';
        pq.PRM_InActive_Ind__c = false;
        insert pq;
        
        PRM_Profile_Questions__c pq1 = new PRM_Profile_Questions__c();
        pq1.PRM_Channel_Program_Id__c = cp.Id;
        //pq1.PRM_Partner_Role__c='Service Provider';       
        //pq1.PRM_Partner_Type_Id__c = pt.Id;
        pq1.PRM_Question_Type_Nm__c = 'Textarea';
        pq1.PRM_InActive_Ind__c = false;
        insert pq1;
        
        PRM_Profile_Questions__c pq2 = new PRM_Profile_Questions__c();
        pq2.PRM_Channel_Program_Id__c = cp.Id;
        //pq2.PRM_Partner_Role__c='Service Provider';
        //pq2.PRM_Partner_Type_Id__c = pt.Id;
        pq2.PRM_Question_Type_Nm__c = 'Multiselect';
        pq2.PRM_InActive_Ind__c = false;
        insert pq2;
        
        PRM_Profile_Questions__c pq3 = new PRM_Profile_Questions__c();
        pq3.PRM_Channel_Program_Id__c = cp.Id;
        //pq3.PRM_Partner_Role__c='Service Provider';
        //pq3.PRM_Partner_Type_Id__c = pt.Id;
        pq3.PRM_Question_Type_Nm__c = 'Boolean';
        pq3.PRM_InActive_Ind__c = false;
        insert pq3;
        
        PRM_Profile_Questions__c pq4 = new PRM_Profile_Questions__c();
        pq4.PRM_Channel_Program_Id__c = cp.Id;
        //pq4.PRM_Partner_Role__c='Service Provider';
        //pq4.PRM_Partner_Type_Id__c = pt.Id;
        pq4.PRM_Question_Type_Nm__c = 'Picklist';
        pq4.PRM_InActive_Ind__c = false;
        insert pq4;
        
        PRM_Profile_Answer__c pa = new PRM_Profile_Answer__c();
        pa.PRM_Profile_Questions_Id__c = pq.Id;
        insert pa;
        
        PRM_Profile_Answer__c pa1 = new PRM_Profile_Answer__c();
        pa1.PRM_Profile_Questions_Id__c = pq1.Id;
        insert pa1;
        
        PRM_Profile_Answer__c pa2 = new PRM_Profile_Answer__c();
        pa2.PRM_Profile_Questions_Id__c = pq2.Id;
        insert pa2;
        
        PRM_Profile_Answer__c pa3 = new PRM_Profile_Answer__c();
        pa3.PRM_Profile_Questions_Id__c = pq3.Id;
        insert pa3;
        
        PRM_Profile_Answer__c pa4 = new PRM_Profile_Answer__c();
        pa4.PRM_Profile_Questions_Id__c = pq4.Id;
        insert pa4;
        
        List<PRM_Profile_Responses__c> prList = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> presList = new List<PRM_Profile_Responses__c>();
        
        PRM_Profile_Responses__c pr = new PRM_Profile_Responses__c();
        pr.PRM_Account_Id__c = acc.Id;
        pr.PRM_Profile_Answer_Id__c = pa.Id;
        pr.PRM_Profile_Questions_Id__c = pq.Id;
        insert pr;
        
        PRM_Profile_Responses__c pr1 = new PRM_Profile_Responses__c();
        pr1.PRM_Account_Id__c = acc.Id;
        pr1.PRM_Profile_Answer_Id__c = pa1.Id;
        pr1.PRM_Profile_Questions_Id__c = pq1.Id;
        prList.add(pr1);
        
        PRM_Profile_Responses__c pr2 = new PRM_Profile_Responses__c();
        pr2.PRM_Account_Id__c = acc.Id;
        pr2.PRM_Profile_Answer_Id__c = pa2.Id;
        pr2.PRM_Profile_Questions_Id__c = pq2.Id;
        prList.add(pr2);
        
        PRM_Profile_Responses__c pr3 = new PRM_Profile_Responses__c();
        pr3.PRM_Account_Id__c = acc.Id;
        pr3.PRM_Profile_Answer_Id__c = pa3.Id;
        pr3.PRM_Profile_Questions_Id__c = pq3.Id;
        presList.add(pr3);
        
        PRM_Profile_Responses__c pr4 = new PRM_Profile_Responses__c();
        pr4.PRM_Account_Id__c = acc.Id;
        pr4.PRM_Profile_Answer_Id__c = pa4.Id;
        pr4.PRM_Profile_Questions_Id__c = pq4.Id;
        presList.add(pr4);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@intel.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@intel.com');
        
        User u1 = new User(Alias = 'standar', Email='standar@intel.com', 
        EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standard@intel.com');
        
        System.runAs(u) {
            AccountShare accShare = new AccountShare();
            accShare.RowCause = 'Manual';
            accShare.AccountAccessLevel = 'Edit';
            accShare.UserOrGroupId = u.Id;
            accShare.AccountId = acc.Id;
            accShare.OpportunityAccessLevel = 'Edit';
            insert accShare;
        }
        
        System.runAs(u1) {
            AccountShare accShareSec = new AccountShare();
            accShareSec.RowCause = 'Manual';
            accShareSec.AccountAccessLevel = 'Read';
            accShareSec.UserOrGroupId = u1.Id;
            accShareSec.AccountId = acc.Id;
            accShareSec.OpportunityAccessLevel = 'Read';
            insert accShareSec;
        }
        
        insert prList;
        insert presList;
        
        Test.stopTest();
        
        PRM_ProfileResponseCtlr.getResponses(acctChnlMem.Id,'Intel Partner Alliance','PRM_AccountChannelMembership__c');
        PRM_ProfileResponseCtlr.getResponses(acc.Id,'Intel Partner Alliance','Account');
        PRM_ProfileResponseCtlr.getResponses(acc.Id,'Intel Partner Alliance, New Partner Program','Account');
        PRM_ProfileResponseCtlr.saveResponse(prList,presList,acc.Id);
        PRM_ProfileResponseCtlr.disableFlagValues(acc2.Id);
         PRM_ProfileResponseCtlr.disableFlagValues(acc1.Id);


        
        System.assertEquals(pr.PRM_Account_Id__c,acc.Id,'Value does not match');
    }
}