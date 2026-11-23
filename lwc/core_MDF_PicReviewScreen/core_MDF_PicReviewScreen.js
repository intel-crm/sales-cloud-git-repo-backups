import { LightningElement, api, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import fetchClaimRecords from '@salesforce/apex/Core_MDF_PICReviewScreen_Controller.fetchClaimRecords';
import checkUserPermissionSet from '@salesforce/apex/Core_MDF_PICReviewScreen_Controller.checkUserPermissionSet';
import fetchExceptionsByClaimId from '@salesforce/apex/Core_MDF_PICReviewScreen_Controller.fetchExceptionsByClaimId';
import { loadStyle } from 'lightning/platformResourceLoader';
import Core_MDF_PICAccordionCSS from '@salesforce/resourceUrl/Core_MDF_PICAccordionCSS';
import Core_MDF_Ad_Run_Start_Date__c from '@salesforce/label/c.Core_MDF_ClaimStartDate';
import Core_MDF_Ad_Run_End_Date__c from '@salesforce/label/c.Core_MDF_ClaimEndDate';
import Core_MDF_Invoice_Number__c from '@salesforce/label/c.Core_MDF_Invoice_Number';
import Core_MDF_Invoice_Date__c from '@salesforce/label/c.Core_MDF_Invoice_Date';
import Core_MDF_Taxes_Local__c from '@salesforce/label/c.Core_MDF_Taxes_Local';
import Core_MDF_OtherCostsnotReimbursable_Local__c from '@salesforce/label/c.Core_MDF_OtherCostsnotReimbursable_Local';
import Core_MDF_Total_Invoice_Amount_Local__c from '@salesforce/label/c.Core_MDF_Total_Invoice_Amount_Local';
import Title from '@salesforce/label/c.Core_MDF_ClaimName';
import Core_MDF_Program__c from '@salesforce/label/c.Core_MDF_Program';
import Core_MDF_Budget_Type_Nm__c from '@salesforce/label/c.Core_MDF_Budget_Type';
import Core_MDF_Country_Location_nm__c from '@salesforce/label/c.Core_MDF_CountryLocation';
import Core_MDF_Currency__c from '@salesforce/label/c.Core_MDF_Core_MDF_Currency';
import activityName from '@salesforce/label/c.Core_MDF_A_description_of_the_activity_to_be_performed';
import Core_MDF_Activity_Category__c from '@salesforce/label/c.Core_MDF_Activity_Category';
import Core_MDF_Activity_Types__c from '@salesforce/label/c.Core_MDF_Activity_Type';
import Core_MDF_Activity_SubType_nm__c from '@salesforce/label/c.Core_MDF_Activity_Sub_Type_nm';
import Core_MDF_AccountCompany__c from '@salesforce/label/c.Core_MDF_AccountCompany';
import Core_MDF_Escalation_Id__c from '@salesforce/label/c.Core_MDF_EscalationId';
import Core_MDF_Claim_Ref_Number__c from '@salesforce/label/c.Core_MDF_ClaimID';
import Core_MDF_Media_Vehicle__c from '@salesforce/label/c.Core_MDF_Media_Vehicle';
import Core_MDF_Reimbursement_Percent__c from '@salesforce/label/c.Core_MDF_Reimbursement_Percent';
import Core_MDF_Claim_Comments__c from '@salesforce/label/c.Core_MDF_Description';
import Core_MDF_Status__c from '@salesforce/label/c.Core_MDF_Claim_Status';
import Core_MDF_Reimbursable_TransactionAmt_Loc__c from '@salesforce/label/c.Core_MDF_Reimbursable_TransactionAmt_Loc';
import Core_MDF_Exchange_rate__c from '@salesforce/label/c.Core_MDF_Exchange_rate';
import Core_MDF_Reimbursable_Transaction_Amount__c from '@salesforce/label/c.Core_MDF_Reimbursable_Transaction_Amount';
import Core_MDF_Requested_Reimbursement_Amt__c from '@salesforce/label/c.Core_MDF_Requested_Reimbursement_Amt';
import Amount from '@salesforce/label/c.Core_MDF_ReimbursementAmount';
import claimStatusPICPending from '@salesforce/label/c.Core_MDF_Claim_Status_PIC_Pending';
import claimTitle from '@salesforce/label/c.Core_MDF_Title_Contact_creation';
import applicationError from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import claimStatusPaidAndPICPending from '@salesforce/label/c.Core_MDF_Claim_Status_Paid_and_PIC_Pending';
import Core_MDF_3rd_Party_POP_Doc_Required_Ind__c from '@salesforce/label/c.Core_MDF_Third_Party_Indicator';
import picReviewScreenHeader from '@salesforce/label/c.Core_MDF_PIC_Review_Header';
import noClaimData from '@salesforce/label/c.Core_MDF_PIC_Review_NoClaimData';
import messageForNonPICPendingStatus from '@salesforce/label/c.Core_MDF_Message_On_NonPICPending';
import messageForNonPICReviewerLabel from '@salesforce/label/c.Core_MDF_Manual_Audit_Access_Error';
import picReviewScreenAccordionTitle from '@salesforce/label/c.Core_MDF_PIC_Review_Accordion_Title';
import applicationErrorText from '@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle';
import activity from '@salesforce/label/c.Core_MDF_Request_Name';
import escalationName from '@salesforce/label/c.Core_MDF_Escalation_Record';
import escalation from '@salesforce/label/c.Core_MDF_Escalation_Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import exceptionName from '@salesforce/label/c.Core_MDF_Exception_Name';
import exceptionReason from '@salesforce/label/c.Core_MDF_Exception_Reason';
import exceptionActCatType from '@salesforce/label/c.Core_MDF_Exception_Activity_Category_Type';
import potentialExceptions from '@salesforce/label/c.Core_MDF_Potential_Exceptions';

export default class Core_MDF_PicReviewScreen extends NavigationMixin(LightningElement) {
    @api claimRecordData;
    @api recordId;
    @api claimReferenceId;
    claimAccountId;
    exceptions = [];
    isPICReviewer;
    showClaimAndActivityDetails = false;
    iconName;
    eligibleForPIC;
    activityUrl;
    claimUrl;
    completeClaimResponse;
    claimAndActivityDetails;
    hasClaimRecordData = false;
    messageForNonEligibleUsers;
    isNonEligibleForPIC;
    showSpinner = false;
    isClaimRefreshed = false;
    messageForNonPICReviewer;
    potentialExceptionsLabel = potentialExceptions;
    exceptionNameLabel = exceptionName;
    exceptionReasonLabel = exceptionReason;
    exceptionActCatTypeLabel = exceptionActCatType;
    

    /**
     * This object contains the claim field api name and its label as key value pair. It is checked against claimRecorddata to display in the claim and activity details accordion
     */
    claimLabel = {
        Core_MDF_Activity_SubType_nm__c, Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c, Core_MDF_Invoice_Number__c, Core_MDF_Invoice_Date__c,
        Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_OtherCostsnotReimbursable_Local__c, Core_MDF_Taxes_Local__c, Title, Core_MDF_Program__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Country_Location_nm__c, Core_MDF_Currency__c,
        activityName, Core_MDF_Activity_Category__c, Core_MDF_Activity_Types__c, Core_MDF_AccountCompany__c, Core_MDF_Escalation_Id__c, Core_MDF_Claim_Ref_Number__c, Core_MDF_Media_Vehicle__c,
        Core_MDF_Reimbursement_Percent__c, Core_MDF_Claim_Comments__c, Core_MDF_Status__c, Core_MDF_Reimbursable_TransactionAmt_Loc__c, Core_MDF_Exchange_rate__c,
        Core_MDF_Reimbursable_Transaction_Amount__c, Core_MDF_Requested_Reimbursement_Amt__c, Amount, claimStatusPICPending, claimTitle, applicationError, claimStatusPaidAndPICPending, Core_MDF_3rd_Party_POP_Doc_Required_Ind__c, escalationName
    };

    picLabel = { picReviewScreenHeader, noClaimData, messageForNonPICPendingStatus, messageForNonPICReviewerLabel, picReviewScreenAccordionTitle, applicationErrorText, activity, escalation };

    @wire(checkUserPermissionSet, { userId: Id })
    wiredUserPermissions(response) {
        if(response.data) {
            this.showSpinner = true;
            this.isPICReviewer = true;
        } else if(response.data == false) {
            this.messageForNonPICReviewer = this.picLabel.messageForNonPICReviewerLabel;
            this.isPICReviewer = false;
            this.showSpinner = false;
        } else if(response.error) {
            console.log("Error in wiredUserPermissions: Core_MDF_PicReviewScreen", response.error);
            this.showSpinner = false;
            const toastEvent = new ShowToastEvent({
                title: this.picLabel.applicationErrorText,
                message: this.claimLabel.applicationError,
                variant: 'error'
            });
            this.dispatchEvent(toastEvent);
            this.closeQuickAction();
        }
        
    }
    //To fetch the claim record data from apex controller
    @wire(fetchClaimRecords, { claimId: '$recordId', isPICReviewer: '$isPICReviewer' })
    wiredClaims(response) {
        const data = response.data;
        const error = response.error;
        this.completeClaimResponse = response;
        if (data && data != {}) {
            this.claimRecordData = data;
            this.hasClaimRecordData = true;
            this.claimReferenceId = this.claimRecordData.Core_MDF_Claim_Ref_Number__c;
            if(this.claimRecordData.Core_MDF_Program__c == 'Retail Marketing Funds') {
                this.claimAccountId = this.claimRecordData.ChannelPartnerId;
            } else {
                this.claimAccountId = this.claimRecordData.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id;
            }
            if (this.isPICReviewer && (this.claimRecordData.Core_MDF_Status__c.toLowerCase() === this.claimLabel.claimStatusPICPending.toLowerCase()) || (this.claimRecordData.Core_MDF_Status__c.toLowerCase() === this.claimLabel.claimStatusPaidAndPICPending.toLowerCase())) {
                this.eligibleForPIC = true;
                this.generateNavigationUrls();
            } else {
                this.messageForNonEligibleUsers = this.picLabel.messageForNonPICPendingStatus;
                this.eligibleForPIC = false;
                this.showSpinner = false;
            }
        } else if(error) {
            this.hasClaimRecordData = false;
            this.showSpinner = false;
        }
    }

    //to fetch the exception data from the apex controller
    @wire(fetchExceptionsByClaimId, { claimId: '$recordId', corpAccountRecordId: '$claimAccountId' })
    wiredExceptions({ data, error }) {
        if (data && data != {}) {
            this.exceptions = Object.values(data);
        } else if (error) {
            console.error(error);
        }
        this.showSpinner = false;
    }
    
    connectedCallback() {
        //this.validateUserPermissions();
        loadStyle(this, Core_MDF_PICAccordionCSS); //to load styles from static resources
    }

    //Dispatch event to Parent aura component on completing the pic review to close the PIC Review Screen
    hidePICReviewScreen(event) {
        const picReviewScreenEvent = new CustomEvent('hidepicreviewscreen', {
            detail: { isReload: event.detail.isReload}
        });
        this.dispatchEvent(picReviewScreenEvent);
    }

    //Flag to expand/collapse expandable section
    toggleClaimAndActvityDetails() {
        this.showClaimAndActivityDetails = !this.showClaimAndActivityDetails;
    }

    //To get icons conditionally on expand/collapse of expandable section
    get iconNames() {
        this.iconName = this.showClaimAndActivityDetails ? 'utility:chevrondown' : 'utility:chevronright';
        return this.iconName;
    }

    //To generate urls of claim and activity
    async generateNavigationUrls() {
        this.claimAndActivityDetails = [];
        //activity url
        await this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.claimRecordData.RequestId,
                actionName: 'view',
            }
        }).then(url => {
            this.activityUrl = url;
        })
        //claim url
        await this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view',
            }
        }).then(url => {
            this.claimUrl = url;
        })
        //escalation url
        await this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.claimRecordData.Core_MDF_Escalation_Id__c,
                actionName: 'view',
            }
        }).then(url => {
            this.escalationUrl = url;
        })
        this.getClaimAndActivityDetails();
    }

    /**
     * To refresh the fetchClaimRecords when claim is edited
     * @param {*} event - event dispatched from PIC doc details
     */
    onUpdateOfClaim() {
        this.showClaimAndActivityDetails = false;
        refreshApex(this.completeClaimResponse);
        this.isClaimRefreshed = true;
    }

    //To get Claim and activity details to display in the expandable section
    getClaimAndActivityDetails() {
        const claimData = this.claimRecordData;
        for (const key in claimData) {
            let header = Object.keys(this.claimLabel).find(label => label === key);
           //Activity Name
            if (key.toLowerCase() === this.picLabel.activity.toLowerCase()) {
                this.claimAndActivityDetails.push({ key: this.claimLabel.activityName, value: `<a href=${this.activityUrl} target='_blank'>${claimData[key].Title}</a>`, show: claimData[key].Title ? true: false });
            }
            //Escalation Name
            else if (key.toLowerCase() === this.picLabel.escalation.toLowerCase()) {
                this.claimAndActivityDetails.push({ key: this.claimLabel.escalationName, value: `<a href=${this.escalationUrl} target='_blank'>${claimData[key].Name}</a>`, show: claimData[key].Name ? true: false });
            }
            //Claim Name
            else if (header && header.toLowerCase() === this.claimLabel.claimTitle.toLowerCase()) {
                this.claimAndActivityDetails.push({ key: this.claimLabel[header], value: `<a href=${this.claimUrl} target='_blank'>${claimData[key]}</a>`, show: claimData[key] ? true: false })
            }
            //Other data
            else if (header && header.toLowerCase() !== this.claimLabel.claimTitle.toLowerCase()) {
                this.claimAndActivityDetails.push({ key: this.claimLabel[header], value: claimData[key], show: claimData[key] != null ? true: false });
            }
        }

        if(this.isClaimRefreshed) {
            this.showSpinner = false;
        }

    }

    closeQuickAction() {
        const picReviewScreenEvent = new CustomEvent('hidepicreviewscreen', {
            detail: { isReload: false }
        });
        this.dispatchEvent(picReviewScreenEvent);
    }

    hideSpinner(event) {
        this.showSpinner = !event.detail.hide;
    }
}