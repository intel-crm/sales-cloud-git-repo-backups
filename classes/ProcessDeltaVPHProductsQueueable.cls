/*********************************************************************************************************************
* Apex Class Name  : ProcessDeltaVPHProductsQueueable
* Author And Date  : Rohit Podder, 20 MAR 2026
* Function         : Orchestrates PIM API calls to store product data into Product Inbound Staging
*********************************************************************************************************************/
public class ProcessDeltaVPHProductsQueueable implements Queueable, Database.AllowsCallouts {
    
    private static final Integer DEFAULT_LIMIT = 50000;
    private static final Integer DEFAULT_OFFSET = 1;
    private static final Integer REDUCED_LIMIT = 1000;
    private static final Integer MIN_CHUNK_SIZE = 25;
    private static final Integer HEAP_THRESHOLD = 8000000;
    // Max response body size (chars) allowed before deserializing. The raw body and the object
    // graph JSON.deserialize builds both live on the heap at once (~3-4x the body size), so a
    // larger body would breach the ~12MB async heap limit inside deserialize (uncatchable).
    private static final Integer MAX_RESPONSE_BODY_SIZE = 2500000;
    
    private Set<String> setLevel1ProductId;
    private Integer count;
    private String ipassLoadId;
    private List<Product_Inbound_Staging__c> listPISTotalToUpsert;
    
    // Chunk-mode state: used when a single L1 id response exceeds heap and must be
    // reprocessed page-by-page across chained queueable jobs (fresh heap per job).
    private Boolean isChunkMode = false;
    private String chunkProductType;
    private Integer chunkOffset;
    private Integer chunkSize;
    private Boolean chunkLastNode = false;
    
    //private PIMApiService apiService;
    private ProductStagingDMLService dmlService;
    private ProductHierarchyFieldMapper fieldMapper;
    
    private final String todayDate = Label.PIM_Api_EndDate != 'Null'? Label.PIM_Api_EndDate : String.valueOf(Date.today());
    private final String yesterdayDate = Label.PIM_Api_StartDate != 'Null'? Label.PIM_Api_StartDate : String.valueOf(Date.today().addDays(-1));
    
    public ProcessDeltaVPHProductsQueueable(Set<String> setLevel1ProductsId) {
        this.setLevel1ProductId = setLevel1ProductsId;
        this.count = 0;
        this.ipassLoadId = String.valueOf(DateTime.now().getTime());
        this.listPISTotalToUpsert = new List<Product_Inbound_Staging__c>();
        initializeServices();
    }
    
    public ProcessDeltaVPHProductsQueueable(Integer count, Set<String> setLevel1ProductId, String ipassLoadId, List<Product_Inbound_Staging__c> listPis) {
        this.setLevel1ProductId = setLevel1ProductId;
        this.count = count;
        this.ipassLoadId = ipassLoadId;
        this.listPISTotalToUpsert = listPis;
        initializeServices();
    }
    
    /**
* Chunk-mode constructor. Reprocesses a single failed product fetch (VPH for the L1 id at
* the given count, or VPLCH) one page at a time using chunkOffset and REDUCED_LIMIT, so each
* chained job runs with a fresh heap.
*/
    public ProcessDeltaVPHProductsQueueable(Integer count, Set<String> setLevel1ProductId, String ipassLoadId,
                                            List<Product_Inbound_Staging__c> listPis, String chunkProductType, Integer chunkOffset, Integer chunkSize, Boolean chunkLastNode) {
                                                this.setLevel1ProductId = setLevel1ProductId;
                                                this.count = count;
                                                this.ipassLoadId = ipassLoadId;
                                                this.listPISTotalToUpsert = listPis;
                                                this.isChunkMode = true;
                                                this.chunkProductType = chunkProductType;
                                                this.chunkOffset = chunkOffset;
                                                this.chunkSize = chunkSize;
                                                this.chunkLastNode = chunkLastNode;
                                                initializeServices();
                                            }
    
