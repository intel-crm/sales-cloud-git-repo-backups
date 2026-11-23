/****************************************************************************************************************************************
* Class Name  : Core_MDF_BankTriggerHandler
* Version     : 1.0
* Created Date: 11-11-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       11/11/2018          Created for extending Trigger framework to process
                                          Bank object business logic methods.
*****************************************************************************************************************************************/
public without sharing class Core_MDF_BankTriggerHandler extends TriggerHandler{
    /*public Core_MDF_BankTriggerHandler() {
    } */

    public override void beforeUpdate(){
        if (isActive('Core_MDF_BankProcessesOnbeforeUpdate')) {
            System.debug('hmz1');
            Core_MDF_BankServiceHandler.beforeUpdateBankRecords((Map<Id,Core_MDF_Bank__c>) Trigger.oldMap, (Map<Id,Core_MDF_Bank__c>) Trigger.newMap);
        }


    }
    public override void beforeInsert() {
        if(isActive('Core_MDF_BankProcessesOnBeforeInsert')){
            Core_MDF_BankServiceHandler.beforeInsertBankRecords((List<Core_MDF_Bank__c>) Trigger.new);
        }
    }

    /*public override void beforeDelete(){
    }*/

    public override void afterInsert(){
        if (isActive('Core_MDF_BankProcessesOnAfterInsert')) {
            /**
            * @description          : Method for processing the Banks after their Insertion
            * @param Trigger.NEW    : List of Banks that have been Inserted
            */
            //Core_MDF_BankServiceHandler.shareBankRecordsWithUsers((Map<Id,Core_MDF_Bank__c>) Trigger.newMap);
            Core_MDF_BankServiceHandler.createShareForBank(new List<Id>(Trigger.newMap.keySet()),'ExtSharing');
        }
    }

    public override void afterUpdate(){
        if (isActive('Core_MDF_BankProcessesOnAfterUpdate')) {
            /**
            * @description              : Method for processing the Banks after Update
            * @param Trigger.oldMap     : Map of the old Banks
            * @param Trigger.newMap     : Map of the new Banks
            */
            System.debug('After Update');
            Core_MDF_BankServiceHandler.afterUpdateBankRecords((Map<Id,Core_MDF_Bank__c>) Trigger.oldMap,
                                                               (Map<Id,Core_MDF_Bank__c>) Trigger.newMap);
        }
    }

    /*public override void afterDelete(){
    }

    public override void afterUndelete(){
    }*/
}