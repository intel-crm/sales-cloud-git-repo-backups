import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import SubmitCaseRecord from '@salesforce/apex/core_IPS_PortalEdqController.SubmitCaseRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCustomSettingLogs from '@salesforce/apex/Core_IPS_CaseCreateMode_CTRL.getCustomSettingLogs';
import showsubCategory from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getSubCategoryDetail";
import getSubCatEdq from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getSubCatProductEDQ";
import getCategoryOptions from '@salesforce/apex/core_IPS_caseCreate_LEX.getCaseCategories'
import getSubCategoryOptions from '@salesforce/apex/core_IPS_caseCreate_LEX.getCaseSubCategories'
import getProdEdq from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getProductEDQ";
import updateDeflectedObject from '@salesforce/apex/Core_IPS_DeflectedObject_LWC_Ctrl.updateDeflectedObject';
import getcountryfields from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getcountryfields";
import Core_Country_Region__c from '@salesforce/schema/Contact.Core_Country_Region__c';
import getcurrentuserprofile from '@salesforce/apex/Core_IPS_TestAllRecords.getcurrentuserprofile';
import getPartnerSupportOwner from '@salesforce/apex/Core_IPS_TestAllRecords.getPartnerSupportOwner';
import getSupportedAccount from '@salesforce/apex/Core_IPS_TestAllRecords.getSupportedAccount';
import Contact from '@salesforce/schema/Contact';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Id from '@salesforce/user/Id';
import EdqAlignLast from '@salesforce/resourceUrl/EdqAlignmentLast';
import progressbarImg from '@salesforce/resourceUrl/progressbarImg';
import { loadStyle } from 'lightning/platformResourceLoader';
import getLoggedInContacts from "@salesforce/apex/core_IPS_caseCreate_LEX.getContactDetails";
import bugAssistRecordConversion from "@salesforce/apex/Core_IPS_BugAssistController.bugAssistRecordConversion"; // Added By Hassan As a Part of Bug Assist
import bugAssistRecordDeletion from "@salesforce/apex/Core_IPS_BugAssistController.bugAssistRecordDeletion"; // Added By Hassan As a Part of Bug Assist
import Core_FC_LastModifiedDate from '@salesforce/label/c.Core_FC_LastModifiedDate';
import Core_IPS_Required from '@salesforce/label/c.Core_IPS_Required';
import Core_IPS_BugAssist_Validation from '@salesforce/label/c.Core_IPS_BugAssist_Validation';
export default class Core_IPS_caseCreation_form3_LWC extends NavigationMixin(LightningElement) {
    @api casedatainfo; //will come from parent
    @api subcatrecedqs; //will come from parent
    @api showcubcatedqs; //will come from parent
    @api showboolean1;
    @api showboolean2;
    @track communityCheck = true;
    @track cummunitydropdown = true;
    @track hideButton = true;
    @track progressbarImg = progressbarImg;
    @api myVal = '';
    @api subject;
    @api description='';//new
    @api caseType;
    @api caseseverity;
    @api custmerreference = '';
    @api endcustomer = '';
    @api recordId;
    @api spinnerOn;
    @api renderProductCategory;//new
    @api selectedContactRecord;//new
    CaseSubcategoryoptions = [];
    @api defectedobjectid;
    @track countrySave;
    Subjectvalue;
    @track selectedCountryValue;
    @track showSeverityReason = false;
    @track checkProdVarient = true;
    @track sslcSeverityReason = false;
    mindsValueForSSLSC = false;
    userId = Id;
    logContact;
    isOpenSeverityModal;
    isSeverity_Question = false;
    isSeverity_Debug = false;
    isSeverity_Feature = false;
    isSeverity_Design = false;
    isCasetypeEmpty = true;
    isRequiredSubject = false;
    isRequiredDesc = false;
    @track richTextClass;
    @track descValid = true;
    isRequiredCaseType = false;
    severityRsnReq = false;
    categoryReq = false;
    subCategoryReq = false;
    isRequiredSubjectSSLC = false;
    descriptionSSLC = false;
    caseTypeInputSSLC = false;
    severityResSSLC = false;
    categoryReqSSLC = false;
    subCategoryReqSSLC = false;
    countrySSLCReq = false;
    isPSArequired = false;
    primaryDetailsValid = false;
    //Added by chetan as part of bug assist validation.
    iscaseTypeValid = false;
    @track label = {
        Core_IPS_Required,
        Core_IPS_BugAssist_Validation
    };
    get CaseTypeOptions() {
        return [
            { label: "Question", value: "Question" },
            { label: "Design Review", value: "Design Review" },
            { label: "Feature Request", value: "Feature Request" },
            { label: "Debug Request", value: "Debug Request" },
        ];
    }
    @api mode;
    @api createmode = false;
    @api sslcmode = false;
    constructor() {
        super();
        this.template.addEventListener('inselectedquestionanswer', this.handleChangeChild.bind(this));
    }
    @api trackvalidation = [];
    @track valCheck = true;
    @api trackchildataa = [];
    savealldataedq = [];
    savealldataedqMap = new Map();
    @api myobjectdata = [];
    @track showSubCategories;
    handleChangeChild(event) {
        var s, c;
        var obj = {};
        var vb;
        if (event.detail.val === false) {
            this.valCheck = false;
            vb = event.detail.val;
            this.trackvalidation.push(vb);
        }
        if (event.detail.child === 'yes') {
            s = {
                "edq": [{ "qquestion": event.detail.qquestion, "llabel": event.detail.llabel, "vvalue": event.detail.vvalue, "rrequired": event.detail.rrequired, "ttype": event.detail.ttype, "val": event.detail.val }]
            };
            this.trackchildataa.push(s);
        }
        s = {
            "edq": [{ "qquestion": event.detail.qquestion, "llabel": event.detail.llabel, "vvalue": event.detail.vvalue, "rrequired": event.detail.rrequired, "ttype": event.detail.ttype, "val": event.detail.val }]
        };

       
        this.savealldataedqMap.set(s.edq[0].qquestion, s);

        for (const x of this.savealldataedqMap.keys()) {
            console.log('132 => ' + 'Key=' + x + ', Value=' + JSON.stringify(this.savealldataedqMap.get(x)));
        }



        //this.savealldataedq.push(s);
       

    }
    CaseCategoryy;
    CaseSubcategoryy;
    booleanRequired = false;
    isAgent;
    connectedCallback() {
        
        getLoggedInContacts({})
        .then((result) => {
            this.selectedContactRecord = result[0];
            
        })
        .catch((error) => {
            console.log(error);
        });

       
        loadStyle(this, EdqAlignLast);
      
        if(this.casedatainfo.project == undefined){
           
            this.booleanRequired = true;
          
        }

        this.passSupportedProductID = this.casedatainfo.passSupportedProductID;
        this.countrySave = this.casedatainfo.country;
        this.subject = this.casedatainfo.Subject;
        this.caseseverity = this.severityValue;
        this.CaseCategoryoptions = this.casedatainfo.CategoryOptions;
        this.CaseSubcategoryoptions = this.casedatainfo.SubCategoryOptions;
        //this.CaseCategoryy = this.casedatainfo.CategoryName;
        this.CaseCategoryy = this.casedatainfo.CategoryId;
        this.CaseSubcategoryy = this.casedatainfo.SubCategoryId;
        
        //this.CaseSubcategoryy = this.casedatainfo.SubCategoryName;
       
        this.renderProductCategory=this.casedatainfo.renderProductCategory;//new
       
        this.renderProductSubCategory =this.casedatainfo.renderProductSubCategory;//newly added
       
        //this.createSubCategorylabel=this.casedatainfo.SubCategoryName; //new
       
        let projectURL = window.location.href;
        let newURL = new URL(projectURL).searchParams;
        this.mode = newURL.get('mode');
        if (this.mode == 'create') {
            this.createmode = true;
            this.sslcmode = false;
            this.getUserProfile();
        } else if (this.mode == 'sslc') {
            this.sslcmode = true;
            this.createmode = false;
            this.getUserProfileData();
            this.handleLoad();
        }
        this.getcountryvalues();
        if (this.casedatainfo.productvariantName == '' || this.casedatainfo.productvariantName == undefined) {
            this.checkProdVarient = false;
        } else {
            this.checkProdVarient = true;
        }
        if (this.casedatainfo.SubCategoryName == '' || this.casedatainfo.SubCategoryName == undefined) {
            //
            this.showSubCategories = false;
        } else {
            this.showSubCategories = true;
        }
    }
    severityValue = 'Low';
    get caseSeverityoptions() {
        return [
            { label: "Low", value: "Low" },
            { label: "Medium", value: "Medium" },
            { label: "High", value: "High" },
            { label: "Critical", value: "Critical" },
        ];
    }
    caseseverityReason;
    SubjectRequired;
    descriptionRequired;
    SeverityReasonRequired;
    sslcrequiredes;
    handleChange(event) {
        var value;
        if (event.target.type === 'checkbox' || event.target.type === 'checkbox-button' || event.target.type === 'toggle') {
            value = event.target.checked;
        } else {
            value = event.target.value;
        }
        if (event.target.dataset.id === 'countryField') {
            this.country = value;
        } else if (event.target.dataset.id === 'subjectField') {
            this.subject = value;
            const subjectreq = this.subject.trim();
            if (subjectreq != '') {
                this.template.querySelector('.subjectInput')?.classList.remove('showRequired');
                this.isRequiredSubject = false;
            }
            this.SubjectRequired = this.subject.replace(/\s/g, '').length;
        } else if (event.target.dataset.id === 'descriptionFeild') {
            this.description = value;
            var plainTextValue = this.description.replaceAll('<p>', '').replaceAll('</p>', '').replaceAll('<strong>', '').replaceAll('</strong>', '').replaceAll('<em>', '').replaceAll('</em>', '').replaceAll('<strike>', '').replaceAll('</strike>', '').replaceAll('<br>', '').trim();
            const decsriptionreq = this.description.trim();
            if (plainTextValue != '' && this.decsriptionreq != '') {
                this.template.querySelector('.descIput')?.classList.remove('Descriptionborder');
                this.isRequiredDesc = false;
                this.descriptionSSLC = false;

            }
            this.descriptionRequired = this.description.replace(/\s/g, '').length;
        } else if (event.target.dataset.id === 'CaseType') {
            //Added by chetan as part of Bug assist validation
            if(this.casedatainfo.isBugAssitCase === true && this.casedatainfo.selectedReason === 'Case Type is not “Debug Request"' && event.target.value === 'Debug Request'){
                this.caseType = ''; 
                this.isRequiredCaseType = false;
                this.iscaseTypeValid = true;
                //this.showToast('Error', 'Case Type Should Not be "Debug Request"', 'Error');
            }else {
                this.iscaseTypeValid = false;
                this.caseType = value;
                this.isRequiredCaseType = false;
                this.template.querySelector('.caseTypeInput')?.classList.remove('showRequired');
            }
        } else if (event.target.dataset.id === 'Severity') {
            this.severityValue = value;
            if (this.severityValue === 'Critical') {
                this.showSeverityReason = true;
            } else {
                this.showSeverityReason = false;
            }
        } else if (event.target.dataset.id === 'SeverityReason') {
            this.caseseverityReason = value;
            const severityreasonreq = this.caseseverityReason.trim();
            if (severityreasonreq != '') {
                this.severityRsnReq = false;
                this.SeverityReasonRequired = this.caseseverityReason.replace(/\s/g, '').length;
                this.template.querySelector('.severityInput')?.classList.remove('showRequired');
            }
        } else if (event.target.dataset.id === 'descriptionFeildSSLC') {
            let varsed = event.target.value;
            var plainTextValeue = varsed.replaceAll('<p>', '').replaceAll('</p>', '').replaceAll('<strong>', '').replaceAll('</strong>', '').replaceAll('<em>', '').replaceAll('</em>', '').replaceAll('<strike>', '').replaceAll('</strike>', '').replaceAll('<br>', '').trim();
            this.sslcrequiredes = plainTextValeue
            if (this.sslcrequiredes != '') {
                this.template.querySelector('.descInputSSLC')?.classList.remove('Descriptionborder');
                this.descriptionSSLC = false;
            }
        }
        else if (event.target.dataset.id === 'custmerreference') {
            this.custmerreference = value;
        } else if (event.target.dataset.id === 'endcustomer') {
            this.endcustomer = value;
        }

        //'this.caseType!= undefined && this.caseType!= null' added by Kamala on 30-04-2026 - TWC745-9174 as part of Lightening Component exception 
        
        if ( this.caseType!= undefined && this.caseType!= null && this.caseType.length > 0) {
            this.isCasetypeEmpty = false;
        }
        if(this.caseType == 'Question'){
            
            this.isSeverity_Question = true;
            this.isSeverity_Debug = false;
            this.isSeverity_Feature = false;
            this.isSeverity_Design = false;
        }
        if(this.caseType == 'Design Review'){
            this.isSeverity_Question = false;
            this.isSeverity_Debug = false;
            this.isSeverity_Feature = false;
            this.isSeverity_Design = true;
        }
        if(this.caseType == 'Feature Request'){
            this.isSeverity_Question = false;
            this.isSeverity_Debug = false;
            this.isSeverity_Feature = true;
            this.isSeverity_Design = false;
        }
        if(this.caseType == 'Debug Request'){
            this.isSeverity_Question = false;
            this.isSeverity_Debug = true;
            this.isSeverity_Feature = false;
            this.isSeverity_Design = false;
        }
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    handleCategoryChange() {

    }
    navigateToViewCase() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'case-detail'
            },
            state: {
                recordId: this.recordId
            }
        });
    }
    validateedq() {
        if (this.trackvalidation.length === 0) {
            this.valCheck = true;
        }

    }
    handleCreateCase(event) {

        let createValid = true;
        if (this.subject == '' || this.subject == undefined || this.subject == null) {
            createValid = false;
            this.isRequiredSubject = true;
            this.template.querySelector('.subjectInput')?.classList.add('showRequired');
            this.template.querySelector('.subjectInput')?.scrollIntoView();
        }
        if (this.description == '' || this.description == undefined || this.description == null || this.plainTextValue === '') {
            createValid = false;
            this.isRequiredDesc = true;
            this.template.querySelector('.descIput')?.classList.add('Descriptionborder');
            this.template.querySelector('.descIput')?.scrollIntoView();
        }
        if (this.caseType == '' || this.caseType == undefined || this.caseType == null) {
            createValid = false;
            this.isRequiredCaseType = true;
            this.template.querySelector('.caseTypeInput')?.classList.add('showRequired');
            this.template.querySelector('.caseTypeInput')?.scrollIntoView();
        }
        //Added by chetan as part of Bug assist validation
        if(this.casedatainfo.isBugAssitCase === true && this.casedatainfo.selectedReason === 'Case Type is not “Debug Request"' && this.caseType == ''){
            createValid = false;
            this.isRequiredCaseType = false;
        }
        if (this.CaseCategoryy == null || this.CaseCategoryy == undefined || this.CaseCategoryy == '') {
            if(this.CaseCategoryoptions == true){
             createValid = false;
            this.categoryReq = true;
            this.template.querySelector('.categoryInput')?.classList.add('showRequired');
            this.template.querySelector('.categoryInput')?.scrollIntoView();
            }

        }
        if (this.CaseSubcategoryy == null || this.CaseSubcategoryy == undefined || this.CaseSubcategoryy == '') {
            if(this.showSubCategories == true){
             createValid = false;
            this.subCategoryReq = true;
            this.template.querySelector('.subCategoryInput')?.classList.add('showRequired');
            this.template.querySelector('.subCategoryInput')?.scrollIntoView();
            }

        }
        if (this.showSeverityReason == true && (this.caseseverityReason == null || this.caseseverityReason == undefined || this.caseseverityReason == '')) {
            createValid = false;
            this.severityRsnReq = true;
            this.template.querySelector('.severityInput')?.classList.add('showRequired');
            this.template.querySelector('.severityInput')?.scrollIntoView();
            event.preventDefault();
            this.template.querySelector('.slds-textarea').style = "margin-bottom:-4px";
        }
        if (this.partnerSupportAccount == null || this.partnerSupportAccount == undefined || this.partnerSupportAccount == ''){
            console.log('boolean',this.booleanRequired);
            //if(this.booleanRequired == false && this.agentCheck == true){ // Niyaz removed this.booleanRequired == false && because the combination was not correct
            if(this.booleanRequired == true && this.agentCheck == true){
            createValid = false;
            this.template.querySelector('.PSArequired')?.classList.add('showRequired');
            this.template.querySelector('.PSArequired')?.scrollIntoView();
            this.isPSArequired = true;
            }
        }

        this.primaryDetailsValid = createValid;
        this.hanldeSaveReport();


    }
    //transforming hanldeSaveReport to aysnc as part of BugAssist by Hassan Khan
    async hanldeSaveReport() {
        let finalEdq;
        let tempSubjectVariable;
        this.trackvalidation = [];
        let caseRecordId; // Added by Hassan as part of Bug Assist
        if (this.showSeverityReason == false) {
            this.caseseverityReason = '';
        }
        if ((this.Subjectvalue != this.subject) && (this.subject !== null || this.subject !== '' || this.subject !== undefined)) {
            tempSubjectVariable = this.subject;
        } else {
            tempSubjectVariable = this.Subjectvalue;
        }
        finalEdq = JSON.stringify(this.subcatrecedqs);
        if (this.casedatainfo.showProdEdqs === true) {
            this.template.querySelector('c-dynamic-form-builder[data-id="prodEDQ"]').callhandleQuestionAnswer();
        }
        if (this.showcubcatedqs === true) {
            this.template.querySelector('c-dynamic-form-builder[data-id="subCatEDQ"]').callhandleQuestionAnswer();
        }
        


        for (const x of this.savealldataedqMap.keys()) {
            this.savealldataedq.push(this.savealldataedqMap.get(x));
        }
        var strEdq = JSON.stringify(this.savealldataedq);
        let finStr = JSON.parse(strEdq);
        this.validateedq();
       
        if (this.valCheck && this.primaryDetailsValid) {

            this.spinnerOn = true;
            
            var caseObj = {
                Core_IPS_Project_Case__c: this.casedatainfo.project,
                ContactId: this.casedatainfo["contactId"],
                AccountId: this.casedatainfo.accountId,
                AssetId: (this.casedatainfo.Product !== undefined && this.casedatainfo.Product !== null) ? this.casedatainfo.Product : '',
                Subject: this.subject,
                Core_Issue_Description__c: this.description,
                Core_Severity__c: this.severityValue,
                Core_Severity_Reason__c: this.caseseverityReason,
                Core_CaseType__c: this.caseType,
                Core_Case_Issue_Category__c: (this.casedatainfo.CategoryId != this.createCategory) && (this.createCategory != null || this.createCategory != undefined) ? this.createCategory : this.casedatainfo.CategoryId,
                Core_Case_Issue_Sub_Category__c: (this.casedatainfo.SubCategoryId != this.createSubCategory) && (this.createSubCategory != null || this.createSubCategory != undefined) ? this.createSubCategory : this.casedatainfo.SubCategoryId,
                Core_External_Issue_Category__c: (this.casedatainfo.CategoryName != this.createCategoryLabel) && (this.createCategoryLabel != null || this.createCategoryLabel != undefined) ? this.createCategoryLabel : this.casedatainfo.CategoryName,
                
                Core_External_Issue_Subcategory__c: (this.createSubCategorylabel == undefined) ? '' : this.createSubCategorylabel,//this.casedatainfo.SubCategoryName
                Core_IPS_Customer_Visible__c: true,
                Core_Customer_Reference_ID__c: this.custmerreference,
                Core_End_Customer__c: this.endcustomer,
                Core_IPS_Country_Region__c: this.casedatainfo.country,
                    Core_IPS_Embargoed_State__c: this.casedatainfo.state,
                Core_Product_Variant__c: this.casedatainfo.productvariantName,
                Core_IPS_Minds__c: this.casedatainfo.mindsValue,
                Core_Partner_Supported_Account__c: this.agentCheck == true ? this.partnerSupportAccount : null,
                Core_IPS_Partner_Sup_Owner__c: this.agentCheck == true ? this.partnerSupportOwnerId : null,
                Origin: 'Web', /*By Tejaswini H TWC745-6588: Empty Case Origin issue Sept 23, 2024. Case creation from Portal*/

                //New Added by Hassan for BUG Assist 
                Do_you_have_SST_log_to_upload__c : this.casedatainfo.sstLogvalueTF,
                Reason_for_not_providing_the_SST_Log__c : this.casedatainfo.selectedReason
            }

            await SubmitCaseRecord({
                newRecord: caseObj,
                contactRecord: this.selectedContactRecord,
                caseEDQdata: strEdq
            })

                .then(result => {
                    if (result !== undefined || result !== null) {
                        this.spinnerOn = false;
                        if (this.recordId !== null || this.recordId !== undefined) {
                            this.spinnerOn = false;
                            this.showToast('Success', 'Case has been created.', 'success');
                            this.sendEventTOCoveo();    // passing custom event to coveo method 
                        }
                        this.recordId = result.Id;
                        caseRecordId = result.Id; // Added by Hassan as part of Bug Assist
                        this.updateDeflectedObj();
                        this.navigateToViewCase();
                    }
                })
                .catch(error => {
                     this.spinnerOn = false;
                    this.showToast('ERROR', error.body.message, 'error');
                });
        }
        this.savealldataedq = [];

        console.log('Hk 479 ---> ',JSON.stringify(this.casedatainfo));

        //Added By Hassan to Convert BUG Assist Attachment record to IPS Attachment
        if(this.casedatainfo.isBugAssitCase === true && this.casedatainfo.sstLogvalueTF ===true && this.casedatainfo.bugAssistRecordId != null && (this.casedatainfo.selectedReason === null || this.casedatainfo.selectedReason === undefined)){
            bugAssistRecordConversion({
            caseId: caseRecordId,
            bugAssistrecordId: this.casedatainfo.bugAssistRecordId
            }).catch((error) => {
                this.error = error;
            });
        }
        else if(this.casedatainfo.isBugAssitCase === true && this.casedatainfo.sstLogvalueTF === false && this.casedatainfo.bugAssistRecordId != null && (this.casedatainfo.selectedReason != null || this.casedatainfo.selectedReason != undefined)) {
            bugAssistRecordDeletion({
            bugAssistrecordId: this.casedatainfo.bugAssistRecordId
            }).catch((error) => {
                this.error = error;
            });
        }
    }
    @api contactCountry;
    value = this.contactCountry;
    handleChangeMINDS(event) {
        if (event.target.name == "yeschecked") {
            if (event.target.checked) {
                this.showboolean1 = true;
                this.showboolean2 = false;
                this.mindsValueForSSLSC = true;
            } else {
                this.showboolean1 = false;
                this.showboolean2 = true;
            }
        }
        if (event.target.name == "nochecked") {
            if (event.target.checked) {
                this.showboolean1 = false;
                this.showboolean2 = true;
            } else {
                this.showboolean1 = true;
                this.showboolean2 = false;
            }
        }
    }
    defaultSubjectvaluesslc;
    @api Projectdefault;
    @api Assetdefault;
    @api subjectvaluesslc;
    @api descriptiondefault='';
    @api CaseTypedefault;
    @api Case_Categorydefault;
    @track CaseSubcategorydefault;
    @track Case_Categorydefaultid;
    @track Projectdefaultid;
    @track Assetdefaultid;
    @track CaseSubcategoryDetaildefalutid;
    caseCategoryOptions = [];
    handleLoad() {
        getCustomSettingLogs().then(result => {
                this.defaultdatainfo = result;
               
                for (let key in this.defaultdatainfo) {
                    for (let key1 in this.defaultdatainfo[key]) {
                        if (key == 0 && key1 == "Core_IPS_Default_Data__c") {
                            this.descriptiondefault = this.defaultdatainfo[key][key1];
                        }
                        if (key == 1 && key1 == 'Core_IPS_Default_Data__c') {
                            this.Assetdefault = this.defaultdatainfo[key][key1];
                        }
                        if (key == 1 && key1 == 'Core_IPS_Default_data_Id__c') {
                            this.Assetdefaultid = this.defaultdatainfo[key][key1];
                        }
                        if (key == 2 && key1 == 'Core_IPS_Default_Data__c') {
                            this.Projectdefault = this.defaultdatainfo[key][key1];
                        }
                        if (key == 2 && key1 == 'Core_IPS_Default_data_Id__c') {
                            this.Projectdefaultid = this.defaultdatainfo[key][key1];
                        }
                        if (key == 3 && key1 == 'Core_IPS_Default_Data__c') {
                            this.CaseTypedefault = this.defaultdatainfo[key][key1];
                        }
                        if (key == 4 && key1 == 'Core_IPS_Default_Data__c') {
                            this.CaseSubcategoryDetaildefalut = this.defaultdatainfo[key][key1];
                        }
                        if (key == 4 && key1 == 'Core_IPS_Default_data_Id__c') {
                            this.CaseSubcategoryDetaildefalutid = this.defaultdatainfo[key][key1];
                            this.getSubCategoryDefaultEdqs(this.CaseSubcategoryDetaildefalutid);
                        }
                        if (key == 5 && key1 == 'Core_IPS_Default_Data__c') {
                            this.Supported_Productdefault = this.defaultdatainfo[key][key1];
                        }
                        if (key == 5 && key1 == 'Core_IPS_Default_data_Id__c') {
                            this.Supported_ProductdefaultID = this.defaultdatainfo[key][key1];
                            this.getCatergories(this.Supported_ProductdefaultID);
                            this.defaultgetProductEdqs(this.Supported_ProductdefaultID);
                        }
                        if (key == 6 && key1 == 'Core_IPS_Default_Data__c') {
                            this.IssueSourcedefault = this.defaultdatainfo[key][key1];
                        }
                        if (key == 7 && key1 == 'Core_IPS_Default_Data__c') {
                            this.Case_Categorydefault = this.defaultdatainfo[key][key1];
                            this.CaseCategoryName = this.defaultdatainfo[key][key1];
                        }
                        if (key == 7 && key1 == 'Core_IPS_Default_data_Id__c') {
                            this.Case_Categorydefaultid = this.defaultdatainfo[key][key1];
                            this.getCatergories(this.Case_Categorydefaultid);
                            this.getProductEdqs(this.Case_Categorydefaultid);
                            this.showCasedefaultSubCategory(this.Case_Categorydefaultid);
                        }
                        
                        if (key == 8 && key1 == 'Core_IPS_Default_Data__c') {}
                        if (key == 8 && key1 == 'Core_IPS_Default_data_Id__c') {}
                    }
                }

            })
            .catch(error => { this.error = error; });
        const childEvent = new CustomEvent('getmode', {
            detail: {
                firstParam: this.sslcmode,
            }
        });
        this.dispatchEvent(childEvent);
    }
    handleChangesubject(event) {
        this.defaultSubjectvaluesslc = event.detail.value;
        const subjectreqsslc = this.defaultSubjectvaluesslc.trim();
        if (subjectreqsslc != '') {
            this.isRequiredSubjectSSLC = false;
            this.template.querySelector('.subjectSSLC')?.classList.remove('showRequired');
        }
    }
    caseTypevalue = "Question";
    get CaseTypeOptions() {
        return [
            { label: "Question", value: "Question" },
            { label: "Design Review", value: "Design Review" },
            { label: "Feature Request", value: "Feature Request" },
            { label: "Debug Request", value: "Debug Request" },
        ];
    }
    severitydefValue = "Low";
    get defaultcaseSeverityoptions() {
        return [
            { label: "Low", value: "Low" },
            { label: "Medium", value: "Medium" },
            { label: "High", value: "High" },
            { label: "Critical", value: "Critical" },
        ];
    }
    defaultycaseseverity;
    handlesevdefChange(event) {
        this.severitydefValue = event.detail.value;
        if (this.severitydefValue == 'Critical') {
            this.sslcSeverityReason = true;
        } else {
            this.sslcSeverityReason = false;
        }
    }
    handlesslcChange(event) {
        this.severityReasondefValue = event.detail.value;
        this.severityResSSLC = false;
        this.template.querySelector('.SeverityReasonSSLC')?.classList.remove('showRequired');
    }
    createCategory;
    createCategoryLabel;
    handleChangeCategory(event) {
        this.CaseSubcategoryy = undefined;// '' removed
       
        this.CaseCategoryy = event.target.value;
        
        this.createCategory = this.CaseCategoryy;
        this.createSubCategory = null;
        this.CaseSubcategoryy = '';
        this.CaseCategoryoptions.forEach(option => {
            if (option.value == this.createCategory) {
                this.createCategoryLabel = option.label;
            }
        });
        if (this.CaseCategoryy !== null) {
            this.categoryReq = false;
            this.template.querySelector('.categoryInput')?.classList.remove('showRequired');
            this.showCaseSubCategory(this.CaseCategoryy);
            this.getSubCategoryEdqs(null);
            
        }
    }
    showCaseSubCategory(caseCategory) {
        
        showsubCategory({
                categorySelected: caseCategory,
            }).then(result => {
               
                if (result !== undefined || result !== null) {
                    this.CaseSubcategoryoptions = result;
                    
                    this.error = undefined;
                    //if (this.subcategoryoptions.length > 0) {
                    if (this.CaseSubcategoryoptions.length > 0) {
                        // this.renderProductSubCategory = true;
                        // console.log('data present case this.renderProductSubCategory----->',this.renderProductSubCategory);
                        this.showSubCategories = true;
                    }
                    else{
                        // this.renderProductSubCategory =false;
                        // console.log('Nodata case this.renderProductSubCategory----->',this.renderProductSubCategory);
                        this.showSubCategories = false;
                        // this.createSubCategorylabel=undefined;//new need to remove
                        // console.log('undefined sub label-->',this.createSubCategorylabel);
                        
                    }
                }
            })
            .catch(error => {
                this.error = error;
                console.log('error in subcategory options----->',this.error);
            });
    }
    @api renderProductSubCategory;
    @api CaseSubCategory;
    getSubCategoryEdqs(subcategoryId) {
       
        let tempVar = subcategoryId;
        getSubCatEdq({
                supportedProductId: null,
                subCategoryid: tempVar,
                isAgent: this.casedatainfo.isAgent
            })
            .then(data => {
                let subCatEdq = [];
                for (let i = 0; i < data.length; i++) {
                    subCatEdq.push(data[i].id);
                }
                let prodEdq = [];
                for (let j = 0; j < this.casedatainfo.prodEdqRecs.length; j++) {
                    prodEdq.push(this.casedatainfo.prodEdqRecs[j].id);
                }
                let finalEdqSet = [];
                for (let k = 0; k < data.length; k++) {
                    if (prodEdq.includes(data[k].id)) {} else {
                        finalEdqSet.push(data[k]);
                    }
                }
                this.subcatrecedqs = finalEdqSet;
               
                if(this.subcatrecedqs.length>0){
                    this.showcubcatedqs = true;
                }
                else{
                    this.showcubcatedqs = false;
                }
               
            })
            .catch(error => {})
    }
    createSubCategory;
    createSubCategorylabel;
    handleChangeRenderSubCategoryedq(event) {
        let subCatId;
        let selectedSubCategory = event.detail.value;
        if (selectedSubCategory != null) {
            this.subCategoryReq = false;
            this.template.querySelector('.subCategoryInput')?.classList.remove('showRequired');
        }
        this.CaseSubcategoryy = selectedSubCategory;//new
        this.createSubCategory = selectedSubCategory;
       
        this.CaseSubcategoryoptions.forEach(option => {
            if (option.value == this.createSubCategory) {
                this.createSubCategorylabel = option.label;
                
            }
        });
        this.getSubCategoryEdqs(selectedSubCategory);
    }
    hanldeSaveDefaultReport() {
       
        this.trackvalidation = [];
        this.template.querySelector('c-dynamic-form-builder[data-id="prodEDQ"]').callhandleQuestionAnswer();
        this.template.querySelector('c-dynamic-form-builder[data-id="subCatEDQ"]').callhandleQuestionAnswer();
      
        this.validateedq();
        let validSSLC = true;
        if (this.CaseSubcategoryDetaildefalutid == '' || this.CaseSubcategoryDetaildefalutid == undefined) {
            this.subCategoryReqSSLC = true;
            validSSLC = false;
            this.template.querySelector('.subCategorySSLC')?.classList.add('showRequired');
            this.template.querySelector('.subCategorySSLC')?.scrollIntoView();
        }
        if (this.Case_Categorydefaultid == '' || this.Case_Categorydefaultid == undefined) {
            this.categoryReqSSLC = true;
            validSSLC = false;
            this.template.querySelector('.categorySSLC')?.classList.add('showRequired');
            this.template.querySelector('.categorySSLC')?.scrollIntoView();
        }
        if (this.sslcSeverityReason == true && (this.severityReasondefValue == '' || this.severityReasondefValue == undefined)) {
            this.severityResSSLC = true;
            validSSLC = false;
            this.template.querySelector('.SeverityReasonSSLC')?.classList.add('showRequired');
            this.template.querySelector('.SeverityReasonSSLC')?.scrollIntoView();
        }
        if (this.CaseTypedefault == '' || this.CaseTypedefault == undefined) {
            this.caseTypeInputSSLC = true;
            validSSLC = false;
            this.template.querySelector('.caseTypeSSLC')?.classList.add('showRequired');
            this.template.querySelector('.caseTypeSSLC')?.scrollIntoView();
        }
        if (this.descriptiondefault == "" || this.descriptiondefault == undefined || this.sslcrequiredes == '') {
            this.descriptionSSLC = true;
            validSSLC = false;
            this.template.querySelector('.descInputSSLC')?.classList.add('Descriptionborder');
            this.template.querySelector('.descInputSSLC')?.scrollIntoView();
        }
        if (this.defaultSubjectvaluesslc == '' || this.defaultSubjectvaluesslc == undefined || this.defaultSubjectvaluesslc.trim().length == 0) {
            this.isRequiredSubjectSSLC = true;
            validSSLC = false;
            this.template.querySelector('.subjectSSLC')?.classList.add('showRequired');
            this.template.querySelector('.subjectSSLC')?.scrollIntoView();

        }
        if (this.selectedCountryValue == 'None') {
            this.countrySSLCReq = true;
            this.template.querySelector('.countrySSLCInput')?.classList.add('showRequired');
            this.template.querySelector('.countrySSLCInput')?.scrollIntoView();
        }
        this.template.querySelector('c-dynamic-form-builder[data-id="prodEDQ"]').callhandleQuestionAnswer();
        this.template.querySelector('c-dynamic-form-builder[data-id="subCatEDQ"]').callhandleQuestionAnswer();

        if (this.valCheck) {
            this.spinnerOn = false;
            var caseObj = {
                Core_IPS_Project_Case__c: this.Projectdefaultid,
                ContactId: this.casedatainfo["contactId"],
                AccountId: this.casedatainfo.accountId,
                AssetId: this.Assetdefaultid,
                Subject: this.defaultSubjectvaluesslc,
                Core_Issue_Description__c: this.descriptiondefault,
                Core_Severity__c: this.severitydefValue,
                Core_Severity_Reason__c: this.severityReasondefValue,
                Core_CaseType__c: this.CaseTypedefault,
                Core_Case_Issue_Category__c: (this.casedatainfo.CategoryId !== undefined && this.casedatainfo.CategoryId !== null) ? this.casedatainfo.CategoryId : this.Case_Categorydefaultid,
                Core_Case_Issue_Sub_Category__c: (this.casedatainfo.SubCategoryId != undefined && this.casedatainfo.SubCategoryId != null) ? this.casedatainfo.SubCategoryId : this.CaseSubcategoryDetaildefalutid,
                
                //Core_External_Issue_Subcategory__c: (this.casedatainfo.SubCategoryName != this.createSubCategorylabel) && (this.createSubCategorylabel != null || this.createSubCategorylabel != undefined) ? this.createSubCategorylabel : this.casedatainfo.SubCategoryName,
                Core_IPS_Customer_Visible__c: true,
                Core_IPS_Country_Region__c: this.selectedCountryValue,
                Core_IPS_Embargoed_State__c: this.casedatainfo.state,
                Core_IPS_Minds__c: this.mindsValueForSSLSC
            }
            this.spinnerOn = false;

            if (validSSLC) {
                for (const x of this.savealldataedqMap.keys()) {
                    this.savealldataedq.push(this.savealldataedqMap.get(x));
                    console.log('Key=' + x + ', Value=' + JSON.stringify(this.savealldataedqMap.get(x)));
                }
                var strEdq = JSON.stringify(this.savealldataedq);
               
                this.spinnerOn = true;
                
                SubmitCaseRecord({ newRecord: caseObj, contactRecord: this.selectedContactRecord, caseEDQdata: strEdq })
                    .then(result => {
                        if (result !== undefined || result !== null) {
                            this.spinnerOn = false;
                            if (this.recordId !== null || this.recordId !== undefined) {
                                this.spinnerOn = false;
                                this.showToast('Success', 'Case has been created.', 'success');
                            }
                            this.recordId = result.Id;
                            this.navigateToViewCase();
                        }
                    })
                    .catch(error => {
                        this.spinnerOn = false;
                        console.error(error);
                        this.showToast('ERROR', error.body.message, 'error');
                    });
            }
            this.savealldataedq = [];
        }
    }

    updateDeflectedObj() {
        updateDeflectedObject({ deflectedId: this.defectedobjectid, caseId: this.recordId })
            .then(result => {

            })
            .catch(error => {})
    }
    getCatergories(prodId) {
        let tempVar;
        if (prodId != null) {
            tempVar = prodId;
        } else {
            tempVar = undefined;
        }
        if (tempVar != null || tempVar != undefined) {
            getCategoryOptions({
                    prodId: tempVar
                })
                .then(data => {
                    if (data) {
                        this.showCategories = true;
                        this.renderProductCategory = true;
                        let options = [];
                        data.forEach(eachRecord => {
                            options.push({ label: eachRecord.Core_Issue_Category_Name__r.Name, value: eachRecord.Id });
                        });
                        this.caseCategoryOptions = options;
                    }
                })
                .catch(error => {})
        }
    }
    prodEdqRecs;
    getProductEdqs(supportedId) {
       
        let tempVar = supportedId;
        getProdEdq({
                supportedProductId: tempVar,
                subCategoryid: null,
                isAgent: this.agentCheck
            })
            .then(data => {
                if (data) {
                    this.prodEdqRecs = data;
                    if (this.prodEdqRecs.length > 0) {
                        this.showEdqSection = true;
                        this.showProdEdqs = true;
                    }
                }
            })
            .catch(error => {})
    }
    getSubcategories(categoryId) {
        let tempVar;
        if (categoryId != null) {
            tempVar = categoryId;
        } else {
            tempVar = undefined;
        }
        if (tempVar != null || tempVar != undefined) {
            getSubCategoryOptions({
                    categoryId: tempVar
                })
                .then(data => {
                    if (data) {
                        this.showSubCategories = true;
                        let options = [];
                        data.forEach(eachRecord => {
                            options.push({ label: eachRecord.Core_Issue_Sub_Category_Name__r.Name, value: eachRecord.Id });
                        });
                        this.CaseSubCategoryOptions = options;
                        for (let i = 0; i < options.length; i++) {
                            if (options[i].value != undefined) {
                                this.CaseCategory = options[i].value;
                            }
                        }
                    }
                })
                .catch(error => {})
        }

    }

    handleChangecasetype(event) {
        this.CaseTypedefault = JSENCODE(event.detail.value);
        this.caseTypeInputSSLC = false;
        this.template.querySelector('.caseTypeSSLC')?.classList.remove('showRequired');
    }
    defaultprodEdqRecs = [];
    defaultgetProductEdqs(supportedId) {
       
        let tempVar = supportedId;
        getProdEdq({
                supportedProductId: tempVar,
                subCategoryid: null,
                isAgent: this.agentCheck
            })
            .then(data => {
                if (data) {
                    this.defaultprodEdqRecs = data;
                    if (this.defaultprodEdqRecs.length > 0) {
                        this.showEdqSection = true;
                        this.showProdEdqs = true;
                    }
                }
            })
            .catch(error => {})
    }
    showCaseSubCategory(caseCategory) {
        showsubCategory({
                categorySelected: caseCategory,
            }).then(result => {
               
                if (result !== undefined || result !== null) {
                    this.CaseSubcategoryoptions = result;
                    this.error = undefined;
                    //if (this.subcategoryoptions.length > 0) {
                    if (this.CaseSubcategoryoptions.length > 0) {
                        this.renderProductSubCategory = true;
                        
                        this.showSubCategories = true;
                       
                    }
                    else{
                        this.renderProductSubCategory =false;//new
                       
                        this.CaseSubcategoryy=undefined;//new
                        
                        this.showSubCategories = false;
                        this.createSubCategorylabel=undefined; //new *
                       
                    }
                    
                }
                
            })
            .catch(error => {
                this.error = error;
            });
    }
    handleChangedefaultCategory(event) {
        this.Case_Categorydefault = event.target.value;
        this.Case_Categorydefaultid = event.target.value;
        this.CaseSubcategoryDetaildefalutid = '';
        if (this.Case_Categorydefault !== null) {
            this.categoryReqSSLC = false;
            this.template.querySelector('.categorySSLC')?.classList.remove('showRequired');
            this.showCasedefaultSubCategory(this.Case_Categorydefault);
            this.getSubCategoryDefaultEdqs(null);
        }
    }

    CaseSubDefaultcategoryoptions;
    showCasedefaultSubCategory(defaultCaseCategory) {
        showsubCategory({
                categorySelected: defaultCaseCategory,
            }).then(result => {
                if (result !== undefined || result !== null) {
                    this.CaseSubDefaultcategoryoptions = result;
                    this.error = undefined;
                    if (this.CaseSubDefaultcategoryoptions.length > 0) {
                        this.renderProductSubCategory = true;
                        this.showSubCategories = true;
                    }
                    else{
                        this.showSubCategories = false; 
                    }
                    
                }
            })
            .catch(error => {
                this.error = error;

            });
    }
    getcountryvalues() {
        getcountryfields()
            .then(result => {
                this.selectedCountryValue = result[0].Core_Country_Region__c;
                this.showboolean1 = result[0].Core_MINDS__c;
                if (result[0].Core_MINDS__c) {
                    this.showboolean1 = true;
                    this.showboolean2 = false;
                    if (this.showboolean1) {
                        this.mindsValueForSSLSC = true;
                    }
                } else {
                    this.showboolean1 = false;
                    this.showboolean2 = true;
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.accounts = undefined;
            })
    }
    handlePicklistChange(event) {
        let strCheck = JSON.stringify(event.detail.value);
        this.selectedCountryValue = strCheck.replace(/['"]+/g, '');
       
        this.value = this.selectedCountryValue;
        this.countrySSLCReq = false;
        this.template.querySelector('.countrySSLCInput')?.classList.remove('showRequired');
    }
    subCatId
    handleChangeDefaultSubCategoryedq(event) {
        let selectedSubCategory = event.detail.value;
        if (selectedSubCategory != null) {
            this.subCategoryReqSSLC = false;
            this.template.querySelector('.subCategorySSLC')?.classList.remove('showRequired');
        }
        this.CaseSubDefaultcategoryoptions.forEach(option => {
            if (option.value == selectedSubCategory) {
                this.subCatId = option.value;
                this.CaseSubcategoryDetaildefalutid = option.value;
                this.CaseSubcategoryDetaildefalut = option.label;
            }
        });
        let subCatId = this.CaseSubcategoryDetaildefalutid
        this.getSubCategoryDefaultEdqs(subCatId);
    }
    countryOptions;
    @wire(getObjectInfo, { objectApiName: Contact })
    objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Core_Country_Region__c })
    wiredData({ error, data }) {
        if (data) {
            let dataOjb = data.values;
            let finalData = [{ label: "--None--", value: "None" }, ...dataOjb];
            this.countryOptions = finalData.map(objPL => {
                return {
                    label: `${objPL.label}`,
                    value: `${objPL.value}`
                };
            });
        } else if (error) {
            this.showToast('ERROR', 'Country field cannot be None', 'error');
        }
    }
    @track defaultsubcatrecedqs;
    getSubCategoryDefaultEdqs(subCatId) {
        let tempVar = subCatId;
        getSubCatEdq({
                supportedProductId: null,
                subCategoryid: tempVar,
                isAgent: false
            })
            .then(data => {
                let subCatEdq = [];
                for (let i = 0; i < data.length; i++) {
                    subCatEdq.push(data[i].id);
                }
                let prodEdq = [];
                for (let j = 0; j < this.defaultprodEdqRecs.length; j++) {
                    prodEdq.push(this.defaultprodEdqRecs[j].id);
                }
                let finalEdqSet = [];
                for (let k = 0; k < data.length; k++) {
                    if (prodEdq.includes(data[k].id)) {} else {
                        finalEdqSet.push(data[k]);
                    }
                }
                this.defaultsubcatrecedqs = finalEdqSet;
               
                //console.log('subcatedqs==- mode sslc'+this.mode+this.sslcmode);
            })
            .catch(error => {})
    }
    @track agentCheck;
    @track partnerSupportOwner;
    getUserProfile() {
        getcurrentuserprofile({})
            .then(data => {
                console.log('data ==1==== ',data);
                if (data === 'PartnerAgent' || data === 'PartnerFAE') {
                    this.agentCheck = true;
                    this.getPartnerSupportOwnerApex(this.casedatainfo.project);
                    this.getPartnerSupportedAccountApex(this.casedatainfo.project, this.userId);
                } else {
                    this.agentCheck = false;
                    
                }
            })
            .catch(error => {})
    }

    partnerSupportOwnerId;
    getPartnerSupportOwnerApex(projectId) {
        getPartnerSupportOwner({
            passedProjectId: projectId
        }).then(data => {
            if (data) {
                let tempSupportOwner = JSON.parse(JSON.stringify(data));
                this.partnerSupportOwner = tempSupportOwner.Name;
                this.partnerSupportOwnerId = tempSupportOwner.Id;
            } else {}
        }).catch(error => {})
    }
    partnerSupportAccount;
    @track partnerSupportedAccount = [];
    getPartnerSupportedAccountApex(projectId, passUserId) {
        getSupportedAccount({
            selectedProject: projectId,
            userID: passUserId
        }).then(data => {
            if (data) {
                let tempPartnerAccounts = data;
                let options = [];
                for (let key in tempPartnerAccounts) {
                    options.push({ label: tempPartnerAccounts[key], value: key });
                }
                this.partnerSupportedAccount = options;
            } else {}
        }).catch(error => {})
    }
    
    handleChangePartnerAccount(event) {
        this.partnerSupportAccount = event.detail.value;
        this.template.querySelector('.PSArequired')?.classList.remove('showRequired');
        this.isPSArequired = false;
    }
    openSeverityhelptextModal(){
        this.isOpenSeverityModal = true;
    }
    closeSeverityhelptextModal(){
        this.isOpenSeverityModal = false;
    }
    getUserProfileData(event) {
        getcurrentuserprofile({})
            .then(data => {
                console.log('data ====== ',data);
                if (data === 'PartnerAgent') {
                    this.agentCheck = true;
                    
                } else {
                    this.agentCheck = false;
                    
                }
                
            })
            .catch(error => {
    
            })
    }
    sendEventTOCoveo(){
        this.template.querySelector('c-core_-i-p-s_-coveo-event-on-submit_-lex').sendEventTOCoveo();
    }
    handleRequired() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false
            }
        });
        return isValid;
    }

}