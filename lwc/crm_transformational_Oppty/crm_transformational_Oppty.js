import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunity from '@salesforce/apex/core_AccountPlanRevenueController.getOpportunities';
import getOpportunitiesdetail from '@salesforce/apex/core_AccountPlanRevenueController.getOpportunityDetails';
import saveOpportunityComments from '@salesforce/apex/core_AccountPlanRevenueController.saveOpportunityComments';
import getOpportunitiesId from '@salesforce/apex/core_AccountPlanRevenueController.getPreOpportunityDetail';
export default class AccountPlanOpportunity extends LightningElement {
    @api recordId; 
    allOpportunities = []; 
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
    preSharedComment = '';
    opportunityies =[];
    showOpportunityies =[];
    isshowOpportunityies = false;
    insideSelection = false;
    iscommentChange = false;
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
//console.log('Toggled! isCollapsed:', this.isCollapsed);
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
            OpportunityLink: `${window.location.origin}/lightning/r/Opportunity/${opp.Id}/view`,
            OwnerLink: `${window.location.origin}/lightning/r/User/${opp.OwnerId}/view`,
            OwnerName:  opp.Owner.Name ,
            TechnicalOwnerLink:  opp.Core_Technical_Owner__c ? `${window.location.origin}/lightning/r/User/${opp.Core_Technical_Owner__c}/view`: '',
            TechnicalOwnerName: opp.Core_Technical_Owner__c ? opp.Core_Technical_Owner__r.Name : ''
            /*AccountLink: `https://intel--crmdevsls3.sandbox.lightning.force.com/lightning/r/Account/${opp.AccountId}/view`,
            AccountName:  opp.Account.Name */
        }));
        this.loadOpportunityDetails();
        this.loadOpportunityID();
        //console.log('this.preselectedListwire',this.preselectedIds);
        this.opportunities = [...this.allOpportunities];
        console.log('this.opportunities',this.opportunities);
        
    } else if (error) {
        console.error('Error fetching:', error);
    }
}

    handleRowSelection(event) {
        //console.log('Inside Row Selection');
        const selectedIds = new Set(event.detail.selectedRows.map(row => row.Id));
        this.selectedOpportunities = this.opportunities
            .filter(opp => selectedIds.has(opp.Id));
        this.opportunityies = this.selectedOpportunities.map(opp => opp.Id);
        this.insideSelection = true;
    }

    handleCommentChange(event) {
        console.log('Inside Comment CHange');
        this.sharedComment = event.target.value;
        this.iscommentChange = true;
    }
    handleToggle() {
        this.isCardVisible = !this.isCardVisible;
    }
    handleCancel() {
        this.isCardVisible = false;
        this.clearFields();
    }
    async handleSave() {
        this.isCardVisible = false;
       if(!this.insideSelection){
            this.opportunityies = [...this.preselectedIds];
            //console.log('this.preselectedList',this.opportunityies);
        }
        if(!this.iscommentChange){
            this.sharedComment =  this.preSharedComment;
            //console.log('this.preSharedComment',this.sharedComment);
        }    
        //console.log('saveId',this.opportunityies);
        //console.log('selectedOpportunities',this.selectedOpportunities);
        //console.log('opportunityies',this.opportunityies);
        await saveOpportunityComments({ recordId: this.recordId , opportunitys: this.opportunityies, comment: this.sharedComment })
            .then(() => {
                this.showToast('Success', 'saved successfully!', 'success');
                this.handleCancel(); 
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', 'Error while saving.', 'error');
            });
            this.opportunities = [...this.allOpportunities];
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
        this.sharedComment = '';
        this.selectedOpportunities = [];
        this.opportunityies=[];
        this.insideSelection = false;
        this.iscommentChange = false;
    }
    connectedCallback() {
        console.log('connectedCallback');
        this.loadOpportunityDetails();
    }
    
    async loadOpportunityDetails() {
        await getOpportunitiesdetail({ recordId: this.recordId })
            .then(result => {
                if (result) {
                    console.log('TestDetails',result);
                    console.log('result.Transformational_Opportunities__c',result.Transformational_Opportunities__c);
                    //console.log('result.Transformational_Opportunities_Comment__c',result.Transformational_Opportunities_Comment__c);
                    //this.transformationalOpportunity = result.Transformational_Opportunities_Links__c || '';
                    this.transformationalOpportunityComment = result.Transformational_Opportunities_Comment_N__c || '';
                    let opptyIdsString = result.Transformational_Opportunities__c || ''; 
                    //let opptyNameString = result.Transformational_Opportunities_Comment__c || '';
                    let opptyIds = opptyIdsString.split(',').filter(Boolean); 
                    /*let opptyName = opptyNameString.split(',').filter(Boolean); 
                    //console.log('opptyIds',opptyIds.length);
                    //console.log('opptyName',opptyName.length);
                    //console.log('result.Transformational_Opportunities_Comment_N__c',result.Transformational_Opportunities_Comment_N__c);
                    let opptyLinksHtml = '';
                    if (opptyIds.length === opptyName.length) {
                        let baseUrl = window.location.origin;
                        for (let i = 0; i < opptyIds.length; i++) {
                            const id = opptyIds[i].trim();
                            const name = opptyName[i].trim();
                            opptyLinksHtml += `<a href="${baseUrl}/lightning/r/Opportunity/${id}/view" target="_blank">${name}</a><br/>`;
                        }
                    }
                    this.transformationalOpportunity = opptyLinksHtml || '';*/
                    this.showOpportunityies = this.allOpportunities.filter(opp =>
                        opptyIds.includes(opp.Id)
                    );
                    if(this.showOpportunityies.length>0){
                        this.isshowOpportunityies = true;
                    }
                    else{
                        this.isshowOpportunityies = false;
                    }
                    console.log('this.showOpportunityies',this.showOpportunityies);
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
                    //console.log('TestDetailsIDID',result);
                    const savedIds = result.Transformational_Opportunities__c;
                    this.preselectedIds = savedIds ? savedIds.split(',').map(id => id.trim()) : [];
                    this.opportunityies = [...this.preselectedIds];
                    this.preSharedComment = result.Transformational_Opportunities_Comment_N__c;
                }
            })
            .catch(error => {
                console.error('Error fetching opportunity details', error);
            });
    }
    
    
}