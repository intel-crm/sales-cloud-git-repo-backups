import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createDeflectedObject from '@salesforce/apex/Core_IPS_DeflectedObject_LWC_Ctrl.createDeflectedObject';
import { CurrentPageReference } from "lightning/navigation";
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import fetchBugAssistRecord from '@salesforce/apex/Core_IPS_BugAssistController.fetchBugAssistRecord'; // Created by Deepaksai as part of BugAssist
import Waiting_For_BugAssist_Response from '@salesforce/label/c.Core_IPS_Bug_Assist_Waiting_For_Response' // Created by Deepaksai as part of BugAssist
import updateDeflectedRecord from '@salesforce/apex/Core_IPS_DeflectedObject_LWC_Ctrl.updateDeflectedRecord';
import {
    destroyEngine
  } from 'c/quanticHeadlessLoader';


export default class Core_IPS_caseCreation_Form extends NavigationMixin(LightningElement) {
    @track showcasedetails_form1 = true;
    @track showcheckAnswers_form2 = false;
    @track showcaseCreation_form3 = false;
    @track hideButton = false;
    @api successMsg;
    @api assetId; //assetId from body component
    @api assetName; //assetName from body component
    @api premiersupprojrojId;
    @api premiersupprojrojName;
    @api project;
    caseInfoStringfy;
    @api deflectedid;
    communityCheck = true;
    @api premiersupportproject;
    @api userRoles;
    @track UserRoleError;
    getItem;
    getcaseItem;
    getNotApplicable;
    waitingForResponseMessage = Waiting_For_BugAssist_Response; //Added by Deepaksai as part of BugAssist
    isWaitingBugAssistForResponse = false; //Added by Deepaksai as part of BugAssist

    connectedCallback() {
        sessionStorage.setItem("NotApplicableCount", 0);
        let testURL = window.location.href;
        let newURL = new URL(testURL).searchParams;
        this.assetId = newURL.get('assetId');
        this.assetName = newURL.get('assetName');
        this.premiersupprojrojId = newURL.get('premiersupprojrojId');
        this.premiersupprojrojName = newURL.get('premiersupprojrojName');
        this.mode = newURL.get('mode');
        if (this.assetId && this.assetName) {
            this.project = {
                Id: this.assetId,
                Name: this.assetName
            }
        }
        if (this.premiersupprojrojId && this.premiersupprojrojName) {
            this.premiersupportproject = {
                Id: this.premiersupprojrojId,
                Name: this.premiersupprojrojName
            }
        }

        if (this.mode === 'create') {} else if (this.mode === 'sslc') {
            this.showcasedetails_form1 = false;
            this.showcheckAnswers_form2 = false;
            this.showcaseCreation_form3 = true;

        }
    }

    renderedCallback() {}
    @api recordId;
    @api caseInfo = {
        "project": undefined,
        "projectName": undefined,
        "productvariant": undefined,
        "productvariantName": undefined,
        "Product": undefined,
        "ProductName": undefined,
        "Subject": undefined,
        "CategoryId": undefined,
        "CategoryName": undefined,
        "SubCategoryId": undefined,
        "SubCategoryName": undefined,
        "Language": undefined,
        "NickName": undefined,
        "testQuestion": undefined,
        "picklistQuestion": undefined,
        "childQuestion1": undefined,
        "childQuestion2": undefined,
        "prodEdqRecs": undefined,
        "showProdEdqs": undefined,
        "showEdqSection": undefined,
        "contactId ": undefined,
        "accountId": undefined,
        "passSupportedProductID": undefined,
        "mindsValue": undefined,
        "renderProductCategory": undefined,
        "renderProductSubCategory": undefined,
        "productVariantOptions": undefined,
        "country" : undefined
    };

