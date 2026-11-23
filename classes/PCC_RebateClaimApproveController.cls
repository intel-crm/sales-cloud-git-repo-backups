/************************************************************************************************************************************** 
Class Name :    PCC_RebateClaimApproveController
Test Class :    PCC_RebateClaimApproveControllerTest,PCC_RebateClaimApproveControlReportTest
Description:    Server side controller for core_PCC_RebateClaim_ApproveReject LWC and core_PCC_RebateClaim_ApproveReject_AuraModal Aura
Created By :    Aashna Anand(Unicorn)
***************************************************************************************************************************************/
public without sharing class PCC_RebateClaimApproveController {
    public static final String  APPROVED_TEXT = 'Approved';
    private static List<PCC_Rebate_Claim__c> rcLst;
    
    /******************************************************************************************************************************* 
this method is returning error message and if toast should be seen as boolean wrapped in showErrorWrap to Aura Component
********************************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static showErrorWrap showToast(Id rebateClaimId) {
        showErrorWrap wrpr = new showErrorWrap();
        wrpr.noErrorToast = false;
        wrpr.errorMsg = '';
        boolean userPScheck = ![SELECT Id FROM PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() AND PermissionSet.Name = 'Pricing_Financial_Incentive_Rebate_Analyst'].isEmpty();       
        String query = 'SELECT count() FROM PCC_Rebate_Claim_Line_Item__c WHERE PCC_Rebate_Claim__c = :rebateClaimId AND PCC_Status__c = \'Submitted\'';
        integer hasData = 0;
        if(userPScheck == true) {
            hasData = Database.countQuery(query);
            if(hasData >0 ) {
                wrpr.noErrorToast = true;
            }/*
        else {
        wrpr.errorMsg = Core_CRM_Utility.getCRMLabel('PCC_RebateClaim_ErrorMsg_NoLineItems');
        }*/
        }
        else {
            wrpr.errorMsg = Core_CRM_Utility.getCRMLabel('PCC_RebateClaim_ErrorMsg_NoPS');
        }
        return wrpr;
    }
    /************************************************************************************************************************ 
this method is returning List of Submitted Rebate Claim Line Items
*************************************************************************************************************************/           
    @AuraEnabled(cacheable=true)
    public static List<PCC_Rebate_Claim_Line_Item__c> getRebateClaimLineItems(Id rebateClaimId) {
        
        return [SELECT Id, PCC_Opportunity__c, PCC_Opportunity__r.Name, PCC_Status__c, PCC_Partner_Reference_Id__c, PCC_Quote_Line_Number__c,
                PCC_Quote_Line_Number__r.Pricing_Quote_Line_Number__c, PCC_Product__c, PCC_Product__r.Name, PCC_Quantity__c, PCC_Invoice_Date__c, PCC_Invoice__c,PCC_Approved_Pricing_Start_Date__c,PCC_Approved_Pricing_End_Date__c,
                PCC_Approved_Quote_Line_Quantity__c,PCC_OEM_Name__c, PCC_Country__c,PCC_Claimed_Rebate_Amount__c, PCC_Approved_Rebate_Amount__c, PCC_Rejection_Code__c, PCC_Rejection_Comments__c
                FROM PCC_Rebate_Claim_Line_Item__c WHERE PCC_Rebate_Claim__c = :rebateClaimId AND PCC_Status__c = 'Submitted'];
    }
    /************************************************************************************************************************ 
This method is used for updating rebate claim line item records List coming from LWC.
*************************************************************************************************************************/    
    @AuraEnabled
    public static boolean updateClaimLineItemsDataList(String rcliDataString, Id rebateClaimId, integer submittedRCLI) {
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        boolean savedData = false;
        try {
            List<PCC_Rebate_Claim_Line_Item__c> rebateClaimLIList = (List<PCC_Rebate_Claim_Line_Item__c>)System.JSON.deserializeStrict(rcliDataString, List<PCC_Rebate_Claim_Line_Item__c>.Class);
            if(rebateClaimLIList.size()>0) {
                Database.update(rebateClaimLIList,true);
                updateQtyOn6QPS(rebateClaimLIList);
                //Test_PCC_UpdateQtyOn6QPS.updateQtyOn6QPS(rebateClaimLIList);
                if(submittedRCLI == 0) {
                    updateRebateClaims(rebateClaimId,submittedRCLI);
                    
                }
                savedData = true;
                
            }
            return savedData;
        } 
        catch (Exception e) {
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c = e.getMessage(), Core_Origin__c='PCC_RebateClaimApproveController.updateRebateClaims', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
            throw new AuraHandledException(e.getMessage());
        }
        finally { 
            insert logEntries;
        } 
    }
    public static void updateRebateClaims(Id rebateClaimId, integer submittedRCLI) {
        List<PCC_Rebate_Claim__c> rebateClaim = [select id, PCC_Approval_Date__c, PCC_Approved_By__c, PCC_Claim_Status__c from PCC_Rebate_Claim__c where Id =: rebateClaimId];
        List<PCC_Rebate_Claim_Line_Item__c> rebateClaimLIList = [SELECT Id,PCC_Status__c, PCC_Opportunity__r.Owner.Email FROM PCC_Rebate_Claim_Line_Item__c WHERE PCC_Rebate_Claim__c =: rebateClaimId]; 
        List<String> ccEmailOptyOwner= new List<String>();       
        for(PCC_Rebate_Claim_Line_Item__c rcli :rebateClaimLIList) {           
            // generate CC email id for all the Opty Owners
            ccEmailOptyOwner.add(rcli.PCC_Opportunity__r.Owner.Email);
            
            if(rcli.PCC_Status__c == APPROVED_TEXT) {
                rebateClaim[0].PCC_Claim_Status__c  ='Claim Approved - Payment Pending';
                rebateClaim[0].PCC_Approval_Date__c = system.today();
                rebateClaim[0].PCC_Approved_By__c   = UserInfo.getUserId();             
                break;
            }
            else {
                rebateClaim[0].PCC_Claim_Status__c = 'Claim Rejected';
            }
        }
        update rebateClaim[0];
        If(rebateClaim[0].PCC_Claim_Status__c == 'Claim Approved - Payment Pending' || rebateClaim[0].PCC_Claim_Status__c == 'Claim Rejected') {
            Approval.UnlockResult[] urList = Approval.unlock(rebateClaim, false);
        }		
        // added as part of TWC4767-2411
        PCC_Rebate_Claim__c rebateClaimStatus = [select id,PCC_Submitted_By__r.Email, PCC_Claim_Status__c, PCC_Partner__r.Core_Account_Owner_Email__c from PCC_Rebate_Claim__c where Id =: rebateClaimId LIMIT 1];
        List<String> toEmailAddress = New List<String>();
        toEmailAddress.add(rebateClaimStatus.PCC_Submitted_By__r.Email);
        if( rebateClaimStatus.PCC_Claim_Status__c == 'Claim Rejected' || rebateClaimStatus.PCC_Claim_Status__c  =='Claim Approved - Payment Pending') {
            PCC_RebateClaimEmailNotification.SendEmail('PCC_RebateClaim_ApprovedNotification', toEmailAddress ,  ccEmailOptyOwner,  rebateClaimId);
        }
    }
    /************************************************************************************************************************ 
This method is used for Approved QTY Validation on rebate claim line item records.
added by Himanshu as part of TWC3123-6335
*************************************************************************************************************************/      
    @AuraEnabled
    public static rebateQuoteLineError get6QPSData(String rebateAppQtyQutlineNostr, String rebateRejQtyQutlineNostr) {
        
        Map<Id, double> rebateAppqtyQutlineNo  = (Map<Id, double>) json.deserialize(rebateAppQtyQutlineNostr, Map<Id, double>.class);
        Map<Id, double> rebateRejqtyQutlineNo  = (Map<Id, double>) json.deserialize(rebateRejQtyQutlineNostr, Map<Id, double>.class);
        
        Map<Id, Double> sumSubmitAppclaimQty = new Map<Id, Double>();
        Map<Id, Double> sumSubmitedclaimQty = new Map<Id, Double>();
        Map<Id, Double> rebateQtyOLI = new Map<Id, Double>();
        Map<Id, Double> rebateRejQtyOLI = new Map<Id, Double>();
        Map<Id, Double> scheduledClaimQtyMap = new Map<Id, Double>();
        Double ApprovedClaimQuantity =0.0;
        Double submittedClaimQtyNbr =0.0;
        Double scheduledClaimQuantity =0.0;
        Map<Id, String> mapOfOppLineItemQuoteLine = new Map<Id, String>();
        
        //System.debug(rebateAppqtyQutlineNo.keySet());
        //System.debug(rebateRejqtyQutlineNo);
        
        for(OpportunityLineItem oppLineitem : [select id,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.Pricing_Quote_Line_Number__c from OpportunityLineItem where SBQQ__QuoteLine__c in :rebateAppqtyQutlineNo.keySet()]) {
            mapOfOppLineItemQuoteLine.put(oppLineitem.id, oppLineitem.SBQQ__QuoteLine__r.Pricing_Quote_Line_Number__c);
            if(rebateAppqtyQutlineNo.containsKey(oppLineitem.SBQQ__QuoteLine__c)) {
                rebateQtyOLI.put(oppLineitem.id,rebateAppqtyQutlineNo.get(oppLineitem.SBQQ__QuoteLine__c));
            }
            
            if(rebateRejqtyQutlineNo.containsKey(oppLineitem.SBQQ__QuoteLine__c)) {
                rebateRejQtyOLI.put(oppLineitem.id,rebateRejqtyQutlineNo.get(oppLineitem.SBQQ__QuoteLine__c));
            }
            else {
                rebateRejQtyOLI.put(oppLineitem.id,0.0);                
            }
        }
        
        for(Core_Opp_FC_Prod_Schedule__c oppProdSch : [Select id,Core_FC_Submitted_Claim_Quantity_nbr__c,Core_FC_Approved_Claim_Quantity_nbr__c,Core_Opp_FC_Quantity__c,Core_Opp_Line_Item_RecordID__c,Core_FC_Opportunity_Product__r.Quantity,Core_Opp_FC_Product__c from Core_Opp_FC_Prod_Schedule__c where Core_Opp_Line_Item_RecordID__c in :mapOfOppLineItemQuoteLine.keySet()]) {
            Double values=0.0; 
            ApprovedClaimQuantity = oppProdSch.Core_FC_Approved_Claim_Quantity_nbr__c == null ? 0:oppProdSch.Core_FC_Approved_Claim_Quantity_nbr__c;
            submittedClaimQtyNbr =  oppProdSch.Core_FC_Submitted_Claim_Quantity_nbr__c == null ? 0:oppProdSch.Core_FC_Submitted_Claim_Quantity_nbr__c;
            scheduledClaimQuantity =  oppProdSch.Core_Opp_FC_Quantity__c == null ? 0:oppProdSch.Core_Opp_FC_Quantity__c;
            values= submittedClaimQtyNbr + ApprovedClaimQuantity;
            if(sumSubmitAppclaimQty.containsKey(oppProdSch.Core_Opp_Line_Item_RecordID__c)) {
                values= values+ sumSubmitAppclaimQty.get(oppProdSch.Core_Opp_Line_Item_RecordID__c);
                sumSubmitAppclaimQty.put(oppProdSch.Core_Opp_Line_Item_RecordID__c,values);
            }
            else {
                sumSubmitAppclaimQty.put(oppProdSch.Core_Opp_Line_Item_RecordID__c,values);
            }
            if(scheduledClaimQtyMap.containsKey(oppProdSch.Core_Opp_Line_Item_RecordID__c)) {
                Double sumScheQty=0.0; 
                sumScheQty = scheduledClaimQuantity + scheduledClaimQtyMap.get(oppProdSch.Core_Opp_Line_Item_RecordID__c);
                scheduledClaimQtyMap.put(oppProdSch.Core_Opp_Line_Item_RecordID__c,sumScheQty);
            }
            else {
                scheduledClaimQtyMap.put(oppProdSch.Core_Opp_Line_Item_RecordID__c,scheduledClaimQuantity);
            }
            if(sumSubmitedclaimQty.containsKey(oppProdSch.Core_Opp_Line_Item_RecordID__c)) {
                Double sumSubQty=0.0; 
                sumSubQty = submittedClaimQtyNbr + sumSubmitedclaimQty.get(oppProdSch.Core_Opp_Line_Item_RecordID__c);
                sumSubmitedclaimQty.put(oppProdSch.Core_Opp_Line_Item_RecordID__c,sumSubQty);
            }
            else {
                sumSubmitedclaimQty.put(oppProdSch.Core_Opp_Line_Item_RecordID__c,submittedClaimQtyNbr);
            }
            
        }
        //system.debug(sumSubmitAppclaimQty);
        rebateQuoteLineError errwrp = new rebateQuoteLineError();
        errwrp.errorMsgWrpallqty='';
        errwrp.errorMsgWrpsubQty='';
        for(Id oppLineItemId: sumSubmitAppclaimQty.keySet()) {
            Double qty=0.0;
            Double subqty=0.0;
            Boolean scherrorflag = false;
           /* qty = sumSubmitAppclaimQty.get(oppLineItemId) + (rebateQtyOLI.get(oppLineItemId) - rebateRejQtyOLI.get(oppLineItemId));            
            if(qty > scheduledClaimQtyMap.get(oppLineItemId) ){
                errwrp.errorMsgWrpallqty = errwrp.errorMsgWrpallqty + mapOfOppLineItemQuoteLine.get(oppLineItemId);
                scherrorflag = true;
            }*/
            //if(scherrorflag == false){
                subqty = sumSubmitedclaimQty.get(oppLineItemId)-rebateRejQtyOLI.get(oppLineItemId);
                if( rebateQtyOLI.get(oppLineItemId) > subqty  ) {
                    errwrp.errorMsgWrpsubQty = errwrp.errorMsgWrpsubQty + mapOfOppLineItemQuoteLine.get(oppLineItemId);
                }//}
        }
        //system.debug('quoteLineNbrError'+errwrp);
        return errwrp;
        
    }
    
