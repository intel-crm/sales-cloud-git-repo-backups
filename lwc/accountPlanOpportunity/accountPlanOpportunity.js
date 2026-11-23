import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunity from '@salesforce/apex/core_AccountPlanRevenueController.getOpportunities';
import getOpportunitiesdetail from '@salesforce/apex/core_AccountPlanRevenueController.getOpportunityDetails';
import saveOpportunityComments from '@salesforce/apex/core_AccountPlanRevenueController.saveOpportunityComments';
import getOpportunitiesId from '@salesforce/apex/core_AccountPlanRevenueController.getOpportunityId';
export default class AccountPlanOpportunity extends LightningElement {
    @api recordId; // Account Plan Record Id
    allOpportunities = []; // unfiltered full list
    opportunities = []; 
    test=true;
    selectedOpportunities = [];
    visibleOpportunities = [];
    currentPage = 1;
    isLoading = false;
    isselected= false;
    sharedComment='';
    isCardVisible = false;
    isCollapsed = false;
    transformationalOpportunity = '';
    transformationalOpportunityComment = '';
    preselectedIds = [];
    opportunityies =[];

    columns = [
        {
            label: 'Opportunity Name',
            fieldName: 'OpportunityLink',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'Name' },
                target: '_blank'
            },
            cellAttributes: { style: 'width: 200px;'}
        },
        {
            label: 'Opportunity Owner',
            fieldName: 'OwnerLink',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'OwnerName' },
                target: '_blank'
            },
            cellAttributes: { style: 'width: 200px;' }
        },
        {
            label: 'Technical Owner',
            fieldName: 'TechnicalOwnerLink',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'TechnicalOwnerName' },
                target: '_blank'
            },
            cellAttributes: { style: 'width: 200px;' }
        },
        { label: 'Amount', fieldName: 'Amount', type: 'currency',cellAttributes: { style: 'min-width: 200px;' } },
        { label: 'Close Date', fieldName: 'CloseDate', type: 'date',cellAttributes: { style: 'min-width: 200px;' } },
        
        { label: 'Stage', fieldName: 'StageName' ,cellAttributes: { style: 'min-width: 200px;' }}
        
        
    ];
    


get iconName() {
return this.isCollapsed ? 'utility:chevronright' : 'utility:chevrondown';
}

toggleSection() {
this.isCollapsed = !this.isCollapsed;
console.log('Toggled! isCollapsed:', this.isCollapsed);
}

handleSearchChange(event) {
    const searchKey = event.target.value.toLowerCase();

    this.opportunities = this.allOpportunities.filter(opp => {
        const name = opp.Name?.toLowerCase() || '';
        const stage = opp.StageName?.toLowerCase() || '';
        const amount = opp.Amount?.toString() || '';

        return (
            name.includes(searchKey) ||
            stage.includes(searchKey) ||
            amount.includes(searchKey)
        );
    });
}
@wire(getOpportunity, { accountPlanId: '$recordId' })
wiredOpportunities({ error, data }) {
    if (data) {

        this.allOpportunities = data.map(opp => ({
            ...opp,
            comment: '',
            OpportunityLink: `https://intel--crmdevint3.sandbox.lightning.force.com/lightning/r/Opportunity/${opp.Id}/view`,
            OwnerLink: `https://intel--crmdevint3.sandbox.lightning.force.com/lightning/r/User/${opp.OwnerId}/view`,
            OwnerName:  opp.Owner.Name ,
            TechnicalOwnerLink:  opp.Core_Technical_Owner__c ? `https://intel--crmdevint3.sandbox.lightning.force.com/lightning/r/User/${opp.Core_Technical_Owner__c}/view`: '',
            TechnicalOwnerName: opp.Core_Technical_Owner__c ? opp.Core_Technical_Owner__r.Name : ''
        }));
        this.loadOpportunityID();
        this.opportunities = [...this.allOpportunities];
        //this.setVisibleOpportunities();
        
    } else if (error) {
        console.error('Error fetching:', error);
    }
}

    handleRowSelection(event) {
        console.log('Test2');
        const selectedIds = new Set(event.detail.selectedRows.map(row => row.Id));
        this.selectedOpportunities = this.opportunities
            .filter(opp => selectedIds.has(opp.Id));
        this.opportunityies = this.selectedOpportunities.map(opp => opp.Id);
    }

    handleCommentChange(event) {
        /*const opportunityId = event.target.dataset.id;
        const value = event.detail.value;
    
        this.selectedOpportunities = this.selectedOpportunities.map(opp => {
            return opp.Id === opportunityId ? { ...opp, comment: value } : opp;
        });*/
        this.sharedComment = event.target.value;
    }

    /*showCard() {
        this.isCardVisible = true;
    }*/
    handleToggle() {
        this.isCardVisible = !this.isCardVisible;
    }
    handleCancel() {
        this.isCardVisible = false;
        this.clearFields();
    }
    async handleSave() {
        this.isCardVisible = false;
        /*if (!this.selectedOpportunities.length /*|| !this.sharedComment && !this.preselectedIds.length) {
            this.showToast('Error', 'Please select at least one opportunity and add a comment.', 'error');
            return;
        }*/
        if(!this.opportunityies.length){
            this.opportunityies = [...this.preselectedIds];
            console.log('this.preselectedList',this.opportunityies);
        }
            
            
        await saveOpportunityComments({ recordId: this.recordId , opportunitys: this.opportunityies, comment: this.sharedComment })
            .then(() => {
                this.showToast('Success', 'Comment saved successfully!', 'success');
                this.handleCancel(); 
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', 'Error while saving comment.', 'error');
            });
            //window.location.reload();
            console.log('call loadOpportunityDetails');
            await this.loadOpportunityDetails();
            await this.loadOpportunityID();
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    
    
    clearFields() {
        this.searchKey = '';
        //this.sharedComment = '';
        this.selectedOpportunities = [];
        this.opportunityies=[];
    }
    connectedCallback() {
        this.loadOpportunityDetails();
    }
    
    async loadOpportunityDetails() {
        await getOpportunitiesdetail({ recordId: this.recordId })
            .then(result => {
                if (result) {
                    this.transformationalOpportunity = result.Transformational_Opportunities_Links__c || '';
                    this.transformationalOpportunityComment = result.Transformational_Opportunities_Comment_N__c || '';
                }
            })
            .catch(error => {
                console.error('Error fetching opportunity details', error);
            });
    }

    async loadOpportunityID() {
        await getOpportunitiesId({ recordId: this.recordId })
            .then(result => {
                if (result) {
                    console.log('TestDetailsIDID',result);
                    const savedIds = result.Transformational_Opportunities__c;
                    this.preselectedIds = savedIds ? savedIds.split(',').map(id => id.trim()) : [];
                    this.sharedComment = result.Transformational_Opportunities_Comment_N__c;
                }
            })
            .catch(error => {
                console.error('Error fetching opportunity details', error);
            });
    }
    
    
}