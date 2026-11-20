import { LightningElement,track } from 'lwc';
import termsLabel_Part1 from '@salesforce/label/c.PCC_DealReg_TandC_1';
import termsLabel_Part2 from '@salesforce/label/c.PCC_DealReg_TandC_2';
import CheckPartnerTermsAndCondition from '@salesforce/apex/PCC_DealTermsAndConditions.CheckPartnerTermsAndCondition';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


export default class PCC_DealReg_TermsAndConditions extends NavigationMixin(LightningElement) {

    @track chkBoxSelect;
    @track  btnVisibility = true;
    @track isLoaded = true;
    
    label = {
        termsLabel_Part1,
        termsLabel_Part2
        
    };

    handleSelection(event){
        this.chkBoxSelect = event.target.checked;
        this.btnVisibility = !(this.chkBoxSelect);
    }

    handleTermsAndConditions(){
        this.isLoaded = false;
        CheckPartnerTermsAndCondition()
		.then(result => {
            this.data = result;
			this.showLoadingSpinner = true;
            const pageUrl = window.location.origin + '/s/deal';
            window.open(pageUrl,'_self');
            this.isLoaded = true; 
        })
		.catch(error => {
			console.log("error -->", error);
			const errorTitle = error.body.message ?? 'Error while processing Terms and Condition';// Utkarsh - TWC727-1237 - Changes done to through error messages.
			this.dispatchEvent(
				new ShowToastEvent({
				title: errorTitle,
				message: error.message,
				variant: 'error',
				}),
			);
		});

    }
}