import { LightningElement, track } from 'lwc';
import createDZPRegistrationEntry from '@salesforce/apex/PRM_DZPRegistration.createDZPRegistrationEntry';
import CheckDZPRegEntryCriteria from '@salesforce/apex/PRM_DZPRegistration.CheckDZPRegEntryCriteria';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DZPDisclaimerContent from '@salesforce/label/c.PCC_DZPDisclaimerContent_1';
import DZPPopUpMsg from '@salesforce/label/c.PRM_DZPPopUpMsg';
import cancel from '@salesforce/label/c.PRM_Cancel_ButtonLabel';
import confirm from '@salesforce/label/c.PRM_Confirm';
import DZPPopUpShortMsg from '@salesforce/label/c.PRM_DZPPopUpShortMsg';
import DZPRegistrationError from '@salesforce/label/c.PRM_DZP_Registration_Error';	
import ErrorMsg from '@salesforce/label/c.PRM_Error';
import DZPEnrollementForm from '@salesforce/label/c.PRM_DZP_Enrollement_Form';
import ThankYouPage from '@salesforce/label/c.PRM_Thank_You_Page';
import DZPBladeCustomLink from '@salesforce/label/c.PRM_DZP_Blade_Custom_Link';
import DZPCstlinkToolTip from '@salesforce/label/c.IPA_DZP_bnft_Description';


export default class PRM_DzpRegistration extends LightningElement {
    showDZPPopup = false;
    showThankYouPage = false;
    @track showSpinner = false;
    insertErr = DZPRegistrationError;
    @track ThankYouPageLink = ThankYouPage;

    label={
        confirm,
        DZPDisclaimerContent,
        DZPPopUpMsg,
        cancel,
        DZPPopUpShortMsg,
        DZPBladeCustomLink,
        DZPCstlinkToolTip
    };

    //check on click if need to create entry to the Registration Object or nevigate to dzp enrollment form
    async handleDZPClick(){
        this.showSpinner = true;
        await CheckDZPRegEntryCriteria().then(result => {
            // Handle success or show a toast message
            if(result){
                this.showDZPPopup = true;
            }else{
                window.open(DZPEnrollementForm, '_blank');
            }
        })
        .catch(error => {
                this.showToast(ErrorMsg, this.insertErr, 'error');
        });
        this.showSpinner = false;
    }

    handleCancelPopup(){
        this.showDZPPopup = false;
    }

    //make an entry to the Registration Object for DZP once user click on confirm button
    async handleConfirmPopup(){
        this.showSpinner = true;
        await createDZPRegistrationEntry().then(result => {
            if(result){
                // Open the thank you page in a new tab
                window.open(this.ThankYouPageLink, '_blank');
            }else{
                //show error toast message
                this.showToast(ErrorMsg, this.insertErr, 'error');
            }
        }).catch(error => {
            // Handle error or show an error message
            this.showToast(ErrorMsg, this.insertErr, 'error');
        }).finally(()=>{
            this.showSpinner = false;
            this.showDZPPopup = false;
        });
    }

    /**
     * @param  {} msgTitle
     * @param  {} msg
     * @param  {} type
     */
    showToast(msgTitle, msg, type) {
        console.log('In Toast');
        this.dispatchEvent(
            new ShowToastEvent({
                title: msgTitle,
                message: msg,
                variant: type,
                mode: 'dismissable'
            }),
        );
    }
}