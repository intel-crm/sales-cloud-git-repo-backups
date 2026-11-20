import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

const CASE_NUMBER_FIELD = 'Case.CaseNumber';

export default class Ips_AgentLuncher extends LightningElement {
    @api recordId;

    caseNumber;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [CASE_NUMBER_FIELD]
    })
    wiredCase({ data, error }) {
        if (data) {
            this.caseNumber = getFieldValue(data, CASE_NUMBER_FIELD);
        }
    }

    get chatUrl() {
    if (!this.caseNumber) {
        return '';
    }

        return `https://oneai.intel.com/c/new?agent_id=agent_O7kTmJ6Ss22w4mlBfR2XY&prompt=${encodeURIComponent(this.caseNumber)}&submit=true`;
    }
}