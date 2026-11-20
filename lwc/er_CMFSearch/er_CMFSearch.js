import { LightningElement,track,api} from 'lwc';
import  getCMF from '@salesforce/apex/ER_SearchCMFService.getCMF';
import  saveCMFData from '@salesforce/apex/ER_SearchCMFService.saveCMFData';
import { refreshApex } from '@salesforce/apex';	
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import mymodalpopup from "c/er_CMFSearchPopUpModal";


export default class Er_CMFSearch extends LightningElement {
cmfColumns = [
    { label: 'CMF Id', fieldName: 'DirectCustomerProfileId', initialWidth: 100, sortable: "true"},
    { label: 'Direct Customer Role', fieldName: 'DirectCustomerRelationshipFunctionalRoleNm' ,initialWidth: 130,wrapText: true,sortable: "true"},
    { label: 'CMF Name', fieldName: 'DirectCustomerProfileNm', initialWidth: 100,wrapText: true,sortable: "true" },
    { label: 'Sales Disti Chnl Code', fieldName: 'DistributionChannelCd', initialWidth: 110,wrapText: true,sortable: "true"},
   
    { label: 'Sales Disti Chnl Name', fieldName: 'DistributionChannelNm' , initialWidth: 125,wrapText: true,sortable: "true"},
    { label: 'Sales Org Code', fieldName: 'SalesOrganizationCd', initialWidth: 118,wrapText: true,sortable: "true"},
    { label: 'Sales Org Code Name', fieldName: 'GeographyCd', initialWidth: 100,wrapText: true,sortable: "true"},
   
   
   
    { label: 'Central Block', fieldName: 'CentralDeleteInd' ,wrapText: true,sortable: "true"},
    { label: 'Sales Area Order Block Code', fieldName: 'SalesAreaOrderBlockCd', /*initialWidth: 148,*/wrapText: true,sortable: "true"},
 
    { label: 'Account Group', fieldName: 'DirectCustomerRoleCd', /*initialWidth: 148,*/wrapText: true,sortable: "true"},
 
   // { label: 'Central Block', fieldName: 'CentralTransactionBlockStatusInd' , initialWidth: 131},
   /// { label: 'Account Group', fieldName: 'DirectCustomerRoleCd', /*initialWidth: 148,*/wrapText: true,sortable: "true"},
    { label: 'Address', fieldName: 'addressString',initialWidth: 130,wrapText: true,sortable: "true"},
    {
        type: "button", label: 'Associated CMF Groups',initialWidth: 140, typeAttributes: {
            label: 'View Groups',
            name: 'View Groups',
            title: 'View',
            disabled: { fieldName: 'disableButton'},
            value: 'view',
            iconPosition: 'center',
        }
    },
    
    
    
];

@api recordId;
@track cmfData=[];
@track areDetailsVisible = false;
@track searchvalue;
@track searchParameter;
@track showSpinner = false;
@track searchButtonSwitch = true;;
@track disableAdd =true;
@track disableFirst = true;
@track disableLast = false;
@track disablePrevious = true;
@track disableNext =false;
//Pagination
@track page = 1; 
@track items =[];
@track startingRecord = 1;
@track endingRecord = 0; 
@track pageSize = 100; 
@track totalRecountCount;
@track totalPage ;
@track count = 1;
@track pageSizeValue=100;
@track preSelectedRows = [];
@track pageNumRecordsMap={};
@track pageFirstRecord = 0;
@track pageLastRecord = 0;
@track selectedRows = [];
@track selectedRowsJs = [];
@track selectedRowsFullList = [];
@track dataRetrieved = false;
@track tempSearchCMFdata ;
@track selectedValue;
@track dataReturn;
@track isDataAvailable =false;
@track isInputDisabled = true;
@track sortBy;
@track sortDirection;
@track hideCheckBoxColumn = false;

get options() {
    return [
        { label: 'CMF ID', value: 'cmfid' },
        { label: 'CMF Name', value: 'cmfname' },
        { label: 'Sales Org Code', value: 'salesorgcode' },
        { label: 'Sales Disti Channel Code', value: 'salesdisticode' },
        
    ];
}

handleChange(event) {
    this.searchParameter = event.detail.value;
    this.isInputDisabled = false;
}

textinputchanged(event){
    this.searchvalue = event.detail.value;
    if(this.searchvalue == '' || this.searchvalue ==null  || this.searchvalue ==undefined){
        this.searchButtonSwitch = true;
    }
    else{
        this.searchButtonSwitch = false;
    }
    
}

showToast(msgTitle,msg,type){
    this.dispatchEvent(
        new ShowToastEvent({
            title: msgTitle,
            message: msg,
            variant: type,
            mode: 'dismissable'
        }),
    );
}

onchangeHandleSearch(event){
        if((this.tempSearchCMFdata == null || this.tempSearchCMFdata == undefined) || 
        (this.tempSearchCMFdata != null && this.tempSearchCMFdata.length == 0)){
        this.tempSearchCMFdata =  this.cmfData || [];
    }
    this.dataReturn = [];
    this.selectedValue = event.target.value;
    let currentList = this.tempSearchCMFdata;
    
    if(this.selectedValue.length > 0 && this.selectedValue!== undefined && this.selectedValue !== null){
        let concat ='';
        let cnt = 0;
        for (let index = 0; index < currentList.length; index++) {
            concat+= currentList[index].DirectCustomerProfileId;
            concat+= currentList[index].DirectCustomerProfileNm;
            concat = concat + currentList[index].SalesOrganizationCd;
            concat = concat + currentList[index].GeographyCd;
            concat = concat + currentList[index].DistributionChannelCd;
            concat = concat + currentList[index].DistributionChannelNm;
            concat = concat + currentList[index].DirectCustomerRoleCd;
            concat = concat + currentList[index].DirectCustomerRelationshipFunctionalRoleCd;
            concat = concat + currentList[index].DirectCustomerRelationshipFunctionalRoleNm;

            concat = concat.toLowerCase()+''+index;
            if(concat.includes(this.selectedValue.toLowerCase())){
                this.isDataAvailable = true;
                this.dataReturn.push(currentList[index]);
                //  cnt++;
            }
            concat=null;
        }
        if(this.dataReturn.length <= 0){
            this.isDataAvailable = false;
        }
        
    }else{
        
        
    }
    if(this.selectedValue.length === 0){
        this.isDataAvailable = true;
        this.cmfData = this.tempSearchCMFdata || [] ;
    }else{
        this.cmfData = this.dataReturn || [];
    }
}
//Gets called on click of 'Search' button on the UI
handleSearchNew(event){
    this.dataRetrieved = false;
    this.items = [];
    this.cmfData =[];
    this.selectedRowsFullList = [];
    this.selectedRecords = [];
    this.selectedRowsJs = [];
    this.pageFirstRecord = 1;
    this.pageLastRecord = 100;
    this.pageSize = 100;
    this.pageNumRecordsMap = {};
    this.page = 1;   
    if(this.recordId == null || this.recordId == '' || this.recordId == undefined){
        console.log('AT 182'+this.recordId)
        this.hideCheckBoxColumn =true;
    }
    this.handleGetRecords(0);
    
}

//Reusable function that makes an apex call to get the list of CMF records,
// first record of the current page is passed as a parameter
handleGetRecords(pageFirstRecord){
this.showSpinner = true;  
var Wrapper = [{pageFirstRec : pageFirstRecord}];
if(this.searchParameter == 'cmfid'){
    Wrapper.push({cmfId : this.searchvalue});
}
if(this.searchParameter == 'salesorgcode'){
    Wrapper.push({salesOrgCode : this.searchvalue.toUpperCase()});
}
if(this.searchParameter == 'salesdisticode'){
    Wrapper.push({salesDistiChannelCode : this.searchvalue.toUpperCase()});
}
if(this.searchParameter == 'cmfname'){
    Wrapper.push({cmfName : this.searchvalue});
}
getCMF({cmfGroupId:this.recordId,input : Wrapper})
.then(result =>{
    this.showSpinner = false;
    this.areDetailsVisible=true;
    this.items = JSON.parse(result.Elements);
    console.log('MAINDATA'+JSON.stringify(result.Elements));
    for(let i=0 ; i< this.items.length;i++){
        if(this.items[i].PhysicalStreetAddressTxt == null || (this.items[i].PhysicalStreetAddressTxt==undefined)){
            this.items[i].PhysicalStreetAddressTxt = '';
        }
        if(this.items[i].CityNm == null || (this.items[i].CityNm==undefined)){
            this.items[i].CityNm = '';
        }
        if(this.items[i].CountrySubDivisionNm == null || (this.items[i].CountrySubDivisionNm==undefined)){
            this.items[i].CountrySubDivisionNm = '';
        }
        if(this.items[i].CountryNm == null || (this.items[i].CountryNm==undefined)){
            this.items[i].CountryNm = '';
        }
        if(this.items[i].PostalCd == null || (this.items[i].PostalCd==undefined)){
            this.items[i].PostalCd = '';
        }
    }
    if(result.RecordCount != undefined){
        this.totalRecountCount = result.RecordCount;
      //  console.log('Total records'+this.totalRecountCount );
    } 
    if(result.RecordCount <= Number(0)){
        this.showToast('Error','No records returned from SAP ECC','error');
    }
    else{
    
    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);

    this.items = this.items.map(record => ({
    ...record,
   // addressString: ((record.PhysicalStreetAddressTxt !=null || record.PhysicalStreetAddressTxt !=undefined)  && (record.CityNm !=null || record.CityNm !=undefined) && (record.CountrySubDivisionNm !=null || record.CountrySubDivisionNm !=undefined) && (record.CountryNm !=null || record.CountryNm !=undefined) && (record.PostalCd !=null || record.PostalCd !=undefined)) ? (record.PhysicalStreetAddressTxt + ' ' + record.CityNm + ' ' + record.CountrySubDivisionNm + ' ' + record.CountryNm + ' ' + record.PostalCd) : '', // Concatenating address
   addressString: record.PhysicalStreetAddressTxt + ' ' + record.CityNm + ' ' + record.CountrySubDivisionNm + ' ' + record.CountryNm + ' ' + record.PostalCd , // Concatenating address
    concatedKeyField:record.DirectCustomerProfileId+''+record.SalesOrganizationCd+''+record.DistributionChannelCd+''+record.DistributionChannelNm + ' '+ record.DirectCustomerRelationshipFunctionalRoleCd +' ' + record.DirectCustomerRelationshipFunctionalRoleNm,
}));
    this.disableButtons()
    this.assignPageArrayToMap(this.pageSize,this.items);
}
//Pagination        
}).catch(error=>{
    this.showSpinner = false;
    this.areDetailsVisible=false;
    this.disableAdd = true;
    this.cmfData =[];
    //this.searchvalue = null;
    //this.value =null;
    console.log('error:'+ JSON.stringify(error));
    this.showToast('Error','SAP ECC call failed. Please try after sometime','error');
})
}

