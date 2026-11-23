import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import successMsg from '@salesforce/label/c.Sales_RemoveLicUserSuccessMsg';
import failureMsg from '@salesforce/label/c.Sales_RemoveLicUserFailureMsg';
import catchErroMsg from '@salesforce/label/c.Sales_RemoveLicUserUnhandledErr';
import removeLicUserFromUser from '@salesforce/apex/Sales_RemoveLicUserOnLicenseRecordCtrl.removeLicUserFromUser';
import Sales_Succes from '@salesforce/label/c.Sales_Succes';
import Sales_failure from '@salesforce/label/c.Sales_failure';
import Sales_AccessCheckMsg from '@salesforce/label/c.Sales_AccessCheckMsg';

import userId from '@salesforce/user/Id';
import validateUserAccess from '@salesforce/apex/Sales_ValidateUserEditAccess.validateUserAccess';


export default class SalesRemoveLicUserOnLicenseRec extends LightningElement {
    @api recordId;
    @track userId=userId;
    @track check=false;
    label = {
        successMsg,
        failureMsg,
        catchErroMsg,
        Sales_Succes,
        Sales_failure,
        Sales_AccessCheckMsg
    };
    connectedCallback() {
        this.validateUserAccessLogic();
        console.log('check: '+this.check);
        
        
    }
    reload() {
        setTimeout(function () {
            location.reload(true);
        }, 2000);
    }

    showNotification(title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }

    closeQuickAction() {
        const closeModal = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeModal);
    }
    validateUserAccessLogic(){
    console.log('824');
    validateUserAccess({userID: this.userId, recordId : this.recordId})
                .then((result) =>{
                    console.log('result ='+result);
					if(result==false){
						    console.log('user doesnt have access to the record');
							//this.closeQuickAction();
                            this.check=true;

                            const evt = new ShowToastEvent({
                                variant: 'error',
                                title: 'Failure',
                                mode: 'sticky',
                                message: this.label.Sales_AccessCheckMsg,
                              });
                              //
							//this.fireToastEvent('Failure!','You cannot modify this record !! ','error','Sticky');
                           this.dispatchEvent(evt);
                            this.closeQuickAction();
					}
                    else{
                        removeLicUserFromUser({ recordId: this.recordId }) //apex method invoked
            .then((result) => {
                if (result) {
                    this.closeQuickAction();
                    this.showNotification(this.label.Sales_Succes,successMsg, 'success');
                    this.reload();
                }
                else {
                    this.closeQuickAction();
                    this.showNotification(this.label.Sales_failure,failureMsg, 'error');
                }

            })
            .catch((error) => {
                this.closeQuickAction();
                this.showNotification(this.label.Sales_failure,catchErroMsg, 'error');
            })
        
                    }
				})
}
}