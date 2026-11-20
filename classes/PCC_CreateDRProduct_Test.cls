/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateDesignRegistration_Test 
Created Date        : June 2023
Function            : Test class for PCC_CreateDRProduct_Test
************************************************************************************************************************************************/

@isTest
public class PCC_CreateDRProduct_Test {
    @testsetup
    static void testSetup(){
         Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
          user sysadm=[select id,userRoleid from user where Profile.Name='System Administrator' and IsActive = true Limit 1 ];
        system.runas(sysadm){
        Account a2 = PRM_TestUtility.getAccount();
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Name='New Account';
        a2.Core_Account_Type__c ='Distributor';
        a2.Industry='Agriculture';
        a2.BillingCity='Goa';
        a2.BillingCountryCode='IND';
        a2.BillingStreet='4th Floor,New Road';
        a2.BillingPostalCode='110065';
        a2.BillingStateCode='KA';
        a2.Core_IPA_Partner_Role__c = 'Service Provider';
        a2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        a2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert a2;
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = a2.Id;
        c1.Email='test.user@intel.com';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_Partner_Role__c = 'Service Provider';
        c1.Email = 'test.diqhwqi@test.com';
        c1.MailingCountry='USA';
        insert c1;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Employee';
        ed1.Core_Display_Name__c='Employee';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed1;
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=c1.Id;
        cce.Core_Entitlement_Id__c = ed1.id;
        cce.Core_Status__c='Complete';
        cce.Core_Selected__c = true;
        cce.Core_Source__c = 'Entitlement';
        insert cce;
        
      
        UserRole ur = [Select Id From UserRole Where PortalType = 'Partner' Limit 1];
         Profile communityUsrProfile = [SELECT id FROM Profile WHERE Name='Partner'];
       
       
        User partnerUser = new User(FirstName='MrTest',LastName='User',alias='t2user',Email='test.diqhwqi@test.com',
                                    UserName='test2udwvgsr@xyz.com', ContactId=c1.Id,ProfileId=communityUsrProfile.Id,
                                    emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US',timezonesidkey='Europe/London',UserRoleId = ur.id);//, UserRoleId = r.id);
        
      //  insert partnerUser;
      //  Id userId=partnerUser.Id;
       }
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        
        Product2 pr = new Product2();
        pr.Name = 'Test data 1';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
        
        Product2 pr1 = new Product2();
        pr1.Name = 'Test data 2';
        pr1.IsActive = true;
        pr1.Core_Design_Registration_Eligible_Ind__c = true;
        pr1.Core_Avail_for_New_Designs__c = true;
        pr1.Core_Sales_Visible_Flag__c = true;
        insert pr1;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec.Core_Vertical_Market_Nm__c='Education';
        ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
        ddrRec.Core_Product_Application_Nm__c='Radar';
        ddrRec.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
        ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        ddrRec.PCC_End_Customer_Country__c ='India';
	ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='AMSTON LAKE';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec; 
       
        
        Product_MM_Attribute_Mapping__c pmam = new Product_MM_Attribute_Mapping__c();
        pmam.Ordering_Code__c = 'WX80660E52630V4';
        pmam.Name = '949344';
        pmam.MMID__c = '949344';
        pmam.L4_Product__c = pr.Id;
        
        insert pmam;
        
        Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
        pmam1.L5_Product__c = pr1.Id;
        pmam1.MMID__c = '12831';
        insert pmam1;
        
        Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
        DRproducts.Core_Design_Registration_Id__c = ddrRec.id;
        DRproducts.Core_Product_Id__c = pr1.Id;
        DRproducts.Core_Target_Resale_Amt__c = 20;
        DRproducts.Core_Full_Year_Qty__c = 3;
        DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
        DRproducts.Core_External_Id__c = 'shs002ABCD12LLLL';
        insert DRproducts;
    }
    
    @isTest 
    static void testgetDDRProductRecord2() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration-product/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id', '002OJKHHEIIWIaaa');
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDDRProducts_V1.getDDRProductRecord();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
    @isTest 
    static void testgetDDRProductRecord3() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration-product/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id', '');
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDDRProducts_V1.getDDRProductRecord();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
    @isTest 
    static void testgetDDRProductRecord4() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration-product/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('UniqueId', 'FSI002DDR');
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDDRProducts_V1.getDDRProductRecord();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
     @isTest 
    static void testgetDDRProductRecord5() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestUri = '/services/apexrest/v1.0/design-registration-product/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDDRProducts_V1.getDDRProductRecord();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
    @isTest 
    static void testgetDDRProductRecord1() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
       /* Product2 pr = new Product2();
        pr.Name = 'Test data';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec.Core_Vertical_Market_Nm__c='Education';
        ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
        ddrRec.Core_Product_Application_Nm__c='Radar';
        ddrRec.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
        ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec;        
        
        Core_Design_Registration_Product__c drProduct = new Core_Design_Registration_Product__c();
        drProduct.Core_Product_Id__c = pr.Id;
        drProduct.Core_Design_Registration_Id__c = ddrRec.Id;
        drProduct.Core_Full_Year_Qty__c= 1000;
        drProduct.Core_Retired_As_Of_Dt__c= Date.today();
        drProduct.Core_External_Id__c= '002uswLKJMgsi3HJK';
        drProduct.Core_Submission_Type__c = 'M2M';
        insert drProduct;
        
        Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
        pmam1.L5_Product__c = pr.Id;
        insert pmam1;
        
        PCC_DDR_L5_Product_Mapping__c dlpm = new PCC_DDR_L5_Product_Mapping__c();
        dlpm.PCC_Design_Registration__c = ddrRec.id;
        dlpm.PCC_Design_Registration_Product__c = drProduct.id;
        dlpm.PCC_Product_MM_Attribute_Mapping__c = pmam1.id;
        dlpm.PCC_MM_ID__c = pmam1.Name;
        dlpm.PCC_Ordering_Cd__c = pmam1.Ordering_Code__c;
        insert dlpm;*/
        list<Core_Design_Registration_Product__c> drProduct = [SELECT Id from Core_Design_Registration_Product__c limit 1];

        req.requestUri = '/services/apexrest/v1.0/design-registration-product/*'; // Replace with your actual endpoint
        req.httpMethod = 'GET';
        req.addParameter('id', drProduct[0].Id);
        
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        PCC_CreateDDRProducts_V1.getDDRProductRecord();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
    @isTest
    static void createDRProductTest1(){
        
        list<Core_Design_registration__c> ddrlst = [SELECT Id from Core_Design_registration__c limit 1];
        Core_Design_registration__c ddrRec = ddrlst[0];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"designRegId":"'+ddrRec.Id+'","mmId":"949348","oldMMId":"12831","quantity":"100","targetResalePrice":"100","comments":"Test DRP creation from M2M","partnerTrackingNumber":"100","externalId":"shs002ABCD12"},{"designRegId":"'+ddrRec.Id+'","oldMMId":"949344","quantity":"100","targetResalePrice":"100","comments":"Test DRP creation from M2M","partnerTrackingNumber":"100","externalId":"shs002ABC7652"},{"designRegId":"'+ddrRec.Id+'","oldMMId":"76543","quantity":"100","targetResalePrice":"100","comments":"Test DRP creation from M2M","partnerTrackingNumber":"100","externalId":"shs0TestDDpBCD12"},{"designRegId":"'+ddrRec.Id+'","mmId":"949348","quantity":"100","targetResalePrice":"100","comments":"Test DRP creation from M2M","partnerTrackingNumber":"100","externalId":"shs002ABCD12LLLL"},{"designRegId":"'+ddrRec.Id+'","mmId":"949348","quantity":"100","targetResalePrice":"ABD","comments":"Test DRP creation from M2M","partnerTrackingNumber":"100","externalId":"shs002ABCD12Tesr55"},{"designRegId":"'+ddrRec.Id+'","orderingCd":"WX80660E52630V4","targetResalePrice":"100","quantity":"ABC","externalId":"shs002ABCD299"},{"designRegId":"'+ddrRec.Id+'","orderingCd":"WX80660E52630V4","targetResalePrice":"ABC","quantity":"100","externalId":"shs002ABCD299"},{"designRegId":"'+ddrRec.Id+'","orderingCd":"WX80660E52630V4","quantity":"100","externalId":"shs002ABCD2"},{"designRegId":"'+ddrRec.Id+'","orderingCd":"CL8067702999011","quantity":"100","externalId":"shs00ABCD3"},{"designRegId":"ABCD","mmId":"924562","quantity":"100","externalId":"shs00ABCD5"},{"designRegId":"'+ddrRec.Id+'","mmId":"","quantity":"100","externalId":"shs002ABCD6"},{"designRegId":"'+ddrRec.Id+'","mmId":"924562","quantity":"","externalId":"shs002ABCD7"},{"designRegId":"'+ddrRec.Id+'","mmId":"924562","quantity":"100"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDDRProducts_V1.createDDRProductRecords();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
    @isTest
    static void createDRProductTest2(){
        /*ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;*/
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"designRegId":"a3D8A000000sdluUAA","externalId":"00JKGKLsdfghjmbvcKOL"}');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDDRProducts_V1.createDDRProductRecords();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    //Test PCC automation class DRP updating if DRP status is cancelled/rejected/abandoned
     @isTest
    static void updateDRProductTest(){
       /* Product2 pr1 = new Product2();
        pr1.Name = 'Test data 2';
        pr1.IsActive = true;
        pr1.Core_Design_Registration_Eligible_Ind__c = true;
        pr1.Core_Avail_for_New_Designs__c = true;
        pr1.Core_Sales_Visible_Flag__c = true;
        insert pr1;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec.Core_Vertical_Market_Nm__c='Education';
        ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
        ddrRec.Core_Product_Application_Nm__c='Radar';
        ddrRec.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
        ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec; 
        
        Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
        DRproducts.Core_Design_Registration_Id__c = ddrRec.id;
        DRproducts.Core_Product_Id__c = pr1.Id;
        DRproducts.Core_Target_Resale_Amt__c = 20;
        DRproducts.Core_Full_Year_Qty__c = 3;
        DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
        insert DRproducts;
        
        Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
        pmam1.L5_Product__c = pr1.Id;
        insert pmam1;*/
                list<Core_Design_Registration_Product__c> DRproducts = [SELECT Id from Core_Design_Registration_Product__c limit 1];

        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"recordId":"'+DRproducts[0].Id+'","mmId":"949348","quantity":"100","targetResalePrice":"100","comments":"Test DRP creation from M2M","partnerTrackingNumber":"100","externalId":"shs002ABCD12"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_AutomationUtility.updateFields(DRproducts[0].id,'Cancelled','Design Registration Product');
        PCC_CreateDDRProducts_V1.updateDDRProductRecord();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
   
    //Test PCC automation class DRP updating if DRP status is cancelled/rejected/abandoned exception
     @isTest
    static void updateDRProductTest1(){
       /* Product2 pr1 = new Product2();
        pr1.Name = 'Test data 2';
        pr1.IsActive = true;
        pr1.Core_Design_Registration_Eligible_Ind__c = true;
        pr1.Core_Avail_for_New_Designs__c = true;
        pr1.Core_Sales_Visible_Flag__c = true;
        insert pr1;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec.Core_Vertical_Market_Nm__c='Education';
        ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
        ddrRec.Core_Product_Application_Nm__c='Radar';
        ddrRec.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
        ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
       ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec; 
        
        Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
        DRproducts.Core_Design_Registration_Id__c = ddrRec.id;
        DRproducts.Core_Product_Id__c = pr1.Id;
        DRproducts.Core_Target_Resale_Amt__c = 20;
        DRproducts.Core_Full_Year_Qty__c = 3;
        DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
        insert DRproducts;
        
        Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
        pmam1.L5_Product__c = pr1.Id;
        insert pmam1;*/
                list<Core_Design_Registration_Product__c> DRproducts = [SELECT Id from Core_Design_Registration_Product__c limit 1];

        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"recordId":"'+DRproducts[0].Id+'","mmId":"949348","quantity":"100","targetResalePrice":"100","comments":"Test DRP creation from M2M","partnerTrackingNumber":"100","externalId":"shs002ABCD12"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_AutomationUtility.updateFields(DRproducts[0].id,'cancel','Design Registration Product');
        PCC_CreateDDRProducts_V1.updateDDRProductRecord();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
     @isTest
    static void updateDRProductTest2(){
       
        
       /* Product2 pr = new Product2();
        pr.Name = 'Test data 1';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
        
        Product2 pr1 = new Product2();
        pr1.Name = 'Test data 4';
        pr1.IsActive = true;
        pr1.Core_Design_Registration_Eligible_Ind__c = true;
        pr1.Core_Avail_for_New_Designs__c = true;
        pr1.Core_Sales_Visible_Flag__c = true;
        insert pr1;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec.Core_Vertical_Market_Nm__c='Education';
        ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
        ddrRec.Core_Product_Application_Nm__c='Radar';
        ddrRec.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
        ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
       ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        ddrRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec.Core_Design_Registration_Status_Nm__c='Draft';
        insert ddrRec; 
        
        Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
        DRproducts.Core_Design_Registration_Id__c = ddrRec.id;
        DRproducts.Core_Product_Id__c = pr1.Id;
        DRproducts.Core_Target_Resale_Amt__c = 20;
        DRproducts.Core_Full_Year_Qty__c = 3;
        DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
        insert DRproducts;
        
        Product_MM_Attribute_Mapping__c pmam = new Product_MM_Attribute_Mapping__c();
        pmam.Ordering_Code__c = 'WX80660E52630V4';
        pmam.MMID__c = '949344';
        pmam.L4_Product__c = pr.Id;
        insert pmam;
        
        Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
        pmam1.L5_Product__c = pr1.Id;
        insert pmam1;*/
        list<Core_Design_Registration_Product__c> DRproducts = [SELECT Id from Core_Design_Registration_Product__c limit 1];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"oldMMId":"949344","recordId":"'+DRproducts[0].Id+'"},{"orderingCd":"WX80550E52630V4","recordId":"'+DRproducts[0].Id+'"},{"quantity":"200","targetResalePrice":"200","recordId":"'+DRproducts[0].Id+'"},{"quantity":"200","designRegId":"a3D2D000000A35JUAS","targetResalePrice":"200","recordId":"'+DRproducts[0].Id+'"},{"mmId":"953354","recordId":"a3CDf000000UTpsLLL"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDDRProducts_V1.updateDDRProductRecord();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
     @isTest
    static void updateDRProductTest3(){
        
        
       /* Product2 pr = new Product2();
        pr.Name = 'Test data 1';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
        
        Product2 pr1 = new Product2();
        pr1.Name = 'Test data 3';
        pr1.IsActive = true;
        pr1.Core_Design_Registration_Eligible_Ind__c = true;
        pr1.Core_Avail_for_New_Designs__c = true;
        pr1.Core_Sales_Visible_Flag__c = true;
        insert pr1;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec.Core_Vertical_Market_Nm__c='Education';
        ddrRec.Core_Product_Segment_Nm__c='Embedded / IOT';
        ddrRec.Core_Product_Application_Nm__c='Radar';
        ddrRec.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
        ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
       ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        ddrRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec.Core_Design_Registration_Status_Nm__c='Draft';
        insert ddrRec; 
        
        Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
       // System.debug('here=='+TestDDRupdate_Rej[0].Core_Design_Registration_Status_Nm__c);
        DRproducts.Core_Design_Registration_Id__c = ddrRec.id;
        DRproducts.Core_Product_Id__c = pr1.Id;
        DRproducts.Core_Target_Resale_Amt__c = 20;
        DRproducts.Core_Full_Year_Qty__c = 3;
        DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
        insert DRproducts;
        
        
        
        Product_MM_Attribute_Mapping__c pmam = new Product_MM_Attribute_Mapping__c();
        pmam.Ordering_Code__c = 'WX80660E52630V4';
        pmam.Name = '949344';
        pmam.L4_Product__c = pr.Id;
        insert pmam;
        
        Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
        pmam1.L5_Product__c = pr1.Id;
        insert pmam1;
        
        PCC_DDR_L5_Product_Mapping__c dlpm = new PCC_DDR_L5_Product_Mapping__c();
        dlpm.PCC_Design_Registration__c = ddrRec.id;
        dlpm.PCC_Design_Registration_Product__c = DRproducts.id;
        dlpm.PCC_Product_MM_Attribute_Mapping__c = pmam1.id;
        dlpm.PCC_MM_ID__c = pmam1.Name;
        dlpm.PCC_Ordering_Cd__c = pmam1.Ordering_Code__c;
        insert dlpm;
        
        Map<Id, String> mapOfDRPIdtoProduct = new Map<Id, String>();
        mapOfDRPIdtoProduct.put(DRproducts.Id, DRproducts.Core_Product_Id__c);
        Map<String, Product_MM_Attribute_Mapping__c> mapOfProductToPM = new  Map<String, Product_MM_Attribute_Mapping__c>();
        mapOfProductToPM.put(pmam1.L5_Product__c, pmam1);*/
        
        list<Core_Design_Registration_Product__c> DRproducts = [SELECT Id from Core_Design_Registration_Product__c limit 1];
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"mmId":"949344","recordId":"'+DRproducts[0].Id+'"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDDRProducts_V1.updateDDRProductRecord();
        system.assertEquals(req, req, 'assert statement');
       // Core_DDR_Product_Handler.updateDDRL5Mappings(mapOfDRPIdtoProduct);
        Test.stopTest();
    }
    
    // @isTest
    /* static void updateDRProductTest4(){
        /*ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;*/
        
       /* Product2 pr1 = new Product2();
        pr1.Name = 'Test data 2';
        pr1.IsActive = true;
        pr1.Core_Design_Registration_Eligible_Ind__c = true;
        pr1.Core_Avail_for_New_Designs__c = true;
        pr1.Core_Sales_Visible_Flag__c = true;
        insert pr1;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec.Core_Vertical_Market_Nm__c='Education';
        ddrRec.Core_Product_Segment_Nm__c='Client Computing';
        ddrRec.Core_Product_Application_Nm__c='Business Desktop';
        ddrRec.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
        ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        insert ddrRec; 
        
        Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
        DRproducts.Core_Design_Registration_Id__c = ddrRec.id;
        DRproducts.Core_Product_Id__c = pr1.Id;
        DRproducts.Core_Target_Resale_Amt__c = 20;
        DRproducts.Core_Full_Year_Qty__c = 3;
        DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
        insert DRproducts; 
         
        Core_Design_Registration_Product__c DRproducts1 = new Core_Design_Registration_Product__c();
        DRproducts1.Core_Design_Registration_Id__c = ddrRec.id;
        DRproducts1.Core_Product_Id__c = pr1.Id;
        DRproducts1.Core_Target_Resale_Amt__c = 20;
        DRproducts1.Core_Full_Year_Qty__c = 3;
        DRproducts1.Core_Design_Product_Status_Nm__c = 'Pending';
        insert DRproducts1; 
         
        Core_Design_Registration_Product__c DRproducts2 = new Core_Design_Registration_Product__c();
        DRproducts2.Core_Design_Registration_Id__c = ddrRec.id;
        DRproducts2.Core_Product_Id__c = pr1.Id;
        DRproducts2.Core_Target_Resale_Amt__c = 20;
        DRproducts2.Core_Full_Year_Qty__c = 3;
        DRproducts2.Core_Design_Product_Status_Nm__c = 'Pending';
        insert DRproducts2; 
         
        DRproducts.Core_Design_Product_Status_Nm__c = 'Approved';
        update DRproducts;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('[{"targetResalePrice":"100","comments":"Test","partnerTrackingNumber":"0123","recordId":"'+DRproducts1.Id+'"},{"quantity":"100","recordId":"'+DRproducts.Id+'"},{"targetResalePrice":"Abc","recordId":"'+DRproducts2.Id+'"}]');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        PCC_CreateDDRProducts_V1.updateDDRProductRecord();
        Test.stopTest();
    }*/
    
    @isTest 
    static void testgetDDRProductRecord14() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        Product2 pr = new Product2();
        pr.Name = 'Test data';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
        
        Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
        pmam1.MMID__c = '949348';
        pmam1.L4_Product__c = pr.Id;
        pmam1.L5_Product__c = pr.Id;
        insert pmam1;
        
        req.addHeader('Content-Type', 'application/json'); // Add a JSON Header as it is validated
        req.requestURI = '/services/apexrest/v1.0/design-registration/product/*';
        req.addParameter('orderingcd','WX80550E52630V4');
        req.httpMethod = 'Get';
        
        
        RestContext.request = req;
        RestContext.response = res;     
        Test.startTest();
        PCC_CreateL4L5ProductsDetails_V1.getProductRecord();
        system.assertEquals(req, req, 'assert statement');
        Test.stopTest();
    }
    
    
     @isTest 
    static void testgetProductId() {  
        Map<String, String> specCdToProductIdMap = new Map<String, String>();
        Map<String, String> mmIdToProductIdMap= new Map<String, String>();
        Map<String, String> orderingCdToProductIdMap= new Map<String, String>();
        Map<String, String> oldMMIdToProductIdMap= new Map<String, String>();
        Map<String, String> prodStatusToProductIdMap= new Map<String, String>();
        Map<String, String> custIndToProductIdMap= new Map<String, String>();
        Map<String, Id> uniqueIdToAttributeMap= new Map<String, String>();

        Product2 pr1 = new Product2();
        pr1.Name = 'Test data 2';
        pr1.IsActive = true;
        pr1.Core_Design_Registration_Eligible_Ind__c = true;
        pr1.Core_Avail_for_New_Designs__c = true;
        pr1.Core_Sales_Visible_Flag__c = true;
        pr1.Core_Product_Type__c = 'Intel® FPGAs';
        insert pr1;
        
        Product_MM_Attribute_Mapping__c pmam1 = new Product_MM_Attribute_Mapping__c();
        pmam1.Ordering_Code__c = 'WX80550E52630V4';
        pmam1.Name = '949348';
        pmam1.L5_Product__c = pr1.Id;
        pmam1.Spec_Code__c = 'S';
        pmam1.Custom_Indicator__c = 'M';
        pmam1.Product_Status__c = 'RT';
        pmam1.MMID__c = '949348';
        insert pmam1;
         Product_MM_Attribute_Mapping__c pmam2 = new Product_MM_Attribute_Mapping__c();
        pmam2.Ordering_Code__c = 'WX80550E52630V4';
        pmam2.Name = '949368';
        pmam2.L5_Product__c = pr1.Id;
        pmam2.Custom_Indicator__c = 'M';
        pmam2.Product_Status__c = 'RT';
        pmam2.MMID__c = '949368';
        insert pmam2;
        specCdToProductIdMap.put(pmam1.L5_Product__r.id, 'Q');
        prodStatusToProductIdMap.put(pmam2.L5_Product__r.id, 'RT');
        PCC_CreateDRProductUtilityHandler_V1.Productwrapper pWrp = new PCC_CreateDRProductUtilityHandler_V1.Productwrapper();
               // PCC_CreateDRProductUtilityHandler_V1.Productwrapper pWrp2 = new PCC_CreateDRProductUtilityHandler_V1.Productwrapper();
        pWrp.specCdToProductIdMap = specCdToProductIdMap;
        pWrp.mmIdToProductIdMap = mmIdToProductIdMap;
        pWrp.orderingCdToProductIdMap = orderingCdToProductIdMap;
        pWrp.oldMMIdToProductIdMap = oldMMIdToProductIdMap;
        pWrp.prodStatusToProductIdMap = prodStatusToProductIdMap;
        pWrp.custIndToProductIdMap = custIndToProductIdMap;

        
        List<String> listOfOrderingCd = new List<String>();
        List<String> listOfMMId = new List<String>();
        List<String> listOfOldMMId = new List<String>();
        List<String> listOfMMId2 = new List<String>();
        listOfMMId.add('949348');listOfMMId2.add('949368');
        
        Test.startTest();
        PCC_CreateDRProductUtilityHandler_V1.getProductId(listOfOrderingCd, listOfMMId, listOfOldMMId);
                PCC_CreateDRProductUtilityHandler_V1.getProductId(listOfOrderingCd, listOfMMId2, listOfOldMMId);
        PCC_CreateDRProductUtilityHandler_V1.drEligible(pWrp, pmam1.L5_Product__r.id);
        system.assertEquals(pr1, pr1, 'assert statement');
        // PCC_CreateDRProductUtilityHandler_V1.drEligible(pWrp2, pmam2.L5_Product__r.id);
        Test.stopTest();

    }
    

    
}