    private void initializeServices() {
        //this.apiService = new PIMApiService();
        this.dmlService = new ProductStagingDMLService();
        this.fieldMapper = new ProductHierarchyFieldMapper(ipassLoadId);
    }
    
    public void execute(QueueableContext qc) {
        if (isChunkMode) {
            executeChunkMode();
            return;
        }
        Boolean lastNode = false;
        Boolean diverted = false;
        try {
            lastNode = processCurrentNode();
        } catch (Exception e) {
            diverted = handleHeapSizeException(e, count == setLevel1ProductId.size() - 1);
            if (!diverted) {
                // Non-heap failure: preserve previous behaviour (log and keep the chain moving).
                lastNode = (count == setLevel1ProductId.size() - 1);
            }
        }
        if (diverted) {
            // The chunked reprocessing job will continue the chain and finalize the load.
            return;
        }
        if (lastNode) {
            finalizeLoad();
        } else {
            enqueueNextNodeIfNeeded();
        }
    }
    
    private Boolean processCurrentNode() {
        String currentL1Id = new List<String>(setLevel1ProductId)[count];
        System.debug('l1 product count '+count);
        System.debug('l1 product ' +new List<String>(setLevel1ProductId)[count]);
        System.debug('IpassLoadId '+ipassLoadId);
        ProductHierarchyWrapper phwVPH = fetchAndValidateResponse(currentL1Id, DEFAULT_LIMIT, DEFAULT_OFFSET, 'VPH');
        // Persist this node's records immediately (bounded heap) instead of accumulating every
        // node's records across the whole queueable chain, which previously grew until the async
        // heap limit was exceeded. The load is processed once from the database at the last node.
        if (phwVPH != null) {
            dmlService.upsertStagingRecordsOnly(fieldMapper.mapToStagingRecords(phwVPH, 'VPH'), ipassLoadId);
        }
        
        Boolean lastNode = (count == setLevel1ProductId.size() - 1);
        if (lastNode) {
            ProductHierarchyWrapper phwVplch = fetchAndValidateResponse(null, DEFAULT_LIMIT, DEFAULT_OFFSET, 'VPLCH');
            if (phwVplch != null) {
                dmlService.upsertStagingRecordsOnly(fieldMapper.mapToStagingRecords(phwVplch, 'VPLCH'), ipassLoadId);
            }
        }
        return lastNode;
    }
    
    /**
* Handles a heap-size failure by enqueuing a chunk-mode job that reprocesses the failed
* product fetch page-by-page (passing the L1 id and chunk size). Returns true when the work
* was diverted to the chunk chain.
*/
	@TestVisible
    private Boolean handleHeapSizeException(Exception e, Boolean lastNode) {
        String productType = determineProductTypeFromException(e);
        if (productType == null) {
            // Not a heap-size failure: log and let the caller continue as before.
            UCD_ACM_Logger.error('ProcessDeltaVPHProductsQueueable', 'execute', 'Message: ' + e.getMessage(), null);
            UCD_ACM_Logger.setLogDetails();
            return false;
        }
        if(!Test.isRunningTest()){
            System.enqueueJob(new ProcessDeltaVPHProductsQueueable(
                count, setLevel1ProductId, ipassLoadId, listPISTotalToUpsert, productType, 1, REDUCED_LIMIT, lastNode));
        }
        return true;
    }
    
