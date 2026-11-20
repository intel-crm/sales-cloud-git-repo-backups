//old
import { api, LightningElement, track, wire } from 'lwc';
import getEditableDataTable from '@salesforce/apex/Core_MDF_ExtendedDataTable_Controller.getEditableDataTable';
import getReadOnlyDatatable from '@salesforce/apex/Core_MDF_ExtendedDataTable_Controller.getReadOnlyDatatable';
import dynamicUpdateRecords from '@salesforce/apex/Core_MDF_ExtendedDataTable_Controller.dynamicUpdateRecords';
import fetchSampleRecs1 from '@salesforce/apex/Core_MDF_ExtendedDataTable_Controller.fetchSampleRecs1';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { loadStyle } from 'lightning/platformResourceLoader';
import leaflet from '@salesforce/resourceUrl/CustomDataTable';
/*const columns = [
    { label: 'Name', fieldName: 'Name', sortable: true, editable: true,initialWidth:300 },
    { label: 'Industry', fieldName: 'Industry', editable: true },
    {
    label: 'Rating', type: 'picklist', fieldName: 'Rating', sortable: true,editable: true, typeAttributes: {
            label : 'Choose Rating',
            placeholder: 'Choose rating',
            options: [
                { label: 'Hot', value: 'Hot' },
                { label: 'Warm', value: 'Warm' },
                { label: 'Cold', value: 'Cold' },
            ],
            parentrecord: { fieldName: 'Id' },
            fieldnameapi: 'Rating',
            class : "slds-truncate"
        },
        cellAttributes:{
            class : "slds-truncate"
        }
    },
    {
        label: 'Parent', fieldName: 'ParentId' , type: 'lookup', editable: true,typeAttributes: {
            object: "Account",
            icon: "standard:account",
            label: "Account",
            placeholder: 'Select Parent Account',
          //  fields: ["Name", "Rating", "AccountNumber"],//fields SOSL used to query
          fields: ["Name"],//fields SOSL used to query
            //displayFields : 'Name, Rating, AccountNumber',// fields seen in dropdown
            displayFields : 'Name,Name',// fields seen in dropdown

            valueId: { fieldName: 'ParentId' },
            valueName : { fieldName: 'ParentId' },
            currentRecordId : { fieldName: 'Id' },
        }
    }
];*/
// const columnsSharingTable = [
//     { label: 'UserOrGroupName', fieldName: 'UserOrGroup.Name', type: 'text',editable: false },
//     { label: 'AccessLevel', fieldName: 'AccessLevel', type: 'text',editable: false },
//     { label: 'RowCause', fieldName: 'RowCause', type: 'text',editable: false },
//     //{ label: 'ParentId', fieldName: 'ParentId', type: 'Id',editable: false },
   
