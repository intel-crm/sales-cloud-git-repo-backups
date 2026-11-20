import { LightningElement,api } from 'lwc';

export default class DynamicFormBuilder extends LightningElement {
    @api iscommunity;
    @api iscummunitydropdown;
   
    @api type;   // type of field
    @api fieldLabel;  // 
    @api lovs; // list of value
    @api isrequiredfield;
    @api placeholdertext;
    @api value = [];
    @api fieldid;
    @api hasChild;

    @api fieldMapping;
    @api fields;
    @api executionMode;
    @api caseId;
    @api supportedProductId;
    @api mode;
    
    @api callhandleQuestionAnswer(){
        this.template.querySelectorAll("c-dynamic-field")
        .forEach(element => {
            element.handleQuestionAnswer();
        });
        this.template.querySelectorAll("c-dynamic-dependent-field")
        .forEach(element => {
            element.handleQuestionAnswerDependentField();
        });
        
    }
    
}