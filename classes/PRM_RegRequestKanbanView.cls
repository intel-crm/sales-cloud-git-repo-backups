/*********************************************************************************************************************
Class Name    : PRM_RegRequestKanbanView
Version       : 1.0
Created Date  : OCT 2018
Function      : Returns picklist values of a particular field based on the recordId

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Kushal Soni               10/12/2018              Returns picklist values of a particular field based on the recordId

*********************************************************************************************************************/
public with sharing class PRM_RegRequestKanbanView {
    
    /**
    *  @description      : Get Registration Request record on the basis of Record Id
    *  @name             : getRegRecord
    *  @param            : String
    *  @throws exception : NONE
    **/
    @AuraEnabled
    public static PRM_Registration_Request__c getRegRecord(String recordId){
        List<Schema.FieldSetMember> fieldSetFSM = Schema.SObjectType.PRM_Registration_Request__c.FieldSets.PRM_Kanban_View.getFields();
        String targetObjectId = '';
        if(recordId.startsWith('04i')){
          //if(!test.isRunningTest()){
             String processInstanceId = [Select ProcessInstanceId from ProcessInstanceWorkitem where Id =: recordId].ProcessInstanceId;targetObjectId = [Select TargetObjectId from ProcessInstance where Id =: processInstanceId].TargetObjectId;
          //}
        }
        else{
             targetObjectId = recordId;
        }
        String commaSepratedFields= '';
        for(Schema.FieldSetMember f : fieldSetFSM) {
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = f.getFieldPath();
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + f.getFieldPath();
            }
        }
        String query = 'select ' + commaSepratedFields + ' from PRM_Registration_Request__c where Id =: targetObjectId';
        PRM_Registration_Request__c lstObj = Database.query(query);
        return lstObj; 
       //PRM_Registration_Request__c regObj = [Select PRM_Email_Verified_Cri1__c, PRM_DeDup_Cri2__c, PRM_LegalAgree_Cri3__c from PRM_Registration_Request__c where Id =: recordId];
       //return regObj;
    }
    /**
    *  @description      : get map of API Name and Labels from the fieldset
    *  @name             : getFieldMembers
    *  @param            : NONE
    *  @throws exception : NONE
    **/
    @AuraEnabled
    public static Map<String, String> getFieldMembers(){
        Map<String, String> fieldSetMap = new Map<String, String>();
        List<Schema.FieldSetMember> fieldSetFSM = Schema.SObjectType.PRM_Registration_Request__c.FieldSets.PRM_Kanban_View.getFields();
        for(Schema.FieldSetMember f : fieldSetFSM) {
            fieldSetMap.put(f.getFieldPath(), f.getLabel());
        }
        return fieldSetMap;
    }
    
}