import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import State_FIELD from '@salesforce/schema/Account.BillingStateCode';
import Country_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAcctResults from "@salesforce/apex/UCD_GenericAcctSearch_SBR.getAcctResults";
import getARQResults from "@salesforce/apex/UCD_GenericAcctSearch_SBR.getAccountRequestQueue";
import Req_Acc_Name from '@salesforce/schema/Account_Create_Request__c.Account_Name__c';
import Alt_Language_Name from '@salesforce/schema/Account_Create_Request__c.Core_Alternate_Language_Name__c';
import Website from '@salesforce/schema/Account_Create_Request__c.Website__c';
import proType from '@salesforce/schema/Account_Create_Request__c.Process_Type__c';
import callSubmitFlow from "@salesforce/apex/UCD_GenericAcctSearch_SBR.callSubmitFlow";
import MandateName_Street from '@salesforce/label/c.UCD_ACM_MandateName_Street';
import CustNameSize from '@salesforce/label/c.UCD_ACM_CustNameSize';
import EnterCountry_State from '@salesforce/label/c.UCD_ACM_EnterCountry_State';
import EnterCountry_State_Website from '@salesforce/label/c.UCD_ACM_EnterCountry_State_Website';
import Note from '@salesforce/label/c.UCD_ACM_Note';
import AccountResults from '@salesforce/label/c.UCD_ACM_AccResults';
import NewAccRequest from '@salesforce/label/c.UCD_ACM_NewAccRequest';

const fields = [Req_Acc_Name, Alt_Language_Name, Website, proType];

const columns = [
    {
        label: 'Account Name',
        fieldName: 'recordUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'accName' },
            target: '_blank'
        },
        initialWidth: 170,
        sortable: 'true',
    },
    { label: 'Unified Hierarchy', fieldName: 'unifiedHierarchy', initialWidth: 150, sortable: 'true', },
    { label: 'Unified Id', fieldName: 'bpId', initialWidth: 150, sortable: 'true', },
    { label: 'Unified Customer Type', fieldName: 'customerAggregationCode', initialWidth: 170, sortable: 'true', },
    { label: 'Address', fieldName: 'address', initialWidth: 170, sortable: 'true', },
    { label: 'Unified Customer URL', fieldName: 'Website', initialWidth: 160, sortable: 'true', },
    { label: 'Associated Unified Global', fieldName: 'unifiedGlobalCustomer', initialWidth: 150, sortable: 'true', },
    { label: 'Sales group', fieldName: 'salesGroupCode', initialWidth: 150, sortable: 'true', },
    { label: 'Account Owner', fieldName: 'accOwner', initialWidth: 150, sortable: 'true', },
    { label: 'Requested Name', fieldName: 'requestedName', initialWidth: 150, sortable: 'true', },
];

const queueColumns = [
    {
        label: 'Name',
        fieldName: 'ARQUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        },
        initialWidth: 500,
    },
    { label: 'Account Name', fieldName: 'Account_Name__c', initialWidth: 540, },
    { label: 'Status', fieldName: 'Status__c', initialWidth: 530, }
];

export default class SearchAccountScreen1 extends NavigationMixin(LightningElement) {
    // All Variables
    @track data = [];
    tableData = [];
    @track treeItems = [];
    @track filteredTreeItems = []; // used for displaying filtered data
    @track accountNameSearchKey = ''; // for inner search box
    columns = columns;
    queueColumns = queueColumns;
    @track _recordId;
    @track checkBoxFieldValue = false;
    @track setSelectedRows = [];
    @track accountRequestQueueData = [];
    @track arqItems = [];
    @track arqVisibleItems = [];
    arqRecordCount = 20;
    arqTotalCount = 0;
    arqTargetDatatable;
    @track showpagination = false;
    @track error = false;
    @track isValidUser = true;
    @track isOpportunity = false;
    @track isOther = false;
    @track noAccessToObject = false;
    @track stateFieldData;
    @track countryOptions;
    @track stateOptions;
    @track searchAccountData = {
        customerName: '',
        customerWebsite: '',
        nonLatin: '',
        addLine1: '',
        addLine2: '',
        city: '',
        countryCode: '',
        stateCode: '',
        zipCode: '',
        cpe: '',
        country: '',
        state: '',
        street: ''
    }
    @track searchValuesList = [];
    @track loaded = false;
    @track showModalLoading = false;
    @track openDupComp = false;
    @track disableNext = true;
    @track disableReUse = true;
    @track recordsCount = 0;
    @track selectedRecords = [];
    @track selectedRecordsData
    @track isShowModal = false;
    @track value;

