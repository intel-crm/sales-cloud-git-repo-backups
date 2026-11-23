public class PRM_DELETETestBatch implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,Core_Intel_Partner_Alliance_PartnerGroup__c FROM Account where Core_Intel_Partner_Alliance_PartnerGroup__c=TRUE and id IN('0011J0000186GNXQA2','0011J00001BWBttQAH','0011J00001BXJL4QAP','0011J00001BXJMJQA5','0011J00001BYQXHQA5','0011J00001DGhY2QAL','0011J00001Ew80EQAR','0011J000017fAqhQAE','0011J000017g41GQAQ','0011J000017gpKCQAY')]);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<PRM_IPAMembership_Attributes__c> membershipRecords = new List<PRM_IPAMembership_Attributes__c>();
        // PRM_IPAMembership_Attributes__c membershipRecord = new PRM_IPAMembership_Attributes__c();
        // membershipRecord.PRM_Account_Id__c = account.Id;
        Set<Id> accountIds = new Set<Id>();
        for (Account account : scope) {
            accountIds.add(account.Id);
            system.debug('accountIds--'+accountIds);
        }
        List<PRM_Profile_Responses__c> accProfResList = [SELECT PRM_Account_Id__c, PRM_Response_Txt__c,PRM_Question_Display_Text__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c,PRM_Reason_Text__c,Unique_Key__c
                                                          FROM PRM_Profile_Responses__c WHERE PRM_Account_Id__c IN :accountIds];
        system.debug('accProfResList--'+accProfResList);
        Map<Id, List<PRM_Profile_Responses__c>> accountToResponsesMap = new Map<Id, List<PRM_Profile_Responses__c>>();
        for (PRM_Profile_Responses__c response : accProfResList) {
            if (!accountToResponsesMap.containsKey(response.PRM_Account_Id__c)) {
                accountToResponsesMap.put(response.PRM_Account_Id__c, new List<PRM_Profile_Responses__c>());
                system.debug('accountToResponsesMap 1--'+accountToResponsesMap);
            }
            accountToResponsesMap.get(response.PRM_Account_Id__c).add(response);
            system.debug('accountToResponsesMap 2--'+accountToResponsesMap);
        }
        for (Account accRec : scope) {
            system.debug('accRec--'+accRec);
            PRM_IPAMembership_Attributes__c membershipRecord = new PRM_IPAMembership_Attributes__c();
            membershipRecord.PRM_Account_Id__c = accRec.Id;
            //add recordtype
            Boolean hasRelevantQuestionCode = false;
            if (accountToResponsesMap.containsKey(accRec.Id)) {
                system.debug('Inside if');
                for (PRM_Profile_Responses__c response : accountToResponsesMap.get(accRec.Id)) {
                   String questionCode = response.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c;
                   String responseText = response.PRM_Response_Txt__c;
                   String reasonText = response.PRM_Reason_Text__c;
                    if(questionCode=='PRM_Opt_In')
                    {    
                        hasRelevantQuestionCode = true;
                        if(PRM_IPAR_ProfileResponse_Utility.isValidDate(responseText)){
                            membershipRecord.PRM_Points_Opt_in_Dt__c = Date.valueof(responseText);  
                        }else{
                            membershipRecord.PRM_Points_Opt_in_Ind__c = boolean.valueof(responseText);
                        } 
                        system.debug('membershipRecord---'+membershipRecord);                        
                    }
                    if(questionCode=='PRM_Point_Not_Eligible') 
                    {
                        hasRelevantQuestionCode = true;
                        if(PRM_IPAR_ProfileResponse_Utility.isValidDate(responseText)){
                            membershipRecord.PRM_Points_Not_Eligible_Dt__c = Date.valueof(responseText);  
                        }else{
                            membershipRecord.PRM_Points_Not_Eligible_Ind__c = boolean.valueof(responseText);
                        }                          
                    }
                    if(questionCode=='PRM_Status')
                    {
                        hasRelevantQuestionCode = true;
                        membershipRecord.PRM_Point_Status_Txt__c = responseText;
                        membershipRecord.PRM_Point_Status_Reason_Txt__c = reasonText;  
                    }
                    if(questionCode=='PRM_Status_date')
                    {
                        hasRelevantQuestionCode = true;
                        membershipRecord.PRM_Point_Status_Dt__c = Date.valueof(responseText);     
                    }
                    //manual field check here
                    if(questionCode=='PRM_ODM_Whitebox_Point')
                    {
                        hasRelevantQuestionCode = true;
                        if(PRM_IPAR_ProfileResponse_Utility.isValidDate(responseText)){
                            membershipRecord.PRM_ODM_whiteboxPointEarning_excl_Dt__c = Date.valueof(responseText);  
                        }else{
                            string str = null;
                            boolean bl = boolean.valueOf((responseText==null?'':responseText));
                            membershipRecord.PRM_ODM_whiteboxPointEarning_excl_Ind__c = boolean.valueof(responseText);
                        }                            
                    }
                    if(questionCode=='PRM_Branded_Point')
                    {
                        hasRelevantQuestionCode = true;
                        if(PRM_IPAR_ProfileResponse_Utility.isValidDate(responseText)){
                            membershipRecord.PRM_Branded_Point_earning_excl_Dt__c = Date.valueof(responseText);  
                        }else{
                            membershipRecord.PRM_Branded_Point_earning_excl_Ind__c = boolean.valueof(responseText);
                        }                            
                    }
                    if(questionCode=='PRM_Component_point')
                    {
                        hasRelevantQuestionCode = true;
                        if(PRM_IPAR_ProfileResponse_Utility.isValidDate(responseText)){
                            membershipRecord.PRM_Component_Point_earning_excl_Dt__c = Date.valueof(responseText);  
                        }else{
                            membershipRecord.PRM_Component_Point_earning_excl_Ind__c = boolean.valueof(responseText);
                        }                            
                    }
                }
            }
            if (hasRelevantQuestionCode) {
                membershipRecords.add(membershipRecord);
            }
        }
        //upsert records
        Database.UpsertResult [] saveResults = Database.upsert(membershipRecords, false);
        List<PRM_IPAMembership_Attributes__c> failedRecords = new List<PRM_IPAMembership_Attributes__c>();
        Map<Id, String> errorMessages = new Map<Id, String>();
        // Process the results
        for (Integer i = 0; i < saveResults.size(); i++) {
            Database.UpsertResult sr = saveResults[i];
            if (sr.isSuccess()) {
                System.debug('Record ' + membershipRecords[i].Id + ' upserted successfully.');
            } else {
            // Handle the error for the failed record
            failedRecords.add(membershipRecords[i]);
            String errorMessage = '';
            for (Database.Error err : sr.getErrors()) {
                errorMessage += err.getMessage() + '; ';
                System.debug('Error for record ' + membershipRecords[i].Id + ': ' + err.getMessage());
            }
            errorMessages.put(membershipRecords[i].Id, errorMessage);
            }
        }
        if (!failedRecords.isEmpty()) {
        // Log errors
            for (PRM_IPAMembership_Attributes__c failedRecord : failedRecords) {
                String errorMsg = errorMessages.get(failedRecord.Id);
                System.debug('Failed record ID: ' + failedRecord.Id + ', Error: ' + errorMsg);
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }   
}