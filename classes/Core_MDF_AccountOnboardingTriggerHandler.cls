/****************************************************************************************************************************************
* Class Name  : Core_MDF_AccountOnboardingTriggerHandler 
* Version     : 1.0 
* Created Date: 10-12-2021
* Modification Log :
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - HP       10/12/2021          Created for extending Trigger framework to process Account Onboarding business logic methods.
*****************************************************************************************************************************************/
public class Core_MDF_AccountOnboardingTriggerHandler extends TriggerHandler{
    public override void beforeInsert(){
            if(isActive('Core_MDF_AccountOnboardOnBeforeInsert')){
                Core_MDF_AccountOnboardingHelper.accountOnboardingOnBeforeInsert((List<Core_MDF_Account_Onboarding__c>) Trigger.NEW);
            }
        
    }
    public override void afterInsert(){
            if(isActive('Core_MDF_AccountOnboardOnAfterInsert')){
            Core_MDF_AccountOnboardingHelper.accountOnboardingOnAfterInsert((List<Core_MDF_Account_Onboarding__c>) Trigger.NEW);
        }
    }
}