public Without Sharing class Core_MDF_SearchController {
    @AuraEnabled
    public static List<sObject> search(String objectName, List<String> fields, String searchTerm){
        String searchKeyword = searchTerm + '*';
        String returningQuery = '';
        List<List<sObject>> searchRecords = new List<List<sObject>>();
        try{
        returningQuery = objectName+' ( Id, '+String.join(fields,',')+')';
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 20';
        //List<List<sObject>> searchRecords = new List<List<sObject>>();
        List<SObject> sobjList = new List<SObject>();
        if(String.isBlank(searchTerm)){
            String soqlQuery = 'SELECT Id, Name, Type, LastViewedDate FROM RecentlyViewed WHERE Type =\''+String.escapeSingleQuotes(objectName)+'\' ORDER BY LastViewedDate DESC LIMIT 5';
            sobjList = Database.query( soqlQuery );
            searchRecords.add(sobjList);
        }else{
            searchRecords = Search.Query(Query);
        }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return searchRecords.get(0);
    }

    @AuraEnabled
    public static sObject getRecentlyCreatedRecord(String recordId, List<String> fields, String objectName){
        sObject createdRecord;
        try {
            String query = 'SELECT Id, '+String.escapeSingleQuotes(String.join(fields,','))+' FROM '+String.escapeSingleQuotes(objectName)+' WHERE Id = \''+String.escapeSingleQuotes(recordId)+'\'';
            
            List<SObject> sobjList = Database.query( query );
            createdRecord = sobjList.get(0);
            
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return createdRecord;
    }


}