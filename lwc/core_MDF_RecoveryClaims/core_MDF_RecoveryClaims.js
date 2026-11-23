import { LightningElement, api, track, wire } from 'lwc';
import getClaimsBasedOnConditionsForUI from
    '@salesforce/apex/Core_MDF_Recovery_Helper.getClaimsBasedOnConditionsForUI';
import updateClaimRecords from '@salesforce/apex/Core_MDF_RecoveryClaimReportViewCtrl.updateSobjectList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import recoveryUIError from '@salesforce/label/c.Core_MDF_Recovery_UI_Error';
import claimsToRecoverFrom from '@salesforce/label/c.Core_MDF_ClaimsToRecoverFrom';
import exportToCSVLabel from '@salesforce/label/c.Core_MDF_ExportToCSV';
import claimNumber from '@salesforce/label/c.Core_MDF_ClaimNumber';
import geoLabel from '@salesforce/label/c.Core_MDF_Geo';
import claimStatus from '@salesforce/label/c.Core_MDF_RecoveryClaimStatus';
import claimAmtLabel from '@salesforce/label/c.Core_MDF_ClaimAmt';
import balanceAmtLabel from '@salesforce/label/c.Core_MDF_BalanceAmt';
import budgetTypeLabel from '@salesforce/label/c.Core_MDF_Budget_Type_PFA';
import countryLabel from '@salesforce/label/c.Core_MDF_Country';
import actCatLabel from '@salesforce/label/c.Core_MDF_ActivityCategory';
import actTypeLabel from '@salesforce/label/c.Core_MDF_Activity_Type';
import commentsLabel from '@salesforce/label/c.Core_MDF_IPA_Comments';
import recoveryAmtLabel from '@salesforce/label/c.Core_MDF_RecoveryAmount';
import recoveryBudTypeLabel from '@salesforce/label/c.Core_MDF_RecoveryBudgetType';
import recoveryBudAmountLabel from '@salesforce/label/c.Core_MDF_RecoveryBudgetAmount';
import totalClaimsSelected from '@salesforce/label/c.Core_MDF_TotalClaimsSelected';
import recoverySelected from '@salesforce/label/c.Core_MDF_RecoverySelected';
import totalRecoveryAmountLabel from '@salesforce/label/c.Core_MDF_TotalRecoveryAmount';
import recoveryErrorMsg from '@salesforce/label/c.Core_MDF_RecoveryErrorMsg';
import applicationErrorMessage from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import readytoRecover from '@salesforce/label/c.Core_MDF_Ready_to_Recover';
import savedMessage from '@salesforce/label/c.Core_MDF_Recovery_Saved_Message';
import preSelectionMessage from '@salesforce/label/c.Core_MDF_Recovery_Preselection_Message';
import closeLabel from '@salesforce/label/c.Core_MDF_Close';
import saveLabel from '@salesforce/label/c.Core_MDF_Save';
import recoveryLabel from '@salesforce/label/c.Core_MDF_Recovery';
import recoveryAmtError from '@salesforce/label/c.Core_MDF_RecoveryAmountError';
import readyToRecoverMessage from '@salesforce/label/c.Core_MDF_Ready_To_Recover_Message';
import selectedForRecovery from '@salesforce/label/c.Core_MDF_SelectedForRecovery';
import selectedForRecHelpTxt from '@salesforce/label/c.Core_MDF_SelectedForRecHelpTxt';
import readyForRecHelpTxt from '@salesforce/label/c.Core_MDF_ReadyForRecHelpTxt';
import recoveryAmtHelpTxt from '@salesforce/label/c.Core_MDF_RecoveryAmtHelpTxt';
import balanceAmtHelpTxt from '@salesforce/label/c.Core_MDF_BalanceAmtHelpTxt';
import recoveryBudAmtHelpTxt from '@salesforce/label/c.Core_MDF_RecoveryBudAmtHelpTxt';
import recoveryBudTypeHelpTxt from '@salesforce/label/c.Core_MDF_RecoveryBudTypeHelpTxt';
import ccfb from '@salesforce/label/c.Core_MDF_NonTranslateCCFBoostRecordType';
import spcf from '@salesforce/label/c.Core_MDF_NonTranslateSPCFRecordType';
import yesButtonLabel from '@salesforce/label/c.Core_MDF_Cancel_Claim_Yes';
import noButtonLabel from '@salesforce/label/c.Core_MDF_Cancel_Claim_No';
import holdClaimsForRecoveryLabel from '@salesforce/label/c.Core_MDF_Hold_Claims_for_Recovery';
import recoveryHoldLabel from '@salesforce/label/c.Core_MDF_Recovery_Hold';
import holdClaimsPopupConfirm from '@salesforce/label/c.Core_MDF_Hold_Claims_Popup_Confirm';
import cancelButtonLabel from '@salesforce/label/c.Core_MDF_Cancel_Button';
import saveSuccessfulLabel from '@salesforce/label/c.Core_MDF_Recovery_Save_Successful';
import recoveryHoldInfoMsg from '@salesforce/label/c.Core_MDF_Recovery_Hold_Info_Msg';
import successHeader from '@salesforce/label/c.Core_MDF_Success';
import informationHeader from '@salesforce/label/c.Core_MDF_Information';


