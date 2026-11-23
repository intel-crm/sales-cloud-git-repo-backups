@isTest(SeeAllData=false) 
public class PCC_DataUpload_Test {
    
    @TestSetup 
    static void makeData(){    
        Id contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        
        Core_Trigger_Executions__c oppCS1 = new Core_Trigger_Executions__c(Name='BypassOpportunityTrigger',Core_Active__c = true,Core_Class_Name__c='Opportunity',Core_Description__c='TestDescription',Core_Object__c='TestObject',Core_Trigger_Events__c = 'TestEvent');
        insert oppCS1;
        
        Core_Opp_Bypass_Validation_Rule__c rule = new Core_Opp_Bypass_Validation_Rule__c(Bypass__c = true);
        insert rule;
        
        CORE_DDR_TriggerHandler.executeTrigger = false;
        
        List<account> LstAcc = Core_Test_Utility.createAccount(1);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();      
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert LstAcc;
        }
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = LstAcc[0].Id;
        c1.Email='test.user@intel.com';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_PartnerRole__c = 'Service Provider';
        c1.Email = 'test.diqhwqi@test.com';
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert c1;}
        
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Id DistiProid = [select id, name from profile where name='Partner'].id;
        User DistiUser = new User(alias = 'PCCBatch', email='pccdatauploadtest@test.com',
                                  emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid = DistiProid, IsActive =true,
                                  contactId = c1.Id,
                                  timezonesidkey='America/Los_Angeles', username='pccdatauploadtest@crm.com');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert DistiUser;
        }
        
        Profile p = [select Id from Profile where Name = 'Sales Manager'];
        
        User OSOOwner = new User(Alias = 'OSOOwner', Email='OSOOwner@apttus.com',
                                 EmailEncodingKey='UTF-8', LastName='TTest', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='OSOOwner@mail.com', Department='OSC', Core_User_Geo__c = 'PRC');
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert OSOOwner;}
        
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        
        PermissionSet ddrExternal = [SELECT Id, Name FROM PermissionSet where Name = 'Core_DDR_Permission_Set'];   
        PermissionSet ddrInternal = [SELECT Id, Name FROM PermissionSet where Name = 'DDR_Internal_Users'];   
        
        PermissionSetAssignment  psa1 = new PermissionSetAssignment(PermissionSetId = ddrExternal.Id, AssigneeId = DistiUser.Id);
        PermissionSetAssignment  psa2 = new PermissionSetAssignment(PermissionSetId = ddrInternal.Id, AssigneeId = OSOOwner.Id);
        psaList.add(psa1);
        psaList.add(psa2);
        System.runAs(Core_Test_Utility.systemAdminUser) {    
            insert psaList;
        }
        Pricebook2 pb2 = new Pricebook2();
        pb2.name = 'Partner Price Book';
        pb2.isActive = TRUE;
        
        insert pb2; 
        
        Pricebook2 pb1 = new Pricebook2();
        pb1.name = 'Standard Price Book';
        pb1.isActive = TRUE;
        
        insert pb1;
        
        Product2 product2 = new Product2();
        product2.Name = 'Intel® Core™ i3-4020M Processor (3M Cache, 2.60 GHz)';
        product2.IsActive = TRUE;
        product2.Core_Design_Registration_Eligible_Ind__c = TRUE;
        product2.Core_Sales_Visible_Flag__c = TRUE;
        product2.Core_Partner_Visible_Ind__c  = TRUE;     
        
        insert product2;
        
        List<PricebookEntry> priceBookList = new List<PricebookEntry>();
        
        PricebookEntry pbe1 = new PricebookEntry();
        pbe1.Pricebook2Id =  Test.getStandardPricebookId();
        pbe1.Product2Id = product2.id;
        pbe1.IsActive = true;
        pbe1.UnitPrice = 100;
        priceBookList.add(pbe1);
        
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Pricebook2Id =  pb2.id;
        pbe2.Product2Id = product2.id;
        pbe2.IsActive = true;
        pbe2.UnitPrice = 100;
        priceBookList.add(pbe2);
        
        insert priceBookList;
        
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        
        List<Product2> NewProducts = new List<Product2>();
        Product2 prod = new Product2();
        
        prod.name = 'Intel® Core™ i3-4020M Processor (3M Cache, 2.60 GHz)';
        prod.Core_Design_Registration_Eligible_Ind__c  = true;
        prod.Core_Sales_Visible_Flag__c = true;
        prod.isActive = true;
        prod.Core_Partner_Visible_Ind__c = true;
        prod.Core_Avail_for_New_Designs__c = true;
        
        Product2 prod2 = new Product2();
        
        prod2.name = '1300W AC CRPS 80+ Titanium efficiency power supply module AXX1300TCRPS_Sid';
        prod2.Core_Design_Registration_Eligible_Ind__c  = true;
        prod2.Core_Sales_Visible_Flag__c = true;
        prod2.isActive = true;
        prod2.Core_Partner_Visible_Ind__c = true;
        prod2.Core_Avail_for_New_Designs__c = false;
        
        NewProducts.add(prod);
        NewProducts.add(prod2);
        
        insert NewProducts;
        
        Core_Design_Registration__c ddr = new Core_Design_Registration__c();
        
        ddr.RecordTypeId = Schema.sObjectType.Core_Design_Registration__c.getRecordTypeInfosByName().get('Design Registration - Locked').getRecordTypeId(); 
        ddr.Core_Product_Group_Nm__c = 'FPGA/Power';
        ddr.Core_Design_Registration_Nm__c = 'PCC DataUpload Test DDR';
        ddr.Core_Design_Registration_Dsc__c = 'ABC';
        ddr.Core_Opportunity_Volume_Cnt__c = 5;
        ddr.Core_Partner_FAE_Nm__c = '6';            
        ddr.Core_End_Customer_Nm__c = 'DDR Test';            
        ddr.Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC ';
        ddr.Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc';
        ddr.Core_End_Customer_City_Nm__c = 'BAN';
        ddr.Core_End_Customer_Country_Subdivision_Nm__c = 'KA';
        ddr.PCC_End_Customer_Country__c  = 'United States';
        ddr.Core_End_Customer_Postal_Cd__c = '560037';
        ddr.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddr.Core_Opportunity_Decision_Dt__c = system.today()+45;
        ddr.Core_First_Customer_Ship_Dt__c = system.today()+46;
        ddr.Core_Production_End_Dt__c = system.today()+47;
        ddr.Core_Vertical_Market_Nm__c = 'Education';
        ddr.Core_Intel_Platform_Nm__c = 'Board';
        ddr.Core_Product_Application_Nm__c = 'Business Desktop';
        ddr.Core_Product_Segment_Nm__c = 'Client Computing';
        ddr.Core_Manufacturing_Region_Cd__c = 'APJ';
        ddr.Core_Design_Registration_Status_Nm__c = 'Approved';
        ddr.Core_Accepted_By_Id__c = Core_Test_Utility.systemAdminUser.id;
        ddr.Core_End_Customer_Account_Id__c = LstAcc[0].id;
        ddr.Core_Partner_Account_Id__c = LstAcc[0].id;
        ddr.Core_Intel_Support_Status__c = '';
        System.runAs(DistiUser) {
            insert ddr;
        }
        
        List<Core_Design_Registration_Product__c> DRPLst = new List<Core_Design_Registration_Product__c>();
        
        for(integer i=0; i < 2; i++)
        {
            Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
            DRproducts.Core_Opportunity_Product_Id__c = null;
            DRproducts.Core_Design_Registration_Id__c = ddr.id;
            DRproducts.Core_Product_Id__c = NewProducts[0].id;
            DRproducts.Core_Target_Resale_Amt__c = 20;
            DRproducts.Core_Full_Year_Qty__c = 3;
            DRproducts.Core_Design_Product_Status_Nm__c = 'Approved';
            DRPLst.add(DRproducts);
        }
        insert DRPLst;
    }
    
    @isTest static void testPCCDataUpload() {
        PCC_DataUpload_Batch testExec = new PCC_DataUpload_Batch();
        Database.executeBatch(testExec,200);
    }
    
}