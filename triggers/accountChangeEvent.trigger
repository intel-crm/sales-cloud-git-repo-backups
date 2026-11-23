trigger accountChangeEvent on ACM_Account_Change_Event__e (after insert) {
    //Tenders IQR method to process the ACM response
    if(TriggerHandler.isActive('Pricing_UCD_Switch')) {
        System.debug('New data===>'+trigger.new);
        Pricing_UCD_IQR_Response_Handler.processACMResponseForUnification(Trigger.New);
    }
}