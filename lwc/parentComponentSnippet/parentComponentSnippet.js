/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import {
    LightningElement,
    wire,
    api,
    track
} from 'lwc';
import getProductedqdetails from "@salesforce/apex/ipsInternalCaseCreateLWCController.getProductEDQ";
import getchilddata from "@salesforce/apex/ipsInternalCaseCreateLWCController.DependentQuestionsLWC";
import getchilddataBasedonQuestionID from "@salesforce/apex/ipsInternalCaseCreateLWCController.basedonSelectedandQuestionValue";
export default class ParentComponentSnippet extends LightningElement {

    @api agentVisibilityEDQ;
    @api supportedProductID;
    @api recordsedq = [];
    @track showEDQ = false;
    @api containsDependentChildEDQ = [];
    @track selectID;
    @track dependentquestionlist = [];
    @api reshowChildQuestion = [];
    @track questnID = [];
    @track guid;
    @api savealledq = [];
    @api isLoaded = false;

    //child values
    @track childquestionlist = 'anish';
    // @api
    // get label() {
    //   return this.childquestionlist;
    //  }

    // set label(value) {
    //this.childquestionlist = value.toUpperCase();
    //     this.setAttribute('label', this.childquestionlist);
    //  }

    @track openmodel = false;
    @api openmodal() {
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false
    }
    saveMethod() {

        // var inp = this.template.querySelectorAll("c-dynamic-question");
        //console.log(inp.value);

        //alert('save method invoked');
        //this.template.querySelectorAll(".maint")
        //    .forEach(element => {
        //        element.handleQuestionAnswerforchild();
        //    });

        this.template.querySelectorAll("c-dynamic-question")
            .forEach(element => {
                element.handlechildonsave();
            });
        this.closeModal();
    }
    get childconditioncheck() {
        //  if (this.recordsedq.hasChildQuestions === true) {
        //this.recordsedq.hasChildQuestions;
        // }
        return this.JSON.stringify(this.recordsedq.childQuestions.isVisible) === true ? true : false;
    }

    connectedCallback() {
        console.log("shouwedqcomp>>" + this.supportedProductID);
        console.log("shouwedqcomp>>" + this.agentVisibilityEDQ);
        getProductedqdetails({
            supportedProductId: 'a2E3F0000000nnUUAQ',//this.supportedProductID
            subCategoryid: null,
            isAgent: this.agentVisibilityEDQ,
            //  this.productid.Core_Supported_Product__c,a2Eo00000019aP8EAI,a2E3F0000009AVzUAM,a2E3F0000000nnUUAQ
            // this.productid.Core_Supported_Product__c,a2E3F0000009LOBUA2 a2E3F0000009LQRUA2

        })
            .then(result => {
                console.log("edq");
                if (result !== undefined || result !== null) {


                    console.log("EDO" + (result));
                    //  console.log("EDO1" + JSON.stringify(result.childQuestions.isVisible));
                    // this.containsDependentChildEDQ = result[0].childQuestions[0];
                    console.log("containsDependentChildEDQ" + JSON.stringify(result));
                    this.recordsedq = result;
                    if (this.recordsedq.childQuestions !== null) {

                        //  for (let i = 0; i < this.recordsedq.length; i++) {

                        // console.log("insidemain>>>" + JSON.stringify(this.recordsedq[1].childQuestions[0].questionId));
                    }


                    // }
                    if (this.recordsedq.length > 0) {
                        // console.log('>>>>>>' + JSON.stringify(this.recordsedq.childQuestions.isVisible));
                        this.showEDQ = true;

                        const haveedq = new CustomEvent("ihaveedq", {
                            bubbles: true,
                            composed: true,
                            //detail : selectedRecordId
                            detail: {
                                edqsize: this.recordsedq

                            }
                        });
                        this.dispatchEvent(haveedq);
                    }
                    // this.showProductSection = true;
                    //this.error = undefined;

                }
            })
            .catch(error1 => {
                this.error = error1;
                if (error1 !== undefined) {
                    console.log("this.edq" + JSON.stringify(error1));
                }

            });

    }

