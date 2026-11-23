/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_UserInput_Trigger 
* Version           : 1.0 
* Created Date      : 03/03/2026
* Modification Log  : 
* Developer            Date(MM/DD/YYYY)  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Ramapriya       03/03/2026        Trigger on MDF User Input object.
*****************************************************************************************************************************************/
trigger Core_MDF_UserInput_Trigger on Core_MDF_User_Input__c 
(after insert, after update) {

    System.debug('TRIGGER STARTED');

    Core_Trigger_Executions__c config = Core_Trigger_Executions__c.getValues('Core_MDF_Bypass_UserInput_Trigger');
    
    System.debug('Config: ' + config);

    Boolean shouldRun = (
        config == null || 
        !(config.Core_Active__c &&
          Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_L3_Bypass_Users')
          .Core_MDF_Value_Txt__c.contains(UserInfo.getUserName()))
    );

    System.debug(' Should Run Trigger: ' + shouldRun);

    if(shouldRun){
        System.debug('Calling Trigger Handler');
        new Core_MDF_UserInput_TriggerHandler().run();
    } else {
        System.debug('Trigger Skipped due to bypass config');
    }
}