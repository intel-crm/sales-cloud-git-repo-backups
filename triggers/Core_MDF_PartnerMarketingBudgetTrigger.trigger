/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PartnerMarketingBudgetTrigger 
* Version           : 1.0 
* Created Date      : 03-09-2018
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV       03-09-2018        Trigger on Partner Marketing Budget object.
*****************************************************************************************************************************************/
trigger Core_MDF_PartnerMarketingBudgetTrigger on PartnerMarketingBudget (before insert, before update,
                                                                          after update
                                                                                  ) {
    new Core_MDF_PMBTriggerHandler().run();                                                                                  
                                                                                      
}