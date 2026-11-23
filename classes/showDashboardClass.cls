public with sharing class showDashboardClass {
    @AuraEnabled
    public static string updateReport(String recId){
        try {
            System.debug('Record Id is '+recId);
            
        
        // Get the report ID
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where 
            DeveloperName = 'Test_Order_syl_SCp'];
        String reportId = (String)reportList.get(0).get('Id');

        // Get the report metadata
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        Reports.ReportMetadata reportMd = describe.getReportMetadata();

        // Override filter and run report
        Reports.ReportFilter filter = reportMd.getReportFilters()[0]; //first filter 
        filter.setValue(recId);
        System.debug('Hurray');
        
        Reports.ReportResults results = Reports.ReportManager.runReport(reportId, reportMd);

        System.debug('Synchronous results: ' + results);
       // Reports.ReportFactWithSummaries factSum = 
        //    (Reports.ReportFactWithSummaries)results.getFactMap().get('T!T');
        //System.debug('Value for November: ' + factSum.getAggregates()[0].getLabel());

        /*
        // Override filter and run report
        filter = reportMd.getReportFilters()[0];
        filter.setValue('2013-10-01');
        results = Reports.ReportManager.runReport(reportId, reportMd);
        factSum = (Reports.ReportFactWithSummaries)results.getFactMap().get('T!T');
        System.debug('Value for October: ' + factSum.getAggregates()[0].getLabel());
        */
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
      return 'Great';
    }
}