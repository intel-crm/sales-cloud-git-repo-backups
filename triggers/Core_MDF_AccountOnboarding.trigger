/****************************************************************************************************************************************
* Trigger Name  : Core_MDF_AccountOnboarding 
* Version     : 1.0 
* Created Date: 10-24-2021
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Harika P                    10-24-2021                     Trigger to handle account onboarding functionalities. 
*****************************************************************************************************************************************/
trigger Core_MDF_AccountOnboarding on Core_MDF_Account_Onboarding__c (after insert,before insert) {
    new Core_MDF_AccountOnboardingTriggerHandler().run();
}