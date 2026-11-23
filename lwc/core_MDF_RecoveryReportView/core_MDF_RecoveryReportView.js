import { LightningElement,track,api,wire} from 'lwc';
import getFilteredDataForClaimsToBeRecovered from 
    '@salesforce/apex/Core_MDF_RecoveryClaimReportViewCtrl.getFilteredDataForClaimsToBeRecovered';
import Get_SummaryBreakdown from '@salesforce/apex/Core_MDF_RecoveryClaimReportViewCtrl.Get_SummaryBreakdown';
import updatePsdRecords from '@salesforce/apex/Core_MDF_RecoveryClaimReportViewCtrl.updatePsdRecords';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import userNameFIELD from '@salesforce/schema/User.Username';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import rowLabel from '@salesforce/label/c.Core_MDF_RowLabel';
import recoveryAmount from '@salesforce/label/c.Core_MDF_RecoveryAmount';
import selectedQuarterClaim from '@salesforce/label/c.Core_MDF_SelectedQuarterClaim';
import summaryBreakDown from '@salesforce/label/c.Core_MDF_SummaryBreakDown';
import budgetTypeLabel from '@salesforce/label/c.Core_MDF_Budget_Type_PFA';
import regionLabel from '@salesforce/label/c.Core_MDF_RegionLabel';
import recoveryAmtForSelQuarter from '@salesforce/label/c.Core_MDF_RecoveryAmtForSelQuarter';
import carryFwdAmtForPrevQtr from '@salesforce/label/c.Core_MDF_CarryFwdAmtForPrevQtr';
import amountRecovered from '@salesforce/label/c.Core_MDF_AmountRecovered';
import amountSummary from '@salesforce/label/c.Core_MDF_AmountSummary';
import cancelLabel from '@salesforce/label/c.Core_MDF_Cancel_Button';
import closeLabel from '@salesforce/label/c.Core_MDF_Close';
import applicationErrorMessage from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import setRecoveryOffset from '@salesforce/label/c.Core_MDF_Set_Recovery_Offset';
import recoveryOffsetAmt from '@salesforce/label/c.Core_MDF_Recovery_Offset_Amt';
import recoveryOffset from '@salesforce/label/c.Core_MDF_Recovery_Offset';
import toastErrorText from '@salesforce/label/c.Core_MDF_Error';
import toastSuccessText from '@salesforce/label/c.Core_MDF_Success';
import negativeAmountError from '@salesforce/label/c.Core_MDF_Recovery_Offset_NegativeError';
import offsetSuccessMsg from '@salesforce/label/c.Core_MDF_Recovery_Offset_Success';
import offsetErrorMsg from '@salesforce/label/c.Core_MDF_Recovery_Offset_ErrorMsg';
import recoveryOffsetLabel from '@salesforce/label/c.Core_MDF_Recovery_Offset_Label';
import recoveryOffsetHelptext from '@salesforce/label/c.Core_MDF_Recovery_Offset_HelpText';
import recoveryOffsetconfimMsg from '@salesforce/label/c.Core_MDF_Recovery_Offset_Confirm_Msg';
import submitButtonLabel from '@salesforce/label/c.Core_MDF_Submit_Button_Label';
import cancelButtonLabel from '@salesforce/label/c.Core_MDF_Cancel_Button';
import yesButtonLabel from '@salesforce/label/c.Core_MDF_Cancel_Claim_Yes';
import noButtonLabel from '@salesforce/label/c.Core_MDF_Cancel_Claim_No';
import commentsHeaderText from '@salesforce/label/c.Core_MDF_Offset_Comments_Header';
import commentsLinkText from '@salesforce/label/c.Core_MDF_Offset_Comments_Link';
import commentsPopUpHeaderText from '@salesforce/label/c.Core_MDF_Offset_Comments_Popup_Header';
import readyToRecoverError from '@salesforce/label/c.Core_MDF_Recovery_Offset_ReadyToRecover_Error';
import savedRecoveryOffsetAmountLabel from '@salesforce/label/c.Core_MDF_SavedRecoveryOffsetAmountLabel';


    const columnsTest = [
        { label: rowLabel, fieldName: 'groupName' ,cellAttributes: {
            class: {fieldName: 'groupCss'},
        }},
        { label: recoveryAmount, fieldName: 'totalRecoveryAmt',type: 'currency',cellAttributes: {
            class: {fieldName: 'recoveryAmtCss'},
        }},
    ];
  
