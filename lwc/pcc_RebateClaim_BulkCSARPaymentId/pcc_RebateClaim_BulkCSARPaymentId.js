import { LightningElement, track, api } from 'lwc';
import Fetchrecords from '@salesforce/apex/PCC_UpdateClaimsController.getClaimRecords';
import Updaterecords from '@salesforce/apex/PCC_UpdateClaimsController.updateClaims';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

const PAGE_SIZE = 2;
 const columns = [ { label: 'S.No', fieldName: 'serialNumber', type: 'text' }, 
 { label: 'Claim Number', fieldName: 'claimUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' } } }, 
 { label: 'Total Claimed Rebate', fieldName: 'PCC_Total_Claimed_Rebate__c', type: 'currency' },
 { label: 'Submission Date', fieldName: 'PCC_Submission_Date__c', type: 'date' }, 
 { label: 'CSAR ID', fieldName: 'PCC_CSAR_ID__c', type: 'text' },
 { label: 'Payment Ref ID', fieldName: 'PCC_Payment_Ref_Id__c', type: 'text' } ];

export default class Pcc_RebateClaim_BulkCSARPaymentId extends LightningElement {
    @api selectedClaims = []; // Receive selected claims from parent component
    @track csarId;
    @track paymentRefId;
    @track claimRecords = []; // Array to hold fetched claim records
    @track selectedClaimIds = []; // Array to hold selected claim IDs
    @track showSuccessMessage = false;
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
     selectedRows = [];
    
    columns = columns;
    
   handleRowSelection(event) {
     console.log('54 selectedRows ',this.selectedRows);

    var selectedIds = [];
    for(var i=0; i<event.detail.selectedRows.length;i++){
        selectedIds.push(event.detail.selectedRows[i].Id);
        this.selectedRows.push(event.detail.selectedRows[i].Id);
    }
    console.log('67 selected rows',this.selectedRows);
    this.selectedClaimIds =selectedIds;
    console.log('66  this.selectedClaimIds ',this.selectedClaimIds);
   
   
}
   
    get isCsarIdDisabled() {
        console.log('is CSAR disable',this.selectedClaimIds.length);
        return this.selectedRows.length === 0;
    }

    get isPaymentRefIdDisabled() {
        console.log('is payref disable',this.selectedClaimIds.length);
        return this.selectedRows.length === 0;
    }

        get isApplyDisabled() {
            console.log('disbled',this.csarId);
            console.log('disbled',this.paymentRefId);
            console.log('disabled',this.selectedClaimIds.length);
        return( this.selectedRows.length === 0 || (!this.csarId && !this.paymentRefId));
    
    }  
        get isSaveDisable(){
          console.log('is saved disable',this.saveButton);
        return this.saveButton === false;
    }
       

    connectedCallback() {
        // Fetch claim records when component initializes
        this.fetchClaimRecords();
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
                        claimUrl: `/${pccRebateClaim.Id}`
                    }));
                    this.selectedClaimIds = this.selectedRows;
                    this.claimRecords = filteredRecords;
                    console.log('Filtered claim records:', this.claimRecords);

                    if (this.claimRecords.length !== 0){
                    this.totalRecordCount = filteredRecords.length; 
                    
                    this.totalPages = Math.ceil(filteredRecords.length / PAGE_SIZE);
                    console.log('Filtered page,no:', this.totalPages);
                    this.displayfields = this.partnerName.length !== 0;

                    this.pagePreparation();
                   
                     }
                     else{
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
    
    handleFromDateChange (event){
        this.fromDate = event.target.value;
        //this.fetchClaimRecords();
    }

    handleToDateChange(event){
        this.toDate = event.target.value;
        //this.fetchClaimRecords();
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
        message: 'Please select Partner Account and Duration to search for Claims',
        variant: 'error',
        mode: 'dismissable'
    });
    this.dispatchEvent(evnt);
    this.displayfields = false;
     }
     this.fetchClaimRecords();
    }
   
    handlePaymentRefIdChange(event) {
        const newpayrefId = event.target.value;
        if (newpayrefId.trim() !== ''  ){
              this.paymentRefId = newpayrefId ;}
        if (newpayrefId !== null ){
                this.paymentRefId = newpayrefId ;}
    }

     handleapplyCsarPaymentRef() {
       console.log('AA 127 this.claimRecords', this.claimRecords);
        let updatedClaimRecords = [...this.claimRecords];
           this.selectedClaimIds.forEach((id) => {
            const selectedIndex = updatedClaimRecords.findIndex((record) => record.Id === id);
               if (selectedIndex !== -1) {
                  if (this.csarId !== '' && this.csarId !== null && this.csarId !== undefined) {
                    console.log('blankrow row CSAR', this.csarId);
                    updatedClaimRecords[selectedIndex].PCC_CSAR_ID__c = this.csarId;
                   }
                if (this.paymentRefId !== '' && this.paymentRefId !== null && this.paymentRefId !== undefined) {
                    console.log('blankrow payref', updatedClaimRecords[selectedIndex].pcc_Payment_Ref_Id);
                    updatedClaimRecords[selectedIndex].PCC_Payment_Ref_Id__c = this.paymentRefId;
                    }
             }
           });
              this.claimRecords = updatedClaimRecords;
               this.saveButton = true;
              console.log('AA 136 this.claimRecords', this.claimRecords);
   }


    handlesave() {
     // Call Apex method to update claims
    Updaterecords({ claimIds: this.selectedClaimIds, csarId: this.csarId, paymentRefId: this.paymentRefId })
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
        })
       .catch(error => {
            console.error('Error updating claims:', error);
            // Optionally show error message or handle error state
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error updating claims: ' + error.message,
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
        this.csarId = '';
        this.paymentRefId = '';
        this.selectedClaimIds = [];
        this.selectedRows = []; 
        // Reset isSelected for claimRecords based on original selectedClaims
        this.claimRecords = this.claimRecords.map(pccRebateClaim => ({
            ...pccRebateClaim,
            isSelected: this.selectedClaims.some(selClaim => selClaim.Id === pccRebateClaim.Id)
        }));
    }
    
     navigateToPage(pageNumber) {
        if (pageNumber >= 1 && pageNumber <= this.totalPages && pageNumber !== this.currentPage) {
            this.currentPage = pageNumber;
            this.fetchClaimRecords();
        }
    }

      // Method to handle "Previous" button click
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
        if (this.selectedClaimIds.includes(pccRebateClaim.Id)) {
            pccRebateClaim.selected = true;
            pccRebateClaim.isChecked = true; // Add this line
        } else {
            pccRebateClaim.selected = false;
            pccRebateClaim.isChecked = false; // Add this line
        }
    });

    const startRecord = (this.currentPage - 1) * PAGE_SIZE + 1;
    const endRecord = Math.min(startRecord + this.claimRecords.length - 1, this.totalRecordCount);
    this.endRecord = endRecord;

    this.totalPageCount = Math.ceil(this.totalRecordCount / PAGE_SIZE);
    
}
}