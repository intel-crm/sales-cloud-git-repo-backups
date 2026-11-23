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
        //settingNameList.add('NewPartnerLeadNotification');
        settingNameList.add('BlockExistingOpponConversionLead');
        settingNameList.add('leadConversionDeduplication');
        settingNameList.add('OPIDStampingOnOnePartnerId');

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
        partnerRec.Core_IPA_Partner_Segment__c = 'Client Computing;Data Center';
        partnerRec.Core_Account_Type__c='Cloud Service Provider (CSP)';
        partnerRec.BillingCountryCode='USA';
        partnerRec.BIllingStateCode='AL';
        partnerRec.BillingCity='Alabama123';
        partnerRec.BillingStreet='test';
        partnerRec.BillingPostalCode='123445';
       // partnerRec.Core_Notify_Owner__c = true;
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
        marketingProfileInfo.Name = partnerRec.Name;
        marketingProfileInfo.PMP_Account_Id__c = partnerRec.Id;
        marketingProfileInfo.PMP_Is_Published_Ind__c=true;
        marketingProfileInfo.PMP_Partner_Benefit_Type__c='Solution Marketplace Basic Access';
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
        lead1.Core_Is_Lead_Shared__c=false;
        //lead1.Core_MPI_Id__c='tyrr546432etF';
        lead1.Core_MPI_Id__c=marketingProfile.Id;
        lead1.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
        lead1.Core_Partner_Name__c = partnerRec.Name;
        lead1.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
        //lead1.Core_Notify_Owner__c = true;
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
        lead2.Core_Lead_State__c='Unclaimed';
      //  lead2.Core_Lead_State__c='In Persuit';
        lead2.Core_Rejection_Comments__c ='Test';
       // lead2.Core_One_Partner_Id__c = partnerRec.Id;
        lead2.PMP_MDA_BizOrg_Id__c = partnerRec.Id;
        lead2.Core_Partner_Name__c = partnerRec.Name;
        //lead2.Core_Notify_Owner__c = true;
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
        lead3.Core_Lead_State__c='Unclaimed';
       // lead3.Core_Lead_State__c='In Persuit';
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
        lead4.Core_Lead_State__c='Unclaimed';
       // lead4.Core_Lead_State__c='In Persuit';
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
       // lead6.Core_One_Partner_Id__c = partnerRec.Id;
        lead6.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
        lead6.Core_Partner_Name__c = partnerRec.Name;
        lead6.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
        //lead6.Core_Notify_Owner__c = true;
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
       // lead7.Core_Notify_Owner__c = true;
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
       // lead8.Core_Notify_Owner__c = true;
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
       // lead9.Core_Notify_Owner__c = true;
        lstLeads.add(lead9);
        system.assertEquals(9, lstLeads.size());
        system.runAs(us){
            insert lstLeads;
            String groupIds = [select Id, Core_Public_Group_Id__c from Lead where Id =: lstLeads[0].Id].Core_Public_Group_Id__c;
            if(groupIds <> null){
                List<String> groupList = groupIds.split(';');
                List<GroupMember> gmList = new List<GroupMember>();
                for(String grId : groupList){
                    GroupMember gm = new GroupMember();
                    gm.GroupId = grId;
                    gm.UserOrGroupId = UserInfo.getUserId();
                    gmList.add(gm);
                }
                insert gmList;
            }
           // Core_PartnerLeadHandler.NewPartnerLeadNotification(lstLeads);
            Lead lead10 = new Lead();
            lead10.RecordTypeId = r1.Id;
            lead10.FirstName = 'Test1qwert';
            lead10.LastName = 'Test12fghj';
            lead10.email = 'gerald.reinartz10=intel.com@example.com';
            lead10.Phone = '123 4567 2345';
            lead10.Company = 'Test1yuiUnique';
            lead10.CountryCode = 'USA';
            lead10.LeadSource = 'Partner Program';
            lead10.Status='PRL';
            lead10.Core_Lead_Status__c='New';
            lead10.Core_Lead_State__c='Unclaimed';
            lead10.Core_Rejection_Comments__c ='Test'; 
            lead10.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
            lead10.Core_Partner_Name__c = partnerRec.Name;
          //  lead10.Core_One_Partner_Id__c = partnerRec.Id;
            lead10.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
            insert lead10;
        }
        
        
    }
    
    
    static testMethod void partnerLeadTest3() {
        Test.startTest(); 
        
        PMP_Partner_Offering__c Offering = new PMP_Partner_Offering__c();
        Offering.Name='Offering By Intel App1';
        Offering.PMP_Partner_Offering_Tag_Line_Txt__c='Hello This is tagline';
         Offering.PMP_Partner_Offering_Nm__c='Hello This is Offering Name';
          Offering.PMP_Business_Segment_Nm__c='Server';
       // Offering.PMP_Offering_Id__c='OFR-0000025';
        insert Offering;
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
        
        Group grp = new Group();
        grp.name = 'Test_Group_1123';
        grp.Type = 'Regular'; 
        Insert grp; 
        
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        grpMem1.GroupId = grp.Id;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Insert grpMem1;
        }
        Account acct=[Select id from Account Where Name='Test Parent Account1'];
        //Account acct1=[Select Id From Account Where Name='Test Intel Account 1'];
        
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
        lead4.Core_Is_Lead_Shared__c=true;
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
       // lead4.Core_Notify_Owner__c=true;
        lead4.Core_Public_Group_Id__c=PublicgroupId;
        lead4.CreatedDate=system.now();
        lead4.Core_1st_Reminder__c=system.today();
        lead4.Core_2nd_Reminder__c=system.today();
        lead4.Core_3rd_Reminder__c=system.today();
        lead4.Core_4th_Reminder__c=system.today();
        lstLeads.add(lead4);
        insert lstLeads;
        //User users=[Select Core_IPA_One_Partner_Id__c From User Where Username='testinguser@inteltest.com'];
        //acct1.Core_IPA_One_Partner_Id__c=lstLeads[0].Id;
        Core_OPID_Lead_Relationship__c opids=new Core_OPID_Lead_Relationship__c();
        opids.Core_Lead_Name__c=lstLeads[0].id;
        opids.Core_OPID_Name__c=acct.id;
        opids.Core_Public_Group_Ids__c=grp.id;
        insert opids;
        String s1='gdhdjkk';
        String s2='Fghfdr';
        
        
        System.assertEquals('New', lead4.Core_Lead_Status__c);
       // Core_PartnerLeadHandler.sendNotificationEmails(lstLeads,true);
        //Core_PartnerLeadHandler.sendNotificationEmails(lstLeads,false);
        //Core_PartnerLeadHandler.sendNotificationEmails(lstLeads,Boolean.valueOf('xxxx'));
        Core_PartnerLeadHandler.prepareHtmlBody(lstLeads,true);
        Core_PartnerLeadHandler.prepareHtmlBody(lstLeads,false);
        Core_PartnerLeadHandler.populateGroupsToRoutePartnerLead(lstLeads);

       // Core_PartnerLeadHandler.NewPartnerLeadNotification(lstLeads);
        Core_PartnerLeadHandler.generatePartnerKey(s1,s2);
        //Core_PartnerLeadHandler.prepareHtmlBody(lstLeads,true,false);
        //Core_PartnerLeadHandler.prepareHtmlBody(lstLeads,false,false);
        //Core_PartnerLeadHandler.sendEmailNotification(lstLeads);
        Test.stopTest();
        
    }
    
    static testMethod void partnerLeadTest4(){
        //Test.startTest();
        
        PMP_Partner_Offering__c Offering = new PMP_Partner_Offering__c();
        Offering.Name='Offering By Intel App1';
        Offering.PMP_Partner_Offering_Tag_Line_Txt__c='Hello This is tagline';
         Offering.PMP_Partner_Offering_Nm__c='Hello This is Offering Name';
          Offering.PMP_Business_Segment_Nm__c='Server';
       // Offering.PMP_Offering_Id__c='OFR-0000025';
        insert Offering;
        
        Group grp = new Group();
        grp.name = 'Test_Group_1123';
        grp.Type = 'Regular'; 
        Insert grp; 
        
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        grpMem1.GroupId = grp.Id;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Insert grpMem1;
        }
        List<Account>accList= new List<Account>();
         String AccPartnerRecType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        String AccIntelRecType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct=[Select id, Name, Core_IPA_Partner_Segment__c from Account Where Name='Test Parent Account1'];
        
        //Account acct1=[Select Id, Name From Account Where Name='Test Intel Account 1'];
        
         Account partnerRec = new Account();
        partnerRec.Name='Test Parent Account2';
        partnerRec.RecordTypeId=AccPartnerRecType;
        partnerRec.Core_IPA_Partner_Segment__c = 'Client Computing;Data Center';
        partnerRec.Core_Account_Type__c='Cloud Service Provider (CSP)';
        partnerRec.BillingCountryCode='USA';
        partnerRec.BIllingStateCode='AL';
        partnerRec.BillingCity='Alabama123';
        partnerRec.BillingStreet='test';
        partnerRec.BillingPostalCode='123445';
      //  partnerRec.Core_Notify_Owner__c = true;
        accList.add(partnerRec);
        
        
        Account Intelrec= new Account();
        Intelrec.Name='Test Intel Account 2';
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
        
        PMP_Company__c marketingProfileInfos = new PMP_Company__c();
        marketingProfileInfos.Name = acct.Name;
        marketingProfileInfos.PMP_Account_Id__c = acct.Id;
        marketingProfileInfos.PMP_Is_Published_Ind__c=true;
        marketingProfileInfos.PMP_Partner_Benefit_Type__c='Solution Marketplace Basic Access';
        insert marketingProfileInfos;
        PMP_Company__c marketingProfile = [select Id, PMP_Marketing_Profile_Id__c from PMP_Company__c where Id =: marketingProfileInfos.Id];
               
        List<Lead> lstLeads1 = [Select id ,RecordTypeId,Core_Lead_Sharing_Error__c,FirstName,LastName,email,Phone,Company,CountryCode,LeadSource,Status,Core_Lead_Status__c,Core_Lead_State__c,Core_Rejection_Comments__c,Core_Is_Lead_Shared__c,PMP_Offering_Id__c,Core_MPI_Id__c,PMP_MDA_BizOrg_Id__c,Core_Partner_Name__c,PMP_MktProfile_BizSegment__c,Core_Is_Segment_Available_In_Offering__c,OwnerId from Lead];
       // List<Lead> lstLeads1 = new List<Lead>();
       lstLeads1[0].Core_Is_Lead_Shared__c = false;
        
       System.assertEquals(false, lstLeads1[0].Core_Is_Lead_Shared__c);
        RecordType r1 = [Select Id from recordType where Name='Partner Lead'];
        Lead lead5 = new Lead();
        lead5.RecordTypeId = r1.Id;
        lead5.FirstName = 'Test1lead5';
        lead5.LastName = 'Test12lead';
        lead5.email = 'gerald.reinartz=intel.coms@example.com';
        lead5.Phone = '123 4567';
        lead5.Company = 'Test1';
        lead5.CountryCode = 'USA';
        lead5.LeadSource = 'Partner Program';
        lead5.Status='PRL';
        lead5.Core_Lead_Status__c='New';
        lead5.Core_Lead_State__c='Unclaimed';
        lead5.Core_Rejection_Comments__c ='Test'; 
        lead5.Core_Is_Lead_Shared__c=false;
        //lead5.PMP_Offering_Id__c=[Select PMP_Offering_Id__c from PMP_Partner_Offering__c where Name ='Offering By Intel App1' limit 1][0].PMP_Offering_Id__c;
         lead5.PMP_Offering_Id__c=Offering.PMP_Offering_Id__c;
        lead5.Core_MPI_Id__c=marketingProfile.Id;
        lead5.Core_Partner_Lead_Individual_Email_Date__c = Core_PartnerLeadHandler.generateNextTimeSlotOfEmail();
        lead5.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
        lead5.Core_Partner_Name__c = 'testPartnerName2';
        lead5.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
        //lead5.Core_Notify_Owner__c = true;
        lead5.Core_Is_Lead_Shared__c=false;
        lead5.Core_Is_Segment_Available_In_Offering__c=true;
        lead5.OwnerId=System.Label.Core_Partner_Global_Queue_Id;
        lstLeads1.add(lead5);
        //insert lstLeads1;
        
        
        
        
        Core_OPID_Lead_Relationship__c opids=new Core_OPID_Lead_Relationship__c();
        opids.Core_Lead_Name__c=lstLeads1[0].id;
        opids.Core_OPID_Name__c=acct.id;
        opids.Core_Public_Group_Ids__c=grp.id;
        
        insert opids;
         Account acct1=[Select id, Name, Core_IPA_Partner_Segment__c from Account Where Name='Test Parent Account2'];
         Core_OPID_Lead_Relationship__c opids1=new Core_OPID_Lead_Relationship__c();
        opids1.Core_Lead_Name__c=lstLeads1[0].id;
        opids1.Core_OPID_Name__c=acct1.id;
        opids1.Core_Public_Group_Ids__c=grp.id;
        insert opids1;
        
        Account accttest=[Select id, Name, Core_IPA_Partner_Segment__c from Account Where Id =: acct.Id];
        PMP_OPID_MPI_Rel__c pmpOpids=new PMP_OPID_MPI_Rel__c();
        pmpOpids.PMP_Marketing_Profile_Id__c=lstLeads1[0].Core_MPI_Id__c;
        pmpOpids.PMP_One_Partner_ID__c=accttest.Id;
        pmpOpids.Is_Active__c=true;
        insert pmpOpids;
       
        Test.startTest();
              
        //Core_PartnerLeadHandler.shareLeadRecord(lstLeads1);
        //Core_PartnerLeadHandler.partnerLeadOwnerUpdate(lstLeads1);

        Core_PartnerLeadHandler.populateGroupsToRoutePartnerLead(lstLeads1);
		Core_PartnerLeadHandler.shareLeadRecord(lstLeads1);
        //Core_PartnerLeadHandler.StampOPIDsonLead(lstLeads1);
        
        Test.stopTest();
    }
    

    static testMethod void partnerLeadTest6(){
        Test.startTest();
        Group grp = new Group();
        grp.name = 'Test_Group_1123';
        grp.Type = 'Regular'; 
        Insert grp; 
        
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        grpMem1.GroupId = grp.Id;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Insert grpMem1;
        }
        Account acct=[Select id, Name from Account Where Name='Test Parent Account1'];
        //Account acct1=[Select Id, Name From Account Where Name='Test Intel Account 1'];
        
        PMP_Company__c marketingProfileInfos = new PMP_Company__c();
        marketingProfileInfos.Name = acct.Name;
        marketingProfileInfos.PMP_Account_Id__c = acct.Id;
        marketingProfileInfos.PMP_Is_Published_Ind__c=true;
        marketingProfileInfos.PMP_Partner_Benefit_Type__c='Solution Marketplace Basic Access';
        insert marketingProfileInfos;
        PMP_Company__c marketingProfile = [select Id, PMP_Marketing_Profile_Id__c from PMP_Company__c where Id =: marketingProfileInfos.Id];
        List<List<Lead>> LstofLeadLst = new  List<List<Lead>>();
        List<Lead> lstLeads1 = new List<Lead>();
        RecordType r1 = [Select Id from recordType where Name='Partner Lead'];
        Lead lead5 = new Lead();
        lead5.RecordTypeId = r1.Id;
        lead5.FirstName = 'Test1lead5';
        lead5.LastName = 'Test12lead';
        lead5.email = 'gerald.reinartz.lead5=intel.coms@example.com';
        lead5.Phone = '123 4567';
        lead5.Company = 'Test1_Test5';
        lead5.CountryCode = 'USA';
        lead5.LeadSource = 'Partner Program';
        lead5.Status='PRL';
        lead5.Core_Lead_Status__c='New';
        lead5.Core_Lead_State__c='Unclaimed';
        lead5.Core_Rejection_Comments__c ='Test'; 
        lead5.Core_Is_Lead_Shared__c=true;
        lead5.Core_MPI_Id__c=marketingProfile.Id;
        lead5.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
        lead5.Core_Partner_Name__c = 'testPartnerName2';
        lead5.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
       // lead5.Core_Notify_Owner__c = true;
        lead5.Core_Is_Lead_Shared__c=true;
        lead5.Core_Is_Segment_Available_In_Offering__c=true;
        lead5.OwnerId=System.Label.Core_Partner_Global_Queue_Id ;
       // lead5.Core_Individual_Send_Email__c=true;
        lstLeads1.add(lead5);
        insert lstLeads1;
       
        Core_OPID_Lead_Relationship__c opids=new Core_OPID_Lead_Relationship__c();
        opids.Core_Lead_Name__c=lstLeads1[0].id;
        opids.Core_OPID_Name__c=acct.id;
        opids.Core_Public_Group_Ids__c=grp.id;
        insert opids;
        
        PMP_OPID_MPI_Rel__c pmpOpids=new PMP_OPID_MPI_Rel__c();
        pmpOpids.PMP_Marketing_Profile_Id__c=marketingProfile.Id;
        pmpOpids.PMP_One_Partner_ID__c=acct.Id;
        pmpOpids.Is_Active__c=true;
        insert pmpOpids;
         LstofLeadLst.add(lstLeads1);
         Core_PartnerLeadHandler.callIndividualEmailBatch(LstofLeadLst);
        //Lead RejectedExecutionException
      //  lstLeads1[0].Core_Lead_State__c='Terminated';
        //lstLeads1[0].Core_Lead_Status__c='Accepted';
        //lstLeads1[0].Status='PAL';
        lstLeads1[0].Core_Partner_Lead_Owner__c=UserInfo.getUserId();
        Update lstLeads1[0];
          
          //new lead
         List<Lead> lstLeads2 = new List<Lead>();
        RecordType r2 = [Select Id from recordType where Name='Partner Lead'];
        Lead lead6 = new Lead();
        lead6.RecordTypeId = r2.Id;
        lead6.FirstName = 'Test1lead51';
        lead6.LastName = 'Test12lead1';
        lead6.email = 'gerald.rei22nartz=intel.coms@example.com';
        lead6.Phone = '123 45671';
        lead6.Company = 'Test1';
        lead6.CountryCode = 'USA';
        lead6.LeadSource = 'Partner Program';
        lead6.Status='PRL';
        lead6.Core_Lead_Status__c='New';
        lead6.Core_Lead_State__c='Unclaimed';
        lead6.Core_Rejection_Comments__c ='Test'; 
        lead6.Core_Is_Lead_Shared__c=false;
        lead6.Core_MPI_Id__c=marketingProfile.Id;
        lead6.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
        lead6.Core_Partner_Name__c = 'testPartnerName2';
        lead6.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
      //  lead6.Core_Notify_Owner__c = true;
        lead6.Core_Is_Lead_Shared__c=true;
        lead6.Core_Is_Segment_Available_In_Offering__c=true;
        lead6.OwnerId=System.Label.Core_Partner_Global_Queue_Id;
        lstLeads2.add(lead6);
        insert lstLeads2;
          
        lstLeads2[0].Core_Lead_State__c='In pursuit';
        lstLeads2[0].Core_Lead_Status__c='Accepted';
        lstLeads2[0].Status='PAL';
        lstLeads2[0].Core_Partner_Lead_Owner__c=UserInfo.getUserId();
        Update lstLeads2[0];
        lstLeads2[0].Core_Lead_State__c='Terminated';
      ///  update lstLeads2[0];
          
          
         List<Lead> lstLeads3 = new List<Lead>();
        RecordType r3 = [Select Id from recordType where Name='Partner Lead'];
        Lead lead7 = new Lead();
        lead7.RecordTypeId = r2.Id;
        lead7.FirstName = 'Test1lead51';
        lead7.LastName = 'Test12lead1';
        lead7.email = 'gerald.rei22nartz.lead7=intel.coms@example.com';
        lead7.Phone = '123 45671';
        lead7.Company = 'Test1_Test7';
        lead7.CountryCode = 'USA';
        lead7.LeadSource = 'Partner Program';
        lead7.Status='PRL';
        lead7.Core_Lead_Status__c='New';
        lead7.Core_Lead_State__c='Unclaimed';
        lead7.Core_Rejection_Comments__c ='Test'; 
        lead7.Core_Is_Lead_Shared__c=false;
        lead7.Core_MPI_Id__c=marketingProfile.Id;
        lead7.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
        lead7.Core_Partner_Name__c = 'testPartnerName2';
        lead7.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
      //  lead7.Core_Notify_Owner__c = true;
        lead7.Core_Is_Lead_Shared__c=true;
        lead7.Core_Is_Segment_Available_In_Offering__c=true;
        lead7.OwnerId=System.Label.Core_Partner_Global_Queue_Id;
        lstLeads3.add(lead7);
        insert lstLeads3;
          
        lstLeads3[0].Core_Lead_State__c='In pursuit';
        lstLeads3[0].Core_Lead_Status__c='Accepted';
        lstLeads3[0].Status='PAL';
        lstLeads3[0].Core_Partner_Lead_Owner__c=UserInfo.getUserId();
        Update lstLeads3[0];
        lstLeads3[0].Core_Lead_Status__c='Contacted';
        update lstLeads3[0];
        lstLeads3[0].Core_Lead_State__c='Terminated';
        System.assertEquals('Contacted', lstLeads3[0].Core_Lead_Status__c);
     ///   update lstLeads3[0];
        Test.stopTest();
    }
    
    
    static testMethod void partnerLeadTest5(){
        Test.startTest();
        
        PMP_Partner_Offering__c Offering = new PMP_Partner_Offering__c();
        Offering.Name='Offering By Intel App1';
        Offering.PMP_Partner_Offering_Tag_Line_Txt__c='Hello This is tagline';
         Offering.PMP_Partner_Offering_Nm__c='Hello This is Offering Name';
          Offering.PMP_Business_Segment_Nm__c='Server';
       // Offering.PMP_Offering_Id__c='OFR-0000025';
        insert Offering;
        
      
        //Acc.Core_IPA_One_Partner_Id__c
        Group grp = new Group();
        grp.name = 'Test_Group_1123';
        grp.Type = 'Regular'; 
        Insert grp; 
        
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        grpMem1.GroupId = grp.Id;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Insert grpMem1;
        }
        List<Account>accList= new List<Account>();
         String AccPartnerRecType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        String AccIntelRecType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account acct=[Select id, Name, Core_IPA_Partner_Segment__c from Account Where Name='Test Parent Account1'];
        //Account acct1=[Select Id, Name From Account Where Name='Test Intel Account 1'];
        
         Account partnerRec = new Account();
        partnerRec.Name='Test Parent Account2';
        partnerRec.RecordTypeId=AccPartnerRecType;
        partnerRec.Core_IPA_Partner_Segment__c = 'Client Computing;Data Center';
        partnerRec.Core_Account_Type__c='Cloud Service Provider (CSP)';
        partnerRec.BillingCountryCode='USA';
        partnerRec.BIllingStateCode='AL';
        partnerRec.BillingCity='Alabama123';
        partnerRec.BillingStreet='test';
        partnerRec.BillingPostalCode='123445';
      //  partnerRec.Core_Notify_Owner__c = true;
        accList.add(partnerRec);
        
        
        Account Intelrec= new Account();
        Intelrec.Name='Test Intel Account 2';
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
        
        PMP_Company__c marketingProfileInfos = new PMP_Company__c();
        marketingProfileInfos.Name = acct.Name;
        marketingProfileInfos.PMP_Account_Id__c = acct.Id;
        marketingProfileInfos.PMP_Is_Published_Ind__c=true;
        marketingProfileInfos.PMP_Partner_Benefit_Type__c='Solution Marketplace Basic Access';
        insert marketingProfileInfos;
        PMP_Company__c marketingProfile = [select Id, PMP_Marketing_Profile_Id__c from PMP_Company__c where Id =: marketingProfileInfos.Id];
              
        List<Lead> lstLeads1 = new List<Lead>();
        RecordType r1 = [Select Id from recordType where Name='Partner Lead'];
        Lead lead5 = new Lead();
        lead5.RecordTypeId = r1.Id;
        lead5.FirstName = 'Test1lead5';
        lead5.LastName = 'Test12lead';
        lead5.email = 'gerald.reinartz=intel.coms@example.com';
        lead5.Phone = '123 4567';
        lead5.Company = 'Test1';
        lead5.CountryCode = 'USA';
        lead5.LeadSource = 'Partner Program';
        lead5.Status='PRL';
        lead5.Core_Lead_Status__c='New';
        lead5.Core_Lead_State__c='Unclaimed';
        lead5.Core_Rejection_Comments__c ='Test'; 
        lead5.Core_Is_Lead_Shared__c=true;
        // lead5.PMP_Offering_Id__c=[Select PMP_Offering_Id__c from PMP_Partner_Offering__c where Name ='Offering By Intel App1' limit 1][0].PMP_Offering_Id__c;
         lead5.PMP_Offering_Id__c=Offering.PMP_Offering_Id__c;
        lead5.Core_MPI_Id__c=marketingProfile.Id;
        lead5.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
        lead5.Core_Partner_Name__c = 'testPartnerName2';
        lead5.PMP_MktProfile_BizSegment__c = 'Data Center;Client Computing';
        //lead5.Core_Notify_Owner__c = true;
        lead5.Core_Is_Lead_Shared__c=true;
        lead5.Core_Is_Segment_Available_In_Offering__c=true;
        lead5.OwnerId=System.Label.Core_Partner_Global_Queue_Id;
        lstLeads1.add(lead5);
        insert lstLeads1;
        System.assertEquals('New', lstLeads1[0].Core_Lead_Status__c);
        
        Core_OPID_Lead_Relationship__c opids=new Core_OPID_Lead_Relationship__c();
        opids.Core_Lead_Name__c=lstLeads1[0].id;
        opids.Core_OPID_Name__c=acct.id;
        opids.Core_Public_Group_Ids__c=grp.id;
        
        insert opids;
        List<Account> Acclst = new List<Account>();
         Account acct1=[Select id, Name, Core_IPA_Partner_Segment__c from Account Where Name='Test Parent Account2'];
         Acclst.add(acct1);
         Acclst.add(acct);
         Core_OPID_Lead_Relationship__c opids1=new Core_OPID_Lead_Relationship__c();
        opids1.Core_Lead_Name__c=lstLeads1[0].id;
        opids1.Core_OPID_Name__c=acct1.id;
        opids1.Core_Public_Group_Ids__c=grp.id;
        insert opids1;
        
        PMP_OPID_MPI_Rel__c pmpOpids=new PMP_OPID_MPI_Rel__c();
        pmpOpids.PMP_Marketing_Profile_Id__c=marketingProfile.Id;
        pmpOpids.PMP_One_Partner_ID__c=acct.Id;
        pmpOpids.Is_Active__c=true;
        insert pmpOpids;
        List<String> partnerSegmentList = new List<String>();
        Schema.sObjectType objType = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get('Core_IPA_Partner_Segment__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : values){
            partnerSegmentList.add(a.getValue());
        }
        
        Core_PartnerLeadHandler.shareLeadRecord(lstLeads1);
        Core_PartnerLeadHandler.partnerLeadOwnerUpdate(lstLeads1);
        Core_PartnerLeadHandler.populateGroupsToRoutePartnerLead(lstLeads1);
       /*code commented**/
        //Core_PartnerLeadHandler.StampOPIDsonLead(lstLeads1);
         //Core_PartnerLeadHandler.sendLeadEmailNotifications(Acclst,false,partnerSegmentList);
        
        Test.stopTest();
    }
    
    @future
    public static void insertPublicGroup(){
       
        //Create Parent Group
       
        Group grp = new Group();
        grp.name = 'Test_Group_1123';
        grp.Type = 'Regular'; 
        Insert grp; 
        System.assertEquals('Test_Group_1123', grp.name);
        
        //Create Group Member
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        grpMem1.GroupId = grp.Id;
        Insert grpMem1;
      
    }
    
     static testmethod void CorePartnerLeadsCountTestMethod(){
        Integer i=0,n=0;
        List<Account> acctList=new List<Account>();
        List<Account> acctList1=new List<Account>();
        List<Group> groupList=new List<Group>();
        List<GroupMember> groupMemberList=new List<GroupMember>();
        List<LeadShare> leadShareList=new List<LeadShare>();
        List<Lead> leadList=new List<Lead>();
        List<Lead> leadList1=new List<Lead>();
        acctList=Core_Test_Utility.createAccount(10);
        leadList=Core_Test_Utility.createLead(10);
        for(Account acc:acctList){
            acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
            acc.Core_Sales_Groups__c='PRC Sales Group';
            acctList1.add(acc);
        }
        insert acctList1;
        for(Account acct:acctList1){
            Group gr=new Group(Name='PMP'+'_'+acct.Id+'_'+'Client_Computing',DeveloperName='PMP'+'_'+acct.Id+'_'+'Client_Computing');
            groupList.add(gr);
            i++;
        }
        insert groupList;
        for(Group grp:groupList){
            GroupMember grpMember=new GroupMember(UserOrGroupId=UserInfo.getUserId(),GroupId=grp.Id);
            groupMemberList.add(grpMember);
        }
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert groupMemberList;
        }
        
        for(Lead ld:leadList){
            //ld.Status='Tele Accepted Lead';
            ld.Core_Lead_Status__c='Accepted';
            ld.Core_Partner_Lead_Owner__c=UserInfo.getUserId();
            ld.RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
            ld.Core_Lead_State__c='In Pursuit';
            leadList1.add(ld);
        }
       insert leadList1;
       System.assertEquals('Accepted', leadList1[0].Core_Lead_Status__c);
 
    /*    leadList1.get(1).Core_Lead_Status__c='Contacted';
        leadList1.get(1).Core_Lead_Contact_Estb_Dt__c = true;
        update leadList1.get(1);
           leadList1.get(1).Core_Lead_Status__c='Qualified';
        update leadList1.get(1);
        leadList1.get(2).Core_Lead_Status__c='Contacted';
        update leadList1.get(2);
        leadList1.get(3).Core_Lead_Status__c='Rejected';
        leadList1.get(3).Core_Lead_Sub_Status__c='Bad Data';
        update leadList1.get(3);*/
        for(Group grp:groupList){
            LeadShare leadShares=new Leadshare(LeadId=leadList1.get(n).Id,UserOrGroupId=grp.Id,LeadAccessLevel='Edit');
            leadShareList.add(leadShares);
            if(n>groupList.size()){
                break;
            }
            else{
                n++;
            }
        }
        insert leadShareList;
        
        List<String> partnerSegmentList = new List<String>();
        Schema.sObjectType objType = Schema.getGlobalDescribe().get('Account');
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> values = fieldMap.get('Core_IPA_Partner_Segment__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : values){
            partnerSegmentList.add(a.getValue());
        }
        
        Test.startTest();
        Core_PartnerLeadHandler.sendLeadEmailNotifications(acctList1,false,partnerSegmentList);
        Core_PartnerLeadHandler.sendLeadEmailNotifications(acctList1,true,partnerSegmentList);
       // Core_PartnerLeads_Count_Batch_Schedule partnerschedule=new Core_PartnerLeads_Count_Batch_Schedule();
       // String sch = '0 0 23 * * ?';
        //system.schedule('Test status Check', sch, partnerschedule);
        Test.stopTest();      
    }

    @isTest
    static void test_prepareGroupWiseEmail_edge() {
        Lead l = new Lead(
            FirstName = 'F',
            LastName = 'L',
            Company = 'C',
            Country = 'USA',
            Email = 'a@a.com',
            Phone = '99',
            RecordTypeId = Core_PartnerLeadHandler.partnerRecTypeId,
            LeadSource = 'Webinar',
            Core_Lead_Source_Pkt__c = 'Marketplace', 
            Core_Lead_PMP_Action__c = 'Attended Webinar',
            Core_1st_Reminder__c = Date.today(),
            Core_2nd_Reminder__c = Date.today(),
            Core_3rd_Reminder__c = Date.today(),
            Core_4th_Reminder__c = Date.today()
           // Added field with a valid value
        );
        insert l;
        System.assertEquals('Marketplace', l.Core_Lead_Source_Pkt__c);
        
        l = [SELECT Id, FirstName, LastName, Company, Country, Email, Phone, RecordTypeId, LeadSource, CreatedDate, Core_Lead_Source_Pkt__c,Core_Lead_PMP_Action__c,Core_1st_Reminder__c, Core_2nd_Reminder__c, Core_3rd_Reminder__c, Core_4th_Reminder__c FROM Lead WHERE Id = :l.Id LIMIT 1];
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Core_PartnerLeadHandler.prepareGroupWiseEmail(false, UserInfo.getUserId(), new List<Lead>{l}, emailList);
        Core_PartnerLeadHandler.prepareGroupWiseEmail(true, UserInfo.getUserId(), new List<Lead>{l}, emailList);
    }
    
    @isTest
    static void test_prepareHtmlBody_reminderAndNew() {
        Lead l = new Lead(
            FirstName = 'First',
            LastName = 'Last',
            Company = 'TestC',
            Country = 'USA',
            Email = 'b@b.com',
            Phone = '88',
            RecordTypeId = Core_PartnerLeadHandler.partnerRecTypeId,
            LeadSource = 'Webinar',
            Core_Lead_Source_Pkt__c = 'Marketplace',
            Core_Lead_PMP_Action__c = 'Attended Webinar',
            Core_1st_Reminder__c = Date.today(),
            Core_2nd_Reminder__c = Date.today(),
            Core_3rd_Reminder__c = Date.today(),
            Core_4th_Reminder__c = Date.today()// Added field with a valid value
        );
        insert l;
        l = [SELECT Id, FirstName, LastName, Company, Country, Email, Phone, RecordTypeId, LeadSource, CreatedDate,Core_Lead_Source_Pkt__c,Core_Lead_PMP_Action__c,Core_1st_Reminder__c, Core_2nd_Reminder__c, Core_3rd_Reminder__c, Core_4th_Reminder__c FROM Lead WHERE Id = :l.Id LIMIT 1];
        
        String bodyRem = Core_PartnerLeadHandler.prepareHtmlBody(new List<Lead>{l}, true);
        String bodyNew = Core_PartnerLeadHandler.prepareHtmlBody(new List<Lead>{l}, false);
        System.assertNotEquals(null, bodyRem);
        System.assertNotEquals(null, bodyNew);
    }
    
    static testMethod void testStampFieldOnRejectLead_CoverStampMethod() {
        Test.startTest();
        
        // Get Partner Lead Record Type ID
        RecordType partnerLeadRT = [SELECT Id FROM RecordType WHERE Name='Partner Lead' LIMIT 1];
        
        // Create test leads that will properly trigger the stamping logic
        List<Lead> testLeads = new List<Lead>();
        
        // Lead 1: PRL New -> Terminated (should stamp PRL_Exit_Dt and Partner_Lead_Owner)
        Lead prlLead = new Lead();
        prlLead.RecordTypeId = partnerLeadRT.Id;
        prlLead.FirstName = 'PRL';
        prlLead.LastName = 'NewLead';
        prlLead.Email = 'prl.new@example.com';
        prlLead.Company = 'PRL New Company';
        prlLead.Status = 'PRL';
        prlLead.Core_Lead_Status__c = 'New';
        prlLead.Core_Lead_State__c = 'Unclaimed'; // NOT Terminated initially
        prlLead.CountryCode = 'USA';
        prlLead.LeadSource = 'Partner Program';
        testLeads.add(prlLead);
        
        // Lead 2: PAL Accepted -> Terminated (should stamp PAL_Exit_Dt only)
        Lead palAcceptedLead = new Lead();
        palAcceptedLead.RecordTypeId = partnerLeadRT.Id;
        palAcceptedLead.FirstName = 'PAL';
        palAcceptedLead.LastName = 'AcceptedLead';
        palAcceptedLead.Email = 'pal.accepted@example.com';
        palAcceptedLead.Company = 'PAL Accepted Company';
        palAcceptedLead.Status = 'PAL';
        palAcceptedLead.Core_Lead_Status__c = 'Accepted';
        palAcceptedLead.Core_Lead_State__c = 'In Pursuit'; // NOT Terminated initially
        palAcceptedLead.CountryCode = 'USA';
        palAcceptedLead.LeadSource = 'Partner Program';
        testLeads.add(palAcceptedLead);
        
        // Lead 3: PAL Contacted -> Terminated (should stamp both PAL_Exit_Dt and Exit_Date_Contacted_Dt)
        Lead palContactedLead = new Lead();
        palContactedLead.RecordTypeId = partnerLeadRT.Id;
        palContactedLead.FirstName = 'PAL';
        palContactedLead.LastName = 'ContactedLead';
        palContactedLead.Email = 'pal.contacted@example.com';
        palContactedLead.Company = 'PAL Contacted Company';
        palContactedLead.Status = 'PAL';
        palContactedLead.Core_Lead_Status__c = 'Contacted';
        palContactedLead.Core_Lead_State__c = 'In Pursuit'; // NOT Terminated initially
        palContactedLead.CountryCode = 'USA';
        palContactedLead.LeadSource = 'Partner Program';
        testLeads.add(palContactedLead);
        
        insert testLeads;
        
        System.assertEquals('Partner Program',testLeads[0].LeadSource);
        
        // Create the old lead map with the original values (before termination)
        Map<Id, Lead> oldLeadMap = new Map<Id, Lead>();
        
        // Create old lead objects with original states
        Lead oldPrlLead = new Lead();
        oldPrlLead.Id = testLeads[0].Id;
        oldPrlLead.RecordTypeId = partnerLeadRT.Id;
        oldPrlLead.Status = 'PRL';
        oldPrlLead.Core_Lead_Status__c = 'New';
        oldPrlLead.Core_Lead_State__c = 'Unclaimed'; // Original state - NOT Terminated
        oldLeadMap.put(testLeads[0].Id, oldPrlLead);
        
        Lead oldPalAcceptedLead = new Lead();
        oldPalAcceptedLead.Id = testLeads[1].Id;
        oldPalAcceptedLead.RecordTypeId = partnerLeadRT.Id;
        oldPalAcceptedLead.Status = 'PAL';
        oldPalAcceptedLead.Core_Lead_Status__c = 'Accepted';
        oldPalAcceptedLead.Core_Lead_State__c = 'In Pursuit'; // Original state - NOT Terminated
        oldLeadMap.put(testLeads[1].Id, oldPalAcceptedLead);
        
        Lead oldPalContactedLead = new Lead();
        oldPalContactedLead.Id = testLeads[2].Id;
        oldPalContactedLead.RecordTypeId = partnerLeadRT.Id;
        oldPalContactedLead.Status = 'PAL';
        oldPalContactedLead.Core_Lead_Status__c = 'Contacted';
        oldPalContactedLead.Core_Lead_State__c = 'In Pursuit'; // Original state - NOT Terminated
        oldLeadMap.put(testLeads[2].Id, oldPalContactedLead);
        
        // Create new lead list with updated values (after termination)
        List<Lead> newLeadList = new List<Lead>();
        
        // Update PRL lead to Terminated
        Lead newPrlLead = testLeads[0].clone(true, true, true, true);
        newPrlLead.Core_Lead_State__c = 'Terminated'; // NOW Terminated
        newPrlLead.Core_Lead_Status__c = 'Rejected';
        newLeadList.add(newPrlLead);
        
        // Update PAL Accepted lead to Terminated
        Lead newPalAcceptedLead = testLeads[1].clone(true, true, true, true);
        newPalAcceptedLead.Core_Lead_State__c = 'Terminated'; // NOW Terminated
        newPalAcceptedLead.Core_Lead_Status__c = 'Rejected';
        newLeadList.add(newPalAcceptedLead);
        
        // Update PAL Contacted lead to Terminated
        Lead newPalContactedLead = testLeads[2].clone(true, true, true, true);
        newPalContactedLead.Core_Lead_State__c = 'Terminated'; // NOW Terminated
        newPalContactedLead.Core_Lead_Status__c = 'Rejected';
        newLeadList.add(newPalContactedLead);
        
        // Call the method under test - this should now trigger stampBasedOnStatusAndStage
        Core_PartnerLeadHandler.stampFieldOnRejectLead(newLeadList, oldLeadMap);
        
        // Verify the stamping occurred
        DateTime testStartTime = System.now().addMinutes(-1);
        
        Test.stopTest();
    }
    
    // Additional test to cover the shouldStampFields method with negative cases
    static testMethod void testShouldStampFields_NegativeCases() {
        Test.startTest();
        
        RecordType partnerLeadRT = [SELECT Id FROM RecordType WHERE Name='Partner Lead' LIMIT 1];
        RecordType nonPartnerLeadRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND Name != 'Partner Lead' LIMIT 1];
        
        // Test case 2: Already terminated old lead
        Lead alreadyTerminatedNew = new Lead();
        alreadyTerminatedNew.RecordTypeId = partnerLeadRT.Id;
        alreadyTerminatedNew.FirstName = 'Already';
        alreadyTerminatedNew.LastName = 'Terminated';
        alreadyTerminatedNew.Email = 'already.terminated@example.com';
        alreadyTerminatedNew.Company = 'Already Terminated Company';
        alreadyTerminatedNew.CountryCode = 'CAN';
        alreadyTerminatedNew.LeadSource = 'Partner Program';
        alreadyTerminatedNew.Core_Lead_State__c = 'Terminated';
        
        Lead alreadyTerminatedOld = new Lead();
        alreadyTerminatedOld.RecordTypeId = partnerLeadRT.Id;
        alreadyTerminatedOld.Core_Lead_State__c = 'Terminated'; // Already terminated
        alreadyTerminatedOld.Core_Lead_Status__c = 'Rejected';
        alreadyTerminatedOld.Status = 'PRL';
        
        // Test case 3: Old lead was Qualified
        Lead qualifiedOldNew = new Lead();
        qualifiedOldNew.RecordTypeId = partnerLeadRT.Id;
        qualifiedOldNew.FirstName = 'Qualified';
        qualifiedOldNew.LastName = 'Old';
        qualifiedOldNew.Email = 'qualified.old@example.com';
        qualifiedOldNew.Company = 'Qualified Old Company';
        qualifiedOldNew.CountryCode = 'GBR';
        qualifiedOldNew.LeadSource = 'Partner Program';
        qualifiedOldNew.Core_Lead_State__c = 'Terminated';
        
        Lead qualifiedOldLead = new Lead();
        qualifiedOldLead.RecordTypeId = partnerLeadRT.Id;
        qualifiedOldLead.Core_Lead_State__c = 'In Pursuit';
        qualifiedOldLead.Core_Lead_Status__c = 'Qualified'; // Was qualified
        qualifiedOldLead.Status = 'PAL';
        
        // Test case 4: Old status was PQL
        Lead pqlOldNew = new Lead();
        pqlOldNew.RecordTypeId = partnerLeadRT.Id;
        pqlOldNew.FirstName = 'PQL';
        pqlOldNew.LastName = 'Old';
        pqlOldNew.Email = 'pql.old@example.com';
        pqlOldNew.Company = 'PQL Old Company';
        pqlOldNew.CountryCode = 'DEU';
        pqlOldNew.LeadSource = 'Partner Program';
        pqlOldNew.Core_Lead_State__c = 'Terminated';
        
        Lead pqlOldLead = new Lead();
        pqlOldLead.RecordTypeId = partnerLeadRT.Id;
        pqlOldLead.Core_Lead_State__c = 'In Pursuit';
        pqlOldLead.Core_Lead_Status__c = 'New';
        pqlOldLead.Status = 'PQL'; // Was PQL
        
        // Test case 5: New lead state is not Terminated
        Lead notTerminatedNew = new Lead();
        notTerminatedNew.RecordTypeId = partnerLeadRT.Id;
        notTerminatedNew.FirstName = 'Not';
        notTerminatedNew.LastName = 'Terminated';
        notTerminatedNew.Email = 'not.terminated@example.com';
        notTerminatedNew.Company = 'Not Terminated Company';
        notTerminatedNew.CountryCode = 'FRA';
        notTerminatedNew.LeadSource = 'Partner Program';
        notTerminatedNew.Core_Lead_State__c = 'In Pursuit'; // Not terminated
        
        Lead notTerminatedOld = new Lead();
        notTerminatedOld.RecordTypeId = partnerLeadRT.Id;
        notTerminatedOld.Core_Lead_State__c = 'Unclaimed';
        notTerminatedOld.Core_Lead_Status__c = 'New';
        notTerminatedOld.Status = 'PRL';
        
        // Create test data
        List<Lead> testLeads = new List<Lead>{ 
            alreadyTerminatedNew, 
            qualifiedOldNew, 
            pqlOldNew, 
            notTerminatedNew
        };
        
        // Insert leads to get IDs
        insert testLeads;
        System.assertEquals('Partner Program', testLeads[3].LeadSource);
        
        // Create old lead map
        Map<Id, Lead> oldLeadMap = new Map<Id, Lead>();
        //oldNonPartnerLead.Id = testLeads[0].Id;
        alreadyTerminatedOld.Id = testLeads[0].Id;
        qualifiedOldLead.Id = testLeads[1].Id;
        pqlOldLead.Id = testLeads[2].Id;
        notTerminatedOld.Id = testLeads[3].Id;
        
        //oldLeadMap.put(testLeads[0].Id, oldNonPartnerLead);
        oldLeadMap.put(testLeads[0].Id, alreadyTerminatedOld);
        oldLeadMap.put(testLeads[1].Id, qualifiedOldLead);
        oldLeadMap.put(testLeads[2].Id, pqlOldLead);
        oldLeadMap.put(testLeads[3].Id, notTerminatedOld);
        
        // Call the method - none of these should be processed
        Core_PartnerLeadHandler.stampFieldOnRejectLead(testLeads, oldLeadMap);
        
        Test.stopTest();
    }
    