export default class Core_MDF_RecoveryReportView extends LightningElement {
    //Custom Label--start
    selectedQuarterClaim = selectedQuarterClaim;
    summaryBreakDown = summaryBreakDown;
    budgetTypeLabel = budgetTypeLabel;
    regionLabel = regionLabel;
    recoveryAmtForSelQuarter = recoveryAmtForSelQuarter;
    carryFwdAmtForPrevQtr = carryFwdAmtForPrevQtr;
    amountRecovered = amountRecovered;
    amountSummary = amountSummary;
    cancelLabel = cancelLabel;
    closeLabel = closeLabel;
    setRecoveryOffset = setRecoveryOffset;
    recoveryOffsetAmt = recoveryOffsetAmt;
    recoveryOffset = recoveryOffset;
    negativeAmountError = negativeAmountError;
    offsetSuccessMsg= offsetSuccessMsg;
    offsetErrorMsg = offsetErrorMsg;
    toastErrorText = toastErrorText;
    toastSuccessText = toastSuccessText;
    recoveryOffsetLabel = recoveryOffsetLabel;
    recoveryOffsetHelptext = recoveryOffsetHelptext;
    recoveryOffsetconfimMsg = recoveryOffsetconfimMsg;
    submitButtonLabel = submitButtonLabel;
    cancelButtonLabel = cancelButtonLabel;
    yesButtonLabel = yesButtonLabel;
    noButtonLabel = noButtonLabel;
    commentsHeaderText = commentsHeaderText;
    commentsLinkText = commentsLinkText;
    commentsPopUpHeaderText = commentsPopUpHeaderText;
    readyToRecoverError = readyToRecoverError;
    savedRecoveryOffsetAmountLabel = savedRecoveryOffsetAmountLabel;

    //Custom Label--end
    @api mode;
    @api progValue;
    @api acctValue;
    @api quarter;
    @api loading;
    @track repCnt;
    @track repURL;
    chart;
    chartjsInitialized = false;
    @track data = [];
    @track columns = [];
    //Show Modal
    @track isShowModal = false;
    @track psdList=[];
    @track hideSummBreakdown=true;
    @track currUserId = Id;
    @track currentUserName;
    showOffsetModel = false;
    showOffsetConfirmationModel = false;
    recordId ='';
    maxOffsetAmount = 0.0;
    offsetComments = '';
    offsetExistingComments = '';
    offsetCommentDetails = '';
    readyToRecoverSavedAmount = 0.0;
    offsetAmount;
    initialOffsetAmount;
    apexResponseMap = {};
    commentToShowInPopup = '';
    showCommentPopup = false;
    @track recoveryOffsetDataMap = {};
    offsetDetailsList;

    @track selectedOptions = {account:this.accountValueSelected, program:this.programValueSelected, quarter:this.quarterValueSelected, mode: this.mode, budgetType: this.selectedBT};
   
