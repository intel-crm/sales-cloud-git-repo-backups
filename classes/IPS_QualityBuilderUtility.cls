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
    
    
    /* Description : Send File callout future method, which will generate a csv and send it to Quality Builder shared folder. */
    @future(Callout = true)
    public static void sendQualityBuilderReport(String jobName) {
        //Fetching job settings based on the Job executed
        IPS_QualityBuilder_Generic_Pipe_Setting__c jobSettings = IPS_QualityBuilder_Generic_Pipe_Setting__c.getInstance(jobName);
        // Retry counter
        Integer retryCount = 0;
        Boolean success = false;
        try {
            Blob reportContent = fetchReportContentWithRetry(jobSettings.Report_Id__c);
            String reportId = jobSettings.Report_Id__c;
            Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
            Reports.ReportFactWithDetails factDetails1 = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');
            List<Reports.SummaryValue> recordCount = factDetails1.getAggregates();
            Decimal grandTotal = (Decimal) recordCount.get(recordCount.size() - 1).getValue();
            if (reportContent != null && reportContent.size() > 0) {
                String token = generateTokenWithRetry(System.Label.IPS_QB_TOKEN_ENDPOINT, System.Label.IPS_QB_CUSTOMER_ID, System.Label.IPS_QB_CUSTOMER_SECRET);
                if (String.isNotBlank(token)) {
                    String fileName = generateFileName(jobSettings.File_Name_Prefix__c, jobSettings.File_Name_Date_Format__c);
                    String boundaryString = generateBoundryString();
                    Blob blobBody = generateBlobBody(reportContent, boundaryString, fileName);
                    exceptionMessage = doReportSendCalloutWithRetry(blobBody, boundaryString, token, grandTotal);
                    success = (exceptionMessage.contains('200')) ? true : false;
                } 
            } 
            else {
                exceptionMessage = 'Report Content Generation Failed, Kindly check Report with Report Id: ' + System.Label.IPS_QB_REPORT_ID;
            }
        } catch (Exception exc) {
            exceptionMessage = exc.getMessage();
        }       
        if (!success) {
            Core_Log_Entry.logEntryWithException('IPS', 'IPS Survey', 'IPS Quality Builder Utility', 'Critical', exceptionMessage, 'Report Failed', 'Survey Report', 'Report', 'Failure Quality Builder Report', null);
        }
    }
    /*
* Method: fetchReportContentWithRetry
* Description: It fetch the report content with max 3 retry attempts, takes the input report id, returns the report as reponse
* @param:  reportId
* @return: reportContent
* @author: Shipra Bardhan 
*/
    // Retry Mechanism for Quality Builder Report - TWC745-7107 - PRB10061244  - START - Shipra
    private static Blob fetchReportContentWithRetry(String reportId) {
        Blob reportContent = null;
        Integer retryCount = 0;
        while (retryCount < 3) {
            try {
                if (String.isNotBlank(reportId)) {
                    ApexPages.PageReference reportPage = new ApexPages.PageReference('/' + reportId + '?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                    if (!Test.isRunningTest()) {
                        reportContent = reportPage.getContent();
                    } else{
                        reportContent = Blob.valueOf(testString);
                    }
                }
                break; 
            } catch (Exception ex) {
                retryCount++;
                exceptionMessage = ex.getMessage();
            }
        }
        return reportContent;
    }
    /*
* Method: generateTokenWithRetry
* Description: It generates the token with max 3 retry attempts, takes  the input end Point,client Id,client Secret and returns the token as reponse
* @param:  endPoint,clientId,clientSecret
* @return: token
* @author: Shipra Bardhan  
*/
    public static String generateTokenWithRetry(String endPoint, String clientId, String clientSecret) {
        String token = null;
        Integer retryCount = 0;
        Boolean success = false;
        while (retryCount < 3 && !success) {
            try {
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endPoint);
                request.setMethod('POST');
                request.setBody('grant_type=' + System.Label.IPS_QB_TOKEN_GRANT_TYPE + '&client_id=' + clientId + '&client_secret=' + clientSecret);
                request.setTimeout(Integer.valueOf(System.Label.IPS_QB_TIMEOUT));
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() == 200) {
                    IPS_QualityBuilderTokenParser parsedResponse = IPS_QualityBuilderTokenParser.parse(response.getBody());
                    token = parsedResponse.access_token;
                    success = true;
                    break; 
                } 
                else{
                    retryCount++;
                }
            } 
            catch (Exception e) {
                retryCount++;
                exceptionMessage = e.getMessage();           
            }
        }        
        if (String.isBlank(token)) {
            Core_Log_Entry.logEntryWithException('IPS', 'IPS Survey', 'IPS Quality Builder Utility', 'Critical', exceptionMessage, 'Token Generation Failed', 'Survey report', 'null', 'Failure', null);
        }    
        return token;
    }
    // Retry Mechanism for Token Generation - TWC745-7107 - PRB10061244  - END - Shipra
    
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
    
    // Method to generate Blob body for callout by encoding header, body content and footer with proper boundry
    public static Blob generateBlobBody(Blob reportContent, String boundryStr, String fileName) {
        Blob bodyBlob = null;
        String header = '--' + boundryStr + '\nContent-Disposition: form-data; name="File"; filename="' + fileName + '";\nContent-Type: text/csv; charset=UTF-8';
        String footer = '--' + boundryStr + '--';
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
        while (headerEncoded.endsWith('=')) {
            header += ' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(reportContent);
        footer = '\r\n' + footer;
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        bodyBlob = EncodingUtil.base64Decode(headerEncoded + bodyEncoded + footerEncoded);
        return bodyBlob;
    }
    /*
* Method: doReportSendCalloutWithRetry
* Description: It sends the report with max 3 retry attempts , takes  the input blob body, bounndary string, token , total records  and returns the message as reponse
* @param:  blobBody,boundaryString,token,totalRecords
* @return: errorMessage
* @author: Shipra Bardhan  
*/
    // Retry Mechanism for Token Generation - TWC745-7107 - PRB10061244  - START - Shipra
    
    public static String doReportSendCalloutWithRetry(Blob blobBody, String boundaryString, String token, Decimal totalRecords) {
        String ipsAuthorization = System.Label.IPS_Authorization;
        String sendFileEndPoint = System.Label.IPS_QB_SEND_FILE_ENDPOINT;
        Integer retryCount = 0;
        Boolean success = false;
        while (retryCount < 3 && !success) {
            try {
                HttpRequest req = new HttpRequest();
                req.setHeader(ipsAuthorization, 'Bearer ' + token);
                req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundaryString);
                req.setBodyAsBlob(blobBody);
                req.setHeader('Content-Length', String.valueOf(blobBody.size()));
                req.setMethod('POST');
                req.setEndpoint(sendFileEndPoint);
                req.setTimeout(Integer.valueOf(System.Label.IPS_QB_TIMEOUT));
                Http http = new Http();
                HttpResponse res = http.send(req);
                if (res.getStatusCode() != 200) {
                    retryCount++;
                    continue; 
                }               
                if (totalRecords > 0) {
                    exceptionMessage = 'File Uploaded Successfully. Status Code: ' + res.getStatusCode() + ' Message: ' + res.getBody();
                    Core_Log_Entry.logEntryWithException('IPS', 'IPS Survey', 'IPS Quality Builder Utility', 'Info', exceptionMessage, 'File Upload Successfull', 'Survey report', 'null', 'Success', null);
                }               
                else {
                    exceptionMessage = 'File generated with No Records in the Report. Status Code: ' + res.getStatusCode() + ' Message: ' + res.getBody();
                    Core_Log_Entry.logEntryWithException('IPS', 'IPS Survey', 'IPS Quality Builder Utility', 'Info', 'File generated with No Records in the Report', 'File Upload Failed', 'Survey report', 'null', 'Failure Quality Builder Report', null);
                } 
                success = true;
                break; 
            } 
            catch (Exception e) {
                exceptionMessage = e.getMessage();
                retryCount++;
            }
        }       
        if (!success) {
            String finalErrorMessage = 'File Upload Failed ' + exceptionMessage;
            Core_Log_Entry.logEntryWithException('IPS', 'IPS Survey', 'IPS Quality Builder Utility', 'Critical', exceptionMessage, finalErrorMessage, 'Survey report', 'null', 'Failure', null);
        }      
        return exceptionMessage;
    }
    // Retry Mechanism for Quality Builder Report - TWC745-7107 - PRB10061244  - END - Shipra
    
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
}