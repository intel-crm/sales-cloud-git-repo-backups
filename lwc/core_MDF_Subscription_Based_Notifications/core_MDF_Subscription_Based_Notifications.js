import { LightningElement, api, track, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/User.Name";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getSubscriptionData from '@salesforce/apex/Core_MDF_SubUnsub_Notifications_Utility.getSubscriptionDetails';
import saveUserResponse from '@salesforce/apex/Core_MDF_SubUnsub_Notifications_Utility.addOrRemoveUserSubscriptionRecord';
import SubsNotification_NoData_Msg from '@salesforce/label/c.Core_MDF_SubsNotification_NoData_Msg';
import SubsNotifications_SaveBtn_Msg from '@salesforce/label/c.Core_MDF_SubsNotifications_SaveBtn_Msg';
import SubsNotifications_CancelBtn_Msg from '@salesforce/label/c.Core_MDF_SubsNotifications_CancelBtn_Msg';
import SubsNotification_SuccessMsg from '@salesforce/label/c.Core_MDF_SubsNotification_SuccessMsg';
import SubsNotification_Error_Msg from '@salesforce/label/c.Core_MDF_SubsNotification_Error_Msg';
import ApplicationErrorMessage from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import SubsNotification_Disclaimer_Msg from '@salesforce/label/c.Core_MDF_SubsNotification_Disclaimer_Msg';
import SubsNotification_MandateNotification_Msg from '@salesforce/label/c.Core_MDF_SubsNotification_MandateNotification_Msg';
import SubsNotification_Header_Title from '@salesforce/label/c.Core_MDF_SubsNotification_HeaderTitle';
import SuccessTitle from '@salesforce/label/c.Core_MDF_Success';
import ErrorTitle from '@salesforce/label/c.Core_MDF_Error';
import SubscriptionEmulationScreen_Msg from '@salesforce/label/c.Core_MDF_SubscriptionEmulationScreen_Msg';
import getUser from '@salesforce/apex/Core_MDF_SubUnsub_Notifications_Utility.getUserList';
import checkEmulationAccessAndGetAppList from '@salesforce/apex/Core_MDF_SubUnsub_Notifications_Utility.checkEmulationAccessAndGetAppList';
import { CurrentPageReference } from 'lightning/navigation';


export default class Core_MDF_Subscription_Based_Notifications extends NavigationMixin(LightningElement) {

    @track subscriptionData = [];
    @track originalSubscriptionData = [];
    @track showNotificationDetails = false;
    @track userResponse = [];
    @track showNoDataMessage = false;
    @track disableSaveBtn = true;
    @track disableCancelBtn = true;
    @track showSaveModal = false;
    @track showSpinner = true;
    @track showCancelModal
    @track showApplicationErrorMessage = false;
    @track showSubscriptionScreen = false;
    @track userList = [];
    @track messageFlag = false;
    @track selUserName ='';
    @track selUserEmail ='';
    @track valueselected ='';
    @track usrId = '';
    @track showSelUserName ='';
    @track hasEmulationAccess = false;
    @track showUserSearchModal = false;
    @track hasUserList = false;
    @track disableProceedBtn = true;
    @track disableSearchCancelBtn = true;
    @track showSelUserDetails = false;
    @track selApplication ='';
    @track appOptions =[];
    @track disableAppDropdown = false;
    @track isUserOnSelfSubscription;
    @track showHomePage = false;
    @track hasNotificationDatails = false;
    @track disableUserSearch = true;
    @track dynamiClassname = 'slds-size_8-of-12';
    @track selUserActive ;
    @track selUserLicenseReclaimed;
    labels = {SubsNotification_NoData_Msg,SubsNotifications_SaveBtn_Msg,SubsNotifications_CancelBtn_Msg,SubsNotification_SuccessMsg,
              SubsNotification_Error_Msg,ApplicationErrorMessage,SubsNotification_Disclaimer_Msg,
              SubsNotification_MandateNotification_Msg,SubsNotification_Header_Title,SuccessTitle, ErrorTitle,SubscriptionEmulationScreen_Msg};

    //Get current logged in User Name
    @wire(getRecord, {
        recordId: userId,
        fields: [NAME_FIELD],
    })
    userRecord;

    get name() {
        return this.selUserName;
    }


    connectedCallback() {     
        checkEmulationAccessAndGetAppList()
        .then((data) => {
            if(data != {} && Object.keys(data).length > 0) {
                const applicationList = data.appList;
                console.log('applicationList - '+applicationList);
            if(data.hasEmulationAccess) {
                this.hasEmulationAccess = true ;
                this.showSubscriptionScreen = false;
                this.showHomePage = true;
                this.showSpinner = false;
                if(applicationList && applicationList.length > 0 ) {
                    if(applicationList.length == 1) {
                    this.appOptions.push({ label: applicationList[0], value: applicationList[0]});
                    this.selApplication = applicationList[0];
                    this.disableAppDropdown = true;
                    this.disableUserSearch = false;
                   }
                  else {
                    applicationList.forEach(mdt => {
                       this.appOptions.push({ label: mdt, value: mdt});
                    });
                }               
                }
            } else {
                this.showHomePage = false;
                this.isUserOnSelfSubscription = true;
                this.selUserName = getFieldValue(this.userRecord.data, NAME_FIELD);
                this.usrId = userId;
                this.getData();
            }
            }
            
               
        })
        .catch(error => {
           this.hasEmulationAccess = false ;
           this.showSubscriptionScreen = false;
           this.showSpinner = false;
           this.showToastMessage(this.labels.ErrorTitle,'error',this.labels.ApplicationErrorMessage,false);
        });
    }

   

  getData()  {
    getSubscriptionData({usrId: this.usrId, application: this.selApplication})
    .then((data) => {
        if (data && data.length > 0) {
            let subData = JSON.parse(JSON.stringify(data));
            subData.forEach(item => {
                item.iconName = 'utility:chevrondown';
                item.cssClassName = 'slds-section slds-is-open slds-var-p-left_xx-large slds-var-p-right_xx-large';
                item.isExpanded = true;

            })
            this.subscriptionData = subData;
            
            //Sort objects in ascending order
            this.subscriptionData.sort((a, b) => (a.objectLabel.toLowerCase() > b.objectLabel.toLowerCase()) ? 1 : -1);      
            this.originalSubscriptionData =  JSON.parse(JSON.stringify(this.subscriptionData)) ;
            this.showSubscriptionScreen = true;
            this.showNotificationDetails = true;
            this.showSpinner = false;
           
        }
        else if(data && data.length == 0){
            this.showSubscriptionScreen = true;
            this.showNotificationDetails = false;
            this.showNoDataMessage = true;
            this.showSpinner = false;
           
        }
           
    })
    .catch(error => {
        this.showNotificationDetails = false;
        this.showSpinner = false;
        let reloadPage = this.hasEmulationAccess;
        this.showToastMessage(this.labels.ErrorTitle,'error',this.labels.ApplicationErrorMessage,reloadPage);
    });
  }
   

    //Change CSS when user opens a particular accordian
    handleSecExpandOrCollapse(event) {
        const currentsel = event.currentTarget.dataset.name;
        const selectedAccIndex = this.subscriptionData.findIndex(opt => opt.objectName == currentsel);
        if (selectedAccIndex !== -1) {
            this.subscriptionData[selectedAccIndex].isExpanded = this.subscriptionData[selectedAccIndex].isExpanded ? false : true;
            if (this.subscriptionData[selectedAccIndex].isExpanded) {
                this.subscriptionData[selectedAccIndex].cssClassName = 'slds-section slds-is-open slds-var-p-left_xx-large slds-var-p-right_xx-large';
                this.subscriptionData[selectedAccIndex].iconName = 'utility:chevrondown';
            } else {
                this.subscriptionData[selectedAccIndex].cssClassName = 'slds-section slds-is-close slds-var-p-left_xx-large slds-var-p-right_xx-large';
                this.subscriptionData[selectedAccIndex].iconName = 'utility:chevronright';
            }
        }
    }


     //Store User responses in a map
     handleToggleChange(event) { 
        const selectedResponse = event.target.checked;
        const selectedNotificationName = event.target.name;
        const selectedObjectName = event.target.dataset.object;
        let existingResponse;
        let subscriptionRecId;
        const index = this.originalSubscriptionData.findIndex(temp => temp.objectName == selectedObjectName);
        if(index != -1) {
                const notifyIndex = this.originalSubscriptionData[index].notificationTypes.findIndex(notify => notify.apiname == selectedNotificationName);
                if(notifyIndex != -1) {

                    existingResponse = this.originalSubscriptionData[index].notificationTypes[notifyIndex].subscribed;
                    
                    subscriptionRecId = this.originalSubscriptionData[index].notificationTypes[notifyIndex].subsRecId;
                    if(selectedResponse != existingResponse) {
                        this.subscriptionData[index].notificationTypes[notifyIndex].isRowSelected = true;
                    }
                    else {
                        this.subscriptionData[index].notificationTypes[notifyIndex].isRowSelected = false;
                    }
                    this.subscriptionData[index].notificationTypes[notifyIndex].subscribed = selectedResponse;
            }
        }

        const responseArray = {};
        responseArray.objectName = event.target.dataset.object;
        responseArray.notificationName = selectedNotificationName;
        responseArray.response = selectedResponse;
        responseArray.subsRecId = subscriptionRecId;
        responseArray.userId = this.usrId;

        //If user response array is not null 
        if(this.userResponse != null && this.userResponse.length > 0 ) {
            const notifyIndex =  this.userResponse.findIndex(notify => notify.notificationName == selectedNotificationName);
            
            //If current Notification type is not part of user response array
            if(notifyIndex == -1 && (existingResponse != selectedResponse)) {
                this.userResponse.push(responseArray);
            }
            //If current Notification type is already part of user response array
            else {
                //If current response is not matching with original data
                if(existingResponse != selectedResponse) {
                    this.userResponse[notifyIndex].response = selectedResponse;
                }
                //If current response is matching with original data
                else if (existingResponse == selectedResponse) {
                    this.userResponse.splice(notifyIndex,1);
                }
                
            }
        }
        else {
            if(existingResponse != selectedResponse) {
                this.userResponse.push(responseArray);
            }
            
        }
        //Enable Save button when user selects atleast one Notification type     
        if (this.userResponse && this.userResponse.length > 0) {
            this.disableSaveBtn = false; 
            this.disableCancelBtn = false;
        }
        else {
            this.disableSaveBtn = true;
            this.disableCancelBtn = true;
        }

    }
    //Execute logic when user clicks on Save button
    handleSave() {
        this.showSaveModal = true;
        this.disableSaveBtn = true;
        this.disableCancelBtn = true;
   }

   //Reset data when user clicks on Cancel button
    handlecancel() {
       this.showCancelModal = true;
       this.disableSaveBtn = true;
       this.disableCancelBtn = true;
    
   }

    //On click of Yes button, Call apex method to insert/update IQR Email Preference records , onClickOfYesFromSaveModal   
    handleSaveModalYes(event) {
        this.showSaveModal = false;
        this.showSpinner = true;
        console.log('Final Result - ' +JSON.stringify(this.userResponse));
        if (this.userResponse && this.userResponse.length > 0) {
            saveUserResponse({ subsUnsubsData: this.userResponse }) 
                .then(result => {
                    console.log('result - '+result);
                    if(result != null && result == 'Success') {  
                        this.showToastMessage(this.labels.SuccessTitle,'success',this.labels.SubsNotification_SuccessMsg,false);
                        this.getData();
                    }
                    else {
                        this.showSpinner = false;
                        this.resetSubscriptionData();
                        this.showToastMessage(this.labels.ErrorTitle,'error',this.labels.SubsNotification_Error_Msg,false);                   
                    }
            }).catch(exception => {
                        this.showSpinner = false;
                        this.resetSubscriptionData();
                        this.showToastMessage(this.labels.ErrorTitle,'error',this.labels.SubsNotification_Error_Msg,false);                   
                });
               
        }
    }

    handleSaveModalNo(event) {
        this.showSaveModal = false;
        if (this.userResponse && this.userResponse.length > 0) {
        this.disableSaveBtn = false;
        this.disableCancelBtn = false;
        }
    }
 
    resetSubscriptionData() {
        this.disableSaveBtn = true;
        this.disableCancelBtn = true;
        this.userResponse = [];
        let tempSubscriptionData = JSON.parse(JSON.stringify(this.originalSubscriptionData)) ;

        //Logic to retain collapsable/Expandable mode of the section on click of 'Yes' from cancel confirmation modal
        tempSubscriptionData.forEach(item => {
                const selectedAccIndex = this.subscriptionData.findIndex(opt => opt.objectName == item.objectName);
                item.isExpanded = this.subscriptionData[selectedAccIndex].isExpanded;
                item.cssClassName = this.subscriptionData[selectedAccIndex].cssClassName;
                item.iconName = this.subscriptionData[selectedAccIndex].iconName;
                console.log('item -> '+JSON.stringify(item));
        })

        this.subscriptionData = JSON.parse(JSON.stringify(tempSubscriptionData)) ;

    }

    handleCancelModalYes() {
        this.showCancelModal = false;
        this.disableSaveBtn = true;
        this.disableCancelBtn = true;
        this.userResponse = [];
        let tempSubscriptionData = JSON.parse(JSON.stringify(this.originalSubscriptionData)) ;

        //Logic to retain collapsable/Expandable mode of the section on click of 'Yes' from cancel confirmation modal
        tempSubscriptionData.forEach(item => {
                const selectedAccIndex = this.subscriptionData.findIndex(opt => opt.objectName == item.objectName);
                item.isExpanded = this.subscriptionData[selectedAccIndex].isExpanded;
                item.cssClassName = this.subscriptionData[selectedAccIndex].cssClassName;
                item.iconName = this.subscriptionData[selectedAccIndex].iconName;
                console.log('item -> '+JSON.stringify(item));
        })

        this.subscriptionData = JSON.parse(JSON.stringify(tempSubscriptionData)) ;

    }
    handleCancelModalNo() {
        this.showCancelModal = false;
        if (this.userResponse && this.userResponse.length > 0) {
        this.disableSaveBtn = false;
        this.disableCancelBtn = false;
        }
    }

    handleYourselfBtn() {
        this.isUserOnSelfSubscription = true;
        this.showHomePage = false;
        this.selUserName = getFieldValue(this.userRecord.data, NAME_FIELD);
        this.usrId = userId;
        this.getData(); 
    }

    handleOthersBtn() {
        this.isUserOnSelfSubscription = false;
        this.showUserSearchModal = true;
    }

    searchUser(event) {
        const userName = event.target.value;
        if(userName =='') {
            this.disableProceedBtn = true;
            this.disableSearchCancelBtn = true;
            this.showSelUserDetails = false;
            this.hasUserList = false;
        }
        else {
        getUser({ userName: userName, app: this.selApplication})
            .then(result => {
                this.userList = result;
                this.hasUserList = true;
                this.dynamiClassname = result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open slds-size_8-of-12' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_8-of-12';
                console.log('length' + result.length);
            })
            .catch(error => {
                console.log(error);
                this.showToastMessage(this.labels.ErrorTitle,'error',this.labels.ApplicationErrorMessage,true);
            });
        }
    }

    getDataBasedOnSelUser(event) {
        this.valueselected = event.currentTarget.dataset.name;
        this.selUserName = event.currentTarget.dataset.name;
        this.selUserEmail = event.currentTarget.dataset.email;
        this.selUserActive = event.currentTarget.dataset.active;
        this.selUserActive = this.selUserActive.toUpperCase();
        this.selUserLicenseReclaimed = event.currentTarget.dataset.reclaim;
        this.selUserLicenseReclaimed = this.selUserLicenseReclaimed.toUpperCase();
        this.usrId = event.currentTarget.dataset.id;

        if( this.selApplication !='' && this.valueselected !='') {
            this.disableProceedBtn = false;
            this.disableSearchCancelBtn = false;
            this.showSelUserDetails = true;
        }
        else {
            this.disableProceedBtn = true;
            this.disableSearchCancelBtn = true;
        }

        this.dynamiClassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-size_8-of-12';

    }

    handleApplicationChange(event) {
        this.selApplication = event.target.value;
        this.valueselected = '';
        this.hasUserList = false;
        this.showSelUserDetails = false;
        this.disableProceedBtn = true;
        this.disableSearchCancelBtn = true;  
        if( this.selApplication !='') {
               this.disableUserSearch = false;      
        }    
     }

    goToHomePage() {
        this.userResponse =[];
        this.subscriptionData =[];
        this.showHomePage = true;
        this.showSubscriptionScreen = false;
        this.showUserSearchModal = false;
        if(this.appOptions && this.appOptions.length > 1) {
             this.selApplication = ''; 
        }
      
        this.valueselected = '';
        this.hasUserList = false;
        this.showSelUserDetails = false;
        this.disableProceedBtn = true;
        this.disableSearchCancelBtn = true;
        if(this.appOptions && this.appOptions.length > 1) {
                 this.disableUserSearch = true;
        }
   
        this.showNoDataMessage = false;
        this.usrId = '';
    }

     handleProceedBtnClick() {
            this.getData();
            this.showHomePage = false;
    }

    handleSearchModalClose() {
        this.showUserSearchModal = false;
        this.valueselected = '';
        this.showSelUserDetails = false;
         if(this.appOptions && this.appOptions.length > 1) {
                 this.disableUserSearch = true;
        }
        if(this.appOptions && this.appOptions.length > 1) {
             this.selApplication = ''; 
        }
        this.disableProceedBtn = true;
        this.disableSearchCancelBtn = true;
        this.hasUserList = false;
        
        
    }
    @wire(CurrentPageReference)
    setCurrentPageReference() {
    this.showNoDataMessage = false;
    if(this.hasEmulationAccess) {
            this.showSubscriptionScreen = false;
            this.showHomePage = true;
    }
        this.resetSubscriptionData(); 
        this.showUserSearchModal = false;
        if(this.appOptions && this.appOptions.length > 1) {
             this.selApplication = ''; 
        }
        if(this.appOptions && this.appOptions.length > 1) {
                 this.disableUserSearch = true;
        }
        this.valueselected = '';
        this.showSelUserDetails = false;
        this.disableProceedBtn = true;
        this.disableSearchCancelBtn = true;
        this.hasUserList = false;

    
}

     //Method to fire toast message
     showToastMessage(title,mode,message,loadWindow) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: mode
        });
        
        this.dispatchEvent(toastEvent);
        if(loadWindow) {
            setTimeout(function () {
                window.location.reload();
            }, 4000);
        }
       
    }

}