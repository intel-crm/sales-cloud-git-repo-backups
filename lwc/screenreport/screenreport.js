import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class Screenreport extends NavigationMixin(LightningElement) {
    @api combinedReports;
    @api showScore;
    @api showMissScore;
    @track recId;
    @track recw
    @track sfdcBaseURL;
    @api recordId;
    connectedCallback(){
        console.log('MMMMMMMMMMM'+this.showReportScore);
    }

@track openModal = false;
 @track modalData = [];
 @track CoreData= [];
 showModal(event) {
    console.log('nnnnnnnnnnnnnn',event.currentTarget.dataset.index);
    const itemindex = event.currentTarget.dataset.index;
    this.openModal = true;
    this.modalClass = 'slds-modal slds-fade-in-open';
    //this.modalData = event.detail.value;
    this.modalData = this.combinedReports[itemindex].MissingData;
    this.CoreData = this.combinedReports[itemindex].CoreData;
    console.log('vvvvvvvvvvv',this.modalData);
}
 closeModal() {
     this.openModal = false;
 }

 navigateToDetail(event) {
    this.recId = event.target.value;
    
    this.sfdcBaseURL = window.location.origin;
    let acctUrl = this.sfdcBaseURL + "/" + this.recId;
    //alert(this.recId + this.sfdcBaseURL);
    window.open(acctUrl);
  }

  navigateToViewAccountPage() {
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            objectApiName: 'Account',
            actionName: 'view'
        },
    });
}
}