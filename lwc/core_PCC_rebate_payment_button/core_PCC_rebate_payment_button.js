import { LightningElement, track, api } from 'lwc';
import Fetchrecords from '@salesforce/apex/PCC_UpdateClaimsController.getClaimRecords';
import Updaterecords from '@salesforce/apex/PCC_UpdateClaimsController.updateClaims';
import userPScheck from '@salesforce/apex/PCC_UpdateClaimsController.userPScheck'; //TWC3123-6336
import noPSMessage from '@salesforce/label/c.PCC_BulkPayment_NoPS'; //TWC3123-6336
import nodatamessage from '@salesforce/label/c.PCC_BulkPayment_Nodata';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import TIME_ZONE  from '@salesforce/i18n/timeZone';

const PAGE_SIZE = 50;
 const columns = [ { label: 'S.No', fieldName: 'serialNumber', type: 'text' }, 
 { label: 'Claim Number', fieldName: 'claimUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' } } }, 
 { label: 'Total Claimed Rebate', fieldName: 'PCC_Total_Claimed_Rebate__c', type: 'currency',
   cellAttributes: { alignment: 'center' } },
 { label: 'Submission Date', fieldName: 'formattedSubmissionDate', type: 'text'}, 
 { label: 'Approval Date', fieldName: 'PCC_Approval_Date__c', type: 'text'},
 { label: 'CSAR ID', fieldName: 'PCC_CSAR_ID__c', type: 'text' },
 { label: 'Payment Ref ID', fieldName: 'PCC_Payment_Ref_Id__c', type: 'text' } ];

export default class UpdateClaimsModal extends  NavigationMixin(LightningElement) {
    @api selectedClaims = []; // Receive selected claims from parent component
    @track csarId;
    @track paymentRefId;
    @track claimRecords = []; // Array to hold fetched claim records
    @track selectedClaimIds = []; // Array to hold selected claim IDs
    @track showSuccessMessage = false;
    @track appliedStateMap = new Map();
    //@track change=false;
    @track fromDate;
    @track toDate;
    @track rebateclaim = [];
    @track partnerName ='';
    @track error =[];
    @track currentPage = 1;
    @track totalPages = 0; 
    @track totalRecordCount = 0; // Track total record count
    @track endRecord = 0; // Track end record number for current page
    @track saveButton = false;
    @track displayfields = false;
    @track selectedRows = [];
    @track originalClaimRecords = []; // New property to hold container data
    @api havingPS=false; //TWC3123-6336
    
    columns = columns;
    
  handleRowSelection(event) {
        console.log('39 before selectedRows ',this.selectedRows);
        console.log('40 event.detail.config.action',event.detail.config.action);
        var selectedIds = [];
        for(var i=0; i<event.detail.selectedRows.length;i++){
            selectedIds.push(event.detail.selectedRows[i].Id);
            if(!this.selectedRows.includes(event.detail.selectedRows[i].Id)){
                this.selectedRows.push(event.detail.selectedRows[i].Id);
            }
        }
        console.log('46 after selected rows',this.selectedRows);
        console.log('47 var selectedIds',selectedIds);
        this.selectedClaimIds =selectedIds;
        console.log('48  this.selectedClaimIds ',this.selectedClaimIds);

        if(event.detail.config.action === 'rowDeselect'){
            event.detail.config.value
            if(this.selectedRows.includes(event.detail.config.value)){
                console.log('56 if deselect event.detail.config.value',event.detail.config.value);
                const index = this.selectedRows.indexOf(event.detail.config.value);
                this.selectedRows.splice(index, 1);
    
            }
            if(this.selectedRows.length === 0){
              this.csarId = '';
              this.paymentRefId = '';
              this.saveButton = false;//added
             }
           
            const deselectedId = event.detail.config.value;
            let updatedClaimRecords = [...this.claimRecords]; 
            const index = updatedClaimRecords.findIndex(record => record.Id === deselectedId);
                if (index !== -1) {
                    updatedClaimRecords[index].PCC_CSAR_ID__c = this.originalClaimRecords[index].PCC_CSAR_ID__c;
                    updatedClaimRecords[index].PCC_Payment_Ref_Id__c = this.originalClaimRecords[index].PCC_Payment_Ref_Id__c;
                    updatedClaimRecords[index].applied = false;
                    console.log('84 proprty',updatedClaimRecords[index].applied);
                     }
             this.claimRecords = updatedClaimRecords;
             
             if (this.appliedStateMap.has(deselectedId)) {
            this.appliedStateMap.delete(deselectedId);
            }
   
            console.log('56 if deselect selected rows',this.selectedRows);
            }
        if (event.detail.config.action === 'deselectAllRows') {
         // Deselect all rows on the current page
        let idsToRemove = [];
            for (var i = 0; i < this.claimRecords.length; i++) {
                const rowId = this.claimRecords[i].Id;
                if (this.selectedRows.includes(rowId)) {
                    const index = this.selectedRows.indexOf(rowId);
                    this.selectedRows.splice(index, 1);
                    idsToRemove.push(rowId);
                }
            }
            if(this.selectedRows.length === 0){
            this.csarId = '';
            this.paymentRefId = '';
            this.saveButton = false;//added 
            }
            let updatedClaimRecords = [...this.claimRecords]; // Make a copy of claimRecords
            for (let i = 0; i < updatedClaimRecords.length; i++) {
               const record = updatedClaimRecords[i];
               const originalRecord = this.originalClaimRecords.find(orig => orig.Id === record.Id);
            if (originalRecord) {
                record.PCC_CSAR_ID__c = originalRecord.PCC_CSAR_ID__c;
                record.PCC_Payment_Ref_Id__c = originalRecord.PCC_Payment_Ref_Id__c;
            }
            record.applied = false;
        }
        this.claimRecords = updatedClaimRecords;
         idsToRemove.forEach(id => {
            if (this.appliedStateMap.has(id)) {
                this.appliedStateMap.delete(id);
            }
         });
    }
  }
   
