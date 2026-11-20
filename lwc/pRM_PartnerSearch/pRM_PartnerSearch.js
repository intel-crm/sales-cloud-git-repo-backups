import { LightningElement, track, wire } from 'lwc';
import getDistributors from '@salesforce/apex/PRM_PartnerSearchController.getDistributors';
import getAccountDetails from '@salesforce/apex/PRM_PartnerSearchController.getAccountDetails';
import getCountryList from '@salesforce/apex/PRM_PartnerSearchController.getCountryList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAuth from '@salesforce/apex/PRM_PartnerSearchController.getAuth';
import ipaLookupError from '@salesforce/label/c.PRM_IPA_Lookup_Error';
import ipaChatSupport from '@salesforce/label/c.IPA_Chat_Support';
import ipaLookupCustomerSupport from '@salesforce/label/c.PRM_IPA_Lookup_CustomerSupport';
import allDefaultPicklistValue from '@salesforce/label/c.PRM_DefaultValue_Picklist';
import partnerSearch from '@salesforce/label/c.PRM_PartnerSearchHeader';
import partnerAdmin from '@salesforce/label/c.PRM_Partner_Admin';
import tier from '@salesforce/label/c.PRM_Tier_Column';
import country from '@salesforce/label/c.PRM_Country';
import accName from '@salesforce/label/c.PRM_Account_Name';
import accNumber from '@salesforce/label/c.PRM_AccountNumber';
import partnerRole from '@salesforce/label/c.PRM_Partner_Role_Column';
import website from '@salesforce/label/c.PRM_Website';
import trainingcredits from '@salesforce/label/c.PRM_Training_Credits';
import search from '@salesforce/label/c.PRM_Search';
import reset from '@salesforce/label/c.PRM_Reset';
import startBySearching from '@salesforce/label/c.PRM_StartBySearching';
import results from '@salesforce/label/c.PRM_Results';
import noRecords from '@salesforce/label/c.PRM_NoRecords';
import close from '@salesforce/label/c.PRM_Close';
import accountDetails from '@salesforce/label/c.PRM_AccountDetails';
import partnerTier from '@salesforce/label/c.PRM_PartnerTier';
import prAddress from '@salesforce/label/c.PRM_PrimaryAddress';
import address from '@salesforce/label/c.PRM_Address';
import state from '@salesforce/label/c.PRM_State';
import zipcode from '@salesforce/label/c.PRM_Zip_Code';
import zipcodeheader from '@salesforce/label/c.PRM_Zip_Code_Header';
import stateheader from '@salesforce/label/c.PRM_State_Header';
import emailheader from '@salesforce/label/c.PRM_Email_Column';
import firstnameheader from '@salesforce/label/c.PRM_First_Name';
import lastnameheader from '@salesforce/label/c.PRM_Last_Name';


import ipaAccepted from '@salesforce/label/c.PRM_IPA_TC_Accepted';
import pointsSatus from '@salesforce/label/c.PRM_PointsStatus';
import searchError from '@salesforce/label/c.PRM_PartnerSearch_Error';
import filters from '@salesforce/label/c.PRM_Filters';
import validationMessage from '@salesforce/label/c.PRM_validationMsg';
import searchMessage from '@salesforce/label/c.PRM_searchMessage';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
// import accCountry from '@salesforce/schema/Account.Core_Account_Country__c';
import accTier from '@salesforce/schema/Account.Core_IPA_Badge_Tier__c';
import { loadStyle } from 'lightning/platformResourceLoader'
import PRM_PartnerSearch_Style from '@salesforce/resourceUrl/PRM_PartnerSearch_Style'
// import Core_INTC from '@salesforce/resourceUrl/Core_INTC'
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import CNDANumber from '@salesforce/label/c.PRM_CNDAPresent';
import affiliation from '@salesforce/label/c.PRM_Is_MOA_Affiliation_Active';
import DZP from '@salesforce/label/c.PRM_DZP_Present';