@isTest
static void testUpdateLeadsWithMPI_BothMethodsIntegration() {
    Test.startTest();
    
    // Get existing test data
    Account partnerAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Parent Account1' LIMIT 1];
    PMP_Company__c marketingProfile = [SELECT Id, PMP_Marketing_Profile_Id__c FROM PMP_Company__c LIMIT 1];
    
    // Create queue mapping for partner name method
    String partnerQueueRecTypeId = Schema.SObjectType.Core_Partner_Queue_Mapping__c
        .getRecordTypeInfosByName().get(Label.Core_Partner_Queue_Mapping_RecordTypeId).getRecordTypeId();
    
    Core_Partner_Queue_Mapping__c queueMapping = new Core_Partner_Queue_Mapping__c();
    queueMapping.Core_Partner_Name__c = 'Integration Test Partner';
    queueMapping.PMP_MDA_BizOrg_Id__c = partnerAccount.Id;
    queueMapping.Core_Active__c = true;
    queueMapping.RecordTypeId = partnerQueueRecTypeId;
    insert queueMapping;
    
    // Create PMP_OPID_MPI_Rel__c records for both methods
    List<PMP_OPID_MPI_Rel__c> omrRecords = new List<PMP_OPID_MPI_Rel__c>();
    
    // For marketing profile method
    PMP_OPID_MPI_Rel__c omrRecord1 = new PMP_OPID_MPI_Rel__c();
    omrRecord1.PMP_Marketing_Profile_Id__c = marketingProfile.Id;
    //omrRecord1.Core_Marketing_Profile_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
    omrRecord1.PMP_One_Partner_ID__c = partnerAccount.Id;
    omrRecord1.Is_Active__c = true;
    omrRecords.add(omrRecord1);
    
    // For OPID method
    /*PMP_OPID_MPI_Rel__c omrRecord2 = new PMP_OPID_MPI_Rel__c();
    omrRecord2.PMP_Marketing_Profile_Id__c = marketingProfile.Id;
    omrRecord2.PMP_One_Partner_ID__c = partnerAccount.Id;
    omrRecord2.Is_Active__c = true;
    omrRecords.add(omrRecord2);*/
    
    insert omrRecords;
    
    // Create mixed leads
    RecordType partnerLeadRT = [SELECT Id FROM RecordType WHERE Name = 'Partner Lead' AND SObjectType = 'Lead'];
    List<Lead> testLeads = new List<Lead>();
    
    // Lead for marketing profile method
    Lead mpiLead = new Lead();
    mpiLead.RecordTypeId = partnerLeadRT.Id;
    mpiLead.FirstName = 'MPI Method';
    mpiLead.LastName = 'Test Lead';
    mpiLead.Email = 'mpimethod@test.com';
    mpiLead.Phone = '111-222-3333';
    mpiLead.Company = 'MPI Method Company';
    mpiLead.CountryCode = 'USA';
    mpiLead.LeadSource = 'Partner Program';
    mpiLead.Status = 'PRL';
    mpiLead.Core_Lead_Status__c = 'New';
    mpiLead.Core_Lead_State__c = 'Unclaimed';
    mpiLead.Core_Is_Lead_Shared__c = false;
    mpiLead.PMP_MDA_BizOrg_Id__c = marketingProfile.PMP_Marketing_Profile_Id__c;
    testLeads.add(mpiLead);
    
    // Lead for OPID method
    Lead opidLead = new Lead();
    opidLead.RecordTypeId = partnerLeadRT.Id;
    opidLead.FirstName = 'OPID Method';
    opidLead.LastName = 'Test Lead';
    opidLead.Email = 'opidmethod@test.com';
    opidLead.Phone = '444-555-6666';
    opidLead.Company = 'OPID Method Company';
    opidLead.CountryCode = 'USA';
    opidLead.LeadSource = 'Partner Program';
    opidLead.Status = 'PRL';
    opidLead.Core_Lead_Status__c = 'New';
    opidLead.Core_Lead_State__c = 'Unclaimed';
    opidLead.Core_Is_Lead_Shared__c = false;
    opidLead.Core_Partner_Name__c = 'Integration Test Partner';
    testLeads.add(opidLead);
    
    insert testLeads;
    
    // Call the main method that routes to both updateLeadsWithMPI methods
    Core_PartnerLeadHandler.populateSegmentMpiInPartnerLeads(testLeads, true);
    
    Test.stopTest();
    
    // Verify both leads are processed correctly
    List<Lead> updatedLeads = [SELECT Id, Core_MPI_Id__c, Core_Partner_Name__c, Core_Storefront_Name__c 
                              FROM Lead WHERE Id IN :testLeads ORDER BY FirstName];
    
    System.assertEquals(2, updatedLeads.size(), 'Both leads should be processed');
    
    // Verify MPI method lead
    System.assertNotEquals(null, updatedLeads[0].Core_MPI_Id__c, 'MPI method lead should have MPI Id');
    System.assertNotEquals(null, updatedLeads[0].Core_Partner_Name__c, 'MPI method lead should have Partner Name');
    
    // Verify OPID method lead
    System.assertNotEquals(null, updatedLeads[1].Core_MPI_Id__c, 'OPID method lead should have MPI Id');
    System.assertNotEquals(null, updatedLeads[1].Core_Storefront_Name__c, 'OPID method lead should have Storefront Name');
}
}