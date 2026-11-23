import { LightningElement, track, wire, api } from 'lwc';
import communityPath from '@salesforce/community/basePath';
//import { NavigationMixin } from 'lightning/navigation';
//import getDynamicTableDataList from '@salesforce/apex/Core_Ips_DynamicDataTable_Lwc_Ctrl.GetWrapperOfSObjectFieldColumnActionValues';
import getDynamicTableDataList from '@salesforce/apex/Core_IPS_ListViewsCtrl_LWC.GetWrapperOfSObjectFieldColumnActionValues';

const columns = [
    {
        label: 'Comment', fieldName: 'linkCase', type: 'url',
        typeAttributes: {
            label: 'Comment',
            target: '_self'
        }
    },
    {
        label: 'Case', fieldName: 'linkCase', type: 'url',
        typeAttributes: {
            label: { fieldName: 'CaseNumber' },
            target: '_self'
        }
    }
]

export default class Core_Ips_DynamicDataTable_Lwc extends LightningElement{
    @api recordId
    @track DataTableResponseWrappper;
    @track finalSObjectDataList;
    @track columns = columns;
    @track columnsResult;
    @track error;
    fdate;
    rowOffSet=0;
    rowLimit=3;
    totalNumberOfRows=100;
    loadMoreStatus;
    targetDatatable;
    tableElement;
    isLoading=false;
    //isLoading=false;
    @track selectedCasevalue = 'AllCases';
    get caseoptions() {
        return [
            { label: 'All Cases', value: 'AllCases' },
            { label: 'My Open Cases', value: 'My_Open_Cases' },
            { label: 'My Closed Cases', value: 'My_Closed_Cases' },
        ];
    }
    connectedCallback(){
        this.wiredContacts();
    }


    wiredContacts() {
       return getDynamicTableDataList({ caseListView:this.selectedCasevalue,rowOffset:this.rowOffSet})
        .then(data => {
            //let rec=[];
console.log(';;;;;;',data);

            let sObjectRelatedFieldListValues = [];
            let rows =  data;
            console.log('///////',rows.CreatedDate);
            const options = {
                year: 'numeric', month: 'numeric', day: 'numeric',
                hour: 'numeric', minute: 'numeric',
                hour12: true
              };
            

            for (let row of rows.lstDataTableData) {



                
                const finalSobjectRow = {}
                let rowIndexes = Object.keys(row);

                rowIndexes.forEach((rowIndex) => {
                    const relatedFieldValue = row[rowIndex];
                    
                    if (relatedFieldValue.constructor === Object) {
                        this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)
                    }
                    else {
                        finalSobjectRow[rowIndex] = relatedFieldValue;
                    }

                });
                sObjectRelatedFieldListValues.push(finalSobjectRow);
            }
            
            // let rec=[];

            this.DataTableResponseWrappper = rows;

            console.log('casenumber', data.lstDataTableData);

            this.finalSObjectDataList = sObjectRelatedFieldListValues;
            this.finalSObjectDataList = JSON.parse(JSON.stringify(this.finalSObjectDataList));

            this.columnsResult = columns.concat(data.lstDataTableColumns);
            // this.finalSObjectDataList.forEach(record => {
            //     if ( record.CreatedDate ) {
            //     let dt = new Date( record.CreatedDate );
            //           console.log('[[[[[[[[',dt);
            //            record.CreatedDate = new Intl.DateTimeFormat( 'en-US', options ).format( dt );
            //              console.log('\\\\\\\\',record.CreatedDate);
            //     }
            //     if ( record.LastModifiedDate ) {
            //         let dt = new Date( record.LastModifiedDate );
            //               console.log('[[[[[[[[',dt);
            //                record.LastModifiedDate = new Intl.DateTimeFormat( 'en-US', options ).format( dt );
            //                  console.log('\\\\\\\\',record.LastModifiedDate);
            //         }
            //         if ( record.ClosedDate ) {
            //             let dt = new Date( record.ClosedDate );
            //                   console.log('[[[[[[[[',dt);
            //                    record.ClosedDate = new Intl.DateTimeFormat( 'en-US', options ).format( dt );
            //                      console.log('\\\\\\\\',record.ClosedDate);
            //             }
        
            //         record.linkCase = communityPath + '/case-detail?recordId=' + record.Id;


            // });

            

            // let updatedRecords = [...this.finalSObjectDataList, data.lstDataTableData];
            // this.finalSObjectDataList=updatedRecords;
            this.finalSObjectDataList = [...this.finalSObjectDataList, ...rows.lstDataTableData];
            this.error = undefined;
            this.loadMoreStatus = '';
            if (this.targetDatatable && this.finalSObjectDataList.length >= this.totalNumberOfRows) {
                this.targetDatatable.enableInfiniteLoading = false;
                this.loadMoreStatus = 'No more data to load';
            }
            if (this.targetDatatable) this.targetDatatable.isLoading = false;
        
    
        

    
        });
       
    }


    _flattenTransformation = (fieldValue, finalSobjectRow, fieldName) => {
        let rowIndexes = Object.keys(fieldValue);
        rowIndexes.forEach((key) => {
            let finalKey = fieldName + '.' + key;
            finalSobjectRow[finalKey] = fieldValue[key];
        })
    }
    
        
        
        
       
    
    
    handleChangeCaseListView(event) {
        console.log('event', event.detail);
        this.selectedCasevalue = event.detail.value;
        console.log('selected case  value is@@@@@' + this.selectedCasevalue);
        this.wiredContacts();
        //alert('value---'+this.value);
    }

    loadMoreData(event) {
console.log('ajith');
        event.preventDefault();
        this.rowOffSet = this.rowOffSet +10;
        event.target.isLoading = true;
        this.targetDatatable = event.target;
        this.loadMoreStatus = 'Loading';
        this.isLoading=true;
        this.wiredContacts();
        this.isLoading=false;
        event.target.isLoading = false;


         

        // const currentRecord = this.finalSObjectDataList;
        //  const newData=currentRecord.concat(this.finalSObjectDataList);
        //    this.finalSObjectDataList=newData;
       
        // const { target } = event;
        // target.isLoading = true;
        
        
        
        
        
        
        
        
        
        // this.rowOffSet = this.rowOffSet +this.rowLimit;
        // this.wiredContacts()
        // .then(()=> {
        // target.isLoading = false;
        // });

// event.target.isLoding=true;
// this.loadMoreStatus='Loading';
// this.wiredContacts(50)
// .then((data)=> {
// if(data.length>=this.totalNumberOfRows){
//     event.target.enableInfiniteLoading=false;
//     this.loadMoreStatus='No More Data To Load';
// }else{

//     const currentData=this.finalSObjectDataList;
//     const newData=currentData.concat(data);
//     this.finalSObjectDataList=newData;
//     this.loadMoreStatus='';
// }
// event.target.isLoding=false;

//      });

        }
    
}