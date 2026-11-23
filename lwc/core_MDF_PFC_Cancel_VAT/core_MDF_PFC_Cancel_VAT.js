import { LightningElement, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getVATCancellationOptions from "@salesforce/apex/Core_MDF_Claim_VAT_Process.getVATCancellationOptions";
import cancelClaimVAT from "@salesforce/apex/Core_MDF_Claim_VAT_Process.cancelClaimVAT";
import cancelSelectedSubClaimVAT from "@salesforce/apex/Core_MDF_Claim_VAT_Process.cancelSelectedSubClaimVAT";

import TITLE from "@salesforce/label/c.Core_MDF_Cancel_VAT";  //Cancel VAT
import YES from "@salesforce/label/c.Core_MDF_Cancel_Claim_Yes";
import NO from "@salesforce/label/c.Core_MDF_Cancel_Claim_No";
import CANCEL from "@salesforce/label/c.Core_MDF_Cancel_Button";
import APPLICATION_ERROR from "@salesforce/label/c.Core_MDF_ApplicationErrorMessage";
import MODAL_BODY from "@salesforce/label/c.Core_MDF_Cancel_VAT_Body";  //Are you sure you want to cancel the VAT hold?
import OUTCOME_MODAL_BODY from "@salesforce/label/c.Core_MDF_Cancel_Outcome_Vat_Msg";  //Select the "Payment Breakdown" for which you want to cancel VAT.
import ACCOUNT_NODE from "@salesforce/label/c.Core_MDF_Account";  //Account
import NODE_AMOUNT from "@salesforce/label/c.Core_MDF_Requested_Reimbursement_Amt";  //Requested Amount (USD)
import DOCUMENT_STATUS from "@salesforce/label/c.Core_MDF_Document_Status";  //Document Status
import VAT_CANCEL_SUCCESS from "@salesforce/label/c.Core_MDF_VAT_Cancel_Success";  //The VAT workflow was successfully cancelled.
import SELECT_PAYMENT_BREAKDOWN from "@salesforce/label/c.Core_MDF_Select_Payment_Breakdown";  //Please select atleast one Payment Breakdown to continue.
import CLAIM_SUBMITTER_ONLY from "@salesforce/label/c.Core_MDF_Cancel_VAT_Claim_Submitter_Only";  //Only the Claim Submitter can cancel VAT.

export default class Core_MDF_PFC_Cancel_VAT extends LightningElement {
    labels = { title: TITLE, yes: YES, no: NO, cancel: CANCEL, modalBody: MODAL_BODY, outcomeModalbody: OUTCOME_MODAL_BODY};

    @api isCustomComp = false;
    _recordId;
    isEligible = false;
    isSuperClaim = false;
    subClaims = [];
    selectedSubClaimIds = [];
    isLoading = true;
    errorMessage = "";

    @api
    get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        if (value && value !== this._recordId) {
            this._recordId = value;
            this.checkEligibility();
        }
    }

    async checkEligibility() {
        this.isLoading = true;
        this.errorMessage = "";
        try {
            const cancellationDecision = await getVATCancellationOptions({
                claimId: this._recordId
            });
            this.isEligible = cancellationDecision.isEligible;
            this.isSuperClaim = cancellationDecision.isSuperClaim;
            this.subClaims = cancellationDecision.subClaims || [];
            this.selectedSubClaimIds = [];
            if (!this.isEligible) {
                this.errorMessage = cancellationDecision.errorMessage || CLAIM_SUBMITTER_ONLY;
            }
        } catch (error) {
            this.isEligible = false;
            this.errorMessage = this.getErrorMessage(error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleConfirm() {
        if (this.isLoading || !this.isEligible) {
            return;
        }
        if (this.isSuperClaim && this.selectedSubClaimIds.length === 0) {
            this.errorMessage = SELECT_PAYMENT_BREAKDOWN;
            return;
        }
        this.isLoading = true;
        this.errorMessage = "";
        try {
            const cancelled = this.isSuperClaim
                ? await cancelSelectedSubClaimVAT({
                    claimId: this._recordId,
                    subClaimIds: this.selectedSubClaimIds
                })
                : await cancelClaimVAT({ claimId: this._recordId });
            if (!cancelled) {
                throw new Error(APPLICATION_ERROR);
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: VAT_CANCEL_SUCCESS,
                    variant: "success"
                })
            );
            this.closeAndRefresh();
        } catch (error) {
            this.errorMessage = this.getErrorMessage(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: this.errorMessage,
                    variant: "error"
                })
            );
        } finally {
            this.isLoading = false;
        }
    }

    handleSelection(event) {
        this.selectedSubClaimIds = event.detail.selectedRows.map((row) => row.id);
        this.errorMessage = "";
    }

    subClaimColumns = [
        { label: ACCOUNT_NODE, fieldName: "accountNode" },
        { label: NODE_AMOUNT, fieldName: "nodeAmount", type: "currency", typeAttributes: {currencyCode: "USD", currencyDisplayAs: "symbol", minimumFractionDigits: 2, maximumFractionDigits: 2 } },
        { label: DOCUMENT_STATUS, fieldName: "vatStatus" }
    ];

    handleClose() {
        if (this.isCustomComp) {
            this.dispatchEvent(new CustomEvent("closemodal"));
        } else {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    closeAndRefresh() {
        this.handleClose();
        window.location.reload();
    }

    getErrorMessage(error) {
        return error?.body?.message || error?.message || APPLICATION_ERROR;
    }
}