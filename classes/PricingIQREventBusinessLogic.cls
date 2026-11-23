/**
 * @description       : Logic for event triggers
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : Gravity
 * @last modified on  : 11-04-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class PricingIQREventBusinessLogic {
    
    public static void quoteShare(List<Pricing_IQR_Event__e> pricingRecList)
    {
        Set<String> quoteIds = new Set<String>();
        try{
            for(Pricing_IQR_Event__e iqrEventRec: pricingRecList){
                if(iqrEventRec.Pricing_QuoteId_Txt__c != null){
                    quoteIds.addAll((iqrEventRec.Pricing_QuoteId_Txt__c).split(','));
                }
            }
            
            Set<Id> recordTypeId = new Set<Id>();
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_RecordType_Edit));
            recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_RecordType_ReadOnly));
            recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_RecordType_Create));
            recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_RecordType_Submitted));
            recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Small_Volume_Quote_Create));
           // recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_SSD_Quote_Create));
           // recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_PMem_Quote_Create));
           // recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_NIC_Quote_Create));
            recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Client_Quote_RecordType_Create));
            recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Client_Quote_RecordType_Edit));
            recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Client_Quote_RecordType_ReadOnly));
            recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Client_Quote_RecordType_Submitted));
            

            if(!quoteIds.isEmpty()){
                quoteList = [SELECT Id, SBQQ__Account__c from SBQQ__Quote__c WHERE Id IN : quoteIds and RecordTypeId IN : recordTypeId];
                if(!quoteList.isEmpty()){
                    QuoteBusinessLogic.shareQuotes(quoteList);
                }
            }
        }
        catch(Exception ex){Pricing_Tender_Utility.logError(ex);}          
    }
    
    public static void wonLostQuoteLineIntegration(List<Pricing_IQR_Event__e> pricingRecList)
    {
        try{
            Set<String> quoteLineIds = new Set<String>();           
            Map<Id,String> quoteLineIdToActionMap = new Map<Id,String>();
            set<String> updateStatusActions = new Set<String> ((Label.Pricing_Tender_Update_Status_Actions).split(':'));
            List<SBQQ__QuoteLine__c> wonLostQuoteLines = new List<SBQQ__QuoteLine__c>();
            Map<Id,String> qlIdToRuleIdRuleNameMap = new Map<Id,String>();
            for(Pricing_IQR_Event__e iqrEventRec: pricingRecList){
                if(iqrEventRec.Pricing_QuoteLineId_Txt__c != null){
                    quoteLineIds.addAll((iqrEventRec.Pricing_QuoteLineId_Txt__c).split(','));
                }
            }
            /*for(Id quoteLineId : quoteLineIds){
                quoteLineIdToActionMap.put(quoteLineId,Label.Pricing_Tender_Integration_Header_Action_UpdateStatus);
            }*/
            
            Map<Id,SBQQ__QuoteLine__c> quoteLineMap;
            quoteLineMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, 
                                                            SBQQ__Quote__r.Name, Pricing_EndCustomer_Nm__c, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,
                                                            Pricing_Reference_Quote_Line_Nbr__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,
                                                            SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,
                                                            Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,
                                                            Pricing_Manager__r.Core_WWID__c,SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_Business_Party_Id__c,SBQQ__Quote__r.Pricing_Market_Segment_values_Nm__c,
                                                            Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,
                                                            Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,SBQQ__Product__r.Core_Item_Id__c,
                                                            Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,Pricing_Consumption_Segment__c,
                                                            Pricing_Approved_Start_Date_Dt__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Pricing_Unified_EndCustomer_Id__c,Pricing_Approved_End_Date_Dt__c,Pricing_Approved_Unit_Qty__c,Pricing_Payable_Quantity__c,Pricing_Deal_RFQ_Status_Nm__c, 
                                                            Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,Pricing_Consumption_Platform__c,Pricing_Consumption_Sale_Geo__c,Pricing_Consumption_Country__c,Pricing_Consumption_Region__c,
                                                            Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,
                                                            SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,SBQQ__Product__r.Core_Family_Nm__c,SBQQ__Product__r.Core_Forecast_Product_Name__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,
                                                            Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,Pricing_Competetor_Product__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__r.Name,
                                                            SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_EndCustomer_Act_Mapping__c,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c,
                                                            SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,Pricing_Program_Type_Nm__c,Pricing_SDM_Fast_Track__c,
                                                            SBQQ__Quote__r.Pricing_Is_Sanctioned__c,Pricing_Account_Division_Nm__c,Pricing_Comp_Product_Txt__c,Pricing_Performance_Metric_Nm__c,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,(SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,
                                                            Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) FROM SBQQ__QuoteLine__c WHERE Id IN : (quoteLineIds)]); 
                    
            for(SBQQ__QuoteLine__c quoteLine : quoteLineMap.values()) {
                if(updateStatusActions.contains(quoteLine.Pricing_Status_Nm__c)) {  
                    quoteLineIdToActionMap.put(quoteLine.Id,Label.Pricing_Tender_Integration_Header_Action_UpdateStatus);
                }
                if(quoteLine.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Rejected) {
                    quoteLineIdToActionMap.put(quoteLine.Id,Label.Pricing_Tender_Integration_Header_Action_Delete);
                }
            }                                                
            
            if(!quoteLineIdToActionMap.isEmpty()){               
                   User loggedInUser = [SELECT Id,Core_WWID__c from User where Id =: pricingRecList[0].createdById];   //Get the WWID of the Current User
                   Pricing_IntegrationSFDCToPricingSystems.insertQuoteOutBoundMessage(quoteLineIdToActionMap,quoteLineMap,loggedInUser.Core_WWID__c,false,qlIdToRuleIdRuleNameMap);
            }
            set<Id> quoteIds = new Set<Id>();            
            for(SBQQ__QuoteLine__c qli :quoteLineMap.values()){
                if((qli.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won || qli.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost)){
                    wonLostQuoteLines.add(qli);
                    quoteIds.add(qli.SBQQ__Quote__c);
                }                    
            }
            if(wonLostQuoteLines.size() > 0){               
                sendMassEmailNotificationOnWonOrLoss(wonLostQuoteLines, quoteIds);
            }
        }
        catch(Exception ex){Pricing_Tender_Utility.logError(ex);}          
    }
    
    public static void wonLostNotificationForWriteInProducts(List<Pricing_IQR_Event__e> pricingRecList){
        try{
            Set<String> quoteLineIds = new Set<String>();           
            List<SBQQ__QuoteLine__c> wonLostQuoteLines = new List<SBQQ__QuoteLine__c>();
            for(Pricing_IQR_Event__e iqrEventRec: pricingRecList){
                if(iqrEventRec.Pricing_QuoteLineId_Txt__c != null){
                    quoteLineIds.addAll((iqrEventRec.Pricing_QuoteLineId_Txt__c).split(','));
                }
            }                   
            set<Id> quoteIds = new Set<Id>();            
            for(SBQQ__QuoteLine__c qli :[SELECT Id,SBQQ__Quote__c,SBQQ__Quote__r.Pricing_Account_Executive_Nm__c,Pricing_Status_Nm__c,Pricing_Manager__r.Email,Pricing_Sales_Rep__c,Pricing_Sales_Rep__r.Email,Pricing_Sales_Rep__r.DelegatedApproverId
                                          FROM SBQQ__QuoteLine__c WHERE Id IN : (quoteLineIds)]){
                if((qli.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Won || qli.Pricing_Status_Nm__c == Label.Pricing_Tender_QuoteLine_Status_Lost)){
                    wonLostQuoteLines.add(qli);
                    quoteIds.add(qli.SBQQ__Quote__c);
                }                    
            }
            if(wonLostQuoteLines.size() > 0){               
                sendMassEmailNotificationOnWonOrLoss(wonLostQuoteLines, quoteIds);
            }
            
        }
        catch(Exception ex){Pricing_Tender_Utility.logError(ex);}   
    }
    
    public static void sendMassEmailNotificationOnWonOrLoss(List<SBQQ__QuoteLine__c> quoteLines, Set<Id> quoteIds){
        
        Set<Id> qliIds = new Set<Id>();
        for(SBQQ__QuoteLine__c quoteLine : quoteLines){
            qliIds.add(quoteLine.Id);
        }
        if(qliIds.size() > 0){
            Pricing_EmailUtility.sendEmailToReciepents(qliIds, Label.Pricing_QuoteLinenWonLossNotification_Template);  
        }
    }

    public static void sendEmailNotification(List<Pricing_IQR_Event__e> pricingRecList){
        Map<String,Set<Id>> templateQLIIdsMap = new Map<String,Set<Id>>();
        try{
            for(Pricing_IQR_Event__e iqrEventRec: pricingRecList){
                if(!String.isEmpty(iqrEventRec.Pricing_EmailTemplate_Nm__c) && iqrEventRec.Pricing_QuoteLineId_Txt__c != null){
                    if(templateQLIIdsMap.containsKey(iqrEventRec.Pricing_EmailTemplate_Nm__c)){
                        templateQLIIdsMap.get(iqrEventRec.Pricing_EmailTemplate_Nm__c).addAll(((List<Id>)iqrEventRec.Pricing_QuoteLineId_Txt__c.split(',')));
                    }else{
                        templateQLIIdsMap.put(iqrEventRec.Pricing_EmailTemplate_Nm__c, new Set<Id>(((List<Id>)iqrEventRec.Pricing_QuoteLineId_Txt__c.split(','))));
                    }              
                }
            }
            for(String emailTemplateName : templateQLIIdsMap.keySet()){
                Pricing_EmailUtility.sendEmailToReciepents(templateQLIIdsMap.get(emailTemplateName), emailTemplateName);
            }
        }catch(Exception ex){Pricing_Tender_Utility.logError(ex);}
    }

    public static void sendEmailNotificationToApprover(List<Pricing_IQR_Event__e> pricingRecList){
        Map<String,Set<Id>> templateQLIIdsMap = new Map<String,Set<Id>>();
        try{
            for(Pricing_IQR_Event__e iqrEventRec: pricingRecList){
                if(!String.isEmpty(iqrEventRec.Pricing_EmailTemplate_Nm__c) && iqrEventRec.Pricing_QuoteLineId_Txt__c != null){
                    if(templateQLIIdsMap.containsKey(iqrEventRec.Pricing_EmailTemplate_Nm__c)){
                        templateQLIIdsMap.get(iqrEventRec.Pricing_EmailTemplate_Nm__c).addAll(((List<Id>)iqrEventRec.Pricing_QuoteLineId_Txt__c.split(',')));
                    }else{
                        templateQLIIdsMap.put(iqrEventRec.Pricing_EmailTemplate_Nm__c, new Set<Id>(((List<Id>)iqrEventRec.Pricing_QuoteLineId_Txt__c.split(','))));
                    }                
                }
            }
            for(String emailTemplateName : templateQLIIdsMap.keySet()){
                    Pricing_EmailUtility.sendEmailToApprover(templateQLIIdsMap.get(emailTemplateName), emailTemplateName);
            }
        }catch(Exception ex){Pricing_Tender_Utility.logError(ex);}
    }
    
    public static void reAssignApprovalRequest(List<Pricing_IQR_Event__e> pEvts){
        String[] recIdsArr = pEvts[0].Pricing_QuoteId_Txt__c.split(';');
        //quote update for new fse
        List<SBQQ__Quote__c> quoteList = [Select id, Pricing_Intel_Sales_Rep_Email_Txt__c, SBQQ__SalesRep__c, (SELECT id, Name, Pricing_Status_Nm__c FROM Quote_Lines__r where Pricing_Status_Nm__c =:Label.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview) from SBQQ__Quote__c where id =:recIdsArr[0]];
        String oldSalesrepId = quoteList[0].SBQQ__SalesRep__c;
        quoteList[0].Pricing_Intel_Sales_Rep_Email_Txt__c = recIdsArr[1];
        update quoteList;
        Set<id> quotelineIds = new Set<Id>();
        for(SBQQ__Quoteline__c qli: quoteList[0].Quote_Lines__r){
            quotelineIds.add(qli.id);
        }
        //reassign the pending approvals to new fse
        User usr = [SELECT id FROM User Where Email=:recIdsArr[1]];
        List<ProcessInstanceWorkItem> pwitems = [SELECT id,ActorId,Actor.Name,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId in :quotelineIds AND ActorId=:oldSalesrepId];
        if(pwitems.size() > 0){
            for(ProcessInstanceWorkItem pwItem : pwitems){
                pwItem.ActorId = usr.Id; 
            }
            update pwitems;
        }
    }

    public static void runCalculatorServiceForFI(List<Pricing_IQR_Event__e> pricingRecList) {
        Set<String> quoteIds = new Set<String>();
        try{
            for(Pricing_IQR_Event__e iqrEventRec: pricingRecList) {
                if(iqrEventRec.Pricing_QuoteId_Txt__c != null){
                    quoteIds.addAll((iqrEventRec.Pricing_QuoteId_Txt__c).split(','));
                }
            }
            

            if(!quoteIds.isEmpty()){
                List<SBQQ__Quote__c> quoteList = [SELECT Id, SBQQ__LastCalculatedOn__c from SBQQ__Quote__c WHERE Id IN : quoteIds];
                if(!quoteList.isEmpty()){
                    for(SBQQ__Quote__c quote: quoteList) {
                        QuoteLineBusinessLogic.runCalculatorService(quote.Id);
                    }
                }
            }
        }
        catch(Exception ex){Pricing_Tender_Utility.logError(ex);}          
    }
}