/* eslint-disable no-console */
import { LightningElement, wire, track, api } from 'lwc';
import getCriteriaDetails from '@salesforce/apex/PRM_AddPartnerController.getCriteriaDetails';
import insertRelatedRecords from '@salesforce/apex/PRM_AddPartnerController.insertRelatedRecords';
import serachAccs from '@salesforce/apex/PRM_AddPartnerController.fetchAccsData';
import fatchPickListValue from '@salesforce/apex/PRM_AddPartnerController.fetchPickListValue';
import filterAccsData from '@salesforce/apex/PRM_AddPartnerController.filterAccsData';
import fatchAccTypePickListValue from '@salesforce/apex/PRM_AddPartnerController.fetchAccTypePickListValue';
import fatchAccCouPickListValue from '@salesforce/apex/PRM_AddPartnerController.fetchAccCouPickListValue';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Account_Object from '@salesforce/schema/Account';
import fetchTierPickListValue from '@salesforce/apex/PRM_AddPartnerController.fetchTierPickListValue';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import insertApprovalPendingRecords from '@salesforce/apex/PRM_AddPartnerController.insertApprovalPendingRecords';
import fetchPendingData from '@salesforce/apex/PRM_AddPartnerController.fetchPendingData';
import fetchSpCriteriaData from '@salesforce/apex/PRM_AddPartnerController.fetchSpCriteriaData';
import insertApprovalPendingCriteria from '@salesforce/apex/PRM_AddPartnerController.insertApprovalPendingCriteria';
import deleteApprovalPendingRec from '@salesforce/apex/PRM_AddPartnerController.deleteApprovalPendingRec';
import deleteUnselectedSpCrit from '@salesforce/apex/PRM_AddPartnerController.deleteUnselectedSpCrit';
import fetchSpCritRelatedToCurrentSp from '@salesforce/apex/PRM_AddPartnerController.fetchSpCritRelatedToCurrentSp';
import PRM_Error_Msg_OnAddPartnerLabel from '@salesforce/label/c.PRM_Error_Msg_OnAddPartner';
import PRM_ASARecordCreation_SuccessMsg from '@salesforce/label/c.PRM_ASARecordCreation_SuccessMsg';
import PRM_EmptySearchInput_ErrMsg from '@salesforce/label/c.PRM_EmptySearchInput_ErrMsg';
import PRM_InputCharacterLimit_ErrMsg from '@salesforce/label/c.PRM_InputCharacterLimit_ErrMsg';
import PRM_SelectionOfRecLimit_ErrMsg from '@salesforce/label/c.PRM_SelectionOfRecLimit_ErrMsg';
import fetchSpeCritRelToACM from '@salesforce/apex/PRM_AddPartnerController.fetchSpeCritRelToACM';
import fetchCustomSettingValues from '@salesforce/apex/PRM_AddPartnerController.fetchCustomSettingValues';
//import WrapperOfAccIdRoleAndSpCrit from '@salesforce/apex/PRM_AddPartnerController.WrapperOfAccIdRoleAndSpCrit';

const columns = [
    {
        label: 'Account Name',
        fieldName: 'nameUrl',
        type: 'url',
        initialWidth: 270,
        typeAttributes: { label: { fieldName: 'accountName' }, target: '_blank' }
    }, {
        label: 'Account Number',
        fieldName: 'accountNum',
        type: 'text'
    }, {
        label: 'Partner Role',
        fieldName: 'acmpartnerRole',
        type: 'text'
    }, {
        label: 'Tier',
        fieldName: 'channelProgLevelName',
        type: 'text'
    }, {
        label: 'Country',
        fieldName: 'accCountry',
        type: 'text'
    }, {
        label: 'BU Focus',
        fieldName: 'accountBuFocus',
        type: 'text'
    }, {
        label: 'Phone',
        fieldName: 'accountPhoneNo',
        type: 'text'
    },
    {
        label: 'Training Credits',
        fieldName: 'spTrainingCredits',
        type: 'text'
    },
    {
        label: 'Trained Employee Number',
        fieldName: 'noOfTrainedEmployee',
        type: 'text'
    },
];
//AddPartner END
export default class DatatableUpdateExample extends LightningElement {

