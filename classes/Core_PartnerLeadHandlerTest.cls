/**************************************************************************************
Apex Class Name:  Core_PartnerLeadHandlerTest
Version     : 1.0 
Created Date: 06 August 2019
Function    : Test Class for the Core_PartnerLeadHandler class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             06/08/2019              Original Version
*************************************************************************************/
@isTest
public class Core_PartnerLeadHandlerTest {
    
    @testSetup 
    static void setup(){
        insertPublicGroup();
        List<Core_Trigger_Executions__c> triggerSettingList = new List<Core_Trigger_Executions__c>();
        List<String> settingNameList = new List<String>();
        settingNameList.add('leadObjectBeforeHandler');
        settingNameList.add('leadObjectSalesGroup');
        settingNameList.add('StampFieldOnReject');
        settingNameList.add('createGroupForLeadRouting');
        settingNameList.add('AssignLeadsToPartnerQueues');
        settingNameList.add('FetchOfferingDetails');
        settingNameList.add('NewPartnerLeadNotification');
        settingNameList.add('BlockExistingOpponConversionLead');
        settingNameList.add('leadConversionDeduplication');
        Core_Trigger_Executions__c triggerSetting;
        for(String settingName : settingNameList){
            triggerSetting = new Core_Trigger_Executions__c();
            triggerSetting.name = settingName;
            triggerSetting.Core_Object__c = 'Lead';
            triggerSetting.Core_Active__c = TRUE;
            triggerSetting.Core_Description__c = 'This is test description';
            triggerSetting.Core_Class_Name__c = 'Core_PartnerLeadHandler';
            triggerSetting.Core_Trigger_Events__c = 'Before Insert, Before Update, After Insert, After Update';
            triggerSettingList.add(triggerSetting);
        }
        insert triggerSettingList;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'IT Admin' LIMIT 1];
        
        User us = new User();
        us.FirstName = 'test';
        us.LastName = 'user';
        us.Email = 'testuser@intel.com';
        us.Username = 'testinguser@inteltest.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test.userqwert';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = profileId.Id;
        us.LanguageLocaleKey = 'en_US';
        insert us;
        
        List<Account> accList = new List<Account>();
        String AccPartnerRecType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        String AccIntelRecType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account partnerRec = new Account();
        partnerRec.Name='Test Parent Account1';
        partnerRec.RecordTypeId=AccPartnerRecType;
        partnerRec.Core_Account_Type__c='Cloud Service Provider (CSP)';
        partnerRec.BillingCountryCode='USA';
        partnerRec.BIllingStateCode='AL';
        partnerRec.BillingCity='Alabama123';
        partnerRec.BillingStreet='test';
        partnerRec.BillingPostalCode='123445';
        accList.add(partnerRec);
        
        Account Intelrec= new Account();
        Intelrec.Name='Test Intel Account 1';
        Intelrec.RecordTypeId=AccIntelRecType;
        Intelrec.Core_IPA_Partner_Segment__c = 'Client Computing;Data Center';
        Intelrec.Core_Account_Type__c='Cloud Service Provider (CSP)';
        Intelrec.BillingCountryCode='IND';
        Intelrec.BIllingStateCode='GJ';
        Intelrec.BillingCity='New Hellow12';
        Intelrec.BillingStreet='Hellow22';
        Intelrec.BillingPostalCode='9876633';
        accList.add(Intelrec);
        
        insert accList;
        
        Core_Account_Group_Member__c Acmem= new Core_Account_Group_Member__c();
        Acmem.Core_Intel_Account_Id__c=Intelrec.id;
        Acmem.Core_Partner_Account_Id__c=partnerRec.id;
        Acmem.Core_MDA_Ind__c=true;
        Insert Acmem;
        
