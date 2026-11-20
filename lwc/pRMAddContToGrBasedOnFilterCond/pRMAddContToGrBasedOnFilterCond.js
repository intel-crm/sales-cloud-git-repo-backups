import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchContactGroups from '@salesforce/apex/PRM_AddContToGrBasedOncondController.fetchContactGroups';
import fetchContacts from '@salesforce/apex/PRM_AddContToGrBasedOncondController.fetchContacts';
import insertContactGrContAssRecords from '@salesforce/apex/PRM_AddContToGrBasedOncondController.insertContactGrContAssRecords';
import PRM_NonExistContData_Notification from '@salesforce/label/c.PRM_NonExistContData_Notification';
import PRM_AddContToGR_ErrorMsg from '@salesforce/label/c.PRM_AddContToGR_ErrorMsg';
import PRM_AddContToGR_SuccessMsg from '@salesforce/label/c.PRM_AddContToGR_SuccessMsg';
import PRM_SelectcontGrNotification from '@salesforce/label/c.PRM_SelectcontGrNotification';
import PRM_SuccessLabel from '@salesforce/label/c.PRM_SuccessLabel';
import PRM_FailedLabel from '@salesforce/label/c.PRM_FailedLabel';


export default class PRMAddContToGrBasedOnFilterCond extends LightningElement {
    //@track searchData = [];
    @track selectedValue = '';
    @track isSearchData = false;
    @track contactGrpList = [];
    @track error;
    @api recordId;
    @track spinner = false;
    @track contactLst = [];
    @track isdisable = false;


    @wire(fetchContactGroups, {})
    contactGrlst({ error, data }) {
        if (data) {
            this.contactGrpList = data;
            this.error = undefined;
            console.log('Contact Group List:' + JSON.stringify(this.contactGrpList));
            console.log('API variable RecotdId: ' + this.recordId);
        } else if (error) {
            this.error = error;
            this.contactGrpList = undefined;
            console.log('Error: ' + JSON.stringify(this.error));
        }
    }

    onValueSelection(event) {
        //this.searchData = []; //to clear data in table after selecting new value.
        this.selectedValue = event.target.value;
        console.log('Picklist Selected value:' + this.selectedValue);
        fetchContacts({ currentRecId: this.recordId, currentContactGrId: this.selectedValue }).then(result => {
            if (result !== null && result !== undefined && result.length > 0) {
                this.contactLst = result;
                //this.isSearchData = true;
                this.isdisable = false;
                console.log('Search data:-', JSON.stringify(this.contactLst));

            } else {
                console.log('Empty List');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: PRM_NonExistContData_Notification,
                        variant: 'Error',
                    }),
                );
                this.isdisable = true;
                //this.searchData = [];
                this.isSearchData = false;
            }

        })
    }

    handleSelContacts() {
        this.spinner = true;
        console.log('selectedlst:-', JSON.stringify(this.contactLst));
        console.log('current gr:-', this.recordId);
        if (this.selectedValue === '') {
            this.spinner = false;
            this.isdisable = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: PRM_SelectcontGrNotification,
                    variant: 'Error',
                }),
            );
        } else {
            insertContactGrContAssRecords({ lstOfSelContacts: this.contactLst, currentContactGrId: this.selectedValue })
                .then(result => {
                    if (result === PRM_SuccessLabel) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: PRM_SuccessLabel,
                                message: PRM_AddContToGR_SuccessMsg,
                                variant: PRM_SuccessLabel,
                            }),
                        );
                        //this.isSearchData = false;
                        this.isdisable = true;
                        this.contactLst = [];
                        //this.selectedValue = '';
                    }
                    if (result === PRM_FailedLabel) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: PRM_AddContToGR_ErrorMsg,
                                variant: 'Error',
                            }),
                        );
                        this.isdisable = true;
                        //this.isSearchData = false;
                        this.contactLst = [];
                    }

                })
        }
    }
}