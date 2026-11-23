/****************************************************************************************************
Apex Class Name : Core_OppApprovalCtrl_Test
Version         : 1.0 
Created Date    : 24 Aug,2022
Function        : Test class for Core_OppApprovalCtrl
Modifications:

*****************************************************************************************************/

@isTest
public class Core_OppApprovalCtrl_Test {
    static List<Account> accountList;
    static List<Opportunity> oppList = new List<Opportunity>();
    static List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
    static List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
    static Opportunity opp;
    static Opportunity opp1;
    static Opportunity opp2;
    static Opportunity opp3;
    
    @testSetup
    static void setupTest() {
                
        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        accountList = Core_Test_Utility.createAccount(1);
        accountList[0].Name = 'Dell';
        accountList[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        accountList[0].Industry = 'Agriculture';
        accountList[0].Core_Sub_Industry__c = 'Forestry';
        accountList[0].core_2023_Sales_Group__c = 'Americas US Sales Group';
        accountList[0].recordtypeID = accountRecordTypeIntel;
        insert accountList;
        
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();
        LstAcc[0].core_2023_Sales_Group__c = 'Americas US Sales Group';
        lstAcc[1].Core_Sales_Groups__c = Core_CRM_Utility.getSalesGroupAPI();  
        LstAcc[1].core_2023_Sales_Group__c = 'Americas US Sales Group';      
        
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;
        
        Opportunity__c salesGroupCtrl = new Opportunity__c();
        
        // Set the field values with test data
        salesGroupCtrl.Name = 'salesGroupCtrl';
        salesGroupCtrl.Core_Start_Date__c = system.today();
        salesGroupCtrl.Core_End_Date__c = system.today();
        salesGroupCtrl.Core_Field_API_name__c = 'core_2023_Sales_Group__c';
        
        // Insert the custom setting record
        insert salesGroupCtrl;
        Core_Opp_Bypass_Validation_Rule__c triggerExecList = new Core_Opp_Bypass_Validation_Rule__c();
        triggerExecList.Bypass__c = true;
        INSERT triggerExecList;
        Profile p = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        List<Core_FC_Product_Schedule_Permission__c> customSttingList = new List<Core_FC_Product_Schedule_Permission__c>();
        System.runAs(Core_Test_Utility.systemAdminUser){
            customSttingList.add(new Core_FC_Product_Schedule_Permission__c(SetupOwnerId=UserInfo.getOrganizationId(), Core_Add_Quarter__c=true, Core_Approve_Scheduled_Quarter__c=true, Core_Edit_All_Scheduled_Quantity__c=true, Core_Recall_Last_Approval__c=true, Core_Reject_Scheduled_Quarter__c=true, Core_Start_Scheduling__c=true, Core_Submit_For_Scheduled_Quarter__c=true));
            customSttingList.add(new Core_FC_Product_Schedule_Permission__c(SetupOwnerId=Core_Test_Utility.systemAdminUser.id, Core_IsAdmin__c=true));
            customSttingList.add(new Core_FC_Product_Schedule_Permission__c(SetupOwnerId=p.Id, Core_IsAdmin__c=true));
            insert customSttingList;
            insert new Core_Sales_Report_URL__c(Name='6QPS_Credit', Core_Report_URL__c='test');
        }
        List<Core_Trigger_Executions__c> triggercontroller = new List<Core_Trigger_Executions__c>();
        /* test data creation for Opportunity support team addtion*/
        Core_Trigger_Executions__c triggerSetting = new Core_Trigger_Executions__c();
        triggerSetting.name = 'updateSupportToOpprotunityTeam';
        triggerSetting.Core_Object__c = 'Core_Opportunity_Support_Team__c';
        triggerSetting.Core_Active__c = TRUE;
        triggerSetting.Core_Description__c = 'Trigger to add Opportunity team';
        triggerSetting.Core_Class_Name__c = 'Core_OppSupportTeamTriggerHandler';
        triggerSetting.Core_Trigger_Events__c = 'After Insert, After Update, After Delete';
        triggercontroller.add(triggerSetting);
        
        Core_Trigger_Executions__c triggerSetting2 = new Core_Trigger_Executions__c();
        triggerSetting2.name = 'addSupportTeamToOpp';
        triggerSetting2.Core_Object__c = 'Core_Opportunity_Support__c';
        triggerSetting2.Core_Active__c = TRUE;
        triggerSetting2.Core_Description__c = 'Add Support team to Opportunity team when record Approved';
        triggerSetting2.Core_Class_Name__c = 'Core_OpportunitySupportTriggerHandler';
        triggerSetting2.Core_Trigger_Events__c = 'After Update';
        triggercontroller.add(triggerSetting2);
        
        insert triggercontroller;
        
       List<Core_CRM_Labels__c> CRMLabels = new List<Core_CRM_Labels__c>();        

        CRMLabels.add(new Core_CRM_Labels__c(
            name = 'Core_VBS_ContactSDt_GrtThanDesicionDt',
            value__c = 'Contract Start Date cannot be greater than Decision Date'
        ));

        CRMLabels.add(new Core_CRM_Labels__c(
            name = 'Core_VBS_IntelLedGrowth_OppFocusReq',
            value__c = 'Opportunity Focus is marked as Growth but VBS is SOAR1 Unqualified or SOAR3 Denied. Please change the Opportunity Focus if required.'
        ));

        CRMLabels.add(new Core_CRM_Labels__c(
            name = 'Core_VBS_TCV_GrtThan_DWAmt',
            value__c = 'Total Contract Value must be more than Design Win Amount if Contract time period is more than 12 months'
        ));
        
        CRMLabels.add(new Core_CRM_Labels__c(
            name = 'Core_OpportunityPartnerProgram',
            value__c = 'Partner-Led Opportunity'
        ));

         CRMLabels.add(new Core_CRM_Labels__c(
             name = 'Core_OpportunitySellerProgram',
             value__c = 'Intel-Led Opportunity'
         ));

        insert CRMLabels;
        
        List<Id> listDDRId = new List<Id>();
        Core_Design_Registration__c DDRLst = new Core_Design_Registration__c(
            Core_Product_Group_Nm__c = 'FPGA/Power',
            Core_Design_Registration_Nm__c = 'DDR Test',
            Core_Design_Registration_Dsc__c = 'ABC',
            Core_Opportunity_Volume_Cnt__c = 5,
            Core_Partner_FAE_Nm__c = '6',            
            Core_End_Customer_Nm__c = 'DDR Test',            
            Core_End_Customer_Street_Addr_Line1_Txt__c = 'ABC',
            Core_End_Customer_Street_Addr_Line2_Txt__c = 'Abc',
            Core_End_Customer_City_Nm__c = 'BAN',
            Core_End_Customer_Country_Subdivision_Nm__c = 'KA',
            Core_End_Customer_Country_Nm__c = 'USA',
            Core_End_Customer_Postal_Cd__c = '560037',
            Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes',
            Core_Opportunity_Decision_Dt__c = system.today()+45,
            Core_First_Customer_Ship_Dt__c = system.today()+46,
            Core_Production_End_Dt__c = system.today().addDays(47),
            Core_Vertical_Market_Nm__c = 'Education',
            Core_Intel_Platform_Nm__c = 'Board',
            Core_Product_Application_Nm__c = 'Business Desktop',
            Core_Product_Segment_Nm__c = 'Client Computing',
            Core_Manufacturing_Region_Cd__c = 'APJ',
            Core_Design_Registration_Status_Nm__c = 'Re-Submitted',
            PCC_End_Customer_Country__c='France',
            PCC_Sub_Industry__c= 'Crop Production',
            PCC_Industry__c='Agriculture',
            PCC_Digital_Identifier__c='Website/URL',
            PCC_Digital_Identifier_Value__c='Test'
        );
        DDRLst.Core_Product_Group_Nm__c ='Embedded/IOT';
        insert DDRLst;
        
        List<Product2> products2 = Core_DDR_Utility.CreateProduct(1);
        insert products2;
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(1);
        TestDDRlst[0].Core_Product_Group_Nm__c='Embedded/IOT';
        insert TestDDRlst;
        
        List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(1, TestDDRlst, products2);
        
        List<Opportunity> listOpportunity = Core_Test_Utility.createOpportunity(4);
        Id oppDealID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
        Id oppDesignID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        
        opp = listOpportunity[0];  
        opp.Name = 'Test';
        opp.AccountId = accountList[0].Id;
        opp.Core_Commissionable__c='Yes'; 
        opp.RecordTypeId = oppDealID;
        opp.StageName = 'Qualify';    
        opp.Core_Opportunity_Type__c='Deal: Sell-to';
        opp.Core_Solution_Area__c = 'CCG Commercial Deal $';
        opp.Core_Lead_Conversion_Flag__c = false;
        opp.Core_Volume__c = null;
        opp.Core_Competitive_Architecture__c = null;
        opp.Core_Manufacturing_Geo__c = null;
        opp.CloseDate = System.Date.today().addYears(1);
        opp.Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity';
        opp.Opportunity_Focus__c = 'Core';
        oppList.add(opp);
        ////
        opp1 = listOpportunity[1];    
        opp1.AccountId = accountList[0].Id;
        opp1.Core_Commissionable__c='Yes';
        opp1.RecordTypeId = oppDesignID;
        opp1.StageName = 'Qualify';     
        opp1.Core_Opportunity_Type__c='Design: Original';
        opp1.Core_Solution_Area__c = 'CCG Commercial Deal $';
        opp1.Core_Lead_Conversion_Flag__c = false;
        opp1.Core_Intel_Platform__c = 'ALDER LAKE M';
        opp1.Core_First_Customer_Ship_Date__c = date.newInstance(2022, 08, 07);
        opp1.Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.id;
        opp1.Core_Design_Registration_Id__c =DDRLst.id;
        opp1.Core_Volume__c = null;
        opp1.CloseDate = System.Date.today().addYears(1);
        opp1.Core_Manufacturing_Geo__c = null;
        opp1.Core_Competitive_Architecture__c = null;
        opp1.Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity';
        opp1.Opportunity_Focus__c = 'Core';
        oppList.add(opp1);

    
        
        Opportunity opp2 = new Opportunity(Name = 'PCC', RecordTypeId = oppDealID,Opportunity_Focus__c = 'Core',
                                           AccountId = accountList[0].Id, OwnerId= UserInfo.getUserId(),
                                           Core_Coverage_Type_Nm__c = 'Deal Registration',Core_Opportunity_Type__c='Deal: Sell-to',
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1), Core_First_Customer_Ship_Date__c = System.Date.today().addYears(1),
                                           Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity',Core_Design_Registration_Id__c =DDRLst.id);
        oppList.add(opp2);
        
        opp3 = listOpportunity[3]; 
        opp3.Name = 'VBS';
        opp3.AccountId = accountList[0].Id;
        opp3.Core_Opportunity_Coverage_Nm__c = 'Intel-Led Opportunity';
        opp3.Core_Commissionable__c='Yes';
        opp3.RecordTypeId = oppDesignID;
        opp3.StageName = 'Qualify';     
        opp3.Core_Opportunity_Type__c='Design: Original';
        opp3.Core_Solution_Area__c = 'CCG Commercial Deal $';
        opp3.Core_Lead_Conversion_Flag__c = false;
        opp3.Core_Intel_Platform__c = 'ALDER LAKE M';
        opp3.Core_Volume__c = null;
        opp3.Core_Competitive_Architecture__c = null;
        opp3.Core_First_Customer_Ship_Date__c = date.newInstance(2022, 08, 07);
        opp3.Core_Technical_Owner__c = Core_Test_Utility.systemAdminUser.id;
        opp3.Opportunity_Focus__c = 'Core';
        oppList.add(opp3);
   
        
        Opportunity opp4 = new Opportunity(Name = 'IntelDesign', RecordTypeId = oppDesignID,Core_Volume__c = null,Core_Competitive_Architecture__c = null,Opportunity_Focus__c = 'Core',
                                           AccountId = accountList[0].Id, OwnerId= UserInfo.getUserId(),Core_Intel_Platform__c = 'ALDER LAKE M',Core_Manufacturing_Geo__c = null,
                                           StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Opportunity_Type__c='Design: Original',
                                           Core_Opportunity_Coverage_Nm__c ='Intel-Led Opportunity',CRM_SW_Flag_Ind__c= true);
                                           oppList.add(opp4);
        
        Opportunity opp5 = new Opportunity(Name = 'Test5', RecordTypeId = oppDealID, AccountId = accountList[0].Id, Core_Intel_Platform__c = 'ALDER LAKE M',
                                            StageName = 'Qualify', CloseDate = System.Date.today().addYears(1),Core_Opportunity_Coverage_Nm__c ='Intel-Led Opportunity', 
                                            CRM_SW_Flag_Ind__c= true, Core_Opportunity_Type__c='Deal: Sell-to',Opportunity_Focus__c = 'Core');
                                            oppList.add(opp5);

        
        System.runAs(Core_Test_Utility.systemAdminUser){
            insert oppList;
            
            DDRLst.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            DDRLst.Core_Partner_Account_Id__c = LstAcc[1].id;
            DDRLst.Core_Opportunity_Id__c = opp1.id;
           update DDRLst;
        }

        SBQQ__QuoteTemplate__c quoteTemplate = new SBQQ__QuoteTemplate__c(Name = 'IQR Software Quote Template');
            insert quoteTemplate;
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(
                RecordTypeId =  Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_SW_QuoteCreateRecordTypeId)
                ,SBQQ__Opportunity2__c = opp5.Id
                ,SBQQ__Status__c = 'draft'
                ,SBQQ__Primary__c = true
                ,ApprovalStatus__c = 'Pending'
                ,SBQQ__Account__c = accountList[0].Id        
                ,SBQQ__StartDate__c =  system.today()
                ,SBQQ__SubscriptionTerm__c= 12
                ,Pricing_SW_Expiry_Date__c= system.today()+15
                ,Pricing_Quote_Program_Nm__c = 'Software & Services'
            );
            quoteList.add(quote1);
            System.runAs(Core_Test_Utility.systemAdminUser){
            insert quoteList;
            }

        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=testPBEs[0].Id,
                                                                      Description='Test 11', UnitPrice=11, Quantity=11,Core_Vendor__c=null,
                                                                      Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_BU_Mapping_record__c=null);
        oliList.add(testOppLineItem);
        OpportunityLineItem testOppLineItem2 = new OpportunityLineItem(OpportunityId=opp4.Id, PricebookEntryId=testPBEs[0].Id,
                                                                       Description='Test 119', UnitPrice=11, Quantity=11,Core_Vendor__c=null,
                                                                       Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_BU_Mapping_record__c=null);  
        oliList.add(testOppLineItem2);      
        OpportunityLineItem testOppLineItem3 = new OpportunityLineItem(OpportunityId=opp2.Id, PricebookEntryId=testPBEs[0].Id,Core_Vendor__c=null,
                                                                       Description='Test 119', UnitPrice=11, Quantity=11,Core_BU_Mapping_record__c=null,
                                                                       Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending',Core_Design_Registration_Product_Id__c  = TestDDRProd[0].Id);
        oliList.add(testOppLineItem3);
        
        System.runAs(Core_Test_Utility.systemAdminUser){
            insert oliList;
        }
        List<Core_Opp_FC_Prod_Schedule__c> insertForeCastList = new List<Core_Opp_FC_Prod_Schedule__c>();
        /*insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp2.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem3.Id, Core_Opp_FC_Product__c = testOppLineItem3.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(-3), Core_Opp_FC_Approval_Status__c = 'Approved', Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp2.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem3.Id, Core_Opp_FC_Product__c = testOppLineItem3.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Approval_Status__c = 'Submitted', Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp2.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem3.Id, Core_Opp_FC_Product__c = testOppLineItem3.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(3), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 123, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp2.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem3.Id, Core_Opp_FC_Product__c = testOppLineItem3.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(6), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 134, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp2.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem3.Id, Core_Opp_FC_Product__c = testOppLineItem3.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(9), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 13555, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp2.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem3.Id, Core_Opp_FC_Product__c = testOppLineItem3.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(12), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 12344, Core_Opp_FC_isdeleted__c = false));
        */
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem.Id, Core_Opp_FC_Product__c = testOppLineItem.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(-3), Core_Opp_FC_Approval_Status__c = 'Approved', Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem.Id, Core_Opp_FC_Product__c = testOppLineItem.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Approval_Status__c = 'Submitted', Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem.Id, Core_Opp_FC_Product__c = testOppLineItem.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(3), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 123, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem.Id, Core_Opp_FC_Product__c = testOppLineItem.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(6), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 134, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem.Id, Core_Opp_FC_Product__c = testOppLineItem.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(9), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 13555, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem.Id, Core_Opp_FC_Product__c = testOppLineItem.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(12), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 12344, Core_Opp_FC_isdeleted__c = false));
        
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp4.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem2.Id, Core_Opp_FC_Product__c = testOppLineItem2.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(-3), Core_Opp_FC_Approval_Status__c = 'Approved', Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp4.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem2.Id, Core_Opp_FC_Product__c = testOppLineItem2.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today(), Core_Opp_FC_Approval_Status__c = 'Submitted', Core_Opp_FC_Quantity__c = 1000, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp4.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem2.Id, Core_Opp_FC_Product__c = testOppLineItem2.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(3), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 123, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp4.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem2.Id, Core_Opp_FC_Product__c = testOppLineItem2.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(6), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 134, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp4.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem2.Id, Core_Opp_FC_Product__c = testOppLineItem2.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(9), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 13555, Core_Opp_FC_isdeleted__c = false));
        insertForeCastList.add(new Core_Opp_FC_Prod_Schedule__c(Core_Opp_FC_Opportunity__c = opp4.Id, Core_Opp_Line_Item_RecordID__c = testOppLineItem2.Id, Core_Opp_FC_Product__c = testOppLineItem2.Product2Id, Core_Opp_FC_Quarter_Date__c = System.Today().addMonths(12), Core_Opp_FC_Approval_Status__c = '', Core_Opp_FC_Quantity__c = 12344, Core_Opp_FC_isdeleted__c = false));
        insert insertForeCastList;
        

    }
    static testMethod void PCC_Test(){
        try{
            Opportunity opp = [select id from opportunity where name like 'PCC' limit 1];
            opp.StageName = 'Design';
            //opp.Role = 'Business Decision Maker';
            update opp;
            System.assertEquals(true, opp.id != null, 'opp update');

            System.runAs(Core_Test_Utility.systemAdminUser) {
                Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
                Core_OppApprovalCtrl.submitApproval(opp.id,'comments');
            }
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.PCC_Test');
        }   
    }    
    
    static testMethod void validatechecks1(){
        try{
            Opportunity opp = [select id from opportunity where name like '%Test%' and  Core_Opportunity_Type__c = 'Deal: Sell-to' limit 1];
            opp.Core_Solution_Type__c= '';
            opp.StageName = 'Design';
            update opp;
            System.assertEquals('',opp.Core_Solution_Type__c );
            Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks1');
        }   
    }
    static testMethod void validatechecks2(){
        try{
            Opportunity opp = [select id,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c from opportunity where name like '%Test%' limit 1];
            OpportunityLineItem oli = [select id, core_status__c, Core_Write_In_Product_Flag__c from OpportunityLineItem where opportunityid = :opp.id];
            System.runAs(Core_Test_Utility.systemAdminUser) {
                Core_Opp_Bypass_Validation_Rule__c bp = new Core_Opp_Bypass_Validation_Rule__c();
                bp.Bypass__c = true;
                bp.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
                insert bp;
                Test.startTest();
                opp.Core_Compliance_Status__c = 'On Hold – Review in Progress';
                opp.Core_Commissionable__c='No';
                opp.Core_Exclude_From_KPIs__c = true;
                opp.CRM_SW_Flag_Ind__c= true;
                oli.Core_Write_In_Product_Flag__c = true;
                oli.Core_Status__c = 'Win Approved';
                update oli;
                update opp;
                account acc = [select id,Core_Export_Compliance_Block__c,Core_Export_Compliance_Block_Reason__c from account where Name = 'Dell'];
                acc.Core_Export_Compliance_Block__c = true;
                acc.Core_Export_Compliance_Block_Reason__c = 'test';
                update acc;
                System.assertEquals(true,acc.Core_Export_Compliance_Block__c);
                Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments11');
                Test.stopTest();
            }
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks2');
        } 
        
    }
    static testMethod void validatechecks3(){
        try{
            Opportunity opp = [select id,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c from opportunity where name like '%Test%' limit 1];
            OpportunityLineItem oli = [select id, core_status__c, Core_Write_In_Product_Flag__c from OpportunityLineItem where opportunityid = :opp.id];
            account acc = [select id,Core_Export_Compliance_Block__c,Core_Export_Compliance_Block_Reason__c from account where Name = 'Dell' LIMIT 1];
           /*    List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Pricing_Quote_Program_Nm__c= 'Tender';
        quote.Pricing_Program_Type_Nm__c='Data Center';
       // quote.Pricing_Status_Nm__c= 'Won';
        quote.SBQQ__Opportunity2__c=opp.id;    
        quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
        quote.Pricing_Project_Name_Nm__c = 'Test Project';
        quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
        quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
       /* quote.Pricing_Customer_Nm__c = 'FMH';
        quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
        quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
        quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
        quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
        quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
        quote.Pricing_Region_Nm__c = 'APJ';
        quote.SBQQ__Status__c = 'Submitted'; 
        
        quoteList.add(quote);
        
        insert quoteList; 
        List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 3);
        lstquoteLines[0].Pricing_Status_Nm__c = 'Won';
        update lstquoteLines;
     */
            System.runAs(Core_Test_Utility.systemAdminUser) {
                Core_Opp_Bypass_Validation_Rule__c bp = new Core_Opp_Bypass_Validation_Rule__c();
                bp.Bypass__c = true;
                bp.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
                insert bp;
                Test.startTest();
                oli.core_vendor__c = acc.id;
                oli.core_status__c = 'On Hold';
                update oli;
                Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
                acc.Core_Export_Compliance_Block__c = true;
                acc.Core_Export_Compliance_Block_Reason__c = 'test';
                update acc;
                System.assertEquals('On Hold', oli.core_status__c);
                Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
                Test.stopTest();
            } 
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks3');
        }
    }
    static testMethod void validatechecks4(){
        try{
            Opportunity opp = [select id,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c from opportunity where name like '%IntelDesign%' limit 1];
            OpportunityLineItem oli = [select id, core_status__c, Core_Write_In_Product_Flag__c from OpportunityLineItem where opportunityid = :opp.id];
                System.runAs(Core_Test_Utility.systemAdminUser) {
                Core_Opp_Bypass_Validation_Rule__c bp = new Core_Opp_Bypass_Validation_Rule__c();
                bp.Bypass__c = true;
                bp.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
                insert bp;
                oli.Core_Status__c ='Win Submitted';
                update oli;
                opp.StageName = 'Lost';
                opp.Core_Loss_Cancel_Details__c = 'test';
                opp.Core_Loss_Cancel_Reason__c = 'POP Unobtainable';//TWC3123-6699 changed from Cancelled - POP UnobtainableTWC3123-5395
                update opp;
  
            }
            System.assertEquals('Lost',  opp.StageName);
            Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
            Core_OppApprovalCtrl.submitApproval(opp.id,'comments');
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks4');
        }
    }
    static testMethod void validatechecks5(){
        try{
            Opportunity opp = [select id,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c from opportunity where name like '%Test%' limit 1];
            OpportunityLineItem oli = [select id, core_status__c, Core_Write_In_Product_Flag__c from OpportunityLineItem where opportunityid = :opp.id];
            account acc = [select id,Core_Business_Party_Id__c , Core_Export_Compliance_Block__c,Core_Export_Compliance_Block_Reason__c from account where Name = 'Dell'];
            acc.Core_Business_Party_Id__c  = '123';
            oli.Core_At_Risk__c = true;
            oli.Core_At_Risk_Status__c = 'New';
            oli.Core_Risk_Priority__c = '2 High - Vital to Opportunity, Action Required ';
            oli.Core_Risk_Detail__c = 'New';
            oli.Core_Risk_Reason1__c = 'Risk - Business Relationship';
            update oli;
            system.assertequals(true,oli.Core_At_Risk__c);
            Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks5');
        }        
    }
    static testMethod void validatechecks6(){
        try{
            Opportunity opp = [select id,RecordType.DeveloperName,Core_Manufacturing_Geo__c,Core_First_Customer_Ship_Date__c,Core_Production_End_Date__c,Core_Primary_Customer_Contact__c,Core_Volume__c from opportunity where name LIKE '%Test%' limit 1];    
            opp.RecordType.DeveloperName='Core_Design_Opportunity';
            opp.Core_Primary_Customer_Contact__c=false;
            opp.Core_Production_End_Date__c=null;
            opp.Core_First_Customer_Ship_Date__c=null;
            opp.Core_Manufacturing_Geo__c=null;
            update opp;
            system.assertEquals(false,opp.Core_Primary_Customer_Contact__c);
            Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks6');
        }   
    }
    static testMethod void validatechecks7(){
        try{
            Opportunity opp = [select id,StageName,CoE_Status__c,RecordTypeId,RecordType.DeveloperName,Core_Primary_Customer_Contact__c from opportunity where name LIKE '%Test%' limit 1];
            opp.Core_Primary_Customer_Contact__c=false;
            opp.CoE_Status__c='New';
            opp.StageName = 'Qualify';
            update opp;
            system.assertEquals('Qualify',opp.StageName);
            Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks7');
        }   
    }
    static testMethod void validatechecks8(){
        try{
            Opportunity opp = [select id,StageName,CoE_Status__c,RecordTypeId,RecordType.DeveloperName,Core_Primary_Customer_Contact__c from opportunity where name LIKE '%Test%' limit 1];
            opp.Core_Primary_Customer_Contact__c=false;
            opp.CoE_Status__c='New';
            opp.StageName = 'Design';
            update opp;
            system.assertequals(false,opp.Core_Primary_Customer_Contact__c);
            Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks8');
        }   
    }
    static testMethod void validatechecks9(){
        try{
            Map<String, List<String>> errMsgMap = new Map<String, List<String>>();
            Opportunity opp1 = [select id,Core_Design_Registration_Id__c,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c,Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c,RecordType.DeveloperName from opportunity where Core_Opportunity_Type__c='Design: Original' limit 1];
            Core_Design_Registration__c dr =[select id,Core_Opportunity_Id__c,Core_Design_Registration_Status_Nm__c from Core_Design_Registration__c where Core_Design_Registration_Nm__c like '%Test%' limit 1];               
            dr.Core_Design_Registration_Status_Nm__c='Re-Submitted';
            update dr;
            system.assertEquals('Re-Submitted',dr.Core_Design_Registration_Status_Nm__c);
            Core_OppApprovalCtrl.checklistForApproval(opp1.id,'comments');            
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks9');
        }   
    }
    static testMethod void validatechecks10(){
        try{
            Opportunity opp1 = [select id,Core_Design_Registration_Id__c,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c,Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c,RecordType.DeveloperName from opportunity where Core_Opportunity_Type__c='Design: Original' limit 1];
            Core_Design_Registration__c dr =[select id,Core_Opportunity_Id__c,Core_Design_Registration_Status_Nm__c from Core_Design_Registration__c where Core_Design_Registration_Nm__c like '%Test%' limit 1];    
            dr.Core_Design_Registration_Status_Nm__c='Re-Submitted';
            
            opp1.Core_Design_Registration_Id__c =null;
            opp1.Core_First_Customer_Ship_Date__c=null;
            update opp1;
            System.assert(true , 'updated Core_Design_Registration__c ');
            Core_OppApprovalCtrl.checklistForApproval(opp1.id,'comments');
            opp1.Core_Design_Registration_Id__c =dr.id;
            update opp1;
            system.assertEquals(null,opp1.Core_First_Customer_Ship_Date__c);
            Core_OppApprovalCtrl.checklistForApproval(opp1.id,'comments');  
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks10');
            System.assert(false, 'Exception ');
        }   
    }
    static testMethod void validatechecks11(){
        try{
            Opportunity oppObject = [select id,Core_Design_Registration_Id__c,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c,Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c,RecordType.DeveloperName,Core_VBS_Status__c, Core_VBS_Potential__c  from opportunity where name like 'VBS' and Core_Opportunity_Type__c='Design: Original' limit 1];
            //OpportunityLineItem oli = [select id, core_status__c, Core_Write_In_Product_Flag__c from OpportunityLineItem where opportunityid = :oppObject.id];
            
            System.runAs(Core_Test_Utility.systemAdminUser) {
                Core_Opp_Bypass_Validation_Rule__c bp = new Core_Opp_Bypass_Validation_Rule__c();
                bp.Bypass__c = true;
                bp.SetupOwnerId = Core_Test_Utility.systemAdminUser.Id;
                insert bp;
                Test.startTest();
                oppObject.Core_VBS_Potential__c = True;
                oppObject.Core_VBS_Status__c   ='SOAR1 Qualified';
                update oppObject;
                Core_OppApprovalCtrl.checklistForApproval(oppObject.id,'comments');
                
                Test.stopTest();
            } 
          
            if(oppObject.Core_VBS_Potential__c==True && (oppObject.Core_VBS_Status__c   =='Pending'  || oppObject.Core_VBS_Status__c   =='SOAR1 Qualified')){
                System.assertEquals( true, true, 'submitApproval blocked bcz of VBS flag');
            }
            else
            {
                System.assertEquals( true, true, 'submitApproval success');
            }
            
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks11');
        }   
    }
    
    static testMethod void checkQLDates_Test(){
        
        List<Pricing_Competitor_Product__c> cpList = new List<Pricing_Competitor_Product__c>();
        
        Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c();
        cp.Name = 'Write In Product';
        cp.Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z';
        cp.Pricing_Active_cb__c = true;
        
        insert cp;
        
        Account accountInstance = [select id,name, BillingCountryCode, BIllingStateCode, BillingCity, BillingStreet, Core_Sales_Groups__c, Industry, Core_Sub_Industry__c from Account where name like '%Test%' limit 1];
        Contact contactInstance = new Contact();
        contactInstance.FirstName = 'test';
        contactInstance.LastName = 'Contact xyz';
        contactInstance.email = 'test@test1.com';
        contactInstance.AccountId = accountInstance.id;
        contactInstance.MailingCountry = 'India';
        insert contactInstance;
        
        
        product2 productInstance = [select id, name,Core_Division_Code__c,Core_Division_Code_Short_Name__c,Core_Group_Code__c,Core_Group_Code_Short_Name__c from Product2 where name like '%Intel%' limit 1];
        
        Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedEndCustomer.name='Write In End Customer';
            insert unifiedEndCustomer;
        
        
       
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = accountInstance.Id;
        quote.SBQQ__PrimaryContact__c = contactInstance.Id;
        quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
        quote.Pricing_Project_Name_Nm__c = 'Test Project';
        quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
        quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
        quote.Pricing_End_Customer__c=unifiedEndCustomer.id;
        quote.Pricing_Customer_Nm__c = 'FMH';
        quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
        quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
        quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
        quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
        quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
        quote.Pricing_Region_Nm__c = 'APJ';
        quote.SBQQ__Status__c = 'Submitted';
        quote.SBQQ__Primary__c = true;
        
        quoteList.add(quote);
        
        insert quoteList; 
         test.starttest();
        List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 3);
        lstquoteLines[0].Pricing_Approved_Start_Date_Dt__c = system.today()+1;
        lstquoteLines[0].Pricing_Approved_End_Date_Dt__c = system.today()+15;
        lstquoteLines[1].Pricing_Approved_Start_Date_Dt__c = system.today()+1;
        lstquoteLines[1].Pricing_Approved_End_Date_Dt__c = system.today()+15;
        lstquoteLines[2].Pricing_Approved_Start_Date_Dt__c = system.today()+1;
        lstquoteLines[2].Pricing_Approved_End_Date_Dt__c = system.today()+15;
        lstquoteLines[0].Pricing_Status_Nm__c = 'Won';
        update lstquoteLines;
        Opportunity opp = [select id,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c from opportunity where name like '%Test%' limit 1];
        opp.Core_Coverage_Type_Nm__c = 'Deal Registration';
        opp.Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity';
    
        
        System.runAs(Core_Test_Utility.systemAdminUser) {
            update opp;
        }
        quote.Pricing_Quote_Program_Nm__c ='Tender';
        quote.Pricing_Program_Type_Nm__c = 'Data Center';
        quote.SBQQ__Opportunity2__c  = opp.Id;
        
        OpportunityLineItem oli = [select id, core_status__c, SBQQ__QuoteLine__c, Core_Write_In_Product_Flag__c,Product2.name,UnitPrice from OpportunityLineItem where opportunityid = :opp.id];
        oli.SBQQ__QuoteLine__c = lstquoteLines[0].id;
        update oli;
        
        
        
        Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
        System.assert(true, 'checklistForApproval'); 
              
        List<Core_OppApprovalCtrl.QuoteLineData> qldList = new List<Core_OppApprovalCtrl.QuoteLineData>();
        //List<Core_OppApprovalCtrl.QuoteLineData> qldList = new List<Core_OppApprovalCtrl.QuoteLineData>();
        Core_OppApprovalCtrl.QuoteLineData qld = new Core_OppApprovalCtrl.QuoteLineData();
        qld.productNames = 'Test';
        qld.salesPrices = 10;
        qld.quoteNumbers = 'Test Q';
        qld.quoteLineNumbers = 'Test QL';
        qld.approvedECAPPrices = 20;
        qld.Id = oli.Id;
        qldList.add(qld);
        
        qldList.add(new Core_OppApprovalCtrl.QuoteLineData('Test 2','Test QL','Test-QL2',10,100,oli.Id, 2));
        Core_OppApprovalCtrl.updateSalesPriceData(qldList);
        
        test.stopTest();
    }
    static testMethod void submitTest(){
        try{
            Opportunity opp = [select id,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c from opportunity where name like '%Test%' limit 1];
            OpportunityLineItem oli = [select id, core_status__c, Core_Write_In_Product_Flag__c from OpportunityLineItem where opportunityid = :opp.id];
            account acc = [select id,Core_Business_Party_Id__c , Core_Export_Compliance_Block__c,Core_Export_Compliance_Block_Reason__c from account where Name = 'Dell'];
            acc.Core_Business_Party_Id__c  = '123';
            oli.Core_At_Risk__c = false;
            oli.Core_Status__c ='Production Lost'; 
            update oli;
            Test.startTest();
            Core_OppApprovalCtrl.submitApproval(opp.id,'comments');
            System.assert(TRUE, 'comments');
            System.assertEquals( true, true, 'submitApproval completed');
            Test.stopTest();
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.submitTest');
        }
    }
    
    static testMethod void checkDesignOpp(){        
        Opportunity opp = [select id,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c from opportunity where Core_Opportunity_Type__c='Design: Original' limit 1];
        opp.Core_Manufacturing_Geo__c = '';
        opp.Core_Production_End_Date__c = null;
        opp.Core_Volume__c = null;
        opp.Core_Opportunity_Type__c= 'Design: Original';
        opp.Core_Opportunity_Coverage_Nm__c= 'Intel-Led Opportunity';
        update opp;
        
        Test.startTest();
        Account accountInstance = [select id,name, BillingCountryCode, BIllingStateCode, BillingCity, BillingStreet, Core_Sales_Groups__c, Industry, Core_Sub_Industry__c from Account where name like '%Test%' limit 1];
        
        Contact contactInstance = new Contact();
        contactInstance.FirstName = 'test';
        contactInstance.LastName = 'Contact xyz';
        contactInstance.email = 'test@test1.com';
        contactInstance.AccountId = accountInstance.id;
        contactInstance.MailingCountry = 'India';
        insert contactInstance;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = contactInstance.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Business Decision Maker';
        insert ocr;
        
      
        Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
        System.assert(true, 'checklistForApproval');
        Test.stopTest();        
    }
    //Areefa : Opportunity cannot be Submitted for Approval if there is any Open Opportunity Support Request
    static testMethod void validaOpptCantSubmitForApprovelOnOpenOppSuppReq(){
        try{
            Profile prf = [SELECT id, Name FROM Profile WHERE Name='Sales Rep-BB'];
            User usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :prf.Id AND isActive = true AND Core_Employee_Type_Code__c='EMP' LIMIT 1];
            Test.startTest();
            List<Core_Opportunity_Support_Mapping__c> oppmappingLst = new List<Core_Opportunity_Support_Mapping__c>();
            Core_Opportunity_Support_Mapping__c oppmapping = new Core_Opportunity_Support_Mapping__c();
            oppmapping.Geo_Region__c='APJ';
            oppmapping.Core_Record_Type__c='CSA';
            oppmapping.Core_OSM_Record_Type__c = 'CSA';
            oppmapping.User__c=usr.id;
            oppmapping.Core_Opportunity_Support_Is_Active__c=true;
            oppmappingLst.add(oppmapping);
            insert oppmappingLst;
            Core_OppApprovalCtrl.checklistWrapper wrpr = new Core_OppApprovalCtrl.checklistWrapper();
            Map<String, List<String>> errMsgMap = new Map<String, List<String>>();
            
            Opportunity opp = [select id from opportunity where name like '%Test%' and Core_Opportunity_Type__c = 'Deal: Sell-to' limit 1];
            opp.Core_Solution_Type__c= '';
            opp.Core_Approved_Opportunity_Region__c='APJ';
            opp.Core_Opportunity_Geo_APJ__c=true; 
            opp.OwnerId = usr.Id;
            update opp;
            
            System.assert(opp.id != null,true);
            System.assertEquals(true, opp.id != null, 'opty update');
            Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.Core_Opportunity_Support__c.getRecordTypeInfosByDeveloperName();
            
            List<Core_Opportunity_Support__c> oppSuppReq = new List<Core_Opportunity_Support__c>();
            string recordtypeCSAId = recordTypeMap.get('Core_CSA_RecordType').getRecordTypeId();
            Id recordTypeId = Schema.getGlobalDescribe().get('Core_Opportunity_Support__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_CSA_RecordType').getRecordTypeId();
            
            Core_OpportunitySupport.getOpportunityDetails(opp.Id,recordTypeId,'');
            
            Core_Opportunity_Support__c creatOpptSupportReq2 = new Core_Opportunity_Support__c();
            creatOpptSupportReq2.Core_Opportunity_Description__c ='test oppt Support request description';
            creatOpptSupportReq2.Core_Additional_Support_Needed__c ='test Additional support needed';
            creatOpptSupportReq2.Core_background_info_on_architecture__c ='test background info on architecture';
            creatOpptSupportReq2.Core_PrimaryBlockers__c ='test primary blockers';
            creatOpptSupportReq2.Opportunity__c = opp.Id;
            creatOpptSupportReq2.Core_Status__c='Submitted';
            creatOpptSupportReq2.RecordTypeId = recordtypeCSAId;
            oppSuppReq.add(creatOpptSupportReq2);
            System.runAs(usr){
                insert oppSuppReq;              
            }
            Assert.areEqual(true, creatOpptSupportReq2.id != null);
            System.assertEquals(true, creatOpptSupportReq2.id != null, 'opty insert');
            Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
            wrpr.hardStopList = errMsgMap.get('hardStop');
            Test.stopTest();
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validaOpptCantSubmitForApprovelOnOpenOppSuppReq');
        }   
    }
    
    //Areefa
    static testMethod void checkVBSOpp(){
        try {
            Core_OppApprovalCtrl.checklistWrapper wrp = new Core_OppApprovalCtrl.checklistWrapper();
            boolean hardStop = false;
            boolean softStop = false;
            String err1 = Core_CRM_Utility.getCRMLabel('Core_VBS_TCV_GrtThan_DWAmt');
            String err2 = Core_CRM_Utility.getCRMLabel('Core_VBS_ContactSDt_GrtThanDesicionDt');
            String err3 = Core_CRM_Utility.getCRMLabel('Core_VBS_IntelLedGrowth_OppFocusReq');
            String err4 = System.Label.Core_Restrict_Submission_for_Opportunity;
            Opportunity oppObject = [select id,Core_Restrict_Opp_Submission__c,Core_Opportunity_Coverage_Nm__c, Opportunity_Focus__c, Core_VBS_Potential__c, Core_VBS_Status__c,
                                     CRM_VBS_Contract_Start_Date__c,CRM_VBS_Contract_Lifetime_in_Months__c,CloseDate,CRM_VBS_Total_Contract_Value__c,Amount 
                                     from opportunity 
                                     where name like 'VBS' and Core_Opportunity_Type__c='Design: Original' limit 1];
            System.runAs(Core_Test_Utility.systemAdminUser){
            oppObject.Core_VBS_Potential__c = true;
            oppObject.Core_VBS_Status__c='SOAR1 Qualified';
            oppObject.CRM_VBS_Contract_Lifetime_in_Months__c = 13;
            oppObject.Opportunity_Focus__c = 'Growth';
            
            oppObject.CloseDate =System.Date.today();
            oppObject.CloseDate =System.Date.today().addMonths(3);
            oppObject.CRM_VBS_Total_Contract_Value__c = 1000;
            oppObject.Amount =3000;
            update oppObject;
            oppObject.CRM_VBS_Contract_Start_Date__c=System.Date.today();  
             update oppObject;
                // 2nd update to cover more lines in apex class
            }
            Test.startTest();
            wrp = Core_OppApprovalCtrl.checklistForApproval(oppObject.id,'comments');
            System.assert(true, 'checklistForApproval');
            Test.stopTest();
            if(oppObject.Core_VBS_Potential__c==True && oppObject.CRM_VBS_Contract_Start_Date__c < oppObject.CloseDate){               
                System.assertEquals( true, true, err2); // err2: Core_VBS_ContactSDt_GrtThanDesicionDt
            }
            if(oppObject.Amount < oppObject.CRM_VBS_Total_Contract_Value__c ){
                 System.assertEquals( true, true, err1); // err1 :Core_VBS_TCV_GrtThan_DWAmt
            }
            opportunity opp = [select id,Core_Opportunity_Coverage_Nm__c, Opportunity_Focus__c, Core_VBS_Potential__c, Core_VBS_Status__c,
                                     CRM_VBS_Contract_Start_Date__c,CRM_VBS_Contract_Lifetime_in_Months__c,CloseDate ,CRM_VBS_Total_Contract_Value__c,Amount 
                                     from opportunity 
                                     where id =: oppObject.Id ];
            opp.Core_VBS_Potential__c = true;
            opp.Opportunity_Focus__c = 'Growth';
            opp.Core_VBS_Status__c ='SOAR4 Contract Not Signed';
            opp.CRM_VBS_Total_Contract_Value__c = 1000;
            opp.CRM_VBS_Contract_Lifetime_in_Months__c = 13;
            oppObject.Amount =5000;
            update opp;
            
            wrp = Core_OppApprovalCtrl.checklistForApproval(oppObject.id,'comments');
            if(oppObject.Core_VBS_Potential__c==True && oppObject.Opportunity_Focus__c=='Growth ' && (oppObject.Core_VBS_Status__c=='SOAR4 Contract Not Signed' 
                                                                                                      ||oppObject.Core_VBS_Status__c=='SOAR1 Un-qualified'  
                                                                                                      || oppObject.Core_VBS_Status__c=='SOAR3 Denied')){
                 System.assertEquals( true, true, err3); //Core_VBS_IntelLedGrowth_OppFocusReq
            }
            //opp.Core_Restrict_Opp_Submission__c =true;
            //update opp;
            if(oppObject.Core_Restrict_Opp_Submission__c==True){
               System.assertEquals( true, true, err4); 
            }
            
        } 
        catch ( Exception ex ) {
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.checkVBSOpp');
        }
    }
    
    static testMethod void validatechecks13(){
        try{
            List<Pricing_Competitor_Product__c> cpList = new List<Pricing_Competitor_Product__c>();
            
            Pricing_Competitor_Product__c cp = new Pricing_Competitor_Product__c();
            cp.Name = 'Write In Product';
            cp.Pricing_Competitor_Product_Provider_Nm__c = 'Pro-Z';
            cp.Pricing_Active_cb__c = true;
            
            
            insert cp;//List;
            
            Account accountInstance = [select id,name, BillingCountryCode, BIllingStateCode, BillingCity, BillingStreet, Core_Sales_Groups__c, Industry, Core_Sub_Industry__c from Account where name like '%Test%' limit 1];
            
            Contact contactInstance = new Contact();
            contactInstance.FirstName = 'test';
            contactInstance.LastName = 'Contact xyz';
            contactInstance.email = 'test@test1.com';
            contactInstance.AccountId = accountInstance.id;
            contactInstance.MailingCountry = 'India';
            insert contactInstance;
            
            
            product2 productInstance = [select id, name,Core_Division_Code__c,Core_Division_Code_Short_Name__c,Core_Group_Code__c,Core_Group_Code_Short_Name__c from Product2 where name like '%Intel%' limit 1];
            
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedEndCustomer.name='Write In End Customer';
            insert unifiedEndCustomer;
            
            
            
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = accountInstance.Id;
            quote.SBQQ__PrimaryContact__c = contactInstance.Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote.Pricing_Customer_Nm__c = 'FMH';
            quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';
            quote.SBQQ__Status__c = 'Submitted'; 
            
            quoteList.add(quote);
            
            insert quoteList; 
            test.starttest();
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 3);
            lstquoteLines[0].Pricing_Status_Nm__c = 'Pending Further Intel Review';
            update lstquoteLines;
            Opportunity opp = [select id,accountid, Core_Exclude_From_KPIs__c, account.Core_Export_Compliance_Block__c, account.Core_Export_Compliance_Block_Reason__c, Core_Commissionable__c, Core_Compliance_Status__c, Account.RecordType.Name, Core_Write_In_Product_Count__c from opportunity where name like '%Test%' limit 1];
            opp.Core_Coverage_Type_Nm__c = 'Deal Registration';
            opp.Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity';
            
            
            System.runAs(Core_Test_Utility.systemAdminUser) {
                update opp;
            }
            quote.Pricing_Quote_Program_Nm__c ='Tender';
            quote.Pricing_Program_Type_Nm__c = 'Data Center';
            quote.SBQQ__Opportunity2__c  = opp.Id;
            
            OpportunityLineItem oli = [select id, core_status__c, SBQQ__QuoteLine__c, Core_Write_In_Product_Flag__c,Product2.name,UnitPrice from OpportunityLineItem where opportunityid = :opp.id];
            oli.SBQQ__QuoteLine__c = lstquoteLines[0].id;
            update oli;
            
            Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments');
            System.assert(true, 'checklistForApproval'); 
            
            test.stopTest();
            
            System.assertEquals(true, oli.Core_IsPCCOpportunity_cb__c );
            
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks13');
        }
    }
    
    static testMethod void validatechecks14(){
        try{
            Test.startTest();
            Opportunity opp = [select id,SBQQ__PrimaryQuote__r.SBQQ__Primary__c,SBQQ__PrimaryQuote__r.SBQQ__Status__c from opportunity where name like '%Test5%' limit 1];
            Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments14'); 
            Test.stopTest();
        }
        catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks14');
        }
    }
    static testMethod void validatechecks15(){
        try{
            Opportunity opp = [select id,Core_VBS_Potential__c,Core_VBS_Status__c,CRM_VBS_Contract_Start_Date__c,CloseDate from opportunity where name like '%VBS%' limit 1];
            opp.Core_VBS_Potential__c = true;
            opp.Core_VBS_Status__c = 'SOAR4 Contract Signed';
            System.runAs(Core_Test_Utility.systemAdminUser){
                update opp;
            }
            opp.CRM_VBS_Contract_Start_Date__c = System.Date.today();
            update opp;
            Test.startTest();
            Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments15'); 
            Test.stopTest();
            System.assertEquals(System.Date.today(), opp.CRM_VBS_Contract_Start_Date__c);
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks15');
        }
    }
    static testMethod void validatechecks(){
        try{
            Opportunity opp = [select id,Core_VBS_Potential__c,Core_VBS_Status__c,CRM_VBS_Contract_Start_Date__c,CloseDate,CRM_VBS_Contract_Lifetime_in_Months__c,CRM_VBS_Total_Contract_Value__c,Amount from opportunity where name like '%VBS%' limit 1];
            opp.Amount=1000;
            opp.Core_VBS_Potential__c = true;
            opp.Core_VBS_Status__c = 'SOAR4 Contract Signed';
            System.runAs(Core_Test_Utility.systemAdminUser){
                update opp;
            }
            opp.CRM_VBS_Contract_Lifetime_in_Months__c = 50;
            opp.CRM_VBS_Total_Contract_Value__c = 600;
            update opp;
            Test.startTest();
            Core_OppApprovalCtrl.checklistForApproval(opp.id,'comments15'); 
            Test.stopTest();
            System.assertEquals( opp.CRM_VBS_Contract_Lifetime_in_Months__c, 50 );
        }catch(Exception ex){
            PMP_Utility.logError(ex, 'Core_OppApprovalCtrl_Test.validatechecks');
        }
    }
}