        List<Core_Partner_Queue_Mapping__c> partQueueMapList = new List<Core_Partner_Queue_Mapping__c>();
        Core_Partner_Queue_Mapping__c partQueueMap = new Core_Partner_Queue_Mapping__c();
        partQueueMap.Core_Queue_Name__c = 'test Queue 1';
        partQueueMap.Core_Partner_Name__c = partnerRec.Name;
        partQueueMap.PMP_MDA_BizOrg_Id__c = partnerRec.Id;
        partQueueMapList.add(partQueueMap);
        
        Core_Partner_Queue_Mapping__c partQueueMap1 = new Core_Partner_Queue_Mapping__c();
        partQueueMap1.Core_Queue_Name__c = 'test Queue 2';
        partQueueMap1.Core_Partner_Name__c = 'partnerQueueMap';
        partQueueMapList.add(partQueueMap1);
        insert partQueueMapList;
        
        PMP_Company__c marketingProfileInfo = new PMP_Company__c();
        marketingProfileInfo.Name = Intelrec.Name;
        marketingProfileInfo.PMP_Account_Id__c = Intelrec.Id;
        insert marketingProfileInfo;
        PMP_Company__c marketingProfile = [select Id, PMP_Marketing_Profile_Id__c from PMP_Company__c where Id =: marketingProfileInfo.Id];
        
        PMP_Partner_Offering__c offering = new PMP_Partner_Offering__c();
        offering.Name='Offering Test';
        offering.PMP_Partner_Offering_Tag_Line_Txt__c='test tagline';
        offering.PMP_Business_Segment_Nm__c = 'IoT;Server';
        offering.PMP_Company_Id__c = marketingProfile.Id;
        insert Offering;
        PMP_Partner_Offering__c offeringRecord = [select Id, Name, PMP_Offering_Id__c, PMP_Partner_Offering_Tag_Line_Txt__c from PMP_Partner_Offering__c where Id =: Offering.Id];
        
        List<Lead> lstLeads = new List<Lead>();
        RecordType r1 = [Select Id from recordType where Name='Partner Lead'];
        Lead lead1 = new Lead();
        lead1.RecordTypeId = r1.Id;
        lead1.FirstName = 'Test1';
        lead1.LastName = 'Test12';
        lead1.email = 'gerald.reinartz=intel.com@example.com';
        lead1.Phone = '123 4567';
        lead1.Company = 'Test1';
        lead1.CountryCode = 'USA';
        lead1.LeadSource = 'Partner Program';
        lead1.Status='PRL';
        lead1.Core_Lead_Status__c='New';
        lead1.Core_Lead_State__c='Unclaimed';
        lead1.Core_Rejection_Comments__c ='Test';
        lead1.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
        lead1.Core_Partner_Name__c = partnerRec.Name;
        lead1.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
        lead1.Core_Notify_Owner__c = true;
        lstLeads.add(lead1);
        
        Lead lead2 = new Lead();
        lead2.RecordTypeId = r1.Id;
        lead2.FirstName = 'Test12';
        lead2.LastName = 'Test123';
        lead2.email = 'qwert@gmail.com';
        lead2.Phone = '123 87345';
        lead2.Company = 'Test1qwe';
        lead2.CountryCode = 'USA';
        lead2.LeadSource = 'Partner Program';
        lead2.Status='PAL';
        lead2.Core_Lead_Status__c='Accepted';
        lead2.Core_Lead_State__c='In Persuit';
        lead2.Core_Rejection_Comments__c ='Test';
        lead2.PMP_MDA_BizOrg_Id__c = partnerRec.Id;
        lead2.Core_Partner_Name__c = partnerRec.Name;
        lead2.Core_Notify_Owner__c = true;
        lstLeads.add(lead2);
        
        Lead lead3 = new Lead();
        lead3.RecordTypeId = System.Label.Core_Partner_Lead_Record_Id;
        lead3.FirstName = 'Test123';
        lead3.LastName = 'Test1234';
        lead3.email = 'dfghj@gmail.com';
        lead3.Phone = '123 09876';
        lead3.Company = 'Test1kjhg';
        lead3.CountryCode = 'USA';
        lead3.LeadSource = 'Partner Program';
        lead3.Core_Partner_Name__c = partnerRec.Name;
        lead3.Status='PAL';
        lead3.Core_Lead_Status__c='Contacted';
        lead3.Core_Lead_State__c='In Persuit';
        lead3.Core_Rejection_Comments__c ='Test';
        lstLeads.add(lead3);
        
