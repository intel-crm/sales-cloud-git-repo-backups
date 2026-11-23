import { LightningElement, wire } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import Escalation_OBJECT from '@salesforce/schema/Core_MDF_Escalation__c'


export default class TestWireListView extends LightningElement {
    @wire(getListUi, {
        objectApiName: Escalation_OBJECT,
        listViewApiName: 'Core_MDF_Open_Escalations'
    })
    listView;

    get escalations() {
        return this.listView.data.records.records;
    }
}