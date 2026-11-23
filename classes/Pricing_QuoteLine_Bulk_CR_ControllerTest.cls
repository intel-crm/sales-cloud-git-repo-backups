/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-31-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_QuoteLine_Bulk_CR_ControllerTest {
   @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Quote_Line_Bulk_CR_Controller_Test');
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
        //List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Name from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<SBQQ__QuoteLine__c> qliList = new List<SBQQ__QuoteLine__c>();
        System.runAs(adminUser){
            qliList = Pricing_QuoteLine_Bulk_CR_Controller.getQuoteLineDetails(quote.Id);
        }
        Boolean var = qliList.size() > 0;
        System.assertEquals(var, false);
        Test.stopTest();
    }
    
    static testMethod void testmanualInsertIIM(){
        Account acc =[Select id from Account Limit 1];
        Contact con = [Select id from Contact Limit 1];
        List<User> adminUser = Pricing_Test_Utility.createAdminUser();
        List<List<SBQQ__Quoteline__c>> qlList = new List<List<SBQQ__QuoteLine__c>>();
        system.runAs(adminUser[0]){
            Test.startTest();
                // Send Data to Mydeals 
                List<SBQQ__Quoteline__c> quoteLineList = new List<SBQQ__Quoteline__c>([SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, SBQQ__Quote__r.Name, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,Pricing_Error_Messages__c,
                                                               SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_SDM_Fast_Track__c,
                                                               SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,Pricing_Manager__r.Core_WWID__c,Pricing_Payable_Quantity__c,
                                                               SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c,Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,
                                                               Pricing_Group_Type_nm__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                               Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Name, 
                                                               SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Country__c,Pricing_Consumption_Region__c,
                                                               SBQQ__Quote__r.Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,Pricing_Competetor_Product__r.Name,SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c,Pricing_Consumption_Segment__c,
                                                               SBQQ__Product__r.Core_Family_Nm__c,SBQQ__Product__r.Core_Forecast_Product_Name__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name, SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__c,Pricing_Account_Division_Nm__c,Pricing_Program_Type_Nm__c,
                                                               Pricing_Performance_Metric_Nm__c,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Performance_Metric_Nm__c
                                                                FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c] );
            
                qlList.add(quoteLineList);
                Pricing_QuoteLine_Bulk_CR_Controller.manualInsertIIM(qlList);
            	System.assertEquals(qlList.size() >0, true);
            	Test.stopTest();
        		}
            }

    static testMethod void testinsertEthernetWriteInProd() {
        SBQQ__QuoteLine__C quoteLine = [SELECT Id, Pricing_Program_Type_Nm__c, SBQQ__Product__r.Id,Pricing_Other_Product_Nm__c,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Item_Id__c from SBQQ__QuoteLine__c LIMIT 1];
        test.startTest();
        Pricing_JSONString.Product prod = Pricing_QuoteLine_Bulk_CR_Controller.insertEthernetWriteInProd(quoteLine);
        System.assertEquals(true, prod != null);
        test.stopTest();
    }
}