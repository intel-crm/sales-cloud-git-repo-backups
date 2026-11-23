import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';

const PRODUCT_HISTORY_LINEITEM__COLS = [{
        label: 'Date',
        fieldName: 'Date'     
    },
    {
        label: 'Field',
        fieldName: 'Field'
    },
    {
        label: 'User',
        fieldName: 'UserNameURL',
        type: 'url',
        typeAttributes: {label: {fieldName: 'User'},
            target: '_blank', 
        }
    },
    {
        label: 'Original Value',
        fieldName: 'OriginalValue'
    },
    {
        label: 'New Value',
        fieldName: 'NewValue'   
    }   
];

export default class MapHistoryComponent extends LightningElement {

    hideCheckboxColumn = false;
    showRowNumberColumn = false;
    enableInfiniteLoading = true;
    numAndCheckboxBothCols = false;
    normalDataTable = true;
    numberOfRowsToShow = 5;
    heightInRem = 12;
    
    lightningCardTitle = 'Product Access History';

    @track dataToShow;
    @track isDataAvailable = false;
    @track columns = PRODUCT_HISTORY_LINEITEM__COLS;
    @track mapRecordId;

    @wire(CurrentPageReference)
        currentPageReference;

    connectedCallback() {
        console.log('mapHistoryComponent ::: connectedCalback called');
        this.getRecords();
    }

    getRecords() {
        this.mapRecordId = this.currentPageReference.attributes.recordId;
        this.queryString = 'SELECT Id, ParentId, CreatedDate, Field, Field.Name, CreatedBy.Id, CreatedBy.Name, OldValue, NewValue FROM Core_IPS_MAP_PAR__History WHERE ParentId  = \''+ this.mapRecordId  + '\' ORDER BY CreatedDate DESC'; 
        getQueryResult({queryString : this.queryString})
            .then(data => {
                if(data) {
                    console.log('data in mapHistoryComponent :::: ', JSON.stringify(data));
                    let dataWrapper = [];
                    for(let i=0;i<data.length;i++) {
                        let obj = {
                            'Date' : data[i].CreatedDate,                             
                            'Field' : data[i].Field.Name,                            
                            'User' : data[i].CreatedBy.Name,
                            //'UserNameURL' : '/' + data[i].CreatedBy.Id,
                            'OriginalValue' : (data[i].OldValue === undefined || data[i].OldValue === null ) ? '' : ''+data[i].OldValue,
                            'NewValue' : (data[i].NewValue  === undefined || data[i].NewValue  === null ) ? '' : ''+data[i].NewValue
                          };
                          dataWrapper = [...dataWrapper, obj];
                    }
                    this.dataToShow = dataWrapper;
                    console.log('data in mapHistoryComponent :::: this.dataToShow ', JSON.stringify(this.dataToShow));
                    this.isDataAvailable = true;
                }
            })
            .catch(error => {
                console.error('mapHistoryComponent ::: Error in loading records. Error : ', JSON.stringify(error));
            })
    }
}