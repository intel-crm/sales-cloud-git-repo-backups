import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import progressbarImg from '@salesforce/resourceUrl/progressbarImg';
export default class core_IPS_caseCreation_Form_Full extends NavigationMixin(LightningElement) {
    value = 'Entire Site';
    @api caseinfodata;
    @api userGroupRoles;
    @track progressbarImg = progressbarImg;
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
    handleNavigate() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'create-form-3'
            },
        });
    }
    handleNavigateBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'new-case'
            },
        });
    }
    @api handleClickEventForDeflection(){
        this.template.querySelector('c-core_-i-p-s_-search-before-submit_-lex').handleClickEventForDeflection();
    }
}