/****************************************************************************************************************************************
* Trigger Name  : Core_MDF_CampaignBlockCreation_Class 
* Version     : 1.0 
* Created Date: 7-10-2018
* Modification Log :
* Description:                                                US106392 - Change External Campaign Visibility Date
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shridhar K                    7/5/2018                     Trigger to handle Core MDF cmapaign functionalities. 
* Harika P                      8/10/2018                    Added trigger contexts after insert and after update to share campaigns.
*****************************************************************************************************************************************/
trigger Core_MDF_Campaign on Campaign (before insert, before update, after insert, after update) {            

    //new Core_MDF_CampaignTriggerHandler().run();
    
}