const columnsTable = [{
    label: accName,
    type: 'customLink',
    sortable: "true",
    hideDefaultActions: "true",
    fieldName: "nameUrl",
    typeAttributes: {
        accountNumber: { fieldName: 'accountName' },
        accountId: { fieldName: 'accountId' }
    }
},
{
    label: accNumber,
    type: 'customLink',
    hideDefaultActions: "true",
    sortable: "true",
    fieldName: "numberUrl",
    typeAttributes: {
        accountNumber: { fieldName: 'accountNumber' },
        accountId: { fieldName: 'accountId' }
    }
},
{
    label: partnerRole,
    fieldName: 'partnerRole',
    hideDefaultActions: "true",
    sortable: "true"
},
{
    label: partnerTier,
    fieldName: 'partnerTier',
    hideDefaultActions: "true",
    sortable: "true"
},
{
    label: address,
    fieldName: 'billingAddress',
    hideDefaultActions: "true",
    sortable: "true"
},
{
    label: stateheader,
    fieldName: 'billingState',
    hideDefaultActions: "true",
    sortable: "true"
},
{

    label: country,
    fieldName: 'billingCountry',
    hideDefaultActions: "true",
    sortable: "true"
},
{
    label: zipcodeheader,
    fieldName: 'billingZipcode',
    hideDefaultActions: "true",
    sortable: "true"
}
];

const contactColumns = [
    {
        label: firstnameheader, fieldName: 'partnerAdminFirstName', sortable: "true", hideDefaultActions: "true"
    },
    {
        label: lastnameheader, fieldName: 'partnerAdminLastName', sortable: "true", hideDefaultActions: "true"
    },
    {
        label: emailheader, fieldName: 'partnerAdminEmail', sortable: "true", hideDefaultActions: "true"
    }
];

export default class PRM_PartnerSearch extends LightningElement {
    columnsTable = columnsTable;
    contactColumns = contactColumns;

    // INPUT PARAMS
    searchInput;
    country;
    tier;
    @track trainingConversion= 0;
    @track showSpinner = false;
    @track accountList = [];
    @track tierList = [];
    @track countryList = [{ "label": allDefaultPicklistValue, "value": allDefaultPicklistValue }];
    // @track tierList = [{ "label": allDefaultPicklistValue, "value": allDefaultPicklistValue }];
    accountDetail;
    authValue;
    showPopup = false;
    showPage = false;
    @track countryOptions;
    @track tierOptions = [{ "attributes": null, "label": allDefaultPicklistValue, "validFor": [], "value": allDefaultPicklistValue }];
    @track recordTypeById;


    label = {
        ipaLookupError,
        ipaChatSupport,
        ipaLookupCustomerSupport,
        allDefaultPicklistValue,
        partnerSearch,
        partnerAdmin,
        tier,
        country,
        accName,
        accNumber,
        partnerRole,
        website,
        trainingcredits,
        search,
        reset,
        startBySearching,
        results,
        noRecords,
        close,
        accountDetails,
        partnerTier,
        prAddress,
        ipaAccepted,
        pointsSatus,
        searchError,
        filters,
        validationMessage,
        searchMessage,
        CNDANumber,
        affiliation,
        DZP
    };


    // to get the default record type id, if you dont' have any recordtypes then it will get master 
    @track pickListvalues;
    @track error;
    @track values;
    @track pickListvaluesByRecordType;
    @track accountsource;
    @track accountMetadata;

    @track sortBy;
    @track sortDirection;
    @track isShowContent = false;
    @track isOnChange = false;
    @track noRecordsMessage = false;
    @track noRecordsMessageOnLoad = true;
    showPartnerDetailsTable = false;
    // @track isShowTable = true;

    /**
     * Calling the getAuth method on Page Load
     */
    connectedCallback() {
        this.getAuth();
    }
    /**
     * Loading static resource file on Page Load
     */
    renderedCallback() {
        if (this.isCssLoaded)
            return
        this.isCssLoaded = true
        loadStyle(this, PRM_PartnerSearch_Style)
            // loadStyle(this, Core_INTC + '/theme/styles/corebundle.min.css')
            .then(() => {
                console.log("Loaded Successfully")
            })
            .catch(error => {
                console.error("Error in loading the colors")
            })
    }
    /**
     * @param  {} getObjectInfo
     * @param  {ACCOUNT_OBJECT}} {objectApiName
     */
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    wiredaccountMetadata({ data, error }) {
        if (data) {
            const rtis = data.recordTypeInfos;
            this.recordTypeById = Object.keys(rtis).find(rti => rtis[rti].name === 'Intel Account');
            //console.log('RecordId' + JSON.stringify(this.recordTypeById));
        }
    }

