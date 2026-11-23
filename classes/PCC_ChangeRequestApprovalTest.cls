@isTest
public class PCC_ChangeRequestApprovalTest {
    
    
    @testSetup
    static void setupTestData() {
        // Create Opportunity
        Id accIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();     
        List<Account> accList=Core_Test_Utility.createAccount(1);
        accList[0].name='Test Account';
        accList[0].RecordTypeId=accIntel;
        insert accList;
        
        
        
        // Create Product and related records
        Product2 product = new Product2(Name = 'Test Product', IsActive = true);
        insert product;
        
        // Use Standard Pricebook
        //Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        
        List<Pricebook2> lstPriceBook = new List<Pricebook2>();  
        
        Pricebook2 pb1 = new Pricebook2();
        pb1.name = 'Standard Price Book';
        pb1.isActive = TRUE;
        
        lstPriceBook.add(pb1);
        
        Pricebook2 pb2 = new Pricebook2();
        pb2.name = 'Partner Price Book';
        pb2.isActive = TRUE;
        
        lstPriceBook.add(pb2); 
        
        insert lstPriceBook;  
        
        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry spbe = new PricebookEntry(
            Product2Id = product.Id,
            UnitPrice = 1000,
            Pricebook2Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        
        
        // Create PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id,
            UnitPrice = 1000,
            Pricebook2Id = pb2.Id,
            IsActive = true
        );
        insert new List<PricebookEntry>{spbe,pbe};
            
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Define',
            AccountId = accList[0].Id,
            CloseDate = Date.today().addDays(30)
            //pricebook2Id = pb2.Id
        );
        insert opp;
        // Create Quote
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = accList[0].Id;
            //quote.SBQQ__PrimaryContact__c = con[0].Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            //quote.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote.Pricing_Customer_Nm__c = 'FMH';
            quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';
            quote.SBQQ__Status__c = 'Submitted';
            quote.SBQQ__Opportunity2__c = opp.Id;
        
        insert quote;
        
