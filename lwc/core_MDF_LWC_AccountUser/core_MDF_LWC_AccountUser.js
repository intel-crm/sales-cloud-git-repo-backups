//Imports
import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import saveAccountToUserData from "@salesforce/apex/Core_MDF_LWC_AccountUserController.saveAccountUserMapping";
import fetchUserInfo from "@salesforce/apex/Core_MDF_LWC_AccountUserController.fetchUserInfo";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//Custom Labels
import accountToUserHeader from "@salesforce/label/c.Core_MDF_LWC_AccountUserHeader";
import userToAccountHeader from "@salesforce/label/c.Core_MDF_LWC_UserAccountHeader";
import action from "@salesforce/label/c.Core_MDF_LWC_ActionType";
import accToUserOption from "@salesforce/label/c.Core_MDF_LWC_AccToUser_Option";
import userToAccOption from "@salesforce/label/c.Core_MDF_LWC_UserToAcc_Option";
import communityRelativeUrl from "@salesforce/label/c.Core_MDF_PFRCommunityLink";
import standardUserType from "@salesforce/label/c.UserType_Standard";
import saveButtonName from "@salesforce/label/c.Core_MDF_LWC_SaveButton";
import cancelButtonName from "@salesforce/label/c.Core_MDF_LWC_CancelButton";
import successMsg from "@salesforce/label/c.Core_MDF_LWC_SuccessMessage";
import successMsgTitle from "@salesforce/label/c.Core_MDF_LWC_SuccessMsgTitle";
import applicationErrorMsg from "@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsg";
import applicationErrorMsgTitle from "@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle";
import requiredMsg from "@salesforce/label/c.Core_MDF_LWC_RequiredFieldErrorTitle";
import invalidSelectionTitle from "@salesforce/label/c.Core_MDF_LWC_InvalidSelectionTitle";

export default class Core_MDF_LWC_AccountUser extends NavigationMixin(
  LightningElement
) {
  //To know if it's been called from Account Detail Page
  @api accountRecordId;
  //To get user info
  @api usrType;
  //Boolean must be default to false
  //Flag to toggle component based on action
  @api isUserToAccountSelected;
  //Toast messages
  _title = successMsgTitle;
  message = successMsg;
  variant = "success";
  mode = "sticky";
  //Flag to toggle Spinner
  @track spinner = true;

  //Parameters for save function
  @track accOrUserRecordId;
  @track accOrUserRecordIdList;
  @track accOrUserMappingType;
  @track programName;
   applicationErrorMsg=applicationErrorMsg;
   applicationErrorMsgTitle=applicationErrorMsgTitle;

  // Expose the labels to use in the template.
  label = {
    accountToUserHeader,
    userToAccountHeader,
    action,
    accToUserOption,
    userToAccOption,
    saveButtonName,
    cancelButtonName
  };

  //Onload function
  connectedCallback() {
    //Get User Type
    this.getUserType();
    // Store the PageReference in a variable
    this.createAccUserPageReference();
  }

  //To switch component based on selected value from action dropdown
  onAccountUserActionChange(event) {
    //Hold element/field name
    const fieldName = event.target.name;
    if (fieldName === "accountUserAction") {
      //Check field value
      if (event.target.value === "A2U") {
        //If account to user action selected
        this.isUserToAccountSelected = false;
      } else {
        //If user to account action selected
        this.isUserToAccountSelected = true;
      }
    }
  }

  //Navigate to account user home page on close/cancel modal popup
  onCancel() {
    if(this.accountRecordId != null && this.accountRecordId.length > 0){
        //Navigate to Account Record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.accountRecordId,
                objectApiName: 'account',
                actionName: 'view',
            }
        });
    }else{
    //For Standard user
    if (this.usrType === standardUserType) {
      this[NavigationMixin.Navigate](this.accountUserHomePageRef);
    } else {
      //For community
      this.navigateToAccUserCommPage();
    }
  }
}
  //Function to save mappings
  onSave(accOrUsrId, accOrUsrIdList, objectName, progName) {
    console.log('Enter in the onSave');
    if (accOrUsrId != null && accOrUsrId.length > 0) {
      this.spinner = false;
      saveAccountToUserData({
        accountOrUserId: accOrUsrId,
        objectListToBeProcessed: accOrUsrIdList,
        mappingType: objectName,
        programName: progName
      })
        .then(result => {
          if (result !=''){
            console.log('Inside If-->', result);
            this.spinner = false;
            this.message = JSON.stringify(result);
            this.variant = "error";
            this._title = invalidSelectionTitle;  // Invalide selection Eg: CCF prgm : DCF AUSU user
            this.showNotification();
          }else{
            console.log('Inside else-->', result);
            this.spinner = false;
            this._title = successMsgTitle;
            this.message = successMsg;
            this.variant = "success";
            this.onCancel();
            this.showNotification();
          }
        })
        .catch(error => {
          console.log('Inside catchDoneTT-->', error);
                this.showGenericError(error);
              //  this.showNotification();             
        });
    } 
      else {
        console.log('Inside::else');
      this.variant = "error";
      this.message = "";
      this._title = requiredMsg;
      this.showNotification();
    }
  }
  //show notification on toast message
  showNotification() {
    const evt = new ShowToastEvent({
      title: this._title,
      message: this.message,
      variant: this.variant,
      mode: this.mode
    });
    this.dispatchEvent(evt);
  }

  //on save button clicked
  onClickOfSave() {
    if (this.isUserToAccountSelected) {
      this.accOrUserRecordId = this.template.querySelector(
        "c-lwc-dual-list-box-user-account"
      ).selectedUserId;
      this.accOrUserRecordIdList = this.template.querySelector(
        "c-lwc-dual-list-box-user-account"
      ).allAvailableMappedAccounts;
      this.accOrUserMappingType = "UserToAccount";
      this.programName = this.template.querySelector(
        "c-lwc-dual-list-box-user-account"
      ).program;
    } else {
      this.accOrUserRecordId = this.template.querySelector(
        "c-lwc-dual-list-box-account-user"
      ).selectedAccountId;
      this.accOrUserRecordIdList = this.template.querySelector(
        "c-lwc-dual-list-box-account-user"
      ).allAvailableMappedUsers;
      this.accOrUserMappingType = "AccountToUser";
    }
    this.onSave(
      this.accOrUserRecordId,
      this.accOrUserRecordIdList,
      this.accOrUserMappingType,
      this.programName
    );
  }


  //Get User Type
  getUserType() {
    fetchUserInfo({}).then(result => {
      if (result) {
        //Getting all available user list
        this.usrType = result;
      }
    });
  }

  // Create account user page reference and store in variable
  createAccUserPageReference() {
    this.accountUserHomePageRef = {
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Core_MDF_Partner_Node_User_Mapping__c",
        actionName: "home"
      }
    };
  }

  //Navigate to account user community page
  navigateToAccUserCommPage() {
    this[NavigationMixin.Navigate](
      {
        type: "standard__webPage",
        attributes: {
          url:
            communityRelativeUrl +
            "s/core-mdf-partner-node-user-mapping/Core_MDF_Partner_Node_User_Mapping__c/"
        }
      },
      true
    );
  }

  //Show Generic Error
  showGenericError(error) {
    console.log('inside showGenericError---' , error);
    if (error){

      this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: applicationErrorMsg,
                      variant: 'error'
                  })
              );
      // this.variant = "error";
      // this.message = applicationErrorMsg;
      
    }
  }
}