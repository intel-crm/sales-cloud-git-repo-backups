import { LightningElement, api, wire, track } from 'lwc';
import getContactEntitlemnts from '@salesforce/apex/Core_ContactHandler.getContactEntitlemnts'

import TYPE from '@salesforce/schema/Core_Contact_Entitlement__c.Core_Type__c';
import STATUS from '@salesforce/schema/Core_Contact_Entitlement__c.Core_Status__c';
import ENTITLEMENT_NAME from '@salesforce/schema/Core_Contact_Entitlement__c.Core_Display_Nm__c';
import SELECTED from '@salesforce/schema/Core_Contact_Entitlement__c.Core_Selected__c';
import ENTITLEMENT_DESCRIPTION from '@salesforce/schema/Core_Contact_Entitlement__c.Core_Entitlement_Help_Txt__c';
import OPS_STATUS from '@salesforce/schema/Core_Contact_Entitlement__c.Core_Ops_Status__c';
import UPDATE_REASON from '@salesforce/schema/Core_Contact_Entitlement__c.Core_Update_Reason__c';


const COLS = [
    {
        label: 'Name',
        fieldName: 'NameURL',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name' }}
        
    },
    {
        label: 'Entitlement Name',
        fieldName: 'Core_Display_Nm__c',
        
        
        
    },
    {
        label: 'Type',
        fieldName: TYPE.fieldApiName,
        
    },
    {
        label: 'Entitlement Description',
        fieldName: ENTITLEMENT_DESCRIPTION.fieldApiName,
        
    },
    {
        label: 'Status',
        fieldName: STATUS.fieldApiName,
        
    },
    {
        label: 'Ops Status',
        fieldName: OPS_STATUS.fieldApiName,
        
    },
    {
        label: 'Selected',
        fieldName: SELECTED.fieldApiName,
        
    },
    {
        label: 'Update Reason',
        fieldName: UPDATE_REASON.fieldApiName,
        
    }
];

export default class Core_showContactEnt extends LightningElement {

    @api recordId;
    @track viewAllFlag = false;
    consData = [];
    columns = COLS;
    @track buttonLabel = 'View All';

    viewAllHandler(){

        if(this.buttonLabel === 'View Less'){
            this.viewAllFlag = false;
            this.buttonLabel = 'View All';
        }
        else{
            this.viewAllFlag = true;
            this.buttonLabel = 'View Less';
        }

        
        console.log('viewAllFlag-->',this.viewAllFlag);
        //this.buttonLabel = 'View Less';
    }

    // viewLessHandler(){
    //     this.viewAllFlag = false;
    //     console.log('viewAllFlag-->',this.viewAllFlag);
    // }


   
        @wire(getContactEntitlemnts, { contId: '$recordId', vAllFlag: '$viewAllFlag'})
        contactsEnt({ error, data }) {

            if (data) {
                let tempConList = []; 
                
                data.forEach((record) => {
                    let tempConRec = Object.assign({}, record);
                    //tempConRec.EntNameURL = "/" + tempConRec.Id;  
                    tempConRec.NameURL = "/" + tempConRec.Id;
                    tempConList.push(tempConRec);
                    
                });
                
                this.consData = tempConList;
                this.error = undefined;
    
                console.table(this.consData);
    
            } else if (error) {
                this.error = result.error;
            }
        }
    

}