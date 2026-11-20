/*************************************************************************************************************************************
Apex Class Name     : PRM_AccountChangeEventSubscriber 
Created Date        : Nov 2023
Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Shraddha                Nov - 2023           Trigger on ACM_Account_Request_Event__e
***************************************************************************************************************************************/

trigger PRM_AccountRequestEventTrigger on ACM_Account_Request_Event__e (after insert) {
    //IPA method to process the Account Request Queue response
    if(TriggerHandler.isActive('PRM_UCD_Switch')) {
        PRM_AccountChangeEventSubscriber.processACMResponseForRegistration(Trigger.New);
    }
}