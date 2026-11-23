import { LightningElement,api,wire,track} from 'lwc';
import  getCMFDetailsFromContact from '@salesforce/apex/ER_SearchCMFService.getCMFDetailsFromContact';
const columns = [
    { label: 'CMFD ID', fieldName: 'Name' },
    { label: 'CMF Name', fieldName: 'ER_CMF_Name__c', type: 'text' },
    { label: 'CMF Group', fieldName: 'phone', type: 'text' },
    { label: 'Sales Org Code', fieldName: 'amount', type: 'text' },
    { label: 'Distribution Channel Code', fieldName: 'closeAt', type: 'text' },
];

export default class ViewAssociationsForContact extends LightningElement {
    @api recordId;
    @track cmfData;
    columns = columns;
    @wire (getCMFDetailsFromContact,{contactId: '$recordId'})
	wireditems({data, error}){
		if(data) {
			this.cmfData =JSON.stringify(data.ER_Customer_Master_File__r);
			this.error = undefined;
            console.log('DATA'+JSON.stringify(this.cmfData));
		}else {
			this.cmfData =undefined;
			this.error = error;
		}
	}


}