import { LightningElement, api, wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

//controller class
import validateRenewal from '@salesforce/apex/Sales_ApplyRenewalController.validateRenewal';

const FIELDS = ['license.Id', 'license.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c', 'license.Sales_License_Maintenance_Exp_Dt__c' ];

export default class Sales_renewalComp extends LightningElement {
@api recordId;

@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
license;

label = {
    successTxt,
    errorMsg,
};

    applyRenewal(){

    }
}