import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import QUOTETEAM_OBJECT from '@salesforce/schema/Pricing_Quote_Team__c';
import ROLE_FIELD from '@salesforce/schema/Pricing_Quote_Team__c.Pricing_Role_Nm__c';
//import getDefaultData from '@salesforce/apex/Pricing_QuoteTeam_SharingController.getDefaultData';
import getQuoteTeam from '@salesforce/apex/Pricing_QuoteTeam_SharingController.getQuoteTeam';
import createQuoteTeamMember from '@salesforce/apex/Pricing_QuoteTeam_SharingController.createQuoteTeamMember';
import removeQuoteTeamMember from '@salesforce/apex/Pricing_QuoteTeam_SharingController.removeQuoteTeamMember';
import findRecords from '@salesforce/apex/Pricing_QuoteTeam_SharingController.findRecords';
import isInternal from '@salesforce/apex/Pricing_QuoteTeam_SharingController.isInternal';
import getQuoteName from '@salesforce/apex/Pricing_QuoteTeam_SharingController.getCurrentQuoteName';
import recordAdded from '@salesforce/label/c.Pricing_QuoteTeamLWC_SuccessAdd';
import duplicateUser from '@salesforce/label/c.Pricing_QuoteTeamLWC_DuplicateUser';
import noRecordSelected from '@salesforce/label/c.Pricing_QuoteTeamLWC_RecordSelect';
import roleEmpty from '@salesforce/label/c.Pricing_QuoteTeamLWC_RoleEmpty';
import recordRemoved from '@salesforce/label/c.Pricing_QuoteTeamLWC_SuccessRemove';
import validUser from '@salesforce/label/c.Pricing_QuoteTeamLWC_ValidUser';
import FSEError from '@salesforce/label/c.Pricing_Tender_Quote_SalesRep_Submit_Error_Message';
import FSERole from '@salesforce/label/c.Pricing_Quote_Team_Role_FSE';
import isDPMLegalFinance from '@salesforce/apex/Pricing_QuoteTeam_SharingController.isDPMLegalFinanceUser';
import getFSEUsers from '@salesforce/apex/Pricing_QuoteTeam_SharingController.getQuoteFSEUsers';

const intelEmailDomain = '^([a-zA-Z0-9.\\_]{2,64})*@intel.com$';
export default class Pricing_Manage_QuoteTeam extends LightningElement {
    @track defaultData;
    @api recordId;
    @track resultList;
    @track quoteTeamMemberList;
    @track quoteTeamList;
    @track quoteTeamMember;
    @track wiredquoteTeamMemberList = [];
    @track userEmail;
    @track userRole;
    @track errorMsg = '';
    @track isSpinner = false;
    @track isDPMLegalFinanceUser;
    @track reassignPrimaryFSE = false;

    //*********US748996*********
    @track recordsList;
    @track searchKey = '';
    @api selectedValue;
    @track selectedRecord;
    @api selectedRecordEmail;
    @api lookupLabel;
    @track message;
    @track isInternalUser;
    typingTimer;
    //@track isFSE;
    //*********US748996*********

    //**************Pagination*************/
    @track currentPageNumber;
    @track totalPages;
    @track totalNoOfRecords;
    @track recordsPerPage = 4;
    @track iterationStarting;
    @track iterationEnding;
    //**************Pagination*************/

    @track columnsInternal = [
        { label: 'User', fieldName: 'teamMemberName', type: 'text' },
        { label: 'Team Role', fieldName: 'role', type: 'text' },
        {
            label: 'AGS Access Granted?', fieldName: 'isAcessGranted', type: 'boolean',
            typeAttributes: { tooltip: { fieldName: 'isAcessGranted', label: 'Does user has access?', iconName: 'utility:info' } }
        }
    ];

    @track columnsExternal = [
        { label: 'User', fieldName: 'teamMemberName', type: 'text' },
        { label: 'Team Role', fieldName: 'role', type: 'text' }
    ];

    @wire(getObjectInfo, { objectApiName: QUOTETEAM_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ROLE_FIELD })
    rolePicklistValues;

    @wire(isInternal) internalCheck(result) {
        const { data, error } = result;
        if (data) {
            if (data === true) {
                this.isInternalUser = true;
            } else {
                this.isInternalUser = false;
            }
        } else if (error) {
            console.log('Error -->' + JSON.stringify(this.error));
        }
    }

    @wire(isDPMLegalFinance) dpmLegalCheck(result) {
        const { data, error } = result;
        if (data) {
            if (data === true) {
                this.isDPMLegalFinanceUser = true;
            } else {
                this.isDPMLegalFinanceUser = false;
            }
        } else if (error) {
            console.log('Error -->' + JSON.stringify(this.error));
        }
    }

    get selectedRole() {
        return (this.userRole == "FSE/SDM");
    }

    @track quoteName;

