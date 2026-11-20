import { LightningElement, wire, track, api } from 'lwc';
import serachContacts from '@salesforce/apex/PRM_AddContactsToGroupController.fetchContactsData';
import insertContactGrContAssRecords from '@salesforce/apex/PRM_AddContactsToGroupController.insertContactGrContAssRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import PRM_EmptySearchInput_ErrMsg from '@salesforce/label/c.PRM_EmptySearchInput_ErrMsg';

const columns = [
    {
        label: 'Contact Name',
        fieldName: 'nameUrl',
        type: 'url',
        initialWidth: 270,
        typeAttributes: { label: { fieldName: 'contactName' }, target: '_blank' }
    }, {
        label: 'First Name',
        fieldName: 'contactFirstName',
        type: 'text'
    }, {
        label: 'Last Name',
        fieldName: 'contactLastName',
        type: 'text'
    }, {
        label: 'Partner Role',
        fieldName: 'contactPartnerRole',
        type: 'text'
    }, {
        label: 'Email',
        fieldName: 'contactEmail',
        type: 'text'
    }, {
        label: 'Phone',
        fieldName: 'contactPhone',
        type: 'text'
    }
];

export default class PRMAddContactsToGrComponent extends LightningElement {
    @track searchData = [];
    @track columns = columns;
    @track contactSearchStr = '';
    @track isSearchData = false;
    @track selectedlst = [];
    @api recordId;
    @track allValid;

    handleContactDetails(event) {
        this.contactSearchStr = event.detail.value;
        console.log('Conatct Email:-', this.contactSearchStr);
        this.allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        console.log('allValid:-', this.allValid);
        if (this.allValid === false) {
            console.log('InValid');
            this.isSearchData = false;
            this.searchData = [];
        }
    }
    /*handleError(event) {
        console.log('Error:-', event.detail.value);
        this.searchData = [];
    }*/

    handleSearch() {

        if (!this.contactSearchStr) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter contact email to search',
                    variant: 'error',
                }),
            );
            this.searchData = [];
            this.isSearchData = false;
            return;
        }

        serachContacts({ contactEmail: this.contactSearchStr, currentContactGrId: this.recordId })
            .then(result => {

                if (result !== null && result !== undefined && result.length > 0) {
                    let nameUrl;
                    this.searchData = result.map(row => {
                        nameUrl = `/${row.id}`;

                        return { ...row, nameUrl }
                    })
                    if (this.searchData) {
                        this.isSearchData = true;
                        console.log('isSearchData:-', this.isSearchData);
                    }
                    console.log('Search data:-', JSON.stringify(this.searchData));
                    //this.selectedrows = [];
                    //return refreshApex(this.searchData);
                } else {
                    console.log('ELSE');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'No Record found with criteria or Records are already exist.',
                            variant: 'error',
                        }),
                    );
                    this.contactSearchStr = '';
                    this.searchData = [];
                    this.isSearchData = false;
                }
            })
    }
    handleSelContacts() {
        this.selectedlst = this.template.querySelector('lightning-datatable').getSelectedRows();
        console.log('selectedlst:-', JSON.stringify(this.selectedlst));
        console.log('current gr:-', this.recordId);
        insertContactGrContAssRecords({ lstOfSelContacts: this.selectedlst, currentContactGrId: this.recordId })
            .then(result => {
                if (result === 'Success') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Contacts are associated to group successfully.',
                            variant: 'success',
                        }),
                    );
                    this.isSearchData = false;
                    this.selectedlst = [];
                    this.searchData = [];
                }
                if (result === 'Failed') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error While Creating Records.',
                            variant: 'Error',
                        }),
                    );
                    this.isSearchData = false;
                    this.selectedlst = [];
                    this.searchData = [];
                }

            })
        this.contactSearchStr = '';
    }
}