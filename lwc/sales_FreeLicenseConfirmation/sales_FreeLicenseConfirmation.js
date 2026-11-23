import { LightningElement,wire,api,track } from 'lwc';

//Labels:
import Sales_LicenseCOnfirmationText1 from '@salesforce/label/c.Sales_LicenseCOnfirmationText1';
import Sales_LicenseCOnfirmationText2 from '@salesforce/label/c.Sales_LicenseCOnfirmationText2';


export default class sales_FreeLicenseConfirmation extends LightningElement {
@api licenseName;
@api licenseFullUrl;

//Labels
label = {
    Sales_LicenseCOnfirmationText1,Sales_LicenseCOnfirmationText2
};
    connectedCallback(){
        console.log('licenseFullURLLL ' + this.licenseFullUrl);
        //const topDiv = this.template.querySelector('[data-id="redDiv"]');
        //topDiv.scrollTop=0;
    }
}