import { LightningElement,track,wire,api } from 'lwc';
import getClaims from '@salesforce/apex/Core_MDF_Bulk_ReleaseBankDocHold.getClaims';
import releaseHold from '@salesforce/apex/Core_MDF_Bulk_ReleaseBankDocHold.releaseHold';
import checkAccess from '@salesforce/apex/Core_MDF_Bulk_ReleaseBankDocHold.checkAccess';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import applicationError from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
const DELAY = 300;
export default class Core_mdf_bulk_ReleaseBankDocHold extends LightningElement {
    @api allClaims= [];
    @api claimsToDisplay= []; //claims to display in datatable
    @api recordCount;
    @track selectedClaimIdList = [];
    @track message;
    @track sortBy;
    @track sortDirection;
    @track showTable = false; //Used to render table after we get the data from apex controller
    @track hasAccess = false;
    @track isSpinner = false;
    @track buttonDisable = true;
    @track toastmessage = '';
    @track columns = [
        { label: 'Claim Name', fieldName: 'claimTitle', type: 'url', typeAttributes: { label: { fieldName: 'Title' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left'}},
        { label: 'Claim Number', fieldName: 'Core_MDF_Claim_Ref_Number__c', type: 'text', sortable: true, cellAttributes: { alignment: 'left'}},
        { label: 'Amount', fieldName: 'Amount', type: 'currency', sortable: true, cellAttributes: { alignment: 'left'}},
        { label: 'Account (Company)', fieldName: 'Core_MDF_AccountCompany__c', type: 'text', sortable: true, cellAttributes: { alignment: 'left'}},
        { label: 'Program', fieldName: 'Core_MDF_Program__c', type: 'text', sortable: true, cellAttributes: { alignment: 'left'}},
        { label: 'Budget Type', fieldName: 'Core_MDF_Budget_Type_Options_Nm__c', type: 'text', sortable: true, cellAttributes: { alignment: 'left'}}        
    ];
    label = { applicationError };

    //to check whether logged in user has the correct permission to release bank doc hold
    connectedCallback(){
        this.isSpinner = true;
        checkAccess()
        .then(result => {
            this.hasAccess = result;
        })
        .catch(error => {
            this.hasAccess = false;
        });
   }

   //on click of release hold button this method is called and 
    updateSelRecords(){
    var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
    for (let index = 0; index < selectedRecords.length; index++){           
        this.selectedClaimIdList.push(selectedRecords[index].Id);
    } 
    console.log("selected records-->", JSON.stringify(selectedRecords));
        releaseHold({selClaimIdList:this.selectedClaimIdList})
        .then(result => {
           // this.isSpinner = true;                
            this.dispatchEvent( 
                new ShowToastEvent({
                    title: 'Success',
                    message: result,
                    variant: 'success',
                }),
            );
            
            setTimeout(function(){window.location.reload();},1500);          
            //for clearing selected row indexs 
            this.template.querySelector('lightning-datatable').selectedRows = [];

            return refreshApex(this.allClaims);        
        })
        .catch(error => {
        //    this.isSpinner = true;
          //  this.message = undefined;
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Application error occurred.',
                    message: this.label.applicationError,
                    variant: 'error',
                }),
            );
        });
    }


    //fetch the claims records which are in bank document hold and not on audit hold
    @wire (getClaims) claimRecords({error,data}){
        this.isSpinner = false;
        if(data){
            let tempClaimList = [];             
            data.forEach((record) => {
                let tempClaimRec = Object.assign({}, record);  
                tempClaimRec.claimTitle = '/' + tempClaimRec.Id;
                tempClaimList.push(tempClaimRec);
                
            });
            this.allClaims = tempClaimList;
            this.claimsToDisplay = tempClaimList;
            this.recordCount = data.length;
            this.showTable = true;
        }
        else if(error){
            this.allClaims = undefined;
        }
    } 
    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
            this.template.querySelector('lightning-datatable').selectedRows = [];
            this.buttonDisable = true;
            this.claimsToDisplay = event.detail;
    }

    //this method is called from the serch logic on html side
    //to fetch the searched records in the datatable
    fetchSearchedRecords(event){
        var searchTextClaimName = '';
        //gets the value of the input given on the UI search field
        searchTextClaimName = event.target.value;
        //If user does not input anything in search field
        if(searchTextClaimName === '' || searchTextClaimName === undefined){
            this.claimsToDisplay = this.allClaims;
        }
        else{
			// Filtering the claim list on searched text and returning it          
            var filteredClaim = this.allClaims.filter(function (claim){ 
            	return claim.Title.toLowerCase().includes(searchTextClaimName.toLowerCase());                                                     
            });
            // If the filtered claims is not empty then display those Claims
            if(filteredClaim != null && filteredClaim.length>0 && filteredClaim != 'undefined'){
                this.claimsToDisplay = filteredClaim;
            }
            else{
                this.claimsToDisplay =[] ;
            }            
        }
        this.recordCount = this.claimsToDisplay.length;
        // Calling Paginator function to handle Pagination when a search is made
        this.template.querySelector("c-paginator").handlePaginationOnSearch(this.claimsToDisplay, this.recordCount);
    }
    
    //preparing the selected rows in datatable
    prepareSelectedRows(event){
        const selectedRows=event.detail.selectedRows; 
        if(selectedRows.length > 0){           
            this.buttonDisable = false;
        }
        else{
            this.buttonDisable = true;
        }
    }

    //sorting logic
    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.claimsToDisplay));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.claimsToDisplay = parseData;

    }
}