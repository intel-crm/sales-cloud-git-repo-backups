/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-17-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class PRM_CustomReportService {
   
    public static Map<String, Type> typeOfReport  = new Map<String, Type>{
        'BenefitMismatch'=> PRM_BenefitMisMatchReport.class,
        'ProfileResponseMismatch'=>PRM_ProfileReponseMismatchReport.class
    };

    @AuraEnabled
    public static String getReportData(String reportType){
        PRM_CustomReportController getReport = (PRM_CustomReportController) typeOfReport.get(reportType).newInstance();        
        return getReport.getReport();
    }
}