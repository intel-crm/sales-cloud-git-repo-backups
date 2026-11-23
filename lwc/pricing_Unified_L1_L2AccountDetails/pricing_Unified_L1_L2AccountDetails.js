import { LightningElement, track, wire , api } from 'lwc';
import getColumns from '@salesforce/apex/Pricing_UCD_IQR_FormRequest.getDataTableColumns';
import getL1andL2AccDetails from '@salesforce/apex/Pricing_UCD_IQR_FormRequest.getL1andL2AccDetails';
export default class Pricing_Unified_L1_L2_Details extends LightningElement {
    @api recordId;
    @track l2AccDetails = [];
    @track l1AccDetails = [];
    @track dataTableColumns;
    @track hasL2AccRecords = false;
    @track hasL1AccRecords = false;
    connectedCallback() {
        getColumns()
        .then(result => {
            this.dataTableColumns = result;
                this.getAccountDetails()

        })
        .catch(error => {
            console.log('Error --> ' + JSON.stringify(error));

        });
    }
    getAccountDetails() {
    getL1andL2AccDetails({recordId : this.recordId})
    .then(result=>{
        if(result !== undefined){
            for (let i = 0; i < result.length; i++) {
                if(result[i].accAggregateType === 'UNFD_CTRY_CUST'){
                    this.l2AccDetails.push(result[i]);
                    this.hasL2AccRecords = true;
                }else{
                    this.l1AccDetails.push(result[i]);
                    this.hasL1AccRecords = true;
                }
            }
        }else{
            this.hasL2AccRecords = false;
            this.hasL1AccRecords = false;
        }

    })
    .catch(error=>{
        console.log('Error: ' + JSON.stringify(error));
    });
    }
    
}