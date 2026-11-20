import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';
import getLabel from '@salesforce/apex/Core_IPS_NewMapHomePageController.getLabel';
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
    @track res1;
    @track customFieldLabel;
    @track properties;
    lightningCardTitle = 'Product Access History';
@track apiLabelMap1 = [];
@track apiLabelMap;
    @track dataToShow;
    @track isDataAvailable = false;
    @track columns = PRODUCT_HISTORY_LINEITEM__COLS;
    @track mapRecordId;

    @wire(CurrentPageReference)
        currentPageReference;

    connectedCallback() {
        console.log('mapHistoryComponent ::: connectedCalback called');
        this.getlabel();
      //  this.getRecords();
    }

    getlabel(Names){
        getLabel({
            ObjectName :'Core_IPS_MAP_PAR__c',
            ApiName:'Core_IPS_MAP_Count_Supp_acct__c'
    
            })
        .then(data => {
            if(data) {
                /*
                for(let key in data) {
                    // Preventing unexcepted data
                    if (data.hasOwnProperty(key)) { // Filtering the data in the loop
                        this.apiLabelMap1.push({value:data[key], key:key});
                    }
                }*/
                this.apiLabelMap = data;
                
                this.getRecords();
                

                
                

            }
        })
    }


    getRecords() {
        console.log('Display Recs');
        this.mapRecordId = this.currentPageReference.attributes.recordId;
        this.queryString = 'SELECT Id, ParentId, CreatedDate, Field, CreatedBy.Id, CreatedBy.Name, OldValue, NewValue FROM Core_IPS_MAP_PAR__History WHERE ParentId  = \''+ this.mapRecordId  + '\' ORDER BY CreatedDate DESC'; 
        getQueryResult({queryString : this.queryString})
            .then(data => {
                if(data) {
                    let dataWrapper = [];
                    for(let i=0;i<data.length;i++) {
                       // console.log('apiLabelMap-->'+JSON.stringify(this.apiLabelMap));
                       // console.log('i value-->'+i);
                        console.log('data[i].Field-->'+data);
                        console.log('History Record : '+ i);
                      this.res1= data[i].Field;


                      this.res1=this.res1.toLowerCase();
                      console.log('Lower Case Fields '+ this.res1);

                      this.properties = Object.keys(this.apiLabelMap);
                    console.log(this.properties);
                    for (let j=0, len=this.properties.length; j < len; j++){
                        if(this.res1 === this.properties[j]){
                            this.customFieldLabel = this.apiLabelMap[this.properties[j]]; 
                            console.log("Name: " + this.properties[j]);
                            console.log("Value: " + this.apiLabelMap[this.properties[j]]);
                            break;
                        }
                    }
                       
                     
                      let dt1 = data[i].CreatedDate;
                        let obj = {
                            'Date' : new Date(dt1).toLocaleString(),
                            'Field':this.customFieldLabel,                                                 
                            'User' : data[i].CreatedBy.Name,
                            'UserNameURL' : '/' + data[i].CreatedBy.Id,
                            'OriginalValue' : (data[i].OldValue === undefined || data[i].OldValue === null ) ? '' : ''+data[i].OldValue,
                            'NewValue' : (data[i].NewValue  === undefined || data[i].NewValue  === null ) ? '' : ''+data[i].NewValue
                          };

                          dataWrapper = [...dataWrapper, obj];
                    }
                    this.dataToShow = dataWrapper;
                    this.isDataAvailable = true;
                }
            })
            .catch(error => {
                console.error('mapHistoryComponent ::: Error in loading records. Error : ', JSON.stringify(error));
            })
    }
}