    @api getFilteredDataForClaimsToBeRecovered(progValue,acctValue,quarterVal){
        this.progValue = progValue;
        this.acctValue = acctValue;
        this.quarterVal = quarterVal;
        console.log('line 54'+this.progValue);
 

        getFilteredDataForClaimsToBeRecovered({program: this.progValue, account: this.acctValue, quarter: this.quarterVal}) 
        .then((data) => {
            if (data) {
                this.hideSummBreakdown = false;

                // Process record data
                this.data = data.filter((record) => {
                    if(record.groupName === 'Offset'){
                        this.offsetDetailsList = record.offsetDetailsList;
                    }
                    return record.groupName != 'Offset';
                }).map((record) => {
                    let groupCss ;
                    let recoveryAmtCss;
                    let manualRecAmtCss; 
    
                    if(record.cssProperty === 'geo Rec'){
                        groupCss = 'slds-text-color_success';
                        recoveryAmtCss = 'slds-text-color_success slds-m-right_x-large';
                    }
                    if(record.cssProperty === 'budgettype Rec'){
                        groupCss = 'slds-text-heading_medium';
                        recoveryAmtCss = 'slds-text-heading_medium';
                    }
                    
                    else if(record.cssProperty === 'total'){
                        groupCss = 'slds-text-heading_medium slds-text-color_success';
                        recoveryAmtCss = 'slds-text-heading_medium slds-text-color_success';
                    }

                    return {...record, 
                        'groupCss': groupCss,
                        'recoveryAmtCss': recoveryAmtCss,
                        'manualRecAmtCss': manualRecAmtCss
                    }
                });
    
    
                this.error = undefined;
                this.loading = false;
                
                const custEvent = new CustomEvent(
                    'callloading', {
                        detail: this.loading
                    });
                this.dispatchEvent(custEvent);
                this.setOffDetailsMap();
            } else if (error) {
                this.error = error;
                this.loading = false;
    
                const custEvent = new CustomEvent(
                    'callloading', {
                        detail: this.loading
                    });
                this.dispatchEvent(custEvent);
            }
           
         })
        .catch(error => {
            const event = new ShowToastEvent({
                title: 'Error',
                message: applicationErrorMessage,
                variant: 'error',
                mode: 'pester'
            });
            this.dispatchEvent(event);
            }); 
            
        }

    connectedCallback() {
        this.columns = columnsTest;
    }

    setOffDetailsMap() {
        const offsetDetailsMap = {};
        if (this.offsetDetailsList) {
            this.offsetDetailsList.forEach(offsetDetail => {
                const key = `${offsetDetail.budgetType}-${offsetDetail.region}`;

                offsetDetailsMap[key] = {
                    key: key,
                    budgetType: offsetDetail.budgetType,
                    region: offsetDetail.region,
                    isUpdated: false,
                    showOffsetButton: offsetDetail.showOffsetButton,
                    disableOffsetButton: offsetDetail.disableOffsetButton,
                    recordId: offsetDetail.recordId,
                    offsetAmount: offsetDetail.recoveryOffsetAmount,
                    initialOffsetAmount: offsetDetail.recoveryOffsetAmount,
                    maxOffsetAmount: offsetDetail.maxOffsetAmount,
                    offsetComments: offsetDetail.offsetComments,
                    offsetExistingComments: offsetDetail.offsetComments,
                    offsetCommentDetails: offsetDetail.offsetCommentDetails,
                    readyToRecoverSavedAmount: offsetDetail.readyToRecoverSavedAmount,
                    errorMessage: '',
                    hasError: false,
                    errorRowKey: key + '-error',
                    errorClass: ''
                };
            });
            this.recoveryOffsetDataMap = offsetDetailsMap;
        }
    }
    
    get disableOffsetButton() {
        if (!this.recoveryOffsetDataMap) {
            return true;
        }
        // Returns true only if all disableOffsetButton are true
        return Object.values(this.recoveryOffsetDataMap).every(
            offsetDetail => offsetDetail.disableOffsetButton === true
        );
    }

    get showOffsetButton() {
        if (!this.recoveryOffsetDataMap) {
            return false;
        }
        // Get all values from the map and check if any have showOffsetButton true
        return Object.values(this.recoveryOffsetDataMap).some(
            offsetDetail => offsetDetail.showOffsetButton === true
        );
    }

    //Get Logged in User detail
    @wire(getRecord, { recordId: Id, fields: [userNameFIELD]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Username.value;
        } else if (error) {
            this.error = error ;
        }
    }
    
