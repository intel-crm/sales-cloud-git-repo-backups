import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
// import { buildContext } from 'c/quanticHeadlessLoader';

export default class Core_IPS_CaseCreateForm2_LWC extends NavigationMixin(LightningElement) {
    value = 'Entire Site';
    @api caseinfodata;
    
    get options() {
        return [
            { label: 'Entire Site', value: 'Entire Site' },
            { label: 'Support & Technical Documentation', value: 'Support & Technical Documentation' },
            { label: 'Knowledge Base', value: 'Knowledge Base' },
            { label: 'Forums & Wiki', value: 'Forums & Wiki' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    handleNavigate(){
        console.log('inside navigate');
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'create-form-3'
            },
        });
    }
    handleNavigateBack(){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'new-case'
            },
        });
      }
}