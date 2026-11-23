/****************************************************************************************************
Apex Class Name : MSVPTriggerHandler
Version         : 1.0 
Created Date    : 02/09/2021
Function        : Handler Class for MSVPtrigger.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pooja             		 02/09/2021                Created
*****************************************************************************************************/
public class MSVPTriggerHandler extends TriggerHandler{    
    public List<price_msvp__c> psgTriggerNewList = new List<price_msvp__c>();
    public Map<Id,price_msvp__c> psgTriggerOldMap = new Map<Id,price_msvp__c>();
    public MSVPTriggerHandler(){
        Id psgFCRecordTypeId =  Schema.SObjectType.price_msvp__c.getRecordTypeInfosByDeveloperName().get(Label.PSG_MSVP_Record_Type).getRecordTypeId(); 
        for(price_msvp__c msvp : (List<price_msvp__c>)Trigger.new){
            if(msvp.RecordTypeId == psgFCRecordTypeId){
                psgTriggerNewList.add(msvp);
            }
            if(Trigger.oldMap != null){
                psgTriggerOldMap.put(msvp.Id,(price_msvp__c)Trigger.oldMap.get(msvp.Id));
            }
        }
    }
    
    public override void beforeInsert() {
        if(isActive('PSG_MSVP_Before_Insert')){
            if(!psgTriggerNewList.isEmpty()){            
                PSG_MSVPBusinessLogic.beforeInsertUpdateOperations(psgTriggerNewList,psgTriggerOldMap,Trigger.isInsert);
            }
        }
        
    }
    
    public override void beforeUpdate() {
        if(isActive('PSG_MSVP_Before_Update')){
            if(!psgTriggerNewList.isEmpty()){
                PSG_MSVPBusinessLogic.beforeInsertUpdateOperations(psgTriggerNewList,psgTriggerOldMap,Trigger.isInsert);
            }
        }
        
    }
}