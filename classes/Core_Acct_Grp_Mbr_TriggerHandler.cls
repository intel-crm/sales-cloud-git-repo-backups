/**************************************************************************************
Apex Class Name : PMP_PartnerAccGroupMemberTriggerHandler
Version     : 1.0 
Created Date: 24th June, 2019
Description : Trigger handler for PMP_Account_Grp_MemberTrigger
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Sandip                  24/06/2019               Original Version
*Anupam Agarwal			  12/08/2019			   Added toggleIsPAGMember method call in the afterInsert and afterUpdate methods 
												   to set the isPAGMember check on the Account
*Anupam Agarwal			  12/08/2019			   Added beforeUpdate and beforeInsert methods  to handle the MDA indicator and
												   duplicate records related validations.
*************************************************************************************/
public class Core_Acct_Grp_Mbr_TriggerHandler extends TriggerHandler{
    
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();    
    public override void afterInsert(){
	//Start of Changes - Accenture - IPA 
        if(isActive('isPAGMTrigger')) {
            PMP_Acct_Grp_Mbr_TriggerHandler.toggleIsPAGMember(Trigger.new,(Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
        //End of Changes - Accenture - IPA 
        }
        Map<Id, Core_Account_Group_Member__c> newMap = (Map<Id, Core_Account_Group_Member__c>) Trigger.newMap;         
        PMP_Acct_Grp_Mbr_TriggerHandler.afterMethod(Trigger.old, Trigger.new);
        if(mapFunctionalityNameTriggerExecution.containsKey('PAG_mem_handler') && 
           mapFunctionalityNameTriggerExecution.get('PAG_mem_handler').Core_Active__c){
               PMP_PAG_mem_handler.onGroupMemAfterInsert(Trigger.new, newMap);
           }        
    }
     public override void afterUpdate(){
	//Start of Changes - Accenture - IPA 
        if(isActive('isPAGMTrigger')) {
           	PMP_Acct_Grp_Mbr_TriggerHandler.toggleIsPAGMember(Trigger.new,(Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
        //End of Changes - Accenture - IPA 
        }
         Map<Id, Core_Account_Group_Member__c> oldMap = (Map<Id, Core_Account_Group_Member__c>) Trigger.oldMap;
         Map<Id, Core_Account_Group_Member__c> newMap = (Map<Id, Core_Account_Group_Member__c>) Trigger.newMap;         
         PMP_Acct_Grp_Mbr_TriggerHandler.afterMethod(Trigger.old, Trigger.new);
         if(mapFunctionalityNameTriggerExecution.containsKey('PAG_mem_handler') && 
            mapFunctionalityNameTriggerExecution.get('PAG_mem_handler').Core_Active__c){
                PMP_PAG_mem_handler.onGroupMemAfterUpdate(Trigger.new, oldMap, newMap);               
            }         
    }
    /*public override void beforeInsert(){
        PMP_PartnerAccGroupMemHandler.beforeMethod(Trigger.old, Trigger.new);
    }
	
    public override void beforeUpdate(){
       PMP_Acct_Grp_Mbr_TriggerHandler.beforeMethod(Trigger.old, Trigger.new);
    }  */
    /*
    public override void beforeDelete(){
        //Map<Id, Core_Account_Group_Member__c> oldMap = (Map<Id, Core_Account_Group_Member__c>) Trigger.oldMap;     
        PMP_Acct_Grp_Mbr_TriggerHandler.beforeMethod(Trigger.old, Trigger.new);
	//
      /  if(mapFunctionalityNameTriggerExecution.containsKey('PAG_mem_handler') && 
       //    mapFunctionalityNameTriggerExecution.get('PAG_mem_handler').Core_Active__c){
         //      //PMP_PAG_mem_handler.onGroupMemBeforeDelete(Trigger.old, oldMap);
           //}  
	//
    }
	*/

//Start of Changes - Accenture - IPA 
    public override void beforeUpdate() {
        if(isActive('isPAGMTrigger')) { //Retrieved from Custom labels
            PMP_Acct_Grp_Mbr_TriggerHandler.checkMDAIndicator(Trigger.new, (Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
        }
     //Start of Changes by Ankit Thakur on 28th August in order to merge code for NPPDEV and PRODUCTION- Accenture - IPA    
	PMP_Acct_Grp_Mbr_TriggerHandler.beforeMethod(Trigger.old, Trigger.new);
      //End of Changes by Ankit Thakur on 28th August in order to merge code for NPPDEV and PRODUCTION- Accenture - IPA 
    }
    
    public override void beforeInsert() {
        if(isActive('isPAGMTrigger')) { //Retrieved from Custom labels
            PMP_Acct_Grp_Mbr_TriggerHandler.checkMDAIndicator(Trigger.new, (Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
        }
    }
    
    //End of Changes - Accenture - IPA 
}