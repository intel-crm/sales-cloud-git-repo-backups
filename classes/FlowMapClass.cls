public class FlowMapClass {
    
    @AuraEnabled @InvocableVariable(label = 'notificationName')
    public string notificationType; //Map key
    
    @AuraEnabled @InvocableVariable(label = 'objectName')
    public string objectName; //Map value
    
    @AuraEnabled @InvocableVariable
    public List<Id> userIdList;
      
    @AuraEnabled @InvocableVariable
    public List<String> userEmailList;
    
    public FlowMapClass(){}
}