    /**
* Chunk-mode driver: fetches one page for the failed product fetch, persists it immediately
* (keeping heap bounded), then either chains the next page or advances the main flow.
*/
    private void executeChunkMode() {
        try {
            if (processOneChunk()) {
                // More pages remain: chain the next page at the same chunk size.
                enqueueChunk(chunkProductType, chunkOffset + 1, chunkSize, chunkLastNode);
            } else {
                advanceAfterChunks();
            }
        } catch (CalloutException ce) {
            // A single page still exceeded the 12MB callout limit: shrink the page size and retry
            // the same record range (reducedOffset keeps the start aligned for the smaller page).
            if (isSizeLimitException(ce) && chunkSize > MIN_CHUNK_SIZE) {
                Integer reducedSize = Math.max(chunkSize / 2, MIN_CHUNK_SIZE);
                Integer reducedOffset = (2 * chunkOffset) - 1;
                UCD_ACM_Logger.error('ProcessDeltaVPHProductsQueueable', 'executeChunkMode',
                                     'Response over callout size limit; reducing chunk size from ' + chunkSize + ' to ' + reducedSize, null);
                UCD_ACM_Logger.setLogDetails();
                enqueueChunk(chunkProductType, reducedOffset, reducedSize, chunkLastNode);
            } else {
                UCD_ACM_Logger.error('ProcessDeltaVPHProductsQueueable', 'executeChunkMode', 'Message: ' + ce.getMessage(), null);
                UCD_ACM_Logger.setLogDetails();
                advanceAfterChunks();
            }
        } catch (Exception e) {
            UCD_ACM_Logger.error('ProcessDeltaVPHProductsQueueable', 'executeChunkMode', 'Message: ' + e.getMessage(), null);
            UCD_ACM_Logger.setLogDetails();
            advanceAfterChunks();
        }
    }
    
    private void enqueueChunk(String productType, Integer offset, Integer size, Boolean lastNode) {
        System.enqueueJob(new ProcessDeltaVPHProductsQueueable(
            count, setLevel1ProductId, ipassLoadId, listPISTotalToUpsert, productType, offset, size, lastNode));
    }
    
    /**
* Fetches and persists a single page for the current chunk. Returns true when more pages
* remain for this product fetch.
*/
    private Boolean processOneChunk() {
        String l1Product = (chunkProductType == 'VPH') ? new List<String>(setLevel1ProductId)[count] : null;
        ProductHierarchyWrapper phw = fetchChunk(l1Product, chunkSize, chunkOffset, chunkProductType);
        if (phw == null) {
            return false;
        }
        // Persist this page directly (no downstream trigger); the load is processed once at the end.
        dmlService.upsertStagingRecordsOnly(fieldMapper.mapToStagingRecords(phw, chunkProductType), ipassLoadId);
        Integer recordCount = parseRecordCount(phw.count);
        return (chunkOffset * chunkSize) < recordCount;
    }
    
    /**
* After all pages of the failed fetch are processed, continue the main flow: resume the next
* L1 id, move on to VPLCH for the last node, or finalize the load.
*/
    private void advanceAfterChunks() {
        if (chunkProductType == 'VPH') {
            if (chunkLastNode) {
                // Last VPH node done -> reprocess VPLCH in chunks, then finalize.
                enqueueChunk('VPLCH', 1, REDUCED_LIMIT, true);
            } else {
                // Resume the main chain at the next L1 id.
                System.enqueueJob(new ProcessDeltaVPHProductsQueueable(
                    count + 1, setLevel1ProductId, ipassLoadId, listPISTotalToUpsert));
            }
        } else {
            finalizeLoad();
        }
    }
    
    /**
* Upserts any records still held in memory and ensures the inbound staging load is processed
* exactly once, even when every record was persisted via chunk reprocessing.
*/
    private void finalizeLoad() {
        if (listPISTotalToUpsert != null && !listPISTotalToUpsert.isEmpty()) {
            dmlService.upsertStagingRecords(listPISTotalToUpsert, ipassLoadId);
        } else {
            Product_ProcessInboundStagingRecords.processInboundStagingRecords(new List<String>{ipassLoadId});
        }
    }
    
    private Integer parseRecordCount(String countValue) {
        if (String.isBlank(countValue)) {
            return 0;
        }
        String trimmed = countValue.trim();
        Integer spaceIndex = trimmed.indexOf(' ');
        String numericPart = (spaceIndex > 0) ? trimmed.subString(0, spaceIndex) : trimmed;
        try {
            return Integer.valueOf(numericPart);
        } catch (Exception ex) {
            return 0;
        }
    }
    
    private String determineProductTypeFromException(Exception e) {
        if (e.getMessage().contains('Exceeded max size limit for VPH')) {
            return 'VPH';
        } else if (e.getMessage().contains('Exceeded max size limit for VPLCH')) {
            return 'VPLCH';
        }
        return null;
    }
    
