import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//Import Apex Class Method
import fetchUsersByAccountId from "@salesforce/apex/Core_MDF_LWC_AccountUserController.findSelectedUsers";
//Import Labels
import accountFieldLabel from "@salesforce/label/c.Core_MDF_LWC_SelectAccount_Label";
import programFieldLabel from "@salesforce/label/c.Core_MDF_LWC_SelectProgram_Label";
import searchUserLabel from "@salesforce/label/c.Core_MDF_LWC_SearchUser_Label";
import availableLabel from "@salesforce/label/c.Core_MDF_Available_Label";
import selectedLabel from "@salesforce/label/c.Core_MDF_Selected_Label";
import applicationErrorMsg from "@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsg";
import applicationErrorMsgTitle from "@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle";

export default class LwcDualListBoxAccountUser extends LightningElement {
  //To hold Account Record Id
  @api selectedAccountId;
  //To Hold list of user for Left side in Dual List Box
  @track allAvailableUsers = [];
  //To Hold list of mapped user for right side in Dual List Box
  @api allAvailableMappedUsers = [];
  //To hold copy of allAvailableUsers List & used for filter user purpose
  @track filteredAvailableUsers = [];
  //To hold copy of allAvailableUsers List & used for tracking old values
  @track clonedAvailableUsers = [];
  //Tempraroy Array to hold filtered right side data on user search box
  @track tempFilteredDataOnRight = [];
  //Tempraroy Array to hold right side data after user filter
  @track removedRightDataOnFilter = [];
  //To hold filtered result on user filter in search box
  @track filteredUsers = [];
  //To hold searched string on user search box
  @api userSearchKey;
  //Flag to toggle Spinner
  @track spinner = true;
  //Flag to check if search used
  @track searchFlag = false;
  //To Hold Program Name
  @api programName; 
  //Input Disable
  @track inputDisable = false;

  //Toast Message attributes
  _title = applicationErrorMsgTitle;
  message = applicationErrorMsg;
  variant = "error";
  mode = "sticky";
  //To hold copy of right side data before user filter processed
  @track tempRightDataBeforeFilter = [];
  //To hold copy of removedRightDataOnFilter
  @track clonedRemovedRightDataOnFilter = [];

  // Expose the labels to use in the template.
  label = {
    accountFieldLabel,
    searchUserLabel,
    availableLabel,
    selectedLabel,
    programFieldLabel
  };

  //Called OnLoad
  connectedCallback(){
    this.inputDisable = true;
  }

  //programSelected
  programSelected(event) {
    this.template.querySelector("c-lwc-custom-lookup").resetData();
    this.resetAllData();
    this.programName = event.detail.programName;
    //On selection of select - disable input 
    if(event.detail.programName === 'select'){
      this.template.querySelector("c-lwc-custom-lookup").inputReadOnly = true;
      this.inputDisable = true;
    }else{
      this.template.querySelector("c-lwc-custom-lookup").inputReadOnly = false;
      this.inputDisable = false;
    }
  }

  //Focus Method
  focusMethod(){
    this.template.querySelector("c-lwc-custom-lookup").txtclassname = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
  }

  //Function called on selection of account record on account search lookup
  populateLookupUsers(accId) {
    var availableUserInfoMap;
    var selectedUserInfoMap;
    //afterSelectionFindRecords
    fetchUsersByAccountId({
      //findSelectedUsers
      accountId: accId
    })
      .then(result => {
        if (result !== null || result !== undefined) {
          //Getting all available user list
          availableUserInfoMap = result.toShowAtLeft;
          for (let key in availableUserInfoMap) {
            if (availableUserInfoMap.hasOwnProperty(key)) {
              //Creating the array of all available users to show on left box
              this.allAvailableUsers.push({
                label: availableUserInfoMap[key],
                value: key
              });
              //Cloned all available users
              this.filteredAvailableUsers.push({
                label: availableUserInfoMap[key],
                value: key
              });
              //Cloned all available users
              this.clonedAvailableUsers.push({
                label: availableUserInfoMap[key],
                value: key
              });
            }
          }
          
          if (this.allAvailableUsers != null) {
            //Getting mapped user list
            selectedUserInfoMap = result.toShowAtRight;
            for (let key in selectedUserInfoMap) {
              if (selectedUserInfoMap.hasOwnProperty(key)) {
                //Creating the array of all available mapped users to show on right box
                this.allAvailableMappedUsers.push(key);
              }
            }
          }
        }
        this.spinner = !this.spinner;
      })
      .catch(() => {
        this.showNotification();
        this.spinner = !this.spinner;
      });
  }

  // Function called on account record selection from lookup.This is the selected account record
  selectedRecord(event) {
    this.spinner = !this.spinner;
    if (event.detail.recordId != null) {
      //Selected account record Id
      this.selectedAccountId = event.detail.recordId;
      //To populate users list on account select from lookup search
      this.populateLookupUsers(this.selectedAccountId);
    } else {
      this.spinner = !this.spinner;
      //reset data
      this.resetAllData();
    }
  }

