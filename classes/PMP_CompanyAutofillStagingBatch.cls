/*********************************************************************************************************************
Apex Class Name  : PMP_CompanyAutofillStagingBatch
Version       : 1.0
Created Date  : AUG 2026
Function      : Creates staging PMP_CompanyAutoFill__c records for eligible draft company profiles based on website information from active OPID relationships and refreshes empty scraped/mixed autofill records.

Modification Log 
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Nitesh Reddy              22/08/2026             Created PMP_CompanyAutofillStagingBatch
*********************************************************************************************************************/

global class PMP_CompanyAutofillStagingBatch implements Database.Batchable<SObject>, Database.Stateful {

    private static final String METADATA_NAME = 'PMP_CompanyAutofillStagingBatch_mdt';
    //private static final Integer DEFAULT_RECORD_LIMIT = 50;

    private Integer recordLimit = 50;

    private Set<String> geos = new Set<String>();
    private Set<String> countries = new Set<String>();
    private Set<Id> recordIds = new Set<Id>();

    private DateTime createdDateFrom;
    private DateTime createdDateTo;

    //Log Entry Variables
    private Integer totalProcessed = 0;
    private Integer totalInserted = 0;
    private Integer totalDeleted = 0;
    private Integer totalInsertFailed = 0;
    private Integer totalDeleteFailed = 0;
    private Set<String> processedOpiMpiRelIds = new Set<String>();
    private Set<String> processedCompanyIds = new Set<String>();
    private Set<String> insertedAutofillIds = new Set<String>();
    private Set<String> deletedAutofillIds = new Set<String>();
    private Set<String> failedOpiMpiRelIds = new Set<String>();
    private Set<String> failedCompanyIds = new Set<String>();
    private Map<Id, Id> companyToOpiMpiRelMap = new Map<Id, Id>();

    global PMP_CompanyAutofillStagingBatch() {
        loadConfiguration();
    }

    public void loadConfiguration() {

        List<Core_CustomMetadata_Object__c> childList = [
            SELECT Id,
                   Header_row__c,
                   Field_1__c,
                   Field_2__c,
                   Field_3__c,
                   Field_4__c,
                   Field_1_Text_Area_Long__c,
                   Field_2_Text_Area_Long__c
            FROM Core_CustomMetadata_Object__c WHERE Metadata_Name__c = :METADATA_NAME and Header_row__c != null LIMIT 1];

        if (childList.isEmpty()) {
            return;
        }

        Core_CustomMetadata_Object__c child = childList[0];

        if (!String.isBlank(child.Field_1__c)) {

            try {
                Integer configuredLimit = Integer.valueOf(child.Field_1__c.trim());

                if (configuredLimit > 0) {
                    recordLimit = configuredLimit;
                }
            } catch (Exception e) {
                // Ignore invalid data
            }
        }

        if (!String.isBlank(child.Field_3__c)) {
            try {
                createdDateFrom = DateTime.valueOf(child.Field_3__c.trim());
            } catch (Exception e) {
                // Ignore invalid date
            }
        }

        if (!String.isBlank(child.Field_4__c)) {
            try {
                createdDateTo = DateTime.valueOf(child.Field_4__c.trim());
            } catch (Exception e) {
                // Ignore invalid date
            }
        }

        geos = parseValues(child.Field_2__c);
        countries = parseValues(child.Field_1_Text_Area_Long__c);

        for (String idValue : parseValues(child.Field_2_Text_Area_Long__c)) {

            try {
                recordIds.add((Id)idValue);
            } catch (Exception e) {
                // Ignore invalid record Ids
            }
        }
    }

    public Set<String> parseValues(String value) {

        Set<String> values = new Set<String>();

        if (String.isBlank(value)) {
            return values;
        }

        for (String item : value.split('[,\\n\\r]+')) {

            String trimmedValue = item.trim();

            if (!String.isBlank(trimmedValue)) {
                values.add(trimmedValue);
            }
        }

        return values;
    }

    private static Boolean isAutofillDataEmpty(PMP_CompanyAutoFill__c caf) {

        return String.isBlank(caf.Company_Key_Values__c)
            && String.isBlank(caf.PMP_Tagline__c)
            && String.isBlank(caf.PMP_Description__c)
            && String.isBlank(caf.PMP_Applications__c)
            && String.isBlank(caf.PMP_Industries__c)
            && String.isBlank(caf.PMP_Regions__c);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        String query =
            'SELECT PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c, ' +
            'PMP_One_Partner_ID__r.UCD_Primary_Account__r.Core_User_Defined_Website__c ' +
            'FROM PMP_OPID_MPI_Rel__c ' +
            'WHERE Is_Active__c = true ' +
            'AND PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c = \'Draft\' ' +
            'AND PMP_One_Partner_ID__r.UCD_Primary_Account__r.Core_User_Defined_Website__c != NULL';
            //'AND PMP_Marketing_Profile_Id__c.PMP_Is_Published_Ind__c = true ' +
            //'AND PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c = \'Draft\' ' +

        if (!geos.isEmpty()) {
            query += ' AND PMP_One_Partner_ID__r.UCD_Primary_Account__r.Core_Geo__c IN :geos';
        }

        if (!countries.isEmpty()) {
            query += ' AND PMP_One_Partner_ID__r.UCD_Primary_Account__r.Core_Account_Country__c IN :countries';
        }

        if (!recordIds.isEmpty()) {
            query += ' AND Id IN :recordIds';
        }

        if (createdDateFrom != null) {
            query += ' AND CreatedDate >= :createdDateFrom';
        }

        if (createdDateTo != null) {
            query += ' AND CreatedDate < :createdDateTo';
        }

        query += ' LIMIT ' + recordLimit;

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<PMP_OPID_MPI_Rel__c> scope) {

        Map<Id, String> companyToWebsite = new Map<Id, String>();

        for (PMP_OPID_MPI_Rel__c rec : scope) {

            Id companyId = rec.PMP_Marketing_Profile_Id__r?.PMP_Working_Copy_Id__c;       
            String website = rec.PMP_One_Partner_ID__r?.UCD_Primary_Account__r?.Core_User_Defined_Website__c;
        
            if (companyId != null && !String.isBlank(website)) {
                companyToWebsite.put(companyId, website);

                companyToOpiMpiRelMap.put(companyId, rec.Id);
                processedOpiMpiRelIds.add(String.valueOf(rec.Id));
                processedCompanyIds.add(String.valueOf(companyId));
            }
        }
        if (companyToWebsite.isEmpty()) {
            return;
        }

        totalProcessed += companyToWebsite.size();

        Map<Id, PMP_CompanyAutoFill__c> existingCafByCompany = new Map<Id, PMP_CompanyAutoFill__c>();

        for (PMP_CompanyAutoFill__c rec : [
            SELECT Id,
                   PMP_Partner_Id__c,
                   PMP_Website__c,
                   PMP_Autofill_Status__c,
                   Company_Key_Values__c,
                   PMP_Tagline__c,
                   PMP_Description__c,
                   PMP_Applications__c,
                   PMP_Industries__c,
                   PMP_Regions__c
            FROM PMP_CompanyAutoFill__c
            WHERE PMP_Partner_Id__c IN :companyToWebsite.keySet()
        ]) {
            existingCafByCompany.put(rec.PMP_Partner_Id__c, rec);
        }

        List<PMP_CompanyAutoFill__c> toDelete = new List<PMP_CompanyAutoFill__c>();
        List<PMP_CompanyAutoFill__c> toInsert = new List<PMP_CompanyAutoFill__c>();

        for (Id companyId : companyToWebsite.keySet()) {

            PMP_CompanyAutoFill__c existingCaf = existingCafByCompany.get(companyId);

            if (existingCaf == null) {
                toInsert.add(new PMP_CompanyAutoFill__c(PMP_Partner_Id__c = companyId, PMP_Website__c = companyToWebsite.get(companyId), PMP_Autofill_Status__c = 'Staged'));
                continue;
            }

            Boolean isScrapedOrMixed = existingCaf.PMP_Autofill_Status__c == 'Scraped' || existingCaf.PMP_Autofill_Status__c == 'Mixed';

            if (isScrapedOrMixed && isAutofillDataEmpty(existingCaf)) {
                toDelete.add(existingCaf);
                toInsert.add(new PMP_CompanyAutoFill__c(PMP_Partner_Id__c = companyId, PMP_Website__c = companyToWebsite.get(companyId), PMP_Autofill_Status__c = 'Staged'));
            }
        }

        if (!toDelete.isEmpty()) {

            Database.DeleteResult[] deleteResults = Database.delete(toDelete, false);

            for (Integer i = 0; i < deleteResults.size(); i++) {

                if (deleteResults[i].isSuccess()) {
                    totalDeleted++;
                    deletedAutofillIds.add(String.valueOf(toDelete[i].Id));
                } else {
                    totalDeleteFailed++;
                }
            }
        }

        if (!toInsert.isEmpty()) {

            Database.SaveResult[] insertResults = Database.insert(toInsert, false);

            for (Integer i = 0; i < insertResults.size(); i++) {

                PMP_CompanyAutoFill__c caf = toInsert[i];

                Id companyId = caf.PMP_Partner_Id__c;
                Id opiMpiRelId = companyToOpiMpiRelMap.get(companyId);

                if (insertResults[i].isSuccess()) {

                    totalInserted++;
                    insertedAutofillIds.add(
                        String.valueOf(insertResults[i].getId())
                    );

                } else {

                    totalInsertFailed++;
                    if (companyId != null) {
                        failedCompanyIds.add(String.valueOf(companyId));
                    }
                    if (opiMpiRelId != null) {
                        failedOpiMpiRelIds.add(String.valueOf(opiMpiRelId));
                    }
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {

        String ORIGIN = 'PMP_CompanyAutofillStagingBatch';
        String PROJECT = 'MP COMPANY AUTOFILL';

        String status;

        if (totalInsertFailed == 0 && totalDeleteFailed == 0) {
            status = 'SUCCESS';
        }
        else if (
            totalInserted > 0 ||
            totalDeleted > 0
        ) {
            status = 'PARTIAL SUCCESS';
        }
        else {
            status = 'FAILED';
        }

        String logEntryMsg =
            'Processed=' + totalProcessed +
            ', Inserted=' + totalInserted +
            ', Deleted=' + totalDeleted +
            ', InsertFailed=' + totalInsertFailed +
            ', DeleteFailed=' + totalDeleteFailed +

            '\n\nProcessed OPI-MPI Relationship IDs:\n' +
            String.join(new List<String>(processedOpiMpiRelIds), ', ') +

            '\n\nProcessed Company IDs:\n' +
            String.join(new List<String>(processedCompanyIds), ', ') +

            '\n\nInserted Autofill IDs:\n' +
            String.join(new List<String>(insertedAutofillIds), ', ') +

            '\n\nDeleted Autofill IDs:\n' +
            String.join(new List<String>(deletedAutofillIds), ', ') +

            '\n\nFailed OPI-MPI Relationship IDs:\n' +
            String.join(new List<String>(failedOpiMpiRelIds), ', ') +

            '\n\nFailed Company IDs:\n' +
            String.join(new List<String>(failedCompanyIds), ', ');

        insert new Core_Log_Entry__c(
            Core_Message__c = ORIGIN + ' - ' + status,
            Core_Origin__c = ORIGIN,
            Core_Severity__c = 'INFO',
            Core_Project__c = PROJECT,
            Core_When__c = System.now(),
            Core_Details__c = logEntryMsg
        );

        System.debug(logEntryMsg);
    }
}