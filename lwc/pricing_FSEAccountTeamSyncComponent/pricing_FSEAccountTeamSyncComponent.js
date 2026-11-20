import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFSEUsers from '@salesforce/apex/Pricing_QuoteTeam_SharingController.getQuoteFSEUsers';

export default class Pricing_FSEAccountTeamSyncComponent extends LightningElement {
    @api recordId;

    @api invoke() {
        console.log(this.recordId);
        let quoteIdList = [];
        quoteIdList.push(this.recordId);
        getFSEUsers({ quoteIds: quoteIdList })
            .then(result => {
                if (result != undefined) {
                    let msgTitle = result['type'] === 'info' ? 'Information' : result['type'] === 'success' ? 'Success' : 'Error';
                    const toastMessage = new ShowToastEvent({
                        title: msgTitle,
                        message: result['msg'],
                        variant: result['type'],
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(toastMessage);
                }

            })
            .catch(error => {
                console.log('error===>', JSON.stringify(error));
            });
    }
}