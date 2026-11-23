import {LightningElement, wire,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import retrieveOfferings from '@salesforce/apex/PMP_OfferingSearchController.retrieveOfferings';
//import getColumns from '@salesforce/apex/PMP_OfferingSearchController.getTableColumns';
import buttonVisibility from '@salesforce/apex/PMP_Utility.isLoggedInUserAdmin';
import editURLLabel from '@salesforce/label/c.PMP_Partner_Offering_Edit_Record';
import cloneURLLabel from '@salesforce/label/c.PMP_Partner_Offering_Clone_Record';


const columns = [
    { label: 'Offering Status', fieldName: 'PMP_Partner_Offering_Lifecycle_Status_Nm__c', type: 'text' },
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Edit', fieldName: 'EditRecord', type: 'url', typeAttributes: { label: 'Edit', target: '_blank'} },
    { label: 'Clone', fieldName: 'CloneRecord', type: 'url', typeAttributes: { label: 'Clone', target: '_blank'} },
    { label: 'Company Information', fieldName: 'Company' ,type: 'url', typeAttributes: { label: {fieldName: 'CompanyName'}, target: '_blank'}},
    //{ label: 'Marketplace Admin', fieldName: 'IntelAdmin' ,type: 'url', typeAttributes: { label: {fieldName: 'IntelAdminName'}, target: '_blank'}},
    { label: 'Category', fieldName: 'PMP_Category_nm__c' , type: 'text'},
    { label: 'Sub Category', fieldName: 'PMP_Sub_Category_nm__c' , type: 'text'},
    { label: 'Is Published', fieldName: 'PMP_Is_Published_Ind__c' , type: 'boolean'},
    { label: 'Partner Program', fieldName: 'PMP_Business_Segment_Nm__c' , type: 'text'},
    { label: 'Created Date', fieldName: 'CreatedDate' , type: 'text'},
    { label: 'Last Modified Date', fieldName: 'LastModifiedDate' , type: 'text'}
    
];
 
export default class PMP_SearchDataTable extends LightningElement {
    offerings = [];
    columns = columns;
    searchKey;
    showOfferings = false;
    @track dynamicColumns;
    @track isShowModal = false;
    @track isAdmin = false;
    /*@track v_Offset=0;
    @track v_TotalRecords;
    @track page_size = 5;*/
    @track recordEnd = 0;
    @track recordStart = 0;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track loaderSpinner = false;
    @track error = null;
    @track pageSize = 10;    
    @track isPrev = true;
    @track isNext = true;
    recordsToDisplay = [];

    /**
     * Custom labels
     *
     * @type {object}
     * @private
     */
    labels = {
        editURLLabel,
        cloneURLLabel
      }

    connectedCallback(){
        this.isLoggedInUserAdmin();
        this.generateColumns();

    }
    isLoggedInUserAdmin(){
        buttonVisibility()
            .then(result => {
                this.isAdmin = result;
                console.log('@@Admin=='+this.isAdmin);
                
            })
            .catch(error => {
                this.error = error;
            });
    }

    generateColumns(){
        getColumns({objName: 'PMP_Partner_Offering__c'})
        .then(result => { 
            let dynamicCols = [];
            let tempResults = result;
            let tempCol = {};
            const actions = [];
            for(let i=0;i<tempResults.length;i++){
                /*Non URL Columns */
                if(tempResults[i].Column_Type__c != 'url'){
              actions.push({
                'label': tempResults[i].Label__c,
                'fieldName': tempResults[i].Field_Name__c,
                'type' : tempResults[i].Column_Type__c,
                'typeAttributes' : tempResults[i].Type_Attributes__c
                
             });
            }
            /*URL Columns definition */
            else {
                let labelVal = tempResults[i].Field_Name__c.split('_');
                
                 if(tempResults[i].Field_Name_as_Label__c){
                    actions.push({
                        'label': tempResults[i].Label__c,
                        'fieldName': tempResults[i].Field_Name__c,
                        'type' : tempResults[i].Column_Type__c,
                        'typeAttributes' : {label:{fieldName:labelVal[0]} , target: '_blank'}
                        
                     });
                    
                 }else{
                     actions.push({
                        'label': tempResults[i].Label__c,
                        'fieldName': tempResults[i].Field_Name__c,
                        'type' : tempResults[i].Column_Type__c,
                        'typeAttributes' : {label:labelVal[0] , target: '_blank'}
                        
                     });

                 }

            }
             
          }
        console.log('@@dynamicCols 1 ==>'+JSON.stringify(columns))
        console.log('@@dynamicCols 2==>'+JSON.stringify(actions));
        this.dynamicColumns = actions;
            
        })
        .catch(error => {
        });
    }

    searchOfferings(){
        /*Need to check if this is needed */
        // if(this.searchKey.length <= 2){
        //     const event = new ShowToastEvent({
        //         title: 'Alert!',
        //         message: 'Please enter more than 2 characters',
        //         variant: 'error',
        //         mode: 'dismissable'
        //     });
        //     this.dispatchEvent(event);
        // }
        // else {
        retrieveOfferings({keyword: this.searchKey})
            .then(result => {
               let tempRecs = [];
               let editUrls = this.labels.editURLLabel.split(',');
               let cloneUrls = this.labels.cloneURLLabel.split(',');
               result.forEach( ( record ) => {
                        let tempRec = Object.assign( {}, record );  
                        let urlString = window.location.href;
                        let baseURL = urlString.substring(0, urlString.indexOf('/s'));
                        tempRec.Edit_Record =  baseURL + editUrls[0]+ tempRec.Id + editUrls[1] ;
                        tempRec.Clone_Record = baseURL + cloneUrls[0] + tempRec.Id+ cloneUrls[1];
                        tempRec.Company_Record = '/imp/s/partner-edit/' + tempRec.PMP_Company_Id__c;
                        tempRec.Company = tempRec.PMP_Company_Id__r.Name;
                        /*tempRec.IntelAdmin = '/' + tempRec.PMP_Intel_Admin_Id__c;
                        console.log('@@IntelAdmin=='+tempRec.IntelAdmin);
                        tempRec.IntelAdminName = tempRec.PMP_Intel_Admin_Id__r.Name;
                        console.log('@@IntelAdminName=='+tempRec.IntelAdminName);*/
                        tempRecs.push( tempRec );
                        
                    });
                this.offerings = tempRecs;
                this.totalRecords = this.offerings.length;
                if(this.offerings.length > 0) {
                    this.showOfferings = true;
                    this.getTableData();
                } else{
                    this.showOfferings = false;
                }
            })
            .catch(error => {
            });
        //}
    }

    handleKeyChange(event){
        this.searchKey = event.target.value;
        console.log('keyload'+event.keyCode);
        if(event.keyCode == 8){
            this.showOfferings = false;
            this.offerings = '';
            this.searchkey = '';
            this.resetValues();
        }
        
    }

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
        this.resetValues();
    }

    handlePageNextAction(){
        this.pageNumber = this.pageNumber+1;
        this.getTableData();
    }
 
   
    handlePagePrevAction(){
        this.pageNumber = this.pageNumber-1;
        this.getTableData();
    }

    getTableData(){
        this.recordsToDisplay = [];
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        var offsetTemp = (this.pageNumber-1) * this.pageSize;
        this.recordStart =   offsetTemp + 1;
        var recEndTemp = this.pageSize * this.pageNumber;
        this.recordEnd = this.totalRecords >= recEndTemp ? recEndTemp : this.totalRecords;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
        this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
        
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.offerings[i]);
            console.log('@@recordsToDisplay=='+JSON.stringify(this.recordsToDisplay));
        }

    }
     
    resetValues(){
        this.showOfferings = false;
        this.offerings = '';
        //this.searchKey = '';
        this.recordEnd = 0;
        this.recordStart = 0;
        this.pageNumber = 1;
        this.totalRecords = 0;
        this.totalPages = 0;
        this.isNext = false;
        this.isPrev = false;
    }
        
    
}