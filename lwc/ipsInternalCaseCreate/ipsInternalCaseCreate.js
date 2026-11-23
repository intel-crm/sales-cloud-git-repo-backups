/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import {
    LightningElement,
    wire,
    api,
    track
} from 'lwc';

import {
    getPicklistValues,
    getObjectInfo
} from 'lightning/uiObjectInfoApi';

import Case_OBJECT from '@salesforce/schema/Case';
import Case_Source from '@salesforce/schema/Case.Core_IPS_Issue_source__c';
import Case_Type from '@salesforce/schema/Case.Core_CaseType__c';
import Case_Severity from '@salesforce/schema/Case.Core_Severity__c';
import showVariants from "@salesforce/apex/ipsInternalCaseCreateLWCController.getvariant";
import showCategory from "@salesforce/apex/ipsInternalCaseCreateLWCController.getCategoryDetails";
import showsubCategory from "@salesforce/apex/ipsInternalCaseCreateLWCController.getSubCategoryDetail";
import getSubCategoryDetails from "@salesforce/apex/ipsInternalCaseCreateLWCController.getSubCatProductEDQ";
import getAgent from "@salesforce/apex/ipsInternalCaseCreateLWCController.getAgentDetail";
import getPlatfrm from "@salesforce/apex/ipsInternalCaseCreateLWCController.getPlatformDetails";
import saveCaseRecord from "@salesforce/apex/ipsInternalCaseCreateLWCController.saveCaseRecord";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import contectErrorMessage from '@salesforce/label/c.Core_IPS_ContactErrorMessage_LWC';
import productErrorMessage from '@salesforce/label/c.Core_IPS_ProductErrorMessage_LWC';
import contAndProdErrorMessage from '@salesforce/label/c.Core_IPS_ConAndProdErrorMessage_LWC';
import contactIdErrorMessage from '@salesforce/label/c.Core_IPS_ContactIdErrorMessage_LWC';
import productIdErrorMessage from '@salesforce/label/c.Core_IPS_ProductIdErrorMessage_LWC';
import caseErrorMessage from '@salesforce/label/c.Core_IPS_CaseErrorMessage_LWC';
import caseTypeErrorMessage from '@salesforce/label/c.Core_IPS_CaseTypeErrorMessage_LWC';
import caseSubjectErrorMessage from '@salesforce/label/c.Core_IPS_CaseSubjectErrorMessage_LWC';
import caseDescErrorMessage from '@salesforce/label/c.Core_IPS_CaseDescErrorMessage_LWC';
import caseSeverityErrorMessage from '@salesforce/label/c.Core_IPS_CaseSeverityErrorMessage_LWC';
import caseCategoryErrorMessage from '@salesforce/label/c.Core_IPS_CaseCategoryErrorMessage_LWC';
import CaseSubCategoryErrorMessage from '@salesforce/label/c.Core_IPS_CaseSubCategoryErrorMessage_LWC';


export default class ipsInternalCaseCreate extends NavigationMixin(LightningElement) {


    constructor() {
        super();
        // this.template.addEventListener('notification', this.handleNotification.bind(this));
        this.template.addEventListener('inselectedquestionanswer', this.handleChangeChild.bind(this));
        this.template.addEventListener('ihaveedq', this.checkproductedqsize.bind(this));


    }
    //record type
    @api recordId;
    @api sourceValues = [];
    @api typeValues = [];
    @api severityValues = [];
    @track savealldataedq = [];

    @wire(getObjectInfo, {
        objectApiName: Case_OBJECT
    })
    objectInfo;



    get myVal() {
        return '**Hello!**';
    }
    @track agentTrack;
    @track supportedProductdata
    @track primaryPickList;
    @track error;
    @api records = [];

    @api categoryoptions = [];
    @api subcategoryoptions = [];
    @track value;
    @track value1;
    @track value2;
    @track value3;
    @track valCheck = true;
    @api trackvalidation = [];
    @api trackchildataa = [];
    @track conid;
    @track productid;
    @track projectid;
    @api ani = "ttt";
    //for contact
    @track lookupIconName = "standard:contact";
    @track lookupQueryString;
    @track lookupSearchFieldName = "Name";
    @track isLookupQueryPresent = false;
    @track showMindSection = false;
    @track lookupCountQueryStringContact;

