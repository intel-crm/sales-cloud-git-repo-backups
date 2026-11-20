/**************************************************************************************  
    Apex Class Name: Core_Task       
    Version : 1.0        
    Created Date: 03 SEP 2014        
    Function : Trigger for Task object       
    Modification Log :       
    * Developer Date Description         
    * ----------------------------------------------------------------------------       
    * Harshith M L        09/30/2014      Original Version   
    * Mahesh Manikonda    11/12/2018      Update a flag on Lead when task is created on Lead
*************************************************************************************/      

trigger Core_Task on Task(before insert,before update,after insert, after update, after delete) {

    // Fetching "Custom Setting" containing details to trigger switch on/off
    Map < String, Core_Trigger_Executions__c > mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
     
   /*if (Trigger.isBefore ) {
         if (Trigger.isInsert) {
                       

             Core_TaskHandler.UpdateTaskflag(Trigger.New);
             
              }
       
            if ( Trigger.isUpdate) {
             Core_TaskHandler.UpdateTaskflagOnUpdate(Trigger.Old,Trigger.New);
            
              }
         }*/
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            // calling method to update last activity date and passing task data to task handler class
            if (mapFunctionalityNameTriggerExecution.containsKey('tasklastActivityUpdateOnLeadUpsert') &&
                mapFunctionalityNameTriggerExecution.get('tasklastActivityUpdateOnLeadUpsert').Core_Active__c)
                Core_TaskHandler.tasklastActivityUpdateOnLeadUpsert(Trigger.oldMap, Trigger.newMap);

        }

        if (Trigger.isUpdate) {
            // calling method to update last activity date and passing task data to task handler class
            if (mapFunctionalityNameTriggerExecution.containsKey('tasklastActivityUpdateOnLeadUpsert') &&
                mapFunctionalityNameTriggerExecution.get('tasklastActivityUpdateOnLeadUpsert').Core_Active__c)
                Core_TaskHandler.tasklastActivityUpdateOnLeadUpsert(Trigger.oldMap, Trigger.newMap);

        }

        iF(Trigger.isDelete) {
            // calling method to update last activity date and passing task data to task handler class
            if (mapFunctionalityNameTriggerExecution.containsKey('tasklastActivityUpdateOnLeadDelete') &&
                mapFunctionalityNameTriggerExecution.get('tasklastActivityUpdateOnLeadDelete').Core_Active__c)
                Core_TaskHandler.tasklastActivityUpdateOnLeadDelete(Trigger.oldMap);

        }
    }

}