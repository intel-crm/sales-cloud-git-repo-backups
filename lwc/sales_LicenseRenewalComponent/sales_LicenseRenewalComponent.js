import { LightningElement ,api, wire, track} from 'lwc';
import getLicenseList from '@salesforce/apex/Sales_ApplyRenewalController.getLicenseList'; 
export default class Sales_LicenseRenewalComponent extends LightningElement {
    @track columns = [{
            label: 'Product',
            fieldName: 'Sales_License_Product__c'
        },
        {
            label: 'Maintenance Expiration',
            fieldName: 'Sales_License_Maintenance_Exp_Dt__c'
            
        },
        {
            label: '# Seats',
            fieldName: 'Sales_License_Quantity__c'
           
        },
        {
            label: 'Rehost Available',
            fieldName: 'Sales_License_Avbl_Rehost_Nbr__c'
          
        },
        {
            label: 'Primary Computer Name',
            fieldName: 'Sales_License_Computer_Name__c'
           
        }
    ];
 
    @track error;
    @track licList ;
    @wire(getLicenseList)
    wiredLicense({error,data}) {
        if (data) {
            this.licList = data;
        } else if (error) {
            this.error = error;
        }
    }
}