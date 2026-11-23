public class POC_ReportController {
    
    
    public static String fetchReportContent() {
       // IPS_QualityBuilder_Generic_Pipe_Setting__c jobSettings = IPS_QualityBuilder_Generic_Pipe_Setting__c.getInstance('On Research IPS Report');
		//String reportId = jobSettings.Report_Id__c;
        String reportId = '00ODU0000028RZt2AM';
        String reportContentString;
        try { 
            ApexPages.PageReference report = new ApexPages.PageReference('/' + reportId + '?csv=1&exp=1&enc=UTF-8&isdtp=p1');
            Blob reportContent = report.getContent();
            System.debug('reportContent -> ' + reportContent);
            System.debug('reportContent Size -> ' + reportContent.size());

           // reportContentString = EncodingUtil.base64Encode(reportContent);
          //  System.debug('reportContentString -> ' + reportContentString);
        } catch (Exception e) {
            System.debug('Error fetching report content: ' + e.getMessage());
        }
        return reportContentString;
    }
    public static void reportDetails(String reportId) {
        Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
        System.debug('results -> '+results);
        
        Reports.ReportFactWithDetails factDetails1 = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');
        System.debug('factDetails1 -> '+factDetails1);
        
        List<Reports.SummaryValue> recordCount = factDetails1.getAggregates();
        System.debug('recordCount -> '+recordCount);
        
        Decimal grandTotal = (Decimal) recordCount.get(recordCount.size() - 1).getValue();
        System.debug('grandTotal -> '+grandTotal);
    }
}