    @api callhandleQuestionAnswer() {
        //    var da, i;
        //    console.log('this.savealledq.length' + this.savealledq.length);
        //    da = this.template.querySelectorAll('.main');
        //   console.log(' da.length' + da.length);
        //   for (i = 0; i < da.length; i++) {
        //       console.log('test' + da[i].dataId);
        //      da[i].style.backgroundColor = "red";
        //   }

        //this.template.querySelector('c-dynamic-question').handleQuestionAnswer();
        this.template.querySelectorAll("c-dynamic-question")
            .forEach(element => {
                element.handleQuestionAnswer();
            });


    }
    @api handleQuestionAnswerforchild() {
        console.log('bababababab');
    }
    // handleallquestionanswer(event) {
    // this.savealledq = 
    //   console.log('ale');
    //  this.savealledq.push(['qquestion='.concat("'" + event.detail.qquestion + "'"), 'llabel='.concat("'" + event.detail.llabel + "'"), 'vvalue='.concat("'" + event.detail.vvalue + "'"), 'rrequired='.concat("'" + event.detail.rrequired + "'")]);
    //  console.log('this.savealledq' + this.savealledq.length);
    //  for (let i = 0; i < this.savealledq.length; i++) {
    //      console.log('this.data' + JSON.stringify(this.savealledq[i]));
    //  }
    //}
    handleonanswerselected(event) {
        this.selectID = event.detail.recordId;
        this.dependentquestionlist = event.detail.record;
        console.log(" this.selectID" + this.selectID);
        console.log("this.dependentquestionlist" + JSON.stringify(this.dependentquestionlist));
        //console.log("this.dependentquestionlist" + JSON.parse(this.dependentquestionlist));
        //if (this.dependentquestionlist !== null) {
        //    this.questnID = '';
        //    for (let i = 0; i < this.dependentquestionlist.length; i++) {
        //        this.questnID = this.questnID + ",'" + this.dependentquestionlist[i].questionId + "'";
        //       console.log("this>>>>questnID" + JSON.stringify(this.questnID));
        // }
        // }
        console.log("this.questnID" + JSON.stringify(this.dependentquestionlist));
        //recordId: this.answerDependentID,
        //        record: this.dependentChildData
        this.questnID = "'" + this.dependentquestionlist + "'";
        if (this.selectID !== null) {

            //getchilddataBasedonQuestionID
            // getchilddata
            this.isLoaded = true;
            getchilddataBasedonQuestionID({
                selectedProductId: this.selectID,
                childquestionsrecords: this.questnID

            })
                .then(result => {
                    // console.log("child >>edq");
                    if (result !== undefined || result !== null) {


                        //    console.log("child >>edq2" + (result));

                        // console.log("child >>edq3" + JSON.stringify(result[0]));
                        // this.reshowChildQuestion = ;



                        if (result.length > 0) {
                            //let c = "[data-id='overview']";


                            //let splitId = this.guid.Split("-");
                            //console.log('this.splitId' + splitId);
                            // if ('a2x3F0000000jpWQAQ' === result[0].parentQuestionID) {

                            // let id = 'a2x3F0000000jpWQAQ';.getAttribute('data-id')
                            //  let divid = this.template.querySelector('.main').getAttribute('id').
                            // this.setAttribute('label', 'this.reshowChildQuestion[0].label');
                            // const tabindex = this.getAttribute('tabindex');
                            //f.setAttribute('label', 'this.reshowChildQuestion[0].label');


                            //  } else {
                            //     console.log('this.elser>>>');
                            //     this.template.querySelector('.main').remove('slds-hide');
                            // }
                            this.reshowChildQuestion = result;
                            console.log('Child Question/Answer' + JSON.stringify(this.reshowChildQuestion));
                            if (this.reshowChildQuestion.length > 0) {
                                for (let i = 0; i < this.reshowChildQuestion.length; i++) {
                                    // console.log(this.reshowChildQuestion[i].isVisible)
                                    if (this.reshowChildQuestion[i].isVisible === true) {
                                        this.isLoaded = false;
                                        //this.openmodal();
                                        console.log('Parent Question ID from backend for which we need to display child question after particular parent question ID >' + this.reshowChildQuestion[i].parentQuestionID);// compare it with div id and if its equal set child questions below that
                                        //let divid = this.template.querySelector('.main').getAttribute('id');
                                        this.template.querySelector(this.reshowChildQuestion[i].parentQuestionID).innerHtml = 'helloworld';
                                        //console.log('Dynamic Div ID >' + divid);
                                        console.log('Dynamic Div ID >' + this.template.querySelector(this.reshowChildQuestion[i].parentQuestionID).innerHtml);
                                    }
                                    this.isLoaded = false;
                                }

                            }


                        }

                    }
                })
                .catch(error => {
                    console.log("this.edq>>1" + error);
                    this.error = error;
                    if (error !== undefined) {
                        console.log("this.edq>>" + JSON.stringify(error));
                    }

                });

        }

    }


}