    @track cpeOptions = [];
    lstCPESelected = [];
    processType;

    @track customerName;
    @track customerWebsite;
    @track countryCode;
    @track stateCode;
    @track country;
    @track state;
    @track preSelectedRows = [];
    @track street;
    sortDirection;
    sortedBy;
    items = [];
    recordCount = 20;
    loadMoreStatus;
    totalRecountCount = 0;
    targetDatatable;
    labels = { Note, AccountResults, NewAccRequest };

    @api acctreasontrail;
    @api isRecordPage;
    @api intelRecordTypeId;
    showBIReport = false;
    @api pageReference;
    biReportLink = "https://app.powerbi.com/groups/me/apps/67a2d052-62f9-429a-920f-3a8b604b3636/reports/a5c230b9-bbe8-4197-9b87-0a4c461aea4b/ReportSectiond4cc39bb0d6879b59919?experience=power-bi&clientSideAuth=0";

    // Wire Methods
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    AccountInfo;
    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: Country_FIELD })
    countryFieldInfo({ data, error }) {

        if (data) {
            this.countryOptions = JSON.parse(JSON.stringify(data.values));
            const noneCountry = { "attributes": null, "label": "--None--", "validFor": [], "value": "None" };
            this.countryOptions.unshift(noneCountry);
            console.log('countryOptions', JSON.stringify(data.values));
            console.log('countrytry', this.countryOptions);

        }
    }

    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: State_FIELD })
    stateFieldInfo(result) {
        // this.stateFieldData = JSON.stringify(result.values);
        this.stateFieldData = result;
        console.log('stateFieldData', this.stateFieldData.values);

    }


    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    accountReq({ error, data }) {
        if (data != undefined) {
            this.customerName = data.fields.Account_Name__c.value;
            this.processType = data.fields.Process_Type__c.value;
            console.log('processType' + this.processType);
        }

    }

    @wire(CurrentPageReference)
    pageReference;

    connectedCallback() {
        if (this.pageReference) {
            if (this.pageReference.type === 'standard__recordPage') {
                this.showBIReport = true;
            }
        }
        console.log('this.acctreasontrail' + this.acctreasontrail);
    }

    @wire(getObjectInfo, { objectApiName: 'Account_Create_Request__c' })
    objectInfo({ error, data }) {
        if (data) {

            //
        }
    }

    @api get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this.setAttribute('recordId', value);

        this._recordId = value;
    }

    // 
    textInputChangeHandler(event) {
        if (!this.isRecordPage) {
            if (event.target.name == 'name') {
                this.searchAccountData.customerName = event.target.value;
            }
            if (event.target.name == 'website') {
                this.searchAccountData.customerWebsite = event.target.value;
            }
            if (event.target.name == 'nonLatin') {
                this.searchAccountData.nonLatin = event.target.value;
            }
            if (event.target.name == 'addLine1') {
                this.searchAccountData.addLine1 = event.target.value;
            }
            if (event.target.name == 'addLine2') {
                this.searchAccountData.addLine2 = event.target.value;
            }
            if (event.target.name == 'country') {
                this.countryCode = event.target.value;
            }
            if (event.target.name == 'state') {
                this.stateCode = event.target.value;
            }
            if (event.target.name == 'city') {
                this.searchAccountData.city = event.target.value;
            }
            if (event.target.name == 'zipCode') {
                this.searchAccountData.zipCode = event.target.value;
            }
            if (event.target.name == 'street') {
                this.searchAccountData.street = event.target.value;
            }
        } else {
            if (event.target.name == 'name') {
                this.customerName = event.target.value;
            }
            if (event.target.name == 'website') {
                this.customerWebsite = event.target.value;
            }
            if (event.target.name == 'country') {
                this.countryCode = event.target.value;
            }
            if (event.target.name == 'state') {
                this.stateCode = event.target.value;
            }
            if (event.target.name == 'street') {
                this.street = event.target.value;
            }
        }

    }

    isRowSelected(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            this.recordsCount = event.detail.selectedRows.length;
            if (this.recordsCount > 0) {
                if (this.recordsCount > 1) {
                    let selectedKey;
                    const accId = this.selectedRecords[0].accId;

                    selectedRows.forEach(function (element) {
                        if (accId !== element.accId) {
                            selectedKey = element;
                        }
                    });

                    const selectedCheckbox = [];
                    selectedCheckbox.push(selectedKey.accId);
                    this.preSelectedRows = selectedCheckbox;
                    this.selectedRecords = [];
                    this.selectedRecords.push(selectedKey);
                    event.preventDefault();
                    return;
                } else if (this.recordsCount == 1) {
                    this.selectedRecords = selectedRows;
                    this.disableReUse = false;
                }
            } else {
                this.disableReUse = true;
            }
        } else {
            this.disableReUse = true;
        }
    }

    reuseClickHandler(event) {
        this.isShowModal = true;
        this.lstCPESelected = [];
        this.cpeOptions = [];
        this.selectedRecordsData = this.selectedRecords[0];
    }
    handleCPEChange(event) {
        this.lstCPESelected = event.detail.value;
    }

    handleBackButtonClick(event) {
        this.isShowModal = false;
        this.lstCPESelected = [];
        this.cpeOptions = [];
    }
    handleSubmit(event) {
        this.showModalLoading = true;
        callSubmitFlow({
            recordId: this._recordId,
            accId: this.selectedRecordsData.accId,
            accName: this.selectedRecordsData.accName,
            accBpId: this.selectedRecordsData.bpId,
            // accCustomerType:this.selectedRecordsData.customerAggregationCode,
            // accCPE:this.selectedRecordsData.cpe,
            // selectedCPE:JSON.stringify(this.lstCPESelected)
        })
            .then((response) => {
                if (response) {
                    this.showModalLoading = false;
                    this.isShowModal = false;
                    this.showSuccessToast('Success', 'Submit Record Successfully!')
                    window.location.reload();
                }
            })
            .catch((error) => {
                //console.log(error);
            });
    }

    pickListChangeHandler(event) {
        if (!this.isRecordPage) {
            if (event.target.name == 'country') {
                this.searchAccountData.country = this.countryOptions.find(opt => opt.value === event.detail.value).label;
                this.searchAccountData.countryCode = event.target.value;
                this.searchAccountData.stateCode = '';
                this.searchAccountData.state = '';
                const key = this.stateFieldData.data.controllerValues[event.target.value];
                this.stateOptions = this.stateFieldData.data.values.filter(opt => opt.validFor.includes(key));
                const noneState = { "attributes": null, "label": "--None--", "validFor": [222], "value": "None" };
                this.stateOptions.unshift(noneState);

                console.log('this.stateOptions', this.stateOptions);
            }
            if (event.target.name == 'state') {
                this.searchAccountData.stateCode = event.target.value;
                this.searchAccountData.state = this.stateOptions.find(opt => opt.value === event.detail.value).label;
            }
        } else {
            if (event.target.name == 'country') {
                this.country = this.countryOptions.find(opt => opt.value === event.detail.value).label;
                this.countryCode = event.target.value;
                this.stateCode = '';
                this.state = '';
                const key = this.stateFieldData.data.controllerValues[event.target.value];
                this.stateOptions = this.stateFieldData.data.values.filter(opt => opt.validFor.includes(key));
                const noneState = { "attributes": null, "label": "--None--", "validFor": [222], "value": "None" };
                this.stateOptions.unshift(noneState);

                console.log('country' + this.countryCode);
            }
            if (event.target.name == 'state') {
                this.stateCode = event.target.value;
                this.state = this.stateOptions.find(opt => opt.value === event.detail.value).label;
            }
        }

    }

    // Seach Button
    searchClickHandler(event) {
        this.disableNext = true;
        this.searchValuesList = [];
        this.items = [];
        this.treeItems = [];
        this.error = false;
        this.loaded = true;
        this.openDupComp = false;
        this.recordCount = 20;
        this.totalRecountCount = 0;
        this.sortDirection = '';
        this.sortedBy = '';
        console.log('country value' + this.searchAccountData.country);
        if (!this.isRecordPage) {
            if ((this.searchAccountData.customerName == '' || this.searchAccountData.customerName == undefined || this.searchAccountData.customerName == null || !this.searchAccountData.customerName.trim()) && (this.searchAccountData.street == '' || this.searchAccountData.street == undefined || this.searchAccountData.street == null || !this.searchAccountData.street.trim())) {

                this.error = true;
                this.loaded = false;
                this.showToastMessage(MandateName_Street, "error", "dismissable");

            } else if ((this.searchAccountData.customerName.trim().length < 2) && !(this.searchAccountData.customerName == '' || this.searchAccountData.customerName == undefined || this.searchAccountData.customerName == null || !this.searchAccountData.customerName.trim())) {

                this.error = true;
                this.loaded = false;
                this.showToastMessage(CustNameSize, "error", "dismissable");

            } else if (((this.searchAccountData.street != '' && this.searchAccountData.street != undefined && this.searchAccountData.street != null) &&
                ((this.searchAccountData.countryCode == '' || this.searchAccountData.countryCode == undefined || this.searchAccountData.countryCode == 'None')
                ))) {
                this.error = true;
                this.loaded = false;
                this.showToastMessage(EnterCountry_State, "error", "dismissable");

            } else if (((this.searchAccountData.customerName != '' || this.searchAccountData.customerName != undefined) || (this.searchAccountData.street != '' || this.searchAccountData.street != undefined)) &&
                ((this.searchAccountData.customerWebsite == '' || this.searchAccountData.customerWebsite == undefined ||
                    this.searchAccountData.customerWebsite == null || !this.searchAccountData.customerWebsite.trim()) &&
                    (this.searchAccountData.countryCode == '' || this.searchAccountData.countryCode == undefined || this.searchAccountData.countryCode == 'None') &&
                    (this.searchAccountData.stateCode == '' || this.searchAccountData.stateCode == undefined || this.searchAccountData.stateCode == 'None'))) {

                this.error = true;
                this.loaded = false;
                this.showToastMessage(EnterCountry_State_Website, "error", "dismissable");

            } else {
                if (this.searchAccountData.countryCode == 'None') {

                    this.searchAccountData.country = '';
                }
                if (this.searchAccountData.stateCode == 'None') {

                    this.searchAccountData.state = '';
                }


                if (this.searchAccountData) {
                    this.addSearchValues('Name', 'Name', this.searchAccountData.customerName);
                    this.addSearchValues('Core_Data_Simplified_Account_Nm__c', 'Core_Data_Simplified_Account_Nm__c', this.searchAccountData.customerName);
                    this.addSearchValues('Core_Data_Simplified_Local_Language_Nm__c', 'Core_Data_Simplified_Local_Language_Nm__c', this.searchAccountData.customerName);
                    this.addSearchValues('Core_Alternate_Language_Name__c', 'Alternate Language Name', this.searchAccountData.customerName);
                    this.addSearchValues('Core_Requested_Name__c', 'Core_Requested_Name__c', this.searchAccountData.customerName);
                    this.addSearchValues('BillingCity', 'BillingCity',);
                    this.addSearchValues('BillingAddress', 'BillingAddress',);
                    this.addSearchValues('Website', 'Website', this.searchAccountData.customerWebsite);
                    this.addSearchValues('Core_MDM_Website__c', 'Core_MDM_Website__c', this.searchAccountData.customerWebsite);
                    this.addSearchValues('Core_User_Defined_Website__c', 'Core_User_Defined_Website__c', this.searchAccountData.customerWebsite);
                    this.addSearchValues('BillingCountry', 'BillingCountry', this.searchAccountData.country);
                    this.addSearchValues('BillingState', 'BillingState', this.searchAccountData.state);
                    this.addSearchValues('BillingStreet', 'BillingStreet', this.searchAccountData.street);
                    this.addSearchValues('BillingPostalCode', 'BillingPostalCode',);
                    this.addSearchValues('RecordType.Name', 'Account Record Type',);
                    this.addSearchValues('Owner.Name', 'Account Owner',);
                    this.addSearchValues('Core_Customer_Aggregation_Type__c', 'Customer Aggregation Type',);
                    this.addSearchValues('Core_Unified_Global_Customer_Name__c', 'Global Customer',);
                    //this.addSearchValues('Core_CIM_ID__c','CIM ID',);
                    this.addSearchValues('Core_Sales_Groups__c', 'Sales Group',);


                    console.log('addSearchValues' + this.addSearchValues);
                }
            }
        } else {
            console.log('country value' + this.countryCode);
            if ((this.customerName == '' || this.customerName == undefined || this.customerName == null || !this.customerName.trim()) && (this.street == '' || this.street == undefined || this.street == null || !this.street.trim())) {
                this.error = true;
                this.loaded = false;
                this.showToastMessage(MandateName_Street, "error", "dismissable");

            } else if (((this.street != '' && this.street != undefined && this.street != null) &&
                ((this.countryCode == '' || this.countryCode == undefined || this.countryCode == 'None')
                ))) {
                this.error = true;
                this.loaded = false;
                this.showToastMessage(EnterCountry_State, "error", "dismissable");

            } else if (((this.customerName != '' || this.customerName != undefined) || (this.street != '' || this.street != undefined)) &&
                ((this.customerWebsite == '' || this.customerWebsite == undefined ||
                    this.customerWebsite == null || !this.customerWebsite.trim()) &&
                    (this.countryCode == '' || this.countryCode == undefined || this.countryCode == 'None') &&
                    (this.stateCode == '' || this.stateCode == undefined || this.stateCode == 'None'))) {

                this.error = true;
                this.loaded = false;
                this.showToastMessage(EnterCountry_State_Website, "error", "dismissable");

            } else {

                if (this.countryCode == 'None') {
                    this.country = '';
                }
                if (this.stateCode == 'None') {
                    this.state = '';
                }


                this.disableReUse = true;
                this.acctreasontrail = this.processType;
                console.log('processType' + this.processType);

                this.addSearchValues('Name', 'Name', this.customerName);
                this.addSearchValues('Core_Data_Simplified_Account_Nm__c', 'Core_Data_Simplified_Account_Nm__c', this.customerName);
                this.addSearchValues('Core_Data_Simplified_Local_Language_Nm__c', 'Core_Data_Simplified_Local_Language_Nm__c', this.customerName);
                this.addSearchValues('Core_Alternate_Language_Name__c', 'Core_Alternate_Language_Name__c', this.customerName);
                this.addSearchValues('Core_Requested_Name__c', 'Core_Requested_Name__c', this.customerName);
                this.addSearchValues('BillingCity', 'BillingCity',);
                this.addSearchValues('BillingAddress', 'BillingAddress',);
                this.addSearchValues('Website', 'Website', this.customerWebsite);
                this.addSearchValues('Core_MDM_Website__c', 'Core_MDM_Website__c', this.customerWebsite);
                this.addSearchValues('Core_User_Defined_Website__c', 'Core_User_Defined_Website__c', this.customerWebsite);
                this.addSearchValues('BillingCountry', 'BillingCountry', this.country);
                this.addSearchValues('BillingState', 'BillingState', this.state);
                this.addSearchValues('BillingStreet', 'BillingStreet', this.street);
                this.addSearchValues('BillingPostalCode', 'BillingPostalCode',);
                this.addSearchValues('RecordType.Name', 'Account Record Type',);
                this.addSearchValues('Owner.Name', 'Account Owner',);
                this.addSearchValues('Core_Customer_Aggregation_Type__c', 'Customer Aggregation Type',);
                this.addSearchValues('Core_Unified_Global_Customer_Name__c', 'Global Customer',);
                //this.addSearchValues('Core_CIM_ID__c','CIM ID',);
                this.addSearchValues('Core_Sales_Groups__c', 'Sales Group',);
            }

        }
        if (!this.error) {
            if (this.searchValuesList) {
                console.log('acctreasontrailsearch', +this.acctreasontrail);
                console.log('searchValuesList', +this.searchValuesList);
                getAcctResults({
                    fDetails: this.searchValuesList,
                    requestReason: this.acctreasontrail
                })
                    .then((response) => {
                        this.data = response.accountSearchModel;
                        if (this.data.length > 0) {

                            const tempjson = JSON.parse(JSON.stringify(this.data).split('childAccounts').join('_children'))

                            //this.items = [...this.items, ...tempjson];

                            this.items = tempjson;
                            this.totalRecountCount = this.items.length;
                            this.treeItems = this.items.slice(0, this.recordCount);
                            this.filteredTreeItems = [...this.treeItems]; // initialize filtered data
                            this.loaded = false;
                            this.showpagination = true;
                        } else {
                            this.showpagination = false;
                            this.loaded = false;
                        }
                        this.openDupComp = true;
                    }).catch((error) => {
                        this.showpagination = false;
                        this.loaded = false;
                        this.openDupComp = true;
                    });
            }
        }
        getARQResults({ fDetails: this.searchValuesList })
            .then(result => {
                console.log('Queue result:', result);
                const processed = result.map(row => ({
                    ...row,
                    ARQUrl: `/lightning/r/AccountRequestQueue__c/${row.Id}/view`
                }));
                this.arqItems = processed;
                this.arqTotalCount = this.arqItems.length;
                this.arqVisibleItems = this.arqItems.slice(0, this.arqRecordCount);
            })
            .catch(error => {
                console.error('Error fetching queue:', error);
            });


    }
    onchangeHandleSearch(event) {
        window.clearTimeout(this.debounceTimeout);
        // Save the new value
        const inputValue = event.target.value?.toLowerCase() || '';
        // Set a new timeout to run after 500ms
        this.debounceTimeout = setTimeout(() => {
            this.accountNameSearchKey = inputValue;
            this.applyInnerFilter();
        }, 500);
    }

    applyInnerFilter() {
        if (this.accountNameSearchKey && this.accountNameSearchKey.trim().length > 0) {
            this.filteredTreeItems = this.treeItems.filter(item => {
                const accNameMatch = item.accName && item.accName.toLowerCase().includes(this.accountNameSearchKey);
                const addressMatch = item.address && item.address.toLowerCase().includes(this.accountNameSearchKey);
                return accNameMatch || addressMatch;
            });
        } else {
            this.filteredTreeItems = [...this.treeItems];
        }
    }


    clearClickHandler(event) {
        this.searchAccountData.customerName = '';
        this.searchAccountData.customerWebsite = '';
        this.searchAccountData.countryCode = '';
        this.searchAccountData.stateCode = '';
        this.searchAccountData.country = '';
        this.searchAccountData.state = '';
        this.searchAccountData.street = '';
        this.customerName = '';
        this.customerWebsite = '';
        this.countryCode = '';
        this.stateCode = '';
        this.stateOptions = [];
        this.street = '';
    }

    addSearchValues(fieldAPINameP, fieldLabelP, fieldValueP) {
        const searchValues = {
            fieldAPIName: fieldAPINameP,
            fieldLabel: fieldLabelP,
            fieldValue: fieldValueP
        };
        this.searchValuesList.push(searchValues);
    }

    // Toast messages for all scenarios
    showToastMessage(message, variant, mode) {
        const evt = new ShowToastEvent({
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
    onNextClickHandler(event) {
        if (this.checkBoxFieldValue) {
            const acctSearchNextClick = new CustomEvent("acctsearchnextclick", { detail: this.searchAccountData });
            this.dispatchEvent(acctSearchNextClick);
        } else {
            alert('Work in progress');
        }
    }
    handleCheckBoxChange(event) {
        this.checkBoxFieldValue = event.target.checked;
        if (this.checkBoxFieldValue) {
            this.disableNext = false;

            if (this.tableData.length > 0) {
                const row = this.template.querySelector("lightning-datatable").getSelectedRows();
                this.setSelectedRows = [];
            }
        } else {
            this.disableNext = true;
        }
    }

    showSuccessToast(title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    /*
    onNewAccountClick(event) {
            const config = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'new'
            },
            state: {
                count: '1',
                nooverride: '1',
                useRecordTypeCheck: '1',
                recordTypeId: this.intelRecordTypeId,
            }
        }
        this[NavigationMixin.Navigate](config);
    }*/

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.treeItems];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'desc' ? 1 : -1));
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.treeItems = cloneData;
        this.applyInnerFilter();
        this.sortDirection = sortDirection;
        this.sortedBy = event.detail.fieldName;
    }

    sortBy(field, reverse, primer) {
        const keyValue = primer
            ? function (a) { return primer(a[field]); }
            : function (a) { return a[field]; };

        return function (a, b) {
            const aValue = keyValue(a) ? keyValue(a) : '';
            const bValue = keyValue(b) ? keyValue(b) : '';

            // Handling null or undefined values
            if (aValue == null && bValue == null) { return 0 };
            if (aValue == null) { return 1 };
            if (bValue == null) { return -1 };

            // Special handling for 'recordUrl' field
            if (field === 'recordUrl') {
                // Sort alphabetically if field is 'recordUrl'
                field = 'accName';
                return reverse ? aValue.localeCompare(bValue) : bValue.localeCompare(aValue);

            }

            // Non-empty values should come on top
            if (aValue !== '' && bValue === '') { return reverse ? -1 : 1 };
            if (aValue === '' && bValue !== '') { return reverse ? 1 : -1 };

            // Compare non-null, non-empty values
            if (reverse == 1) {
                return reverse ? (aValue > bValue) - (bValue > aValue) : (bValue > aValue) - (aValue > bValue);
            }
            else {
                return reverse * ((aValue > bValue) - (bValue > aValue));
            }
        };
    }

    loadMoreData(event) {
        event.preventDefault();
        if (this.recordCount < this.totalRecountCount) {
            // increase the record Count by 20 on every loadmore event
            this.recordCount = this.recordCount + 20;
            //Display a spinner to signal that data is being loaded
            event.target.isLoading = true;
            //Set the onloadmore event taraget to make it visible to imperative call response to apex.
            this.targetDatatable = event.target;
            //Display "Loading" when more data is being loaded
            this.treeItems = this.items.slice(0, this.recordCount);
            this.filteredTreeItems = [...this.treeItems]; // reset filter
            this.targetDatatable.isLoading = false;
            //this.loadMoreStatus = false;
            // Get new set of records and append to this.data
            //this.getRecords();
            const onSortEvent = new CustomEvent("onSortEvent", {
                detail: {
                    fieldName: this.sortedBy,
                    sortDirection: this.sortDirection
                }
            });
            this.onHandleSort(onSortEvent);
        }
        else {
            event.target.isLoading = false;
        }
    }

    loadMoreARQData(event) {
        event.preventDefault();
        if (this.arqRecordCount < this.arqTotalCount) {
            this.arqRecordCount += 20;
            event.target.isLoading = true;
            this.arqTargetDatatable = event.target;

            this.arqVisibleItems = this.arqItems.slice(0, this.arqRecordCount);

            this.arqTargetDatatable.isLoading = false;
        } else {
            event.target.isLoading = false;
        }
    }

    getRecords() {
        this.recordCount = (this.recordCount > this.totalRecountCount) ? this.totalRecountCount : this.recordCount;
        this.treeItems = this.items.slice(0, this.recordCount);
        this.loadMoreStatus = '';
        if (this.targetDatatable) {
            this.targetDatatable.isLoading = false;
        }
    }
    get setDatatableHeight() {
        if (this.totalRecountCount > 10) {
            return 'height:500px';
        }
        return 'height: auto';
    }
    get showAccountNoResults() {
        return this.arqVisibleItems.length > 0 && this.treeItems.length === 0;
    }
    get showArqNoResults() {
        return this.arqVisibleItems.length === 0;
    }
    get showCombinedNoResults() {
        return this.arqVisibleItems.length === 0 && this.treeItems.length === 0;
    }
    get showArqOnly() {
        return this.treeItems.length > 0 || this.arqVisibleItems.length > 0;
    }
    get setARQDatatableHeight() {
        return this.arqTotalCount > 10 ? 'height: 500px;' : 'height: auto;';
    }

}