//This functions gets all data from 'handleGetRecords'... 
//and divide into 100 records each and creates a map of key as pagenumber and value as list of records
assignPageArrayToMap(defaultPageSize,currentList){
if(this.page === 1){
var j = 0;
}else{
var j = this.page - 1;    
}
if(currentList.length > 0){
    this.dataRetrieved = true;
}
for(let i=0; i < currentList.length; i += defaultPageSize){
    j += 1;
    var pageTemp = [];
    pageTemp = currentList.slice(i,i+defaultPageSize);
    if(this.pageNumRecordsMap[j] === undefined){
    this.pageNumRecordsMap[j] = this.pageNumRecordsMap[j] || [];
    this.pageNumRecordsMap[j].push(pageTemp);
    }
}
var cmfDataNew = this.pageNumRecordsMap[this.page][0];
this.cmfData = [...cmfDataNew];
//this.pageSize = this.cmfData.length; 
this.firstLastRecordsNumbers(this.page);

}

//Reusable function call from next, previous, page change functions to update list based on page change
pageNumberChangeHandle(currentPage){
// this.showSpinner = true;
if(this.pageNumRecordsMap[currentPage] !== undefined){
    this.cmfData = this.pageNumRecordsMap[currentPage][0];
    this.pageSize = this.cmfData.length;
    this.firstLastRecordsNumbers(currentPage);
    this.addSelectedRows(this.selectedRowsFullList);
}else{
    var currentPageFirstRec = (currentPage - 1)*100;
    this.handleGetRecords(currentPageFirstRec);
}
}


