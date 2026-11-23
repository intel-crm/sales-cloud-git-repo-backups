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
import noneLabel from "@salesforce/label/c.Core_MDF_LWC_None_Label";
import headerLabel from "@salesforce/label/c.Core_MDF_Account_Domain_Mapping_Header_Label";
import requiredMsg from "@salesforce/label/c.Core_MDF_LWC_RequiredFieldErrorTitle";
import noPGMFoundWithSelectedValue from "@salesforce/label/c.Core_MDF_No_Records_available";
//importing apex class
import getLoggedInUserDetails from "@salesforce/apex/Core_MDF_AccountDomainMapping.getLoggedInUserDetails";
import updateEmailDomainInPGM from "@salesforce/apex/Core_MDF_AccountDomainMapping.updateEmailDomainInPGM";
export default class Acctlookup extends NavigationMixin(LightningElement) {

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
  //To store List of channelPrgram getting from apex
  @track channelProgramList;
  //To store ID of selected account
  @track selectedAccount;
  //To store ID of selected program
  @track selectedProgram;
  toastTitle = successMsgTitle;
  message = successMsg;
  variant = "success";
  
//On page load
  connectedCallback(){
    getLoggedInUserDetails()
    .then(result => {
      if (result !== null || result !== undefined) {
        this.error = undefined;
        this.channelProgramList = result.listOfchannelProg;
        this.actCatAndActsMap = result.mapOfAcctCategAndAccts;
        this.acctChanlProgAndDomainMap = result.mapOfAcctChanlProgAndDomain;
      }
    })
    .catch(error => {
      this.error = error;
      this.showGenericError(error);
    })
  }
  //After selecting any Radio button
  handleRadioButtonChange(event){
    for (let key in this.actCatAndActsMap) {
        if(this.actCatAndActsMap.hasOwnProperty(key) && key===event.target.value){
          this.acctList = this.actCatAndActsMap[key];
        }
    }
      this.channleProgLst = this.channelProgramList;
  }
//If account or channel Program is changed
  handleSelection(){
    var acctChanlProgKey;
    this.selectedAccount = this.template.querySelector('[data-id="accountSelected"]').value ;
    this.selectedProgram = this.template.querySelector('[data-id="programSelected"]').value ;
    
    if(this.selectedAccount!=='' && this.selectedProgram!==''){
      acctChanlProgKey = this.selectedAccount+'_'+this.selectedProgram;      
      for(let key in this.acctChanlProgAndDomainMap){
        if(key===acctChanlProgKey){
          this.emailDomainOld=this.acctChanlProgAndDomainMap[key];
          this.template.querySelector('[data-id="availableDomain"]').value = this.acctChanlProgAndDomainMap[key];
        }
        else{
          this.variant = "error";
          this.message = "";
          this.toastTitle = noPGMFoundWithSelectedValue;
          this.showNotification();
        }
      }
    }
  }
  //Radio group for Account Category
  get options() {
    return [
        { label: corporateRadioLabel, value: 'Corporate' },
        { label: agencyRadioLabel, value: 'Agency' },
    ];
  }
  //Cancel Button click or cancelling from cross icon
  onCancel(){
    this.navigateToHomePage();
  }
  //Navigation to home page
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
  //Save function to store the value
  onClickOfSave(){
    if(this.template.querySelector('[data-id="availableDomain"]').value !=='' && (this.selectedAccount!=='') && (this.selectedProgram!=='')){
      this.spinner = !this.spinner;
      updateEmailDomainInPGM({
        acct: this.template.querySelector('[data-id="accountSelected"]').value,
        cp: this.template.querySelector('[data-id="programSelected"]').value,
        newDomain: this.template.querySelector('[data-id="availableDomain"]').value,
        oldDomain: this.emailDomainOld
      })
      .then(result => {
        if (result !== null || result !== undefined) {
          window.console.log('result'+result);
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
    else{
      this.variant = "error";
      this.message = "";
      this.toastTitle = requiredMsg;
      this.showNotification();
    }
  }
 //show notification on toast message
  showNotification() {
    const evt = new ShowToastEvent({
      title: this.toastTitle,
      message: this.message,
      variant: this.variant,
      mode: 'sticky'
    });
    this.dispatchEvent(evt);
  }
  //To show Application error message
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
        noneLabel,
        headerLabel
      };
}