import { LightningElement,api,wire,track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getMINDSQuestions from "@salesforce/apex/Core_IPS_MAG_Questionnaire_Lex.getMINDSQuestions";
import saveAnswer from "@salesforce/apex/Core_IPS_MAG_Questionnaire_Lex.saveAnswer";
import getCaseStatus from "@salesforce/apex/Core_IPS_MAG_Questionnaire_Lex.getCaseStatus";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Core_IPS_MAG_Questionnaire_LEX extends LightningElement {


    @api recordId;
    @track currentPageReference;
    @track tempRecordId;
    @track cnt=0;
    @track type;
    @track savealldataedq =[];
    @track isEditable;
    @track saveFlag = false;
    @track valCheck = true;
    @track isError = false;
    @api trackvalidation = [];
    a_Record_URL;
    readOnly = true;
    label;
    mindsData = false;
    result=[];
    textcheck=false;
    picklistcheck=false;
    multiselectpiclistchecktrue=false;
    textareacheck=false;

    constructor() {
        super();
        this.template.addEventListener('inselectedquestionanswer', this.handleChangeChild.bind(this));
    }
    connectedCallback() {
        this.a_Record_URL = window.location.origin;
    }

    handleChangeChild(event) {
        var s, c;
        var obj = {};
        var vb;
        console.log('Inside val check->'+event.detail.val);
        if (event.detail.val === false) {
            this.valCheck = false;
            vb = event.detail.val;
            this.trackvalidation.push(vb);
        }
        if (event.detail.child === 'Yes') {
            s = {
                "edq": [{ "question": event.detail.question, "selectedValues": event.detail.selectedValues, "required": event.detail.required, "answerType": event.detail.answerType, "answer": event.detail.answer, "val": event.detail.val }]
            };
            this.savealldataedq.push(s);
        } else{
        s = {
            "edq": [{ "question": event.detail.question, "selectedValues": event.detail.selectedValues, "required": event.detail.required, "answerType": event.detail.answerType, "val": event.detail.val }]
        };
        this.savealldataedq.push(s);
    }
    }
    
    validateedq() {
        console.log('Inside validate-->'+this.valCheck);
        if (this.trackvalidation.length === 0) {
            this.valCheck = true;
        }
    }
    
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.recordId = this.currentPageReference?.state?.c__recordId;
        if(this.cnt==1&&this.recordId!=this.tempRecordId){
           window.location.reload();
        }
    }
    @wire(getMINDSQuestions,{recordId:'$recordId'})
      mindsQuestion({data,error}) {
        if(data) {
            this.result = data;
            getCaseStatus({recordId:this.recordId})
        .then(result =>{
            this.isEditable = result;
            if(this.isEditable == true){
                this.readOnly = false;
            } else {
                this.readOnly = true;
            }
        })
        .catch(error =>{

        })
        } else if(error) {
        }
      }

    saveHandler() { 
        this.trackvalidation = [];
        this.template.querySelectorAll('c-magbuilder')
        .forEach(element => {
            element.callhandleQuestionAnswer();
        })
        this.validateedq();
        if(this.valCheck){
            this.saveFlag = true;
        var strEdq = JSON.stringify(this.savealldataedq);
        console.log('Sjakdksa--'+JSON.stringify(this.savealldataedq));
        saveAnswer({magEDQdata :strEdq,recordId :this.recordId})
        .then(result =>{
            console.log('Done');
            this.saveFlag = false;
            this.showToast();
            this.cancelHandler();
        })
        .catch(error =>{
            this.saveFlag = false;
            console.log('ERROR-->'+JSON.stringify(error));
        })
    } else{
        console.log('sjisos-->'+this.isError);
            this.isError = true;
    }
    }
    callFromChild(event){
        this.template.querySelectorAll('c-magbuilder')
        .forEach(element => {
            if(element.ordernumber == event.detail.ordernumber + 1 && (event.detail.ordernumber != 2) && (event.detail.ordernumber != 1)){
                   element.remove();
            }
        })
    }

    cancelHandler() {
        this.a_Record_URL = this.a_Record_URL +'/lightning/r/Case/'+this.recordId+'/view';
        window.open(this.a_Record_URL,"_self");
    }
   
    showToast() {
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'Success!',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}