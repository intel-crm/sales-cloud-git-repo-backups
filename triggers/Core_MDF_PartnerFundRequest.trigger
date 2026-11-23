/****************************************************************************************************************************************
* Trigger Name  : Core_MDF_PartnerFundRequest 
* Version     : 1.0 
* Created Date: 08-21-2018
* Modification Log :
* Description:                                                
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel-Narayani Perachi        8/21/2018                     Trigger to handle Core MDF PartnerFundRequest functionalities. 
*****************************************************************************************************************************************/
trigger Core_MDF_PartnerFundRequest on PartnerFundRequest (before update, after insert, after update, before insert) {
    
    new Core_MDF_PartnerRequestTriggerHandler().run();

}