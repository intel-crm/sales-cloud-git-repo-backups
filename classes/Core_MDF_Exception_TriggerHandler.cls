/****************************************************************************************************************************************
* Class Name        : Core_MDF_Exception_TriggerHandler
* Created Date      : 19-06-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture SS        19-06-2019          Exception Trigger Handler which handles all the triggers methods and call Service handler methods        
*****************************************************************************************************************************************/
public with sharing class Core_MDF_Exception_TriggerHandler extends TriggerHandler  {
    
    /**
        * @description              : Method for processing the Exception after their Insertion
        * @param Trigger.newMap     : Map of Exception that have been Inserted
    **/
    public override void afterInsert(){
        if (isActive('Core_MDF_ExceptionAfterInsert')) {
            Core_MDF_Exception_TriggerServiceHandler.shareExceptionRecordsWithInternalUsers( (Map<Id,Core_MDF_Exception__c>) 
                                                                                            Trigger.newMap, true );
        }
    }
    /**
        * @description              : Method for processing the Exception after Update
        * @param Trigger.newMap     : Map of Exception that have been Updated  
    */
    public override void afterUpdate(){if (isActive('Core_MDF_ExceptionAfterUpdate')) {
        System.debug('After Update');
        Core_MDF_Exception_TriggerServiceHandler.shareExceptionRecordsWithUsersForUpdate( (Map<Id,Core_MDF_Exception__c>) Trigger.newMap );
        }
    }
}