    connectedCallback() {

        this.getQuoteTeamMembers();
        getQuoteName({ quoteId: this.recordId }) //
            .then(result => {
                console.log('this.result connected callback--' + result);
                this.quoteName = result;
            });
    }

    getQuoteTeamMembers() {
        getQuoteTeam({ quoteId: this.recordId }) //
            .then(result => {
                this.resultList = result;
                this.quoteTeamMemberList = [];
                this.iterationStarting = 0;
                this.iterationEnding = this.recordsPerPage;
                for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                    if (result[i] !== undefined) {
                        this.quoteTeamMemberList.push(result[i]);
                    }
                }
                this.currentPageNumber = 1;
                this.totalNoOfRecords = result.length;
                this.totalPages = Math.ceil(result.length / this.recordsPerPage);
                this.isSpinner = false;
                console.log('Quote team Member List-->' + JSON.stringify(this.quoteTeamMemberList));
            });
    }

    handleEmailChange(event) {
        this.userEmail = event.target.value;
        this.errorMsg = '';
    }

    handleRoleChange(event) {
        this.errorMsg = '';
        this.userRole = event.target.value;
        this.reassignPrimaryFSE = false;
    }

    handleSaveClick() {
        let emailCheck;
        let isPresent = false;
        let isValidUser = false;
        if (this.isInternalUser) {
            emailCheck = this.selectedRecordEmail;
        } else {
            emailCheck = this.userEmail;
        }
        const patt = new RegExp('^([a-zA-Z0-9.\\_]{2,64})*@intel.com$');

        if (this.selectedRecordEmail !== null || this.selectedRecordEmail !== undefined || patt.test(this.userEmail)) {

            for (let i = 0; i < this.resultList.length; i++) {
                if (emailCheck === this.resultList[i].userEmail) {
                    isPresent = true;
                    break;
                }
            }
            isValidUser = true;
        }
        if (this.userRole !== undefined && !isPresent && isValidUser) {
            this.isSpinner = true;
            createQuoteTeamMember({ teamMemberEmail: emailCheck, quoteId: this.recordId, role: this.userRole, reassignPrimaryFSE: this.reassignPrimaryFSE }) //
                .then(result => {
                    this.message = result;
                    this.error = null;

                    if (result !== null && result !== undefined) {
                        this.userEmail = null;
                        this.userRole = undefined;
                        this.errorMsg = null;
                        this.template.querySelector('.comboboxClass').selectedIndex = 0;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: recordAdded + this.quoteName,
                                variant: 'success',
                            }),
                        );
                        this.removeRecordOnLookup();
                        this.refreshPage();
                    }           
                    else if (result === null && this.userRole === FSERole) {
                        console.log('error');
                        this.errorMsg = FSEError;
                    }
                    else if (result === null) {
                        this.errorMsg = validUser;
                        this.isSpinner = false;
                    }
                    this.getQuoteTeamMembers();
                })
                .catch(error => {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: (error !== null && error != '' && error !== undefined) ? error.body.message : 'Error occured while processing the request Please Contact IQR Team',
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                    this.isSpinner = false;
                });
        } else if (isPresent) {
            this.errorMsg = duplicateUser;
        } else if (!isValidUser) {
            this.errorMsg = validUser;
        } else if (this.userRole === undefined) {
            this.errorMsg = roleEmpty;
        }
    }

    //*********US748996*********
    onLeave(event) {
        setTimeout(() => {
            this.searchKey = '';
            this.recordsList = null;
        }, 300);
    }

    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.searchKey = '';
        this.selectedRecord = this.recordsList.find(element => element.Name === this.selectedValue);

        this.selectedRecordEmail = this.selectedRecord.Email;
        this.onSeletedRecordUpdate();
    }

    handleKeyChange(event) {
        clearTimeout(this.typingTimer);
        const searchKey = event.target.value;
        this.searchKey = searchKey;
        const thisKey = this;
        console.log(searchKey);
        this.typingTimer = setTimeout(function () {
            console.log('thisKey.getLookupResult')
            thisKey.getLookupResult();
        }.bind(this), 1000);
    }

    handleKeyDown(event) {
        clearTimeout(this.typingTimer);
    }

    removeRecordOnLookup(event) {
        this.searchKey = '';
        this.selectedValue = null;
        this.selectedRecordId = null;
        this.recordsList = null;
        this.selectedRecord = null;
        this.selectedRecordEmail = null;
    }

    getLookupResult() {
        findRecords({ searchKey: this.searchKey })
            .then((result) => {
                if (result.length === 0) {
                    this.recordsList = [];
                    this.message = 'No Records Found';
                } else {
                    this.recordsList = result;
                    this.message = '';
                }
                this.error = null;
            })
            .catch((error) => {
                this.error = error;
                this.recordsList = null;
            });

    }

    onSeletedRecordUpdate() {
        const passEventr = new CustomEvent('recordselection', {
            detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }
        });
        this.dispatchEvent(passEventr);
    }

    onRemoveButtonClick(event) {
        this.isSpinner = true;
        let selectedRecords = this.template.querySelector('lightning-datatable').getSelectedRows(); // NOSONAR
        let selectCombo = this.template.querySelector('.comboboxClass'); // NOSONAR
        let selectedIds = []; // NOSONAR
        if (selectedRecords.length === 0) {
            this.errorMsg = noRecordSelected;
            this.isSpinner = false;
        } else {
            for (let i = 0; i < selectedRecords.length; i++) {
                selectedIds.push(selectedRecords[i].teamMemberId);
            }
            removeQuoteTeamMember({ teamMemberIds: selectedIds, quoteId: this.recordId })
                .then(result => {
                    this.message = result;
                    console.log('this.message.isSuccess', result);
                    console.log('this.message.message', result.message);
                    this.error = null;
                    if (result !== null && result !== undefined && result.isSuccess) {
                        //this.userEmail = null;
                        //this.userRole = undefined;
                        this.template.querySelector('lightning-datatable').maxRowSelection = 0;
                        this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: recordRemoved + this.quoteName,
                                variant: 'success',
                            }),
                        );
                        // selectCombo.value = '';
                        this.errorMsg = null;
                        this.isSpinner = false;
                        this.getQuoteTeamMembers();
                        this.refreshPage();
                    }
                    else if (!result.isSuccess) {
                        this.errorMsg = result.message;
                        this.isSpinner = false;
                    }

                });
        }
    }
    //*********US748996*********

    handleChange(event) {
        this.quoteTeamMemberList = [];
        for (let i = 0; i < event.target.value; i++) {
            if (this.resultList.data[i] !== undefined) {
                this.quoteTeamMemberList.push(this.resultList.data[i]);
            }
        }
    }


    //**************Pagination*************/
    onPrevious() {
        if (this.iterationStarting > 0) {
            this.currentPageNumber = this.currentPageNumber - 1;
            this.iterationStarting = this.iterationStarting - this.recordsPerPage;
            this.iterationEnding = this.iterationEnding - this.recordsPerPage;
            this.quoteTeamMemberList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList[i] !== undefined) {
                    this.quoteTeamMemberList.push(this.resultList[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }
    }

    onNext() {
        if (this.currentPageNumber < this.totalPages) {
            this.currentPageNumber = this.currentPageNumber + 1;
            this.iterationStarting = this.iterationStarting + this.recordsPerPage;
            this.iterationEnding = this.iterationEnding + this.recordsPerPage;
            this.quoteTeamMemberList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList[i] !== undefined) {
                    this.quoteTeamMemberList.push(this.resultList[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }
    }

    get disablePreviousButtom() {
        return (this.iterationStarting === 0);
    }
    get disableNextButtom() {
        return (this.currentPageNumber === this.totalPages) || (this.currentPageNumber > this.totalPages);
    }

    get hasRecords() {
        return (this.totalNoOfRecords !== 0);
    }

    onLast() {
        if (this.currentPageNumber < this.totalPages) {
            this.currentPageNumber = this.totalPages;
            this.iterationStarting = (this.recordsPerPage * this.totalPages) - this.recordsPerPage;
            this.iterationEnding = this.recordsPerPage * this.totalPages;
            this.quoteTeamMemberList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList[i] !== undefined) {

                    this.quoteTeamMemberList.push(this.resultList[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }

    }

    onFirst() {
        if (this.iterationStarting > 0) {
            this.currentPageNumber = 1;
            this.iterationStarting = 0;
            this.iterationEnding = this.recordsPerPage;
            this.quoteTeamMemberList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList[i] !== undefined) {
                    this.quoteTeamMemberList.push(this.resultList[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }
    }
    //**************Pagination*************/

    onRefreshClick() {
        this.isSpinner = true;
        this.getQuoteTeamMembers();
        this.isSpinner = false;
    }

    refreshPage() {
        eval('$A.get(\'e.force:refreshView\').fire();');
    }

    selectChange(event) {
        this.errorMsg = '';
        this.userRole = event.target.value;
    }

    handleFSEtoGroupAdd() {
        this.isSpinner = true;
        let quoteIdList = [];
        quoteIdList.push(this.recordId);
        getFSEUsers({ quoteIds: quoteIdList })
            .then(result => {
                if (result != undefined) {
                    let msgTitle = result['type'] === 'info' ? 'Information' : result['type'] === 'success' ? 'Success' : 'Error';
                    const toastMessage = new ShowToastEvent({
                        title: msgTitle,
                        message: result['msg'],
                        variant: result['type'],
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(toastMessage);
                }
                this.isSpinner = false;
            })
            .catch(error => {
                console.log('error===>', JSON.stringify(error));
                this.isSpinner = false;

            });
    }

    //primary fse change
    /*primyFSECheck(event) {
        this.reassignPrimaryFSE = event.target.checked;
        console.log(event.target.checked);
    }*/
}