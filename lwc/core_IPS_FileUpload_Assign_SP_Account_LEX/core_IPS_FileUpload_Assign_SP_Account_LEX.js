import { LightningElement,track,api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import saveRecords from '@salesforce/apex/Core_IPS_File_Upload_Console_Cont_LEX.saveRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkStatus from '@salesforce/apex/Core_IPS_File_Upload_Console_Cont_LEX.checkStatus';
import {refreshApex} from '@salesforce/apex';


export default class Core_IPS_FileUpload_Assign_SP_Account_LEX extends  NavigationMixin(LightningElement) {


    @api recordId;
    @track searchProduct =[];
    @track searchAccount=[];
    @track ProductDetails =[];
    @track AccountDetails = [];
    @track showProducts = false;
    @track showAccounts = false;
    @track spinner = false;
    @track selectedList =[];
    @track listOfRows;
    mapp = new Map();
    tempVarAcc = undefined;
    tempVarSp;
    records = [];
    nodelete = false;
    checkcndtn ;
    statusIncplte=false;
    expdate=false;
    connectedCallback() {
        
        this.initData();

    }
    
        @wire(checkStatus,{fileuploadId: '$recordId'})
        checkConditions(result){
            if(result.data){
                console.log('checkstatus-data',result.data);
                if(result.data =='dateexpired'){
                    this.checkcndtn = true;
                    this.expdate = true;
                }
                else if(result.data == 'statusIncomplete'){
                    this.checkcndtn = true;
                    this.statusIncplte = true;
                }
                else if(result.data == 'true'){
                    this.checkcndtn = false;
                }
        }
        else{
            console.log('Error=');
        }
    }
            
        
    
    initData() {
        let listOfRows = [];
        this.createRow(listOfRows);
        this.listOfRows = listOfRows;
        if(this.listOfRows.index == 1){
            this.nodelete = true;
        }
    }

    createRow(listOfRows) {
        let rows = {};
        if(listOfRows.length > 0) {
            rows.index = listOfRows[listOfRows.length - 1].index + 1;
            if(rows.index != 1 ){
                rows.nodelete = false;
                this.listOfRows[0].nodelete = false;
            }
        } else {
            rows.index = 1;
            rows.nodelete = true;
        }
        
        listOfRows.push(rows);
    }

    /**
     * Adds a new row
     */
    addNewRow() {
        this.createRow(this.listOfRows);
        if(this.tempVarAcc == undefined && this.tempVarSp != undefined){
           let  obj ={
                'Core_Account__c': null,
                'Core_Supported_Product__c': this.tempVarSp
            }
            this.records.push(obj);
        }
        this.tempVarAcc = undefined;
        this.tempVarSp = undefined;
    }

    /**
     * Removes the selected row
     */
    removeRow(event) {
        let toBeDeletedRowIndex = event.target.name;
        console.log('delete row',toBeDeletedRowIndex);
        let listOfRows = [];
        let tempRecs = [];
        for(let i = 0; i < this.listOfRows.length; i++) {
            let tempRecord = Object.assign({}, this.listOfRows[i]);
            console.log('Temporary record=',tempRecord); //cloning object
            if(tempRecord.index !== toBeDeletedRowIndex) {
                listOfRows.push(tempRecord);
            }
        }
        for(let i=0;i<this.records.length;i++){
            if(i != toBeDeletedRowIndex-1){
                tempRecs.push(this.records[i]);
            }
        }
        for(let i = 0; i < listOfRows.length; i++) {
            listOfRows[i].index = i + 1;
        }

        this.listOfRows = listOfRows;
        console.log('List of Rows',this.listOfRows);
        if(this.listOfRows.length == 1){
            this.listOfRows[0].nodelete = true;
        }
        
        this.records = tempRecs;
        console.log('After Delete',this.records);
        this.listOfRows = listOfRows;
    }

    
    lookupAccountRecord(event){
        let record =  JSON.stringify(event.detail.selectedRecord);
        if(record != undefined){
            let recs =   JSON.parse(record);
            console.log('Account Record',recs);
            let obj = {};
            
            this.tempVarAcc = recs.Id;
            if(this.tempVarSp!= undefined){
                
                obj ={
                    'Core_Account__c':this.tempVarAcc,
                    'Core_Supported_Product__c': this.tempVarSp
                }
                
                //console.log('AccID',this.tempVarAcc);
               // console.log('Map=>',this.mapp);
            } 
            this.records.push(obj);
           // console.log('Records',this.records);
           // console.log('List of Acc Recs',this.accrecs);
        }
        
       
    }
    
    lookupSpRecord(event){
        let record =  JSON.stringify(event.detail.selectedRecord);
        if(record != undefined){
            let recs =   JSON.parse(record);
            
            this.tempVarSp = recs.Id;
             if(this.tempVarAcc == undefined) {
                this.mapp.set(this.tempVarSp,' ');
            }
            //console.log('Supported Product',recs);
            //console.log('List of SP Recs',this.sprecs);
        }    
    }



    navigateToFileUpload(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Core_IPS_File_Upload_Master__c',
                actionName: 'view'
            },
        });
    }

    showList(){
        console.log('Selected List-',this.records);
        console.log('listofAccounts',this.listOfAccounts);
    }
    
    saveFileRecords(){
        this.spinner = true;
        if(this.tempVarAcc == undefined && this.tempVarSp != undefined){
            let  obj ={
                 'Core_Account__c': null,
                 'Core_Supported_Product__c': this.tempVarSp
             }
             this.records.push(obj);
         }
        
        if(this.records.length==0){
            alert('Both Supported Product And Account cannot be Empty');
            this.spinner = false;
        }    
        
            
            else{
                saveRecords({prodIds: this.records, upldId: this.recordId,}).then(result=>{
                    
                        if(result == 'true'){
                            this.showToast('Success!!', 'Files Assigned Successfully', 'Success');
                            this.navigateToFileUpload();
                            
                        }
                        else{
                            this.showToast('Error!!', result, 'error');
                            this.spinner = false;
                        }
                    
                })
                .catch(error=>{
                    this.showToast('Error!!', error.message, 'error');
                    console.log('Error=>',error);
                })
                
            }
            
        
    }
    
        showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    
}