/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Core_IPSPortal_dynamicQuestion extends LightningElement {

    @api optionss;
    @api type;
    @api questionlist;
    @api answerlist;
    @api requiredfields;
    @api placeholderpicklist;
    @api placeholdertext;
    @api value = [];
    @track _selected = [];
    @track questnlist;
    @api isChildQuestion;
    @track answerDependentID;
    @api dependentChildData = [];
    @track ischildvisible;
    @api questionid;
    @track parentquestion;
    @track label;
    @track globalmap = [];
    @track datamap = [];
    @api edqsavealldata = [];
    @api childiterate;
    @api parentid;
    @api parentiterate;
    @api subcatvaluem;


    connectedCallback() {

        this.questnlist = this.questionlist;

    }

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

    @api handlechildonsave() {
        var da, valued, require;
        var checkval = true;
        var inputCmpChild = this.template.querySelector(".inputdat");
        // console.log('inputCmp>' + inputCmp.length());
        // inp = this.template.querySelector("lightning-input");
        // console.log('inp>' + inp);
        console.log('crequired>' + inputCmpChild.label);
        console.log('crequired>' + inputCmpChild.title);
        da = this.type;
        console.log('da>' + da);
        valued = inputCmpChild.value;
        require = inputCmpChild.required;
        // }
        if (da === 'Multiselect Picklist') {
            // for (let i = 0; i < valued.length; i++) {
            valued = valued.toString();

        }
        console.log('valllllll' + valued);
        //}
        if (inputCmpChild.title === 'ani') {
            const selectedquestionanswerin = new CustomEvent("inselectedquestionanswer", {
                bubbles: true,
                composed: true,
                //detail : selectedRecordId
                detail: {
                    qquestion: inputCmpChild.name,
                    llabel: inputCmpChild.label,
                    vvalue: valued,
                    rrequired: require,
                    ttype: da,
                    val: checkval,
                    child: 'yes'
                }
            });
            this.dispatchEvent(selectedquestionanswerin);
        }
        // const inputCmpChild2 = this.template.querySelectorAll(".dat");
        // inputCmpChild2.forEach(e => { console.log(e); })
        // console.log('inputCmpChild2>' + inputCmpChild2);
    }

    @api handleQuestionAnswer() {
            var da;
            var checkval = true;
            var valued = "";
            var require = "";
            var inputCmp = this.template.querySelector(".inputdat");
            // console.log('inputCmp>' + inputCmp);
            console.log('required>' + inputCmp.required);
            console.log('label>' + inputCmp.label);
            console.log('value>' + this.type);
            da = this.type;
            // is input is valid?

            //if (inputCmp) {
            valued = inputCmp.value;
            require = inputCmp.required;
            console.log('Inside handleQuestionAnswer require:', require);
            // }
            if (da === 'Multiselect Picklist') {
                // for (let i = 0; i < valued.length; i++) {
                valued = valued.toString();

                // }

            }

            console.log('eorr>' + valued);
            if (valued === undefined) {
                valued = "";
                if (require === true) {
                    inputCmp.setCustomValidity("Please select/enter require fields");
                    checkval = false;
                }

                // this.showToast('ERROR', 'Please Select/Enter Required Fields', 'error');
            } else if (valued === "" || valued.length === 0) {
                console.log('yes');
                valued = "";
                if (require === true) {
                    inputCmp.setCustomValidity("Please select/enter require fields");
                    checkval = false;
                }
            } else if (valued === null) {
                console.log('aniyes');
                valued = "";
                // this.showToast('ERROR', 'Please Select/Enter Required Fields', 'error');
                if (require === true) {
                    inputCmp.setCustomValidity("Please select/enter require fields");
                    checkval = false;
                }

            } else {
                console.log('no');
                inputCmp.setCustomValidity(""); // if there was a custom error before, reset it

            }
            if (inputCmp != null) {
                inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction
            }
            //  console.log('child');

            console.log('child');
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



            [].forEach.call(
                this.template.querySelectorAll('.main'),
                function(el) {
                    //  for (let i = 0; i < el.length; i++) {
                    //     el[i].style.backgroundColor = "red";
                    //  }
                    // console.log('label' + el);
                    ////console.log('value' + el.value);
                    //  console.log('options' + el.options);
                    // console.log('child' + el.name);

                    // questionanswer = new Map();
                    // questionanswer.set(el.label, [el.label, el.value]);
                    // console.log('map' + questionanswer.get(el.label));
                }
            );
            //  da = this.template.querySelectorAll('.main');
            //   console.log(' da.length' + da.length);
            //  for (i = 0; i < da.length; i++) {
            //      da[i].style.backgroundColor = "red";
            //  }



        }
        //subcat validate edq
    @api handleQuestionAnswerSubCat() {
        var checkval = true;
        var valuedsubcat = "";
        var subtype;
        var requiresubcat = "";
        var inputCmp = this.template.querySelector(".inputdat");
        console.log('Subcategoryvalidate');
        console.log('inputCmp>' + inputCmp);
        console.log('required>' + inputCmp.required);
        subtype = this.type
            // is input is valid?

        //if (inputCmp) {
        valuedsubcat = inputCmp.value;
        requiresubcat = inputCmp.required;
        // }
        if (subtype === 'Multiselect Picklist') {
            // for (let i = 0; i < valued.length; i++) {
            valuedsubcat = valuedsubcat.toString();

            // }

        }
        console.log('valuedsubcat>' + valuedsubcat);
        if (valuedsubcat === undefined) {
            if (requiresubcat === true) {
                inputCmp.setCustomValidity("Please Select/Enter Required Fields");
                checkval = false;
            }

            // this.showToast('ERROR', 'Please Select/Enter Required Fields', 'error');
        } else if (valuedsubcat === "" || valuedsubcat.length === 0) {
            valuedsubcat = "";
            console.log('yes');
            if (requiresubcat === true) {
                inputCmp.setCustomValidity("Please Select/Enter Required Fields");
                checkval = false;
            }
        } else if (valuedsubcat === null) {
            console.log('aniyes');
            // this.showToast('ERROR', 'Please Select/Enter Required Fields', 'error');
            if (requiresubcat === true) {
                inputCmp.setCustomValidity("Please Select/Enter Required Fields");
                checkval = false;
            }

        } else {
            console.log('no');
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
                vvalue: valuedsubcat,
                rrequired: requiresubcat,
                ttype: subtype,
                val: checkval,
                child: 'no'
            }
        });
        this.dispatchEvent(selectedquestionanswerin);
    }


    handleChangesss(event) {
        var checkval = true;
        var questionanswer = new Map();
        event.preventDefault();
        this.subcatvaluem = event.target.value;
        console.log('label' + event.target.label);
        this.label = event.target.label;
        console.log('question' + event.target.name);
        console.log('options' + event.target.options);
        console.log('questionid' + this.questionid);
        // this.globalmap.push(this.questionid, [this.label, this.value]);
        //  this.datamap = [...this.datamap, this.globalmap];
        //console.log('this.datamap' + this.datamap);
        //for (var i = 0; i < this.globalmap.length; i++) {
        // console.log('anishmap' + this.globalmap);
        // }

        if (this.type === 'Multiselect Picklist') {
            this.subcatvaluem = this.subcatvaluem.toString();

        }
        //data.split(" ").splice(-1)
        // questionanswer.set(this.questionid, [this.label, this.value]);
        console.log('map' + questionanswer.get(this.questionid));

        /*    const selectedquestionanswerin = new CustomEvent("inselectedquestionanswer", {
                bubbles: true,
                composed: true,
                //detail : selectedRecordId
                detail: {
                    qquestion: event.target.name,
                    llabel: event.target.label,
                    vvalue: this.subcatvaluem,
                    rrequired: this.requiredfields,
                    ttype: this.type,
                    val: checkval
                }
            });
            this.dispatchEvent(selectedquestionanswerin);*/


        [].forEach.call(
            this.template.querySelectorAll('.main'),
            function(el) {
                // console.log('label' + el.label);
                // console.log('value' + el.value);
                // console.log('options' + el.options);
                // console.log('child' + el.name);
                // questionanswer = new Map();
                // questionanswer.set(el.label, [el.label, el.value]);
                // console.log('map' + questionanswer.get(el.label));
            }
        );
        //validation
        //  if (this.requiredfields === true && (this.value === null || this.value === undefined)) {
        //      this.showToast('ERROR', 'Please Select Contact', 'error');
        //     this.isValid = false;
        //  }


    }






    get options() {
        return [
            { label: 'English', value: 'en' },
            { label: 'German', value: 'de' },
            { label: 'Spanish', value: 'es' },
            { label: 'French', value: 'fr' },
            { label: 'Italian', value: 'it' },
            { label: 'Japanese', value: 'ja' },
        ];
    }

    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    handleChanged(e) {
        this._selected = e.detail.value;
    }

    loadDependentQuestion(event) {
        this.answerDependentID = event.detail.value;
        console.log('this.answerDependentID ' + this.answerDependentID);
        //console.log('childdata' + JSON.stringify(this.dependentChildData));



        //  this.timeoutId = setTimeout(this.doExpensiveThing.bind(this), 500); 

        const selectedDependentChildData = new CustomEvent("selecteddependentidchild", {
            //detail : selectedRecordId
            detail: {
                recordId: this.answerDependentID,
                record: this.questionid
            }
        });
        this.dispatchEvent(selectedDependentChildData);



    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}