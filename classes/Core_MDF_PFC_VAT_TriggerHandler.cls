/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_VAT_TriggerHandler 
* Version     : 1.0 
* Created Date: 08-10-2018
* Modification Log :
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sridhar       08-10-2018          Created for extending Trigger framework to process 
Partner Fund VAT business logic methods.
*****************************************************************************************************************************************/
public with sharing class Core_MDF_PFC_VAT_TriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        
        if (isActive('Core_MDF_VATInfoOnBeforeInsert')) {

            Core_MDF_PFC_VAT_ServiceHandler.updateDateFieldsOnVAT((List<Core_MDF_Claim_VAT_Info__c>) Trigger.NEW,
                                                                       (Map<Id,Core_MDF_Claim_VAT_Info__c>) Trigger.oldMap,
                                                                       Trigger.isInsert,Trigger.isUpdate);

        }
        if (isActive('Core_MDF_VATRecordTypeIdOnBeforeInsert')) {
        
            Core_MDF_PFC_VAT_ServiceHandler.updateRecordTypeOnVAT((List<Core_MDF_Claim_VAT_Info__c>) Trigger.NEW,
                                                                       (Map<Id,Core_MDF_Claim_VAT_Info__c>) Trigger.oldMap,
                                                                       Trigger.isInsert,Trigger.isUpdate);
        }
        
    }
    
    public override void beforeUpdate() {
	if(!Core_MDF_Utility.byPassFeature('Bypass_Payment_Doc_InvFileVAT_Validate'))
            if (isActive('Core_MDF_Claim_VAT_Info_Validations')) {
                    Core_MDF_PFC_VAT_ServiceHandler.validateVATInvoiceandFiles((List<Core_MDF_Claim_VAT_Info__c>) Trigger.NEW, (Map<Id,Core_MDF_Claim_VAT_Info__c>) Trigger.oldMap);
            }

        if (isActive('Core_MDF_VATInfoOnBeforeUpdate')){
        
            Core_MDF_PFC_VAT_ServiceHandler.updateDateFieldsOnVAT((List<Core_MDF_Claim_VAT_Info__c>) Trigger.NEW,
                                                                       (Map<Id,Core_MDF_Claim_VAT_Info__c>) Trigger.oldMap,
                                                                       Trigger.isInsert,Trigger.isUpdate);

        }
        if (isActive('Core_MDF_VATRecordTypeIdOnBeforeUpdate')) {
        
            Core_MDF_PFC_VAT_ServiceHandler.updateRecordTypeOnVAT((List<Core_MDF_Claim_VAT_Info__c>) Trigger.NEW,
                                                                       (Map<Id,Core_MDF_Claim_VAT_Info__c>) Trigger.oldMap,
                                                                       Trigger.isInsert,Trigger.isUpdate);
        }
        if(isActive('Core_MDF_ClearApprovedPaymentField')){
             Core_MDF_PFC_VAT_ServiceHandler.clearApprovedPaymentFieldsOnRevReq((List<Core_MDF_Claim_VAT_Info__c>) Trigger.NEW,
                                                                                            (Map<Id,Core_MDF_Claim_VAT_Info__c>) Trigger.oldMap);
        }

    }
    
    public override void afterUpdate() {
        Core_MDF_PFC_VAT_ServiceHandler.releaseClaimWhenVatisCancelled((List<Core_MDF_Claim_VAT_Info__c>) Trigger.NEW,(Map<Id,Core_MDF_Claim_VAT_Info__c>) Trigger.oldMap,(Map<Id,Core_MDF_Claim_VAT_Info__c>) Trigger.newMap); 
      
    }  
    
}