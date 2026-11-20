import { LightningElement, wire, track, api } from 'lwc';
import submitForApproval from '@salesforce/apex/Core_MDF_IUPGM_ApprovalRequest.submitForApproval';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import APPLICATION_ERROR from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
export default class Core_MDF_Approval_Request_Detail extends NavigationMixin(LightningElement) {


    @api recId;
    showSpinner = false;
    isModalopen = false;
    popupHeaderText;
    approvalButtonName;
    approvalComments;
    recordsToApproveReject = [];
    objectName;
    contentDetailUI = [];

    connectedCallback() {
        this.contentDetailUI = JSON.parse(this.recId);
    }

    handleApproveRejectClick(event) {
        this.approvalButtonName = event.currentTarget.dataset.id;
        this.objectName = this.contentDetailUI[0].object;
        this.isModalopen = true;
        this.popupHeaderText = this.approvalButtonName + ' ' + this.objectName;
    }

    handleApproveRejectPopUp() {
        this.recordsToApproveReject = [];
        this.showSpinner = true;
        var id = this.contentDetailUI[0].id;
        var piwiId = this.contentDetailUI[0].piwiId;
        let approvalRecord = {
            piwiId: piwiId,
            requestId: id,
            comments: this.approvalComments,
            actionStatus: this.approvalButtonName,
            targetObjectName: this.objectName
        };
        this.recordsToApproveReject.push(approvalRecord);
        this.recordsToApproveReject = JSON.parse(JSON.stringify(this.recordsToApproveReject));
        this.handleSubmitForApproval();
    }

    handleTextAreaChange(event) {
        this.approvalComments = event.target.value;
    }

    closeModal() {
        this.isModalopen = false;
    }
    handleNavigate(event) {
        if (this.isDesktop) {
            var selectedRecId = event.target.dataset.recordId;
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: selectedRecId,
                    actionName: 'view'
                }
            }).then(url => {
                window.open(url, "_blank");
            });
        }
    }

    handleSubmitForApproval() {
        if (this.approvalButtonName == 'Approve') {
            this.onSuccessShowToastMessage = this.objectName + ' Approved Successfully!!';
        } else if (this.approvalButtonName == 'Reject') {
            this.onSuccessShowToastMessage = this.objectName + ' Rejected Successfully!!';
        }
        submitForApproval({ approvalWrapperStr: JSON.stringify(this.recordsToApproveReject) })
            .then(data => {
                var result = JSON.parse(data);
                var showToastMsg = '';
                var fireToast = false;
                if (result != null && result != undefined) {
                    if (result.isSuccess) {
                        this.showToastMessage('Success', this.onSuccessShowToastMessage, 'success', 'pester');
                        this[NavigationMixin.Navigate]({
                            type: 'standard__navItemPage',
                            attributes: {
                                apiName: 'Core_MDF_Approval_Requests',
                            }
                        });
                        location.reload();
                    } else {
                        var returnValue = result.approvalTotalResult;
                            if (returnValue.length > 0) {
                                showToastMsg = returnValue[0].message;
                            }else {
                                showToastMsg = result.message;
                            }
                            fireToast = true;
                    
                        if (fireToast) {
                            var variant = result.variant
                            var header;
                            if (variant == 'warning') {
                                header = 'Alert';
                            } else if (variant == 'info') {
                                header = 'Info';
                            } else if (variant == 'error') {
                                header = 'Error';
                            }
                            this.showToastMessage(header, showToastMsg, variant, 'pester');
                        }

                        if(variant == 'warning'){
                            this[NavigationMixin.Navigate]({
                                type: 'standard__navItemPage',
                                attributes: {
                                    apiName: 'Core_MDF_Approval_Requests',
                                }
                            });
                            location.reload();
                        }
                    }
                }
                this.showSpinner = false;
                this.isModalopen = false;
            })
            .catch(error => {
                this.showToastMessage('Error',APPLICATION_ERROR, 'error', 'sticky');
                this.isModalopen = false;
                this.showSpinner = false;
            });
    }


    handleNavigate(event) {
        var selectedRecId = event.target.dataset.recordId;
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecId,
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }

    showToastMessage(title, message, variant, mode) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode
            })
        );
    }
}