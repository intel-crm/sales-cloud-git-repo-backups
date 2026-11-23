import { LightningElement,api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFieldsAndRecords from '@salesforce/apex/AdvancedSearchController.getFieldsAndRecords';
import getObjectLabel from '@salesforce/apex/AdvancedSearchController.getObjectName';
export default class AdvancedSearch extends LightningElement {

    @api recordId;  // record id from record detail page e.g. ''0012v00002WCUdxAAH'
    @api objectAPIName; //kind of related list object API Name e.g. 'Case'
    @api fieldSetName; // FieldSet which is defined on that above object e.g. 'CaseRelatedListFS'
    @api criteriaFieldAPIName; // This field will be used in WHERE condition e.g.'AccountId'
    @api firstColumnAsRecordHyperLink; //if the first column can be displayed as hyperlink
    @api criteriaFieldOperator;
    @api criteriaValue;
    @api paginationSize;

    @track columns;   //columns for List of fields datatable
    @track tableData;   //data for list of fields datatable
    @track isShowModal = false;
    @track objName;
    @track searchHeader;

    @track recordEnd = 0;
    @track recordStart = 0;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track loaderSpinner = false;
    @track error = null;
    @track isPrev = true;
    @track isNext = true;
    
    dataset = [];
    searchKey;
    showData = false;
    lblobjectName; //this displays the Object Name whose records are getting displayed
    
    //To get the Object Label to display in the popup header
    @wire(getObjectLabel, { objectApiName: '$objectAPIName' })
    searchHeader;
    
    
    showModalBox(){  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
        this.resetValues();
    }

    handleKeyChange(event){
        this.searchKey = event.target.value;
        if(this.searchKey.length <= 0){
            this.showData = false;
            
        }
        
    }

    search(){
        if(this.searchKey.length <= 2){
            const event = new ShowToastEvent({
                title: 'Alert!',
                message: 'Please enter more than 2 characters',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
        else {
            let firstTimeEntry = false;
        let firstFieldAPI;

        //make an implicit call to fetch records from database
        getFieldsAndRecords({ strObjectApiName: this.objectAPIName,
                                strfieldSetName: this.fieldSetName,
                                criteriaField: this.criteriaFieldAPIName,
                                criteriaFieldValue: this.recordId,
                                keyword: this.searchKey})
        .then(data=>{        
            //get the entire map
            let objStr = JSON.parse(data);   
            
            let listOfFields= JSON.parse(Object.values(objStr)[2]);
            console.log('@@listOfFields=='+JSON.stringify(listOfFields));

            //retrieve listOfRecords from the map
            let listOfRecords = JSON.parse(Object.values(objStr)[1]);
            console.log('@@listOfRecords=='+JSON.stringify(listOfRecords));
            
            //retrieve listOfRecords from the map
            let searchlst = JSON.parse(Object.values(objStr)[0]);
            console.log('@@searchlst=='+JSON.stringify(searchlst));

            let items = []; //local array to prepare columns
            let lookupFields = [];
            let lookupFieldAPIs = [];
            let searchResults = [];
            listOfFields.map(element=>{
                //it will enter this if-block just once
                if(this.firstColumnAsRecordHyperLink !=null && this.firstColumnAsRecordHyperLink=='Yes'
                                                        && firstTimeEntry==false){
                    firstFieldAPI  = element.fieldName; 
                    //perpare first column as hyperlink                                     
                    items = [...items ,
                                    {
                                        label: element.label, 
                                        fieldName: 'URLField',
                                        fixedWidth: 150,
                                        type: 'url', 
                                        typeAttributes: { 
                                            label: {
                                                fieldName: element.fieldName
                                            },
                                            target: '_blank'
                                        },
                                        sortable: true 
                                    }
                    ];
                    firstTimeEntry = true;
                } 
                else if(element.dataType == 'lookupColumn'){
                    let tempVar = element.label.replace(" ","_");
                    //lookupFields = [...lookupFields ,{label:tempVar, fieldApi: element.fieldName}];
                    var obj = {};
                    obj[tempVar] = element.fieldName;
                    //lookupFields.push(obj);
                    lookupFields.push({key:tempVar, value:element.fieldName});
                    lookupFieldAPIs = [...lookupFieldAPIs ,element.lookupNameRef];
                    console.log('$$Lkup=='+JSON.stringify(lookupFieldAPIs));
                    items = [...items ,{label: element.label, 
                        fieldName: element.lookupNameRef, typeAttributes: { label: {fieldName: element.fieldName}, target: '_blank'}}];
                }
                else {
                    items = [...items ,{label: element.label, 
                        fieldName: element.fieldName}];
                }   
            });
            console.log('##mod lookupFields=='+JSON.stringify(lookupFields));
           /* searchlst.map(element=>{
                lookupFields.map(lookupElement=>{
                    let tempVal = lookupElement.label;
                    searchlst = [...searchlst ,{tempVal: lookupElement.fieldApi}];
                });
                
            });
            console.log('##mod searchlst=='+JSON.stringify(searchlst));*/
            /*lookupFields.map(lookupElement=>{
                console.log('##mod map lkup=='+lookupElement);
                console.log('##mod map lkup1=='+JSON.stringify(lookupElement));
            });
            var searchRec = [];
            for(var i = 0; i < searchlst.length; i++){
                searchRec.push(searchlst[i]);
            //searchlst.map(element=>{
                
                for(let key in lookupFields)
                {
                    ///* NEEEEEEEEEEEEEEEEEEEEEEEED TO WORK HEREEEEEEEEEEEEE 
                    var temp = {};
                    var keyVal = lookupFields[key];
                    console.log('##mod key=='+JSON.stringify(key));
                    //console.log('##mod keyval=='+JSON.stringify(keyVal));
                    //console.log('##mod keyval1=='+JSON.stringify(lookupFields[key]));
                    //temp[key] = searchRec.map(keyVal);
                    //console.log('##mod temp=='+JSON.stringify(searchRec[lookupFields[key]]));
                    //searchRec = [...searchRec,{temp}];// searchRec.push(temp);
                } 
            }
            //});
            console.log('##mod searchlst=='+JSON.stringify(searchRec));*/
            /* Lookup fields*/
            let parseData;
            for(var i=0;i<lookupFields.length;i++){
                let apiField = lookupFields[i];
            if(searchlst){
                parseData =  JSON.parse(JSON.stringify(searchlst));
                parseData.forEach(record=>{
                    /*if(record.get(apiField)){
                        console.log('##Inside if=='+record.get(apiField));
                        record.Company_Name = record.Name;
                    }*/
                    //record.push({apiField.get('key'): apiField.get('value')}); 
                    //console.log('##parse=='+JSON.stringify(apiField[key]));
                });
            }
        }
        /*Forming Related Fields new Key Value pair and append to the existing Search results */
        if(searchlst){
        for (let i = 0; i < searchlst.length; i++) {
            for(let j = 0; j < lookupFields.length; j++){
            var  jsonkey = lookupFields[j]["key"];
            var keyValue = lookupFields[j]["value"];
            const jsonValues = keyValue.split('.');
            //console.log('$$$iterator cont=='+JSON.stringify(searchlst[i][jsonValues[0]][jsonValues[1]]));
            //if(searchlst[i].hasOwnProperty([jsonValues[0]][jsonValues[1]])) {
                if((searchlst[i][jsonValues[0]]) && (searchlst[i][jsonValues[0]][jsonValues[1]])){
                //searchlst[i] = Object.assign(searchlst[i], searchlst[i]["jsonkey"] = searchlst[i][jsonValues[0]][jsonValues[1]]);
                var obj = {};
                obj[jsonkey] = searchlst[i][jsonValues[0]][jsonValues[1]];
                searchlst[i] = Object.assign(searchlst[i], obj);
                }
              }
            }
            
          console.log('$$$Searchlst=='+JSON.stringify(searchlst));
        }
           //finally assigns item array to columns
            this.columns = items; 
            this.tableData = searchlst;
            this.totalRecords = this.tableData.length;
            
            
            //this.showData = true;
            console.log('columns',JSON.stringify(this.columns));
            console.log('listOfRecords',JSON.stringify(this.tableData));
            
            if(this.firstColumnAsRecordHyperLink !=null && this.firstColumnAsRecordHyperLink=='Yes'){
                let URLField;
                //retrieve Id, create URL with Id and push it into the array
                this.tableData = searchlst.map(item=>{
                    URLField = '/lightning/r/' + this.objectAPIName + '/' + item.Id + '/view';
                    return {...item,URLField};                     
                });
                
                //now create final array excluding firstFieldAPI
                this.tableData = this.tableData.filter(item => item.fieldPath  != firstFieldAPI);
            }
            if(this.tableData.length > 0) {
                this.showData = true;
                this.getTableData();
            } else{
                this.showData = false;
            }

            //assign values to display Object Name and Record Count on the screen
            this.lblobjectName = this.objectAPIName;
            this.error = undefined;   
        })
            .catch(error => {
                this.error = error;
                console.log('error',error);
                this.tableData = undefined;
                this.lblobjectName = this.objectAPIName;
            });
        }
    }

    getTableData(){
        this.dataset = [];
        this.totalPages = Math.ceil(this.totalRecords / this.paginationSize);
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        var offsetTemp = (this.pageNumber-1) * this.paginationSize;
        this.recordStart =   offsetTemp + 1;
        var recEndTemp = this.paginationSize * this.pageNumber;
        this.recordEnd = this.totalRecords >= recEndTemp ? recEndTemp : this.totalRecords;
        this.totalPages = Math.ceil(this.totalRecords / this.paginationSize);
        this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
        this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.paginationSize);
        
        for (let i = (this.pageNumber - 1) * this.paginationSize; i < this.pageNumber * this.paginationSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.dataset.push(this.tableData[i]);
            
        }

    }

    handlePageNextAction(){
        this.pageNumber = this.pageNumber+1;
        this.getTableData();
    }
 
   
    handlePagePrevAction(){
        this.pageNumber = this.pageNumber-1;
        this.getTableData();
    }

    resetValues(){
        this.showData = false;
        this.dataset = [];
        this.columns = [];
        this.searchKey = '';
        this.recordEnd = 0;
        this.recordStart = 0;
        this.pageNumber = 0;
        this.totalRecords = 0;
        this.totalPages = 0;
        this.isNext = false;
        this.isPrev = false;
    }

}