nextHandlerNew(){
    if((this.page < this.totalPage) && this.page !== this.totalPage){
        this.page = Number(this.page) + 1; //increase page by 1
        this.pageNumberChangeHandle(this.page);
    }     
this.disableButtons();      
}


//Called on click of 'Previous'
previousHandlerNew() {
if (this.page > 1) {
    this.page = Number(this.page) - 1; //decrease page by 1
    this.pageNumberChangeHandle(this.page);
}
this.disableButtons();
}

//Called on change of page input change
handlePageChange(event){ 
// this.showSpinner = true;
if(event.target.value && event.keyCode === 13 && event.target.value !== 0){
    this.page = event.target.value;
    if(this.page >0 && this.page<=this.totalPage){
        this.pageNumberChangeHandle(this.page); 
        this.disableButtons();
    }
    else{
        this.showToast('Error', 'Invalid Page number','Error');
    }

}
}
//Reusable function to update first and last record number of current page list
firstLastRecordsNumbers(currentPage){
    //console.log('Current'+ currentPage+'');
    if(currentPage === 1){
    this.pageFirstRecord = 1;
    this.pageLastRecord = 100;
    }
    else{
        this.pageFirstRecord = currentPage*100+1-100;
        this.pageLastRecord = currentPage*100;
    }
}

