import AccountId from '@salesforce/schema/Case.AccountId';
import { LightningElement,track } from 'lwc';


export default class TestComponent extends LightningElement {

    @track sprecs = [] ;
    @track accrecs = [];

    @track listOfAccounts;

    connectedCallback() {
        this.initData();
    }

    initData() {
        let listOfAccounts = [];
        this.createRow(listOfAccounts);
        this.listOfAccounts = listOfAccounts;
    }

    createRow(listOfAccounts) {
        let accountObject = {};
        if(listOfAccounts.length > 0) {
            accountObject.index = listOfAccounts[listOfAccounts.length - 1].index + 1;
        } else {
            accountObject.index = 1;
        }
        accountObject.Name = null;
        accountObject.Website = null;
        accountObject.Phone = null;
        listOfAccounts.push(accountObject);
    }

    /**
     * Adds a new row
     */
    addNewRow() {
        this.createRow(this.listOfAccounts);
        if(this.tempVarAcc == undefined){
           let  obj ={
                'Core_Account__c':' ',
                'Core_Supported_Product__c': this.tempVarSp
            }
            this.records.push(obj);
        }
        this.tempVarAcc = undefined;
    }

    /**
     * Removes the selected row
     */
    removeRow(event) {
        let toBeDeletedRowIndex = event.target.name;

        let listOfAccounts = [];
        for(let i = 0; i < this.listOfAccounts.length; i++) {
            let tempRecord = Object.assign({}, this.listOfAccounts[i]); //cloning object
            if(tempRecord.index !== toBeDeletedRowIndex) {
                listOfAccounts.push(tempRecord);
            }
        }

        for(let i = 0; i < listOfAccounts.length; i++) {
            listOfAccounts[i].index = i + 1;
        }

        this.listOfAccounts = listOfAccounts;
    }

    /**
     * Removes all rows
     */
    removeAllRows() {
        let listOfAccounts = [];
        this.createRow(listOfAccounts);
        this.listOfAccounts = listOfAccounts;
    }

    handleInputChange(event) {
        let index = event.target.dataset.Id;
        let fieldName = event.target.Name;
        let value = event.target.value;

        for(let i = 0; i < this.listOfAccounts.length; i++) {
            if(this.listOfAccounts[i].index === parseInt(index)) {
                this.listOfAccounts[i][fieldName] = value;
            }
        }
    }

    mapp = new Map();
    tempVarAcc = undefined;
    tempVarSp;
    records = [];
    lookupAccountRecord(event){
        let record =  JSON.stringify(event.detail.selectedRecord);
        if(record != undefined){
            let recs =   JSON.parse(record);
            console.log('Account Record',recs);
            let obj = {};
            /*if(this.accrecs.length>0){
                this.accrecs = [...this.accrecs,recs];
            }
            else{
                this.accrecs = recs;
            }*/
            this.tempVarAcc = recs.Id;
            if(this.tempVarSp!= undefined){
                //this.mapp[this.tempVarSp]= recs.Id;
                this.mapp.set(this.tempVarSp,this.tempVarAcc);
                obj ={
                    'Core_Account__c':this.tempVarAcc,
                    'Core_Supported_Product__c': this.tempVarSp
                }
                this.tempVarAcc = 'changed';
                console.log('AccID',this.tempVarAcc);
                console.log('Map=>',this.mapp);
            } 
            this.records.push(obj);
            console.log('Records',this.records);
            console.log('List of Acc Recs',this.accrecs);
        }
        
       // let recs =   JSON.parse(record);
        //this.AccountId = recs.Id;
    }
    createAccounts(){
        console.log('List',this.records);
        if(this.tempVarAcc == undefined){
            let  obj ={
                 'Core_Account__c':' ',
                 'Core_Supported_Product__c': this.tempVarSp
             }
             this.records.push(obj);
         }
    }
    lookupSpRecord(event){
        let record =  JSON.stringify(event.detail.selectedRecord);
        if(record != undefined){
            let recs =   JSON.parse(record);
            /*if(this.sprecs.length>0){
                this.sprecs = [...this.sprecs,recs];
            }
            else{
                this.sprecs = recs;
            }*/
            this.tempVarSp = recs.Id;
            //this.tempVarAcc = undefined;
            /*if(this.tempVarAcc!= undefined){
               // this.mapp[this.tempVarAcc] = recs.Id;
            }*/ if(this.tempVarAcc == undefined) {
                this.mapp.set(this.tempVarSp,' ');
            }
            console.log('Supported Product',recs);
            console.log('List of SP Recs',this.sprecs);
        }    
    }
    handlerows(event){
        const selectedRows = event.detail.selectedRows;
        console.log('Selected SP Rows',this.sprecs);
        console.log('Selected Acc rows',this.accrecs);
       // console.log('Selected Rows',this.template.querySelector('c-core_ips_custom-Lookup-Lex').getSelectedRows());
    }
}