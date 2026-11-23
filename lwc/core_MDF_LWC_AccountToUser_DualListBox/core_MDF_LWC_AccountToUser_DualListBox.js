/* eslint-disable no-inner-declarations */
/* eslint-disable guard-for-in */
/* eslint-disable no-mixed-spaces-and-tabs */
/* eslint-disable vars-on-top */
import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import fetchUsersByAccountId from "@salesforce/apex/Core_MDF_LWC_AccountUserController.findSelectedUsers"; //findSelectedUsers
import saveAccountToUserData from "@salesforce/apex/Core_MDF_LWC_AccountUserController.saveAccountToUserMapping";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import fetchUserInfo from "@salesforce/apex/Core_MDF_LWC_AccountUserController.fetchUserInfo";
import accountFieldLabel from "@salesforce/label/c.Core_MDF_LWC_SelectAccount_Label";
import communityRelativeUrl from "@salesforce/label/c.Core_MDF_PFRCommunityLink";

export default class Core_MDF_LWC_AccountToUser_DualListBox extends NavigationMixin(
  LightningElement
) {
  //To get user info
  @api usrType;
  //To hold Account Record Id
  @api recordId;
  //To Hold list of user for Left side in Dual List Box
  @track allAvailableUsers = []; // mapData
  //To Hold list of mapped user for right side in Dual List Box
  @track allAvailableMappedUsers = []; //availableMapData
  //To hold copy of allAvailableUsers List & used for filter user purpose
  @track clonedAllAvailableUsers = []; //userMapDataArray
  //To hold copy of allAvailableUsers List & used for tracking old values
  @track clonedAllAvailUsers = []; //userMapDataArray2
  //Tempraroy Array to hold filtered right side data on user search box
  @track tempFilteredDataOnRight = []; //tempCatchArray
  //Tempraroy Array to hold right side data after user filter
  @track removedRightDataOnFilter = []; //finalCatchTempArray
  //To hold filtered result on user filter in search box
  @track filteredUsers = [];
  //To hold searched string on user search box
  @api userSearchKey;
  //Flag to toggle Spinner
  @track loaded = true;
  //Flag to check if search used
  @track searchFlag = false;
  //Toast Message attributes
  _title = "Successful";
  message = "Account User Mapping Saved Sccessfully";
  variant = "success";
  mode = "sticky";
  //To hold copy of right side data before user filter processed
  @track tempRightDataBeforeFilter = []; //tempInSearchRightArray
  //To hold copy of removedRightDataOnFilter
  @track clonedRemovedRightDataOnFilter = []; //newTempArrayData

  // Expose the labels to use in the template.
  label = {
    accountFieldLabel
  };
  connectedCallback() {
    this.loaded = !this.loaded;
    fetchUserInfo({})
      .then(result => {
        if (result !== null || result !== undefined) {
          //Getting all available user list
          this.usrType = result;
          window.console.log("UserInfo cc::" + result);
        }
      })
      .catch(error => {
        window.console.log("THis is the error: " + error);
      });
    // Store the PageReference in a variable
    this.pnumHomePageRef = {
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Core_MDF_Partner_Node_User_Mapping__c",
        actionName: "home"
      }
    };
    this.loaded = !this.loaded;
  }
  //Function called on selection of account record on account search lookup
  populateLookupUsers(accId) {
    //afterSelectionFindRecords
    fetchUsersByAccountId({
      //findSelectedUsers
      accountId: accId
    })
      .then(result => {
        if (result !== null || result !== undefined) {
          //Getting all available user list
          var availableUserInfoMap = result.toShowAtLeft;
          for (let key in availableUserInfoMap) {
            if (availableUserInfoMap.hasOwnProperty(key)) {
              //Creating the array of all available users to show on left box
              this.allAvailableUsers.push({
                label: availableUserInfoMap[key],
                value: key
              });
              //Cloned all available users
              this.clonedAllAvailableUsers.push({
                label: availableUserInfoMap[key],
                value: key
              });
              //Cloned all available users
              this.clonedAllAvailUsers.push({
                label: availableUserInfoMap[key],
                value: key
              });
            }
          }
          if (this.allAvailableUsers != null) {
            //Getting mapped user list
            var selectedUserInfoMap = result.toShowAtRight;
            for (let key in selectedUserInfoMap) {
              if (selectedUserInfoMap.hasOwnProperty(key)) {
                //Creating the array of all available mapped users to show on right box
                this.allAvailableMappedUsers.push(key);
              }
            }
          }
        }
        this.loaded = !this.loaded;
      })
      .catch(error => {
        this.loaded = !this.loaded;
        window.console.log("THis is the error: " + error);
      });
  }

  // Function called on account record selection from lookup.This is the selected account record
  selectedRecord(event) {
    this.loaded = !this.loaded;
    if (event.detail.recordId != null) {
      //Selected account record Id
      this.recordId = event.detail.recordId;
      //To populate users list on account select from lookup search
      this.populateLookupUsers(this.recordId);
    } else {
      this.loaded = !this.loaded;
      //reset data
      this.resetAllData();
    }
  }

  //Function used to clear all populated data
  resetAllData() {
    //reset all populated data
    this.recordId = "";
    this.allAvailableUsers = [];
    this.allAvailableMappedUsers = [];
    this.clonedAllAvailableUsers = [];
    this.clonedAllAvailUsers = [];
    this.userSearchKey = "";
  }

  //Called on shuffle and unshuffle data
  handleChange(e) {
    this.loaded = !this.loaded;
    this.allAvailableUsers = [];
    //Assign all available left side data
    this.allAvailableUsers.push(...this.clonedAllAvailUsers);
    if (!this.searchFlag) {
      this.allAvailableMappedUsers = e.detail.value;
    } else {
      for (var i = 0; i < this.allAvailableMappedUsers.length; i++) {
        for (var k = 0; k < this.filteredUsers.length; k++) {
          if (
            this.filteredUsers[k].value.includes(
              this.allAvailableMappedUsers[i]
            )
          ) {
            this.tempFilteredDataOnRight.push(this.allAvailableMappedUsers[i]);
          }
        }
      }
      //Get difference of all mapped data and filtered right data after search
      this.removedRightDataOnFilter = this.differenceOfArray(
        this.tempFilteredDataOnRight,
        this.allAvailableMappedUsers
      );

      this.allAvailableMappedUsers = e.detail.value;
      for (var j = 0; j < this.removedRightDataOnFilter.length; j++) {
        if (
          !this.allAvailableMappedUsers.includes(
            this.removedRightDataOnFilter[j]
          )
        ) {
          this.clonedRemovedRightDataOnFilter.push(
            this.removedRightDataOnFilter[j]
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
    this.loaded = !this.loaded;
  }

  //To get difference of array
  differenceOfArray(filteredUserOnRight, allAvailableUser) {
    var finalUserArray = [],
      arrayDataDifference = [];
    for (var j = 0; j < filteredUserOnRight.length; j++) {
      finalUserArray[filteredUserOnRight[j]] = true;
    }
    for (var l = 0; l < allAvailableUser.length; l++) {
      if (finalUserArray[allAvailableUser[l]]) {
        delete finalUserArray[allAvailableUser[l]];
      } else {
        finalUserArray[allAvailableUser[l]] = true;
      }
    }
    for (var user in finalUserArray) {
      arrayDataDifference.push(user);
    }
    return arrayDataDifference;
  }

  //Function to save mappings
  onSave() {
    if (this.recordId != null && this.recordId.length > 0) {
      this.loaded = !this.loaded;
      saveAccountToUserData({
        recordId: this.recordId,
        objectListToBeProcessed: this.allAvailableMappedUsers,
        objectName: "Account"
      })
        .then(result => {
          window.console.log("This is result: " + JSON.stringify(result));
          if (result == null || result === undefined) {
            this.loaded = !this.loaded;
            this._title = "Successful";
            this.message = "Account User Mapping Saved Sccessfully";
            this.variant = "success";
            this.onCancel();
            this.showNotification();
          } else {
            this.loaded = !this.loaded;
            this.message = JSON.stringify(result);
            this.variant = "error";
            this._title = "Invalid Selection!";
            this.showNotification();
          }
        })
        .catch(error => {
          this.loaded = !this.loaded;
          this.variant = "error";
          this.message = "Application Error occured. Please contact help desk.";
          this._title = "Application Error";
          this.showNotification();
          window.console.log("THis is the error: " + error);
        });
    } else {
      this.variant = "error";
      this.message = "";
      this._title = "Required Fields Missing!";
      this.showNotification();
    }
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
        this.filteredUsers = this.clonedAllAvailableUsers.filter(
          (value, index) => {
            var userLowerCaseValue = this.clonedAllAvailableUsers[
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
    this.allAvailableUsers.push(...this.clonedAllAvailUsers);
    this.allAvailableMappedUsers = [];
    //assign all available mapped users
    this.allAvailableMappedUsers.push(...rightSideData);
    this.searchFlag = false;
  }

  //Navigate to account user home page on modal cancel/close
  onCancel() {
    if (this.usrType === "Standard") {
      window.console.log("usrType::" + this.usrType);
      this[NavigationMixin.Navigate](this.pnumHomePageRef);
    } else if (this.usrType === "PowerPartner") {
      window.console.log("usrType::" + this.usrType);
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