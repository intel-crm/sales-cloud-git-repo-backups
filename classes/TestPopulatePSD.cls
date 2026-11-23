public class TestPopulatePSD {
    public Core_Design_Registration_Product__c childRecord { get; set; }
    
    
 public TestPopulatePSD(ApexPages.StandardController controller) {
       childRecord = (Core_Design_Registration_Product__c)controller.getRecord();
        system.debug('childRecord>>'+childRecord);
        Core_Design_Registration_Product__c drId=[select Core_Design_Registration_Id__c from Core_Design_Registration_Product__c where id=:childRecord.id limit 1 ];
        // Query parent record and retrieve parent field value
        Core_Design_Registration__c parentRecord = [SELECT PCC_Pricing_Start_Date__c FROM Core_Design_Registration__c WHERE Id =:drId.Core_Design_Registration_Id__c LIMIT 1];
        system.debug('parentRecord>>'+parentRecord);
        // Set the value of the child field using parent field value
        childRecord.PCC_Quote_Line_Pricing_Start_Date__c = parentRecord.PCC_Pricing_Start_Date__c;
    }
    /*public TestPopulatePSD() {
    Id id=ApexPages.currentPage().getParameters().get('Id');
        
            Core_Design_Registration_Product__c drId=[select Core_Design_Registration_Id__c from Core_Design_Registration_Product__c where id=:id limit 1 ];
        // Query parent record and retrieve parent field value
        Core_Design_Registration__c parentRecord = [SELECT PCC_Pricing_Start_Date__c FROM Core_Design_Registration__c WHERE Id =:drId.Core_Design_Registration_Id__c LIMIT 1];
        system.debug('parentRecord>>'+parentRecord);
        // Set the value of the child field using parent field value
        childRecord.PCC_Quote_Line_Pricing_Start_Date__c = parentRecord.PCC_Pricing_Start_Date__c;    
    }*/




 
}