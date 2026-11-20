import { LightningElement, wire, api, track } from 'lwc';
import FIELD_NAME from '@salesforce/apex/PCC_ApprovalPageMessage.objectTypedetail';
import hasPermissionSet from '@salesforce/apex/PCC_ApprovalPageMessage.hasPermissionSet';
import hasPreapproverPermissionSet from '@salesforce/apex/PCC_ApprovalPageMessage.hasPreapproverPermissionSet';

export default class PCC_ApprovalPageMessage extends LightningElement {
    @api recordId; 
    @track showMessage;
    @track enableMessage;
    @track enableMessagesPre;
    @track fieldValue;
   

    @wire(FIELD_NAME, { recordId: '$recordId'})
    wiredRecord({ error, data }) {
        if (data) {
            this.showMessage = true
        } else if (error) {
        }
    }
    @wire(hasPermissionSet, { permissionSetName: 'PCC_Deal_Reg_Internal_Admin' })
    wiredPermissionSet({ error, data }) {
        if (data) {
            this.enableMessage = data;
        } else if (error) {
            this.error = error;

        }
    }
    @wire(hasPreapproverPermissionSet, { permissionSetName: 'PCC_Deal_Reg_Channel_Ops' })
    wiredPermissionS({ error, data }) {
        if (data) {
            this.enableMessagesPre = data;
        
        } else if (error) {
            this.error = error;

        }
    }    
        }