    /**
     * @param  {} getPicklistValues fetching the tier picklist values from Account Object
     */
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeById',
        fieldApiName: accTier
    })
    wiredPickListValueTier({ data, error }) {
        if (data) {
            this.tierList = data.values;
            this.error = undefined;
            this.tierOptions = [{ "attributes": null, "label": allDefaultPicklistValue, "validFor": [], "value": allDefaultPicklistValue }];
            if (this.tierList != null && this.tierList != undefined) {
                if (this.tierList.length > 0) {
                    this.tierList.forEach(element => {
                        if (element != null && element != '') {
                            this.tierOptions.push(element);
                        }
                    });
                }
            }
            this.tierOptions = JSON.parse(JSON.stringify(this.tierOptions));
        } else if (error) {
            this.error = error;
            this.pickListvalues = undefined;
        }
    }



    /**
     * @param  {} msgTitle
     * @param  {} msg
     * @param  {} type
     */
    showToast(msgTitle, msg, type) {
        console.log('In Toast');
        this.dispatchEvent(
            new ShowToastEvent({
                title: msgTitle,
                message: msg,
                variant: type,
                mode: 'dismissable'
            }),
        );
    }
    /**
     * Fetching deatils based on Search Parameters
     */
    async searchDistributors() {
        this.noRecordsMessageOnLoad = false;
        this.country = allDefaultPicklistValue;
        this.tier = allDefaultPicklistValue;
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = this.defaultVal;
        });
        var inputError = this.template.querySelector('.inputError');
        var value = inputError.value;
        // is input valid text?
        if (value.length < 3) {
            inputError.setCustomValidity(validationMessage);
            this.isShowContent = false;
        }
        else {
            inputError.setCustomValidity('');
            await this.handleSearch();
            this.getUpdatedCountries();
            // this.getUpdatedTier();
        }
        inputError.reportValidity();

    }

    async handleSearch() {
        this.noRecordsMessageOnLoad = false;
        if (this.searchInput == null || this.searchInput == undefined || this.searchInput == '') {
            this.showToast('Error', searchError, 'error');
            return;
        }
        this.showSpinner = true;
        try {
            console.log("no records value start=>>>>" + this.noRecordsMessage);
            this.accountList = await getDistributors({ searchInput: this.searchInput, country: this.country, tier: this.tier });
            console.log("Account List data=>>>>>>" + JSON.stringify(this.accountList));
            if (this.accountList != null && this.accountList != undefined && this.accountList != '') {
                if (this.accountList.length > 0) {
                    this.isShowContent = true;
                    this.noRecordsMessage = false;
                }
            }
            else {
                if (this.isOnChange) {
                    this.isShowContent = true;
                }
                else {
                    this.isShowContent = false;
                }
                this.noRecordsMessage = true;
            }
        } catch (error) {
            console.log('Error occured:- ' + error.body.message);
        }
        this.showSpinner = false;
    }

    getUpdatedCountries() {
        this.countryList = [{ "label": allDefaultPicklistValue, "value": allDefaultPicklistValue }];
        if (this.accountList != null && this.accountList != undefined) {
            if (this.accountList.length > 0) {
                this.accountList.forEach(element => {
                    if (element.billingCountry != null && element.billingCountry != '') {
                        if (!this.countryList.find(country => country.label == element.billingCountry)) {
                            this.countryList.push(
                                { label: element.billingCountry, value: element.billingCountry }
                            );
                        }
                    }
                });
            }
        }
        console.log("country list 323=>>>>>" + this.countryList)
        this.countryList = JSON.parse(JSON.stringify(this.countryList));

    }

    /**
     * Resetting values on click of Reset Button
     */
    handleResetAll() {
        this.noRecordsMessageOnLoad = true;
        console.log("no records value reset=>>>>" + this.noRecordsMessage);
        this.showSpinner = true;
        this.isShowContent = false;
        this.noRecordsMessage = false;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.value = null;
        });
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = this.defaultVal;
        });
        this.accountList = [];
        this.searchInput = null;
        this.country = null;
        this.tier = null;
        this.showSpinner = false;
    }

    changeInput(event) {
        this[event.target.name] = event.target.value;
        this.isOnChange = false
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = this.defaultVal;
        });
        this.country = null;
        this.tier = null;
    }
    changeCountry(event) {
        this[event.target.name] = event.target.value;
        console.log("selected country=>>>>>>> " + event.target.value);
        this.handleSearch();
        console.log("filter list=>>>>>>>>" + JSON.stringify(this.accountList));
        this.isOnChange = true;

    }
    changeTier(event) {
        this[event.target.name] = event.target.value;
        this.handleSearch();
        this.isOnChange = true;
    }

    closeModal() {
        this.showPopup = false;
    }
    /**
     * @param  {} event 
     */
    handleClick(event) {
        this.showSpinner = true
        event.stopPropagation();
        this.getAccountDetails(event.detail.data.accountid);
        this.showSpinner = false;
    }
    /**
     * @param  {} accountid To fetch Account Details
     */
    async getAccountDetails(accountid) {
        try {
            this.accountDetail = await getAccountDetails({ recordId: accountid });
            this.trainingConversion = this.convertNumber(this.accountDetail.trainingCreditCurPeriod, false);//utkarsh - passed false as a parameter while calling convertNumber method because we need to show actual sales data.
            this.showPopup = true;
            if (this.accountDetail.partnerDetails.length > 0 && this.accountDetail.partnerDetails != null) {
                if(this.accountDetail.isValidRegion == true){
                    this.showPartnerDetailsTable = true;
                }
            }else{
                this.showPartnerDetailsTable = false;
            }

        } catch (error) {
            console.log('Error occured while fetching acc details:- ' + error.body.message);
        }
    }

    get isShowTable() {
        return this.accountList.length > 0
    }
    /**
     * To check if the user navigating to the Partner Search Page is Authorized or not
     */
    async getAuth() {
        try {
            this.authValue = await getAuth();
            console.log('authValue--->' + JSON.stringify(this.authValue));
            this.showPage = true;
        } catch (error) {
            console.log('error--->' + JSON.stringify(error));
            this.showToast('Error', JSON.stringify(error), 'success');
            this.showSpinner = false;
            this.showPage = true;

        }
    }

    handleAccountSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortAccountData(event.detail.fieldName, event.detail.sortDirection);
    }

    handleContactSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortContactData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortAccountData(fieldName, direction) {
        fieldName = fieldName === 'nameUrl' ? 'accountName' : fieldName === 'numberUrl' ? 'accountNumber' : fieldName;
        let parseData = JSON.parse(JSON.stringify(this.accountList));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldName];
        };
        let isReverse = direction === 'asc' ? 1 : -1;   // cheking reverse direction
        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x).toLowerCase() : ''; // handling null values
            y = keyValue(y) ? keyValue(y).toLowerCase() : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.accountList = parseData;
    }


    sortContactData(fieldName, direction) {
        let parseData = JSON.parse(JSON.stringify(this.accountDetail.partnerDetails));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldName];
        };
        let isReverse = direction === 'asc' ? 1 : -1; // cheking reverse direction 
        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x).toLowerCase() : ''; // handling null values
            y = keyValue(y) ? keyValue(y).toLowerCase() : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        // set the sorted data to data table data
        this.accountDetail.partnerDetails = parseData;
    }

    convertNumber(value, convert) {
        // Default is no conversion
        const converted = {
          decimals: 0,
          text: '',
          value,
        };
  
        if (convert) {
          if (value >= 1000 && value < 1000000) {
            // Convert the number to the "xxx K" format
            converted.decimals = 0;
            converted.text = 'K';
            converted.value = value / 1000;
          } else if (value >= 1000000 && value < 1000000000) {
            // Convert the number to the "xxx M" format
            converted.decimals = 0;
            converted.text = 'M';
            converted.value = value / 1000000;
          } else if (value >= 1000000000){
            // Convert the number to the "xxx M" format
            converted.decimals = 0;
            converted.text = 'B';
            converted.value = value / 1000000000;  
          }
        }
        return converted;
      } 

}