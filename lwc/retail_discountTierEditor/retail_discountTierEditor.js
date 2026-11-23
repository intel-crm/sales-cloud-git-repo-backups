import { LightningElement,track,api,wire } from 'lwc';
import getTiers from '@salesforce/apex/Retail_CPQ_DiscountScheduleEditor.fetchDisconuntTiers'; 
import addRow from '@salesforce/apex/Retail_CPQ_DiscountScheduleEditor.addNewTier';
import deleteRecord from '@salesforce/apex/Retail_CPQ_DiscountScheduleEditor.deleteRecord';
import updateTiers from '@salesforce/apex/Retail_CPQ_DiscountScheduleEditor.updateTiers';
import { refreshApex } from '@salesforce/apex';	
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const actions = [
    { label: 'Delete', name: 'delete'}
];
const COLS = [
    
    { label: 'Tier Name', fieldName: 'Name',wrapText:true,editable: true,type: 'text',
      },
    //{ label: 'Download Link', fieldName: 'fileUrl', type:'url' }
    { label: 'Lower Bound', fieldName: 'SBQQ__LowerBound__c',wrapText:true,editable: true,type: 'number',
    },
    { label: 'Upper Bound', fieldName: 'SBQQ__UpperBound__c',wrapText:true,editable: true,type: 'number',
    },
    { label: 'Rebate', fieldName: 'core_cpq_Rebate__c',wrapText:true,editable: true,type: 'currency',
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        },
    }
]
export default class Retail_discountTierEditor extends LightningElement {
    columns=COLS;
    // tableData=[
        //{"Name":"Tier-1","SBQQ__LowerBound__c":"1","SBQQ__UpperBound__c":"10","Rebate":" "},
        //{"Name":"Tier-2","SBQQ__LowerBound__c":"10","SBQQ__UpperBound__c":"20","Rebate":" "}
    //]
    @api recordId;
    @track tableData;
    @track errorMsgOnUI='';
    @track wiredRefresh;
    @track saveDraftValues;
    @track draftValues=[];
    @track showSpinner=false;
    @track suppressFlag=false;
    @track count=0;
    columns=COLS;
    connectedCallback(){
        //this.getAllTiers();
    }
    @wire (getTiers,{quoteLineId:'$recordId'})
    getTiers(result){
        this.wiredRefresh=result;
        if(result.data){
            this.tableData=JSON.parse(JSON.stringify(result.data.tierList));
            console.log("ResultDiscountTier"+JSON.stringify(this.tableData));

        }
        else if(result.error){
            //console.log("ErrorDiscountTier"+result);
            console.log('FailedToGetTiers' + JSON.stringify(result.error));
        }
    }
    addNewRow(){
        this.showSpinner=true;
        addRow({recordId : this.recordId , tierLst:this.tableData})
        .then(result=>{ 
            this.tableData = JSON.parse(JSON.stringify(result.tierList));
            
            this.showSpinner=false;
            console.log('New result '+JSON.stringify(result.tierList));
            console.log('New result '+result.tierList.length);
            let index = this.tableData.length;
            console.log('length'+JSON.stringify(index));
            if(index>1){
                console.log('In index');
                let lastLine=this.tableData[index-1];
                //lastLine.SBQQ__LowerBound__c=this.tableData[index-2].SBQQ__UpperBound__c
                lastLine.Id='row-'+this.count;
            }
            this.count=this.count+1;
            console.log('Data'+JSON.stringify(this.tableData));
        })
       
    }
    handleRowActions(event) {
        this.showSpinner=true;
        let actionName = event.detail.action.name;
        console.log('Row Result'+ JSON.stringify(event.detail));

        window.console.log('actionName ====> ' + actionName);

        const row = event.detail.row;

        window.console.log('row ====> ' + JSON.stringify(row));
        
        // eslint-disable-next-line default-case
        let obj = JSON.parse(JSON.stringify(this.template.querySelector("lightning-datatable")));
        
        console.log('this.template.querySelector'+JSON.stringify(obj));
        switch (actionName) {
            case 'delete':
                this.deleteCons(row.Id);
                break;
        }
    }
    deleteCons(deleteRecordId){
      /* console.log("Row"+currentRow);
        let currentRecord = [];
        currentRecord.push(currentRow.Id);
        console.log("Current record"+"<=>"+JSON.stringify(currentRecord));*/
       /* if(currentRow.Id==null || currentRow.Id=='' || currentRow.Id==undefined){
           this.showSpinner=false;
            return refreshApex(this.wiredRefrex);
        }*/
        let index = 0;
        let recordIndex = 0;
        let isNewRecordDeletion = false;

        let removeFromTierList = false;
        let removeFromItems = false;
        let removeFromDraftList = false;
        this.tableData.forEach (function (eachItem) {
            console.log('eachItem.Id '+eachItem.Id+'deleteRecordId: '+deleteRecordId+'eachItem'+eachItem);
            let eachItemId = '' + eachItem.Id;
            let deleteRecordIdStr = '' + deleteRecordId;
            if(/*eachItemId.includes('row') && */eachItemId == deleteRecordIdStr){
                recordIndex = index;
                removeFromTierList = true;
                if(eachItemId.includes('row')){
                    isNewRecordDeletion = true;
                }
            }
            index = index + 1;
        }); 
        let draftItemsIndex = 0;
        let draftItemsRecordIndex = 0;
        this.draftValues=this.template.querySelector("lightning-datatable").draftValues;
        console.log('draft'+JSON.stringify(this.draftValues))
        this.draftValues.forEach (function (eachItem) {
            let eachItemId = '' + eachItem.Id;
            let deleteRecordIdStr = '' + deleteRecordId;
            if(/*eachItemId.includes('row') && */eachItemId == deleteRecordIdStr){
                draftItemsRecordIndex = draftItemsIndex;
                removeFromDraftList = true;
                //isNewRecordDeletion = true;
            }
            draftItemsIndex = draftItemsIndex + 1;
        }); 
         console.log('bbbbbbbbb '+removeFromTierList);
       // console.log('bbbbbbbbb '+removeFromItems);
        console.log('bbbbbbbbb '+removeFromDraftList+recordIndex);
       // let quoteLine;
        if(removeFromTierList == true){
            let tempTierList = this.tableData;
            //quoteLine = tempTierList[recordIndex];
            (tempTierList).splice(recordIndex,1);
            this.tableData = [...tempTierList];

        }
        console.log('Line1 '+removeFromTierList);
        if(removeFromDraftList == true){
            let draftItemsTempTierList = this.draftValues;
            (draftItemsTempTierList).splice(draftItemsRecordIndex,1);
            this.draftValues = [...draftItemsTempTierList];
        }

        console.log('Line2 '+removeFromDraftList);
       
        if(isNewRecordDeletion==false){
            console.log('Line3 '+removeFromDraftList);
            deleteRecord({recordId:deleteRecordId})
            .then(result =>{
            this.showSpinner=false;
            console.log("DeleteSuccess");
            //return refreshApex(this.wiredRefresh);
            })
            .catch(error =>{
            this.showSpinner=false;
            console.log("DeleteError "+JSON.stringify(error));
            })
        }
        else{
            this.showSpinner=false;
        }
        
    }
    handleSave(event){
        console.log('event  '+JSON.stringify(event));
        this.showSpinner=true;
        const updatedFields = event.detail.draftValues;
        console.log('Updated items',JSON.stringify(updatedFields)+'<---->'+'<---->'+updatedFields.length);  
        const updatedRecords =[];
        const newDataTableList =[];
        for(let index = 0 ; index < updatedFields.length ;index++){
            updatedRecords.push(updatedFields[index]);

        }
        //set Line number for each lines
       /* let countPrevLineNo=0;
        let previousUpperBound=0;
        let tierValidationFlag = false;
        this.tableData.forEach((tableRecords) => {
            let newDataTableRecord=[];
            let newListChangeFlag = false;
            console.log("countPrevLineNo"+countPrevLineNo);
            updatedRecords.forEach((draftRecords) => {
                if(draftRecords.Id==tableRecords.Id && (draftRecords.Id.includes('row'))){
                    draftRecords.SBQQ__Number__c=countPrevLineNo+1;
                }
                if(draftRecords.Id==tableRecords.Id && draftRecords.SBQQ__UpperBound__c !=null && draftRecords.SBQQ__LowerBound__c !=null ){
                    console.log('insideIf'+draftRecords.Id);
                    newDataTableRecord.Id = draftRecords.Id;
                    newDataTableRecord.SBQQ__UpperBound__c = draftRecords.SBQQ__UpperBound__c ;
                    newDataTableRecord.SBQQ__LowerBound__c = draftRecords.SBQQ__LowerBound__c ;
                    newListChangeFlag=true;
                    newDataTableList.push(newDataTableRecord);
                }else if(draftRecords.Id==tableRecords.Id && draftRecords.SBQQ__UpperBound__c !=null){
                    newDataTableRecord.Id = draftRecords.Id;
                    newDataTableRecord.SBQQ__UpperBound__c = draftRecords.SBQQ__UpperBound__c ;
                    newListChangeFlag=true;
                    newDataTableList.push(newDataTableRecord);
                }else if(draftRecords.Id==tableRecords.Id && draftRecords.SBQQ__LowerBound__c !=null){
                    newDataTableRecord.Id = draftRecords.Id;
                    newDataTableRecord.SBQQ__LowerBound__c = draftRecords.SBQQ__LowerBound__c ;
                    newListChangeFlag=true;
                    newDataTableList.push(newDataTableRecord);
                }
            });
            if(newListChangeFlag==false){
                newDataTableList.push(tableRecords);
            }
            countPrevLineNo=tableRecords.SBQQ__Number__c;
        });
        console.log('newDataTableList22'+JSON.stringify(newDataTableList));
        for(let index = 0 ; index < this.tableData.length -1 ;index++){
            if(newDataTableList[index+1].SBQQ__LowerBound__c != this.tableData[index].SBQQ__UpperBound__c){
                tierValidationFlag=true;
                break;
            }
        }*/

        console.log("this.tableDataBeforeSave"+JSON.stringify(this.tableData));
        console.log('updatedRecords'+JSON.stringify(updatedRecords)+'<==>'+updatedRecords.length)
        //console.log("tierValidationFlag"+tierValidationFlag);
        //if(tierValidationFlag==false){            
            updateTiers({recordId : this.recordId , updatedTiers : updatedRecords})
            .then(result => {
                this.showSpinner=false;
                console.log('Sucesss1234'+JSON.stringify(result));
                //this.showSpinner=false;
            this.draftValues = [];
                this.suppressFlag=true;
                //window.location.reload();
                return refreshApex(this.wiredRefresh);
                
            
            })
            .catch(error => {
               // this.draftValues = [];
                this.showSpinner=false;
                console.log('Failed' + JSON.stringify(error));
            })
        /*}else{
            this.errorMsgOnUI ='Lower Bound of next tier must equal to Upper Bound of previous tier for each Schedule';
            this.showSpinner=false;
            const event = new ShowToastEvent({
                title: 'Error',
                message: this.errorMsgOnUI,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }*/
    }
    /*getAllTiers(){
        getTiers({quoteLineId:this.recordId})
        .then(result=>{
            this.tableData=result.tierList;
        })
        .catch(error=>{
        })
    }*/
    /*handleCellChange(event){
        console.log('cell change  '+JSON.stringify(event));
    }*/
    handleCellChange(event){
        this.suppressFlag=false;
    }
}