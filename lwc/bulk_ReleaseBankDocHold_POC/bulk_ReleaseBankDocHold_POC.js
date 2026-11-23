import { LightningElement,track,wire,api } from 'lwc';
import getClaims from '@salesforce/apex/Core_MDF_Bulk_ReleaseBankDocHold.getClaims';
import releaseHold from '@salesforce/apex/Core_MDF_Bulk_ReleaseBankDocHold.releaseHold';
import checkAccess from '@salesforce/apex/Core_MDF_Bulk_ReleaseBankDocHold.checkAccess';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const DELAY = 300;
export default class Bulk_ReleaseBankDocHold_POC extends LightningElement {
    @api recordsToDisplay= [];
    @api recordsToRender= [];
    @api recordCount;
    @track selectedClaimIdList = [];
    @track message;
    @track sortBy;
    @track sortDirection;
    @track opps; //All claims available for data table    
    @track showTable = false; //Used to render table after we get the data from apex controller
    @track rowNumberOffset; //Row number
    @track hasAccess = false;
    @track isSpinner = false;
    @track columns = [
        { label: 'Claim Name', fieldName: 'claimTitle', type: 'url', typeAttributes: { label: { fieldName: 'Title' }, target: '_blank'}, sortable: true, cellAttributes: { alignment: 'left'}},
        { label: 'Claim Number', fieldName: 'Core_MDF_Claim_Ref_Number__c', type: 'text', sortable: true, cellAttributes: { alignment: 'left'}},
        { label: 'Account (Company)', fieldName: 'Core_MDF_AccountCompany__c', type: 'text', sortable: true, cellAttributes: { alignment: 'left'}},
        { label: 'Program', fieldName: 'Core_MDF_Program__c', type: 'text', sortable: true, cellAttributes: { alignment: 'left'}}
    ];
    connectedCallback(){
        this.isSpinner = true;
        checkAccess()
        .then(result => {
            this.hasAccess = result;
            console.log("hasAccess--->", JSON.stringify(this.hasAccess));
           // this.error = undefined;
        })
        .catch(error => {
            this.hasAccess = false;
        });
   }
  // @wire (checkAccess) hasAccess1;
 /*  @wire (checkAccess) checkPAAccess({error,data}){
    console.log("hasAccess--->", JSON.stringify(this.hasAccess));
       if(data != null && data != undefined){
           this.hasAccess = data;
           console.log("hasAccess2--->", JSON.stringify(this.hasAccess));
       }
       else if(error){
           this.hasAccess = false;
           console.log("hasAccess2--->", JSON.stringify(this.hasAccess));
       }
   }*/

    updateSelRecords(){
        releaseHold({selClaimIdList:this.selectedClaimIdList})
        .then(result => {               
            this.dispatchEvent( 
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Selected Claims are released from Bank Document Hold!',
                    variant: 'success',
                }),
            );
            var recordstoshow = this.recordsToRender;
            var claimrecordid = [];
            for(let index=0; index<recordstoshow.length; index++){
                claimrecordid.push(recordstoshow[index].Id);
            }
            console.log("recordsToRender1--->", JSON.stringify(this.recordsToRender));
                var showclaims =[];
                console.log("claimrecordid--->", claimrecordid);
                
                console.log("recordstoshow1--->", JSON.stringify(recordstoshow));
                console.log("sel claim list", JSON.stringify(this.selectedClaimIdList));
                console.log("sel claim list length", JSON.stringify(this.selectedClaimIdList.length));
            for(let i=0; i<this.selectedClaimIdList.length; i++){
                console.log("recordstoshow2--->", JSON.stringify(recordstoshow));
                if(claimrecordid.includes(this.selectedClaimIdList[i])){
                    console.log("recordstoshow3--->", JSON.stringify(recordstoshow));
                    console.log("selectedClaimIdList--->", this.selectedClaimIdList[i]);
                   var  recordindex = claimrecordid.indexOf(this.selectedClaimIdList[i]); //var a = ["a","123"]
                   recordstoshow.splice(recordindex,i);
                   console.log("recordsindex--->", recordindex);
                   console.log("recordstoshow4--->", JSON.stringify(recordstoshow));
                    
                }
            }
            this.recordsToRender = recordstoshow;
            console.log("recordsToRender--->", JSON.stringify(this.recordsToRender));

           // setTimeout(function(){window.location.reload();},1500);          
              //for clearing selected row indexs 
            this.template.querySelector('lightning-datatable').selectedRows = [];

            return refreshApex(this.recordsToDisplay);        
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
           /* this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating records',
                    message: error.body.pageErrors[0].message,
                    variant: 'error',
                }),
            );*/
            console.log("error", JSON.stringify(this.error));
        });
    }

    @wire (getClaims) claimRecords({error,data}){
        this.isSpinner = false;
        if(data){
           // let recs = [];
         /*   for(let i=0; i<data.length; i++){
                let opp = {};
                opp.rowNumber = ''+(i+1);
                opp.oppLink = '/'+data[i].Id;
                opp = Object.assign(opp, data[i]);
               // opp.Title = '/' + opp[i].Id;
                recs.push(opp);
            }*/
            let tempClaimList = [];             
            data.forEach((record) => {
                let tempClaimRec = Object.assign({}, record);  
                tempClaimRec.claimTitle = '/' + tempClaimRec.Id;
              //  tempClaimRec.rowNumber = '' + (record.length+1);
                tempClaimList.push(tempClaimRec);
                
            });
            this.recordsToDisplay = tempClaimList;
            this.recordsToRender = tempClaimList;
            this.recordCount = data.length;
            this.showTable = true;
            console.log("data--->", JSON.stringify(this.recordsToDisplay));
           // this.data = data;
        }
        else if(error){
            this.recordsToDisplay = undefined;
        }
    } 
    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
           // this.recordsToDisplay = event.detail;
            this.recordsToRender = event.detail;
            //this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
    }
    fetchSearchedRecords(event){
        var searchTextClaimName = '';
        searchTextClaimName = event.target.value;
        if(searchTextClaimName === '' || searchTextClaimName === undefined){
            this.recordsToRender = this.recordsToDisplay;
        }
        else{
			// Filtering the claim list on searched text and returning it          
            var filteredClaim = this.recordsToDisplay.filter(function (claim){ 
            	return claim.Title.toLowerCase().includes(searchTextClaimName.toLowerCase());                                                     
            });
            // If the filtered accounts is not empty then display those Claims
            if(filteredClaim != null && filteredClaim.length>0 && filteredClaim != 'undefined'){
                this.recordsToRender = filteredClaim;
            }
            else{
                this.recordsToRender =[] ;
            }            
        }
        this.recordCount = this.recordsToRender.length;
            console.log('this.recordsToRender.length',this.recordCount);
            console.log('this.recordsToRender.length',this.recordsToRender);
            // Calling Paginator function to handle Pagination when a search is made
            this.template.querySelector("c-paginator").handlePaginationOnSearch(this.recordsToRender, this.recordCount);
    }

   /* handleKeyChange(event){
        const searchString= event.target.value;
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(()=>{
            this.recordsToDisplay =searchString;
        },DELAY);
    }*/
    
    
    prepareSelectedRows(event){
        const selectedRows=event.detail.selectedRows; 
        this.selectedClaimIdList = []; 
        for (let i = 0; i < selectedRows.length; i++){           
            this.selectedClaimIdList.push(selectedRows[i].Id);
        }  
        console.log(this.selectedClaimIdList);   
    }
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
        let parseData = JSON.parse(JSON.stringify(this.recordsToDisplay));

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
        this.recordsToDisplay = parseData;

    }
}