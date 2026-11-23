// permissionMessage.js
import { LightningElement, api } from 'lwc';
import hasPermission1 from '@salesforce/customPermission/PCC_Deal_Reg_Internal_Admin_Custom';

export default class PermissionMessage extends LightningElement {
    @api permissionSetName;
    @api message;

    get hasPermission() {
        return hasPermission1;
    }
}