        // Create QuoteLine
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = product.Id,
            SBQQ__Quantity__c = 10
        );
        insert quoteLine;
        
        // Create Opportunity Product (Assuming SBQQ__OpportunityProduct__c is the correct object)
        OpportunityLineItem opportunityProduct = new OpportunityLineItem(TotalPrice = 240,
            Core_At_Risk_Status__c = 'In-Progress',quantity=100,opportunityId = opp.Id,SBQQ__QuoteLine__c = quoteLine.Id,Product2Id =product.Id);
        insert opportunityProduct;
        
        // Create PCC_Deal_Change_Request__c (Change Request)
        PCC_Deal_Change_Request__c changeRequest = new PCC_Deal_Change_Request__c(
            PCC_Opportunity__c = opp.Id
        );
        insert changeRequest;
        
        // Create PCC_Deal_Change_Request_Line_Item__c (Change Request Line Item)
        PCC_Deal_Change_Request_Line_Item__c changeRequestLineItem = new PCC_Deal_Change_Request_Line_Item__c(
            PCC_Change_Request_Quote_Line__c = quoteLine.Id,
            PCC_Change_Request__c = changeRequest.Id,
            PCC_Approval_Status__c = 'Approved',
            PCC_Request_Type__c = 'Change',
            //PCC_Deal_Product__c = dealProduct.Id,
            PCC_Opportunity_Product_Id__c = opportunityProduct.Id,
            PCC_Quantity__c = 10,
            PCC_Approved_Pricing_Start_Date__c = Date.today(),
            PCC_Approved_Pricing_End_Date__c = Date.today().addMonths(1)
        );
        
         PCC_Deal_Change_Request_Line_Item__c changeRequestLineItem1 = new PCC_Deal_Change_Request_Line_Item__c(
            PCC_Change_Request_Quote_Line__c = quoteLine.Id,
            PCC_Change_Request__c = changeRequest.Id,
            PCC_Approval_Status__c = 'Approved',
            PCC_Request_Type__c = 'Add',
            //PCC_Deal_Product__c = dealProduct.Id,
            PCC_Opportunity_Product_Id__c = opportunityProduct.Id,
             PCC_Product_JSON__c='{"Name":"DR-PROD-20241011-0079831"}',//,"RecordTypeId":"012D30000007OcwIAE","Core_Design_Registration_Id__c":"a3DD3000001RI2qMAG","Core_Design_Product_Status_Nm__c":"Pending","Core_Full_Year_Qty__c":966,"Core_Full_Year_Value_Amt__c":5399940,"Core_Locked_Ind__c":false,"Core_Product_Id__c":"01tD3000006HnNrIAK","Core_Target_Resale_Amt__c":5590,"Core_Product_List_Price_Amt__c":5590,"Core_Design_Registration_Nm__c":"Deal change request 105","Core_Design_Registration_Owner_Nm__c":"testdeal partner1","Core_End_Customer_Account_Nm__c":"<a href=\"/001o0000016OQZR\" target=\"_self\">IP3</a>","Core_End_Customer_City_Nm__c":"Deal change request 105","Core_End_Customer_Country_Subdivision_Nm__c":"Deal change request 105","Core_End_Customer_Nm__c":"Deal change request 105","Core_Intel_Technical_Owner_Nm__c":"Test Deal Approver User","Core_Opportunity_Nm__c":"<a href=\"/006D300000B2gNM\" target=\"_self\">Deal change request 105  20240918114212</a>","Core_Partner_FAE_Nm__c":"Deal change request 105","Core_Active_Status__c":true,"Core_DR_Eligible_Status__c":true,"core_cpq_OPN_Concatenation_txt__c":"Intel® Xeon® W Processor -","core_cpq_product_hierarchy_txt__c":"Valid Product Hierarchy","DDR_Target_Resale_Price_Note__c":"Intel will review Target Resale Price as part of the design registration review process, in order to accurately calculate the value of the design registration. Intel will not provide input or guidance on the Target Resale Price, which will/must be inputted by the Distributor registering the design. Submission of the Target Resale Price does not constitute agreement on or endorsement of that price by Intel, and it will not affect the price offered by Intel to the Distributor.","PCC_Total_Design_Registration_Price__c":5399940,"PCC_Competitor_OEM_Name__c":"Dell","PCC_Competitor_Product__c":"a8cD30000009OWVIA2","PCC_Competitor_System_Model__c":"system","PCC_Form_Factor__c":"Desktop Workstation","PCC_OEM_Name__c":"HP","PCC_Product_Additional_Attribute__c":"a6aD3000000QJ35IAG","PCC_Quote_Line_Pricing_End_Date__c":"2025-01-22","PCC_Quote_Line_Pricing_Start_Date__c":"2025-01-15","PCC_System_Model__c":"System Model","PCC_Deal_Eligible_Status__c":true,"PCC_Programs_Eligible__c":"PDI;","Id":"a3CD3000000pAv2MAE"}',
            PCC_Quantity__c = 10,
            PCC_Approved_Pricing_Start_Date__c = Date.today(),
            PCC_Approved_Pricing_End_Date__c = Date.today().addMonths(1)
        );
        
         PCC_Deal_Change_Request_Line_Item__c changeRequestLineItem2 = new PCC_Deal_Change_Request_Line_Item__c(
            PCC_Change_Request_Quote_Line__c = quoteLine.Id,
            PCC_Change_Request__c = changeRequest.Id,
            PCC_Approval_Status__c = 'Approved',
            PCC_Request_Type__c = 'Cancel',
            //PCC_Deal_Product__c = dealProduct.Id,
            PCC_Opportunity_Product_Id__c = opportunityProduct.Id,
            PCC_Quantity__c = 10,
            PCC_Approved_Pricing_Start_Date__c = Date.today(),
            PCC_Approved_Pricing_End_Date__c = Date.today().addMonths(1)
        );
        insert new List<PCC_Deal_Change_Request_Line_Item__c>{changeRequestLineItem,changeRequestLineItem1,changeRequestLineItem2};
    }
    
    
    @isTest
    public static void approveChangeReqTest(){
        Test.startTest();
        PCC_ChangeRequestApproval.approveChangeRequest(new List<Id>{[select Id from PCC_Deal_Change_Request__c limit 1].Id});
        Test.stopTest();
        
    }
    
}