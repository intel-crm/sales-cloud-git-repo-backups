import { api, LightningElement, track, wire } from 'lwc';
import getCurrentCase from '@salesforce/apex/Core_IPS_TestAllRecords.getCurrentCase';
import getProjStatus from '@salesforce/apex/Core_IPS_TestAllRecords.getProjectStatus';
import getProdStatus from '@salesforce/apex/Core_IPS_TestAllRecords.getProductStatus';
import getCurrentCaseComments from '@salesforce/apex/Core_IPS_TestAllRecords.getCurrentCaseComments';
import getattachments from '@salesforce/apex/Core_IPS_TestAllRecords.getattachments';
import showsubCategory from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getSubCategoryDetail";
import retriveCaseData from '@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.geCloneCaseDetails'; //Anil Case Copy
import getCaseData from '@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.getCaseDetails'; //Anil Case Copy
import getCaseonLoad from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getCaseData";
// import scftlabel from "@salesforce/label/c.Core_IPS_File_SCFT_URL_Azure_Migration";
import getProductVariants from '@salesforce/apex/Core_IPS_AdminUtility.getProductVariants';
import displaySubCategoryData from '@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.displaySubCategoryData'; //Anil Case Copy
import displayCategoryData from '@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.displayCategoryData'; //Anil Case Copy
import getBaseUrlToLoadIframePage from '@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.getBaseUrlToLoadIframePage'; //Anil Case Copy
import getProdEdq from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getProductEDQ"; //Anil Case Copy
import getSubCatEdq from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getSubCatProductEDQ"; //Anil Case Copy
import SubmitCaseRecord from "@salesforce/apex/Core_IPS_CaseCreateLWCController.submitCaseRecord"; ///Anil Case Copy
import insertCaseData from "@salesforce/apex/Core_IPS_Case_Clone_Controller_LEX.insertCaseData";
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCaseClosed from '@salesforce/apex/Core_IPS_TestAllRecords.getCaseClosed';
import saveNewComment from '@salesforce/apex/Core_IPS_TestAllRecords.saveNewComment';
import updateCaseDetails from '@salesforce/apex/Core_IPS_TestAllRecords.updateCaseDetails';
import getEnvDetails from '@salesforce/apex/Core_IPS_TestAllRecords.getEnvDetails';
// import prepareUrl from '@salesforce/apex/Core_IPS_File_AttachToCase_Controller.prepareUrl'; // krishna
import getcurrentuserprofile from '@salesforce/apex/Core_IPS_TestAllRecords.getcurrentuserprofile';
// import getcurcasestatus from '@salesforce/apex/Core_IPS_TestAllRecords.getcurcasestatus';
import getcurUsername from '@salesforce/apex/Core_IPS_TestAllRecords.getcurUsername';
import getFileList from '@salesforce/apex/Core_IPS_caseAttLinkFileCont_LWC.getFiles';
import saveRecords from '@salesforce/apex/Core_IPS_caseAttLinkFileCont_LWC.saveFile';
import deleteAttachmentRecord from '@salesforce/apex/Core_IPS_TestAllRecords.deleteAttachmentRecord';
import core_Ips_InterestedParties_CTRL1 from '@salesforce/apex/core_Ips_InterestedParties_CTRL.core_Ips_InterestedParties_CTRL1';
import addOrRemovePartyMembers from '@salesforce/apex/core_Ips_InterestedParties_CTRL.addOrRemovePartyMembers';
import IPS_Survey_BannerLink from '@salesforce/label/c.IPS_Survey_BannerLink';
import IPS_Survey_LOGO from '@salesforce/resourceUrl/Core_IPS_New_Logo';
import Core_IPS_No_External_Active_Member from '@salesforce/label/c.Core_IPS_No_External_Active_Member';
// import submitCaseClosureRes from '@salesforce/apex/Core_IPS_TestAllRecords.submitCaseClosureRes';
// import Core_IPS_CaseRTF_Intel_Technical_Specialist from '@salesforce/label/c.Core_IPS_CaseRTF_Intel_Technical_Specialist';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
// import Comments from '@salesforce/schema/Case.Comments';
// import { refreshApex } from '@salesforce/apex';
import surveyMessage from '@salesforce/label/c.Core_IPS_PortalSurveyMessage'

//minhaj
//minhaj
import Core_Country_Region__c from '@salesforce/schema/Contact.Core_Country_Region__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Contact from '@salesforce/schema/Contact';
//country values
import getcountryfields from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getcountryfields";
import getLoggedInContacts from "@salesforce/apex/core_IPS_caseCreate_LEX.getContactDetails";
import TIME_ZONE from '@salesforce/i18n/timeZone';

//Added by Shruti
// import getPartnerSupportOwner from '@salesforce/apex/Core_IPS_TestAllRecords.getPartnerSupportOwner';
import getSupportedAccount from '@salesforce/apex/Core_IPS_TestAllRecords.getSupportedAccount';
import getSupOwnerAndSupAccountforEditCase from '@salesforce/apex/Core_IPS_TestAllRecords.getSupOwnerAndSupAccountforEditCase';
import Id from '@salesforce/user/Id';
import EdqAlignLast from '@salesforce/resourceUrl/EdqAlignmentLast';
import EdqAlignment from '@salesforce/resourceUrl/EdqAlignment';
import { loadStyle } from 'lightning/platformResourceLoader'
// import TickerSymbol from '@salesforce/schema/Account.TickerSymbol';
import Core_IPS_Required from '@salesforce/label/c.Core_IPS_Required'; 
import Core_IPS_Minds_Message from '@salesforce/label/c.Core_IPS_Minds_Message';
import Core_IPS_Preferences_Message from '@salesforce/label/c.Core_IPS_Preferences_Message';
import Core_IPS_Country_Message from '@salesforce/label/c.Core_IPS_Country_Message';
import Core_IPS_Permission_Message from '@salesforce/label/c.Core_IPS_Permission_Message';
import Core_IPS_Note_Message from '@salesforce/label/c.Core_IPS_Note_Message';
import Core_IPS_Limit_Message from '@salesforce/label/c.Core_IPS_Limit_Message';
import Core_IPS_Notes_Message from '@salesforce/label/c.Core_IPS_Notes_Message';
import Core_IPS_Company_Message from '@salesforce/label/c.Core_IPS_Company_Message';
const timezone = TIME_ZONE;
let attachmentcolumns = [
    { label: 'File Name', fieldName: 'Core_File_Name__c', type: 'text' },
    { label: 'Description', fieldName: 'Core_File_Description__c', type: 'text' },
    { label: 'File Size', fieldName: 'Core_File_Size__c', type: 'text' },
    { label: 'File Download Link', type: 'button', fieldName: 'Core_File_URL__c', typeAttributes: { label: { fieldName: 'Fieldlabelname' }, variant: 'brand' } },
    { label: 'Upload Status', fieldName: 'Core_Upload_Status__c', type: 'text' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'text' },
];
const actions = [
    { label: 'Edit', name: 'Edit' },
    { label: 'Delete', name: 'Delete' }
];

let attachmentAgentcolumns = [{
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: ' bottom-left,'
        }
    },

    { label: 'File Name', fieldName: 'Core_File_Name__c', type: 'text' },
    { label: 'Description', fieldName: 'Core_File_Description__c', type: 'text' },
    { label: 'File Size', fieldName: 'Core_File_Size__c', type: 'text' },
    { label: 'File Download Link', type: 'button', fieldName: 'Core_File_URL__c', typeAttributes: { label: { fieldName: 'Fieldlabelname' }, variant: 'brand' } },
    { label: 'Upload Status', fieldName: 'Core_Upload_Status__c', type: 'text' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'text' },
];


let linkAttachmentcolumns = [
    { label: 'File Name', fieldName: 'Core_File_Name__c', type: 'text' },
    { label: 'File Description', fieldName: 'Core_File_Description__c', type: 'text' },
    { label: 'Category', fieldName: 'Core_Category__c', type: 'text' },
    { label: 'File Size', fieldName: 'Core_File_Size__c', type: 'text' },
    { label: 'Effective Date', fieldName: 'Core_Effective_Date__c', type: 'text' },
    { label: 'Expiration Date', fieldName: 'Core_Expiration_Date__c', type: 'text' },
    { label: 'File Download Link', type: 'url', fieldName: 'Core_File_URL__c', typeAttributes: { label: { fieldName: 'Fieldlabelname' }, variant: 'brand' } },
    { label: 'Upload Status', fieldName: 'Core_Upload_Status__c', type: 'text' },
    { label: 'Upload Status Updated At', fieldName: 'Core_Last_Status_Updated_At__c', type: 'text' },
    { label: 'File GUID', fieldName: 'Core_File_GUID__c', type: 'text' },
];

export default class Core_IPS_CaseDetail_LWC extends NavigationMixin(LightningElement) {
    label = {
        IPS_Survey_BannerLink,
        Core_IPS_Required,
        Core_IPS_Minds_Message,
        Core_IPS_Preferences_Message,
        Core_IPS_Country_Message,
        Core_IPS_Permission_Message,
        Core_IPS_Note_Message,
        Core_IPS_Limit_Message,
        Core_IPS_Notes_Message,
        Core_IPS_Company_Message
    }
    @track surveyLink = IPS_Survey_BannerLink;
    @track showCloseCaseSurvey = true;
    @track ips_Survey_Logo = IPS_Survey_LOGO;
    @track showSurvey = true;
    @api recordId;
    @api attachmentURL;
    @api selectedRecordId;
    @track showmaincmp = true;
    @track showCopycmp = false;
    @track showdata = false;
    @track statedefaultvalue;
    @track selectedState;
    @track showState;
    linkdataToShow;
    @api selectedItem = 'caseComments';
    @track editattRecord = false;
    caseComments = false;
    caseInformation = false;
    isCaseClosed = false;
    isCaseClosedCmt;
    isPartnerORCustomer = false;
    isPartnerORPartnerFAE = false;
    environment = false;
    attachments = false;
    interestedParties = false;
    columns = attachmentcolumns;
    linkcolumns = linkAttachmentcolumns;
    Agentcolumns = attachmentAgentcolumns;
    @track isLinkDataAvailable = false;
    fileRecords;
    recordsCount;
    communityCheck = true;
    @track attachmentRecords;
    attachmentInitialRecords;
    @track attachmentData;
    fileData
    @track ccCommentValue;
    @track currentCaseData;
    @track isSpinner = false;
    @track passSupportedProductID;
    @track ClosedCase = true;
    contactData;
    @track selectedValuecountry;
    @track selectedCountry;

    @track enableCopy = true;
    @track enablePrint = true;
    @track editProjandProd = false;
    @track isAttachment = true;
    @track subjectReadonly = false;
    @track removeReadonly = false;
    @track descriptionReadonly = false;
    @track caseTypeReadonly = false;
    @track severityReadonly = false;
    @track customerrefReadonly = false;
    @track endCustomerReadonly = false;
    @track prodVariantReadonly = false;
    @track caseCategoryReadOnly = false;
    @track subCatReadonly = false;
    @track editSeverityReason = false;
    booleanPublictoCustomers = true;
    booleanPrivatetoPartners = true;
    booleanPrivatetoIntel = true;
    booleanLinkFile = true;
    booleanRefreshAttachments = true;
    @track isCaseCmt = true;
    @track isProjectActive = false;
    @track isProductActive = false;
    @track isProjectProjuctActive = false;
    EditPartnerAccountRequired = true;
    @track isErrormessage = false;
    @track errorMessageLabel = Core_IPS_No_External_Active_Member;
    @track defaultTabItem = null;
    @track caseSubCategoryValue;
    isRequiredDesc = false;

    //Added By Shruti
    userId = Id;

    @track surveyMessage = surveyMessage;

