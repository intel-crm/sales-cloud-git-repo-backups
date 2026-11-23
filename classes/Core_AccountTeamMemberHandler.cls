/**************************************************************************************
Apex Class Name:  Core_AccountTeamMemberHandler
Version     : 1.0 
Created Date: 28 FEB 2020
Function    : methods to handle AccountTeamMember Trigger functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gopala Krishna             02/28/2020              Original Version
*************************************************************************************/
public class Core_AccountTeamMemberHandler extends TriggerHandler{
    
     /*
    * Method name  :  afterInsert()
    * Description  :  List of AccountTeamMember added to Account Sending that list to Core_AccountTeamMemberServiceHandler class .
    * Return Type  :  VOID
    * Parameter    : 
    */  
    
	public override void afterInsert(){
	    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
		if(mapFunctionalityNameTriggerExecution.containsKey('SendingListOfTenderUsersTobatch') &&  mapFunctionalityNameTriggerExecution.get('SendingListOfTenderUsersTobatch').Core_Active__c){
		       
            Core_AccountTeamMemberServiceHandler.sharingAccountTeamList((List<AccountTeamMember>) Trigger.new , Trigger.isDelete );
           } 
        }

  /*
    * Method name  :  afterUpdate()
    * Description  :  List of AccountTeamMember updated to Account Sending that list to Core_AccountTeamMemberServiceHandler class .
    * Return Type  :  VOID
    * Parameter    : 
    */  		
    
    public override void afterUpdate(){
       Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
		if(mapFunctionalityNameTriggerExecution.containsKey('SendingListOfTenderUsersTobatch') &&  mapFunctionalityNameTriggerExecution.get('SendingListOfTenderUsersTobatch').Core_Active__c){
		       
            Core_AccountTeamMemberServiceHandler.sharingAccountTeamList((List<AccountTeamMember>) Trigger.new, Trigger.isDelete);
           } 
    }
    
    /*
    * Method name  :  afterDelete()
    * Description  :  List of AccountTeamMember deleted to Account Sending that list to Core_AccountTeamMemberServiceHandler class .
    * Return Type  :  VOID
    * Parameter    : 
    */  		
    
    public override void afterDelete(){
       Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
		if(mapFunctionalityNameTriggerExecution.containsKey('SendingListOfTenderUsersTobatch') &&  mapFunctionalityNameTriggerExecution.get('SendingListOfTenderUsersTobatch').Core_Active__c){
		       
            Core_AccountTeamMemberServiceHandler.sharingAccountTeamList((List<AccountTeamMember>) Trigger.old, Trigger.isDelete);
           } 
    }
	
	}