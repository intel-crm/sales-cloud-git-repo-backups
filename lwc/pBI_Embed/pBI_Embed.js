import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import checkAccess from '@salesforce/apex/PBI_Embed_Class.checkAccess'; 


const FIELDS = [
    'Account.Name',
    'Account.Core_Prime_Account_Name__c',

];

const ARFIELDS = [
    'Account_Revenue__c.Account__r.Core_Prime_Account_Name__c'
]
export default class PBI_Embed extends LightningElement {
    @api recordId;
    @api objectApiName;
    hasAccess = false;
    noAccess = false;
   
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    account;

    @wire(getRecord, { recordId: '$recordId', fields: ARFIELDS })
    araccount;

    connectedCallback() { 
        this.checkVisibility();
    }
    checkVisibility(){
        console.log('recordId: '+ this.recordId);
        checkAccess({accountID:this.recordId})
        .then((data) => {
        if(data == true){
            this.hasAccess = true;
        }  
        else{
            this.noAccess = true;
        } 
        console.log('data: '+ data);
      
        })
        .catch(error => {
            this.error = error;  
        });

    }
     

    // get name() {
    //     return this.account.data.fields.Name.value;
    // }

    get prime_name() {
        //return this.account.data.fields.Core_Prime_Account_Name__c.value;
        return getFieldValue(this.account.data, "Account.Core_Prime_Account_Name__c");

    }

    get ar_prime_name() {
        return getFieldValue(this.araccount.data, "Account_Revenue__c.Account__r.Core_Prime_Account_Name__c");
    }


     get fullUrl() {
    //return`https://my-sitename.com/amazon/customer_system_api.php?token=XVF1C5CGE&sys=${this.sysId}&type=header`;
    let primeName;
    primeName = this.objectApiName == 'Account' ? this.prime_name : this.ar_prime_name;
    //primeName = this.ar_prime_name;
    console.log('primeName: '+primeName);
    //return 'https://app.powerbi.com/reportEmbed?reportId=3a9f25bb-f5a4-4c3c-9570-c12a7837f466&autoAuth=true&navContentPaneEnabled=false&filter=Fact%2FPrime_x0020_Customer_x0020_Account_x0020_Name eq \'' +  primeName + '\'&filterPaneEnabled=false';
    return 'https://app.powerbi.com/reportEmbed?reportId=adbaad5d-a07f-40ef-ac83-8852a2445fe9&autoAuth=true&navContentPaneEnabled=false&filter=Congruence%2FCustomer eq \'' +  primeName + '\'&filterPaneEnabled=false';
    }
}