//Called on click of 'checkboxes' of each row, handles add/remove row selection.
handleRowSelection(event){
if(event.detail.config.action ==='rowDeselect'){
    let index = this.selectedRowsFullList.findIndex(object => {
        return object.concatedKeyField === event.detail.config.value;
        });
    if(index >= 0){
    this.selectedRowsFullList.splice(index,1);
    }
    let indexRowjs = this.selectedRowsJs.indexOf(event.detail.config.value);
    if(indexRowjs >= 0){
    this.selectedRowsJs.splice(indexRowjs,1);
    this.selectedRows = [...this.selectedRowsJs];
    }
}else if(event.detail.config.action === 'deselectAllRows'){
    for(let i=0 ; i < this.cmfData.length ; i++){
    let index = this.selectedRowsFullList.findIndex(object => {
        return object.concatedKeyField === this.cmfData[i].concatedKeyField;
        });
    if(index >= 0){
    this.selectedRowsFullList.splice(index,1);
    }  
    let indexRowcmfjs = this.selectedRowsJs.indexOf(this.cmfData[i].concatedKeyField);
    if(indexRowcmfjs >= 0){   
    this.selectedRowsJs.splice(indexRowcmfjs,1);
    }
    }
    this.selectedRows = [...this.selectedRowsJs];
}else if(event.detail.config.action === 'rowSelect' || event.detail.config.action === 'selectAllRows'){ 
if(event.detail.selectedRows){
for(let i=0 ; i < event.detail.selectedRows.length ; i++){
    let indexcmf = this.selectedRowsFullList.findIndex(object => {
        return object.concatedKeyField === event.detail.selectedRows[i].concatedKeyField;
        });
    if(indexcmf < 0){
    this.selectedRows.push(event.detail.selectedRows[i].concatedKeyField);
    this.selectedRowsJs.push(event.detail.selectedRows[i].concatedKeyField);
    this.selectedRowsFullList.push(event.detail.selectedRows[i]);
    
    }
}
}
}
if(this.selectedRowsFullList.length > 0){
    this.disableAdd = false;
}else{
    this.disableAdd = true;
}
}
addSelectedRows(selectedRowsFullList){
for(let i=0 ; i < selectedRowsFullList.length ; i++){
if(this.selectedRowsJs.indexOf(selectedRowsFullList[i].concatedKeyField) < 0){
    this.selectedRowsJs.push(selectedRowsFullList[i].concatedKeyField);
}
}
this.selectedRows = [...this.selectedRowsJs];
}

