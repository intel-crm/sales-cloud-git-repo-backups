import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import transferPrimaryAdmin from '@salesforce/apex/Sales_TransferPrimaryAdmin.transferPrimaryAdmin';
import SalesFieldsblank from '@salesforce/label/c.Sales_Fields_blank';
import Sales_TransferPrimary from '@salesforce/label/c.Sales_TransferPrimary';
import SalesMoveForwardHtml from '@salesforce/label/c.Sales_Move_Forward_Html';
import TransferPrimaryHtml from '@salesforce/label/c.Transfer_Primary_Html';
import SalesErrorMessage from '@salesforce/label/c.Sales_Error_Message';
import SalesOrderSuccess from '@salesforce/label/c.Sales_Order_Success';
import Sales_primaryadmin from '@salesforce/label/c.Sales_primaryadmin';
import Sales_yes from '@salesforce/label/c.Sales_yes';
import Sales_no from '@salesforce/label/c.Sales_no';
import Sales_Primaryadminupdate from '@salesforce/label/c.Sales_Primaryadminupdate';
import Sales_Toprimaryadmin from '@salesforce/label/c.Sales_Toprimaryadmin';
import Sales_diffcontct from '@salesforce/label/c.Sales_diffcontct';
import Sales_OrderClose from '@salesforce/label/c.Sales_OrderClose';
import Sales_transferlic from '@salesforce/label/c.Sales_transferlic';







export default class Sales_License_TransferLicenses extends LightningElement {

    @api fromPrimayAdmin = '';
    @api toPrimaryAdmin = '';
    @api showModal;
    label={ SalesFieldsblank,SalesOrderSuccess,SalesMoveForwardHtml,TransferPrimaryHtml,SalesErrorMessage,
        Sales_yes,Sales_no,Sales_Primaryadminupdate,Sales_Toprimaryadmin,Sales_diffcontct,Sales_primaryadmin,Sales_OrderClose,
        Sales_transferlic,Sales_TransferPrimary

    };

    handleTransfer() {

        if (this.fromPrimayAdmin != '' && this.toPrimaryAdmin != '' && this.fromPrimayAdmin != this.toPrimaryAdmin) {
            this.showModal = true;
            console.log('Show Confirmation modal - Yes ' + this.showModal);

        } else {
            this.fireToastEvent(this.label.SalesErrorMessage, this.label.SalesFieldsblank, 'error', 'sticky');
        }

    }

    handleYes() {
        console.log('fromPrimayAdmin: ' + this.fromPrimayAdmin);
        console.log('toPrimaryAdmin: ' + this.toPrimaryAdmin);

        transferPrimaryAdmin({ fromPrimayAdmin: this.fromPrimayAdmin, toPrimaryAdmin: this.toPrimaryAdmin })
            .then(() => {
             this.fireToastEvent(this.label.SalesOrderSuccess ,this.label.Sales_TransferPrimary, 'success', 'sticky');
						//this.fireToastEvent(this.label.Sales_TransferPrimary, this.label.SalesOrderSuccess,'success', 'dismissable');
                this.closeModal();
                this.reloadPage();
            })
            .catch((error) => {
                this.fireToastEvent(this.label.SalesErrorMessage, error.body.message, 'error', 'sticky');
            });
    }

    handleNo() {
        this.closeModal();
    }

    handleFromPrimary(event) {
        this.fromPrimayAdmin = event.target.value;
        console.log('Change fromPrimayAdmin: ' + this.fromPrimayAdmin);
    }

    handleToPrimary(event) {
        this.toPrimaryAdmin = event.target.value;
        console.log('Change toPrimaryAdmin: ' + this.toPrimaryAdmin);
    }

    closeModal() {
        // to close modal set showModal tarck value as false
        this.showModal = false;
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

    closeQuickAction() {
        const closeModal = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeModal);
    }

    reloadPage() {
        location.reload(true);
        /*setTimeout(function() {
                eval("$A.get('e.force:refreshView').fire();");
        }, 2000);*/
    }

}