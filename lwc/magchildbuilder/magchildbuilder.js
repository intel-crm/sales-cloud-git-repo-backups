import { LightningElement,api } from 'lwc';

export default class Magchildbuilder extends LightningElement {
    @api type;   // type of field
    @api fieldlabel;  // 
    @api lovs; // list of value
    @api isrequiredfield;
    @api placeholdertext;
    @api value;
    @api mvalue;
    @api fieldid;
    @api parentquesid;
    @api dependentques;
    @api iseditable;
    @api recordid;
    @api ordernumber;
    @api answer;
    @api questionid;

    get textcheck() {
        return this.type === 'text' ? true : false;
    }

    get textareacheck() {
        return this.type === 'textarea' ? true : false;
    }

    @api handleQuestionAnswer() {
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
                console.log('1');
                inputCmp.setCustomValidity("Please select/enter require fields");
                checkval = false;
            }
        }
        else if (valued === "" || valued.length === 0) {
            valued = "";
            if (require === true) {
                console.log('2');
                inputCmp.setCustomValidity("Please select/enter require fields");
                checkval = false;
            }
        }
        else if (valued === null) {
            valued = "";
            if (require === true) {
                console.log('3');
                inputCmp.setCustomValidity("Please select/enter require fields");
                checkval = false;
            }

        }
        else {
            console.log('4');
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
                answer: this.answer,
                val: checkval,
                child: 'Yes'
            }
        });
        this.dispatchEvent(selectedquestionanswerin);
    }
}