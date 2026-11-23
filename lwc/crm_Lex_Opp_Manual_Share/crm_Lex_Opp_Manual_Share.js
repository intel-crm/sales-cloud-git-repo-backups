import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Crm_Lex_Opp_Manual_Share extends NavigationMixin(LightningElement) {
    @api recordId;

    connectedCallback() {
        this.navigateToOpportunityShare();
    }

    navigateToOpportunityShare() {
        this[NavigationMixin.Navigate]({
            type: 'Opportunity',
            attributes: {
                recordId: this.recordId,
                actionName: 'share'
            }
        });
    }
}cr