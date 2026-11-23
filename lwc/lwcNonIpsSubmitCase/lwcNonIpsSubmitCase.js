import { LightningElement, wire, track} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import fetchNonIPSCaseCreation from '@salesforce/apex/Sales_NonIPSCaseCreation.fetchNonIPSCaseCreationtest';


export default class LwcNonIpsSubmitCase extends LightningElement {
    @track pickListValues = [];

    @wire( fetchNonIPSCaseCreation )  
    wiredRecs( value ) {
        console.log('fetchNonIPSCaseCreation '+JSON.stringify(value));
        this.wiredRecords = value;
        const { data, error } = value;
        if (data) {
            var dataTemp = JSON.parse(JSON.stringify(data));
            var pickListValuesTemp = [];
            dataTemp.forEach(function (record) {
                pickListValuesTemp.push(record.Type_of_License_Issue__c);
                console.log('picklistvaluestemp',pickListValuesTemp)
            });
            this.pickListValues = pickListValuesTemp;
            console.log('pickListValues',pickListValues)
            this.records = dataTemp;
            this.error = undefined;
        } else if ( error ) {
            this.error = error;
            this.records = undefined;
        }
        
        console.log('fetchNonIPSCaseCreation 3'+JSON.stringify(this.pickListValues));
        

    }  
    handleOnSubmitBtnClick(){

    }
    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }
    connectedCallback(){
        console.log('pick '+JSON.stringify(this.metadatarecord));
    }
    onChangeproductname(){}
    onChangepo(){}

    handleChange(event) {
        this.value = event.detail.value;
    }
    handleOnSubmitBtnClick()
    {
        
    }
}