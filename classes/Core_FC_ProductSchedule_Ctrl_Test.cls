/******************************************************************************************************************************************
Class Name:  Core_FC_ProductSchedule_Ctrl_Test
Version     : 1.0

Created Date: 15 JAN 2021
Function    : Test class for Core_FC_ProductSchedule_Ctrl
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar             15/01/2021              Original Version
*****************************************************************************************************************************************/

@isTest
public class Core_FC_ProductSchedule_Ctrl_Test {

    public static User sysAdmin = new User();
    public static User itAdmin = new User();    
    public static User PartnerAdmin = new User(); 
    public static List<String> listfcRec = new List<String>();
    @testSetup
    static void setup(){
        Core_Opp_Bypass_Validation_Rule__c rec = new Core_Opp_Bypass_Validation_Rule__c();
        rec.Bypass__c = true;
        insert rec;
    
        sysAdmin = [SELECT Id, Name,email,Manager.IsActive,IsActive,DelegatedApproverId,ManagerId,Manager.DelegatedApproverId FROM User WHERE isActive = TRUE AND Core_Employee_Type_Code__c = 'EMP' AND Profile.Name = 'Sales Rep-BB' AND ManagerId != '' AND Manager.DelegatedApproverId !='' AND Core_User_Type__c != 'External User' LIMIT 1];
        sysAdmin.email ='abc@intel.com';
        Profile p = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        itAdmin = [SELECT id, Name, isActive,Manager.IsActive FROM User WHERE ProfileId = :p.Id AND isActive = true LIMIT 1];
        Profile partnerp = [SELECT id, Name FROM Profile WHERE Name='Partner'];
        PartnerAdmin = [SELECT id, Name, isActive,Manager.IsActive FROM User WHERE ProfileId = :partnerp.Id AND isActive = true LIMIT 1];
        List<Core_FC_Product_Schedule_Permission__c> customSttingList = new List<Core_FC_Product_Schedule_Permission__c>();
        System.runAs(sysAdmin){
            customSttingList.add(new Core_FC_Product_Schedule_Permission__c(SetupOwnerId=UserInfo.getOrganizationId(), Core_Add_Quarter__c=true, Core_Approve_Scheduled_Quarter__c=true, Core_Edit_All_Scheduled_Quantity__c=true, Core_Recall_Last_Approval__c=true, Core_Reject_Scheduled_Quarter__c=true, Core_Start_Scheduling__c=true, Core_Submit_For_Scheduled_Quarter__c=true));
            customSttingList.add(new Core_FC_Product_Schedule_Permission__c(SetupOwnerId=sysAdmin.Id, Core_IsAdmin__c=true));
            customSttingList.add(new Core_FC_Product_Schedule_Permission__c(SetupOwnerId=p.Id, Core_IsAdmin__c=true));
            insert customSttingList;
            insert new Core_Sales_Report_URL__c(Name='6QPS_Credit', Core_Report_URL__c='test');
        }

        Account acct;
        acct = new Account(Name = 'Test Account1', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345' /*Core_CIM_ID__c = '8675309'*/,Core_Sales_Groups__c=Core_CRM_Utility.getSalesGroupAPI(),
                                  Industry='Agriculture',Core_Sub_Industry__c= 'Crop Production');
            insert acct;
              
        Id newOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        Id newOppRecTypeIddesign = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        List<Opportunity> opptyList = new List<Opportunity>();
        
            opptyList.add(new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId, Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity', Core_Coverage_Type_Nm__c= 'Deal Registration',
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdmin.Id, Core_Sales_Group__c='Global Accounts', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='ALDER LAKE D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $'/*,OwnerId= UserInfo.getUserId()*/));
            opptyList.add(new Opportunity(Name = 'Test Opportunity2', RecordTypeId = newOppRecTypeId,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdmin.Id, Core_Sales_Group__c='Regional Sales', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='ALDER LAKE D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $',Core_FC_Recall_Count__c=null/*,OwnerId= UserInfo.getUserId()*/));
       
