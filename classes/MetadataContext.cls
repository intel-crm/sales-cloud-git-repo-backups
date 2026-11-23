public class MetadataContext {
    @AuraEnabled public Integer totalCustomFields;
    @AuraEnabled public Integer totalApexClasses;
    @AuraEnabled public Integer totalFlows;
    @AuraEnabled public Integer totalValidationRules;
    @AuraEnabled public String organizationType;
    @AuraEnabled public List<ObjectMetadata> objectsAnalyzed;
    
    public class ObjectMetadata {
        @AuraEnabled public String objectName;
        @AuraEnabled public Integer recordCount;
        @AuraEnabled public Integer customFieldCount;
        @AuraEnabled public List<FieldMetadata> fields;
    }
    
    public class FieldMetadata {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean isCustom;
        @AuraEnabled public Integer dataPopulationCount;
        @AuraEnabled public Decimal dataPopulationPercentage;
    }
    
    // Constants for optimization
    private static final Integer MAX_FIELDS_PER_CHUNK = 50; // Salesforce allows ~200 fields in SELECT, use 50 for safety
    private static final Integer MAX_FIELDS_TOTAL = 500; // Overall limit to prevent timeout
    
    public static MetadataContext buildContext(List<String> objectNames) {
        MetadataContext context = new MetadataContext();
        context.objectsAnalyzed = new List<ObjectMetadata>();
        
        for (String objName : objectNames) {
            ObjectMetadata objMeta = buildObjectMetadata(objName);
            if (objMeta != null) {
                context.objectsAnalyzed.add(objMeta);
            }
        }
        
        // Calculate totals
        context.totalCustomFields = calculateTotalCustomFields(context.objectsAnalyzed);
        context.organizationType = getOrgType();
        
        return context;
    }
    
    private static ObjectMetadata buildObjectMetadata(String objectName) {
        ObjectMetadata objMeta = new ObjectMetadata();
        objMeta.objectName = objectName;
        objMeta.fields = new List<FieldMetadata>();
        
        try {
            // ✅ FIXED: Remove unnecessary LIMIT (COUNT ignores it anyway)
            String countQuery = 'SELECT COUNT() FROM ' + objectName;
            objMeta.recordCount = Database.countQuery(countQuery);
            
            // Get field metadata
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
                .get(objectName).getDescribe().fields.getMap();
            
            // Collect custom fields first
            List<String> customFieldNames = new List<String>();
            Map<String, Schema.DescribeFieldResult> fieldDescribeMap = new Map<String, Schema.DescribeFieldResult>();
            
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                
                if (fieldDescribe.isCustom()) {
                    customFieldNames.add(fieldName);
                    fieldDescribeMap.put(fieldName, fieldDescribe);
                    
                    // Safety limit to prevent governor issues
                    if (customFieldNames.size() >= MAX_FIELDS_TOTAL) {
                        System.debug('⚠️ Reached max field limit (' + MAX_FIELDS_TOTAL + ') for ' + objectName);
                        break;
                    }
                }
            }
            
            // ✅ NEW: Calculate population counts in bulk (optimized chunked queries)
            Map<String, Integer> populationCounts = calculateFieldPopulations(objectName, customFieldNames, objMeta.recordCount);
            
            // Build field metadata with actual population data
            objMeta.customFieldCount = 0;
            
            for (String fieldName : customFieldNames) {
                Schema.DescribeFieldResult fieldDescribe = fieldDescribeMap.get(fieldName);
                
                FieldMetadata fieldMeta = new FieldMetadata();
                fieldMeta.name = fieldName;
                fieldMeta.label = fieldDescribe.getLabel();
                fieldMeta.type = String.valueOf(fieldDescribe.getType());
                fieldMeta.isCustom = true;
                
                // ✅ FIXED: Use actual calculated values instead of hardcoded 0
                fieldMeta.dataPopulationCount = populationCounts.get(fieldName);
                
                // Calculate percentage
                if (objMeta.recordCount > 0) {
                    fieldMeta.dataPopulationPercentage = 
                        (Decimal.valueOf(fieldMeta.dataPopulationCount) / objMeta.recordCount * 100).setScale(1);
                } else {
                    fieldMeta.dataPopulationPercentage = 0;
                }
                
                objMeta.fields.add(fieldMeta);
                objMeta.customFieldCount++;
            }
            
        } catch (Exception e) {
            System.debug('Error building metadata for ' + objectName + ': ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            return null;
        }
        
        return objMeta;
    }
    
    /**
     * ✅ NEW METHOD: Calculate field populations in optimized bulk queries
     * Uses chunking to avoid SOQL SELECT field limit (~200 fields max)
     */
    private static Map<String, Integer> calculateFieldPopulations(
        String objectName, 
        List<String> fieldNames,
        Integer totalRecords
    ) {
        Map<String, Integer> populationCounts = new Map<String, Integer>();
        
        // If no records, all fields are 0% populated
        if (totalRecords == 0) {
            for (String fieldName : fieldNames) {
                populationCounts.put(fieldName, 0);
            }
            return populationCounts;
        }
        
        // Split fields into chunks to avoid SOQL SELECT field limit
        Integer totalChunks = (Integer) Math.ceil(fieldNames.size() / (Decimal) MAX_FIELDS_PER_CHUNK);
        
        for (Integer i = 0; i < totalChunks; i++) {
            Integer startIdx = i * MAX_FIELDS_PER_CHUNK;
            Integer endIdx = Math.min(startIdx + MAX_FIELDS_PER_CHUNK, fieldNames.size());
            
            List<String> chunk = new List<String>();
            for (Integer j = startIdx; j < endIdx; j++) {
                chunk.add(fieldNames[j]);
            }
            
            // Query this chunk
            Map<String, Integer> chunkCounts = queryFieldPopulationChunk(objectName, chunk);
            populationCounts.putAll(chunkCounts);
        }
        
        return populationCounts;
    }
    
    /**
     * ✅ NEW METHOD: Query field population for a single chunk using aggregate COUNT
     */
    private static Map<String, Integer> queryFieldPopulationChunk(String objectName, List<String> fieldNames) {
        Map<String, Integer> counts = new Map<String, Integer>();
        
        try {
            // Build dynamic aggregate query
            // Example: SELECT COUNT(Field1__c) field1Count, COUNT(Field2__c) field2Count FROM Account
            List<String> selectClauses = new List<String>();
            Map<String, String> aliasToFieldMap = new Map<String, String>();
            
            for (String fieldName : fieldNames) {
                // Create safe alias (remove __c, replace special chars)
                String alias = fieldName.replace('__c', '').replace('_', '') + 'Count';
                selectClauses.add('COUNT(' + fieldName + ') ' + alias);
                aliasToFieldMap.put(alias, fieldName);
            }
            
            String query = 'SELECT ' + String.join(selectClauses, ', ') + ' FROM ' + objectName;
            
            System.debug('🔍 Population query: ' + query);
            
            // Execute aggregate query
            AggregateResult[] results = Database.query(query);
            
            if (!results.isEmpty()) {
                AggregateResult ar = results[0];
                
                // Extract counts from aggregate result
                for (String alias : aliasToFieldMap.keySet()) {
                    String fieldName = aliasToFieldMap.get(alias);
                    Integer count = (Integer) ar.get(alias);
                    counts.put(fieldName, count != null ? count : 0);
                }
            }
            
        } catch (Exception e) {
            System.debug('⚠️ Error querying field population chunk: ' + e.getMessage());
            // Return 0 for all fields in this chunk on error
            for (String fieldName : fieldNames) {
                counts.put(fieldName, 0);
            }
        }
        
        return counts;
    }
    
    private static Integer calculateTotalCustomFields(List<ObjectMetadata> objects) {
        Integer total = 0;
        for (ObjectMetadata obj : objects) {
            if (obj != null) {
                total += obj.customFieldCount;
            }
        }
        return total;
    }
    
    private static String getOrgType() {
        try {
            Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
            return org.IsSandbox ? 'Sandbox' : 'Production';
        } catch (Exception e) {
            System.debug('Error determining org type: ' + e.getMessage());
            return 'Unknown';
        }
    }
}