import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//Import Apex Class Method
import fetchAccountByUserId from "@salesforce/apex/Core_MDF_LWC_AccountUserController.findSelectedAccounts";
//Custom Labels
import userFieldLabel from "@salesforce/label/c.Core_MDF_LWC_SelectUser_Label";
import programFieldLabel from "@salesforce/label/c.Core_MDF_LWC_SelectProgram_Label";
import availableLabel from "@salesforce/label/c.Core_MDF_Available_Label";
import selectedLabel from "@salesforce/label/c.Core_MDF_Selected_Label";
import searchLabel from "@salesforce/label/c.Core_MDF_SearchAccount_Label";
import applicationErrorMsg from "@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsg";
import applicationErrorMsgTitle from "@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle";

export default class LwcDualListBoxAccountUser extends LightningElement {
  //To hold User Record Id
  @api selectedUserId;
  //To Hold list of accounts for Left side in Dual List Box
  @track allAvailableAccounts = [];
  //To Hold list of mapped accounts for right side in Dual List Box
  @api allAvailableMappedAccounts = [];
  //To hold copy of allAvailableAccounts List & used for filter account purpose
  @track filteredAvailableAccounts = [];
  //To hold copy of allAvailableAccounts List & used for tracking old values
  @track clonedAvailableUsers = [];
  //Tempraroy Array to hold filtered right side data on user search box
  @track tempFilteredDataOnRight = [];
  //Tempraroy Array to hold right side data after user filter
  @track removedRightDataOnFilter = [];
  //To hold filtered result on user filter in search box
  @track filteredAccounts = [];
  //To hold searched string on user search box
  @api accountSearchKey;
  //Flag to toggle Spinner
  @track spinner = true;
  //Flag to check if search used
  @track searchFlag = false;
  //Toast Message attributes
  _title = applicationErrorMsgTitle;
  message = applicationErrorMsg;
  variant = "error";
  mode = "sticky";
  //To hold copy of right side data before user filter processed
  @track tempRightDataBeforeFilter = [];
  //To hold copy of removedRightDataOnFilter
  @track clonedRemovedRightDataOnFilter = [];
  //Input Disable
  @track inputDisable = false;
 
//To Hold Program Name
  @api program; 

  // Expose the labels to use in the template.
  label = {
    userFieldLabel,
    availableLabel,
    selectedLabel,
    searchLabel,
    programFieldLabel
  };

  //Called OnLoad
  connectedCallback(){
    this.inputDisable = true;
  }
  
  //Function called on selection of user record on user search lookup
  populateLookupAccounts(usrId) {
    var availableAccountInfoMap;
    var selectedAccountInfoMap;
    fetchAccountByUserId({
      userId: usrId,
      programName: this.program
    })
      .then(result => {
        if (result !== null || result !== undefined) {
          //Getting all available accounts list
          availableAccountInfoMap = result.toShowAtLeft;
          for (let key in availableAccountInfoMap) {
            if (availableAccountInfoMap.hasOwnProperty(key)) {
              //Creating the array of all available accounts to show on left box
              this.allAvailableAccounts.push({
                label: availableAccountInfoMap[key],
                value: key
              });
              //Cloned all available accounts
              this.filteredAvailableAccounts.push({
                label: availableAccountInfoMap[key],
                value: key
              });
              //Cloned all available accounts
              this.clonedAvailableUsers.push({
                label: availableAccountInfoMap[key],
                value: key
              });
            }
          }
          if (this.allAvailableAccounts != null) {
            //Getting mapped accounts list
            selectedAccountInfoMap = result.toShowAtRight;
            for (let key in selectedAccountInfoMap) {
              if (selectedAccountInfoMap.hasOwnProperty(key)) {
                //Creating the array of all available mapped accounts to show on right box
                this.allAvailableMappedAccounts.push(key);
              }
            }
          }
        }
        this.spinner = !this.spinner;
      })
      .catch(() => {
        this.spinner = !this.spinner;
        this.showNotification();
      });
  }

  // Function called on user record selection from lookup.This is the selected user record
  selectedRecord(event) {
    this.spinner = !this.spinner;
    if (event.detail.recordId != null) {
      //Selected user record Id
      this.selectedUserId = event.detail.recordId;
      //To populate account list on user select from lookup search
      this.populateLookupAccounts(this.selectedUserId);
    } else {
      this.spinner = !this.spinner;
      //reset data
      this.resetAllData();
    }
  }

  //programSelected
  programSelected(event) {
    this.template.querySelector("c-lwc-custom-lookup-user").resetData();
    this.resetAllData();
    if(event.detail.programName === 'select'){
      this.template.querySelector("c-lwc-custom-lookup-user").inputReadOnly = true;
      this.inputDisable = true;
    }else{
      this.program = event.detail.programName;
      this.template.querySelector("c-lwc-custom-lookup-user").inputReadOnly = false;
      this.inputDisable = false;
    }
  }

  //Focus Method
  focusedMethod(){
    this.template.querySelector("c-lwc-custom-lookup-user").txtclassname = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
  }

