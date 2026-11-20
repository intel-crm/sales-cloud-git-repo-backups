/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PartnerFundAllocation 
* Version           : 1.0 
* Created Date      : AUG-5-2018
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - athoma10     8/5/2018        Trigger on Partner Fund Allocation object.
*****************************************************************************************************************************************/
trigger Core_MDF_PartnerFundAllocation on PartnerFundAllocation(    before insert, 
                                                                    before update, 
                                                                    before delete, 
                                                                    after insert, 
                                                                    after update, 
                                                                    after delete
                                                                ){

new Core_MDF_PFA_TriggerHandler().run();

}