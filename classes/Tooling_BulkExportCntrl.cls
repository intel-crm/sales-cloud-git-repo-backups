public without sharing class Tooling_BulkExportCntrl {
    @AuraEnabled
    public static List<SObject> fetchRecords(String parameters) {
        RecordQuery params = (RecordQuery)JSON.deserialize(parameters, RecordQuery.class);
        String query = String.escapeSingleQuotes(params.query) ;
        String filterFieldName = String.escapeSingleQuotes(params.filterFieldName);
        List<String> values = params.values;
        try{
            query += ' WHERE ' + filterFieldName + ' IN :values';
            List<SObject> recordList = Database.query(query);
            return recordList;
        }catch(Exception ex){return null;}
        
    }
    
    public class RecordQuery {
        public String query { get; set; }
        public String filterFieldName { get; set; }
        public List<String> values { get; set; }
    }
}