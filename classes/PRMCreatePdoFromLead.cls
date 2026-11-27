public with sharing class PRMCreatePdoFromLead {

    public class PdoRequest {

        @AuraEnabled public Id leadId { get; set; }

        // Lead fields
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String website { get; set; }
        @AuraEnabled public String company { get; set; }
        @AuraEnabled public String country { get; set; }

        // Manually entered fields
        @AuraEnabled public String opportunityName { get; set; }
        @AuraEnabled public String opportunitySummary { get; set; }
        @AuraEnabled public Decimal estimatedBudget { get; set; }
    }

    @AuraEnabled
    public static Id createPDO(PdoRequest request) {

        if (request == null || request.leadId == null) {
            throw new AuraHandledException(
                'Lead Id is required.'
            );
        }

        // Validate Lead
        List<Lead> leads = [
            SELECT Id
            FROM Lead
            WHERE Id = :request.leadId
            WITH USER_MODE
            LIMIT 1
        ];

        if (leads.isEmpty()) {
            throw new AuraHandledException(
                'Lead record not found.'
            );
        }

        // Validate mandatory fields
        if (String.isBlank(request.email) ||
            String.isBlank(request.website) ||
            String.isBlank(request.company) ||
            String.isBlank(request.country) ||
            String.isBlank(request.opportunityName) ||
            String.isBlank(request.opportunitySummary) ||
            request.estimatedBudget == null) {

            throw new AuraHandledException(
                'Please populate all mandatory fields.'
            );
        }

        if (request.estimatedBudget < 0) {
            throw new AuraHandledException(
                'Estimated Budget cannot be negative.'
            );
        }

        // Create PDO record
        PRM_Partner_Deal_Opportunity__c pdo =
            new PRM_Partner_Deal_Opportunity__c();

        // Lead fields
        //pdo.PRM_Email__c = request.email;
        pdo.PRM_End_Customer_Website__c = request.website;
        pdo.PRM_End_Customer_Name__c = request.company;

        // Country mapping
        pdo.PRM_End_Customer_Country__c = request.country;

        // Manually entered fields
        pdo.PRM_Opportunity_Name__c =
            request.opportunityName;

        pdo.PRM_Opportunity_Summary__c =
            request.opportunitySummary;

        pdo.PRM_Estimated_Budget__c =
            request.estimatedBudget;

        // Set Status
        pdo.PRM_Stage__c = 'Pre-Registered';

        try {
            insert as user pdo;
            return pdo.Id;
        }
        catch (DmlException e) {
            throw new AuraHandledException(
                'Unable to create PDO: ' + e.getDmlMessage(0)
            );
        }
    }
}