import { LightningElement, api, track } from 'lwc';

import fetchRecords from '@salesforce/apex/Tooling_BulkExportCntrl.fetchRecords';

export default class BulkExport extends LightningElement {

    @track columns=[];

    @api format = {};
    @track filtervalues = [];
    @track filteringValues;
    @track filteringField;

    @track startIndex;
    @track endIndex;
    @track counter;
    @track data = [];
    @track colNames= [];

    
    @track query;
    handleFilterChange(evt) {
        const filterval = evt.target.value.replace('\n', '');

        if (filterval.includes(',')) {
            
            filterval.split(',').map(item=>{
                if(item.includes('\n') && item!=null){
                    this.populateIds(item.replace('\n',''));
                }else if(item!=null){
                    this.populateIds(item);
                }
            })
        } else if(filterval!=null) {
            this.populateIds(filterval);
        }

    }
    
    populateIds(item){
        if(!this.filtervalues.includes(item))this.filtervalues.push(item);
    }

    handleFieldFilterChange(evt) {
        this.fieldFilter = evt.target.value;
    }
    handleQueryChange(evt) {
        this.query = evt.target.value;
        console.log('Query -->', this.query);

    }

    fetchRecordsFromServer(qr) {

        fetchRecords({ query: qr.trim(), filterFilterName: this.fieldFilter, values: this.filtervalues.slice(this.startIndex, this.endIndex) }).then(result => {
            
            result.map(item => {
                Object.keys(item).forEach(key => {
                    console.log('Key -->', key);
                    if(!this.colNames.includes(key)){
                        this.colNames.push(key);
                    }
                    
                  });
                this.data.push(item);
            })
            console.log('Result -->', result);
            this.counter += 1;
            if (this.counter <= this.noOfBatches) {
                this.startIndex = this.endIndex + 1;
                this.endIndex = (this.startIndex + 199 > this.filtervalues.length) ? this.filtervalues.length : this.startIndex + 199;
                this.fetchRecordsFromServer(qr);
            }else{
                const col = []
                this.colNames.map(item=>{
                    col.push({'label':item, 'fieldName':item,'type':'text'});
                })
                this.columns = col;
            }
        })
            .catch(error => {
                console.log('Error -->', error);
            })
    }

    handlerExport() {
        this.data = [];
        this.counter = 0
        this.startIndex = 0;
        this.endIndex = 200;
        console.log('this.filtervalues.length', this.filtervalues.length);
        // let qr = this.query.replace('<p>', '')
        // qr = qr.replace('</p>','');
        this.noOfBatches = Math.ceil(this.filtervalues.length / 200);
        this.fetchRecordsFromServer(this.query);
        // this.counter++;

    }


}