    get isCsarIdDisabled() {
        console.log('disabled icsardisabled claim len',this.selectedClaimIds.length);
        return this.selectedRows.length === 0;
    }

    get isPaymentRefIdDisabled() {
        console.log('disabled payrefdisable claim len',this.selectedClaimIds.length);
        return this.selectedRows.length === 0;
    }
   
    get isApplyDisabled() {
        console.log('disbled isApplyDisabled cs',this.csarId);
        console.log('disbled isApplyDisabled pay',this.paymentRefId);
        console.log('disabled isApplyDisabled claim len',this.selectedClaimIds.length);
        return( this.selectedRows.length === 0 || (!this.csarId && !this.paymentRefId));
    } 

    get isSaveDisable(){
        console.log('is saved disable',this.saveButton);
        return (this.saveButton === false ||this.selectedRows.length === 0)  ;
    }
       
    connectedCallback() {
        //TWC3123-6336 -Rebate Analyst Permission Set check
        userPScheck({})
        .then(result => { 
            if (result!= null){
                this.havingPS = result;
            } 
        })
    }
   
    fetchClaimRecords() {
            console.log('apex call',this.partnerName);
            console.log('apex call',this.fromDate);
            console.log('apex call',this.toDate);
            Fetchrecords({partnerName : this.partnerName, fromdate: this.fromDate, todate: this.toDate })
                .then(result => {
                    const filteredRecords = result.map((pccRebateClaim, index) => ({
                        ...pccRebateClaim,
                        serialNumber: index + 1,
                        PCC_CSAR_ID__c: pccRebateClaim.PCC_CSAR_ID__c,
                        PCC_Payment_Ref_Id__c: pccRebateClaim.PCC_Payment_Ref_Id__c,
                        isSelected: this.selectedClaims.some(selClaim => selClaim.Id === pccRebateClaim.Id),
                        selected: false, // Add this property
                        applied: false,
                        claimUrl: `/${pccRebateClaim.Id}`
                    }));

                    this.originalClaimRecords = result.map(record => ({
                    Id: record.Id,
                    PCC_CSAR_ID__c: record.PCC_CSAR_ID__c,
                    PCC_Payment_Ref_Id__c: record.PCC_Payment_Ref_Id__c
                    }));
                    this.selectedClaimIds = this.selectedRows;
										// Format the raw data
										this.formatData = filteredRecords.map(record => ({
												...record,
												formattedSubmissionDate: this.formatDate(record.PCC_Submission_Date__c, true)
												//formattedApprovedDate: this.formatDate(record.PCC_Approval_Date__c, false)
										}));
                    this.claimRecords = this.formatData;
                    console.log('Filtered claim records:', this.claimRecords);

                    if (this.claimRecords.length !== 0){

                    this.totalRecordCount = filteredRecords.length; 
                    
                    this.totalPages = Math.ceil(filteredRecords.length / PAGE_SIZE);
                    console.log('Filtered page,no:', this.totalPages);
                    this.displayfields = this.partnerName.length !== 0;

                    this.pagePreparation();
                   
                     }
                     else{
                         console.log('Else fetchclaim');
                        const evnt = new ShowToastEvent({
                        message: 'There is no data present.',
                        variant: 'error',
                        mode: 'dismissable'
                        });
                        this.dispatchEvent(evnt);
                        this.displayfields = false;
                     }
                })
                .catch(error => {
                    console.error('Error fetching claim records:', error);
                    // Optionally show error message or handle error state
                });
        
    }
		
