/****************************************************************************************************************************************
* Class Name  : Core_MDF_ApprovalCriteriaHelper 
* Version     : 1.0 
* Created Date: 08-31-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar K        08/31/2018                    Created Core_MDF_ApprovalCriteriaHelper to set dynamic picklist values.
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ApprovalCriteriaHelper {

/****************************************************************************************************************************************
    Method Name:                                             getAllFields
    @return  :                                               List of string
    @parameters:                                             SObject as string
    Description:                                             Returns list of fields with api name and label of object.
    Added By:                                                Accenture – Shridhar K  -  08/31/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        08/31/2018                 Created.
*****************************************************************************************************************************************/ 
    @AuraEnabled
    public static List<String> getAllFields(String sObjectName){
    
    	Map<String,Schema.SObjectType> allObjectsMap = Schema.getGlobalDescribe();
        list<String> lstFields = new list<String>();
        
        Schema.SObjectType sObj = allObjectsMap.get(sObjectName);
        Schema.DescribeSObjectResult sObjRes = sObj.getDescribe();
        Map<String,Schema.SObjectField> sObjFieldMap = sObjRes.fields.getMap();
        
        for(String str : sObjFieldMap.keySet()){
            DescribeFieldResult describe = sObjFieldMap.get(str).getDescribe();
            lstFields.add(describe.getLabel()+'#;'+describe.getName());
        }
        
        lstFields.sort();
        
        return lstFields;
    }
    
/****************************************************************************************************************************************
    Method Name:                                             getAllObjects
    @return  :                                               Map with all object's api name as key and value as object label 
    @parameters:                                             --
    Description:                                             Return map with all object's api name as key and value as object label 
    Added By:                                                Accenture – Shridhar K  -  09/12/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        09/12/2018                 Created.
*****************************************************************************************************************************************/ 
    @AuraEnabled
    public static list<String> getAllObjects(){
    
        Map<String,Schema.SObjectType> allObjectsMap = Schema.getGlobalDescribe();
        List<String> objList = new list<String>();
       
        
        List<String> objApiNameLst = Core_MDF_CCP_ConstantClass.OBJECT_API_NAME_LIST;
        // for(Core_MDF_Approval_Object_List__mdt objName : [SELECT Id, Name, Core_MDF_Object_API_Name__c 
        //                                                   FROM Core_MDF_Approval_Object_List__mdt LIMIT 10000]){
        //     if(allObjectsMap.containsKey(objName.Core_MDF_Object_API_Name__c)){
        //         DescribeSObjectResult describe = allObjectsMap.get(objName.Core_MDF_Object_API_Name__c).getDescribe();
        //         objList.add(describe.getLabel()+'#;'+describe.getName());                
        //     }
        // }
        //updated the code for the change of Custom Metadata to Custom Settings - Akanksha(WW32 2024)
        for(String objApiName : objApiNameLst){
            if(allObjectsMap.containsKey(objApiName)){
                DescribeSObjectResult describe = allObjectsMap.get(objApiName).getDescribe();
                objList.add(describe.getLabel()+'#;'+describe.getName());                
            }
        }
        objList.sort();
        return objList;
    } 
    
/****************************************************************************************************************************************
    Method Name:                                             createApprovalCriteria
    @return  :                                               Approval Criteria Id
    @parameters:                                             Instance of Sobject
    Description:                                             Return Approval Criteria id 
    Added By:                                                Accenture – Shridhar K  -  08/31/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        0/31/2018                  Created.
*****************************************************************************************************************************************/     
    @AuraEnabled
    public static Id updateApprovalCriteria(Core_MDF_Criteria__c approvalCriteria){
        try{
            Database.upsert(approvalCriteria);
        }
        catch(Exception e){ throw new AuraHandledException(e.getMessage()); 
            
        }
        return approvalCriteria.Id;
    }
    
