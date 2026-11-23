import { LightningElement,wire,track,api } from 'lwc';
import getNewRecords from '@salesforce/apex/Core_MDF_Approval_Requests.getNewRecords';
import getFieldsOfSelectedRecords from '@salesforce/apex/Core_MDF_Approval_Requests.getFieldsOfSelectedRecords';
import smallScreen from "./core_MDF_Redirect_Mobile.html";
import largeScreen from "./core_MDF_Redirect_Desktop.html";

 export default class RenderHtml extends LightningElement {
    @track recordsToRender;
    @track fieldsToDisplay;
    @api recordId;
    @api prop1;
    
connectedCallback(){ 
    
    // Fetching Record clicked on Approval Page
     this.fetchRecord();
    // //Fetching Details of the record
     this.fetchFieldsOfDetailRecord();
       // return window.screen.width < 768 ? smallScreen : largeScreen;
    
}
fetchRecord(){
    
    console.log('****Entered*********');
    getNewRecords({recordId:this.recordId})
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
   getFieldsOfSelectedRecords({recordId:this.recordId})
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
render(){        
    return window.screen.width < 768 ? smallScreen : largeScreen;
}
}