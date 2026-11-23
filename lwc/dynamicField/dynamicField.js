/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import Core_IPS_Exceeding_the_char_length from '@salesforce/label/c.Core_IPS_Exceeding_the_char_length';

export default class dynamicQuestion extends LightningElement {

    //@api optionss;
    @api commcheck;
    @api iscombo;
    @api type;   // type of field
    @api fieldlabel;  // 
    @api lovs; // list of value
    @api isrequiredfield;
    @api placeholdertext;
    @api value = [];
    @api mvalue = [];
    @api fieldid;
    @api fielditself;
    @api mode;
    @track picklistValue;
    //Sowmya start - INC14903157 - Applied fix on exceeding Char length on Long text Area              
    islengtherr = false;
    @track label = {
        Core_IPS_Exceeding_the_char_length
       
    };
    //Sowmya End
 
    connectedCallback() {
        
        if(this.type == 'Picklist'){
            if(this.fielditself.lovs == null || this.fielditself.lovs == undefined || this.fielditself.lovs == ''){
                this.fromDependentField = true;
            } else {
                this.fromDependentField = false;
            }
        }

        if(this.mode == 'sslc' && this.mode != '' && this.mode != null && this.mode != undefined){
            if(this.fielditself.label == 'Case Subcategory Detail'){
                let templovs = this.fielditself.lovs;
                for (let k = 0; k < templovs.length; k++) {
                    if (templovs[k].label == "Licensing self service") {
                        this.picklistValue = templovs[k].value;
                        break;
                    } 
                    else {
                        this.picklistValue = this.fielditself.value;
                    }
                }    
            }
            else{
                this.picklistValue = this.fielditself.value;
            }
        }
        else{
            this.picklistValue = this.fielditself.value;
        }
    }
   // @api edqsavealldata = [];
   // @api parentid;
   // @api subcatvaluem;
   // @api placeholderpicklist;
   // @api isChildQuestion;
   // @api dependentChildData = [];
   // @api parentiterate;
   // @api childiterate;

  //  @track _selected = [];
  //  @track questnlist;
  //  @track answerDependentID;
  //  @track ischildvisible;
  //  @track parentquestion;
  //  @track label;
  //  @track globalmap = [];
  //  @track datamap = [];
  
    get textcheck() {
        return this.type === 'Text' ? true : false;
    }
    get piclistcheck() {
        return this.type === 'Picklist' ? true : false;

    }
    get multiselectpiclistcheck() {
        return this.type === 'Multiselect Picklist' ? true : false;
    }
    get textareacheck() {
        return this.type === 'Text Area' ? true : false;
    }
    get selected() {
        return this._selected.length ? this._selected : 'none';
    }    
    @api handleQuestionAnswer() {
        var da;
        var checkval = true;
        var valued = "";
        var require = "";
        var inputCmp = this.template.querySelector(".inputdat");
        var inputCm =  this.template.querySelector(".inputda");
        da = this.type;

        //Sowmya start - INC14903157 - Applied fix on exceeding Char length on Long text Area-->
        if(da === 'Text Area'){
            if(inputCmp.value.length>5000){
                this.islengtherr=true;
                this.template.querySelector('lightning-textarea')?.classList.add('showRequired');
                this.template.querySelector('lightning-textarea')?.scrollIntoView();
            checkval = false;
            
            }
        }
        //Sowmya end
        // Started By Hassan Khan to Fix Validation
        if(da != 'Multiselect Picklist'){
            valued = inputCmp.value;
            
        }
        if(da === 'Multiselect Picklist'){
            valued = inputCmp.value;
            valued = valued.toString();
        }
        require = inputCmp.required;
        // Finished By Hassan Khan

        if (valued === undefined) {
            valued = "";
            if (require === true) {
                inputCmp.setCustomValidity("Complete this field.");
                checkval = false;
            }

            // this.showToast('ERROR', 'Please Select/Enter Required Fields', 'error');
        }
        else if (valued === "" || valued.length === 0) {
            valued = "";
            if (require === true) {
                inputCmp.setCustomValidity("Complete this field.");
                if(da === 'Multiselect Picklist'){
                    this.template.querySelector('lightning-dual-listbox').classList.add('showRequiredProducts');
                } 
                checkval = false;
            }
        }
        else if (valued === null) {
            valued = "";
            // this.showToast('ERROR', 'Please Select/Enter Required Fields', 'error');
            if (require === true) {
                this.isrequiredfield = true;
                inputCmp.setCustomValidity("Complete this field.");
                checkval = false;
            }

        }
        else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it

        }
        if (inputCmp != null) {
            inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction
        }
        const selectedquestionanswerin = new CustomEvent("inselectedquestionanswer", {
            bubbles: true,
            composed: true,
            //detail : selectedRecordId
            detail: {
                qquestion: inputCmp.name,
                llabel: inputCmp.label,
                vvalue: valued,
                rrequired: require,
                ttype: da,
                val: checkval,
                child: 'no'
            }
        });
        this.dispatchEvent(selectedquestionanswerin);



    }

     handleChange(event){
        var dualListId = event.target;
        event.target.reportValidity();
        this.template.querySelector('lightning-dual-listbox').classList.remove('showRequiredProducts');
        this.template.querySelector('lightning-dual-listbox').setCustomValidity("");
        this.template.querySelector('lightning-dual-listbox').reportValidity();
    }


     handleTextChange(event){
        if(this.type === 'Text') {
            this.template.querySelector('lightning-input').classList.remove('showRequiredProducts');
            this.template.querySelector('lightning-input').setCustomValidity("");
            this.template.querySelector('lightning-input').reportValidity();
        }
        if(this.type === 'Text Area') {
            this.template.querySelector('lightning-textarea').classList.remove('showRequiredProducts');
            this.template.querySelector('lightning-textarea').setCustomValidity("");
            this.template.querySelector('lightning-textarea').reportValidity();
             //Sowmya start - INC14903157 - Applied fix on exceeding Char length on Long text Area
               this.islengtherr=false;
               this.template.querySelector('lightning-textarea')?.classList.remove('showRequired');
            //Sowmya end
       
        }
        if(this.type === 'Picklist') {
            this.template.querySelector('lightning-combobox').setCustomValidity("");
            this.template.querySelector('lightning-combobox').reportValidity();
        }

    }

}