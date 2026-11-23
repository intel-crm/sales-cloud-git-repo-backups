public class ER_ABT_TriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
       // TWC722-178 Commented
        /*if(isActive('ER_Insert_ABT_Check')) {
            //Perform validations before insertion on ABT
           // ER_ABT_TriggerHandler_Utility.ABTValidations(Trigger.New); // TWC722-178 Commented, because standard validations rules are implemented
        }*/
    }
    
    public override void beforeUpdate() {
    
    }
    
    public override void afterInsert() {        
        
    }
    
  
    public override void afterUpdate() {
        System.debug('before ER_Update_ABT_Check');
        if(isActive('ER_Update_ABT_Check')){
            //Reject all CBTs if ABT status is changed to Rejected
            System.debug('ER_Update_ABT_Check inside');
            ER_ABT_TriggerHandler_Utility.RejectCBTStatus(Trigger.New, (Map<Id, Account_Business_Types__c>)Trigger.OldMap);
        }
    }
}