    @api casedatafromform3 = {
        "subject": undefined,
        "description": undefined,
        "caseType": undefined,
        "caseseverity": undefined,
        "custmerreference": undefined,
        "endcustomer": undefined,
        "CategoryId": undefined,
        "CategoryName": undefined,
        "SubCategoryId": undefined,
        "SubCategoryName": undefined
    };
    // Created by Deepaksai as part of BugAssist
    bugAssistRecord;
    bugAssistAttachmentSessionId;
    // transformend handleNavigateform1toform2 into an async function as we have to wait for the response - by Deepaksai as part of BugAssist
    async handleNavigateform1toform2(){
        let isValid = true;
        if(this.caseInfo.Subject == undefined ||this.caseInfo.Subject == null||this.caseInfo.Subject == ''||this.caseInfo.Subject.trim().length == 0){
            this.template.querySelector('c-core_-i-p-s_case-creation_form1_-l-w-c').validateSubjectMethod();
            this.showcheckAnswers_form2 = false;          
            this.showcasedetails_form1 = true;
            isValid = false;
        } 
        if(this.caseInfo.renderProductSubCategory == true && this.caseInfo.SubCategoryOptions != '' && (this.caseInfo.SubCategoryId == undefined || this.caseInfo.SubCategoryId == null  || this.caseInfo.SubCategoryId == '')){
            this.template.querySelector('c-core_-i-p-s_case-creation_form1_-l-w-c').validateSubCategoryMethod();
            this.showcheckAnswers_form2 = false;          
            this.showcasedetails_form1 = true;
            isValid = false;
        }
        if(this.caseInfo.renderProductCategory == true &&this.caseInfo.CategoryOptions != '' &&(this.caseInfo.CategoryId == undefined || this.caseInfo.CategoryId == null || this.caseInfo.CategoryId == ''||this.caseInfo.CategoryName==''||this.caseInfo.CategoryName==undefined||this.caseInfo.CategoryName==null)){
            this.template.querySelector('c-core_-i-p-s_case-creation_form1_-l-w-c').validateCategoryMethod();
            this.showcheckAnswers_form2 = false;          
            this.showcasedetails_form1 = true;
            isValid = false;
        } 
        if(this.caseInfo.ProductName==null||this.caseInfo.ProductName==undefined||this.caseInfo.ProductName=='' || this.caseInfo.ProductName.trim().length == 0){
            this.template.querySelector('c-core_-i-p-s_case-creation_form1_-l-w-c').validateProductMethod();
            this.showcheckAnswers_form2 = false;          
            this.showcasedetails_form1 = true;
            isValid = false;
        } 
        if(this.caseInfo.projectName =='' ||this.caseInfo.projectName ==undefined ||this.caseInfo.projectName == null || this.caseInfo.projectName.trim().length == 0){
            this.template.querySelector('c-core_-i-p-s_case-creation_form1_-l-w-c').validateProjectMethod();
            this.showcheckAnswers_form2 = false;          
            this.showcasedetails_form1 = true; 
            isValid = false; 
        } 
        if(this.caseInfo.country == 'None' || this.caseInfo.country == undefined || this.caseInfo.country == null){
            this.template.querySelector('c-core_-i-p-s_case-creation_form1_-l-w-c').validateCountryMethod();
            this.showcheckAnswers_form2 = false;          
            this.showcasedetails_form1 = true;
            isValid = false;
        }
        if(this.caseInfo.showState == true && (this.caseInfo.state == 'None' || this.caseInfo.state == undefined || this.caseInfo.state == null)){
            this.template.querySelector('c-core_-i-p-s_case-creation_form1_-l-w-c').validateStateMethod();
            this.showcheckAnswers_form2 = false;          
            this.showcasedetails_form1 = true;
            isValid = false;
        }
    // START - Added by Deepaksai as part of BugAssist
        if (this.caseInfo.isBugAssitCase === true && (this.caseInfo.sstLogvalueTF === null || this.caseInfo.sstLogvalueTF === undefined || this.caseInfo.sstLogvalueTF === '')) {
            this.template.querySelector('c-core_-i-p-s_case-creation_form1_-l-w-c').validateSSTLogRequired();
            this.showcheckAnswers_form2 = false;
            this.showcasedetails_form1 = true;
            isValid = false;
        }
        if (this.caseInfo.isBugAssitCase === true && this.caseInfo.sstLogvalueTF === false && (this.caseInfo.sstLogvalueTF !== null || this.caseInfo.sstLogvalueTF !== undefined || this.caseInfo.sstLogvalueTF !== '')  && (this.caseInfo.selectedReason === undefined ||this.caseInfo.selectedReason === null||this.caseInfo.selectedReason === ''||this.caseInfo.selectedReason.trim().length === 0)) {
            this.template.querySelector('c-core_-i-p-s_case-creation_form1_-l-w-c').validateSSTResponseMethod();
            this.showcheckAnswers_form2 = false;
            this.showcasedetails_form1 = true;
            isValid = false;
        }
        if (this.caseInfo.isBugAssitCase === true && this.caseInfo.sstLogvalueTF === true && ( this.bugAssistAttachmentSessionId !== undefined || this.bugAssistAttachmentSessionId !== null || this.bugAssistAttachmentSessionId !=='')) {
            this.bugAssistAttachmentSessionId = sessionStorage.getItem('bugAssistRecId');
            this.bugAssistRecord = await fetchBugAssistRecord({recordId : this.bugAssistAttachmentSessionId});

            if ((this.bugAssistRecord !== null || this.bugAssistRecord !== undefined || this.bugAssistRecord !== '') && this.caseInfo.sstLogvalueTF === true && this.bugAssistRecord.Core_Upload_Status__c !== 'Complete' /*&& this.sstFileUploadStatus == false*/) {
                this.isWaitingBugAssistForResponse = true;
                this.showcheckAnswers_form2 = false;
                this.showcasedetails_form1 = true;
                isValid = false;
            }
            if (this.bugAssistRecord && this.bugAssistRecord.Core_Upload_Status__c === 'Complete' && this.sstFileUploadStatus == false) {
                this.isWaitingBugAssistForResponse = true;
                this.showcheckAnswers_form2 = false;
                this.showcasedetails_form1 = true;
                isValid = false;
            }
            if ((this.bugAssistRecord !== null || this.bugAssistRecord !== undefined || this.bugAssistRecord !== '') && (this.bugAssistRecord.Core_Upload_Status__c === 'Complete' || this.caseInfo.sstLogvalueTF === false)) {
                this.template.querySelector('c-core_-i-p-s_case-creation_form1_-l-w-c').bugAssistRecordData(this.bugAssistRecord);
                this.isWaitingBugAssistForResponse = false;
            }
        }
     //END - Deepaksai - BugAssist
     if(isValid == true){
          this.storeingInDeflected();
          this.showcasedetails_form1 = false;
          sessionStorage.setItem("screenValidation",true);
     }     
    }
    // START - Deepaksai as part of BugAssist
    @api sstFileUploadStatus;
    handleSSTFileUploadEvent(event) {
        this.sstFileUploadStatus = event.detail === 'Completed' ? true : false;
    }
    // END - BugAssist