    updateOffsetAmounts() {
        const updatedRecords = [];
    
        for (const key in this.recoveryOffsetDataMap) {
            const row = this.recoveryOffsetDataMap[key];

            if (!row.isUpdated) {
                continue;
            }

            const psdRecord = { 'sobjectType': 'Core_MDF_Partnership_Score_Detail__c' };
            psdRecord['Id'] = row.recordId;
            psdRecord['Core_MDF_Recovery_Offset_Amt__c'] = row.offsetAmount;
            psdRecord['Core_MDF_Recovery_Offset_Comments_txt__c'] = row.offsetComments;

            // Add comment history if comments were changed
            const commentChanged =
                ((row.offsetComments != row.offsetExistingComments || row.offsetExistingComments == '') && row.offsetComments != '') ||
                (row.offsetComments == '' && row.offsetExistingComments != '');

            if (commentChanged) {
                const currTime = new Date().toGMTString();
                const userDetail = 'Username: ' + this.currentUserName + ' Time: ' + currTime;
                const commentHistory = userDetail + '\n' + row.offsetComments +
                    (row.offsetExistingComments == '' ? '' : '\n\n') + row.offsetCommentDetails;

                psdRecord['Core_MDF_Offset_Comment_Details_txt__c'] = commentHistory
                    ? commentHistory.slice(0, 120000)
                    : '';
            }

            updatedRecords.push(psdRecord);
        }
        
        updatePsdRecords({ recordList: updatedRecords })
            .then(() => {
        
                this.closeOffsetModal();
                
                //Refresh Summary Breakdown
                this.getSummaryBreakdown();
                
                //Refresh Left and Right Section
                this.selectedOptions.program = this.progValue;
                this.selectedOptions.account = this.acctValue;
                this.selectedOptions.quarter = this.quarterVal;
                this.selectedOptions.mode = this.mode;
                const custEvent = new CustomEvent(
                    'callpasstoparent', {
                        detail: this.selectedOptions
                    });
                this.dispatchEvent(custEvent);
                this.showToast(this.toastSuccessText, this.offsetSuccessMsg, 'success');
            })
            .catch(error => {
                this.closeOffsetModal();
                this.showToast('Error', error.body?.message, 'error');
            });
    }

    showModalBox(){
        this.isShowModal = true;
        this.getSummaryBreakdown();
    }

    getSummaryBreakdown(){
        Get_SummaryBreakdown ({program:this.progValue,account:this.acctValue,quarter:this.quarterVal})
        .then((result)=>{
            this.psdList = result;
            this.apexResponseMap = this.createMapFromResponse(result);
        })
        .catch(error => {
            console.log('Errorured:- '+error);
        });
    }

    createMapFromResponse(result) {
        let resultMap = new Map();
        result.forEach(item => {
            resultMap.set(item.id, item);
        });
        return resultMap;
    }

    handleLinkClick(event) {
        const clickedComment = event.target.dataset.key;
        const details = this.apexResponseMap.get(clickedComment);
        this.commentToShowInPopup = details.recoveryOffsetComments;
        this.showCommentPopup = true;
        this.isShowModal = false;
    }

    closeCommentPopup(){
        this.showCommentPopup = false;
        this.isShowModal = true;
    }

    showOffsetModalBox(){
        this.showOffsetModel = true;
    }

    closeOffsetModal(){
        this.showOffsetModel = false;
        this.resetOffsetData();
    }

    closeOffsetModals(){
        this.showOffsetModel = false;
        this.showOffsetConfirmationModel = false;
        this.resetOffsetData();
    }

    // Convert to array for iteration in template
    get offsetDetailsToRender() {
        return Object.entries(this.recoveryOffsetDataMap).map(([key, value]) => ({
            key,
            value
        }));
    }

    get disableOffsetSubmitButton() {
        // Disable the button if no offset record have isUpdated = true
        return !Object.values(this.recoveryOffsetDataMap).some(entry => entry.isUpdated);
    }

