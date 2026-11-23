public class ContactNotificationDisabler {
    
    @testVisible static Map<String, List<Core_Contact_Email_Notification_Disabler__mdt>> customMetadataRecordsMap 
        = new Map<String, List<Core_Contact_Email_Notification_Disabler__mdt>>();
    
    public List<Core_Contact_Email_Notification_Disabler__mdt> getCustomMetadataRecords(String soqlQuery) {
        if ( !customMetadataRecordsMap.containsKey(soqlQuery) ) {
            customMetadataRecordsMap.put( soqlQuery, Database.query(soqlQuery) );
        }
        System.debug('ContactNotificationDisabler : customMetadataRecordsMap ='+
                    ContactNotificationDisabler.customMetadataRecordsMap);
        return customMetadataRecordsMap.get(soqlQuery);
    }

}