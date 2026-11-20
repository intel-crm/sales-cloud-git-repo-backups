import { LightningElement, api, wire, track } from 'lwc';
/*import { getRecord } from 'lightning/uiRecordApi';
import getDelegateAdmin from "@salesforce/apex/Sales_LicenseGenerationGenericFunctions.getDelegateAdmin";
import getContactId from "@salesforce/apex/Sales_LicenseGenerationGenericFunctions.getPrimaryCtId";
import delegateredirect from '@salesforce/label/c.sales_delegateredirect';
const columns = [
    { label: 'Delegate', fieldName: 'urlValue', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
    // { label: 'Delegate Admin Contact', fieldName: 'ctUrlValue', type: 'url', typeAttributes: { label: { fieldName: 'adminName' },target:'_blank' } },
    { label: 'Delegate Admin Contact', fieldName: 'adminName', type: 'text', initialwidth: '20' },
    { label: 'Delegate Admin Email', fieldName: 'Sales_License_DlgAdmin_Email_Txt__c', type: 'text', initialwidth: '20' },
    { label: 'Active', fieldName: 'Sales_License_isActive__c', type: 'boolean' },
];

// get an License Record Field (Primary Admin Contact)
const FIELDS = ['Sales_License__c.Sales_License_Primary_Admin_Contact__c'];
*/
export default class SalesLicenseRelatedList extends LightningElement {
    /*@api licPrimAdmContactId;
    @track tableSize;
    @api licenseData = false;
    @api adminData;
    @track adminName;
    @track ctUrlValue;
    @api columns = columns;
    @api recordId;
    @track urlValue;
    @track tablename='Delegate Admin';
    baseUrl;

    label={delegateredirect};

    connectedCallback() {
        //get base url
        this.baseUrl = window.location;
        console.log('Base location -->' + this.baseUrl);

        if (JSON.stringify(this.baseUrl.pathname).includes('Sales_License__c')) {
            var split = JSON.stringify(this.baseUrl.pathname).split('Sales_License__c/');
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
            let split = JSON.stringify(this.baseUrl.pathname).split('sales-license/');
            //let split = JSON.stringify(this.baseUrl.pathname).split('sales_license__c/');
            console.log('split else>>>'+split);
            this.recordId = split[1].split('/')[0];
            console.log('Spli -->' + this.recordId);
            this.getDetails();
        }
        //Sales_License__c//sales-license/
    }
    getDetails() {
        getContactId({ id: this.recordId }).then(response => {
            if (response != null && response != undefined) {
                getDelegateAdmin({ primaryContactId: response })   // fetching data from apex method
                    .then(result => {
                        console.log('Result-->>>>' + JSON.stringify(result));
                        if (result != null) {
                            this.licenseData = true;
                            this.adminData = result; // need to change tabledata to adminData
                            this.tablename = 'Delegate Admin (' + this.adminData.length + ')';
                            // showing how many records of Delegate Admin we have (Count)
                            if (this.adminData != null && this.adminData != undefined) {
                                //   console.log('table -->' + this.adminData);

                                this.adminData.forEach(item => {              // need for each loop

                                    console.log(' -->' + item.Id);

                                    if(JSON.stringify(window.location.origin ).includes('.lightning.'))
                                    {   console.log('sfdc');
                                        item.urlValue = this.baseUrl.origin+'/' + item.Id; // Redirecting this to Delegate Admin Record Page
                                 
                                    }
                                    else
                                    {   console.log('SSLC');
                                        item.urlValue = this.label.delegateredirect+ item.Id;

                                     }
                                    /* if (item.Id != null && item.Id != undefined) {
                                        item.urlValue = this.baseUrl.origin+'/' + item.Id; // Redirecting this to Delegate Admin Record Page
                                    } else {
                                        item.urlValue = null;
                                    }*/

                                    /*if (item.Sales_License_DlgAdmin_Contact__r != null && item.Sales_License_DlgAdmin_Contact__r != undefined) {
                                        console.log('Parse -->' + JSON.stringify(item.Sales_License_DlgAdmin_Contact__r));
                                        item.adminName = item.Sales_License_DlgAdmin_Contact__r.Name;
                                    } else {
                                        item.adminName = null;
                                    }

                                });

                            } else {
                                console.log('Table undefined');
                            }
                            console.log('Inside table-Data->' + JSON.stringify(this.adminData));
                        } else {
                            this.adminData = [];
                            this.tablename = 'Delegate Admin (0)';
                        }
                       
                    })
                    .catch((err) => {
                        console.log('apex call err' + JSON.stringify(err));
                    });
            }

            this.tablename = 'Delegate Admin (0)';
            console.log('no delegate records');
        })
        .catch(Error => {

        });


    }*/
}