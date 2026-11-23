import { LightningElement, api, wire, track } from 'lwc';
import getOpportunity from '@salesforce/apex/core_AccountPlanRevenueController.getOpportunities';
const PAGE_SIZE = 10;

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
    columns = [
        { label: 'Opportunity Name', fieldName: 'Name' },
        { label: 'Stage', fieldName: 'StageName' },
        { label: 'Amount', fieldName: 'Amount', type: 'currency' },
        { label: 'Close Date', fieldName: 'CloseDate', type: 'date' }
    ];
    
@track isCollapsed = true;

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
        console.log('Test1',this.recordId);
        console.log('Test1',data);
        this.allOpportunities = data.map(opp => ({ ...opp, comment: '' }));
        console.log('Test1',this.allOpportunities);
        this.opportunities = [...this.allOpportunities];
        console.log('Test1',this.opportunities);
        this.setVisibleOpportunities();
        
    } else if (error) {
        console.error('Error fetching:', error);
    }
}

setVisibleOpportunities() {
    const end = this.currentPage * PAGE_SIZE;
    this.visibleOpportunities = this.opportunities.slice(0, end);
    console.log('Test1', this.visibleOpportunities);
}

handleScroll(event) {
    console.log('Test1handlescrol');
    const container = event.target;
    const scrollPosition = container.scrollTop + container.clientHeight;
    const scrollHeight = container.scrollHeight;

    if (scrollPosition >= scrollHeight - 10 && !this.isLoading && this.visibleOpportunities.length < this.opportunities.length) {
        this.loadMore();
    }
}

loadMore() {
    this.isLoading = true;

    setTimeout(() => {
        this.currentPage += 1;
        this.setVisibleOpportunities();
        this.isLoading = false;
    }, 500); // slight delay to simulate loading
}

handleSearchChange(event) {
    const searchKey = event.target.value.toLowerCase();

    this.opportunities = this.allOpportunities.filter(opp => {
        const name = opp.Name?.toLowerCase() || '';
        return name.includes(searchKey);
    });

    this.currentPage = 1;
    this.setVisibleOpportunities();
}
    handleRowSelection(event) {
        console.log('Test2');
        /*const selectedIds = new Set(event.detail.selectedRows.map(row => row.Id));
        this.selectedOpportunities = this.opportunities
            .filter(opp => selectedIds.has(opp.Id));*/
        const selectedIds = event.detail.selectedRows || [];
        if(selectedIds.length>0){
            this.isselected = true;
        }
        else{
            this.isselected = false;
        }
       
    }

    handleCommentChange(event) {
        console.log('Test3');
        /*const opportunityId = event.target.dataset.id;
        const value = event.detail.value;
    
        this.selectedOpportunities = this.selectedOpportunities.map(opp => {
            return opp.Id === opportunityId ? { ...opp, comment: value } : opp;
        });*/
        this.sharedComment = event.target.value;
    }
}