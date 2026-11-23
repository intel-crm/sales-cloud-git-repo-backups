/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PartnerGroupDomainMappingTrigger 
* Version           : 1.0 
* Created Date      : 06-Mar-2020
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VD       06-Mar-2020      Trigger on Partner Group Domain Mapping object.
*****************************************************************************************************************************************/

trigger Core_MDF_PartnerGroupDomainMappingTrigger on Core_MDF_Partner_Group_Domain_Mapping__c (before insert,after insert) {
    try{                                                                              
        new Core_MDF_PGDMTriggerHandler().run();
    }    
    catch(Exception e){
        System.debug('exception'+e.getMessage());
    }
}