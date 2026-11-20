import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord,getFieldValue  } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id'; 
import Name from '@salesforce/schema/User.Name';
import RoleName from '@salesforce/schema/User.UserRole.Name';
import ProfileName from '@salesforce/schema/User.Profile.Name'; 
import ExportCompliance_FIELD from '@salesforce/schema/Account.Core_Export_Compliance_Block__c';
import profilesLabel from '@salesforce/label/c.UCD_ACM_GTSHierarchyBlockMsg_Profile';

export default class UCD_ACM_gtsHierarchyBlockMessage extends LightningElement {

    @api recordId;
    userId = Id;
    userRoleName;
    userProfileName;
    @track exportComplianceBlock;
    profilesForMsg;

    @wire(getRecord, { recordId: Id, fields: [Name, RoleName, ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Profile.value != null) {
                console.log('Gts Profile ',data.fields.Profile.value.fields.Name.value);
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
            }
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ExportCompliance_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('GTS Record : ',JSON.stringify(data));
            this.exportComplianceBlock = getFieldValue(data, ExportCompliance_FIELD);
            console.log('Export Compliance field : ',JSON.stringify(getFieldValue(data, ExportCompliance_FIELD)));
        } else if (error) {
            console.error('Error fetching record data', error);
        }
    }
    connectedCallback(){
        this.profilesForMsg = profilesLabel.split(',');
        console.log('msgProfile : ',this.profilesForMsg);
        console.log('GTS User Id : ',this.userId,' userProfie : ',this.userProfileName,' Record id : ',this.recordId);
        console.log('Label : ',profilesLabel);
        this.checkUserProfileAndAccountIsECBBlocked();
    }
    showBlockedMessage() {
        const evt = new ShowToastEvent({
          title: 'Account is in GTS block. ',
          variant: 'Error',
          mode : 'pester'
        });
        this.dispatchEvent(evt);
    }
    checkUserProfileAndAccountIsECBBlocked(){
        setTimeout(() => {
            if(this.profilesForMsg.includes(this.userProfileName) && this.exportComplianceBlock===true){
                 this.showBlockedMessage();
            }
        },3000);
    }        
    
}