import { LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import IntelPremierSupportLogo from '@salesforce/resourceUrl/IntelPremierSupportLogo';
import PortalFooterLogo from '@salesforce/resourceUrl/PortalFooterLogo';
export default class Portal_Header_LWC extends LightningElement {
    IntelLogo = IntelPremierSupportLogo;
    FooterLogo=PortalFooterLogo;
    @track name;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.name = data.fields.Name.value;
        }
    }
}