        Lead lead4 = new Lead();
        lead4.RecordTypeId = r1.Id;
        lead4.FirstName = 'Test1';
        lead4.LastName = 'Test50';
        lead4.email = 'oiuytre@gmail.com';
        lead4.Phone = '123 34567';
        lead4.Company = 'Test1zxdftgh';
        lead4.CountryCode = 'USA';
        lead4.LeadSource = 'Partner Program';
        lead4.Core_Partner_Name__c = 'TestPartner1';
        lead4.Status='PQL';
        lead4.Core_Lead_Status__c='Qualified';
        lead4.Core_Lead_State__c='In Persuit';
        lead4.Core_Rejection_Comments__c ='Test';
        lead4.OwnerId = System.Label.Core_Partner_Global_Queue_Id;
        lead4.Core_PSG_Lead__c = 'PSG';
        lstLeads.add(lead4);
        
        Lead lead5 = new Lead();
        lead5.RecordTypeId = r1.Id;
        lead5.FirstName = 'Test1';
        lead5.LastName = 'Test50psg';
        lead5.email = 'zdshyyj@gmail.com';
        lead5.Phone = '62434685690';
        lead5.Company = 'Test1zxdftgh';
        lead5.CountryCode = 'USA';
        lead5.LeadSource = 'Partner Program';
        lead5.Core_Partner_Name__c = 'TestPartner1';
        lead5.Status='PRL';
        lead5.Core_Lead_Status__c='New';
        lead5.Core_Lead_State__c='Unclaimed';
        lead5.Core_Rejection_Comments__c ='Test';
        lead5.OwnerId = System.Label.Core_Partner_Global_Queue_Id;
        lead5.Core_PSG_Lead__c = 'PSG';
        lstLeads.add(lead5);
        
        Lead lead6 = new Lead();
        lead6.RecordTypeId = r1.Id;
        lead6.FirstName = 'Test1';
        lead6.LastName = 'Test12';
        lead6.email = 'gerald.reinartz=intel.com@example.com';
        lead6.Phone = '123 4567';
        lead6.Company = 'Test1';
        lead6.CountryCode = 'USA';
        lead6.LeadSource = 'Partner Program';
        lead6.Status='PRL';
        lead6.Core_Lead_Status__c='New';
        lead6.Core_Lead_State__c='Unclaimed';
        lead6.Core_Rejection_Comments__c ='Test';
        lead6.PMP_Offering_Id__c = offeringRecord.PMP_Offering_Id__c;
        lead6.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
        lead6.Core_Partner_Name__c = partnerRec.Name;
        lead6.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
        lead6.Core_Notify_Owner__c = true;
        lstLeads.add(lead6);
        
        Lead lead7 = new Lead();
        lead7.RecordTypeId = r1.Id;
        lead7.FirstName = 'Test7';
        lead7.LastName = 'Test72';
        lead7.email = 'gerald.reinartz7=intel.com@example.com';
        lead7.Phone = '123 54356';
        lead7.Company = 'Test7';
        lead7.CountryCode = 'USA';
        lead7.LeadSource = 'Partner Program';
        lead7.Status='PRL';
        lead7.Core_Lead_Status__c='New';
        lead7.Core_Lead_State__c='Unclaimed';
        lead7.Core_Rejection_Comments__c ='Test';
        lead7.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
        lead7.Core_Notify_Owner__c = true;
        lstLeads.add(lead7);
        
