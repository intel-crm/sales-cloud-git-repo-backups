import { LightningElement, wire, track,api } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import getEntitlementsList from '@salesforce/apex/AnkitPOCLInkController.retrieveEntitlements';
import approveRecord from '@salesforce/apex/AnkitPOCLInkController.approveRecord';
import rejectRecord from '@salesforce/apex/AnkitPOCLInkController.rejectRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



const columns = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Contact Name', fieldName: 'ContactName', type: 'text' },
    { label: 'Entitlement', fieldName: 'EntitlementName', type: 'text' },
    { label: 'Entitlement Type', fieldName: 'Core_Type__c', type: 'text' },
    { label: 'Selected', fieldName: 'Core_Selected__c', type: 'boolean' },
];

export default class AnkitPOCLInk extends LightningElement {
    @track displayValue;
    @track contactId;
    @api recordId;
    @api objectApiName;
    @api c__contactId;

    @track entitlements ;
    @track ContactMoveGovernanceId;
    @track showButtons = false;
    @track isModalOpen = false;
    @track showEntitlement = false;
    @track reason = '';


    data1 ;
    columns = columns;

   // fields = ["Old_CIM_ID__c","New_CIM_ID__c"];

   /* @wire(getEntitlementsList,{ContactMoveGovernanceId:'$recordId'})
    wiredCompetitions( value ) {

        this.wiredRecords = value;
        const { data, error } = value;

        if ( data ) {
            
            let tempRecords = JSON.parse( JSON.stringify( data ) );

            tempRecords = tempRecords.map( row => {
                return {...row, ContactName: row.Core_Contact_Id__r.Name, EntitlementName: row.Core_Entitlement_Id__r.Core_Display_Name__c };
            })
            this.data1 = tempRecords;
            this.showButtons = true;

            this.error = undefined;
        } else if ( error ) {

            this.error = error;
            showErrorToast( this.error);
            this.showButtons = false;

            this.data1 = undefined;

        }
    }*/

    connectedCallback(){

        getEntitlementsList({ContactMoveGovernanceId : this.recordId })
        .then(result => {
            let tempRecords = JSON.parse( JSON.stringify( result ) );

            tempRecords = tempRecords.map( row => {
                return {...row, ContactName: row.Core_Contact_Id__r.Name, EntitlementName: row.Core_Entitlement_Id__r.Core_Display_Name__c };
            })
            this.data1 = tempRecords;
            this.showButtons = true;

            this.error = undefined;

        })
        .catch(error => {
            this.error = error;
            this.showErrorToast( this.error);
            this.showButtons = false;

            this.data1 = undefined;        
        });


    }
    handleClick1(){
        approveRecord({ContactMoveGovernanceId : this.recordId })
        .then(result => {
            this.showSuccessToast();
            this.showButtons = false;
            eval("$A.get('e.force:refreshView').fire();");


        })
        .catch(error => {
            this.showErrorToast(error);
        });
    }

    handleClick2(){
        this.isModalOpen = true;
        this.showButtons = false;

    }

    AllEntitlement(){
        this.showEntitlement = true;
    }

    closeModalforEntitlments(){
        this.showEntitlement = false;

    }

    handlechange(event){
        this.reason = event.target.value;
    }

    onRejection(event){
           

        rejectRecord({ContactMoveGovernanceId : this.recordId, reason : this.reason })
         .then(result => {
             this.showSuccessToast();
             this.showButtons = true;
             eval("$A.get('e.force:refreshView').fire();");


         })
         .catch(error => {
             this.showErrorToast(error);
         });
         this.isModalOpen = false;
    }

    showErrorToast(error) {
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: 'Some unexpected error:'+JSON.stringify(error),
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Success',
            message: 'Your Request is Approved/Rejected Successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    closeModal(){
        this.isModalOpen = false;
    }

}