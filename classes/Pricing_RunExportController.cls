/**
* @description       : Class to get the report for different qli type and add it to excel sheet for downloading.
* @author            : Accenture
* @group             : Gravity
* @last modified on  : 04-25-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_RunExportController {
    
    private static Boolean  isRPM;
    private static Boolean  isFIRPM;
    private static Boolean  isExternal;
    private static List<SBQQ__QuoteLine__c> qliLst;
    private static List<String> qliStatus;
    private static Map<String,List<String>> qliTypeToFieldAPIMap;
    
    /**
* @description called from pricing_RunExport LWC to get the header and row data.
* @author Accenture
* @param recordId 
* @return Map<String, Map<String, List<List<String>>>> 
**/
    @AuraEnabled
    public static Map<String,Map<String,List<List<String>>>> getQLIData(Id recordId) {
        Map<String,Map<String,List<List<String>>>> qliTypeToHeaderToQliMap = new Map<String,Map<String,List<List<String>>>>();
        try{
        isRPM = personaCheck(new List<String>{Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager});
    	isFIRPM = personaCheck(new List<String>{Label.Pricing_Tender_PermissionSets_FinancialIncentivePricingManager});
        isExternal = personaCheck(Label.Pricing_Tender_PermissionSets_AllExternal.split(':'));
        qliStatus = (isRPM || isFIRPM) ? new List<String>{Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview} : Label.Pricing_Tender_PicklistValue_AllQLStatus.split(',');
        Map<String,List<SBQQ__QuoteLine__c>> qliTypeToQliMap = new Map<String,List<SBQQ__QuoteLine__c>>();
        qliLst = [Select id,Pricing_Program_Type_Nm__c,SBQQ__Quote__r.Name from SBQQ__QuoteLine__c where SBQQ__Quote__c =: recordId and Pricing_Status_Nm__c =: qliStatus];
        List<String> qliType = new List<String>();
        Set<String> qliTypeSet = new Set<String>();
        for(SBQQ__QuoteLine__c  qli:qliLst){
            qliTypeSet.add(qli.Pricing_Program_Type_Nm__c);
            if(qliTypeToQliMap.keySet().contains(qli.Pricing_Program_Type_Nm__c)){
                qliTypeToQliMap.get(qli.Pricing_Program_Type_Nm__c).add(qli);
            }
            else{
                qliTypeToQliMap.put(qli.Pricing_Program_Type_Nm__c,new List<SBQQ__QuoteLine__c>{qli});
            }
        }
        qliType.addAll(qliTypeSet);
        qliType.sort();
        for(String key: qliType){
            if(qliTypeToQliMap.containsKey(key)){
                qliTypeToHeaderToQliMap.put(key,getQliDetails(key,qliLst[0].SBQQ__Quote__r.Name));
            }
        }
    }
    catch(Exception e){
        Pricing_Tender_Utility.logError(e);
    }
        return qliTypeToHeaderToQliMap;
    }
        /**
* @description method to get the filter and id for respective  export report
* @author Accenture
* @param key 
* @param name 
* @return Map<String, Reports.ReportMetadata> 
**/
    private static Map<String,Reports.ReportMetadata> getFilters(String key,String name){
        List <Report> reportList = new List<Report>();
        String reportId;
        String reportName;
        Reports.ReportMetadata reportMd = new Reports.ReportMetadata();
        
        reportName = key == Label.Pricing_Tender_Small_Volume_Quote || key == Label.Pricing_Tender_Standard_QuoteLine ? isExternal ? Label.Pricing_Tender_Report_GenerateExternalReport : Label.Pricing_Tender_Report_GenerateInternalReport :
        key == Label.Pricing_Tender_SSD_Quote ? isExternal ? Label.Pricing_Tender_SSD_Report_External : Label.Pricing_Tender_SSD_Report:
        key == Label.Pricing_Tender_PMem_Quote ? isExternal ? Label.Pricing_Tender_PMem_Report_External : Label.Pricing_Tender_PMem_Report :
        key == Label.Pricing_Tender_CCG_Quote ? isExternal ? Label.Pricing_Tender_Client_Report_External : Label.Pricing_Tender_Client_Report : 
        key == Label.Pricing_Tender_DataCenter_GPU ? isExternal ? Label.Pricing_Tender_DataCenter_GPU_Report_External : Label.Pricing_Tender_DataCenter_GPU_Report : 
        key == Label.Pricing_Tender_FinancialIncentive_Quote ? Label.Pricing_IQR_F_I_Quotes_Report_Export : isExternal ? Label.Pricing_Tender_NIC_Report_External :  Label.Pricing_Tender_NIC_Report;
        reportList = [SELECT Id,DeveloperName FROM Report where DeveloperName =: reportName];
        reportId = (String)reportList.get(0).get('Id');
        Reports.ReportDescribeResult describeRPMUsr = Reports.ReportManager.describeReport(reportId);
        //Get Report records to apply filter on
        Reports.ReportResults resultsRpm = Reports.ReportManager.runReport(reportId, true);
        reportMd = resultsRpm.getReportMetadata();
        for(Reports.ReportFilter filter : reportMd.getReportFilters())
        {
            //Apply Filters on the Report records fetched
            if(filter.getColumn() == 'SBQQ__Quote__c.Name'){
                filter.setValue(name);
            }
            else if(filter.getColumn() == 'SBQQ__QuoteLine__c.Pricing_Status_Nm__c'){
                filter.setValue((isRPM || isFIRPM)? Label.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview : Label.Pricing_Tender_PicklistValue_AllQLStatus);    
            }
            else if(filter.getColumn() == 'SBQQ__QuoteLine__c.Pricing_Program_Type_Nm__c'){
                filter.setValue(Key);
            }
        }
        
        return new Map<String,Reports.ReportMetadata>{reportId => reportMd};
            }
    
    /**
* @description method to run report and return the heaader and the data
* @author Accenture 
* @param qliType 
* @param Name 
* @return Map<String, List<List<String>>> 
**/
    private static Map<String,List<List<String>>> getQliDetails(String qliType,String Name){   
        
        List<List<String>> cellValuesList = new List<List<String>>();
        
        Map<String,Reports.ReportMetadata> idToFilterMAP = getFilters(qliType,name);
        List<String> reportIdLst = new List<String>();
        reportIdLst.addAll(idToFilterMAP.keySet());
        
        //Run the report with the report metadata, filters and the report id value fetched from the Pricing_ReportFilterController
        Reports.ReportResults results = Reports.ReportManager.runReport(reportIdLst[0],idToFilterMAP.get(reportIdLst[0]), true);
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
            List<String> cellValues = new List<String>();
            for(Reports.ReportDataCell dataCell:detailRow.getDataCells())
            {
                /*Loop through the detail row records and get the individual cell value from the report corresponding to each detail row*/
                cellValues.add(dataCell.getlabel());
            }
            cellValuesList.add(cellValues);
        }
        Reports.ReportMetadata reportMd = new Reports.ReportMetadata();
        List<String> columnHeaders = new List<String>();
        Reports.ReportDescribeResult describeRes = Reports.ReportManager.describeReport(reportIdLst[0]);
        Reports.ReportExtendedMetadata reportMeta = describeRes.getReportExtendedMetadata();
        Map<String,Reports.DetailColumn> colMap = reportMeta.getDetailColumnInfo();
        for(String key : colMap.KeySet())
        {
            columnHeaders.add(colMap.get(key).getLabel());
        }
        return new Map<String,List<List<String>>>{String.join(columnHeaders,',') => cellValuesList}; 
            }
    
    /**
* @description method to check for assigned PS
* @author Accenture
* @param psName 
* @return Boolean 
**/
    @AuraEnabled
    public static Boolean personaCheck(List<String> psName) {
        integer count = [SELECT count() FROM PermissionSetAssignment
                         WHERE AssigneeId = : Userinfo.getUserId() AND PermissionSet.Name In: psName
                        ];
        return count > 0;
    }
}