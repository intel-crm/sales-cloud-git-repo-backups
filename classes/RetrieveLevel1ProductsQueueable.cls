public class RetrieveLevel1ProductsQueueable implements Queueable, Database.AllowsCallouts {
    
    // Constants
    private static final Integer DEFAULT_LIMIT = 10000;
    private static final Integer MAX_CALLOUTS_PER_EXECUTION = 100; // Salesforce limit
    private static final String ENDPOINT_BASE = 'callout:Product_Integration_Dev/pim/v1/services/hierarchies';
    private static final String LOCALE_GEO_ID = 'en-US';
    private static final String HIERARCHY_NAME = 'VPH_Hierarchy';
    private static final String ROOT_PARENT_ID = 'root';
    
    // Instance variables (not static to avoid issues with multiple executions)
    private Set<String> level1ProductIds;
    private Integer currentOffset;
    private Integer totalProcessed;
    private Integer totalRecords;
    
    // Default constructor
    public RetrieveLevel1ProductsQueueable() {
        this.level1ProductIds = new Set<String>();
        this.currentOffset = 1;
        this.totalProcessed = 0;
        this.totalRecords = 0;
    }
    
    // Constructor for chaining (to continue processing)
    public RetrieveLevel1ProductsQueueable(Set<String> existingIds, Integer offset, Integer processed, Integer total) {
        this.level1ProductIds = existingIds != null ? existingIds : new Set<String>();
        this.currentOffset = offset;
        this.totalProcessed = processed;
        this.totalRecords = total;
    }
    
    public void execute(QueueableContext qc) {
        try {
            processLevel1Products();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in RetrieveLevel1ProductsQueueable: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
        }
    }
    
    private void processLevel1Products() {
        Integer calloutsUsed = 0;
        
        // Process records in batches to respect callout limits
        while (calloutsUsed < MAX_CALLOUTS_PER_EXECUTION && shouldContinueProcessing()) {
            Level1ResponseWrapper response = fetchLevel1Products(currentOffset, DEFAULT_LIMIT);
            calloutsUsed++;
            
            if (response == null || response.metadata == null) {
                System.debug(LoggingLevel.ERROR, 'Invalid response received from API at offset: ' + currentOffset);
                break;
            }
            
            // Set total records on first call
            if (totalRecords == 0) {
                totalRecords = response.metadata.count;
            }
            
            // Process the response
            processResponse(response);
            
            // Update counters
            Integer recordsInThisBatch = response.categories != null ? response.categories.size() : 0;
            totalProcessed += recordsInThisBatch;
            currentOffset += DEFAULT_LIMIT;
            
            System.debug(LoggingLevel.INFO, 'Processed batch. Total processed: ' + totalProcessed + '/' + totalRecords);
        }
        
        // Check if we need to continue processing
        if (shouldContinueProcessing() && !hasReachedLimits()) {
            // Chain another queueable job
            System.enqueueJob(new RetrieveLevel1ProductsQueueable(level1ProductIds, currentOffset, totalProcessed, totalRecords));
        } else {
            // Processing complete
            finalizeProcessing();
        }
    }
    
    private Boolean shouldContinueProcessing() {
        return totalRecords == 0 || totalProcessed < totalRecords;
    }
    
    private Boolean hasReachedLimits() {
        return Limits.getQueueableJobs() >= Limits.getLimitQueueableJobs() - 1;
    }
    
    private Level1ResponseWrapper fetchLevel1Products(Integer offset, Integer limitValue) {
        try {
            HttpRequest req = buildHttpRequest(offset, limitValue);
            Http http = new Http();
            HttpResponse response = http.send(req);
            
            if (response.getStatusCode() == 200) {
                return parseResponse(response.getBody());
            } else {
                System.debug(LoggingLevel.ERROR, 'API call failed. Status: ' + response.getStatusCode() + 
                           ', Body: ' + response.getBody());
                return null;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception in API call: ' + e.getMessage());
            return null;
        }
    }
    
    private HttpRequest buildHttpRequest(Integer offset, Integer limitValue) {
        HttpRequest req = new HttpRequest();
        String endpoint = ENDPOINT_BASE + '?localeGeoId=' + LOCALE_GEO_ID + 
                         '&hierarchyName=' + HIERARCHY_NAME + 
                         '&offset=' + offset + 
                         '&limit=' + limitValue;
        
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(120000);
        
        return req;
    }
    
    private Level1ResponseWrapper parseResponse(String responseBody) {
        try {
            String modifiedJson = responseBody.replace('"_metadata":', '"metadata":')
                                            .replace('"limit":', '"limitValue":');
            
            return (Level1ResponseWrapper)JSON.deserialize(modifiedJson, Level1ResponseWrapper.class);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error parsing response: ' + e.getMessage());
            return null;
        }
    }
    
    private void processResponse(Level1ResponseWrapper response) {
        if (response.categories == null) {
            return;
        }
        
        for (Category category : response.categories) {
            if (ROOT_PARENT_ID.equals(category.parentId) && 
                String.isNotBlank(category.sourceId)) {
                level1ProductIds.add(category.sourceId);
            }
        }
        
        System.debug(LoggingLevel.DEBUG, 'Current Level 1 products count: ' + level1ProductIds.size());
    }
    
    private void finalizeProcessing() {
        System.debug(LoggingLevel.INFO, 'Processing complete. Total Level 1 products found: ' + level1ProductIds.size());
        System.debug(LoggingLevel.DEBUG, 'Level 1 Product IDs: ' + level1ProductIds);
        
        // Store the results in a static variable or custom setting for other processes to use
        storeResults();
        
        // Optionally trigger the next phase of processing
        triggerNextPhase();
    }
    
    private void storeResults() {
        // Convert Set to List and store in static variable for access by other classes
        RetrieveLevel1ProductsQueueable.setLevel1Products(new List<String>(level1ProductIds));
        
        // Alternatively, you could store in Custom Metadata, Custom Settings, or Platform Cache
        // Example with Platform Cache:
        // Cache.Org.put('Level1Products', level1ProductIds, 3600); // Cache for 1 hour
    }
    
    private void triggerNextPhase() {
        if (!level1ProductIds.isEmpty()) {
            // Example: Trigger delta processing for each Level 1 product
            System.debug(LoggingLevel.INFO, 'Ready to process delta changes for ' + level1ProductIds.size() + ' products');
            
            // You could enqueue another job here:
            // System.enqueueJob(new ProcessDeltaChangesQueueable(new List<String>(level1ProductIds)));
        }
    }
    
    // Static method to set Level 1 products (for external access)
    public static void setLevel1Products(List<String> products) {
        // Note: Using a static list can be problematic in a multi-tenant environment
        // Consider using Platform Cache or Custom Settings instead
        if (products != null) {
            // Store in Platform Cache for better reliability
            try {
                Cache.Org.put('Level1Products', products, 3600); // Cache for 1 hour
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN, 'Could not store in cache: ' + e.getMessage());
            }
        }
    }
    
    // Static method to get Level 1 products (for external access)
    public static List<String> getLevel1Products() {
        try {
            List<String> cachedProducts = (List<String>)Cache.Org.get('Level1Products');
            return cachedProducts != null ? cachedProducts : new List<String>();
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Could not retrieve from cache: ' + e.getMessage());
            return new List<String>();
        }
    }
    
    // Wrapper classes
    public class Level1ResponseWrapper {
        public List<Category> categories;
        public Metadata metadata;
    }
    
    public class Metadata {
        public Integer count;
        public Integer limitValue;
        public Integer offset;
    }
    
    public class Category {
        public String parentId;
        public String sourceId;
    }
}