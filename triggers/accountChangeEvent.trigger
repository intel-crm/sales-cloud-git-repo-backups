trigger accountChangeEvent on ACM_Account_Change_Event__e (after insert) {
    //Tenders IQR method to process the ACM response
    if(TriggerHandler.isActive('Pricing_UCD_Switch')) {
        Pricing_UCD_IQR_Response_Handler.processACMResponseForUnification(Trigger.New);
    }
    PRM_OPID_UCD_Hierarchy_Handler.processOpidUcdHierarchy(Trigger.New);
}