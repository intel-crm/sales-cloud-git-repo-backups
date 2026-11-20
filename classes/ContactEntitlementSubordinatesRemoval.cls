public  without sharing class ContactEntitlementSubordinatesRemoval{
    @testVisible static Map<String, List<Contact_Entitlement_Subordinates_Removal__mdt>> customMetadataRecordsMap = new Map<String, List<Contact_Entitlement_Subordinates_Removal__mdt>>();
     
    public List<Contact_Entitlement_Subordinates_Removal__mdt> getCustomMetadataRecords(String query) {
        if ( !customMetadataRecordsMap.containsKey( query ) ) {
            customMetadataRecordsMap.put( query, Database.query( query ) );
        }
        return customMetadataRecordsMap.get( query );
    }
}