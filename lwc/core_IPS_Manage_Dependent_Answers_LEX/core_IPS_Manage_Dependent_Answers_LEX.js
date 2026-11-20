import { LightningElement,api,wire,track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import Core_IPS_Question_Name from '@salesforce/schema/Core_IPS_Question__c.Core_IPS_Question__c';
import getParentAnswers from '@salesforce/apex/Core_IPS_AddDependentAnswersLEX.getParentAnswers';
import getChildQuestions from '@salesforce/apex/Core_IPS_AddDependentAnswersLEX.getChildQuestions';
import validateChildQuestions from '@salesforce/apex/Core_IPS_AddDependentAnswersLEX.validateChildQuestions';
import validateChildAnswers from '@salesforce/apex/Core_IPS_AddDependentAnswersLEX.validateChildAnswers'; 
import validateParentAnswers from '@salesforce/apex/Core_IPS_AddDependentAnswersLEX.validateParentAnswers';
import getChildAnswers from '@salesforce/apex/Core_IPS_AddDependentAnswersLEX.getChildAnswers';
import updateParentAnswerOnChildAnswer from '@salesforce/apex/Core_IPS_AddDependentAnswersLEX.updateParentAnswerOnChildAnswer';
import saveDependentAnswers from '@salesforce/apex/Core_IPS_AddDependentAnswersLEX.saveDependentAnswers';
const FIELDS = [Core_IPS_Question_Name];
let i=0;

export default class Core_IPS_Manage_Dependent_Answers_LEX extends NavigationMixin(LightningElement) {

columns = [
               { label: 'Environment detail Answer', fieldName: 'Name' },
          ];
@track items = []; //this will hold key, value pair
@track value = ''; //initialize combo box value
@track chosenValue = '';
@track childQuestionitems = [];
@track childQuestionIds = [];
@track chosenQuestionValue;
@track value = '';
@track ChildQuestionRecords;
@track ChildAnswerRecords = [];
@track errorChildAnswerRecords = [];
@track Core_IPS_Question_Name;
@track EnvDetailAnswerData = [];
@track errorEnvDetailAnswerData = [];
@track errorEnvDetailQuestionData = [];
@track selectedEnvDetailAnswerRecord;
@track selectedchildAnswerData = [];
@track tempList = [];
@track fldsItemValues = [];
@track isLoading = false;
@track showData;
@track showChilData;
@track showParentAnswerData;
@track message = '';
@track rowsSelected = [];
@track currentPageReference;
@wire(CurrentPageReference)
setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
}

get recordId() {
    return this.currentPageReference?.state?.c__recordId;
}

connectedCallback(){
    this.showChilData = true;
    this.showParentAnswerData = true;
    this.EnvDetailAnswerRecords();
    this.getChildQuestionRecords();
    this.validateParentAnswersData();
    this.validateData();
    this.validateChildAnswerData();
}

// Wire method to get the data of fields
@wire( getRecord, { recordId: '$recordId', fields: FIELDS } )
    wiredRecord({ error, data }) {
        if ( error ) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading Record',
                    message,
                    variant: 'error',
                }),
            );
        } else if ( data ) {
            this.Core_IPS_Question_Name = data.fields.Core_IPS_Question__c.value;
        }
    }

validateData(){
        validateChildQuestions({recordId : this.recordId})
          .then(result =>{
            if(result==true){
              this.showData = true;
            }  
            else{
                this.showData = false;
            }  
          })
}

validateParentAnswersData(){
    validateParentAnswers({recordId : this.recordId})
      .then(result =>{
        if(result==true){
          this.showParentAnswerData = true;
        }  
        else{
            this.showParentAnswerData = false;
        }  
      })
}

validateChildAnswerData(){
    validateChildAnswers({recordId : this.recordId})
      .then(result =>{
        if(result==true){
          this.showChilData = true;
        }  
        else{
            this.showChilData = false;
        }  
      })
}

@track ShowInsufficientAccess = false;
EnvDetailAnswerRecords(){
        getParentAnswers({recordId : this.recordId})
          .then(result =>{
              this.items = [];
                  for(i=0; i<result.length; i++)  {
                    this.items = [...this.items ,{value: result[i].Id , label: result[i].Name} ];                                   
                }
                if(this.value == null || this.value == undefined || this.value == '') {
                    this.value = this.items[0].value;    
                }
          })
          .catch(error=>{
                if(error.status == 500){
                    this.ShowInsufficientAccess = true;
                }
                  this.errorEnvDetailAnswerData = error;
          });
}