    @track currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;

    }


    connectedCallback() {
        
        loadStyle(this, EdqAlignLast); 
        loadStyle(this, EdqAlignment);  
        this.getcountryvalues();
        let testURL = encodeURI(window.location.href);
        let newURL = new URL(testURL).searchParams;
        this.recordId = newURL.get('recordId');
        this.getAttach();
        if (sessionStorage.getItem('defaultTab') == 'comments') {
            this.defaultTabItem = 'comments';
            this.selectedItem = 'caseComments';
        }
        if (localStorage.getItem('selected') == 'attachments') {
            this.selectedItem = 'attachments';
        }
        if (localStorage.getItem('showSurvey') == 'YES') {
            this.showCloseCaseSurvey = true;
        } else {
            this.showCloseCaseSurvey = false;
        }
        localStorage.removeItem('showSurvey');

        this.curusrname = localStorage.getItem('curusrname');
        this.currentUserProfile = localStorage.getItem('curusrprofile');
        localStorage.removeItem('selected');
        setTimeout(() => {
            this.getCurUserprofile();
        }, 3000);
        this.getquryrslt();

        getLoggedInContacts({})
            .then((result) => {
                this.contactData = result;
                this.contactCountry = this.contactData[0].Core_Country_Region__c;
                this.selectedValuecountry = this.contactData[0].Core_Country_Region__c;
                this.statedefaultvalue = this.contactData[0].Core_IPS_Embargoed_State__c;
                this.selectedCountry = this.selectedValuecountry;
                this.selectedState = this.statedefaultvalue;

            })
            .catch((error) => {
                this.error = error;
            });
        //console.log('call comments--'+this.recordId);    
        this.getCurrentCaseComments();
    }
    
    renderedCallback() {
        
	var outputfield = this.template.querySelector('[data-id="outputfield"]');
        if (outputfield) {
            this.template.querySelector('[data-id="outputfield"]').className = '';
        }


    }
    countrySelect(event) {
        this.selectedCountry = event.detail.countryName;
        this.showState = event.detail.showState;
        this.selectedState = event.detail.state;
    }
    stateSelect(event) {
        this.selectedState = event.detail.stateName;
    }
    handleKeyChange(event) {}
    handleSelect(event) {
        const selected = event.target.value;
        if (selected == 'caseComments') {
            this.caseComments = true;
        } else {
            this.caseComments = false;
        }
        if (selected == 'caseInformation') {
            this.caseInformation = true;
        } else {
            this.caseInformation = false;
        }
        if (selected == 'environment') {
            this.environment = true;
        } else {
            this.environment = false;
        }
        if (selected == 'attachments') {
            this.attachments = true;
            this.getAttach();
            this.getCurUserprofile();

        } else {
            this.attachments = false;
        }
        if (selected == 'interestedParties') {
            this.interestedParties = true;
            this.interestedctrl();
        } else {
            this.interestedParties = false;
        }
    }

    @track isModalOpen = false;
    openCsModal() {
        this.isModalOpen = true;
    }
    closeCsModal() {
        this.isModalOpen = false;
    }
    @track isRecCaseClose = false;
    @track isRecCaseModal = false;
    openrecCCModal() {
        this.isRecCaseModal = true;
    }
    closerecCCModal() {
        this.isRecCaseModal = false;
    }
    closeTheCase() {
        this.isSpinner = true;
        getCaseClosed({ caseId: this.recordId })
            .then((result) => {
                if (result == 'error') {
                    this.isSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Case Cannot be Updated',
                            variant: 'error'
                        }),
                    );
                } else {
                    this.isSpinner = false;
                    if (this.isPartnerORPartnerFAE) {
                        localStorage.setItem('showSurvey', 'YES');
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Case Record Update Successful',
                            variant: 'success'
                        }),
                    );
                    setTimeout(() => window.location.reload(), 1000);

                }

            })
            .catch((error) => {
                this.isSpinner = false;
                this.error = error;
            });
        this.isModalOpen = false;

    }

    @track isEditCase = false;
    async openEditModal() {
        if (this.currentCaseData.Core_Severity__c == 'Critical') {
            this.editSeverityReason = true;
        } else {
            this.editSeverityReason = false;
        }
        this.prodId = this.currentCaseData.Core_IPS_Supported_Product__c;
        this.caseIssueCategoryId = this.currentCaseData.Core_Case_Issue_Category__c;
        
        this.showEdqSection = false;
        this.showProdEdqs = false;
        this.showSubCatEdqs = false;
        getCaseonLoad({ caseId: this.recordId }).then(res => {
            if ((res.subCatFields != null && res.subCatFields != undefined) || (res.fields != null && res.fields != undefined)) {
               
		        this.showEdqSection = true;
                this.prodEdqRecs = res.fields;
                this.showProdEdqs = true;
                this.subCatRecEdqs = res.subCatFields;
                this.showSubCatEdqs = true;
                this.getSubCategoryEdqs(this.casesubcatedq);
                setTimeout(() => {this.enableEdit();}, 100);
            }
            else{
                setTimeout(() => {this.enableEdit();}, 100);
            }
        }).catch(err => {
            setTimeout(() => {this.enableEdit();}, 100);
        })
        this.getProdVariants(this.selectedProductId);
        this.getsubcategoryData();
        this.getcategoryData();
        this.getUserProfile();

    }
    enableEdit(){
        this.isEditCase = true;
    }
    closeEditModal() {
        this.isEditCase = false;

       
    }
    @track theRecord = {};
    severityReason;
    editSeverityRea;
    SeverityReasonRequired;
    SubjectRequired;
    DescriptionRequired;
    doCheckbox(event) {
        this.theRecord[event.target.name] = event.target.checked;
    }
    doSomething(event) {
        let name = event.target.name;
        let editValue = event.target.value;
        this.theRecord[event.target.name] = event.target.value;
        if (event.target.dataset.id === 'SeverityInput') {
            this.editSeverityRea = editValue;
            if (this.editSeverityRea == 'Critical') {
                this.editSeverityReason = true;
            } else {

                this.editSeverityReason = false;
            }
        }
        if (event.target.dataset.id === 'Subject') {
            this.SubjectRequired = event.target.value.trim();
            console.log('SubjectRequired',this.SubjectRequired);
            if(this.SubjectRequired !=''){
            this.isRequiredSubject = false;
            this.template.querySelector('.editSubjectInput')?.classList.remove('showRequired');
            }
        }

        if (event.target.dataset.id === 'description') {
            let plainVal = editValue.replaceAll('<p>','').replaceAll('</p>','').replaceAll('<br>','').trim();
            let vardes = editValue.trim();
            if(vardes != '' && plainVal !='') {
                this.isRequiredDesc = false;
                this.template.querySelector('.editDescInput')?.classList.remove('Descriptionborder');
            }
               
            this.DescriptionRequired = value.trim().length;
        }
        if (event.target.dataset.id === 'SeverityReason') {
            let value = event.target.value.trim();
            this.SeverityReasonRequired = value.replace(/\s/g, '').length;
            if(value!=''){
            this.isRequiredSeverityRsn = false;
            this.template.querySelector('.editSeverityRsnInput')?.classList.remove('showRequired');
            }
        }



    }
    @track strCaseData;
    submitEditDetails() {
        this.strCaseData = JSON.stringify(this.theRecord);
        updateCaseDetails({ caseId: this.recordId, caseData: this.strCaseData })
            .then((result) => {
                if (result == 'error') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Case Cannot be Updated',
                            variant: 'error'
                        }),
                    );
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Case Record Update Successful',
                            variant: 'success'
                        }),
                    );
                }

            })
            .catch((error) => {
                this.error = error;
            });
        this.isEditCase = false;
    }
    
    
    
    isRequiredSubject = false;
    isRequiredSubCat = false;
    isRequiredSeverityRsn = false;
    ispartnerAccreq = false;

    editSaveHandler() {
        this.trackvalidation = [];
        let tempCurrentCaseData = JSON.parse(JSON.stringify(this.theRecord));
        if (this.editSeverityReason == false) {
            tempCurrentCaseData.SeverityReason = '';
        }
        
        let caseObj = {
            Id: this.recordId,
            Subject: (this.currentCaseData.Subject != tempCurrentCaseData.Subject) && (tempCurrentCaseData.Subject != null || tempCurrentCaseData.Subject != undefined) ? tempCurrentCaseData.Subject : this.currentCaseData.Subject,
            Core_Issue_Description__c: (this.currentCaseData.Core_Issue_Description__c != tempCurrentCaseData.description) && (tempCurrentCaseData.description != null || tempCurrentCaseData.description != undefined) ? tempCurrentCaseData.description : this.currentCaseData.Core_Issue_Description__c,
            Core_Severity__c: (this.currentCaseData.Core_Severity__c != tempCurrentCaseData.Severity) && (tempCurrentCaseData.Severity != null || tempCurrentCaseData.Severity != undefined) ? tempCurrentCaseData.Severity : this.currentCaseData.Core_Severity__c,
            Core_Severity_Reason__c: (this.currentCaseData.Core_Severity_Reason__c != tempCurrentCaseData.SeverityReason) && (tempCurrentCaseData.SeverityReason != null || tempCurrentCaseData.SeverityReason != undefined) ? tempCurrentCaseData.SeverityReason : this.currentCaseData.Core_Severity_Reason__c,
            Core_CaseType__c: (this.currentCaseData.Core_CaseType__c != tempCurrentCaseData.CaseType) && (tempCurrentCaseData.CaseType != null || tempCurrentCaseData.CaseType != undefined) ? tempCurrentCaseData.CaseType : this.currentCaseData.Core_CaseType__c,
            Core_End_Customer__c: (this.currentCaseData.Core_End_Customer__c != tempCurrentCaseData.endCustomer) && (tempCurrentCaseData.endCustomer != null || tempCurrentCaseData.endCustomer != undefined) ? tempCurrentCaseData.endCustomer : this.currentCaseData.Core_End_Customer__c,
            Core_Customer_Reference_ID__c: (this.currentCaseData.Core_Customer_Reference_ID__c != tempCurrentCaseData.customerRefId) && (tempCurrentCaseData.customerRefId != null || tempCurrentCaseData.customerRefId != undefined) ? tempCurrentCaseData.customerRefId : this.currentCaseData.Core_Customer_Reference_ID__c,
            Core_Case_Issue_Category__c: (this.currentCaseData.Core_Case_Issue_Category__c != tempCurrentCaseData.caseCategory) && (tempCurrentCaseData.caseCategory != null || tempCurrentCaseData.caseCategory != undefined) ? tempCurrentCaseData.caseCategory : this.currentCaseData.Core_Case_Issue_Category__c,
            Core_Case_Issue_Sub_Category__c: (this.currentCaseData.Core_Case_Issue_Sub_Category__c != tempCurrentCaseData.subCategory) && (tempCurrentCaseData.subCategory != null || tempCurrentCaseData.subCategory != undefined) ? tempCurrentCaseData.subCategory : this.currentCaseData.Core_Case_Issue_Sub_Category__c,
            Core_Product_Variant__c: this.productvariantName,
            Core_Partner_Supported_Account__c: this.agentCheck == true ? this.partnerSupportAccount : null,
            Core_IPS_Partner_Sup_Owner__c: this.agentCheck == true ? this.partnerSupportOwnerId : null,
            Core_External_Issue_Category__c: (this.currentCaseData.Core_External_Issue_Category__c != tempCurrentCaseData.categoryLabel) && (tempCurrentCaseData.categoryLabel != null || tempCurrentCaseData.categoryLabel != undefined) ? tempCurrentCaseData.categoryLabel : this.currentCaseData.Core_External_Issue_Category__c,
            Core_External_Issue_Subcategory__c: (this.currentCaseData.Core_External_Issue_Subcategory__c != tempCurrentCaseData.subCategoryLabel) && (tempCurrentCaseData.subCategoryLabel != null || tempCurrentCaseData.subCategoryLabel != undefined) ? tempCurrentCaseData.subCategoryLabel : this.currentCaseData.Core_External_Issue_Subcategory__c,
            Core_IPS_Restricted_Secret_Content__c: (this.currentCaseData.Core_IPS_Restricted_Secret_Content__c != tempCurrentCaseData.RemoveNotificationDetails) && (tempCurrentCaseData.RemoveNotificationDetails != null || tempCurrentCaseData.RemoveNotificationDetails != undefined) ? tempCurrentCaseData.RemoveNotificationDetails : this.currentCaseData.Core_IPS_Restricted_Secret_Content__c,
        }
        let validationCaseDescription = caseObj.Core_Issue_Description__c.replaceAll('<p>', '').replaceAll('</p>', '').replaceAll('<br>', '');
       
        let editValid = true;
        if( this.showSubCat == true && (caseObj.Core_Case_Issue_Sub_Category__c == null || caseObj.Core_Case_Issue_Sub_Category__c == undefined || caseObj.Core_Case_Issue_Sub_Category__c =='')){
            this.isRequiredSubCat = true;
            this.template.querySelector('.editSubCatInput')?.classList.add('showRequired');
            this.template.querySelector('.editSubCatInput')?.scrollIntoView();
        }
        if((this.editSeverityReason == true) && (caseObj.Core_Severity_Reason__c == null || caseObj.Core_Severity_Reason__c == undefined || caseObj.Core_Severity_Reason__c == '')){
            editValid = false;
            this.isRequiredSeverityRsn = true;
            this.template.querySelector('.editSeverityRsnInput')?.classList.add('showRequired');
            this.template.querySelector('.editSeverityRsnInput')?.scrollIntoView();
        }
        if(validationCaseDescription == null || validationCaseDescription == undefined || validationCaseDescription == ''){
            editValid = false;
            this.isRequiredDesc = true;
            this.template.querySelector('.editDescInput')?.classList.add('Descriptionborder');
            this.template.querySelector('.editDescInput')?.scrollIntoView();
        }
        
        if(caseObj.Subject == null || caseObj.Subject == undefined || caseObj.Subject == ''){
            editValid = false;
            this.isRequiredSubject = true;
            this.template.querySelector('.editSubjectInput')?.classList.add('showRequired');
            this.template.querySelector('.editSubjectInput')?.scrollIntoView();
            
        }    
        if(this.CopyPartnerAccountRequired == true && ( this.partnerSupportAccount == null || this.partnerSupportAccount  == undefined || this.partnerSupportAccount  == '')){
            this.ispartnerAccreq = true;
            this.template.querySelector('.partnerAccreq')?.classList.add('showRequired');
            this.template.querySelector('.partnerAccreq')?.scrollIntoView();  
        }    

        if (this.showProdEdqs === true) {
            this.template.querySelector('c-dynamic-form-builder[data-id="prodEDQ"]').callhandleQuestionAnswer();
        }
        if (this.showSubCatEdqs === true) {
            this.template.querySelector('c-dynamic-form-builder[data-id="subCatEDQ"]').callhandleQuestionAnswer();
        }
        this.validateedq();
        if (this.valCheck) {   
            if(editValid == true) {
                for (const x of this.savealldataedqMap.keys()) {
                    this.savealldataedq.push(this.savealldataedqMap.get(x));
                    console.log('Key=' + x + ', Value=' + JSON.stringify(this.savealldataedqMap.get(x)));
                }
                let strEdq = JSON.stringify(this.savealldataedq);
                this.isSpinner = true;
                SubmitCaseRecord({ newRecord: caseObj, ContactRecord: null, CaseEDQData: strEdq })
                    .then(result => {
                        if (result == 'error') {
                            this.isSpinner = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Case Cannot be Updated',
                                    variant: 'error'
                                }),
                            );
                        } else {
                            this.isSpinner = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Case Record Update Successful',
                                    variant: 'success'
                                }),
                            );
                            setTimeout(() => window.location.reload(), 1000);

                        }

                    })
                    .catch(error => {
                        this.isSpinner = false;
                        this.error = error;
                    });
                this.isEditCase = false;

            }

        } else{
         this.template.querySelector('.validate').classList.add('showRequired');
         
        }
         this.savealldataedq=[];
    }
    ProjNotapplicable = 'Not Applicable';
    ProjectData = true;
    @track resCaseCloseValueChanged = {};
    @track strResCaseCloseData;
    resCaseCloseHandleChange(event) {
            this.resCaseCloseValueChanged[event.target.name] = event.target.value;
        }
        //@track currentCaseData;
    supportedProdIdTest;
    showCloseCaseSurveyValue;
    hasAccess = true;
    hideCaseCategory;
    casesubcatedq;
    @wire(getCurrentCase, { csId: '$recordId' })
    getCurCase({ error, data }) {
    
        this.isSpinner = true;
        //if(data){
        // this.hasAccess=true;
        if (data) {
            this.isSpinner = false;
            this.hasAccess = true;
            let tabItem = this.currentPageReference?.state?.isCase;

            if (tabItem == 'true' && tabItem != undefined && tabItem != null) {
                if (this.defaultTabItem == 'comments' && this.selectedItem != 'attachments') {
                    this.selectedItem = 'caseComments';
                } else if (this.selectedItem != 'attachments') {
                    this.selectedItem = 'caseInformation';
                    sessionStorage.setItem('defaultTab', 'comments');
                }
            }

            /*else if(tabItem == 'false'){
                this.selectedItem = 'caseComments';
                }*/

            let cData = JSON.parse(JSON.stringify(data));
            this.showCloseCaseSurveyValue = this.surveyLink + '=' + cData.CaseNumber;
            this.currentCaseData = cData;
            this.productvariantName = this.currentCaseData.Core_Product_Variant__c;
            
	        this.supportedProdIdTest = cData.Core_IPS_Supported_Product__c;
            this.passSupportedProductID = cData.Core_IPS_Supported_Product__c;
            this.getAllEDQs();
            this.getProductEdqs(cData.Core_IPS_Supported_Product__c);
            if (this.currentCaseData.Core_IPS_Premier_Support_Project_ID__c == undefined) {
                this.EditPartnerAccountRequired = false;
            }
            if (this.currentCaseData.Core_IPS_Premier_Support_Project_ID__c == '' || this.currentCaseData.Core_IPS_Premier_Support_Project_ID__c == undefined) {
                this.ProjectData = false;
                this.isProjectProjuctActive = true;

            } else {
                this.ProjectData = true;
                this.getProjectStatus();
            }
            this.getProductStatus();
            this.showHideCopyCaseBtn();
            if (cData.Status == 'Closed') {
                this.isCaseClosed = true;
                this.ClosedCase = false;
                this.isCaseClosedCmt = true;
                this.isCaseCmt = false;
                this.booleanRefreshAttachments = false;
                this.booleanLinkFile = false;
                this.booleanPrivatetoIntel = false;
                this.booleanPrivatetoPartners = false;
                this.booleanPublictoCustomers = false;
                this.isAttachment = false;
            } else {
                this.ClosedCase = true;
                this.isCaseCmt = true;
                
            }
            //if (cData.Core_IPS_GEC_Flag__c == true) {
            let recordTypeName = cData.RecordType.DeveloperName;
            
            if (recordTypeName == 'IPS_GEC_ReadOnly') {
                this.isCaseClosed = true;
                this.ClosedCase = false;
                this.enableCopy = false;
                this.enablePrint = false;
                this.isCaseClosedCmt = true;
                this.booleanRefreshAttachments = false;
                this.booleanLinkFile = false;
                this.booleanPrivatetoIntel = false;
                this.booleanPrivatetoPartners = false;
                this.booleanPublictoCustomers = false;
                this.isAttachment = false;
            } else {
                this.isCaseClosedCmt = false;
            }
            /*if (this.currentUserProfile == 'PartnerAgent' && cData.Status == 'Closed') {
                this.isCaseClosedCmt = true;
                this.isCaseCmt = true;

            } else {
                this.isCaseClosedCmt = false;
                this.isCaseCmt = false;

            }*/
            if (cData.Status == 'Closed' && this.currentUserProfile != 'PartnerAgent') {
                this.isCaseClosedCmt = true;
                this.ClosedCase = false;
                this.subjectReadonly = true;
                this.removeReadonly = true;
                this.descriptionReadonly = true;
                this.caseTypeReadonly = true;
                this.severityReadonly = true;
                this.customerrefReadonly = true;
                this.endCustomerReadonly = true;
                this.prodVariantReadonly = true;
                this.caseCategoryReadOnly = true;
                this.subCatReadonly = true;
            } else {

                this.subjectReadonly = false;
                this.removeReadonly = false;
                this.descriptionReadonly = false;
                this.caseTypeReadonly = false;
                this.severityReadonly = false;
                this.customerrefReadonly = false;
                this.endCustomerReadonly = false;
                this.prodVariantReadonly = false;
                this.caseCategoryReadOnly = false;
                this.subCatReadonly = false;
            }

            if (cData.Status == 'Closed' && this.currentUserProfile == 'PartnerAgent') {
                this.subjectReadonly = false;
                this.removeReadonly = false;
                this.descriptionReadonly = false;
                this.caseTypeReadonly = false;
                this.severityReadonly = false;
                this.customerrefReadonly = false;
                this.endCustomerReadonly = false;
                this.prodVariantReadonly = false;
                this.caseCategoryReadOnly = false;
                this.subCatReadonly = false;
            }

            let tempCaseData = JSON.parse(JSON.stringify(cData));
            let coreCaseCategory = tempCaseData.Core_Case_Issue_Sub_Category__c;
            this.casesubcatedq = coreCaseCategory;
            if(tempCaseData.Core_jsonfield__c!=null && tempCaseData.Core_jsonfield__c!=undefined && tempCaseData.Core_jsonfield__c!=''){
                this.edqdata = JSON.parse(tempCaseData.Core_jsonfield__c);
            }    
            if (coreCaseCategory != null || coreCaseCategory != '' || coreCaseCategory != undefined) {
                this.getSubCategoryEdqs(coreCaseCategory);

            }
            this.error = undefined;

        } else if (error) {
            this.isSpinner = false;
            this.error = error;
            this.currentCaseData = undefined;
            this.hasAccess = false;
        }
        if (this.currentUserProfile == 'PartnerAgent') {
            this.editProjandProd = false;
        } else {
            this.editProjandProd = true;
        }
       
    }

    projectDetailRecId;
    navigateToProjectDetail(event) {
        this.projectDetailRecId = this.currentCaseData.Core_IPS_Project_Case__r.Id;
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'project-detail'
            },
            state: {
                recordId: this.projectDetailRecId,
            }
        });
    }

    projectStatus;
    getProjectStatus() {
        getProjStatus({ projectId: this.currentCaseData.Core_IPS_Project_Case__c })
            .then((result) => {
                if ((result != null && result != undefined && result?.length > 0)) {

                    this.projectStatus = result.Core_Status__c;
                    if (result.Core_Status__c == 'Active') {
                        this.isProjectProjuctActive = true;
                    } else {}
                }
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Project',
                        variant: 'error'
                    }),
                );
            });
    }
    ProductStatus;
    getProductStatus() {
        getProdStatus({ assetId: this.currentCaseData.AssetId })
            .then((result) => {
                if ((result != null || result != undefined || result?.length > 0) && result.Status == 'Active') {
                    this.isProductActive = true;
                    this.ProductStatus = result.Status;
                }
            })
            .catch((error) => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Product Status.',
                        variant: 'error'
                    }),
                );

            });
    }

    showHideCopyCaseBtn() {
        if (this.ProjectData == true) {
            if (this.isProjectActive == true && this.isProductActive == true) {}
        } else if (this.ProjectData == false) {
            if (this.isProductActive == true) {
                this.isProjectProjuctActive = true;
            }
        } else {
            this.isProjectProjuctActive = false;
        }
    }




    newCaseEvnList = [];
    @track currentCaseEnvDetails;
    @track currentCaseEnvSearch;
    getAllEDQs() {
        getEnvDetails({ csId: this.recordId })
            .then((result) => {
                if (result == 'error') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error while getting EDQ Response',
                            variant: 'error'
                        }),
                    );
                } else {
                    let tempMap = new Map();
                    this.currentCaseEnvDetails = result;
                    let teampCaseEvnDetails = JSON.parse(JSON.stringify(this.currentCaseEnvDetails));
                    teampCaseEvnDetails.forEach(item => {
                        if (tempMap.has(item.Core_IPS_Question__c)) {
                            let tempData = tempMap.get(item.Core_IPS_Question__c);
			    if(item.Core_IPS_Answer__c!=undefined && item.Core_IPS_Answer__c != null && item.Core_IPS_Answer__c != ''){
                           	 tempData += ',' + item.Core_IPS_Answer__c;
			    }		    
                            tempMap.set(item.Core_IPS_Question__c, tempData);
                        } else {
                            tempMap.set(item.Core_IPS_Question__c, item.Core_IPS_Answer__c);
                        }
                    })
                    let questionset = new Set();
                    teampCaseEvnDetails.forEach(item => {
                        if (tempMap.has(item.Core_IPS_Question__c) && !questionset.has(item.Core_IPS_Question__c)) {
                            item.Core_IPS_Answer__c = tempMap.get(item.Core_IPS_Question__c);
                            questionset.add(item.Core_IPS_Question__c);
                            this.newCaseEvnList.push(item);
                        }
                    })
                    this.currentCaseEnvDetails = this.newCaseEvnList;
                    this.currentCaseEnvSearch = this.newCaseEvnList;
                }

            })
            .catch((error) => {
                this.error = error;
            });

    }
    handleEnvSearch(event) {
        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            this.currentCaseEnvDetails = this.currentCaseEnvSearch;
            if (this.currentCaseEnvDetails) {
                let recs = [];
                for (let rec of this.currentCaseEnvDetails) {
                    let valuesArray = Object.values(rec);
                    for (let val of valuesArray) {
                        if (val) {
                            if (val.toString().toLowerCase().includes(searchKey)) {
                                recs.push(rec);
                                break;
                            }
                        }
                    }
                }
                this.currentCaseEnvDetails = recs;
            }
        } else {
            this.currentCaseEnvDetails = this.newCaseEvnList;
        }
    }

    @track currentCaseComments;
    initialCaseComments;
    cmntofattachment = false;
    cmntofattachment1 = true;
    @track curusrname;
    hasRendered = false;
    @track isExternal = false;
    @track isnotExternal = false;
    getquryrslt() {
        getcurUsername()
            .then(result => {
                if (result) {
                    this.curusrname = result.Name;
                }
            })
            .catch(error => {

            })
    }

    @track sectionNames = [];
    @track tempVar = [];
    @track recentCommentsList = [];
   
    getCurrentCaseComments(){
         getCurrentCaseComments({csId: this.recordId})
            .then(async (data) => {
                if (data) {
                   // console.log('wire comments'+JSON.stringify(data));
                    await this.getCurUserprofile();
                    let cmts = [];
                    data.forEach(element => {
                        let rowobj = {}
                        rowobj.Core_IPS_Case_Comment_Type__c = element.Core_IPS_Case_Comment_Type__c;
                        rowobj.Core_IPS_Comment_Authored_By_FirstName__c = element.Core_IPS_Comment_Authored_By_FirstName__c;
                        rowobj.Id = element.Id;
                        if (element.Core_IPS_Rich_Comment__c.includes('New Case Attachment uploaded:') && (this.currentUserProfile == 'PartnerAgent' || this.currentUserProfile == 'PartnerFAE')) {
                            rowobj.Core_IPS_Comment_Authored_By_Name__c = element.Core_IPS_Comment_Authored_By_Name__c;
                            if(this.currentUserProfile == 'PartnerAgent' && (element.Core_IPS_Comment_Authored_By_Name__c==null || element.Core_IPS_Comment_Authored_By_Name__c=='' || element.Core_IPS_Comment_Authored_By_Name__c==undefined || !element.Core_IPS_Comment_Authored_By_Name__c.includes(element.CreatedBy_Name__c))){
                                rowobj.Core_IPS_Comment_Authored_By_Name__c = element.CreatedBy_Name__c;
                            }
                            
                        } else if (element.Core_IPS_Rich_Comment__c.includes('New Case Attachment uploaded:') && (this.currentUserProfile == 'Customer' || this.currentUserProfile == 'Partner')) {
                            rowobj.Core_IPS_Comment_Authored_By_Name__c = element.Core_IPS_Comment_Authored_By_FirstName__c;
                        } else {
                            rowobj.Core_IPS_Comment_Authored_By_Name__c = element.Core_IPS_Comment_Authored_By_Name__c;
                        }
                        rowobj.Core_IPS_Comment_Authored_By_Email__c = element.Core_IPS_Comment_Authored_By_Email__c;
                        rowobj.Core_IPS_Comment_Author_Type__c = element.Core_IPS_Comment_Author_Type__c;
                        rowobj.Core_IPS_Rich_Comment__c = element.Core_IPS_Rich_Comment__c.replaceAll('<img', '<br/><img style=" width:400px; padding-left:10px;" ');
                        var utcTime = new Date(element.CreatedDate);
                        var usaTime = utcTime.toLocaleString("en-US", { timeZone: timezone, year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit' });
                        rowobj.CreatedDate = usaTime;
                        if ((element.Core_IPS_Case_Comment_Source__c != 'Internal Portal') && (this.currentUserProfile == 'Customer' || this.currentUserProfile == 'Partner' || this.currentUserProfile == 'PartnerFAE') && (element.Core_IPS_Comment_Author_Type__c == 'Customer' || element.Core_IPS_Comment_Author_Type__c == 'Partner' || element.Core_IPS_Comment_Author_Type__c == 'Partner - DFAE')) {
                            rowobj.isExternal = true;
                            rowobj.isnotExternal = false;
                        } else if ((this.currentUserProfile == 'Customer' || this.currentUserProfile == 'Partner' || this.currentUserProfile == 'PartnerFAE')) {
                            rowobj.isExternal = false;
                            rowobj.isnotExternal = true;
                        } else if ((this.currentUserProfile == 'PartnerAgent')) {
                            rowobj.isExternal = false;
                            rowobj.isnotExternal = true;
                        }
                        cmts.push(rowobj);
                    })
                    for (let i = 0; i < cmts.length; i++) {
                        this.sectionNames = [...this.sectionNames, cmts[i].Id];
                    }
                    if (cmts.length >= 10) {
                        for (let i = 0; i < 10; i++) {
                            this.recentCommentsList[i] = cmts[i];
                        }
                    } else if (cmts.length < 10) {
                        for (let i = 0; i < cmts.length; i++) {
                            this.recentCommentsList[i] = cmts[i];
                        }
                    }
                    this.currentCaseComments = cmts;
                    this.initialCaseComments = cmts;
                 //   console.log('wire comments end'+JSON.stringify(this.currentCaseComments));
                    this.error = undefined;
                } 
            })
            .catch(error => {
                console.log('wire comments error'+JSON.stringify(error));
                this.error = error;
                this.currentCaseComments = undefined;
            })
    }    
        // Recent comments collapse view
    showcmts = true;
    showRecentcomments() {
        if (this.showcmts == true) {
            this.showcmts = false;
        } else if (this.showcmts == false) {
            this.showcmts = true;
        }
    }

    handleCollapse() {
            if (this.sectionNames.length > 0) {
                this.tempVar = [...this.sectionNames];
                this.sectionNames = [];
            } else if (this.sectionNames.length === 0) {
                this.sectionNames = [...this.tempVar];
                this.tempVar = [];
            }
        }
        //comment search
    handleCommentSearch(event) {
            const searchKey = event.target.value.toLowerCase();
            if (searchKey) {
                this.currentCaseComments = this.initialCaseComments;
                if (this.currentCaseComments) {
                    let recs = [];
                    for (let rec of this.currentCaseComments) {
                        let valuesArray = Object.values(rec);
                        for (let val of valuesArray) {
                            if (val) {
                                if (val.toString().toLowerCase().includes(searchKey)) {
                                    recs.push(rec);
                                    break;
                                }
                            }
                        }
                    }
                    this.currentCaseComments = recs;
                }
            } else {
                this.currentCaseComments = this.initialCaseComments;
            }
        }
        //back button navigation
    prodNavigation;
    homeNavigation;
    ProjNavigation;
    ProjectId;
    Navigation;
    AdvNavigation;
    handleNavigateBack() {
        let recordId = this.prodNavigation;
        this.prodNavigation = sessionStorage.getItem("ProjectDetail");
        this.homeNavigation = sessionStorage.getItem("CaseNav");
        this.Navigation = sessionStorage.getItem("ProdDetail");
        this.ProjNavigation = sessionStorage.getItem("ProjectCase");
        this.ProjectId = sessionStorage.getItem('ProjId');
        this.AdvNavigation = sessionStorage.getItem('AdvanceSearch');

        if (this.AdvNavigation == 'Search') {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'advance-search'
                },
            });
        }
        if (this.homeNavigation == 'NavigateCase') {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'home'
                },
            });
        }
        if (this.Navigation == 'Session') {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'product-detail'
                },
                state: {
                    recordId: this.prodNavigation
                },
            });
        }
        if (this.ProjNavigation == 'caseproject') {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'project-detail'
                },
                state: {
                    recordId: this.ProjectId
                },
            });
        }
        sessionStorage.removeItem('ProjectCase');
        sessionStorage.removeItem('CaseNav');
        sessionStorage.removeItem('ProdDetail');
        sessionStorage.removeItem('ProjectDetail');
        sessionStorage.removeItem("AdvanceSearch");
        sessionStorage.clear();
    }
    handlePrevilageCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }

    caseCmtSection = true;
    newCommentBtn(event) {
        if (event.target.name = "newCommentBtn") {
            this.caseCmtSection = false;
        } else {
            this.caseCmtSection = true;
        }
    }

    @track currentUserProfile;
    get commentOptions() {
        if (this.currentUserProfile == 'Partner' || this.currentUserProfile == 'Customer') {
            return [
                { label: 'Public to Customers', value: 'Public to Customers' },
            ];

        } else if (this.currentUserProfile == 'PartnerFAE') {
            return [
                { label: 'Public to Customers', value: 'Public to Customers' },
                { label: 'Private to Partner', value: 'Private to Partner' },
            ];

        } else {
            return [
                { label: 'Public to Customers', value: 'Public to Customers' },
                { label: 'Private to Partner', value: 'Private to Partner' },
                { label: 'Private to Intel', value: 'Private to Intel' },
                { label: 'Private to Agents', value: 'Private to Agents' },
            ];
        }

    }

    @track PublictoCustomers = false;
    @track PrivatetoPartner = false;
    @track PrivatetoIntel = true;
    @track PrivatetoAgents = false;
    commentValue = 'Public to Customers';
    selectedOption = this.commentValue;
    handleRadioChange(event) {
        this.selectedOption = event.detail.value;
        if (this.selectedOption == 'Public to Customers') {
            this.PublictoCustomers = true;
        } else {
            this.PublictoCustomers = false;
        }
        if (this.selectedOption == 'Private to Partner') {
            this.PrivatetoPartner = true;
        } else {
            this.PrivatetoPartner = false;
        }
        if (this.selectedOption == 'Private to Intel') {
            this.PrivatetoIntel = true;
        } else {
            this.PrivatetoIntel = false;
        }
        if (this.selectedOption == 'Private to Agents') {
            this.PrivatetoAgents = true;
        } else {
            this.PrivatetoAgents = false;
        }

    }
    commentValueError;
    getCommentValue(event) {
        this.ccCommentValue = event.target.value;
        
        this.commentValueError = this.ccCommentValue.replace(/\s/g, '').length;
        
    }
    noSpaceComment;

    sendCommentBtn() {
        if (this.commentValueError == 0 || this.ccCommentValue == '' || this.ccCommentValue == undefined) {
            this.showToast('ERROR', 'Please fill Required Field Comment', 'error');
        } else {
            this.isSpinner = true;
            saveNewComment({ csId: this.recordId, visibility: this.selectedOption, comment: this.ccCommentValue })
                .then((result) => {
                    if (result === 'Error' || result == 'Error') {
                        this.isSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Comment Cannot be Added',
                                variant: 'error'
                            }),
                        );
                    } else if (result == 'Blank Comment') {
                        this.isSpinner = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Comment value cannot be blank',
                                variant: 'error'
                            }),
                        );
                    } else {
                        this.isSpinner = false;
                        localStorage.setItem('curusrname', this.curusrname);
                        localStorage.setItem('curusrprofile', this.currentUserProfile);
                        const newWindow = window.open("case-detail?recordId=" + this.recordId, "_self");
                        newWindow.opener = null; //Added for Vulnerability issue

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Comment Added Successfully',
                                variant: 'success'
                            }),
                        );
                    }
                })
                .catch((error) => {
                    this.error = error;
                });
            this.caseCmtSection = true;

        }
    }
    commentCancelled() {
        this.caseCmtSection = true;
    }

    visibility = false;
    getAttach() {
        this.isSpinner = true;
        getattachments({ caseID: this.recordId })
            .then(result => {
                this.isSpinner = false;
                this.attachmentRecords = result;
                this.attachmentInitialRecords = result;
                let attach = [];
                result.forEach(element => {
                    let rowobj = {}
                    rowobj.Name = element.Name;
                    rowobj.Id1 = element.Id;
                    rowobj.Core_File_GUID__c = element.Core_File_GUID__c;
                    rowobj.Core_File_Name__c = element.Core_File_Name__c;
                    rowobj.Core_File_Description__c = element.Core_File_Description__c;
                    rowobj.Core_File_URL__c = element.Core_File_URL__c;
                    rowobj.Core_File_Size__c = element.Core_File_Size__c;
                    rowobj.Core_Upload_Status__c = element.Core_Upload_Status__c;
                    rowobj.Core_IPS_Attachment_Visibility__c = element.Core_IPS_Attachment_Visibility__c;
                    var utcTime = new Date(element.CreatedDate);
                    var usaTime = utcTime.toLocaleString("en-US", { timeZone: timezone });
                    rowobj.CreatedDate = usaTime;
                    if (element.Core_Upload_Status__c == 'Complete') {
                        rowobj.Fieldlabelname = 'Download';
                    } else {
                        rowobj.Fieldlabelname = 'Resume';
                    }
                    attach.push(rowobj);
                });
                this.attachmentData = attach;
                this.attachmentInitialRecords = attach;
                this.showTable = true;
            })
            .catch(error => {
                this.isSpinner = false;
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Cases',
                        message: error.message,
                        variant: 'error'
                    }),
                );
                this.attachmentRecords = undefined;
                this.attachmentInitialRecords = undefined;
            });
    }
    handleAttachmentRecordSubmit() {
        this.showToast('Success', 'Case Attachment has been updated.', 'success');
        this.editattRecord = false;
    }
    @wire(getFileList, { caseId: '$recordId' })
    getFiles({ data, error }) {
        if (data) {
            let dataWrapper = [];
            for (let i = 0; i < data.length; i++) {
                this.row = data[i];
                if (this.row.Core_FileUploadedBy__r) {
                    this.coreFileUploadedBy = JSON.stringify(this.row.Core_FileUploadedBy__r.Name);
                }
                var effdate = new Date(data[i].Core_Effective_Date__c);
                var effectivedate = effdate.toLocaleString("en-US", { timeZone: timezone });
                var expdate = new Date(data[i].Core_Expiration_Date__c);
                var expirationdate = expdate.toLocaleString("en-US", { timeZone: timezone });
                var uploaddate = new Date(data[i].Core_Last_Status_Updated_At__c);
                var uploaddateStatus = uploaddate.toLocaleString("en-US", { timeZone: timezone });
                let obj = {
                    'Id': data[i].Id,
                    'Core_File_Name__c': data[i].Core_File_Name__c,
                    'Core_File_Description__c': data[i].Core_File_Description__c,
                    'Core_Category__c': data[i].Core_Category__c,
                    'Core_File_Size__c': data[i].Core_File_Size__c,
                    'Core_IPS_Attachment_Visibility__c' : data[i].Core_IPS_Attachment_Visibility__c,
                    'Core_Effective_Date__c': effectivedate,
                    'Core_Expiration_Date__c': expirationdate,
                    'Core_File_URL__c': data[i].Core_File_URL__c,
                    'Core_Upload_Status__c': data[i].Core_Upload_Status__c,
                    'Core_Last_Status_Updated_At__c': uploaddateStatus,
                    'Core_File_GUID__c': data[i].Core_File_GUID__c,
                    'Fieldlabelname': data[i].Core_Upload_Status__c == 'Complete' ? 'Download' : 'Resume'
                };
                dataWrapper = [...dataWrapper, obj]
            }
            this.linkdataToShow = dataWrapper;
            if (this.linkdataToShow.length > 0) {
                this.isLinkDataAvailable = true;
            } else {
                this.isLinkDataAvailable = false;
            }
        }
        if (error) {
            this.response = undefined;
            this.errors = error;
        }
    }

    closeAttEditModal() {
        this.editattRecord = false;
    }
    handlelinkfile() {
        this.showdata = true;
        this.caseid = this.recordId;
    }
    closeLinkModal() {
        this.showdata = false;
    }

    getSelectedRecords(event) {
        let selectedRecords = [];
        const selectedRows = event.detail.selectedRows;
        this.recordsCount = event.detail.selectedRows.length;
        let fileIds = new Set();
        for (let i = 0; i < selectedRows.length; i++) {
            fileIds.add(selectedRows[i].Id);
            selectedRecords = [...selectedRecords, selectedRows[i].Id]
        }
        this.fileRecords = selectedRecords;
    }

    onSaveHandler() {
	this.isSpinner = true;
        saveRecords({ selectedRecordIds: this.fileRecords, caseId: this.recordId })
            .then(result => {
                if (this.fileRecords != null) {
		    this.isSpinner = false;
                    this.showToast('SUCCESS!!', 'Files has been Attached successfully', 'success');
                    this.template.querySelector('lightning-datatable').selectedRows = [];
                    this.recordsCount = 0;
                    this.showdata = false;
                } else {
		    this.isSpinner = false;
                    this.showToast('Error!!', 'Please Select Files ', 'error');
                }
            })
            .catch(error => {
		this.isSpinner = false;
                this.showToast('ERROR', error.body.message, 'error');
                this.showdata = false;
            });
    }

    onCancelHandler() {
        this.showdata = false;
    }

    handleRowActions(event) {
        const handleRowActionsEvent = new CustomEvent("rowActions", {
            detail: {
                actionName: event.detail.action.name,
                row: event.detail.row
            }
        });
        let rec = JSON.stringify(handleRowActionsEvent);
        let record = JSON.parse(rec);
        let action = record.detail.row.Fieldlabelname;
        let actionName = record.detail.actionName;
        switch (actionName) {
            case 'Edit':
                this.editRecord(record.detail.row);
                break;
            case 'Delete':
                this.deleteCurrentRecord(record.detail.row);
                break;
        }
        if (actionName != 'Edit') {
            if (actionName != 'Delete') {
                if (action == 'Resume') {
                    
		    localStorage.setItem('resume','resume');
                    localStorage.setItem('iframeurl', record.detail.row.Core_File_URL__c);
                    //localStorage.setItem('recordId', this.recordId);
                    const newWindow = window.open('attachment-upload?c__recordId='+this.recordId+'+'+record.detail.row.Core_IPS_Attachment_Visibility__c, '_blank');
                    newWindow.opener = null; //Added for Vulnerability issue
                }
                if (action == 'Download') {
                    
		    const newWindow = window.open(record.detail.row.Core_File_URL__c,'_self');
                    newWindow.opener = null; //Added for Vulnerability issue
                }
            }

        }
    }
    attrecId;
    attName;
    editRecord(row) {
        this.attrecId = row.Id1;
        this.attName = row.Name;
        this.editattRecord = true;
    }
    deleteCurrentRecord(row) {
        deleteAttachmentRecord({ attId: row.Id1 })
            .then((result) => {
                if (result) {
                    this.showToast('SUCCESS', 'Records is Deleted', 'success');
                    localStorage.setItem('selected', 'attachments');
                    window.location.reload();
                }
            })
            .catch(error => {
                this.showToast('ERROR', 'caseAttachment -- Error in deleting record. Error : ' + JSON.stringify(error), 'error');
            });
    }

    attRowAction(event) {
        const recId = event.detail.row;
        const actionName = event.detail.action;
        const record = JSON.stringify(recId);
        const recs = JSON.parse(record);
        let action = recs.Fieldlabelname;
        if (action == 'Resume') {
            localStorage.setItem('resume','resume');
            localStorage.setItem('iframeurl', recs.Core_File_URL__c);
            const newWindow = window.open('attachment-upload?c__recordId='+this.recordId+'+'+recs.Core_IPS_Attachment_Visibility__c, '_blank');
            newWindow.opener = null; //Added for Vulnerability issue
        }
        if (action == 'Download') {
            let url = window.location.href;
            const newWindow = window.open(recs.Core_File_URL__c);
            newWindow.opener = null; //Added for Vulnerability issue
        }
    }
    custpartfae = false;
    profileattach = false;
    profileattachshow = false;
    profileattachFae = false;
    isAgentPartner = false;
    async getCurUserprofile() {
        await getcurrentuserprofile().then(result => {
            let rslt = result;
            this.currentUserProfile = rslt;
            if (rslt == 'Customer' || rslt == 'Partner') {
                this.profileattachshow = true;
                this.isPartnerORCustomer = true;
                if (rslt == 'Partner') {
                    this.isPartnerORPartnerFAE = true;
                }
            } else if (rslt == 'PartnerAgent') {
                this.profileattach = true;
                this.isAgentPartner = true;
            } else if (rslt == 'PartnerFAE') {
                this.profileattachFae = true;
                this.isPartnerORPartnerFAE = true;
            }
            if (rslt == 'PartnerAgent') {
                 this.isCaseCmt = true;
            }
            if (this.currentCaseData.Status == 'Closed') {
                this.isCaseCmt = false;
                
            }
            if( (rslt == 'Partner' || rslt == 'PartnerFAE') && (this.currentCaseData.RecordType.DeveloperName != 'IPS_Closed_Case' && this.currentCaseData.RecordType.DeveloperName != 'IPS_GEC_ReadOnly')) {
                this.isCaseCmt = true;
                
            }else if(rslt == 'Partner' || rslt == 'PartnerFAE'){
                this.isCaseCmt = false;

            }

            if (rslt == 'PartnerAgent' && this.currentCaseData.Status == 'Closed') {
                this.ClosedCase = true;
                this.subjectReadonly = false;
                this.removeReadonly = false;
                this.descriptionReadonly = false;
                this.caseTypeReadonly = false;
                this.severityReadonly = false;
                this.customerrefReadonly = false;
                this.endCustomerReadonly = false;
                this.prodVariantReadonly = false;
                this.caseCategoryReadOnly = false;
                this.subCatReadonly = false;
            } else {
                this.subjectReadonly = true;
                this.removeReadonly = true;
                this.descriptionReadonly = true;
                this.caseTypeReadonly = true;
                this.severityReadonly = true;
                this.customerrefReadonly = true;
                this.endCustomerReadonly = true;
                this.prodVariantReadonly = true;
                this.caseCategoryReadOnly = true;
                this.subCatReadonly = true;

            }
        });
    }
    get CaseTypeOptions() {
        return [
            { label: "Question", value: "Question" },
            { label: "Design Review", value: "Design Review" },
            { label: "Feature Request", value: "Feature Request" },
            { label: "Debug Request", value: "Debug Request" },
        ];
    }

    severityValue = 'Medium';
    get caseSeverityoptions() {
        return [
            { label: "Low", value: "Low" },
            { label: "Medium", value: "Medium" },
            { label: "High", value: "High" },
            { label: "Critical", value: "Critical" },
        ];
    }

    OEMValue = 'No';
    get OEMOptions() {
        return [
            { label: "Yes", value: "Yes" },
            { label: "No", value: "No" },
        ];
    }

    //attachment search
    attachmentsearchbox(event) {
        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            this.attachmentData = this.attachmentInitialRecords;
            if (this.attachmentData) {
                let recs = [];
                for (let rec of this.attachmentData) {
                    let valuesArray = Object.values(rec);
                    for (let val of valuesArray) {
                        if (val) {
                            if (val.toString().toLowerCase().includes(searchKey)) {
                                recs.push(rec);
                                break;
                            }
                        }
                    }
                }
                this.attachmentData = recs;
            }
        } else {
            this.attachmentData = this.attachmentInitialRecords;
        }
    }

    attachfilesection = true;
    attachhandleClick() {
        
        const newWindow = window.open('attachment-upload?c__recordId='+this.recordId+'+'+'Public_to_Customers', "_blank");
        newWindow.opener = null; //Added for Vulnerability issue
    }

    attachhandleClickPartner() {
        
        const newWindow = window.open('attachment-upload?c__recordId='+this.recordId+'+'+'Private_to_Partner', "_blank");
        newWindow.opener = null; //Added for Vulnerability issue
    }

    attachhandleClickIntel() {
        
        const newWindow = window.open('attachment-upload?c__recordId='+this.recordId+'+'+'Private_to_Intel', "_blank");
        newWindow.opener = null; //Added for Vulnerability issue
    }

    
    // Refresh Attachments Page
    refreshPage(event) {
        location.reload();
        localStorage.setItem('selected', 'attachments');
    }
    handlenaviagateattachment() {
        this.attachfilesection = true;
    }

    @api clonedCase;
    @api errorMsg;
    @api subject;
    @api caseDescription;
    @api severity;
    @api caseType;
    @api customerReferenceID;
    @api endcustomer;
    @api endCustomer;
    @api contactId;
    @api projectName;
    @api ProductName;
    productvariantName;
    @api caseProductVariantOptions;
    @api CaseSubcategoryoptions;
    @api CaseCategoryoptions;
    @api error;
    @api getdatafromwire;
    @api caseIssueCategoryId;
    @api caseIssueSubCategoryId;
    @api selectedProductId;
    @api prodId;
    @api CategoryName;
    @api SubCategoryName;
    @api caseinsertion;
    @api AccountId;
    @api caseSource;
    @api caseSeverityReason;
    @api countrySelected;
    //minhaj
    @track subsCatedqi;
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
        "childQuestion2": undefined
    };
    @wire(getCaseData, { recId: '$recordId' })
    getCase({ error, data }) {
        if (data) {
            this.getdatafromwire = data[0];
            
            for (let key in this.getdatafromwire) {
                if (key == 'Core_Product_Variant__c') {
                    if (this.getdatafromwire[key] != undefined) {
                        this.productvariantName = this.getdatafromwire[key];
                    }
                }
                if (key == 'AssetId') {
                    if (this.getdatafromwire[key] != undefined) {
                        this.selectedProductId = this.getdatafromwire[key];
                    }
                }
                if (key == 'Core_Case_Issue_Category__c') {
                    if (this.getdatafromwire[key] != undefined) {
                        this.caseIssueCategoryId = this.getdatafromwire[key];
                    }
                }
                if (key == 'Core_Case_Issue_Sub_Category__c') {
                    if (this.getdatafromwire[key] != undefined) {
                        this.caseIssueSubCategoryId = this.getdatafromwire[key];
                    }
                }
                if (key == 'Core_IPS_Supported_Product__c') {
                    if (this.getdatafromwire[key] != undefined) {
                       // this.prodId = JSON.parse(this.getdatafromwire[key]);
                        this.prodId = this.getdatafromwire[key];
                        this.getcategoryData();
                    }
                }
                if (key == 'Core_IPS_Project_Case__c') {
                    if (this.getdatafromwire[key] != undefined) {
                        this.projectId = this.getdatafromwire[key];
                    }
                }
                if (key == 'AccountId') {
                    if (this.getdatafromwire[key] != undefined) {
                        this.AccountId = this.getdatafromwire[key];
                    }
                }
            }
        } else if (error) {}
    }
    showCopy() {

        if (this.ProjectData == true && (this.projectStatus != 'Active' && this.projectStatus != undefined) || (this.ProductStatus != 'Active' && this.ProductStatus != undefined)) {
            this.showToast('Error', 'You cannot copy the Case as Project/Product is Inactive', 'error');
        } else {
            //this.showCopycmp = true;
            //this.getProductEdqs(this.prodId);
            //this.getcloneCaseData();
            /*this.getProdVariants(this.selectedProductId);
            this.getsubcategoryData();
            this.getcategoryData();
            this.getUserProfile();*/
            
            this.showEdqSection = false;
            this.showProdEdqs = false;
            this.showSubCatEdqs = false;
            getCaseonLoad({ caseId: this.recordId }).then(res => {
                if ((res.subCatFields != null && res.subCatFields != undefined) || (res.fields != null && res.fields != undefined)) {
                    this.showEdqSection = true;
                    this.prodEdqRecs = res.fields;
                    this.showProdEdqs = true;
                    //this.subCatRecEdqs = res.subCatFields;
                    this.showSubCatEdqs = true;
                    setTimeout(() => {this.enableCopyCase();}, 100);
                }
                else{
                    setTimeout(() => {this.enableCopyCase();}, 100);
                }
            }).catch(err => {
                setTimeout(() => {this.enableCopyCase();}, 100);
            })
            //this.showCopycmp = true;
            this.getcloneCaseData();
            this.getProdVariants(this.selectedProductId);
            this.getcategoryData();
            this.getsubcategoryData();
           
            this.getUserProfile();

        }
    }
    enableCopyCase(){
        this.showCopycmp = true;
    }
    gobackToCase() {
        this.showmaincmp = true;
        this.showCopycmp = false;
    }
    envQAs = new Map();
    edqdata;
    //Call Apex clone Method
    CopyPartnerAccountRequired = true;
    getcloneCaseData() {
        retriveCaseData({ recId: this.recordId })
            .then(result => {
               // console.log('Clone Case1' + JSON.stringify(result));
                if (result != '' && result != undefined && result != null) {
                    this.caseinsertion = result;
                    this.clonedCase = result[0];
                    if ((this.clonedCase.Core_External_Issue_Category__c == '' || this.clonedCase.Core_External_Issue_Category__c == undefined) && this.CaseCategoryoptions.length == 0){
                        this.showCategory = false;
                    } else {
                        this.showCategory = true;
                    }
                    if ((this.clonedCase.Core_External_Issue_Subcategory__c == '' || this.clonedCase.Core_External_Issue_Subcategory__c == undefined) && this.CaseSubcategoryoptions.length == 0) {
                        this.showSubCategory = false;
                    } else {
                        this.showSubCategory = true;
                    }
                    if (this.clonedCase.Core_IPS_Project_Case__r == undefined) {
                        this.CopyPartnerAccountRequired = false;
                    }
                    for (let key in this.clonedCase) {
                        if (key == 'ContactId') {
                            if (this.clonedCase[key] != undefined) {
                                this.contactId = this.clonedCase[key];
                            }
                        }
                        if (key == 'Subject') {
                            if (this.clonedCase[key] != undefined) {
                                this.subject = this.clonedCase[key];
                                this.caseInfo["Subject"] = this.subject;
                            }
                        }
                        if (key == 'Core_Severity__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.severity = this.clonedCase[key];
                                if (this.severity == 'Critical') {
                                    this.copySeverityReason = true;
                                } else {
                                    this.copySeverityReason = false;
                                }

                            }
                        }
                        if (key == 'Core_Issue_Description__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.caseDescription = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_CaseType__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.caseType = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_IPS_Product_name__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.ProductName = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_IPS_Project_Case__r') {
                            if (this.clonedCase[key] != undefined) {
                                for (let innerkey in this.clonedCase[key]) {
                                    if (innerkey == 'Name') {
                                        this.projectName = this.clonedCase[key][innerkey];
                                    }
                                    if (innerkey == 'Id') {}
                                }
                            }
                        }
                        if (key == 'Core_Customer_Reference_ID__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.customerReferenceID = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_End_Customer__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.endcustomer = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_External_Issue_Category__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.CategoryName = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_External_Issue_Subcategory__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.SubCategoryName = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_Case_Issue_Category__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.caseIssueCategoryId = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_Case_Issue_Sub_Category__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.caseIssueSubCategoryId = this.clonedCase[key];
                                this.getsubcategoryData();
                            }
                        }
                        if (key == 'Core_IPS_Issue_source__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.caseSource = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_jsonfield__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.edqdata = JSON.parse(this.clonedCase[key]);
                                let tempVarLst = [];
                                for (let i in this.edqdata) {
                                    tempVarLst = this.edqdata[i];
                                }
                                for (let j in tempVarLst) {
                                    this.envQAs.set(tempVarLst[j].Qstn, tempVarLst[j].Ansr);
                                }
                            }
                        }
                        if (key == 'Core_Severity_Reason__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.caseSeverityReason = this.clonedCase[key];
                            }
                        }
                        if (key == 'Core_IPS_Country_Region__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.countrySelected = this.clonedCase[key];
                            }
                        }

                        if (key == 'Core_Partner_Supported_Account__c') {
                            if (this.clonedCase[key] != undefined) {
                                this.partnerSupportAccount = this.clonedCase[key];
                            }
                        }
                        if (this.clonedCase['Asset']['Core_Supported_Product__c'] != null || this.clonedCase['Asset']['Core_Supported_Product__c'] != '' || this.clonedCase['Asset']['Core_Supported_Product__c'] != undefined) {
                            this.passSupportedProductID = this.clonedCase['Asset']['Core_Supported_Product__c'];
                        }
                    }
                    if (this.caseIssueSubCategoryId != '' || this.caseIssueSubCategoryId != null || this.caseIssueSubCategoryId != undefined) {
                        this.getSubCategoryEdqs(this.caseIssueSubCategoryId);

                    }
                } else {

                }
            })
            .catch(error => {
                console.log('Error in Clone Case-' + JSON.stringify(error));
                this.errorMsg = error;
            })
    }
    @track showProductVarinat;
    getProdVariants(prodIdStr) {
        let tempVar;
        if (prodIdStr != null || prodIdStr != undefined) {
            getProductVariants({
                    prodId: prodIdStr
                })
                .then(data => {
                    if (data) {
                        this.renderProductVariant = true;
                        let options = [];
                        this.caseProductVariantOptions = [];
                        data.forEach(eachRecord => {
                            options.push({ label: eachRecord.Name, value: eachRecord.Id });
                        });
                        this.caseProductVariantOptions = options;
                        this.showProductVarinat = true;
                    } else {
                        this.showProductVarinat = false;
                        this.caseProductVariantOptions = [
                            { value: 'None', label: 'None' }
                        ];

                    }
                })
                .catch(error => {
                    this.showProductVarinat = false;
                })
        } else {}
    }
    @track showSubCategory;
    getsubcategoryData() {
        displaySubCategoryData({ caseIssueCategoryId: this.caseIssueCategoryId })
            .then(result => {
                if (result != null && result.length > 0) {
                    this.CaseSubcategoryoptions = [];
                    for (let i = 0; i < result.length; i++) {
                        this.CaseSubcategoryoptions = [
                            ...this.CaseSubcategoryoptions,
                            { value: result[i].Id, label: result[i].Core_Issue_Sub_Category_Name__r.Name }
                        ];
                    }
                    this.showSubCategory = true;
                    if (this.CaseSubcategoryoptions.length > 0) {
                        this.showSubCat = true;
                    }
                    else{
                        this.showSubCat = false;
                    }
                    
                } else {
                    this.showSubCategory = false;
                    this.showSubCat = false;
                    this.CaseSubcategoryoptions = [
                        { value: 'None', label: 'None' }
                    ];
                }
            })
            .catch(error => {
                this.showSubCategory = false;
            })
    }
    @track showCategory;
    getcategoryData() {
        displayCategoryData({ prodId: this.prodId })
            .then(result => {
                if (result != null && result.length > 0) {
                    this.hideCaseCategory = true;

                    this.CaseCategoryoptions = [];
                    for (let i = 0; i < result.length; i++) {
                        this.CaseCategoryoptions = [
                            ...this.CaseCategoryoptions,
                            { value: result[i].Id, label: result[i].Core_Issue_Category_Name__r.Name }
                        ];
                    }
                    this.showCategory = true;
                } else {
                    this.hideCaseCategory = false;

                    this.showCategory = false;
                    this.CaseCategoryoptions = [
                        { value: 'None', label: 'None' }
                    ];
                }
            })
            .catch(error => {

                this.showCategory = false;
            })
    }
    @api prodEdqRecs;
    @api showEdqSection;
    @api showProdEdqs;
    getProductEdqs(supportedId) {
        let tempVar = supportedId;
        getProdEdq({ supportedProductId: tempVar, subCategoryid: null, isAgent: this.profileattach })
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
    @api subCatRecEdqs = [];
    @api showSubCatEdqs;
    getSubCategoryEdqs(subcategoryId) {
        let tempVar = subcategoryId;
        
	getSubCatEdq({ supportedProductId: null, subCategoryid: tempVar, isAgent: this.profileattach })
            .then(data => {
               // console.log('subcatedmethod-');
		let subCateboryEDQ = new Set();
                let eDQSet = new Set();
                let i;
                for (i = 0; i < data.length; i++) {
                    subCateboryEDQ.add(data[i].id);
                }
                for (i = 0; i < this.prodEdqRecs.length; i++) {
                    eDQSet.add(this.prodEdqRecs[i].id);
                }
                i = 0;
                let categoryEDQ = [];
                data.forEach(edq => {
                    if (eDQSet.has(edq.id)) {} else {
                        categoryEDQ.push(data[i]);
                    }
                    i++;
                });
                //this.subCatRecEdqs = JSON.parse(categoryEDQ);
                this.subCatRecEdqs = JSON.parse(JSON.stringify(categoryEDQ));
                
                let tempSubCatRecEdqs = JSON.parse(JSON.stringify(this.subCatRecEdqs));
                let tempEDQData = JSON.parse(JSON.stringify(this.edqdata));
                tempEDQData['Env Dtl Resp'].forEach(item => {
                    tempSubCatRecEdqs.forEach(item2 => {
                        if (item.Qstn === item2.label && !item2.lovs) {
                            item2.value = item.Ansr;
                        }
                        if (item.Qstn === item2.label && item2.lovs) {
                            let tempValArr = [];
                            item2.lovs.forEach(item3 => {
                                if (item3.label === item.Ansr && item2.type === 'Picklist') {
                                    item2.value = item3.value;
                                }
                                if (item.Ansr && item.Ansr.includes(';') && item2.type === 'Multiselect Picklist') {
                                    let tempAnsArr = item.Ansr.split(';');
                                    tempAnsArr.forEach(item4 => {
                                        if (item3.label === item4) {
                                            tempValArr.push(item3.value);
                                        }
                                    })
                                    item2.value = tempValArr;
                                } else if (item.Ansr && !item.Ansr.includes(';') && item2.type === 'Multiselect Picklist') {
                                    let tempValArr1 = [];
                                    if (item3.label === item.Ansr) {
                                        tempValArr1.push(item3.value);
                                        item2.value = tempValArr1;
                                    }

                                }

                            })

                        }
                    })
                })
                this.subCatRecEdqs = tempSubCatRecEdqs;
                let tempprodEdqRecs = JSON.parse(JSON.stringify(this.prodEdqRecs));
                tempEDQData['Env Dtl Resp'].forEach(item => {
                    tempprodEdqRecs.forEach(item2 => {
                        if (item.Qstn === item2.label && item2.lovs) {
                            item2.lovs.forEach(item3 => {
                                if (item3.label === item.Ansr) {
                                    item2.value = item3.value;
                                }

                            })
                        }
                    })
                })

                this.prodEdqRecs = tempprodEdqRecs;
                for (let i = 0; i < categoryEDQ.length; i++) {
                    if (categoryEDQ[i].id != undefined) {
                        this.CaseSubCategory = categoryEDQ[i].id;
                    }
                }
                if (this.subCatRecEdqs.length > 0) {
                    this.showEdqSection = true;
                    this.showSubCatEdqs = true;
                }
                
            })
            .catch(error => {
                console.log('in sub cate edq error'+JSON.stringify(error)+error);
            })
    }
    activeSectionsMessage = '';
    activeSections = ['A', 'B', 'C', 'D'];
    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

    getcountryvalues() {
        getcountryfields()
            .then(result => {
                this.showboolean1 = result[0].Core_MINDS__c;
                if (result[0].Core_MINDS__c) {
                    this.showboolean1 = true;
                    this.showboolean2 = false;
                    if (this.showboolean1) {
                        this.mindsValue = true;
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
    @api showboolean1 = false;
    @api showboolean2 = false;
    handleChangeMINDS(event) {
        if (event.target.name == "yeschecked") {
            if (event.target.checked) {
                this.showboolean1 = true;
                this.showboolean2 = false;
                this.mindsValue = this.showboolean1;
            } else {
                this.showboolean1 = false;
                this.showboolean2 = true;
            }
        }
        if (event.target.name == "nochecked") {
            if (event.target.checked) {
                this.showboolean1 = false;
                this.showboolean2 = true;
                this.mindsValue = false;
            } else {
                this.showboolean1 = true;
                this.showboolean2 = false;
            }
        }
    }

    handleClick() {
        insertCaseData({
                caseList: this.caseinsertion
            })
            .then((result) => {
                this.handleNavigateHome();
            })
            .catch((error) => {
                this.error = error;
            });
    }
    handleNavigateHome() {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
        });
    }


    //showExportPDF starts here
    @api isExportButtonClicked = false;
    @track applicationPageUrl;
    @api isPrintButtonClicked = false;
    showPrint() {
        this.isPrintButtonClicked = true;
        this.showmaincmp = false;
        this.setIframePage();

    }
    showExportPDF() {
        this.isExportButtonClicked = true;
        this.setIframePage();
    }
    closeModal() {
        this.showmaincmp = true;
        this.isExportButtonClicked = false;
        this.isPrintButtonClicked = false;
    }
    setIframePage() {
        getBaseUrlToLoadIframePage()
            .then(result => {
                if (result) {
                    let communityName = result;
                    let baseUrl = communityName ? '/' + communityName + '/apex' : '/apex';
                    this.applicationPageUrl = this.generateIframeUrl(baseUrl);
                } else {
                    this.applicationPageUrl = '';
                }
            })
            .catch(error => {
                let message = 'Unknown error';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
            })
    }
    generateIframeUrl(baseUrl) {
        let generatedUrl = '';
        let pageName = 'Core_IPS_Case_ExportPDF_LEX';
        generatedUrl = pageName ? baseUrl + '/' + pageName + '?Id=' + this.recordId : '';
        return generatedUrl;
    }
    constructor() {
        super();
        this.template.addEventListener('inselectedquestionanswer', this.handleChangeChild.bind(this));
    }





    @api trackchildataa = [];
    @track savealldataedq = [];
    savealldataedqMap = new Map();
    @api myobjectdata = [];
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

        obj.edq = [];
        obj.edq.question = [event.detail.qquestion];
        obj.edq.label = [event.detail.llabel];
        obj.edq.value = [event.detail.vvalue];
        obj.edq.require = [event.detail.rrequired];
        obj.edq.type = [event.detail.ttype];
        // this.savealldataedq.push(s);
        this.savealldataedqMap.set(s.edq[0].qquestion, s);
        this.myobjectdata.push(obj);
    }
    validateedq() {
        if (this.trackvalidation.length === 0) {
            this.valCheck = true;
        }

    }
    @track copyCaseDetails = {};
    @track copySeverityReason = false;
    copyValue;
    descriptionValue;
    SeverityReasonValue;
    SubjectValue;
    DescriptionValue;
    isRequiredDesc;
    richTextClass;
    handleChangeCopy(event) {
        this.copyCaseDetails[event.target.name] = event.target.value;
        if(event.target.dataset.id =='subjectField'){
            const subvar = this.copyCaseDetails.subject.trim();
            if(subvar!=''){
            this.isRequiredSubjectCpy = false;
            this.template.querySelector('.cpySubjectInput')?.classList.remove('showRequired');
            }
        }
        if (event.target.dataset.id === 'Severity') {
            let severityRea = event.target.value;
            if (severityRea == 'Critical') {
                this.copySeverityReason = true;
            } else {
                this.copySeverityReason = false;
            }
        }
        if (event.target.name == 'CountryRegion') {
            let strCheck = JSON.stringify(event.detail.value);
            this.selectedValuecountry = strCheck.replace(/['"]+/g, '');
            this.isRequiredCountrycpy = false;
            this.template.querySelector('.cpyCountryInput')?.classList.remove('showRequired');
        }
        if(event.target.dataset.id === 'descriptionFeild') {
            let plainVal =  this.copyCaseDetails.description.replaceAll('<p>','').replaceAll('</p>','').replaceAll('<br>','').trim();
            const vardescription =  this.copyCaseDetails.description.trim();
            if(vardescription !='' && plainVal !=''){
            this.isRequiredDescCpy = false;
            this.template.querySelector('.cpyDescInput')?.classList.remove('Descriptionborder');
            }
        }
        if(event.target.dataset.id == 'SeverityReasonCpy'){
            const varsecreason =  this.copyCaseDetails.SeverityReason.trim();
            if(varsecreason!=''){
            this.isRequiredSeverityRsncpy = false;
            this.template.querySelector('.cpySrnsInput')?.classList.remove('showRequired');
            }
        }
    }
    isRequiredSeverityRsncpy = false;
    isRequiredSubCatcpy = false;
    isRequiredCountrycpy = false;
    isRequiredSubjectCpy = false;
    isRequiredDescCpy = false;
    saveHandler() {
        this.trackvalidation = [];
        let tempCurrentCaseData = JSON.parse(JSON.stringify(this.copyCaseDetails));
        if (this.copySeverityReason == false) {
            tempCurrentCaseData.SeverityReason = '';
        }

        let caseObj = {
            AssetId: (this.selectedProductId !== undefined && this.selectedProductId !== null) ? this.selectedProductId : '',
            Core_IPS_Project_Case__c: this.projectId,
            ContactId: this.contactId,
            AccountId: this.AccountId.toString(),
            Subject: (this.subject != tempCurrentCaseData.subject) && (tempCurrentCaseData.subject != null || tempCurrentCaseData.subject != undefined) ? tempCurrentCaseData.subject : this.subject,
            Core_Issue_Description__c: (this.caseDescription != tempCurrentCaseData.description) && (tempCurrentCaseData.description != null || tempCurrentCaseData.description != undefined) ? tempCurrentCaseData.description : this.caseDescription,
            Core_Severity__c: (this.severity != tempCurrentCaseData.Severity) && (tempCurrentCaseData.Severity != null || tempCurrentCaseData.Severity != undefined) ? tempCurrentCaseData.Severity : this.severity,
            Core_CaseType__c: (this.caseType != tempCurrentCaseData.CaseType) && (tempCurrentCaseData.CaseType != null || tempCurrentCaseData.CaseType != undefined) ? tempCurrentCaseData.CaseType : this.caseType,
            Core_IPS_Issue_source__c: this.caseSource,
            Core_Severity_Reason__c: (this.caseSeverityReason != tempCurrentCaseData.SeverityReason) && (tempCurrentCaseData.SeverityReason != null || tempCurrentCaseData.SeverityReason != undefined) ? tempCurrentCaseData.SeverityReason : this.caseSeverityReason,
            Core_Case_Issue_Category__c: (this.caseIssueCategoryId !== undefined && this.caseIssueCategoryId !== null) ? this.caseIssueCategoryId : null,
            Core_Case_Issue_Sub_Category__c: (this.caseIssueSubCategoryId !== undefined && this.caseIssueSubCategoryId !== null) ? this.caseIssueSubCategoryId : null,
            Core_IPS_Country_Region__c: this.selectedCountry,
            Core_IPS_Embargoed_State__c: this.selectedState,
            Core_End_Customer__c: (this.endcustomer != tempCurrentCaseData.endCustomer) && (tempCurrentCaseData.endCustomer != null || tempCurrentCaseData.endCustomer != undefined) ? tempCurrentCaseData.endCustomer : this.endcustomer,
            Core_Customer_Reference_ID__c: (this.customerReferenceID != tempCurrentCaseData.customerRefId) && (tempCurrentCaseData.customerRefId != null || tempCurrentCaseData.customerRefId != undefined) ? tempCurrentCaseData.customerRefId : this.customerReferenceID,
            Core_IPS_Minds__c: this.mindsValue,
            Core_IPS_Customer_Visible__c: true,
            Core_Product_Variant__c: this.productvariantName,
            Core_Partner_Supported_Account__c: this.agentCheck == true ? this.partnerSupportAccount : null,
            Core_IPS_Partner_Sup_Owner__c: this.agentCheck == true ? this.partnerSupportOwnerId : null,
            Core_External_Issue_Category__c: this.CategoryName,
            Core_External_Issue_Subcategory__c: this.SubCategoryName,
            /*By Tejaswini H TWC745-6588: Empty Case Origin issue Sept 23, 2024. Case copy from Portal*/
            Origin : 'Web'
        }
        let plainVal = caseObj.Core_Issue_Description__c.replaceAll('<p>','').replaceAll('</p>','').replaceAll('<br>','').trim();
        
        this.isSpinner = false;

        let copyValid = true;
        if(this.CopyPartnerAccountRequired == true && ( this.partnerSupportAccount == null || this.partnerSupportAccount  == undefined || this.partnerSupportAccount  == '')){
            this.ispartnerAccreq = true;
            this.template.querySelector('.partnerAccreq')?.classList.add('showRequired');
            this.template.querySelector('.partnerAccreq')?.scrollIntoView();  
        }  
        if (this.selectedValuecountry == undefined) {
            if (caseObj.Core_IPS_Country_Region__c == undefined || this.selectedCountry == undefined) {
                copyValid = false;
                this.template.querySelector('c-core_-i-p-s_-country-state_-l-w-c').validateCountryMethod();
            }
        }
        if (this.statedefaultvalue == undefined) {
            if (this.showState == true && (caseObj.Core_IPS_Embargoed_State__c == undefined || this.selectedState == undefined)) {
                copyValid = false;
                this.template.querySelector('c-core_-i-p-s_-country-state_-l-w-c').validateStateMethod();
            }
        }    
        if(caseObj.Subject == null || caseObj.Subject == undefined || caseObj.Subject == ''){
            copyValid = false;
            this.isRequiredSubjectCpy = true;
            this.template.querySelector('.cpySubjectInput')?.classList.add('showRequired');
            this.template.querySelector('.cpySubjectInput')?.scrollIntoView();
        }  
        if(caseObj.Core_Issue_Description__c == null || caseObj.Core_Issue_Description__c == undefined || caseObj.Core_Issue_Description__c == '' || plainVal == '') {
            copyValid = false;
            this.isRequiredDescCpy = true;
            this.template.querySelector('.cpyDescInput')?.classList.add('Descriptionborder');
            this.template.querySelector('.cpyDescInput')?.scrollIntoView();
        }  
        if(this.copySeverityReason && (caseObj.Core_Severity_Reason__c == '' || caseObj.Core_Severity_Reason__c == undefined || caseObj.Core_Severity_Reason__c == null)){
            copyValid = false;
            this.isRequiredSeverityRsncpy = true;
            this.template.querySelector('.cpySrnsInput')?.classList.add('showRequired');
            this.template.querySelector('.cpySrnsInput')?.scrollIntoView();
        }  
        if(this.showSubCat == true && (caseObj.Core_Case_Issue_Sub_Category__c ==  null || caseObj.Core_Case_Issue_Sub_Category__c == undefined || caseObj.Core_Case_Issue_Sub_Category__c ==  '')) {
            copyValid = false;
            this.isRequiredSubCatcpy = true;
            this.template.querySelector('.cpysubCatInput')?.classList.add('showRequired');
            this.template.querySelector('.cpysubCatInput')?.scrollIntoView();
        } 

        if (this.showProdEdqs === true) {
            this.template.querySelector('c-dynamic-form-builder[data-id="prodEDQ"]').callhandleQuestionAnswer();
        }
        if (this.showSubCatEdqs === true) {
            this.template.querySelector('c-dynamic-form-builder[data-id="subCatEDQ"]').callhandleQuestionAnswer();
        }
        this.validateedq();
        if (this.valCheck) {
            if(copyValid) {
                for (const x of this.savealldataedqMap.keys()) {
                    this.savealldataedq.push(this.savealldataedqMap.get(x));
                    console.log('Key=' + x + ', Value=' + JSON.stringify(this.savealldataedqMap.get(x)));
                }
                var strEdq = JSON.stringify(this.savealldataedq);
                this.isSpinner = true;
              
                SubmitCaseRecord({ newRecord: caseObj, ContactRecord: null, CaseEDQData: strEdq })
                    .then(result => {
                        if (result !== undefined || result !== null) {
                            if (this.recordId === null || this.recordId === undefined) {
                                this.showToast('Error', 'Case cannot be created', 'error');
                                this.isSpinner = false;

                            } else {
                                this.showToast('Success', 'Case has been created.', 'success');
                                this.isSpinner = false;

                            }
                            this.recordId = result.Id;
                            this.showCopycmp = false;
                            this.navigateToViewCase();
                        } else {}
                        this.isLoaded = false;
                    })
                    .catch(error => {
                        this.isSpinner = false;
                        this.showToast('ERROR', error.body.message, 'error');
                    });
             }
        } else{
            this.template.querySelector('.validate').classList.add('showRequired');
        }
         this.savealldataedq=[];
    }

    handleChangeProductVariant(event) {
        let selectedProdVariant = event.detail.value;
        let productVariantID = event.detail.recordId;
        this.caseProductVariantOptions.forEach(option => {
            if (option.value == selectedProdVariant) {
                this.productvariantName = option.label;
            }
        });
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
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleSuccess(event) {}
    handleSubmit() {
        this.isModalOpen = false;
        this.showToast('Success', 'Case has been updated.', 'success');
        setTimeout(() => window.location.reload(), 1000);
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    searchpara = '*';
    availableAccounts;
    searchString;
    initialRecords = [];
    getcaseid() {
        getcaseid({ caseid: this.recordId })
            .then(result => {
                this.items = result;
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Caseid',
                        message: error.message,
                        variant: 'error'
                    }),
                );
            });

    }

    interestedpartiesvalue = [];
    csob = [];
    caseobjvalue;
    linkedext = [];
    previnterestedparties = [];
    existingInterestedParties = [];
    interestedctrl() {
        core_Ips_InterestedParties_CTRL1({ caseid: this.recordId })
            .then(result => {
                this.items = result;
                this.csob = JSON.parse(result);
                this.caseobjvalue = this.csob[0].cs;
                this.linkedext = this.csob[0].linkedextparty;
                if (this.caseobjvalue) {
                    let options = [];
                    this.caseobjvalue.forEach(eachRecord => {
                        options.push({ label: eachRecord.Name, value: eachRecord.Id });
                    });
                    this.linkedext.forEach(eachRecord => {
                        let names = eachRecord.firstName + ' ' + eachRecord.lastName;
                        options.push({ label: names, value: eachRecord.contactId });
                    });
                    this.interestedpartiesvalue = options;
                    this.initialRecords = options;
                }
                if (this.linkedext) {
                    let values = [];
                    let parties = [];
                    this.linkedext.forEach(eachRecord => {
                        let names = eachRecord.firstName + ' ' + eachRecord.lastName;
                        values.push(names, eachRecord.contactId);
                        parties.push(eachRecord.contactId);
                    });
                    this.previnterestedparties = values;
                    this.existingInterestedParties = parties;
                }
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Caseobj',
                        message: error.message,
                        variant: 'error'
                    }),
                );
            });
    }
    onchangevalue = [];
    handleChangeintrsdpartymembers(event) {
        this.onchangevalue = event.detail.value;
        
        if(this.currentCaseData.RecordType.DeveloperName == 'IPS_Closed_Case' || this.currentCaseData.RecordType.DeveloperName == 'IPS_GEC_ReadOnly'){
            this.showAddRemoveBtn = false;
        }
        else{
            this.showAddRemoveBtn = true;
        }    
        if (this.intvalue) {
            this.onchangevalue = [...this.onchangevalue, ...this.intvalue];
            this.previnterestedparties = [...new Set(this.onchangevalue)];
            this.intvalue = [];
            this.countinterested = 0;
        }


    }
    initialProjMem = [];
    handleSaveMemeber() {
        this.isSpinner = true;
        let tempProjMem = this.linkedext;
        for (let i = 0; i < tempProjMem.length; i++) {
            let temp = tempProjMem[i].contactId;
            this.initialProjMem.push(temp);
        }
        addOrRemovePartyMembers({ initialIds: this.initialProjMem, selectedIds: this.onchangevalue, caseID: this.recordId })
            .then(result => {
                if (result == 'Success') {
                    this.isSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Interested Parties Member Add / Remove operation is done.',
                            variant: 'success'
                        }),
                    );
                } else {
                    this.isSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in Add / Remove Interested Parties Member.',
                            variant: 'error'
                        }),
                    );
                }
                setTimeout(() => window.location.reload(), 1000);
            })
            .catch(error => {
                this.isSpinner = false;
                this.errorMsg = error;
                this.showToast('ERROR', error.body.message, 'error');
            })
    }
    countinterested = 0;
    intvalue = [];
    handleSearchChange(event) {
        this.searchString = event.detail.value;

        if (this.searchString) {
            if (this.countinterested == 0) {
                this.intvalue = this.existingInterestedParties;
                this.countinterested = 1;
            }
            this.interestedpartiesvalue = this.initialRecords;
            if (this.interestedpartiesvalue) {
                let recs = [];
                for (let rec of this.interestedpartiesvalue) {
                    let interestedInput = this.searchString.toLowerCase();
                    if (rec.label.toLowerCase().includes(interestedInput)) {
                        recs.push(rec);
                    }
                }
                this.interestedpartiesvalue = recs;

                if (recs.length == 0)
                    this.isErrormessage = true;
                else
                    this.isErrormessage = false;
            }
        } else {
            this.interestedpartiesvalue = this.initialRecords;
        }
    }
    subCategoryLabel;
    handleChangeRenderSubCategoryedq(event) {
        let selectedSubCategory = event.detail.value;
        this.caseIssueSubCategoryId = selectedSubCategory;
        this.showSubCatEdqs = false;
        this.getSubCategoryEdqs(selectedSubCategory);
        this.theRecord.subCategory = selectedSubCategory;
        this.CaseSubcategoryoptions.forEach(option => {
            if (option.value == selectedSubCategory) {
                this.subCategoryLabel = option.label;
            }
        });
        this.theRecord.subCategoryLabel = this.subCategoryLabel;
        this.SubCategoryName = this.subCategoryLabel;
        this.template.querySelector('.cpysubCatInput')?.classList.remove('showRequired');
        this.template.querySelector('.editSubCatInput')?.classList.remove('showRequired');
        this.isRequiredSubCatcpy = false;
        this.isRequiredSubCat = false;
        
    }

    categoryLabel;
    //tempSubCat ;
    handleChangeCategory(event) {
        let categoryNameForEdit = event.target.value;
        this.caseIssueCategoryId = categoryNameForEdit;
        this.CaseCategoryoptions.forEach(option => {
            if (option.value == categoryNameForEdit) {
                this.categoryLabel = option.label;
            }
        });
        if (categoryNameForEdit !== null) {
            this.showSubCatEdqs = false;
            this.theRecord.subCategory = '';
            this.theRecord.subCategoryLabel  = '';
            this.caseIssueSubCategoryId = '';
            this.SubCategoryName = '';
            this.showCaseSubCategory(categoryNameForEdit);
        }
        this.theRecord.caseCategory = categoryNameForEdit;
        this.theRecord.caseCategoryLabel = this.categoryLabel;
        this.CategoryName = this.categoryLabel;
    }

    @track showSubCat;
    showCaseSubCategory(caseCategory) {
        showsubCategory({
                categorySelected: caseCategory,
            }).then(result => {
                if (result !== undefined || result !== null) {
                    this.CaseSubcategoryoptions = result;
                    this.SubCategoryName = '';
                    if (this.CaseSubcategoryoptions.length > 0) {
                        this.showSubCat = true;
                        this.showSubCategory = true;
                    } else {
                        this.showSubCat = false;
                        this.showSubCategory = false;
                        this.subCatRecEdqs = [];
                    }
                }
            })
            .catch(error => {
                this.error = error;
            });

    }

    closeCopyModal() {
        this.showCopycmp = false;
    }
    countryOptions = [];

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
        } else if (error) {}
    }

    @track agentCheck;
    @track partnerSupportOwner;
    getUserProfile() {
        getcurrentuserprofile({})
            .then(data => {
                if (data === 'PartnerAgent' || data === 'PartnerFAE') {
                    this.agentCheck = true;
                    this.getPartnerSupportedAccountApex(this.projectId, this.userId);
                    this.getSupOwnerAndSupAccountforEditCaseApex(this.recordId);
                } else {
                    this.agentCheck = false;
                }
            })
            .catch(error => {
                console.log('error occured in getting user profile.');
            })
    }

    partnerSupportOwnerId;
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

    partnerSupportAccount;
    handleChangePartnerAccount(event) {
        this.partnerSupportAccount = event.detail.value;
        this.ispartnerAccreq = false;
        this.template.querySelector('.partnerAccreq')?.classList.remove('showRequired');
    }

    @track partnerSupportedAccountName;
    getSupOwnerAndSupAccountforEditCaseApex(caseId) {
        getSupOwnerAndSupAccountforEditCase({
            caseId: caseId
        }).then(data => {
            if (data) {
                let tempData = JSON.parse(JSON.stringify(data));
                if (tempData.Core_IPS_Partner_Sup_Owner__c != null || tempData.Core_IPS_Partner_Sup_Owner__c != undefined) {
                    this.partnerSupportOwner = tempData.Core_IPS_Partner_Sup_Owner__r.Name;
                    this.partnerSupportOwnerId = tempData.Core_IPS_Partner_Sup_Owner__c;
                }
                if (tempData.Core_Partner_Supported_Account__c != null || tempData.Core_Partner_Supported_Account__c != undefined) {
                    this.partnerSupportAccount = tempData.Core_Partner_Supported_Account__c;
                    this.partnerSupportedAccountName = tempData.Core_Partner_Supported_Account__r.Name;
                }
            }
        }).catch(error => {
            console.log('Getting error in getSupOwnerAndSupAccountforEditCase method ', error);
        })
    }

}