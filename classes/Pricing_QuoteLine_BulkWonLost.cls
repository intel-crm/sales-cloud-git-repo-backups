/**
 * @description       : Class to update quotelines to Won/Lost from Bulk Screen
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 05-11-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_QuoteLine_BulkWonLost {
    private static User currentUser = [select id,(select PermissionSet.Name from PermissionSetAssignments) from User where id =: UserInfo.getUserId()];

    /**
    * @description method called from LWC to process csv data
    * @author Sandeep Chamate | 06-07-2023 
    * @param base64Data - csv Data uploaded
    * @param objectName - bulkWonLost
    * @return String 
    **/
    @AuraEnabled
    public static String processWonLost(String base64Data, String objectName){
        Map<String, SBQQ__QuoteLine__c> QLMap = New Map<String, SBQQ__QuoteLine__c>();
        String data = JSON.deserializeUntyped(base64Data).toString();
        data=String.escapeSingleQuotes(data);
        List<String> lstCSVLines = data.split('\n');
        integer errorRow = 0;
        try{
            for (Integer i=1;i<lstCSVLines.size();i++){
                errorRow = i;
                list<String> columnValues = new list<String>();
                columnValues = lstCSVLines[i].split(',');
                SBQQ__QuoteLine__c QL = New SBQQ__QuoteLine__c();
                QL.Pricing_Status_Nm__c = String.isBlank((columnValues[3]).replace('"',''))? Null : (columnValues[3]).replace('"','');
                QL.Pricing_Won_Lost_Comments_Txt__c = String.isBlank((columnValues[4]).replace('"',''))? Null : (columnValues[4]).replace('"','');
                QL.Pricing_Lost_Reason_Nm__c = String.isBlank((columnValues[5]).replace('"',''))? Null : (columnValues[5]).replace('"','');
                if((columnValues[0]).replace('"','').trim() != null && (columnValues[0]).replace('"','').trim() != '' ){
                    QLMap.put((columnValues[0]).replace('"','').trim(),QL);
                }
            }
            Pricing_QuoteLine_BulkWonLostBatch bulkWonLost = new Pricing_QuoteLine_BulkWonLostBatch(QLMap);
            Database.executeBatch(bulkWonLost, Integer.valueOf(Label.Pricing_QuoteLine_BulkWonLost_BatchSize));
        } catch (Exception e) {
            errorRow = errorRow +1;
            Pricing_Tender_Utility.logError(e); 
            return 'Error while uploading File - On Row: '+errorRow+' - '+e;
        }
        return 'Operation Completed';
    }

    /**
    * @description Method to validate all quotelines befor marking won/lost from uploaded file
    * @author Sandeep Chamate | 06-07-2023 
    * @param quoteLineNumberMap - qli number to csv data Map
    **/
    public static Map<String, String> validateWonLostQuoteLines(Map<String,SBQQ__QuoteLine__c> quoteLineNumberMap, List<SBQQ__QuoteLine__c> quoteLineList){
        Map<Id,SBQQ__QuoteLine__c> quoteLineIdMap = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id,SBQQ__QuoteLine__c> quoteLineIdtoRecordMap = new Map<Id, SBQQ__QuoteLine__c>();
        Set<Id> quoteLineIdSet = new set<Id>();
        Set<Id> hasCRQuoteLineSet = new set<Id>();
        List<SBQQ__QuoteLine__c> quoteLineListtoUpdate = new List<SBQQ__QuoteLine__c>();
        Map<String, String> quoteLineSuccessErromMap = new Map<String, String>();
        Set<Id> restrictedAccountId = new Set<Id>();
        Boolean isRPMUser = userHasValidPermissionSet(new Set < String > {
            Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager}) ? true : false;
        Map<string, string> lostReasonValues = Pricing_QuoteLineController.getLostReasonValue();

        try{
            for(Pricing_QuoteLine_WonLoss_Restriction__mdt rec : [SELECT Id,Pricing_Account_Id__c FROM Pricing_QuoteLine_WonLoss_Restriction__mdt WHERE Pricing_IsActive_Ind__c=true]){
                restrictedAccountId.add(rec.Pricing_Account_Id__c);
            }

            for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                if(quoteLineNumberMap.containsKey(quoteLine.Pricing_Quote_Line_Number__c)){
                    quoteLineIdMap.put(quoteLine.Id, quoteLineNumberMap.get(quoteLine.Pricing_Quote_Line_Number__c));
                    quoteLineIdSet.add(quoteLine.Id);
                    quoteLineIdtoRecordMap.put(quoteLine.Id, quoteLine);
                } 
            }

            for(SBQQ__QuoteLine__c qli : [SELECT Id, Pricing_Quote_Line_Number__c, Pricing_Reference_Quote_Line_Nbr__c FROM SBQQ__QuoteLine__c 
                                            WHERE Pricing_Reference_Quote_Line_Nbr__c IN: quoteLineIdSet AND Pricing_Status_Nm__c != 'Rejected']){
                hasCRQuoteLineSet.add(qli.Pricing_Reference_Quote_Line_Nbr__c);
            }
            Map<Id, String> qlIdMsgMap = Pricing_QuoteLineController.isNotUnifiedQuoteLineBulk(quoteLineIdSet);

            for(Id qliId : quoteLineIdMap.keySet()){
                String errorMsg = '';
                String resMsg = '';
                String dealId = '';
                String status = '';

                //check for existing CR
                if(hasCRQuoteLineSet.contains(qliId)){
                    errorMsg += Label.Pricing_CR_Reference_Status_Change_Message_Trigger + '; ';
                }

                //check for restricted Account
                if(!isRPMUser && restrictedAccountId.contains(quoteLineIdtoRecordMap.get(qliId).SBQQ__Quote__r.SBQQ__Account__c)){
                    errorMsg += Label.Pricing_WonLost_AccountRestrict_RA_Error_Message + '; ';
                }

                //check if status is blank or status is not won/lost.
                if(String.isBlank(quoteLineIdMap.get(qliId).Pricing_Status_Nm__c)){
                    errorMsg += 'Quote Line Status cannot be blank.' + '; ';
                }
                else if(quoteLineIdMap.get(qliId).Pricing_Status_Nm__c.toLowerCase() != 'won' && quoteLineIdMap.get(qliId).Pricing_Status_Nm__c.toLowerCase() != 'lost'){
                    errorMsg += 'Quote Line Status should be Won/Lost.' + '; ';
                }

                //check if current status is Approved.
                if(quoteLineIdtoRecordMap.get(qliId).Pricing_Status_Nm__c != Label.Pricing_Tender_QuoteLine_Status_Approved){
                    errorMsg += Label.Pricing_Restrict_Bulk_Won_Lost_Error + '; ';
                }

                //check for unification if marking as won
                if(qlIdMsgMap.containsKey(qliId) && !String.isBlank(quoteLineIdMap.get(qliId).Pricing_Status_Nm__c)){
                    errorMsg = quoteLineIdMap.get(qliId).Pricing_Status_Nm__c.toLowerCase() == 'won' ? errorMsg + qlIdMsgMap.get(qliId) + '; ' : errorMsg;
                }

                //non latin characters check for won/lost comments
                if(quoteLineIdMap.get(qliId).Pricing_Won_Lost_Comments_Txt__c != null && !String.isEmpty(quoteLineIdMap.get(qliId).Pricing_Won_Lost_Comments_Txt__c)){
                    if(Pricing_Tender_Utility.validateNonLatinChars(quoteLineIdMap.get(qliId).Pricing_Won_Lost_Comments_Txt__c)){
                        errorMsg += Label.Pricing_Non_Latin_Char_Validation_Error + '; ';
                    }
                }  
                
				//check 1000 characters for won/lost comments
				if(!String.isEmpty(quoteLineIdMap.get(qliId).Pricing_Won_Lost_Comments_Txt__c) && quoteLineIdMap.get(qliId).Pricing_Won_Lost_Comments_Txt__c.length() > 1000){
					errorMsg += 'Won/Lost Comments cannot be more than 1000 characters.' + '; ';
				}
                
                //check When 'Other' is selected in the Lost Reason field, Lost reason must be entered in the Comments field.
                if(!String.isBlank(quoteLineIdMap.get(qliId).Pricing_Status_Nm__c) && quoteLineIdMap.get(qliId).Pricing_Status_Nm__c.toLowerCase() == 'lost' &&  !String.isEmpty(quoteLineIdMap.get(qliId).Pricing_Lost_Reason_Nm__c) 
                && (quoteLineIdMap.get(qliId).Pricing_Lost_Reason_Nm__c).equals('Other') && (String.isEmpty(quoteLineIdMap.get(qliId).Pricing_Won_Lost_Comments_Txt__c) || quoteLineIdMap.get(qliId).Pricing_Won_Lost_Comments_Txt__c == '')){
                    errorMsg += Label.Pricing_Tender_Lost_Error.replace(',',';') + '; ';                                          
                }
                
                if(quoteLineIdtoRecordMap.get(qliId).SBQQ__Quote__r.Pricing_On_Hold_Cb__c) {
                    errorMsg += Label.Pricing_Quote_Line_On_Hold_Error_Msg +' ; '; 
                }

                //check Lost Reason cannot be edited when status is won.
                if(!String.isBlank(quoteLineIdMap.get(qliId).Pricing_Status_Nm__c) && quoteLineIdMap.get(qliId).Pricing_Status_Nm__c.toLowerCase() == 'won' &&  !String.isEmpty(quoteLineIdMap.get(qliId).Pricing_Lost_Reason_Nm__c)){
                    errorMsg += Label.Pricing_LostReason_WonStatus_ErrorMsg + '; ';                                      
                }
                
                //Check When Lost Reason Invalid Values are entered
                if(!String.isEmpty(quoteLineIdMap.get(qliId).Pricing_Lost_Reason_Nm__c) && !lostReasonValues.values().contains(quoteLineIdMap.get(qliId).Pricing_Lost_Reason_Nm__c)){
                    errorMsg += 'Invalid value for Lost Reason ; ';                                      
                }
                
                dealId = String.isBlank(quoteLineIdtoRecordMap.get(qliId).Pricing_Deal_RFQ_Id__c) ? String.valueOf('') : quoteLineIdtoRecordMap.get(qliId).Pricing_Deal_RFQ_Id__c;
                status = String.isBlank(quoteLineIdMap.get(qliId).Pricing_Status_Nm__c) ? String.valueOf('') : quoteLineIdMap.get(qliId).Pricing_Status_Nm__c;
                resMsg = quoteLineIdtoRecordMap.get(qliId).Pricing_Quote_Line_Number__c + ',' + status + ',' + dealId + ',';
                system.debug('errorMsg:'+errorMsg);
                if(String.isBlank(errorMsg)){
                    SBQQ__QuoteLine__c qlitoUpdate = new SBQQ__QuoteLine__c();
                    qlitoUpdate.Id = qliId;
                    qlitoUpdate.Pricing_Status_Nm__c = quoteLineIdMap.get(qliId).Pricing_Status_Nm__c.toLowerCase() == 'won' ? Label.Pricing_Tender_QuoteLine_Status_Won : Label.Pricing_Tender_QuoteLine_Status_Lost;
                    qlitoUpdate.Pricing_Won_Lost_Comments_Txt__c = quoteLineIdMap.get(qliId).Pricing_Won_Lost_Comments_Txt__c;
                    qlitoUpdate.Pricing_Lost_Reason_Nm__c = quoteLineIdMap.get(qliId).Pricing_Lost_Reason_Nm__c;
                    quoteLineListtoUpdate.add(qlitoUpdate);
                    resMsg += 'Success';
                    quoteLineSuccessErromMap.put(qliId, resMsg);
                }
                else{
                    resMsg += errorMsg.removeEnd('; ');
                    quoteLineSuccessErromMap.put(qliId, resMsg);
                }
            }
            system.debug('quoteLineListtoUpdate:'+quoteLineListtoUpdate);
            if(quoteLineListtoUpdate.size() > 0){
                Pricing_RecordJobHandler.isStopCalculatorForBulkWon = true;
                SBQQ.TriggerControl.disable();
                update quoteLineListtoUpdate;
                SBQQ.TriggerControl.enable();
            }
        }
        catch(Exception e){
            Pricing_Tender_Utility.logError(e); 
        }
        return quoteLineSuccessErromMap;
    }

    private static Boolean userHasValidPermissionSet(Set < string > permissionSets) {
        for(PermissionSetAssignment psa: currentUser.PermissionSetAssignments){
            if(permissionSets.contains(psa.PermissionSet.Name)){
                return true;
            }
        }
        return false;
    }

    /**
    * @description method to perform action from future method -  updateAtRiskForTenderQuotes
    * @author Sandeep Chamate | 07-11-2023 
    **/
    public static void updateAtRiskForWonQuotelines(Map<String,String> quoteLineIdsMap){        
        try{            
            Set<Id> oppIds = new Set<Id>();
            Set<Id> quoteIds = new set<Id>();
            List<OpportunityLineItem> opportunitylinelist = new list<OpportunityLineItem>();
            // Get the list of QuotelineItems of the respective Quotes
            List<SBQQ__QuoteLine__c> quoteLineList = [Select Id,SBQQ__Product__c,SBQQ__Product__r.NAME,SBQQ__Quote__r.Pricing_Quote_Program_Nm__c,Pricing_Status_Nm__c,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,Pricing_Quote_Program_Nm__c from SBQQ__QuoteLine__c 
                                                        where Id IN : quoteLineIdsMap.keyset() AND SBQQ__Quote__r.SBQQ__Opportunity2__c != NULL 
                                                        AND ((SBQQ__Quote__r.Pricing_Quote_Program_Nm__c = : system.label.Pricing_Tender_Quote_Program)AND (Pricing_Status_Nm__c = : system.label.Quote_Pricing_Status OR Pricing_Status_Nm__c = : system.label.Pricing_Status_Won))];
                      
            for(SBQQ__QuoteLine__c qline : quoteLineList) {
                quoteIds.add(qline.SBQQ__Quote__c);  
                oppIds.add(qline.SBQQ__Quote__r.SBQQ__Opportunity2__c);
            }                      
            opportunitylinelist = [SELECT Id,Core_At_Risk__c,Core_At_Risk_Status__c,Product2Id,Product2.NAME,UnitPrice,TotalPrice FROM OpportunityLineItem 
                                    WHERE OpportunityId IN : oppIds ];        
            list<OpportunityLineItem> oppupdatelist =new list<OpportunityLineItem>(); 
            if(quoteLineList.size() >0){
                for(SBQQ__QuoteLine__c quoteline : quoteLineList){ 
                    if(opportunitylinelist.size()>0) {
                        for(OpportunityLineItem Oppline : opportunitylinelist) { 
                            if(Oppline.Product2Id == quoteLine.SBQQ__Product__c && Oppline.Core_At_Risk__c && (Oppline.Core_At_Risk_Status__c == system.label.At_Risk_Status_New || Oppline.Core_At_Risk_Status__c == system.label.At_Risk_Status_In_Progress))  {   
                                Oppline.Core_At_Risk_Status__c = system.label.At_Risk_Status_Closed; 
                                oppupdatelist.add(Oppline);
                            }    
                        }
                    }// End if (opportunitylinelist)
                    else {
                        Continue; 
                    } 
                } 
                Database.SaveResult[] srList=  Database.update(oppupdatelist);  
            }
        }
        catch (Exception ex){
            Pricing_Tender_Utility.logError(ex);
        }
    }

}