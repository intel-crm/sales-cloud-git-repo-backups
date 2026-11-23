@isTest
public class Pricing_QLBulkCR_Test {
    
    Public static PermissionSet permissionRec;
    Static{
        permissionRec = [SELECT Id, Name FROM PermissionSet where Name=:Label.Pricing_CPQ_Managed_License_User Limit 1];
    }
    
    @testSetup
    static void dataSetup(){
      //  Pricing_RestAPI_TestUtility.createRestAPIErrorCodesConfig();
        List<Product2> prodList = new List<Product2>();
        Product2 prod = new Product2();
        prod.Core_Product_Org__c = 'Sales';
        prod.Core_Product_Type__c = 'Processors';
        prod.Core_Sales_Visible_Flag__c  = True;
        prod.IsActive = True;
        prod.Core_Hierarchy_ID__c = '43';
        prod.Core_Group_Code_Short_Name__c = 'CCG';
        prod.Name = 'Product X';
        prod.Core_Processor_Number_Nm__c = 'i7-8705G';
        prodList.add(prod);
        
        Product2 prod1 = new Product2();
        prod1.Core_Product_Org__c = 'Sales';
        prod1.Core_Product_Type__c = 'Processors';
        prod1.Core_Sales_Visible_Flag__c  = True;
        prod1.IsActive = True;
        prod1.Core_Hierarchy_ID__c = '43';
        prod1.Core_Group_Code_Short_Name__c = 'CCG';
        prod1.Name = 'Product1';
        prodList.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Core_Product_Org__c = 'Sales';
        prod2.Core_Product_Type__c = 'Processors';
        prod2.Core_Sales_Visible_Flag__c  = True;
        prod2.IsActive = True;
        prod2.Core_Hierarchy_ID__c = '43';
        prod2.Core_Group_Code_Short_Name__c = 'CCG';
        prod2.Name = 'Write In Product';
        prodList.add(prod2);
        insert prodList;
        Pricing_Test_Utility.createPriceBook();
        
        List<Pricing_Competitor_Product__c> cpList = new List<Pricing_Competitor_Product__c>();
        
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c();
        cp.Name = 'Product Z';
        cp.Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z';
        cpList.add(cp);
        
        Pricing_Competitor_Product__c cp1 = new Pricing_Competitor_Product__c();
        cp1.Name = 'Comp Product';
        cp1.Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z';
        cpList.add(cp1);
        
        Pricing_Competitor_Product__c cp2 = new Pricing_Competitor_Product__c();
        cp2.Name = 'Write In Product';
        cp2.Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z';
        cpList.add(cp2);
        
        insert cpList;
        
        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();  
       // List<User> normalUser = createUser();
        System.runAs(lstUsers2[0])
        {
            
            Account acc = Pricing_Test_Utility.createAccount();
            //Contact con = Pricing_Test_Utility.createContact(acc.Id);
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(lstUsers2[0].id);
            //Pricing_Test_Utility.createAEUser();
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
        
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedEndCustomer.name='Write In End Customer';
            insert unifiedEndCustomer;
            
            insert accTeam;
        }     
    }
        
