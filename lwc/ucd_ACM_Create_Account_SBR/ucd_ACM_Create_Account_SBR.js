import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { createRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import User_Name from '@salesforce/schema/User.Name';
import User_Email from '@salesforce/schema/User.Email';
import User_WWID from '@salesforce/schema/User.Core_WWID__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import ACCOUNT_CREATE_REQUEST_OBJECT from '@salesforce/schema/Account_Create_Request__c';
import Country_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import State_FIELD from '@salesforce/schema/Account.BillingStateCode';
import Intel_Led_Label from '@salesforce/label/c.UCD_Intel_Led_Label';
import Partner_Led_Label from '@salesforce/label/c.UCD_Partner_Led_Label';
import Other_Led_Label from '@salesforce/label/c.UCD_Other_Led_Label';
import Not_Covered_Label from '@salesforce/label/c.UCD_Not_Covered_Label';
import checkForDuplicates from "@salesforce/apex/UCD_GenericAcctSearch_SBR.checkForDuplicates";
import addressVerification from "@salesforce/apex/UCD_ACM_AICleansedAddress.addressVerification";
import userFields from "@salesforce/apex/UCD_GenericAcctSearch_SBR.userFields";
import WarningLabel from "@salesforce/label/c.UCD_UserSearchError";
import UCD_ACM_Intel_Covered_Undefined_SalesGroup from '@salesforce/label/c.UCD_ACM_Intel_Covered_Undefined_SalesGroup';
import UCD_ACM_Intel_Covered_NotPartnerLed_SalesGroup from '@salesforce/label/c.UCD_ACM_Intel_Covered_NotPartnerLed_SalesGroup';
import UCD_ACM_Intel_Covered_PartnerLed_SalesGroup from '@salesforce/label/c.UCD_ACM_Intel_Covered_PartnerLed_SalesGroup';
import getCountryRegion from '@salesforce/apex/CountryReferenceController.getCountryRegion';

const accRequestColumns = [
    { label: 'ARQ ID', fieldName: 'recordUrl', type: 'url', typeAttributes: { label: { fieldName: 'acctRequestId' }, target: '_blank' } },
    { label: 'Requested Name', fieldName: 'customername', },
    { label: 'Requested Address', fieldName: 'acctRequestCountry' },
    { label: 'Requested Date', fieldName: 'createdDate' },
    { label: 'Requested by User Name', fieldName: 'requestorName' },
    { label: 'Requested Reason Type', fieldName: 'processType' }
];

const acctColumns = [
    { label: 'Account ID', fieldName: 'recordacctId', type: 'url', typeAttributes: { label: { fieldName: 'acctId' }, target: '_blank' } },
    { label: 'Account Name', fieldName: 'accountName', },
    { label: 'Account Address', fieldName: 'accountCountry' },
    { label: 'Account Owner', fieldName: 'acctOwner' },
    { label: 'Unified Global Customer Name', fieldName: 'unifiedGlobalCustomerName' }
];

export default class ucd_ACM_Create_Account_SBR extends NavigationMixin(LightningElement) {

    @track loaded = false;
    @track errorMsg;
    @track permissionErrorCode = 0;
    @track submitError;
    @track errorList;
    @track UserName;
    @track UserEmail;
    @track UserWWID;
    @track OwnerId;
    @track RequestorUser;
    @track disabledDigital = true;
    @track disabledLocalLang = true;
    @track spinLoad = false;
    @track stateFieldData;
    @track accountLevel = '';
    @track accountcategory = '';
    @track disableUmbrellaGroup = false;
    accountName = '';
    alternateLanName = '';
    @track accountNameLocalLan = '';
    digitalIdentifier = '';
    digitalIdentifierVal = '';
    industry = '';
    subIndustry = '';
    salesGrp = '';
    taxId = '';
    @track accountcoverage = 'Not Covered';
    @track option1;
    @track option2;
    @track option3;
    @track option4 = false;
    @track isUmbrellaGroupRequired = false;
    label = {
        Intel_Led_Label,
        Partner_Led_Label,
        Other_Led_Label,
        Not_Covered_Label,
        UCD_ACM_Intel_Covered_Undefined_SalesGroup,
        UCD_ACM_Intel_Covered_NotPartnerLed_SalesGroup,
        UCD_ACM_Intel_Covered_PartnerLed_SalesGroup
    };
    globalAccount = '';
    @track state = "";
    @track stateOpt = '';
    @track province = '';
    isError = false;

    loader(event) {
        this.loaded = true;
    }

    @track countryOptions;
    @track stateOptions;
    @track addressAddress = {
        Street: '',
        City: '',
        province: '',
        postalCode: '',
        Country: '',
        stateCode: ''
    }
    @track addressCountryAndState = {
        countryName: '',
        stateName: ''
    }
    @track showDuplicates = false;
    @track accountDuplicate = false;
    @track accountRequestDuplicate = false;
    @track duplicates = [];
    @track cleansedAddress = {};
    @track userEnteredAddress = {};
    @track selectedAddressOption = null;
    @track showModal = false;
    @track showAddress = false;
    //@track disableProceed=false;
    accRequestColumns = accRequestColumns;
    acctColumns = acctColumns;
    @api acctformdetails;
    @api acctreasontrail;
    @api objectApiName = "Account";
    @track fields;
    get options() {
        return [
            { label: 'Submit Request for Self', value: false },
            { label: 'Submit Request for Others', value: true },
        ];
    }
    @track selected = false;
    @track selected1 = false;
    userselection;
    @track displaySalesgroup = false;
    isOpenModal = false;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    AccountInfo;
    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: State_FIELD })
    /* stateFieldInfo(result) {
            this.stateFieldData = result;
    } */
    stateFieldInfo({ data, error }) {
        if (data) {
            // this.stateOptions = data.values;
            this.stateOptions = '';
            this.stateFieldData = data;
        }
    }
    get getStateOptions() {
        return this.stateOptions;
    }

    @wire(getPicklistValues, { recordTypeId: '$AccountInfo.data.defaultRecordTypeId', fieldApiName: Country_FIELD })
    countryFieldInfo({ data, error }) {

        if (data) {
            this.countryOptions = JSON.parse(JSON.stringify(data.values));
        }
    }
    get getCountryOptions() {
        return this.countryOptions;
    }

    connectedCallback() {
        if (this.acctreasontrail === 'CoMarketing') {
            this.displaySalesgroup = false;
            this.salesGrp = 'Undefined';
        }
        else if (this.acctreasontrail === 'Partner' || this.acctreasontrail === 'Access & Entitlement' || this.acctreasontrail === 'Other') {
            this.displaySalesgroup = true;
            this.Value = 'Undefined';
            this.salesGrp = this.Value;
        }
        else {
            this.displaySalesgroup = true;
        }
        // New requirement: For all request types other than Opportunity Management, 
        // lock account primary coverage as "Not Covered" and account level as "No Level"
        if (this.acctreasontrail !== 'Opportunity Management') {
            this.accountcoverage = 'Not Covered';
            this.accountLevel = 'NoLevel';
        }
    }

    pickListChangeHandler(event) {
        let countryIsoCode;
        this.showDuplicates = false;
        if (event.target.country != '') {
            this.countryOptions.forEach(record => {
                if (record.value === event.target.country) {
                    console.log('CountryNameLabel =>' + record.label + ' ' + record.value);
                    this.addressCountryAndState.countryName = record.label;
                    countryIsoCode = record.value
                }
            });
            getCountryRegion({ isoCode: countryIsoCode }).then(result => {
                this.template.querySelector('.Region').value = result.Core_Geo__c ? result.Core_Geo__c : null;
            }).catch(error => {
                console.log(error);
            });
            this.addressAddress.Country = event.target.country;
            let key = this.stateFieldData.controllerValues[event.target.country];
            this.stateOptions = this.stateFieldData.values.filter(opt => opt.validFor.includes(key));
        }
        if (event.target.country == '') {
            this.addressAddress.province = '';
            this.stateOptions = '';
            this.addressAddress.stateCode = '';
        }
        if (event.target.street != '') {
            this.addressAddress.Street = event.target.street;
        }
        if (event.target.city != '') {
            this.addressAddress.City = event.target.city;
        }
        if (event.target.province != '') {
            this.stateOptions.forEach(record => {
                if (record.value === event.target.province) {
                    this.addressCountryAndState.stateName = record.label;
                }
            });
            this.addressAddress.province = event.target.province;
        } else {
            this.addressAddress.province = '';
            this.addressAddress.stateCode = '';
            this.addressCountryAndState.stateName = '';
        }
        if (event.target.postalCode != '') {
            this.addressAddress.postalCode = event.target.postalCode;
        } else {
            this.addressAddress.postalCode = '';
        }
        console.log('addres filed postalcode' + event.target.postalCode);

    }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [User_Name, User_Email, User_WWID]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.UserName = data.fields.Name.value;
            this.UserEmail = data.fields.Email.value;
            this.UserWWID = data.fields.Core_WWID__c.value;


        }
    }

    renderedCallback() {
        this.loaded = false;
    }
    handleLoad(event) {
        this.loaded = false;
    }

    handleFieldChange(event) {
        console.log('@OnChangecall');
        this.showDuplicates = false;
        if (event.target.fieldName == 'Account_Name__c') {
            console.log('Name--> ' + event.target.value);
            this.accountName = event.target.value;
        }
        if (event.target.fieldName == 'Core_Alternate_Name_Language__c') {
            console.log('AlternateLan--> ' + event.target.value);
            if (event.target.value != '') {
                this.disabledLocalLang = false;
            } else {
                this.disabledLocalLang = true;
                this.accountNameLocalLan = '';
            }
            this.alternateLanName = event.target.value;
        }
        if (event.target.fieldName == 'Core_Alternate_Language_Name__c') {
            console.log('CoreAltLan--> ' + event.target.value);
            this.accountNameLocalLan = event.target.value;
        }
        if (event.target.fieldName == 'Digital_Identifier_Type__c') {
            console.log('DigitalIden--> ', event.target.value);
            if (event.target.value != '') {
                this.disabledDigital = false;

            } else {
                this.disabledDigital = true;
                this.digitalIdentifierVal = '';

            }
            console.log('event.target.value--> ' + event.target.value);
            this.digitalIdentifier = event.target.value;
        }
        if (event.target.fieldName == 'Digital_Identifier_Value__c') {
            console.log('DigitalIdenVal--> ' + event.target.value);
            this.digitalIdentifierVal = event.target.value;
        }
        if (event.target.fieldName == 'Industry__c') {
            console.log('Industry--> ' + event.target.value);
            this.industry = event.target.value;
            // Check if Umbrella Group should be required
            const requiredIndustries = ['Defense and Space', 'Education', 'Government'];
            this.isUmbrellaGroupRequired = requiredIndustries.includes(event.target.value);
            if (requiredIndustries.includes(event.target.value)) {
                this.disableUmbrellaGroup = false;
                this.isUmbrellaGroupRequired = true;
            } else {
                this.isUmbrellaGroupRequired = false;
                this.disableUmbrellaGroup = true;
                this.template.querySelector('.UmbrellaGrp').value = '';
            }
        }
        if (event.target.fieldName == 'Core_Sub_Industry__c') {
            console.log('SubInd--> ' + event.target.value);
            this.subIndustry = event.target.value;
        }
        if (event.target.fieldName == 'Core_Sales_Groups__c') {
            this.salesGrp = event.target.value;
        }
        if (event.target.fieldName == 'Tax_Id__c') {
            console.log('event.target.value--> ' + event.target.value);
            this.taxId = event.target.value;
        }
        if (event.target.fieldName == 'Core_Account_Primary_Coverage__c') {
            this.accountcoverage = event.target.value;
            if (this.isOpportunityManagement) {
                if (this.accountcoverage === 'Indirect Covered') {
                    this.accountLevel = 'Level3';
                    const levelField = this.template.querySelector('.AccountLevel');
                    if (levelField) {
                        levelField.value = 'Level3';
                        levelField.disabled = true;
                    }
                    this.showToastSuccessMessage('Info', 'Account Level set to Level 3 for Indirect Covered', 'info', 3000);
                }

                // Auto-set and lock Account Level for Not Covered
                else if (this.accountcoverage === 'Not Covered') {
                    this.accountLevel = 'NoLevel';
                    const levelField = this.template.querySelector('.AccountLevel');
                    if (levelField) {
                        levelField.value = 'NoLevel';
                        levelField.disabled = true;
                    }
                    this.showToastSuccessMessage('Info', 'Account Level set to No Level for Not Covered', 'info', 3000);
                }
                // Enable Account Level for other coverages
                else {
                    const levelField = this.template.querySelector('.AccountLevel');
                    if (levelField) {
                        levelField.disabled = false;
                    }
                }
            } else {
                // For non-Opportunity Management requests, reset to Not Covered if changed
                this.accountcoverage = 'Not Covered';
                const coverageField = this.template.querySelector('.AccountCoverage');
                if (coverageField) {
                    coverageField.value = 'Not Covered';
                }
                event.preventDefault();
            }
        }
        if (event.target.fieldName == 'Global_Account__c') {
            this.globalAccount = event.target.value;
        }
        if (event.target.fieldName == 'Core_Account_Category__c') {
            this.accountcategory = event.target.value;
        }
        if (event.target.fieldName == 'Core_Account_Level__c') {
            this.accountLevel = event.target.value;
        }
    }

    handleSelfSelectionchange(event) {
        if (event.target.name == 'self') {
            this.template.querySelector('.others').checked = false;
            this.selected = false;
            this.selectedRecord(event);
        }
        if (event.target.name == 'others') {
            this.selected = true;
            this.template.querySelector('.self').checked = false;
        }
        console.log('Event ', event.target.value, ' selected', this.selected, ' name', event.target.value);
        let hide = "visibility\: hidden\;margin-top\: -5%\;";
        let show = "visibility\: visible\;";
        this.userselection = true;
    }
    /*handleSuccess(event) {
        this.loaded=false;
        this.spinLoad=false;
        if(!this.isError){
            this.showToastSuccessMessage('Success !','Account Request Record has been created successfully','success',1000);
            
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                  recordId: event.detail.id,
                  objectApiName: 'Account_Create_Request__c',
                  actionName: 'list'
                },
                state:{
                    filterName: 'New_Request'
                }
              });
        }
        
    }*/
    handleError(event) {
        this.isOpenModal = false
        console.log('Inside handle error' + JSON.stringify(event.detail));
        console.log('event' + event, detail.detail);
        this.loaded = false;
        this.spinLoad = false;
        if (JSON.stringify(event.detail.detail) === '""') {
            console.log('Inside if' + event.detail.detail);
            this.permissionErrorCode = 1;
            this.errorMsg = 'Invalid values to create a record!';
        }
        else {
            console.log('Inside else' + event.detail.detail);
            this.errorMsg = JSON.stringify(event.detail.detail);
        }
        this.showToastErrorMessage('error', 'Error!', this.errorMsg);
    }

    handleBackButtonClick(event) {
        console.log('inside create account ' + JSON.stringify(this.acctformdetails));
        const acctCreateBackClick = new CustomEvent("acctcreatebackclick", { detail: this.acctformdetails });
        this.dispatchEvent(acctCreateBackClick);
    }
    closedModal() {
        this.showModal = false;
    }

    get hasCleansedAddress() {
        const c = this.cleansedAddress;
        if (!c || c.verificationStatus === 'Reverted' || c.verificationStatus === 'Unverified') {
            return false;
        }
        return !!(c.streetName || c.cityName || c.stateName || c.postalCode || c.countryName);
    }

    get cleansedBoxClass() {
        const base = 'slds-box slds-box_x-small slds-text-align_center slds-p-around_medium address-box';
        return this.selectedAddressOption === 'cleansed' ? base + ' address-box_selected' : base;
    }

    get userInputBoxClass() {
        const base = 'slds-box slds-box_x-small slds-text-align_center slds-p-around_medium address-box';
        return this.selectedAddressOption === 'userInput' ? base + ' address-box_selected' : base;
    }

    handleAddressBoxClick(event) {
        event.stopPropagation();
        this.selectedAddressOption = event.currentTarget.dataset.option;
    }
    handleDeselectAddress() {
        this.selectedAddressOption = null;
    }

    handleProceed() {
        this.isOpenModal = false;
        this.spinLoad = true;
        this.duplicates = [];
        const nameValue = this.template.querySelector(".Name").value;
        const countryFieldValue = this.addressCountryAndState.countryName;
        const streetFieldValue = this.addressAddress.Street;
        const cityFieldValue = this.addressAddress.City;
        const stateFieldValue = this.addressCountryAndState.stateName;
        const postalCodeValue = this.addressAddress.postalCode;
        //const concatAddress=streetFieldValue + ', ' + cityFieldValue + ', ' + stateFieldValue +  ', ' + countryFieldValue + ', ' + postalCodeValue;
        //const fullAddress=concatAddress.replace(/,\s*$/, '');
        console.log('#@$stateFieldValueCleansed1 ' + stateFieldValue + ', ' + nameValue);
        console.log('AddressVerification REQUEST => ' + JSON.stringify({
            organizationName: nameValue,
            streetName: streetFieldValue,
            countryName: countryFieldValue,
            stateName: stateFieldValue,
            cityName: cityFieldValue,
            postalCode: postalCodeValue
        }));
        addressVerification({
            organizationName: nameValue,
            streetName: streetFieldValue,
            countryName: countryFieldValue,
            stateName: stateFieldValue,
            cityName: cityFieldValue,
            postalCode: postalCodeValue
        })
            .then(result => {
                this.spinLoad = false;
                this.cleansedAddress = result;
                this.showModal = true;
                //this.showModal = true;
                // Capture the address the user entered so it can be shown alongside the
                // Loqate cleansed address and selected as the address to proceed with.
                this.userEnteredAddress = {
                    streetName: this.addressAddress.Street,
                    cityName: this.addressAddress.City,
                    stateName: this.addressCountryAndState.stateName,
                    postalCode: this.addressAddress.postalCode,
                    countryName: this.addressCountryAndState.countryName
                };
                // Default to the cleansed address when one is available, otherwise
                // proceed with the address the user entered.
                console.log('CleansedAddress@67 ' + JSON.stringify(this.cleansedAddress));
                if (!this.cleansedAddress || this.cleansedAddress.verificationStatus === 'Reverted' || this.cleansedAddress.verificationStatus === 'Unverified') {
                    this.showAddress = false;
                    console.log('Address not verified', this.showAddress);
                }
                else {
                    this.showAddress = true;
                    console.log('Address verified', this.showAddress);
                }
                this.selectedAddressOption = null;
            })
            .catch(error => {
                this.spinLoad = false;
            });
    }
    handleCancel() {
        this.isOpenModal = false;
        this.spinLoad = false;
        return;
    }
    handleSubmit1(event) {
        const fields = event.detail.fields;
        console.log('fields 1--> ' + JSON.stringify(fields));
        this.validateFields(event);

    }
    handleSubmit(event) {
        event.preventDefault();
        console.log('In handleSubmit' + this.addressAddress.postalCode);
        // Set the account level and category for Opportunity Management
        if (!this.isError) {
            this.spinLoad = true;
            const nameFieldValue = this.template.querySelector(".Name").value;
            const alternateLangNameFieldValue = this.accountNameLocalLan;
            const countryFieldValue = this.addressAddress.Country;
            const streetFieldValue = this.addressAddress.Street;
            const cityFieldValue = this.addressAddress.City;
            const stateFieldValue = this.addressAddress.province;
            //const postalCodeValue=this.addressAddress.postalCode;
            console.log('#@$stateFieldValue35 ' + stateFieldValue);
            checkForDuplicates({
                customername: nameFieldValue,
                alternateLangName: alternateLangNameFieldValue,
                primaryCountry: countryFieldValue,
                primaryStreet: streetFieldValue,
                primaryCity: cityFieldValue,
                primaryState: stateFieldValue
            })
                .then(result => {
                    if (result && result.length > 0) {
                        this.spinLoad = false;
                        this.showToastDuplicateErrorMessage('error', 'Error!', 'Error! An account matching the customer name & address you entered has been found. You can’t submit this new request as it is a duplicate.');
                        this.showDuplicates = true;
                        this.duplicates = result;
                        console.log('DuplicateRecordS1 ' + JSON.stringify(this.duplicates));
                        this.formatRecordsForDisplay();
                    } else {
                        this.spinLoad = false;
                        this.isOpenModal = true;
                    }
                })
                .catch(error => {
                    this.spinLoad = false;
                });
            this.fields = event.detail.fields;

        }
        else {
            this.spinLoad = false;
        }
    }
    submitRequest(event) {
        console.log('EnteringSubmitrequest');
        if (!this.isError) {
            // For non-Opportunity Management requests, ensure these values are set  
            if (!this.isOpportunityManagement) {
                this.accountcoverage = 'Not Covered';
                this.accountLevel = 'NoLevel';
            }
            if (this.isOpportunityManagement) {

                if (!this.validateAccountLevelRules()) {
                    return; // Stop submission if validation fails
                }
            }
            if (!this.validateUserSelection()) {
                return;
            }
            if (this.selectedAddressOption === 'cleansed' && this.hasCleansedAddress) {
                this.fields.Address__CountryCode__s = this.cleansedAddress.countryCode;
                this.fields.Address__StateCode__s = this.cleansedAddress.stateCode;
                this.fields.Address__Street__s = this.cleansedAddress.streetName;
                this.fields.Address__City__s = this.cleansedAddress.cityName;
                this.fields.Address__PostalCode__s = this.cleansedAddress.postalCode;
                this.fields.Core_Sales_Groups__c = this.salesGrp;
                // Record was created using the Loqate cleansed address.
                this.fields.IsAddressVerified__c = true;
            }
            else {
                this.fields.Address__CountryCode__s = this.addressAddress.Country;
                this.fields.Address__StateCode__s = this.addressAddress.province;
                this.fields.Address__Street__s = this.addressAddress.Street;
                this.fields.Address__City__s = this.addressAddress.City;
                this.fields.Address__PostalCode__s = this.addressAddress.postalCode;
                this.fields.Core_Sales_Groups__c = this.salesGrp;
                // Record was created using the address as entered (not the cleansed address).
                this.fields.IsAddressVerified__c = false;
            }
            if (!this.fields.Core_Account_Level__c || this.fields.Core_Account_Level__c === '') {
                this.fields.Core_Account_Level__c = this.accountLevel || 'NoLevel';
            }
            this.fields.Core_Account_Category__c = this.accountcategory;
            console.log('ownerID', this.OwnerId);
            this.fields['OwnerId'] = this.OwnerId;
            //this.fields.Standardized_Address_VerificationStatus__c=this.cleansedAddress.verificationStatus;
            let fields = this.fields;
            console.log('Fields__>>', JSON.stringify(this.fields));
            const recordInput = { apiName: ACCOUNT_CREATE_REQUEST_OBJECT.objectApiName, fields };
            this.showModal = false;
            this.spinLoad = true;
            createRecord(recordInput)
                .then((result) => {
                    if (!this.isError) {
                        this.showToastSuccessMessage('Success !', 'Account Request Record has been created successfully', 'success', 1000);

                        this[NavigationMixin.Navigate]({
                            type: 'standard__objectPage',
                            attributes: {
                                //recordId: result.id,
                                objectApiName: 'Account_Create_Request__c',
                                actionName: 'list'
                            },
                            state: {
                                filterName: 'New_Request'
                            }
                        });
                    }
                })
                .catch((error) => {
                    this.spinLoad = false;
                    console.log('ErrorMessage ' + JSON.stringify(error));
                    this.showToastErrorMessage('error', 'Error !', 'An error occured while trying to create record. Plesae check and try again');
                    /*this.dispatchEvent(
                        new ShowToastEvent({
                        title: "Error creating record",
                        message: error.body.message,
                        variant: "error",
                        }),
                    );*/
                });
        }
    }

    formatRecordsForDisplay() {
        let formattedRecordsAccount = [];
        let formattedRecordsAccountRequest = [];
        this.duplicates.forEach(record => {
            const formattedAccountRecord = {
                recordacctId: '/' + record.acctId,
                acctId: record.acctId,
                accountName: record.accountName,
                accountCountry: record.accountCountry,
                acctOwner: record.acctOwner,
                unifiedGlobalCustomerName: record.unifiedGlobalCustomerName
            };
            const formattedRecordRequest = {
                recordUrl: '/' + record.acctRequestId,
                acctRequestId: record.acctRequestId,
                customername: record.customername,
                acctRequestCountry: record.acctRequestCountry,
                createdDate: record.createdDate,
                requestorName: record.requestorName,
                processType: record.processType
            };
            if (record.objectName === 'Account') {
                this.accountDuplicate = true;
                formattedRecordsAccount.push(formattedAccountRecord);
                console.log('@#AccountRecordcheck7 ' + this.accountDuplicate);
            }
            if (record.objectName === 'Account_Create_Request__c') {
                this.accountRequestDuplicate = true;
                formattedRecordsAccountRequest.push(formattedRecordRequest);
                console.log('@#AccountRequestrecordcheck6 ' + this.accountRequestDuplicate);
            }
        });

        this.formattedRecordsAccount = formattedRecordsAccount;
        this.formattedRecordsAccountRequest = formattedRecordsAccountRequest;
        if (formattedRecordsAccount.length === 0) {
            this.accountDuplicate = false;
            console.log('@#AccountRecordcheckfalsec ' + this.accountDuplicate);
        }
        if (formattedRecordsAccountRequest.length === 0) {
            this.accountRequestDuplicate = false;
            console.log('@#AccountRequsetcheckfalse ' + this.accountRequestDuplicate);
        }
        console.log('#formattedRecordsAccount7 ' + JSON.stringify(this.formattedRecordsAccount));
        console.log('#formattedRecordsAccountRequest7 ' + JSON.stringify(this.formattedRecordsAccountRequest));
    }

    validateFields(event) {
        this.submitError = '';
        this.errorList = '';

        console.log('this.template.querySelector(".Name").value--> ' + this.template.querySelector(".Name").value);
        this.errorList = (((this.template.querySelector(".Name").value == '' || this.template.querySelector(".Name").value == null) || !this.template.querySelector(".Name").value.trim()) ? (this.submitError + ',' + 'Account Name') : '') +
            ((!this.template.querySelector(".Industry").value) ? (this.submitError + ',' + 'Industry') : '') +
            ((!this.template.querySelector(".SubIndustry").value) ? (this.submitError + ',' + 'Sub Industry') : '') +
            ((!this.template.querySelector(".globaAcct").value) ? (this.submitError + ',' + 'Justification for Request') : '') +
            ((!this.template.querySelector(".digitalIdentifier").value) ? (this.submitError + ',' + 'Digital Identifier ') : '') +
            ((!this.template.querySelector(".digitalIdentifierVal").value) ? (this.submitError + ',' + 'Digital Identifier Value') : '');
        console.log('USER_ID' + USER_ID + 'OwnerId ' + this.OwnerId)
        //Add account level validation if this is an Opportunity Management request
        if (this.selected == true && (this.OwnerId == null || USER_ID == this.OwnerId)) {
            this.showToastErrorMessage('error', 'Validation Error', WarningLabel);
            this.loaded = false;
            this.isError = true;
            this.spinLoad = false;
            return;
        }
        if (this.isOpportunityManagement) {
            // Check account level rules
            const accountLevelValid = this.validateAccountLevelRules();
            if (!accountLevelValid) {
                this.isError = true;
                return; // Exit validation early since we've already shown the error toast
            }
        }

        if (this.displaySalesgroup) {
            this.errorList = this.errorList + ((!this.template.querySelector(".SalesGrp").value) ? (this.submitError + ',' + 'Sales Group') : '');
        }

        // Validate Umbrella Group if required based on Industry
        if (this.isUmbrellaGroupRequired) {
            this.errorList = this.errorList + ((!this.template.querySelector(".UmbrellaGrp").value) ? (this.submitError + ',' + 'Umbrella Group') : '');
        }

        console.log('disabled' + this.disabledDigital);
        if (!this.disabledDigital) {
            console.log('inside if digital');
            if (this.digitalIdentifierVal == '' && this.digitalIdentifier == 'Website/URL') {
                this.errorList = this.errorList + (((this.template.querySelector(".digitalIdentifierVal").value == '' || this.template.querySelector(".digitalIdentifierVal").value == null) || !this.template.querySelector(".digitalIdentifierVal").value.trim()) ? (' . If a customer website cannot be found, you can enter N/A') : '')
            }
            else if (this.digitalIdentifierVal == '' && this.digitalIdentifier == 'WeChat') {
                this.errorList = this.errorList + (((this.template.querySelector(".digitalIdentifierVal").value == '' || this.template.querySelector(".digitalIdentifierVal").value == null) || !this.template.querySelector(".digitalIdentifierVal").value.trim()) ? (' . If a customer website cannot be found, you can enter N/A') : '')
            }

        }
        if (!this.disabledLocalLang) {
            this.errorList = this.errorList + (((this.template.querySelector(".AltLangName").value == '' || this.template.querySelector(".AltLangName").value == null) || !this.template.querySelector(".AltLangName").value.trim()) ? (this.submitError + ',' + 'Customer Name - Local Language') : '')
        }
        //  (((this.template.querySelector(".digitalIdentifier").value == '' || this.template.querySelector(".digitalIdentifier").value == null) || !this.template.querySelector(".digitalIdentifier").value.trim())?(this.submitError+',' +'Digital Identifier Value'):'')+
        // (((this.template.querySelector(".AltLangName").value == '' || this.template.querySelector(".AltLangName").value == null) || !this.template.querySelector(".AltLangName").value.trim())?(this.submitError+',' +'Customer Name - Local Language'):'');
        console.log('error list' + this.errorList);
        const address = this.template.querySelector('lightning-input-address');
        //Country Field Validation
        var country = address.country;
        if (country == null || country == '') {
            address.setCustomValidityForField('Complete this field.', 'country');
        } else {
            address.setCustomValidityForField("", 'country'); //Reset previously set message
        }

        //Street Field Validation
        var street = address.street;
        console.log('Street' + street);
        if (!street) {
            address.setCustomValidityForField('Complete this field.', 'street');
        } else {
            address.setCustomValidityForField("", 'street'); //Reset previously set message
        }

        //city Field Validation
        var city = address.city;
        console.log('Street' + city);
        if (!city) {
            address.setCustomValidityForField('Complete this field.', 'city');
        } else {
            address.setCustomValidityForField("", 'city'); //Reset previously set message
        }

        address.reportValidity(); // Refreshes the component to show or remove error messages from UI
        const isValid = address.checkValidity(); //Check if the address is Valid and accordingly proceed.

        if (!isValid) {
            this.errorList = this.errorList + ', Complete all address fields.';
        }

        if (this.errorList.charAt(0) == ',') {
            this.submitError = this.errorList.substring(1);
        } else {
            this.submitError = this.errorList;
        }
        console.log('this.submitError--> ' + this.submitError);
        if (this.submitError != '') {
            this.isError = true;
            this.showToastErrorMessage('error', 'Error!', 'Review the required fields errors! ' + this.submitError);
        } else {
            console.log('in else submiterror');
            this.isError = false;
        }
        console.log('DupCheck ');
    }

    get isOpportunityManagement() {
        return this.acctreasontrail === 'Opportunity Management';
    }
    showToastSuccessMessage(title, message, variant, duration) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            duration: duration
        });
        this.dispatchEvent(evt);
    }

    showToastErrorMessage(variant, title, message) {
        const eve = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message,
        });
        this.dispatchEvent(eve);
    }

    showToastDuplicateErrorMessage(variant, title, message) {
        const eve = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message,
            mode: 'sticky'
        });
        this.dispatchEvent(eve);
    }
    // Function called on user record selection from lookup.This is the selected user record
    selectedRecord(event) {
        //this.spinner = !this.spinner;
        if (event.detail.recordId != null || USER_ID != null) {
            //Selected user record Id
            this.OwnerId = event.detail.recordId ? event.detail.recordId : USER_ID;
            //To populate account list on user select from lookup search
            console.log('OwnerId ', this.OwnerId);
            userFields({
                recordID: this.OwnerId
            }).then(result => {
                if (result) {
                    console.log('result', result);
                    this.UserName = result.name;
                    this.UserEmail = result.email;
                    this.UserWWID = result.wwid;
                    this.OwnerId = result.id;
                }
            }).catch(error => {
                console.log(error);

            });
        }
    }

    validateAccountLevelRules() {
        let isValid = true;
        let errorMessage = '';
        //setting default values if null or empty
        if (this.accountcoverage == null || this.accountcoverage == '') {
            this.accountcoverage = 'Not Covered';
        }
        // if(this.accountLevel == null || this.accountLevel == ''||this.accountLevel.toLowerCase() === 'undefined'){
        //     console.log('entering undefined check ,value:'+this.accountLevel);
        //      this.accountLevel = 'NoLevel';
        // }

        const coverage = (this.accountcoverage || '').trim();
        const salesGroup = (this.salesGrp || '').trim();
        const level = (this.accountLevel || '').trim();
        const isLevel12 = lvl => ['Level1', 'Level 1', 'Level2', 'Level 2'].includes(lvl);
        const isLevel2 = lvl => ['Level2', 'Level 2'].includes(lvl);
        const isLevel123 = lvl => ['Level1', 'Level 1', 'Level2', 'Level 2', 'Level3', 'Level 3'].includes(lvl);
        const isNoLevel = lvl => ['No Level', 'NoLevel'].includes(lvl);


        // Rule 1 & 2: If Account Primary Coverage is Intel Covered (and not Partner Led), Account level must be Level1/2
        if (coverage === 'Intel Covered') {
            if (salesGroup.toLowerCase() === 'undefined' || !salesGroup) {
                if (!isNoLevel(level)) {
                    isValid = false;
                    errorMessage = this.label.UCD_ACM_Intel_Covered_Undefined_SalesGroup;
                }
            } else {
                const isPartnerLed = salesGroup.toLowerCase().includes('partner led');
                if (!isPartnerLed) {
                    if (!isLevel12(level)) {
                        isValid = false;
                        errorMessage = this.label.UCD_ACM_Intel_Covered_NotPartnerLed_SalesGroup;
                    }
                } else if (isPartnerLed) {
                    if (!isLevel2(level)) {
                        isValid = false;
                        errorMessage = this.label.UCD_ACM_Intel_Covered_PartnerLed_SalesGroup;
                    }
                }
            }
        }
        // If validation fails, show error message
        if (!isValid) {
            this.showToastErrorMessage('error', 'Validation Error', errorMessage);
            console.log('Account level validation failed:', errorMessage);
        }


        return isValid;
    }

    validateUserSelection() {
        var isValid = true;
        var errorMessage;
        if (this.selected == true && (this.OwnerId == null || USER_ID == this.OwnerId)) {
            isValid = false;
            errorMessage = WarningLabel;
        }
        // If validation fails, show error message
        if (!isValid) {
            this.showToastErrorMessage('error', 'Validation Error', errorMessage);
        }


        return isValid;
    }

    renderedCallback() {
        setTimeout(() => {
            console.log("inside renderedCallback 33");
            const levelField = this.template.querySelector('.AccountLevel');
            const coverageField = this.template.querySelector('.AccountCoverage');
            if (levelField) {
                if (this.acctreasontrail !== 'Opportunity Management') {
                    // For non-Opportunity Management requests, lock both fields
                    levelField.value = 'NoLevel';
                    levelField.disabled = true;

                    if (coverageField) {
                        coverageField.value = 'Not Covered';
                        coverageField.disabled = true;
                    }
                } else {
                    // For Opportunity Management, apply the existing logic
                    if (this.accountcoverage === 'Not Covered') {
                        levelField.value = 'NoLevel';
                        levelField.disabled = true;
                    } else if (this.accountcoverage === 'Indirect Covered') {
                        levelField.value = 'Level3';
                        levelField.disabled = true;
                    } else {
                        levelField.disabled = false;
                    }
                }
            }
        }, 0);
    }

}