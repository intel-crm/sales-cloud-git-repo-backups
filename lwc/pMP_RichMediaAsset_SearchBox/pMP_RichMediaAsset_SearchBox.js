import { LightningElement,track,api,wire} from 'lwc';
/*
 Importing server side apex
*/
import getCompanyList from '@salesforce/apex/PMP_RichMediaAssetController.getCompanyList';

const DELAY = 50;

 
export default class RichMediaAssetSearchBox extends LightningElement {
    
    @track searchValue ='';
    @track selectedpartner;
    // @track showOfferingListFlag = false; IPA2.0 + US TWC4497-1631
    @track error;
    @track par;

	@wire(getCompanyList, { searchKey: '$searchValue' })
	partners;
    handleKeyUp(event) {
        if (!this.showpartnerListFlag) {    
            this.showpartnerListFlag = true;
            this.template
                .querySelector('.partners_list')
                .classList.remove('slds-hide');
        }
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            this.searchValue = searchKey;
        }, DELAY);
    }
    handleOptionSelect(event) {
        this.selectedpartner = event.currentTarget.dataset.name;
        console.log('the selected record is:'+this.selectedpartner);
        for(var i = 0; i < this.partners.data.length; i++) {
            if(this.partners.data[i].label === this.selectedpartner) {
                this.par = JSON.parse(JSON.stringify(this.partners.data[i].selected));
                //this.par = this.partners.data[i].selected
                this.par = true;
            }
        }
        /*this.template
            .querySelector('.selectedOption')
            .classList.remove('slds-hide');
         this.template
            .querySelector('.partners_list')
            .classList.add('slds-hide');
         this.template
            .querySelector('.slds-combobox__form-element')
            .classList.add('slds-input-has-border_padding');*/
    }
    handleRemoveSelectedOption() {
        this.template
            .querySelector('.selectedOption')
            .classList.add('slds-hide');
        this.template
            .querySelector('.slds-combobox__form-element')
            .classList.remove('slds-input-has-border_padding');

        // this.showOfferingListFlag = false;IPA2.0 + US TWC4497-1631
    }
}