    //AddPartner START
    @track searchData = [];
    @track columns = columns;
    strSearchAccName = '';
    @track errorMsg = '';
    @track openfilterModel = false;
    @track selectedValue = '';
    @track selectedAccType = '';
    @track selectedCouInput = '';
    @api tierVal = [];
    @api selectedRecordLst = [];
    @track tempSelectedlst = [];
    @track error;
    @track globalMap = new Map();
    @track globalCommentMap = new Map();
    @track globalSuppressEmailMap = new Map();
    @api specialty;
    @api recordId;
    @track confirmscreen = false;
    @track selectedpartnersize;
    @track finalAccounts;
    @track critMap = [];
    @track critListMap = [];
    @track stringValofGlobalCommentMap = [];
    @track stringValofGlobalSuppressEmailMap = [];
    @track singleRecChecked = false;
    @track headercheckboxval = true;
    @track accIdCheckedMap = new Map();
    @track rowData = [];
    @track showSelectPartner = false;
    @track checked = false;
    @track lstcommentschngAccId = [];
    @track lstSuppressEmailchngAccId = [];
    @track size = 0;
    @track selectedrows = [];
    @track showcheckboxInConfSc = false;
    @track disabled = true;
    @track isdisabled = false;
    @api isLoaded = false;
    @track isSearchData = true;
    @track isData = true;
    @track selectedRecordIds = [];
    @track valueOfFormulaValues = '';
    @track isApproved = false;
    @track isApprovePending = false;
    @track finalSelAccounts;
    @track value = [];//for specialty criteria
    @track mapaccIdandSpCrit;
    @track lstaccIdandSpCrit;
    @track isAddPartner = false;
    @track lstOfspCritIdsrelatedToSp = [];
    @track finalSelDataToEport = []; //To export selected list
    @track finalACMIdAndRelSpCritlst = [];
    @track showDownloadButton = false;
    @track lstOfcustsettingValues = [];
    //@track lstOfExistPersData = [];
    //@track allowToInsertSpcrit = false; //to call insertSpCrit method after fetching Exist Persist Partner Records.
    @track lstOfSpCritIdsReltoSp = [];
    // @track isSpinnerLoaded = false;    
    // @track isSpCritSelected = true;
    // @track lstOfWrapperRecToDelete = [];    
    connectedCallback() {
        this.searchData = [];
        this.isSearchData = false;
        //this.isData = false;        
        let finalList = JSON.parse(JSON.stringify(this.selectedRecordLst));
        if (this.selectedRecordLst !== null && this.selectedRecordLst !== undefined && this.selectedRecordLst.length > 0) {
            this.showDownloadButton = true;
            this.isData = true;
        }
        if (this.selectedRecordLst === null || this.selectedRecordLst === undefined || this.selectedRecordLst.length === 0) {
            this.isData = false;
        }
    }
    @wire(fetchCustomSettingValues) custsettingValues({ error, data }) {
        if (data) {
            this.lstOfcustsettingValues = data;
        }
    }
    @wire(fetchPendingData, { currentspecialtyId: '$recordId' }) pendingLst({ error, data }) {
        if (data) {
            let nameUrl;
            this.selectedRecordLst = data.map(row => {
                nameUrl = `/${row.accountId}`;
                return { ...row, nameUrl }
            })
            if (this.selectedRecordLst !== null && this.selectedRecordLst !== undefined && this.selectedRecordLst.length > 0) {
                this.isApprovePending = true;
                this.showSelectPartner = true;
                this.isLoaded = false;
                this.showcheckboxInConfSc = true;
                this.showDownloadButton = true;
                this.isData = true;
            }
            if (this.selectedRecordLst === null || this.selectedRecordLst === undefined || this.selectedRecordLst.length === 0) {
                this.isData = false;
            }
            console.log('PendingData>>', this.isData);
        }
    }

    @wire(fetchSpCriteriaData, { currentspecialtyId: '$recordId' }) spCritLst({ error, data }) {
        if (data) {
            this.lstaccIdandSpCrit = data;

        }
    }
    @wire(fetchSpCritRelatedToCurrentSp, { currentspecialtyId: '$recordId' }) lstSpCritIds({ error, data }) {
        if (data) {
            this.lstOfspCritIdsrelatedToSp = data;
        }
    }

