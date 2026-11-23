import { LightningElement,wire, track } from 'lwc';
import getGovernorLimits from '@salesforce/apex/sfdcGovernorLimits_Controller.getGovernorLimits';

const COLS = [
    { label: 'Limit Name', fieldName: 'limitName'}, {label: 'Limit Value', fieldName: 'limitValue'}, {label: 'Usage Value', fieldName: 'usageValue'}, 
    {label: 'Percentage used', fieldName: 'percentValue', type: 'percent', cellAttributes: {alignment: 'left'} }
];

export default class SfdcOrgLimits extends LightningElement {

    columns = COLS;

    @track limitList =[]
    @wire(getGovernorLimits)
    governorLimits;
}