  //Function used to clear all populated data
  resetAllData() {
    //reset all populated data
    this.selectedAccountId = "";
    this.allAvailableUsers = [];
    this.allAvailableMappedUsers = [];
    this.filteredAvailableUsers = [];
    this.clonedAvailableUsers = [];
    this.userSearchKey = "";
  }

  //Called on shuffle and unshuffle data
  handleChange(e) {
    var indexOfRightMap;
    var indexOfFilteredMap;
    var indexOfRemovedRight;
    this.spinner = !this.spinner;
    this.allAvailableUsers = [];
    //Assign all available left side data
    this.allAvailableUsers.push(...this.clonedAvailableUsers);
    if (!this.searchFlag) {
      this.allAvailableMappedUsers = e.detail.value;
    } else {
      //To get the available data on right array after filter
      for (
        indexOfRightMap = 0;
        indexOfRightMap < this.allAvailableMappedUsers.length;
        indexOfRightMap++
      ) {
        for (
          indexOfFilteredMap = 0;
          indexOfFilteredMap < this.filteredUsers.length;
          indexOfFilteredMap++
        ) {
          if (
            this.filteredUsers[indexOfFilteredMap].value.includes(
              this.allAvailableMappedUsers[indexOfRightMap]
            )
          ) {
            this.tempFilteredDataOnRight.push(
              this.allAvailableMappedUsers[indexOfRightMap]
            );
          }
        }
      }
      //Get difference of all mapped data and filtered right data after search
      this.removedRightDataOnFilter = this.differenceOfArray(
        this.tempFilteredDataOnRight,
        this.allAvailableMappedUsers
      );

      this.allAvailableMappedUsers = e.detail.value;
      for (
        indexOfRemovedRight = 0;
        indexOfRemovedRight < this.removedRightDataOnFilter.length;
        indexOfRemovedRight++
      ) {
        if (
          !this.allAvailableMappedUsers.includes(
            this.removedRightDataOnFilter[indexOfRemovedRight]
          )
        ) {
          this.clonedRemovedRightDataOnFilter.push(
            this.removedRightDataOnFilter[indexOfRemovedRight]
          );
        }
      }
      //Assign all available right side data
      this.allAvailableMappedUsers.push(...this.clonedRemovedRightDataOnFilter);
      this.removedRightDataOnFilter = [];
      this.tempFilteredDataOnRight = [];
      this.clonedRemovedRightDataOnFilter = [];
      this.searchFlag = false;
    }
    this.spinner = !this.spinner;
  }

  //To get difference of array
  differenceOfArray(filteredUserOnRight, allAvailableUser) {
    var indexOfFilteredRight;
    var indexOfAvailUser;
    var user;
    var finalUserArray = [],
      arrayDataDifference = [];
    for (
      indexOfFilteredRight = 0;
      indexOfFilteredRight < filteredUserOnRight.length;
      indexOfFilteredRight++
    ) {
      finalUserArray[filteredUserOnRight[indexOfFilteredRight]] = true;
    }
    for (
      indexOfAvailUser = 0;
      indexOfAvailUser < allAvailableUser.length;
      indexOfAvailUser++
    ) {
      if (finalUserArray[allAvailableUser[indexOfAvailUser]]) {
        delete finalUserArray[allAvailableUser[indexOfAvailUser]];
      } else {
        finalUserArray[allAvailableUser[indexOfAvailUser]] = true;
      }
    }
    for (user in finalUserArray) {
      if (finalUserArray.hasOwnProperty(user)) {
        arrayDataDifference.push(user);
      }
    }
    return arrayDataDifference;
  }

  //function to filter users from user search box
  onUserSearch(event) {
    //Temprary array to hold right side data
    this.tempRightDataBeforeFilter = this.allAvailableMappedUsers;
    this.searchFlag = true;
    if (this.allAvailableUsers != null) {
      //search key
      this.userSearchKey = event.target.value;
      if (event.target.value !== "") {
        //Filtering data based on searched user
        this.filteredUsers = this.filteredAvailableUsers.filter(
          (value, index) => {
            var userLowerCaseValue = this.filteredAvailableUsers[
              index
            ].label.toLowerCase();
            return userLowerCaseValue.includes(
              this.userSearchKey.toLowerCase()
            );
          }
        );
        this.allAvailableUsers = [];
        //To display filtered data on left side
        this.allAvailableUsers.push(...this.filteredUsers);
      } else {
        //track old data
        this.reassignPreviousData(this.tempRightDataBeforeFilter);
      }
    }
  }

  //function to reassign previous data
  reassignPreviousData(rightSideData) {
    this.allAvailableUsers = [];
    //assign all available users
    this.allAvailableUsers.push(...this.clonedAvailableUsers);
    this.allAvailableMappedUsers = [];
    //assign all available mapped users
    this.allAvailableMappedUsers.push(...rightSideData);
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