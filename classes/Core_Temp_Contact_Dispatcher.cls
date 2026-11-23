public class Core_Temp_Contact_Dispatcher {
    
    public static void beforeMethod(List<Core_Temp_Contact_Upload__c> oldList, List<Core_Temp_Contact_Upload__c> newList, 
                                    Map<Id,Core_Temp_Contact_Upload__c> oldMap,Map<Id,Core_Temp_Contact_Upload__c> newMap)
    {
        System.debug(' Handler '+Trigger.New);        
    }
    public static void afterMethod(List<Core_Temp_Contact_Upload__c> oldList, List<Core_Temp_Contact_Upload__c> newList, 
                                   Map<Id,Core_Temp_Contact_Upload__c> oldMap,Map<Id,Core_Temp_Contact_Upload__c> newMap)
    {
        System.debug(' Handler '+Trigger.New);
    }
}