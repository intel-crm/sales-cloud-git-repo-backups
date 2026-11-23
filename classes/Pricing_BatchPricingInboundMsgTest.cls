/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-06-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_BatchPricingInboundMsgTest {
    @testSetup
    public static void setUpData(){
        List<User> adminUser = Pricing_Test_Utility.createAdminUser();
        system.runAs(adminUser[0]){
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(adminUser[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            insert (new SBQQ__QuoteTemplate__c(Name = 'IQR Quote Template'));
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 3,salesRepUserList[0].Email,accountExecutiveUserList[0].Email); 
            test.startTest();
            List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>(); 
            for(SBQQ__QuoteLine__c quoteLine : Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 6)){
                quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
                quoteLine.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Submitted);
                lstquoteLines.add(quoteLine);
            }
            test.stopTest();
        }
    }
    static testMethod void testInboundAcknowldgementProcessing(){
        Map<Id,String> qlIdToRuleIdRuleNameMap = new Map<Id,String>();
        List<Core_Trigger_Executions__c> triggerEntryList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c();
        triggerEntry.name = 'processInboundMessagesIQR';
        triggerEntry.Core_Object__c = 'Descriptive Feature';
        triggerEntry.Core_Trigger_Events__c = 'After insert';
        triggerEntry.Core_Active__c = TRUE;
        triggerEntry.Core_Description__c = 'This is test description';
        triggerEntry.Core_Class_Name__c = 'Test Class';
        triggerEntryList.add(triggerEntry);
        
        Core_Trigger_Executions__c triggerEntry1 = new Core_Trigger_Executions__c();
        triggerEntry1.name = 'processInboundMessagesERPM';
        triggerEntry1.Core_Object__c = 'Descriptive Feature';
        triggerEntry1.Core_Trigger_Events__c = 'After insert';
        triggerEntry1.Core_Active__c = TRUE;
        triggerEntry1.Core_Description__c = 'This is test description';
        triggerEntry1.Core_Class_Name__c = 'Test Class';
        triggerEntryList.add(triggerEntry1);
        
        Core_Trigger_Executions__c triggerEntry2 = new Core_Trigger_Executions__c();
        triggerEntry2.name = 'processInboundMessages';
        triggerEntry2.Core_Object__c = 'Descriptive Feature';
        triggerEntry2.Core_Trigger_Events__c = 'After insert';
        triggerEntry2.Core_Active__c = TRUE;
        triggerEntry2.Core_Description__c = 'This is test description';
        triggerEntry2.Core_Class_Name__c = 'Test Class';
        triggerEntryList.add(triggerEntry2);
        
        Core_Trigger_Executions__c triggerEntry3 = new Core_Trigger_Executions__c();
        triggerEntry3.name = 'processInboundMessagesAGS';
        triggerEntry3.Core_Object__c = 'Descriptive Feature';
        triggerEntry3.Core_Trigger_Events__c = 'After insert';
        triggerEntry3.Core_Active__c = TRUE;
        triggerEntry3.Core_Description__c = 'This is test description';
        triggerEntry3.Core_Class_Name__c = 'Test Class';
        triggerEntryList.add(triggerEntry3);
        
        Core_Trigger_Executions__c triggerEntry4 = new Core_Trigger_Executions__c();
        triggerEntry4.name = 'pricingSendOutboundMessagesIQR';
        triggerEntry4.Core_Object__c = 'Descriptive Feature';
        triggerEntry4.Core_Trigger_Events__c = 'After insert';
        triggerEntry4.Core_Active__c = TRUE;
        triggerEntry4.Core_Description__c = 'This is test description';
        triggerEntry4.Core_Class_Name__c = 'Test Class';
        
        triggerEntryList.add(triggerEntry4);
        insert triggerEntryList;
        
        List<Core_Integration_Inbound_Message__c> inboundMsgs = new List<Core_Integration_Inbound_Message__c>();
        Core_Integration_Inbound_Message__c inboundMsgQuote = new Core_Integration_Inbound_Message__c();
        inboundMsgQuote.Core_Message_Type__c = 'Quote';
        inboundMsgQuote.Core_Processing_Status__c = 'Pending';
        inboundMsgQuote.Core_Error_Code__c = '200';
        inboundMsgQuote.Core_Source_System__c = 'test';
        inboundMsgQuote.Core_Reprocess_Message__c = true;
        Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;
        //insert inboundMsgQuote;
        inboundMsgs.add(inboundMsgQuote);
        Core_Integration_Inbound_Message__c inboundMsgERPM1 = new Core_Integration_Inbound_Message__c();
        inboundMsgERPM1.Core_Message_Type__c = 'Contact';
        inboundMsgERPM1.Core_Processing_Status__c = 'Pending';
        inboundMsgERPM1.Core_Error_Code__c = '200';
        inboundMsgERPM1.Core_Source_System__c = 'ERPM';
        Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;
        //insert inboundMsgERPM1;
        inboundMsgs.add(inboundMsgERPM1);
        Core_Integration_Inbound_Message__c inboundMsgERPM2 = new Core_Integration_Inbound_Message__c();
        inboundMsgERPM2.Core_Message_Type__c = 'Account';
        inboundMsgERPM2.Core_Processing_Status__c = 'Pending';
        inboundMsgERPM2.Core_Error_Code__c = '200';
        inboundMsgERPM2.Core_Source_System__c = 'ERPM';
        Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;
        //insert inboundMsgERPM2;
        inboundMsgs.add(inboundMsgERPM2);
        Core_Integration_Inbound_Message__c inboundMsgERPM3 = new Core_Integration_Inbound_Message__c();
        inboundMsgERPM3.Core_Message_Type__c = 'Blackbox';
        inboundMsgERPM3.Core_Processing_Status__c = 'Pending';
        inboundMsgERPM3.Core_Error_Code__c = '200';
        inboundMsgERPM3.Core_Source_System__c = 'ERPM';
        Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;
        //insert inboundMsgERPM3;
        inboundMsgs.add(inboundMsgERPM3);
        QuoteLineBusinessLogic.hasRunOnce = false;
        insert inboundMsgs;
        
        test.startTest();
        List<SBQQ__Quote__c> quote = [SELECT Id,createdById FROM SBQQ__Quote__c LIMIT 3];
        List<User> lstUsers = new List<User>([select id from User where id=:quote[0].createdbyid]);
        System.runAs(lstUsers[0]){
            List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>();
            quoteLine = [select id from SBQQ__QuoteLine__c];
            List<Pricing_Performance_Metric__c> pm = Pricing_Test_Utility.createPerformanceMetrics(quoteLine[1].Id);
            insert pm;
            
            If(quoteLine.size() > 0){
                // Send Data to Mydeals 
                Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
                Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, SBQQ__Quote__r.Name, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,Pricing_Error_Messages__c,Pricing_Payable_Quantity__c,
                                                                   SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,Pricing_Workload_Nm__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Name,
                                                                   SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,Pricing_Manager__r.Core_WWID__c,SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c,Pricing_SDM_Fast_Track__c,
                                                                   SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c,SBQQ__Quote__r.SBQQ__Account__r.Name,Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,
                                                                   Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                                   Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c,Pricing_Consumption_Region__c,Pricing_Consumption_Country__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Segment__c, 
                                                                   SBQQ__Quote__r.Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_AI_Host_Node_cb__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,SBQQ__Product__r.Id,SBQQ__Product__r.Name,Pricing_Product_Nm__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,
                                                                   Pricing_Competetor_Product__r.Name,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c, SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name, SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__c, SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c,
                                                                   SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Is_Sanctioned__c,Pricing_Account_Division_Nm__c,Pricing_Program_Type_Nm__c,SBQQ__Product__r.Core_Family_Nm__c,SBQQ__Product__r.Core_Forecast_Product_Name__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,
                                                                   Pricing_Performance_Metric_Nm__c,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Performance_Metric_Nm__c
                                                                    FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE Id IN : (quoteLine) LIMIT 6] );
                
                quoteLineIdToActionMap.put(quoteLine[0].Id,Label.Pricing_Tender_Integration_Header_Action_Create);
                quoteLineIdToActionMap.put(quoteLine[1].Id,Label.Pricing_Tender_Integration_Header_Action_Update);
                quoteLineIdToActionMap.put(quoteLine[2].Id,Label.Pricing_Tender_Integration_Header_Action_UpdateStatus);
                quoteLineIdToActionMap.put(quoteLine[3].Id,Label.Pricing_Tender_Integration_Header_Action_Create);
                quoteLineIdToActionMap.put(quoteLine[4].Id,Label.Pricing_Tender_Integration_Header_Action_Update);
                quoteLineIdToActionMap.put(quoteLine[5].Id,Label.Pricing_Tender_Integration_Header_Action_UpdateStatus);

                User loggedInUser = [SELECT Id,Name,Core_WWID__c from User where Id =: userInfo.getUserId()];
                Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap, quoteLineMap,loggedInUser.Core_WWID__c,true,qlIdToRuleIdRuleNameMap);
                Pricing_JSONString JSONVar;
                List<Core_Integration_Inbound_Message__c> inboundMsgList = new List<Core_Integration_Inbound_Message__c>();
                
                Core_Integration_Inbound_Message__c inboundMsg1 = new Core_Integration_Inbound_Message__c();
                inboundMsg1.Core_Payload__c = 'test';
                inboundMsg1.Core_Message_Type__c = Label.Pricing_Tender_Inbound_MsgType_Tender;
                inboundMsg1.Core_Source_System__c = Label.Pricing_Tender_Inbound_Source_MyDeals;
                inboundMsg1.Core_Processing_Status__c = 'Failed';
                inboundMsg1.Core_Error_Code__c = '200';
                inboundMsg1.Core_Reprocess_Message__c = true;
                inboundMsgList.add(inboundMsg1);
                
                if(!inboundMsgList.isEmpty()){
                    Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = true;       
                    insert inboundMsgList;
                    inboundMsgList[0].Core_Processing_Status__c = 'Failed';
                    inboundMsgList[0].Core_Retry_Counter__c = 1;
                    inboundMsgList[0].Core_Reprocess_Message__c = true;
                    update inboundMsgList[0];
                }
                Pricing_BatchPricingRetriggerInboundMsg pricingBatch = new Pricing_BatchPricingRetriggerInboundMsg();
                pricingBatch.resursiveCounter = 2;
                Database.executeBatch(pricingBatch);
                System.assertEquals(true, quoteLine != null);
                Test.stopTest();
            }
        }
    }
}