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
import findRecords from "@salesforce/apex/Pricing_QuoteTeam_SharingController.findRecords";
import isInternal from "@salesforce/apex/Pricing_QuoteTeam_SharingController.isInternal";
import { refreshApex } from '@salesforce/apex';

export default class Pricing_AEsharing extends LightningElement {
    @track defaultData;
    @api recordId;
    @track resultList;
    @track quoteTeamMemberList;
    @track quoteTeamList;
    @track quoteTeamMember;
    @track wiredquoteTeamMemberList = [];
    @track userEmail;
    @track userRole;
    intelEmailDomain = '^([a-zA-Z0-9.\\_]{​​​​2,64}​​​​)*@intel.com$';

    //*********US748996*********
    @track recordsList;
    @track searchKey = "";
    @api selectedValue;
    @track selectedRecord;
    @api selectedRecordEmail;
    @api lookupLabel;
    @track message;
    @track isInternalUser;
    //*********US748996*********

    //**************Pagination*************/
    @track currentPageNumber;
    @track totalPages;
    @track totalNoOfRecords;
    @track recordsPerPage = 5;
    @track iterationStarting;
    @track iterationEnding;
    //**************Pagination*************/

    @track columns = [
        { label: 'User', fieldName: 'teamMemberName', type: 'text' },
        { label: 'Role', fieldName: 'role', type: 'text' },
        { label: 'Access Granted?', fieldName: 'isAcessGranted', type: 'boolean' }
    ];



    @wire(getObjectInfo, { objectApiName: QUOTETEAM_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ROLE_FIELD })
    rolePicklistValues;

    @wire(isInternal) internalCheck(result) {
        const { data, error } = result;
        if (data) {
            // this.quoteTeamMemberList = data;
            if (data == true) {
                this.isInternalUser = true;
            } else {
                this.isInternalUser = false;
            }
        } else if (error) {
            console.log('Error -->' + JSON.stringify(this.error));
        }
    }

