public class Sales_ValidateAccountOnRenew {
    public Boolean status=true; 
    @AuraEnabled
    public static Boolean validateAccount(String contId) {
        System.debug('Inside contract:'+contId);
        Contract contractRecord=[select Id,Account.Core_Is_Active__c from Contract where Id=:contId limit 1];
        if(contractRecord.Account.Core_Is_Active__c==true) {
            
            return true;
        }
        else {
            return false;
        } 
    }
}