const columnsTest = [
    { label: 'Claim #', fieldName: 'claimID', type: 'text' },
    { label: 'Budget Type', fieldName: 'budgetType', type: 'text' },
    { label: 'Geo', fieldName: 'geo', type: 'text' },
    { label: 'Country', fieldName: 'country', type: 'text' },
    { label: 'Claim Amount', fieldName: 'claimAmt', type: 'currency', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
    { label: 'Recovery Amount', fieldName: 'recoveryAmount', type: 'currency', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
    { label: 'Balance Amount', fieldName: 'balanceAmt', type: 'currency', typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
    { label: 'Recovery Budget Amount', fieldName: 'recoveryBudAmt', type: 'text', wrapText: true },
    { label: 'Comments', fieldName: 'comments', type: 'text' },
    { label: 'Claim Status', fieldName: 'clmStatus', type: 'text' },
    { label: 'Activity Category', fieldName: 'actCategory', type: 'text' },
    { label: 'Activity Type', fieldName: 'actType', type: 'text' },
];


export default class Core_MDF_RecoveryClaimsHtmlTable extends LightningElement {
    //Custom Labels--start
    recoveryErrorMsg = recoveryErrorMsg;
    totalRecoveryAmountLabel = totalRecoveryAmountLabel;
    totalClaimsSelected = totalClaimsSelected;
    recoverySelected = recoverySelected;
    claimsToRecoverFrom = claimsToRecoverFrom;
    exportToCSVLabel = exportToCSVLabel;
    claimNumber = claimNumber;
    geoLabel = geoLabel;
    claimStatus = claimStatus;
    claimAmtLabel = claimAmtLabel;
    balanceAmtLabel = balanceAmtLabel;
    budgetTypeLabel = budgetTypeLabel;
    countryLabel = countryLabel;
    actCatLabel = actCatLabel;
    actTypeLabel = actTypeLabel;
    commentsLabel = commentsLabel;
    recoveryAmtLabel = recoveryAmtLabel;
    recoveryBudTypeLabel = recoveryBudTypeLabel;
    recoveryBudAmountLabel = recoveryBudAmountLabel;
    closeLabel = closeLabel;
    saveLabel = saveLabel;
    recoveryLabel = recoveryLabel;
    readytoRecover = readytoRecover;
    recoveryUIError = recoveryUIError;
    recoveryAmtError = recoveryAmtError;
    source = '';
    readyToRecoverMessage = readyToRecoverMessage;
    selectedForRecovery = selectedForRecovery;
    selectedForRecHelpTxt = selectedForRecHelpTxt;
    readyForRecHelpTxt = readyForRecHelpTxt;
    recoveryAmtHelpTxt = recoveryAmtHelpTxt;
    balanceAmtHelpTxt = balanceAmtHelpTxt;
    recoveryBudAmtHelpTxt = recoveryBudAmtHelpTxt;
    recoveryBudTypeHelpTxt = recoveryBudTypeHelpTxt;
    ccfb = ccfb;
    spcf = spcf;
    yesButtonLabel = yesButtonLabel;
    noButtonLabel = noButtonLabel;
    holdClaimsForRecoveryLabel = holdClaimsForRecoveryLabel;
    recoveryHoldLabel = recoveryHoldLabel;
    holdClaimsPopupConfirm = holdClaimsPopupConfirm;
    cancelButtonLabel = cancelButtonLabel;
    saveSuccessfulLabel = saveSuccessfulLabel;
    recoveryHoldInfoMsg = recoveryHoldInfoMsg;
    successHeader = successHeader;
    informationHeader = informationHeader;
    //Custom Labels--end
    error;
    @track hasData = false;
    @api progValue;
    @api acctValue;
    @api quarter;
    @api mode;
    @api loading;
    @track data = [];
    @track columns = [];
    @track errors;
    @track data;
    draftValues = [];
    @track claimList = [];
    @track selectedRows = [];
    @api resultList;
    @track recoveryHoldResultList;
    @track tempRecoveryHoldResultList;
    recoveryHoldUpdated = new Map();
    enableRecoveryHoldSave = true;
    showRecoveryHoldConfirmationModel = false;
    isLoading = false;
    err = [];
    @track isShowModal = false;
    @track mapData = [];
    @track claimId;
    @track disableSave = true;
    @track claimRecoveryMap = [];
    @track claimRecBTAmountMap = [];
    @track eventClaim;
    @track showError = false;
    @track showSpinner = false;
    @track showHoldClaimsScreen = false;

    totalSelectedRowsCount = 0;
    totalSelectedBasedOnBudgetCount = 0;
    totalRecoveryAmount = 0;
    selectedBudgetType = 'ALL';
    selectedBudgetTypeValue = 'ALL';
    selectedGeo = 'ALL';
    selectedCountry = 'ALL';
    allDataFromApex = [];
    disableBudgetFilter = false;
    totalSelectedRecoveryAmount = 0;
    showMessage = false;
    msgToShow = '';
    claimAmount = 0;
    claimRecoveryAmount = 0;
    claimBalanceAmount = 0;

    @track claimList;

    handleBudgetChange(event) {

        this.selectedBudgetType = event.detail.value;
        this.totalRecoveryAmount = 0;
        let selectedRows = [];
        let tempClaims = [];
        if (this.selectedBudgetType == 'ALL') {
            this.resultList = this.allDataFromApex;
            tempClaims = this.resultList;
        } else {
            this.allDataFromApex.forEach(element => {
                if (element.budgetType == this.selectedBudgetType) {
                    tempClaims.push(element);
                }
            });
            this.resultList = tempClaims;
        }

        this.resultList.forEach(data => {
            if (data.selected == true) {
                selectedRows.push(data);
                if (data.recoveryAmount != '') {
                    if (!isNaN(data.recoveryAmount)) {
                        this.totalRecoveryAmount += parseFloat(data.recoveryAmount);
                    }
                }
            }
        });
        this.totalSelectedBasedOnBudgetCount = selectedRows.length;

        let selectedClaims = [];
        this.allDataFromApex.forEach(element => {
            if (element.selected == true) {
                selectedClaims.push(element);
            }
        });

        var selectedRec = { data: selectedClaims, errors: this.err.length };
        const custEvent2 = new CustomEvent(
            'saveclaimsforrecovery', {
            detail: selectedRec
        });
        this.dispatchEvent(custEvent2);
    }

    handleRecoveryHoldChange(event){
        let claimId = event.target.dataset.id;
        let selectedHoldValue = event.target.checked;
        let claimObj = {Core_MDF_Recovery_Hold_Ind__c: selectedHoldValue, Id: claimId, sobjectType : 'PartnerFundClaim'};

        this.allDataFromApex.forEach(element => {
            if(element.Id == claimId){
                if(element.recoveryHold != selectedHoldValue){
                    this.recoveryHoldUpdated.set(claimId, claimObj);
                }else if(this.recoveryHoldUpdated.has(claimId)){
                    this.recoveryHoldUpdated.delete(claimId);
                }
                return;
            }
        });

        this.recoveryHoldResultList.forEach(element => {
            if(element.Id == claimId){
                if(this.recoveryHoldUpdated.has(claimId)){
                    element.className = 'selected-row-color';
                }else{
                    element.className = '';
                }
                return;
            }
        });
        this.recoveryHoldResultList = [...this.recoveryHoldResultList];

        //Enable or Disable Save button
        if(this.recoveryHoldUpdated.size > 0){
            this.enableRecoveryHoldSave = false;
        }else{
            this.enableRecoveryHoldSave = true;
        }

        //Update the temp list
        this.tempRecoveryHoldResultList.forEach(element => {
            if(element.Id == claimId){
                element.recoveryHold = selectedHoldValue;
                if(this.recoveryHoldUpdated.has(claimId)){
                    element.className = 'selected-row-color';
                }else{
                    element.className = '';
                }
                return;
            }
        });
    }

    handleRecoveryHoldSave(){
        this.showHoldClaimsScreen = false;
        this.showRecoveryHoldConfirmationModel = true;
    }

    handleRecoveryHoldFilter(event){
        let filterValue = event.detail.value;
        let filterType = event.target.dataset.id;

        if(filterType == 'budgetType'){
            this.selectedBudgetTypeValue = filterValue;
        }else if(filterType == 'geo'){
            this.selectedGeo = filterValue;
        }else if(filterType == 'country'){
            this.selectedCountry = filterValue;
        }
        
        let tempClaims = [];
        this.tempRecoveryHoldResultList.forEach(element => {
            if ((this.selectedBudgetTypeValue == 'ALL' || element.budgetType == this.selectedBudgetTypeValue)
                    && (this.selectedGeo == 'ALL' || element.geo == this.selectedGeo)
                    && (this.selectedCountry == 'ALL' || element.country == this.selectedCountry)) {
                tempClaims.push(element);
            }
        });
        this.recoveryHoldResultList = tempClaims;
    }

    closeRecoveryHoldConfirmationModel(){
        this.showRecoveryHoldConfirmationModel = false;
        this.resetValues();
    }

    resetValues(){
        if(!this.enableRecoveryHoldSave){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.informationHeader,
                    message: this.recoveryHoldInfoMsg,
                    variant: 'info',
                })
            );
        }
        this.showHoldClaimsScreen = false;
        this.enableRecoveryHoldSave = true;
        this.recoveryHoldUpdated = new Map();
        this.recoveryHoldResultList = JSON.parse(JSON.stringify(this.allDataFromApex));
        this.tempRecoveryHoldResultList = JSON.parse(JSON.stringify(this.allDataFromApex));
        this.selectedBudgetTypeValue = 'ALL';
        this.selectedGeo = 'ALL';
        this.selectedCountry = 'ALL';
    }

    showHoldClaimsPopUp(){
        this.showHoldClaimsScreen = true;
    }

    closeHoldClaimPopup(){
        this.resetValues();
    }

    handleRecoveryHoldSaveConfirm(event){
        this.isLoading = true;
        let claimObjToUpdate = [];
        this.recoveryHoldUpdated.forEach((value, key) => {
            claimObjToUpdate.push(value);
        });
        updateClaimRecords({sobjectToUpdateList : claimObjToUpdate})
        .then(() => {
            this.getClaimsBasedOnConditionsForUI(this.progValue, this.acctValue, this.quarterVal, this.mode);
            this.showRecoveryHoldConfirmationModel = false;
            this.showHoldClaimsScreen = false;
            this.enableRecoveryHoldSave = true;
            this.recoveryHoldUpdated = new Map();
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.successHeader,
                    message: this.saveSuccessfulLabel,
                    variant: 'success',
                })
            );
        }) 
        .catch(error => {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    @api reloadWire() {
        this.getClaimsBasedOnConditionsForUI(this.progValue, this.acctValue, this.quarterVal, this.mode);
        this.errors = {};
    }

    @api getClaimsBasedOnConditionsForUI(progValue, acctValue, quarterVal, mode) {
        this.errors = {};
        this.hasData = false;
        this.progValue = progValue;
        this.acctValue = acctValue;
        this.quarterVal = quarterVal;
        this.mode = mode;
        this.data = [];
        this.calledFromGetData = true;
        this.budgetOptions = [{ label: 'ALL', value: 'ALL' }];
        this.geoOptions = [{ label: 'ALL', value: 'ALL' }];
        this.countryOptions = [{ label: 'ALL', value: 'ALL' }];
        this.selectedBudgetType = 'ALL';
        this.totalRecoveryAmount = 0;
        this.err = [];
        this.disableBudgetFilter = false;
        this.showMessage = false;
        this.msgToShow = '';

        getClaimsBasedOnConditionsForUI({ program: this.progValue, account: this.acctValue, quarter: this.quarterVal })
            .then((data) => {
                if (data != null && data != undefined) {
                    if (Object.hasOwn(data, 'rows')) {
                        if (data.rows.length > 0) {
                            if (this.mode == 'read') {
                                this.isDisabled = true;
                            }
                            else {
                                this.isDisabled = false;
                            }
                            this.hasData = true;
                            this.exportData = data.rows;
                            this.resultList = JSON.parse(JSON.stringify(data.rows));
                            this.tempClaims = [];
                            for (let i = 0; i < this.resultList.length; i++) {
                                this.resultList[i].accountId = this.acctValue;
                                this.resultList[i].program = this.progValue;
                                this.resultList[i].quarter = this.quarterVal;
                                if (this.resultList[i].selected == true) {
                                    this.resultList[i].isDisabled = false;
                                    this.tempClaims.push(this.resultList[i]);
                                } else {
                                    this.resultList[i].isDisabled = true;
                                }
                                if (this.resultList[i].budgetType != null && this.resultList[i].budgetType != '') {
                                    if (!this.budgetOptions.find(budget => budget.label == this.resultList[i].budgetType)) {
                                        this.budgetOptions.push(
                                            { label: this.resultList[i].budgetType, value: this.resultList[i].budgetType }
                                        );
                                    }
                                }                                
                                else if(this.resultList[i].program == ccfb){
                                    this.resultList[i].budgetType = 'CCFB';
                                }
                                else if(this.resultList[i].program == spcf){
                                    this.resultList[i].budgetType = 'SPCF';
                                }

                                if (this.resultList[i].geo != null && this.resultList[i].geo != '') {
                                    if (!this.geoOptions.find(geo => geo.label == this.resultList[i].geo)) {
                                        this.geoOptions.push(
                                            { label: this.resultList[i].geo, value: this.resultList[i].geo }
                                        );
                                    }
                                }

                                if (this.resultList[i].country != null && this.resultList[i].country != '') {
                                    if (!this.countryOptions.find(country => country.label == this.resultList[i].country)) {
                                        this.countryOptions.push(
                                            { label: this.resultList[i].country, value: this.resultList[i].country }
                                        );
                                    }
                                }
                                
                            }
                            this.allDataFromApex = this.resultList;
                            this.recoveryHoldResultList = JSON.parse(JSON.stringify(this.resultList));
                            this.tempRecoveryHoldResultList = JSON.parse(JSON.stringify(this.resultList));
                            this.totalSelectedRowsCount = this.tempClaims.length;
                            this.totalSelectedBasedOnBudgetCount = this.tempClaims.length;
                            this.source = data.isSaved === true ? savedMessage : preSelectionMessage;

                            this.resultList.forEach(data => {
                                if (data.selected == true) {
                                    if (data.recoveryAmount != '') {
                                        if (!isNaN(data.recoveryAmount)) {
                                            this.totalRecoveryAmount += parseFloat(data.recoveryAmount);
                                            this.totalSelectedRecoveryAmount = this.totalRecoveryAmount;
                                        }
                                    }
                                }
                            });


                            var selectedRec = { data: this.tempClaims, errors: null };
                            const custEvent1 = new CustomEvent(
                                'saveclaimsforrecovery', {
                                detail: selectedRec
                            });
                            this.dispatchEvent(custEvent1);

                            this.error = undefined;
                            this.loading = false;
                            const custEvent = new CustomEvent(
                                'callloading', {
                                detail: this.loading
                            });
                            this.dispatchEvent(custEvent);
                        }
                        else {
                            this.loading = false;
                            const custEvent = new CustomEvent(
                                'callloading', {
                                detail: this.loading
                            });
                            this.dispatchEvent(custEvent);
                        }
                    }
                    else {

                        if (Object.hasOwn(data, 'hideClaimInfo') && data.hideClaimInfo) {
                            this.showMessage = true;
                            this.msgToShow = data.msgToShow;
                        }

                        this.loading = false;
                        var selectedRec = { data: null, errors: null };
                        const custEvent1 = new CustomEvent(
                            'saveclaimsforrecovery', {
                            detail: selectedRec
                        });
                        this.dispatchEvent(custEvent1);

                        const custEvent = new CustomEvent(
                            'callloading', {
                            detail: this.loading
                        });
                        this.dispatchEvent(custEvent);
                    }
                }
                else {
                    this.loading = false;
                    var selectedRec = { data: null, errors: null };
                    const custEvent1 = new CustomEvent(
                        'saveclaimsforrecovery', {
                        detail: selectedRec
                    });
                    this.dispatchEvent(custEvent1);

                    const custEvent = new CustomEvent(
                        'callloading', {
                        detail: this.loading
                    });
                    this.dispatchEvent(custEvent);
                }
            })
            .catch(error => {
                var selectedRec = { data: null, errors: null };
                this.loading = false;
                const custEvent1 = new CustomEvent('saveclaimsforrecovery', {
                    detail: selectedRec
                });
                this.dispatchEvent(custEvent1);
                const custEvent = new CustomEvent(
                    'callloading', {
                    detail: this.loading
                });
                this.dispatchEvent(custEvent);
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: applicationErrorMessage,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
            });
    }
    connectedCallback() {
        this.columns = columnsTest;
    }

    exportToCSV() {
        let columnHeader = []; let jsonKeys = [];
        for (let x = 0; x < this.columns.length; x++) {
            columnHeader.push(this.columns[x].label);
            jsonKeys.push(this.columns[x].fieldName);
        }

        // This array holds the Column headers to be displayd
        // This array holds the keys in the json data  
        var jsonRecordsData = this.exportData;
        let csvIterativeData;
        let csvSeperator
        let newLineCharacter;
        csvSeperator = ",";
        newLineCharacter = "\n";
        csvIterativeData = "";
        csvIterativeData += columnHeader.join(csvSeperator);
        csvIterativeData += newLineCharacter;
        for (let i = 0; i < jsonRecordsData.length; i++) {
            let counter = 0;
            for (let iteratorObj in jsonKeys) {
                let dataKey = jsonKeys[iteratorObj];
                if (counter > 0) { csvIterativeData += csvSeperator; }
                if (jsonRecordsData[i][dataKey] !== null &&
                    jsonRecordsData[i][dataKey] !== undefined
                ) {
                    csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';
                } else {
                    csvIterativeData += '""';
                }
                counter++;
            }
            csvIterativeData += newLineCharacter;
        }

        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(csvIterativeData);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Recovery.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    //Checkbox Actions
    checkboxActions(event) {
        let key = event.target.dataset.id;
        let selection = event.target.checked;
        let tempClaims = this.resultList;
        let selectedClaims = [];
        for (let i = 0; i < tempClaims.length; i++) {
            if (tempClaims[i].Id == key) {
                if ((tempClaims[i].recoveryAmount == '' || tempClaims[i].recoveryAmount > tempClaims[i].claimAmt) && selection == true) {
                    tempClaims[i].selected = true;
                    tempClaims[i].isDisabled = false;
                    tempClaims[i].showCustomValidation = true;
                    tempClaims[i].cssClassName = 'row-color'
                    let found = false;
                    if (this.err.find(x => x == tempClaims[i].Id)) {
                        found = true;
                    }

                    if (!found) {
                        this.err.push(tempClaims[i].Id);
                    }
                    break;
                }
                else if (selection == false) {
                    tempClaims[i].selected = false;
                    tempClaims[i].righttoRecover = false;
                    tempClaims[i].isDisabled = true;
                    tempClaims[i].recoveryAmount = '';
                    tempClaims[i].recoveryBudAmt = '';
                    tempClaims[i].comments = '';
                    tempClaims[i].balanceAmt = '';
                    var tempMap = new Map();
                    for (let bt in tempClaims[i].recoveryBudAmtMap) {
                        tempMap[bt] = 0.00;
                    }
                    tempClaims[i].recoveryBudAmtMap = tempMap;
                    tempClaims[i].cssClassName = '';
                    tempClaims[i].showCustomValidation = false;
                    this.err = this.err.filter(value => value !== tempClaims[i].Id);
                    break;
                }
            }
        }
        this.resultList = tempClaims;
        this.totalSelectedRecoveryAmount = 0;
        let getFilterCount = [];
        this.totalRecoveryAmount = 0;

        for (let i = 0; i < this.resultList.length; i++) {
            if (this.resultList[i].selected == true) {
                getFilterCount.push(this.resultList[i]);
                if (this.resultList[i].recoveryAmount != '') {
                    if (!isNaN(this.resultList[i].recoveryAmount)) {
                        this.totalRecoveryAmount += parseFloat(this.resultList[i].recoveryAmount);
                    }
                }
            }
            this.allDataFromApex.forEach(element => {
                if (element.Id == this.resultList[i].Id) {
                    element.selected = this.resultList[i].selected;
                    element.comments = this.resultList[i].comments;
                    element.recoveryAmount = this.resultList[i].recoveryAmount;
                    element.balanceAmt = this.resultList[i].balanceAmt;
                }
            });
        }


        this.allDataFromApex.forEach(element => {
            if (element.selected == true) {
                selectedClaims.push(element);
                if (element.recoveryAmount != '') {
                    if (!isNaN(element.recoveryAmount)) {
                        this.totalSelectedRecoveryAmount += parseFloat(element.recoveryAmount);
                    }
                }
            }
        });

        this.totalSelectedRowsCount = selectedClaims.length;
        this.totalSelectedBasedOnBudgetCount = getFilterCount.length;


        if (this.err.length > 0) {
            this.disableBudgetFilter = true;
        } else {
            this.disableBudgetFilter = false;
        }

        var selectedRec = { data: selectedClaims, errors: this.err.length };
        const custEvent4 = new CustomEvent(
            'saveclaimsforrecovery', {
            detail: selectedRec
        });
        this.dispatchEvent(custEvent4);
    }

    //Comment Actions
    commentActions(event) {
        let key = event.target.dataset.id;
        let tempClaims = this.resultList;
        let selectedClaims = [];
        for (let i = 0; i < tempClaims.length; i++) {
            if (tempClaims[i].Id == key) {
                tempClaims[i].comments = event.target.value;
            }
        }

        this.resultList = tempClaims;
        let getFilterCount = [];
        for (let i = 0; i < this.resultList.length; i++) {
            if (this.resultList[i].selected == true) {
                getFilterCount.push(this.resultList[i]);
            }
            this.allDataFromApex.forEach(element => {
                if (element.Id == this.resultList[i].Id) {
                    element.comments = this.resultList[i].comments;
                }
            });
        }

        this.allDataFromApex.forEach(element => {
            if (element.selected == true) {
                selectedClaims.push(element);
            }
        });


        this.totalSelectedRowsCount = selectedClaims.length;
        this.totalSelectedBasedOnBudgetCount = getFilterCount.length;


        if (this.err.length > 0) {
            this.disableBudgetFilter = true;
        } else {
            this.disableBudgetFilter = false;
        }
        var selectedRec = { data: selectedClaims, errors: this.err.length };
        const custEvent5 = new CustomEvent(
            'saveclaimsforrecovery', {
            detail: selectedRec
        });
        this.dispatchEvent(custEvent5);
    }

    showModalBox(event) {
        let key = event.target.dataset.id;
        let tempClaims = this.resultList;
        this.mapData = [];
        this.claimId = key;
        for (let i = 0; i < tempClaims.length; i++) {
            if (tempClaims[i].Id == key) {
                for (let bt in this.resultList[i].recoveryBudAmtMap) {
                    let splitBt = bt.split(';');
                    if ((tempClaims[i].budgetType == 'RSA MD' && tempClaims[i].geo == splitBt[1]) || tempClaims[i].budgetType != 'RSA MD'){
                        this.mapData.push({ value: this.resultList[i].recoveryBudAmtMap[bt], key: bt, budgetType: splitBt[0], geo: splitBt[1]});
                    }
                }
                this.claimAmount = this.resultList[i].claimAmt;
                this.claimRecoveryAmount = this.resultList[i].recoveryAmount;
                this.claimBalanceAmount = this.resultList[i].balanceAmt;
                this.resetClaimRecovery = this.resultList[i].recoveryAmount;
            }
        }
        this.disableSave = true;
        this.isShowModal = true;
    }

    hideModalBox() {
        if (this.resetMapData != '') {
            let claimId = this.claimId;
            let tempClaims = this.resultList;
            for (let i = 0; i < tempClaims.length; i++) {
                if (tempClaims[i].Id == claimId) {
                    tempClaims[i].recoveryAmount = this.resetClaimRecovery;
                    tempClaims[i].balanceAmt = tempClaims[i].recoveryAmount == '' ? '' : (tempClaims[i].claimAmt - tempClaims[i].recoveryAmount).toFixed(2);
                    if (!tempClaims[i].selected) {
                        tempClaims[i].recoveryAmount = '';
                        tempClaims[i].balanceAmt = '';
                    }
                }
            }
            this.resultList = tempClaims;
            this.claimRecoveryMap = [];
        }
        this.showError = false;
        this.isShowModal = false;
    }

    crossRecoveryInputActions(event) {
        let claimId = this.claimId;
        let key = event.target.dataset.name;
        let inputValue = event.target.value;
        let tempClaims = this.resultList;
        var clmIdKeyToValMap = new Map();
        for (let i = 0; i < tempClaims.length; i++) {
            if (tempClaims[i].Id == claimId) {
                let value = inputValue != '' && inputValue >= 0 && inputValue != undefined && inputValue != null ? inputValue : 0;
                if (value >= 0) {
                    var recBudMap = new Map();
                    let sum = 0;
                    if (this.claimRecoveryMap.size > 0) {
                        clmIdKeyToValMap = this.claimRecoveryMap;
                        clmIdKeyToValMap.set(claimId + key, value);
                    } else {
                        clmIdKeyToValMap.set(claimId + key, value);
                    }
                    this.claimRecoveryMap = clmIdKeyToValMap;

                    for (let bt in tempClaims[i].recoveryBudAmtMap) {
                        if (this.claimRecoveryMap.get(claimId + bt) != undefined) {
                            recBudMap[bt] = parseFloat(this.claimRecoveryMap.get(claimId + bt));
                        } else {
                            recBudMap[bt] = this.resultList[i].recoveryBudAmtMap[bt];
                        }

                    }
                    this.claimRecBTAmountMap = recBudMap;


                    for (let bt in recBudMap) {
                        sum += recBudMap[bt];
                    }

                    this.claimRecoveryAmount = sum;
                    this.claimBalanceAmount = (tempClaims[i].claimAmt - sum).toFixed(2);
                    this.showError = false;
                    this.disableSave = false;
                } else {
                    this.disableSave = true;
                }
            }
        }

        this.resultList = tempClaims;

    }

    //saveRecoveryInputs
    saveRecoveryInputs() {
        let claimId = this.claimId;
        let selectedRows = this.template.querySelectorAll('lightning-input');
        let selectedClaims = [];
        let tempClaims = this.resultList;
        for (let i = 0; i < tempClaims.length; i++) {
            if (tempClaims[i].Id == claimId) { 
                if (this.claimBalanceAmount < 0 || this.claimRecoveryAmount < 0) {
                    this.showError = true;
                    this.disableSave = true;
                }else{
                    this.showError = false;
                    this.showSpinner = true;
                    for (let i = 0; i < selectedRows.length; i++) {
                        if (selectedRows[i].type === 'checkbox' && selectedRows[i].dataset.id == claimId && this.claimRecoveryAmount > 0) {
                            selectedRows[i].checked = true;
                            break;
                        }
                    }
                    this.claimRecoveryMap = [];
                    let recAmt = this.claimRecoveryAmount;

                    tempClaims[i].recoveryAmount = parseFloat(recAmt).toFixed(2);
                    tempClaims[i].recoveryBudAmtMap = this.claimRecBTAmountMap;

                    let st = '';
                    for (let bt in tempClaims[i].recoveryBudAmtMap) {
                        st = tempClaims[i].recoveryBudAmtMap[bt] > 0 ? st != '' ? st + ',' + bt + '=' + (tempClaims[i].recoveryBudAmtMap[bt]).toFixed(2) : bt + '=' + (tempClaims[i].recoveryBudAmtMap[bt]).toFixed(2) : st != '' ? st : '';
                    }
                    tempClaims[i].recoveryBudAmt = st;
                    if (tempClaims[i].recoveryAmount == '' || tempClaims[i].recoveryAmount == 0 || tempClaims[i].recoveryAmount < 0) {
                        if (tempClaims[i].cssClassName == 'row-color') {
                            tempClaims[i].selected = true;
                            tempClaims[i].isDisabled = false;
                        } else {
                            tempClaims[i].selected = false;
                            tempClaims[i].righttoRecover = false;
                            tempClaims[i].isDisabled = true;
                        }
                        tempClaims[i].recoveryAmount = '';
                        tempClaims[i].recoveryBudAmt = '';
                        tempClaims[i].balanceAmt = '';
                        break;
                    }
                    //If entered Recovery Amount is valid
                    else if (this.claimRecoveryAmount >= 0) {
                        tempClaims[i].selected = true;
                        tempClaims[i].isDisabled = false;
                        tempClaims[i].balanceAmt = (tempClaims[i].claimAmt - tempClaims[i].recoveryAmount).toFixed(2);
                        if (tempClaims[i].cssClassName == 'row-color') {
                            this.disableBudgetFilter = false;
                            tempClaims[i].cssClassName = '';
                            tempClaims[i].showCustomValidation = false;
                            this.err = this.err.filter(value => value !== tempClaims[i].Id);
                        }                        
                        break;
                    }
                }
            }
        }

        if(!this.showError){
            if (this.err.length > 0) {
                this.disableBudgetFilter = true;
            } else {
                this.disableBudgetFilter = false;
            }
            this.resultList = tempClaims;
            this.totalSelectedRecoveryAmount = 0;
            let getFilterCount = [];
            this.totalRecoveryAmount = 0;

            for (let i = 0; i < this.resultList.length; i++) {
                if (this.resultList[i].selected == true) {
                    getFilterCount.push(this.resultList[i]);
                    if (this.resultList[i].recoveryAmount != '') {
                        if (!isNaN(this.resultList[i].recoveryAmount)) {
                            this.totalRecoveryAmount += parseFloat(this.resultList[i].recoveryAmount);
                        }
                    }
                }

                this.allDataFromApex.forEach(element => {
                    if (element.Id == this.resultList[i].Id) {
                        element.selected = this.resultList[i].selected;
                        element.recoveryAmount = this.resultList[i].recoveryAmount;
                        element.balanceAmt = this.resultList[i].balanceAmt;
                    }
                });
            }

            this.allDataFromApex.forEach(element => {
                if (element.selected == true) {
                    selectedClaims.push(element);
                    if (element.recoveryAmount != '') {
                        if (!isNaN(element.recoveryAmount)) {
                            this.totalSelectedRecoveryAmount += parseFloat(element.recoveryAmount);
                        }
                    }
                }
            });

            this.totalSelectedRowsCount = selectedClaims.length;
            this.totalSelectedBasedOnBudgetCount = getFilterCount.length;

            var selectedRec = { data: selectedClaims, errors: this.err.length };
            const custEvent3 = new CustomEvent(
                'saveclaimsforrecovery', {
                detail: selectedRec
            });
            this.dispatchEvent(custEvent3);
            this.showSpinner = false;
            this.isShowModal = false;                                          
        }        
    }

    rightToRecoverActions(event) {
        let key = event.target.dataset.id;
        let tempClaims = this.resultList;
        let selectedClaims = [];
        for (let i = 0; i < tempClaims.length; i++) {
            if (tempClaims[i].Id == key) {
                tempClaims[i].righttoRecover = event.target.checked;
            }
        }

        this.resultList = tempClaims;
        for (let i = 0; i < this.resultList.length; i++) {
            this.allDataFromApex.forEach(element => {
                if (element.Id == this.resultList[i].Id) {
                    element.righttoRecover = this.resultList[i].righttoRecover;
                }
            });
        }

        this.allDataFromApex.forEach(element => {
            if (element.selected == true) {
                selectedClaims.push(element);
            }
        });

        var selectedRec = { data: selectedClaims, errors: this.err.length };
        const custEvent5 = new CustomEvent(
            'saveclaimsforrecovery', {
            detail: selectedRec
        });
        this.dispatchEvent(custEvent5);
    }
}