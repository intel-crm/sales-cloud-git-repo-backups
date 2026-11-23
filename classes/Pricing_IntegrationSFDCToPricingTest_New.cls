/**
 * @description       : 
 * @author            : Bharath Chandrashekar
 * @group             : 
 * @last modified on  : 02-01-2024
 * @last modified by  : Bharath Chandrashekar
**/
@isTest
public class Pricing_IntegrationSFDCToPricingTest_New {
    
    @testSetup
    public static void setUpData(){
        
        List<User> adminUser = Pricing_Test_Utility.createAdminUser();
        system.runAs(adminUser[0]){
            List<Core_Trigger_Executions__c> triggerEntryList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c triggerEntry = new Core_Trigger_Executions__c();
            triggerEntry.name = 'processInboundMessagesIQR';
            triggerEntry.Core_Object__c = 'Descriptive Feature';
            triggerEntry.Core_Trigger_Events__c = 'After insert';
            triggerEntry.Core_Active__c = TRUE;
            triggerEntry.Core_Description__c = 'This is test description';
            triggerEntry.Core_Class_Name__c = 'Test Class';
            //insert triggerEntry;
            triggerEntryList.add(triggerEntry);
            
            Core_Trigger_Executions__c triggerEntry1 = new Core_Trigger_Executions__c();
            triggerEntry1.name = 'processInboundMessagesERPM';
            triggerEntry1.Core_Object__c = 'Descriptive Feature';
            triggerEntry1.Core_Trigger_Events__c = 'After insert';
            triggerEntry1.Core_Active__c = TRUE;
            triggerEntry1.Core_Description__c = 'This is test description';
            triggerEntry1.Core_Class_Name__c = 'Test Class';
            //insert triggerEntry1;
            triggerEntryList.add(triggerEntry1);
            
            Core_Trigger_Executions__c triggerEntry2 = new Core_Trigger_Executions__c();
            triggerEntry2.name = 'pricingSendOutboundMessagesIQR';
            triggerEntry2.Core_Object__c = 'Descriptive Feature';
            triggerEntry2.Core_Trigger_Events__c = 'After insert';
            triggerEntry2.Core_Active__c = TRUE;
            triggerEntry2.Core_Description__c = 'This is test description';
            triggerEntry2.Core_Class_Name__c = 'Test Class';
            //insert triggerEntry2;
            triggerEntryList.add(triggerEntry2);
            
            Core_Trigger_Executions__c triggerEntry3 = new Core_Trigger_Executions__c();
            triggerEntry3.name = 'processInboundMessagesAGS';
            triggerEntry3.Core_Object__c = 'Descriptive Feature';
            triggerEntry3.Core_Trigger_Events__c = 'After insert';
            triggerEntry3.Core_Active__c = TRUE;
            triggerEntry3.Core_Description__c = 'This is test description';
            triggerEntry3.Core_Class_Name__c = 'Test Class';
            //insert triggerEntry3;
            triggerEntryList.add(triggerEntry3);
            
            Core_Trigger_Executions__c triggerEntry4 = new Core_Trigger_Executions__c();
            triggerEntry4.name = 'processInboundMessages';
            triggerEntry4.Core_Object__c = 'Descriptive Feature';
            triggerEntry4.Core_Trigger_Events__c = 'After insert';
            triggerEntry4.Core_Active__c = TRUE;
            triggerEntry4.Core_Description__c = 'This is test description';
            triggerEntry4.Core_Class_Name__c = 'Test Class';
            //insert triggerEntry2;
            triggerEntryList.add(triggerEntry4);
            
            insert triggerEntryList;
            
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
            Pricing_Test_Utility.createTemplate(adminUser[0].id);
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            insert (new SBQQ__QuoteTemplate__c(Name = 'IQR Quote Template'));
            test.startTest();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            system.debug('Setup Time 000 111===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 3,salesRepUserList[0].Email,accountExecutiveUserList[0].Email); 
            system.debug('Setup Time 000===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
            
            system.debug('Setup Time 111===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
            List<SBQQ__QuoteLine__c> lstquoteLines = new List<SBQQ__QuoteLine__c>(); 
            for(SBQQ__QuoteLine__c quoteLine : Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 6)){
                quoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview;
                quoteLine.RecordTypeId = Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Submitted);
                lstquoteLines.add(quoteLine);
            }
            system.debug('Setup Time 222===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
            test.stopTest();           
            
        }
    }            
    
    static testMethod void testInboundAcknowldgementProcessing_0(){  
        try{    
            
            List<User> adminUser = Pricing_Test_Utility.createAdminUser();
            system.runAs(adminUser[0]){
                
                List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>();
                quoteLine = [select id from SBQQ__QuoteLine__c LIMIT 6];
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[1].id, 1));
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[2].id, 1));
                List<Pricing_Performance_Metric__c> pm = Pricing_Test_Utility.createPerformanceMetrics(quoteLine[1].Id);
                insert pm;
                system.debug('Test Method Time 111===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                If(quoteLine.size() > 0){
                    // Send Data to Mydeals 
                    Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
                    Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, SBQQ__Quote__r.Name, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,Pricing_Error_Messages__c,
                                                                   SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,
                                                                   SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,Pricing_Manager__r.Core_WWID__c,
                                                                   SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID__c,Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,
                                                                   Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                                   Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c, 
                                                                   SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,
                                                                   Pricing_Competetor_Product__r.Name,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,
                                                                                                       Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE Id IN : (quoteLine) LIMIT 6] );
                    
                    
                    newQuoteLineMap.put(quoteLine[0].Id,quoteLineMap.get(quoteLine[0].Id));
                    quoteLineIdToActionMap.put(quoteLine[0].Id,Label.Pricing_Tender_Integration_Header_Action_Create); 
                    
                    newQuoteLineMap.values()[0].Pricing_ECAP_Price_Amt__c = null;
                    
                    User loggedInUser = [SELECT Id,Name,Core_WWID__c from User where Id =: userInfo.getUserId()];                   
                    
