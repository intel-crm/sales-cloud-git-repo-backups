import { LightningElement, api, track } from 'lwc';

import displayPointsData from '@salesforce/apex/PRM_AccountActvityOverview.displayPointsData'

export default class PRM_Renewal_dashboard extends LightningElement {

    @track total_SalesDatanbr = 0;
    @track total_TrainingCreditsnbr = 0;
    accrecordId='0018A00000UE7RMQA1';
    displayMethod() {
        displayPointsData({ accID: accrecordId }).then(result => {
            console.log("Record Id -->" + this.recordId);
            if (result != null) {
                this.isLoaded = true;
                console.log('result -->' + JSON.stringify(result));

                this.total_SalesDatanbr = this.convertNumber(result.totalSalesData, true);
                this.total_TrainingCreditsnbr = this.convertNumber(result.totalTrainingCredits, true);
                
            } else {
                this.isLoaded = true;
                this.resetAttributes();
                console.log('received null');
            }
        })
        .catch(error => {
            this.isLoaded = true;
            console.log('displayPointsData.error -->' + JSON.stringify(error));
        });
    }
    connectedCallback() {
        this.displayMethod();
    }
    refreshAction() {
        this.isLoaded = false;
        this.resetAttributes();
        this.displayMethod();
    }
    resetAttributes() {
		
        this.total_SalesDatanbr = 0;
        this.total_TrainingCreditsnbr = 0;

    }
}