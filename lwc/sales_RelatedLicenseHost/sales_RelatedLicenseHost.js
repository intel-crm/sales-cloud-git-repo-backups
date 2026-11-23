import { LightningElement,track,api} from 'lwc';
import fetchLicensesFromHost from "@salesforce/apex/Sales_HostTriggerUtility.fetchLicensesFromHost";
import licenseriedirect from '@salesforce/label/c.sales_licenseriedirect';
const columns = [
    { label: 'License Name', fieldName: 'urlValue', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
    { label: 'Product Name', fieldName: 'productname', type: 'text', initialwidth: '10' },
    { label: 'License Activation Code', fieldName: 'Sales_License_Activation_Code__c', type: 'text', initialwidth: '10' },
    { label: 'Primary Admin Contact Name', fieldName: 'primaryadminname', type: 'text', initialwidth: '10' },
	{ label: 'Licensed User', fieldName: 'Sales_Lic_User_Contact_Txt__c', type: 'text', initialwidth: '10' },
    { label: '# of seats', fieldName: 'Sales_License_Quantity__c', type: 'text', initialwidth: '10' },
    { label: 'Available Quantity', fieldName: 'Sales_License_Avbl_Qty_Nbr__c', type: 'text', initialwidth: '10' },
    { label: 'Maintenance Expiration Date', fieldName: 'Sales_License_Maintenance_Exp_Dt__c', type: 'text', initialwidth: '10' },
    { label: 'License Expiration Date', fieldName: 'Sales_License_Expiration_Date_Dt__c', type: 'text', initialwidth: '10' },
    { label: 'Available Rehosts', fieldName: 'Sales_License_Avbl_Rehost_Nbr__c', type: 'text', initialwidth: '10' },
];

export default class Sales_RelatedLicenseHost extends LightningElement {
    @track tablename='Licenses';
    @api columns = columns;
    @api licenseData = false;
    @api licenses;
    @track urlValue;
    @track licensename;
    @track productname;
    @track primaryadminname;
    @api recordId;
    baseUrl;

    label={licenseriedirect};
    connectedCallback() {
        //get base url
        this.baseUrl = window.location;
        console.log('Base location -->' + this.baseUrl);

        if (JSON.stringify(this.baseUrl.pathname).includes('Sales_Host__c')) {
            var split = JSON.stringify(this.baseUrl.pathname).split('Sales_Host__c/');
            console.log('split >>>'+split);
            var split3=split.toString();
            console.log('before if>>'+split3.includes('action/quick/'));
            //avoid quick action page reload
            if(!split3.includes('action/quick/')){
                this.recordId = split[1].split('/')[0];
                console.log('Spli -->' + this.recordId);
                this.getDetails();
            }
         
        } else {
            let split = JSON.stringify(this.baseUrl.pathname).split('sales-host/');
            //let split = JSON.stringify(this.baseUrl.pathname).split('sales_license__c/');
            console.log('split else>>>'+split);
            this.recordId = split[1].split('/')[0];
            console.log('Spli -->' + this.recordId);
             this.getDetails();
        }
        //Sales_License__c//sales-license/
    }
    getDetails(){
        fetchLicensesFromHost({ hostid: this.recordId })
        .then(result => {
            console.log('Result-->>>>' + JSON.stringify(result));
            if (result != null && result !='') {
                this.licenseData = true;
                console.log(this.licenseData+'licenseData');
                this.licenses = result; // need to change tabledata to license data
               // showing how many records of license we have (Count)
                if (this.licenses != null && this.licenses != undefined) {
                    this.tablename = 'Licenses (' + this.licenses.length + ')';
                    console.log('tablename'+this.tablename);
                 this.licenses.forEach(item => {              // need for each loop
                        console.log(' -->' + item.Id);
                        if (item.Id != null && item.Id != undefined) {
                            item.urlValue = this.label.licenseriedirect+ item.Id; // Redirecting this to Licenses detail page
                        } else {
                            item.urlValue = null;
                        }

                        if (item.Name != null && item.Name != undefined) {
                            console.log('Parse -->' + JSON.stringify(item.Name));
                            item.licensename = item.Name;
                            item.productname=item.Sales_License_Product__r.Name;
                            item.primaryadminname=item.Sales_License_Primary_Admin_Contact__r.Name;
                            console.log('primary admin'+ item.primaryadminname);
                        } else {
                            item.licensename = null;
                            item.productname=null;
                            item.primaryadminname=null;
                        }

                    });

                } else {
                    console.log('Table undefined');
                }
                console.log('Inside table-Data->' + JSON.stringify(this.licenses));
            } 
            else {
                this.licenses = [];
                this.tablename = 'Licenses (0)';
            }
        })
}


}