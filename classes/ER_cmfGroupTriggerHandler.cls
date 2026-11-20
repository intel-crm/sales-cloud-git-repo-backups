/******************************************************************************************************************************************
Class Name  : ER_cmfGroupTriggerHandler
Test Class Name : ER_cmfGroupBusinessLogic_Test, Coverage:93%
Version     : 1.0 
Created Date: 15 Nov 2023
Function    : CMF Group Trigger Handler
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Shreyash Agrawal         25/11/2023              Original version 
*****************************************************************************************************************************************/
public class ER_cmfGroupTriggerHandler  extends TriggerHandler {
    public List<ER_Customer_Master_File_Group__c> cmfGroupTriggerOldList = new List<ER_Customer_Master_File_Group__c>();
    public List<ER_Customer_Master_File_Group__c> cmfGroupTriggerNewList = new List<ER_Customer_Master_File_Group__c>();
    public Map<Id,ER_Customer_Master_File_Group__c> cmfGroupTriggerNewMap = new Map<Id,ER_Customer_Master_File_Group__c>();
    public Map<Id,ER_Customer_Master_File_Group__c> cmfGroupTriggerOldMap = new Map<Id,ER_Customer_Master_File_Group__c>();
    
    public ER_cmfGroupTriggerHandler(){
        if(trigger.new != null){
            for(ER_Customer_Master_File_Group__c cmgGroupRec : (List<ER_Customer_Master_File_Group__c>)trigger.new){
                cmfGroupTriggerNewList.add(cmgGroupRec);
                if(trigger.newMap != null){
                    cmfGroupTriggerNewMap.put(cmgGroupRec.id,cmgGroupRec);
                }
			}
        }
        if(trigger.old != null){
            for(ER_Customer_Master_File_Group__c cmgGroupRec : (List<ER_Customer_Master_File_Group__c>)trigger.old){
                cmfGroupTriggerOldList.add(cmgGroupRec);
                if(trigger.oldMap != null){
                    cmfGroupTriggerOldMap.put(cmgGroupRec.id,cmgGroupRec);
                }
			}
        }
    }
    public override void beforeInsert() {
        
    }
    public override void beforeUpdate() {
        
    }
    public override void afterInsert() {
        if(!cmfGroupTriggerNewList.isEmpty()){
            ER_cmfGroupBusinessLogic.afterInsertUpdateOperation(cmfGroupTriggerNewList,cmfGroupTriggerOldMap,Trigger.isInsert);
        }
        
    }
    public override void afterUpdate() {
        
    }
}