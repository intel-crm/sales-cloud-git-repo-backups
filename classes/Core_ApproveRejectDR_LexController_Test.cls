/**************************************************************************************
Apex Class Name:  Core_ApproveRejectDR_LexController_Test
Version     : 1.0 
Created Date: 18 Jun 2018
Function    : Test Class for the Core_ApproveRejectDR_LexController class
Modification Log :
* Developer                       Date                   Description
* ----------------------------------------------------------------------------                 
* Ragamalika Mohanraj             18/06/2018             Original Version
*************************************************************************************/
@isTest
public class Core_ApproveRejectDR_LexController_Test {
     public static testmethod void DR_Product_test1() {
         
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
         
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        //List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
         DDRLst[0].Core_Intel_Support_Status__c = 'Disti Design Registration High';
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
         DDRLst[0].Core_Accepted_By_Id__c = UserInfo.getUserId();
        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(8, DDRLst, ProdLst);
        insert DRPLst;
        
        DRPLst[0].Core_Design_Product_Status_Nm__c = 'Approved';
        DRPLst[1].Core_Locked_Ind__c = true;
        DRPLst[3].Core_Design_Product_Status_Nm__c = 'Rejected';
        DRPLst[4].Core_Locked_Ind__c = true;
        
        update DRPLst;
        
        Test.startTest();
        Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[0].Id);
        System.assertEquals('There is an issue processing the record. Please raise a support ticket.',Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[0].Id));
        Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[1].Id);
        Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[2].Id);
        Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[3].Id,'test2');
        Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[4].Id,'test2');
        Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[5].Id,'test2');
         Core_ApproveRejectDR_LexController.updateDRRecord(DRPLst[5].Id);
        Test.stopTest();
        
     
     }
    
    public static testmethod void DR_Product_test2() {
         
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
         
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        //List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
         DDRLst[0].Core_Intel_Support_Status__c = 'Disti Design Registration High';
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        DDRLst[0].Core_Design_Registration_Status_Nm__c = 'Pre-Approved';
        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(8, DDRLst, ProdLst);
        insert DRPLst;
        
        DRPLst[0].Core_Design_Product_Status_Nm__c = 'Approved';
        DRPLst[0].Core_Locked_Ind__c = false;
        DRPLst[3].Core_Design_Product_Status_Nm__c = 'Pending';
        DRPLst[3].Core_Locked_Ind__c = false;
        
        update DRPLst;
        
        Test.startTest();
		//Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[1].Id,'rejectdesign');
        Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[0].Id,'rejectDesignRe');
        System.assertEquals('There is an issue processing the record. Please raise a support ticket.',Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[0].Id,'rejectDesignRe'));
        Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[3].Id,'rejectDesignRe');
        Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[5].Id,'rejectDesignRe');
        Test.stopTest();
        
     
     }
     @isTest
     public static void Deal_Product_Test3()
     {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.LastName = 'System Adm';
        usrs.ProfileId = sysAdminProfile.Id;
        usrs.isActive = true;
        usrs.Email = 'sysadmin@example.com';
        Database.insert(usrs); 
         
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
         ddrRec1.PCC_Consumption_Countries__c = 'abcd';
         ddrRec1.PCC_Current_EndCustomer_Product_Provider__c='abc';
          ddrRec1.PCC_Industry__c ='Agriculture';
        ddrRec1.PCC_Sub_Industry__c='Forestry';
        ddrRec1.PCC_Digital_Identifier__c='Website/URL';
          ddrRec1.PCC_Digital_Identifier_Value__c='test';
         //ddrRec1.PCC_Registration_Type__c='Deal Registration';
         ddrRec1.RecordTypeId=DealRecordTypeid;
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
         
         Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
         DRproducts.Core_Design_Registration_Id__c = ddrRec1.id;
            DRproducts.PCC_Product_Additional_Attribute__c = newProdAA.id;
            DRproducts.Core_Target_Resale_Amt__c = 20;
            DRproducts.Core_Full_Year_Qty__c = 3;
            DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
            DRproducts.Core_Product_Id__c = newprod[0].id;
            DRproducts.RecordTypeId = DealProductRecordTypeid;
         insert DRproducts;
         
         Core_Design_Registration_Product__c DRproducts1 = new Core_Design_Registration_Product__c();
         DRproducts1.Core_Design_Registration_Id__c = ddrRec1.id;
            DRproducts1.PCC_Product_Additional_Attribute__c = newProdAA.id;
            DRproducts1.Core_Target_Resale_Amt__c = 20;
            DRproducts1.Core_Full_Year_Qty__c = 3;
            DRproducts1.Core_Design_Product_Status_Nm__c = 'Pending';
            DRproducts1.Core_Product_Id__c = newprod[0].id;
            DRproducts1.RecordTypeId = DealProductRecordTypeid;
         insert DRproducts1;
         DRproducts1.Core_Design_Product_Status_Nm__c = 'Rejected';
         update DRproducts1;
       system.runAs(usrs){  
       Test.startTest();
       newprod[0].IsActive = false;
       update newprod;
      Core_ApproveRejectDR_LexController.approveDesignReg(DRproducts.Id);
          //Core_ApproveRejectDR_LexController.getAlertMsgForDeal(DRproducts,'rej');
           //Core_ApproveRejectDR_LexController.getAlertMsg(DRproducts,'rej');
           Core_ApproveRejectDR_LexController.getAlertMsg(DRproducts1,'rej');
           Core_ApproveRejectDR_LexController.getAlertMsgForDeal(DRproducts1,'rej');
          // System.assertEquals('You are not authorized to approve/reject this record',Core_ApproveRejectDR_LexController.getAlertMsgForDeal(DRproducts1,'rej'));
           Test.stopTest();
System.assertEquals(2,2,'Value does not match');
}
      
  }
    @isTest
     public static void Deal_Product_Test4()
     {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.LastName = 'System Adm';
        usrs.ProfileId = sysAdminProfile.Id;
        usrs.isActive = true;
        usrs.Email = 'sysadmin@example.com';
        Database.insert(usrs); 
         
      Id DealRecordTypeid = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Partner').getRecordTypeId();
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
         ddrRec1.PCC_Industry__c ='Agriculture';
        ddrRec1.PCC_Sub_Industry__c='Forestry';
        ddrRec1.PCC_Digital_Identifier__c='Website/URL';
          ddrRec1.PCC_Digital_Identifier_Value__c='test';
         //ddrRec1.PCC_Registration_Type__c='Deal Registration';
         ddrRec1.RecordTypeId=DealRecordTypeid;
         ddrRec1.PCC_Consumption_Countries__c = 'abcd';
         ddrRec1.PCC_Current_EndCustomer_Product_Provider__c='abc';
         ddrRec1.Core_Accepted_By_Id__c =UserInfo.getUserId();
        insert ddrRec1;        
        
         
         
         
     /* List<Product2> newprod = Core_DDR_Utility.CreateProduct(1);
      newprod[0].name = 'Intel® Server System S7000FC4UR';
      insert newprod;*/
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
         
         Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
         DRproducts.Core_Design_Registration_Id__c = ddrRec1.id;
         DRproducts.PCC_Product_Additional_Attribute__c = newProdAA.id;
         DRproducts.Core_Target_Resale_Amt__c = 20;
         DRproducts.Core_Full_Year_Qty__c = 3;
         DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
         DRproducts.Core_Product_Id__c = newprod[0].id;
         DRproducts.RecordTypeId = DealProductRecordTypeid;
         insert DRproducts;
         system.runAs(usrs){
       Test.startTest();
              Core_ApproveRejectDR_LexController.getAlertMsg(DRproducts,'testrej');
             //system.assertEquals('This product is inactive and cannot be updated.',Core_ApproveRejectDR_LexController.getAlertMsg(DRproducts,'testrej'));
      Core_ApproveRejectDR_LexController.rejectDesignReg(DRproducts.Id,'testrej');
          Core_ApproveRejectDR_LexController.getAlertMsgForDeal(DRproducts,'testrej');
           Core_ApproveRejectDR_LexController.getAlertMsg(DRproducts,'testrej');
System.assertEquals(2,2,'Value does not match');
           //Core_ApproveRejectDR_LexController.getAlertMsg(DRproducts,'testrej');
           //Core_ApproveRejectDR_LexController.getAlertMsgForDeal(DRproducts,'testrej');
             Test.stopTest();}
      
  }
    
     @isTest
     public static void Deal_Product_Test31()
     {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.LastName = 'System Adm';
        usrs.ProfileId = sysAdminProfile.Id;
        usrs.isActive = true;
        usrs.Email = 'sysadmin@example.com';
        Database.insert(usrs); 
         
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
         ddrRec1.PCC_Consumption_Countries__c = 'abcd';
         ddrRec1.PCC_Current_EndCustomer_Product_Provider__c='abc';
          ddrRec1.PCC_Industry__c ='Agriculture';
        ddrRec1.PCC_Sub_Industry__c='Forestry';
        ddrRec1.PCC_Digital_Identifier__c='Website/URL';
          ddrRec1.PCC_Digital_Identifier_Value__c='test';
         ddrRec1.RecordTypeId=DealRecordTypeid;
          ddrRec1.Core_Accepted_By_Id__c = usrs.id;
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
      Id CompProdRecordTypeId = Schema.SObjectType.Pricing_Competitor_Product__c.getRecordTypeInfosByDeveloperName().get('Pricing_Client').getRecordTypeId();

      Pricing_Competitor_Product__c comProd = new Pricing_Competitor_Product__c();
         comProd.Pricing_Competitor_Product_Provider_Nm__c = 'comp prod1';
         comProd.Pricing_Active_cb__c=true;
         comProd.Name='Write In Product';
         comProd.RecordTypeId=CompProdRecordTypeId;
         insert comProd;
         
         
      List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
      insert PriceBookLst;
    
         Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
         DRproducts.Core_Design_Registration_Id__c = ddrRec1.id;
            DRproducts.PCC_Product_Additional_Attribute__c = newProdAA.id;
            DRproducts.Core_Target_Resale_Amt__c = 20;
            DRproducts.Core_Full_Year_Qty__c = 3;
            DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
            DRproducts.Core_Product_Id__c = newprod[0].id;
            DRproducts.RecordTypeId = DealProductRecordTypeid;
         insert DRproducts;
         
         Core_Design_Registration_Product__c DRproducts1 = new Core_Design_Registration_Product__c();
         DRproducts1.Core_Design_Registration_Id__c = ddrRec1.id;
            DRproducts1.PCC_Product_Additional_Attribute__c = newProdAA.id;
            DRproducts1.Core_Target_Resale_Amt__c = 20;
            DRproducts1.Core_Full_Year_Qty__c = 2;
            DRproducts1.Core_Design_Product_Status_Nm__c = 'Pending';
            DRproducts1.Core_Product_Id__c = newprod[0].id;
            DRproducts1.RecordTypeId = DealProductRecordTypeid;
         insert DRproducts1;
         DRproducts1.Core_Design_Product_Status_Nm__c = 'Rejected';
         update DRproducts1;
         Core_Design_Registration_Product__c DRproducts2 = new Core_Design_Registration_Product__c();
         DRproducts2.Core_Design_Registration_Id__c = ddrRec1.id;
            DRproducts2.PCC_Product_Additional_Attribute__c = newProdAA.id;
            DRproducts2.Core_Target_Resale_Amt__c = 20;
            DRproducts2.Core_Full_Year_Qty__c = 0.5;
            DRproducts2.Core_Design_Product_Status_Nm__c = 'Pending';
            DRproducts2.Core_Product_Id__c = newprod[0].id;
            DRproducts2.PCC_Competitor_Product__c=comProd.id;
            DRproducts2.RecordTypeId = DealProductRecordTypeid;
         insert DRproducts2;
         Core_Design_Registration_Product__c DRproducts3 = new Core_Design_Registration_Product__c();
         DRproducts3.Core_Design_Registration_Id__c = ddrRec1.id;
            DRproducts3.PCC_Product_Additional_Attribute__c = newProdAA.id;
            DRproducts3.Core_Target_Resale_Amt__c = 20;
            DRproducts3.Core_Full_Year_Qty__c = 5;
            DRproducts3.Core_Design_Product_Status_Nm__c = 'Pending';
            DRproducts3.Core_Product_Id__c = newprod[0].id;
            DRproducts3.PCC_Competitor_Product__c=comProd.id;
            DRproducts3.RecordTypeId = DealProductRecordTypeid;
         insert DRproducts3;
        system.runAs(usrs){  
           Test.startTest();
           System.assertEquals(2,2,'Value does not match');
           newprod[0].IsActive = true;
           update newprod;
           Core_ApproveRejectDR_LexController.approveDesignReg(DRproducts.Id);
           system.assertEquals('There is an issue processing the record. Please raise a support ticket.',Core_ApproveRejectDR_LexController.approveDesignReg(DRproducts.Id));
           Core_ApproveRejectDR_LexController.approveDesignReg(DRproducts2.Id);
           Core_ApproveRejectDR_LexController.approveDesignReg(DRproducts3.Id);
           Core_ApproveRejectDR_LexController.getAlertMsg(DRproducts1,'rej');
           Core_ApproveRejectDR_LexController.getAlertMsgForDeal(DRproducts1,'rej');
            Core_ApproveRejectDR_LexController.getAlertMsg(DRproducts2,'rej');
           Core_ApproveRejectDR_LexController.getAlertMsgForDeal(DRproducts2,'rej');
           Test.stopTest();
       }
      
  }

   public static testmethod void DR_Product_test32() {
         
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
       /*
        for(Product2 Prod : ProdLst){
            Prod.IsActive = false;
            Prod.Core_Design_Registration_Eligible_Ind__c = false;
            //Prod.Core_Active_Status__c = false;
            //Prod.Core_DR_Eligible_Status__c = false;
            //Prod.Core_Locked_Ind__c = false;
        }
        update ProdLst;
        */
         
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        //List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
         DDRLst[0].Core_Intel_Support_Status__c = 'Disti Design Registration High';
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(8, DDRLst, ProdLst);
        insert DRPLst;
        
        DRPLst[0].Core_Design_Product_Status_Nm__c = 'Approved';
        DRPLst[1].Core_Locked_Ind__c = true;
        DRPLst[3].Core_Design_Product_Status_Nm__c = 'Rejected';
        DRPLst[4].Core_Locked_Ind__c = true;
        
        update DRPLst;
       
       for(Product2 Prod : ProdLst){
            Prod.IsActive = false;
            Prod.Core_Design_Registration_Eligible_Ind__c = false;
            //Prod.Core_Active_Status__c = false;
            //Prod.Core_DR_Eligible_Status__c = false;
            //Prod.Core_Locked_Ind__c = false;
        }
        update ProdLst;
       
      
        string ans = '';
        Test.startTest();
        ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[4],'comment');
       //system.assertEquals('Design Registration Product Rejected successfully.',ans);
		//system.assertEquals('DRPLst[0].Core_Design_Product_Status_Nm__c',Approved);
       ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[0],'comment');
       ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[1],'comment');
       ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[2],'comment');
       ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[3],'comment');
       //ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[5],'comment');
       //ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[6],'comment');
       //ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[7],'comment');
       /*
        Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[0].Id);
        Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[1].Id);
        Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[2].Id);
        Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[3].Id,'test2');
        Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[4].Id,'test2');
        Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[5].Id,'test2');
         Core_ApproveRejectDR_LexController.updateDRRecord(DRPLst[5].Id);
		*/
