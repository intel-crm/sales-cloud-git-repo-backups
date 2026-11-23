/* eslint-disable no-inner-declarations */
/* eslint-disable guard-for-in */
/* eslint-disable no-mixed-spaces-and-tabs */
/* eslint-disable vars-on-top */
//dualListBox.JS
import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import findSelectedUsers from "@salesforce/apex/Core_MDF_LWC_AccountUserController.findSelectedUsers";
import saveAccountToUserData from "@salesforce/apex/Core_MDF_LWC_AccountUserController.saveAccountToUserMapping";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class dualListBoxV1 extends NavigationMixin(LightningElement) {
  @track _selected = [];
  @api searchKey;
  @track mapData = [];
  @track rightTempMap = [];
  @track availableMapData = [];
  @track userMapDataArray = [];
  @track userMapDataArray2 = [];
  @track tempCatchArray = [];
  @track finalCatchTempArray = [];
  @track filteredUsers = [];
  @api userSearchKey;
  @track loaded = true;
  @track searchFlag = false;
  _title = "Successful";
  message = "Account User Mapping Saved Sccessfully";
  variant = "success";
  mode = "sticky";
  @track tempInSearchRightArray = [];
  @track newTempArrayData = [];
  @track newTempArrayData2 = [];

  connectedCallback() {
    // Store the PageReference in a variable to use in handleClick.
    // This is a plain Javascript object that conforms to the
    // PageReference type by including "type" and "attributes" properties.
    // The "state" property is optional.
    this.pnumHomePageRef = {
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Core_MDF_Partner_Node_User_Mapping__c",
        actionName: "home"
      }
    };
    window.console.log("Inside ConnectedCallback::");
  }
  afterSelectionFindRecords(a) {
    findSelectedUsers({
      accountId: a
    })
      .then(result => {
        if (result !== null || result !== undefined) {
          window.console.log("result::" + result);
          var availableUserInfoMap = result.toShowAtLeft;
          for (let key in availableUserInfoMap) {
            if (availableUserInfoMap.hasOwnProperty(key)) {
              this.mapData.push({
                label: availableUserInfoMap[key],
                value: key
              }); //Here we are creating the array to show on UI.
              this.userMapDataArray.push({
                label: availableUserInfoMap[key],
                value: key
              });
              this.userMapDataArray2.push({
                label: availableUserInfoMap[key],
                value: key
              });
            }
          }
          if (this.mapData != null) {
            var selectedUserInfoMap = result.toShowAtRight;
            window.console.log("Right wrapper - " + selectedUserInfoMap);
            for (let key in selectedUserInfoMap) {
              if (selectedUserInfoMap.hasOwnProperty(key)) {
                this.availableMapData.push(key);
              }
            }
          }
          window.console.log(
            "onfetchdata::availableMapData::" + this.availableMapData
          );
        }
      })
      .catch(error => {
        window.console.log("THis is the error: " + error);
      });
  }

  // Called on account record selection from lookup .this is the selected account record
  selectedRecord(event) {
    window.console.log("SelectedAtLast::" + event.detail.recordId);
    if (event.detail.recordId != null) {
      window.console.log("Inside selected Record");
      this.searchKey = event.detail.recordId;
      this.afterSelectionFindRecords(this.searchKey);
      window.console.log("SelectedAtLast::" + this._selected);
    } else {
      window.console.log("Inside else selected Record");
      // set empty string to handle event
      this.searchKey = "";
      //Empty left and right values of dual list box
      this.mapData = [];
      this.availableMapData = [];
      //Temp array - clone of left available data, used in on user search
      this.userMapDataArray = [];
      this.userMapDataArray2 = [];
      //clear search user field value
      this.userSearchKey = "";
    }
  }
  handleChange(e) {
    this.mapData = [];
    this.mapData.push(...this.userMapDataArray2);
    if (!this.searchFlag) {
      window.console.log(
        "Inside Handle Change IF, searchFlag::" + this.searchFlag
      );
      this.availableMapData = e.detail.value;
      window.console.log(
        "Inside Handle Change IF, availableMapData::" + this.availableMapData
      );
    } else {
      var tempAvailableMapFromSearch = e.detail.value;
      window.console.log(
        "in else handle, e.detail.value::" + tempAvailableMapFromSearch
      );
      window.console.log("this.filteredUsers::" + this.filteredUsers);
      window.console.log("this.availableMapData::" + this.availableMapData);
      for (var i = 0; i < this.availableMapData.length; i++) {
        for (var k = 0; k < this.filteredUsers.length; k++) {
          window.console.log(
            "this.filteredUsers[i].value::" + this.filteredUsers[k].value
          );
          if (this.filteredUsers[k].value.includes(this.availableMapData[i])) {
            window.console.log(
              "this.availableMapData[i]::" + this.availableMapData[i]
            );
            this.tempCatchArray.push(this.availableMapData[i]);
          }
        }
      }
      window.console.log("this.tempCatchArray::" + this.tempCatchArray);
      this.finalCatchTempArray = arr_diff(
        this.tempCatchArray,
        this.availableMapData
      );
      window.console.log(
        "this.finalCatchTempArray::" + this.finalCatchTempArray
      );

      function arr_diff(a1, a2) {
        var a = [],
          diff = [];

        for (var j = 0; j < a1.length; j++) {
          a[a1[j]] = true;
        }

        for (var l = 0; l < a2.length; l++) {
          if (a[a2[l]]) {
            delete a[a2[l]];
          } else {
            a[a2[l]] = true;
          }
        }

        for (var z in a) {
          diff.push(z);
        }

        return diff;
      }
      this.availableMapData = e.detail.value;
      for (var k2 = 0; k2 < this.finalCatchTempArray.length; k2++) {
        if (!this.availableMapData.includes(this.finalCatchTempArray[k2])) {
          window.console.log(
            "this.finalCatchTempArray[k2]::" + this.finalCatchTempArray[k2]
          );
          this.newTempArrayData.push(...this.finalCatchTempArray[k2]);
          this.newTempArrayData2.push(this.finalCatchTempArray[k2]);
        }
      }

      window.console.log("this.newTempArrayData::" + this.newTempArrayData);
      window.console.log("this.newTempArrayData2::" + this.newTempArrayData2);

      this.availableMapData.push(...this.newTempArrayData2);
      window.console.log("this.availableMapData::" + this.availableMapData);
      this.finalCatchTempArray = [];
      this.tempCatchArray = [];
      this.newTempArrayData = [];
      this.newTempArrayData2 = [];
      this.searchFlag = false;
    }
  }

  //To save mapping data
  onSave() {
    this.loaded = !this.loaded;
    saveAccountToUserData({
      accountId: this.searchKey,
      userInfoData: this.availableMapData,
      objectName: "Account"
    })
      .then(result => {
        window.console.log("This is result: " + JSON.stringify(result));
        if (result == null || result === undefined) {
          this.showNotification();
          window.console.log("A2U Mapping Saved");
        } else {
          this.message = JSON.stringify(result);
          this.variant = "warning";
          this._title = "Invalid Entries!";
          this.showNotification();
        }
      })
      .catch(error => {
        this.variant = "error";
        this.message = "Application Error occured. Please contact help desk.";
        this._title = "Application Error";
        this.showNotification();
        window.console.log("THis is the error: " + error);
      });
    this.loaded = !this.loaded;
  }

  //function to filter users from user search
  onUserSearch(event) {
    this.tempInSearchRightArray = this.availableMapData;
    this.searchFlag = true;
    if (this.mapData != null) {
      this.userSearchKey = event.target.value;
      if (event.target.value !== "") {
        this.filteredUsers = this.userMapDataArray.filter((value, index) => {
          var userLowerCaseValue = this.userMapDataArray[
            index
          ].label.toLowerCase();
          return userLowerCaseValue.includes(this.userSearchKey.toLowerCase());
        });

        window.console.log("filtyer Left data::" + this.filteredUsers);
        this.mapData = [];
        this.mapData.push(...this.filteredUsers);
      } else {
        this.nullUserSearch(this.tempInSearchRightArray);
      }
    }
  }

  nullUserSearch(tempInSearchRight) {
    window.console.log("1:: " + this.availableMapData);
    this.mapData = [];
    this.mapData.push(...this.userMapDataArray2);
    window.console.log("mapDAta2:: " + this.mapData);
    this.availableMapData = [];
    window.console.log("after null2:: " + this.availableMapData);
    this.availableMapData.push(...tempInSearchRight);
    window.console.log("3:: " + this.availableMapData);
    this.searchFlag = false;
  }

  //To close modal popup
  onCancel() {
    this[NavigationMixin.Navigate](this.pnumHomePageRef);
  }

  showNotification() {
    this.onCancel();
    const evt = new ShowToastEvent({
      title: this._title,
      message: this.message,
      variant: this.variant,
      mode: this.mode
    });
    this.dispatchEvent(evt);
  }
}