    @wire(getQuoteTeam, { quoteId: '$recordId' })
    wiredquoteTeamMemberList(result) {
        this.resultList = result;
        const { data, error } = result;
        if (data) {
            // this.quoteTeamMemberList = data;
            this.quoteTeamMemberList = [];
            this.iterationStarting = 0;
            this.iterationEnding = this.recordsPerPage
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (data[i] != undefined) {
                    this.quoteTeamMemberList.push(data[i]);
                }
            }
            this.currentPageNumber = 1;
            this.totalNoOfRecords = data.length;
            this.totalPages = Math.ceil(data.length / this.recordsPerPage);
            console.log('Quote team Member List-->' + JSON.stringify(this.quoteTeamMemberList));
        } else if (error) {
            this.error = error;
            console.log('Error -->' + JSON.stringify(this.error));
        }
    }

    get options() {
        return [
            { label: '4', value: 4 },
            { label: '8', value: 8 },
            { label: '10', value: 10 },
            { label: '11', value: 11 }
        ];
    }
    /*
    connectedCallback() {
        /* getDefaultData({ quoteId: this.recordId })
             .then(result => {
                 this.defaultData = result;
                 console.log('Default Data-->', this.defaultData);
             })
             .catch(error => {
                 this.error = error;
                 console.log('Error-->', this.error);
             }); 

    } */

    handleEmailChange(event) {
        this.userEmail = event.target.value;
    }

    handleRoleChange(event) {
        this.userRole = event.target.value;
    }

    handleSaveClick() {
        let emailCheck;
        console.log('internal user-- ' + this.isInternalUser);
        if (this.isInternalUser) {
            emailCheck = this.selectedRecordEmail;
            console.log("isInternal");
        } else {
            emailCheck = this.userEmail;
            console.log("not isInternal");
        }
        if (this.userRole != undefined) {
            createQuoteTeamMember({ teamMemberEmail: emailCheck, quoteId: this.recordId, role: this.userRole }) //
                .then(result => {
                    this.message = result;
                    this.error = undefined;
                    console.log('Result->', JSON.stringify(result));
                    if (result !== null && result !== undefined) {
                        this.userEmail = null;
                        this.userRole = null;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Quote Team Member added Successfully.',
                                variant: 'success',
                            }),
                        );
                        this.removeRecordOnLookup();
                    } else if (result == null) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '',
                                message: 'Quote Team Member cannot be added',
                                variant: 'error',
                            }),
                        );
                    }
                    refreshApex(this.resultList);
                    console.log("Refresh Apex", this.quoteTeamMemberList);
                })
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'Role cannot be empty',
                    variant: 'error',
                }),
            );

        }
    }

    handleClick(event) {

    }


    //*********US748996*********
    onLeave(event) {
        setTimeout(() => {
            this.searchKey = "";
            this.recordsList = null;
        }, 300);
    }

    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.searchKey = "";
        this.selectedRecord = this.recordsList.find(element => element.Name == this.selectedValue);

        this.selectedRecordEmail = this.selectedRecord.Email;
        console.log(this.selectedRecordEmail);
        this.onSeletedRecordUpdate();
    }

    handleKeyChange(event) {
        const searchKey = event.target.value;
        this.searchKey = searchKey;
        this.getLookupResult();
    }

    removeRecordOnLookup(event) {
        this.searchKey = "";
        this.selectedValue = null;
        this.selectedRecordId = null;
        this.recordsList = null;
        this.onSeletedRecordUpdate();
    }

    getLookupResult() {
        findRecords({ searchKey: this.searchKey })
            .then((result) => {
                if (result.length === 0) {
                    this.recordsList = [];
                    this.message = "No Records Found";
                } else {
                    this.recordsList = result;
                    this.message = "";
                }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.recordsList = undefined;
            });
    }

    onSeletedRecordUpdate() {
        const passEventr = new CustomEvent('recordselection', {
            detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }
        });
        this.dispatchEvent(passEventr);
    }

    onRemoveButtonClick(event) {

        let selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('selectedRecords-- ' + JSON.stringify(selectedRecords));
        let selectedIds = [];
        for (let i = 0; i < selectedRecords.length; i++) {
            selectedIds.push(selectedRecords[i].teamMemberId);
        }
        console.log('selectedNames--' + selectedIds);
        removeQuoteTeamMember({ teamMemberIds: selectedIds, quoteId: this.recordId })
            .then(result => {
                this.message = result;
                this.error = undefined;
                console.log('Result->', JSON.stringify(result));
                if (result !== null && result !== undefined && result == true) {
                    this.userEmail = null;
                    this.userRole = null;
                    this.template.querySelector('lightning-datatable').maxRowSelection = 0;
                    this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Quote Team Member removed Successfully.',
                            variant: 'success',
                        }),
                    );
                } else if (result == null || result == false) {
                    this.message = undefined;
                    this.error = error;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in removing record',
                            message: '', // error.body.message,
                            variant: 'error',
                        }),
                    );
                    console.log("error", JSON.stringify(this.error));
                }
                refreshApex(this.resultList);
            })
            .catch(error => {
                this.message = undefined;
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error in removing record',
                        message: '', // error.body.message,
                        variant: 'error',
                    }),
                );
                console.log("error", JSON.stringify(this.error));
            });
    }
    //*********US748996*********

    handleChange(event) {
        this.quoteTeamMemberList = [];
        for (let i = 0; i < event.target.value; i++) {
            if (this.resultList.data[i] != undefined) {
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
                if (this.resultList.data[i] != undefined) {
                    this.quoteTeamMemberList.push(this.resultList.data[i]);
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
                if (this.resultList.data[i] != undefined) {
                    this.quoteTeamMemberList.push(this.resultList.data[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }
    }

    get disablePreviousButtom() {
        return (this.iterationStarting == 0);
    }
    get disableNextButtom() {
        return (this.currentPageNumber == this.totalPages);
    }

    onLast() {
        if (this.currentPageNumber < this.totalPages) {
            this.currentPageNumber = this.totalPages;
            this.iterationStarting = (this.recordsPerPage * this.totalPages) - this.recordsPerPage;
            this.iterationEnding = this.recordsPerPage * this.totalPages;
            this.quoteTeamMemberList = [];
            for (let i = this.iterationStarting; i < this.iterationEnding; i++) {
                if (this.resultList.data[i] != undefined) {
                    this.quoteTeamMemberList.push(this.resultList.data[i]);
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
                if (this.resultList.data[i] != undefined) {
                    this.quoteTeamMemberList.push(this.resultList.data[i]);
                }
            }
            this.template.querySelector('lightning-datatable').maxRowSelection = 0;
            this.template.querySelector('lightning-datatable').maxRowSelection = this.recordsPerPage;
        }
    }
    //**************Pagination*************/

    onRefreshClick() {
        refreshApex(this.resultList);
    }
}