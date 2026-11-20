/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PartnerNodeUserMapping 
* Version           : 1.0 
* Created Date      : 7-24-2018
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - SB       7/23/2018        Trigger on Partner Node User Mapping object.
*****************************************************************************************************************************************/
trigger Core_MDF_PartnerNodeUserMapping on Core_MDF_Partner_Node_User_Mapping__c (before insert,
                                                                                  before update,
                                                                                  before delete,
                                                                                  after insert,
                                                                                  after update,
                                                                                  after delete,
                                                                                  after undelete) {
                                                                                      
    new Core_MDF_PNUM_Mapping_TriggerHandler().run();
 }