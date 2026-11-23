import { LightningElement , track} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//importing labels
import account from "@salesforce/label/c.Core_MDF_selectAccount";
import program from "@salesforce/label/c.Core_MDF_selectProgram";
import domain from "@salesforce/label/c.Core_MDF_EnterDomain";
import saveButtonName from "@salesforce/label/c.Core_MDF_LWC_SaveButton";
import cancelButtonName from "@salesforce/label/c.Core_MDF_LWC_CancelButton";
import acctCategory from "@salesforce/label/c.Core_MDF_AccountCategory";
import communityRelativeUrl from "@salesforce/label/c.Core_MDF_PFRCommunityLink";
import availableDomainHlpText from "@salesforce/label/c.Core_MDF_Available_Domain_Help_Text";
import accountHlpText from "@salesforce/label/c.Core_MDF_Account_Field_Help_Text";
import programHlpText from "@salesforce/label/c.Core_MDF_Program_Help_Text";
import acctCategoryHlpText from "@salesforce/label/c.Core_MDF_Account_Category_Help_Text";
import successMsgTitle from "@salesforce/label/c.Core_MDF_LWC_SuccessMsgTitle";
import successMsg from "@salesforce/label/c.Core_MDF_Success_Message";
import applicationErrorMsg from "@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsg";
import applicationErrorMsgTitle from "@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle";
import corporateRadioLabel from "@salesforce/label/c.Core_MDF_Corporate_Account_Label";
import agencyRadioLabel from "@salesforce/label/c.Core_MDF_Agency_Account_Label";
//importing apex class
import getLoggedInUserDetails from "@salesforce/apex/Core_MDF_AccountDomainMapping.getLoggedInUserDetails";
import updateEmailDomainInPGM from "@salesforce/apex/Core_MDF_AccountDomainMapping.updateEmailDomainInPGM";
export default class Acctlookup extends NavigationMixin(LightningElement) {
  //
  //@track value = '';
  //To store List of channelPrgram getting from apex
  @track channleProgLst;
  //To store Map of actCatAndActsMap getting from apex
  @track actCatAndActsMap;
  //To store Map of acctChanlProgAndDomainMap getting from apex
  @track acctChanlProgAndDomainMap;
  //list of account according to account category
  @track acctList;
  //spinner
  @track spinner = true;
  //to store old domain value
  @track emailDomainOld;

  toastTitle = successMsgTitle;
  message = successMsg;
  variant = "success";

  connectedCallback(){
    getLoggedInUserDetails()
    .then(result => {
      if (result !== null || result !== undefined) {
        this.error = undefined;
        this.channleProgLst = result.listOfchannelProg;
        this.actCatAndActsMap = result.mapOfAcctCategAndAccts;
        this.acctChanlProgAndDomainMap = result.mapOfAcctChanlProgAndDomain;
      }
    })
    .catch(error => {
      this.error = error;
      this.showGenericError(error);
    })
  }
  handleRadioButtonChange(event){
    for (let key in this.actCatAndActsMap) {
        if(this.actCatAndActsMap.hasOwnProperty(key) && key===event.target.value){
          this.acctList = this.actCatAndActsMap[key];
        }
    }
  }

  handleSelection(){
    let selectedAccount = this.template.querySelector('[data-id="accountSelected"]').value ;
    let selectedProgram = this.template.querySelector('[data-id="programSelected"]').value ;
    var acctChanlProgKey;
    if(selectedAccount!=='' && selectedProgram!==''){
      acctChanlProgKey = selectedAccount+'_'+selectedProgram;

      for(let key in this.acctChanlProgAndDomainMap){
        if(key===acctChanlProgKey){
          this.emailDomainOld=this.acctChanlProgAndDomainMap[key];
          this.template.querySelector('[data-id="availableDomain"]').value = this.acctChanlProgAndDomainMap[key];
        }
      }
    }
  }
  get options() {
    return [
        { label: corporateRadioLabel, value: 'Corporate' },
        { label: agencyRadioLabel, value: 'Agency' },
    ];
  }
  onCancel(){
    this.navigateToHomePage();
  }

  navigateToHomePage() {
    this[NavigationMixin.Navigate](
      {
        type: "standard__webPage",
        attributes: {
          url:communityRelativeUrl +"s/partnerfundclaim/PartnerFundClaim/"
        }
      },
      true
    );
  }

  onClickOfSave(){
    updateEmailDomainInPGM({
      acct: this.template.querySelector('[data-id="accountSelected"]').value,
      cp: this.template.querySelector('[data-id="programSelected"]').value,
      newDomain: this.template.querySelector('[data-id="availableDomain"]').value,
      oldDomain: this.emailDomainOld
    })
    .then(result => {
      if (result !== null || result !== undefined) {
        this.spinner = !this.spinner;
        this.toastTitle = successMsgTitle;
        this.message = result;
        this.variant = "success";
        this.onCancel();
        this.showNotification();
      }
    })
    .catch(error => {
      this.spinner = !this.spinner;
      this.showGenericError(error);
      this.onCancel();
      this.showNotification();
    });
  }

 //show notification on toast message
  showNotification() {
    const evt = new ShowToastEvent({
      title: this.toastTitle,
      message: this.message,
      variant: this.variant,
    });
    this.dispatchEvent(evt);
  }

  showGenericError(error) {
    if (error != null && error !== "" && error !== undefined) {
      this.variant = "error";
      this.message = applicationErrorMsg;
      this.toastTitle = applicationErrorMsgTitle;
    }
  }

    label = {
        account,
        program,
        domain,
        saveButtonName,
        cancelButtonName,
        acctCategory,
        availableDomainHlpText,
        accountHlpText,
        programHlpText,
        acctCategoryHlpText,
      };
}