    @wire(getCriteriaDetails, { specialtyId: '$recordId' })
    wiredAccount({ error, data }) {
        if (data) {
            this.specialty = data;
            if (this.specialty !== null && this.specialty !== undefined && this.specialty.length > 0) {
                for (let i = 0; i < this.specialty.length; i++) {
                    if (this.specialty[i].Specialty_Criteria_Associations__r !== undefined && this.specialty[i].Specialty_Criteria_Associations__r.length > 0) {
                        for (let j = 0; j < this.specialty[i].Specialty_Criteria_Associations__r.length; j++) {
                            this.lstOfSpCritIdsReltoSp.push(this.specialty[i].Specialty_Criteria_Associations__r[j].PRM_Criteria_Id__c);
                        }
                    }
                }
            }
            console.log('lstOfSpCritIdsReltoSp>>>', JSON.stringify(this.lstOfSpCritIdsReltoSp));
            this.error = undefined;
            data.forEach(function (item, key) {
            });
        } else if (error) {
            this.error = error;
            this.specialty = undefined;
        }
    }

    confirmPartners() {
        var index;
        this.confirmscreen = true;
        this.showSelectPartner = false;
        this.showcheckboxInConfSc = false;
        this.isdisabled = false;
        //To show header checkbox selected        
        if (this.selectedRecordLst.length > 0 && this.selectedRecordLst !== undefined) {
            this.isData = true;
            this.isApprovePending = false;
        }
        this.selectedpartnersize = this.globalMap.size;
    }

    mapValueChange(event) {
        var mapOfCrit = new Map(event.detail.mapOfAccIdAndspCrit);
        var finalList = [];
        var optionVal = { label: '', value: '' };
        var lstofSpCritId = [];
        var lstOfAccIds = [];
        let lstToDeleteUnselectedSpCrit = [];
        let accIdToDeleteSpCrit;
        let currentPartnerRole;

        for (let accKey of mapOfCrit.keys()) {
            for (let critvalues of mapOfCrit.values()) {
                optionVal.label = accKey;
                optionVal.value = critvalues;
                lstofSpCritId = critvalues;
                lstOfAccIds = accKey;
                this.critMap.push(optionVal);
            }
            this.critListMap = JSON.stringify((this.critMap));
        }
        console.log('critListMap>>>>>>>', JSON.stringify(this.critListMap));
        finalList = JSON.parse(JSON.stringify(this.selectedRecordLst));

        if (this.lstOfspCritIdsrelatedToSp !== undefined && this.lstOfspCritIdsrelatedToSp !== null) {
            if (this.lstOfspCritIdsrelatedToSp.length > 0) {
                for (let h = 0; h < this.lstOfspCritIdsrelatedToSp.length; h++) {
                    if (lstofSpCritId.length > 0) {
                        if (lstofSpCritId.indexOf(this.lstOfspCritIdsrelatedToSp[h]) < 0) {
                            lstToDeleteUnselectedSpCrit.push(this.lstOfspCritIdsrelatedToSp[h]);
                        }
                    }
                    else {
                        lstToDeleteUnselectedSpCrit = this.lstOfspCritIdsrelatedToSp;
                    }
                }
            }
        }
        currentPartnerRole = event.detail.partnerRole;
        accIdToDeleteSpCrit = event.detail.accId;

        insertApprovalPendingCriteria({ lstaccAndAcmRec: finalList, specialtyId: this.recordId, accWithSpecCriteria: this.critListMap })

        if (lstToDeleteUnselectedSpCrit !== undefined && lstToDeleteUnselectedSpCrit !== null) {
            deleteUnselectedSpCrit({ specialtyId: this.recordId, currentaccId: accIdToDeleteSpCrit, partnerRole: currentPartnerRole, spCritId: lstToDeleteUnselectedSpCrit })
        }
    }
    //mapSuppressEmailValueChange
    //mapCommentValueChange