                    system.debug('Test Method Time 222===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());                    
                    //test.startTest();
                    Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap, newQuoteLineMap, loggedInUser.Core_WWID__c,true);
                    test.startTest();
                    system.debug('Test Method Time 333===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    Pricing_JSONString JSONVar;
                    List<Core_Integration_Inbound_Message__c> inboundMsgList = new List<Core_Integration_Inbound_Message__c>();
                    List<Core_Integration_Outbound_Message__c> IOMList = [Select id,Core_Payload__c from Core_Integration_Outbound_Message__c where Core_MessageType__c= 'Tender'];
                    Integer i=0;
                    system.debug('IOMList size==>'+IOMList.size());
                    for(Core_Integration_Outbound_Message__c outBoundMsg : IOMList){
                        
                        JSONVar = (Pricing_JSONString)System.JSON.deserialize(outBoundMsg.Core_Payload__c, Pricing_JSONString.class);
                        Pricing_JSONString.parse(outBoundMsg.Core_Payload__c);
                        JSONVar.Header.source_system = 'MyDeals';
                        JSONVar.Header.target_system = 'Tender';
                        JSONVar.Header.action = Label.Pricing_Tender_Integration_Header_Action_CreateResponse;
                        JSONVar.RecordDetails.Quote.FolioID = '1234';
                        List<Pricing_JSONString.QuoteLine> quoteLineList = new List<Pricing_JSONString.QuoteLine>();
                        quoteLineList = JSONVar.RecordDetails.Quote.QuoteLine;
                        for(Pricing_JSONString.QuoteLine temp : quoteLineList){
                            //temp.DealRFQId = '1234';
                            //temp.DealRFQStatus = 'Requested';
                            Pricing_JSONString.ErrorMessages errorMessageRec = new Pricing_JSONString.ErrorMessages(); 
                            errorMessageRec.code = 'test';
                            errorMessageRec.Message = 'test2';
                            temp.ErrorMessages = new List<Pricing_JSONString.ErrorMessages>{errorMessageRec};
                                }
                        
                        Core_Integration_Inbound_Message__c inboundMsg1 = new Core_Integration_Inbound_Message__c();
                        inboundMsg1.Core_Payload__c = JSON.serialize(JSONVar);
                        inboundMsg1.Core_Message_Type__c = 'Tender';
                        inboundMsg1.Core_Source_System__c = 'MyDeals';
                        inboundMsg1.Core_Processing_Status__c = 'Pending';
                        inboundMsg1.Core_Error_Code__c = '200';
                        inboundMsgList.add(inboundMsg1);
                    }                  
                    
                    
                    system.debug('inboundMsgList size==>'+inboundMsgList.size());
                    system.debug('Test Method Time 444===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    if(!inboundMsgList.isEmpty()){
                        QuoteLineBusinessLogic.hasRunOnce = false;
                        Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;       
                        insert inboundMsgList;                                          
                    }
                    
                    system.debug('Test Method Time 555===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    
                    JSONVar = (Pricing_JSONString)System.JSON.deserialize(IOMList[0].Core_Payload__c, Pricing_JSONString.class);
                    JSONVar.Header.source_system = 'MyDeals';
                    JSONVar.Header.target_system = 'Tender';
                    JSONVar.Header.action = Label.Pricing_Tender_Integration_Header_Action_Update;
                    JSONVar.RecordDetails.Quote.Id = '';
                    JSONVar.RecordDetails.Quote.FolioID = '';
                    
                    
                    List<Pricing_JSONString.QuoteLine> quoteLineList10 = new List<Pricing_JSONString.QuoteLine>();
                    quoteLineList10 = JSONVar.RecordDetails.Quote.QuoteLine;
                    for(Pricing_JSONString.QuoteLine temp : quoteLineList10){
                        temp.Id = '';
                        temp.DealRFQId = '';
                        temp.DealRFQStatus = 'Offer';   
                    }
                    JSONVar.RecordDetails.Quote.QuoteLine = quoteLineList10;
                    inboundMsgList[0].Core_Payload__c = JSON.serialize(JSONVar);
                    inboundMsgList[0].Core_Processing_Status__c = 'Pending';
                    
                    JSONVar = (Pricing_JSONString)System.JSON.deserialize(IOMList[0].Core_Payload__c, Pricing_JSONString.class);
                    JSONVar.Header.source_system = 'MyDeals';
                    JSONVar.Header.target_system = 'Tender';
                    JSONVar.Header.action = Label.Pricing_Tender_Integration_Header_Action_UpdateStatus;
                    JSONVar.RecordDetails.Quote.Id = '';
                    JSONVar.RecordDetails.Quote.FolioID = '';
                    List<Pricing_JSONString.QuoteLine> quoteLineList2 = new List<Pricing_JSONString.QuoteLine>();
                    quoteLineList2 = JSONVar.RecordDetails.Quote.QuoteLine;
                    Pricing_IntegrationSFDCToPricingSystems integrationSystem5 = new Pricing_IntegrationSFDCToPricingSystems();
                    for(Pricing_JSONString.QuoteLine temp : quoteLineList2){
                        temp.Id = '';
                        temp.DealRFQId = '1234';
                        temp.DealRFQStatus = 'Offer';
                        Pricing_JSONString.ErrorMessages errorMessageRec = new Pricing_JSONString.ErrorMessages(); 
                        errorMessageRec.code = '435';
                        errorMessageRec.Message = 'test2';
                        temp.ErrorMessages = new List<Pricing_JSONString.ErrorMessages>{errorMessageRec};
                            integrationSystem5.updateErrorFieldOnQuoteLine(new SBQQ__QuoteLine__c(),temp);
                        
                    }
                    
                    JSONVar.RecordDetails.Quote.QuoteLine = quoteLineList2;
                    
                    List<Core_Integration_Inbound_Message__c> errorInboundList = new List<Core_Integration_Inbound_Message__c>();
                    Core_Integration_Inbound_Message__c errorInbound = new Core_Integration_Inbound_Message__c();
                    errorInbound.Core_Payload__c = JSON.serialize(JSONVar);
                    errorInbound.Core_Message_Type__c = 'Tender';
                    errorInbound.Core_Source_System__c = 'MyDeals';
                    errorInbound.Core_Processing_Status__c = 'Pending';
                    errorInbound.Core_Error_Code__c = '200';
                    errorInboundList.add(errorInbound);//insert errorInbound;
                    
                    Core_Integration_Inbound_Message__c errorInbound1 = new Core_Integration_Inbound_Message__c();
                    errorInbound1.Core_Payload__c = JSON.serialize(JSONVar);
                    errorInbound1.Core_Message_Type__c = 'Tender';
                    errorInbound1.Core_Source_System__c = 'MyDeals';
                    errorInbound1.Core_Processing_Status__c = 'Pending';
                    errorInbound1.Core_Error_Code__c = '700';
                    errorInboundList.add(errorInbound1);//insert errorInbound1;
                    insert errorInboundList;
                    system.debug('Test Method Time 666===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    List<Pricing_JSONString.QuoteLine> quoteLineList = new List<Pricing_JSONString.QuoteLine>();
                    quoteLineList = JSONVar.RecordDetails.Quote.QuoteLine;
                    for(Pricing_JSONString.QuoteLine temp : quoteLineList){
                        temp.DealRFQId = '4087';
                        temp.DealRFQStatus = 'Submitted';
                        
                        Pricing_JSONString.ErrorMessages errorMessageRec = new Pricing_JSONString.ErrorMessages(); 
                        errorMessageRec.code = 'test';
                        errorMessageRec.Message = 'test2';
                        temp.ErrorMessages = new List<Pricing_JSONString.ErrorMessages>{errorMessageRec};
                            }
                    
                    
                    system.debug('Test Method Time 777===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                }
            }
        }catch(DMLException e){
            
        }
        test.stopTest();
    } 
    static testMethod void testInboundAcknowldgementProcessing_1(){  
        try{    
            
            List<User> adminUser = Pricing_Test_Utility.createAdminUser();
            system.runAs(adminUser[0]){
                
                List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>();
                quoteLine = [select id from SBQQ__QuoteLine__c LIMIT 6];
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[1].id, 1));
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[2].id, 1));
                List<Pricing_Performance_Metric__c> pm = Pricing_Test_Utility.createPerformanceMetrics(quoteLine[1].Id);
                insert pm;
                system.debug('TestMethod_1 Time 111===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                If(quoteLine.size() > 0){
                    // Send Data to Mydeals 
                    Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
                    Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, SBQQ__Quote__r.Name, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,Pricing_Error_Messages__c,
                                                                   SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,
                                                                   SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,Pricing_Manager__r.Core_WWID__c,
                                                                   SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID__c,Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,
                                                                   Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                                   Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c, 
                                                                   SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,
                                                                   Pricing_Competetor_Product__r.Name,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,
                                                                                                       Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE Id IN : (quoteLine) LIMIT 6] );
                    
                    
                    newQuoteLineMap.put(quoteLine[1].Id, quoteLineMap.get(quoteLine[1].Id));
                    
                    quoteLineIdToActionMap.put(quoteLine[1].Id,Label.Pricing_Tender_Integration_Header_Action_Update);
                    User loggedInUser = [SELECT Id,Name,Core_WWID__c from User where Id =: userInfo.getUserId()];
                    system.debug('TestMethod_1 Time 222===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    
                    system.debug('TestMethod_1 Time 333===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    //test.startTest();
                    Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap, newQuoteLineMap,loggedInUser.Core_WWID__c,true);
                    system.debug('TestMethod_1 Time 444===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    test.startTest();
                    system.debug('TestMethod_1 Time 444 000===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    
                    Pricing_JSONString JSONVar;
                    List<Core_Integration_Inbound_Message__c> inboundMsgList = new List<Core_Integration_Inbound_Message__c>();
                    List<Core_Integration_Outbound_Message__c> IOMList = [Select id,Core_Payload__c from Core_Integration_Outbound_Message__c where Core_MessageType__c= 'Tender'];
                    Integer i=0;
                    system.debug('IOMList size==>'+IOMList.size());
                    for(Core_Integration_Outbound_Message__c outBoundMsg : IOMList){
                        JSONVar = (Pricing_JSONString)System.JSON.deserialize(outBoundMsg.Core_Payload__c, Pricing_JSONString.class);
                        JSONVar.Header.source_system = 'MyDeals';
                        JSONVar.Header.target_system = 'Tender';
                        JSONVar.Header.action = Label.Pricing_Tender_Integration_Header_Action_Create;
                        //JSONVar.RecordDetails.Quote.Id = null;
                        JSONVar.RecordDetails.Quote.FolioID = '1234';                     
                        
                        List<Pricing_JSONString.QuoteLine> quoteLineList = new List<Pricing_JSONString.QuoteLine>();
                        quoteLineList = JSONVar.RecordDetails.Quote.QuoteLine;
                        for(Pricing_JSONString.QuoteLine temp : quoteLineList){
                            //temp.Id = null;
                            temp.DealRFQId = '6843';
                            temp.DealRFQStatus = 'Submitted';
                            Pricing_JSONString.ErrorMessages errorMessageRec = new Pricing_JSONString.ErrorMessages(); 
                            errorMessageRec.code = 'test';
                            errorMessageRec.Message = 'test2';
                            temp.ErrorMessages = new List<Pricing_JSONString.ErrorMessages>{errorMessageRec};
                                }
                        JSONVar.RecordDetails.Quote.QuoteLine = quoteLineList;
                        Core_Integration_Inbound_Message__c inboundMsg2 = new Core_Integration_Inbound_Message__c();
                        inboundMsg2.Core_Payload__c = JSON.serialize(JSONVar);
                        inboundMsg2.Core_Message_Type__c = 'Tender';
                        inboundMsg2.Core_Source_System__c = 'MyDeals';
                        inboundMsg2.Core_Processing_Status__c = 'Pending';
                        inboundMsg2.Core_Error_Code__c = '200';
                        inboundMsgList.add(inboundMsg2);                        
                        
                    }
                    system.debug('inboundMsgList size==>'+inboundMsgList.size());
                    system.debug('TestMethod_1 Time 555===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    if(!inboundMsgList.isEmpty()){
                        QuoteLineBusinessLogic.hasRunOnce = false;
                        Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;       
                        insert inboundMsgList;                                         
                    }
                    
                    system.debug('TestMethod_1 Time 666===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    Core_Integration_Inbound_Message__c updateInboundMsg = inboundMsgList[0].clone(false, true, false, false); 
                    updateInboundMsg.Core_Processing_Status__c = 'Pending';
                    updateInboundMsg.Core_Error_Code__c = '200';
                    JSONVar = (Pricing_JSONString)System.JSON.deserialize(IOMList[0].Core_Payload__c, Pricing_JSONString.class);
                    JSONVar.Header.source_system = 'MyDeals';
                    JSONVar.Header.target_system = 'Tender';
                    JSONVar.Header.action = Label.Pricing_Tender_Integration_Header_Action_Update;
                    JSONVar.RecordDetails.Quote.Id = '';
                    JSONVar.RecordDetails.Quote.FolioID = '';
                    
                    
                    List<Pricing_JSONString.QuoteLine> quoteLineList10 = new List<Pricing_JSONString.QuoteLine>();
                    quoteLineList10 = JSONVar.RecordDetails.Quote.QuoteLine;
                    for(Pricing_JSONString.QuoteLine temp : quoteLineList10){
                        temp.Id = '';
                        temp.DealRFQId = '';
                        temp.DealRFQStatus = 'Offer';   
                    }
                    JSONVar.RecordDetails.Quote.QuoteLine = quoteLineList10;
                    inboundMsgList[0].Core_Payload__c = JSON.serialize(JSONVar);
                    inboundMsgList[0].Core_Processing_Status__c = 'Pending';
                    
                    JSONVar = (Pricing_JSONString)System.JSON.deserialize(IOMList[0].Core_Payload__c, Pricing_JSONString.class);
                    JSONVar.Header.source_system = 'MyDeals';
                    JSONVar.Header.target_system = 'Tender';
                    JSONVar.Header.action = Label.Pricing_Tender_Integration_Header_Action_UpdateStatus;
                    JSONVar.RecordDetails.Quote.Id = '';
                    JSONVar.RecordDetails.Quote.FolioID = '';
                    List<Pricing_JSONString.QuoteLine> quoteLineList2 = new List<Pricing_JSONString.QuoteLine>();
                    quoteLineList2 = JSONVar.RecordDetails.Quote.QuoteLine;
                    Pricing_IntegrationSFDCToPricingSystems integrationSystem5 = new Pricing_IntegrationSFDCToPricingSystems();
                    for(Pricing_JSONString.QuoteLine temp : quoteLineList2){
                        temp.Id = '';
                        temp.DealRFQId = '1234';
                        temp.DealRFQStatus = 'Offer';
                        Pricing_JSONString.ErrorMessages errorMessageRec = new Pricing_JSONString.ErrorMessages(); 
                        errorMessageRec.code = '435';
                        errorMessageRec.Message = 'test2';
                        temp.ErrorMessages = new List<Pricing_JSONString.ErrorMessages>{errorMessageRec};
                            integrationSystem5.updateErrorFieldOnQuoteLine(new SBQQ__QuoteLine__c(),temp);
                        
                    }
                    
                    JSONVar.RecordDetails.Quote.QuoteLine = quoteLineList2;
                    inboundMsgList[0].Core_Payload__c = JSON.serialize(JSONVar); 
                    inboundMsgList[0].Core_Processing_Status__c = 'Failed';
                    inboundMsgList[0].Core_Error_Code__c = '201';
                    inboundMsgList[0].Core_Retry_Counter__c  = 9;
                    //update inboundMsgList[0];  
                    //update inboundMsgList[1];
                    system.debug('TestMethod_1 Time 777===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    update inboundMsgList;
                    system.debug('TestMethod_1 Time 888===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    
                    List<Core_Integration_Inbound_Message__c> errorInboundList = new List<Core_Integration_Inbound_Message__c>();
                    Core_Integration_Inbound_Message__c errorInbound = new Core_Integration_Inbound_Message__c();
                    errorInbound.Core_Payload__c = JSON.serialize(JSONVar);
                    errorInbound.Core_Message_Type__c = 'Tender';
                    errorInbound.Core_Source_System__c = 'MyDeals';
                    errorInbound.Core_Processing_Status__c = 'Pending';
                    errorInbound.Core_Error_Code__c = '200';
                    errorInboundList.add(errorInbound);//insert errorInbound;
                    
                    Core_Integration_Inbound_Message__c errorInbound1 = new Core_Integration_Inbound_Message__c();
                    errorInbound1.Core_Payload__c = JSON.serialize(JSONVar);
                    errorInbound1.Core_Message_Type__c = 'Tender';
                    errorInbound1.Core_Source_System__c = 'MyDeals';
                    errorInbound1.Core_Processing_Status__c = 'Pending';
                    errorInbound1.Core_Error_Code__c = '700';
                    errorInboundList.add(errorInbound1);//insert errorInbound1;
                    insert errorInboundList;
                    system.debug('TestMethod_1 Time 999===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    List<Pricing_JSONString.QuoteLine> quoteLineList = new List<Pricing_JSONString.QuoteLine>();
                    quoteLineList = JSONVar.RecordDetails.Quote.QuoteLine;
                    for(Pricing_JSONString.QuoteLine temp : quoteLineList){
                        temp.DealRFQId = '4087';
                        temp.DealRFQStatus = 'Submitted';
                        
                        Pricing_JSONString.ErrorMessages errorMessageRec = new Pricing_JSONString.ErrorMessages(); 
                        errorMessageRec.code = 'test';
                        errorMessageRec.Message = 'test2';
                        temp.ErrorMessages = new List<Pricing_JSONString.ErrorMessages>{errorMessageRec};
                            }
                    
                    JSONVar.RecordDetails.Quote.QuoteLine = quoteLineList;
                    updateInboundMsg.Core_Payload__c = JSON.serialize(JSONVar);
                    updateInboundMsg.Core_Message_Type__c = 'Tender';
                    updateInboundMsg.Core_Source_System__c = 'MyDeals';
                    updateInboundMsg.Core_Processing_Status__c = 'Pending';
                    updateInboundMsg.Core_Error_Code__c = '200';
                    
                    Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;
                    system.debug('TestMethod_1 Time 101010===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    insert updateInboundMsg;
                    system.debug('TestMethod_1 Time 111111===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                }
            }
        }catch(DMLException e){
            
        }
        test.stopTest();
    }
    static testMethod void testInboundAcknowldgementProcessing_2(){  
        try{    
            
            List<User> adminUser = Pricing_Test_Utility.createAdminUser();
            system.runAs(adminUser[0]){
                
                List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>();
                quoteLine = [select id from SBQQ__QuoteLine__c LIMIT 6];
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[1].id, 1));
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[2].id, 1));
                List<Pricing_Performance_Metric__c> pm = Pricing_Test_Utility.createPerformanceMetrics(quoteLine[1].Id);
                insert pm;
                system.debug('TestMethod_2 Time 111===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                If(quoteLine.size() > 0){
                    // Send Data to Mydeals 
                    Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
                    Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, SBQQ__Quote__r.Name, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,Pricing_Error_Messages__c,
                                                                   SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,
                                                                   SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,Pricing_Manager__r.Core_WWID__c,
                                                                   SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID__c,Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,
                                                                   Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                                   Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c, 
                                                                   SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,
                                                                   Pricing_Competetor_Product__r.Name,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,
                                                                                                       Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE Id IN : (quoteLine) LIMIT 6] );
                    
                    
                    newQuoteLineMap.put(quoteLine[2].Id, quoteLineMap.get(quoteLine[2].Id));
                    quoteLineIdToActionMap.put(quoteLine[2].Id,Label.Pricing_Tender_Integration_Header_Action_UpdateStatus);
                    newQuoteLineMap.values()[0].Pricing_Deal_RFQ_Id__c='1234';
                    newQuoteLineMap.values()[0].Pricing_Reference_Quote_Line_Nbr__c = quoteLine[3].Id;
                    newQuoteLineMap.values()[0].Pricing_Previous_Inbound_Msg_Number__c = 'IIM-29826617';
                    User loggedInUser = [SELECT Id,Name,Core_WWID__c from User where Id =: userInfo.getUserId()];
                    system.debug('TestMethod_2 Time 222===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    
                    Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap, newQuoteLineMap,loggedInUser.Core_WWID__c,true);
                    system.debug('TestMethod_2 Time 333===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    test.startTest();  
                    system.debug('TestMethod_2 Time 444===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    Pricing_JSONString JSONVar;
                    List<Core_Integration_Inbound_Message__c> inboundMsgList = new List<Core_Integration_Inbound_Message__c>();
                    List<Core_Integration_Outbound_Message__c> IOMList = [Select id,Core_Payload__c from Core_Integration_Outbound_Message__c where Core_MessageType__c= 'Tender'];
                    Integer i=0;
                    system.debug('IOMList size==>'+IOMList.size());
                    for(Core_Integration_Outbound_Message__c outBoundMsg : IOMList){
                        
                        JSONVar = (Pricing_JSONString)System.JSON.deserialize(outBoundMsg.Core_Payload__c, Pricing_JSONString.class);
                        JSONVar.Header.source_system = 'MyDeals';
                        JSONVar.Header.target_system = 'Tender';
                        JSONVar.Header.action = Label.Pricing_Tender_Integration_Header_Action_UpdateStatus;
                        List<Pricing_JSONString.QuoteLine> quoteLineList = new List<Pricing_JSONString.QuoteLine>();
                        quoteLineList = JSONVar.RecordDetails.Quote.QuoteLine;
                        for(Pricing_JSONString.QuoteLine temp : quoteLineList){
                            //temp.id = '';
                            temp.DealRFQId = '1234';
                            temp.DealRFQStatus = 'Requested';
                            Pricing_JSONString.ErrorMessages errorMessageRec = new Pricing_JSONString.ErrorMessages(); 
                            errorMessageRec.code = '1234';
                            errorMessageRec.Message = 'test2';
                            temp.ErrorMessages = new List<Pricing_JSONString.ErrorMessages>{errorMessageRec};
                                }
                        JSONVar.RecordDetails.Quote.QuoteLine = quoteLineList;
                        Core_Integration_Inbound_Message__c inboundMsg3 = new Core_Integration_Inbound_Message__c();
                        inboundMsg3.Core_Payload__c = JSON.serialize(JSONVar);
                        inboundMsg3.Core_Message_Type__c = 'Tender';
                        inboundMsg3.Core_Source_System__c = 'MyDeals';
                        inboundMsg3.Core_Processing_Status__c = 'Pending';
                        inboundMsg3.Core_Error_Code__c = '200';
                        inboundMsgList.add(inboundMsg3);
                        
                    }
                    system.debug('inboundMsgList size==>'+inboundMsgList.size());
                    system.debug('TestMethod_2 Time 555===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    if(!inboundMsgList.isEmpty()){
                        QuoteLineBusinessLogic.hasRunOnce = false;
                        Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;       
                        insert inboundMsgList;
                        system.debug('TestMethod_2 Time 666===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    }             
                    
                }
            }
        }catch(DMLException e){
            
        }
        test.stopTest();
    }	
    
    static testMethod void testInboundAcknowldgementProcessing_3(){  
        try{  
            
            List<User> adminUser = Pricing_Test_Utility.createAdminUser();
            system.runAs(adminUser[0]){
                
                List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>();
                quoteLine = [select id from SBQQ__QuoteLine__c LIMIT 6];
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[1].id, 1));
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[2].id, 1));
                List<Pricing_Performance_Metric__c> pm = Pricing_Test_Utility.createPerformanceMetrics(quoteLine[1].Id);
                insert pm;
                system.debug('TestMethod_3 Time 111===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                If(quoteLine.size() > 0){
                    // Send Data to Mydeals 
                    Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
                    Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, SBQQ__Quote__r.Name, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,Pricing_Error_Messages__c,
                                                                   SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,
                                                                   SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,Pricing_Manager__r.Core_WWID__c,
                                                                   SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID__c,Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,
                                                                   Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                                   Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c, 
                                                                   SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,
                                                                   Pricing_Competetor_Product__r.Name,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,
                                                                                                       Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE Id IN : (quoteLine) LIMIT 6] );
                    
                    
                    newQuoteLineMap.put(quoteLine[3].Id, quoteLineMap.get(quoteLine[3].Id));
                    quoteLineIdToActionMap.put(quoteLine[3].Id,Label.Pricing_Tender_Integration_Header_Action_Create);
                    newQuoteLineMap.values()[0].Pricing_Status_Nm__c = 'Won';               
                    User loggedInUser = [SELECT Id,Name,Core_WWID__c from User where Id =: userInfo.getUserId()];
                    system.debug('TestMethod_3 Time 222===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap, quoteLineMap,loggedInUser.Core_WWID__c,true);
                    system.debug('TestMethod_3 Time 333===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    test.startTest();
                    system.debug('TestMethod_3 Time 444===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    Pricing_JSONString JSONVar;
                    List<Core_Integration_Inbound_Message__c> inboundMsgList = new List<Core_Integration_Inbound_Message__c>();
                    List<Core_Integration_Outbound_Message__c> IOMList = [Select id,Core_Payload__c from Core_Integration_Outbound_Message__c where Core_MessageType__c= 'Tender'];
                    Integer i=0;
                    system.debug('IOMList size==>'+IOMList.size());
                    for(Core_Integration_Outbound_Message__c outBoundMsg : IOMList){                        
                        JSONVar = (Pricing_JSONString)System.JSON.deserialize(outBoundMsg.Core_Payload__c, Pricing_JSONString.class);
                        Pricing_JSONString.parse(outBoundMsg.Core_Payload__c);
                        JSONVar.Header.source_system = 'MyDeals';
                        JSONVar.Header.target_system = 'Tender';
                        JSONVar.Header.action = Label.Pricing_Tender_Integration_Header_Action_CreateResponse;
                        JSONVar.RecordDetails.Quote.FolioID = null;
                        JSONVar.RecordDetails.Quote.id = null;
                        List<Pricing_JSONString.QuoteLine> quoteLineList = new List<Pricing_JSONString.QuoteLine>();
                        quoteLineList = JSONVar.RecordDetails.Quote.QuoteLine;
                        for(Pricing_JSONString.QuoteLine temp : quoteLineList){
                            //temp.DealRFQId = '3097';
                            temp.id = null;
                            temp.DealRFQStatus = 'offer';
                            Pricing_JSONString.ErrorMessages errorMessageRec = new Pricing_JSONString.ErrorMessages(); 
                            errorMessageRec.code = 'test';
                            errorMessageRec.Message = 'test2';
                            temp.ErrorMessages = new List<Pricing_JSONString.ErrorMessages>{errorMessageRec};
                                }
                        JSONVar.RecordDetails.Quote.QuoteLine = quoteLineList;
                        
                        Core_Integration_Inbound_Message__c inboundMsg1 = new Core_Integration_Inbound_Message__c();
                        inboundMsg1.Core_Payload__c = JSON.serialize(JSONVar);
                        inboundMsg1.Core_Message_Type__c = 'Tender';
                        inboundMsg1.Core_Source_System__c = 'MyDeals';
                        inboundMsg1.Core_Processing_Status__c = 'Pending';
                        inboundMsg1.Core_Error_Code__c = '200';
                        inboundMsgList.add(inboundMsg1);
                        
                    }
                    system.debug('inboundMsgList size==>'+inboundMsgList.size());
                    system.debug('TestMethod_3 Time 555===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    if(!inboundMsgList.isEmpty()){
                        QuoteLineBusinessLogic.hasRunOnce = false;
                        Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;       
                        insert inboundMsgList;
                        system.debug('TestMethod_3 Time 666===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    }
                }
            }
        }catch(DMLException e){
            
        }
        test.stopTest();
    }
    static testMethod void testInboundAcknowldgementProcessing_4(){  
        try{  
            
            List<User> adminUser = Pricing_Test_Utility.createAdminUser();
            system.runAs(adminUser[0]){
                
                List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>();
                quoteLine = [select id from SBQQ__QuoteLine__c LIMIT 6];
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[1].id, 1));
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[2].id, 1));
                List<Pricing_Performance_Metric__c> pm = Pricing_Test_Utility.createPerformanceMetrics(quoteLine[1].Id);
                insert pm;
                system.debug('TestMethod_4 Time 111===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                If(quoteLine.size() > 0){
                    // Send Data to Mydeals 
                    Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
                    Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, SBQQ__Quote__r.Name, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,Pricing_Error_Messages__c,
                                                                   SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,
                                                                   SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,Pricing_Manager__r.Core_WWID__c,
                                                                   SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID__c,Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,
                                                                   Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                                   Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c, 
                                                                   SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,
                                                                   Pricing_Competetor_Product__r.Name,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,
                                                                                                       Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE Id IN : (quoteLine) LIMIT 6] );
                    
                    
                    newQuoteLineMap.put(quoteLine[4].Id, quoteLineMap.get(quoteLine[4].Id));
                    quoteLineIdToActionMap.put(quoteLine[4].Id,Label.Pricing_Tender_Integration_Header_Action_Update);
                    
                    
                    User loggedInUser = [SELECT Id,Name,Core_WWID__c from User where Id =: userInfo.getUserId()];
                    system.debug('TestMethod_4 Time 222===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    
                    Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap, newQuoteLineMap,loggedInUser.Core_WWID__c,true);
                    system.debug('TestMethod_4 Time 333===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    test.startTest();
                    system.debug('TestMethod_4 Time 444===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    Pricing_JSONString JSONVar;
                    List<Core_Integration_Inbound_Message__c> inboundMsgList = new List<Core_Integration_Inbound_Message__c>();
                    List<Core_Integration_Outbound_Message__c> IOMList = [Select id,Core_Payload__c from Core_Integration_Outbound_Message__c where Core_MessageType__c= 'Tender'];
                    Integer i=0;
                    system.debug('IOMList size==>'+IOMList.size());
                    for(Core_Integration_Outbound_Message__c outBoundMsg : IOMList){
                        
                        JSONVar = (Pricing_JSONString)System.JSON.deserialize(outBoundMsg.Core_Payload__c, Pricing_JSONString.class);
                        JSONVar.Header.source_system = 'MyDeals';
                        JSONVar.Header.target_system = 'Tender';
                        JSONVar.Header.action = Label.Pricing_Tender_Integration_Header_Action_Update;
                        //JSONVar.RecordDetails.Quote.Id = null;
                        JSONVar.RecordDetails.Quote.FolioID = null;
                        JSONVar.RecordDetails.Quote.Id = null;
                        
                        List<Pricing_JSONString.QuoteLine> quoteLineList = new List<Pricing_JSONString.QuoteLine>();
                        quoteLineList = JSONVar.RecordDetails.Quote.QuoteLine;
                        for(Pricing_JSONString.QuoteLine temp : quoteLineList){
                            //temp.Id = null;
                            temp.DealRFQId = null;
                            temp.DealRFQStatus = 'Requested';
                            //Pricing_JSONString.ErrorMessages errorMessageRec = new Pricing_JSONString.ErrorMessages(); 
                            //errorMessageRec.code = 'test';
                            //errorMessageRec.Message = 'test2';
                            //temp.ErrorMessages = new List<Pricing_JSONString.ErrorMessages>{errorMessageRec};
                        }
                        JSONVar.RecordDetails.Quote.QuoteLine = quoteLineList;
                        Core_Integration_Inbound_Message__c inboundMsg2 = new Core_Integration_Inbound_Message__c();
                        inboundMsg2.Core_Payload__c = JSON.serialize(JSONVar);
                        inboundMsg2.Core_Message_Type__c = 'Tender';
                        inboundMsg2.Core_Source_System__c = 'MyDeals';
                        inboundMsg2.Core_Processing_Status__c = 'Pending';
                        inboundMsg2.Core_Retry_Counter__c  = 9;
                        inboundMsg2.Core_Error_Code__c = '201';
                        inboundMsgList.add(inboundMsg2);
                        
                        
                    }
                    system.debug('inboundMsgList size==>'+inboundMsgList.size());
                    system.debug('TestMethod_4 Time 555===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    if(!inboundMsgList.isEmpty()){
                        QuoteLineBusinessLogic.hasRunOnce = false;
                        Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;       
                        insert inboundMsgList;
                        system.debug('TestMethod_4 Time 666===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    }               
                    
                }
            }
        }catch(DMLException e){
            
        }
        test.stopTest();
    }
    static testMethod void testInboundAcknowldgementProcessing_5(){  
        try{  
            
            List<User> adminUser = Pricing_Test_Utility.createAdminUser();
            system.runAs(adminUser[0]){
                List<Core_Integration_Outbound_Message__c> IOMList1 = [Select id,Core_Payload__c from Core_Integration_Outbound_Message__c where Core_MessageType__c= 'Tender'];
                system.debug('IOMList1 size ==>'+IOMList1.size());
                List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>();
                quoteLine = [select id from SBQQ__QuoteLine__c LIMIT 6];
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[1].id, 1));
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[2].id, 1));
                List<Pricing_Performance_Metric__c> pm = Pricing_Test_Utility.createPerformanceMetrics(quoteLine[1].Id);
                insert pm;
                system.debug('TestMethod_5 Time 111===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                If(quoteLine.size() > 0){
                    // Send Data to Mydeals 
                    Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
                    Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, SBQQ__Quote__r.Name, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,Pricing_Error_Messages__c,
                                                                   SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,
                                                                   SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,Pricing_Manager__r.Core_WWID__c,
                                                                   SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID__c,Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,
                                                                   Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                                   Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c, 
                                                                   SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,
                                                                   Pricing_Competetor_Product__r.Name,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,
                                                                                                       Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE Id IN : (quoteLine) LIMIT 6] );
                    
                    
                    newQuoteLineMap.put(quoteLine[5].Id, quoteLineMap.get(quoteLine[5].Id));
                    quoteLineIdToActionMap.put(quoteLine[5].Id,Label.Pricing_Tender_Integration_Header_Action_UpdateStatus);
                    newQuoteLineMap.values()[0].Pricing_Deal_RFQ_Id__c='1234';
                    newQuoteLineMap.values()[0].Pricing_Reference_Quote_Line_Nbr__c=quoteLine[3].Id;
                    User loggedInUser = [SELECT Id,Name,Core_WWID__c from User where Id =: userInfo.getUserId()];
                    system.debug('TestMethod_5 Time 222===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    
                    Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap, quoteLineMap,loggedInUser.Core_WWID__c,true);
                    system.debug('TestMethod_5 Time 333===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    
                    system.debug('TestMethod_5 Time 444===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    Pricing_JSONString JSONVar;
                    List<Core_Integration_Inbound_Message__c> inboundMsgList = new List<Core_Integration_Inbound_Message__c>();
                    List<Core_Integration_Outbound_Message__c> IOMList = [Select id,Core_Payload__c from Core_Integration_Outbound_Message__c where Core_MessageType__c= 'Tender'];
                    Integer i=0;
                    system.debug('IOMList size==>'+IOMList.size());
                    for(Core_Integration_Outbound_Message__c outBoundMsg : IOMList){
                        if(i==0){                            
                            JSONVar = (Pricing_JSONString)System.JSON.deserialize(outBoundMsg.Core_Payload__c, Pricing_JSONString.class);
                            JSONVar.Header.source_system = 'MyDeals';
                            JSONVar.Header.target_system = 'Tender';
                            JSONVar.Header.action = Label.Pricing_Tender_Integration_Header_Action_UpdateStatus;
                            List<Pricing_JSONString.QuoteLine> quoteLineList = new List<Pricing_JSONString.QuoteLine>();
                            quoteLineList = JSONVar.RecordDetails.Quote.QuoteLine;
                            for(Pricing_JSONString.QuoteLine temp : quoteLineList){
                                //temp.Id = '';
                                temp.DealRFQId = '1234';
                                temp.DealRFQStatus = Label.Pricing_Tender_Integration_Deal_Status_Won;
                                //Pricing_JSONString.ErrorMessages errorMessageRec = new Pricing_JSONString.ErrorMessages(); 
                                //errorMessageRec.code = '546';
                                //errorMessageRec.Message = 'Test2';
                                //temp.ErrorMessages = //new List<Pricing_JSONString.ErrorMessages>{errorMessageRec};
                            }
                            JSONVar.RecordDetails.Quote.QuoteLine = quoteLineList;
                            Core_Integration_Inbound_Message__c inboundMsg3 = new Core_Integration_Inbound_Message__c();
                            inboundMsg3.Core_Payload__c = JSON.serialize(JSONVar);
                            inboundMsg3.Core_Message_Type__c = 'Tender';
                            inboundMsg3.Core_Source_System__c = 'MyDeals';
                            inboundMsg3.Core_Processing_Status__c = 'Pending';
                            inboundMsg3.Core_Error_Code__c = '200';
                            inboundMsgList.add(inboundMsg3);
                        }
                        i++;
                        
                    }
                    test.startTest();
                    system.debug('inboundMsgList size==>'+inboundMsgList.size());
                    system.debug('TestMethod_5 Time 555===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    if(!inboundMsgList.isEmpty()){
                        QuoteLineBusinessLogic.hasRunOnce = false;
                        Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;       
                        insert inboundMsgList;
                        system.debug('TestMethod_5 Time 666===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    }                
                    
                }
            }
        }catch(DMLException e){
            
        }
        test.stopTest();
    }
    static testMethod void testInboundAcknowldgementProcessing_6(){  
        try{  
            
            List<User> adminUser = Pricing_Test_Utility.createAdminUser();
            system.runAs(adminUser[0]){
                List<Core_Integration_Outbound_Message__c> IOMList1 = [Select id,Core_Payload__c from Core_Integration_Outbound_Message__c where Core_MessageType__c= 'Tender'];
                system.debug('IOMList1 size ==>'+IOMList1.size());
                List<SBQQ__QuoteLine__c> quoteLine = new List<SBQQ__QuoteLine__c>();
                quoteLine = [select id from SBQQ__QuoteLine__c LIMIT 6];
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[1].id, 1));
                //quoteLine.addAll(Pricing_Test_Utility.createQuoteLines(quote[2].id, 1));
                List<Pricing_Performance_Metric__c> pm = Pricing_Test_Utility.createPerformanceMetrics(quoteLine[1].Id);
                insert pm;
                system.debug('TestMethod_5 Time 111===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                If(quoteLine.size() > 0){
                    // Send Data to Mydeals 
                    Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
                    Map<Id,SBQQ__QuoteLine__c> quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    Map<Id,SBQQ__QuoteLine__c> newQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
                    quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, SBQQ__Quote__r.Name, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,Pricing_Error_Messages__c,
                                                                   SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,Pricing_Reference_Quote_Line_Nbr__c,
                                                                   SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,Pricing_Manager__r.Core_WWID__c,
                                                                   SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID__c,Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,
                                                                   Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                                                                   Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c, 
                                                                   SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,
                                                                   Pricing_Competetor_Product__r.Name,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,
                                                                                                       Pricing_Intel_SKU_Performance_Nbr__c,Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE Id IN : (quoteLine) LIMIT 6] );
                    
                    
                    newQuoteLineMap.put(quoteLine[5].Id, quoteLineMap.get(quoteLine[5].Id));
                    quoteLineIdToActionMap.put(quoteLine[5].Id,Label.Pricing_Tender_Integration_Header_Action_UpdateStatus);
                    newQuoteLineMap.values()[0].Pricing_Deal_RFQ_Id__c='1234';
                    //newQuoteLineMap.values()[0].Pricing_Reference_Quote_Line_Nbr__c=quoteLine[3].Id;
                    User loggedInUser = [SELECT Id,Name,Core_WWID__c from User where Id =: userInfo.getUserId()];
                    system.debug('TestMethod_5 Time 222===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    
                    Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap, quoteLineMap,loggedInUser.Core_WWID__c,true);
                    system.debug('TestMethod_5 Time 333===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    
                    system.debug('TestMethod_5 Time 444===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    Pricing_JSONString JSONVar;
                    List<Core_Integration_Inbound_Message__c> inboundMsgList = new List<Core_Integration_Inbound_Message__c>();
                    List<Core_Integration_Outbound_Message__c> IOMList = [Select id,Core_Payload__c from Core_Integration_Outbound_Message__c where Core_MessageType__c= 'Tender'];
                    Integer i=0;
                    system.debug('IOMList size==>'+IOMList.size());
                    for(Core_Integration_Outbound_Message__c outBoundMsg : IOMList){
                        if(i==1){                            
                            JSONVar = (Pricing_JSONString)System.JSON.deserialize(outBoundMsg.Core_Payload__c, Pricing_JSONString.class);
                            JSONVar.Header.source_system = 'MyDeals';
                            JSONVar.Header.target_system = 'Tender';
                            JSONVar.Header.action = Label.Pricing_Tender_Integration_Header_Action_UpdateStatus;
                            List<Pricing_JSONString.QuoteLine> quoteLineList = new List<Pricing_JSONString.QuoteLine>();
                            quoteLineList = JSONVar.RecordDetails.Quote.QuoteLine;
                            for(Pricing_JSONString.QuoteLine temp : quoteLineList){
                                //temp.Id = '';
                                temp.DealRFQId = '1234';
                                temp.DealRFQStatus = Label.Pricing_Tender_Integration_Deal_Status_Won;
                                //Pricing_JSONString.ErrorMessages errorMessageRec = new Pricing_JSONString.ErrorMessages(); 
                                //errorMessageRec.code = '546';
                                //errorMessageRec.Message = 'Test2';
                                //temp.ErrorMessages = //new List<Pricing_JSONString.ErrorMessages>{errorMessageRec};
                            }
                            JSONVar.RecordDetails.Quote.QuoteLine = quoteLineList;
                            Core_Integration_Inbound_Message__c inboundMsg3 = new Core_Integration_Inbound_Message__c();
                            inboundMsg3.Core_Payload__c = JSON.serialize(JSONVar);
                            inboundMsg3.Core_Message_Type__c = 'Tender';
                            inboundMsg3.Core_Source_System__c = 'MyDeals';
                            inboundMsg3.Core_Processing_Status__c = 'Pending';
                            inboundMsg3.Core_Error_Code__c = '200';
                            inboundMsgList.add(inboundMsg3);
                        }
                        i++;
                        
                    }
                    test.startTest();
                    system.debug('inboundMsgList size==>'+inboundMsgList.size());
                    system.debug('TestMethod_5 Time 555===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    if(!inboundMsgList.isEmpty()){
                        QuoteLineBusinessLogic.hasRunOnce = false;
                        Core_IntegrationInboundMessageHandler.hasProcessedNewMessagesAfter = false;       
                        insert inboundMsgList;
                        system.debug('TestMethod_5 Time 666===>'+Limits.getCpuTime()+';;;Queries===>'+Limits.getQueries());
                    }                
                    
                }
            }
        }catch(DMLException e){
            
        }
        test.stopTest();
    }
}