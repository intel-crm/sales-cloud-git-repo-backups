/*********************************************************************************************************************************************************************************
* Class Name  : Core_MDF_Bulk_TransactionServiceHandler 
* Test class : Core_MDF_Bulk_Transaction_Test
* Version     : 1.0 
* Created Date: 4-26-2021
* Modification Log :
* Developer                         Date                          Description
  Accenture - NZ				06/23/2021					Bulk Data Insert/Update
**********************************************************************************************************************************************************************************/
public without sharing class Core_MDF_Bulk_TransactionServiceHandler {
    
    public static String logEntryMsg = '';
    public static final String SOBJECT_TYPE = 'User';
   
/*****************************************************************************************************
Method Name :   upsertRecords 
@return     :   NULL
@parameters :   list of Core_MDF_Bulk_Transaction__e platform event record
Description :   Bulk Data Insert/Update
Added By    :   Accenture - NZ - 06/23/2021	
******************************************************************************************************/
    public static void upsertRecords(List<Core_MDF_Bulk_Transaction__e> newList){
        try{
            set<Id> recordIds = new set<Id>();
	    set<Id> escalationIds = new set<Id>();
            Map<String,List<Sobject>> sobjectsMap = new Map<String,List<Sobject>>();
            for(Core_MDF_Bulk_Transaction__e eventObj: newList){  
                //Get the Object Name 
                String objectName = eventObj.Core_MDF_Object_Name__c;
                /* Call global describe to get the map of string to token. */
                Map<String, Schema.SObjectType> glblDesc = Schema.getGlobalDescribe();
		 List<String> MDFBudgetTypes = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetReversal_BudgetTypes').split(';');
                Schema.SObjectType sObjctTyp = glblDesc.get(objectName);
                Sobject sObj = sObjctTyp.newSobject();                
                //Fetch Data from JSON
                sObj = (sObject)JSON.deserialize(eventObj.Core_MDF_JSON_Data__c, sObject.Class);                
                //sObjList.add(sObj);
                if(String.isBlank(eventObj.Core_MDF_Action_Name__c))
                {
                    if(sobjectsMap.containsKey(objectName)){
                        List<Sobject> rectToAdd = sobjectsMap.get(objectName);
                        rectToAdd.add(sObj);
                        sobjectsMap.put(objectName,rectToAdd);
                    } else{
                        sobjectsMap.put(objectName, new List<Sobject>{sObj});
                    }
                }
                else
                {
                    if(eventObj.Core_MDF_Action_Name__c == 'Cancelled Claim'){
                        PartnerFundClaim pfcObj = (PartnerFundClaim)sObj;
                        if(MDFBudgetTypes.contains(pfcObj.Core_MDF_Budget_Type_Options_Nm__c)){
                            recordIds.add(pfcObj.RequestId);
                        }
                        if(pfcObj.Core_MDF_Escalation_Id__c != null){
                            escalationIds.add(pfcObj.Core_MDF_Escalation_Id__c);
                        }
                        
                    }
                }
                
            } 
            if(sobjectsMap != null && !sobjectsMap.isEmpty()){
                upsertData(sobjectsMap);
            }
            
            if(!escalationIds.isEmpty()){
                Core_MDF_PFR_PlatformEventHandler.updateEscalationStatus(escalationIds);
            }
            
            if(!recordIds.isEmpty()){
                Core_MDF_PFR_PlatformEventHandler.updateActivityAmount(recordIds);
            }
            
        }
        catch(exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);         
        }         
    }
    
    public static void insertUserGroupMappingRecords(Map<Id,Boolean> recsToInsertMap){
        List<Core_MDF_UserGroupMapping_Log__c> logobjectList = new List<Core_MDF_UserGroupMapping_Log__c>();
        try{
            for(id userid: recsToInsertMap.keyset()){
                Core_MDF_UserGroupMapping_Log__c logobject = new Core_MDF_UserGroupMapping_Log__c();
                logobject.Core_MDF_User_id__c= userid;
                logobject.Core_MDF_Action_nm__c = 'Marketing User Update';
                logObject.Core_MDF_Status_nm__c= recsToInsertMap.get(userid)? 'Completed' : 'Action Required';
                logObject.Core_MDF_Processed_dtm__c = system.now();
                logobject.Core_MDF_Error_Message_txt__c = !recsToInsertMap.get(userid)? 'Marketing User update failed': '';
                logobjectList.add(logobject);   
            }
            if(logobjectList != null && !logobjectList.isEmpty()){
                Database.SaveResult[] saveResult = Database.insert(logobjectList,false);   
            }   
        }catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        
    }    

    //Test with 200 record with 3 object at time and records was updated.
    public static void upsertData(Map<String,List<Sobject>> sobjectsMap) {
        //if(!sobjectsMap.isEmpty()) {
        try{
            Map<Id,Boolean> userToUpdateFlag = new Map<Id,Boolean>();
            List<SObject> allRecords = new List<SObject>();

            for(String objName:sobjectsMap.keySet()) {
                String listType = 'List<' + objName + '>';  
                List<SObject> sObjList = (List<SObject>)Type.forName(listType).newInstance();
                sObjList.addAll(sobjectsMap.get(objName));
               
                if(sObjList != null && !sObjList.isEmpty()){
                    allRecords.addAll(sObjList);
                }
            }

           if (!allRecords.isEmpty()) {
                insertUserGroupMappingRecords(allRecords, userToUpdateFlag);
            }
        }
        catch(exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);         
        }
        //}
    }

    public static void insertUserGroupMappingRecords(List<SObject> allRecords, Map<Id,Boolean> userToUpdateFlag) {
        List<Database.UpsertResult> saveList = Database.upsert(allRecords, false);
        for (Database.UpsertResult sr : saveList) {
            if (sr.isSuccess()) {
                String objName = sr.id.getSObjectType().getDescribe().getName();
                if (objName == SOBJECT_TYPE) {
                    userToUpdateFlag.put(sr.getId(), true);
                }
            }
            else {
                if (!sr.getErrors().isEmpty()) {
                    Database.Error error = sr.getErrors().get(0);
                    if (error.getFields() != null && error.getFields().size() > 0) {
                        String objName = error.getFields()[0];
                        if (objName == SOBJECT_TYPE) {
                            userToUpdateFlag.put(sr.getId(), false);
                        }
                    }
                }
            }
        }

        if (!userToUpdateFlag.isEmpty()) {
                insertUserGroupMappingRecords(userToUpdateFlag);
        }
    }
}