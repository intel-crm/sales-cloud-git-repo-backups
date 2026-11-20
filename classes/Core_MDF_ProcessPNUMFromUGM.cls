public without sharing class Core_MDF_ProcessPNUMFromUGM implements Queueable {
	public Map<Id, Id> intAccToVCIdMap;
    public List<Core_MDF_UserGroupMapping_Log__c> ugmLogs;
    public Map<Id, Id> accountIdToGroupIdWithErrors = new Map<Id, Id>();
    
    public Core_MDF_ProcessPNUMFromUGM(Map<Id, Id> intAccToVCIdMap,List<Core_MDF_UserGroupMapping_Log__c> ugmLogs){
        this.intAccToVCIdMap = intAccToVCIdMap;
        this.ugmLogs = ugmLogs;
    }
    
    public void execute(QueueableContext context){
        try {
            String errorMsg = '';
            Boolean isError = false;
            List<User> userList = [SELECT Id, AccountId FROM User WHERE ContactId IN (SELECT Core_Contact_Id__c FROM Core_Contact_Entitlement__c  WHERE Core_Contact_Id__r.AccountId IN: intAccToVCIdMap.keySet() AND Core_Type__c = 'Entitlement' AND Core_Status__c='Complete' AND Core_Selected__c = TRUE AND Core_Entitlement_Nm__c = 'IPA MDF USER') AND (IsActive = TRUE OR Partner_License_Reclaimed__c = TRUE) LIMIT 50000];            
            if(!userList.isEmpty()){
                Map<Id, User> userMap = new Map<Id, User>(userList);
                Core_MDF_DmlOperationDetails dmlDetails = insertOrUpdatePNUMs(intAccToVCIdMap, userMap, errorMsg, isError);            
                errorMsg = dmlDetails.message;
                isError = dmlDetails.isError;            
                if(dmlDetails.accountIdToGroupId != null){
                    accountIdToGroupIdWithErrors.putAll(dmlDetails.accountIdToGroupId);
                }
            }
            if(isError){
                Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorMsg, 'Core_MDF_Partner_Node_User_Mapping__c');
            }
        
            List<Core_MDF_UserGroupMapping_Log__c> toUpdate = new List<Core_MDF_UserGroupMapping_Log__c>();

            for(Core_MDF_UserGroupMapping_Log__c record : ugmLogs){
                if((!accountIdToGroupIdWithErrors.containsKey(record.Core_MDF_Account_id__c)) || (accountIdToGroupIdWithErrors.containsKey(record.Core_MDF_Account_id__c) && record.Core_MDF_Virtual_Account_id__c != accountIdToGroupIdWithErrors.get(record.Core_MDF_Account_id__c))) {
                    toUpdate.add(new Core_MDF_UserGroupMapping_Log__c(Id = record.Id, Core_MDF_Status_nm__c = 'Completed', Core_MDF_Processed_dtm__c = System.now()));
                }
            }

            if(!toUpdate.isEmpty()){
                Database.update(toUpdate, false);
            }
        } catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    
    public static Core_MDF_DmlOperationDetails insertOrUpdatePNUMs(Map<Id,Id> intAccToVCIdMap, Map<Id, User> userMap, String errorMsg, Boolean isError){

        Core_MDF_DmlOperationDetails dmlDetails = new Core_MDF_DmlOperationDetails();
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumListToInsert = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumListToUpdate = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        Map<Id,Id> usrIdToAccIdMap = new Map<Id,Id>();
        Map<Id, Id> accountIdToVCIdWithErrors = new Map<Id, Id>();
        List<String> detailedErrors = new List<String>();
        
        Map<String, Core_MDF_Partner_Node_User_Mapping__c> existingPnumsMap = new Map<String, Core_MDF_Partner_Node_User_Mapping__c>();
        for(Core_MDF_Partner_Node_User_Mapping__c p : [SELECT Id, Core_MDF_User__c, Core_MDF_Account__c, Core_MDF_Active_Ind__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_User__c IN :userMap.keySet() AND Core_MDF_Active_Ind__c = false]) {
            String key = p.Core_MDF_User__c + '-' + p.Core_MDF_Account__c;
            existingPnumsMap.put(key, p);
        }
        
        for(User usr : userMap.values()){
            if(intAccToVCIdMap.containsKey(usr.AccountId) && intAccToVCIdMap.get(usr.AccountId) != null){
                String key = usr.Id + '-' + intAccToVCIdMap.get(usr.AccountId);
                if(existingPnumsMap.containsKey(key)){
                    Core_MDF_Partner_Node_User_Mapping__c pnumToUpdate = new Core_MDF_Partner_Node_User_Mapping__c(Id = existingPnumsMap.get(key).Id, Core_MDF_Active_Ind__c = true);
                    pnumListToUpdate.add(pnumToUpdate);
                } else {
                    Core_MDF_Partner_Node_User_Mapping__c newPnum = new Core_MDF_Partner_Node_User_Mapping__c();
                    newPnum.Core_MDF_Account__c = intAccToVCIdMap.get(usr.AccountId);
                    newPnum.Core_MDF_User__c = usr.Id;
                    pnumListToInsert.add(newPnum);
                }
                usrIdToAccIdMap.put(usr.Id, usr.AccountId);
            }
        }
        
        if(!pnumListToUpdate.isEmpty()){
            Database.SaveResult[] updateResults = Database.update(pnumListToUpdate, false);
            Map<String, Object> updateResultMap = handleDmlErrors(updateResults,isError,pnumListToUpdate,usrIdToAccIdMap,intAccToVCIdMap,'Update');
            isError = (Boolean) updateResultMap.get('isError') || isError;
            detailedErrors.addAll((List<String>) updateResultMap.get('detailedErrors'));
            accountIdToVCIdWithErrors.putAll((Map<Id, Id>) updateResultMap.get('accountIdToVCIdWithErrors'));
        }
        
        if(!pnumListToInsert.isEmpty()){
            Database.SaveResult[] insertResults = Database.insert(pnumListToInsert, false);
            Map<String, Object> insertResultMap = handleDmlErrors(insertResults,isError,pnumListToInsert,usrIdToAccIdMap,intAccToVCIdMap,'Insert');
            isError = (Boolean) insertResultMap.get('isError') || isError;
            detailedErrors.addAll((List<String>) insertResultMap.get('detailedErrors'));
            accountIdToVCIdWithErrors.putAll((Map<Id, Id>) insertResultMap.get('accountIdToVCIdWithErrors'));
        }
        
        if(isError && !detailedErrors.isEmpty()){
            errorMsg += String.join(detailedErrors, '\n');
        }
        dmlDetails.message = errorMsg;
        dmlDetails.isError = isError;
        dmlDetails.accountIdToGroupId = accountIdToVCIdWithErrors;
        return dmlDetails;
    }

    public static Map<String, Object> handleDmlErrors(Database.SaveResult[] results,Boolean isError, List<Core_MDF_Partner_Node_User_Mapping__c> pnumList,Map<Id,Id> usrIdToAccIdMap, Map<Id,Id> intAccToVCIdMap,String operationType){
        List<String> detailedErrors = new List<String>();
        Map<Id, Id> accountIdToVCIdWithErrors = new Map<Id, Id>();
        
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                isError = true;
                Core_MDF_Partner_Node_User_Mapping__c rec = pnumList[i];
                Id userId = rec.Core_MDF_User__c;
                Id accId = usrIdToAccIdMap.get(userId);
                
                if (accId != null) {
                    accountIdToVCIdWithErrors.put(accId, intAccToVCIdMap.get(accId));
                    detailedErrors.add('<b>Error: PNUM ' + operationType + ' Failed for UserId/VCId</b> => UserId: ' + userId + ' / VCId: ' + intAccToVCIdMap.get(accId) + ' <b>Error Details:</b> ' + results[i].getErrors());
                }
            }
        }
        Map<String, Object> resultMap = new Map<String, Object>{'isError' => isError,'detailedErrors' => detailedErrors,'accountIdToVCIdWithErrors' => accountIdToVCIdWithErrors};
            return resultMap;
    }
}