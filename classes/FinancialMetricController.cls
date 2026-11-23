public without sharing class FinancialMetricController {

    @AuraEnabled(cacheable=true)
    public static List<CRM_Financial_Metric__c> getFinancialMetrics(Id accountPlanId) {
        return [
            SELECT Id, CRM_Year__c, CRM_Metric__c, CRM_Value__c, CRM_Account_Plan__c
            FROM CRM_Financial_Metric__c
            WHERE CRM_Account_Plan__c = :accountPlanId
        ];
    }

    @AuraEnabled
    public static List<CRM_Financial_Metric__c> saveFinancialMetrics(List<CRM_Financial_Metric__c> metrics) {
        upsert metrics;
        return [
            SELECT Id, CRM_Year__c, CRM_Metric__c, CRM_Value__c, CRM_Account_Plan__c
            FROM CRM_Financial_Metric__c
            WHERE CRM_Account_Plan__c = :metrics[0].CRM_Account_Plan__c
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getYearPicklistValues() {
        return new List<String>{ 'FY 2025', 'FY 2024', 'FY 2023', 'FY 2022', 'FY 2021' };
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getMetricTypePicklistValues() {
        return new List<String>{
            'Market Cap',
            'Revenue',
            'Net Income',
            'Cash & Investments',
            'Debt Long Term',
            'Price/Earnings',
            'Gross Margin',
            'Employees'
        };
    }
}