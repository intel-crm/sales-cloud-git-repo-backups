public with sharing class Pricing_ReportExportController {
    //Method used to get the Report Data and return the data to LWC, which will be used in exporting the report as Excel.
    @AuraEnabled(cacheable=true)
    public static List<String> getReportData(Id quoteIdParam){
        List<String> cellValues = new List<String>();
        //Run the report with the report metadata, filters and the report id value fetched from the Pricing_ReportFilterController
        Reports.ReportResults results = Reports.ReportManager.runReport(Pricing_ReportFilterController.getReportId(quoteIdParam), Pricing_ReportFilterController.setReportFilter(quoteIdParam), true);
        MAP<String,Reports.ReportFact> factDet = results.getFactMap();
        Set<String> factMapKeySet = factDet.keySet();
        String factMapKey = null;
        //Gets the key associated with each detail row (For Tabular Reports, Key will be same for all the Detail Rows)
        for(String reportKey: factMapKeySet){
            factMapKey = reportKey;
            break;
        }
        Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithdetails)results.getFactMap().get(factMapKey);
        //Gets the detail rows for the Report that was run
        List<Reports.ReportDetailRow> detailListRows = factDetails.getRows();
        for(Reports.ReportDetailRow detailRow:detailListRows)
        {
            for(Reports.ReportDataCell dataCell:detailRow.getDataCells())
            {
                /*Loop through the detail row records and get the individual cell value 
                from the report corresponding to each detail row*/
                cellValues.add(dataCell.getlabel());
            }
        }
        return cellValues;
    }
    
    //Method used to get the column titles for the report. 
    //Column Titles will be returned to LWC to be referred for exporting the report as Excel.
    @AuraEnabled(cacheable=true)
    public static List<String> getColumnHeaders(Id quoteIdParam){
        Reports.ReportMetadata reportMd = new Reports.ReportMetadata();
        List<String> columnHeaders = new List<String>();
        Reports.ReportDescribeResult describeRes = Reports.ReportManager.describeReport(Pricing_ReportFilterController.getReportId(quoteIdParam));
        Reports.ReportExtendedMetadata reportMeta = describeRes.getReportExtendedMetadata();
        Map<String,Reports.DetailColumn> colMap = reportMeta.getDetailColumnInfo();
        for(String key : colMap.KeySet())
        {
            columnHeaders.add(colMap.get(key).getLabel());
        }
        return columnHeaders;
    }
}