/**************************************************************************************************************************************************
TWC3123-6334 - Devashish[Unicorn] - This method updates Submitted/Approved quantities on associated 6QPS records based on RCLI submission/approval/rejection
**************************************************************************************************************************************************/
    public static void updateQtyOn6QPS(List<PCC_Rebate_Claim_Line_Item__c> rebateClaimLIList) {
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
        try {
            Map<Id, Integer> OLIWithQtrCnt = new Map<Id, Integer>();
            Map<Id, Map<String, Decimal>> QLwithQtrQty = new Map<Id, Map<String, Decimal>>();
            Map<String, Decimal> QtrWithQty = new Map<String, Decimal>();
            Map<Id, Map<String, Decimal>> QLwithQtrQtyMap = new Map<Id, Map<String, Decimal>>();
            Map<Id, Map<String, Decimal>> QLwithQtrwithRemainingApprovedQty = new Map<Id, Map<String, Decimal>>();
            Map<String, Decimal> QtrwithRemainingApprovedQty = new Map<String, Decimal>();
            Map<Id, List<rebateClaimItemQuoteLineDetails>> QLWrp = new Map<Id, List<rebateClaimItemQuoteLineDetails>>();
            rebateClaimItemQuoteLineDetails qlWrapper = new rebateClaimItemQuoteLineDetails();
            for (PCC_Rebate_Claim_Line_Item__c rcl : rebateClaimLIList) {
                String Qrtr = Core_FC_ProductSchedule_Ctrl.getQuarter(rcl.PCC_Invoice_Date__c);
                qlWrapper = new rebateClaimItemQuoteLineDetails();
                qlWrapper.RCLIStatus = rcl.PCC_Status__c;
                qlWrapper.RCLIQty = rcl.PCC_Quantity__c;
                qlWrapper.RCLIQtr = Qrtr;
                qlWrapper.RCLIQL = rcl.PCC_Quote_Line_Number__c;
                if (!QLWrp.containsKey(rcl.PCC_Quote_Line_Number__c)) {
                    QLWrp.put(rcl.PCC_Quote_Line_Number__c, new List<rebateClaimItemQuoteLineDetails>());
                }
                QLWrp.get(rcl.PCC_Quote_Line_Number__c).add(qlWrapper);
            }
            List<Core_Opp_FC_Prod_Schedule__c> fcList = [select id, name, Core_FC_Opportunity_Product__c,Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__r.Pricing_Approved_Start_Date_Dt__c, Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__r.Pricing_Approved_End_Date_Dt__c, Core_Opp_FC_Quarter__c, Core_Opp_FC_Quantity__c, Core_FC_Approved_Claim_Quantity_nbr__c, Core_FC_Submitted_Claim_Quantity_nbr__c, Core_FC_Remaining_Claim_Quantity_nbr__c from Core_Opp_FC_Prod_Schedule__c where Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c IN : QLWrp.keySet()];
            for (Core_Opp_FC_Prod_Schedule__c fcRecord : fcList) {
                if (!OLIWithQtrCnt.containsKey(fcRecord.Core_FC_Opportunity_Product__c)) {
                    OLIWithQtrCnt.put(fcRecord.Core_FC_Opportunity_Product__c, 0);
                }
                Integer qtrSizeForFCRecord = OLIWithQtrCnt.get(fcRecord.Core_FC_Opportunity_Product__c);
                qtrSizeForFCRecord++;
                OLIWithQtrCnt.put(fcRecord.Core_FC_Opportunity_Product__c, qtrSizeForFCRecord);
                fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c = fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c == null? 0: fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c;
                fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c = fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c == null ? 0 : fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c;
                
                if (!QLwithQtrQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                    QLwithQtrQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,new Map<String, Decimal>());
                }
                QtrWithQty = QLwithQtrQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                if (!QtrWithQty.containsKey(fcRecord.Core_Opp_FC_Quarter__c)) {
                    QtrWithQty.put(fcRecord.Core_Opp_FC_Quarter__c, 0);
                }
                Decimal currentQty = QtrWithQty.get(fcRecord.Core_Opp_FC_Quarter__c);
                QtrWithQty.put(fcRecord.Core_Opp_FC_Quarter__c,currentQty + fcRecord.Core_Opp_FC_Quantity__c);
                QLwithQtrQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, QtrWithQty);
                
                if (!QLwithQtrwithRemainingApprovedQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                    QLwithQtrwithRemainingApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, new Map<String, Decimal>());
                }
                QtrwithRemainingApprovedQty = QLwithQtrwithRemainingApprovedQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                if (!QtrwithRemainingApprovedQty.containsKey(fcRecord.Core_Opp_FC_Quarter__c)) {
                    QtrwithRemainingApprovedQty.put(fcRecord.Core_Opp_FC_Quarter__c, 0);
                }
                Decimal currentQty4 = QtrwithRemainingApprovedQty.get(fcRecord.Core_Opp_FC_Quarter__c);
                QtrwithRemainingApprovedQty.put(fcRecord.Core_Opp_FC_Quarter__c, currentQty4 + (fcRecord.Core_Opp_FC_Quantity__c - fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c));
                QLwithQtrwithRemainingApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, QtrwithRemainingApprovedQty);
            } 
            
            for (Core_Opp_FC_Prod_Schedule__c fcRecord : fcList) {
                if (QLWrp.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                    for (List<rebateClaimItemQuoteLineDetails> rcliDetailList : QLWrp.values()) {
                        for (rebateClaimItemQuoteLineDetails rcliDetail : rcliDetailList) {
                            if (fcRecord.Core_Opp_FC_Quarter__c == rcliDetail.RCLIQtr && fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c == rcliDetail.RCLIQL) {
                                String approvedQtyQtr;
                                Date qlStartDate = fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__r.Pricing_Approved_Start_Date_Dt__c;
                                Date qlEndDate = fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__r.Pricing_Approved_End_Date_Dt__c;
                                List<String> qtrsBetweenQLStartDtEndDt = getQuartersBetweenDates(qlStartDate, qlEndDate);
                                if (rcliDetail.RCLIStatus == 'Approved') {
                                    Decimal previousSchedQty = fcRecord.Core_Opp_FC_Quantity__c;
                                    Decimal oldApprovedQty = fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c;
                                    system.debug('Previous schd qty AND oldApprovedQty--'+previousSchedQty+' AND '+oldApprovedQty);
                                    system.debug('Qty from rebate claim--'+rcliDetail.RCLIQty);
                                    fcRecord.Core_Opp_FC_Quantity__c = fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c + (Integer)rcliDetail.RCLIQty;
                                    approvedQtyQtr = fcRecord.Core_Opp_FC_Quarter__c;
                                    fcRecord.Core_FC_Approved_Claim_Quantity_nbr__c += rcliDetail.RCLIQty;
                                    fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c -= rcliDetail.RCLIQty;
                                    Decimal newApprovedQty = (Integer)rcliDetail.RCLIQty;
                                    Decimal additionalApprovedQty = 0;
                                    //system.debug('New approved qty is--'+newApprovedQty);
                                    //system.debug('Old approved qty is--'+oldApprovedQty);
                                    
//////////////////////////////block 1
                                    if (newApprovedQty == previousSchedQty) {
                                        system.debug('BLOCK 1, both are equal');
                                        Map<String, Decimal> PreviousQtrMap1 = new Map<String, Decimal>();
                                        Map<String, Decimal> FutureQtrMap1 = new Map<String, Decimal>();
                                        Map<String, Decimal> FinalQtrQtyMap1 = new Map<String, Decimal>();	//to store all the final numbers related to futureQtr map and PreviousQtr map
                                        
                                        String currentQuarter = getQuarterFromDate(Date.today());	//get current quarter we are in
                                        Integer qtrSize = OLIWithQtrCnt.get(fcRecord.Core_FC_Opportunity_Product__c);	//get total number of 6QPS quarters related to current Opportunity product
                                        
                                        List<String> previousQuarters = getPreviousQuarters(currentQuarter, qtrSize);  //get Previous quarters based on today
                                        List<String> futureQuarters = getFutureQuarters(currentQuarter, qtrSize);	//get Future quarters based on today
                                        futureQuarters.add(currentQuarter);	//add current quarter as well in Future quarters
                                        
                                        
                                        //Extract Quote Line with all related 6QPS quarters and their quantity
                                        Map<String, Decimal> QtrWithQtyMap = new Map<String, Decimal>();
                                        if (QLwithQtrQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                                            QtrWithQtyMap = QLwithQtrQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                                        }
                                        
                                        //Variable to check how much additional approved qty needs to be fulfilled from existing quantities in 6QPS, either from past or future quarters
                                        Decimal remainingQtyToFulfill = oldApprovedQty<>0 ? newApprovedQty : 0;
                                        
                                        //Prepare map of previous quarters with qtr and existing qty, based on QuoteLine approved start date and end date
                                        for (String quarter : previousQuarters) {
                                            if (qtrsBetweenQLStartDtEndDt.contains(quarter) && quarter != approvedQtyQtr) {
                                                Decimal qty = QtrWithQtyMap.get(quarter);
                                                PreviousQtrMap1.put(quarter, qty);
                                                FinalQtrQtyMap1.put(quarter, PreviousQtrMap1.get(quarter));
                                            }
                                        }
                                        
                                        //variable to store any unapproved qty from past quarters, later to be distributed evenly in future qtrs
                                        Decimal additionalToBeAdjustedInFutureFromPast = 0;
                                        
                                        if (remainingQtyToFulfill > 0) {
                                            //system.debug('Inside adjusting remaining qty from past');
                                            for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                                for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                    if (PreviousQtrMap1.containsKey(quarter) && PreviousQtrMap1.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                        //system.debug('Qtry with prev qtr--'+PreviousQtrMap1);
                                                        //system.debug('Quarter to be updated--'+quarter);
                                                        Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                        //system.debug('available qty iss--'+availableQty);
                                                        //system.debug('qty to be consumed from past qtr--'+remainingQtyToFulfill);
                                                        if (availableQty > 0 && remainingQtyToFulfill >0) {
                                                            if (availableQty <= remainingQtyToFulfill) {
                                                                //system.debug('Consume full prv qtrs');
                                                                //If consumed fully, nothing left in previous qtr, so making it 0
                                                                if(PreviousQtrMap1.get(quarter) == availableQty) {
                                                                    PreviousQtrMap1.put(quarter, 0);
                                                                    //system.debug('inside if making FutureQtrMap1 as 0--'+QtrwithRemainingApprovedQty);
                                                                }
                                                                else {
                                                                    //This condition checks if our existing sch and remaining approved is not same, then subtract availableQty from existing scheduled qty and update new scheduled qty in that qtr
                                                                    PreviousQtrMap1.put(quarter,PreviousQtrMap1.get(quarter) - availableQty);
                                                                    //system.debug('inside else making FutureQtrMap2 as approved - available qty --'+QtrwithRemainingApprovedQty);
                                                                }
                                                                remainingQtyToFulfill -= availableQty;
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ PreviousQtrMap1.get(quarter));
                                                                //system.debug('remainingQtyToFulfill after update--'+remainingQtyToFulfill);
                                                                QtrwithRemainingApprovedQty.put(quarter,0);
                                                            } 
                                                            else {
                                                                //system.debug('Consume partially prv qtrs');
                                                                PreviousQtrMap1.put(quarter, PreviousQtrMap1.get(quarter) - remainingQtyToFulfill);
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ PreviousQtrMap1.get(quarter));
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)- remainingQtyToFulfill);
                                                                additionalToBeAdjustedInFutureFromPast = PreviousQtrMap1.get(quarter);
                                                                //Since it consumed partially, meaning all remainingQtyToFulfill was fulfilled, so making it 0
                                                                remainingQtyToFulfill = 0;
                                                            }
                                                        }
                                                        FinalQtrQtyMap1.put(quarter, PreviousQtrMap1.get(quarter));
                                                    }
                                                }
                                            }
                                        }
                                        
                                        //populate additionalToBeAdjustedInFutureFromPast with unapproved qty and set that qtr's qty to 0
                                        //QLwithQtrwithRemainingApprovedQty - this map contains any unapproved qty for each qtr
                                        //ex. if 30 is scheduled qty and 25 is approved, then this map will store '5' unapproved qty
                                        /*for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                            for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                if (PreviousQtrMap1.containsKey(quarter) && PreviousQtrMap1.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                    system.debug('Qtr with remaining approved qty mapppp---'+qtrWithRemainingApprovedQtyMap);
                                                    system.debug('Qtry with prev qtr--'+PreviousQtrMap1);
                                                    system.debug('Quarter to be updated--'+quarter);
                                                    Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter);
                                                    system.debug('available qty iss--'+availableQty);
                                                    if (availableQty > 0) {
                                                        system.debug('Updated qtr--'+quarter+'--which has existing additional qty--'+ availableQty);
                                                        system.debug('PreviousQtrMap1 before updating values--'+PreviousQtrMap1);
                                                        additionalToBeAdjustedInFutureFromPast += availableQty;
                                                        PreviousQtrMap1.put(quarter, PreviousQtrMap1.get(quarter)-availableQty);
                                                        system.debug('PreviousQtrMap1 after updating values--'+PreviousQtrMap1);
                                                        //If we are updating previous qtr to 0, then nothing is left to be approved, so setting QtrwithRemainingApprovedQty map qty as 0 too.
                                                        QtrwithRemainingApprovedQty.put(quarter,0);
                                                        system.debug('block 1 QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                    }
                                                    FinalQtrQtyMap1.put(quarter, PreviousQtrMap1.get(quarter));
                                                }
                                            }
                                        }*/
                                        
                                        system.debug('Prev Qrt1 Map is after making 0--'+PreviousQtrMap1);
                                        
                                        //prepare map of future quarters with qtr and existing qty, based on QL approved start date and end date
                                        //6QPS may have 10 quarters but we will only consider the quarters between QuoteLine start date and end date
                                        for (String quarter : futureQuarters) {
                                            if (qtrsBetweenQLStartDtEndDt.contains(quarter) && quarter != approvedQtyQtr) {
                                                Decimal qty = QtrWithQtyMap.get(quarter);
                                                FutureQtrMap1.put(quarter, qty);
                                                FinalQtrQtyMap1.put(quarter, FutureQtrMap1.get(quarter));
                                            }
                                        }
                                        
                                        //system.debug('future Qrt1 Map is--'+FutureQtrMap1);
                                        //system.debug('Final Qrt1 Map is--'+FinalQtrQtyMap1);
                                        
                                        if (remainingQtyToFulfill > 0) {
                                            //system.debug('Inside adjusting remaining qty from future');
                                            for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                                for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                    if (FutureQtrMap1.containsKey(quarter) && FutureQtrMap1.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                        //system.debug('Qtry with future qtr--'+FutureQtrMap1);
                                                        //system.debug('Quarter to be updated--'+quarter);
                                                        Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                        //system.debug('available qty iss--'+availableQty);
                                                        //system.debug('qty to be consumed--'+remainingQtyToFulfill);
                                                        if (availableQty > 0 && remainingQtyToFulfill >0) {
                                                            if (availableQty <= remainingQtyToFulfill) {
                                                                //system.debug('Consume full prv qtrs');
                                                                //If consumed fully, nothing left in this future qtr, so making it 0
                                                                //This condition checks if our existing sch and remaining approved is same, then make existing scheduled to 0
                                                                if(FutureQtrMap1.get(quarter) == availableQty) {
                                                                    FutureQtrMap1.put(quarter, 0);
                                                                    //system.debug('inside if making FutureQtrMap1 as 0--'+QtrwithRemainingApprovedQty);
                                                                }
                                                                else {
                                                                    //This condition checks if our existing sch and remaining approved is not same, then subtract availableQty from existing scheduled qty and update new scheduled qty in that qtr
                                                                    FutureQtrMap1.put(quarter,FutureQtrMap1.get(quarter) - availableQty);
                                                                    //system.debug('inside else making FutureQtrMap2 as approved - available qty --'+QtrwithRemainingApprovedQty);
                                                                }
                                                                QtrwithRemainingApprovedQty.put(quarter,0);
                                                                //subtracting whatever we adjusted from future, and calculating new remainingQtyToFulfill
                                                                remainingQtyToFulfill -= availableQty;
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ FutureQtrMap1.get(quarter));
                                                                //system.debug('remainingQtyToFulfill after update--'+remainingQtyToFulfill);
                                                            } 
                                                            else {
                                                                //system.debug('Consume partially qtrs');
                                                                FutureQtrMap1.put(quarter, FutureQtrMap1.get(quarter) - remainingQtyToFulfill);
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ FutureQtrMap1.get(quarter));
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)-remainingQtyToFulfill);
                                                                //system.debug('block 1 else QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                                //Since it consumed partially, meaning all remainingQtyToFulfill was fulfilled, so making it 0
                                                                remainingQtyToFulfill = 0;
                                                            }
                                                        }
                                                        FinalQtrQtyMap1.put(quarter, FutureQtrMap1.get(quarter));
                                                    }
                                                }
                                            }
                                        }
                                        //get total no of qtrs in futuremap, to split the qty to be distributed, evenly
                                        Integer numberOfFutureQuarters = FutureQtrMap1.size();
                                        //system.debug('Future Qtr numbers--'+numberOfFutureQuarters);
                                        
                                        //If there are any future qtrs and we have some qty to be adjusted in future
                                        if (numberOfFutureQuarters > 0 && additionalToBeAdjustedInFutureFromPast > 0) {
                                            // Calculate the quantity to add to each future quarter, then round it off in another variable and add that to every future qtr
                                            Decimal qtyPerFutureQuarter = additionalToBeAdjustedInFutureFromPast / numberOfFutureQuarters;
                                            Double qtyPerFutureQuarterRdOffDbl = Math.Floor(qtyPerFutureQuarter);
                                            Integer qtyPerFutureQuarterRdOff = (Integer)qtyPerFutureQuarterRdOffDbl;
											//system.debug('Qty to be divided per qtr--'+qtyPerFutureQuarter);
											//system.debug('Rounded qty--'+qtyPerFutureQuarterRdOff);
                                            //system.debug('qtyPerFutureQuarterRdOff--floorValue'+qtyPerFutureQuarterRdOffDbl +'  '+qtyPerFutureQuarterRdOff);
                                            integer counter =0;
                                            for (String quarter : FutureQtrMap1.keySet()) {
                                                counter++;
                                                if (qtyPerFutureQuarterRdOff <= additionalToBeAdjustedInFutureFromPast) {
                                                    Decimal existingQty = FutureQtrMap1.get(quarter);
                                                    FutureQtrMap1.put(quarter, existingQty + qtyPerFutureQuarterRdOff);
                                                    //system.debug('updated Future Quarter: '+quarter+' with quantity: '+(existingQty + qtyPerFutureQuarterRdOff));
                                                    QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+qtyPerFutureQuarterRdOff);
                                                    //system.debug('QtrwithRemainingApprovedQty block1'+QtrwithRemainingApprovedQty);
                                                    additionalToBeAdjustedInFutureFromPast -= qtyPerFutureQuarterRdOff;
                                                    //system.debug('Additional qty in qtr--'+additionalToBeAdjustedInFutureFromPast);
                                                } 
                                                /*else if (additionalToBeAdjustedInFutureFromPast <= qtyPerFutureQuarterRdOff) {
                                                    //This else block adds any decimal qty left after rounding off qty to be distributed.
                                                    //ex. if we have to divide 10 between 3 qtrs, it comes as 3.33 to be added in each qtr. After rounding off, it will add 3 each to all 3 qtrs. Remaining 1 which was decimal, will be adjusted from here
                                                    system.debug('Inside last divide');
                                                    FutureQtrMap1.put(quarter, FutureQtrMap1.get(quarter) + additionalToBeAdjustedInFutureFromPast);
                                                    QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+additionalToBeAdjustedInFutureFromPast);
                                                    system.debug('QtrwithRemainingApprovedQty block 1'+QtrwithRemainingApprovedQty);
                                                }*/
                                                if (additionalToBeAdjustedInFutureFromPast <> 0 && numberOfFutureQuarters == counter) {
                                                    //This else block adds any decimal qty left after rounding off qty to be distributed.
                                                    //ex. if we have to divide 1 between 3 qtrs, it comes as 0.33 to be added in each qtr. After rounding off, it will add 0 each to all 3 qtrs. Remaining 1 which was decimal, will be adjusted from here
                                                    //system.debug('Inside last divide');
                                                    FutureQtrMap1.put(quarter, FutureQtrMap1.get(quarter) + additionalToBeAdjustedInFutureFromPast);
                                                    QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+additionalToBeAdjustedInFutureFromPast);
                                                    additionalToBeAdjustedInFutureFromPast = 0;
                                                    //system.debug('QtrwithRemainingApprovedQty block 1'+QtrwithRemainingApprovedQty);
                                                }
                                                FinalQtrQtyMap1.put(quarter, FutureQtrMap1.get(quarter));
                                            }
                                        } 
                                        else {
                                            //If there are no future qtrs, we adjust everything in last qtr based on QL approved End Date
                                            //System.debug('No future quarters available to distribute remaining quantity.');
                                            String qtr = getQuarterFromDate(qlEndDate);
                                            FinalQtrQtyMap1.put(qtr, QtrWithQtyMap.get(qtr)+additionalToBeAdjustedInFutureFromPast);
                                            QtrwithRemainingApprovedQty.put(qtr,QtrwithRemainingApprovedQty.get(qtr)+additionalToBeAdjustedInFutureFromPast);
                                        }
                                        //system.debug('retention before QtrwithRemainingApprovedQty'+QtrwithRemainingApprovedQty);
                                        QtrwithRemainingApprovedQty.put(approvedQtyQtr,0);
                                        //system.debug('retention after QtrwithRemainingApprovedQty'+QtrwithRemainingApprovedQty);
                                        //system.debug('retention before QLwithQtrwithRemainingApprovedQty'+QLwithQtrwithRemainingApprovedQty);
                                        QLwithQtrwithRemainingApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrwithRemainingApprovedQty);
                                        //system.debug('retention after QLwithQtrwithRemainingApprovedQty'+QLwithQtrwithRemainingApprovedQty);
                                        //system.debug('FinalQtrQtyMap1 at last--'+FinalQtrQtyMap1);
                                        //system.debug('qtr with qty map before update--'+QtrWithQtyMap);
                                        
                                        //updating local maps here, to be used if we are approving multiple line items in one go
                                        QtrWithQtyMap = updateLocalMaps(QtrWithQtyMap,PreviousQtrMap1,FutureQtrMap1,approvedQtyQtr,newApprovedQty,oldApprovedQty);
                                        
                                        //system.debug('qtr with qty map after update--'+QtrWithQtyMap);
                                        //system.debug('QLwithQtrQty before update--'+QLwithQtrQty);
                                        QLwithQtrQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrWithQtyMap);
                                        //system.debug('QLwithQtrQty after update--'+QLwithQtrQty);
                                        QLwithQtrQtyMap.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, FinalQtrQtyMap1);
                                        //system.debug('QLwithQtrQtyMap 1 is--'+QLwithQtrQtyMap);
                                    }
                                    
