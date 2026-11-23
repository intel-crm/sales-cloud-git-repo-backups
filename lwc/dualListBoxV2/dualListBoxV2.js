//dualListBox.JS
import { LightningElement, track, wire, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import findSelectedAccounts from "@salesforce/apex/Core_MDF_LWC_AccountUserController.findSelectedAccounts";
import saveAccountToUserData from "@salesforce/apex/Core_MDF_LWC_AccountUserController.saveAccountToUserMapping";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class dualListBoxV1 extends NavigationMixin(LightningElement) {
  @track _selected = [];
  @api searchKey;
  @track mapData = [];
  @track availableMapData = [];
  @track userMapDataArray = [];
  @track filteredUsers = [];
  @api accountSearchKey;
  @track loaded = true;
  @track searchFlag = false;
  _title = 'Successful';
  message = 'Account User Mapping Saved Sccessfully';
  variant = 'success';
  mode = 'sticky';

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
  }
  //To fetch all users available and mapped to selected accounts
  @wire(findSelectedAccounts, { userId: "$searchKey" })
  userWrapper({ data, error }) {
    this.loaded = !this.loaded;
    window.console.log("In find selected users");
    window.console.log(JSON.stringify(data));
    if (data) {
      // eslint-disable-next-line vars-on-top
      var availableUserInfoMap = data.toShowAtLeft;
      window.console.log("Left wrapper - " + availableUserInfoMap);
      for (let key in availableUserInfoMap) {
        if (availableUserInfoMap.hasOwnProperty(key)) {
          this.mapData.push({ label: availableUserInfoMap[key], value: key }); //Here we are creating the array to show on UI.
          this.userMapDataArray.push({
            label: availableUserInfoMap[key],
            value: key
          });
        }
      }

      if (this.mapData != null) {
        // eslint-disable-next-line vars-on-top
        var selectedUserInfoMap = data.toShowAtRight;
        window.console.log("Right wrapper - " + selectedUserInfoMap);
        for (let key in selectedUserInfoMap) {
          if (selectedUserInfoMap.hasOwnProperty(key)) {
            this.availableMapData.push(key); //Here we are creating the array to show on UI.
          }
        }
        //this.availableMapData.push(['005g0000006Ze81AAC']);
      }
      window.console.log(
        "onfetchdata::availableMapData::" + this.availableMapData
      );
    } else if (error) {
      window.console.log(error);
    }
    this.loaded = !this.loaded;
  }

  // Called on account record selection from lookup .this is the selected account record
  selectedRecord(event) {
    window.console.log("SelectedAtLast::" + event.detail.recordId);
    if (event.detail.recordId != null) {
      window.console.log("Inside selected Record");
      this.searchKey = event.detail.recordId;
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
      //clear search account field value
      this.accountSearchKey = "";
    }
  }

  //Called on Account select and populate all available and mapped users
  handleChange(e) {
      if(!this.searchFlag){
        window.console.log('Inside Handle Change IF, searchFlag::'+this.searchFlag);
        this.availableMapData = e.detail.value;
        window.console.log(
            "SelectedFromApex::availableMapData::" + this.availableMapData
            );
      }else{
        window.console.log('Inside Handle Change ELSE, searchFlag::'+this.searchFlag);
        //Clear selected values list from right box
        window.console.log("Inside handleChange first");
        //this.availableMapData = [];
        window.console.log("Inside handleChange" + e.detail.value);
        window.console.log(
        "SelectedFromApex before ::availableMapData::" + this.availableMapData
        );
        //all updated data from right side box
        // eslint-disable-next-line vars-on-top
        var updatedDataArr = e.detail.value;
        // eslint-disable-next-line vars-on-top
        for (var i = 0; i < updatedDataArr.length; i++) {
        //push all values same as latest selected
        this.availableMapData.push(updatedDataArr[i]);
        }
        window.console.log(
        "SelectedFromApex::availableMapData::" + this.availableMapData
        );
      }
  }

  //To save mapping data
  onSave() {
    this.loaded = !this.loaded;
    saveAccountToUserData({
      accountId: this.searchKey,
      userInfoData: this.availableMapData,
      objectName: "User"
    })
      // eslint-disable-next-line no-irregular-whitespace
      .then(result => {
        // eslint-disable-next-line no-console
        console.log("This is result: " + JSON.stringify(result));
        // eslint-disable-next-line no-irregular-whitespace
        if (result == null || result === undefined) {
          // eslint-disable-next-line no-alert
          //alert("Account User Mapping is saved");
          this.showNotification();
          window.console.log("A2U Mapping Saved");
        }else{
          // eslint-disable-next-line no-alert
          //alert(JSON.stringify(result));
          this.message = JSON.stringify(result);
          this.variant = "warning";
          this._title = "Invalid Entries!";
          this.showNotification();
        }
      })
      // eslint-disable-next-line no-irregular-whitespace
      .catch(error => {
        // eslint-disable-next-line no-alert
         //alert("Application error occured. Please contact help desk.");
         this.variant = "error";
         this.message = "Application Error occured. Please contact help desk.";
         this._title = "Application Error";
         this.showNotification();
        // eslint-disable-next-line no-console
        console.log("THis is the error: " + error);
      });
    this.loaded = !this.loaded;
  }

  //function to filter users from user search
  onAccountSearch(event) {
    this.searchFlag = true;
    window.console.log("inside account search - " + event.target.value);
    if (this.mapData != null) {
      window.console.log("acc string 1 - " + event.target.value);
      // eslint-disable-next-line vars-on-top
      this.accountSearchKey = event.target.value;
      window.console.log("acc string - " + this.accountSearchKey);
      if (event.target.value !== "") {
        // eslint-disable-next-line vars-on-top
        this.filteredUsers = this.userMapDataArray.filter((value, index) => {
          // eslint-disable-next-line no-unused-expressions
          window.console.log(
            "value from array - " + this.userMapDataArray[index].label
          );
          // eslint-disable-next-line vars-on-top
          var userLowerCaseValue = this.userMapDataArray[
            index
          ].label.toLowerCase();
          return userLowerCaseValue.includes(
            this.accountSearchKey.toLowerCase()
          );
        });
        window.console.log("filtyer data- " + this.filteredUsers);
        this.mapData = this.filteredUsers;
      } else {
        this.mapData = this.userMapDataArray;
      }
    }
  }
  //To close modal popup
  onCancel(evt) {
    // Stop the event's default behavior.
    // Stop the event from bubbling up in the DOM.
    evt.preventDefault();
    evt.stopPropagation();
    // Navigate to the Account Home page.
    this[NavigationMixin.Navigate](this.pnumHomePageRef);
  }
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