    mapCommentValueChange(event) {
        var mapOfComment = new Map(event.detail);
        for (let accKey of mapOfComment.keys()) {
            this.lstcommentschngAccId.push(accKey);
            for (let commentValues of mapOfComment.values()) {
                this.globalCommentMap.set(accKey, commentValues);
            }
            this.stringValofGlobalCommentMap = JSON.stringify(Array.from(this.globalCommentMap.entries()));
        }
        //alert('globalCommentMap###'+JSON.stringify(this.globalCommentMap));
        //alert('stringValofGlobalCommentMap'+JSON.stringify(this.stringValofGlobalCommentMap));
    }
    mapSuppressEmailValueChange(event) {
        var mapOfSuppressEmail = new Map(event.detail);
        for (let accKey of mapOfSuppressEmail.keys()) {
            this.lstSuppressEmailchngAccId.push(accKey);
            for (let suppressEmailValues of mapOfSuppressEmail.values()) {
                this.globalSuppressEmailMap.set(accKey, suppressEmailValues);
            }
            this.stringValofGlobalSuppressEmailMap = JSON.stringify(Array.from(this.globalSuppressEmailMap.entries()));
        }
        //alert('stringValofGlobalSuppressEmailMap'+JSON.stringify(this.stringValofGlobalSuppressEmailMap));

    }
    mapSuppressEmailValueChange(event) {
        var mapOfSuppressEmail = new Map(event.detail);
        for (let accKey of mapOfSuppressEmail.keys()) {
            this.lstSuppressEmailchngAccId.push(accKey);
            for (let suppressEmailValues of mapOfSuppressEmail.values()) {
                this.globalSuppressEmailMap.set(accKey, suppressEmailValues);
            }
            this.stringValofGlobalSuppressEmailMap = JSON.stringify(Array.from(this.globalSuppressEmailMap.entries()));
        }
        //alert('stringValofGlobalSuppressEmailMap'+JSON.stringify(this.stringValofGlobalSuppressEmailMap));

    }
    
