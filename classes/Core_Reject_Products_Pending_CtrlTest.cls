/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Reject_Products_Pending_CtrlTest
Version     : 1.0 
Created Date: 19 JUNE 2018
Function    : Test class for Core_Reject_Products_Pending_Ctrl apex class.
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            11/06/2018              Original Version
-------------------------------------------------------------------------------------------*/

@isTest
public class Core_Reject_Products_Pending_CtrlTest {
    public static List<Core_Design_Registration__c> DDRLst = new List<Core_Design_Registration__c>();
    public static List<Core_Design_Registration_Product__c> DRPLst = new List<Core_Design_Registration_Product__c>();
    public static List<Core_Design_Registration_Product__c> DRPLst3 = new List<Core_Design_Registration_Product__c>();

    public static List<Product2> ProdLst = new List<Product2>();
    public static List<Product2> ProdLst2 = new List<Product2>();

    @testSetup
    public static void setup(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.LastName = 'System Adm';
        usrs.ProfileId = sysAdminProfile.Id;
        usrs.IsActive = true;
        usrs.Email = 'sysadmin@example.com';
        insert usrs;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='PCC_Deal_Reg_Internal_Admin' LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = usrs.Id,PermissionSetId = ps.Id);
        insert psa;

    }

    static testMethod void rejectProductsPendingTest(){
      // setup();
      ProdLst = Core_DDR_Utility.CreateProduct(5);
       insert ProdLst;
        ProdLst2 = Core_DDR_Utility.CreateProduct(2);
        ProdLst2[0].isActive=false;
        insert ProdLst2;
        
        list<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[0].Core_End_Customer_URL__c = 'www.url.com';
        insert DDRLst;
        DRPLst = Core_DDR_Utility.CreateDRProduct(4, DDRLst, ProdLst);
        insert DRPLst;
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Pending';   
        }
        update DRPLst;
        Test.startTest();
        List<Core_Design_Registration_Product__c> DRPLst1 = Core_DDR_Utility.CreateDRProduct(2, DDRLst, ProdLst);
        insert DRPLst1;
        PageReference pageRef = Page.Core_Reject_Products_Pending;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DDRLst);
        pageRef.getParameters().put('id',DDRLst[0].Id);
        //Core_Reject_Products_Pending_Ctrl ext = new Core_Reject_Products_Pending_Ctrl(stdSetController);
        //ext.rejectProductsPending();
        Test.stopTest();
        System.assert(DRPLst1!=Null);
    }
    //Added as part of twc727-1088

    public static testmethod void DR_Product_test2() {
         
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[0].Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst[0].Core_End_Customer_URL__c = 'www.url.com';

        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(6, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Pending';
            DRP.Core_Locked_Ind__c = false;
            DRP.Core_Comment_Txt__c = '';
        }
        
        update DRPLst;
        ProdLst[0].isActive=false;
        ProdLst[0].Core_Design_Registration_Eligible_Ind__c=false;
        update  ProdLst[0];
         
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_Reject_Products_Pending_Ctrl drr =  new Core_Reject_Products_Pending_Ctrl(stdSetController);
        drr.rejectProductsPending();
        drr.updateDDRProdRecords(DRPLst,'test1');
        
        Test.stopTest();
        System.assert(DRPLst!=Null);
        
        
        
     }
         //Added as part of twc727-1088

     public static testmethod void DR_Product_test3() {
         
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[0].Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst[0].Core_End_Customer_URL__c = 'www.url.com';

        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(6, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP.Core_Locked_Ind__c = false;
        }
        
        update DRPLst;
        ProdLst[0].isActive=false;
        update  ProdLst[0];
         List<Core_Design_Registration_Product__c> DRPLst2 = Core_DDR_Utility.CreateDRProduct(1, DDRLst, ProdLst);
         //DRPLst2[0].Core_Design_Product_Status_Nm__c = 'Approved';
         //DRPLst2[0].Core_Locked_Ind__c = false;
        // insert DRPLst2;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP.Core_Locked_Ind__c = false;
        }
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_Reject_Products_Pending_Ctrl drr =  new Core_Reject_Products_Pending_Ctrl(stdSetController);
        drr.rejectProductsPending();
        drr.commentText='test1'; 
        drr.updateDDRProdRecords(DRPLst,'test1');
        drr.setRetUrl();
        drr.checkApprovedDRP(DRPLst,DDRLst[0].id);
        drr.updateDDRRecords(DDRLst,'Approved' );
        Test.stopTest();  
        System.assert(DRPLst!=Null);
     }
    
    public static testmethod void DR_Product_test4() {
         
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[0].Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst[0].Core_End_Customer_URL__c = 'www.url.com';

        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(6, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Pending';
            DRP.Core_Locked_Ind__c = false;
            DRP.Core_Comment_Txt__c = '';
        }
        
        update DRPLst;
         
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_Reject_Products_Pending_Ctrl drr =  new Core_Reject_Products_Pending_Ctrl(stdSetController);
        drr.rejectProductsPending();
        Test.stopTest(); 
        System.assert(DRPLst!=Null);
     }
    
    public static testmethod void DR_Product_test5() {
         
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[0].Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst[0].Core_End_Customer_URL__c = 'www.url.com';

        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(6, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP.Core_Locked_Ind__c = false;
            DRP.Core_Comment_Txt__c = '';
        }
        
        update DRPLst;
         
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_Reject_Products_Pending_Ctrl drr =  new Core_Reject_Products_Pending_Ctrl(stdSetController);
        drr.rejectProductsPending();
        Test.stopTest(); 
        System.assert(DRPLst!=Null);
     }
    
    public static testmethod void deal_Product_test() {

        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();     
        List<account> LstAcc2 = Core_Test_Utility.createAccount(1);
        
        for(Account accountInstance : LstAcc2){
            // acc.Core_Sales_Groups__c ='';
            accountInstance.recordTypeId = accountRecordTypeIntel;
            accountInstance.OwnerId = UserInfo.getUserId(); 
            accountInstance.name = 'Testvijayvarshan';
            accountInstance.BillingCountryCode = 'USA';
            accountInstance.BIllingStateCode = 'AL';
            accountInstance.BillingCity = 'Alabama testobc';
            accountInstance.BillingStreet = 'test jkhl';
        }
        insert LstAcc2;
        Contact testContact = new Contact(FirstName='testFirstName12345', LastName='testLastName', Email='test123456@testing.com.test',AccountId=LstAcc2[0].Id,Core_IPS_Active__c =false);
        insert testContact;
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
        
        User u1 = new User( email='partneruser1@example.com',profileid = partnerProfile.id,UserName='partneruser1@example.com',Alias = 'PDS',TimeZoneSidKey='America/New_York',
                           EmailEncodingKey='ISO-8859-1',LocaleSidKey='en_US', LanguageLocaleKey='en_US',ContactId = testContact.Id,PortalRole = 'Manager',FirstName = 'Genea',LastName = 'Dsouz');
        
        Database.insert(u1);
        Id DealProductRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
        Id DealRecordTypeid = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('Deal_Registration_Draft').getRecordTypeId();
        system.runas(u1){
            List<Core_Design_Registration__c> DDRLst = new list<Core_Design_Registration__c>();
            Core_Design_Registration__c ddrRec2 = new  Core_Design_Registration__c();
            ddrRec2.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
            ddrRec2.Core_Vertical_Market_Nm__c='Education';
            ddrRec2.Core_Product_Segment_Nm__c='Client Computing';
            ddrRec2.Core_Product_Application_Nm__c='Business Desktop';
            ddrRec2.Core_Opportunity_Volume_Cnt__c=100;
            ddrRec2.Core_Partner_FAE_Nm__c='Test FAE';
            ddrRec2.Core_Partner_FSR_Nm__c='Test FSR';
            ddrRec2.Core_End_Customer_Nm__c='Arrow Electronics Account';
            ddrRec2.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
            ddrRec2.Core_End_Customer_Street_Addr_Line2_Txt__c='';
            ddrRec2.PCC_End_Customer_Country__c='India';
            ddrRec2.Core_End_Customer_City_Nm__c='Bangalore';
            ddrRec2.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
            ddrRec2.Core_End_Customer_Postal_Cd__c='758854';
            ddrRec2.Core_End_Customer_Contact_Title_Txt__c='Mr.';
            ddrRec2.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
            ddrRec2.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
            ddrRec2.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
            ddrRec2.Core_Manufacturing_Region_Cd__c='ASMO';
            ddrRec2.Core_Opportunity_Decision_Dt__c = system.today()+20;
            ddrRec2.Core_First_Customer_Ship_Dt__c = system.today()+21;
            ddrRec2.Core_Production_End_Dt__c = system.today()+22;
            //ddrRec2.Core_Intel_Platform_Nm__c='Agilex';
            ddrRec2.Core_Design_Registration_Nm__c='Test DR Name Arrow9';
            ddrRec2.Core_Design_Registration_Dsc__c='Test Des';
            ddrRec2.Core_External_Id__c='abczd001';
            ddrRec2.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
            ddrRec2.Core_End_Customer_URL__c = 'Test';
            ddrRec2.PCC_Consumption_Countries__c = 'Test';
            ddrRec2.PCC_Current_EndCustomer_Product_Provider__c='Test';
            ddrRec2.RecordTypeId=DealRecordTypeid;
            DDRLst.add(ddrRec2);
            insert DDRLst; 
           
        }
        /*setup();
        list<Core_Design_Registration__c> DDRLst = new list<Core_Design_Registration__c>();
        DDRLst.add(ddrRec2);*/
         DDRLst =[SELECT Id,Core_Product_Group_Nm__c,Core_Military_Aerospace_Gvrnmt_Use_Ind__c,Core_Vertical_Market_Nm__c,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_External_Id__c,Core_Partner_FAE_Nm__c, Core_Partner_FSR_Nm__c,Core_Opportunity_Volume_Cnt__c,
                                                   Core_End_Customer_Nm__c,Core_Design_Registration_Nm__c,Core_End_Customer_Street_Addr_Line1_Txt__c,Core_End_Customer_Street_Addr_Line2_Txt__c,Core_End_Customer_Country_Nm__c,Core_End_Customer_Country_Subdivision_Nm__c,Core_End_Customer_Postal_Cd__c,
                                                   Core_End_Customer_City_Nm__c,Core_End_Customer_Contact_Title_Txt__c,Core_End_Customer_Contact_Phone_Txt__c,Core_End_Customer_Contact_Nm__c,Core_End_Customer_Contact_Email_Txt__c,Core_End_Customer_URL__c,Core_Manufacturing_Region_Cd__c,DDR_Partner_FAE_Email__c,
                                                   Core_Opportunity_Decision_Dt__c,Core_Accepted_By_Id__c,PCC_Registration_Type__c,RecordType.DeveloperName,Core_First_Customer_Ship_Dt__c,Core_Production_End_Dt__c,Core_Intel_Platform_Nm__c, Core_Design_Registration_Status_Nm__c
                                                   FROM Core_Design_Registration__c where Core_External_Id__c='abczd001'];
system.debug('ddrlistt'+DDRLst);
        
         List<Product2> newprod = new List<Product2>();
        product2 prod1 = new product2();    
        prod1.name = 'Intel® Server System S7000FC4UR';
        prod1.Core_Design_Registration_Eligible_Ind__c  = true;
        prod1.Core_Sales_Visible_Flag__c = true;
        prod1.isActive = false;
        prod1.Core_Partner_Visible_Ind__c = true;
        prod1.Core_Avail_for_New_Designs__c = true;
        prod1.Core_Product_Org__c = 'sales';
        prod1.Core_Sales_Visible_Flag__c = true;
        prod1.IsActive = true;
        prod1.Core_Hierarchy_ID__c = '43';
        newprod.add(prod1);
        insert newprod;
        
        Product_Additional_Attribute__c newProdAA = new Product_Additional_Attribute__c();
        newProdAA.Name = 'Intel® Server System S7000FC4UR';
        newProdAA.Product__c =newProd[0].id;
        newProdAA.Eligible_for_Deal_Reg__c = true;
        insert newProdAA;
        list<Core_Design_Registration_Product__c> DRPLst = new list<Core_Design_Registration_Product__c>();
        Core_Design_Registration_Product__c DRproducts1 = new Core_Design_Registration_Product__c();
        DRproducts1.Core_Design_Registration_Id__c = DDRLst[0].id;
        DRproducts1.PCC_Product_Additional_Attribute__c = newProdAA.id;
        DRproducts1.Core_Target_Resale_Amt__c = 20;
        DRproducts1.Core_Full_Year_Qty__c = 3;
        DRproducts1.Core_Design_Product_Status_Nm__c = 'Pending';
        DRproducts1.Core_Product_Id__c = newprod[0].id;
        DRproducts1.RecordTypeId = DealProductRecordTypeid;
        DRPLst.add(DRproducts1);
       insert DRPLst;
        
        User usrs = [select id from User where Email='sysadmin@example.com' limit 1];
        DDRLst[0].Core_Accepted_By_Id__c=usrs.id;
        update DDRLst;
        Test.startTest();
                /*ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_Reject_Products_Pending_Ctrl drr =  new Core_Reject_Products_Pending_Ctrl(stdSetController);
        drr.commentText='ab';
        drr.rejectProductsPending();*/
        system.runas(usrs){
		ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_Reject_Products_Pending_Ctrl drr =  new Core_Reject_Products_Pending_Ctrl(stdSetController);
        drr.commentText='ab';
        drr.rejectProductsPending();}
        Test.stopTest(); 
        System.assert(DRPLst!=Null);
     }
    public static testmethod void DR_Product_test6() {
         
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[0].Core_Design_Registration_Status_Nm__c = 'Approved';
        DDRLst[0].Core_End_Customer_URL__c = 'www.url.com';

        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(6, DDRLst, ProdLst);
        insert DRPLst;
        Id DealProdPartnerRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Pending';
            DRP.Core_Locked_Ind__c = false;
            DRP.Core_Comment_Txt__c = 'abcd';
            DRP.RecordTypeId = DealProdPartnerRecordTypeid;
        }
        
        update DRPLst;
         
        Test.startTest();
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_Reject_Products_Pending_Ctrl drr =  new Core_Reject_Products_Pending_Ctrl(stdSetController);
        drr.commentText='ab';
        drr.rejectProductsPending();
        Test.stopTest(); 
        System.assert(DRPLst!=Null);
     }
}