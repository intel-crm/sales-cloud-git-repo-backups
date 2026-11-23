import { LightningElement,api,wire,track} from 'lwc';
import fetchBudgetCampaignPFRDetails from '@salesforce/apex/Core_MDF_BudgetAddUp.fetchBudgetCampaignPFRDetails';

export default class Core_MDF_BudgetAddUp extends LightningElement {
 
    // get the current parent recordId
    @api recordId;
    
    @track budgetAmount = 0;
    @track usedBudgetAmount = 0;
    @track remainingBudgetAmount = 0;
    @track totalPFRAmount = 0;
    @track pfrList = [];
    @track hasValidData = false;
    @track columnCamp = [

        {
            label: 'Activity Name',
            fieldName: 'Title',
            type: 'text',
            wrapText: true,
            sortable: true
        }

    ];
    @track columns = [
        /* {
            label: 'Activity Name',
            fieldName: 'linkName',
            type: 'url', 
            typeAttributes: {
                label: { fieldName: 'Title' }, 
                target: '_blank'
            },
            wrapText: true,
            sortable: true
        }, 
        {
            label: 'Activity Name',
            fieldName: 'Title',
            type: 'text',
            wrapText: true,
            sortable: true
        },*/
        {
            label: 'Activity Name',
            fieldName: 'Core_MDF_PFRDetailLink__c',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Title' }, 
            target: '_blank'},
            sortable: true
        },
        {
            label: ' Activity Status',
            fieldName: 'Core_MDF_Fund_Request_Status__c',
            type: 'text',
            sortable: true
        },
        {
            label: 'Amount',
            fieldName: 'RequestedAmount',
            type: 'currency',
            typeAttributes: { currencyCode: 'USD' },
            sortable: true,
            cellAttributes: { alignment: 'left' }
        }
 
    ];
   
    
    @wire(fetchBudgetCampaignPFRDetails, { recordId: '$recordId' })
    wiredPFR(result){
        if(result.data){

            this.hasValidData = true;
            this.budgetAmount = result.data.budgetAmount;
            this.usedBudgetAmount = result.data.usedBudgetAmount;
            this.remainingBudgetAmount = result.data.remainingBudgetAmount;
            
            /* for(var outerIndexIterator in result.data.campaignIdPFRWrapperList){
                for(var innerIndexIterator in result.data.campaignIdPFRWrapperList[outerIndexIterator].pfrList){
                    //result.data.campaignIdPFRWrapperList[outerIndexIterator].pfrList[innerIndexIterator].linkName = '/'+result.data.campaignIdPFRWrapperList[outerIndexIterator].pfrList[innerIndexIterator].Id;
                    let linkName;
                    result.data.campaignIdPFRWrapperList[outerIndexIterator].pfrList.map(row => {
                        linkName = `/${row.Id}`;
                        //alert('linkName: ' + linkName);
                        return {...row , linkName} 
                    });
                }
            } */
            this.pfrList = result.data.campaignIdPFRWrapperList;
        }
    }
}