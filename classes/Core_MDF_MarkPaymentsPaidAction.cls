public with sharing class Core_MDF_MarkPaymentsPaidAction {

    public class MarkPaidRequest {
        @InvocableVariable(label='Selected Payments' required=true)
        public List<Core_MDF_Payment__c> selectedPayments;

        @InvocableVariable(label='Payment Made On' required=true)
        public Date paymentMadeOn;

        @InvocableVariable(label='EFT Number' required=false)
        public String eftNumber;
    }

    @InvocableMethod(
        label='Mark Payments as Paid'
        description='Stamps Payment Made On and EFT Number on selected payments, sets status to Paid, and updates related claims to Paid.'
    )
    public static void markAsPaid(List<MarkPaidRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            return;
        }
        MarkPaidRequest req = requests[0];
        if (req.selectedPayments == null || req.selectedPayments.isEmpty()) {
            return;
        }

        Set<Id> paymentIds = new Set<Id>();
        List<Core_MDF_Payment__c> paymentsToUpdate = new List<Core_MDF_Payment__c>();

        for (Core_MDF_Payment__c pmt : req.selectedPayments) {
            paymentIds.add(pmt.Id);
            paymentsToUpdate.add(new Core_MDF_Payment__c(
                Id = pmt.Id,
                Core_MDF_Payment_Status_Txt__c = 'Paid',
                Core_MDF_Payment_Made_Dt__c = req.paymentMadeOn,
                Core_MDF_EFT_Nbr__c = req.eftNumber
            ));
        }
        update paymentsToUpdate;

        List<PartnerFundClaim> claimsToUpdate = [
            SELECT Id
            FROM PartnerFundClaim
            WHERE Core_MDF_Payment_Id__c IN :paymentIds
        ];
        for (PartnerFundClaim claim : claimsToUpdate) {
            claim.Core_MDF_Status__c = 'Paid';
        }
        if (!claimsToUpdate.isEmpty()) {
            update claimsToUpdate;
        }
    }
}