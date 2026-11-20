import { api,wire,track } from 'lwc';
import LightningModal from 'lightning/modal';
import  getCmfGroupDetails from '@salesforce/apex/ER_SearchCMFService.getCmfGroupDetails';

export default class Er_CMFSearchPopUpModal extends LightningModal {
    groupColumns = [
        { label: 'Group Name', fieldName: 'GroupLink' ,wrapText: true,sortable: "true", type: 'url',typeAttributes: {label: { fieldName: 'GroupName' }, 
        target: '_blank'}},
        { label: 'Active', fieldName: 'Active', type : 'boolean'},
        { label: 'Active CMF Count', fieldName: 'ActiveCMFCount', type : 'text'},
        { label: 'Active Contact Count', fieldName: 'ActiveContactCount', type : 'text'},



    ]
        
    @api content;
    @track GroupData;
    @track showSpinner = true;


    handleOkay() {
        this.close('okay');
    }
    @wire(getCmfGroupDetails, { uniqueString: '$content' }) 
    getGroupDetails ({ error, data }) {
        if (data) {
            this.GroupData = data; 
            console.log('DATA'+JSON.stringify(data));
            this.showSpinner = false;
       } else if (error) { 
           this.error = error;  
           this.showSpinner = false;
      }   }
    
    
}