import { LightningElement, wire, track, api } from 'lwc';
import getNewRecords from '@salesforce/apex/Core_MDF_Approval_Requests.getNewRecords';
import getFieldsOfSelectedRecords from '@salesforce/apex/Core_MDF_Approval_Requests.getFieldsOfSelectedRecords';
import approveRejectActivity from '@salesforce/apex/Core_MDF_Approval_Requests.approveRejectActivity';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class Core_MDF_Approval_Request_Poc extends NavigationMixin(LightningElement){
    @track recdId;
    @track recordsToRender;
    @track fieldsToDisplay;
    @track phoneOrDesktop;
    @track formFactor;
    @track buttonClicked;
    @track isModalopen = false;
    @track approvalComments;
    @track popupButtonLabel;
    @track popupHeaderText;
    @track error;
    @track showSpinner = false;
    @track showApproveRejectButton = true;
    formFactor = formFactorPropertyName;
    @api prop1
    @api
    //getter method
    get recId() {
        console.log('Entered' + this.__recId);

        return this._recId;

    }
    //setter method
    set recId(value) {
        if (value) {
            console.log('Entered Inside  First set' + value);
            this._recId = value;
            this.recdId = value;
        } else {
            this._recId = undefined;
        }
    }
    connectedCallback() {
        console.log('@@@' + this.formFactor);
        if (this.formFactor == 'Large') {
            this.phoneOrDesktop = false;
        } else {
            this.phoneOrDesktop = true;
        }
        console.log('@@@' + this.phoneOrDesktop);

        // Fetching Record clicked on Approval Page
        this.fetchRecord();
        //Fetching Details of the record
        this.fetchFieldsOfDetailRecord();
    }
    fetchRecord() {
        console.log('****Entered*********');
        getNewRecords({ recordId: this.recdId })
            .then(data => {
                this.recordsToRender = JSON.parse(data);
                this.error = undefined;
                console.log('$$$ recordToDisplay' + json.stringify(this.recordsToRender))
            })
            .catch(error => {
                this.error = error;
                this.recordToDisplay = undefined;
            });
    }

    fetchFieldsOfDetailRecord() {
        console.log('Entered Inside toggle');

        getFieldsOfSelectedRecords({ recordId: this.recdId })
            .then(data => {
                this.fieldsToDisplay = JSON.parse(data);
                this.error = undefined;
                console.log('$$$ recordToDisplay' + JSON.stringify(this.fieldsToDisplay))
            })
            .catch(error => {
                this.error = error;
                this.recordToDisplay = undefined;
            });
    }
    // Navigate to View  Page
    navigateToViewDetailPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }
    handleToggleSection(event) {

        console.log('Selected Sections ' + event.detail.openSections);

    }
    handleApproveRejectClick(event){
        //this.buttonClicked = event.target.name;
        this.buttonClicked = event.target.title;
        console.log('Button Name => '+this.buttonClicked);
        this.isModalopen = true;
        this.popupButtonLabel = this.buttonClicked;
        this.popupHeaderText = this.buttonClicked + ' Co-Marketing Activity';
    }

    closeModal() {    
        // to close modal window
        this.isModalopen = false;
    }

    handleSave(){
        let curRecId = this.recdId;
        let objRecId = curRecId.substring(1);
        this.showSpinner = true;
        let displayMessage = 'Co-Marketing Activity is ';
        console.log('Approval Comments on Save => '+this.approvalComments);
        console.log('Current Recod Id => '+objRecId);
        console.log('Button Clicked => '+this.buttonClicked);
        if (this.buttonClicked === 'Approve') {
            displayMessage += 'Approved'
        }else if (this.buttonClicked === 'Reject') {
            displayMessage += 'Rejected'
        }
        approveRejectActivity({ recordId: objRecId, approvalComments: this.approvalComments, action: this.buttonClicked})
            .then(result => {
               if (result === true) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: displayMessage,
                            variant: 'success'
                        })
                    );
                    this.showSpinner = false;
                    this.isModalopen = false;
                    this.showApproveRejectButton = false; 
                } else if (result === false) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Failed',
                            message: 'There is an error in Approving the Activity',
                            variant: 'error'
                        })
                    );
                    this.showSpinner = false;
                    this.isModalopen = false;        
                }
            })
            .catch(error => {
                this.error = error;
                this.showSpinner = false;
                console.log('Inside Catch Error => '+error);
            });
     
    }

    handleTextAreaChange(event){
        this.approvalComments = event.target.value;
        console.log('Approval Comments on change=> '+this.approvalComments);
    }

    openPicker(event){
        console.log('Inside Button click');
        let buttonClicked = event.target.title;
        console.log('Clicked Button => '+buttonClicked);
    }
    viewRecord(event) {
var selectedRecId = '';
let isNavigateToStandardPage = false;
selectedRecId = event.target.dataset.recordId;
let selRecId = selectedRecId.substring(1);

        console.log('Clicked Button => '+selRecId);
        console.log(selRecId.startsWith('0RJ'));
        if (selRecId.startsWith('0RJ'))
        {
            isNavigateToStandardPage = true;
            console.log('Activity =>'+isNavigateToStandardPage);
        }
        // Navigate to Account record page
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": selRecId,
                "actionName": "view"
            },
        });
    }
}