    approvePartners() {
        var optionVal = { label: '', value: '' };
        var message;
        this.isdisabled = true;
        this.isApproved = true;

        if (this.selectedRecordLst !== undefined && this.selectedRecordLst.length > 0) {
            this.finalAccounts = JSON.parse(JSON.stringify(this.selectedRecordLst));

            for (let i = 0; i < this.selectedRecordLst.length; i++) {
                //if record is not handle by event
                if (this.lstcommentschngAccId.length === 0) {
                    this.globalCommentMap.set(this.selectedRecordLst[i].id, '');
                }
                if (this.lstcommentschngAccId.length > 0 && this.lstcommentschngAccId.indexOf(this.selectedRecordLst[i].id) < 0) {
                    this.globalCommentMap.set(this.selectedRecordLst[i].id, '');
                }
                if (this.critListMap.indexOf(this.selectedRecordLst[i].id) < 0) {
                    optionVal.label = this.selectedRecordLst[i].id;
                    optionVal.value = [];
                    this.critMap.push(optionVal);
                }
            }
            this.stringValofGlobalCommentMap = JSON.stringify(Array.from(this.globalCommentMap.entries()));

            for(let i =0; i <this.selectedRecordLst.length; i++){
                if (this.lstSuppressEmailchngAccId.length === 0) {
                    this.globalSuppressEmailMap.set(this.selectedRecordLst[i].id, false);
                }
                if (this.lstSuppressEmailchngAccId.length > 0 && this.lstSuppressEmailchngAccId.indexOf(this.selectedRecordLst[i].id) < 0) {
                    this.globalSuppressEmailMap.set(this.selectedRecordLst[i].id, false);
                }
            }
            this.stringValofGlobalSuppressEmailMap =JSON.stringify(Array.from(this.globalSuppressEmailMap.entries()));

            this.critListMap = JSON.stringify((this.critMap));
            console.log('critListMap?????', JSON.stringify(this.critListMap));
            console.log('lstOfSpCritIdsReltoSp approve>>>', JSON.stringify(this.lstOfSpCritIdsReltoSp));
            //let finallstOfSpCritRelToSp = JSON.stringify(Array.from(this.lstOfSpCritIdsReltoSp));

            insertRelatedRecords({ lstaccIdAndAcm: this.finalAccounts, specialtyId: this.recordId, accCommentsMap: this.stringValofGlobalCommentMap, lstOfTotalSpCritRelSp: this.lstOfSpCritIdsReltoSp,accSuppressEmailMap:this.stringValofGlobalSuppressEmailMap })
                .then(result => {
                    if (result === 'Success') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: PRM_ASARecordCreation_SuccessMsg,
                                variant: 'success',
                            }),
                        );
                        //to display after click on approve
                        this.confirmscreen = false;
                        this.isSearchData = false;
                        this.selectedRecordLst = [];
                        this.searchData = [];
                        this.isData = false;
                    }
                })
                .catch(error => {
                    this.message = undefined;
                    this.error = error;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error while creating record',
                            variant: 'error',
                        }),
                    );
                });
        }
    }

    handleAccountName(event) {
        this.strSearchAccName = event.detail.value;
    }
    handleChangeofValue(event) {
        this.valueOfFormulaValues = event.target.value;
    }

    handleSearch() {
        var result;
        var errMsg;
        this.selectedrows = [];
        this.isLoaded = !this.isLoaded;

        if (!this.strSearchAccName) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: PRM_EmptySearchInput_ErrMsg,
                    variant: 'error',
                }),
            );
            this.searchData = [];
            this.isSearchData = false;
            this.isLoaded = false;
            return;
        }
        if (this.strSearchAccName.length < 3) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: PRM_InputCharacterLimit_ErrMsg,
                    variant: 'error',
                }),
            );
            this.searchData = [];
            this.isSearchData = false;
            this.isLoaded = false;
            return;
        }
        serachAccs({ accountName: this.strSearchAccName, currentspecialtyId: this.recordId })
            .then(returnedResult => {
                if (returnedResult !== null && returnedResult !== undefined && returnedResult.length > 0) {
                    for (let lst = 0; lst < returnedResult.length; lst++) {
                        result = returnedResult[lst].lstofAccAndAcmWrapper;
                        errMsg = returnedResult[lst].errMsg;
                        this.finalSelDataToEport = returnedResult[lst].lstofAccAndAcmWrapper;
                    }
                }
                for (let lst = 0; lst < result.length; lst++) {
                    console.log('Type>>', typeof (result[lst].noOfTrainedEmployee));
                }

                console.log('result:-', JSON.stringify(result));
                if (result !== null && result !== undefined && result.length > 0) {
                    let nameUrl;
                    this.searchData = result.map(row => {
                        nameUrl = `/${row.accountId}`;

                        return { ...row, nameUrl }
                    })

                    if (this.searchData) {
                        this.isSearchData = true;
                        this.isLoaded = false;
                    }
                    this.selectedrows = [];
                    return refreshApex(this.searchData);
                }
                if (errMsg !== null && errMsg !== '' && errMsg !== undefined && errMsg.length > 0) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: PRM_Error_Msg_OnAddPartnerLabel,
                            variant: 'error',
                        }),
                    );
                    this.isLoaded = false;
                    this.searchData = [];
                    this.isSearchData = false;
                }
            })
            .catch(error => {
                this.error = error;
                if (this.error !== undefined || this.error !== '') {
                    console.log('CatchBlockErr', this.error);
                }
                this.isLoaded = false;
                this.searchData = [];
                this.isSearchData = false;
            });
    }
    //US587186:- Method - fatchPickListValue to fetch partner roles related to specialty
    @wire(fatchPickListValue, { currentSpecialtyId: '$recordId' }) partnerRoleValues;

    @wire(fatchAccTypePickListValue, {
        objInfo: { 'sobjectType': 'Account' },
        picklistFieldApi: 'Core_Account_BU_Focus__c'
    }) accTypeValues;

    @wire(fatchAccCouPickListValue, {
        objInfo: { 'sobjectType': 'Account' },
        picklistFieldApi: 'BillingCountryCode'
    }) countryValues;

    @wire(fetchTierPickListValue) TierValues;

    onValueSelection(event) {
        this.selectedValue = event.target.value;
    }

    onAccTypeSelection(event) {
        this.selectedAccType = event.target.value;
    }

    onCountrySelection(event) {
        this.selectedCouInput = event.target.value;
    }
    openfilterModal() {
        if (this.openfilterModel === true) {
            this.openfilterModel = false;
        } else {
            this.openfilterModel = true;
        }

    }

    handleFilter() {
        var result;
        var errMsg;
        this.isLoaded = true;
        if (this.strSearchAccName.length > 0 && this.strSearchAccName.length < 3) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: PRM_InputCharacterLimit_ErrMsg,
                    variant: 'error',
                }),
            );
            this.searchData = [];
            this.isSearchData = false;
            this.isLoaded = false;
            return;
        }
        filterAccsData({ accountName: this.strSearchAccName, partnerRoleValues: this.selectedValue, accType: this.selectedAccType, countryValues: this.selectedCouInput, tierValue: this.valueOfFormulaValues, currentspecialtyId: this.recordId })
            .then(filteredresult => {
                if (filteredresult !== null && filteredresult !== undefined && filteredresult.length > 0) {
                    for (let lst = 0; lst < filteredresult.length; lst++) {
                        result = filteredresult[lst].lstofAccAndAcmWrapper;
                        errMsg = filteredresult[lst].errMsg;
                        this.finalSelDataToEport = filteredresult[lst].lstofAccAndAcmWrapper;
                    }
                }

                if (result !== null && result !== undefined && result.length > 0) {
                    let nameUrl;
                    this.searchData = result.map(row => {
                        nameUrl = `/${row.accountId}`;
                        return { ...row, nameUrl }
                    })
                    if (this.searchData) {
                        this.isSearchData = true;
                        this.isLoaded = false;
                    }
                }
                if (errMsg !== null && errMsg !== '' && errMsg !== undefined && errMsg.length > 0) {

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: PRM_Error_Msg_OnAddPartnerLabel,
                            variant: 'error',
                        }),
                    );
                    this.isLoaded = false;
                    this.searchData = [];
                    this.isSearchData = false;
                }
            })
            .catch(errorMsg => {
                this.errorMsg = errorMsg.body.message;
                console.log('InFilteredcatchBlock');
                this.searchData = [];
                this.isSearchData = false;
                this.isLoaded = false;
            });

    }

    toggleSteps() {
        var finalsellst = new Set();
        var tempIdset = new Set();
        var tempNewlst = [];
        var flag = 0;
        if (this.selectedRecordLst === undefined || this.selectedRecordLst.length < 0) {
            this.selectedRecordLst = [];
            this.isData = false;
        }
        this.showcheckboxInConfSc = true;
        this.tempSelectedlst = this.template.querySelector('lightning-datatable').getSelectedRows();

        if (this.selectedRecordLst.length > 0 && this.selectedRecordLst !== undefined) {
            tempNewlst = this.selectedRecordLst;

            for (let i = 0; i < this.selectedRecordLst.length; i++) {
                finalsellst.add(this.selectedRecordLst[i].id);
            }

            for (let j = 0; j < this.tempSelectedlst.length; j++) {
                tempIdset.add(this.tempSelectedlst[j].id);

                if (finalsellst.has(this.tempSelectedlst[j].id)) {
                    flag = 1;
                }
                else {
                    flag = 0;
                }

                if (flag === 0) {
                    tempNewlst.push((this.tempSelectedlst[j]));
                }
            }
            this.selectedRecordLst = tempNewlst;
        }
        else {
            for (let k = 0; k < this.tempSelectedlst.length; k++) {
                this.selectedRecordLst[k] = this.tempSelectedlst[k];
            }
        }
        if (this.selectedRecordLst.length > 0 && this.selectedRecordLst !== undefined && this.confirmscreen === false) {
            this.showSelectPartner = true;
            this.isData = true;
            this.isApprovePending = false;
        }
        this.size = this.selectedRecordLst.length;
        if (this.tempSelectedlst.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: PRM_SelectionOfRecLimit_ErrMsg,
                    variant: 'error',
                }),
            );
        }

        this.finalSelAccounts = JSON.parse(JSON.stringify(this.selectedRecordLst));

        if (this.selectedRecordLst !== undefined && this.selectedRecordLst.length > 0 && this.isApproved === false) {
            insertApprovalPendingRecords({ lstaccId: this.finalSelAccounts, specialtyId: this.recordId })
        }

        if (this.selectedRecordLst !== null && this.selectedRecordLst !== undefined && this.selectedRecordLst.length > 0) {
            this.showDownloadButton = true;
        }
    }

    handleEvent(event) {
        var j;
        var accIdCheckedMapVal;
        this.accIdCheckedMap = event.detail;

        for (let partnerIDKey of this.accIdCheckedMap.keys()) {
            for (let partnerIDval of this.accIdCheckedMap.values()) {
                accIdCheckedMapVal = partnerIDval;
            }
            //if user unselect record again before delete(true -> false)
            if (accIdCheckedMapVal === false) {
                this.checked = false;
                for (let i = 0; i < this.selectedRecordLst.length; i++) {
                    if (partnerIDKey === this.selectedRecordLst[i].id && this.selectedRecordIds.includes(partnerIDKey)) {
                        j = this.selectedRecordIds.indexOf(partnerIDKey);
                        this.selectedRecordIds.splice(j, 1);
                    }
                }
            }

            if (accIdCheckedMapVal === true) {
                //this.checked = false;
                for (let i = 0; i < this.selectedRecordLst.length; i++) {
                    if (partnerIDKey === this.selectedRecordLst[i].id) {
                        //index = i;
                        this.selectedRecordIds.push(partnerIDKey);
                    }
                }
            }
        }
        if (this.selectedRecordIds.length > 0) {
            this.disabled = false;
            this.isAddPartner = true;
        }
        else {
            this.disabled = true;
            this.isAddPartner = false;
        }
    }

    handleAllCheckboxEvent(event) {
        var hcheckboxVal = event.detail;
        this.headercheckboxval = event.detail;
        this.singleRecChecked = hcheckboxVal;

        if (this.headercheckboxval === true && this.selectedRecordLst.length > 0) {
            this.disabled = false;
            this.isAddPartner = true;
        }
        else {
            this.disabled = true;
            this.isAddPartner = false;
        }
        if (this.headercheckboxval === true) {
            this.selectedRecordIds = [];
            for (let i = 0; i < this.selectedRecordLst.length; i++) {
                this.selectedRecordIds.push(this.selectedRecordLst[i].id);
            }
        } else {
            this.selectedRecordIds = [];
        }
    }
    onClickBack(event) {
        var recordId = [];
        var i;
        this.searchData = [];
        this.isSearchData = false;
        for (i = 0; i < this.selectedRecordLst.length > 0; i++) {
            recordId.push(this.selectedRecordLst[i].id);
        }
        this.confirmscreen = false;
        this.showSelectPartner = true;
        this.showcheckboxInConfSc = true;
        if (this.selectedRecordLst.length !== this.selectedRecordIds.length) {
            this.checked = false;
        }
    }
    deleteRecords(event) {
        var l, m, j;
        var recordIdToDelete = [];
        var lstOfremovalRec = [];
        this.disabled = true;
        this.isAddPartner = false;

        if (this.selectedRecordLst !== undefined && this.selectedRecordIds !== undefined && this.selectedRecordIds.length > 0 && this.selectedRecordLst.length > 0) {
            for (l = 0; l < this.selectedRecordIds.length; l++) {
                for (m = 0; m < this.selectedRecordLst.length; m++) {
                    if (this.selectedRecordIds[l] === this.selectedRecordLst[m].id) {
                        lstOfremovalRec.push(this.selectedRecordLst[m]); //JSON.parse(JSON.stringify());
                        this.selectedRecordLst.splice(m, 1);
                    }
                }
            }
        }
        lstOfremovalRec = JSON.parse(JSON.stringify(lstOfremovalRec));

        if (lstOfremovalRec !== undefined && lstOfremovalRec.length > 0) {
            deleteApprovalPendingRec({ lstOfRemovalAcmRec: lstOfremovalRec, specialtyId: this.recordId })
        }
        this.selectedRecordIds = [];
        this.singleRecChecked = false;
        this.finalACMIdAndRelSpCritlst = [];
    }

    //US554904:-  this method validates the data and creates the csv file to download
    downloadCSVFile() {
        let rowEnd = '\n';
        let csvString = '';
        let rowData = new Set();
        let rowHeaderKeys = new Set();
        let excelRowData = this.selectedRecordLst;
        let value;
        let SpCritVar;

        //Below code is to add Column Header values --->START
        if (this.lstOfcustsettingValues !== null && this.lstOfcustsettingValues !== undefined && this.lstOfcustsettingValues.length > 0) {
            for (let j = 0; j < this.lstOfcustsettingValues.length; j++) {
                SpCritVar = this.lstOfcustsettingValues[j].PRM_SpCritVar__c;
                //Below code is to add Row Column Header keys
                rowHeaderKeys.add(this.lstOfcustsettingValues[j].PRM_AccNameColHeader__c);
                rowHeaderKeys.add(this.lstOfcustsettingValues[j].PRM_AccNumColHeader__c);
                rowHeaderKeys.add(this.lstOfcustsettingValues[j].PRM_AcmPartnerRoleColHeader__c);
                rowHeaderKeys.add(this.lstOfcustsettingValues[j].PRM_ChProgLevelColHeader__c);
                rowHeaderKeys.add(this.lstOfcustsettingValues[j].PRM_AccBuFocusColHeader__c);
                rowHeaderKeys.add(this.lstOfcustsettingValues[j].PRM_SpCritNameColHeader__c);
                rowHeaderKeys.add(this.lstOfcustsettingValues[j].PRM_TrainingCreditsHeader__c);
                rowHeaderKeys.add(this.lstOfcustsettingValues[j].PRM_TrainedEmpNoHeader__c);

                //Below code is to add (selectedRecordLst)Wrapper List Field Name
                rowData.add(this.lstOfcustsettingValues[j].PRM_accountNameVar__c);
                rowData.add(this.lstOfcustsettingValues[j].PRM_accountNumVar__c);
                rowData.add(this.lstOfcustsettingValues[j].PRM_acmpartnerRoleVar__c);
                rowData.add(this.lstOfcustsettingValues[j].PRM_channelProgLevelNameVar__c);
                rowData.add(this.lstOfcustsettingValues[j].PRM_accountBuFocusVar__c);
                rowData.add(this.lstOfcustsettingValues[j].PRM_SpCritVar__c);
                rowData.add(this.lstOfcustsettingValues[j].PRM_TrainingCreditsVar__c);
                rowData.add(this.lstOfcustsettingValues[j].PRM_TrainedEmpNoVar__c);
            }
        }
        console.log('Selected List:-', JSON.stringify(this.selectedRecordLst));
        //Below code is to add Column Header values --->END
        fetchSpeCritRelToACM({ currentspecialtyId: this.recordId }).then(returnedlstResult => {
            this.finalACMIdAndRelSpCritlst = returnedlstResult;
            rowHeaderKeys = Array.from(rowHeaderKeys);
            rowData = Array.from(rowData);
            csvString += rowHeaderKeys.join(',');
            csvString += rowEnd;

            if (this.selectedRecordLst !== null && this.selectedRecordLst !== undefined && this.selectedRecordLst.length > 0 && rowData !== null && rowData !== undefined && rowData.length > 0) {
                for (let i = 0; i < this.selectedRecordLst.length; i++) {
                    let colValue = 0;
                    for (let key in rowData) {
                        if (rowData.hasOwnProperty(key)) {
                            let rowKey = rowData[key];

                            if (colValue > 0) {
                                csvString += ',';
                            }

                            if (rowKey !== SpCritVar) {
                                value = this.selectedRecordLst[i][rowKey] === undefined ? '' : this.selectedRecordLst[i][rowKey];

                            }
                            if (rowKey === SpCritVar && this.finalACMIdAndRelSpCritlst !== null && this.finalACMIdAndRelSpCritlst !== undefined && this.finalACMIdAndRelSpCritlst.length > 0) {
                                let critNameCount = 0;
                                let spCritName = '';
                                for (let m = 0; m < this.finalACMIdAndRelSpCritlst.length; m++) {
                                    if (this.finalACMIdAndRelSpCritlst[m].acmId === this.selectedRecordLst[i].id) {
                                        for (let n = 0; n < this.finalACMIdAndRelSpCritlst[m].spCrit.length; n++) {
                                            if (critNameCount > 0) {
                                                spCritName += ', ';
                                            }
                                            spCritName += this.finalACMIdAndRelSpCritlst[m].spCrit[n];
                                            critNameCount++;
                                        }
                                    }
                                }
                                value = spCritName === undefined ? '' : spCritName;
                            }

                            csvString += '"' + value + '"';
                            value = '';
                            colValue++;
                        }
                    }
                    csvString += rowEnd;
                }
            }
            console.log('csvString: -', csvString);
            let downloadElement = document.createElement('a');
            downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
            downloadElement.target = '_self';
            downloadElement.download = 'Account Data.csv';
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
            downloadElement.click();
        })
    }

    //AddPartner END
}