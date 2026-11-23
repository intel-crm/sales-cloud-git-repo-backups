import { LightningElement,wire,track } from 'lwc';
//import getSubmittedRecords from '@salesforce/apex/Core_MDF_Approval_Request_POC55.getSubmittedRecords';
import getApprovalRecords from '@salesforce/apex/Sample_Example_ApprovalRequestController.getSubmittedRecords';
import formFactorPropertyName from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';

export default class Approval_Requests extends NavigationMixin(LightningElement) {
    @track searchInput;
    @track PhoneOrDesktop;
    @track error;
    @track recordsToRender = [];
    @track searchRecordsToRender = [];
    @track isMainTable=true;
    @track formFactor;
    formFactor = formFactorPropertyName;
    @track phoneOrDesktop;
    @track noSearchResultsFound=false;

    @wire(getApprovalRecords)
    wiredAccounts({error, data}) {
        if (data) {
            this.recordsToRender = JSON.parse(data);
            console.log(JSON.parse(data));
        } else if (error) {
            this.error = error;
        }
        console.log('Total Records Length=> '+ this.recordsToRender.length);
    }
    get getTotalItemsCount() {
        let count = this.recordsToRender.length;
        if(count <= 0){
            return '';
        }
        return count;
    }
    handleClick(event){
        var selectedRecId = '';
        let isNavigateToStandardPage = false;
        selectedRecId = event.target.dataset.recordId;
        //let processInstWIRecs = [];
        //processInstWIRecs = this.recordsToRender;
        let selRecId = selectedRecId.substring(1);
        console.log('All Recs => '+JSON.stringify(this.recordsToRender));
        for(let i = 0; i <this.recordsToRender.length; i++){

            if (this.recordsToRender[i].recordId == selRecId && this.recordsToRender[i].naviagteToStandardPage) {
                isNavigateToStandardPage = true;
                break;
            }
        }
        console.log('Navigate to standard Page Check => '+isNavigateToStandardPage);
       
        if(isNavigateToStandardPage) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: selRecId,
                    objectApiName: 'ProcessInstanceWorkItem',
                    actionName: 'view'
                }
            });            
        }else{
            this[NavigationMixin.Navigate]({
                type: "standard__component",
                attributes: {
                    componentName: "c__Core_MDF_navAuraCmp"
                },
                state: {
                    c__recId: selectedRecId
                }
            });
            console.log('Outside Navigation');
        }        
    }
    handleSearchInput(event){
        let searchInputValue=event.target.value.toLowerCase();
        var allRecords=[];
        allRecords=this.recordsToRender;
        this.noSearchResultsFound = false;
        var filteredRecords=[];
        let approvalRecord;
        console.log('search term'+searchInputValue);
        if(searchInputValue === '' || searchInputValue === undefined){
            this.isMainTable=true;
        }else{
            for(var index in allRecords){
             approvalRecord = JSON.stringify(allRecords[index]).toLowerCase();
                if(approvalRecord.includes(searchInputValue)){
                    console.log(approvalRecord);
                    filteredRecords.push(allRecords[index]);
                }
            }
            this.isMainTable=false;
            this.searchRecordsToRender= filteredRecords;
             if(filteredRecords.length<=0){
                this.noSearchResultsFound = true;
            }
        }
}
}