// ];
const columns = [
   // { label: 'Name', fieldName: 'Name', sortable: true,initialWidth:300 },
    {label: 'Account', fieldName: 'ChannelPartnerId' , type: 'lookup', editable: true,initialWidth:300,typeAttributes: {
            objectname: "Account",
            icon: "standard:account",
            label: "Account",
            placeholder: 'Select Account',
          //  fields: ["Name", "Rating", "AccountNumber"],//fields SOSL used to query
          fields: ["Name"],//fields SOSL used to query
            //displayFields : 'Name, Rating, AccountNumber',// fields seen in dropdown
            displayFields : 'Name,Name',// fields seen in dropdown
            parentAPIName: 'ChannelPartnerId',// to know field of lookup,while saving used

            valueId: { fieldName: 'ChannelPartnerId' },
            valueName : { fieldName: 'ChannelPartnerId' },
            currentRecordId : { fieldName: 'Id' },
        }
    },
    { label: 'Priority', fieldName: 'Core_MDF_Priorities__c',initialWidth:300, editable: true },
    {
        label: "Start Date",
        fieldName: "Core_MDF_Start_Date__c",
        type: "date",editable: true,initialWidth:300

    },
    {
        label: "End Date",
        fieldName: "Core_MDF_End_Date__c",
        type: "date",initialWidth:300,editable: true

    },
    {label: 'Owner', fieldName: 'OwnerId' , type: 'lookup',initialWidth:300, editable: true,typeAttributes: {
        objectname: "User",
        icon: "standard:account",
        label: "Owner",
        placeholder: 'Select Owner',
      //  fields: ["Name", "Rating", "AccountNumber"],//fields SOSL used to query
      fields: ["Name"],//fields SOSL used to query
        //displayFields : 'Name, Rating, AccountNumber',// fields seen in dropdown
        displayFields : 'Name,Name',// fields seen in dropdown
        parentAPIName: 'OwnerId',// to know field of lookup,while saving used
        valueId: { fieldName: 'OwnerId' },
        valueName : { fieldName: 'Owner.Name' },
        currentRecordId : { fieldName: 'Id' },
    }
},


];
const sharingCol=
[
    {label:'Sharing Details',type: "button",initialWidth:190, typeAttributes: {  
        label: 'Sharing Details',  
        name: 'View',  
        title: 'View',  
        disabled: false,  
        value: 'view',  
        iconPosition: 'left' ,
        iconName: 'utility:archive'
        }
    },
   // { label: 'Result', fieldName: 'result', sortable: true, editable: false,initialWidth:200 }
];
//label: 'Quote',fieldName: 'QuoteLink',type: 'url',typeAttributes: {label: {fieldName: 'QuoteName'},target: '_self'},sortable: true
const idCol= {  label: 'Id', fieldName: 'IdLink', type: 'url',sortable: true, editable: false,initialWidth:200,typeAttributes: {label: {fieldName: 'Id'},target: '_self'} }
const resultCol= {  label: 'Result', fieldName: 'result', sortable: true, editable: false,initialWidth:200 }
export default class Core_MDF_CCP_extendedDataTable extends LightningElement {

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
  //  data;
    isLoadingTable = true;
    isLoading = true;
    errorChange = true;
    isToastInfo=false;
    wiredRecords;
    columns = columns;
    columnsSharingTable;
    ops;
    @api objectName = 'test';
    @api incident='test1';
    @api selectedIds = [];
    @api selectedFields = [];
    @track accounts;
    @track error;
    @track isError = false;
    @track errorMessageOnUpdate='';
    @track draftValues = [];
    @track shareObjectAPIName ;
    @track recordIdToReasonMap;
    //sharing variables
    @track sharingMapValues;
    @track sharingReadOnlyData;
    @track sharingEditData;
    @track isShowReadOnly =false;
    @track isShowEditOnly = false;

    @track DataTableResponseWrappper;
    @track ReadOnlyDataTableResponseWrappper;
    @track dataCols;
    @track readOnlydataCols;
    @track finalSObjectDataList;
    @track readOnlyfinalSObjectDataList;
    @track suppressFlag = true;
    @track showRowNumberCol = false;
    @track sharingfinalmap;
    