    //for project

    @track lookupIconNameProject = "standard:Account";
    @track lookupSearchFieldNameProject = "Name";
    @track lookupQueryStringProject;
    @track isLookupQueryPresentProject = false;
    @track lookupCountQueryStringProject;
    //for product
    @track lookupIconNameProduct = "standard:Account";
    @track lookupQueryStringProduct;
    @track lookupCountQueryStringProduct;
    @track lookupSearchFieldNameProduct = "Name";
    @track isLookupQueryPresentProduct = false;
    @track showProductSection = false;
    @track renderProductVariant = false;
    @track renderProductCategory = false;
    @track renderProductSubCategory = false;
    @track passSupportedProductID;
    @track showSubCatEDQ = false;
    @track subCatIdPass = false;
    @track subsCatedqi = [];
    @track customerVisible = false;


    //platform
    @track showplatform = false;
    @api platformoptions = [];

    //to validation and save of case

    @track isValid = true;
    @track caseSource;
    @track caseType;
    @track caseSubject;
    @track caseDescription;
    @track caseSeverity;
    @track showPriority = false;
    @track caseId;
    @track recordId;
    @track recordPageUrl;
    @track capedqsize = [];
    @api myobjectdata = [];
    @api isLoaded;
    initialized = false;
    //@track inselectedquestionanswer = [];

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: Case_Source
    })
    wiredsourceField({
        data,
        error
    }) {
        if (data) {
            this.sourceValues = data.values;
            //  console.log('statusvalues:' + this.sourceValues);
        }
        if (error) {
            console.log('error: ' + error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: Case_Type
    })
    wiredtypeField({
        data,
        error
    }) {
        if (data) {
            this.typeValues = data.values;
            //  console.log('statusvalues:' + this.typeValues);
        }
        if (error) {
            console.log('error: ' + error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: Case_Severity
    })
    wiredSeverityField({
        data,
        error
    }) {
        if (data) {
            this.severityValues = data.values;
            // console.log('statusvalues:' + this.typeValues);
        }
        if (error) {
            console.log('error: ' + error);
        }
    }


    @wire(getAgent)
    wiredCases({
        data,
        error
    }) {
        if (data) {

            // console.log("Agent>>" + JSON.stringify(data));
            this.agentTrack = data
            // console.log('agentTrack' + this.agentTrack)
            this.errors = undefined;
        }
        if (error) {
            this.records = undefined;
            this.errors = error;
        }
    }

    renderedCallback() {

        this.lookupQueryString = 'Select id,' + this.lookupSearchFieldName + ' from contact where Name like :key limit 999';
        this.lookupCountQueryStringContact = 'select count() from contact where Name like :key ';
        this.isLookupQueryPresent = true;
        this.lookupQueryStringProject = 'select id,' + this.lookupSearchFieldNameProject + ' from core_ips_project__c where Name like :key limit 999';
        this.lookupCountQueryStringProject = 'select count() from core_ips_project__c where Name like :key ';
        this.isLookupQueryPresentProject = true;
        this.lookupQueryStringProduct = 'select id,core_supported_product__c,' + this.lookupSearchFieldNameProduct + ' from asset where Name like :key limit 999';
        this.lookupCountQueryStringProduct = 'select count() from asset where Name like :key  ';
        this.isLookupQueryPresentProduct = true;




        if (this.initialized) {
            return;
        }
        this.initialized = true;
        let listId = this.template.querySelector('datalist').id;
        this.template.querySelector("input").setAttribute("list", listId);

        // let listIda = this.template.querySelector('select').id;
        // this.template.querySelector("input").setAttribute("list", listIda);
    }

    // platform change
    handleChangeplatform(event) {
        this.platformValue = event.detail.value3;
        //  console.log('platformValue>>' + this.platformValue);
    }
    // on contact change
    handleAccountChange(event) {
        this.conid = event.detail.recordId;
        //  console.log('Conid' + JSON.stringify(this.conid));
        this.conid = JSON.stringify(this.conid);
        //const returnValue = this.template.querySelector('c-ips-mind-section').getcontactdata('test');
        if (this.conid != null) {
            this.showMindSection = true;
        }
        if (this.conid === undefined) {
            this.showMindSection = false;
        }


    }
    //on project change
    handleChangeProject(event) {
        this.projectid = event.detail.recordId;
        //  console.log('projectid' + JSON.stringify(this.projectid));
    }
    //on product change
    handleChangeProduct(event) {
        this.productid = event.detail.record;
        //console.log('productid' + JSON.stringify(this.productid));
        //this.productid = JSON.stringify(this.conid);
        //const returnValue = this.template.querySelector('c-ips-mind-section').getcontactdata('test');
        if (this.productid === undefined) {
            this.showProductSection = false;
            this.renderProductVariant = false;
            this.renderProductCategory = false;
            this.renderProductSubCategory = false;
            this.capedqsize = '';
            this.platformoptions = '';
            this.categoryoptions = '';
            this.subsCatedqi = '';
            this.savealldataedq = '';
        }
        if (this.productid != null) {
            this.passSupportedProductID = this.productid.Core_Supported_Product__c
            if (this.passSupportedProductID != null) {
                //  console.log("this.passSupportedProductID" + this.passSupportedProductID);
                this.showProductSection = true;
            }
            // show variant based on product id
            showVariants({
                selectedProductId: this.productid.Id,

            })
                .then(result => {
                    //  console.log("this.records inside varaints");
                    if (result !== undefined || result !== null) {


                        this.records = result;
                        //this.error = undefined;
                        if (this.records.length > 0) {
                            this.renderProductVariant = true;
                        }

                    }
                })
                .catch(error => {
                    //this.showToast('ERROR', error.body.message, 'error');
                    this.error = error;
                    console.log("this.error" + JSON.stringify(this.error));
                });

            // show plaform    
            getPlatfrm({
                productsId: this.productid.Id,
                // this.productid.Core_Supported_Product__c,a2E3F0000009LOBUA2 a2E3F0000009LQRUA2

            })
                .then(result => {
                    //      console.log("platform");
                    if (result !== undefined || result !== null) {
                        //  console.log("this.platform" + JSON.stringify(result));
                        this.platformoptions = result;
                        // this.error = undefined;
                        if (this.platformoptions.length > 0) {
                            this.showplatform = true;
                        }
                    }
                })
                .catch(error => {
                    //  this.showToast('ERROR', error.body.message, 'error');
                    this.error = error;
                    console.log("this.cat" + JSON.stringify(this.error));
                });
            // console.log("Category" + JSON.stringify(this.productid.Core_Supported_Product__c));
            //show category based on supported product/product id
            showCategory({
                supportedProductId: this.productid.Core_Supported_Product__c,
                // this.productid.Core_Supported_Product__c,a2E3F0000009LOBUA2 a2E3F0000009LQRUA2

            })
                .then(result => {
                    //console.log("cateory");
                    if (result !== undefined || result !== null) {
                        //console.log("this.categoryoptions" + JSON.stringify(result));

                        this.categoryoptions = result;
                        // this.error = undefined;
                        if (this.categoryoptions.length > 0) {
                            this.renderProductCategory = true;
                        }


                    }
                })
                .catch(error => {
                    // this.showToast('ERROR', error.body.message, 'error');
                    this.error = error;
                    console.log("this.cat" + JSON.stringify(this.error));
                });


        }


    }
    handleChangecaseSource(event) {
        this.caseSource = event.target.value;
    }
    handleChangecaseType(event) {
        this.caseType = event.target.value;
    }
    handleChangeSubject(event) {
        this.caseSubject = event.target.value;
    }
    handleChangeDescription(event) {
        this.caseDescription = event.target.value;
    }
    handleChangecaseSeverity(event) {
        this.caseSeverity = event.target.value;
        if (this.caseSeverity === 'Critical') {
            this.showPriority = true;
        }
    }
    //on product variant change
    handleChangeProductVariant(event) {
        this.value = event.detail.value;
        // console.log("varaintvalue:" + JSON.stringify(this.value));
    }
    //on  category change
    handleChangeSubCategory(event) {
        // for type head picklist
        console.log('head' + event.target.value);
        this.value1 = event.target.value;
        console.log('stand' + this.value1);


        // console.log("label>>>" + event.detail.label);
        // console.log("sub category:" + JSON.stringify(this.value1));
        if (this.value1 !== null) {
            showsubCategory({
                categorySelected: this.value1,


            })
                .then(result => {
                    console.log("subcateory");
                    if (result !== undefined || result !== null) {
                        //  console.log("this.subcategoryoptions" + JSON.stringify(result));

                        this.subcategoryoptions = result;
                        // this.error = undefined;
                        if (this.subcategoryoptions.length > 0) {
                            this.renderProductSubCategory = true;
                        }


                    }
                })
                .catch(error => {
                    this.error = error;
                    //  this.showToast('ERROR', error.body.message, 'error');
                    console.log("this.error" + JSON.stringify(this.error));
                });
        }
    }

    handleChangeRenderSubCategoryedq(event) {
        this.value2 = event.target.value;
        this.showSubCatEDQ = false;
        console.log("Render EDQ Categgory:" + JSON.stringify(this.value2));
        if (this.value2 !== null) {
            //this.showSubCatEDQ = false;
            //this.subCatIdPass = this.value2;
            console.log("Render EDQ subCatIdPass:" + JSON.stringify(this.subCatIdPass));
            //render sub category based edq
            getSubCategoryDetails({
                supportedProductId: null,
                subCategoryid: this.value2,
                //'a263F0000003YKoQAM',
                //this.previousID,
                isAgent: this.agentTrack,
                //  this.productid.Core_Supported_Product__c,
                // this.productid.Core_Supported_Product__c,a2E3F0000009LOBUA2 a2E3F0000009LQRUA2

            })
                .then(result => {
                    console.log("edq");
                    if (result !== undefined || result !== null) {

                        console.log("EDO" + (result));
                        // console.log("EDO1" + JSON.stringify(result[0].label));
                        // console.log("EDO2" + result[0].type);
                        this.subsCatedqi = result;
                        if (this.subsCatedqi.length > 0) {
                            this.showSubCatEDQ = true;
                            //  this.showcatEDQ = true;
                        }
                        // this.showProductSection = true;
                        // this.error = undefined;

                    }
                })
                .catch(error1 => {
                    this.error = error1;
                    if (error1 !== undefined) {
                        //this.showToast('ERROR', error1.body.message, 'error');
                        console.log("this.edq" + JSON.stringify(error1));
                    }

                });


        }
    }

    checkproductedqsize(event) {
        //  console.log("edqsize" + event.detail.edqsize);
        this.capedqsize = event.detail.edqsize;



    }

    handleChangeChild(event) {
        var s, c;
        var obj = {}; var vb;
        //if ((event.detail.vvalue.length === 0 || event.detail.vvalue === null) && (event.detail.rrequired === true)) {
        console.log('validationcheck>>' + event.detail.val);
        if (event.detail.val === false) {
            this.valCheck = false;
            vb = event.detail.val;
            this.trackvalidation.push(vb);
        }
        //   if (!event.detail.val) {
        //      this.showToast('ERROR', 'Please select/enter mandatory environment details', 'error');
        //      this.valCheck = false;

        //  }
        //trackvalidation
        //  else {

        if (event.detail.child === 'yes') {
            s = {
                "edq": [{ "qquestion": event.detail.qquestion, "llabel": event.detail.llabel, "vvalue": event.detail.vvalue, "rrequired": event.detail.rrequired, "ttype": event.detail.ttype, "val": event.detail.val }]
            };
            this.trackchildataa.push(s);
        }
        //data.split(" ").splice(-1)

        s = {
            "edq": [{ "qquestion": event.detail.qquestion, "llabel": event.detail.llabel, "vvalue": event.detail.vvalue, "rrequired": event.detail.rrequired, "ttype": event.detail.ttype, "val": event.detail.val }]
        };

        console.log("parent" + s);
        obj.edq = [];
        obj.edq.question = [event.detail.qquestion];
        obj.edq.label = [event.detail.llabel];
        obj.edq.value = [event.detail.vvalue];
        obj.edq.require = [event.detail.rrequired];
        obj.edq.type = [event.detail.ttype];
        //obj.edq.push(event.detail.qquestion, event.detail.llabel, event.detail.vvalue, event.detail.rrequired, event.detail.ttype);
        // var obj = JSON.parse(s);
        //console.log("222>>>" + JSON.stringify(obj.edq.length));
        console.log("obj>>>" + JSON.stringify(obj));
        console.log("ccc1" + JSON.stringify(s));
        // console.log("s length" + s.length);

        //if (s.length > 0) {

        this.savealldataedq.push(s);
        //}

        //  this.valCheck = true;



        // if (obj.length > 0) {
        this.myobjectdata.push(obj);
        // }




        // ["qquestion".concat(":".concat("'" + event.detail.qquestion + "'")), "llabel".concat(":".concat("'" + event.detail.llabel + "'")), "vvalue".concat(":".concat("'" + event.detail.vvalue + "'")), "rrequired".concat(":".concat("'" + event.detail.rrequired + "'"))]

        console.log('this.savealledq>>parent' + this.savealldataedq.length);
        //console.log('parse>>parent' + JSON.parse(this.savealldataedq));
        //for (let i = 0; i < this.savealldataedq.length; i++) {
        //    console.log('this.data' + JSON.stringify(this.savealldataedq[i]));
        // }

        // }
    }

    validateedq() {

        console.log('fianllsist' + JSON.stringify(this.savealldataedq));
        //  console.log('val1' + JSON.stringify(this.savealldataedq));
        //  this.trackvalidation = this.savealldataedq.filter(item => item.edq.val === false);
        console.log('trackvalidat' + JSON.stringify(this.trackvalidation));
        console.log('trackvalidationlen' + JSON.stringify(this.trackvalidation.length));

        if (this.trackvalidation.length === 0) {
            this.valCheck = true;
        }
        /* if (this.savealldataedq.length > 0) {
             for (let i = 0; i < this.savealldataedq.length; i++) {
                 const j = this.savealldataedq[i].edq[i].val;
                 console.log('trackvalidation' + JSON.stringify(j));
                 console.log('trackvalidation' + j);
                 if (typeof (j) === undefined) {
                     console.log('trackvalidation1' + JSON.stringify(j));
                     if (j === false) {
                         console.log('trackvalidation2' + JSON.stringify(j));
                         // this.valCheck = false;
                         // const v = false;
                         //  this.trackvalidation.push(v);
                         //break;
 
                     } else {
 
                         console.log('errrrrr');
                     }
 
                 } else { console.log('errrrrr1'); }
             } 
      

        //   this.isValid = false;
        // this.valCheck = true;
    }*/

        // if (this.valCheck === false) {
        //      this.isValid = false;

        //   }


    }
    handleCustomerVisibleChange(event) {
        this.customerVisible = event.target.checked;
    }
    // Added by Anusha for US519583
    onSaveHandler() {
        var resultsa;
        // this.savealldataedq = '';
        //this.trackvalidation = '';
        console.log('test' + this.trackchildataa.length);
        this.savealldataedq.splice(this.trackchildataa.length, this.savealldataedq.length);
        this.trackvalidation = [];

        if (this.capedqsize.length > 0) {

            console.log('check edq size');
            this.template.querySelector('c-show-dynamicedq-section').callhandleQuestionAnswer();


        }
        //subcategory edq
        if (this.subsCatedqi.length > 0) {
            console.log('check sub cate size');
            this.template.querySelector('c-show-sub-categoryedq-section').callhandleQuestionAnswerSubCat();
        }

        //this.addEventListener('inselectedquestionanswer', this.handleChangeChild.bind(this));
        //this.template.querySelector('c-show-dynamicedq-section').callhandleQuestionAnswer();
        //  console.log('dat1' + JSON.stringify(dat));
        //  console.log('dat' + dat);
        //callhandleQuestionAnswer();


        this.validateCaseForm();
        this.validateedq();
        console.log('dat' + this.isValid);
        console.log('this.valCheck' + this.valCheck);
        if (this.isValid && this.valCheck) {
            this.isLoaded = true;
            saveCaseRecord({
                customerVisible: this.customerVisible,
                caseType: this.caseType,
                contactId: JSON.parse(this.conid),
                caseProject: this.projectid,
                productId: this.productid.Id,
                caseSource: this.caseSource,
                caseSeverity: this.caseSeverity,
                caseSubject: this.caseSubject,
                caseDesc: this.caseDescription,
                caseCategory: this.value1,
                caseSubCategory: this.value2,
                caseSupportProject: this.passSupportedProductID,
                caseEDQdata: JSON.stringify(this.savealldataedq)

            })
                .then(result => {
                    if (result !== undefined || result !== null) {
                        this.recordId = result;
                        this.isLoaded = false;
                        this.showToast('Success', 'Record has been created' + this.recordId, 'success');
                        this.navigateToViewCase();
                        this.savealldataedq = '';
                    }
                })
                .catch(error => {
                    this.isLoaded = false;
                    this.showToast('ERROR', error.body.message, 'error');

                });


            /* const fields = {'Core_CaseType__c' : this.caseType,
                 'Core_IPS_Supported_Contact__c' : this.conid,
                'Core_IPS_Project_Case__c' : this.projectid,
                 'Core_IPS_Product__c' : this.productid.Id,
                 'Core_IPS_Issue_source__c' : this.caseSource,
                 'Core_Severity__c' : this.caseSeverity,
                 'Subject' : this.caseSubject,
                 'Core_Issue_Description__c' : this.caseDescription,
                 'Core_Case_Issue_Category__c' : this.value1,
                 'Core_Case_Issue_Sub_Category__c': this.value2};
     
                 const recordInput = {apiName : 'Case', fields};
     
                 createRecord(recordInput).then(response =>{
                     console.log('Record has been created Successfully', response.id);
                     this.recordId = response.id;
                     this.showToast('SUCCESS', 'Record has been created'+this.recordId, 'success');
                 }).catch(error =>{
                     console.log('Error in Creating a Case', error.body.message);
                     this.showToast('ERROR', error.body.message, 'error');
                 });*/

        }

    }
    validateCaseForm() {
        if (this.conid === undefined) {
            this.showToast('ERROR', contectErrorMessage, 'error');
            this.isValid = false;
        } else if (this.productid === undefined) {
            this.showToast('ERROR', productErrorMessage, 'error');
            this.isValid = false;
        } else if ((this.conid !== null && this.conid === '') && (this.productid !== null && this.productid === '')) {
            this.showToast('ERROR', contAndProdErrorMessage, 'error');
            this.isValid = false;
        } else if ((this.conid !== null && this.conid === '')) {
            this.showToast('ERROR', contactIdErrorMessage, 'error');
            this.isValid = false;
        } else if ((this.productid !== null && this.productid === '')) {
            this.showToast('ERROR', productIdErrorMessage, 'error');
            this.isValid = false;
        } else if (this.caseSource === undefined || this.caseSource === '') {
            this.showToast('ERROR', caseErrorMessage, 'error');
            this.isValid = false;
        } else if (this.caseType === undefined || this.caseType === '') {
            this.showToast('ERROR', caseTypeErrorMessage, 'error');
            this.isValid = false;
        } else if (this.caseSubject === undefined || this.caseSubject === '') {
            this.showToast('ERROR', caseSubjectErrorMessage, 'error');
            this.isValid = false;
        } else if (this.caseDescription === undefined || this.caseDescription.trim() === '') {
            this.showToast('ERROR', caseDescErrorMessage, 'error');
            this.isValid = false;
        } else if (this.caseSeverity === undefined || this.caseSeverity === '') {
            this.showToast('ERROR', caseSeverityErrorMessage, 'error');
            this.isValid = false;
        } else if ((this.categoryoptions !== null && this.categoryoptions.length > 1) && (this.value1 === null || (this.value1 !== null && this.value1 === ''))) {
            this.showToast('ERROR', caseCategoryErrorMessage, 'error');
            this.isValid = false;
        } else if ((this.subcategoryoptions !== null && this.subcategoryoptions.length > 1) && (this.value2 === null || (this.value2 !== null && this.value2 === ''))) {
            this.showToast('ERROR', CaseSubCategoryErrorMessage, 'error');
            this.isValid = false;
        }
        else {
            this.isValid = true;
        }

    }
    onCancelHandler() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    navigateToViewCase() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Case',
                actionName: 'view'
            },
        });

    }

}