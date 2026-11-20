import { LightningElement, api, track, wire } from 'lwc';
import getDependentQuestion from "@salesforce/apex/Core_IPS_MAG_Questionnaire_Lex.renderDependentQuestions";
export default class Magbuilder extends LightningElement {
    @api type;   // type of field
    @api fieldlabel;  // 
    @api lovs; // list of value
    @api isrequiredfield;
    @api placeholdertext;
    @api value = [];
    @api mvalue = [];
    @api fieldid;
    @api parentquesid;
    @api questionid;
    @api dependentques;
    @api recordid;
    @api ordernumber;
    @api answer;
    @api question;
    @api iseditable;
    @track sflag = false;
    @track flag = false;
    @track childResult =[];
    @track tempResult = [];
    @track none;

    get textcheck() {
        return this.type === 'text' ? true : false;
    }
    get piclistcheck() {
        return this.type === 'picklist' ? true : false;

    }
    get multiselectpiclistcheck() {
        return this.type === 'Multiselect Picklist' ? true : false;
    }
    get textareacheck() {
        return this.type === 'textarea' ? true : false;
    }
    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    handleChange(event) {
        let orderNo = this.ordernumber;
        let paramData = {ordernumber:orderNo};
        let ev = new CustomEvent('childmethod',
        {detail : paramData}
                                );
            this.dispatchEvent(ev);
        let value = event.target.value;
        this.childResult = [];
        console.log('EVEntShiad-->'+value);
        this.none = this.lovs[this.lovs.length -1].value;
        const result = value.includes(this.none);
        if(result){
        console.log('EVEnYes==>'+result);
        this.mvalue = [];
        this.mvalue.push(this.none);
        value = this.none;
        console.log('EVEnres2==>'+value);
        }
        getDependentQuestion({orderNumber:this.ordernumber,recordId:this.recordid})
        .then(result=>{
             for(let i =0; i<result.length; i++) {
                if(result[i].parentQuestionId == value) {
                    this.childResult = result[i];
                    this.flag = true;
                } 
             }
             if(this.childResult.length == 0){
                this.flag = false;
             }
        })
        .catch(error=>{
        })
    }
    @api callhandleQuestionAnswer(){
        this.handleQuestionAnswer();
        this.template.querySelectorAll("c-magchildbuilder")
        .forEach(element => {
            element.handleQuestionAnswer();
        });
    }
    handleQuestionAnswer() {
        var da;
        var checkval = true;
        var valued = "";
        var require = "";
        var inputCmp = this.template.querySelector(".inputdat");
        da = this.type;
        valued = inputCmp.value;
        require = inputCmp.required;
        if (da === 'Multiselect Picklist') {
            valued = valued.toString();
        }

        if (valued === undefined) {
            valued = "";
            if (require === true) {
                inputCmp.setCustomValidity("Please select/enter require fields");
                checkval = false;
            }
        }
        else if (valued === "" || valued.length === 0) {
            valued = "";
            if (require === true) {
                inputCmp.setCustomValidity("Please select/enter require fields");
                checkval = false;
            }
        }
        else if (valued === null) {
            valued = "";
            if (require === true) {
                inputCmp.setCustomValidity("Please select/enter require fields");
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
            detail: {
                qquestion: inputCmp.name,
                question: this.questionid,
                selectedValues: valued,
                required: require,
                answerType: da,
                dependentQues: this.dependentQues,
                val: checkval,
                child: 'No'
            }
        });
        this.dispatchEvent(selectedquestionanswerin);
    }
}