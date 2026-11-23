public without sharing class FinancialMetricController {

    @AuraEnabled(cacheable=true)
    public static List<CRM_Financial_Metric__c> getMetrics(Id accountPlanId) {
        return [
            SELECT Id, CRM_Metric_Type__c, CRM_Financial_metric_value__c, CRM_percentage_value__c, CRM_Fiscal_Year__c, CRM_As_of_Date__c
            FROM CRM_Financial_Metric__c
            WHERE CRM_Account_Plan__c = :accountPlanId
            ORDER BY CreatedDate DESC
        ];
    }


    @AuraEnabled
    public static void deleteMetric(Id metricId) {
        CRM_Financial_Metric__c metric = [
            SELECT Id FROM CRM_Financial_Metric__c WHERE Id = :metricId
            LIMIT 1
        ];
        delete metric;
    }

     @AuraEnabled
    public static void upsertMetrics(List<CRM_Financial_Metric__c> metrics) {
        if (metrics == null || metrics.isEmpty()) {
            throw new AuraHandledException('No metrics to save.');
        }

        try {
            upsert metrics;
        } catch (Exception e) {
            throw new AuraHandledException('Error while saving metrics: ' + e.getMessage());
        }
    }
}