            opptyList.add(new Opportunity(Name = 'Test Opportunity3', RecordTypeId = newOppRecTypeId, Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity', Core_Coverage_Type_Nm__c= 'Deal Registration',Core_Lead_Conversion_Flag__c = false,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = UserInfo.getUserId(), Core_Sales_Group__c='Regional Sales', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='ALDER LAKE D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $',Core_FC_Recall_Count__c=null,OwnerId= sysAdmin.Id));         
               
            opptyList.add(new Opportunity(Name = 'Test Opportunity4', RecordTypeId = newOppRecTypeIddesign,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdmin.Id, Core_Sales_Group__c='Global Accounts', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Design: Original', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='ALDER LAKE D', Core_First_Customer_Ship_Date__c= null, Core_Solution_Area__c='DCG Compute Deal $',OwnerId= UserInfo.getUserId()));
          
            opptyList.add(new Opportunity(Name = 'Test Opportunity5', RecordTypeId = newOppRecTypeId,
                AccountId = acct.Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_Technical_Owner__c = sysAdmin.Id, Core_Sales_Group__c='Global Accounts', Core_Commissionable__c ='No', Core_Opportunity_Type__c='Deal: Sell-to', Core_Product_Segment__c='Data Center Computing', Core_Product_Application__c = 'Storage', Core_Consumption_Market__c = 'Education',Core_Intel_Platform__c='ALDER LAKE D', Core_First_Customer_Ship_Date__c= System.Date.today().addMonths(8), Core_Solution_Area__c='DCG Compute Deal $',OwnerId= UserInfo.getUserId()));
            insert opptyList;
      
        
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        /*List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c> ();
       System.runAs(itAdmin){
         List<SBQQ__Quote__c> quoteList = [SELECT Id from SBQQ__Quote__c LIMIT 1];
         quoteLineList =  [SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.OwnerId,RecordType.Name,Pricing_Sales_Rep__c, Pricing_Status_Nm__c from SBQQ__QuoteLine__c  where Pricing_Approved_Start_Date_Dt__c <> null AND Pricing_Approved_End_Date_Dt__c <> null AND Pricing_Status_Nm__c NOT IN('Rejected', 'Lost', 'Cancelled')  LIMIT 2];
       }
        SBQQ__QuoteLine__c quoteLine = quoteLineList[0]; */
        List<OpportunityLineItem> oliTestList = new List<OpportunityLineItem>();
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[0].Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Production Win')); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[0].Id, PricebookEntryId= testPBEs[0].Id, Description = 'Test 11', UnitPrice=11, Quantity=2000, Core_Loss_Cancel_Reason__c = null, Core_Status__c='Pending'));
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[0].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=11, Quantity=2345, Core_Loss_Cancel_Reason__c = null, Core_Status__c='Pending'));
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[1].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending')); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[1].Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending'));  
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_Loss_Cancel_Reason__c = 'Test', Core_Status__c = 'Lost'/*,BQQ__QuoteLine__c = quoteLine.Id*/)); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[2].Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Production Win'/*,SBQQ__QuoteLine__c = quoteLine.Id*/)); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[3].Id, PricebookEntryId= testPBEs[1].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Lost'/*,BQQ__QuoteLine__c = quoteLine.Id*/)); 
            oliTestList.add(new OpportunityLineItem(OpportunityId = opptyList[3].Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Production Win'/*,BQQ__QuoteLine__c = quoteLine.Id*/)); 
            insert oliTestList;
            listfcRec.Add(oliTestList[0].Id);
            listfcRec.Add(oliTestList[1].Id);
            listfcRec.Add(oliTestList[2].Id);
            listfcRec.Add(oliTestList[3].Id);
            listfcRec.Add(oliTestList[4].Id);
            listfcRec.Add(oliTestList[5].Id);
        
        List<Core_Opp_FC_Prod_Schedule__c> insertForeCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(-3), Core_Opp_FC_Approval_Status__c = 'Approved', Core_Opp_FC_Quantity__c = 100, Core_Opp_FC_isdeleted__c = false, Core_Core_FC_Appvd_SalesPrice__c=2000));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Approval_Status__c = 'Submitted', Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(3), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 123, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(6), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 134, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(9), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 13555, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(12), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 12344, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(-3), Core_Opp_FC_Approval_Status__c = 'Approved', Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false, Core_Core_FC_Appvd_SalesPrice__c=21000));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Approval_Status__c = 'Submitted', Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(3), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(6), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(9), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[0].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(12), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(-3), Core_Opp_FC_Approval_Status__c = 'Approved', Core_Opp_FC_Quantity__c = 100, Core_Opp_FC_isdeleted__c = false, Core_Core_FC_Appvd_SalesPrice__c=3000));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Approval_Status__c = 'Submitted', Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(3), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 123, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(6), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 134, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(9), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 13555, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[0].Id, Core_Opp_FC_Product__c = oliTestList[0].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(12), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 12344, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(-3), Core_Opp_FC_Approval_Status__c = 'Approved', Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false, Core_Core_FC_Appvd_SalesPrice__c=12000));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Approval_Status__c = 'Submitted', Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(3), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(6), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(9), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(12), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 1234, Core_Opp_FC_isdeleted__c = false));       
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opptyList[2].Id, Core_Opp_Line_Item_RecordID__c = oliTestList[1].Id, Core_Opp_FC_Product__c = oliTestList[1].Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(12), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 0, Core_Opp_FC_isdeleted__c = false));
        insert insertForeCastList;
        
    }
    
    @isTest
    static void testOpty6QPSReportPCC(){
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test Opportunity3'];
        
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId= testPBEs[2].Id, Description = 'Test 11', UnitPrice=20, Quantity=11000, Core_Loss_Cancel_Reason__c = null, Core_Status__c = 'Pending'); 
        insert oli;
        
        test.startTest();   
        Core_FC_ProductSchedule_Ctrl.FCWrapper fcWrap = Core_FC_ProductSchedule_Ctrl.initializeForecast(opp.Id);
            
        Core_FC_ProductSchedule_Ctrl.FCDisplayWrapper fcDispWrap = new Core_FC_ProductSchedule_Ctrl.FCDisplayWrapper();
        
        for(Core_FC_ProductSchedule_Ctrl.FCDisplayWrapper fcDisplayWrap: fcWrap.fcDisplayWrapList){
            for (Core_FC_ProductSchedule_Ctrl.ScheduledWrapper schdWrap: fcDisplayWrap.scheduledList) {
                if(schdWrap.oppProduct == null){
                    schdWrap.oppProduct = oli;
                }
            }
        }

        String fcDisplayWrapStr = JSON.serialize(fcWrap.fcDisplayWrapList);
        String dummyFcDisplayWrapStr = JSON.serialize(fcWrap.dummyFcDisplayWrapList);
        Core_FC_ProductSchedule_Ctrl.saveAll(fcDisplayWrapStr, dummyFcDisplayWrapStr,opp, 'edit');
        Core_FC_ProductSchedule_Ctrl.saveAll(fcDisplayWrapStr, dummyFcDisplayWrapStr,opp, 'addQuarter');
        
        Core_FC_ProductSchedule_Ctrl.checkQLDates(fcDisplayWrapStr, dummyFcDisplayWrapStr,opp, 'addQuarter', 'Aura');
        Core_FC_ProductSchedule_Ctrl.checkQLDates(fcDisplayWrapStr, dummyFcDisplayWrapStr,opp, 'editQuarter', 'Aura');
        Core_FC_ProductSchedule_Ctrl.checkQLDates(fcDisplayWrapStr, dummyFcDisplayWrapStr,opp, 'editQuarter', 'Submit');
        
        Core_FC_ProductSchedule_Ctrl.open6QPSReport(opp.Id);
        //commented out as part of TWC3123-6013
        //Core_FC_ProductSchedule_Ctrl.checkFCQuarterDate(opp.Id);
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 01, 01));
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 02, 01));
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 03, 01));
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 04, 01)); 
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 06, 01)); 
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 11, 01)); 
            test.stopTest();     
    }
    
    @isTest
    static void testOptyQPSReport(){
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test Opportunity1'];
        test.startTest();
        Core_FC_ProductSchedule_Ctrl.FCWrapper fcWrap = Core_FC_ProductSchedule_Ctrl.initializeForecast(opp.Id);
        String fcDisplayWrapStr = JSON.serialize(fcWrap.fcDisplayWrapList);
        String dummyFcDisplayWrapStr = JSON.serialize(fcWrap.dummyFcDisplayWrapList);
        Core_FC_ProductSchedule_Ctrl.saveAll(fcDisplayWrapStr, dummyFcDisplayWrapStr,opp, 'edit');
        Core_FC_ProductSchedule_Ctrl.saveAll(fcDisplayWrapStr, dummyFcDisplayWrapStr,opp, 'addQuarter');
        Core_FC_ProductSchedule_Ctrl.open6QPSReport(opp.Id);
        //commented out as part of TWC3123-6013
        //Core_FC_ProductSchedule_Ctrl.checkFCQuarterDate(opp.Id);
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 01, 01));
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 02, 01));
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 03, 01));
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 04, 01));
        test.stopTest();        
    }
    
    @isTest
    static void testsubmitQuarterForApproval(){
        try{
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test Opportunity1'];
        Opportunity opp2 = [select Id, Name,Core_Number_of_Quarters__c,Core_FC_Recall_Count__c from Opportunity where Name =: 'Test Opportunity2'];
        Opportunity opp3 = [select Id, Name,Core_Number_of_Quarters__c,Core_FC_Recall_Count__c from Opportunity where Name =: 'Test Opportunity3'];
        Opportunity opp5 = [select Id, Name,Core_Number_of_Quarters__c,Core_FC_Recall_Count__c from Opportunity where Name =: 'Test Opportunity5'];
        test.startTest();
        
        Core_FC_ProductSchedule_Ctrl.FCWrapper fcWrap = Core_FC_ProductSchedule_Ctrl.initializeForecast(opp.Id);
        String fcDisplayWrapStr = JSON.serialize(fcWrap.fcDisplayWrapList);
        String quarterStatusString = JSOn.serialize(fcWrap.quarterStatusSet);
        Core_FC_ProductSchedule_Ctrl.approveQuarters(fcDisplayWrapStr, quarterStatusString, opp);
        fcWrap = Core_FC_ProductSchedule_Ctrl.initializeForecast(opp.Id);
        fcDisplayWrapStr = JSON.serialize(fcWrap.fcDisplayWrapList);
        quarterStatusString = JSOn.serialize(fcWrap.quarterStatusSet);
        opp = Core_FC_ProductSchedule_Ctrl.getOpportunityRecord(opp.Id);
        Core_FC_ProductSchedule_Ctrl.recallApproval(opp, fcDisplayWrapStr, quarterStatusString);
        Core_FC_ProductSchedule_Ctrl.recallApproval(opp2, fcDisplayWrapStr, quarterStatusString);
        Core_FC_ProductSchedule_Ctrl.rejectQuarters(fcDisplayWrapStr, quarterStatusString);
            //--------------------------------------------
        List<string> lst = new List<string>();
        Core_Opp_FC_Prod_Schedule__c fc =  [Select id,Core_Opp_FC_isdeleted__c,Core_Opp_Line_Item_RecordID__c from Core_Opp_FC_Prod_Schedule__c where Core_Opp_FC_isdeleted__c = false LIMIT 1];
        lst.add(fc.Core_Opp_Line_Item_RecordID__c);
        Core_FC_ProductSchedule_Ctrl.deletePostWinProducts(lst);  
        Core_FC_ProductSchedule_Ctrl.quarterAlignmentCheck(opp.Id);  
        String res = Core_FC_ProductSchedule_Ctrl.checkTotalQuantity(opp.Id);
        Core_FC_ProductSchedule_Ctrl.FCWrapper wrapper = Core_FC_ProductSchedule_Ctrl.getFCWrapdata(opp.Id);
        Core_FC_ProductSchedule_Ctrl.FCDisplayWrapper fcDispWrap = new Core_FC_ProductSchedule_Ctrl.FCDisplayWrapper();
         Core_FC_ProductSchedule_Ctrl.sendEmail(new List<String>{'abcd@email.com'}, new List<String>{'abcdf@email.com'}, opp, 'Test');
            //--------------------------------------------------
        //Core_FC_ProductSchedule_Ctrl.submitQuarterForApproval(fcDisplayWrapStr, quarterStatusString, opp2, sysAdmin);
        Core_FC_ProductSchedule_Ctrl.submitQuarterForApproval(fcDisplayWrapStr, quarterStatusString, opp, sysAdmin);
        
        //Core_FC_ProductSchedule_Ctrl.submitQuarterForApproval(null, null, null, null); 

        /*string s= [select Id from OpportunityLineItem  where Opportunity.name= 'Test Opportunity1'].Id;
        string s1= [select Id from OpportunityLineItem  where Opportunity.name= 'Test Opportunity2'].Id;
        string s2= [select Id from OpportunityLineItem  where Opportunity.name= 'Test Opportunity3'].Id;
        
        Core_Opp_FC_Prod_Schedule__c fc =  [select id,Core_Opp_FC_isdeleted__c from Core_Opp_FC_Prod_Schedule__c where Core_Opp_Line_Item_RecordID__c = : s2 and Core_Opp_FC_isdeleted__c = false];
        fc.Core_Opp_FC_isdeleted__c = true;
        update fc;*/
        

        test.stopTest(); 
            
            Core_FC_ProductSchedule_Ctrl.submitQuarterForApproval(fcDisplayWrapStr, quarterStatusString, opp5, new user(id=UserInfo.getUserId(),email='abcd@email.com'));
            
        }catch(Exception e){
        system.assertNotEquals(null, e, 'Error');
        }
    }
    
    @isTest
    static void testOpty6QPSReportNew(){
        test.startTest();
        Opportunity opp1 = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test Opportunity1'];
        Opportunity opp = [select Id, Name,Core_Number_of_Quarters__c from Opportunity where Name =: 'Test Opportunity4'];
        
        Core_FC_ProductSchedule_Ctrl.FCWrapper fcWrap = Core_FC_ProductSchedule_Ctrl.initializeForecast(opp1.Id);
        String fcDisplayWrapStr = JSON.serialize(fcWrap.fcDisplayWrapList);
        String dummyFcDisplayWrapStr = JSON.serialize(fcWrap.dummyFcDisplayWrapList);
        String quarterStatusString = JSOn.serialize(fcWrap.quarterStatusSet);
        Core_FC_ProductSchedule_Ctrl.saveAll(fcDisplayWrapStr, dummyFcDisplayWrapStr,opp, 'edit');
        Core_FC_ProductSchedule_Ctrl.saveAll(fcDisplayWrapStr, dummyFcDisplayWrapStr,opp, 'addQuarter');
        Core_FC_ProductSchedule_Ctrl.open6QPSReport(opp.Id);
        //commented out as part of TWC3123-6013
        //Core_FC_ProductSchedule_Ctrl.checkFCQuarterDate(opp.Id);
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 01, 01));
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 02, 01));
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 03, 01));
        Core_FC_ProductSchedule_Ctrl.getQuarterEndDate(Date.newInstance(2024, 04, 01));
         //Core_FC_ProductSchedule_Ctrl.sendEmail(new List<String>{'abcd@email.com'}, new List<String>{'abcdf@email.com'}, opp, 'Test');
       //Core_FC_ProductSchedule_Ctrl.submitQuarterForApproval(fcDisplayWrapStr, quarterStatusString, opp, new user(id=UserInfo.getUserId(),email='abcd@email.com'));
        test.stopTest();        
    }
}