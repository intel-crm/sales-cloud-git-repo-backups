import {
    LightningElement,
    wire,
    track
} from 'lwc';
//import getSubmittedRecords from '@salesforce/apex/Core_MDF_Approval_Request_POC55.getSubmittedRecords'; 
import getApprovalRecords from '@salesforce/apex/Core_MDF_ApprovalReqsController.getSubmittedRecords';
//import searchApprovals from '@salesforce/apex/Core_MDF_ApprovalReqsController.searchApprovals';
import formFactorPropertyName from '@salesforce/client/formFactor';
import {
    NavigationMixin,
    CurrentPageReference
} from 'lightning/navigation';
import isBulkApprovalRequestsActive from '@salesforce/apex/Core_MDF_ApprovalReqsController.isBulkApprovalRequestsNeeded';
import submitBulkApprovalRequests from '@salesforce/apex/Core_MDF_Bulk_Approvals_Requests.submitBulkApprovalRequests';

export default class Core_MDF_Approval_Requests extends NavigationMixin(LightningElement) {
    @track PhoneOrDesktop;
    @track error;
    @track recordsToRender = [];
    @track formFactor;
    formFactor = formFactorPropertyName;
    @track phoneOrDesktop;
    @track searchRecordsToRender = [];
    @track isSearchContext = false;
    @track noSearchResultsFound = false;
    @track selectedRecords = new Set();
    @track approvalStatus = new Map();
    @track finalRecords = new Map();
    searchKey;
    disabled = true;
    value = '';
    selectAllDisabled = false;
    selectAllCheckbox = false;
    @track approve;
    @track noApprovalRequestsFound = false;
    @track noApprovalRequestsFoundMessage = false;