  //Function used to clear all populated data
  resetAllData() {
    //reset all populated data
    this.selectedUserId = "";
    this.allAvailableAccounts = [];
    this.allAvailableMappedAccounts = [];
    this.filteredAvailableAccounts = [];
    this.clonedAvailableUsers = [];
    this.accountSearchKey = "";
  }

  //Called on shuffle and unshuffle data
  handleChange(e) {
    var indexOfRightMap;
    var indexOfFilteredMap;
    var indexOfRemovedRight;
    this.spinner = !this.spinner;
    this.allAvailableAccounts = [];
    //Assign all available left side data
    this.allAvailableAccounts.push(...this.clonedAvailableUsers);
    if (!this.searchFlag) {
      this.allAvailableMappedAccounts = e.detail.value;
    } else {
      //indexOfAvailMapAccs
      for (
        indexOfRightMap = 0;
        indexOfRightMap < this.allAvailableMappedAccounts.length;
        indexOfRightMap++
      ) {
        for (
          indexOfFilteredMap = 0;
          indexOfFilteredMap < this.filteredAccounts.length;
          indexOfFilteredMap++
        ) {
          if (
            this.filteredAccounts[indexOfFilteredMap].value.includes(
              this.allAvailableMappedAccounts[indexOfRightMap]
            )
          ) {
            this.tempFilteredDataOnRight.push(
              this.allAvailableMappedAccounts[indexOfRightMap]
            );
          }
        }
      }
      //Get difference of all mapped data and filtered right data after search
      this.removedRightDataOnFilter = this.differenceOfArray(
        this.tempFilteredDataOnRight,
        this.allAvailableMappedAccounts
      );

      this.allAvailableMappedAccounts = e.detail.value;
      for (
        indexOfRemovedRight = 0;
        indexOfRemovedRight < this.removedRightDataOnFilter.length;
        indexOfRemovedRight++
      ) {
        if (
          !this.allAvailableMappedAccounts.includes(
            this.removedRightDataOnFilter[indexOfRemovedRight]
          )
        ) {
          this.clonedRemovedRightDataOnFilter.push(
            this.removedRightDataOnFilter[indexOfRemovedRight]
          );
        }
      }
      //Assign all available right side data
      this.allAvailableMappedAccounts.push(
        ...this.clonedRemovedRightDataOnFilter
      );
      this.removedRightDataOnFilter = [];
      this.tempFilteredDataOnRight = [];
      this.clonedRemovedRightDataOnFilter = [];
      this.searchFlag = false;
    }
    this.spinner = !this.spinner;
  }

  //To get difference of array
  differenceOfArray(filteredUserOnRight, allAvailableAccounts) {
    var indexOfFilteredRight;
    var indexOfAvailAccount;
    var account;
    var finalAccountArray = [],
      arrayDataDifference = [];
    for (
      indexOfFilteredRight = 0;
      indexOfFilteredRight < filteredUserOnRight.length;
      indexOfFilteredRight++
    ) {
      finalAccountArray[filteredUserOnRight[indexOfFilteredRight]] = true;
    }
    for (
      indexOfAvailAccount = 0;
      indexOfAvailAccount < allAvailableAccounts.length;
      indexOfAvailAccount++
    ) {
      if (finalAccountArray[allAvailableAccounts[indexOfAvailAccount]]) {
        delete finalAccountArray[allAvailableAccounts[indexOfAvailAccount]];
      } else {
        finalAccountArray[allAvailableAccounts[indexOfAvailAccount]] = true;
      }
    }
    for (account in finalAccountArray) {
      if (finalAccountArray.hasOwnProperty(account)) {
        arrayDataDifference.push(account);
      }
    }
    return arrayDataDifference;
  }

  //function to filter account from account search box
  onAccountSearch(event) {
    //Temprary array to hold right side data
    this.tempRightDataBeforeFilter = this.allAvailableMappedAccounts;
    this.searchFlag = true;
    if (this.allAvailableAccounts != null) {
      //search key
      this.accountSearchKey = event.target.value;
      if (event.target.value !== "") {
        //Filtering data based on searched user
        this.filteredAccounts = this.filteredAvailableAccounts.filter(
          (value, index) => {
            var userLowerCaseValue = this.filteredAvailableAccounts[
              index
            ].label.toLowerCase();
            return userLowerCaseValue.includes(
              this.accountSearchKey.toLowerCase()
            );
          }
        );
        this.allAvailableAccounts = [];
        //To display filtered data on left side
        this.allAvailableAccounts.push(...this.filteredAccounts);
      } else {
        //track old data
        this.reassignPreviousData(this.tempRightDataBeforeFilter);
      }
    }
  }

  //function to reassign previous data
  reassignPreviousData(rightSideData) {
    this.allAvailableAccounts = [];
    //assign all available accounts
    this.allAvailableAccounts.push(...this.clonedAvailableUsers);
    this.allAvailableMappedAccounts = [];
    //assign all available mapped accounts
    this.allAvailableMappedAccounts.push(...rightSideData);
    this.searchFlag = false;
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
}