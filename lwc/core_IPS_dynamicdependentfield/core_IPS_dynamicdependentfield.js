/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDependentField from "@salesforce/apex/DynamicLWCFormBuilderController.getDependentDynamicFields";
import getExistingResponses from "@salesforce/apex/Core_IPS_Questions_Utility.getEnvDetailCoreResponseField";

export default class core_IPS_DynamicQuestion extends LightningElement {
    
    @api type;   // type of field
    @api fieldlabel;  // 
    @api lovs; // list of value
    @api isrequiredfield;
    @api placeholdertext;
    @api value = [];
    @api fieldid;
    @api executeMode;
    @api csId;
    @api productId;

    @track renderChildQuestions;
    @track dependetQuestions;
    @track isLoaded = false;

    get piclistcheck() {
        return this.type === 'Picklist' ? true : false;
    }

    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    handleChanged(e) {
        this._selected = e.detail.value;
    }
    async connectedCallback(){
        if((this.executeMode == 'edit'|| this.executeMode == 'copy') && (this.csId != undefined)){

            let responseData;
            await getExistingResponses({
                caseId: this.csId,
                fieldId: this.fieldid
            })
            .then(data=>{
                responseData= data;
            })
            .catch(error=>{
                console.log('error occured in getting existing responses ', error);
            })


            getDependentField({  
                selectedValue: this.value,
                FieldId: "'" + this.fieldid + "'",
                supProdId: this.productId
            }) 
            .then(result => {    
                if (result !== undefined || result !== null) {
                    if (result.length > 0) {
                        let tempVar = result;
                        for(let i=0; i<tempVar.length;i++){
                            for(let j=0;j<responseData.length;j++){
                                if(tempVar[i].questionId == responseData[j].Core_IPS_Question_Master__c){
                                    tempVar[i].selectedValue = responseData[j].Core_IPS_Answer_Master__c;
                                }
                            }
                        }
                        
                        this.dependetQuestions = tempVar;
                        if (this.dependetQuestions.length > 0) {
                            this.renderChildQuestions = true;
                        }  
                    }
                }
            })
            .catch(error => {
                this.error = error;
                if (error !== undefined) {
                    console.log("this.edq>>" + JSON.stringify(error));
                }
            });
        }
    }
    // Load child questions based on parent question
    loadDependentFields(event) {
        this.isLoaded = true;
        this.parentAnswerId = event.detail.value;
        this.parentQuestionId = this.fieldid;
        this.dependetQuestions = []; // Added by Hassan Khan for Child EDQ Fix.
        if (this.parentAnswerId !== null) {

            //getDependentField
            //this.isLoaded = true;
            
            getDependentField({  
                selectedValue: this.parentAnswerId,
                FieldId: "'" + this.parentQuestionId + "'",
                supProdId: this.productId

            }) 
                .then(result => {
                    if (result !== undefined || result !== null) {
                        if (result.length > 0) {
                            //let c = "[data-id='overview']";

                            this.dependetQuestions = result;
                            this.isLoaded = false;
                            console.log('childdata?>>' + JSON.stringify(this.dependetQuestions));
                            if (this.dependetQuestions.length > 0) {
                               /* for (let i = 0; i < this.dependetQuestions.length; i++) {
                                    console.log(this.dependetQuestions[i].isVisible)
                                    if (this.dependetQuestions[i].isVisible === true) {
                                        this.isLoaded = false;
                                        this.renderChildQuestions = true;
                                    }
                                    this.isLoaded = false;
                                }*/
                                this.renderChildQuestions = true;
                            }  
                        }
                    }
                })
                .catch(error => {
                    console.log("this.edq>>1" + JSON.stringify(error));
                    this.error = error;
                    if (error !== undefined) {
                        console.log("this.edq>>" + JSON.stringify(error));
                    }
                });
        }
        
    }

    @api handleQuestionAnswerDependentField() {
        var type = 'Picklist';
        var da;
        var checkval = true; //false;
        var valued = "";
        var require = "";
        var inputCmp = this.template.querySelector(".inputdat");
        da = type;
        // Started By Hassan Khan to Fix Validation
        if(da === 'Multiselect Picklist'){
            valued = inputCmp.value; 
        }else{
            valued = inputCmp.value.trim(); // Trim Function Added by Hassan Khan for Validation
        }
        require = inputCmp.required;
        // Finished By Hassan Khan
        if (inputCmp.value === "" || inputCmp.value === undefined || inputCmp.value === null) {
            if (inputCmp.required === true) {
                inputCmp.setCustomValidity("Please select/enter require fields");
                checkval = false;
            }
        }
        if (inputCmp != null) {
            inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction
        }
                 
        const selectedquestionanswerin = new CustomEvent("inselectedquestionanswer", {
            bubbles: true,
            composed: true,   
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

        
       // this.template.querySelectorAll("c-dynamic-field")
        this.template.querySelectorAll("c-core_-i-p-s_dynamicfield") 
        .forEach(element => {
            element.handleQuestionAnswer();
        });
    }
}