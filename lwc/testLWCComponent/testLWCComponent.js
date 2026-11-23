export default class TestLWCComponent extends LightningElement{}
// import { LightningElement,wire} from 'lwc';
// import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
// import STATUS from '@salesforce/schema/ArdiraSurvey__Survey_Result__c.PSS_Partner_Solution_Lifecycle_Status_Nm__c';
// import SUBMITTER_NAME from '@salesforce/schema/ArdiraSurvey__Survey_Result__c.PSS_Solution_Submitter_UserId_Id__r.Name';


// export default class TestLWCComponent extends LightningElement {
//     //recordId = 'a7q2h0000004GAE';

//     @wire(getRecord, { recordId: 'a7x8A000000D5iCQAS', fields: [STATUS, SUBMITTER_NAME]})
//     survey;

//     get submitterName() {
//         return getFieldValue(this.survey.data, SUBMITTER_NAME);
//     }

//     get status() {
//         return getFieldValue(this.survey.data, STATUS);
//     }
// }