    get options() {
        return [{
                label: 'Approve',
                value: 'Approve'
            },
            {
                label: 'Reject',
                value: 'Reject'
            },
        ];
    }
    connectedCallback() {
        if (this.formFactor == 'Large') {
            this.phoneOrDesktop = false;
        } else {
            this.phoneOrDesktop = true;
        }
        // Fetching Approval Records
        console.log('Connected Callback : Started');
        this.fetchApprovalRecords();
        //Show Total Items
        this.showTotalItemsCount();
        // Check if bulk approval requests needed
        this.isBulkApprovalRequestsRequired();
        console.log('Connected Callback : Completed');
    }
    get getTotalItemsCount() {
        let count = this.recordsToRender.length;
        if (count <= 0) {
            return 0;
        }
        return count;
    }
    @wire(CurrentPageReference)
    wiredPageRef() {
        console.log('Current PageReference Wire Service');

        console.log('Form Factor' + this.phoneOrDesktop);
        if (this.recordsToRender.length > 0) {
            console.log('Current PageReference Fetching Approval Records');
            this.fetchApprovalRecords();
            this.isSearchContext = false;

            let searchText = this.template.querySelector("[data-id='searchText']")
            console.log('@@@' + searchText);
            if (searchText) {
                console.log('Entered here');
                searchText.value = '';

            }

        }
    }
    fetchApprovalRecords() {
        getApprovalRecords()
            .then(data => {
                this.recordsToRender = JSON.parse(data);
                console.log(JSON.parse(data));
            })
            .catch(error => {
                this.error = error;
            });
        console.log('Total Records Length=> ' + this.recordsToRender.length);
    }
    handleClick(event) {
        var selectedRecId = '';
        let isNavigateToStandardPage = false;
        selectedRecId = event.target.dataset.recordId;
        //let processInstWIRecs = [];
        //processInstWIRecs = this.recordsToRender;
        let selRecId = selectedRecId.substring(1);
        console.log('All Recs => ' + JSON.stringify(this.recordsToRender));
        for (let i = 0; i < this.recordsToRender.length; i++) {

            if (this.recordsToRender[i].recordId == selRecId && this.recordsToRender[i].naviagteToStandardPage) {
                isNavigateToStandardPage = true;
                break;
            }
        }
        console.log('Navigate to standard Page Check => ' + isNavigateToStandardPage);

        if (isNavigateToStandardPage) {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: selRecId,
                    objectApiName: 'ProcessInstanceWorkItem',
                    actionName: 'view'
                }
            }).then(url => {
                window.open(url, "_blank");
            });
        } else {
            this[NavigationMixin.GenerateUrl]({
                type: "standard__component",
                attributes: {
                    componentName: "c__Core_MDF_navAuraCmp"
                },
                state: {
                    c__recId: selectedRecId
                }
            }).then(url => {
                window.open(url, "_blank");
            });
            console.log('Outside Navigation');
        }
    }
    handleClickOnMobile(event) {
        var selectedRecId = '';
        let isNavigateToStandardPage = false;
        selectedRecId = event.target.dataset.recordId;
        //let processInstWIRecs = [];
        //processInstWIRecs = this.recordsToRender;
        let selRecId = selectedRecId.substring(1);
        console.log('All Recs => ' + JSON.stringify(this.recordsToRender));
        for (let i = 0; i < this.recordsToRender.length; i++) {

            if (this.recordsToRender[i].recordId == selRecId && this.recordsToRender[i].naviagteToStandardPage) {
                isNavigateToStandardPage = true;
                break;
            }
        }
        console.log('Navigate to standard Page Check => ' + isNavigateToStandardPage);

        if (isNavigateToStandardPage) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: selRecId,
                    objectApiName: 'ProcessInstanceWorkItem',
                    actionName: 'view'
                }
            });
        } else {
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
    handleSearch(event) {
        let searchInputValue = event.target.value.toLowerCase();
        var allRecords = [];
        allRecords = this.recordsToRender;
        this.noSearchResultsFound = false;
        var filteredRecords = [];
        let approvalRecord;
        this.noApprovalRequestsFoundMessage = false;
        this.selectAllCheckbox = false;

        if (searchInputValue === '' || searchInputValue === undefined) {
            this.isSearchContext = false;
            this.noApprovalRequestsFoundMessage = true;
        } else {
            for (var index in allRecords) {
                approvalRecord = JSON.stringify(allRecords[index]).toLowerCase();
                if (approvalRecord.includes(searchInputValue)) {
                    filteredRecords.push(allRecords[index]);
                }
            }
            this.isSearchContext = true;
            this.searchRecordsToRender = filteredRecords;
            if (filteredRecords.length <= 0) {
                this.noSearchResultsFound = true;
            }
        }
    }
    handleSelectAll(event) {
        let request = this.template.querySelectorAll('[type=checkbox]');
        if (event.target.checked) {
            request.forEach(element => {
                element.checked = true;
                this.disabled = false;
                this.selectAllCheckbox = true;
                if (element.name != "Approve All") {
                    this.selectedRecords.add(element.name);
                }
            });
        } else if (!event.target.checked) {
            request.forEach(element => {
                this.disabled = true;
                this.selectAllCheckbox = false;
                element.checked = false;
                if (this.selectedRecords.has(element.name)) {
                    this.selectedRecords.delete(element.name);
                }
            });
        }
    }
    handleCheckboxInput(event) {
        this.checked = event.target.checked;
        this.recName = event.target.name;
        let recId = '[data-id="' + this.recName + '"]';
        if (this.checked) {
            //this.disabled = false;
            this.selectedRecords.add(this.recName);
            let inputEnabled = this.template.querySelectorAll(recId);
            inputEnabled.forEach(element => {
                element.disabled = false;
            });
        } else if (!this.checked) {
            //this.disabled = true;  
            if (this.selectedRecords.has(this.recName)) {
                this.selectedRecords.delete(this.recName);
                this.selectAllCheckbox = false;
                let inputEnabled = this.template.querySelectorAll(recId);
                inputEnabled.forEach(element => {
                    element.disabled = true;
                });
            }
        }
    }
    handleRadioOption(event) {
        this.approve = event.target.value;
        this.recId = event.target.name;
        /*let radioId = '[title="' + this.recId + '"]';
        let radioOption = this.template.querySelectorAll(radioId);
        radioOption.forEach(element => {
            element.value = this.approve;
        });*/
        if (this.selectedRecords.has(this.recId)) {
            if (this.approvalStatus.has(this.recId)) {
                this.recordsStatus = this.approvalStatus.get(this.recId);
                this.recordsStatus.status = this.approve;
                this.approvalStatus.set(this.recId, this.recordsStatus);
            } else {
                this.recordsStatus = {
                    id: this.recId,
                    status: this.approve,
                    comments: ''
                };
                this.approvalStatus.set(this.recId, this.recordsStatus);
            }
        }
    }
    handleComments(event) {
        this.comments = event.target.value;
        this.recdId = event.target.name;
        if (this.selectedRecords.has(this.recdId)) {
            if (this.approvalStatus.has(this.recdId)) {
                this.recordComments = this.approvalStatus.get(this.recdId);
                this.recordComments.comments = this.comments;
                this.approvalStatus.set(this.recdId, this.recordComments);
            } else {
                this.recordComments = {
                    id: this.recdId,
                    status: '',
                    comments: this.comments
                };
                this.approvalStatus.set(this.recdId, this.recordComments);
            }
        }
    }
    handleSubmitClick() {
        this.selectedRecords.forEach(element => {
            if (this.approvalStatus.has(element)) {
                this.finalRecords.set(element, this.approvalStatus.get(element));
            }
        });
        submitBulkApprovalRequests({ records: this.finalRecords})
            .then(result => {
               if (result === true) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: displayMessage,
                            variant: 'success'
                        })
                    );
                    this.showSpinner = false;
                    this.isModalopen = false;
                    this.showApproveRejectButton = false; 
                } else if (result === false) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Failed',
                            message: 'There is an error in Approving the Activity',
                            variant: 'error'
                        })
                    );
                    this.showSpinner = false;
                    this.isModalopen = false;        
                }
            })
            .catch(error => {
                this.error = error;
                this.showSpinner = false;
                console.log('Inside Catch Error => '+error);
            });
    }
    showTotalItemsCount() {
        let itemsCount = this.recordsToRender.length;
        if (itemsCount <= 0) {
            this.selectAllDisabled = true;
            this.noApprovalRequestsFound = true;
            this.noApprovalRequestsFoundMessage = true;
        } else if (itemsCount > 0) {
            this.selectAllDisabled = false;
            this.noApprovalRequestsFound = false;
            this.noApprovalRequestsFoundMessage = false;
        }
    }
    isBulkApprovalRequestsRequired() {
        isBulkApprovalRequestsActive()
            .then(data => {
                if(data != null && data != undefined){
                    this.isBulkAppReqsActive = data;
                    console.log(">>> this.isBulkAppReqsActive: " + this.isBulkAppReqsActive);
                }
                else if(error){
                    this.error = error;
                    this.isBulkAppReqsActive = false;
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    /*handleSearchWithApex(event){
        this.searchKey = event.target.value;
         window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.fuzzySearch();
        }, 350);
    }

    fuzzySearch(){
        let searchInputValue= this.searchKey;
        let matchingIds;
        var allRecords=[];
        allRecords=this.recordsToRender;
        var filteredRecords=[];
        this.noSearchResultsFound = false;
        this.isSearchContext=false;

        if(searchInputValue != '' && searchInputValue != undefined && searchInputValue != null){
        searchApprovals({searchKeyword:searchInputValue})
            .then(data => {
                matchingIds = data;
                for(var index in allRecords){
                    if(matchingIds.includes(allRecords[index].recordId)){
                        filteredRecords.push(allRecords[index]);
                    }
                }
                this.isSearchContext=true;
                this.searchRecordsToRender= filteredRecords;
                if(filteredRecords.length<=0){
                    this.noSearchResultsFound = true;
                }
            })
            .catch(error => {
                this.error = error;
                
            });
        }
    } */

}