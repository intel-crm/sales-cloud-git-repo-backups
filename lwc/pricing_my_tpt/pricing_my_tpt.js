import { LightningElement, track, wire } from 'lwc';
import getTPTData from '@salesforce/apex/Pricing_FieldSetFormController.getTPT';

export default class Pricing_my_tpt extends LightningElement {

    @track isLoading = true;
    @track dataList = [];
    @track col = [
        {
            fieldName: 'Pricing_Deal_RFQ_Id__c',
            label: 'Deal ID',
            type: 'text'
        },
        {
            fieldName: 'Pricing_OEM_Account_Nm__c',
            label: 'Account',
            type: 'text'
        },
        {
            fieldName: 'Pricing_TPT_Status_From__c',
            label: 'From Stage',
            type: 'text'
        },
        {
            fieldName: 'Pricing_TPT_Age__c',
            label: 'Status Time (in days, hrs, mins, secs)',
            type: 'text'
        }
    ];

    @wire(getTPTData)
    wiredData({ error, data }) {
        if (data) {
            this.dataList = JSON.parse(JSON.stringify(data));
            this.dataList.forEach(element => {
                
                element.Pricing_TPT_Quote_Line_Number__r.hasOwnProperty('Pricing_OEM_Account_Nm__c') ? element['Pricing_OEM_Account_Nm__c'] = element.Pricing_TPT_Quote_Line_Number__r.Pricing_OEM_Account_Nm__c : '';
                element.Pricing_TPT_Quote_Line_Number__r.hasOwnProperty('Pricing_Deal_RFQ_Id__c') ? element['Pricing_Deal_RFQ_Id__c'] = element.Pricing_TPT_Quote_Line_Number__r.Pricing_Deal_RFQ_Id__c : '';
                
            });
            
            console.log('Data TPT => ', JSON.stringify(this.dataList));
            this.isLoading = false;
        } else if (error) {
            console.error('Error:', error);
        }
    }

}