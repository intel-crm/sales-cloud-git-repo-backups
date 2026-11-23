import { LightningElement ,api, track} from 'lwc';
//console.log('hi firt cmp');
export default class Core_IPS_CRUD extends LightningElement {
    @track inputSObjectListSent = [];
    @track isInserPresent = false;
    @track isUpdatePresent = false;
    @track isDataRead = false;
    @track isRecordDelete = false;
    @track query;
    connectedCallback() {
    }  
    handleClick(){
        console.log('in parent comp Called1');
        this.inputSObjectListSent =[{sobjectType : "Case",
        AccountId:"0013F000001wRywQAE",
        RecordTypeId :"012o0000000TPVgAAO",
        Contact:"0033F000002T9wMQAS",
        Product:"02i3F000002rv08QAA",
        Core_IPS_Issue_source__c : "Internal Portal",
        Core_CaseType__c : "Question",
        Subject : "ranjini_Create_1",
        Description:"this is description"    
        }];
        this.isInserPresent = true;
        console.log('in parent comp Called1', JSON.stringify(this.inputSObjectListSent));
    }

    handleClickEdit(){
        console.log('in parent comp Called2');
        var accountList = [];
        let account = {
        Id : "0013F000001wRyw",
        Name : "ModifiedBy CRUDER",
        Description: "this is description"
    }
        accountList = [...accountList, account]; 
        this.inputSObjectListSent =accountList;
        this.isUpdatePresent = true;
        console.log('in parent comp Called2', JSON.stringify(this.inputSObjectListSent));
       // this.template.querySelector("c-crudcmp").handleValueChange();
    }

    handleClickRead(){
        console.log('in parent comp Called3');
        this.inputSObjectListSent ='Select id from case limit 10';
        this.isDataRead = true;
        console.log('in parent comp Called3', JSON.stringify(this.inputSObjectListSent));
    }

    handleClickDelete(){
        console.log('in parent comp Called4');
        var accountList = [];
        let account = {
        Id : "0013F000001wRyw",
        Name : "ModifiedBy CRUDER",
        Description: "this is description"
    }
        accountList = [...accountList, account]; 
        this.inputSObjectListSent =accountList;
        this.isRecordDelete = true;
        console.log('in parent comp Called4', JSON.stringify(this.inputSObjectListSent));
    }
}