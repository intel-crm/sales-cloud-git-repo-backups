public class ER_CBT_TriggerHandler extends TriggerHandler {
    //To prevent calling handler class twice
    //Please make use of different variable for before/delete scenarios
    public static boolean firstRun = true;
    public override void beforeInsert() {
        if(isActive('ER_Before_Insert_ABT_Appd_Check')) {
            //Check if ABT status is approved before inserting CBT
            Core_Contact_Business_Type_Handler.ABTApprovedCheck(Trigger.new);
        }
        //Comment for TWC722-178 - This has been implemented in validation rule.
        /*if(isActive('ER_Before_Insert_CBT_Con_Eng_Name_Check')) {
//Check if contact english name exists
// Core_Contact_Business_Type_Handler.CBTContactEngNameCheck(Trigger.new); //Comment for TWC722-178
}*/
    }
    
    public override void beforeUpdate() {
        if(isActive('ER_Before_Update_ABT_Appd_Check')) {
            //Check if ABT status is approved before Updating CBT
            Core_Contact_Business_Type_Handler.ABTApprovedCheck(Trigger.new);
        }
        
    }
    
    public override void afterInsert() {        
        if(isActive('ER_Insert_Contact_Ent_Check')) {
            //Insert contact entitlement on CBT insert only on status Approval - Pending
            System.debug('In ENT');
            Core_Contact_Business_Type_Handler.insertContactEntitlement(Trigger.new);
        }
    }
    
    public override void afterUpdate() {
        if(isActive('ER_Update_Contact_Enttl_Check')){
            //Remove/add again contact entitlement on CBT update
            Core_Contact_Business_Type_Handler.updateContactEntitlement(Trigger.new, (Map<Id, Contact_Business_Types__c>)Trigger.OldMap);
            
            System.debug('In Subs');
            //Core_Contact_Business_Type_Handler.upsertSubscription(Trigger.new);
        }
        
         if(isActive('ER_eRPM_Integration_Check') && firstRun){
             Core_Contact_Business_Type_Handler.eRPMIntegrationCBTApproveReject(Trigger.new, (Map<Id, Contact_Business_Types__c>)Trigger.OldMap);
             firstRun = false;
         }
        if(isActive('ER_Update_Auto_Approve_Reg_Req'))
        {
            System.debug('In ER_Update_Auto_Approve_Reg_Req');
            ER_RegistrationUtility.autoApproveRegReq(Trigger.new, (Map<Id, Contact_Business_Types__c>)Trigger.OldMap);
        }
    }
    
}