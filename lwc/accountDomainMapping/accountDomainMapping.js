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
import failedMsgTitle from "@salesforce/label/c.Core_MDF_Claim_Batch_Failed";
import successMsg from "@salesforce/label/c.Core_MDF_Success_Message";
import applicationErrorMsg from "@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsg";
import applicationErrorMsgTitle from "@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle";
import corporateRadioLabel from "@salesforce/label/c.Core_MDF_Corporate_Account_Label";
import agencyRadioLabel from "@salesforce/label/c.Core_MDF_Agency_Account_Label";
import noneLabel from "@salesforce/label/c.Core_MDF_LWC_None_Label";
import headerLabel from "@salesforce/label/c.Core_MDF_Account_Domain_Mapping_Header_Label";
import requiredMsg from "@salesforce/label/c.Core_MDF_LWC_RequiredFieldErrorTitle";
import noChangesMsg from "@salesforce/label/c.Core_MDF_Toast_Message";
import oldDomainLabel from "@salesforce/label/c.Core_MDF_Old_Domain_Label";
import newDomainLabel from "@salesforce/label/c.Core_MDF_New_Domain_Label";
import confirmationMsg from "@salesforce/label/c.Core_MDF_Confirmation_Message";
import confirmationModalHeader from "@salesforce/label/c.Core_MDF_Modal_Pop_Up_Header";
import yesButtonLabel from "@salesforce/label/c.Core_MDF_Cancel_Claim_Yes";
//importing apex class
import getLoggedInUserDetails from "@salesforce/apex/Core_MDF_AccountDomainMapping.getLoggedInUserDetails";
import updateEmailDomainInPGM from "@salesforce/apex/Core_MDF_AccountDomainMapping.updateEmailDomainInPGM";
export default class Acctlookup extends NavigationMixin(LightningElement) {