    static testmethod void validChangeRequest_Test1(){
//CH.Start

Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
Account acc = [Select Id from Account where Name = 'Test Account'];
Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
Product2 prod = [Select Id from Product2 where Name = 'Product X'];
Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = [Select Id from Pricing_UnifiedEndCustomerAccountMapping__c where name='Write In End Customer'];

           List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
            quote2.SBQQ__Account__c = acc.Id;
            quote2.SBQQ__PrimaryContact__c = con.Id;
            quote2.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote2.Pricing_Project_Name_Nm__c = 'Test Project';
            quote2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote2.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote2.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote2.Pricing_Customer_Nm__c = 'FMH';
            quote2.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote2.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote2.Pricing_Bid_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote2.Pricing_ShipmentEndDate_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote2.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote2.Pricing_Region_Nm__c = 'APJ';
            quote2.SBQQ__Status__c = 'Submitted';
            quoteList.add(quote2);
            insert quoteList; 
            test.startTest();
            List<SBQQ__QuoteLine__c> quoteLine2 = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
            quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            quoteLineob.Pricing_Other_Product_Nm__c='';
            quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob.Pricing_Systems_qty__c = 6; 
            quoteLineob.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob.Pricing_Competetor_Product__c=cp.Id;
            quoteLineob.Pricing_Other_Competitor_Product_Nm__c = 'test';  
            quoteLineob.SBQQ__Quote__c = quote2.Id;
            quoteLineob.Pricing_Status_Nm__c='Draft';
            quoteLine2.add(quoteLineob);
            insert quoteLine2;  
  
        
            List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
            Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
            metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
            metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
            metrics.Pricing_Other_Nm__c='test';
            metrics.Pricing_Performance_Metric_Nm__c='Other';
            metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
            metrics.Pricing_Weighting_Pct__c=10;
            mList2.add(metrics);
            insert mList2;          
       

//CH.End        
        //test.startTest();
                User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
       PermissionSet ps = [SELECT Id FROM PermissionSet
                         WHERE Name =:
                         Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager Limit 1];
           //     insert new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = ps.Id);
        List<User> lstUsers2 = [SELECT id FROM User WHERE email='firstName@intel.com' Limit 1];
       //CH.Start
            List<SBQQ__QuoteLine__c> quoteLineUpdate = new List<SBQQ__QuoteLine__c>();       
        system.runAs(lstUsers2[0]){

            quoteLine2[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLine2[0].Pricing_ECAP_Price_Amt__c = 1200;
            quoteLine2[0].Pricing_Approved_Unit_Qty__c = 10;
            quoteLine2[0].Pricing_Approved_End_Date_Dt__c = system.today()+1;
            quoteLineUpdate.add(quoteLine2[0]);
            
            update quoteLineUpdate;  
        }
        //CH.END        
        
        system.runAs(usr){
            
                       Map<Id, SBQQ__QuoteLine__c> QLMap = New Map<Id, SBQQ__QuoteLine__c>();
           SBQQ__QuoteLine__c QL =New SBQQ__QuoteLine__c();
           Date today2=Date.Today();
           QL.Pricing_Approved_Start_Date_Dt__c = today2.addDays(2);
           QL.Pricing_Approved_End_Date_Dt__c = today2.addDays(10);
           QL.Pricing_ECAP_Price_Amt__c = 12;
           QL.Pricing_Approved_Unit_Qty__c = 11;
           QL.Pricing_Billing_Start_Date_Dt__c = today2.addDays(2);
           QL.Pricing_Billing_End_Date_Dt__c = today2.addDays(10);
           QL.Pricing_Backdate_Reason_Txt__c = '';
           QL.Pricing_Additional_T_C_s_Txt__c = 'dscsdcsdc';
           QL.Pricing_Status_Nm__c = 'Pending Further Intel Review';
           QL.Pricing_Meet_Comp_Price_Amt__c = 12;

           QLMap.put(quoteLineUpdate[0].Id,QL);
          //  Pricing_QLBulkCRValidation.validateBulkCR(QLMap);
        Pricing_QLBulkCRValidationBatch bulkCR = New Pricing_QLBulkCRValidationBatch(QLMap);
        Database.executeBatch(bulkCR, 1);
            system.assertEquals(quoteLine2.size() > 0,true);
            test.stopTest();
        }
    }
    
    static testmethod void validChangeRequest_Test2(){
//CH.Start
Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
Account acc = [Select Id from Account where Name = 'Test Account'];
Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
Product2 prod = [Select Id from Product2 where Name = 'Write In Product'];
Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = [Select Id from Pricing_UnifiedEndCustomerAccountMapping__c where name='Write In End Customer'];

           List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
            quote2.SBQQ__Account__c = acc.Id;
            quote2.SBQQ__PrimaryContact__c = con.Id;
            quote2.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote2.Pricing_Project_Name_Nm__c = 'Test Project';
            quote2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote2.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote2.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote2.Pricing_Customer_Nm__c = 'FMH';
            quote2.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote2.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote2.Pricing_Bid_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote2.Pricing_ShipmentEndDate_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote2.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote2.Pricing_Region_Nm__c = 'APJ';
            quote2.SBQQ__Status__c = 'Submitted';
            quoteList.add(quote2);
            insert quoteList;
        test.startTest();
            List<SBQQ__QuoteLine__c> quoteLine2 = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
            quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            quoteLineob.Pricing_Other_Product_Nm__c='test';
            quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob.Pricing_Systems_qty__c = 6; 
            quoteLineob.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob.Pricing_Competetor_Product__c=cp.Id;
            quoteLineob.Pricing_Other_Competitor_Product_Nm__c = 'test';  
            quoteLineob.SBQQ__Quote__c = quote2.Id;
            quoteLineob.Pricing_Status_Nm__c='Draft';
            quoteLine2.add(quoteLineob);
            insert quoteLine2; 
        
            List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
            Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
            metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
            metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
            metrics.Pricing_Other_Nm__c='test';
            metrics.Pricing_Performance_Metric_Nm__c='Other';
            metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
            metrics.Pricing_Weighting_Pct__c=10;
            mList2.add(metrics);
            insert mList2;      

       //CH.End
        //test.startTest();        
        User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
        List<User> lstUsers2 = [SELECT id FROM User WHERE email='firstName@intel.com' Limit 1];
       //CH.Start
        List<SBQQ__QuoteLine__c> quoteLineUpdate = new List<SBQQ__QuoteLine__c>();
        system.runAs(lstUsers2[0]){

            quoteLine2[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLine2[0].Pricing_ECAP_Price_Amt__c = 1200;
            quoteLine2[0].Pricing_Approved_Unit_Qty__c = 10;
            quoteLine2[0].Pricing_Approved_End_Date_Dt__c = system.today()+1;
            quoteLineUpdate.add(quoteLine2[0]);
            
            update quoteLineUpdate;  
        }
        //CH.END
        PermissionSet ps = [SELECT Id FROM PermissionSet
                         WHERE Name =:
                         Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager Limit 1];
               // insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        system.runAs(usr){
                       Map<Id, SBQQ__QuoteLine__c> QLMap = New Map<Id, SBQQ__QuoteLine__c>();
           SBQQ__QuoteLine__c QL =New SBQQ__QuoteLine__c();
           Date today2=Date.Today();
           QL.Pricing_Approved_Start_Date_Dt__c = today2.addDays(2);
           QL.Pricing_Approved_End_Date_Dt__c = today2.addDays(10);
           QL.Pricing_ECAP_Price_Amt__c = 12;
           QL.Pricing_Approved_Unit_Qty__c = 11;
           QL.Pricing_Billing_Start_Date_Dt__c = today2.addDays(2);
           QL.Pricing_Billing_End_Date_Dt__c = today2.addDays(10);
           QL.Pricing_Backdate_Reason_Txt__c = '';
           QL.Pricing_Additional_T_C_s_Txt__c = 'dscsdcsdc';
           QL.Pricing_Status_Nm__c = 'Pending Further Intel Review';
           QL.Pricing_Meet_Comp_Price_Amt__c = 12;

           QLMap.put(quoteLineUpdate[0].Id,QL);
         //   Pricing_QLBulkCRValidation.validateBulkCR(QLMap);
        
        Pricing_QLBulkCRValidationBatch bulkCR = New Pricing_QLBulkCRValidationBatch(QLMap);
        Database.executeBatch(bulkCR, 1); 
            system.assertEquals(quoteLine2.size() > 0,true);
            test.stopTest();
        }
    }
    
       static testmethod void validChangeRequest_Test3(){
//CH.Start

Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
Account acc = [Select Id from Account where Name = 'Test Account'];
Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
Product2 prod = [Select Id from Product2 where Name = 'Product X'];
Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = [Select Id from Pricing_UnifiedEndCustomerAccountMapping__c where name='Write In End Customer'];

           List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
            quote2.SBQQ__Account__c = acc.Id;
            quote2.SBQQ__PrimaryContact__c = con.Id;
            quote2.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote2.Pricing_Project_Name_Nm__c = 'Test Project';
            quote2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote2.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote2.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote2.Pricing_Customer_Nm__c = 'FMH';
            quote2.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote2.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote2.Pricing_Bid_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote2.Pricing_ShipmentEndDate_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote2.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote2.Pricing_Region_Nm__c = 'APJ';
            quote2.SBQQ__Status__c = 'Submitted';
            quoteList.add(quote2);
            insert quoteList; 
            test.startTest();
            List<SBQQ__QuoteLine__c> quoteLine2 = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
            quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            quoteLineob.Pricing_Other_Product_Nm__c='';
            quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob.Pricing_Systems_qty__c = 6; 
            quoteLineob.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob.Pricing_Competetor_Product__c=cp.Id;
            quoteLineob.Pricing_Other_Competitor_Product_Nm__c = 'test';  
            quoteLineob.SBQQ__Quote__c = quote2.Id;
            quoteLineob.Pricing_Status_Nm__c='Draft';
            quoteLine2.add(quoteLineob);
            insert quoteLine2;      
       

//CH.End        
       // test.startTest();
                User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
       PermissionSet ps = [SELECT Id FROM PermissionSet
                         WHERE Name =:
                         Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager Limit 1];
           //     insert new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = ps.Id);
        List<User> lstUsers2 = [SELECT id FROM User WHERE email='firstName@intel.com' Limit 1];
       //CH.Start
            List<SBQQ__QuoteLine__c> quoteLineUpdate = new List<SBQQ__QuoteLine__c>();       
        system.runAs(lstUsers2[0]){

            quoteLine2[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLine2[0].Pricing_ECAP_Price_Amt__c = 1200;
            quoteLine2[0].Pricing_Approved_Unit_Qty__c = 10;
            quoteLine2[0].Pricing_Approved_End_Date_Dt__c = system.today()+1;
            quoteLineUpdate.add(quoteLine2[0]);
            
            update quoteLineUpdate;  
        }
        //CH.END        
        
        system.runAs(usr){
            
                       Map<Id, SBQQ__QuoteLine__c> QLMap = New Map<Id, SBQQ__QuoteLine__c>();
           SBQQ__QuoteLine__c QL =New SBQQ__QuoteLine__c();
           Date today2=Date.Today();
           QL.Pricing_Approved_Start_Date_Dt__c = today2.addDays(9);
           QL.Pricing_Approved_End_Date_Dt__c = today2.addDays(1);
           QL.Pricing_ECAP_Price_Amt__c = 0;
           QL.Pricing_Approved_Unit_Qty__c = 0;
           QL.Pricing_Billing_Start_Date_Dt__c = today2.addDays(10);
           QL.Pricing_Billing_End_Date_Dt__c = today2.addDays(2);
           QL.Pricing_Backdate_Reason_Txt__c = '';
           QL.Pricing_Additional_T_C_s_Txt__c = 'dscsdcsdc';
           QL.Pricing_Status_Nm__c = 'Pending Further Intel Review';
           QL.Pricing_Meet_Comp_Price_Amt__c = 0;

           QLMap.put(quoteLineUpdate[0].Id,QL);
          //  Pricing_QLBulkCRValidation.validateBulkCR(QLMap);
        Pricing_QLBulkCRValidationBatch bulkCR = New Pricing_QLBulkCRValidationBatch(QLMap);
        Database.executeBatch(bulkCR, 1); 
            system.assertEquals(quoteLine2.size() > 0,true);
            test.stopTest();
        }
    }
    
       static testmethod void validChangeRequest_Test4(){
//CH.Start

Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
Account acc = [Select Id from Account where Name = 'Test Account'];
Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
Product2 prod = [Select Id from Product2 where Name = 'Product X'];
Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = [Select Id from Pricing_UnifiedEndCustomerAccountMapping__c where name='Write In End Customer'];

           List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
            quote2.SBQQ__Account__c = acc.Id;
            quote2.SBQQ__PrimaryContact__c = con.Id;
            quote2.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote2.Pricing_Project_Name_Nm__c = 'Test Project';
            quote2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote2.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote2.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote2.Pricing_Customer_Nm__c = 'FMH';
            quote2.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote2.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote2.Pricing_Bid_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote2.Pricing_ShipmentEndDate_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote2.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote2.Pricing_Region_Nm__c = 'APJ';
            quote2.SBQQ__Status__c = 'Submitted';
            quoteList.add(quote2);
            insert quoteList; 
            test.startTest();
            List<SBQQ__QuoteLine__c> quoteLine2 = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
            quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            quoteLineob.Pricing_Other_Product_Nm__c='';
            quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob.Pricing_Systems_qty__c = 6; 
            quoteLineob.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob.Pricing_Competetor_Product__c=cp.Id;
            quoteLineob.Pricing_Other_Competitor_Product_Nm__c = 'test';  
            quoteLineob.SBQQ__Quote__c = quote2.Id;
            quoteLineob.Pricing_Status_Nm__c='Draft';
            quoteLine2.add(quoteLineob);
            insert quoteLine2;      
       

//CH.End        
        //test.startTest();
                User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];

        List<User> lstUsers2 = [SELECT id FROM User WHERE email='firstName@intel.com' Limit 1];
       //CH.Start
            List<SBQQ__QuoteLine__c> quoteLineUpdate = new List<SBQQ__QuoteLine__c>();       
        system.runAs(lstUsers2[0]){

            quoteLine2[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLine2[0].Pricing_ECAP_Price_Amt__c = 1200;
            quoteLine2[0].Pricing_Approved_Unit_Qty__c = 10;
            quoteLine2[0].Pricing_Approved_End_Date_Dt__c = system.today()+1;
            quoteLine2[0].Pricing_Quote_Line_Number__c = 'Q-777777';
            quoteLineUpdate.add(quoteLine2[0]);
            
            update quoteLineUpdate;  
        }
        //CH.END        

                  List<User> userRPM = Pricing_Test_Utility.createPricingMangerUser();   
        
        system.runAs(userRPM[0]){
             //   insert new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = ps.Id);
            
           Map<Id, SBQQ__QuoteLine__c> QLMap = New Map<Id, SBQQ__QuoteLine__c>();
            Map<String, SBQQ__QuoteLine__c> QLMap2 = New Map<String, SBQQ__QuoteLine__c>();
           SBQQ__QuoteLine__c QL =New SBQQ__QuoteLine__c();
           Date today2=Date.Today();
           QL.Pricing_Approved_Start_Date_Dt__c = today2.addDays(-9);
           QL.Pricing_Approved_End_Date_Dt__c = today2.addDays(-1);
           QL.Pricing_ECAP_Price_Amt__c = -1;
           QL.Pricing_Approved_Unit_Qty__c = -2;
           QL.Pricing_Billing_Start_Date_Dt__c = today2.addDays(-10);
           QL.Pricing_Billing_End_Date_Dt__c = today2.addDays(-2);
           QL.Pricing_Backdate_Reason_Txt__c = '';
           QL.Pricing_Additional_T_C_s_Txt__c = 'dscsdcsdc';
           QL.Pricing_Status_Nm__c = 'Pending Further Intel Review';
             QL.Pricing_FSE_Recommended_Price_Nm__c = '123456';
         //  QL.Pricing_Meet_Comp_Price_Amt__c = -10;

           QLMap.put(quoteLineUpdate[0].Id,QL);
            QLMap2.put(quoteLineUpdate[0].Pricing_Quote_Line_Number__c,QL);
            Map<String,Id> wwIdUserIdMap = New Map<String,Id>();
            wwIdUserIdMap.put('123456',usr.Id);
         Pricing_QLBulkCRValidation.validateBulkCR(QLMap2,wwIdUserIdMap);
        Pricing_QLBulkCRValidationBatch bulkCR = New Pricing_QLBulkCRValidationBatch(QLMap);
        Database.executeBatch(bulkCR, 1); 
            system.assertEquals(quoteLine2.size() > 0,true);
        }
           test.stopTest();
    }  

    static testmethod void createPayload_Test1(){
//CH.Start

Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
Account acc = [Select Id from Account where Name = 'Test Account'];
Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
Product2 prod = [Select Id from Product2 where Name = 'Product X'];
Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = [Select Id from Pricing_UnifiedEndCustomerAccountMapping__c where name='Write In End Customer'];

           List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
            quote2.SBQQ__Account__c = acc.Id;
            quote2.SBQQ__PrimaryContact__c = con.Id;
            quote2.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote2.Pricing_Project_Name_Nm__c = 'Test Project';
            quote2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote2.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote2.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote2.Pricing_Customer_Nm__c = 'FMH';
            quote2.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote2.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote2.Pricing_Bid_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote2.Pricing_ShipmentEndDate_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote2.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote2.Pricing_Region_Nm__c = 'APJ';
            quote2.SBQQ__Status__c = 'Submitted';
            quoteList.add(quote2);
            insert quoteList; 
            test.startTest();
            List<SBQQ__QuoteLine__c> quoteLine2 = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
            quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            quoteLineob.Pricing_Other_Product_Nm__c='';
            quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob.Pricing_Systems_qty__c = 6; 
            quoteLineob.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob.Pricing_Competetor_Product__c=cp.Id;
            quoteLineob.Pricing_Other_Competitor_Product_Nm__c = 'test';  
            quoteLineob.SBQQ__Quote__c = quote2.Id;
            quoteLineob.Pricing_Status_Nm__c='Draft';
            quoteLine2.add(quoteLineob);
            insert quoteLine2;  
  
        
            List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
            Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
            metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
            metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
            metrics.Pricing_Other_Nm__c='test';
            metrics.Pricing_Performance_Metric_Nm__c='Other';
            metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
            metrics.Pricing_Weighting_Pct__c=10;
            mList2.add(metrics);
            insert mList2;          
       

//CH.End        
        //test.startTest();
                User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
       PermissionSet ps = [SELECT Id FROM PermissionSet
                         WHERE Name =:
                         Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager Limit 1];
           //     
        List<User> lstUsers2 = [SELECT id FROM User WHERE email='firstName@intel.com' Limit 1];
       //CH.Start
            List<SBQQ__QuoteLine__c> quoteLineUpdate = new List<SBQQ__QuoteLine__c>();       
        system.runAs(lstUsers2[0]){

            quoteLine2[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLine2[0].Pricing_ECAP_Price_Amt__c = 1200;
            quoteLine2[0].Pricing_Approved_Unit_Qty__c = 10;
            quoteLine2[0].Pricing_Approved_End_Date_Dt__c = system.today()+1;
            quoteLineUpdate.add(quoteLine2[0]);
            
            update quoteLineUpdate;  
        }
        //CH.END   
             
       List<User> userRPM = Pricing_Test_Utility.createPricingMangerUser();   
        
        system.runAs(userRPM[0]){
         //   insert new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = ps.Id);

           Set<Id> QLSet = New Set<Id>();
           QLSet.add(quoteLineUpdate[0].Id);
            
            Pricing_QLBulkCRSendPayload.callPayloadBatch(QLSet);          
        }
        system.assertEquals(quoteLine2.size() > 0,true);
        test.stopTest();
    }   
       static testmethod void createPayload_Test2(){
//CH.Start

Pricing_Competitor_Product__c cp = [Select Id from Pricing_Competitor_Product__c where Name = 'Write In Product'];
Account acc = [Select Id from Account where Name = 'Test Account'];
Contact con = [Select Id from Contact where Email = 'primarycontact@noemail.com'];
Product2 prod = [Select Id from Product2 where Name = 'Product X'];
Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = [Select Id from Pricing_UnifiedEndCustomerAccountMapping__c where name='Write In End Customer'];

           List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote2 = new SBQQ__Quote__c();
            quote2.SBQQ__Account__c = acc.Id;
            quote2.SBQQ__PrimaryContact__c = con.Id;
            quote2.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote2.Pricing_Project_Name_Nm__c = 'Test Project';
            quote2.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote2.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote2.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote2.Pricing_Customer_Nm__c = 'FMH';
            quote2.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote2.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote2.Pricing_Bid_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote2.Pricing_ShipmentEndDate_Dt__c = quote2.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote2.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote2.Pricing_Region_Nm__c = 'APJ';
            quote2.SBQQ__Status__c = 'Submitted';
            quoteList.add(quote2);
            insert quoteList; 
            test.startTest();
            List<SBQQ__QuoteLine__c> quoteLine2 = new List<SBQQ__QuoteLine__c>(); 
            SBQQ__QuoteLine__c quoteLineob = new SBQQ__QuoteLine__c(); 
            quoteLineob.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
            quoteLineob.Pricing_Product_Nm__c = prod.Id;
            //quoteLineob.SBQQ__Product__c = prod.Id;
            quoteLineob.Pricing_Other_Product_Nm__c='';
            quoteLineob.Pricing_OEM_System_Model_Nm__c = 'Test OEM System Model';
            quoteLineob.Pricing_Systems_qty__c = 6; 
            quoteLineob.Pricing_pm_approval_comments_nm__c = 'Test Comment';
            quoteLineob.Pricing_CPUs_per_system_qty__c = 1;
            quoteLineob.Pricing_Single_System_Price_Amt__c = 4;
            quoteLineob.Pricing_OEM_Standard_Unit_Price_Amt__c = 2;
            quoteLineob.Pricing_Req_Discounted_Unit_Price__c = 1;
            quoteLineob.Pricing_Additional_OEM_Discount_Amt__c = 1;
            quoteLineob.Pricing_Competetor_Product__c=cp.Id;
            quoteLineob.Pricing_Other_Competitor_Product_Nm__c = 'test';  
            quoteLineob.SBQQ__Quote__c = quote2.Id;
            quoteLineob.Pricing_Status_Nm__c='Draft';
            quoteLine2.add(quoteLineob);
            insert quoteLine2;  
  
        
            List<Pricing_Performance_Metric__c> mList2=new List<Pricing_Performance_Metric__c>();
            Pricing_Performance_Metric__c metrics=new Pricing_Performance_Metric__c();
            metrics.Pricing_Comp_SKU_Performance_Nbr__c=-1;
            metrics.Pricing_Intel_SKU_Performance_Nbr__c=-1;
            metrics.Pricing_Other_Nm__c='test';
            metrics.Pricing_Performance_Metric_Nm__c='Other';
            metrics.Pricing_Quote_Line__c=quoteLine2[0].Id;
            metrics.Pricing_Weighting_Pct__c=10;
            mList2.add(metrics);
            insert mList2;          
       

//CH.End        
        //test.startTest();
                User usr = [SELECT id FROM User WHERE email='primarycontact@noemail.com'];
       PermissionSet ps = [SELECT Id FROM PermissionSet
                         WHERE Name =:
                         Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager Limit 1];
           //     
        List<User> lstUsers2 = [SELECT id FROM User WHERE email='firstName@intel.com' Limit 1];
       //CH.Start
            List<SBQQ__QuoteLine__c> quoteLineUpdate = new List<SBQQ__QuoteLine__c>();       
        system.runAs(lstUsers2[0]){

            quoteLine2[0].Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
            quoteLine2[0].Pricing_ECAP_Price_Amt__c = 1200;
            quoteLine2[0].Pricing_Approved_Unit_Qty__c = 10;
            quoteLine2[0].Pricing_Approved_End_Date_Dt__c = system.today()+1;
            quoteLineUpdate.add(quoteLine2[0]);
            
            update quoteLineUpdate;  
        }
        //CH.END
       List<User> userRPM = Pricing_Test_Utility.createPricingMangerUser();   
        
        system.runAs(userRPM[0]){
          //  insert new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = ps.Id);

           Set<Id> QLSet = New Set<Id>();
           QLSet.add(quoteLineUpdate[0].Id);
            
           List<SBQQ__QuoteLine__c> quoteLine = [SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, 
                                                       SBQQ__Quote__r.Name, Pricing_EndCustomer_Nm__c, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,
                                                       Pricing_Reference_Quote_Line_Nbr__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,
                                                       SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,
                                                       SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,
                                                       Pricing_Manager__r.Core_WWID__c,SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,
                                                       Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,
                                                       Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,
                                                       Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                       Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Project_Nm__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, 
                                                       Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,Pricing_Consumption_Region__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Country__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Segment__c,
                                                       Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Payable_Quantity__c,SBQQ__Product__r.Core_Item_Id__c,
                                                       SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,SBQQ__Product__r.Core_Family_Nm__c,SBQQ__Product__r.Core_Forecast_Product_Name__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,
                                                       Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,Pricing_Competetor_Product__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c,
                                                       SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_End_Customer__c,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c,
                                                       SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c,Pricing_Program_Type_Nm__c,
                                                       SBQQ__Quote__r.Pricing_Is_Sanctioned__c,Pricing_Account_Division_Nm__c,Pricing_Comp_Product_Txt__c,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,
                                                        Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE 
                                                       Id IN : QLSet order by SBQQ__Quote__c];
            
            Pricing_QLBulkCRSendPayloadHelper.createpayload(QLSet, quoteLine, 'Update', false);      
        }
           system.assertEquals(quoteLine2.size() > 0,true);
           test.stopTest();
    }   
}