/***************************************************************************************************
 * @Name IPS_QualityBuilderReportBatch
 * @Description uns the dynamic SOQL query produced by ICS_QualityBuilderReportQueries and builds
 *              a CSV export from the results 
 *
 * @version 1.0
 ***************************************************************************************************/

public class IPS_QualityBuilderReportBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    private IPS_QualityBuilder_Generic_Pipe_Setting__c jobSettings;
    @TestVisible private List<String> csvRows = new List<String>();
    @TestVisible private Decimal grandTotal = 0;
    @TestVisible private List<String> fieldApiNames;
    @TestVisible private Boolean queryBuilt = false;

    public IPS_QualityBuilderReportBatch(IPS_QualityBuilder_Generic_Pipe_Setting__c jobSettings) {
        this.jobSettings = jobSettings;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        IPS_QualityBuilderReportQueries.QueryBuildResult qr = IPS_QualityBuilderReportQueries.buildQueryDetailsFromReportId(jobSettings.Name, jobSettings.Report_Id__c, 'Case');
        System.debug('qr-->'+qr);
        if(qr == null || qr.fieldLabels == null || qr.query == null || qr.fields == null){
            //Core_Log_Entry.logEntryWithDetails(jobSettings.Name, 'QualityBuilder', 'ISVC', 'Critical', jobSettings.Name + ' Query build failed', 'Could not build query from report ' + jobSettings.Report_Id__c);
            Core_Log_Entry.logEntryWithDetails('IPS', 'IPS Survey', 'IPS Quality Builder Utility', 'Info', 'Describe API', 'Failed to retrieve data for job', 'Survey report', 'null', 'Success');
            return Database.getQueryLocator('SELECT Id FROM Case LIMIT 0');
        }
        queryBuilt = true;
        fieldApiNames = qr.fields;
        csvRows.add(buildCsvLine(qr.fieldLabels));
        return Database.getQueryLocator(qr.query);
    }

    //For each record, reads every configured field and appends one CSV row.
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        try{
            for(SObject rec : scope) {
                List<String> values = new List<String>();
                for(String field: fieldApiNames) {
                    Object val = getFieldValue(rec, field);
                    values.add(val == null ? '' : String.valueOf(val));
                }
                csvRows.add(buildCsvLine(values));
            }
            grandTotal += scope.size();
        } catch(Exception ex) {
            Core_Log_Entry.logEntryWithException('IPS', 'IPS Survey', 'IPS Quality Builder Utility', 'Info', 'Describe API', 'Failed to request report API for job', 'Survey report', 'null', 'Success', null);
            
        }
    }

    //Joins every accumulated CSV line (header + all data rows) into a single body, converts it to a Blob
    public void finish(Database.BatchableContext bc) {
        if(!queryBuilt) return;
        try {
            Blob reportContent = Blob.valueOf(String.join(csvRows, '\n'));
            IPS_QualityBuilderUtility.sendReport(jobSettings, reportContent, grandTotal);
            //generateFile(reportContent);
            
        } catch(Exception exp) {
            
			 Core_Log_Entry.logEntryWithException('IPS', 'IPS Survey', 'IPS Quality Builder Utility', 'Info', 'Describe API', 'Failed to send file for job', 'Survey report', 'null', 'Success', null);
        }
    }

    //Reads a single field's value off a record, supporting simple relationship traversal
    public Object getFieldValue(SObject rec, String fieldPath) {
        if (!fieldPath.contains('.')) {
            return rec.get(fieldPath);
        }
        List<String> parts = fieldPath.split('\\.');
        SObject current = rec;
        for (Integer i = 0; i < parts.size() - 1; i++) {
            if (current == null) return null;
            current = current.getSObject(parts[i]);
        }
        return current == null ? null : current.get(parts[parts.size() - 1]);
    }

    //Joins a list of already-escaped-per-cell values into one comma-separated CSV line.
    public String buildCsvLine(List<String> values) {
        List<String> escaped = new List<String>();
        for (String v : values) {
            escaped.add(escapeCsv(v));
        }
        return String.join(escaped, ',');
    }

    public String escapeCsv(String value) {
        if (value == null) return '';
        Boolean needsQuoting = value.contains(',') || value.contains('"') || value.contains('\n') || value.contains('\r');
        String out = value.replace('"', '""');
        return needsQuoting ? '"' + out + '"' : out;
    }
    /*private static void generateFile(Blob reportContent) {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'QB_Test_Export_' + Datetime.now().format('yyyyMMdd_HHmmss');
        cv.PathOnClient = cv.Title + '.csv';
        cv.VersionData = reportContent;
        cv.IsMajorVersion = true;
        insert cv;
 
        System.debug('BULK API: ContentVersion Id: ' + cv.Id);
    }*/
}