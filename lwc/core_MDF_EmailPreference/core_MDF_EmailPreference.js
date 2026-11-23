import { LightningElement, api, track, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/User.Name";
import { loadStyle } from 'lightning/platformResourceLoader';
import { refreshApex } from '@salesforce/apex';
import RadioGroupCSS from '@salesforce/resourceUrl/Core_MDF_PICRadioGroupCSS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getSubscriptionData from '@salesforce/apex/Core_MDF_SubUnsub_Notifications_Utility.getSubscriptionDetails';
import updateUserSubscriptionData from '@salesforce/apex/Core_MDF_SubUnsub_Notifications_Utility.addOrRemoveUserSubscriptionRecord';

export default class Core_MDF_EmailPreference extends NavigationMixin(LightningElement) {

    @track subscriptionDt = [];
    @track subscriptionCopy = [];
    showAccordion = false;
    @track userResponse = [];
    @track finalUserResponseMap =[];
    showMessage;
    wiredResponse;
    @track enableSave = true;
    @track enableCancelBtn = true;
    @track showModal = false;
    @track showSpinner = true;
    @track cancelClicked = true;
    @track showCancelModal

    //Get current logged in User Name
    @wire(getRecord, {
        recordId: userId,
        fields: [NAME_FIELD],
    })
    userRecord;

    get name() {
        return getFieldValue(this.userRecord.data, NAME_FIELD);
        //return this.userRecord.data.NAME_FIELD;
    }

    //Get Notification data from Notification Subscription Type object based on User access
    @wire(getSubscriptionData)
    wiredGetData(result) {
        this.wiredResponse = result;  
        const { data, error } = result;
        
        if (data && data.length > 0) {
            this.showAccordion = true;
            this.showMessage = false;
            console.log('data - ' + JSON.stringify(data));
            let subData = JSON.parse(JSON.stringify(data));
            subData.forEach(item => {
                //item.iconName = 'utility:chevronright';
                item.cssClassName = 'slds-section slds-is-close slds-var-p-left_xx-large slds-var-p-right_xx-large';
                item.isExpanded = false;

            })
            this.subscriptionDt = subData;
            console.log('subData - ' + JSON.stringify(subData));
        }
        else if(data && data.length == 0){
            this.showAccordion = false;
            this.showMessage = true;
            this.showSpinner = false;
        }
        else {
            this.showAccordion = false;
            this.showSpinner = true;
        }

       

        //Sort objects in ascending order
        this.subscriptionDt.sort((a, b) => (a.objectLabel.toLowerCase() > b.objectLabel.toLowerCase()) ? 1 : -1);      
        this.subscriptionCopy =  JSON.parse(JSON.stringify(this.subscriptionDt)) ;
    }

    /*options = [{
        objectName: 'Activity',
        notificationTypes: [
            {
                label: 'Status Update',
                apiname: 'Status Update',
                subscribed: 'Yes',
                mandate: true,
                helpText: 'This notification will be send on Activity Status Update'
            }],
        iconName: 'utility:chevronright',
        cssClassName: 'slds-section slds-is-close slds-var-p-left_large slds-var-p-right_large',
        isExpanded: false,
    }]*/

    //Change CSS when user opens a particular accordian
    getSubsDetailsOnExpand(event) {
        let currentsel = event.currentTarget.dataset.name;
        let selectedAccIndex = this.subscriptionDt.findIndex(opt => opt.objectName == currentsel);
        if (selectedAccIndex !== -1) {
            this.subscriptionDt[selectedAccIndex].isExpanded = this.subscriptionDt[selectedAccIndex].isExpanded ? false : true;
            if (this.subscriptionDt[selectedAccIndex].isExpanded) {
                this.subscriptionDt[selectedAccIndex].cssClassName = 'slds-section slds-is-open slds-var-p-left_xx-large slds-var-p-right_xx-large';
                //this.subscriptionDt[selectedAccIndex].iconName = 'utility:chevrondown';
            } else {
                this.subscriptionDt[selectedAccIndex].cssClassName = 'slds-section slds-is-close slds-var-p-left_xx-large slds-var-p-right_xx-large';
                //this.subscriptionDt[selectedAccIndex].iconName = 'utility:chevronright';
            }
        }
    }

    //Change CSS when user clicks on Expand All Button
    handleExpandAll() {
        this.subscriptionDt.forEach(item => {
            //item.iconName = 'utility:chevrondown';
            item.cssClassName = 'slds-section slds-is-open slds-var-p-left_xx-large slds-var-p-right_xx-large';
            item.isExpanded = true;

        })
        
    }

    //Change CSS when user clicks on Collapse All Button
    handleCollapseAll() {
        this.subscriptionDt.forEach(item => {
            //item.iconName = 'utility:chevronright';
            item.cssClassName = 'slds-section slds-is-close slds-var-p-left_xx-large slds-var-p-right_xx-large';
            item.isExpanded = false;

        })
    }

    //Execute logic when user clicks on Save button
    handleInputSave() {

        if (this.userResponse && this.userResponse.length > 0) {
            this.showModal = true;
        }
        else {
            const FailureEvent1 = new ShowToastEvent({
                title: 'Error',
                message: 'Nothing is selected for Save action',
                variant: 'error'
            });
            this.dispatchEvent(FailureEvent1);
        }
    }

    //Reset data when user clicks on Cancel button
    handlecancel() {
        this.showCancelModal = true;
        
    }

    handleModalNo(event) {
        this.showModal = false;
    }

    
    hideModal() {
        this.showModal = false;
    }

    //On click of Yes button, Call apex method to insert/update IQR Email Preference records    
    handleModalSave(event) {
        this.showModal = false;
        this.userResponse.forEach(item => {
            this.finalUserResponseMap.push(JSON.stringify(item));
        })
        console.log('Final Result - ' +JSON.stringify(this.userResponse));
        if (this.finalUserResponseMap && this.finalUserResponseMap.length > 0) {
            updateUserSubscriptionData({ subsUnsubsData: this.finalUserResponseMap })
                .then(result => {
                    const successEvent = new ShowToastEvent({
                        title: 'Success',
                        message: 'Reponse has been saved Successfully',
                        variant: 'success'
                    });
                    this.dispatchEvent(successEvent);
                    setTimeout(function () {
                        window.location.reload();
                    }, 3000);
                })
                .catch(exception => {
                    console.log('exception - ' + JSON.stringify(exception));
                    const successEvent = new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(exception) + 'Application Error Occurred. Please contact help desk.',
                        variant: 'error'
                    });
                    this.dispatchEvent(successEvent);
                });
        }
        else {
            const FailureEvent1 = new ShowToastEvent({
                title: 'Error',
                message: 'Nothing is selected for Save action',
                variant: 'error'
            });
            this.dispatchEvent(FailureEvent1);
        }

    }

    //Store User responses in a map
    handleResponseChange(event) {
        let selectedOption = event.target.checked;
        console.log('selectedOption - '+selectedOption);
        let selectedNotificationName = event.target.name;
        console.log('selectedNotificationName - '+selectedNotificationName);
        let selectedObjectName = event.target.dataset.object;
        let existingResponse;
        let subscriptionRecId;
        let index = this.subscriptionDt.findIndex(temp => temp.objectName == selectedObjectName);
        console.log('index - '+ index);
        if(index != -1) {
            let notificationtype = this.subscriptionDt[index].notificationTypes;
            console.log('data - '+JSON.stringify(this.subscriptionDt[index].notificationTypes));

                let notifyIndex = this.subscriptionDt[index].notificationTypes.findIndex(notify => notify.apiname == selectedNotificationName);
                console.log('index1 - '+ notifyIndex);
                if(notifyIndex != -1) {

                    existingResponse = this.subscriptionCopy[index].notificationTypes[notifyIndex].subscribed;
                    
                    subscriptionRecId = this.subscriptionDt[index].notificationTypes[notifyIndex].subsRecId;
                    if(selectedOption != existingResponse) {
                        this.subscriptionDt[index].notificationTypes[notifyIndex].isRowSelected = true;
                    }
                    else {
                        this.subscriptionDt[index].notificationTypes[notifyIndex].isRowSelected = false;
                    }
                    this.subscriptionDt[index].notificationTypes[notifyIndex].subscribed = selectedOption;
            }
        }
        console.log('existingResponse - '+existingResponse);
        console.log('147- ' + event.target.name);
        console.log('148- ' + event.target.dataset.object);
        console.log('278- ' + subscriptionRecId);
        let responseArray = {};
        responseArray.objectName = event.target.dataset.object;
        responseArray.notificationName = selectedNotificationName;
        responseArray.response = selectedOption;
        responseArray.subsRecId = subscriptionRecId;

        //If user response array is not null 
        if(this.userResponse != null && this.userResponse.length > 0 ) {
            let notifyIndex =  this.userResponse.findIndex(notify => notify.notificationName == selectedNotificationName);
            
            //If current Notification type is not part of user response array
            if(notifyIndex == -1 && (existingResponse != selectedOption)) {
                this.userResponse.push(responseArray);
            }
            //If current Notification type is already part of user response array
            else {
                //If current response is not matching with original data
                if(existingResponse != selectedOption) {
                    this.userResponse[notifyIndex].response = selectedOption;
                }
                //If current response is matching with original data
                else if (existingResponse == selectedOption) {
                    this.userResponse.splice(notifyIndex,1);
                }
                
            }
        }
        else {
            if(existingResponse != selectedOption) {
                this.userResponse.push(responseArray);
            }
            
        }


        //Enable Save button when user selects atleast one Notification type     
        if (this.userResponse.length > 0) {
            this.enableSave = false;
            this.enableCancelBtn = false;
        }
        else {
            this.enableSave = true;
            this.enableCancelBtn = true;
        }
        console.log('Response : ' + JSON.stringify(this.userResponse));

    }
    handleCancelModalSave() {
        this.showCancelModal = false;
        this.cancelClicked = false;
        this.userResponse = [];
        this.finalUserResponseMap =[];
        let tempSubscriptionData = JSON.parse(JSON.stringify(this.subscriptionCopy)) ;

        console.log('wiredResponse ' + JSON.stringify(this.wiredResponse));

        tempSubscriptionData.forEach(item => {
                let selectedAccIndex = this.subscriptionDt.findIndex(opt => opt.objectName == item.objectName);
                item.isExpanded = this.subscriptionDt[selectedAccIndex].isExpanded;

                item.cssClassName = 'slds-section slds-is-open slds-var-p-left_xx-large slds-var-p-right_xx-large';
                //item.iconName = 'utility:chevrondown';
                //item.isRowSelected = false ;
                //item.notificationTypes.subscribed = true;
                //item.notificationTypes = this.subscriptionDt[selectedAccIndex].notificationTypes;
                /*item.notificationTypes.forEach(notype => {
                    notype.subscribed = true;
                });*/
                
                console.log('item -> '+JSON.stringify(item));
        })
        //this.cancelClicked = true;
        this.subscriptionDt = JSON.parse(JSON.stringify(tempSubscriptionData)) ;
        this.subscriptionDt.sort((a, b) => (a.objectLabel.toLowerCase() > b.objectLabel.toLowerCase()) ? 1 : -1);      
        this.cancelClicked = true;
        console.log('item -> '+JSON.stringify(this.subscriptionDt));

    }
    handleCancelModalNo() {
        this.showCancelModal = false;
    }
}