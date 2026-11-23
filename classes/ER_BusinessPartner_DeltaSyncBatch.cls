public class ER_BusinessPartner_DeltaSyncBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    // --- Runtime Variables ---
    @TestVisible
    private Datetime currentRunTime;
    @TestVisible
    private Datetime lastSyncTime;

    // --- Counters for summary ---
    private Integer totalProcessed = 0;
    private Integer totalInserted = 0;
    private Integer totalUpdated = 0;
    private Integer totalFailed = 0;

    // --- Logging Constants ---
    private static final String LOG_ENTRY_ORIGIN = 'S4MDG';
    private static final String LOG_ENTRY_PROJECT = 'BusinessPartnerDeltaSync';
    private static final String LOG_ENTRY_SCOPE = 'ER_BusinessPartner_DeltaSyncBatch';

    // --- Log Buffer ---
    private List<Core_Log_Entry__c> logBuffer = new List<Core_Log_Entry__c>();

    // --- Constructor ---
    public ER_BusinessPartner_DeltaSyncBatch() {
        currentRunTime = Datetime.now();
        lastSyncTime = getLastSyncTime();
    }

    // --- Batch Start ---
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Account LIMIT 1]);
    }

    // --- Batch Execute ---
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        try {
            System.debug('--- Starting Business Partner Delta Sync ---');

            String lastSyncIso = lastSyncTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
            System.debug('Last Sync ISO: ' + lastSyncIso);

            Id bpRecordType = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Business Partner').getRecordTypeId();
            Map<String, String> accountTypeMap = new Map<String, String>{
                'Sold-to Party' => 'Sold-to Party',
                'Ship-to Party' => 'Ship-to Party'
            };

            String deltaFilter =
                'COALESCE("SalesAreaOrderBlockCd",\'\') not in (\'99\',\'01\') AND ' +
                '("DirectCustomerRelationshipFunctionalRoleCd" = \'WE\' OR "DirectCustomerRelationshipFunctionalRoleCd" = \'AG\') AND ' +
                '"ChangeDtm" gt \'' + lastSyncIso + '\'';
            String encodedFilter = EncodingUtil.urlEncode(deltaFilter, 'UTF-8');

            String apiUrl =
                'callout:SalesCRM_Apigee/intel-products-customer/v1/intel-products-direct-customer-details' +
                '?$filter=' + encodedFilter + '&$format=json';

            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl);
            req.setMethod('GET');
            req.setHeader('Accept', 'application/json');
            HttpResponse res = new Http().send(req);

            if (res.getStatusCode() != 200) {
                createLogEntry('API call failed', null, 'Error', 'Status: ' + res.getStatusCode() + ' | Body: ' + res.getBody());
                flushLogs();
                return;
            }

            ApiResponseWrapper apiResp = (ApiResponseWrapper) JSON.deserialize(res.getBody(), ApiResponseWrapper.class);
            List<BusinessPartnerWrapper> bpList = (apiResp != null && apiResp.elements != null) ? apiResp.elements : new List<BusinessPartnerWrapper>();

            System.debug('Total BP records retrieved: ' + bpList.size());
            if (bpList.isEmpty()) return;

            Integer chunkSize = 200;
            List<BusinessPartnerWrapper> chunk = new List<BusinessPartnerWrapper>();

            for (BusinessPartnerWrapper bp : bpList) {
                chunk.add(bp);
                if (chunk.size() >= chunkSize) {
                    processChunk(chunk, bpRecordType, accountTypeMap);
                    chunk.clear();
                }
            }
            if (!chunk.isEmpty()) processChunk(chunk, bpRecordType, accountTypeMap);

            flushLogs(); // flush at end of execute
        } catch (Exception e) {
            createLogEntry('Unexpected error in execute()', e, 'Critical', 'General execution failure');
            flushLogs();
        }
    }

    // --- Process one chunk of BPs ---
    @TestVisible
    private void processChunk(List<BusinessPartnerWrapper> bpList, Id recordTypeId, Map<String, String> typeMap) {
        try {
            Set<String> bpIds = new Set<String>();
            for (BusinessPartnerWrapper bp : bpList) {
                if (!String.isBlank(bp.DirectCustomerProfileId)) bpIds.add(bp.DirectCustomerProfileId);
            }

            Map<String, Account> existing = new Map<String, Account>();
            for (Account acc : [
                SELECT Id, Core_Direct_Account_Id__c
                FROM Account
                WHERE Core_Direct_Account_Id__c IN :bpIds
            ]) {
                existing.put(acc.Core_Direct_Account_Id__c, acc);
            }

            List<Account> toInsert = new List<Account>();
            List<Account> toUpdate = new List<Account>();

            for (BusinessPartnerWrapper bp : bpList) {
                if (String.isBlank(bp.DirectCustomerProfileId) || String.isBlank(bp.DirectCustomerProfileNm)) {
                    createLogEntry('Skipping invalid BP record', null, 'Warning', JSON.serialize(bp));
                    continue;
                }

                Account acc = new Account();
                acc.Core_Direct_Account_Id__c = bp.DirectCustomerProfileId;
                acc.Name = bp.DirectCustomerProfileNm;
                acc.Core_Direct_Account_Name_Txt__c = bp.DirectCustomerProfileNm;
                acc.Core_ER_Sales_Org_Name__c = bp.GeographyCd;
                acc.Core_Direct_Sales_Organization_Nm__c = bp.SalesOrganizationCd;
                acc.Core_ER_Sales_Disti_Chnl_Name__c = bp.DistributionChannelNm;
                acc.Core_Direct_Distributor_Channel_Nm__c = bp.DistributionChannelCd;
                acc.Core_ER_Direct_CustomerRelationship_Code__c = bp.DirectCustomerRelationshipFunctionalRoleCd;
                acc.Core_ER_Account_Group__c = bp.DirectCustomerRoleCd;
                acc.Core_ER_Sales_Area_Order_Block_Code__c = bp.SalesAreaOrderBlockCd;
                acc.Core_ER_Sales_Area_Order_Block_Name__c = bp.SalesAreaOrderBlockNm;
                //acc.Core_ER_Central_block__c=bp.CentralDeleteInd; // QUEST-TWC722-3431
                acc.BillingCountry = bp.CountryNm;
                acc.BillingCity = bp.CityNm;
                acc.BillingStreet = bp.PhysicalStreetAddressTxt;
                acc.BillingPostalCode = bp.PostalCd;
                acc.RecordTypeId = recordTypeId;

                if (typeMap.containsKey(bp.DirectCustomerRelationshipFunctionalRoleNm)) {
                    acc.Core_Direct_Account_Type_Nm__c = typeMap.get(bp.DirectCustomerRelationshipFunctionalRoleNm);
                }

                if (existing.containsKey(bp.DirectCustomerProfileId)) {
                    acc.Id = existing.get(bp.DirectCustomerProfileId).Id;
                    toUpdate.add(acc);
                } else {
                    toInsert.add(acc);
                }
            }

            commitRecords(toInsert, toUpdate);
        } catch (Exception ex) {
            createLogEntry('Error in processChunk()', ex, 'Error', 'Chunk processing failure');
        }
    }

    // --- Commit Insert & Update with failure logging ---
    @TestVisible
    private void commitRecords(List<Account> toInsert, List<Account> toUpdate) {
        if (!toInsert.isEmpty()) {
            List<Database.SaveResult> insertResults = Database.insert(toInsert, false);
            for (Integer i = 0; i < insertResults.size(); i++) {
                if (insertResults[i].isSuccess()) {
                    totalInserted++;
                    totalProcessed++;
                } else {
                    totalFailed++;
                    Database.Error err = insertResults[i].getErrors()[0];
                    String rec = JSON.serialize(toInsert[i]);
                    if (rec.length() > 500) rec = rec.substring(0, 500) + '...';
                    createLogEntry('Insert failed for record', null, 'Error', 'Record: ' + rec + ' | Error: ' + err.getMessage());
                }
            }
        }

        if (!toUpdate.isEmpty()) {
            List<Database.SaveResult> updateResults = Database.update(toUpdate, false);
            for (Integer i = 0; i < updateResults.size(); i++) {
                if (updateResults[i].isSuccess()) {
                    totalUpdated++;
                    totalProcessed++;
                } else {
                    totalFailed++;
                    Database.Error err = updateResults[i].getErrors()[0];
                    String rec = JSON.serialize(toUpdate[i]);
                    if (rec.length() > 500) rec = rec.substring(0, 500) + '...';
                    createLogEntry('Update failed for record', null, 'Error', 'Record: ' + rec + ' | Error: ' + err.getMessage());
                }
            }
        }
    }

    // --- Finish Method ---
    public void finish(Database.BatchableContext bc) {
        try {
            if (!logBuffer.isEmpty()) flushLogs();

            ER_BusinessPartner_Deltasync__c config = ER_BusinessPartner_Deltasync__c.getOrgDefaults();
            if (config == null) config = new ER_BusinessPartner_Deltasync__c();
            config.Name__c = 'S4MDG_Sync';
            config.Last_DateTime_Sync__c = currentRunTime;
            upsert config;

            createLogEntry('Delta Sync Completed', null, 'Info',
                'Inserted: ' + totalInserted + ', Updated: ' + totalUpdated + ', Failed: ' + totalFailed);
            flushLogs();
        } catch (Exception e) {
            createLogEntry('Error in finish()', e, 'Error', 'Failed to update sync timestamp');
            flushLogs();
        }
    }

    // --- Helper: Last Sync Retrieval ---
    @TestVisible
    private Datetime getLastSyncTime() {
        ER_BusinessPartner_Deltasync__c config = ER_BusinessPartner_Deltasync__c.getOrgDefaults();
        if (config != null && config.Last_DateTime_Sync__c != null) {
            return config.Last_DateTime_Sync__c;
        }
        return Datetime.now().addDays(-7);
    }

    // --- Helper: Create log entry (buffered) ---
     @TestVisible
    private void createLogEntry(String msg, Exception ex, String severity, String params) {
        try {
            String details = '';
            if (ex != null) {
                details += 'Message: ' + ex.getMessage() + '\n';
                details += 'Stack Trace: ' + ex.getStackTraceString() + '\n';
            }

            String safeParams = (params != null && params.length() > 240)
                ? params.substring(0, 240) + '... (truncated)'
                : params;

            logBuffer.add(new Core_Log_Entry__c(
                Core_Origin__c = LOG_ENTRY_ORIGIN,
                Core_Project__c = LOG_ENTRY_PROJECT,
                Core_Scope__c = LOG_ENTRY_SCOPE,
                Core_Severity__c = severity,
                Core_Message__c = msg,
                Core_When__c = System.now(),
                Core_Details__c = details,
                Core_Tags__c = safeParams
            ));
        } catch (Exception e) {
            System.debug('Failed to prepare log entry: ' + e.getMessage());
        }
    }

    // --- Helper: Flush buffered logs safely ---
     @TestVisible
    private void flushLogs() {
        try {
            if (!logBuffer.isEmpty()) {
                Database.insert(logBuffer, false);
                logBuffer.clear();
            }
        } catch (Exception e) {
            System.debug('Failed to insert log buffer: ' + e.getMessage());
        }
    }

    // --- Wrapper Classes ---
    public class ApiResponseWrapper {
        public String name;
        public List<BusinessPartnerWrapper> elements;
    }

    public class BusinessPartnerWrapper {
        public String DirectCustomerProfileId;
        public String SalesOrganizationCd;
        public String DistributionChannelCd;
        public String DistributionChannelNm;
        public String DirectCustomerRelationshipFunctionalRoleCd;
        public String DirectCustomerRelationshipFunctionalRoleNm;
        public String PhysicalStreetAddressTxt;
        public String CityNm;
        public String CountrySubDivisionNm;
        public String CountryNm;
        public String PostalCd;
        public String DirectCustomerProfileNm;
        public String GeographyCd;
        public String CentralDeleteInd;
        public String DirectCustomerRoleCd;
        public String SalesAreaOrderBlockCd;
        public String SalesAreaOrderBlockNm;
        public String ChangeDtm;
    }
}