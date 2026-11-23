import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Pricing_QuoteLine_Collapsible_Section extends NavigationMixin(LightningElement) {
    @api recordId;

    connectedCallback() {
        console.log('div onload===>');
            let recordPage = {
                    type: 'standard__objectPage',
                    attributes: {
                        recordId: '$recordId',
                        objectApiName: 'SBQQ__QuoteLine__c',
                        actionName: 'edit'
                    },
                    /*state: {
                        nooverride: '1',
                    // navigationLocation: 'HOME',
                        //recordTypeId: this.recordTypeId,
                    }*/
                };
                this[NavigationMixin.Navigate](recordPage);
    }
    /*@track sectionClass = 'slds-is-close';

    handleSectionHeaderClick(event) {
        /*console.log('event==>',JSON.stringify(event.target));
        var button = event.target.value;
        this.state = button.state;

        var sectionContainer = this.template.querySelector('[data-id="section"]');
		//util.toggleClass(sectionContainer, "slds-is-open");
        console.log('inside onclick',this.sectionClass);
        this.sectionClass = 'slds-is-open';
    }*/
}