    rowId;
    connectedCallback(){
        Promise.all([
            loadStyle(this, leaflet)
        ]).then(() => {
            console.log('OUTPUT : '+'Style Loaded');
        });
       console.log('Inside connected callback');
       console.log('Inside connectedApiobjectName'+this.objectName);
       console.log('Inside connectedApiSelectedFields'+(this.selectedFields));
       console.log('Inside connectedApiSelectedIds'+(this.selectedIds));
       console.log('Inside connectedIncident is '+(this.incident));
       this.getReadOnlyDatatable();
       this.isLoadingTable = true;
				console.time("EditMethod");
    }
    //Function that calls getReadOnlyDatatable apex method and stores the return result
    getReadOnlyDatatable(){
				console.time("ReadMethod");
        getReadOnlyDatatable({objectName : this.objectName,selectedFields : this.selectedFields,selectedIds : this.selectedIds})  
        .then(result => {
						console.timeEnd("ReadMethod");
            let data =JSON.parse(JSON.stringify(result));
            let sObjectRelatedFieldListValues = [];
            this.ops=data;
            console.log('getReadOnlyDatatable-->data'+JSON.stringify(data.lstDataTableData));
            console.log('Sharing Columns'+JSON.stringify(data.lstSharingDataTableColumns));
            this.columnsSharingTable = JSON.parse(JSON.stringify(data.lstSharingDataTableColumns));
           for (let row of data.lstDataTableData) 
           {
                const finalSobjectRow = {}
                let rowIndexes = Object.keys(row); 
                rowIndexes.forEach((rowIndex) => 
                {
                    const relatedFieldValue = row[rowIndex];
                    if(relatedFieldValue.constructor === Object)
                    {
                        this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)        
                    }
                    else
                    {
                        finalSobjectRow[rowIndex] = relatedFieldValue;
                    }
                });
                finalSobjectRow.IdLink ='/'+ row["Id"];
                sObjectRelatedFieldListValues.push(finalSobjectRow);
            }
            //sharing table
           
            this.sharingMapValues = new Map(Object.entries(data.lstSharingTableData));
            console.log('this.sharingMapValues', this.sharingMapValues);

            this.ReadOnlyDataTableResponseWrappper = data;
            console.log('getReadOnlyDatatable-->lstDataTableColumns:'+JSON.stringify(data.lstDataTableColumns));
            this.readOnlydataCols = JSON.parse(JSON.stringify(data.lstDataTableColumns));
            this.shareObjectAPIName =data.shareObjectAPIName;
            //add sharing coloumn
            this.readOnlydataCols.unshift(idCol);
            this.readOnlydataCols.push(...sharingCol);
            this.readOnlyfinalSObjectDataList = sObjectRelatedFieldListValues;
            this.isLoadingTable = false;
        })
        .catch(error => {
            console.log(error);
            alert('error while loading datatable.');
        });
    }
    @wire(getEditableDataTable, { objectName: '$objectName', selectedFields:'$selectedFields', selectedIds:'$selectedIds'})
    wiredData( value) {
        this.wiredRecords = value; // track the provisioned value
        const { data, error } = value;
        if (data) {
						console.timeEnd("EditMethod");
            let sObjectRelatedFieldListValues = [];
            
           for (let row of data.lstDataTableData) 
           {
                const finalSobjectRow = {}
                let rowIndexes = Object.keys(row); 
                rowIndexes.forEach((rowIndex) => 
                {
                    const relatedFieldValue = row[rowIndex];
                    if(relatedFieldValue.constructor === Object)
                    {
                        this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)        
                    }
                    else
                    {
                        finalSobjectRow[rowIndex] = relatedFieldValue;
                    }
                });
                if(this.isError == true){
                    if(this.recordIdToReasonMap.has(row["Id"])){
                        finalSobjectRow.result = this.recordIdToReasonMap.get(row["Id"]);
                    }else{
                        finalSobjectRow.result = '';
                    }
                }
                finalSobjectRow.IdLink ='/'+ row["Id"];
                sObjectRelatedFieldListValues.push(finalSobjectRow);
            }
            this.DataTableResponseWrappper = data;
           
            this.dataCols = JSON.parse(JSON.stringify(data.lstDataTableColumns));
            //add sharing coloumn
            console.log('this.sharingCol'+ sharingCol);
            this.dataCols.push(...sharingCol);
            this.dataCols.unshift(idCol);
            this.dataCols.unshift(resultCol);
            
            this.finalSObjectDataList = sObjectRelatedFieldListValues;
            console.log('finalSObjectDataList-->Obj'+ this.finalSObjectDataList);
            console.log('finalSObjectDataList-->Obj'+JSON.stringify( this.finalSObjectDataList));
            console.log( this.DataTableResponseWrappper);
           
         
        } else if (error) {
            console.error('Error:', error);
            this.error = error
        }

        console.log( this.dataCols);
        console.log(' this.dataCols'+JSON.stringify( this.dataCols));


        //rec[strindData["parentAPIName"]]=strindData["recordId"];
        //this.columns.push(sharingCol);
        console.log('ApiobjectName'+this.objectName);
        console.log('ApiSelectedFields'+(this.selectedFields));
        console.log('ApiSelectedIds'+(this.selectedIds));
        this.isLoading = false;
        this.isError = false;
        //this.errorChange = true;
    };

    //flattens reference fields to incorporate it in dataTable
    _flattenTransformation = (fieldValue, finalSobjectRow, fieldName) => 
    {        
        let rowIndexes = Object.keys(fieldValue);
        rowIndexes.forEach((key) => 
        {
            let finalKey = fieldName + '.'+ key;
            finalSobjectRow[finalKey] = fieldValue[key];
        })
    }

    
    //calls on row selection:
    rowSelection(evt){}
    handleLookup(event){
        event.stopPropagation(); 
        //this.suppressFlag = false;
        let strindData =  JSON.parse(JSON.stringify(event.detail.data));
        console.log('strindData2222222'+strindData);
        console.log(strindData);
        if(this.draftValues  != undefined &&   this.draftValues  != null ){
            let recFound= false;
            this.draftValues.forEach((item)=>{
                if(item.Id == strindData["currentRecordId"]){
                    recFound=true;
                    //item[strindData["parentAPIName"]] = strindData["recordId"];
                    item[strindData["parentAPIName"]] = strindData["recordId"]?strindData["recordId"]:"";
                }
            });
            if(!recFound){
                let rec={};
                rec["Id"]=strindData["currentRecordId"];
                //rec[strindData["parentAPIName"]]=strindData["recordId"];
                rec[strindData["parentAPIName"]] = strindData["recordId"]?strindData["recordId"]:"";
                this.draftValues.push(rec);
            }
        } else{
            this.draftValues=[];
            let rec={};
            rec["Id"]=strindData["currentRecordId"];
        // rec[strindData["parentAPIName"]]=strindData["recordId"];
            rec[strindData["parentAPIName"]] = strindData["recordId"]?strindData["recordId"]:"";
            this.draftValues.push(rec);
        }
        
        window.console.log(' this.draftValues123 ', JSON.stringify(this.draftValues) );     
        window.console.log(' strindData Lookup ', strindData );
    }

    handlePickListChanged(event){
        event.stopPropagation();
      //  this.suppressFlag = false;
       // let strindData =  JSON.stringify(event.detail.data);
       
        let strindData =  JSON.parse(JSON.stringify(event.detail.data));
        console.log('strindData2222222'+strindData);
        console.log(strindData);
        if(this.draftValues  != undefined &&   this.draftValues  != null ){
            let recFound= false;
            this.draftValues.forEach((item)=>{
                if(item.Id == strindData["relatedRecord"]){
                    recFound=true;
                    //item[strindData["parentAPIName"]] = strindData["recordId"];
                    item[strindData["fieldnameapi"]] = strindData["selectedValue"]?strindData["selectedValue"]:"";
                }
            });
            if(!recFound){
                let rec={};
                rec["Id"]=strindData["relatedRecord"];
                //rec[strindData["parentAPIName"]]=strindData["recordId"];
                rec[strindData["fieldnameapi"]] = strindData["selectedValue"]?strindData["selectedValue"]:"";
                this.draftValues.push(rec);
            }
        } else{
            this.draftValues=[];
            let rec={};
            rec["Id"]=strindData["relatedRecord"];
        // rec[strindData["parentAPIName"]]=strindData["recordId"];
            rec[strindData["selectedValue"]] = strindData["selectedValue"]?strindData["selectedValue"]:"";
            this.draftValues.push(rec);
        }
        console.log(' picklist data ', strindData );
    }

    handleMultiselectPicklistChanged(event){
        event.stopPropagation();
      //  this.suppressFlag = false;
       // let strindData =  JSON.stringify(event.detail.data);
       
        let strindData =  JSON.parse(JSON.stringify(event.detail.data));
        console.log('strindDataMultiselect'+strindData);
        console.log(strindData);
        if(this.draftValues  != undefined &&   this.draftValues  != null ){
            let recFound= false;
            this.draftValues.forEach((item)=>{
                if(item.Id == strindData["relatedRecord"]){
                    recFound=true;
                    //item[strindData["parentAPIName"]] = strindData["recordId"];
                    item[strindData["fieldnameapi"]] = strindData["selectedValue"]?strindData["selectedValue"]:"";
                }
            });
            if(!recFound){
                let rec={};
                rec["Id"]=strindData["relatedRecord"];
                //rec[strindData["parentAPIName"]]=strindData["recordId"];
                rec[strindData["fieldnameapi"]] = strindData["selectedValue"]?strindData["selectedValue"]:"";
                this.draftValues.push(rec);
            }
        } else{
            this.draftValues=[];
            let rec={};
            rec["Id"]=strindData["relatedRecord"];
        // rec[strindData["parentAPIName"]]=strindData["recordId"];
            rec[strindData["selectedValue"]] = strindData["selectedValue"]?strindData["selectedValue"]:"";
            this.draftValues.push(rec);
        }
        console.log(' multiselectPicklist data ', strindData );
    }

    handleSelection(event){

    }
    handleCellChange(event) {
        event.preventDefault();
        let draftValuesTemp = event.detail.draftValues;
        draftValuesTemp.forEach((updateItems) => {
            this.updateDraftValues(updateItems);
        });
    }
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
        copyDraftValues.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
        console.log('UpdatedDraft:'+JSON.stringify(this.draftValues));
    }

    handleSave(event) {
        let tableSelectedData = [];
        let draftValuesFinal = [];
        this.isError = false;
        this.isToastInfo =false;
        this.errorMessageOnUpdate ='';//blanking out previous errors
        let isDataChange = false;
        tableSelectedData = this.template.querySelector('c-core_-m-d-f_-c-c-p_lwc-datatable').getSelectedRows();
        console.log('tableSelecteddata'+JSON.stringify(tableSelectedData));
        console.log(' event.detail.draftValues'+JSON.stringify(this.draftValues));
       /* const recordInputs =  event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });*/
        
        if(tableSelectedData.length!=0){
            //filter based on selection
            tableSelectedData.forEach((itemSelected) => {
                isDataChange = false; 
                this.draftValues.forEach((itemDraft) =>{
                    if (itemSelected.Id === itemDraft.Id) {
                        for (const key in itemDraft) {
                            if(itemSelected[key] != itemDraft[key]){
                                isDataChange = true; 
                            }
                            console.log('itemSelected[key]: '+itemSelected[key]+'itemDraft[key]:'+itemDraft[key]);
                        }
                        console.log('isDataChange:'+isDataChange);
                        if(isDataChange == true){
                            draftValuesFinal.push(itemDraft);
                        }
                        
                    }
                })
            });
            console.log('draftValuesFinal'+JSON.stringify(draftValuesFinal));
            draftValuesFinal = JSON.parse(JSON.stringify(draftValuesFinal));
            this.isLoading = true;
            //-----------
           /* const recordInputs = draftValuesFinal.slice().map(draft => {
                const fields = Object.assign({}, draft);
                return { fields };
            });


            console.log('recordInputs222'+JSON.stringify(recordInputs));
            const promises = recordInputs.map(recordInput => updateRecord(recordInput));
            console.log('promises');
            this.isLoading = true;
            Promise.all(promises).then(record => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'All Record updated',
                        variant: 'success'
                    })
                );
                this.draftValues = [];
                console.log('promises.....Then');
                this.suppressFlag = true;
                return refreshApex(this.wiredRecords);
            }).catch(error => {
                let errors = error.body.output.errors;
                let fieldErrors = error.body.output.fieldErrors;
                this.draftValues = [];
                console.error(' Error Occured While Uploading Records ', error);
                //this.errorMessageOnUpdate = ''+error.body.output.errors[0].errorCode+': '+error.body.output.errors[0].message;
                
                //added to capture all kinds of error
                if (error.body.output.errors != null) {
                    // Loop & Display Errors
                    for (let index = 0; index < error.body.output.errors.length; index++) {
                        console.log('Displaying Errors');

                        this.errorMessageOnUpdate += error.body.output.errors[index].errorCode + ' - ' + error.body.output.errors[index].message+'\n';
                    }
                }
                if (error.body.output.fieldErrors != null) {
                    console.log('Displaying Field Errors');
                    for (let prop in fieldErrors) {
                        console.log(Object.keys(fieldErrors));
                        let val = Object.values(fieldErrors);
                        console.log(val[0][0]["message"]);

                        this.errorMessageOnUpdate += val[0][0]["errorCode"]+' - '+val[0][0]["message"];
                    }
                } else {
                    console.log('Displaying Generic Errors')

                    this.errorMessageOnUpdate +=error.body.message;
                }
                this.isError = true;
            })
            .finally( () => {
                this.isLoading = false;
            });*/
            this.errorChange = true;
            dynamicUpdateRecords({records : draftValuesFinal,incidentno : this.incident, ObjectName : this.objectName})  
                        .then(result=>{ 
                            /*this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Info',
                                    message: 'Some error occured,Please refer to the result coloumn',
                                    variant: 'info'
                                })
                            );*/
                            let mapResult = result.recordIdToReasonMap;
                            let isBatchRun = result.isBatchRun;
                            console.log('isBatchRun:',isBatchRun);
                            if(isBatchRun == false){

                                
                                this.recordIdToReasonMap = new Map(Object.entries(mapResult));
                            // this.recordIdToReasonMap = new Map(result);
                                let it = this.recordIdToReasonMap.keys(); 
                            
                                let rowIndexes = it.next();
                                console.log('rowIndexes',rowIndexes);
                            
                                while (!rowIndexes.done) {
                                    if(this.recordIdToReasonMap.has(rowIndexes.value)){
                                    let errorMsg = this.recordIdToReasonMap.get(rowIndexes.value);
                                    console.log('insideerrorMsg'+errorMsg)
                                        if(errorMsg  == 'Success'){
                                            console.log('insideErrorChANGE')
                                            this.errorChange = false;
                                        }else{
                                            this.isToastInfo = true;
                                        }
                                    }
                                    rowIndexes = it.next();
                                }
                                //added for toast event..
                                console.log('this.isToastInfo'+this.isToastInfo)
                                if(this.isToastInfo == true){
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Info',
                                            message: 'Some records failed to update,Please refer to the result column',
                                            variant: 'info'
                                        })
                                    );
                                }else{
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Success',
                                            message: 'All records updated successfully',
                                            variant: 'success'
                                        })
                                    );
                                }
                                this.draftValues = [];
                                console.log('promises.....Then',this.recordIdToReasonMap);
                                this.suppressFlag = true;
                                this.isError = true;
                                //this.isLoading = false;
                                
                                if(this.errorChange == false){
                                    refreshApex(this.wiredRecords);
                                }else{
                                    let sObjectRelatedFieldListValues = [];
                
                                    for (let row of this.finalSObjectDataList) 
                                    {
                                        const finalSobjectRow = {}
                                        let rowIndexes = Object.keys(row); 
                                        rowIndexes.forEach((rowIndex) => 
                                        {
                                        const relatedFieldValue = row[rowIndex];
                                        finalSobjectRow[rowIndex] = relatedFieldValue; 
                                        });
                                        
                                        if(this.recordIdToReasonMap.has(row["Id"])){
                                            finalSobjectRow.result = this.recordIdToReasonMap.get(row["Id"]);
                                        }else{
                                            finalSobjectRow.result = '';
                                        }

                                        sObjectRelatedFieldListValues.push(finalSobjectRow);
                                    }
                                    this.finalSObjectDataList = sObjectRelatedFieldListValues;
                                    this.isLoading = false;
                                    this.isError =false;
                                }
                            }else{
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Info',
                                        message: 'More than 50 records were proccesed.You will receive an email once all the batches are completed.',
                                        variant: 'info',
                                        mode:'sticky'
                                    })
                                );
                                this.draftValues = [];
                                let sObjectRelatedFieldListValues = [];
                                sObjectRelatedFieldListValues = this.finalSObjectDataList;
                                this.finalSObjectDataList = sObjectRelatedFieldListValues;
                                this.isLoading = false;
                                //this.isError =false;
                            }
                           //comment here
                        //    this.draftValues = [];
                        //    console.log('promises.....Then',this.recordIdToReasonMap);
                        //    this.suppressFlag = true;
                        //    this.isError = true;
                        //    //this.isLoading = false;
                        //    refreshApex(this.wiredRecords);
                           
                        })  
                        .catch(error=>{  
                            console.log('Error Updating Records:',error);
                            this.isLoading = false;
                            
                        }) 
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select atleast one record for editing',
                    variant: 'error'
                })
            );
            
        }

    }
    //onClick of sharing details button readonly table
    callRowActionReadOnly(event){
        console.log('InsidereadOnly')
        this.isShowReadOnly =false;
        const recId =  event.detail.row.Id;  
        this.rowId = event.detail.row.Id; 
        const actionName = event.detail.action.name;  
        console.log(recId);
        console.log(actionName);
     
        if ( actionName === 'View' ) {  
            let sObjectRelatedFieldListValues = [];
            //this.sharingReadOnlyData=this.sharingMapValues.get(recId);
            for (let row of this.sharingMapValues.get(recId)) 
            {
                 const finalSobjectRow = {}
                 let rowIndexes = Object.keys(row); 
                 rowIndexes.forEach((rowIndex) => 
                 {
                     const relatedFieldValue = row[rowIndex];
                     if(relatedFieldValue.constructor === Object)
                     {
                         this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)        
                     }
                     else
                     {
                         finalSobjectRow[rowIndex] = relatedFieldValue;
                     }
                 });
                 sObjectRelatedFieldListValues.push(finalSobjectRow);
             }
            this.sharingReadOnlyData = sObjectRelatedFieldListValues;
            this.isShowReadOnly =true;
  
        }
    }
    //onClick of sharing details button edit table
    callRowAction( event ) {  
          
        this.isShowEditOnly =false;
        const recId =  event.detail.row.Id;  
        this.rowId = event.detail.row.Id; 
        const actionName = event.detail.action.name; 
        let sObjectRelatedFieldListValues = []; 
        console.log(recId);
        console.log(actionName);
        if ( actionName === 'View' ) {  
            fetchSampleRecs1({ObjectName : this.objectName,selectedRecId : this.selectedIds}) 
            .then(result =>{
               // this.ops = result;
                //console.log('Finally',ops);
                let temp = JSON.parse(JSON.stringify(result));
                let mapvalues = new Map(Object.entries(temp));
                console.log('Data',mapvalues);
               // this.sharingEditData=mapvalues.get(recId);
                let sObjectRelatedFieldListValues = [];
            
            for (let row of mapvalues.get(recId)) 
            {
                console.log("row is "+JSON.stringify(row));
                 const finalSobjectRow = {}
                 let rowIndexes = Object.keys(row); 
                 console.log("rowindexes are "+rowIndexes);
                 rowIndexes.forEach((rowIndex) => 
                 {
                     const relatedFieldValue = row[rowIndex];
                     if(relatedFieldValue.constructor === Object)
                     {
                         this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)        
                     }
                     else
                     {
                         finalSobjectRow[rowIndex] = relatedFieldValue;
                     }
                 });
                 sObjectRelatedFieldListValues.push(finalSobjectRow);
             }
             this.sharingEditData = sObjectRelatedFieldListValues;
                this.isShowEditOnly =true;
            })
            .catch(error =>{
                this.errorMsg = error;
                console.log('Error',this.errorMsg);
            })

  
        }
  
    }
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.finalSObjectDataList];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.finalSObjectDataList = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    sortBy(field, reverse, primer) {
        const key = primer
        ? function(x) {
            return primer(x[field]);
        }
        : function(x) {
            return x[field];
        };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    handleDownloadClick(event) {
        console.log("Readonlycols are "+JSON.stringify(this.readOnlydataCols));
        let fincols=this.readOnlydataCols;
        console.log("")
        let readonly=JSON.parse(JSON.stringify(this.readOnlyfinalSObjectDataList));
        this.downloadCSVFile(fincols,readonly,1);
    }
    handleDownloadClickSave(event) {
        let fincols=this.columnsSharingTable;
        console.log("Sharing map values ",(this.sharingMapValues));
        let sObjectRelatedFieldListValues = [];
        let it = this.sharingMapValues.keys();
        let rowIndexes = it.next();
        console.log('rowIndexes',rowIndexes);
       while (!rowIndexes.done) {
        for (let row of this.sharingMapValues.get(rowIndexes.value)) 
        {
            console.log("row is "+ JSON.stringify(row));
             const finalSobjectRow = {}
             let rowIndexes = Object.keys(row); 
             rowIndexes.forEach((rowIndex) => 
             {
                 const relatedFieldValue = row[rowIndex];
                 if(relatedFieldValue.constructor === Object)
                 {
                     this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)        
                 }
                 else
                 {
                     finalSobjectRow[rowIndex] = relatedFieldValue;
                 }
             });
             sObjectRelatedFieldListValues.push(finalSobjectRow);
         }
        rowIndexes = it.next();
    }
    console.log('sObjectRelatedFieldListValues22',sObjectRelatedFieldListValues);
     this.downloadCSVFile(fincols,sObjectRelatedFieldListValues,2);
     
    }
    handleDownloadEdit(event) {
        console.log("Editable cols are "+JSON.stringify(this.dataCols));
        let fincols=this.readOnlydataCols;
        let readonly=JSON.parse(JSON.stringify(this.finalSObjectDataList));
        console.log("Editable table data are ",readonly);
        this.downloadCSVFile(fincols,readonly,1);
        //this.handleDownloadEditSave();
    }
    handleDownloadEditSave()
    {
        console.log("ENTERED DOWNLOAD EDIT SAVE");
        let fincols=this.columnsSharingTable;
        let sObjectRelatedFieldListValues = [];


        fetchSampleRecs1({ObjectName : this.objectName,selectedRecId : this.selectedIds}) 
        .then(result =>{
           // this.ops = result;
            //console.log('Finally',ops);
            let temp = JSON.parse(JSON.stringify(result));
            console.log("rsult is "+temp);
            let mapvalues = new Map(Object.entries(temp));
            console.log('Data',mapvalues);
           // this.sharingEditData=mapvalues.get(recId);
           let it = this.sharingMapValues.keys();
        let rowIndexes = it.next();
            console.log('rowIndexes',rowIndexes);
           while (!rowIndexes.done) {
            for (let row of mapvalues.get(rowIndexes.value)) 
            {
            console.log("row is "+JSON.stringify(row));
             const finalSobjectRow = {}
             let rowIndexes = Object.keys(row); 
             console.log("rowindexes are "+rowIndexes);
             rowIndexes.forEach((rowIndex) => 
             {
                 const relatedFieldValue = row[rowIndex];
                 if(relatedFieldValue.constructor === Object)
                 {
                     this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)        
                 }
                 else
                 {
                     finalSobjectRow[rowIndex] = relatedFieldValue;
                 }
             });
             sObjectRelatedFieldListValues.push(finalSobjectRow);
             
            
         }
        
        rowIndexes = it.next();
           }
           console.log("downlaodle data is ",sObjectRelatedFieldListValues);
        this.downloadCSVFile(fincols,sObjectRelatedFieldListValues,2);
        })
        .catch(error =>{
            this.errorMsg = error;
            console.log('Error',this.errorMsg);
        })
       // clearTimeout(this.timeoutId); // no-op if invalid id

    }

    

    downloadCSVFile(fincols,datatablevalues,x){
        console.log('Entered downloadCSV');
        let rowEnd = '\n';
        let csvString = '';
        let downloadElement = document.createElement('a');
        let rowData = new Set();
        if(x==1)
        {
         for(let i=0;i<fincols.length-1;i++)
         {
             rowData.add(fincols[i].fieldName);
         }
         downloadElement.download = 'CCP_readonlytable.csv';
        }
        else
        {
            for(let i=0;i<fincols.length;i++)
         {
             rowData.add(fincols[i].fieldName);
         }
         downloadElement.download = 'CCP_sharingtable.csv';
        }
        rowData = Array.from(rowData);
        console.log("rowdata is "+rowData);
        csvString += rowData.join(',');
        csvString += rowEnd;
        for(let i=0; i < datatablevalues.length; i++){
            let colValue = 0;
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    let rowKey = rowData[key];
                    if(colValue > 0){
                        csvString += ',';
                    }
                    let value = datatablevalues[i][rowKey] === undefined ? '' :datatablevalues[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
}