    storeingInDeflected() {
        if(sessionStorage.getItem('deflectionId')!= null && sessionStorage.getItem('deflectionId')!= undefined && sessionStorage.getItem('deflectionId')!= ''){
            this.deflectedid = sessionStorage.getItem('deflectionId');
        }
        this.showSpinner = true;
        this.caseInfoStringfy = JSON.stringify(this.caseInfo);
        createDeflectedObject({ caseInfo: this.caseInfoStringfy,deflectedId: this.deflectedid})
            .then(result => {
                this.deflectedid = result;
                sessionStorage.setItem("deflectionId", this.deflectedid);
                this.showcheckAnswers_form2 = true; 
                this.showSpinner = false;
            })
            .catch(error => {})
    }


    handleNavigateBackfrom1toHome() {
        this.getItem = sessionStorage.getItem("tech");
        this.getcaseItem = sessionStorage.getItem("techstack");
        if (this.getItem == 'JavaScript') {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'product-detail'
                },
                state: {
                    recordId: this.assetId
                },
            });
        }
        if (this.getcaseItem == 'casecreation') {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'home'
                },
            });
        }

        sessionStorage.removeItem('tech');
        sessionStorage.removeItem('techstack');
        sessionStorage.clear();
    }

    handleContinueToCaseCreation() {
        this.handleNavigatefrom2tofrom3();
    }

    handleNavigatefrom2tofrom3() {
        this.handleClickEventForDeflection();
        const topDiv = this.template.querySelector('[data-id="yellowDiv"]');
        topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
        this.showcaseCreation_form3 = true;
        this.showcheckAnswers_form2 = false;
        this.hideButton = true;
    }
    handleNavigateBackfrom2tofrom1() {
        this.showcheckAnswers_form2 = false;
        this.showcasedetails_form1 = true;
        destroyEngine('IPSSBS-engine');
    }

    handleNavigateBackfrom3tofrom2() {
        this.showcaseCreation_form3 = false;
        this.showcheckAnswers_form2 = true;
        this.hideButton = false;
    }
    handlecaseEventData(event) {
        this.caseInfo = {
            "project": event.detail.project,
            "projectName": event.detail.projectName,
            "Product": event.detail.Product,
            "ProductName": event.detail.ProductName,
            "productvariant": event.detail.productvariant,
            "productvariantName": event.detail.productvariantName,
            "CategoryId": event.detail.CategoryId,
            "CategoryName": event.detail.CategoryName,
            "CategoryOptions": event.detail.CategoryOptions,
            "SubCategoryId": event.detail.SubCategoryId,
            "SubCategoryName": event.detail.SubCategoryName,
            "SubCategoryOptions": event.detail.SubCategoryOptions,
            "Subject": event.detail.Subject,
            "Language": event.detail.language,
            "prodEdqRecs": event.detail.prodEdqRecs,
            "showProdEdqs": event.detail.showProdEdqs,
            "showEdqSection": event.detail.showEdqSection,
            "contactId": event.detail.contactId,
            "accountId": event.detail.accountId,
            "passSupportedProductID": event.detail.passSupportedProductID,
            "isAgent": event.detail.isAgent,
            "mindsValue": event.detail.mindsValue,
            "country": event.detail.country,
            "state": event.detail.state,
            "renderProductCategory": event.detail.renderProductCategory,
            "renderProductSubCategory": event.detail.renderProductSubCategory,
            "productVariantOptions": event.detail.productVariantOptions,
            "showState":event.detail.showState,
            
            //New Added by Hassan for BugAssist
            "sstLogvalueTF" : event.detail.sstLogvalueTF,
            "selectedReason" : event.detail.selectedReason,
            "attachedUrl" : event.detail.attachedUrl,
            "isBugAssitCase" : event.detail.isBugAssitCase, //added by Deepaksai as part of BugAssist
            "bugAssistRecordId" : event.detail.bugAssistRecordId, //added by Deepaksai as part of BugAssist
            "isSubjectEntered": event.detail.isSubjectEntered,  //added by Deepaksai as part of BugAssist
            "uploadedFileName": event.detail.uploadedFileName,//added by Deepaksai as part of BugAssist
            "isBugAssistProduct": event.detail.isBugAssistProduct, //added by Deepaksai as part of BugAssist
            "subjectForBugAssist": event.detail.subjectForBugAssist  //added by Deepaksai as part of BugAssist
        };
        // START Added by Deepaksai as part of BugAssist
        if(this.caseInfo.sstLogvalueTF === false || this.caseInfo.isBugAssitCase === false){
            this.isWaitingBugAssistForResponse = false;
        }
        // END - BugAssist
    }
    @api subCatRecEdqs;
    @api showSubCatEdqs;
    handlecateedq(event) {
        this.subCatRecEdqs = event.detail.firstParam;
        this.showSubCatEdqs = event.detail.secondParam;
    }
    @api sslcmode;
    handlemode(event) {
        this.sslcmode = event.detail.firstParam;
    }
    handlecasedataform3(event) {
        this.casedatafromform3 = {
            "subject": event.detail.subject,
            "description": event.detail.description,
            "caseType": event.detail.caseType,
            "caseseverity": event.detail.caseseverity,
            "custmerreference": event.detail.custmerreference,
            "endcustomer": event.detail.endcustomer,
            "CategoryId": event.detail.CategoryId,
            "CategoryName": event.detail.CategoryName,
            "SubCategoryId": event.detail.SubCategoryId,
            "SubCategoryName": event.detail.SubCategoryName
        };
    }
    urlValue;
    sslcNavigation = true;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.urlValue = currentPageReference.state.mode;
            if (this.urlValue == 'sslc') {
                this.sslcNavigation = false;
            }
        }
    }
    handleBacktoHomefromsslc() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });

    }
    @api handleClickEventForDeflection(){      
        this.template.querySelector('c-core_-i-p-s_case-creation_-form_-full').handleClickEventForDeflection();
        let coveoSubject = '';
        if(sessionStorage.getItem('coveoDescription')!= null && sessionStorage.getItem('coveoDescription') != ''){
        coveoSubject = sessionStorage.getItem('coveoDescription');
        sessionStorage.removeItem('coveoDescription');
        }  
         //update status to Abandoned
         updateDeflectedRecord({deflectionId : this.deflectedid ,coveoDescription : coveoSubject}).then(result=>{
           
        }).catch(error=>{
            console.log('Deflection record error',error);
        });      
    }
    disconnectedCallback() {
        sessionStorage.removeItem("NotApplicableCount");
        sessionStorage.removeItem("deflectionId");
        sessionStorage.removeItem('coveoDescription');
        sessionStorage.removeItem('bugAssistRecId'); // Added by Deepaksai as part of BugAssist
        destroyEngine('IPSSBS-engine');
    }
}