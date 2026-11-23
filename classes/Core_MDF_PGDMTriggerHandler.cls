/****************************************************************************************************************************************
* Class Name  : Core_MDF_PGDMTriggerHandler 
* Version     : 1.0 
* Created Date: 06-Mar-2020
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD      06-Mar-2020          Created for extending Trigger framework to process 
                                           Partner Group Domain Mapping business logic methods.
*****************************************************************************************************************************************/

public class Core_MDF_PGDMTriggerHandler extends TriggerHandler{
    
    public override void beforeInsert() {
        if (isActive('Core_MDF_PGDMOnBeforeInsert')) {
            Core_MDF_PGDMServiceHandler.checkDuplicatePGDMRecords((List<Core_MDF_Partner_Group_Domain_Mapping__c>) Trigger.new);            
        }
    }
    public override void afterInsert() {
        if (isActive('Core_MDF_PGDMOnAfterInsert')) {
            Core_MDF_PGDMServiceHandler.insertDomainRecordsForOtherPGMs((List<Core_MDF_Partner_Group_Domain_Mapping__c>) Trigger.new);
        }
    }
}