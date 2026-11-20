/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_HoldList_TriggerHandler 
* Version           : 1.0 
* Created Date      : 18-04-2019
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Krishna Kulkarni       18-04-2019        Trigger Handler class.
*****************************************************************************************************************************************/
public class Core_MDF_HoldCriteriaList_TriggerHandler extends TriggerHandler {
    // to delete hold list criteria record
    public override void beforeDelete() {
        if (isActive('Core_MDF_holdCriteriaProcessBeforeDelete')) {
            Core_MDF_HoldCriteriaList_ServiceHandler.preventDeleteOfEffectiveHoldCriteria(Trigger.OLD);
        }
    }
    
    // to validate account-program, geo-country, category-type association on create
    public override void beforeInsert() {
        if (isActive('Core_MDF_holdCriteriaProcessBeforeInsert')) {
            Core_MDF_HoldCriteriaList_ServiceHandler.validateAccountProgramAssociation((List<Core_MDF_Hold_Criteria__c>)Trigger.NEW);
            Core_MDF_HoldCriteriaList_ServiceHandler.validateGeoCountryAssociation((List<Core_MDF_Hold_Criteria__c>)Trigger.NEW);
            Core_MDF_HoldCriteriaList_ServiceHandler.validateCategoryTypeAssociation((List<Core_MDF_Hold_Criteria__c>)Trigger.NEW);
        }
    }
    
    // to validate account-program, geo-country, category-type association on Edit
    public override void beforeUpdate() {
        if (isActive('Core_MDF_holdCriteriaProcessBeforeUpdate')) 
        {
            Core_MDF_HoldCriteriaList_ServiceHandler.validateAccountProgramAssociationOnEdit((List<Core_MDF_Hold_Criteria__c>)Trigger.NEW,
                                                                                               (Map<Id,Core_MDF_Hold_Criteria__c>) Trigger.OldMap);
            Core_MDF_HoldCriteriaList_ServiceHandler.validateGeoCountryAssociationOnEdit((List<Core_MDF_Hold_Criteria__c>)Trigger.NEW,
                                                                                               (Map<Id,Core_MDF_Hold_Criteria__c>) Trigger.OldMap);
            Core_MDF_HoldCriteriaList_ServiceHandler.validateCategoryTypeAssociationOnEdit((List<Core_MDF_Hold_Criteria__c>)Trigger.NEW,
                                                                                               (Map<Id,Core_MDF_Hold_Criteria__c>) Trigger.OldMap);
        }
    }
}