get answerOptions() {
    return this.items;
}
dependentques=true;
handleparentAnswerChnage(event){
        this.value = event.target.value;
        this.EnvDetailAnswerRecords();
        this.getChildQuestionRecords();
        this.validateParentAnswersData();
        this.validateData();
        this.validateChildAnswerData();
        //this.template.querySelector('lightning-datatable').maxRowSelection=0;
        //this.template.querySelector('lightning-datatable').maxRowSelection=5;

}  

getChildQuestionRecords(){
    this.childQuestionIds = [];
    this.childQuestionitems = [];
    getChildQuestions({recordId : this.recordId})
      .then(result =>{
              for(i=0; i<result.length; i++)  {
                this.childQuestionitems = [...this.childQuestionitems ,{value: result[i].Id , label: result[i].Name}];     
                this.childQuestionIds.push(result[i].Id);                              
            }  
            this.getChildAnswerRecords();          
      })
      .catch(error=>{
            if(error.status == 500){
                this.ShowInsufficientAccess = true;
            }
              this.errorEnvDetailQuestionData = error;
      });
}

get childQuestionOptions() {
    return this.childQuestionitems;
}

handleChildQuestionChnage(event){
        const selectedQuestionOption = event.target.value;  
        this.chosenQuestionValue = selectedQuestionOption; 
        }

rowsSel = [];
disabledrows1 = [];
disabledrows = [];
async getChildAnswerRecords(){
    this.ChildAnswerRecords = [];
    await getChildAnswers({recordId : this.recordId, childQuestionIds : this.childQuestionIds})
      .then(result =>{
              this.ChildAnswerRecords = result;   
              
              for(let question of this.childQuestionitems) { 
                  for(let answer of this.ChildAnswerRecords) {
                      if(question.value == answer.questionId) {   
                          if(!question.hasOwnProperty('childQuestions')) {
                              question.childQuestions = [answer];
                            }
                              else {
                                  question.childQuestions.push(answer);
                              }
                        }
                    }
                }

                for(let question of this.childQuestionitems) {
                    for(let answer of question.childQuestions) {
                        if(answer.parentAnswer == this.value || answer.parentAnswer == undefined) {
                            answer.isDisabled = false;
                        } else {
                            answer.isDisabled = true
                        }
                    }
                }

                let answerMap = new Map();
                this.rowsSelected = this.rowsSel;
                this.disabledrows = this.disabledrows1;
      })
      .catch(error=>{
              this.errorChildAnswerRecords = error;
      });
}

selectedAnswers = [];

onchangeLineItems(event){
    let found = false;
    let isChecked = event.target.checked; 
    for(let answer of this.selectedAnswers) {
        if(answer.Id == event.target.value) {
            answer.isChecked = isChecked;
            found = true;        }
    }

    if(!found) {
        this.selectedAnswers.push({Id : event.target.value, isChecked : isChecked});
    }
}

handleRowSelection(event){
    let childAnswerData = event.detail.selectedRows;  
    this.selectedchildAnswerData = childAnswerData;
}

handleQuickSave(){
    this.isLoading=true;
    if(this.selectedAnswers.length > 0){
        saveDependentAnswers({recordId: this.value, selectedAnswers : JSON.stringify(this.selectedAnswers)})
         .then(result=>{
            if(result==true){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Records updated Successfully',
                        variant: 'success'
                    }));
            }
        })
        .catch(error =>{
            this.dispatchEvent(
                   new ShowToastEvent({
                       title: 'Error!',
                       message: 'something went wrong', 
                       variant: 'error'
                    })
            )
        })    
    }
    else {
        alert('No Dependent Answer is selected. Please select atleast one Dependent Answer');
        this.isLoading = false;
    }   
}

handleSave(){
    this.isLoading=true;
    if(this.selectedAnswers.length > 0){
        saveDependentAnswers({recordId: this.value, selectedAnswers : JSON.stringify(this.selectedAnswers)})
         .then(result=>{
            if(result==true){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Records updated Successfully',
                        variant: 'success'
                    }));
            }
            this.isLoading=false;
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Core_IPS_Question__c',
                    actionName: 'view'
                }
            });
        })
        .catch(error =>{
            this.dispatchEvent(
                   new ShowToastEvent({
                       title: 'Error!',
                       message: 'something went wrong', 
                       variant: 'error'
                    })
            )
        })    
    }
    else {
        alert('No Dependent Answer is selected. Please select atleast one Dependent Answer');
        this.isLoading = false;
    }   
}

exitAction(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Core_IPS_Question__c',
                actionName: 'view'
            }
        });    
    }
}