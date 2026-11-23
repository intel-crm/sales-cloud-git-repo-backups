public class UCD_ACM_accountChangeEventHandler {
/* unused code
    public static void updateIntegrationMessageStatus(List<ACM_Account_Change_Event__e> newaccountChangeEvents){
        Set<Id> accountIds = new Set<Id>();
        List<ACM_Integration_Message_Queue__c> integrationMessageToUpdate = new List<ACM_Integration_Message_Queue__c>();

        For(ACM_Account_Change_Event__e accountChangeEvent: newAccountChangeEvents){
           UCD_ACM_Models.AccountResponseModel platformEventResponse = (UCD_ACM_Models.AccountResponseModel) System.JSON.deserialize(accountChangeEvent.Message__c,UCD_ACM_Models.AccountResponseModel.class);
           accountIds.add(platformEventResponse.AccountId);
        }

        if(accountIds != null && accountIds.size() > 0){
            if (Schema.sObjectType.ACM_Integration_Message_Queue__c.fields.Message_Status__c.isAccessible()){
                For(ACM_Integration_Message_Queue__c integrationMessage : [Select Id,Message_Status__c from ACM_Integration_Message_Queue__c where Custom_Filter__c=: accountIds and Content_Type__c = 'AccountId']){
                    integrationMessage.Message_Status__c = 'Success';
                    integrationMessageToUpdate.add(integrationMessage);
                }
            }
            
        }

        if(integrationMessageToUpdate != null && integrationMessageToUpdate.size() > 0){
            if(Schema.sObjectType.ACM_Integration_Message_Queue__c.fields.Message_Status__c.isUpdateable()){
                update integrationMessageToUpdate;
            }
        }
    }*/
}