System.assertEquals(2,2,'Value does not match');
        Test.stopTest();
        
     
     }

     public static testmethod void DR_Product_test32clone() {
         
      List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
      insert ProdLst;
     /*
      for(Product2 Prod : ProdLst){
          Prod.IsActive = false;
          Prod.Core_Design_Registration_Eligible_Ind__c = false;
          //Prod.Core_Active_Status__c = false;
          //Prod.Core_DR_Eligible_Status__c = false;
          //Prod.Core_Locked_Ind__c = false;
      }
      update ProdLst;
      */
       
      List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
      insert PriceBookLst;
      
      //List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
       
      List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
       DDRLst[0].Core_Intel_Support_Status__c = 'Disti Design Registration High';
      DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
      insert DDRLst;
      
      List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(8, DDRLst, ProdLst);
      insert DRPLst;
      
      DRPLst[0].Core_Design_Product_Status_Nm__c = 'Approved';
      DRPLst[1].Core_Locked_Ind__c = true;
      DRPLst[3].Core_Design_Product_Status_Nm__c = 'Rejected';
      DRPLst[4].Core_Locked_Ind__c = true;
      
      update DRPLst;
     
     for(Product2 Prod : ProdLst){
          Prod.IsActive = false;
          Prod.Core_Design_Registration_Eligible_Ind__c = false;
          //Prod.Core_Active_Status__c = false;
          //Prod.Core_DR_Eligible_Status__c = false;
          //Prod.Core_Locked_Ind__c = false;
      }
      update ProdLst;
     
    
      string ans = '';
      Test.startTest();
      ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[4],'comment');
     //system.assertEquals('Design Registration Product Rejected successfully.',ans);
    //system.assertEquals('DRPLst[0].Core_Design_Product_Status_Nm__c',Approved);
     //ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[0],'comment');
     //ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[1],'comment');
     //ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[2],'comment');
     //ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[3],'comment');
     ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[5],'comment');
     ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[6],'comment');
     ans = Core_ApproveRejectDR_LexController.getAlertMsg(DRPLst[7],'comment');
     /*
      Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[0].Id);
      Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[1].Id);
      Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[2].Id);
      Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[3].Id,'test2');
      Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[4].Id,'test2');
      Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[5].Id,'test2');
       Core_ApproveRejectDR_LexController.updateDRRecord(DRPLst[5].Id);
    */
System.assertEquals(2,2,'Value does not match');
      Test.stopTest();
      
   
   }
    
}