		formatDate(dateString, includeTime) {
        const date = new Date(dateString);
        const timeZone = TIME_ZONE;

        const options = {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            hour: includeTime ? 'numeric' : undefined,
            minute: includeTime ? 'numeric' : undefined,
            second: includeTime ? 'numeric' : undefined,
            hour12: true,
            timeZone: timeZone
        };

        const formatter = new Intl.DateTimeFormat(navigator.language, options);
        return formatter.format(date);
    }
    
    handleFromDateChange (event){
        this.fromDate = event.target.value;
    }

    handleToDateChange(event){
        this.toDate = event.target.value;
    }

    handlepartnername(event){
        this.partnerName = event.detail.recordId;
        console.log('265',this.partnerName,event.detail.recordId);
    }
    handleCsarIdChange(event) {
        const newCsarId = event.target.value;
        if ( newCsarId.trim() !== ''){
         this.csarId = newCsarId;   
        }
        if (newCsarId !== null ) {
            this.csarId = newCsarId;
        }
        console.log('AA handleCsarIdChange', this.csarId);
    }
    handleSearch(){
        if(!this.partnerName || !this.fromDate || !this.toDate){
            const evnt = new ShowToastEvent({
                title: 'Error',
                message: nodatamessage,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evnt);
            this.displayfields = false;
        }
        else{
            //TWC3123-6336 - start - if PS is there , only then fetch the records, else throw the 'NO PS' Error
            if(this.havingPS === true) {
                this.fetchClaimRecords();
                //this.resetFields(); 
                this.selectedRows = [];
                this.csarId='';
                this.paymentRefId='';
            }
            else{
                const evnt = new ShowToastEvent({
                message: noPSMessage ,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evnt);
            }
            //TWC3123-6336 - end
        }
        
    }
    handlePaymentRefIdChange(event) {
        const newpayrefId = event.target.value;
        if (newpayrefId.trim() !== ''  ){
            this.paymentRefId = newpayrefId ;
        }
        if (newpayrefId !== null ){
            this.paymentRefId = newpayrefId ;
        }
    }

    handleapplyCsarPaymentRef() {
    console.log('AA 127 this.claimRecords', this.claimRecords);
    let updatedClaimRecords = [...this.claimRecords];
    this.selectedRows.forEach((id) => {
        const selectedIndex = updatedClaimRecords.findIndex((record) => record.Id === id);
        if (selectedIndex !== -1) {
            if (!this.csarId && this.originalClaimRecords[selectedIndex]) {
                updatedClaimRecords[selectedIndex].PCC_CSAR_ID__c = this.originalClaimRecords[selectedIndex].PCC_CSAR_ID__c;
            } else {
                updatedClaimRecords[selectedIndex].PCC_CSAR_ID__c = this.csarId;
            }

            if (!this.paymentRefId && this.originalClaimRecords[selectedIndex]) {
                updatedClaimRecords[selectedIndex].PCC_Payment_Ref_Id__c = this.originalClaimRecords[selectedIndex].PCC_Payment_Ref_Id__c;
            } else {
                updatedClaimRecords[selectedIndex].PCC_Payment_Ref_Id__c = this.paymentRefId;
            }
             updatedClaimRecords[selectedIndex].applied = true;
           
        }
         this.appliedStateMap.set(id, true);
    });

    this.claimRecords = updatedClaimRecords;
    this.saveButton = true;
    console.log('AA 136 this.claimRecords', this.claimRecords);
}



     handlesave() {
     // Call Apex method to update claims
     Updaterecords({ claimIds: this.selectedRows, csarId: this.csarId, paymentRefId: this.paymentRefId })
       .then(result => {
            console.log('Claims updated successfully:', result);
            // Dispatch success toast message
            const evnt = new ShowToastEvent({
               title: 'Success',
               message: 'CSAR/Payment Ref ID applied successfully',
               variant: 'success',
               mode: 'dismissable'
            });
            this.dispatchEvent(evnt);

             // Refresh the entire page
           // eval("$A.get('e.force:refreshView').fire();")
            this.showSuccessMessage = true; // Show success message
            this.resetFields(); 
            this.fetchClaimRecords();
        })
       .catch(error => {
            console.error('Error updating claims:', error);
            // Optionally show error message or handle error state
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error updating claims: ' + error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        });
        
     }


    handleReset() {
       // this.closeModal(); // Close modal
        eval("$A.get('e.force:refreshView').fire();"); // Refresh the component

    }

    resetFields() {
        this.saveButton = false
        this.csarId = '';
        this.paymentRefId = '';
        this.selectedClaimIds = [];
        this.selectedRows = []; 
        /*
        this.filteredRecords =[];
         //Reset isSelected for claimRecords based on original selectedClaims
        this.claimRecords = this.claimRecords.map(pccRebateClaim => ({
            ...pccRebateClaim,
            isSelected: this.selectedClaims.some(selClaim => selClaim.Id === pccRebateClaim.Id)
        }));
       */
       //this.fetchClaimRecords();
        console.log('reseet');
    }
    
     navigateToPage(pageNumber) {
        if (pageNumber >= 1 && pageNumber <= this.totalPages && pageNumber !== this.currentPage) {
            this.currentPage = pageNumber;
            this.fetchClaimRecords();
        }
    }

      // Method to handle "Previous" button clic
     handlePrevious() {
        if (this.currentPage > 1) {
            this.navigateToPage(this.currentPage - 1);
        }
        console.log('401 previous ',this.selectedRows);
        this.selectedClaimIds.concat( this.selectedRows);
        console.log('399 this.selectedClaimIds',this.selectedClaimIds);
    }

    get ispreviousDisable() {
         return this.currentPage === 1;
    }

    // Method to handle "Next" button click
    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.navigateToPage(this.currentPage + 1);
        }
    }

    get isnextDisable(){
        return this.currentPage === this.totalPages;
    }
    
    pagePreparation() {
    const startIndex = (this.currentPage - 1) * PAGE_SIZE;
    this.claimRecords = this.claimRecords.slice(startIndex, startIndex + PAGE_SIZE);

    this.claimRecords.forEach(pccRebateClaim => {
        const originalRecord = this.originalClaimRecords.find(record => record.Id === pccRebateClaim.Id);

        if (this.selectedRows.includes(pccRebateClaim.Id)) {
            pccRebateClaim.selected = true;
            pccRebateClaim.isChecked = true;

            const isApplied = this.appliedStateMap.get(pccRebateClaim.Id) || false;
            console.log('407',this.appliedStateMap);
            console.log('406',this.isApplied);
            pccRebateClaim.applied = isApplied;

            if (pccRebateClaim.applied && pccRebateClaim.selected) {
            if (this.csarId !== undefined && this.csarId !== null && this.csarId !== '') {
                pccRebateClaim.PCC_CSAR_ID__c = this.csarId;
            } else if (!pccRebateClaim.PCC_CSAR_ID__c && originalRecord) {
                pccRebateClaim.PCC_CSAR_ID__c = originalRecord.PCC_CSAR_ID__c;
            }

            if (this.paymentRefId !== undefined && this.paymentRefId !== null && this.paymentRefId !== '') {
                pccRebateClaim.PCC_Payment_Ref_Id__c = this.paymentRefId;
            } else if (!pccRebateClaim.PCC_Payment_Ref_Id__c && originalRecord) {
                pccRebateClaim.PCC_Payment_Ref_Id__c = originalRecord.PCC_Payment_Ref_Id__c;
            }
          }
        } else {
            pccRebateClaim.selected = false;
            pccRebateClaim.isChecked = false;

            /* Maintain existing values if not selected
            if (!pccRebateClaim.PCC_CSAR_ID__c && originalRecord) {
                pccRebateClaim.PCC_CSAR_ID__c = originalRecord.PCC_CSAR_ID__c;
            }
            if (!pccRebateClaim.PCC_Payment_Ref_Id__c && originalRecord) {
                pccRebateClaim.PCC_Payment_Ref_Id__c = originalRecord.PCC_Payment_Ref_Id__c;
            }*/
        }
    });

    const startRecord = (this.currentPage - 1) * PAGE_SIZE + 1;
    const endRecord = Math.min(startRecord + this.claimRecords.length - 1, this.totalRecordCount);
    this.endRecord = endRecord;

    this.totalPageCount = Math.ceil(this.totalRecordCount / PAGE_SIZE);

    console.log('429 Selected ids:', this.selectedRows);
    console.log('Claim Records:', this.claimRecords);
}

    
}