  //To store List of channelPrgram getting from apex
  @track channelProgList;
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
  channelProgramList;
  //To store ID of selected account
  selectedAccount;
  //To store ID of selected program
  selectedProgram;
  //To store domain
  @track updatedDomain;
  //to control classes of pop up message
  @track modalClass = 'slds-modal ';
   //to control classes of pop up message
  @track modalBackdropClass = 'slds-backdrop ';
  //to store new domain list
  @track newDomainList;
  //to store old domain list
  oldDomainList;
  //to store removed domain list
  @track removedDomainList= new Array();
  //to check if any new domain is added or not
  domainAdded=false;
  //toast variables
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
        window.console.log('ProgramList'+this.channelProgramList );
        this.actCatAndActsMap = result.mapOfAcctCategAndAccts;
        window.console.log('actCatAndActsMap'+this.actCatAndActsMap );
        this.acctChanlProgAndDomainMap = result.mapOfAcctChanlProgAndDomain;
        window.console.log('acctChanlProgAndDomainMap'+this.acctChanlProgAndDomainMap );
      }
    })
    .catch(error => {
      this.error = error;
      this.showGenericError(error);
    })
  }

  //After selecting any Radio button
  handleRadioButtonChange(event){
    this.template.querySelector('[data-id="accountSelected"]').value = '';
    this.template.querySelector('[data-id="programSelected"]').value = '';
    this.template.querySelector('[data-id="availableDomain"]').value = '';
    window.console.log('HereIam');
    for (let key in this.actCatAndActsMap) {
      if(this.actCatAndActsMap.hasOwnProperty(key) && key===event.target.value){
        this.acctList = this.actCatAndActsMap[key];
      }
    }
    window.console.log('acctList'+this.acctList);
    window.console.log('List@#'+this.channelProgramList);
    //check if below is actually required, 
    if(this.template.querySelector('[data-id="accountSelected"]').value === ''){
      window.console.log('YESD');
      this.template.querySelector('[data-id="programSelected"]').value = '';
    }      
  }

  //If account or channel Program is changed
  handleSelection(){
    //use value attribute of text area instead of querySelector
    //for select - 
    var acctChanlProgKey;
    this.selectedAccount = this.template.querySelector('[data-id="accountSelected"]').value ;
    this.selectedProgram = this.template.querySelector('[data-id="programSelected"]').value ;
    
    if(this.template.querySelector('[data-id="accountSelected"]').value===''){
      this.template.querySelector('[data-id="programSelected"]').value ='';
    }
    else{
      window.console.log('YESD2');
      window.console.log('Lists'+this.channelProgramList);
      this.channelProgList = this.channelProgramList;
      window.console.log('Listsdf'+this.channelProgList);
    }
    window.console.log('qqqYESD2');
    if(this.template.querySelector('[data-id="accountSelected"]').value==='' && this.template.querySelector('[data-id="programSelected"]').value ===''
    || this.template.querySelector('[data-id="accountSelected"]').value!=='' && this.template.querySelector('[data-id="programSelected"]').value ===''){
      window.console.log('YEddSD2');
      this.template.querySelector('[data-id="availableDomain"]').value = '';
    }
    window.console.log('selectedAccount'+this.selectedAccount);
    window.console.log('selectedProgram'+this.selectedProgram);
    if(this.selectedAccount!=='' && this.selectedProgram!==''){
      window.console.log('YESHer');
      acctChanlProgKey = this.selectedAccount+'_'+this.selectedProgram;     
      window.console.log('acctChanlProgKey'+this.acctChanlProgKey);
      for(let key in this.acctChanlProgAndDomainMap){
        if(key===acctChanlProgKey){
          window.console.log('IamInside');
          this.emailDomainOld=this.acctChanlProgAndDomainMap[key];
          window.console.log('IamInside2'+this.emailDomainOld);
          this.template.querySelector('[data-id="availableDomain"]').value = this.acctChanlProgAndDomainMap[key];
          window.console.log('IamInside3'+this.template.querySelector('[data-id="availableDomain"]').value);
          break;
        }
      }
    }
  }

  //Radio group for Account Category
  get options() {
    return [
        { label: corporateRadioLabel, value: corporateRadioLabel },
        { label: agencyRadioLabel, value: agencyRadioLabel },
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
          url:communityRelativeUrl +"s/accountdomainmapping"
        }
      },
      true
    );
  }

  //On clicking Yes button of pop up model
  onClickOfOK(){
    var i;
    var j;
    if(this.template.querySelector('[data-id="availableDomain"]').value !=='' && (this.selectedAccount!=='') && (this.selectedProgram!=='')){
    this.spinner = !this.spinner;
    this.oldDomainList = this.emailDomainOld.split(';');
    this.newDomainList = this.template.querySelector('[data-id="availableDomain"]').value.split(';');
    this.removedDomainList.length=0;
    
    window.console.log('oldDomainList1'+this.oldDomainList);
    window.console.log('newDomainList1'+this.newDomainList);

    for (i = 0; i < this.oldDomainList.length; i++) {
      if(!(this.newDomainList.includes(this.oldDomainList[i]))){
        this.removedDomainList.push(this.oldDomainList[i]);
      }
    }
    window.console.log('removedDomainList'+this.removedDomainList);

    for (j = 0; j < this.newDomainList.length; j++) {
      if(!(this.oldDomainList.includes(this.newDomainList[j]))){
        this.domainAdded = true;
        //break;
      }
    }

    if((this.removedDomainList===null || this.removedDomainList.length===0) && !(this.domainAdded)){
      //this is 1st case where no domain is added nor removed, no need to call server
      this.toastTitle = successMsgTitle;
      this.message = noChangesMsg;
      this.variant = "success";
      this.onCancel();
      this.showNotification();
    }
    else if((this.removedDomainList===null || this.removedDomainList.length===0)  && (this.domainAdded)){
      //this is 2nd case where domain is only added
      updateEmailDomainInPGM({
        acct: this.template.querySelector('[data-id="accountSelected"]').value,
        channelProg: this.template.querySelector('[data-id="programSelected"]').value,
        newDomain: this.template.querySelector('[data-id="availableDomain"]').value,
        removedDomainList: this.removedDomainList
      })
      .then(result => {
        if (result !== null || result !== undefined) {
            this.spinner = !this.spinner;
            this.toastTitle = successMsgTitle;
            this.message = result.message;
            this.variant = result.variant;
            this.onCancel();
            this.showNotification();
          }
        })
      .catch(error => {
        this.spinner = !this.spinner;
        this.showGenericError(error);
        this.showNotification();
        });
    }
    else{
      //this is 3rd case where domain is removed & 4th case
      updateEmailDomainInPGM({
        acct: this.template.querySelector('[data-id="accountSelected"]').value,
        channelProg: this.template.querySelector('[data-id="programSelected"]').value,
        newDomain: this.template.querySelector('[data-id="availableDomain"]').value,
        removedDomainList: this.removedDomainList
      })
      .then(result => {
        if (result !== null || result !== undefined) {
          if(result.variant==='error'){
            this.spinner = !this.spinner;
            this.modalClass = 'slds-modal ';
            this.modalBackdropClass = 'slds-backdrop ';
            this.toastTitle = failedMsgTitle;
            this.message = result.message;
            this.variant = result.variant;
            this.showNotification();
          }
          else if(result.variant==='success'){
              this.spinner = !this.spinner;
              this.toastTitle = successMsgTitle;
              this.message = result.message;
              this.variant = result.variant;
              this.onCancel();
              this.showNotification();
          }
        }
      })
      .catch(error => {
        this.spinner = !this.spinner;
        this.showGenericError(error);
        this.showNotification();
      });
      }
    }
    else{
        this.variant = "error";
        this.message = "";
        this.toastTitle = requiredMsg;
        this.showNotification();
    }
  }

  //On clicking cancel button of pop up model
  onClickOfClose(){
    this.modalClass = 'slds-modal ';
    this.modalBackdropClass = 'slds-backdrop ';
  }

  //new save code which will call pop up 
  onClickOfSave(){
    this.updatedDomain = this.template.querySelector('[data-id="availableDomain"]').value;
    this.modalClass = 'slds-modal slds-fade-in-open';
    this.modalBackdropClass = 'slds-backdrop slds-backdrop_open';
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
      this.modalClass = 'slds-modal ';
      this.modalBackdropClass = 'slds-backdrop ';
    }
  }

  //labels
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
    headerLabel,
    oldDomainLabel,
    newDomainLabel,
    confirmationModalHeader,
    yesButtonLabel,
    confirmationMsg
  };
}