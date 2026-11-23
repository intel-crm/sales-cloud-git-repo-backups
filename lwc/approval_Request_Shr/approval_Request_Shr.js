import { LightningElement,wire,track,api } from 'lwc';
import getNewRecords from '@salesforce/apex/Core_MDF_Approval_Requests.getNewRecords';
import getFieldsOfSelectedRecords from '@salesforce/apex/Core_MDF_Approval_Requests.getFieldsOfSelectedRecords';
import formFactorPropertyName from '@salesforce/client/formFactor';
export default class Approval_Request_Shr extends LightningElement {
    @track recdId='/0RJg0000000CcjjGAC';
    @track recordsToRender;
    @track fieldsToDisplay;
	@track phoneOrDesktop;
    @track formFactor;
formFactor = formFactorPropertyName;
   /* @api prop1
    @api
    //getter method
    get recId() {
        console.log('Entered'+this.__recId);
        
        return this._recId;

    }
    //setter method
    set recId(value) {
       if(value){
           console.log('Entered Inside  First set'+value);
            this._recId = value;
            this.recdId = value;
       }else{
            this._recId = undefined;
       }
} */
connectedCallback(){ 
     console.log('@@@'+this.formFactor);
    if(this.formFactor == 'Large'){
        this.phoneOrDesktop = false;
    }else{
        this.phoneOrDesktop = true;
    }
    console.log('@@@'+this.phoneOrDesktop);
    
    // Fetching Record clicked on Approval Page
   // this.fetchRecord();
    //Fetching Details of the record
    this.fetchFieldsOfDetailRecord();
}
fetchRecord(){
    console.log('****Entered*********');
    getNewRecords({recordId:this.recdId})
    .then(data => {
        this.recordsToRender = JSON.parse(data);
        this.error = undefined;
        console.log('$$$ recordToDisplay'+ this.recordsToRender)
    })
    .catch(error => {
        this.error = error;
        this.recordToDisplay = undefined;
    });
}   

fetchFieldsOfDetailRecord(){
    console.log('Entered Inside toggle');
    
   getFieldsOfSelectedRecords({recordId:this.recdId})
    .then(data => {
        this.fieldsToDisplay = JSON.parse(data);
        this.error = undefined;
        console.log('$$$ recordToDisplay'+ this.fieldsToDisplay)
    })
    .catch(error => {
        this.error = error;
        this.recordToDisplay = undefined;
    }); 
}
handleToggleSection(event) {

    console.log( 'Selected Sections ' + event.detail.openSections );

}
}