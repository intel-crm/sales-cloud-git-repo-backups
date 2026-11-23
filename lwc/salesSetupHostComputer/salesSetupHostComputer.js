/*********************************************************************************************************************
Version       : 1.0
Created Date  : Apr 2021

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        16-Apr-2021             salesSetupHostComputer LWC Component
* ---------------------------------------------------------------------------------------------------------*/
import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//CONTROLLER
import getUserDetails from '@salesforce/apex/Sales_SetupHostComputerController.getUserDetails';

//Import the current user’s ID 
import userId from '@salesforce/user/Id';

//LABELS
import successTxt from '@salesforce/label/c.Sales_Order_Success';                        //Success title
import errorMsg from '@salesforce/label/c.Sales_Error_Message';                          //Error title
import computerCreatedSuccess from '@salesforce/label/c.Sales_Host_CreatedSuccessfully'; //Computer Created successfully.
//import successTxt from '@salesforce/label/c.Sales_Order_Success';                       //Success title
//import errorMsg from '@salesforce/label/c.Sales_Error_Message';     
import SalesOrderSuccess from '@salesforce/label/c.Sales_Order_Success';                       //Success title
import SalesErrorMessage from '@salesforce/label/c.Sales_Error_Message';  
import SalesHostCreatedSuccessfully from '@salesforce/label/c.Sales_Host_CreatedSuccessfully';
import SalesCompInfoHTML from '@salesforce/label/c.Sales_CompInfo_HTML';  
import SalesServerInfo from '@salesforce/label/c.Sales_ServerInfo';
import SalesAddCompErrHTML from '@salesforce/label/c.Sales_AddComp_Err_HTML';
import Sales_Cancel from '@salesforce/label/c.Sales_Cancel';  
import Sales_OrderSubmit_HTML from '@salesforce/label/c.Sales_OrderSubmit_HTML';
import Sales_AddComp_Err_HTML from '@salesforce/label/c.Sales_AddComp_Err_HTML';


label = {
    successTxt,
    computerCreatedSuccess,
    errorMsg,
    SalesOrderSuccess,
    SalesErrorMessage,
    SalesHostCreatedSuccessfully,
    SalesCompInfoHTML,
    SalesServerInfo,
    SalesAddCompErrHTML,
    Sales_AddComp_Err_HTML,
    Sales_OrderSubmit_HTML,
    Sales_Cancel
    


};



export default class SalesSetupHostComputer extends NavigationMixin(LightningElement) {

    //Template show/hide flags
    @api showAddComputerModal = false;
    @api islicTypeFloat = false;
    @api islicTypeFixed = false;

    //Data
    @api licenseType;
    @api loggedInUserId = userId;
    @api contactId = '';
    @api contactAccountId = '';

    //Labels
    label = {
        successTxt,
        computerCreatedSuccess,
        errorMsg
    };

    //Handle errors on submission
    handleError(event) {
        console.log('handleError: ' + JSON.stringify(event.detail));
        this.fireToastEvent(this.label.errorMsg, event.detail.detail, 'error', 'dismissable');
    }

    //Submitting Form
    handleSubmit(event) {
        //console.log('handleSubmit Payload: '+ JSON.stringify(event.detail) );
        event.preventDefault();                 // stop the form from submitting
        const fields = event.detail.fields;
        console.log('fields: ' + JSON.stringify(fields));

        if (this.contactId != '') {
            fields.Sales_Contact__c = this.contactId;
            console.log('Set: ' + fields.Sales_Contact__c + ' , this=' + this.contactId);
        }

        if (this.contactAccountId != '') {
            fields.Sales_Account__c = this.contactAccountId;
            console.log('Set: ' + fields.Sales_Account__c + ' , this=' + this.contactAccountId);
        }

        console.log('submit fields: ' + JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    //Data submitted successfully, perform Host Computer Record Creation 
    handleSuccess(event) {
        this.fireToastEvent(this.label.successTxt, this.label.computerCreatedSuccess, 'success', 'dismissable');
        console.log('Record Id Generated for new Host:', event.detail.id);
        this.closeAddComputerModal();
    }

    handleLicenseTypeChange(event) {
        this.licenseType = event.target.value;
        console.log('Selected License Type: ' + this.licenseType);
        if (this.licenseType == 'FLOAT') {
            this.islicTypeFixed = false;
            this.islicTypeFloat = true;
            //console.log('floatflag:'+this.islicTypeFloat + ' , fixedflag:'+ this.islicTypeFixed );
        }
        else if (this.licenseType == 'FIXED') {
            this.islicTypeFloat = false;
            this.islicTypeFixed = true;
            //console.log('floatflag:'+this.islicTypeFloat + ' , fixedflag:'+ this.islicTypeFixed );
        }
        else {
            this.islicTypeFloat = false;
            this.islicTypeFixed = false;
            //console.log('floatflag:'+this.islicTypeFloat + ' , fixedflag:'+ this.islicTypeFixed );
        }
    }

    fireToastEvent(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    closeAddComputerModal() {
        this.showAddComputerModal = false;
    }

    openAddComputerModal() {
        this.showAddComputerModal = true;
        //Setting defaults
        this.islicTypeFloat = false;
        this.islicTypeFixed = false;

        //Assigning the Contact & Account to Host Computer Record
        console.log('Logged In user Id : ' + this.loggedInUserId);
        getUserDetails({ uId: this.loggedInUserId })
            .then((result) => {
                console.log('Controller result payload: ' + JSON.stringify(result));
                if (result != null) {
                    if (result.Contact != null) {
                        this.contactId = result.Contact.Id;
                        this.contactAccountId = result.Contact.AccountId;
                    }
                    console.log('Contact Id: ' + this.contactId + ' , Contact Account Id: ' + this.contactAccountId);
                }
            })
            .catch((error) => {
                this.closeAddComputerModal();
                this.fireToastEvent(this.label.errorMsg, error.body.message, 'error', 'sticky');
            });

    }

}