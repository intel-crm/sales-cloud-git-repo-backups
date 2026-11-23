import { LightningElement, wire, track, api } from 'lwc';
import serachContacts from '@salesforce/apex/PRM_AddContactsToGroupController.fetchContactsData';
import insertContactGrContAssRecords from '@salesforce/apex/PRM_AddContactsToGroupController.insertContactGrContAssRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PRM_AddContToGR_ErrorMsg from '@salesforce/label/c.PRM_AddContToGR_ErrorMsg';
import PRM_AddContToGR_SuccessMsg from '@salesforce/label/c.PRM_AddContToGR_SuccessMsg';
import PRM_EnterContactEmail_Search from '@salesforce/label/c.PRM_EnterContactEmail_Search';
import PRM_AddContToGrComp_NoCriteria from '@salesforce/label/c.PRM_AddContToGrComp_NoCriteria';
import PRM_Contact_Name from '@salesforce/label/c.PRM_Contact_Name';
import PRM_First_Name from '@salesforce/label/c.PRM_First_Name';
import PRM_Last_Name from '@salesforce/label/c.PRM_Last_Name';
import PRM_Partner_Role_Column from '@salesforce/label/c.PRM_Partner_Role_Column';
import PRM_Email_Column from '@salesforce/label/c.PRM_Email_Column';
import PRM_Phone_Column from '@salesforce/label/c.PRM_Phone_Column';
//import PRM_EmptySearchInput_ErrMsg from '@salesforce/label/c.PRM_EmptySearchInput_ErrMsg';

const columns = [
    {
        label: PRM_Contact_Name,
        fieldName: 'nameUrl',
        type: 'url',
        initialWidth: 270,
        typeAttributes: { label: { fieldName: 'contactName' }, target: '_blank' }
    }, {
        label: PRM_First_Name,
        fieldName: 'contactFirstName',
        type: 'text'
    }, {
        label: PRM_Last_Name,
        fieldName: 'contactLastName',
        type: 'text'
    }, {
        label: PRM_Partner_Role_Column,
        fieldName: 'contactPartnerRole',
        type: 'text'
    }, {
        label: PRM_Email_Column,
        fieldName: 'contactEmail',
        type: 'text'
    }, {
        label: PRM_Phone_Column,
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
                    message: PRM_EnterContactEmail_Search,
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
                            message: PRM_AddContToGrComp_NoCriteria,
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
                            message: PRM_AddContToGR_SuccessMsg,
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
                            message: PRM_AddContToGR_ErrorMsg,
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