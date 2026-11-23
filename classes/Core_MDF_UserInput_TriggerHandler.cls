/****************************************************************************************************************************************
* Class Name       : Core_MDF_UserInput_TriggerHandler 
* Version          : 1.0 
* Created Date     : 03/04/2026
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Ramapriya       03/04/2026         Created for extending Trigger framework to process 
												 MDF User Input object business logic methods.
*****************************************************************************************************************************************/
public class Core_MDF_UserInput_TriggerHandler extends TriggerHandler {

    public override void afterInsert(){

        System.debug('AFTER INSERT START');

        Boolean active = isActive('Core_MDF_afterInsertUserInput');
        System.debug('isActive(afterInsert): ' + active);

        if(active){
            System.debug('Calling Service Handler (Insert)');
            Core_MDF_UserInput_ServiceHandler.processUserInput(
                (List<Core_MDF_User_Input__c>)Trigger.new
            );
        } else {
            System.debug('afterInsert is inactive');
        }
    }

    public override void afterUpdate(){

        System.debug('AFTER UPDATE START');

        Boolean active = isActive('Core_MDF_afterUpdateUserInput');
        System.debug('isActive(afterUpdate): ' + active);

        if(active){
            System.debug('Calling Service Handler (Update)');
            Core_MDF_UserInput_ServiceHandler.processUserInput(
                (List<Core_MDF_User_Input__c>)Trigger.new
            );
        } else {
            System.debug('afterUpdate is inactive');
        }
    }
}