/****************************************************************************************************************************************
    Method Name:                                             getCriteria
    @return  :                                               Approval Criteria 
    @parameters:                                             Approval Criteria Id
    Description:                                             Returns Approval Criteria 
    Added By:                                                Accenture – Shridhar K  -  08/31/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        0/31/2018                  Created.
*****************************************************************************************************************************************/      
    @AuraEnabled
    public static Core_MDF_Criteria__c getCriteria(Id recId){
        
        Core_MDF_Criteria__c crtAppr = [SELECT Id, Name, Core_MDF_Active__c, Core_MDF_Approval_Process__c, 
                                        Core_MDF_Approval_Type__c, Core_MDF_Approvers_Count__c, Core_MDF_Field_Name_1__c, 
                                        Core_MDF_Field_Name_2__c,Core_MDF_Field_Name_3__c,Core_MDF_Field_Name_4__c,
                                        Core_MDF_Field_Name_5__c,Core_MDF_Field_Name_6__c, Core_MDF_Field_Name_7__c,
                                        Core_MDF_Field_Name_8__c, Core_MDF_Field_Name_9__c, Core_MDF_Field_Name_10__c,
                                        Core_MDF_Number_Of_Steps__c, Core_MDF_Object_Type__c, Core_MDF_Operator_1__c,
                                        Core_MDF_Operator_2__c, Core_MDF_Operator_3__c,Core_MDF_Operator_4__c,
                                        Core_MDF_Operator_5__c, Core_MDF_Operator_6__c, Core_MDF_Operator_7__c,
                                        Core_MDF_Operator_8__c, Core_MDF_Operator_9__c, Core_MDF_Operator_10__c,
                                        Core_MDF_Sub_Type__c, Core_MDF_Value_1__c,Core_MDF_Value_2__c,
                                        Core_MDF_Value_3__c,Core_MDF_Value_4__c, Core_MDF_Value_5__c,
                                        Core_MDF_Value_6__c, Core_MDF_Value_7__c, Core_MDF_Value_8__c,
                                        Core_MDF_Value_9__c, Core_MDF_Value_10__c, Core_MDF_Approval_Criteria_Ref_Code_txt__c FROM Core_MDF_Criteria__c WHERE Id =:recId LIMIT 10000];
       return crtAppr;
    }

/****************************************************************************************************************************************
    Method Name:                                             getCriteriaRule
    @return  :                                               Criteria Rules list associated with the approver set
    @parameters:                                             Approver Set Record Id
    Description:                                             Returns Criteria Rules list associated with the approver set
    Added By:                                                Accenture – Shridhar K  -  09/13/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        09/13/2018                 Created.
*****************************************************************************************************************************************/      
    @AuraEnabled
    public static list<Core_MDF_Criteria_Rule__c> getCriteriaRule(Id recId){
        list<Core_MDF_Criteria_Rule__c> crtRuleList = [SELECT Id, Name, Core_MDF_Approver__c, Core_MDF_Field_Name__c, 
                                                       Core_MDF_Operator__c, Core_MDF_Value__c FROM Core_MDF_Criteria_Rule__c
                                                       WHERE Core_MDF_Approver__c =:recId LIMIT 10000];
       return crtRuleList;
    }    

/****************************************************************************************************************************************
    Method Name:                                             getSObjectType
    @return  :                                               SOject Type of Approval Criteria
    @parameters:                                             Approver Id
    Description:                                             Returns SOject Type of Approval Criteria
    Added By:                                                Accenture – Shridhar K  -  09/13/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        09/13/2018                 Created.
*****************************************************************************************************************************************/      
    @AuraEnabled
    public static list<String> getFields(Id recId){
        Core_MDF_Approver__c appr = [SELECT Id, Name, Core_MDF_Criteria__r.Core_MDF_Object_Type__c FROM Core_MDF_Approver__c
                                     WHERE Id=:recId LIMIT 10000];
        String sObjType = appr.Core_MDF_Criteria__r.Core_MDF_Object_Type__c;
        list<String> allFields = getAllFields(sObjType);
        return allFields;
    }

/****************************************************************************************************************************************
    Method Name:                                             updateCriteriaRule
    @return  :                                               --
    @parameters:                                             Updated Criteria Rules and Approver Id
    Description:                                             Criteria Rule will be deleted/updated based on the user input  
    Added By:                                                Accenture – Shridhar K  -  09/13/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        09/13/2018                 Created.
*****************************************************************************************************************************************/      
    @AuraEnabled   
    public static void updateCriteriaRule(list<Core_MDF_Criteria_Rule__c> crtRuleList, Id apprId){
                
        list<Id> availableCriteraRule = new list<Id>();
        list<Core_MDF_Criteria_Rule__c> toBeInserted = new list<Core_MDF_Criteria_Rule__c>();
        list<Core_MDF_Criteria_Rule__c> toBeUpdated = new list<Core_MDF_Criteria_Rule__c>();
        
        for(Core_MDF_Criteria_Rule__c crtRule: crtRuleList){            
            if(crtRule.Id != NULL){
                availableCriteraRule.add(crtRule.Id);
                toBeUpdated.add(crtRule);
            }else{
                toBeInserted.add(crtRule);
            } 
        }
        
        list<Core_MDF_Criteria_Rule__c> toBeDeleted = [SELECT Id, Name, Core_MDF_Approver__c, Core_MDF_Field_Name__c, Core_MDF_Operator__c,
                                                       Core_MDF_Value__c FROM Core_MDF_Criteria_Rule__c WHERE Core_MDF_Approver__c =:apprId 
                                                       AND Id NOT IN : availableCriteraRule LIMIT 10000];
         
        try{
            if(toBeInserted.size() > 0){
                Database.insert(toBeInserted, true);
            }
            if(toBeDeleted.size() > 0){
                Database.delete (toBeDeleted, true);
            }
            if(toBeUpdated.size() > 0){
                Database.update(toBeUpdated, true);
            }
        }
        catch(Exception e){ throw new AuraHandledException(e.getMessage()); 
            
        }
    }    
}