        Lead lead8 = new Lead();
        lead8.RecordTypeId = r1.Id;
        lead8.FirstName = 'Test8';
        lead8.LastName = 'Test82';
        lead8.email = 'gerald.reinartz8=intel.com@example.com';
        lead8.Phone = '123 854453';
        lead8.Company = 'Test8';
        lead8.CountryCode = 'USA';
        lead8.LeadSource = 'Partner Program';
        lead8.Status='PRL';
        lead8.Core_Lead_Status__c='New';
        lead8.Core_Lead_State__c='Unclaimed';
        lead8.Core_Rejection_Comments__c ='Test';
        lead8.Core_Partner_Name__c = partQueueMap1.Core_Partner_Name__c;
        lead8.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
        lead8.Core_Notify_Owner__c = true;
        lstLeads.add(lead8);
        
        Lead lead9 = new Lead();
        lead9.RecordTypeId = r1.Id;
        lead9.FirstName = 'Test9';
        lead9.LastName = 'Test92';
        lead9.email = 'gerald.reinartz9=intel.com@example.com';
        lead9.Phone = '123 343567';
        lead9.Company = 'Test9';
        lead9.CountryCode = 'USA';
        lead9.LeadSource = 'Partner Program';
        lead9.Status='PRL';
        lead9.Core_Lead_Status__c='New';
        lead9.Core_Lead_State__c='Unclaimed';
        lead9.Core_Rejection_Comments__c ='Test';
        lead9.Core_Partner_Name__c = 'Invalid Partner Queue Name';
        lead9.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
        lead9.Core_Notify_Owner__c = true;
        lstLeads.add(lead9);
        system.assertEquals(9, lstLeads.size());
        
