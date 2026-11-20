import { LightningElement,api } from 'lwc';

export default class Core_IPS_dynamicformbuilder extends LightningElement {
    @api iscommunity;
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
    /*connectedCallback(){
       // console.log('in form builder fields ', this.fields);
        //console.log('in form builder fields comp '+ this.fields);
        //console.log('form builder stringify ');// JSON.stringify(this.fields));
        //console.log('in form builder fields ', this.field.label);
        //console.log('in dynamic form builder mode =>',this.executionMode);
        //console.log('case id from case ', this.caseId);
      
    }*/
    @api callhandleQuestionAnswer(){
        this.template.querySelectorAll("c-core_-i-p-s_dynamicfield")
        .forEach(element => {
            element.handleQuestionAnswer();
        });
        this.template.querySelectorAll("c-core_-i-p-s_dynamicdependentfield")
        .forEach(element => {
            element.handleQuestionAnswerDependentField();
        });
        
    }
    
}