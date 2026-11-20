import { LightningElement,api,wire,track} from 'lwc';
import getfieldSetByName from "@salesforce/apex/core_IPS_LEXAddCommentController.getFieldSetFieldsByFieldSetName";
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import CASE_SUBJECT from '@salesforce/schema/Case.Subject';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
const fields = [CASE_SUBJECT,CASE_NUMBER];

export default class Core_IPS_Page_Header extends LightningElement {
    @api objectApiName;
    @api recordId;
    @api casenumber1;
    @wire(getRecord, { recordId: '$recordId', fields})
    case
    get subject() {
        return getFieldValue(this.case.data, CASE_SUBJECT);
    }
    get casenumber(){
        
        this.casenumber1=getFieldValue(this.case.data, CASE_NUMBER);
        console.log('case number in page header', this.casenumber1);
        return getFieldValue(this.case.data, CASE_NUMBER);
    }
    @api fieldsToFetchFieldSet='Case_Compact_Layout';
    fieldSets;
   
    @wire(getfieldSetByName, {objectApiName: '$objectApiName', fieldSetName: '$fieldsToFetchFieldSet', recordId: '$recordId'})
    wiredFieldsToFetchFieldSet({ error, data }) {
        if (data) {
            console.log('wirePageHeader');
            this.fieldSets = data;
            this.error = undefined;
        }else if (error) {
           console.log(error);
        }
    }
   
}