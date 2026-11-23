public class TestClass {
    public List<Core_Integration_Outbound_Message__c> fphList{get;set;}
    public TestClass(){
   fphList = new List<Core_Integration_Outbound_Message__c>();    
	if(Core_Integration_Outbound_Message__c.SObjectType.getDescribe().isAccessible()){
                fphList = [SELECT Id, Name FROM Core_Integration_Outbound_Message__c limit 1];        
            system.debug('RA4');
            }
            system.debug('RAZZICaseUtility lkjl'+fphList);        
    }
 
}