    resetOffsetData() {
        // Clear errors
        this.offsetDetailsToRender.forEach(record => {
            record.value.errorMessage = '';
            record.value.hasError = false;
            record.value.errorClass = '';
        });

        // Reset all recoveryOffsetDataMap entries to their initial values
        const updatedMap = {};

        Object.entries(this.recoveryOffsetDataMap).forEach(([key, value]) => {
            updatedMap[key] = {
                ...value,
                offsetAmount: value.initialOffsetAmount,
                offsetComments: value.offsetExistingComments,
                isUpdated: false
            };
        });
        this.recoveryOffsetDataMap = updatedMap;
    }

    handleAmountChange(event) {
        const key = event.target.dataset.key;
        const inputValue = event.target.value;
        const row = this.recoveryOffsetDataMap[key];

        row.offsetAmount = inputValue;

        row.isUpdated = this.isOffsetRowUpdated(
            inputValue,
            row.initialOffsetAmount,
            row.offsetComments,
            row.offsetExistingComments
        );

        this.recoveryOffsetDataMap = { ...this.recoveryOffsetDataMap };
    }

    handleCommentChange(event) {
        const key = event.target.dataset.key;
        const inputValue = event.target.value;
        const row = this.recoveryOffsetDataMap[key];

        row.offsetComments = inputValue;

        row.isUpdated = this.isOffsetRowUpdated(
            row.offsetAmount,
            row.initialOffsetAmount,
            inputValue,
            row.offsetExistingComments
        );

        this.recoveryOffsetDataMap = { ...this.recoveryOffsetDataMap };
    }

    isOffsetRowUpdated(newAmountRaw, initialAmountRaw, newCommentRaw, initialCommentRaw) {
        const newAmount = parseFloat(newAmountRaw) || 0.0;
        const initialAmount = parseFloat(initialAmountRaw) || 0.0;

        const newComment = (newCommentRaw || '').trim();
        const initialComment = (initialCommentRaw || '').trim();

        return newAmount !== initialAmount || newComment !== initialComment;
    }

    handleClick(event) {
        event.preventDefault();

        // Clear previous errors
        this.offsetDetailsToRender.forEach(record => {
            record.value.errorMessage = '';
            record.value.hasError = false;
            record.value.errorClass = '';
        });

        let allRowsValid = true;

        for (let key in this.recoveryOffsetDataMap) {
            const row = this.recoveryOffsetDataMap[key];
            const enteredAmt = row.offsetAmount !== undefined ? parseFloat(row.offsetAmount) : 0.0;
            const maxOffsetAmt = parseFloat(row.maxOffsetAmount) || 0.0;
            const readyToRecoverSavedAmt = parseFloat(row.readyToRecoverSavedAmount) || 0.0;

            row.errorMessage = '';
            row.hasError = false;
            row.errorClass = '';

            // Negative amount check
            if (enteredAmt < 0) {
                row.errorMessage = this.negativeAmountError;
                row.hasError = true;
                row.errorClass = 'slds-input_error';
                allRowsValid = false;
            }

            // Exceeds maxOffsetAmt - readyToRecoverSavedAmount check
            if (readyToRecoverSavedAmt > 0 && enteredAmt > (maxOffsetAmt - readyToRecoverSavedAmt)) {
                row.errorMessage = this.readyToRecoverError + (' ($' + String((maxOffsetAmt - readyToRecoverSavedAmt).toFixed(2)) + ')');
                row.hasError = true;
                row.errorClass = 'slds-input_error';
                allRowsValid = false;
            }

            // Exceeds maxOffsetAmt check
            if (enteredAmt > maxOffsetAmt) {
                row.errorMessage = this.offsetErrorMsg + maxOffsetAmt;
                row.hasError = true;
                row.errorClass = 'slds-input_error';
                allRowsValid = false;
            }
        }

        // If no errors, show confirmation modal
        if (allRowsValid) {
            this.showOffsetModel = false;
            this.showOffsetConfirmationModel = true;
        }
    }

    showToast(title, message, variant = 'info') {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }

    saveRecord(){
        this.updateOffsetAmounts();
        this.showOffsetModel = false;
        this.showOffsetConfirmationModel = false;
    }

    hideModalBox() {  
             this.isShowModal = false;
    }

}