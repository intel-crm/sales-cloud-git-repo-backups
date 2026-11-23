/***************************************************************************************************
* @Name ICS_QualityBuilderBulkPoller 
* @Description Checks one Bulk API 2.0 query job status.
*              On JobComplete, assembles the CSV result and hands off to ICS_QualityBuilderUtility.completeBulkQueryJob().
*              On Failed/Aborted, logs and stops. Otherwise, re-schedules another check via ICS_QualityBuilderBulkPollScheduler until MAX_ATTEMPTS is hit.
* @version 1.0
* @Created Date 03/09/2026
* @Modified Date 08/09/2026
***************************************************************************************************/
public class IPS_QualityBuilderBulkPoller implements Queueable, Database.AllowsCallouts {
    
    private static final Integer MAX_ATTEMPTS = 30;
    private static final Integer MAX_RESULT_PAGES = 50;

    private String jobName;
    private String bulkJobId;
    private Integer attemptCount;

    public IPS_QualityBuilderBulkPoller(String jobName, String bulkJobId, Integer attemptCount) {
        this.jobName = jobName;
        this.bulkJobId = bulkJobId;
        this.attemptCount = attemptCount;
    }

    public void execute(QueueableContext ctx) {
        try {
            Map<String, Object> status = BulkApiV2Service.getJobStatus(jobName, bulkJobId);
            String state = (String) status.get('state');

            if (state == 'JobComplete') {
                Object rawCount = status.get('numberRecordsProcessed');
                Decimal grandTotal = (rawCount != null) ? Decimal.valueOf(String.valueOf(rawCount)) : 0;
                Blob reportContent = fetchAllResultPages(bulkJobId);

                IPS_QualityBuilderUtility.completeBulkQueryJob(jobName, reportContent, grandTotal);

            } else if (state == 'Failed' || state == 'Aborted') {
                //Core_Log_Entry.logEntryWithDetails(jobName, 'QualityBuilder', 'ISVC', 'Critical',jobName + ' Bulk Job Failed', String.valueOf(status.get('errorMessage')));
                System.debug('BULK API: Bulk Job Failed'+String.valueOf(status.get('errorMessage')));
                
            } else if (attemptCount >= MAX_ATTEMPTS) {
                //Core_Log_Entry.logEntryWithDetails(jobName, 'QualityBuilder', 'ISVC', 'Critical',jobName + ' Bulk Job Timed Out','Bulk job did not complete after ' + MAX_ATTEMPTS + ' poll attempts.');
                System.debug('BULK API: Max Attempts reached');
            } else {
                IPS_QualityBuilderBulkPollScheduler.scheduleNextPoll(jobName, bulkJobId, attemptCount + 1);
            }

        } catch (Exception exc) {
            //Core_Log_Entry.logEntryWithException(jobName, 'QualityBuilder', 'ISVC', 'Critical', jobName + ' Poll Failed', 'Unhandled exception occurred while polling bulk job', exc);
            System.debug('BULK API: Poll Failed, Unhandled exception occurred while polling bulk job: '+exc);
        }
    }

    private Blob fetchAllResultPages(String bulkJobId) {
        String combinedCsv = '';
        String locator = null;
        Boolean firstPage = true;
        Integer pageCount = 0;

        do {
            BulkApiV2Service.ResultsPage page = BulkApiV2Service.getJobResults(jobName, bulkJobId, locator);
            if(page == null){
                return null;
            }
            String pageCsv = page.csv;
            if (!firstPage) {
                Integer firstNewline = pageCsv.indexOf('\n');
                pageCsv = (firstNewline >= 0) ? pageCsv.substring(firstNewline + 1) : '';
            }
            combinedCsv += pageCsv;
            firstPage = false;
            locator = page.nextLocator;
            pageCount++;
        } while (String.isNotBlank(locator) && pageCount < MAX_RESULT_PAGES);

        System.debug('BULK API: Page created');
        return Blob.valueOf(combinedCsv);
    }
}