public with sharing class PCC_UpdateClaimsController {
    
    // Method to update CSAR ID and Payment Ref ID for selected claims
    @AuraEnabled
    public static String updateClaims(List<String> claimIds, String csarId, String paymentRefId) {
        List<PCC_Rebate_Claim__c> claimsToUpdate = [
            SELECT Id, PCC_CSAR_ID__c, PCC_Payment_Ref_Id__c, PCC_Payment_Date__c
            FROM PCC_Rebate_Claim__c
            WHERE Id IN :claimIds
        ];
        system.debug('PCC_CSAR_ID__c value'+ csarId);
        system.debug('paymentRefId value'+ paymentRefId);
        
        for (PCC_Rebate_Claim__c claim : claimsToUpdate) {
            if(csarId != null && csarId != 'undefined' && csarId != ''){
                claim.PCC_CSAR_ID__c = csarId;
            }
            if(paymentRefId != null && paymentRefId != 'undefined' && paymentRefId != '' ){ 
                claim.PCC_Payment_Ref_Id__c = paymentRefId;
            }
            if (claim.PCC_CSAR_ID__c != null && claim.PCC_CSAR_ID__c != ''  && claim.PCC_Payment_Ref_Id__c != null && claim.PCC_Payment_Ref_Id__c != '')  {
                claim.PCC_Claim_Status__c = 'Payment Processed';
                claim.PCC_Payment_Date__c = Date.today();
            }
             system.debug('PCC_CSAR_ID__c value'+ csarId);
            system.debug('paymentRefId value'+ paymentRefId);
        }
        try {
            update claimsToUpdate;
            return 'Claims updated successfully.';
        } catch (DmlException e) {
            System.debug('DML Exception occurred: ' + e.getMessage());
            return 'Failed to update claims: ' + e.getMessage();
        } catch (Exception e) {
            System.debug('General Exception occurred: ' + e.getMessage());
            return 'An unexpected error occurred: ' + e.getMessage();
        }
    }

    // Method to fetch claim records
    @AuraEnabled//(cacheable=true)
    public static List<PCC_Rebate_Claim__c> getClaimRecords(String partnerName, Date fromdate, Date todate) {
        List<PCC_Rebate_Claim__c> claimRecords = [
            SELECT Id, Name, PCC_Total_Claimed_Rebate__c, PCC_Submission_Date__c, 
            PCC_CSAR_ID__c, PCC_Payment_Ref_Id__c, CreatedDate, PCC_Partner__c, PCC_Approval_Date__c
            FROM PCC_Rebate_Claim__c
            WHERE (PCC_CSAR_ID__c = null OR PCC_Payment_Ref_Id__c = null) 
            AND PCC_Claim_Status__c = 'Claim Approved - Payment Pending' 
            AND PCC_Partner__c = :partnerName
            ORDER BY PCC_Submission_Date__c DESC
        ];
      
        List<PCC_Rebate_Claim__c> filteredRecords = new List<PCC_Rebate_Claim__c>();

        for (PCC_Rebate_Claim__c claim : claimRecords) {
        Date createdDate = claim.CreatedDate.date();
        if (createdDate >= fromdate && createdDate <= todate) {
            filteredRecords.add(claim);
        }
      }
    return filteredRecords;    
    }
    
    @AuraEnabled //TWC3123-6336 -Rebate Analyst Permission Set check
    public static boolean userPScheck() {
        boolean havingPS = ![SELECT Id FROM PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() AND PermissionSet.Name = 'Pricing_Financial_Incentive_Rebate_Analyst'].isEmpty();
        return havingPS;
    }
}