/////////////////////////////block 2
                                    if (newApprovedQty > previousSchedQty) {
                                        system.debug('BLOCK 2, new approved Qty is greater than prev schedule Qty');
                                        Map<String, Decimal> PreviousQtrMap2 = new Map<String, Decimal>();
                                        Map<String, Decimal> FutureQtrMap2 = new Map<String, Decimal>();
                                        Map<String, Decimal> FinalQtrQtyMap2 = new Map<String, Decimal>();	//to store all the final numbers related to futureQtr map and PreviousQtr map
                                        //system.debug('new app qty--'+newApprovedQty);
                                        //system.debug('old app qty--'+oldApprovedQty);
                                        //system.debug('prev sch qty--'+previousSchedQty);
                                        additionalApprovedQty = (newApprovedQty + oldApprovedQty) - previousSchedQty;
                                        //system.debug('additional qty--'+additionalApprovedQty);
                                        String currentQuarter = getQuarterFromDate(Date.today());	//get current quarter we are in
                                        Integer qtrSize = OLIWithQtrCnt.get(fcRecord.Core_FC_Opportunity_Product__c);
                                        List<String> previousQuarters = getPreviousQuarters(currentQuarter, qtrSize);	//get Previous quarters based on today
                                        List<String> futureQuarters = getFutureQuarters(currentQuarter, qtrSize);	//get Future quarters based on today
                                        futureQuarters.add(currentQuarter);	//add current quarter as well in Future quarters
                                        
                                        //Extract Quote Line with all related 6QPS quarters and their quantity
                                        Map<String, Decimal> QtrWithQtyMap = new Map<String, Decimal>();
                                        if (QLwithQtrQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                                            QtrWithQtyMap = QLwithQtrQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                                        }
                                        
                                        //Prepare map of previous quarters with qtr and existing qty, based on QuoteLine approved start date and end date
                                        for (String quarter : previousQuarters) {
                                            if (qtrsBetweenQLStartDtEndDt.contains(quarter) && quarter != approvedQtyQtr) {
                                                    //system.debug('Previous Quarter Found: ' + quarter + ' with quantity: ' + QtrWithQtyMap.get(quarter));
                                                    Decimal qty = QtrWithQtyMap.get(quarter);
                                                    PreviousQtrMap2.put(quarter, qty);
                                                    FinalQtrQtyMap2.put(quarter, PreviousQtrMap2.get(quarter));
                                            }
                                        }
                                        //system.debug('Previous Quarters Map: ' + PreviousQtrMap2);

                                        //Variable to check how much additional approved qty needs to be fulfilled from existing quantities in 6QPS, either from past or future quarters
                                        Decimal remainingQtyToFulfill = additionalApprovedQty;
                                        
                                        //Variable to store unapproved quantities from past quarters, which need to split evenly in future qtrs
                                        Decimal remainingQtyForFuture = 0;
                                        
                                        //Fulfilling remainingQtyToFulfill from past quarters, if it has some unapproved quantity left
                                        //Here, we will take whatever is present in first found quarter and then move to next quarter, till our remainingQtyToFulfill is fulfilled
                                        //If not completely fulfilled from past, then we will fulfill the same from future
                                        if (remainingQtyToFulfill > 0) {
                                            //system.debug('Inside adjusting remaining qty from past');
                                            for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                                for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                    if (PreviousQtrMap2.containsKey(quarter) && PreviousQtrMap2.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                        //system.debug('Qtry with prev qtr--'+PreviousQtrMap2);
                                                        //system.debug('Quarter to be updated--'+quarter);
                                                        Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                        //system.debug('available qty iss--'+availableQty);
                                                        //system.debug('qty to be consumed from past qtr--'+remainingQtyToFulfill);
                                                        if (availableQty > 0 && remainingQtyToFulfill >0) {
                                                            if (availableQty <= remainingQtyToFulfill) {
                                                                //system.debug('Consume full prv qtrs');
                                                                //If consumed fully, nothing left in previous qtr, so making it 0
                                                                if(PreviousQtrMap2.get(quarter) == availableQty) {
                                                                    PreviousQtrMap2.put(quarter, 0);
                                                                    //system.debug('inside if making PreviousQtrMap2 as 0--'+QtrwithRemainingApprovedQty);
                                                                }
                                                                else {
                                                                    //This condition checks if our existing sch and remaining approved is not same, then subtract availableQty from existing scheduled qty and update new scheduled qty in that qtr
                                                                    PreviousQtrMap2.put(quarter,PreviousQtrMap2.get(quarter) - availableQty);
                                                                    //system.debug('inside else making PreviousQtrMap2 as approved - available qty --'+QtrwithRemainingApprovedQty);
                                                                }
                                                                remainingQtyToFulfill -= availableQty;
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ PreviousQtrMap2.get(quarter));
                                                                //system.debug('remainingQtyToFulfill after update--'+remainingQtyToFulfill);
                                                                QtrwithRemainingApprovedQty.put(quarter,0);
                                                            } 
                                                            else {
                                                                //system.debug('Consume partially prv qtrs');
                                                                PreviousQtrMap2.put(quarter, PreviousQtrMap2.get(quarter) - remainingQtyToFulfill);
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ PreviousQtrMap2.get(quarter));
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)- remainingQtyToFulfill);
                                                                //system.debug('QtrwithRemainingApprovedQty block 2'+QtrwithRemainingApprovedQty);
                                                                remainingQtyForFuture = PreviousQtrMap2.get(quarter);
                                                                //Since it consumed partially, meaning all remainingQtyToFulfill was fulfilled, so making it 0
                                                                remainingQtyToFulfill = 0;
                                                            }
                                                        }
                                                        FinalQtrQtyMap2.put(quarter, PreviousQtrMap2.get(quarter));
                                                    }
                                                }
                                            }
                                        }
                                        
                                        //system.debug('Final qtr after adusting in prev qtrs--'+FinalQtrQtyMap2);
                                        //system.debug('remainingQtyForFuture--'+remainingQtyForFuture);
                                        //system.debug('PRVqtr map is--'+PreviousQtrMap2);
                                        //system.debug('Remaining qty to fulfill--'+remainingQtyToFulfill);
                                        
                                        //Prepare map of future quarters with qtr and existing qty, based on QuoteLine approved start date and end date
                                        for (String quarter : futureQuarters) {
                                            if (qtrsBetweenQLStartDtEndDt.contains(quarter) && quarter != approvedQtyQtr) {
                                                //system.debug('Future Quarter Found: '+quarter+' with quantity: '+QtrWithQtyMap.get(quarter));
                                                Decimal qty = QtrWithQtyMap.get(quarter);
                                                FutureQtrMap2.put(quarter, qty);
                                                FinalQtrQtyMap2.put(quarter, FutureQtrMap2.get(quarter));
                                            }
                                        }
                                        //system.debug('Future Map 2nd block-'+FutureQtrMap2);
                                        
                                        Decimal qtyToBeSplitInFuture = 0;
                                        
                                        //If there is any unapproved qty remaining in past qtrs even after fulfilling remainingQtyToFulfill, then store it in one variable, make that qtr 0 and distribute remaining into future qtrs
                                        for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                            for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                if (PreviousQtrMap2.containsKey(quarter) && PreviousQtrMap2.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                    //system.debug('Map with prev qtr--'+PreviousQtrMap2);
                                                    //system.debug('Quarter to be updated--'+quarter+'--where existing qty is--'+PreviousQtrMap2.get(quarter));
                                                    qtyToBeSplitInFuture += PreviousQtrMap2.get(quarter);
                                                    //system.debug('qtyToBeSplitInFuture--'+qtyToBeSplitInFuture);
                                                    PreviousQtrMap2.put(quarter, 0);
                                                    //system.debug('PreviousQtrMap2 after updating values--'+PreviousQtrMap2);
                                                    QtrwithRemainingApprovedQty.put(quarter,0);
                                                    //system.debug('QtrwithRemainingApprovedQty block 2'+QtrwithRemainingApprovedQty);
                                                    FinalQtrQtyMap2.put(quarter, PreviousQtrMap2.get(quarter));
                                                }
                                            }
                                        }
                                        
                                        //system.debug('Remaining qty to be distributed in future is--'+qtyToBeSplitInFuture);
                                        //system.debug('Remaining qty to be adjusted first time is--'+remainingQtyToFulfill);
                                        
                                        // remaining approved qty to be fulfilled in future qtrs, after adjusting from past qtrs, since could not be fully consumed from past qtrs
                                        if (remainingQtyToFulfill > 0) {
                                            system.debug('Inside adjusting remaining qty from future');
                                            for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                                for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                    if (FutureQtrMap2.containsKey(quarter) && FutureQtrMap2.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                        //system.debug('Qtry with future qtr--'+FutureQtrMap2);
                                                        //system.debug('Quarter to be updated--'+quarter);
                                                        Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                        //system.debug('available qty iss--'+availableQty);
                                                        //system.debug('qty to be consumed from past qtr--'+remainingQtyToFulfill);
                                                        if (availableQty > 0 && remainingQtyToFulfill >0) {
                                                            if (availableQty <= remainingQtyToFulfill) {
                                                                //system.debug('Consume full prv qtrs');
                                                                //If consumed fully, nothing left in this future qtr, so making it 0
                                                                //This condition checks if our existing sch and remaining approved is same, then make existing scheduled to 0
                                                                if(FutureQtrMap2.get(quarter) == availableQty) {
                                                                    FutureQtrMap2.put(quarter, 0);
                                                                    //system.debug('inside if making FutureQtrMap2 as 0--'+QtrwithRemainingApprovedQty);
                                                                }
                                                                else {
                                                                    //This condition checks if our existing sch and remaining approved is not same, then subtract availableQty from existing scheduled qty and update new scheduled qty in that qtr
                                                                    FutureQtrMap2.put(quarter,FutureQtrMap2.get(quarter) - availableQty);
                                                                    //system.debug('inside else making FutureQtrMap2 as approved - available qty --'+QtrwithRemainingApprovedQty);
                                                                }
                                                                QtrwithRemainingApprovedQty.put(quarter,0);
                                                                //subtracting whatever we adjusted from future, and calculating new remainingQtyToFulfill
                                                                remainingQtyToFulfill -= availableQty;
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ FutureQtrMap2.get(quarter));
                                                                //system.debug('remainingQtyToFulfill after update--'+remainingQtyToFulfill);
                                                            } 
                                                            else {
                                                                //system.debug('Consume partially prv qtrs');
                                                                FutureQtrMap2.put(quarter, FutureQtrMap2.get(quarter) - remainingQtyToFulfill);
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ FutureQtrMap2.get(quarter));
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)-remainingQtyToFulfill);
                                                                //system.debug('block 2 else QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                                remainingQtyForFuture = FutureQtrMap2.get(quarter);
                                                                //Since it consumed partially, meaning all remainingQtyToFulfill was fulfilled, so making it 0
                                                                remainingQtyToFulfill = 0;
                                                            }
                                                        }
                                                        FinalQtrQtyMap2.put(quarter, FutureQtrMap2.get(quarter));
                                                    }
                                                }
                                            }
                                        }
                                        //system.debug('Remaining qty to be adjusted second time is--'+remainingQtyToFulfill);
                                        //system.debug('Previous qtr map--'+PreviousQtrMap2);
                                        //system.debug('Final qtr map for previous qtrs updated--'+FinalQtrQtyMap2);
                                        //system.debug('Remaining qty from past to be stored in future--'+qtyToBeSplitInFuture);
                                        
                                        //qtyToBeSplitInFuture is qty left from past qtrs to be split evenly in future qtrs`                                        
                                        //If there are any future qtrs and we have some qty to be split in future
                                        if (qtyToBeSplitInFuture > 0) {
                                            //system.debug('Inside qtyToBeSplitInFuture');
                                            Integer futureQuarterCount = FutureQtrMap2.size();
                                            if (futureQuarterCount > 0) {
                                                //Calculate the quantity to add to each future quarter, then round it off in another variable and add that to every future qtr
                                                Decimal qtyPerFutureQuarter = qtyToBeSplitInFuture / futureQuarterCount;
                                                Double qtyPerFutureQuarterRdOffDbl = Math.Floor(qtyPerFutureQuarter);
                                                Integer qtyPerFutureQuarterRdOff = (Integer)qtyPerFutureQuarterRdOffDbl;
                                                //system.debug('qtyPerFutureQuarter--'+qtyPerFutureQuarter);
                                                //system.debug('qtyPerFutureQuarterRdOff--'+qtyPerFutureQuarterRdOff);
                                                integer counter =0;
                                                for (String quarter : FutureQtrMap2.keySet()) {
                                                    if (qtrsBetweenQLStartDtEndDt.contains(quarter)) {
                                                        counter++;
                                                        //system.debug('Qtr from ftrqtr map--'+quarter);
                                                        if (qtyPerFutureQuarterRdOff <= qtyToBeSplitInFuture) {
                                                            Decimal currentQty = FutureQtrMap2.get(quarter);
                                                            FutureQtrMap2.put(quarter, currentQty + qtyPerFutureQuarterRdOff);
                                                            FinalQtrQtyMap2.put(quarter, FutureQtrMap2.get(quarter));
                                                            QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+qtyPerFutureQuarterRdOff);
                                                            //tracking how much qty we have split and how much is still remaining to split
                                                            qtyToBeSplitInFuture -= qtyPerFutureQuarterRdOff;
                                                            /*if (qtyToBeSplitInFuture <= qtyPerFutureQuarterRdOff) {
                                                                //This else block adds any decimal qty left after rounding off qty to be distributed.
                                                    			//ex. if we have to divide 10 between 3 qtrs, it comes as 3.33 to be added in each qtr. After rounding off, it will add 3 each to all 3 qtrs. Remaining 1 which was decimal, will be adjusted from here
                                                                FutureQtrMap2.put(quarter, FutureQtrMap2.get(quarter) + qtyToBeSplitInFuture);
                                                                FinalQtrQtyMap2.put(quarter, FutureQtrMap2.get(quarter));
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+qtyToBeSplitInFuture);
                                                                system.debug('Final qtr map update--'+FinalQtrQtyMap2);
                                                                system.debug('block 2 QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                            }*/
                                                            if (qtyToBeSplitInFuture <> 0 && counter == futureQuarterCount) {
                                                                //system.debug('Inside last if to adjust decimal qty--'+qtyToBeSplitInFuture);
                                                                //This block adds any decimal qty left after rounding off qty to be distributed.
                                                    			//ex. if we have to divide 1 between 3 qtrs, it comes as 0.33 to be added in each qtr. After rounding off, it will add 0 each to all 3 qtrs. Remaining 1 which was decimal, will be adjusted from here
                                                                FutureQtrMap2.put(quarter, FutureQtrMap2.get(quarter) + qtyToBeSplitInFuture);
                                                                FinalQtrQtyMap2.put(quarter, FutureQtrMap2.get(quarter));
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+qtyToBeSplitInFuture);
                                                                qtyToBeSplitInFuture=0;
                                                                //system.debug('Final qtr map update--'+FinalQtrQtyMap2);
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            else {
                                                //If there are no future qtrs, we adjust everything in last qtr based on QL approved End Date
                                                //System.debug('No future quarters available to distribute remaining quantity.');
                                                String qtr = getQuarterFromDate(qlEndDate);
                                                Decimal lastQtrQty = QtrWithQtyMap.get(qtr)+qtyToBeSplitInFuture+additionalApprovedQty;
                                                //system.debug('lastQtrQty--'+lastQtrQty);
                                                FinalQtrQtyMap2.put(qtr, lastQtrQty);
                                            }
                                        }
                                        
                                        //system.debug('qtr with qty map before update--'+QtrWithQtyMap);

                                        //updating local maps here, to be used if we are approving multiple line items in one go
                                        QtrWithQtyMap = updateLocalMaps(QtrWithQtyMap,PreviousQtrMap2,FutureQtrMap2,approvedQtyQtr,newApprovedQty,oldApprovedQty);
                                        
                                        //system.debug('qtr with qty map after update--'+QtrWithQtyMap);
                                        //system.debug('QLwithQtrQty before update--'+QLwithQtrQty);
                                        QLwithQtrQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrWithQtyMap);
                                        //system.debug('QLwithQtrQty after update--'+QLwithQtrQty);
                                        
                                        //system.debug('2 retention before QtrwithRemainingApprovedQty'+QtrwithRemainingApprovedQty);
                                        QtrwithRemainingApprovedQty.put(approvedQtyQtr,0);
                                        //system.debug('2 retention after QtrwithRemainingApprovedQty'+QtrwithRemainingApprovedQty);
                                        //system.debug('2 retention before QLwithQtrwithRemainingApprovedQty'+QLwithQtrwithRemainingApprovedQty);
                                        QLwithQtrwithRemainingApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrwithRemainingApprovedQty);
                                        //system.debug('2 retention after QLwithQtrwithRemainingApprovedQty'+QLwithQtrwithRemainingApprovedQty);
                                        
                                        //system.debug('FutureQtrMap2--'+FutureQtrMap2);
                                        //system.debug('Final qrt map last --'+FinalQtrQtyMap2);   
                                        QLwithQtrQtyMap.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, FinalQtrQtyMap2);
                                        //system.debug('QLwithQtrQtyMap2 is--'+QLwithQtrQtyMap);
                                    }
                                    
