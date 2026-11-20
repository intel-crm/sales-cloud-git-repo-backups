import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateActivity from '@salesforce/apex/Core_MDF_Reopen_Activity.validateActivity';
import reOpenActivity from '@salesforce/apex/Core_MDF_Reopen_Activity.reOpenActivity';

import Open_Activity_To_Claim_Label from '@salesforce/label/c.Core_MDF_Open_Activity_To_Claim';
import Button_HelpText_Label from '@salesforce/label/c.Core_MDF_Button_HelpText';
import ReOpen_Confirmation_HelpText_Label from '@salesforce/label/c.Core_MDF_ReOpen_Activity_Confirmation_Text';
import Success_Label from '@salesforce/label/c.Core_MDF_Success';
import Error_Label from '@salesforce/label/c.Core_MDF_Error';
import Activity_Reopened_Successfully_Label from '@salesforce/label/c.Core_MDF_Activity_Reopened_Successfully';
import User_Does_Not_Have_Access from '@salesforce/label/c.Core_MDF_CloneAccessError';
import Yes_Label from '@salesforce/label/c.Core_MDF_DQYes';
import No_Label from '@salesforce/label/c.Core_MDF_DQNo';



export default class Core_MDF_Reopen_Activity extends LightningElement {

  @api recordId;
 
  
  Open_Activity_To_Claim_Label = Open_Activity_To_Claim_Label;

  activityRecord;
  isShowContent = false;
  validationResult;
  eligibleReopenAmount;
  totalClaimedAmount;
  intelContribution;

  Yes_Label = Yes_Label;
  No_Label = No_Label;

  message_Label_1;
  message_Label_2;
  message_Label_3;
  message_Label_4;

  button_HelpText_label_1;
  button_HelpText_label_2;
  button_HelpText_label_3;
  button_HelpText_label_4;
  button_HelpText_label_5;





  connectedCallback(){
    this.validateResult();

    var reOpenHelpText = ReOpen_Confirmation_HelpText_Label.split('#');
    this.message_Label_1 = reOpenHelpText[0];
    this.message_Label_2 = reOpenHelpText[1];
    this.message_Label_3 = reOpenHelpText[2];
    this.message_Label_4 = reOpenHelpText[3];

    var butonHelpText = Button_HelpText_Label.split('#');
    this.button_HelpText_label_1 = butonHelpText[0];
    this.button_HelpText_label_2 = butonHelpText[1];
    this.button_HelpText_label_3 = butonHelpText[2];
    this.button_HelpText_label_4 = butonHelpText[3];
    this.button_HelpText_label_5 = butonHelpText[4];
  }

  validateResult() {
    validateActivity({ activityId: this.recordId })
      .then((data) => {
        this.validationResult = JSON.parse(data);
        console.log('validationResult',this.validationResult);
        if (this.validationResult.validationMsg == 'success') {
          this.eligibleReopenAmount = this.validationResult.pendingClaimableAmount;
          this.totalClaimedAmount = this.validationResult.totalClaimAmount;
          this.intelContribution = this.validationResult.intelContribution;
          this.isShowContent = true;
        }
        else {
          this.showToastMessage(Error_Label, this.validationResult.validationMsg, 'error','sticky');
          this.isShowContent = false;
        }
      })
      .catch(error => {
        this.showToastMessage(Error_Label, User_Does_Not_Have_Access, 'error','sticky');
        this.isShowContent = false;
      });
  }

  get claimedAmountUI() {
    var formatter = new Intl.NumberFormat('en-US', {style: 'currency',currency: 'USD'});
    return formatter.format(this.totalClaimedAmount);
  }

  get activityIntelContributionUI() {
    var formatter = new Intl.NumberFormat('en-US', {style: 'currency',currency: 'USD'});
    return formatter.format(this.intelContribution);
  }

  get activityPendingClaimAmountUI() {
    var formatter = new Intl.NumberFormat('en-US', {style: 'currency',currency: 'USD'});
    return formatter.format(this.eligibleReopenAmount);
  }

  handleCloseModal() {
    const closeModal = new CustomEvent('closemodal', {});
    this.dispatchEvent(closeModal);
  }

  handleSave() {
    this.isShowContent = false;
      reOpenActivity({actId: this.recordId})
      .then((result) => {
        console.log('result-->',result);
        if(result == 'success'){
          this.showToastMessage(Success_Label, Activity_Reopened_Successfully_Label, 'success','pester');
          location.reload();
        }else{
          this.showToastMessage(Error_Label, result, 'error','sticky');
        }
        
      })
      .catch(error => {
        this.showToastMessage(Error_Label, error.body.message, 'error','sticky');
      });
    this.isShowContent = false;
  }


  showToastMessage(title, message, variant,mode) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
      })
    );
    this.handleCloseModal();
  }
}