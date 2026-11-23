import { LightningElement, api } from 'lwc';

export default class Core_IPS_File_AttachToCase extends LightningElement {

    @api url = 'https://ips-scft-tst.intel.com/ips/upload?caseId=5003F000000rWL7QAM&extended={"visibility":"Public to Customers"}';
    @api recordId;
}