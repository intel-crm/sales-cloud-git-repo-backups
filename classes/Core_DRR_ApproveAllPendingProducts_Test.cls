/**************************************************************************************
Apex Class Name:  Core_DRR_ApproveAllPendingProducts_Test
Version     : 1.0 
Created Date: 18 Jun 2018
Function    : Test Class for Core_DRR_ApproveAllPendingProducts
Modification Log :
* Developer                       Date                    Description
* ----------------------------------------------------------------------------                 
* Ragamalika Mohanraj             18/06/2014              Original Version
*************************************************************************************/
@isTest
public class Core_DRR_ApproveAllPendingProducts_Test {
      @testSetup
    public static void setup() {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.LastName = 'System Adm';
        usrs.ProfileId = sysAdminProfile.Id;
        usrs.IsActive = true;
        usrs.Email = 'sysadmin@example.com';
        Database.insert(usrs);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='PCC_Deal_Reg_Internal_Admin' LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = usrs.Id,PermissionSetId = ps.Id);
        insert psa;
    }
     public static testmethod void DR_Product_test1() {
         
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
       
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM11@intel.com',
                                 EmailEncodingKey='UTF-8',LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMPM.com',FirstName='TestUtility', ProfileId = profile1.Id);
        insert testUser;
         List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        //List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        Core_Design_Registration__Share drShare = new Core_Design_Registration__Share();
         drShare.ParentId = DDRLst[0].Id;
         drShare.UserOrGroupId = testUser.Id;
         drShare.AccessLevel = 'Edit';
         drShare.RowCause = 'Manual';
       //  drShare.IsDeleted =  false;
         insert drShare;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(6, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Pending';
            DRP.Core_Locked_Ind__c = false;
        }
        
        update DRPLst;
        
        Test.startTest();
        Test.setCurrentPage(Page.Core_DRR_ApproveAllPendingProdListButton); 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_DRR_ApproveAllPendingProducts drr =  new Core_DRR_ApproveAllPendingProducts(stdSetController);
        PageReference ans = drr.approvalAllpendingProd();
        system.assertEquals(null,ans);
        //delete DRPLst;
        drr.approvalAllpendingProd();
        Test.stopTest();
        
     
     }
    
         public static testmethod void DR_Product_test2() {
         
             Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
       
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM11@intel.com',
                                 EmailEncodingKey='UTF-8',LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMPM.com',FirstName='TestUtility', ProfileId = profile1.Id);
        insert testUser;
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        // for(Product2 Pro : ProdLst){
        //    Pro.Core_Design_Registration_Eligible_Ind__c = false;
        //    
        //}
        // update ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        //List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        Core_Design_Registration__Share drShare = new Core_Design_Registration__Share();
         drShare.ParentId = DDRLst[0].Id;
         drShare.UserOrGroupId = testUser.Id;
         drShare.AccessLevel = 'Edit';
         drShare.RowCause = 'Manual';
       //  drShare.IsDeleted =  false;
         insert drShare;
             
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(6, DDRLst, ProdLst);
        insert DRPLst;
        
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Pending';
            DRP.Core_Locked_Ind__c = false;
            
        }
        
        update DRPLst;
        
        for(Product2 Pro : ProdLst){
            Pro.Core_Design_Registration_Eligible_Ind__c = false;
            
        }
         update ProdLst;
             
        ProdLst[0].Core_Design_Registration_Eligible_Ind__c=false;
        update  ProdLst[0];
         
        Test.startTest();
        Test.setCurrentPage(Page.Core_DRR_ApproveAllPendingProdListButton); 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_DRR_ApproveAllPendingProducts drr =  new Core_DRR_ApproveAllPendingProducts(stdSetController);
        //drr.approvalAllpendingProd();
        //delete DRPLst;
        PageReference ans = drr.approvalAllpendingProd();
        system.assertEquals(null,ans);
        Test.stopTest();
        
     
     }
     public static testmethod void DR_Product_test3() {
         Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
       
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM11@intel.com',
                                 EmailEncodingKey='UTF-8',LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMPM.com',FirstName='TestUtility', ProfileId = profile1.Id);
        insert testUser;
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        //List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[0].Core_Design_Registration_Status_Nm__c = 'Approved';

        insert DDRLst;
        Core_Design_Registration__Share drShare = new Core_Design_Registration__Share();
         drShare.ParentId = DDRLst[0].Id;
         drShare.UserOrGroupId = testUser.Id;
         drShare.AccessLevel = 'Edit';
         drShare.RowCause = 'Manual';
       //  drShare.IsDeleted =  false;
         insert drShare;
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(6, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP.Core_Locked_Ind__c = false;
        }
        
        update DRPLst;
        ProdLst[0].isActive=false;
        update  ProdLst[0];

        Test.startTest();
        Test.setCurrentPage(Page.Core_DRR_ApproveAllPendingProdListButton); 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_DRR_ApproveAllPendingProducts drr =  new Core_DRR_ApproveAllPendingProducts(stdSetController);
        drr.approvalAllpendingProd();
        // delete DRPLst;
        PageReference ans = drr.approvalAllpendingProd();
        system.assertEquals(null,ans);
        Test.stopTest();
        
     
     }
     public static testmethod void DR_Product_test4() {
         Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
       
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMPM11@intel.com',
                                 EmailEncodingKey='UTF-8',LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMPM.com',FirstName='TestUtility', ProfileId = profile1.Id);
        insert testUser;
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        //List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'FPGA/Power';
        insert DDRLst;
      /*  Core_Design_Registration__Share drShare = new Core_Design_Registration__Share();
         drShare.ParentId = DDRLst[0].Id;
         drShare.UserOrGroupId = UserInfo.getUserId();
         drShare.AccessLevel = 'Edit';
         drShare.RowCause = 'Manual';
       //  drShare.IsDeleted =  false;
         insert drShare;*/
         
      //   insert testUser;
         Core_DDR_Design_Handler_Utility.designRegShare(DDRLst);
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(6, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Pending';
            DRP.Core_Locked_Ind__c = false;
        }
        
        update DRPLst;
        ProdLst[0].isActive=false;
        update  ProdLst[0];
         
        Test.startTest();
        Test.setCurrentPage(Page.Core_DRR_ApproveAllPendingProdListButton); 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_DRR_ApproveAllPendingProducts drr =  new Core_DRR_ApproveAllPendingProducts(stdSetController);
        drr.approvalAllpendingProd();
        //delete DRPLst;
        PageReference ans = drr.approvalAllpendingProd();
        system.assertEquals(null,ans);
        Test.stopTest();
        
     
     }
         
     @isTest
     public static void Deal_Product_Test3()
     {
             User usrs = [SELECT Id FROM User WHERE Email = 'sysadmin@example.com' LIMIT 1];

         
      Id DealRecordTypeid = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('Deal_Registration_Draft').getRecordTypeId();
 Core_Design_Registration__c ddrRec1 = new  Core_Design_Registration__c();
		ddrRec1.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec1.Core_Vertical_Market_Nm__c='Education';
		ddrRec1.Core_Product_Segment_Nm__c='Client Computing';
		ddrRec1.Core_Product_Application_Nm__c='Business Desktop';
		ddrRec1.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec1.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec1.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec1.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec1.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec1.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec1.PCC_End_Customer_Country__c='India';
		ddrRec1.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec1.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec1.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec1.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec1.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec1.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec1.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec1.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec1.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec1.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec1.Core_Production_End_Dt__c = system.today()+22;
        ddrRec1.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec1.Core_Design_Registration_Nm__c='Test DR Name Arrow9';
        ddrRec1.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec1.Core_External_Id__c='abcd001';
        ddrRec1.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec1.Core_End_Customer_URL__c = 'Test';
        ddrRec1.PCC_Consumption_Countries__c = 'Test';
        ddrRec1.PCC_Current_EndCustomer_Product_Provider__c='Test';
         //ddrRec1.PCC_Registration_Type__c='Deal Registration';
         ddrRec1.Core_Accepted_By_Id__c = usrs.id;
         ddrRec1.RecordTypeId=DealRecordTypeid;
         ddrRec1.Core_Accepted_By_Id__c = usrs.id;
         ddrRec1.PCC_Digital_Identifier__c = 'Website/URL';
         ddrRec1.PCC_Digital_Identifier_Value__c = 'test';
         ddrRec1.PCC_Industry__c = 'Agriculture';
         ddrRec1.PCC_Sub_Industry__c = 'Animal Production';
         insert ddrRec1;        
        
         
         
         
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
      
        Id DealProductRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
        Product_Additional_Attribute__c newProdAA = new Product_Additional_Attribute__c();
        newProdAA.Name = 'Intel® Server System S7000FC4UR';
        newProdAA.Product__c =newProd[0].id;
        newProdAA.Eligible_for_Deal_Reg__c = true;
        insert newProdAA;
         
        Pricing_Competitor_Product__c CompetitorProd = new Pricing_Competitor_Product__c();
         CompetitorProd.Name = 'competitorprod1';
         CompetitorProd.Pricing_Competitor_Product_Provider_Nm__c = 'provider1';
         CompetitorProd.Pricing_Active_cb__c = true;
         CompetitorProd.RecordTypeId = Schema.SObjectType.Pricing_Competitor_Product__c.getRecordTypeInfosByDeveloperName().get('Pricing_Client').getRecordTypeId();
         insert CompetitorProd;
      
      /*
      Product2 newprod = new Product2();
          
      newprod.name = 'Intel® Server System S7000FC4UR';
      newprod.Core_Design_Registration_Eligible_Ind__c  = true;
      newprod.Core_Sales_Visible_Flag__c = true;
      newprod.isActive = false;
      newprod.Core_Partner_Visible_Ind__c = true;
      newprod.Core_Avail_for_New_Designs__c = true;
      insert newprod;
      */
      List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
      insert PriceBookLst;
      
      //List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(1, newprod, PriceBookLst);
      /* 
      List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
       DDRLst[0].Core_Intel_Support_Status__c = 'Disti Design Registration High';
      //DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
      insert DDRLst;
      */
         /*
      List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(1, DDRLst, newprod);
      //DRPLst[0].PCC_Product_Additional_Attribute__c = newProdAA.Id;
      insert DRPLst;
      
      //DRPLst[0].Core_Active_Status__c = false;
          
      Test.startTest();
      Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[0].Id);
      Test.stopTest();
		*/
         
         List<Core_Design_Registration_Product__c> DRproducts = new List<Core_Design_Registration_Product__c>();
         for(integer i=0; i < 3; i++) {
             Core_Design_Registration_Product__c DRproducts_1 = new Core_Design_Registration_Product__c();
         	DRproducts_1.Core_Design_Registration_Id__c = ddrRec1.id;
            DRproducts_1.PCC_Product_Additional_Attribute__c = newProdAA.id;
            DRproducts_1.Core_Target_Resale_Amt__c = 20;
            DRproducts_1.Core_Full_Year_Qty__c = 3;
            DRproducts_1.Core_Design_Product_Status_Nm__c = 'Pending';
            DRproducts_1.Core_Product_Id__c = newprod[0].id;
            DRproducts_1.RecordTypeId = DealProductRecordTypeid;
            DRproducts_1.PCC_Competitor_Product__c = CompetitorProd.Id;
             DRproducts.add(DRproducts_1);
        }
         insert DRproducts;
         
       system.runAs(usrs){  
       Test.startTest();
       //System.debug('product status'+DRproducts.Core_Design_Product_Status_Nm__c);
       //System.debug('product id'+DRproducts.Id);
       newprod[0].IsActive = false;
       update newprod;
     	Test.setCurrentPage(Page.Core_DRR_ApproveAllPendingProdListButton); 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRproducts);
        stdSetController.setSelected(DRproducts);
        ApexPages.currentPage().getParameters().put('Id',DRproducts[0].Core_Design_Registration_Id__c);
        Core_DRR_ApproveAllPendingProducts drr =  new Core_DRR_ApproveAllPendingProducts(stdSetController);
        PageReference ans = drr.approvalAllpendingProd();
        system.assertEquals(null,ans);
           Test.stopTest();}
      
  }
    
      
     @isTest
     public static void Deal_Product_Test4()
     {
      User usrs = [SELECT Id FROM User WHERE Email = 'sysadmin@example.com' LIMIT 1];

         
      Id DealRecordTypeid = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('Deal_Registration_Draft').getRecordTypeId();
 Core_Design_Registration__c ddrRec1 = new  Core_Design_Registration__c();
		ddrRec1.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec1.Core_Vertical_Market_Nm__c='Education';
		ddrRec1.Core_Product_Segment_Nm__c='Client Computing';
		ddrRec1.Core_Product_Application_Nm__c='Business Desktop';
		ddrRec1.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec1.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec1.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec1.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec1.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec1.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec1.PCC_End_Customer_Country__c='India';
		ddrRec1.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec1.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec1.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec1.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec1.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec1.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec1.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec1.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec1.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec1.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec1.Core_Production_End_Dt__c = system.today()+22;
        ddrRec1.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec1.Core_Design_Registration_Nm__c='Test DR Name Arrow9';
        ddrRec1.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec1.Core_External_Id__c='abcd001';
        ddrRec1.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec1.Core_End_Customer_URL__c = 'Test';
        ddrRec1.PCC_Consumption_Countries__c = 'Test';
        ddrRec1.PCC_Current_EndCustomer_Product_Provider__c='Test';
         //ddrRec1.PCC_Registration_Type__c='Deal Registration';
         ddrRec1.RecordTypeId=DealRecordTypeid;
         ddrRec1.Core_Accepted_By_Id__c = usrs.id;
          ddrRec1.PCC_Digital_Identifier__c = 'Website/URL';
         ddrRec1.PCC_Digital_Identifier_Value__c = 'test';
         ddrRec1.PCC_Industry__c = 'Agriculture';
         ddrRec1.PCC_Sub_Industry__c = 'Animal Production';
        insert ddrRec1;        
         
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
      
        Id DealProductRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
        Product_Additional_Attribute__c newProdAA = new Product_Additional_Attribute__c();
        newProdAA.Name = 'Intel® Server System S7000FC4UR';
        newProdAA.Product__c =newProd[0].id;
        newProdAA.Eligible_for_Deal_Reg__c = true;
        insert newProdAA;
      
      List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
      insert PriceBookLst;
      
      //List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(1, newprod, PriceBookLst);
         
         List<Core_Design_Registration_Product__c> DRproducts = new List<Core_Design_Registration_Product__c>();
         for(integer i=0; i < 3; i++) {
             Core_Design_Registration_Product__c DRproducts_1 = new Core_Design_Registration_Product__c();
         	DRproducts_1.Core_Design_Registration_Id__c = ddrRec1.id;
            DRproducts_1.PCC_Product_Additional_Attribute__c = newProdAA.id;
            DRproducts_1.Core_Target_Resale_Amt__c = 20;
            DRproducts_1.Core_Full_Year_Qty__c = 3;
            DRproducts_1.Core_Design_Product_Status_Nm__c = 'Pending';
            DRproducts_1.Core_Product_Id__c = newprod[0].id;
            DRproducts_1.RecordTypeId = DealProductRecordTypeid;
             DRproducts.add(DRproducts_1);
        }
         insert DRproducts;
         
       system.runAs(usrs){  
       Test.startTest();
           newprod[0].IsActive = true;
           update newprod;
     	Test.setCurrentPage(Page.Core_DRR_ApproveAllPendingProdListButton); 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRproducts);
        stdSetController.setSelected(DRproducts);
        ApexPages.currentPage().getParameters().put('Id',DRproducts[0].Core_Design_Registration_Id__c);
        Core_DRR_ApproveAllPendingProducts drr =  new Core_DRR_ApproveAllPendingProducts(stdSetController);
        PageReference ans = drr.approvalAllpendingProd();
           system.assertEquals(null,ans);
           Test.stopTest();}
      
  }
    
    @isTest
     public static void Deal_Product_Test5()
     {
       User usrs = [SELECT Id FROM User WHERE Email = 'sysadmin@example.com' LIMIT 1];

         
      Id DealRecordTypeid = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('Deal_Registration_Draft').getRecordTypeId();
      Core_Design_Registration__c ddrRec1 = new  Core_Design_Registration__c();
		ddrRec1.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec1.Core_Vertical_Market_Nm__c='Education';
		ddrRec1.Core_Product_Segment_Nm__c='Client Computing';
		ddrRec1.Core_Product_Application_Nm__c='Business Desktop';
		ddrRec1.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec1.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec1.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec1.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec1.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec1.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec1.PCC_End_Customer_Country__c='India';
		ddrRec1.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec1.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec1.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec1.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec1.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec1.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec1.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec1.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec1.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec1.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec1.Core_Production_End_Dt__c = system.today()+22;
        ddrRec1.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec1.Core_Design_Registration_Nm__c='Test DR Name Arrow9';
        ddrRec1.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec1.Core_External_Id__c='abcd001';
        ddrRec1.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec1.Core_End_Customer_URL__c = 'Test';
        ddrRec1.PCC_Consumption_Countries__c = 'Test';
        ddrRec1.PCC_Current_EndCustomer_Product_Provider__c='Test';
         //ddrRec1.PCC_Registration_Type__c='Deal Registration';
         ddrRec1.RecordTypeId=DealRecordTypeid;
         ddrRec1.Core_Accepted_By_Id__c = usrs.id;
          ddrRec1.PCC_Digital_Identifier__c = 'Website/URL';
         ddrRec1.PCC_Digital_Identifier_Value__c = 'test';
         ddrRec1.PCC_Industry__c = 'Agriculture';
         ddrRec1.PCC_Sub_Industry__c = 'Animal Production';
        insert ddrRec1;        
         
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
      
        Id DealProductRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
        Product_Additional_Attribute__c newProdAA = new Product_Additional_Attribute__c();
        newProdAA.Name = 'Intel® Server System S7000FC4UR';
        newProdAA.Product__c =newProd[0].id;
        newProdAA.Eligible_for_Deal_Reg__c = true;
        insert newProdAA;
      
      List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
      insert PriceBookLst;
      
      //List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(1, newprod, PriceBookLst);
         
         Pricing_Competitor_Product__c CompetitorProd = new Pricing_Competitor_Product__c();
         CompetitorProd.Name = 'competitorprod1';
         CompetitorProd.Pricing_Competitor_Product_Provider_Nm__c = 'provider1';
         CompetitorProd.Pricing_Active_cb__c = true;
         CompetitorProd.RecordTypeId = Schema.SObjectType.Pricing_Competitor_Product__c.getRecordTypeInfosByDeveloperName().get('Pricing_Client').getRecordTypeId();
         insert CompetitorProd;
         
         List<Core_Design_Registration_Product__c> DRproducts = new List<Core_Design_Registration_Product__c>();
         for(integer i=0; i < 3; i++) {
             Core_Design_Registration_Product__c DRproducts_1 = new Core_Design_Registration_Product__c();
         	DRproducts_1.Core_Design_Registration_Id__c = ddrRec1.id;
            DRproducts_1.PCC_Product_Additional_Attribute__c = newProdAA.id;
            DRproducts_1.Core_Target_Resale_Amt__c = 20;
            DRproducts_1.Core_Full_Year_Qty__c = 3;
            DRproducts_1.Core_Design_Product_Status_Nm__c = 'Pending';
            DRproducts_1.Core_Product_Id__c = newprod[0].id;
            DRproducts_1.RecordTypeId = DealProductRecordTypeid;
            DRproducts_1.PCC_Competitor_Product__c = CompetitorProd.Id;
             DRproducts.add(DRproducts_1);
        }
         insert DRproducts;
         
       system.runAs(usrs){  
       Test.startTest();
       //CompetitorProd.Pricing_Active_cb__c = false;
       //update CompetitorProd;
     	Test.setCurrentPage(Page.Core_DRR_ApproveAllPendingProdListButton); 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRproducts);
        stdSetController.setSelected(DRproducts);
        ApexPages.currentPage().getParameters().put('Id',DRproducts[0].Core_Design_Registration_Id__c);
        Core_DRR_ApproveAllPendingProducts drr =  new Core_DRR_ApproveAllPendingProducts(stdSetController);
        PageReference ans = drr.approvalAllpendingProd();
           system.assertEquals(null,ans);
           Test.stopTest();}
      
  
         
      }
    
    @isTest
     public static void Deal_Product_Test6()
     {
       User usrs = [SELECT Id FROM User WHERE Email = 'sysadmin@example.com' LIMIT 1];

         
      Id DealRecordTypeid = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('Deal_Registration_Draft').getRecordTypeId();
      Core_Design_Registration__c ddrRec1 = new  Core_Design_Registration__c();
		ddrRec1.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
		ddrRec1.Core_Vertical_Market_Nm__c='Education';
		ddrRec1.Core_Product_Segment_Nm__c='Client Computing';
		ddrRec1.Core_Product_Application_Nm__c='Business Desktop';
		ddrRec1.Core_Opportunity_Volume_Cnt__c=100;
		ddrRec1.Core_Partner_FAE_Nm__c='Test FAE';
		ddrRec1.Core_Partner_FSR_Nm__c='Test FSR';
		ddrRec1.Core_End_Customer_Nm__c='Arrow Electronics Account';
		ddrRec1.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
		ddrRec1.Core_End_Customer_Street_Addr_Line2_Txt__c='';
		ddrRec1.PCC_End_Customer_Country__c='India';
		ddrRec1.Core_End_Customer_City_Nm__c='Bangalore';
		ddrRec1.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
		ddrRec1.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec1.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec1.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec1.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec1.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec1.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec1.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec1.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec1.Core_Production_End_Dt__c = system.today()+22;
        ddrRec1.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec1.Core_Design_Registration_Nm__c='Test DR Name Arrow9';
        ddrRec1.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec1.Core_External_Id__c='abcd001';
        ddrRec1.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec1.Core_End_Customer_URL__c = 'Test';
        ddrRec1.PCC_Consumption_Countries__c = 'Test';
        ddrRec1.PCC_Current_EndCustomer_Product_Provider__c='Test';
         //ddrRec1.PCC_Registration_Type__c='Deal Registration';
         ddrRec1.RecordTypeId=DealRecordTypeid;
         ddrRec1.Core_Accepted_By_Id__c = usrs.id;
          ddrRec1.PCC_Digital_Identifier__c = 'Website/URL';
         ddrRec1.PCC_Digital_Identifier_Value__c = 'test';
         ddrRec1.PCC_Industry__c = 'Agriculture';
         ddrRec1.PCC_Sub_Industry__c = 'Animal Production';
        insert ddrRec1;        
         
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
      
        Id DealProductRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
        Product_Additional_Attribute__c newProdAA = new Product_Additional_Attribute__c();
        newProdAA.Name = 'Intel® Server System S7000FC4UR';
        newProdAA.Product__c =newProd[0].id;
        newProdAA.Eligible_for_Deal_Reg__c = true;
        insert newProdAA;
      
      List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
      insert PriceBookLst;
      
      //List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(1, newprod, PriceBookLst);
         
         Pricing_Competitor_Product__c CompetitorProd = new Pricing_Competitor_Product__c();
         CompetitorProd.Name = 'competitorprod1';
         CompetitorProd.Pricing_Competitor_Product_Provider_Nm__c = 'provider1';
         CompetitorProd.Pricing_Active_cb__c = true;
         CompetitorProd.RecordTypeId = Schema.SObjectType.Pricing_Competitor_Product__c.getRecordTypeInfosByDeveloperName().get('Pricing_Client').getRecordTypeId();
         insert CompetitorProd;
         
         List<Core_Design_Registration_Product__c> DRproducts = new List<Core_Design_Registration_Product__c>();
         for(integer i=0; i < 3; i++) {
             Core_Design_Registration_Product__c DRproducts_1 = new Core_Design_Registration_Product__c();
         	DRproducts_1.Core_Design_Registration_Id__c = ddrRec1.id;
            DRproducts_1.PCC_Product_Additional_Attribute__c = newProdAA.id;
            DRproducts_1.Core_Target_Resale_Amt__c = 20;
            DRproducts_1.Core_Full_Year_Qty__c = 3;
            DRproducts_1.Core_Design_Product_Status_Nm__c = 'Pending';
            DRproducts_1.Core_Product_Id__c = newprod[0].id;
            DRproducts_1.RecordTypeId = DealProductRecordTypeid;
            DRproducts_1.PCC_Competitor_Product__c = CompetitorProd.Id;
            DRproducts_1.PCC_Quote_Line_Pricing_Start_Date__c = Date.today() - 1;
             DRproducts.add(DRproducts_1);
        }
         insert DRproducts;
         
       system.runAs(usrs){  
       Test.startTest();
       //CompetitorProd.Pricing_Active_cb__c = false;
       //update CompetitorProd;
     	Test.setCurrentPage(Page.Core_DRR_ApproveAllPendingProdListButton); 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRproducts);
        stdSetController.setSelected(DRproducts);
        ApexPages.currentPage().getParameters().put('Id',DRproducts[0].Core_Design_Registration_Id__c);
        Core_DRR_ApproveAllPendingProducts drr =  new Core_DRR_ApproveAllPendingProducts(stdSetController);
        PageReference ans = drr.approvalAllpendingProd();
           system.assertEquals(null,ans);
           Test.stopTest();}
      
  
         
      }
         
}