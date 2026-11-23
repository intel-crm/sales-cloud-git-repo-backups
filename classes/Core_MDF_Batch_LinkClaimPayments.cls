/***********************************************************************************************************************************
* Class Name  : Core_MDF_Batch_LinkClaimPayments
* Version     : 1.0
* Created By  : Accenture-Vikas Soni
* Created Date: 24/08/2026
* Test Class  : Core_MDF_Batch_LinkClaimPaymentsTest
* Description : Batch to link claims to their payment records via the Core_MDF_Claim_Payment_Link__c junction object.
*               Queries payments created last quarter, finds associated claims, and creates junction records.
*               Uses Core_MDF_Unique_Key_Id__c external ID on junction object to prevent duplicate records.
* Modification Log :
* Developer              Date               Description
*************************************************************************************************************************************/
public without sharing class Core_MDF_Batch_LinkClaimPayments implements Database.Batchable<sObject> {

    // ─────────────────────────────────────────────────────────────────────────
    // START: Query Payment records created in the last quarter
    // Batch scope is Payment records; claims are queried inside execute()
    // ─────────────────────────────────────────────────────────────────────────
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Core_MDF_Payment__c
            WHERE CreatedDate >= LAST_90_DAYS
        ]);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // EXECUTE: For each batch of payments, find linked claims and create
    //          junction records with duplicate prevention
    // ─────────────────────────────────────────────────────────────────────────
    public void execute(Database.BatchableContext bc, List<Core_MDF_Payment__c> scopePayments) {
        try {

            // ── Step 1: Collect Payment Ids from this batch scope ──────────────
            Set<Id> paymentIdSet = new Set<Id>();
            for (Core_MDF_Payment__c payment : scopePayments) {
                paymentIdSet.add(payment.Id);
            }

            // ── Step 2: Query Claims linked to these Payment records ───────────
            // Only claims in Pending Payment status are eligible for linking
            List<PartnerFundClaim> linkedClaims = [
                SELECT Id,
                       Core_MDF_Claim_Id__c,
                       Core_MDF_Payment_Id__c,
                       ChannelPartnerId,
                       Core_MDF_Bank__c
                FROM PartnerFundClaim
                WHERE Core_MDF_Payment_Id__c IN :paymentIdSet
            ];
            if (linkedClaims.isEmpty()) {
                return;
            }

            // ── Step 3: Build Unique Keys for all candidate junction records ───
            // Format WITH sub-claim    : {PaymentId}_{ClaimId}_{SubClaimId}
            // Format WITHOUT sub-claim : {PaymentId}_{ClaimId}
            Set<String> candidateUniqueKeySet = new Set<String>();

            for (PartnerFundClaim claim : linkedClaims) {
                Boolean isSubClaim   = claim.Core_MDF_Claim_Id__c != null;
                Id      claimIdToUse = isSubClaim ? claim.Core_MDF_Claim_Id__c : claim.Id;
                Id      subClaimId   = isSubClaim ? claim.Id : null;

                candidateUniqueKeySet.add(
                    buildUniqueKey(claim.Core_MDF_Payment_Id__c, claimIdToUse, subClaimId)
                );
            }

            // ── Step 4: Query existing junction records to detect duplicates ───
            // Fetch any junction records that already have one of our candidate unique keys
            Set<String> existingUniqueKeySet = new Set<String>();

            for (Core_MDF_Claim_Payment_Link__c existingLink : [
                SELECT Core_MDF_Unique_Key_Id__c
                FROM Core_MDF_Claim_Payment_Link__c
                WHERE Core_MDF_Unique_Key_Id__c IN :candidateUniqueKeySet
            ]) {
                existingUniqueKeySet.add(existingLink.Core_MDF_Unique_Key_Id__c);
            }

            // ── Step 5: Build junction records, skipping already existing ones ─
            List<Core_MDF_Claim_Payment_Link__c> linkRecordsToInsertList = new List<Core_MDF_Claim_Payment_Link__c>();

            for (PartnerFundClaim claim : linkedClaims) {
                Boolean isSubClaim   = claim.Core_MDF_Claim_Id__c != null;
                Id      claimIdToUse = isSubClaim ? claim.Core_MDF_Claim_Id__c : claim.Id;
                Id      subClaimId   = isSubClaim ? claim.Id : null;

                String uniqueKey = buildUniqueKey(claim.Core_MDF_Payment_Id__c, claimIdToUse, subClaimId);

                // Skip if junction record already exists for this combination
                if (existingUniqueKeySet.contains(uniqueKey)) { continue; }

                linkRecordsToInsertList.add(new Core_MDF_Claim_Payment_Link__c(
                    Core_MDF_Claim_Id__c     = claimIdToUse,
                    Core_MDF_Sub_Claim_Id__c = subClaimId,
                    Core_MDF_Payment_Id__c   = claim.Core_MDF_Payment_Id__c,
                    Core_MDF_Unique_Key_Id__c   = uniqueKey,
                    Core_MDF_Account_Id__c = claim.ChannelPartnerId,
                    Core_MDF_Bank_Id__c = (claim.Core_MDF_Bank__c != null ? claim.Core_MDF_Bank__c : null)
                ));
            }

            if (linkRecordsToInsertList.isEmpty()) { return; }

            // Partial success (false) handles any edge case duplicates from concurrent runs gracefully.
            Database.insert(linkRecordsToInsertList, false);

        } catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e);}
    }

    public void finish(Database.BatchableContext bc) {
    }

    // ─────────────────────────────────────────────────────────────────────────
    // HELPER: Build a deterministic unique key for the junction record
    // Format WITH sub-claim    : {PaymentId}_{ClaimId}_{SubClaimId}
    // Format WITHOUT sub-claim : {PaymentId}_{ClaimId}
    // ─────────────────────────────────────────────────────────────────────────
    @TestVisible
    private static String buildUniqueKey(Id paymentId, Id claimId, Id subClaimId) {
        String uniqueKey = String.valueOf(paymentId) + '_' + String.valueOf(claimId);
        if (subClaimId != null) {
            uniqueKey += '_' + String.valueOf(subClaimId);
        }
        return uniqueKey;
    }
}