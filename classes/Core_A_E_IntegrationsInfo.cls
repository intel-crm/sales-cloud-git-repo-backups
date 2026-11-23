public class Core_A_E_IntegrationsInfo {
    
    @AuraEnabled
    Public static List<Contact> getContactDetails(String emailOrEnterpriseId){
        return [SELECT Id, Name from Contact WHERE email =: emailOrEnterpriseId];
    }
    
}