//Called on click of 'Add' button, makes an apex call with selected rows and upsert CMF and
handleAddNew(event){
    this.showSpinner=true;
    this.showToast('Info','Note : CMF Group & CMF association is unique ','Informational');
    console.log('At 389'+this.recordId+'-'+this.selectedRowsFullList);
    saveCMFData({bagId:this.recordId,inputData:this.selectedRowsFullList})
    .then(result=>{
        if(this.page === 1){
            this.cmfData = [];
        }else{
            this.page = 1;
        }
        this.showSpinner=false;
        
        this.selectedRowsFullList = [];
        this.selectedRecords = [];
        this.selectedRowsJs = [];
        this.cmfData = this.pageNumRecordsMap[1][0];

        this.pageFirstRecord = 1;
        this.pageLastRecord = 100;
        
        this.showToast('Success','CMF/s added to CMF Group Successfully.','success');
        setTimeout(() => {
             window.location.reload();
        }, 1000);
       

    
        

        
    })
    .catch(error=>{
        this.showSpinner=false;
        this.showToast('Error',error.body.message,'error');
    })
}
    firstPageHandler(event){
        this.page = 1;
        this.pageNumberChangeHandle(this.page);
        this.disableButtons();
    
    }
    lastPageHandler(event){
       // console.log('In last');
        this.page = this.totalPage;
        this.disableButtons();
        //console.log('Disable buttons'+this.disableFirst + this.disablePrevious+this.disableNext+this.disableLast)
        this.pageNumberChangeHandle(this.page);
    }
    disableButtons(){
        if(this.page == Number(1) && this.totalPage!=Number(1)){
            this.disablePrevious = true;
            this.disableFirst =true;
            this.disableNext =false;
            this.disableLast =false;
          //  console.log('in first'+this.page+this.totalPage);
        }
        else if(this.page == this.totalPage && this.totalPage!=Number(1) ){
            this.disableFirst =false;
            this.disableNext = true;
            this.disableLast =true;
            this.disablePrevious =false;
           // console.log('in last'+this.page+this.totalPage);
        }
        else if(this.totalPage==Number(1) ){
            this.disableFirst =true;
            this.disableLast =true;
            this.disableNext =true;
            this.disablePrevious =true;
           // console.log('in count'+this.page+this.totalPage);
        }
        else{
            this.disableFirst =false;
            this.disableLast =false;
            this.disableNext =false;
            this.disablePrevious =false;
          //  console.log('in else'+this.page+this.totalPage);
        }
    }
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.cmfData));
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
        var cmfDataNew = parseData;
        this.cmfData = [...cmfDataNew];
        
    
    } 
    handleOpenModal(event) {
        const row = event.detail.row;
        mymodalpopup.open({
            
            // `label` is not included here in this example.
            // it is set on lightning-modal-header instead
            size: 'large',
            description: 'Accessible description of modal\'s purpose',
            content: row.concatedKeyField,
        });
    } 
    connectedCallback() {
      //window.location.reload();
    }
    
    
        
}