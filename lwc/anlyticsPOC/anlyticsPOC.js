import { LightningElement, api, track, wire } from 'lwc';
import { getDataset, executeQuery } from 'lightning/analyticsWaveApi';
const DATASET_NAME ='Duplicate';
export default class AnlyticsPOC extends LightningElement {
    @track datasetId;
    @track datasetVersionId;
    @track query;
    data;
    @track searchMap= [];
    @wire(getDataset, {
        datasetIdOrApiName: DATASET_NAME
    })
    onGetDataset({data, error}) {
        if (error) {
            console.log('ERROR:', error);
        } else if (data) {
            this.datasetId = data.id;
            this.datasetVersionId = data.currentVersionId;
        }
    }

   /* get computedQuery() {
        if(this.datasetId && this.datasetVersionId){
            let query = 'q = load "' + this.datasetId + '/' + this.datasetVersionId + '";';
            console.log(this.searchMap);
            console.log(this.searchMap.length);
            this.searchMap.forEach(item => {
                query += (item['field'] == 'Id') ? 'q = filter q by Id like "%'+ item['value'] +'%";' : '';
                query += (item['field'] == 'Name') ? 'q = filter q by Name like "%'+ item['value'] +'%";' : '';
                query += (item['field'] == 'AccountSource') ? 'q = filter q by AccountSource like "%'+ item['value'] +'%";' : '';
            });
            query += 'q = group q by Id;';
            query += 'q = group q by Name;';
            query += 'q = group q by AccountSource;';
            query += 'q = foreach q generate Id, Name, AccountSource;';
            query += 'q = limit q 20;';
            console.log(query);
            this.query = query;
        }
        
        if (!this.query) { return undefined; } 
        return {
            query: this.query
        }
    }
    
    @wire(executeQuery, {
        query: '$computedQuery'
    })
    onExecuteQuery({data, error}) {
        if (error) {
            console.log('Error:', JSON.parse(JSON.stringify(error)));
        } else if (data) {
        this.data = data.results.records;
            //console.log(JSON.parse(JSON.stringify(this.data)));
        }
    }

    handleSearch(event){
        let searchItem = this.searchMap.find((item) => {return item['field'] == event.target.dataset.name});
        if(searchItem){
            searchItem['value'] =  event.target.value;
        }else{
            this.searchMap.push({field:event.target.dataset.name, value: event.target.value});
        }       
    }*/
}