/////////////////////////////block 3
                                    else if (newApprovedQty < previousSchedQty) {
                                        system.debug('BLOCK 3-- newApproved less than prev schedl');
                                        Map<String, Decimal> PreviousQtrMap3 = new Map<String, Decimal>();
                                        Map<String, Decimal> FutureQtrMap3 = new Map<String, Decimal>();
                                        Map<String, Decimal> FinalQtrQtyMap3 = new Map<String, Decimal>();	//to store all the final numbers related to futureQtr map and PreviousQtr map
                                        Decimal totalToBeConsumed = 0;	//to be taken from past/future
                                        Decimal remainingScheduledQty = 0;	//to be distributed in future
                                        
                                        if(oldApprovedQty == 0) {
                                            //system.debug('Inside if 1');
                                            remainingScheduledQty = previousSchedQty - newApprovedQty;
                                        }
                                        else if(oldApprovedQty <> 0) {
                                            //system.debug('Inside if 2');
                                            totalToBeConsumed = newApprovedQty ;
                                            remainingScheduledQty = previousSchedQty - oldApprovedQty;
                                        }
                                        //system.debug('Rem sch qty--> '+remainingScheduledQty);
                                        //system.debug('totalToBeConsumed--> '+totalToBeConsumed);
                                        String currentQuarter = getQuarterFromDate(Date.today());	
                                        Integer qtrSize = OLIWithQtrCnt.get(fcRecord.Core_FC_Opportunity_Product__c);
                                        List<String> previousQuarters = getPreviousQuarters(currentQuarter, qtrSize);	//get Previous quarters based on today
                                        List<String> futureQuarters =  getFutureQuarters(currentQuarter, qtrSize);	//get Future quarters based on today
                                        futureQuarters.add(currentQuarter);	//add current quarter as well in Future quarters
										
                                        Map<String, Decimal> QtrWithQtyMap =  new Map<String, Decimal>();
                                        if (QLwithQtrQty.containsKey(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c)) {
                                            QtrWithQtyMap = QLwithQtrQty.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                                        }
                                        //Prepare map of previous quarters with qtr and qty, based on QuoteLine approved start date and end date
                                        for (String quarter : previousQuarters) {
                                            if (qtrsBetweenQLStartDtEndDt.contains(quarter) && quarter != approvedQtyQtr) {
                                                Decimal qty = QtrWithQtyMap.get(quarter);
                                                //system.debug('Qtr--' +quarter+ '--with Qty--'+qty);
                                                PreviousQtrMap3.put(quarter, qty);
                                                FinalQtrQtyMap3.put(quarter, PreviousQtrMap3.get(quarter));
                                            }
                                        }
                                        //system.debug('Previous Qtr Map--'+PreviousQtrMap3);
                                        
                                        //Fulfilling totalToBeConsumed from past quarters, if it has some unapproved quantity left
                                        //Here, we will take whatever is present in first found quarter and then move to next quarter, till our totalToBeConsumed is fulfilled
                                        //If not completely fulfilled from past, then we will fulfill the same from future
                                        for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                            for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                if (PreviousQtrMap3.containsKey(quarter) && PreviousQtrMap3.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                    //system.debug('Qty with prev qtr--'+PreviousQtrMap3);
                                                    //system.debug('Quarter to be updated--'+quarter);
                                                    Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                    //system.debug('available qty iss--'+availableQty);
                                                    if (availableQty > 0 && totalToBeConsumed > 0 ) {
                                                        if (availableQty <= totalToBeConsumed) {
                                                            //system.debug('Consume full prv qtrs');
                                                            //If consumed fully, nothing left in previous qtr, so making it 0
                                                            if(PreviousQtrMap3.get(quarter) == availableQty) {
                                                                PreviousQtrMap3.put(quarter, 0);
                                                                //system.debug('inside if making PreviousQtrMap3 as 0--'+QtrwithRemainingApprovedQty);
                                                            }
                                                            else {
                                                                //This condition checks if our existing sch and remaining approved is not same, then subtract availableQty from existing scheduled qty and update new scheduled qty in that qtr
                                                                PreviousQtrMap3.put(quarter,PreviousQtrMap3.get(quarter) - availableQty);
                                                                //system.debug('inside else making PreviousQtrMap3 as approved - available qty --'+QtrwithRemainingApprovedQty);
                                                            }
                                                            totalToBeConsumed -= availableQty;
                                                            //system.debug('Update qtr--'+quarter+'--with qty--'+ PreviousQtrMap3.get(quarter));
                                                            //system.debug('remainingQtyToFulfill after update--'+totalToBeConsumed);
                                                            QtrwithRemainingApprovedQty.put(quarter,0);
                                                        } 
                                                        else {
                                                            //system.debug('Consume partially prv qtrs');
                                                            PreviousQtrMap3.put(quarter, PreviousQtrMap3.get(quarter) - totalToBeConsumed);
                                                            //system.debug('Update qtr--'+quarter+'--with qty--'+ PreviousQtrMap3.get(quarter));
                                                            QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)- totalToBeConsumed);
                                                            //system.debug('block 3 if QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                            totalToBeConsumed = 0;
                                                        }
                                                    }
                                                    FinalQtrQtyMap3.put(quarter, PreviousQtrMap3.get(quarter));
                                                }
                                            }
                                        }
                                        Decimal additionalToBeAdjustedInFutureFromPast = 0;
                                        
                                        ////If there is any unapproved qty remaining in past qtrs even after fulfilling remainingQtyToFulfill, then store it in one variable, make that qtr 0 and distribute remaining into future qtrs
                                        for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                            for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                if (PreviousQtrMap3.containsKey(quarter) && PreviousQtrMap3.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                    //system.debug('Qtry with prev qtr--'+PreviousQtrMap3);
                                                    //system.debug('Quarter to be updated--'+quarter);
                                                    Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                    //system.debug('available qty iss--'+availableQty);
                                                    if (availableQty > 0) {
                                                        //system.debug('Updated qtr--'+quarter+'--which has existing additional qty--'+ availableQty);
                                                        //system.debug('PreviousQtrMap2 before updating values--'+PreviousQtrMap3);
                                                        additionalToBeAdjustedInFutureFromPast += availableQty;
                                                        PreviousQtrMap3.put(quarter, 0);
                                                        //system.debug('PreviousQtrMap2 after updating values--'+PreviousQtrMap3);
                                                        QtrwithRemainingApprovedQty.put(quarter, 0);
                                                        //system.debug('block 3 if QtrwithRemainingApprovedQty qtr map update--'+QtrwithRemainingApprovedQty);
                                                    }
                                                    FinalQtrQtyMap3.put(quarter, PreviousQtrMap3.get(quarter));
                                                }
                                            }
                                        }
                                        
                                        //prepare map of future quarters with qtr and qty, based on QL approved start date and end date
                                        //6QPS may have 10 quarters but we will only consider the quarters between QuoteLine start date and end date
                                        for (String quarter : futureQuarters) {
                                            if (qtrsBetweenQLStartDtEndDt.contains(quarter) && quarter != approvedQtyQtr) {
                                                //system.debug('Future Quarter Found:-- ' + quarter + '--with quantity: ' + QtrWithQtyMap.get(quarter));
                                                Decimal qty = QtrWithQtyMap.get(quarter);
                                                FutureQtrMap3.put(quarter, qty);
                                                FinalQtrQtyMap3.put(quarter, FutureQtrMap3.get(quarter));
                                            }
                                        }
                                        //system.debug('Future Qtr Map-'+FutureQtrMap3);
                                        
                                        // remaining approved qty to be fulfilled in future qtrs, after adjusting from past qtrs, since could not be fully consumed from past qtrs
                                        if(totalToBeConsumed > 0) {
                                            //system.debug('Inside adjusting remaining qty from future');
                                            for (Map<String, Decimal> qtrWithRemainingApprovedQtyMap : QLwithQtrwithRemainingApprovedQty.values()) {
                                                for (String quarter : qtrWithRemainingApprovedQtyMap.keySet()) {
                                                    if (FutureQtrMap3.containsKey(quarter) && FutureQtrMap3.get(quarter) > 0 && qtrWithRemainingApprovedQtyMap.get(quarter) > 0) {
                                                        //system.debug('Qty with future qtr--'+FutureQtrMap3);
                                                        //system.debug('Quarter to be updated--'+quarter);
                                                        Decimal availableQty = qtrWithRemainingApprovedQtyMap.get(quarter); // Remaining approved qty for particular qtr(scheduled-approved)
                                                        //system.debug('available qty iss--'+availableQty);
                                                        //system.debug('qty to be consumed from future qtr--'+totalToBeConsumed);
                                                        if (availableQty > 0 && totalToBeConsumed >0) {
                                                            if (availableQty <= totalToBeConsumed) {
                                                                ///system.debug('Consume full prv qtrs');
                                                                //This condition checks if our existing sch and remaining approved is same, then make existing scheduled to 0
                                                                if(FutureQtrMap3.get(quarter) == availableQty) {
                                                                    FutureQtrMap3.put(quarter, 0);
                                                                    //system.debug('inside if making FutureQtrMap3 as 0--'+QtrwithRemainingApprovedQty);
                                                                }
                                                                else {
                                                                    //This condition checks if our existing sch and remaining approved is not same, then subtract availableQty from existing scheduled qty and update new scheduled qty in that qtr
                                                                    FutureQtrMap3.put(quarter,FutureQtrMap3.get(quarter) - availableQty);
                                                                    //system.debug('inside else making FutureQtrMap3 as approved - available qty --'+QtrwithRemainingApprovedQty);
                                                                }
                                                                //tracking how much qty we have consumed and how much is still remaining to be consumed
                                                                totalToBeConsumed -= availableQty;
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ FutureQtrMap3.get(quarter));
                                                                //system.debug('totalToBeConsumed after update--'+totalToBeConsumed);
                                                                QtrwithRemainingApprovedQty.put(quarter,0);
                                                            } 
                                                            else {
                                                                //system.debug('Consume partially prv qtrs');
                                                                FutureQtrMap3.put(quarter, FutureQtrMap3.get(quarter) - totalToBeConsumed);
                                                                //system.debug('Update qtr--'+quarter+'--with qty--'+ FutureQtrMap3.get(quarter));
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)-totalToBeConsumed);
                                                                //Since it consumed partially, meaning all totalToBeConsumed was fulfilled, so making it 0
                                                                totalToBeConsumed = 0;
                                                            }
                                                        }
                                                        FinalQtrQtyMap3.put(quarter, FutureQtrMap3.get(quarter));
                                                    }
                                                }
                                            }
                                            //system.debug('Map is--'+FutureQtrMap3);
                                            //system.debug('Remaining qty to fulfill is--'+totalToBeConsumed);
                                            //system.debug('Final future related map data is--'+FinalQtrQtyMap3); 
                                        }
                                        Decimal totalQtyToBeAdjustedInFuture = remainingScheduledQty + additionalToBeAdjustedInFutureFromPast;
                                        //system.debug('totalQtyToBeAdjustedInFuture---'+totalQtyToBeAdjustedInFuture);
                                        
                                        //If there are any future qtrs and we have some qty to be split in future
                                        if (totalQtyToBeAdjustedInFuture > 0) {
                                            Integer futureQuarterCount = FutureQtrMap3.size();
                                            if (futureQuarterCount > 0) {
                                                //Calculate the quantity to add to each future quarter, then round it off in another variable and add that to every future qtr
                                                Decimal qtyPerFutureQuarter = totalQtyToBeAdjustedInFuture / futureQuarterCount;
                                                //system.debug('to adjust in future qtrs-'+qtyPerFutureQuarter);
                                                Double qtyPerFutureQuarterRdOffDbl = Math.Floor(qtyPerFutureQuarter);
                                                Integer qtyPerFutureQuarterRdOff = (Integer)qtyPerFutureQuarterRdOffDbl;
                                                //system.debug('qtyPerFutureQuarterRdOff--floorValue '+qtyPerFutureQuarterRdOffDbl +'  '+qtyPerFutureQuarterRdOff);
                                                //system.debug('Future qtrs map--'+FutureQtrMap3);
                                                integer counter =0;
                                                for (String quarter : FutureQtrMap3.keyset()) {
                                                    if (qtrsBetweenQLStartDtEndDt.contains(quarter)) {
                                                        counter++;
                                                        //system.debug('Quarter being considered for update--'+quarter);
                                                        //system.debug('Quarter old qty--'+QtrWithQtyMap.get(quarter));
                                                        //system.debug('Qty to be adjusted in this qtr--'+qtyPerFutureQuarterRdOff);
                                                        if (qtyPerFutureQuarterRdOff <= totalQtyToBeAdjustedInFuture) {
                                                            //system.debug('Inside adjust 1st if');
                                                            Decimal currentQty = FutureQtrMap3.get(quarter);
                                                            FutureQtrMap3.put(quarter, currentQty + qtyPerFutureQuarterRdOff);
                                                            //system.debug('Qty updates in qtr--'+quarter+'--is--'+FutureQtrMap3.get(quarter));
                                                            QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+qtyPerFutureQuarterRdOff);
                                                            //tracking how much qty we have split and how much is still remaining to split
                                                            totalQtyToBeAdjustedInFuture -= qtyPerFutureQuarterRdOff;
                                                            //system.debug('Remaining totalQtyToBeAdjustedInFuture after update--'+totalQtyToBeAdjustedInFuture);
                                                            /*if (totalQtyToBeAdjustedInFuture < qtyPerFutureQuarterRdOff) {
                                                                system.debug('Inside last if to adjust decimal qty--'+totalQtyToBeAdjustedInFuture);
                                                                //This block adds any decimal qty left after rounding off qty to be distributed.
                                                    			//ex. if we have to divide 10 between 3 qtrs, it comes as 3.33 to be added in each qtr. After rounding off, it will add 3 each to all 3 qtrs. Remaining 1 which was decimal, will be adjusted from here
                                                                FutureQtrMap3.put(quarter, FutureQtrMap3.get(quarter)+ totalQtyToBeAdjustedInFuture);
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+totalQtyToBeAdjustedInFuture);
                                                                system.debug('QtrwithRemainingApprovedQty block3 last value'+QtrwithRemainingApprovedQty);
                                                            }*/
                                                            if (totalQtyToBeAdjustedInFuture <> 0 && counter == futureQuarterCount) {
                                                                //system.debug('Inside last if to adjust decimal qty--'+totalQtyToBeAdjustedInFuture);
                                                                //This block adds any decimal qty left after rounding off qty to be distributed.
                                                    			//ex. if we have to divide 1 between 3 qtrs, it comes as 0.33 to be added in each qtr. After rounding off, it will add 0 each to all 3 qtrs. Remaining 1 which was decimal, will be adjusted from here
                                                                FutureQtrMap3.put(quarter, FutureQtrMap3.get(quarter)+ totalQtyToBeAdjustedInFuture);
                                                                QtrwithRemainingApprovedQty.put(quarter,QtrwithRemainingApprovedQty.get(quarter)+totalQtyToBeAdjustedInFuture);
                                                                totalQtyToBeAdjustedInFuture = 0;
                                                            }
                                                        }
                                                        FinalQtrQtyMap3.put(quarter, FutureQtrMap3.get(quarter));
                                                    }
                                                }
                                                //system.debug('Final map after all updates to future--'+FinalQtrQtyMap3);
                                            }
                                            else {
                                                //If there are no future qtrs, we adjust everything in last qtr based on QL approved End Date
                                                //System.debug('No future quarters available to distribute remaining quantity.');
                                                String qtr = getQuarterFromDate(qlEndDate);
                                                Decimal lastQtrQty = QtrWithQtyMap.get(qtr)+ additionalToBeAdjustedInFutureFromPast ;
                                                //system.debug('lastQtrQty--'+lastQtrQty);
                                                FinalQtrQtyMap3.put(qtr, lastQtrQty);
                                            }
                                        }
                                        //system.debug('qtr with qty map before update--'+QtrWithQtyMap);

                                        //updating local maps here, to be used if we are approving multiple line items in one go
                                        QtrWithQtyMap = updateLocalMaps(QtrWithQtyMap,PreviousQtrMap3,FutureQtrMap3,approvedQtyQtr,newApprovedQty,oldApprovedQty);
                                        
                                        //system.debug('QtrWithQtyMap after update--'+QtrWithQtyMap);
                                        //system.debug('QLwithQtrQty before update--'+QLwithQtrQty);
                                        QLwithQtrQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrWithQtyMap);
                                        //system.debug('QLwithQtrQty after update--'+QLwithQtrQty);
                                        //system.debug('3 retention before QtrwithRemainingApprovedQty'+QtrwithRemainingApprovedQty);
                                        QtrwithRemainingApprovedQty.put(approvedQtyQtr,0);
                                        //system.debug('3 retention after QtrwithRemainingApprovedQty'+QtrwithRemainingApprovedQty);
                                        //system.debug('3 retention before QLwithQtrwithRemainingApprovedQty'+QLwithQtrwithRemainingApprovedQty);
                                        QLwithQtrwithRemainingApprovedQty.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c,QtrwithRemainingApprovedQty);
                                        //system.debug('3 retention after QLwithQtrwithRemainingApprovedQty'+QLwithQtrwithRemainingApprovedQty);
                                        QLwithQtrQtyMap.put(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c, FinalQtrQtyMap3);
                                        //system.debug('Final qtr map after all updates to past--'+FinalQtrQtyMap3);
                                        //system.debug('QLwithQtrQtyMap 3 is--'+QLwithQtrQtyMap);
                                    }
                                    updateFcListWithQuantities(fcList, QLwithQtrQtyMap); 
                                }
                                if (rcliDetail.RCLIStatus == 'Rejected') {
                                    fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c = fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c - rcliDetail.RCLIQty;
                                }
                                if (rcliDetail.RCLIStatus == 'Submitted') {
                                    fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c = fcRecord.Core_FC_Submitted_Claim_Quantity_nbr__c + rcliDetail.RCLIQty;
                                }
                            }
                        }
                    }
                }
            }
            update fcList;
        }
        
        catch (Exception e) {
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Message',Core_Details__c = e.getMessage(), Core_Origin__c='PCC_RebateClaimApproveController.updateQtyOn6QPS', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
            throw new AuraHandledException(e.getMessage());
        }
        finally { 
            insert logEntries;
        } 
    }
    //Method to update Local Maps
	public static map<String, Decimal> updateLocalMaps(map<String, Decimal> QtrWithQtyMap, map<String, Decimal> PreviousQtrMap, map<String, Decimal> FutureQtrMap, string approvedQtyQtr, Decimal newApprovedQty, Decimal oldApprovedQty) {
		for(String qtr : QtrWithQtyMap.keySet()) {
			if(PreviousQtrMap.containsKey(qtr)) {            
				QtrWithQtyMap.put(qtr,PreviousQtrMap.get(qtr));
			}
			else if(FutureQtrMap.containsKey(qtr)) {            
				QtrWithQtyMap.put(qtr,FutureQtrMap.get(qtr));
			}
			else if(qtr == approvedQtyQtr) {
				QtrWithQtyMap.put(qtr, newApprovedQty+oldApprovedQty);
			}
		} 
		return QtrWithQtyMap;
	}
    
    //Method to update fcList based on previous and future quarter maps
    public static void updateFcListWithQuantities(List<Core_Opp_FC_Prod_Schedule__c> fcList, Map<Id, Map<String, Decimal>> QLwithQtrQtyMap) {
        Map<String, Decimal> QtrWithQtyMapforFC = new Map<String, Decimal>();
        for(Id qlId : QLwithQtrQtyMap.keySet()) {
            for(Core_Opp_FC_Prod_Schedule__c fcRecord : fcList) {
                if(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c == qlId) {
                    QtrWithQtyMapforFC = QLwithQtrQtyMap.get(fcRecord.Core_FC_Opportunity_Product__r.SBQQ__QuoteLine__c);
                    Decimal qtyToAdd = QtrWithQtyMapforFC.get(fcRecord.Core_Opp_FC_Quarter__c);
                    system.debug('FcRecord log 1 before--'+fcRecord.Core_Opp_FC_Quantity__c);
                    if(qtyToAdd>=0) {
                        fcRecord.Core_Opp_FC_Quantity__c = qtyToAdd;
                    }
                    system.debug('FcRecord log 1 after--'+fcRecord.Core_Opp_FC_Quantity__c);
                }
            }
        }
        update fcList;
    }
    
    //get quarter end date based on quarter name
    public static Date getQuarterEndDateFromQtrName(String quarterName) {
        Integer year = Integer.valueOf(quarterName.substring(0, 4));
        String quarter = quarterName.substring(5);
        
        Date qtrEndDate;
        switch on quarter {
            when 'Q1' {
                qtrEndDate = Date.newInstance(year, 3, 31);
            }
            when 'Q2' {
                qtrEndDate = Date.newInstance(year, 6, 30);
            }
            when 'Q3' {
                qtrEndDate = Date.newInstance(year, 9, 30);
            }
            when 'Q4' {
                qtrEndDate = Date.newInstance(year, 12, 31);
            }
            when else {
                qtrEndDate = null;
            }
        }
        return qtrEndDate;
    }
    
    
    //get quarter start date based on quarter name
    public static Date getQuarterStartDateFromQtrName(String quarterName) {
        Integer year = Integer.valueOf(quarterName.substring(0, 4));
        String quarter = quarterName.substring(5);
        
        Date qtrStDate;
        switch on quarter {
            when 'Q1' {
                qtrStDate = Date.newInstance(year, 1, 1);
            }
            when 'Q2' {
                qtrStDate = Date.newInstance(year, 4, 1);
            }
            when 'Q3' {
                qtrStDate = Date.newInstance(year, 7, 1);
            }
            when 'Q4' {
                qtrStDate = Date.newInstance(year, 10, 1);
            }
            when else {
                qtrStDate = null;
            }
        }
        return qtrStDate;
    }
    
    // Method to get the current quarter based on today's date
    public static String getQuarterFromDate(Date dt) {
        Integer month = dt.month();
        Integer year = dt.year();
        String quarter;
        
        if (month >= 1 && month <= 3) {
            quarter = year + '-Q1';
        } else if (month >= 4 && month <= 6) {
            quarter = year + '-Q2';
        } else if (month >= 7 && month <= 9) {
            quarter = year + '-Q3';
        } else {
            quarter = year + '-Q4';
        }
        return quarter;
    }
    
    // Method to get previous quarters based on the current quarter
    public static List<String> getPreviousQuarters(String currentQuarter, Integer qtrSize) {
        List<String> previousQuarters = new List<String>();
        
        // Split the current quarter into year and quarter
        String[] parts = currentQuarter.split('-Q');
        Integer currentYear = Integer.valueOf(parts[0]);
        Integer currentQtr = Integer.valueOf(parts[1]);
        
        // Loop to get previous quarters
        Integer count = 0;
        Integer year = currentYear;
        Integer quarter = currentQtr - 1;
        
        while (count < qtrSize) {
            if (quarter <= 0) {
                // Transition to previous year and set quarter to Q4
                year--;
                quarter = 4;
            }
            previousQuarters.add(year + '-Q' + quarter);
            count++;
            quarter--;
        }    
        return previousQuarters;
    }
    
    
    // Method to calculate future quarters based on the current quarter
    public static List<String> getFutureQuarters(String currentQuarter, Integer qtrSize) {
        List<String> futureQuarters = new List<String>();
        
        // Split the current quarter into year and quarter
        String[] parts = currentQuarter.split('-Q');
        Integer currentYear = Integer.valueOf(parts[0]);
        Integer currentQtr = Integer.valueOf(parts[1]);
        
        // Loop to calculate future quarters
        for (Integer i = 1; i <= qtrSize; i++) {
            Integer futureQtr = currentQtr + i;
            Integer futureYear = currentYear;
            
            // Handle year transition
            while (futureQtr > 4) {
                futureQtr -= 4; // Go back to Q1
                futureYear += 1; // Move to the next year
            }
            futureQuarters.add(futureYear + '-Q' + futureQtr);
        }
        return futureQuarters;
    }
    
    //To get quarters between specific dates
    public static List<String> getQuartersBetweenDates(Date startDate, Date endDate) {
        List<String> quarters = new List<String>();
        
        Integer startYear = startDate.year();
        Integer endYear = endDate.year();
        Integer startQuarter = (startDate.month() - 1) / 3 + 1;
        Integer endQuarter = (endDate.month() - 1) / 3 + 1;
        for (Integer year = startYear; year <= endYear; year++) {
            Integer startQtr = (year == startYear) ? startQuarter : 1;
            Integer endQtr = (year == endYear) ? endQuarter : 4;
            for (Integer qtr = startQtr; qtr <= endQtr; qtr++) {
                String quarterString = year + '-Q' + qtr;
                quarters.add(quarterString);
            }
        }
        return quarters;
    }   
    
    
    
    /**************************************************************************************************************************************************
TWC3123-6334 - Wrapper to store details of Rebate Claim Line Items and update in 6QPS records based on status/quarter
**************************************************************************************************************************************************/    
    public class rebateClaimItemQuoteLineDetails {
        public String RCLIStatus { get;set;}
        public Double RCLIQty { get;set;}
        public String RCLIQtr { get;set; }
        public String RCLIQL { get;set; }
    }
    
    /************************************************************************************************************************** 
Method Name :   showErrorWrap(will return error Message and if toast should be visible or not.)
***************************************************************************************************************************/
    public class showErrorWrap {
        @AuraEnabled
        public String errorMsg { get;set;}
        @AuraEnabled
        public boolean noErrorToast { get;set;}
    }
    public Class rebateQuoteLineError {
        @AuraEnabled
        public String errorMsgWrpallqty { get;set;}
        @AuraEnabled
        public String errorMsgWrpsubQty { get;set;}
    }
  /*  
    @AuraEnabled
    public static Boolean personaCheck(List<String> psName) {
        integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = : Userinfo.getUserId() AND PermissionSet.Name In: psName
                        ];
        return count > 0;
    }
*/
    
    @AuraEnabled
    public static Map<String,Map<String,List<List<String>>>> getRCData(Id recordId) {
        Map<String,Map<String,List<List<String>>>> rcMap = new Map<String,Map<String,List<List<String>>>>();
        rcLst = [Select id,Name from PCC_Rebate_Claim__c where Id =: recordId];
        if(rcLst.size() > 0){
            rcMap.put(rcLst[0].Name,getRCDetails(rcLst[0].Id,rcLst[0].Name));
        }   
        System.debug(rcMap);
        System.debug(rcMap.size());
        
        return rcMap;  
        
    }
    @TestVisible
    private static Map<String,List<List<String>>> getRCDetails(Id rcId,String name){   
        
        List<List<String>> cellValuesList = new List<List<String>>();
        
        Map<String,Reports.ReportMetadata> idToFilterMAP = getFilters(name);
        //System.debug(idToFilterMAP);
        List<String> reportIdLst = new List<String>();
        reportIdLst.addAll(idToFilterMAP.keySet());
        //Run the report with the report metadata, filters and the report id value fetched from the Pricing_ReportFilterController
        Reports.ReportResults results = Reports.ReportManager.runReport(reportIdLst[0],idToFilterMAP.get(reportIdLst[0]), true);
        MAP<String,Reports.ReportFact> factDet = results.getFactMap();
        Set<String> factMapKeySet = factDet.keySet();
        String factMapKey = null;
        //Gets the key associated with each detail row (For Tabular Reports, Key will be same for all the Detail Rows)
        for(String reportKey: factMapKeySet){
            factMapKey = reportKey;
            break;
        }
        Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithdetails)results.getFactMap().get(factMapKey);
        //Gets the detail rows for the Report that was run
        List<Reports.ReportDetailRow> detailListRows = factDetails.getRows();
        for(Reports.ReportDetailRow detailRow:detailListRows)
        {
            List<String> cellValues = new List<String>();
            for(Reports.ReportDataCell dataCell:detailRow.getDataCells())
            {
                /*Loop through the detail row records and get the individual cell value from the report corresponding to each detail row*/
                cellValues.add(dataCell.getlabel());
               
            }
            //System.debug('# cellValues'+cellValues);
            cellValuesList.add(cellValues);
        }
        Reports.ReportMetadata reportMd = new Reports.ReportMetadata();
        List<String> columnHeaders = new List<String>();
        Reports.ReportDescribeResult describeRes = Reports.ReportManager.describeReport(reportIdLst[0]);
        Reports.ReportExtendedMetadata reportMeta = describeRes.getReportExtendedMetadata();
        Map<String,Reports.DetailColumn> colMap = reportMeta.getDetailColumnInfo();
        for(String key : colMap.KeySet()){
            columnHeaders.add(colMap.get(key).getLabel());
            //system.debug(colMap.get(key).getLabel());
        }
        
        //System.debug(cellValuesList);
        return new Map<String,List<List<String>>>{String.join(columnHeaders,',') => cellValuesList}; 
	}
    @TestVisible
    private static Map<String,Reports.ReportMetadata> getFilters(String name){
        List <Report> reportList = new List<Report>();
        String reportId;
        String reportName = Core_CRM_Utility.getCRMLabel('CRM_Rebate_Claim_Report_Name');
        Reports.ReportMetadata reportMd = new Reports.ReportMetadata();
        reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName =: reportName];
        reportId = (String)reportList.get(0).get('Id');
        Reports.ReportDescribeResult describeRPMUsr = Reports.ReportManager.describeReport(reportId);
        //Get Report records to apply filter on
        Reports.ReportResults resultsRpm = Reports.ReportManager.runReport(reportId, true);
        reportMd = resultsRpm.getReportMetadata();
        for(Reports.ReportFilter filter : reportMd.getReportFilters())
        {
            //Apply Filters on the Report records fetched
            if(filter.getColumn() == 'CUST_NAME'){
                filter.setValue(name);
            }
        }
        return new Map<String,Reports.ReportMetadata>{reportId => reportMd};
	}
}