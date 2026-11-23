public class LOVChange {


    public static void updatePicklistValue( )
    {
       
       
// Fetch records with specific picklist value
List<Core_Design_Registration__c> recordsToUpdate = [SELECT id , name, Core_Product_Application_Nm__c, Core_Product_Segment_Nm__c from Core_Design_Registration__c  WHERE  Core_Product_Application_Nm__c ='Wireless radio'];

// Update records with a new picklist value
if(recordsToUpdate.size() > 0) {
    for(Core_Design_Registration__c record : recordsToUpdate) {
       // record.Core_Product_Application_Nm__c = 'Wireless Baseband/Radio';
           System.debug(' records found with the specified picklist value.');

    }
    
    // Update records
    /*try {
        update recordsToUpdate;
        System.debug('Records updated successfully.');
    } catch(Exception e) {
        System.debug('Error updating records: ' + e.getMessage());
    
}*/
}
    else {
    System.debug('No records found with the specified picklist value.');
}

      
    }
}