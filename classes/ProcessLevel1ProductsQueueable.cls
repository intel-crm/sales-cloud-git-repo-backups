/***************************************************************************************************************************
 * Apex Class Name  : ProcessLevel1ProductsQueueable
 * Author And Date  : Rohit Podder, 20 MAR 2026
 * Function         : Orchestrates retrieval of Level 1 products from PIM API
 ****************************************************************************************************************************/
public class ProcessLevel1ProductsQueueable implements Queueable, Database.AllowsCallouts {
    
    private static final Integer MAX_CALLOUTS_PER_EXECUTION = 100;
    private static final Integer DEFAULT_LIMIT = 5000;
    
    private Map<String, String> mapNameLevel1ProductIds;
    private Integer totalRecordProcessed;
    private Integer totalRecordCount;
    private Integer offset;
    
    //private PIMApiService apiService;
    private Level1ProductSettingService settingService;
    private Level1ProductResponseParser responseParser;
    
    public ProcessLevel1ProductsQueueable() {
        this.mapNameLevel1ProductIds = new Map<String, String>();
        this.totalRecordProcessed = 0;
        this.totalRecordCount = 0;
        this.offset = 1;
        //this.apiService = new PIMApiService();
        this.settingService = new Level1ProductSettingService();
        this.responseParser = new Level1ProductResponseParser();
    }
    
    public void execute(QueueableContext qc) {
        try {
            fetchAllLevel1Products();
            if (!mapNameLevel1ProductIds.isEmpty()) {
                settingService.createOrUpdateSettings(mapNameLevel1ProductIds);
                System.enqueueJob(new ProcessDeltaVPHProductsQueueable(new Set<String>(mapNameLevel1ProductIds.values())));
            }
        } catch (Exception e) {
            System.debug(e);
            UCD_ACM_Logger.error('ProcessLevel1ProductsQueueable', 'execute', 'Message: ' + e.getMessage(), null);
            UCD_ACM_Logger.setLogDetails();
        }
    }
    
    private void fetchAllLevel1Products() {
        try{
            processLevel1Product(offset, DEFAULT_LIMIT);
            Integer calloutsUsed = 1;
            while (totalRecordProcessed < totalRecordCount && calloutsUsed < MAX_CALLOUTS_PER_EXECUTION) {
                offset++;
                processLevel1Product(offset, DEFAULT_LIMIT);
                calloutsUsed++;
                totalRecordProcessed += DEFAULT_LIMIT;
            }
        }catch (Exception e) {
            UCD_ACM_Logger.error('ProcessLevel1ProductsQueueable', 'fetchAllLevel1Products', 'Message: ' + e.getMessage(), null);
        } finally {
            UCD_ACM_Logger.setLogDetails();
        }
    }
    
    private void processLevel1Product(Integer currentOffset, Integer currentLimit) {
            //System.debug('enter');
            Core_ACM_CalloutService.RequestConfig rc = Core_ACM_CalloutService.getRequestConfig('PIM');
            String endPoint = rc.endPoint + 'hierarchies?localeGeoId=en-US&hierarchyName=VPH_Hierarchy&offset=' + currentOffset + '&limit=' + currentLimit;
            Core_RestClient restClient = new Core_RestClient(
                endPoint,
                rc.method,
                new Map<String,String>(),
                '',
                rc.timeoutMs == null ? Core_ACM_Constants.API_TIMEOUT : rc.timeoutMs
            );
            HttpResponse response = restClient.invokeAPI();
            //HttpResponse response = apiService.getHierarchyCategories(currentOffset, currentLimit);
            if (response.getStatusCode() == 200) {
                Level1ProductResponseWrapper lrw = responseParser.parse(response);
                totalRecordCount = (Integer) lrw.metadata.count;
                totalRecordProcessed += (Integer) lrw.metadata.limitValue;
                Map<String, String> rootCategories = responseParser.extractRootCategories(lrw);
                mapNameLevel1ProductIds.putAll(rootCategories);
                System.debug('mapNameLevel1ProductIds'+mapNameLevel1ProductIds);
            } else {
                UCD_ACM_Logger.error('ProcessLevel1ProductsQueueable', 'processLevel1Product', 'Message: ' + response.toString(), null);
            }
    }
}