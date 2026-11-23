/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
import getchilddataBasedonQuestionID from "@salesforce/apex/ipsInternalCaseCreateLWCController.basedonSelectedandQuestionValue";

//import getSubCategoryDetails from "@salesforce/apex/ipsInternalCaseCreateLWCController.getSubCatProductEDQ";
export default class showSubCategoryedqSection extends LightningElement {

    @api subCatID = [];
    @track previousID;
    // @api subsCatedq = [];
    @track showcatEDQ = true;
    @track records = [];
    @track errors;
    @track questnID;
    @track dependentquestionlist;
    @track selectID;
    @api reshowsubChildQuestion = [];

    @track openmodel = false;
    @api openmodal() {
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false
    }
    saveMethod() {
        //  alert('save method invoked');
        this.closeModal();
    }

    handleonanswerselected(event) {

        this.selectID = event.detail.recordId;
        this.dependentquestionlist = event.detail.record;

        console.log("this.questnID" + JSON.stringify(this.dependentquestionlist));
        //recordId: this.answerDependentID,
        //        record: this.dependentChildData
        this.questnID = "'" + this.dependentquestionlist + "'";
        if (this.selectID !== null) {

            //getchilddataBasedonQuestionID
            // getchilddata
            getchilddataBasedonQuestionID({
                selectedProductId: this.selectID,
                childquestionsrecords: this.questnID

            })
                .then(result => {
                    // console.log("child >>edq");
                    if (result !== undefined || result !== null) {


                        console.log('subcateedqchild2' + JSON.stringify(result));
                        if (result.length > 0) {
                            //let c = "[data-id='overview']";
                            console.log('subcateedqchild');

                            this.reshowsubChildQuestion = result;
                            if (this.reshowsubChildQuestion.length > 0) {
                                for (let i = 0; i < this.reshowsubChildQuestion.length; i++) {
                                    console.log(this.reshowsubChildQuestion[i].isVisible)
                                    if (this.reshowsubChildQuestion[i].isVisible === true) {
                                        this.openmodal();
                                    }

                                }

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

    @api callhandleQuestionAnswerSubCat() {
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
                element.handleQuestionAnswerSubCat();
            });
    }
    // @wire(getSubCategoryDetails, { supportedProductId: null, subCatID: '$subCatID', isAgent: false })
    //  record;

    /*@wire(getSubCategoryDetails, {
        supportedProductId: null,
        subCatID: '$subCatID',
        isAgent: false
    })
    wiredCases({
        data,
        error
    }) {
        if (data) {
            console.log('test' + this.subCatID);
            console.log('maindata' + data);
            this.records = data;
            console.log("EDO" + (data));
            console.log("EDO1" + JSON.stringify(data));
            console.log("EDO2" + data);
            console.log('this.records' + this.records);
            this.errors = undefined;
        }
        if (error) {
            this.records = undefined;
            this.errors = error;
        }
    }
*/

    /*connectedCallback() {
        console.log('test2');
        if (this.subCatID !== null) {
            this.previousID = this.subCatID;
            // this.previousID = this.subCatID;
            console.log("subsCatedq>>" + this.subCatID);
            console.log("pageSize>>rev" + this.pageSize);
            console.log("previousID>>rev" + this.previousID);
            getSubCategoryDetails({
                supportedProductId: null,
                subCategoryid: this.subCatID,
                //'a263F0000003YKoQAM',
                //this.previousID,
                isAgent: false,
                //  this.productid.Core_Supported_Product__c,
                // this.productid.Core_Supported_Product__c,a2E3F0000009LOBUA2 a2E3F0000009LQRUA2

            })
                .then(result => {
                    console.log("edq");
                    if (result !== undefined || result !== null) {


                        console.log("EDO" + (result));
                        console.log("EDO1" + JSON.stringify(result[0].label));
                        console.log("EDO2" + result[0].type);
                        this.subsCatedq = result;
                        if (this.subsCatedq.length > 0) {
                            this.showcatEDQ = true;
                        }
                        // this.showProductSection = true;
                        this.error = undefined;

                    }
                })
                .catch(error1 => {
                    this.error = error1;
                    if (error1 !== undefined) {
                        console.log("this.edq" + JSON.stringify(error1));
                    }

                });

        }
    }*/
}