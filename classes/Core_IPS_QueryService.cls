public without sharing class Core_IPS_QueryService {
    public static List<SObject> queryRecords(String query,Map<String, Object>  parameter){
        return Database.queryWithBinds(query,
                                       parameter, 
                                       AccessLevel.SYSTEM_MODE);
    }
    public static List<SObject> queryRecords(String query) {
        return Database.query(query,AccessLevel.SYSTEM_MODE);
    }
    public static Map<Id, SObject> queryRecordsAsMap(String query, Map<String, Object> parameter) {
        return new Map<Id, SObject>(
            Database.queryWithBinds(query, parameter, AccessLevel.SYSTEM_MODE)
        );
    }
    public static SObject querySingleRecord(String query, Map<String, Object> params) {
        List<SObject> rows = queryRecords(query, params);
        return (rows != null && !rows.isEmpty()) ? rows[0] : null;
    }
    // Wrapper for dynamic SOQL
    public static List<SObject> executeDynamicQuery(String queryString) {
       if (String.isBlank(queryString)) {
            return new List<SObject>();
        }
        try {
            return Database.query(queryString, AccessLevel.SYSTEM_MODE);
        } catch (Exception e) {
          
            return new List<SObject>();
        }
    }
    
    // Wrapper for SOSL (No SYSTEM_MODE API exists)
    public static List<List<SObject>> executeSOSL(String queryString) {
        return Search.query(queryString);
    }
    
    public static List<SObject> updateRecords(List<SObject> records){
        if (records == null || records.isEmpty()) {
            return records;
        }

        Database.SaveResult[] saveResults = Database.update(records, false, AccessLevel.SYSTEM_MODE);
        List<String> errors = new List<String>();

        for (Integer i = 0; i < saveResults.size(); i++) {
            if (!saveResults[i].isSuccess()) {
                for (Database.Error dmlError : saveResults[i].getErrors()) {
                    errors.add(
                        'Record index ' + i + ': ' +
                        String.valueOf(dmlError.getStatusCode()) + ' - ' +
                        dmlError.getMessage()
                    );
                }
            }
        }

        if (!errors.isEmpty()) {
            //throw new QueryServiceException('Update failed. ' + String.join(errors, ' | '));
        }

        return records;
    }
    public static List<SObject> insertRecords(List<SObject> records){
        if (records == null || records.isEmpty()) {
            return records;
        }

        Database.SaveResult[] saveResults = Database.insert(records, false, AccessLevel.SYSTEM_MODE);
        List<String> errors = new List<String>();

        for (Integer i = 0; i < saveResults.size(); i++) {
            if (saveResults[i].isSuccess()) {
                records[i].put('Id', saveResults[i].getId());
            } else {
                for (Database.Error dmlError : saveResults[i].getErrors()) {
                    errors.add(
                        'Record index ' + i + ': ' +
                        String.valueOf(dmlError.getStatusCode()) + ' - ' +
                        dmlError.getMessage()
                    );
                }
            }
        }

        if (!errors.isEmpty()) {
            //throw new QueryServiceException('Insert failed. ' + String.join(errors, ' | '));
        }

        return records;
    }
    public static List<SObject> deleteRecords(List<SObject> records){
        if (records == null || records.isEmpty()) {
            return records;
        }

        Database.DeleteResult[] deleteResults = Database.delete(records, false, AccessLevel.SYSTEM_MODE);
        List<String> errors = new List<String>();

        for (Integer i = 0; i < deleteResults.size(); i++) {
            if (!deleteResults[i].isSuccess()) {
                for (Database.Error dmlError : deleteResults[i].getErrors()) {
                    errors.add(
                        'Record index ' + i + ': ' +
                        String.valueOf(dmlError.getStatusCode()) + ' - ' +
                        dmlError.getMessage()
                    );
                }
            }
        }

        if (!errors.isEmpty()) {
            //throw new QueryServiceException('Delete failed. ' + String.join(errors, ' | '));
        }

        return records;
    }
    public static List<SObject> upsertRecords(List<SObject> records){
        if (records == null || records.isEmpty()) {
            return records;
        }

        Database.UpsertResult[] upsertResults = Database.upsert(records, false, AccessLevel.SYSTEM_MODE);
        List<String> errors = new List<String>();

        for (Integer i = 0; i < upsertResults.size(); i++) {
            if (upsertResults[i].isSuccess()) {
                records[i].put('Id', upsertResults[i].getId());
            } else {
                for (Database.Error dmlError : upsertResults[i].getErrors()) {
                    errors.add(
                        'Record index ' + i + ': ' +
                        String.valueOf(dmlError.getStatusCode()) + ' - ' +
                        dmlError.getMessage()
                    );
                }
            }
        }

        if (!errors.isEmpty()) {
            //throw new QueryServiceException('Upsert failed. ' + String.join(errors, ' | '));
        }

        return records;
    }
    
    public static List<SObject> upsertRecords(List<SObject> records, Schema.SObjectField externalIdField){
        if (records == null || records.isEmpty()) {
            return records;
        }

        Database.UpsertResult[] upsertResults = Database.upsert(records, externalIdField, false, AccessLevel.SYSTEM_MODE);
        List<String> errors = new List<String>();

        for (Integer i = 0; i < upsertResults.size(); i++) {
            if (upsertResults[i].isSuccess()) {
                records[i].put('Id', upsertResults[i].getId());
            } else {
                for (Database.Error dmlError : upsertResults[i].getErrors()) {
                    errors.add(
                        'Record index ' + i + ': ' +
                        String.valueOf(dmlError.getStatusCode()) + ' - ' +
                        dmlError.getMessage()
                    );
                }
            }
        }

        if (!errors.isEmpty()) {
            //throw new QueryServiceException('Upsert failed. ' + String.join(errors, ' | '));
        }

        return records;
    }
}