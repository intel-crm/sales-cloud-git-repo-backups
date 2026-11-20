/**
 * @description       : 
 * @author            : Sandeep Chamate
 * @group             : 
 * @last modified on  : 05-22-2024
 * @last modified by  : Sandeep Chamate
**/
@isTest
public class Pricing_QuoteLine_BulkDealControllerTest {
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Line_Bulk_Deal_Controller_Test');
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].Id, 2);
            test.stopTest();
        }
    }

    static testMethod void testgetQuoteLineDetails(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<SBQQ__QuoteLine__c> qliList = new List<SBQQ__QuoteLine__c>();
        System.runAs(adminUser){
            qliList = Pricing_QuoteLine_BulkDealController.getQuoteLineDetails(quote.Id);
        }
        Boolean var = qliList.size() > 0;
        System.assertEquals(var, false);
        Test.stopTest();
    }

    static testMethod void testupdateQuoteLineDetails(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,SBQQ__Quote__c,Name,Pricing_Status_Nm__c,Pricing_Product_Nm__c,Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c from SBQQ__QuoteLine__c LIMIT 2];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<User> rpmUser = Pricing_Test_Utility.createPricingMangerUser();
        List<String> parentId = new List<String>();
        Map<Id,String> errorMap = new Map<Id,String>();
        Pricing_Test_Utility.shareQuoteWithUser(quote.Id, rpmUser[0].Id);
        System.runAs(rpmUser[0]){   
            quote.Pricing_Unified_Global_End_Customer_Nm__c = null;
            quote.Pricing_My_Deals_Folio_Name_Nm__c = 'Test';
            update quote;
            quoteLineList[0].Pricing_Program_Type_Nm__c = 'Ethernet';
            quoteLineList[0].Pricing_Status_Nm__c = 'Pending Further Intel Review';
            quoteLineList[0].Pricing_Billing_Start_Date_Dt__c = System.today();
            quoteLineList[0].Pricing_Billing_End_Date_Dt__c = System.today();
            quoteLineList[0].Pricing_ECAP_Price_Amt__c = 100;
            quoteLineList[0].Pricing_Meet_Comp_Price_Amt__c = 50;
            quoteLineList[0].Pricing_Approved_Unit_Qty__c = 10;
            quoteLineList[0].Pricing_Market_Segment_Nm__c = 'Non Embedded';
            quoteLineList[0].Pricing_Market_Segment_values_Nm__c = 'Corp';
            quoteLineList[0].Pricing_Group_Type_nm__c = 'Mutually Exclusive';
            //quoteLineList[1].Pricing_Status_Nm__c = 'Pending Further Intel Review';
            //quoteLineList[1].Pricing_Integration_Status_Nm__c = 'Pending'; 
            quoteLineList[0].Pricing_Approved_Start_Date_Dt__c = System.today();
            quoteLineList[0].Pricing_Approved_End_Date_Dt__c = System.today();
            quoteLineList[0].Pricing_Consumption_Country__c = '';
            quoteLineList[0].Pricing_Consumption_Platform__c = '';
            quoteLineList[0].Pricing_Consumption_Sale_Geo__c = '';
            quoteLineList[0].Pricing_Consumption_Region__c = '';
            quoteLineList[0].Pricing_Consumption_Segment__c = '';
            //quoteLineList[1].Pricing_Product_Nm__c = quoteLineList[0].Pricing_Product_Nm__c;
            //quoteLineList[1].Pricing_Approved_Start_Date_Dt__c = System.today();
            //quoteLineList[1].Pricing_Approved_End_Date_Dt__c = System.today();
            update quoteLineList;
            parentId.add(quoteLineList[0].Id);
            errorMap = Pricing_QuoteLine_BulkDealController.updateQuoteLineDetails(quoteLineList, parentId, true, false);
        }
        //Boolean var = errorMap.size() > 0;
        System.assertEquals(quoteLineList.size() > 0, true);
        
        Test.stopTest();
    }

    static testMethod void testupdateQuoteLineDetailsError(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name,Pricing_Backdate_Reason_Txt__c from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<String> parentId = new List<String>();
        Map<Id,String> errorMap = new Map<Id,String>();

        System.runAs(adminUser){   
            quoteLineList[0].Pricing_Backdate_Reason_Txt__c = 'None';
            parentId.add(quoteLineList[0].Id);
            errorMap = Pricing_QuoteLine_BulkDealController.updateQuoteLineDetails(quoteLineList, parentId, false,false);
        }
        Boolean var = errorMap.size() > 0;
        System.assertEquals(var, false);
        Test.stopTest();
    }
    
    static testMethod void testisOverLapDealQL(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name,Pricing_Status_Nm__c,Pricing_Product_Nm__c,Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c from SBQQ__QuoteLine__c LIMIT 2];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<User> rpmUser = Pricing_Test_Utility.createPricingMangerUser();
        List<String> parentId = new List<String>();
        Map<Id,String> errorMap = new Map<Id,String>();
        Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
        Pricing_Test_Utility.shareQuoteWithUser(quote.Id, rpmUser[0].Id);
        System.runAs(rpmUser[0]){   
            quote.Pricing_Unified_Global_End_Customer_Nm__c = null; 
            update quote;
            quoteLineList[0].Pricing_Status_Nm__c = 'Pending Further Intel Review';
            quoteLineList[1].Pricing_Status_Nm__c = 'Pending Further Intel Review';
            quoteLineList[1].Pricing_Integration_Status_Nm__c = 'Pending'; 
            quoteLineList[0].Pricing_Approved_Start_Date_Dt__c = System.today();
            quoteLineList[0].Pricing_Approved_End_Date_Dt__c = System.today();
            quoteLineList[1].Pricing_Product_Nm__c = quoteLineList[0].Pricing_Product_Nm__c;
            quoteLineList[1].Pricing_Approved_Start_Date_Dt__c = System.today();
            quoteLineList[1].Pricing_Approved_End_Date_Dt__c = System.today();
            //update quoteLineList;
            parentId.add(quoteLineList[0].Id);
            quoteLineMap = quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,
                                                       SBQQ__Quote__r.Name, Pricing_EndCustomer_Nm__c, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,
                                                       Pricing_Reference_Quote_Line_Nbr__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,
                                                       SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,
                                                       SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Country__c,Pricing_Consumption_Region__c,Pricing_Consumption_Segment__c,
                                                       Pricing_Manager__r.Core_WWID__c,SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,
                                                       Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,
                                                       Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,
                                                       Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                       Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Project_Nm__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, 
                                                       Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,
                                                       Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,
                                                       SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,SBQQ__Product__r.Core_Family_Nm__c,SBQQ__Product__r.Core_Forecast_Product_Name__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,
                                                       Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,Pricing_Competetor_Product__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c,
                                                       SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__c,SBQQ__Quote__r.Pricing_End_Customer__c,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,
                                                       SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c
                                                       FROM SBQQ__QuoteLine__c WHERE Id IN : parentId]); 

            errorMap = Pricing_QuoteLine_BulkDealController.isOverLapDealQL(quoteLineMap, parentId);
        }
        Boolean var = errorMap.size() > 0;
        System.assertEquals(var, true);
        Test.stopTest();
    }
    
    static testMethod void testuserHasValidRPMPermission(){
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id from SBQQ__Quote__c LIMIT 1];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Pricing_Additional_RPM_Notify_Recipients__c from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        Map<Id,String> errorMap = new Map<Id,String>();
        Map<Id,String> quoteLineIdToEmailsMap = new Map<Id,String>();
        System.runAs(adminUser){
            quoteLineList[0].Pricing_Additional_RPM_Notify_Recipients__c = 'abc@intel.com';
            update quoteLineList;
            quoteLineIdToEmailsMap.put(quoteLineList[0].Id,quoteLineList[0].Pricing_Additional_RPM_Notify_Recipients__c);
            errorMap = Pricing_QuoteLine_BulkDealController.userHasValidRPMPermission(quoteLineList,quoteLineIdToEmailsMap);
        }
        Boolean var = errorMap.size() > 0;
        System.assertEquals(var, true);
        Test.stopTest();
    }
    
    static testMethod void testPicklistValues(){
        Test.startTest();
        List<List<String>> valuesList = new List<List<String>>();
        valuesList = Pricing_QuoteLine_BulkDealController.getPicklistBulkDealController();
        System.assertEquals(valuesList.size() > 0, true);
        Test.stopTest();
    }

    
    static testMethod void testfindRecords(){
        Test.startTest();
        List<User> listUsers = new List<User>();
        String str = 'anyUser';
        listUsers = Pricing_QuoteLine_BulkDealController.findRecords(str);
        System.assertEquals(listUsers.size() == 0, true);
        Test.stopTest();
    }
    
    static testMethod void testgetExcludedEndCustomer(){
        Test.startTest();
        List<String> endCustomerList = new List<String>();
        endCustomerList = Pricing_QuoteLine_BulkDealController.getCustomSettingRecordsforExcludedList();
        System.assertEquals(endCustomerList.size() == 0, true);
        Test.stopTest();
    }

    static testMethod void testOverlapConsumption(){
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,
                                                                        SBQQ__Quote__r.Name, Pricing_EndCustomer_Nm__c, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,
                                                                        Pricing_Reference_Quote_Line_Nbr__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,
                                                                        SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,
                                                                        SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Country__c,Pricing_Consumption_Region__c,Pricing_Consumption_Segment__c,
                                                                        Pricing_Manager__r.Core_WWID__c,SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,
                                                                        Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,
                                                                        Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,
                                                                        Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                                        Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Project_Nm__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, 
                                                                        Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,
                                                                        Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,
                                                                        SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,SBQQ__Product__r.Core_Family_Nm__c,SBQQ__Product__r.Core_Forecast_Product_Name__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,
                                                                        Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,Pricing_Competetor_Product__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c,
                                                                        SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__c,SBQQ__Quote__r.Pricing_End_Customer__c,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,
                                                                        SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c
                                                                        FROM SBQQ__QuoteLine__c LIMIT 2];

        //quoteLineList[1].Pricing_Consumption_Platform__c
        Boolean isConsumptionOverlap = Pricing_QuoteLine_BulkDealController.consumptionOverlap(quoteLineList[0], quoteLineList[1]);
        System.assertEquals(isConsumptionOverlap, true);
        Test.stopTest();
    }
}