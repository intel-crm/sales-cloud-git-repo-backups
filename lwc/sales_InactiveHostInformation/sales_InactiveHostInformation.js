import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import errorMsg from '@salesforce/label/c.Sales_Error_Message';
import checkLicesnseExpirationDate from '@salesforce/apex/Sales_SetupHostComputerController.checkLicesnseExpirationDate';
import checkHostActivationStatus from '@salesforce/apex/Sales_SetupHostComputerController.checkHostActivationStatus';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import SalesErrorMessage from '@salesforce/label/c.Sales_Error_Message';
import SalesHostDeactivation from '@salesforce/label/c.Sales_Host_Deactivation';
import SalesInactiveHostError from '@salesforce/label/c.Sales_InactiveHost_Error';
import SalesHostHtml from '@salesforce/label/c.Sales_Host_Html';
import SalesHostconfirmationHtml from '@salesforce/label/c.Sales_Host_confirmation_Html';
import SalesOrderSuccess from '@salesforce/label/c.Sales_Order_Success';
import Sales_infomsg from '@salesforce/label/c.Sales_infomsg';
import Sales_yes from '@salesforce/label/c.Sales_yes';
import Sales_no from '@salesforce/label/c.Sales_no';
import SalesHostActivation from '@salesforce/label/c.Sales_Host_Activation';
//import Sales_infomsg from '@salesforce/label/c.Sales_infomsg';
const FIELDS = ['Sales_Host__c.Id', 'Sales_Host__c.Sales_isActiveHost__c'];
export default class Sales_InactiveHostInformation extends NavigationMixin(LightningElement) {
    label = {
        errorMsg
    };
    @api visible;
    @api recordId;
    @api salesActivateHost;
    @api hostData;
    @api returnedData;
    @api iSActivecheck;
    @api error;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    host;
    label={
        SalesErrorMessage,
        SalesHostDeactivation,
        SalesInactiveHostError,
        SalesHostHtml,
        SalesHostconfirmationHtml,
        SalesOrderSuccess,
        Sales_infomsg,
        Sales_yes,
        Sales_no,
				SalesHostActivation
    }

    handleOnLoad() {
      if (this.host.data != undefined) {
            console.log('Host data1' + this.host.data.fields.Sales_isActiveHost__c.value);
            if (this.host.data.fields.Sales_isActiveHost__c.value == false) {
							
	      // Added and commented code in this if block by Bharath as per requirement from Jira ID TWC3144-31
							
              //  this.closeQuickAction();
              // this.fireToastEvent(this.label.Sales_infomsg, this.label.SalesInactiveHostError, 'info', 'sticky');
						
	      this.handleActivate();				
							
            }
            else {
                checkLicesnseExpirationDate({ hostId: this.recordId })
                    .then((result) => {
                        console.log('Controller result: ' + result);
                        if (result == true) {
                            this.visible = true;
                            console.log('visible result' + this.visible);
                        }
                        else {
                            this.visible = false;
                        /*    this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: this.recordId,
                                    objectApiName: 'Sales_Host__c',
                                    actionName: 'view'
                                }
                            }); */
                            this.handleDeactivate();
                         //   this.reloadPage();
                       }
})
                    .catch(error => {
                        this.closeQuickAction();
                        this.fireToastEvent(this.label.SalesErrorMessage, error.body.message, 'error', 'sticky');//displaying error
                        this.error = error;

                    });

            }
        }
    }

    handleDeactivate() {
        checkHostActivationStatus({ HostId: this.recordId })
            .then((result) => {
                console.log('inactivated successfully ' + result);
               
               
                this.closeQuickAction();
               // window.setTimeout(this.successMsg, 10000);
                 console.log('Inside Handle Deactivate !!');
                this.fireToastEvent(this.label.SalesOrderSuccess, this.label.SalesHostDeactivation, 'success', 'sticky');
               this.reloadPage()
                /*window.setTimeout(
                    this.fireToastEvent('Success!', 'The Host is deactivated successfully', 'success', 'sticky')
                , 5000);*/
               //window.setTimeout(this.successMsg, 10000);
 


                
            })


            .catch(error => {

                this.fireToastEvent(this.label.SalesErrorMessage, error.body.message, 'error', 'sticky');//displaying error 
                this.error = error;

                this.closeQuickAction();
            });
    }
		
    handleActivate(){
         checkHostActivationStatus({ HostId: this.recordId })
            .then((result) => {
                console.log('Activated successfully ' + result); 
		this.fireToastEvent(this.label.SalesOrderSuccess, this.label.SalesHostActivation, 'success', 'sticky');
                this.reloadPage();                
            })
            .catch(error => {
                this.fireToastEvent(this.label.SalesErrorMessage, error.body.message, 'error', 'sticky');//displaying error 
                this.error = error;
                this.closeQuickAction();
            });		
    }
    successMsg(){
        this.fireToastEvent(this.label.SalesOrderSuccess, this.label.SalesHostDeactivation, 'success', 'sticky');
}
    handleCancel() {
        this.closeQuickAction();
    }
    closeQuickAction() {
        const closeModal = new CustomEvent('close');

        this.dispatchEvent(closeModal);

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
    reloadPage() {

        setTimeout(function () {
            location.reload(true);
        }, 700);

    }


}