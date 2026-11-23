public class Tooling_BulkExportCntrl {
    @AuraEnabled
    public static List<SObject> fetchRecords(String query, String filterFieldName, List<String> values) {
        try{
            query += ' WHERE ' + filterFieldName + ' IN :values';
            System.debug('Query --> ' + query);
            
            List<SObject> recordList = Database.query(query);
            
            System.debug('Record List --> ' + recordList);
            
            return recordList;
        }catch(Exception ex){return null;}
    }
}