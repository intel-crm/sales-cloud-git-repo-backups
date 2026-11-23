public class AccountPlanControllerLWC {

    @AuraEnabled(cacheable=true)
    public static List<Hot_Button__c> getHotButtons() {
        return [SELECT Id, Title__c, Description__c, Status__c FROM Hot_Button__c WHERE Account_Plan__c = :UserInfo.getUserId()];
    }

 
}