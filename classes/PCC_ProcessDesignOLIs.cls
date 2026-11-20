/****************************************************************************************************************************************
* Class Name  : PCC_ProcessDesignOLIs 
* Version     : 1.0 
* Created Date:  18-11-2024
* Modification Log :
* Developer            		  Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Aravind                        18-11-2024         This contains InvocableMethod called from platform event to create design OLIs
                                                  in asyn mode.
*****************************************************************************************************************************************/
public with sharing class PCC_ProcessDesignOLIs {
    /**
     * This method is used to reate design opportunity and related records.
     */
    @InvocableMethod(label='Process design reg OLI' description='Process design OLI')
    public static void processDesignOLIs(List<Id> ddrIds) {
        List<Id> oppIds = new List<Id>();
        for (Core_Design_Registration__c dr: [Select Id,Core_Opportunity_Id__c FROM Core_Design_Registration__c WHERE ID IN :ddrIds and Core_Opportunity_Id__c != null with USER_MODE]) {
            oppIds.add(dr.Core_Opportunity_Id__c);
        }
        String message = Core_DDR_Design_Handler_Utility.insertOppLineItems(oppIds, ddrIds);

        PCC_Deal_Approval_Process_Communication__e evt = new PCC_Deal_Approval_Process_Communication__e();
        evt.PCC_Object__c = 'Opportunity';
        evt.PCC_Record_ID__c = ddrIds[0];
        evt.PCC_Type__c = (String.isNotBlank(message) && message != 'null')? 'Failure' : 'Success';
        evt.PCC_Error_Message__c = (String.isNotBlank(message) && message != 'null')? message : '';
        evt.Design__c = true;
        Database.SaveResult result = EventBus.publish(evt);
    }
}