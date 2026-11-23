import { LightningElement, api, wire, track} from 'lwc';
import showFormDetails from '@salesforce/apex/Pricing_PerformanceMetricsController.showQuoteLineDetail'; 
import { NavigationMixin } from 'lightning/navigation';

export default class Pricing_QuoteLineDetail_Page extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isStandardQuoteLine;
    //@track recordTypeId;

    @wire(showFormDetails,{quoteLineId : '$recordId'})
    Values({ error, data }) {
        //console.log('recordId==>',recordId);
        if(data) {
            console.log('data==>',JSON.stringify(data));
            /*let dataValue = data.split(":");
            console.log('data value 0==>',dataValue[0]);
            console.log('data value 1==>',dataValue[1]);
            if(dataValue[0] != '') {
                this.isStandardQuoteLine = (dataValue[0]==='true') ? true : false;
                console.log('isStandardQuoteLine==>',this.isStandardQuoteLine);
                if(this.isStandardQuoteLine === true) {
                    this.displayStandardRecordPage();
                }
            }
            if(dataValue[1] != '') {
                this.recordTypeId = dataValue[1];
            }    */  
            this.isStandardQuoteLine = (data === true) ? true : false;  
            /*if(this.isStandardQuoteLine === true) {
                this.displayStandardRecordPage();
            }*/
        } else if (error) {
            console.log('error==>',JSON.stringify(error));
        }
    }

    displayStandardRecordPage() {
        console.log('div onload===>');
        let recordPage = {
                type: 'standard__objectPage',
                attributes: {
                    recordId: '$recordId',
                    objectApiName: 'SBQQ__QuoteLine__c',
                    actionName: 'view'
                },
                /*state: {
                    nooverride: '1',
                   // navigationLocation: 'HOME',
                    //recordTypeId: this.recordTypeId,
                }*/
            };
            this[NavigationMixin.Navigate](recordPage);
    }
}