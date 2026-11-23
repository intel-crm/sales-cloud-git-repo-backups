public with sharing  class  Demoflowclass {
    @invocablemethod
    public static void updateCustomObject( List<String> selectedIds) {
        System.debug('......'+selectedIds[0]);
        // Update the custom field for the selected records
        List<Contact> recordsToUpdate = [select id,Demo_field__c FROM contact WHERE Id IN :selectedIds];
        for (Contact record : recordsToUpdate) {
          
         
            record.Demo_field__c = true;
         
        }
        update recordsToUpdate;
    }
   
 
   
   
}