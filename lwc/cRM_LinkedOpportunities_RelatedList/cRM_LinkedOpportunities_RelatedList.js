import { LightningElement, api, wire, track } from 'lwc'; 
import fetchRecords from '@salesforce/apex/CRM_Linked_Opportunity_RelatedList.fetchRecords'; 
import { NavigationMixin } from 'lightning/navigation';
 
export default class RelatedList extends NavigationMixin( LightningElement ) { 
 
    
    @api recordId; 
    @api objectName; 
    @track records = [];

    connectedCallback() { 
        fetchRecords({ recordId : this.recordId })
            .then(result => {
                if (result && result.length > 0 ) {
                    //this.totalRecordCount = result.length;
                    this.records = result.map((item, index) => ({
                        ...item,
                        oppfromURL: '/lightning/r/' + item.CRM_Primary_Opportunity__c + '/view',
                        opptoURL: '/lightning/r/' + item.CRM_Linked_Opportunity__c + '/view',
                        oppLinkReason:item.CRM_Link_Reason__c,
                        opplinkdesc:item.CRM_Link_Description__c
                    }));
                    this.error = undefined;
                   
                }
                
            })
            .catch(error => {
                console.log('AA Error', error);
                this.error = error;
                this.records = undefined;
            });
    

    }


    createNew() {

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                actionName: 'new',
                objectApiName: this.objectName,
            }
        });

    }

    navigateToRelatedList() {
       
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });

    }
 
}