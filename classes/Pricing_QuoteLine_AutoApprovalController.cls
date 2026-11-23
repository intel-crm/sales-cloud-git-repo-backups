/**
 * @description       : Class used to perform auto approval action from Flow
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 06-25-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_QuoteLine_AutoApprovalController extends TriggerHandler{

    public static Map<Id, String> quoteLineIdtoActionMap = new Map<Id, String>();
    public static Map<Id, String> quoteLineIdtoMsgMap = new Map<Id, String>();
    public static Map<Id, Decimal> qliIdtoECAPPrice = new Map<Id, Decimal>();
    public static Map<Id, Decimal> qliIdtoMeetCompPrice = new Map<Id, Decimal>();
    public static Map<Id, String> qlIdToRuleIdMap = new Map<Id, String>();
    public static Map<Id, String> qlIdToRuleIdRuleNameMap = new Map<Id, String>();
    public static Set<String> priceRuleIds = new Set<String>();
    public static Map<String, Pricing_Product_Floor_Price__c> prodIdToFloorPriceRec = new Map<String, Pricing_Product_Floor_Price__c>();
    public static Map<String, List<Pricing_Product_Floor_Price__c>> ruleIdToFloorPriceRec = new Map<String, List<Pricing_Product_Floor_Price__c>>();
    public static Boolean isChangeRequestPriceRule = false;
    public static Boolean isCalledFromTrigger = false;
    public static Boolean isNotRunByPriceRule = false;
    public static Boolean isChangeRequestQl = false;



    /**
    * @description Method called from Autolaunched flow to perform Auto Action
    * @author Sandeep Chamate | 08-23-2023 
    * @param flowInputsList - contains action and QuoteLine List
    **/
    @InvocableMethod(label = 'autoApprovePFIRQuoteLine' description = 'To Approve PFIR Quoteline')
    public static void autoApprovePFIRQuoteLine(List<FlowInputs> flowInputsList){
        String rpmEmail = flowInputsList[0].rpmUserEmail;
        Map<String, List<SBQQ__QuoteLine__c>> actionToQuoteLineListMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        

        try{
            for(Integer i=0; i < flowInputsList.size(); i++){
                qliIdtoECAPPrice.put(flowInputsList[i].quoteLine.Id, flowInputsList[i].ecapPrice);
                qliIdtoMeetCompPrice.put(flowInputsList[i].quoteLine.Id, flowInputsList[i].meetCompPrice);
                if(TriggerHandler.isActive('Pricing_PriceRulesSwitch')){
                   qlIdToRuleIdMap.put(flowInputsList[i].quoteLine.Id, flowInputsList[i].priceRuleId);
                   priceRuleIds.add(flowInputsList[i].priceRuleId);
                }
                if(actionToQuoteLineListMap.containsKey(flowInputsList[i].action)){
                    actionToQuoteLineListMap.get(flowInputsList[i].action).add(flowInputsList[i].quoteLine);
                }else{
                    actionToQuoteLineListMap.put(flowInputsList[i].action, new List<SBQQ__QuoteLine__c>{flowInputsList[i].quoteLine});
                }

            }

            QuoteLineBusinessLogic.isAutoApproveReject = true;
            if(actionToQuoteLineListMap.containsKey('FSE Approve')){
                Pricing_BulkSalesRepActionController.recordApproval(actionToQuoteLineListMap.get('FSE Approve'), Label.Pricing_Tender_QuoteLine_Status_Approved, null, false);
            }

            if(actionToQuoteLineListMap.containsKey('FSE Reject')){ // rejection reason- other/ comments - auto rejected
                Pricing_BulkSalesRepActionController.recordApproval(actionToQuoteLineListMap.get('FSE Reject'), Label.Pricing_Tender_QuoteLine_Status_Rejected, null, false);
            }

            if(actionToQuoteLineListMap.containsKey('RPM Reject') || actionToQuoteLineListMap.containsKey('RPM Approve') || actionToQuoteLineListMap.containsKey('RPM Create Deal')){
                autoApprovebyRPM(actionToQuoteLineListMap, rpmEmail);
            }
        }
        catch(Exception ex){
            Pricing_Tender_Utility.logError(ex);
        }
    }

    /**
    * @description - Method to perform Auto RPM Action
    * @author Sandeep Chamate | 08-24-2023 
    * @param actionToQuoteLineListMap 
    * @param rpmEmail - Email Id of RPM User from BRE
    **/
    public static void autoApprovebyRPM(Map<String, List<SBQQ__QuoteLine__c>> actionToQuoteLineListMap, String rpmEmail){
        List<SBQQ__QuoteLine__c> quoteLineListtoUpdate = new List<SBQQ__QuoteLine__c>();
        List<String> quoteLinesIds = new List<String>();
        List<String> crQuoteLinesIds = new List<String>();
        Id rpmUserId;
        Map<Id,SBQQ__QuoteLine__c> qlIdRecordMap = new Map<Id,SBQQ__QuoteLine__c>();
        Set<Id> quoteIds = new Set<Id>();
        Map<Id,String> ruleIdToRPMEmail = new Map<Id,String>();
        Map<String,Id> rpmEmailToUserId = new Map<String,Id>();
        Map<Id,SBQQ__Quote__c> quoteIdRecordMap = new Map<Id,SBQQ__Quote__c>();
         Map<Id,SBQQ__QuoteLine__c> qlIdqlRecordMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<String,Decimal> accountIdMtdRecordMap = new Map<String,Decimal>();
        Map<Id,Id> qlIdAccountIdMap = new Map<Id,Id>();
        String accountId = '';

        if(!String.isBlank(rpmEmail)){
            rpmUserId = [SELECT id FROM User WHERE Email =: rpmEmail LIMIT 1].Id;
        }
        
        accountIdMtdRecordMap = Pricing_QuoteLine_BulkDealController.accountToCIMIdMappingMtdRec(); 

        if(priceRuleIds.size() >0){
            for (String key : actionToQuoteLineListMap.keySet()) {
                List<SBQQ__QuoteLine__c> qlList = actionToQuoteLineListMap.get(key);
                for (SBQQ__QuoteLine__c ql : qlList) {
                    if(ql.Pricing_Additional_Comments_Txt__c != '#autoapprove'){
                        qlIdRecordMap.put(ql.Id,ql);
                        quoteIds.add(ql.SBQQ__Quote__c);
                    }
                }
            }

            //getting all products for each rule where product floor price record is active and Approval price rule is active
            for(Pricing_Product_Floor_Price__c prodEcap : [select id,Pricing_Product__c,Pricing_Approved_ECAP_Price__c,Pricing_Approval_Price_Rules__r.Name,Pricing_Approval_Price_Rules__r.Pricing_Rule_Name__c,Pricing_Approval_Price_Rules__c, 
                                                            Pricing_Approval_Price_Rules__r.Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Approval_Price_Rules__r.Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Approval_Price_Rules__r.Pricing_RPM_Email__c 
                                                            from Pricing_Product_Floor_Price__c where Pricing_Approval_Price_Rules__c In: priceRuleIds and Pricing_Active__c = true and Pricing_Approval_Price_Rules__r.Pricing_Is_Active__c = true]){

                prodIdToFloorPriceRec.put(prodEcap.Pricing_Product__c + ':' + prodEcap.Pricing_Approval_Price_Rules__c ,prodEcap);
                
                //for rpm populating map
                if(!ruleIdToRPMEmail.containsKey(prodEcap.Pricing_Approval_Price_Rules__c)){
                    ruleIdToRPMEmail.put(prodEcap.Pricing_Approval_Price_Rules__c,prodEcap.Pricing_Approval_Price_Rules__r.Pricing_RPM_Email__c);
                }
                if(ruleIdToFloorPriceRec.containsKey(prodEcap.Pricing_Approval_Price_Rules__c)){
                    ruleIdToFloorPriceRec.get(prodEcap.Pricing_Approval_Price_Rules__c).add(prodEcap);
                }else{
                    ruleIdToFloorPriceRec.put(prodEcap.Pricing_Approval_Price_Rules__c, new List<Pricing_Product_Floor_Price__c> { prodEcap});
                }
            }
        }


        for(PermissionSetAssignment usrPS : [SELECT Id, AssigneeId,Assignee.Email FROM PermissionSetAssignment WHERE Assignee.Email In: ruleIdToRPMEmail.values() AND Assignee.IsActive = true 
                                                      AND  PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager]){
            rpmEmailToUserId.put(usrPS.Assignee.Email,usrPS.AssigneeId);
        }

        //getting quotes and Ql fields for Ql where Price rule as run.
        if(qlIdRecordMap.size() > 0){
            for(SBQQ__QuoteLine__c ql : [select Id,SBQQ__Quote__r.SBQQ__Account__c,Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,
                                        Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_End_Date_dt__c, SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c,
                                        SBQQ__Quote__r.Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_New_Change_Request_cb__c,Pricing_Reference_QuoteLine_Link_Nbr__c,Pricing_Request_Discount_Unit_Price_qty__c from SBQQ__QuoteLine__c where Id In: qlIdRecordMap.keySet()]){
                qlIdqlRecordMap.put(ql.Id,ql);
                qlIdAccountIdMap.put(ql.Id,ql.SBQQ__Quote__r.SBQQ__Account__c);
            }           
        }
            if(actionToQuoteLineListMap.containsKey('RPM Reject')){
                for(SBQQ__QuoteLine__c qli: actionToQuoteLineListMap.get('RPM Reject')){
                    qli.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Rejected;
                    qli.Pricing_Rejection_Reason__c = Label.Pricing_rejection_reason_other_value;
                    qli.Pricing_Rejection_Comments_nm__c = 'Auto Rejection by RPM.';
                    qli.Pricing_Manager__c = rpmUserId != null ? rpmUserId : userInfo.getUserId();
                    quoteLineListtoUpdate.add(qli);
                }
            }

            if(actionToQuoteLineListMap.containsKey('RPM Approve')){
                for(SBQQ__QuoteLine__c qli: actionToQuoteLineListMap.get('RPM Approve')){
                    
                        qli.Pricing_ECAP_Price_Amt__c = qliIdtoECAPPrice.containsKey(qli.Id) && qliIdtoECAPPrice.get(qli.Id) != null ? qliIdtoECAPPrice.get(qli.Id) :  qli.Pricing_Req_Discounted_Unit_Price__c ;//2000;
                        qli.Pricing_Meet_Comp_Price_Amt__c = qliIdtoMeetCompPrice.containsKey(qli.Id) && qliIdtoMeetCompPrice.get(qli.Id) != null ? qliIdtoMeetCompPrice.get(qli.Id) : 1;
                        qli.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Approved;
                        qli.Pricing_Manager__c = rpmUserId != null ? rpmUserId : userInfo.getUserId();
                        quoteLineListtoUpdate.add(qli);
                }
            }

            if(actionToQuoteLineListMap.containsKey('RPM Create Deal')){
                for(SBQQ__QuoteLine__c qli: actionToQuoteLineListMap.get('RPM Create Deal')){
                    if(qli.Pricing_New_Change_Request_cb__c == true){
                        isChangeRequestQl = true;
                    }
                    if(qli.Pricing_Additional_Comments_Txt__c == '#autoapprove' ){
                        isNotRunByPriceRule = true;
                        qli.Pricing_ECAP_Price_Amt__c = qliIdtoECAPPrice.containsKey(qli.Id) && qliIdtoECAPPrice.get(qli.Id) != null ? qliIdtoECAPPrice.get(qli.Id) : qli.Pricing_Req_Discounted_Unit_Price__c ;//2000;
                        qli.Pricing_Meet_Comp_Price_Amt__c = qliIdtoMeetCompPrice.containsKey(qli.Id) && qliIdtoMeetCompPrice.get(qli.Id) != null ? qliIdtoMeetCompPrice.get(qli.Id) : 1;// build pre flow list of product and price
                        qli.Pricing_Manager__c = rpmUserId != null ? rpmUserId : userInfo.getUserId();
                        qli.Pricing_Deal_Description__c = '#IQRAutoApprove';
                        quoteLinesIds.add(qli.Id);
                        quoteLineListtoUpdate.add(qli);
                    }else{
                        system.debug('entering else:');
                        accountId = 'Id_' +qlIdAccountIdMap.get(qli.Id);
                        Boolean isQlProdPricePodMatch = false;
                        isChangeRequestPriceRule = true;
                        if(ruleIdToFloorPriceRec.size() > 0 && ruleIdToFloorPriceRec.containsKey(qlIdToRuleIdMap.get(qli.Id)) && !qlIdToRuleIdMap.isEmpty()){
                            for(Pricing_Product_Floor_Price__c floorPrice : ruleIdToFloorPriceRec.get(qlIdToRuleIdMap.get(qli.Id))){
                                if(floorPrice.Pricing_Product__c == qli.SBQQ__Product__c) {
                                    isQlProdPricePodMatch = true;
                                    break;
                                }
                            }
                        }

                        //checking if sales Rep or AE is provided on rule against quotes sales rep and AE or if not provided sales Rep and AE on rule also we are allowing deal creation
                        String accountExecutiveEmail = isQlProdPricePodMatch ? prodIdToFloorPriceRec.get(qli.SBQQ__Product__c + ':' + qlIdToRuleIdMap.get(qli.Id)).Pricing_Approval_Price_Rules__r.Pricing_Intel_Account_Exec_Email_Txt__c : null;
                        String salesRepEmail = isQlProdPricePodMatch ? prodIdToFloorPriceRec.get(qli.SBQQ__Product__c + ':' + qlIdToRuleIdMap.get(qli.Id)).Pricing_Approval_Price_Rules__r.Pricing_Intel_Sales_Rep_Email_Txt__c : null;
                        Boolean isEmptyAllorOneEmails = false;

                        if((String.isBlank(accountExecutiveEmail) && String.isBlank(salesRepEmail)) || ((String.isBlank(accountExecutiveEmail) && !String.isBlank(salesRepEmail)) || (!String.isBlank(accountExecutiveEmail) && String.isBlank(salesRepEmail))) || (!String.isBlank(accountExecutiveEmail) && !String.isBlank(salesRepEmail))){
                            isEmptyAllorOneEmails = true;                        
                        }

                        system.debug('priceRuleIds:'+priceRuleIds);
                        system.debug('qlIdToRuleIdMap:'+qlIdToRuleIdMap);
                        if(isEmptyAllorOneEmails == true && (((!String.isBlank(accountExecutiveEmail) && accountExecutiveEmail != qlIdqlRecordMap.get(qli.Id).SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c) && (!String.isBlank(salesRepEmail) && salesRepEmail != qlIdqlRecordMap.get(qli.Id).SBQQ__Quote__r.Pricing_Intel_Sales_Rep_Email_Txt__c)) 
                            || ((!String.isBlank(accountExecutiveEmail) && accountExecutiveEmail != qlIdqlRecordMap.get(qli.Id).SBQQ__Quote__r.Pricing_Intel_Account_Exec_Email_Txt__c) || (!String.isBlank(salesRepEmail) && salesRepEmail != qlIdqlRecordMap.get(qli.Id).SBQQ__Quote__r.Pricing_Intel_Sales_Rep_Email_Txt__c)))){
                            isEmptyAllorOneEmails = false;
                        }
                        system.debug('isQlProdPricePodMatch:'+isQlProdPricePodMatch);
                        system.debug('prodIdToFloorPriceRec:'+prodIdToFloorPriceRec);
                        system.debug('isEmptyAllorOneEmails:'+isEmptyAllorOneEmails);
                        if((priceRuleIds.size() > 0 && qlIdToRuleIdMap.size() > 0 && isQlProdPricePodMatch && prodIdToFloorPriceRec.size() > 0 && qlIdToRuleIdMap.get(qli.Id) == prodIdToFloorPriceRec.get(qli.SBQQ__Product__c + ':' + qlIdToRuleIdMap.get(qli.Id)).Pricing_Approval_Price_Rules__c 
                            && prodIdToFloorPriceRec.get(qli.SBQQ__Product__c + ':' + qlIdToRuleIdMap.get(qli.Id)).Pricing_Approved_ECAP_Price__c != null) && isEmptyAllorOneEmails){ 

                            qlIdToRuleIdRuleNameMap.put(qli.Id,prodIdToFloorPriceRec.get(qli.SBQQ__Product__c + ':' + qlIdToRuleIdMap.get(qli.Id)).Pricing_Approval_Price_Rules__r.Name+':'+prodIdToFloorPriceRec.get(qli.SBQQ__Product__c + ':' + qlIdToRuleIdMap.get(qli.Id)).Pricing_Approval_Price_Rules__r.Pricing_Rule_Name__c);
                            Decimal ecapPriceAmt = prodIdToFloorPriceRec.get(qli.SBQQ__Product__c + ':' + qlIdToRuleIdMap.get(qli.Id)).Pricing_Approved_ECAP_Price__c;
                           if(qli.Pricing_New_Change_Request_cb__c == true && qli.Pricing_Reference_Quote_Line_Nbr__c != null && qli.Pricing_Request_Discount_Unit_Price_qty__c != null){
                                if(qli.Pricing_Request_Discount_Unit_Price_qty__c < qli.Pricing_ECAP_Price_Amt__c){
                                    break;
                                }
                                qli.Pricing_ECAP_Price_Amt__c = qli.Pricing_Request_Discount_Unit_Price_qty__c > ecapPriceAmt ? qli.Pricing_Request_Discount_Unit_Price_qty__c : qli.Pricing_Request_Discount_Unit_Price_qty__c < ecapPriceAmt ? ecapPriceAmt : qli.Pricing_Request_Discount_Unit_Price_qty__c == ecapPriceAmt ? ecapPriceAmt : null;  
                            }else{
                                qli.Pricing_ECAP_Price_Amt__c = qli.Pricing_Req_Discounted_Unit_Price__c > ecapPriceAmt ? qli.Pricing_Req_Discounted_Unit_Price__c : qli.Pricing_Req_Discounted_Unit_Price__c < ecapPriceAmt ? ecapPriceAmt : qli.Pricing_Req_Discounted_Unit_Price__c == ecapPriceAmt ? ecapPriceAmt : null;
                            }
                            if(qli.Pricing_New_Change_Request_cb__c == true && qli.Pricing_Reference_Quote_Line_Nbr__c != null && qli.Pricing_New_Quantity_qty__c != null){
                                qli.Pricing_Approved_Unit_Qty__c = qli.Pricing_New_Quantity_qty__c;  
                            }
                            system.debug('ruleIdToRPMEmail:'+ruleIdToRPMEmail);
                            qli.Pricing_Manager__c = rpmEmailToUserId.size() > 0 && rpmEmailToUserId.containsKey(ruleIdToRPMEmail.get(qlIdToRuleIdMap.get(qli.Id))) ? rpmEmailToUserId.get(ruleIdToRPMEmail.get(qlIdToRuleIdMap.get(qli.Id))) : null ;//rpmUserId;
                            qli.Pricing_Approval_Price_Rule_Name__c = qlIdToRuleIdRuleNameMap.get(qli.Id);
                            qli.Pricing_Price_Rule_Error_Message__c = null;
                            system.debug('pricingmanager:'+qli.Pricing_Manager__c);
                            if(qli.Pricing_Manager__c != null){
                                system.debug('pricingmanager:'+qli.Pricing_Manager__c);
                                if(qli.Pricing_Program_Type_Nm__c == 'Data Center Xeon® CPU'){
                                    qli.Pricing_Approved_Start_Date_Dt__c = Date.today();
                                    qli.Pricing_Approved_End_Date_Dt__c = Date.today().addMonths(12);
                                    qli.Pricing_Billing_Start_Date_Dt__c = qli.Pricing_Reference_Quote_Line_Nbr__c == null && !accountIdMtdRecordMap.isEmpty() && accountIdMtdRecordMap.containskey(accountId) && accountIdMtdRecordMap.get(accountId) != null ? Date.today().addDays(-Integer.valueOf(accountIdMtdRecordMap.get(accountId))) : Date.today().addDays(-Integer.valueOf(Label.Pricing_NoOfDays_NotPresent_CIMIdMtd));
                                    qli.Pricing_Billing_End_Date_Dt__c = Date.today().addMonths(12);
                                }
                                if(qli.Pricing_Revised_Pricing_Start_Date_dt__c == null && qli.Pricing_Reference_Quote_Line_Nbr__c != null && qlIdqlRecordMap.get(qli.Id).Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c == 'Won'){
                                    qli.Pricing_Revised_Pricing_Start_Date_dt__c = qlIdqlRecordMap.get(qli.Id).Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c != null ? qlIdqlRecordMap.get(qli.Id).Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c : qlIdqlRecordMap.get(qli.Id).Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c;
                                }
                                if(qli.Pricing_New_Change_Request_cb__c==true && qli.Pricing_Reference_Quote_Line_Nbr__c!=null){
                                    qli.Pricing_Approved_End_Date_Dt__c = qlIdqlRecordMap.get(qli.Id).Pricing_Reference_Quote_Line_Nbr__r.Pricing_End_Date_dt__c != qli.Pricing_End_Date_dt__c ? qli.Pricing_End_Date_dt__c : qli.Pricing_End_Date_dt__c; //quoteline pricing end date on the Approved Pricing End date
                                    crQuoteLinesIds.add(qli.Id);
                                }else{
                                    quoteLinesIds.add(qli.Id);
                                }
                                quoteLineListtoUpdate.add(qli);
                            }else{
                                quoteLineIdToMsgMap.put(qli.Id, Label.Pricing_RPM_IsNotValid_Error);
                            }
                        }
                    }
                }
            }

        if(quoteLineListtoUpdate.size() > 0){
            SBQQ.TriggerControl.disable();
            update quoteLineListtoUpdate;
            SBQQ.TriggerControl.enable();
        }

        if(quoteLineIdToMsgMap.size()> 0){
            createLogEntry();
        }

        system.debug('isNotRunByPriceRule:'+isNotRunByPriceRule);
        system.debug('quoteLinesIds:'+quoteLinesIds);
        system.debug('priceRuleIds:'+priceRuleIds);
        if(actionToQuoteLineListMap.containsKey('RPM Create Deal') && quoteLinesIds.size() > 0){
            List<List<SBQQ__Quoteline__c>> qlList = new List<List<SBQQ__QuoteLine__c>>();
            if(isNotRunByPriceRule){
                //To Insert Submitted Payload in to IIM calling method.
                qlList.add(quoteLineListtoUpdate);
                Pricing_QuoteLine_Bulk_CR_Controller.manualInsertIIM(qlList);

                //To insert offer payload in to IIM calling through flow by giving 1 min dealy.
                if(!isChangeRequestQl){
                    List<Id> qlRecords = new List<Id>();
                        for(SBQQ__QuoteLine__c ql : quoteLineListtoUpdate){
                            qlRecords.add(ql.Id);
                        }
                    
                    // Call the Flow with parameters
                    Map<String, Object> params = new Map<String, Object>();
                    params.put('qlids', qlRecords);
                    Flow.Interview.Pricing_ManualApproval_Delay flowInterview = new Flow.Interview.Pricing_ManualApproval_Delay(params);
                    flowInterview.start();
                }

            }else if(actionToQuoteLineListMap.containsKey('RPM Create Deal') && quoteLinesIds.size() > 0 && priceRuleIds.size() > 0 && !isNotRunByPriceRule){
                 system.debug('isNotRunByPriceRule:'+isNotRunByPriceRule);
                quoteLineIdToMsgMap = Pricing_QuoteLine_BulkDealController.insertOutbound(quoteLinesIds, 'Create', qlIdToRuleIdRuleNameMap);
                createLogEntry();
            }
        }
        if(actionToQuoteLineListMap.containsKey('RPM Create Deal') && crQuoteLinesIds.size() > 0){
            quoteLineIdToMsgMap = Pricing_QuoteLine_BulkDealController.insertOutbound(crQuoteLinesIds, 'Update', qlIdToRuleIdRuleNameMap);
            createLogEntry();
        }
    }
    @AuraEnabled
    public static List<String> isOverlapApprovalPriceRule(Id approvalPriceRuleId){ //Map<Id,Pricing_Approval_Price_Rules__c> approvalPriceRuleMap,
        List<String> overLapMsg = new List<String>();
        Boolean isOverlappingproduct = false;
        List<String> overLapApprovalRecNums = new List<String>();
        Map<Id,Set<Id>> ruleIdToprodFloorExtMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> ruleIdToprodFloorPresentMap = new Map<Id,Set<Id>>();
        Map<Id,Pricing_Approval_Price_Rules__c> ruleIdToPresentRecordMap = new Map<Id,Pricing_Approval_Price_Rules__c>();
        try{
            if(approvalPriceRuleId != null){

                //getting present rule record
                for(Pricing_Approval_Price_Rules__c rule : [SELECT Id, Name,Pricing_Quote_Type__c, Pricing_End_Date__c, Pricing_Region_Nm__c, Pricing_Form_Factor__c, Pricing_Server_Deal_Type_Nm__c, Pricing_End_Customer_Country__c, Pricing_Account__c, 
                                                                        Pricing_Maximum_Requested_Unit_Price__c, Pricing_Minimum_Requested_Unit_Price__c, Pricing_Intel_Sales_Rep_Email_Txt__c, Pricing_Intel_Account_Exec_Email_Txt__c, Pricing_Approval_Status__c, 
                                                                        Pricing_Minimum_Quantity__c, Pricing_Maximum_Quantity__c, Pricing_Approval_Rejection_Comments__c, Pricing_PriceRule_Id__c, Pricing_Rule_Name__c, Pricing_Is_Enabled__c, Pricing_Is_Active__c, 
                                                                        Pricing_Rule_Start_Date__c, Pricing_Rule_End_Date__c, Pricing_RPM_Email__c, Pricing_Market_Segment_values_Nm__c FROM Pricing_Approval_Price_Rules__c WHERE Id =: approvalPriceRuleId]){
                                                                        
                                                                            ruleIdToPresentRecordMap.put(rule.Id,rule);

                                                                        }
                
                //throwing error when user click on submit to approval when ql status is other than Draft.
                if(!isCalledFromTrigger && ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Approval_Status__c != 'Draft'){
                    overLapMsg.add(Label.Pricing_ApprovalPriceRule_Submission_Msg);
                }                                                            
                
                //getting present product floor price records for present approvel price rule                                                        
                for(Pricing_Product_Floor_Price__c prodEcap : [select id,Pricing_Product__c,Pricing_Approved_ECAP_Price__c,Pricing_Approval_Price_Rules__r.Name,Pricing_Approval_Price_Rules__r.Pricing_Rule_Name__c,Pricing_Approval_Price_Rules__c 
                                                                from Pricing_Product_Floor_Price__c where Pricing_Approval_Price_Rules__c =: approvalPriceRuleId]){

                                                                    if(ruleIdToprodFloorPresentMap.containsKey(prodEcap.Pricing_Approval_Price_Rules__c)){
                                                                        ruleIdToprodFloorPresentMap.get(prodEcap.Pricing_Approval_Price_Rules__c).add(prodEcap.Pricing_Product__c);
                                                                    }else{
                                                                        ruleIdToprodFloorPresentMap.put(prodEcap.Pricing_Approval_Price_Rules__c, new Set<Id> { prodEcap.Pricing_Product__c});
                                                                    }
                }

                //throwing error when present record is not having product floor price records
                if(ruleIdToprodFloorPresentMap.isEmpty()){
                    overLapMsg.add(Label.Pricing_ApprovalPriceRule_NoProducts_Msg); //= 'Please check Products and do Submit Record';
                }

                if(overLapMsg.isEmpty()){
                    //checking overlapping of rule name , quote type, rule Start and End date ,Min and max Qty,Min and Max requested unit price and end date.
                    List<Pricing_Approval_Price_Rules__c> approvalPriceRuleExtList = [SELECT Id, Name,Pricing_Quote_Type__c, Pricing_End_Date__c, Pricing_Region_Nm__c, Pricing_Form_Factor__c, Pricing_Server_Deal_Type_Nm__c, Pricing_End_Customer_Country__c, Pricing_Account__c, 
                                                                            Pricing_Maximum_Requested_Unit_Price__c, Pricing_Minimum_Requested_Unit_Price__c, Pricing_Intel_Sales_Rep_Email_Txt__c, Pricing_Intel_Account_Exec_Email_Txt__c, Pricing_Approval_Status__c, 
                                                                            Pricing_Minimum_Quantity__c, Pricing_Maximum_Quantity__c, Pricing_Approval_Rejection_Comments__c, Pricing_PriceRule_Id__c, Pricing_Rule_Name__c, Pricing_Is_Enabled__c, Pricing_Is_Active__c, 
                                                                            Pricing_Rule_Start_Date__c, Pricing_Rule_End_Date__c, Pricing_RPM_Email__c, Pricing_Market_Segment_values_Nm__c FROM Pricing_Approval_Price_Rules__c WHERE Pricing_Is_Active__c = true 
                                                                            AND (Pricing_Approval_Status__c = 'Approved' OR Pricing_Approval_Status__c = 'Submitted') 
                                                                            AND Id !=: ruleIdToPresentRecordMap.get(approvalPriceRuleId).Id  
                                                                            AND Pricing_Quote_Type__c = : ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Quote_Type__c //Pricing_Rule_Name__c =: ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Rule_Name__c and
                                                                                AND ((Pricing_Rule_Start_Date__c <= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Rule_Start_Date__c AND Pricing_Rule_End_Date__c >= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Rule_Start_Date__c) OR
                                                                                (Pricing_Rule_Start_Date__c <= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Rule_End_Date__c AND Pricing_Rule_End_Date__c >= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Rule_End_Date__c) OR 
                                                                                (Pricing_Rule_Start_Date__c >= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Rule_Start_Date__c AND Pricing_Rule_End_Date__c <= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Rule_End_Date__c))
                                                                                //Quantity check Min and Max
                                                                                AND ((Pricing_Minimum_Quantity__c =: ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Minimum_Quantity__c AND Pricing_Maximum_Quantity__c = null) OR
                                                                                (Pricing_Minimum_Quantity__c <= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Minimum_Quantity__c AND Pricing_Maximum_Quantity__c >= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Minimum_Quantity__c) OR
                                                                                (Pricing_Minimum_Quantity__c <= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Maximum_Quantity__c AND Pricing_Maximum_Quantity__c >= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Maximum_Quantity__c) OR 
                                                                                (Pricing_Minimum_Quantity__c >= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Minimum_Quantity__c AND Pricing_Maximum_Quantity__c <= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Maximum_Quantity__c))
                                                                                //Requested Unit Price Check Min amd Max
                                                                                AND ((Pricing_Minimum_Requested_Unit_Price__c =: ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Minimum_Requested_Unit_Price__c AND Pricing_Maximum_Requested_Unit_Price__c = null) OR
                                                                                (Pricing_Minimum_Requested_Unit_Price__c <= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Minimum_Requested_Unit_Price__c AND Pricing_Maximum_Requested_Unit_Price__c >= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Minimum_Requested_Unit_Price__c) OR
                                                                                (Pricing_Minimum_Requested_Unit_Price__c <= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Maximum_Requested_Unit_Price__c AND Pricing_Maximum_Requested_Unit_Price__c >= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Maximum_Requested_Unit_Price__c) OR 
                                                                                (Pricing_Minimum_Requested_Unit_Price__c >= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Minimum_Requested_Unit_Price__c AND Pricing_Maximum_Requested_Unit_Price__c <= :ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Maximum_Requested_Unit_Price__c))
                                                                                AND Pricing_End_Date__c =: ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_End_Date__c ];

                    //getting Existing product floor price records for all approval price rules except present approval price rule records product floor records.
                    for(Pricing_Product_Floor_Price__c prodEcap : [select id,Pricing_Product__c,Pricing_Approved_ECAP_Price__c,Pricing_Approval_Price_Rules__r.Name,Pricing_Approval_Price_Rules__r.Pricing_Rule_Name__c,Pricing_Approval_Price_Rules__c
                                                                    from Pricing_Product_Floor_Price__c where Pricing_Approval_Price_Rules__c !=: ruleIdToPresentRecordMap.get(approvalPriceRuleId).Id AND Pricing_Active__c = true]){

                                                                        if(ruleIdToprodFloorExtMap.containsKey(prodEcap.Pricing_Approval_Price_Rules__c)){
                                                                            ruleIdToprodFloorExtMap.get(prodEcap.Pricing_Approval_Price_Rules__c).add(prodEcap.Pricing_Product__c);
                                                                        }else{
                                                                            ruleIdToprodFloorExtMap.put(prodEcap.Pricing_Approval_Price_Rules__c, new Set<Id> { prodEcap.Pricing_Product__c});
                                                                        }
                                                                    }
                    
                    for(Pricing_Approval_Price_Rules__c existingrule : approvalPriceRuleExtList){
                        Boolean isOverlappingRule = false;
                        Boolean isOverlapRegion = false;
                        if(existingrule.Pricing_Region_Nm__c != null && ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Region_Nm__c != null){
                            List<String> existRegionList = existingrule.Pricing_Region_Nm__c.split(';');
                            //List<String> presentRegionList = ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Region_Nm__c.split(';');
                            for(String regionPresent : ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Region_Nm__c.split(';')){

                                if(existRegionList.contains(regionPresent)){
                                    isOverlapRegion = true;
                                    break;
                                }
                            }
                        }else if(existingrule.Pricing_Region_Nm__c == ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Region_Nm__c || existingrule.Pricing_Region_Nm__c == null || ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Region_Nm__c == null){
                                isOverlapRegion = true;
                        }
                        

                        if(isOverlapRegion && ((existingrule.Pricing_Account__c == ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Account__c || existingrule.Pricing_Account__c == null || ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Account__c == null) 
                            && (existingrule.Pricing_End_Customer_Country__c == ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_End_Customer_Country__c || existingrule.Pricing_End_Customer_Country__c == null || ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_End_Customer_Country__c == null)
                            && (existingrule.Pricing_Server_Deal_Type_Nm__c == ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Server_Deal_Type_Nm__c || existingrule.Pricing_Server_Deal_Type_Nm__c == null || ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Server_Deal_Type_Nm__c == null)  
                            && (existingrule.Pricing_Form_Factor__c == ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Form_Factor__c || existingrule.Pricing_Form_Factor__c == null || ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Form_Factor__c == null)
                            && (existingrule.Pricing_Market_Segment_values_Nm__c == ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Market_Segment_values_Nm__c ||existingrule.Pricing_Market_Segment_values_Nm__c == null || ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Market_Segment_values_Nm__c == null)
                            && (existingrule.Pricing_Intel_Account_Exec_Email_Txt__c == ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Intel_Account_Exec_Email_Txt__c || existingrule.Pricing_Intel_Account_Exec_Email_Txt__c == null || ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Intel_Account_Exec_Email_Txt__c == null)
                            && (existingrule.Pricing_Intel_Sales_Rep_Email_Txt__c == ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Intel_Sales_Rep_Email_Txt__c || existingrule.Pricing_Intel_Sales_Rep_Email_Txt__c == null || ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Intel_Sales_Rep_Email_Txt__c == null))){
                                
                                    isOverlappingRule = true;
                                    overLapApprovalRecNums.add(existingrule.Name);
                            }

                        //if there is overlap of approval price rule then checking if there is overlap in products.
                        if(isOverlappingRule && ruleIdToprodFloorPresentMap.size() > 0){
                            for(Id floorId : ruleIdToprodFloorPresentMap.get(approvalPriceRuleId)){

                                if(ruleIdToprodFloorExtMap.size() > 0 && ruleIdToprodFloorExtMap.get(existingrule.Id).contains(floorId)){
                                       isOverlappingproduct = true;
                                        if(!overLapApprovalRecNums.contains(existingrule.Name)){
                                            overLapApprovalRecNums.add(existingrule.Name);
                                    }
                                }
                            }
                        }
                    }

                    
                    if(isOverlappingproduct && overLapApprovalRecNums.size() > 0){
                        overLapMsg = overLapApprovalRecNums;
                    }else{
                        overLapMsg.add('Success');
                    }

                    //updating status to submitted and calling approval records generation method.
                    if(overLapMsg.contains('Success') && !isCalledFromTrigger){
                        if(ruleIdToPresentRecordMap.size() > 0){
                            ruleIdToPresentRecordMap.get(approvalPriceRuleId).Pricing_Approval_Status__c = 'Submitted';
                            update ruleIdToPresentRecordMap.values();
                            Pricing_ApprovalPriceRulesTriggerHandler.approvalRecordsCreation(ruleIdToPresentRecordMap);
                        }
                    }
                }
            }
        }catch(Exception e){
            Pricing_Tender_Utility.logError(e);
        } 
            return overLapMsg;
    }


    public static void createLogEntry(){
        List<Core_Log_Entry__c> logEntryList =  new List<Core_Log_Entry__c>();
        Set<Id> qlIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> qlListToUpdate =  new List<SBQQ__QuoteLine__c>();
        for(Id recId: quoteLineIdToMsgMap.keySet()){
            if(quoteLineIdToMsgMap.get(recId) != 'Success'){
                qlIds.add(recId);
                Core_log_Entry__c logEntry = new Core_Log_Entry__c();
                logEntry.Core_Origin__c = 'Auto RPM Create Deal';
                logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
                logEntry.Core_sObjectId__c = recId;
                logEntry.Core_Severity__c = 'Critical';
                logEntry.Core_Details__c = quoteLineIdToMsgMap.get(recId);
                logEntry.Core_Message__c = Label.Pricing_IQR_SFDC_Environment + ': An error has occurred in Class.Pricing_QuoteLine_AutoApprovalController - sObject Id:' +recId;
                logEntry.Core_Support_Email__c = Label.Pricing_IQR_Support_Email;
                logEntry.Core_Support_Link__c = Label.Pricing_IQR_Support_Link;
                logEntry.Core_When__c = System.now();
                logEntryList.add(logEntry);
            }
        }

        for(SBQQ__QuoteLine__c ql : [Select id,Pricing_Price_Rule_Error_Message__c from SBQQ__QuoteLine__c where Id In: qlIds]){
            if(quoteLineIdToMsgMap.get(ql.Id) != 'Success'){
             ql.Pricing_Price_Rule_Error_Message__c = quoteLineIdToMsgMap.get(ql.Id);
             qlListToUpdate.add(ql);
            }
        }
        if(qlListToUpdate.size() > 0){
            update qlListToUpdate;
        }
        if(!logEntryList.isEmpty()){
            insert logEntryList;
        }
    }
    //Stores inputs from Flow 
    public class FlowInputs {
        @InvocableVariable public String action;
        @InvocableVariable public Decimal ecapPrice;
        @InvocableVariable public Decimal meetCompPrice;
        @InvocableVariable public SBQQ__QuoteLine__c quoteLine;
        @InvocableVariable public String rpmUserEmail;
        @InvocableVariable public String priceRuleId;
        public FlowInputs(){

        }
    }
   
}