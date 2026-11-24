/***************************************************************************************************************
* @Name IPS_QualityBuilderUtility
* @Description Utilty class to schedule daily csv file report upload job to Quality Builder shared forlder
* @Author ANil popcornapps
* @version 1.0
* @Created Date 26/11/2021
* Farooq 							  					04/10/2024				 Modified the approval prcess as part of ATHR (TWC745-6578)
* @LastMofied By - Shipra Bardhan                      04/11/2024               Retry Mechanism(TWC745-7107) - PRB10061244
****************************************************************************************************************/
public with sharing class IPS_QualityBuilderUtility {
    // As 'getContent' not work in test context, taking the variable to test all padding conditions.
    @testvisible
    private static String testString;
    public static Integer countRetry = 0;
    public static String exceptionMessage;
    public static String errorMessage;
    public static String grandTotalErrorMessage;
    
    
    /* Description : Send File callout future method, which will generate a csv and send it to Quality Builder shared folder. */
    //@future(Callout = true)
    // Migration to dynamic query genaration and batch apex. Commenting the future call - Nuthana - 22-09-2026
    public static void sendQualityBuilderReport(String jobName) {
        //Fetching job settings based on the Job executed
        IPS_QualityBuilder_Generic_Pipe_Setting__c jobSettings = IPS_QualityBuilder_Generic_Pipe_Setting__c.getInstance(jobName);
        // Retry counter
 
        Integer retryCount = 0;
        Boolean success = false;
        try {
            // Migration to dynamic query genaration and batch apex.- Nuthana
             if(jobSettings != null && String.isNotBlank(jobSettings.Report_Id__c)) {
                 Database.executeBatch(new IPS_QualityBuilderReportBatch(jobSettings));}
        
        } catch (Exception exc) {
            exceptionMessage = exc.getMessage();
        }       
        if (!success) {
            Core_Log_Entry.logEntryWithException('IPS', 'IPS Survey', 'IPS Quality Builder Utility', 'Critical', exceptionMessage, 'Report Failed', 'Survey Report', 'Report', 'Failure Quality Builder Report', null);
        }
    }
   
    
    //Method to generate the file name based on toay's date
    public static String generateFileName(String prefix, String dateFormat) {
        Datetime todayDt = Datetime.now();
        String dateT = '';
        if (String.isNotBlank(dateFormat)) {
            try {
                dateT = todayDt.format(dateFormat);
            } 
            catch (Exception exc) {
                exceptionMessage = exc.getMessage();
                
                Core_Log_Entry.logEntryWithException('IPS', 'IPS Survey', 'IPS Quality Builder Utility', 'Info', 'Survey Report', 'Incorrect format provided', 'Survey report', 'exception when incorrect format provided', 'exception when incorrect format provided', exc);
            }
        }
        String fileName = prefix + dateT + '.csv';
        return fileName;
    }
    
    // Method to generate random boundry string used in the multipart callout
    public static String generateBoundryString() {
        Blob blobString = crypto.generateAesKey(128);
        String hexString = EncodingUtil.convertToHex(blobString);
        String bndryStr = '--Boundry' + hexString.substring(0, 20);
        return bndryStr;
    }
     //Added changes related to last4Bytes to get rid of padding without corrupting the file data - Nuthana
     public static Blob generateBlobBody(Blob reportContent,String boundryStr,String fileName) {
        Blob bodyBlob = null;
        // Call to generate file name based on today's date 
        String header = '--'+boundryStr+'\nContent-Disposition: form-data; name="File"; filename="'+fileName+'";\nContent-Type: text/csv; charset=UTF-8'; 
        String footer = '--'+boundryStr+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('=')){
            // Add space until encoded value ends with '='
            header +=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        // call to encode body
        String bodyEncoded = EncodingUtil.base64Encode(reportContent);
        // Fetch last 4 bytes for padding logic
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        // logic to get rid of padding without corrupting the file data
        if(last4Bytes.endsWith('==')) {
            // The '==' sequence indicates that the last group contained only one out of 3x8 bit bytes
            // We will append base64 mapping values \r\n that is 0K (refer comments below)
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            // As we have appended the \r\n to the Blob, so leave footer as it is.
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } 
        else if(last4Bytes.endsWith('=')) {
            // The '=' indicates that encoded data already contained two out of 3x8 bit bytes
            // We will append base64 mapping value \r that is N (refer comments below)
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            // As we have appended the CR e.g. \r, still need to prepend the line feed to the footer
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } 
        else {
            // need to Prepend the \r \n to the footer
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
        return bodyBlob;
    }
  
  
    
    // Method to abort all the Jobs
    public static void abortAllJobs(Set<String> jobs) {
        for (CronTrigger job : [SELECT Id, CronJobDetail.Name
                                FROM CronTrigger
                                WHERE CronJobDetail.Name IN:jobs]) {
                                    System.abortJob(job.Id);
                                }
    }   
    //Method to schedule all the active Jobs
    public static void scheduleActiveJobs(Map<String, IPS_QualityBuilder_Generic_Pipe_Setting__c> jobSettingMap) {
        IPS_QualityBuilderReportscheduler qbReportSch = new IPS_QualityBuilderReportscheduler();
        system.schedule('Daily IPS survey file for OnR', '0 0 2 * * ?', qbReportSch);
    }    
    //Method to get the Job Name based on the Scheduable context
    public static String getJobName(SchedulableContext sContext) {
        String jobName;
        try {
            if (sContext != null) {
                // US603437 - PMD - P1 - False Positive (SOQL Already have "WITH SECURITY_ENFORCED" clause in place) PMD Violation - Check for access permissions before a SOQL/SOSL/DML operation.
                CronTrigger job = [SELECT Id, CronJobDetail.Name
                                   FROM CronTrigger
                                   WHERE Id = :sContext.getTriggerId()
                                   WITH SECURITY_ENFORCED
                                   LIMIT 1];
                jobName = job.CronJobDetail.Name;
            }
        } catch (Exception exc) {
            Core_Log_Entry.logEntryWithException('QualityBuilder', 'IPS Survey report', 'IPS Quality Builder Utility', 'Critical', 'Quality Builder File POST Failed', 'Unhandled exception occur while posting File', 'Servey Report', 'Custom Settings', 'Servey report', exc);
        }
        return jobName;
    } 
    //Added separate Method sendReport initially these steps were followed in sendQualityBuilderReport Method - Nuthana - 22-09-2026
     public static void sendReport(IPS_QualityBuilder_Generic_Pipe_Setting__c jobSettings, Blob reportContent, Decimal grandTotal) {
      
        String fileName = generateFileName(jobSettings.File_Name_Prefix__c,jobSettings.File_Name_Date_Format__c);
       
        String boundryString = generateBoundryString();
    
        Blob blobBody = generateBlobBody(reportContent,boundryString,fileName);
        
        grandTotalErrorMessage = doReportSendCallout(blobBody,boundryString,grandTotal);
       
    }
    //Switched to Named Credential 'callout:IPS_Quality_Builder_Integration' for endpoint and auth. - Nuthana - 26-10-2026
    public static String doReportSendCallout(Blob blobBody,String boundryString,Decimal recordcount) { 
        String sendFileEndPoint='callout:IPS_Quality_Builder_Integration';
        HttpRequest req = new HttpRequest();       
        req.setHeader('Content-Type','multipart/form-data; boundary='+boundryString);
        req.setBodyAsBlob(blobBody);
        //req.setHeader('Content-Length',String.valueOf(blobBody.size()));        
        req.setMethod('POST');
        req.setEndpoint(sendFileEndPoint); 
        req.setTimeout(120000);
        Http http = new Http();
        executeWithRetry(req, recordcount);
		System.debug('content length'+ String.valueOf(blobBody.size()));
        return errorMessage;
    }
    private static String executeWithRetry(HttpRequest req, Decimal recordCount) {
        Http http = new Http();
        Integer maxRetries = 2;
        Integer attempt = 0;
        Boolean success = false;
        while (attempt <= maxRetries && !success) {
            attempt++;
            errorMessage = '';
            try {
                HTTPResponse res = http.send(req);
                if (res.getStatusCode() == 200) {
                    success = true;
                    if (recordCount == 0) {
                        return 'File Upload Failed. File generated with no data. Status Code: ' + res.getStatusCode() + ' Message: ' + res.getBody();
                    }
                } else {
                    System.debug(LoggingLevel.ERROR, '>>> QB ' + res.getStatusCode() + ': ' + res.getBody());
    
                    errorMessage = 'File Upload Failed. Status Code: ' + res.getStatusCode() + ' Message: ' + res.getBody();
                }
            } catch (Exception ex) {
                  errorMessage = 'Exception occurred during file upload with attempt : ' +attempt +' with exception '+ex.getMessage() ;
            }
        }
        return errorMessage;
    }
}