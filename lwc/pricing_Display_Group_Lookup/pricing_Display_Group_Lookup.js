import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
// Append the __c to both the object name and field name to tell Salesforce it is custom
import rpmGroupId from '@salesforce/schema/SBQQ__Quote__c.Pricing_Pricing_Manager_Group_Label_Txt__c';
import rpmGroupName from '@salesforce/schema/SBQQ__Quote__c.Pricing_Pricing_Manager_Group_Name_Txt__c';

export default class Pricing_Display_Group_Lookup extends NavigationMixin(LightningElement) {

    @api recordId;
    rpmGroupId;
    rpmGroupName;
    groupNameToDisplay;

    @wire(CurrentPageReference)
    getStateParameters(pageRef) {
        if (pageRef && pageRef.attributes) {
            // In a standard record page layout, the ID lives under 'recordId' attributes
            this.recordId = pageRef.attributes.recordId;
            console.log('OUTPUT : recordId',this.recordId);
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields: [rpmGroupId, rpmGroupName] })
    wiredRecord({ data, error }) {
        if (data) {
            const rpmGroupDetails = data;
            if (rpmGroupDetails != undefined) {
                this.rpmGroupId = rpmGroupDetails.fields.Pricing_RPM_Group_Id_Txt__c.value;
                this.rpmGroupName = rpmGroupDetails.fields.Pricing_RPM_Group_Name_Txt__c.value;
                //Alternate for above - getFieldValue(data, pass field);
                this.generateGroupLabel(this.rpmGroupName);
            }


        } else if (error) {
            console.error('Error loading record data: ', error);
        }
    }

    // Optional mapping logic to convert API names into human-readable text
    generateGroupLabel(groupName) {
        if (groupName === 'Pricing_RR_ASMO_DCG_HPC_RPM_Group') {
            this.groupNameToDisplay = 'RPM Approval Group for ASMO DCG(HPC)';
        }
    }
    navigateToGroup() {
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.rpmGroupId,
                objectApiName: 'Group',
                actionName: 'view'
            }
        });*/
        this[NavigationMixin.Navigate]({//Takes you to exact group
        type: 'standard__webPage',
        attributes: {
            // This direct URL maps to the deep-linked Setup page for that specific group ID
            url: `/lightning/setup/PublicGroups/page?address=%2Fsetup%2Fown%2Fgroupdetail.jsp%3Fid%3D${this.rpmGroupId}`
        }
    });
    }
}