        system.runAs(us){
            insert lstLeads;
        }
        
        
    }
    
    static testMethod void partnerLeadTest1() {
        test.startTest();
        List<Lead> leadList = [select Id, FirstName, LastName, Company, Core_Lead_Source_Pkt__c, Core_Lead_PMP_Action__c, createdDate, PMP_MDA_BizOrg_Id__c, Core_Partner_Name__c, PMP_MktProfile_BizSegment__c, Core_Notify_Owner__c, Core_Public_Group_Id__c, Core_1st_Reminder__c, Core_2nd_Reminder__c, Core_3rd_Reminder__c, Core_4th_Reminder__c, Core_PSG_Lead__c, OwnerId from Lead];
        Core_PartnerLeadHandler.sendNotificationEmails(leadList,true);
        Core_PartnerLeadHandler.sendNotificationEmails(leadList,false);
        Core_PartnerLeadHandler.prepareDisplayableLeads('baseUrl','listViewUrl',leadList,'emailBody',false);
        Core_PartnerLeadHandler.prepareDisplayableLeads('baseUrl','listViewUrl',leadList,'emailBody',true);
        List<Lead> leadsToUpdate = new List<Lead>();
        leadList[0].Core_Lead_State__c = 'Terminated';
        leadList[0].Core_Rejection__c = 'Bad Data';
        leadsToUpdate.add(leadList[0]);
        leadList[1].Core_Lead_State__c = 'Terminated';
        leadList[1].Core_Rejection__c = 'Bad Data';
        leadsToUpdate.add(leadList[1]);
        leadList[2].Core_Lead_State__c = 'Terminated';
        leadList[2].Core_Rejection__c = 'Bad Data';
        leadsToUpdate.add(leadList[2]);
        update leadsToUpdate;
        System.assertEquals('Terminated', leadList[2].Core_Lead_State__c);
        test.stopTest();
    }
    
    static testMethod void partnerLeadTest2() {
        test.startTest();
        Database.executeBatch(new Core_PartnerLead_SummaryEmail(), 100);
        Database.executeBatch(new Core_PartnerLead_ReminderEmail(), 100);
        test.stopTest();
    }
    
    static testMethod void partnerLeadTest3() {
        Test.startTest(); 
        
        PMP_Partner_Offering__c Offering = new PMP_Partner_Offering__c();
        Offering.Name='Offering By Intel App1';
        Offering.PMP_Partner_Offering_Tag_Line_Txt__c='Hello This is tagline';
         Offering.PMP_Partner_Offering_Nm__c='Hello This is Offering Name';
       // Offering.PMP_Offering_Id__c='OFR-0000025';
        insert Offering;
        system.debug('Offering.id'+Offering.id);
         System.assertEquals('Hello This is tagline', Offering.PMP_Partner_Offering_Tag_Line_Txt__c);
        List<PMP_Category__c> Categorylst= new List<PMP_Category__c>();
        PMP_Category__c Cate = new PMP_Category__c(Name='OfferingCatergory1',PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_TYPE',PMP_Active_Ind__c=true);
        Categorylst.add(Cate);
        PMP_Category__c Cate1 = new PMP_Category__c(Name='OfferingCatergory2',PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_TYPE',PMP_Active_Ind__c=true);
        Categorylst.add(Cate1);
        PMP_Category__c Cate11 = new PMP_Category__c(Name='OfferingSubCatergory1',PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_TYPE',PMP_Active_Ind__c=true);
        Categorylst.add(Cate11);
        
        PMP_Category__c Ind = new PMP_Category__c(Name='Saleindustry',PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_Industry',PMP_Active_Ind__c=true);
        Categorylst.add(Ind);
        PMP_Category__c Ind1 = new PMP_Category__c(Name='Subindustry1',PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_Industry',PMP_Active_Ind__c=true);
        Categorylst.add(Ind1);
        PMP_Category__c Ind11 = new PMP_Category__c(Name='Subindustry2',PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_Industry',PMP_Active_Ind__c=true);
        Categorylst.add(Ind11);
        
        PMP_Category__c Ind111 = new PMP_Category__c(Name='SMarketingSubindustry123',PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_Industry',PMP_Active_Ind__c=true);
        Categorylst.add(Ind111);
        
        PMP_Category__c App = new PMP_Category__c(Name='OfferingApp',PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_APP',PMP_Active_Ind__c=true);
        Categorylst.add(App);
        
        PMP_Category__c App1 = new PMP_Category__c(Name='OfferingApp1',PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_APP',PMP_Active_Ind__c=true);
        Categorylst.add(App1);
        
        Insert Categorylst;
        
        List<PMP_Partner_Offering_Category__c> OfferingCategery= new List<PMP_Partner_Offering_Category__c>();
        PMP_Partner_Offering_Category__c OffcateA= new PMP_Partner_Offering_Category__c();
        OffcateA.Name='OfferingApp';
        OffcateA.PMP_Offering_Id__c=Offering.id;
        OffcateA.PMP_Ancestor_Category_Cd__c = 'NPP_01_APP';
        OffcateA.PMP_Category_Id__c=App.id;
        OfferingCategery.add(OffcateA);
        
        
        PMP_Partner_Offering_Category__c OffcateA1= new PMP_Partner_Offering_Category__c();
        OffcateA1.Name='OfferingApp1';
        OffcateA1.PMP_Offering_Id__c=Offering.id;
        OffcateA1.PMP_Ancestor_Category_Cd__c = 'NPP_01_APP';
        OffcateA1.PMP_Category_Id__c=App1.id;
        OfferingCategery.add(OffcateA1);
        
        PMP_Partner_Offering_Category__c Offcate= new PMP_Partner_Offering_Category__c();
        Offcate.Name='OfferingCatergory1';
        Offcate.PMP_Offering_Id__c=Offering.id;
        Offcate.PMP_Ancestor_Category_Cd__c  = 'NPP_01_TYPE';
        Offcate.PMP_Category_Id__c=Cate.id;
        OfferingCategery.add(Offcate);
        
        PMP_Partner_Offering_Category__c Offca= new PMP_Partner_Offering_Category__c();
        Offca.Name='OfferingCatergory2';
        Offca.PMP_Offering_Id__c=Offering.id;
        Offca.PMP_Ancestor_Category_Cd__c   = 'NPP_01_TYPE';
        Offca.PMP_Category_Id__c=Cate1.id;
        OfferingCategery.add(Offca);
        
        PMP_Partner_Offering_Category__c Offcate1= new PMP_Partner_Offering_Category__c();
        Offcate1.Name='OfferingSubCatergory1';
        Offcate1.PMP_Offering_Id__c=Offering.id;
        Offcate1.PMP_Ancestor_Category_Cd__c='NPP_01_TYPE | annjksjjkjhs';
        Offcate1.PMP_Category_Id__c=Cate11.id;
        OfferingCategery.add(Offcate1);
        
        PMP_Partner_Offering_Category__c Offcate2= new PMP_Partner_Offering_Category__c();
        Offcate2.Name='Saleindustry';
        Offcate2.PMP_Offering_Id__c=Offering.id;
        Offcate2.PMP_Ancestor_Category_Cd__c='NPP_01_Industry';
        Offcate2.PMP_Category_Id__c=Ind.id;
        OfferingCategery.add(Offcate2);
        
        PMP_Partner_Offering_Category__c Offcate3= new PMP_Partner_Offering_Category__c();
        Offcate3.Name='Subindustry1';
        Offcate3.PMP_Offering_Id__c=Offering.id;
        Offcate3.PMP_Ancestor_Category_Cd__c='NPP_01_Industry |jjsdsjjfd';
        Offcate3.PMP_Category_Id__c=Ind1.id;
        OfferingCategery.add(Offcate3);
        
        PMP_Partner_Offering_Category__c Offcate33= new PMP_Partner_Offering_Category__c();
        Offcate33.Name='Subindustry2';
        Offcate33.PMP_Offering_Id__c=Offering.id;
        Offcate33.PMP_Ancestor_Category_Cd__c='NPP_01_Industry |jjsdsjjfd';
        Offcate33.PMP_Category_Id__c=Ind11.id;
        OfferingCategery.add(Offcate33);
        
        
        PMP_Partner_Offering_Category__c Offcate4= new PMP_Partner_Offering_Category__c();
        Offcate4.Name='SMarketingSubindustry123';
        Offcate4.PMP_Offering_Id__c=Offering.id;
        Offcate4.PMP_Ancestor_Category_Cd__c='NPP_01_Industry |jjsdsjjfd';
        Offcate4.PMP_Category_Id__c=Ind111.id;
        
        OfferingCategery.add(Offcate4);
        
        Insert OfferingCategery;
        
        List<PMP_Specification__c> PMPSpec= new List<PMP_Specification__c>();
        PMP_Specification__c Sp= new PMP_Specification__c();
        Sp.Name='Regiontest';
        Sp.PMP_Active_Ind__c=true;
        PMPSpec.add(Sp);
        
        
        PMP_Specification__c Sp1= new PMP_Specification__c();
        Sp1.Name='SubRegiontest';
        Sp1.PMP_Active_Ind__c=true;
        PMPSpec.add(Sp1);
        PMP_Specification__c Sp11= new PMP_Specification__c();
        Sp11.Name='SubRegiontest123';
        Sp11.PMP_Active_Ind__c=true;
        PMPSpec.add(Sp11);
        
        Insert PMPSpec;
        
        List<PMP_Partner_Offering_Specification__c> OfferingSpec= new List<PMP_Partner_Offering_Specification__c>();
        PMP_Partner_Offering_Specification__c OffSpec= new PMP_Partner_Offering_Specification__c();
        OffSpec.Name='Regiontest';
        OffSpec.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage';
        OffSpec.PMP_Offering_Id__c=Offering.id;
        OffSpec.PMP_Specification_Id__c=Sp.id;
        OfferingSpec.add(OffSpec);
        
        PMP_Partner_Offering_Specification__c OffSpec1= new PMP_Partner_Offering_Specification__c();
        OffSpec1.Name='SubRegiontest';
        OffSpec1.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage | anjlsklkskl';
        OffSpec1.PMP_Offering_Id__c=Offering.id;
        OffSpec1.PMP_Specification_Id__c=Sp.id;
        //OffSpec1.PMP_Active_Ind__c=true;
        
        OfferingSpec.add(OffSpec1);
        
        PMP_Partner_Offering_Specification__c OffSpec11= new PMP_Partner_Offering_Specification__c();
        OffSpec11.Name='SubRegiontest123';
        OffSpec11.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage | anjlsklkskl';
        OffSpec11.PMP_Offering_Id__c=Offering.id;
        OffSpec11.PMP_Specification_Id__c=Sp11.id;
        //OffSpec1.PMP_Active_Ind__c=true;
        
        OfferingSpec.add(OffSpec11);
        
        Insert OfferingSpec;
        
        List<Lead> lstLeads = new List<Lead>();
        RecordType r1 = [Select Id from recordType where Name='Partner Lead'];
        Lead lead4 = new Lead();
        lead4.RecordTypeId = r1.Id;
        lead4.FirstName = 'Test1 Lead';
        lead4.LastName = 'Test5022';
        lead4.email = 'oiuytrett@gmail.com';
        lead4.Phone = '123 344567';
        lead4.Company = 'Test1zxdftgh2';
        lead4.CountryCode = 'USA';
        lead4.LeadSource = 'Partner Program';
        lead4.Core_Partner_Name__c = 'TestPartner1';
        lead4.Status='PRL';
        lead4.Core_Lead_Status__c='New';
        lead4.Core_Lead_State__c='Unclaimed';
        lead4.Core_Rejection_Comments__c ='Test';
        //lead4.Core_PSG_Lead__c = 'PSG';
        
        lead4.PMP_MDA_BizOrg_Id__c = 'testpatnerId1';
        lead4.Core_Partner_Name__c = 'testpartnername1';
        lead4.PMP_MktProfile_BizSegment__c = 'Data Center;Programmable Logic';
        lead4.PMP_MDA_BizOrg_Id__c = 'testpatnerId1';
        lead4.Core_Partner_Name__c = 'testpartnername1';
        lead4.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
       // lead4.PMP_Offering_Id__c=Offering.PMP_Offering_Id__c;
        lead4.PMP_Offering_Id__c=[Select PMP_Offering_Id__c from PMP_Partner_Offering__c where Name ='Offering By Intel App1' limit 1][0].PMP_Offering_Id__c;
        String PublicgroupId=[Select id,Name from Group where Name = 'Test_Group_1123' limit 1][0].id;
        lead4.Core_Notify_Owner__c=true;
        lead4.Core_Public_Group_Id__c=PublicgroupId;
        lead4.CreatedDate=system.now();
        lead4.Core_1st_Reminder__c=system.today();
        lead4.Core_2nd_Reminder__c=system.today();
        lead4.Core_3rd_Reminder__c=system.today();
        lead4.Core_4th_Reminder__c=system.today();
        lstLeads.add(lead4);
        insert lead4;
         System.assertEquals('New', lead4.Core_Lead_Status__c);
        system.debug('lead4'+lead4.Core_Public_Group_Id__c);
        Core_PartnerLeadHandler.sendNotificationEmails(lstLeads,true);
        Core_PartnerLeadHandler.sendNotificationEmails(lstLeads,false);
        Core_PartnerLeadHandler.prepareHtmlBody(lstLeads,true);
        Core_PartnerLeadHandler.prepareHtmlBody(lstLeads,false);
        //Core_PartnerLeadHandler.prepareHtmlBody(lstLeads,true,false);
        //Core_PartnerLeadHandler.prepareHtmlBody(lstLeads,false,false);
        //Core_PartnerLeadHandler.sendEmailNotification(lstLeads);
        Test.stopTest();
        
    }
    
    @future
    public static void insertPublicGroup(){
        //Create Parent Group
        Group grp = new Group();
        grp.name = 'Test_Group_1123';
        grp.Type = 'Regular'; 
        Insert grp; 
        
        //Create Group Member
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        grpMem1.GroupId = grp.Id;
        Insert grpMem1;
    }
    
}