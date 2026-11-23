import { LightningElement } from 'lwc';
import returnData from '@salesforce/apex/PRM_SecutityTesting.returnData';

const columns = [
    {
        label: 'Id',
        fieldName: 'Id',
        type: 'text'
    }, {
        label: 'Name',
        fieldName: 'Name',
        type: 'text'
    }]

export default class PRM_tempLink extends LightningElement {
    columns = columns
    showData = false;
    searchData = [];
    connectedCallback() {
        returnData().then(response => {
            console.log('here');
            if(response.length> 0){
				console.log('documents--->',response);
				this.searchData=response;
                this.showData = true;
			}
        })       
        .catch(error => {
            console.log("Error in  saveUploadedDoc-->", error);
        });
    }
    

}