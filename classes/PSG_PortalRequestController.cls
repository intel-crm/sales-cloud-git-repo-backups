/****************************************************************************************************
Apex Class Name : PSG_PortalRequestController
Version         : 1.0 
Created Date    : 12/16/2022
Function        : This class is Helper class for PortalRequest Object Trigger Operations.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ranjit                    12/16/2022                Created
*****************************************************************************************************/

public class PSG_PortalRequestController {
    
    /************************************************************************************************************
    *Method Name : afterInsertUpdateOperations
    *Created Date: 12/16/2022
    *Author: Ranjit
    *Description : Performs operations on After context of trigger.
    ************************************************************************************************************/
    
    public static void afterInsertUpdateOperations(List<core_cpq_portalrequest__c> PR_List,Map<Id,core_cpq_portalrequest__c> oldMap,Boolean isInsert){
        Boolean isUpdate=!isInsert;
        if(isUpdate){ 
            List<SObject> sObjtoUpdate=new List<SObject>();
            for(core_cpq_portalrequest__c pr :PR_List){
                if(pr.core_cpq_Status__c!= oldMap.get(pr.Id).core_cpq_Status__c&& pr.core_cpq_Status__c=='Approved'){
                    if(pr.core_cpq_request_type__c == 'Field Update' || pr.core_cpq_request_type__c == 'Quote Deactivation'){
                        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(pr.core_cpq_bot_Object_Name__c);
                        Sobject sobj=targetType.newSObject();
                        sObj.put(pr.core_cpq_bot_field_name__c,getFieldValue(pr.core_cpq_Field_Type__c,pr.core_cpq_value__c));
                        sObj.put('Id',pr.core_cpq_record_Id__c);
                        sObjtoUpdate.add(sObj);
                    }                    
                }
            }
            
            if(!sObjtoUpdate.isEmpty()){
                update sObjtoUpdate;
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : getFieldValue
    *Created Date: 12/16/2022
    *Author: Ranjit
    *Description : Performs Value Conversion based on field type.
    ************************************************************************************************************/
    
    public static Object getFieldValue(String fieldType,String fieldValue){
        if(fieldType=='Currency' || fieldType=='Double'){
            return Decimal.valueOf(fieldValue);
        }else if(fieldType=='Date'){
            return Date.parse(fieldValue);
        }else if(fieldType=='Boolean'){
            return Boolean.valueOf(fieldValue);
        }else if(fieldType=='Percent'){
            return Decimal.valueOf(fieldValue);
        }else{
            return null;
        }        
    }
    
    /************************************************************************************************************
    *Method Name : GetPRList
    *Created Date: 12/16/2022
    *Author: Ranjit
    *Description : fetch all the PR records where approver is current logged-in user and status is 'pending'.
    ************************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    Public static List<core_cpq_portalrequest__c> GetPRList(){
        return[select id,Name,toLabel(core_cpq_bot_Object_Name__c),toLabel(core_cpq_bot_field_name__c),core_cpq_Field_Type__c,core_cpq_Record__c,core_cpq_record_number__c,core_cpq_record_Id__c,core_cpq_request_type__c,core_cpq_Requested_By__r.name,core_cpq_value__c,core_cpq_Status__c,Owner.name from core_cpq_portalrequest__c where core_cpq_Status__c='Pending' and OwnerId=:UserInfo.getUserId()];
    }

}