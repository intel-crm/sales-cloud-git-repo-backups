import { LightningElement, api, wire, track } from 'lwc';
import getReportData from '@salesforce/apex/core_S2S_ViewICSCases.getListViewData';
import hasAccess from '@salesforce/apex/core_S2S_ViewICSCases.hasAccess';
import getLabel from '@salesforce/apex/core_S2S_CaseExternalFeedController.getLabel';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import ICSCase from '@salesforce/label/c.View_ICS_Cases';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';


export default class ViewICSCases extends NavigationMixin(LightningElement) {
    @track recordId;
    @api recordId;
    userEmail;
    reportData = [];
    error;
    showAccountCase = false;
    isDataLoaded = false;
    isSpinner = true;
    reportDataLenght;
    accountName
    fetchTime;
    rowLimit = 25;
    rowOffSet = 0;
    fullyLoaded;
    labels = {};
    hasAccessForAccount = true;
    noAccessOnAccount = '';

    /****************************************************************************************** 
     * Set the recordId and local storage with recordId.
     * @param {CurrentPageReference} i - The containing the current page reference.
     *****************************************************************************************/
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            if (this.recordId !== undefined) {
                this.showAccountCase = true;
                this.init();
            }

            if (currentPageReference.state.c__value !== undefined && currentPageReference.state.c__value !== null) {
                this.recordId = currentPageReference.state.c__value;
            }
        }
    }

    /****************************************************************************************** 
     * Return the get user record details and set the init.
     * @param { recordId: USER_ID, fields: ['User.Email'] } .
     *****************************************************************************************/
    @wire(getRecord, { recordId: USER_ID, fields: ['User.Email', 'User.Name'] })
    wiredUser({ error, data }) {
        if (data) {
            this.userEmail = data.fields.Email.value;
            this.accountName = data.fields.Name.value + ' -';
            this.init();
        } else if (error) {
            this.error = error;
        }
    }

    /****************************************************************************************** 
     * Return the current account name.
     * @param { recordId: '$recordId', fields: ['Account.Name'] }.
     *****************************************************************************************/
    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Name'] })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountName = data.fields.Name.value + ' -';
        } else if (error) {
            this.error = error;
        }
    }

    /****************************************************************************************** 
    * Return the labels and set the map.
    * @param { } .
    *****************************************************************************************/
    @wire(getLabel)
    getLabels({ error, data }) {
        if (data) {
            let labels = {};
            data.forEach(lab => {
                labels[lab.Name] = lab.Value__c;
            });

            this.labels = labels;
        } else if (error) {
            console.error('Error fetching labels:', error);
        }
    }

    /****************************************************************************************** 
     * Init the view cases with account & user email.
     * @param .
     *****************************************************************************************/
    init() {
        if (!this.showAccountCase && (this.userEmail !== null && this.userEmail !== undefined) && (this.recordId === null || this.recordId === undefined)) {
            return this.getValueFromApex(null, this.userEmail);
        } else if ((this.recordId !== null && this.recordId !== undefined)) {
            if (!this.showAccountCase) {
                return this.getValueFromApex(this.recordId, null);
            } else {
                this.hasAccess();
            }
        }
    }


    connectedCallback() {
        window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
        const date = new Date();
        const options = {
            weekday: 'long',
            timeZone: TIME_ZONE,
            year: 'numeric',
            month: 'long',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            hour12: true,
            timeZoneName: 'short'
        };
        this.fetchTime = new Intl.DateTimeFormat('en-US', options).format(date);
    }

    /****************************************************************************************** 
     * Return the data from the apex.
     * @param {recordId, userEmail} pass record id & user email.
    *****************************************************************************************/
    getValueFromApex(recordId, userEmail) {
        return getReportData({ accountId: recordId, userEmail: userEmail, limitSize: this.rowLimit, offset: this.rowOffSet }).
            then((data, error) => {
                if (data) {
                    let accParsedData = JSON.parse(JSON.stringify(data));
                    accParsedData.forEach(acc => {
                        if (acc.AccountId__r) {
                            acc.accountURL = `/lightning/r/${acc.AccountId__r.Id}/view`;
                            acc.AccountId__Name__c = acc.AccountId__r.Name__c;
                        }
                        if (acc.AccountId__r) {
                            acc.caseURL = `/lightning/r/${acc.Id}/view`;
                            acc.AccountId__Name__c = acc.AccountId__r.Name__c;
                        }
                        if (acc.Contact__r) {
                            acc.contactUrl = `/lightning/r/${acc.Contact__r.Id}/view`;
                            acc.Contact__Name__c = acc.Contact__r.Name__c;
                        }
                        if (acc.Product__r) {
                            acc.productUrl = `/lightning/r/${acc.Product__r.Id}/view`;
                            acc.Product__Name__c = acc.Product__r.Name__c;
                        }
                        if (acc.CreatedDate__c) {
                            let createdDate = acc.CreatedDate__c;
                            let formattedDateTime = this.formatDateTime(createdDate);
                            acc.CreatedDate__c = formattedDateTime;
                        }
                        if (acc.ClosedDate__c) {
                            let closedDate = acc.ClosedDate__c;
                            let formattedDateTime = this.formatDateTime(closedDate);
                            acc.ClosedDate__c = formattedDateTime;
                        }
                    });
                    let updatedRecords = [...this.reportData, ...accParsedData];
                    if (this.reportData.length === updatedRecords.length) {
                        this.fullyLoaded = true;
                    }
                    this.reportData = updatedRecords;
                    this.reportDataLenght = this.reportData.length > 10 ? this.reportData.length + '+' : this.reportData.length;
                    this.error = undefined;
                    this.isSpinner = false;
                } else if (error) {
                    this.error = error;
                    this.reportData = undefined;
                    const event = new ShowToastEvent({
                        label: 'Error',
                        message: this.labels.NoAccountIdEmail,
                        variant: 'error',
                        mode: 'dismissible'
                    });
                    this.dispatchEvent(event);
                }
            })
    }

    /****************************************************************************************** 
     * Return the formatted datetime value for createddate and closed date.
     * @param 
    *****************************************************************************************/
    formatDateTime(datetime) {
        const date = new Date(datetime);
        const options = {
            timeZone: TIME_ZONE,
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        };
        return new Intl.DateTimeFormat('en-US', options).format(date);
    }

    /****************************************************************************************** 
     * Return the colums for view cases.
     * @param 
    *****************************************************************************************/
    get columns() {
        var getFieldLabel = ICSCase.split(',');
        var optionsForAccount = [];
        var optionsForAAQ = [];
        getFieldLabel.forEach(currentItem => {
            if (currentItem !== 'Id') {
                var objectKey = {};
                if (currentItem === 'AccountId__r.Name__c') {
                    objectKey.label = 'Account Name';
                    objectKey.fieldName = 'accountURL';
                    objectKey.type = 'url';
                    objectKey.typeAttributes = {
                        label: { fieldName: 'AccountId__Name__c' },
                        target: '_self'
                    };
                    objectKey.sortable = false;

                } else if (currentItem === 'Contact__r.Name__c') {
                    objectKey.label = 'Contact Name';
                    objectKey.fieldName = 'contactUrl';
                    objectKey.type = 'url';
                    objectKey.typeAttributes = {
                        label: { fieldName: 'Contact__Name__c' },
                        target: '_self'
                    };
                    objectKey.sortable = false;
                } else if (currentItem === 'Product__r.Name__c') {
                    objectKey.label = 'Product Name';
                    objectKey.fieldName = 'productUrl';
                    objectKey.type = 'url';
                    objectKey.typeAttributes = {
                        label: { fieldName: 'Product__Name__c' },
                        target: '_self'
                    };
                    objectKey.sortable = false;
                }
                else if (currentItem === 'CaseNumber__c') {
                    objectKey.label = 'Case Number';
                    objectKey.fieldName = 'caseURL';
                    objectKey.type = 'url';
                    objectKey.typeAttributes = {
                        label: { fieldName: 'CaseNumber__c' },
                        target: '_self'
                    };
                    objectKey.sortable = false;
                } else if (currentItem === 'API_Origin_c__c') {
                    objectKey.label = 'Sub Origin';
                    objectKey.fieldName = currentItem;
                } else {
                    objectKey.label = currentItem.replace('__c', ' ').replace('_', ' ').replace('_c', ' ');
                    objectKey.fieldName = currentItem;
                }
                if (currentItem !== 'AccountId__r.Name__c' && currentItem !== 'Contact__r.Name__c' && !localStorage.getItem('recordId')) {
                    optionsForAAQ.push(objectKey);
                }
                optionsForAccount.push(objectKey);
            }
        });
        return localStorage.getItem('recordId') ? optionsForAccount : optionsForAAQ;
    }

    /****************************************************************************************** 
     * Set the event for load more data if not fully loaded.
     * @param {event} contain the current event.
    *****************************************************************************************/
    loadMoreData(event) {
        const { target } = event;
        if (!this.fullyLoaded) {
            target.isLoading = true;
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            this.init().then(() => {
                target.isLoading = false;
            });
        } else {
            target.enableInfiniteLoading = false;
        }

    }

    /****************************************************************************************** 
      * Set the before unload handler.
      * @param .
     *****************************************************************************************/
    beforeUnloadHandler() {
        localStorage.removeItem("recordId");
    }

    hasAccess() {
        return hasAccess({ recordId: this.recordId, userId: USER_ID })
            .then((data, error) => {
                if (data === true) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'View_ICS_Case',
                        },
                        state: {
                            c__value: this.recordId
                        }
                    });
                } else {
                    this.hasAccessForAccount = false;
                    this.isSpinner = false;
                    this.reportData = undefined;
                    this.noAccessOnAccount = this.labels.NoAccessToAccount;
                }
            });
    }
}