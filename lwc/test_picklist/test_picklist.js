import { LightningElement, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import TYPE_FIELD from '@salesforce/schema/Account.AccountSource';

export default class WireGetPicklistValues extends LightningElement {
    @wire(getPicklistValues, {
        recordTypeId: '012o0000000GlzTAAS',
        fieldApiName: TYPE_FIELD
    })
    picklistValues;
}