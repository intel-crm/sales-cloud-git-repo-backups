import { LightningElement, api, wire, track } from 'lwc';
import fetchRelatedContact from '@salesforce/apex/UCD_RelatedContactController.getRelatedList';


export default class Related_contact extends LightningElement {
    @api recordid;
    @track count = 0;
    @track contact;

@wire(fetchRelatedContact,{ContactID:'$recordId'})
wiredContact({ error, data }){
    if (data) {
        console.log('check data : ',data);


        if(data != undefined && data != '' && data.count >= 0){
            this.displayData = true;
            this.contact = data;
            this.count = this.accounts.count;
        } else {
            this.displayData = false;
        }
    } else if (error) {
        console.log('check error : ',error);
        //todo handle error
    } else {
        this.displayData = false;
    }
}

}