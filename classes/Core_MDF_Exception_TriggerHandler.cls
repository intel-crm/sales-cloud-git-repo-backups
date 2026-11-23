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
    * @description              : Method for processing the Exception before Insert
    * @param Trigger.new        : new List of Exception that have been Inserted
    * @param Trigger.isInsert   : execute while Insert
    */
    public override void beforeInsert(){
        if (isActive('Core_MDF_ExceptionBeforeInsert')) {
            
            Core_MDF_Exception_TriggerServiceHandler.exceptionDataValidation((List<Core_MDF_Exception__c>) Trigger.new);
            Core_MDF_Exception_TriggerServiceHandler.checkActCatTypeWithBudgetType((List<Core_MDF_Exception__c>) Trigger.new, NULL, Trigger.isInsert);
            if(System.label.Core_MDF_BypassNewCategoryExceptionError.toLowercase() != 'true'){
                Core_MDF_Exception_TriggerServiceHandler.validateActivityCategoryType((List<Core_MDF_Exception__c>) Trigger.new, NULL, Trigger.isInsert);
            }
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPassAccountTypeMap_Excep')){
                Core_MDF_Exception_TriggerServiceHandler.prepareAccountTypeForException((List<Core_MDF_Exception__c>) Trigger.new, (Map<Id, Core_MDF_Exception__c>) Trigger.oldMap);
            }
        }
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPassValidateExcepAccounts')){
            Core_MDF_Exception_TriggerServiceHandler.validateSelectedAccount((List<Core_MDF_Exception__c>) Trigger.new, (Map<Id, Core_MDF_Exception__c>) Trigger.oldMap);
        }
    }
    
    /**
    * @description              : Method for processing the Exception before Update
    * @param Trigger.oldMap     : old Map of Exception that have been Updated
    * @param Trigger.newMap     : new Map of Exception that have been Updated  
    */
    public override void beforeUpdate(){
        
        if (isActive('Core_MDF_ExceptionBeforeUpdate')) {
            
            Core_MDF_Exception_TriggerServiceHandler.exceptionDataValidation((List<Core_MDF_Exception__c>) Trigger.new);
            Core_MDF_Exception_TriggerServiceHandler.checkActCatTypeWithBudgetType((List<Core_MDF_Exception__c>) Trigger.new,(Map<Id,Core_MDF_Exception__c>) Trigger.oldMap, Trigger.isInsert);
            if(System.label.Core_MDF_BypassNewCategoryExceptionError.toLowercase() != 'true'){
                Core_MDF_Exception_TriggerServiceHandler.validateActivityCategoryType((List<Core_MDF_Exception__c>) Trigger.new,(Map<Id,Core_MDF_Exception__c>) Trigger.oldMap, Trigger.isInsert);
            }
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPassAccountTypeMap_Excep')){
                Core_MDF_Exception_TriggerServiceHandler.prepareAccountTypeForException((List<Core_MDF_Exception__c>) Trigger.new, (Map<Id, Core_MDF_Exception__c>) Trigger.oldMap);
            }
        }
        if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPassValidateExcepAccounts')){
            Core_MDF_Exception_TriggerServiceHandler.validateSelectedAccount((List<Core_MDF_Exception__c>) Trigger.new, (Map<Id, Core_MDF_Exception__c>) Trigger.oldMap);
        }
    }
    
    /**
    * @description              : Method for processing the Exception after their Insertion
    * @param Trigger.newMap     : Map of Exception that have been Inserted
    **/
    public override void afterInsert(){
        if (isActive('Core_MDF_ExceptionAfterInsert')) {
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPassAccountTypeMap_Excep')){
                Core_MDF_Exception_TriggerServiceHandler.prepareAccountTypeForException((List<Core_MDF_Exception__c>) Trigger.new, (Map<Id, Core_MDF_Exception__c>) Trigger.oldMap);
            }
            Core_MDF_ExceptionEmailHandler.sendEmailToExceptionReviewer((List<Core_MDF_Exception__c>) Trigger.new);
        }
    }
    /**
    * @description              : Method for processing the Exception after Update
    * @param Trigger.newMap     : Map of Exception that have been Updated  
    */
    public override void afterUpdate(){
        if (isActive('Core_MDF_ExceptionAfterUpdate')) {        
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPassAccountTypeMap_Excep')){
            Core_MDF_Exception_TriggerServiceHandler.prepareAccountTypeForException((List<Core_MDF_Exception__c>) Trigger.new, (Map<Id, Core_MDF_Exception__c>) Trigger.oldMap);
        }
            
            Core_MDF_Exception_TriggerServiceHandler.shareExceptionRecordsWithUsersForUpdate( (Map<Id,Core_MDF_Exception__c>) Trigger.newMap,(Map<Id,Core_MDF_Exception__c>) Trigger.oldMap );
            
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_ByPass_ExptSharingto_ExtUser')){
            Core_MDF_Exception_TriggerServiceHandler.shareExceptionRecordsWithExtUsers((Map<Id,Core_MDF_Exception__c>) Trigger.newMap, (Map<Id,Core_MDF_Exception__c>) Trigger.oldMap);
            }
        }
    }
    
}