/****************************************************************************************************
Apex Class Name : UserDelegationTriggerHandler
Version         : 1.0 
Created Date    : 01/05/2021
Function        : Trigger Handler for User Delegation Trigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                     01/05/2021               Created
*****************************************************************************************************/
public with sharing class UserDelegationTriggerHandler  extends TriggerHandler {
    public List<core_user_delegation__c> udTriggerOldList = new List<core_user_delegation__c>();
    public List<core_user_delegation__c> udTriggerNewList = new List<core_user_delegation__c>();
    public MAP<Id,core_user_delegation__c> udTriggerNewMap = new Map<Id,core_user_delegation__c>();
    public Map<Id,core_user_delegation__c> udTriggerOldMap = new Map<Id,core_user_delegation__c>();
    public UserDelegationTriggerHandler() {
        if(Trigger.new != null){
            for(core_user_delegation__c ud : (List<core_user_delegation__c>)Trigger.new){
                udTriggerNewList.add(ud);
                if(Trigger.newMap != null){
                    udTriggerNewMap.put(ud.id, ud);
                }
            }
        }
        if(Trigger.old != null){
            for(core_user_delegation__c ud : (List<core_user_delegation__c>)Trigger.old){
                udTriggerOldList.add(ud);
                if(Trigger.oldMap != null){
                    udTriggerOldMap.put(ud.id, ud);
                }
            } 
        } 
    }
    
    /************************************************************************************************************
    *Method Name : beforeInsert
    *Created Date: 08/13/2021
    *Author: Hema
    *Description : Performs operations on before insert context of trigger.
    ************************************************************************************************************/
    public override void beforeInsert() {
        if(isActive('PSG_DELEGATE_USER_BEFORE_INSERT')){
            if(!udTriggerNewList.isEmpty()){            
                PSG_UserDelegationBusinessLogic.beforeInsertUpdateOperations(udTriggerNewList,udTriggerOldMap,Trigger.isInsert);
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : beforeUpdate
    *Created Date: 08/13/2021
    *Author: Hema
    *Description : Performs operations on before update context of trigger.
    ************************************************************************************************************/
    public override void beforeUpdate() {
        if(isActive('PSG_DELEGATE_USER_BEFORE_UPDATE')){
            if(!udTriggerNewList.isEmpty()){
                PSG_UserDelegationBusinessLogic.beforeInsertUpdateOperations(udTriggerNewList,udTriggerOldMap,Trigger.isInsert);
            }
        }
    }
}