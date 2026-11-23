public with sharing class Pricing_ReportFilterController {
    public static Reports.ReportMetadata setReportFilter(Id quoteIdParam)
    {
        Id quoteId = (Id) String.escapeSingleQuotes(String.valueOf(quoteIdParam)); 
        SBQQ__Quote__c quote = [select id, Name, Pricing_Program_Type_Nm__c from SBQQ__Quote__c where id = : quoteId];
        List <Report> reportList = new List<Report>();
        String reportId;
        String reportName;
        Reports.ReportMetadata reportMd = new Reports.ReportMetadata();
        Reports.ReportFilter quoteNumberFilter = new Reports.ReportFilter();
        Reports.ReportFilter quoteLineStatusFilter = new Reports.ReportFilter();
        List<Reports.ReportFilter> reportQNFilters = new List<Reports.ReportFilter>();
        List<Reports.ReportFilter> reportQLSFilters = new List<Reports.ReportFilter>();
        List<Reports.ReportFilter> reportFinalFilters = new List<Reports.ReportFilter>();
        Set < String > internalPSWithoutRPM = new Set < String > ();
        Set < String > internalPSWithRPM = new Set < String > ();
        if(Label.Pricing_Tender_PermissionSets_AllInternal != null) {
            internalPSWithoutRPM.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllInternal).split(':')));
            internalPSWithoutRPM.remove(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
            internalPSWithRPM = new Set < String > {
                Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager
                    };
                        }
        Set < String > externalPS = new Set < String > ();
        if(Label.Pricing_Tender_PermissionSets_AllExternal != null) {
            externalPS.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllExternal).split(':')));
        }
        Boolean isInternalUserWithoutRPM = false;
        Boolean isRPMUser = false;
        Boolean isExternalUser = false;
        if(userHasValidPermissionSet(internalPSWithRPM)) {
            isRPMUser = true;
        } else if(userHasValidPermissionSet(internalPSWithoutRPM)) {
            isInternalUserWithoutRPM = true;
        } else if(userHasValidPermissionSet(externalPS)) {
            isExternalUser = true;
        }
        //Identify the Report and apply the Filter based on the logged in User
        if(isRPMUser) {
            if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){
                //reportName = 'IQR_Small_Volume_Quote_Export_QA';
                reportName = Label.Pricing_Tender_SmallVolumeReport_GenerateInternalReport;
            }
            else if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote){
                //reportName = 'IQR_Small_Volume_Quote_Export_QA';
                reportName = Label.Pricing_Tender_Report_GenerateInternalReport;
            }
            reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName =: reportName];
            reportId = (String)reportList.get(0).get('Id');
            Reports.ReportDescribeResult describeRPMUsr = Reports.ReportManager.describeReport(reportId);
            //Get Report records to apply filter on
            Reports.ReportResults resultsRpm = Reports.ReportManager.runReport(reportId, true);
            reportMd = resultsRpm.getReportMetadata();
            for(String col : reportMd.getDetailColumns())
            {
                //Apply Filters on the Report records fetched
                if(col == 'SBQQ__Quote__c.Name'){
                    quoteNumberFilter.setColumn(col);
                    quoteNumberFilter.setOperator('equals');
                    quoteNumberFilter.setValue(quote.Name);
                    reportQNFilters.add(quoteNumberFilter);
                }
                else if(col == 'SBQQ__QuoteLine__c.Pricing_Status_Nm__c'){
                    quoteLineStatusFilter.setColumn(col);
                    quoteLineStatusFilter.setOperator('equals');
                    quoteLineStatusFilter.setValue(Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview);
                    reportQLSFilters.add(quoteLineStatusFilter);
                    break;
                }   
            }
            
            reportFinalFilters.addAll(reportQNFilters);
            reportFinalFilters.addAll(reportQLSFilters);
            //Set the report filters
            reportMd.setReportFilters(reportFinalFilters);
        }
        else if(isInternalUserWithoutRPM){
            if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){
                //reportName = 'IQR_Small_Volume_Quote_Export_QA';
                reportName = Label.Pricing_Tender_SmallVolumeReport_GenerateInternalReport;
            }
            else if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote){
                //reportName = 'IQR_Small_Volume_Quote_Export_QA';
                reportName = Label.Pricing_Tender_Report_GenerateInternalReport;
            }
            reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName =: reportName];
            reportId = (String)reportList.get(0).get('Id');
            Reports.ReportDescribeResult describeIntUsr = Reports.ReportManager.describeReport(reportId);
            //Get Report records to apply filter on
            Reports.ReportResults resultsInt = Reports.ReportManager.runReport(reportId, true);
            reportMd = resultsInt.getReportMetadata();
            for(String col : reportMd.getDetailColumns())
            {
                //Apply Filters on the Report records fetched
                if(col == 'SBQQ__Quote__c.Name'){
                    quoteNumberFilter.setColumn(col);
                    quoteNumberFilter.setOperator('equals');
                    quoteNumberFilter.setValue(quote.Name);
                    reportQNFilters.add(quoteNumberFilter);
                }
                else if(col == 'SBQQ__QuoteLine__c.Pricing_Status_Nm__c'){
                    quoteLineStatusFilter.setColumn(col);
                    quoteLineStatusFilter.setOperator('equals');
                    quoteLineStatusFilter.setValue(Label.Pricing_Tender_PicklistValue_AllQLStatus);
                    reportQLSFilters.add(quoteLineStatusFilter);
                    break;
                }   
            }
            
            reportFinalFilters.addAll(reportQNFilters);
            reportFinalFilters.addAll(reportQLSFilters);
            //Set the report filters
            reportMd.setReportFilters(reportFinalFilters);
        }
        else if(isExternalUser) {
            if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){
                //reportName = 'IQR_Small_Volume_Quote_Export_QA';
                reportName = Label.Pricing_Tender_SmallVolumeReport_GenerateExternalReport;
            }
            else if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote){
                //reportName = 'IQR_Small_Volume_Quote_Export_QA';
                reportName = Label.Pricing_Tender_Report_GenerateExternalReport;
            }
            reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName =: reportName];
            reportId = (String)reportList.get(0).get('Id');
            Reports.ReportDescribeResult describeExtUsr = Reports.ReportManager.describeReport(reportId);
            //Get Report records to apply filter on
            Reports.ReportResults resultsExt = Reports.ReportManager.runReport(reportId, true);
            reportMd = resultsExt.getReportMetadata();
            for(String col : reportMd.getDetailColumns())
            {
                //Apply Filter on the Report records fetched
                if(col == 'SBQQ__Quote__c.Name'){
                    quoteNumberFilter.setColumn(col);
                    quoteNumberFilter.setOperator('equals');
                    quoteNumberFilter.setValue(quote.Name);
                    reportQNFilters.add(quoteNumberFilter);
                    break;
                } 
            }
            
            reportFinalFilters.addAll(reportQNFilters);
            reportFinalFilters.addAll(reportQLSFilters);
            system.debug(reportFinalFilters);
            //Set the report filters
            reportMd.setReportFilters(reportFinalFilters);
        }
        return reportMd;
    }
    
    //Method used to get the Report Id of a Report based on the Quote Id Parameter
    public static String getReportId(Id quoteIdParam){
        Id quoteId = (Id) String.escapeSingleQuotes(String.valueOf(quoteIdParam)); 
        SBQQ__Quote__c quote = [select id, Name, Pricing_Program_Type_Nm__c from SBQQ__Quote__c where id = : quoteId];
        List <Report> reportList = new List<Report>();
        String reportId;
        String reportName;
        Set < String > internalPSWithoutRPM = new Set < String > ();
        Set < String > internalPSWithRPM = new Set < String > ();
        if(Label.Pricing_Tender_PermissionSets_AllInternal != null) {
            internalPSWithoutRPM.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllInternal).split(':')));
            internalPSWithoutRPM.remove(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
            internalPSWithRPM = new Set < String > {
                Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager
                    };
                        }
        Set < String > externalPS = new Set < String > ();
        if(Label.Pricing_Tender_PermissionSets_AllExternal != null) {
            externalPS.addAll(new List < String > ((Label.Pricing_Tender_PermissionSets_AllExternal).split(':')));
        }
        Boolean isInternalUserWithoutRPM = false;
        Boolean isRPMUser = false;
        Boolean isExternalUser = false;
        if(userHasValidPermissionSet(internalPSWithRPM)) {
            isRPMUser = true;
        } else if(userHasValidPermissionSet(internalPSWithoutRPM)) {
            isInternalUserWithoutRPM = true;
        } else if(userHasValidPermissionSet(externalPS)) {
            isExternalUser = true;
        }
        //Identify the Report Name and fetch the Report Id based on the logged in User
        if(isRPMUser) {
            if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){
                //reportName = 'IQR_Small_Volume_Quote_Export_QA';
                reportName = Label.Pricing_Tender_SmallVolumeReport_GenerateInternalReport;
                reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName =: reportName];
                reportId = (String)reportList.get(0).get('Id');
            }
            else if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote){
                //reportName = 'IQR_Small_Volume_Quote_Export_QA';
                reportName = Label.Pricing_Tender_Report_GenerateInternalReport;
                reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName =: reportName];
                reportId = (String)reportList.get(0).get('Id');
            }
        }
        else if(isInternalUserWithoutRPM) {
            if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){
                //reportName = 'IQR_Small_Volume_Quote_Export_QA';
                reportName = Label.Pricing_Tender_SmallVolumeReport_GenerateInternalReport;
                reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName =: reportName];
                reportId = (String)reportList.get(0).get('Id');
            }
            else if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote){
                //reportName = 'IQR_Small_Volume_Quote_Export_QA';
                reportName = Label.Pricing_Tender_Report_GenerateInternalReport;
                reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName =: reportName];
                reportId = (String)reportList.get(0).get('Id');
            }
        }
        else if(isExternalUser) {
            if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Small_Volume_Quote){
                //reportName = 'IQR_Small_Volume_Quote_Export_QA';
                reportName = Label.Pricing_Tender_SmallVolumeReport_GenerateExternalReport;
                reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName =: reportName];
                reportId = (String)reportList.get(0).get('Id');
            }
            else if(quote.Pricing_Program_Type_Nm__c == Label.Pricing_Tender_Standard_Quote){
                //reportName = 'IQR_Small_Volume_Quote_Export_QA';
                reportName = Label.Pricing_Tender_Report_GenerateExternalReport;
                reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName =: reportName];
                reportId = (String)reportList.get(0).get('Id');
            }
        }
        return reportId;
    }
    
    //Method written to check if the logged in User is a valid User and has atleast 1 Permission Set corresponding to FSE/RPM/Partner
    private static Boolean userHasValidPermissionSet(Set < string > permissionSets) {
        integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId =: UserInfo.getUserId() 
                         AND PermissionSet.Name IN: permissionSets];
        return count > 0;
    }
}