    private void enqueueNextNodeIfNeeded() {
        if (count < setLevel1ProductId.size() - 1) {
            count++;
            System.enqueueJob(new ProcessDeltaVPHProductsQueueable(count, setLevel1ProductId, ipassLoadId, listPISTotalToUpsert));
        }
    }
    
    private ProductHierarchyWrapper fetchAndValidateResponse(String l1Product, Integer recordLimit, Integer offset, String productType) {
        Core_ACM_CalloutService.RequestConfig rc = Core_ACM_CalloutService.getRequestConfig('PIM');
        HttpResponse res;
        try {
            res = invokeHierarchyCallout(rc, l1Product, recordLimit, offset, productType);
        } catch (CalloutException ce) {
            // Response too large for a single callout (>12MB) -> divert to chunked reprocessing.
            if (isSizeLimitException(ce)) {
                throw new CustomException('Exceeded max size limit for ' + productType);
            }
            throw ce;
        }
        if (res.getStatusCode() == 200) {
            String body = res.getBody();
            // Guard BEFORE deserialization: an oversized body cannot be safely deserialized within
            // the async heap limit (the exception fires inside JSON.deserialize and is uncatchable).
            // Divert to the page-by-page chunk chain, which fetches far smaller pages.
            if (body.length() > MAX_RESPONSE_BODY_SIZE || Limits.getHeapSize() > HEAP_THRESHOLD) {
                throw new CustomException('Exceeded max size limit for ' + productType);
            }
            return (ProductHierarchyWrapper) JSON.deserialize(body, ProductHierarchyWrapper.class);
        } else {
            return null;
        }
    }
    
    /**
* Chunk-mode fetch: deserializes a single page without the heap-threshold guard. The page is
* bounded by the current chunk size, and any oversized-callout failure propagates so the
* caller can shrink the chunk size and retry.
*/
    private ProductHierarchyWrapper fetchChunk(String l1Product, Integer recordLimit, Integer offset, String productType) {
        Core_ACM_CalloutService.RequestConfig rc = Core_ACM_CalloutService.getRequestConfig('PIM');
        HttpResponse res = invokeHierarchyCallout(rc, l1Product, recordLimit, offset, productType);
        if (res.getStatusCode() == 200) {
            return (ProductHierarchyWrapper) JSON.deserialize(res.getBody(), ProductHierarchyWrapper.class);
        }
        return null;
    }
    
    private HttpResponse invokeHierarchyCallout(Core_ACM_CalloutService.RequestConfig rc, String l1Product, Integer recordLimit, Integer offset, String productType) {
        String endPoint;
        if (productType == 'VPLCH') {
            endPoint = rc.endPoint + 'hierarchyLevels?limit=' + recordLimit + '&offset=' + offset + '+&hierarchyName=VPLCH_Hierarchy&modifiedDateFrom=' + yesterdayDate + '&modifiedDateTo=' + todayDate + '&includeInactive=true';
        } else if (productType == 'VPH') {
            endPoint = rc.endPoint + 'hierarchyLevels?hierarchyName=VPH_Hierarchy&offset=' + offset + '&limit=' + recordLimit + '&l1id=' + l1Product + '&modifiedDateFrom=' + yesterdayDate + '&modifiedDateTo=' + todayDate + '&includeInactive=true';
        }
        // Use a raw HTTP send (instead of Core_RestClient, which swallows callout failures) so the
        // "Exceeded max size limit of 12000000" CalloutException surfaces and can trigger chunking.
        HttpRequest req = new HttpRequest();
        req.setMethod(rc.method);
        req.setEndpoint(endPoint);
        req.setTimeout(rc.timeoutMs == null ? 30000 : rc.timeoutMs);
        return new Http().send(req);
    }
    
    @TestVisible
    private Boolean isSizeLimitException(Exception e) {
        return e != null && e.getMessage() != null && e.getMessage().containsIgnoreCase('max size limit');
    }
    
    public class CustomException extends Exception {}
}