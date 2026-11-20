/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */

/* import salesforce standard components  */
import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord,getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

/* import fields  */
import Case_OBJECT from '@salesforce/schema/Case';
import Case_Source from '@salesforce/schema/Case.Core_IPS_Issue_source__c';
import Case_Type from '@salesforce/schema/Case.Core_CaseType__c';
import Case_Severity from '@salesforce/schema/Case.Core_Severity__c';

/* import constants/labels  */
//import contectErrorMessage from '@salesforce/label/c.Core_IPS_ContactErrorMessage_LWC';
//import productErrorMessage from '@salesforce/label/c.Core_IPS_ProductErrorMessage_LWC';
//import contAndProdErrorMessage from '@salesforce/label/c.Core_IPS_ConAndProdErrorMessage_LWC';
import contactIdErrorMessage from '@salesforce/label/c.Core_IPS_ContactIdErrorMessage_LWC';
import productIdErrorMessage from '@salesforce/label/c.Core_IPS_ProductIdErrorMessage_LWC';
//import caseErrorMessage from '@salesforce/label/c.Core_IPS_CaseErrorMessage_LWC';
//import caseTypeErrorMessage from '@salesforce/label/c.Core_IPS_CaseTypeErrorMessage_LWC';
//import caseSubjectErrorMessage from '@salesforce/label/c.Core_IPS_CaseSubjectErrorMessage_LWC';
//import caseDescErrorMessage from '@salesforce/label/c.Core_IPS_CaseDescErrorMessage_LWC';
//import caseSeverityErrorMessage from '@salesforce/label/c.Core_IPS_CaseSeverityErrorMessage_LWC';
//import caseCategoryErrorMessage from '@salesforce/label/c.Core_IPS_CaseCategoryErrorMessage_LWC';
//import CaseSubCategoryErrorMessage from '@salesforce/label/c.Core_IPS_CaseSubCategoryErrorMessage_LWC';
import Core_IPS_Internal_Portal from '@salesforce/label/c.Core_IPS_Internal_Portal';
import navigateToCaseRecentList from '@salesforce/label/c.Core_IPS_Case_RecentList';
/* import Apex calls  */
import getAgent from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getAgentDetail";
import getProjectList from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getProjectList";
import getPlatfrm from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getPlatformDetails";
import getContactSOQL from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getContactLookupSOQL";
import getProductEdqs from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getProductEDQ";
import getCase from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getCaseData";
import displayProductVariant from "@salesforce/apex/Core_IPS_CaseCreateLWCController.displayProductVariant";
import SubmitCaseRecord from "@salesforce/apex/Core_IPS_CaseCreateLWCController.submitCaseRecord";
import showCategory from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getCategoryDetails";
import showsubCategory from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getSubCategoryDetail";
import getSubCategoryDetails from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getSubCatProductEDQ";
import showVariants from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getvariant";
import copyInterestedParties from "@salesforce/apex/Core_IPS_CaseCreateLWCController.copyInterestedParties";
import getErrorMessage from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getErrorMessage";
import readFieldSet from "@salesforce/apex/Core_IPS_CaseCreateLWCController.readFieldSet";
import getProjectListFromAsset from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getProjectListFromAsset";
import getAccountList from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getAccountList";
import getContactListFromProject from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getContactListFromProject";
import getContactListFromAsset from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getContactListFromAsset";
import getProjectAsset from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getProjectAsset";
import getProductQuery from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getProductQuery";
import getAssetOnProjectChange from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getAssetOnProjectChange";
import getProductSupportOwner from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getProductSupportOwner";
import getPartnerSupportAccount from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getPartnerSupportAccount";
import hasReadAccess from "@salesforce/apex/Core_IPS_CaseCreateLWCController.hasReadAccess";
import validateBeforeSubmitCase from "@salesforce/apex/Core_IPS_CaseCreateLWCController.validateBeforeSubmitCase";
import USER_ID from "@salesforce/user/Id";
import USERPROFILE_NAME from "@salesforce/schema/User.Profile.Name";
import TickerSymbol from '@salesforce/schema/Account.TickerSymbol';


/* Declare & initialize constants */
const Core_IPS_Global_Asset_RT = 'Core_IPS_Public_Product';

export default class core_IPS_CreateCase extends NavigationMixin(LightningElement) {

    /* Public Attributes */
    @api recordId;
    @api mode = 'create';
    @api modeType='Case Create';
    @api returnURL;
    @api recordTypeId;
    @api recordTypeName;

    @api sourceValues = [];
    @api typeValues = [];
    @api severityValues = [];
    @api records = [];
    @api platformoptions = [];
    @api myobjectdata = [];
    @api isLoaded;
    @api trackvalidation = [];
    @api trackchildataa = [];
    @api categoryoptions = [];
    @api subcategoryoptions = [];

    /* Private Attributes */
    @track ipsCreateRecordId;
    @track openConfirmPopup = false;
    @track isMindsCase = false;
    @track countrySelected;
    @track isPrivateProject;
    @track ipsSupportedContact;
    @track selectedContactRecord;
    @track selectedProductRecord;
    @track platformValue;
    @track showGECFields;
    @track selfAssigned = false;
    @track caseEditData;
    @track project;
    @track isSelectedProjectPresent = false;
    @track savealldataedq = [];
    @track recordsedq = [];
    @track activeSection = ['A', 'B'];
    @track nacRecType = false;
    @track agentTrack;
    @track supportedProductdata
    @track primaryPickList;
    @track error;
    @track productVariant = '';
    @track caseCategory;
    @track caseSubCategory;
    @track value3;
    @track valCheck = true;
    @track editAccess = false;
    @track conid;
    @track productid;
    @track projectid;

    @track caseContactId;
    @track caseAccountId;
    @track caseProjectId;
    @track caseProductId;

    @track projectList;
    @track projectLstFromAsset;
    @track accountList;
    @track contactLstFromProject;
    @track contactLstFromAsset;
    @track stateSelected;

    // for PSO
    @track PSOlookupIconName = "standard:User";
    @track PSOlookupQueryString;
    @track PSOlookupSearchFieldName = "Name";
    @track PSOisLookupQueryPresent = false;
    @track PSOlookupCountQueryStringUser;
    @track PSOSelected;
    @track PSAOptions;
    @track PSASelected;
    @track displayPSO;

    //for contact
    @track lookupIconName = "standard:contact";
    @track lookupQueryString;
    @track lookupSearchFieldName = "Name";
    @track isLookupQueryPresentContact = false;
    @track showMindSection = false;
    @track lookupCountQueryStringContact;

    //for project

    @track lookupIconNameProject = "standard:account";
    @track lookupSearchFieldNameProject = "Name";
    @track lookupQueryStringProject;
    @track isLookupQueryPresentProject = false;
    @track lookupCountQueryStringProject;
    //for product
    @track lookupIconNameProduct = "standard:product";
    @track lookupQueryStringProduct;
    @track templookupQueryStringProduct;
    @track lookupCountQueryStringProduct;
    @track lookupSearchFieldNameProduct = "Name";//Product2.Name
    @track isLookupQueryPresentProduct = false;
    @track showProductSection = false;
    @track renderProductVariant = false;
    @track renderProductCategory = false;
    @track renderProductSubCategory = false;
    @track passSupportedProductID;
    @track showSubCatEDQ = false;
    @track showProductEDQ = false;
    @track subCatIdPass = false;
    @track subsCatedqi = [];
    @track customerVisible = false;
    @track isCustomerVisibleTrue = false;
    //caseEditVariables
    @track caseSubjectEdit;
    @track caseDescriptionEdit;
    @track caseProductEdit;
    @track caseTypeEdit;
    @track caseSourceEdit;
    @track endCustomerEdit;
    @track customerRefIdEdit;
    //platform
    @track showplatform = false;
    //to validation and save of case
    @track isValid = true;
    @track caseSource = Core_IPS_Internal_Portal;
    @track caseType;
    @track caseSubject;
    @track caseDescription;
    @track caseSeverity = 'Low';
    @track showPriority = false;
    @track caseId;
    @track recordId;
    @track recordPageUrl;
    @track capedqsize = [];
    //@track inselectedquestionanswer = [];
    @track currentPageReference;
    @track assetProdName;
    @track assetProjName;
    @track newCase = true;
    @track editFlag = false;
    @track spinnerOn = false;
    @track nacCase = false;
    @track skipProductChange = false;
    @track showProductInfoDialog = false;
    @track tempProjectId;
    @track tempProjectName;
    @track setClose=false;
    @track currentProductData;
    @track cnt = 0;
    @track flag = false;
    @track pageReload=false;
    @track PSOQuery =0;
    @track currentUserProfileName;
    @track disableSubject=false;
    @track isSAP=false;
    @track isAssetId=true;
    @track InlineHelpText;
    @track helpTextInfo;
    @track productFocusAreaLabel = "core_Product_Application__c";
    publicProductRecTypeName = Core_IPS_Global_Asset_RT;
    productInactiveError;
    initialized = false;

    constructor() {
        super();
        // this.template.addEventListener('notification', this.handleNotification.bind(this));
        this.template.addEventListener('inselectedquestionanswer', this.handleChangeChild.bind(this));
        // this.template.addEventListener('ihaveedq', this.checkproductedqsize.bind(this));
    }

    /* wire methods started */
    @wire(getObjectInfo, { objectApiName: Case_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Case_Source })
    wiredsourceField({ data, error }) {
        if (data) {
            let recordtypeinfo = this.objectInfo.data.recordTypeInfos;
            for (var eachRecordtype in recordtypeinfo) {
                if (recordtypeinfo[eachRecordtype].name === 'IPS Case Create') {
                    this.ipsCreateRecordId = recordtypeinfo[eachRecordtype].recordTypeId;
                    break;
                }
            }
            console.log('create ips id--->' + this.ipsCreateRecordId);
            this.sourceValues = data.values;
        }
        if (error) {
            console.error('Error in loading case source values. Error : ' + error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Case_Type })
    wiredtypeField({ data, error }) {
        if (data) {
            this.typeValues = data.values;
        }
        if (error) {
            console.error('Error in loading case type values. Error : ' + error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Case_Severity })
    wiredSeverityField({ data, error }) {
        if (data) {
            this.severityValues = data.values;
        }
        if (error) {
            console.error('Error in loading case severity values. Error : ' + error);
        }
    }

    @wire(getAgent)
    wiredCases({ data, error }) {
        if (data) {
            this.agentTrack = data
            this.errors = undefined;
        }
        if (error) {
            this.records = undefined;
            this.errors = error;
            console.error('Error in loading case severity values. Error : ' + error);
        }
    }

    @wire(getProjectList, { relatedId: '$caseContactId' })
    wiredProjectList({ data, error }) {
        if (data) {
            console.log('Anil caseContactId--', this.caseContactId);
            this.projectList = JSON.stringify(data);
            this.projectList = this.projectList.replace("[", "(");
            this.projectList = this.projectList.replace("]", ")");
            this.projectList = this.projectList.replace(/"/g, "'");
            if (this.projectList !== undefined && this.projectList !== null && this.projectList !== '' && this.projectList !== '()') {
                console.log('Inside get ProjectList '+this.projectList);
                this.formCaseProjectLookupQuery();
                this.formCaseProductLookupQuery();
            }
            this.spinnerOn = false;
        }
        if (error) {
            console.error('Error in loading project id list. Error : ' + error);
            this.spinnerOn = false;
        }
    }

    @wire(getProjectListFromAsset, { prodId: '$caseProductId' })
    wiredAssetProjectList({ data, error }) {
        if (data) {
            console.log('sho10--- '+this.caseProductId);
            this.projectLstFromAsset = JSON.stringify(data);
            this.projectLstFromAsset = this.projectLstFromAsset.replace("[", "(");
            this.projectLstFromAsset = this.projectLstFromAsset.replace("]", ")");
            this.projectLstFromAsset = this.projectLstFromAsset.replace(/"/g, "'");
            console.log('shob0--- '+this.projectLstFromAsset);
            if (this.projectLstFromAsset !== undefined && this.projectLstFromAsset !== null && this.projectLstFromAsset !== '' && this.projectLstFromAsset !== '()') {
            
                this.formCaseProjectLookupQuery();
            }
            this.spinnerOn = false;
        }
        if (error) {
            console.error('Error in loading project from Asset id. Error : ' + error);
            this.spinnerOn = false;
        }
    }

    @wire(getAccountList)
    wiredAccountList({ data, error }) {
        if (data) {
            this.accountList = JSON.stringify(data);
            this.accountList = this.accountList.replace("[", "(");
            this.accountList = this.accountList.replace("]", ")");
            this.accountList = this.accountList.replace(/"/g, "'");
            if (this.accountList !== undefined && this.accountList !== null && this.accountList !== '' && this.accountList !== '()') {
                this.formCaseContactLookupQuery();
            }
        }
        if (error) {
            console.error('Error in loading Account list. Error : ' + error);
        }
    }

    @wire(getContactListFromProject, { projectId: '$caseProjectId' })
    wiredProjectContactList({ data, error }) {
        if (data) {
            this.contactLstFromProject = JSON.stringify(data);
            this.contactLstFromProject = this.contactLstFromProject.replace("[", "(");
            this.contactLstFromProject = this.contactLstFromProject.replace("]", ")");
            this.contactLstFromProject = this.contactLstFromProject.replace(/"/g, "'");
            if (this.contactLstFromProject !== undefined && this.contactLstFromProject !== null && this.contactLstFromProject !== '' && this.contactLstFromProject !== '()') {
                if (!this.nacRecType) {
                    this.formCaseContactLookupQuery();
                }
            }
            this.spinnerOn = false;
            console.log('conlstfromproj-pp');
        }
        if (error) {
            console.error('Error in loading contact list from project. Error : ' + error);
            this.spinnerOn = false;
        }
    }

    @wire(getContactListFromAsset, { prodId: '$caseProductId' })
    wiredAssetContactList({ data, error }) {
            if (data) {
                this.contactLstFromAsset = JSON.stringify(data);
                this.contactLstFromAsset = this.contactLstFromAsset.replace("[", "(");
                this.contactLstFromAsset = this.contactLstFromAsset.replace("]", ")");
                this.contactLstFromAsset = this.contactLstFromAsset.replace(/"/g, "'");
                if (this.contactLstFromAsset !== undefined && this.contactLstFromAsset !== null && this.contactLstFromAsset !== '' && this.contactLstFromAsset !== '()') {
                    if (!this.nacRecType) {
                        this.formCaseContactLookupQuery();
                    }
                }
                this.spinnerOn = false;
                console.log('conlstfromprod-pp');
            }
            if (error) {
                console.error('Error in loading contact List from Asset id. Error : ' + error);
                this.spinnerOn = false;
            }
        }
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        //this.mode = this.currentPageReference?.state?.c__mode;
        this.caseProductId = this.currentPageReference?.state?.c__productId;
        this.caseProjectId = this.currentPageReference?.state?.c__projectId;
        //this.mode = this.currentPageReference?.state?.c__mode;
        if(this.caseProductId!=undefined && this.caseProductId!=null && this.caseProductId !== ''){
            this.mode = 'asset';
        }
        console.log('ppmode--'+this.mode);
        if(this.pageReload==true && (this.mode == 'create'|| this.mode == 'asset') && this.mode != undefined ){
            window.location.reload();
            //this.pageReload = false;
        }
    } 
    @wire(getRecord, { recordId: USER_ID, fields: [USERPROFILE_NAME]}) 
    userDetails({data,error}) {
        if (data) {
            this.currentUserProfileName = data.fields.Profile.value.fields.Name.value;
            if(this.currentUserProfileName === 'Global Export Compliance' && (this.mode=='create' || this.mode == 'copy')){
                this.disableSubject = true;
            }
            else{
                this.disableSubject = false;
            }
            this.spinnerOn = false;
            
        }
        if (error) {
            console.log('Error--'+ error);
            this.spinnerOn = false;
        }
    }
    @wire(getObjectInfo, { objectApiName: Case_OBJECT})
    getHelpTextInfo(result) {
        if (result.data)
            this.helpTextInfo = result.data.fields;
        console.log(JSON.stringify(result));
    }
        /* wire methods ended */

    /* get Methods started */
    get disableEdit() {
        if (this.caseEditData === undefined || this.caseEditData === null) {
            console.log('1 edit');
            return false;

        }
        if (this.recordTypeName !== undefined && this.recordTypeName !== null &&
            this.recordTypeName === 'IPS_GEC_ReadOnly') {
            console.log('2 edit');
            return true;
        }
        if (this.mode === 'copy') {
            console.log('3 edit');
            return false;
        }     
        else {
            return this.caseEditData.isClosed;
        }
    }

    get disableProjectEdit() {

            var isClosed = false;
            var isReadOnly = false;
            if (this.recordTypeName !== undefined && this.recordTypeName !== null &&
                this.recordTypeName === 'IPS_GEC_ReadOnly') {
                isReadOnly = true;
            }
            if (this.caseEditData !== undefined && this.caseEditData !== null) {
                isClosed = this.caseEditData.isClosed;
            }

            if (this.mode === 'copy') {
                return false;
            } else {
                console.log('prohectedit---' + isClosed);
                console.log('prohectedit1---' + isReadOnly);
                return this.isProjectReadOnly || isClosed || isReadOnly;
            }
        }
        /* get Methods ended */

    setLookupQueries() {
        this.lookupQueryString = 'SELECT Id, Name, Account.Name, AccountId, Account.ownerId, Core_IPS_Intel_Support_Owner__c, Core_MINDS__c, Core_Country_Region__c FROM Contact WHERE Core_IPS_Active__c=true AND Name LIKE :key LIMIT :recordLimit';
        this.lookupCountQueryStringContact = 'select count() from contact where Name like :key';
        if (this.recordTypeName !== undefined && this.recordTypeName !== null) { //&& this.recordTypeName === 'IPS_Case_Create') {
            this.isLookupQueryPresent = true;
        }
        this.lookupQueryStringProject = 'select id, Core_IPS_Private__c, Core_IPS_Project_ID__c, ' + this.lookupSearchFieldNameProject + ' from core_ips_project__c where Name like :key LIMIT :recordLimit';
        this.lookupCountQueryStringProject = 'select count() from core_ips_project__c where Name like :key';
        this.isLookupQueryPresentProject = true;
        if (this.recordTypeName !== undefined && this.recordTypeName !== null && this.recordTypeName === 'Core_IPS_Case_Create_Self_Assigned') {
            this.showMindSection = true;
            this.nacRecType = true;
            this.showGECFields = true;
            this.selfAssigned = true;
        }
        this.formCaseProductLookupQuery();



    }

    // init  = async () =>  {
    init() {
        if (this.recordId === '' || this.recordId === null || this.recordId === undefined) {
            this.isLoaded = false;
            //this.setLookupQueries();
            return;
        }

        if (this.recordTypeName !== undefined && this.recordTypeName !== null && this.recordTypeName === 'Core_IPS_Case_Create_Self_Assigned') {
            this.showMindSection = true;
            this.nacRecType = true;
            this.showGECFields = true;
            this.selfAssigned = true;
        }

        getCase({
            caseId: this.recordId,

        }).then(result => {
            //  console.log("this.records inside varaints");
            // console.log("rsult" + JSON.stringify(result));
            //console.log("1" + JSON.stringify(result.DynamicField.label));


            if (result !== undefined || result !== null) {
                this.caseEditData = result;
                console.log('test cs ', JSON.stringify(this.caseEditData));
                //console.log('cs edit data debug ===>', JSON.stringify(this.caseEditData));
                this.recordTypeName = this.caseEditData.cs.RecordType.DeveloperName;

                if (this.recordTypeName !== undefined && this.recordTypeName !== null &&
                    this.recordTypeName === 'IPS_GEC_ReadOnly') {
                    this.showToast('ERROR', 'This case is not editable.', 'error');
                    this.navigateToViewCase();
                    this.isLoaded = false;
                    return;
                }
                // console.log(' this.case ' + JSON.stringify(result.fields));
                if (this.mode === 'copy') {
                    console.log('ProductReadAccess--'+this.caseEditData.cs.AssetId);
                    if(this.caseEditData.cs.AssetId!=undefined && this.caseEditData.cs.AssetId!=null){
                        hasReadAccess({
                           assestId : this.caseEditData.cs.AssetId,
                        }).then(result=>{
                        //console.log('ShobEditAccess-->'+this.editAccess);
                            this.editAccess = result;
                            if(!this.editAccess){
                               this.showToast('ERROR', 'You do not have product access', 'error');
                               this.navigateToViewCase();
                               this.isLoaded = false;
                               return; 
                            }
                        }).catch(error=>{
                            console.log('Error--'+JSON.stringify(error)); 
                        })
                    }
                    if (this.caseEditData.cs.Core_IPS_Supported_Product__r.Core_EOIS__c == true ||
                        (this.caseEditData.cs.AssetId !== undefined &&
                            this.caseEditData.cs.AssetId !== null &&
                            this.caseEditData.cs.Asset.Status === 'Inactive')
                    ) {
                        this.showToast('ERROR', this.productInactiveError, 'error');
                        this.navigateToViewCase();
                        this.isLoaded = false;
                        return;
                    }
                }

                if ((this.recordTypeName !== undefined && this.recordTypeName !== null && this.recordTypeName === 'Core_IPS_Case_Create_Self_Assigned')||(this.caseEditData.cs.Core_IPS_Self_Assigned__c && (this.caseEditData.cs.Core_IPS_Project_Case__c == undefined || this.caseEditData.cs.Core_IPS_Project_Case__c == null))) {
                    this.showMindSection = true;
                    this.nacRecType = true;
                    this.showGECFields = true;
                    this.selfAssigned = true;
                }

                //this.setLookupQueries();
                this.caseSeverity = this.caseEditData.cs.Core_Severity__c;
                this.caseSeverityReason = this.caseEditData.cs.Core_Severity_Reason__c;
                this.setReasonVisibility();
                this.isProjectReadOnly = this.caseEditData.isPrivateProjectCase;
                this.showMindSection = this.caseEditData.showGECFields;

                this.caseDescriptionEdit = this.caseEditData.cs.Core_Issue_Description__c;
                this.caseSubjectEdit = this.caseEditData.cs.Subject;
                //this.caseProductEdit = this.caseEditData.cs.Core_IPS_Product__c;
                if (this.caseEditData.asset !== undefined && this.caseEditData.asset !== null) {
                    this.asset = {
                        Id: this.caseEditData.asset.Id,
                        Name: this.caseEditData.asset.Name //this.caseEditData.asset.name 
                    }
                    this.selectedProductRecord = {
                        Id: this.caseEditData.asset.Id,
                        Name: this.caseEditData.asset.Name
                    }
                    this.caseProductId = this.caseEditData.asset.Id;
                      }
                else{        
                    this.asset = {
                        Id: this.caseEditData.cs.Core_IPS_Supported_Product__c,
                        Name: this.caseEditData.cs.Product.Name
                    }
                    
                    this.selectedProductRecord = {
                        Id: this.caseEditData.cs.Core_IPS_Supported_Product__c,
                        Name: this.caseEditData.cs.Product.Name
                    }
                    this.caseProductId = this.caseEditData.cs.Core_IPS_Supported_Product__c;
                    this.isAssetId = false;
                    this.lookupSearchFieldNameProduct = "Name";
                    
                }
                if (this.caseEditData.isPrivateProjectCase) {
                    if (this.caseEditData.cs.Core_IPS_Supported_Contact__c !== undefined && this.caseEditData.cs.Core_IPS_Supported_Contact__c !== null) {
                        this.contact = {
                            Id: this.caseEditData.cs.Core_IPS_Supported_Contact__c,
                            Name: this.caseEditData.cs.Core_IPS_Supported_Contact__r.FirstName + ' ' + this.caseEditData.cs.Core_IPS_Supported_Contact__r.LastName
                        } 
                    }
                } else {
                    if (this.caseEditData.contact !== undefined && this.caseEditData.contact !== null) {
                        this.contact = {
                            Id: this.caseEditData.contact.Id,
                            Name: this.caseEditData.contact.FirstName + ' ' + this.caseEditData.contact.LastName //this.caseEditData.asset.name 
                        }
                    }
                }
                this.caseTypeEdit = this.caseEditData.cs.Core_CaseType__c;
                this.caseSourceEdit = this.caseEditData.cs.Core_IPS_Issue_source__c;
                this.PSOlookupQueryString = this.caseEditData.PSOQuery;
                this.PSOCountQuery = this.caseEditData.PSOCountQuery;
                this.endCustomerEdit = this.caseEditData.cs.Core_End_Customer__c;
                this.customerRefIdEdit = this.caseEditData.cs.Core_Customer_Reference_ID__c;
                if (this.caseEditData.PSO !== undefined && this.caseEditData.PSO !== null) {
                    this.PSOSelected = {
                        Id: this.caseEditData.PSO.Id,
                        //Name: this.caseEditData.PSO.FirstName + ' ' + this.caseEditData.PSO.LastName
                        Name: this.caseEditData.PSO.FirstName
                    }
                }
                this.displayPSO = this.caseEditData.displayPSO;
                this.PSAOptions = this.caseEditData.lstPSA;
                if(this.caseEditData.cs.Core_Partner_Supported_Account__c != undefined){
                this.PSASelected = this.caseEditData.cs.Core_Partner_Supported_Account__r.Id;
                }
                //this.displayPSO = this.caseEditData.displayPSO;    

                if (this.caseEditData.fields !== null && this.caseEditData.fields !== undefined && this.caseEditData.subCatFields !== null && this.caseEditData.subCatFields !== undefined) {
                    //this.subsCatedqi = this.caseEditData.fields;
                    //this.showSubCatEDQ = true;
                    this.showProductSection = true;
                    this.recordsedq = this.caseEditData.fields;
                     this.showProductEDQ = true;

                    //Hassan Start --- To include only elements not present in recordsedq
                    console.log('hk 651---> ', JSON.stringify(this.caseEditData.subCatFields)); 
                    const recordsedqSet = new Set(this.recordsedq.map(item => item.id));
                    let uniqueSubsCatedqi = [];
                    for (let subCatField of this.caseEditData.subCatFields) {
                        if (!recordsedqSet.has(subCatField.id)) { 
                            uniqueSubsCatedqi.push(subCatField);
                        }
                    }
                    //this.subsCatedqi = this.caseEditData.subCatFields;
                    this.subsCatedqi = uniqueSubsCatedqi;
                    // End
                    console.log('hk 662---> ', JSON.stringify(this.subsCatedqi));
                     this.showSubCatEDQ = true;
                }
                if (this.caseEditData.project !== undefined && this.caseEditData.project !== null) {
                    //this.project = this.caseEditData.project;

                    this.project = {
                        Id: this.caseEditData.project.Id,
                        Name: this.caseEditData.project.Name
                    }
                    console.log('this.project---', JSON.stringify(this.project));
                    this.caseProjectId = this.caseEditData.project.Id;
                    if (this.project.Id !== undefined && this.project.Id !== null && this.project.Id !== '') {
                        this.isSelectedProjectPresent = true;
                    } else {
                        this.isSelectedProjectPresent = false;
                    }
                } else {
                    this.isSelectedProjectPresent = false;
                }
                this.isLoaded = false;

                // set fields for case save
                this.customerVisible = this.caseEditData.cs.Core_IPS_Customer_Visible__c;
                if (this.customerVisible === true) {
                    this.isCustomerVisibleTrue = true;
                }
                this.projectid = this.caseEditData.cs.Core_IPS_Project_Case__c;
                
                //console.log('584 this.this.caseEditData.cs.AssetId ', json.stringify(this.caseEditData.asset));
                
                if(this.caseEditData.asset != null && this.caseEditData.asset != undefined){
                    this.productid = this.caseEditData.asset;
                }
                else{
                    
                    this.productid = this.caseEditData.cs.Core_IPS_Supported_Product__c;
                }  
                
                //this.productid = this.caseEditData.asset;  
                if (this.recordTypeName !== undefined && this.recordTypeName !== null &&
                    this.recordTypeName !== 'Core_IPS_Case_Create_Self_Assigned' && (this.caseEditData.cs.Core_IPS_Self_Assigned__c == false)) {

                    if (this.caseEditData.isPrivateProjectCase) {
                        if (this.caseEditData.cs.Core_IPS_Supported_Contact__c !== undefined && this.caseEditData.cs.Core_IPS_Supported_Contact__c !== null) {

                            this.selectedContactRecord = {
                                Id: this.caseEditData.cs.Core_IPS_Supported_Contact__c,
                                Name: this.caseEditData.cs.Core_IPS_Supported_Contact__r.FirstName + ' ' + this.caseEditData.cs.Core_IPS_Supported_Contact__r.LastName,
                                AccountId: this.caseEditData.cs.Core_IPS_Supported_Contact__r.AccountId,
                                Account: {
                                    Id: this.caseEditData.cs.Core_IPS_Supported_Contact__r.AccountId,
                                    OwnerId: this.caseEditData.cs.Core_IPS_Supported_Contact__r.Account.OwnerId,
                                },
                                IntelSupportOwner : this.caseEditData.cs.Core_IPS_Supported_Contact__r.Core_Intel_Sup_Owner__c
                            };

                            this.conid = this.caseEditData.cs.Core_IPS_Supported_Contact__c;
                            this.caseContactId = this.caseEditData.cs.Core_IPS_Supported_Contact__c;
                            this.caseAccountId = this.caseEditData.cs.Core_IPS_Supported_Contact__r.AccountId;

                        }
                    } else {
                        this.selectedContactRecord = {
                            Id: this.caseEditData.cs.ContactId,
                            Name: this.caseEditData.cs.Contact.FirstName + ' ' + this.caseEditData.cs.Contact.LastName,
                            AccountId: this.caseEditData.cs.Contact.AccountId,
                            Account: {
                                Id: this.caseEditData.cs.Contact.AccountId,
                                OwnerId: this.caseEditData.cs.Contact.Account.OwnerId,
                            },
                            IntelSupportOwner : this.caseEditData.cs.Core_IPS_Supported_Contact__r.Core_Intel_Sup_Owner__c
                        };
                        this.conid = this.caseEditData.cs.ContactId;
                        this.caseContactId = this.caseEditData.cs.ContactId;
                        this.caseAccountId = this.caseEditData.cs.Core_IPS_Supported_Contact__r.AccountId
                    }
                    //this.selectedContactRecord = this.caseEditData.cs.ContactId;

                }
                //this.selectedProductRecord =  this.caseEditData.cs.AssetId;	

                if (this.mode !== undefined && this.mode === 'copy') {
                    this.displayPSO = false;
                    this.showMindSection = true;
                    this.caseSubject = '(Copy Of ' + this.caseEditData.cs.CaseNumber + ') ' + this.caseEditData.cs.Subject;
                    this.caseSubjectEdit = this.caseSubject;
                    this.caseDescription = '**Copied From Case ' + this.caseEditData.cs.CaseNumber + '<br>' + this.caseEditData.cs.Core_Issue_Description__c;
                    this.caseDescriptionEdit = this.caseDescription;
                } else {
                    this.caseSubject = this.caseEditData.cs.Subject;
                    this.caseDescription = this.caseEditData.cs.Core_Issue_Description__c;
                }

                this.caseSource = this.caseEditData.cs.Core_IPS_Issue_source__c;
                this.caseType = this.caseEditData.cs.Core_CaseType__c;
                this.caseSeverity = this.caseEditData.cs.Core_Severity__c;
                this.caseCategory = this.caseEditData.cs.Core_Case_Issue_Category__c;
                this.caseSubCategory = this.caseEditData.cs.Core_Case_Issue_Sub_Category__c;
                if(this.caseEditData.cs.asset != null && this.caseEditData.cs.asset != undefined){   // changed by tushar---- vanuability        
                    this.passSupportedProductID = this.caseEditData.cs.Asset.Core_Supported_Product__c;
                }
                else{
                    this.passSupportedProductID = this.caseEditData.cs.Core_IPS_Supported_Product__c;
                }
                //if (this.caseCategory !== undefined && this.caseCategory !== null && this.caseCategory !== '') {
                    //this.showCaseCategory(this.caseEditData.cs.Asset.Core_Supported_Product__c);
                    this.showCaseCategory(this.passSupportedProductID);
                    //if (this.caseSubCategory !== undefined && this.caseSubCategory !== null && this.caseSubCategory !== '') {
                        this.showCaseSubCategory(this.caseCategory);
                    //}
                //}
                this.recordTypeId = this.caseEditData.cs.RecordTypeId;
                this.isMindsCase = this.caseEditData.cs.Core_IPS_Minds__c;
                this.selfAssigned = this.caseEditData.cs.Core_IPS_Self_Assigned__c; //if NAC then true       
                this.productVariant = this.caseEditData.cs.Core_Product_Variant__c;
                //console.log('assestshowId-- ',this.caseEditData.asset.Id);
                //if ((this.productVariant !== undefined && this.productVariant !== null & this.productVariant !== '')|| {
                    if(this.caseEditData.asset != null && this.caseEditData.asset != undefined){
                        this.renderProductVariant = true;
                       this.displayProdVariant(this.caseEditData.asset.Id, this.recordTypeName);
                       //this.displayProdVariant(this.caseEditData.cs.Core_IPS_Supported_Product__c, this.recordTypeName);
                    }
                    else{
                        this.renderProductVariant = true;
                       this.displayProdVariant(this.caseEditData.cs.Core_IPS_Supported_Product__c, this.recordTypeName);
                    }   
                    //this.renderProductVariant = true;
                //}
                if ((this.recordTypeName !== undefined && this.recordTypeName !== null && this.recordTypeName === 'Core_IPS_Case_Create_Self_Assigned'
                     && this.mode != null && this.mode != undefined && this.mode === 'copy')||this.caseEditData.cs.Core_IPS_Self_Assigned__c) {
                    this.nacCase = true;
                }
                this.platformValue = this.caseEditData.cs.Core_Platform_Name__c;
                this.countrySelected = this.caseEditData.cs.Core_IPS_Country_Region__c;
                if(this.displayPSO == true && this.mode=='edit'){
                   this.PSOQuery =1;
                   this.formCasePSOLookupQuery();
                   this.getPSAOptions();
                }
                

            }
        }).catch(error => {
            console.log("error" + JSON.stringify(error))
            //this.showToast('ERROR', 'Error in loading case', 'error');
            this.error = error;
            console.log("this.error" + JSON.stringify(this.error));
        });

    }
    connectedCallback() {
        if(this.pageReload==false){
          // window.location.reload();
           this.pageReload = true;
        }
        if (this.mode !== undefined && this.mode !== null && this.mode !== '' && this.mode === 'copy') {
            getErrorMessage({ errorCode: 'G119' })
                .then(res => {
                    this.productInactiveError = res;
                }).catch(err => {
                    console.error('Error in loading error message');
                })
        }
        if (this.mode !== undefined && this.mode !== null && this.mode !== '' && this.mode === 'edit') {
            this.modeType = 'Edit Case';
            this.editFlag = 'true';
            console.log('Editing case');
        }
        if (this.recordTypeName !== undefined && this.recordTypeName !== null && this.recordTypeName === 'Core_IPS_Case_Create_Self_Assigned') {
            this.showMindSection = true;
            this.nacRecType = true;
            this.showGECFields = true;
            this.selfAssigned = true;
        }
        if(this.mode === 'asset'){
            this.assetCaseCreation();
        }

        this.isLoaded = true;
        this.init();
        if (!this.nacRecType) {
            readFieldSet({ fieldSetName: 'ContactFieldSet', ObjectApiName: 'Contact' })
                .then(res => {
                    this.contactFieldSet = res;
                    this.formCaseContactLookupQuery();
                })
                .catch(err => {
                    console.error('Error in loading contact field set ', err, JSON.stringify(err));
                })

        }
        readFieldSet({ fieldSetName: 'IpsProjectFieldSet', ObjectApiName: 'core_ips_project__c' })
            .then(res => {
                this.projectFieldSet = res;
                this.formCaseProjectLookupQuery();
                //console.log('ANil Project FieldSet-- ', err, JSON.stringify(this.projectFieldSet));
            })
            .catch(err => {
                console.error('Error in loading project field set ', err, JSON.stringify(err));
            });
        readFieldSet({ fieldSetName: 'SupportedProductFieldSet', ObjectApiName: 'Core_IPS_Supported_Product__c' })
            .then(res => {
                this.supportedProductFieldSet = res;
                //this.formCaseSupportedProdLookupQuery();
            })
            .catch(err => {
                console.error('Error in loading supported product field set ', err, JSON.stringify(err));
            });
        readFieldSet({ fieldSetName: 'AssetFieldSet', ObjectApiName: 'asset' })
            .then(res => {
                this.assetFieldSet = res;
                
                if (this.recordTypeName !== undefined && this.recordTypeName !== null && this.recordTypeName == 'Core_IPS_Case_Create_Self_Assigned' && (this.caseProjectId==null || this.caseProjectId == undefined)) {
                    
                   // this.lookupSearchFieldNameProduct = "Core_Supported_Product_Name__c";
                    //this.lookupSearchFieldNameProduct = "Name";
                    this.isSAP = true;
                    this.formCaseSupportedProdLookupQuery();
                }
                else{ 
                    
                    //this.lookupSearchFieldNameProduct = "Name"; 
                    this.isSAP = false;  
                    this.formCaseProductLookupQuery();
                }
                
            })
            .catch(err => {
                console.error('Error in loading Asset field set ', err, JSON.stringify(err));
            });
            
                
    }

    //commenting this as it's not getting called from anywhere.
    /*getCasedetails() {
        if (this.recordId === '') {
            return;
        }
        getCase({
            caseId: this.recordId,

        }).then(result => {
            //  console.log("this.records inside varaints");
            // console.log("rsult" + JSON.stringify(result));
            //console.log("1" + JSON.stringify(result.DynamicField.label));


            if (result !== undefined || result !== null) {

                // console.log(' this.case ' + JSON.stringify(result.fields));
                this.caseEditData = result;
                this.caseSeverity = this.caseEditData.cs.Core_Severity__c;
                this.setReasonVisibility();
                this.caseDescriptionEdit = this.caseEditData.cs.Core_Issue_Description__c;
                this.caseSubjectEdit = this.caseEditData.cs.Subject;
                this.caseProductEdit = this.caseEditData.cs.Core_IPS_Product__c;
                this.caseTypeEdit = this.caseEditData.cs.Core_CaseType__c;
                this.caseSourceEdit = this.caseEditData.cs.Core_IPS_Issue_source__c;

                if (this.caseEditData.fields !== null && this.caseEditData.fields !== undefined) {
                    console.log('cs check edq check ', this.caseEditData.fields);
                    
                    this.subsCatedqi = this.caseEditData.fields;
                    this.showSubCatEDQ = true;
                    this.showProductSection = true;
                    this.recordsedq = this.caseEditData.fields;
                    this.showProductEDQ = true;
                }


                if (this.caseEditData.project !== undefined && this.caseEditData.project !== null) {
                    this.project = this.caseEditData.project;
                    //this.project = {
                        //id: 'a2B3F000000CaszUAC',
                        //name: 'test prasad'
                    //}
                }


            }
        }).catch(error => {
            console.log("error" + JSON.stringify(error))
                //this.showToast('ERROR', error.body.message, 'error');
            this.error = error;
            console.log("this.error" + JSON.stringify(this.error));
        });


    }*/


    /*get contactVisibleFlag() {
        let flag = false;
        if(this.recordTypeName === "IPS_Case_Create") {
            flag = true;
        }
        return flag;
    } */

    renderedCallback() {
        
        //this.lookupQueryString = 'Select id,' + this.lookupSearchFieldName + ' from contact where Name like :key LIMIT :recordLimit';
        /*this.lookupQueryString = 'SELECT Id, Name FROM Contact WHERE Core_IPS_Active__c=true AND Name LIKE :key LIMIT :recordLimit';
        this.lookupCountQueryStringContact = 'select count() from contact where Name like :key';
        this.isLookupQueryPresent = true;
        this.lookupQueryStringProject = 'select id,' + this.lookupSearchFieldNameProject + ' from core_ips_project__c where Name like :key LIMIT :recordLimit';
        this.lookupCountQueryStringProject = 'select count() from core_ips_project__c where Name like :key';
        this.isLookupQueryPresentProject = true; */
        //this.lookupQueryStringProduct = 'select id,core_supported_product__c,' + this.lookupSearchFieldNameProduct + ' from asset where Name like :key  LIMIT :recordLimit';
        //this.lookupCountQueryStringProduct = 'select count() from asset where Name like :key';
        //this.isLookupQueryPresentProduct = true;
        if (this.initialized) {
            return;
        }
        this.initialized = true;
        //  let listId = this.template.querySelector('datalist').id;
        //  this.template.querySelector("input").setAttribute("list", listId);

        // let listIda = this.template.querySelector('select').id;
        // this.template.querySelector("input").setAttribute("list", listIda);
    }

    formCaseContactLookupQuery() {
        /* SOQL Query
        let querySeleteStr = 'SELECT ';
        this.contactFieldSet = ' FirstName, LastName, Account.Name, AccountId, Account.ownerId, Core_IPS_Intel_Support_Owner__c, Core_MINDS__c, Core_Country_Region__c,  ' 
        let queryFieldsStr = this.contactFieldSet + ' Id, Name ';
        let queryFromObjStr = ' FROM Contact ';
        let queryWhereClause1Str = ' WHERE Core_IPS_Active__c=true AND Name LIKE :key ';
        let queryOrderByClauseStr = ' ORDER BY Name ASC ';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
        if(this.accountList !== undefined && this.accountList !== null && this.accountList !== '' && this.accountList !== '()') {
            queryWhereClause1Str += ' AND AccountId IN ' + this.accountList;
        }
        if(this.caseProjectId !== undefined && this.caseProjectId !== null && this.caseProjectId !== '') {
            if(this.contactLstFromProject !== undefined && this.contactLstFromProject !== null && this.contactLstFromProject !== '' && this.contactLstFromProject !== '()') {
                queryWhereClause1Str += ' AND Id IN ' + this.contactLstFromProject;
            }
        } else if(this.caseProductId !== undefined && this.caseProductId !== null && this.caseProductId !== '') {
            if(this.contactLstFromAsset !== undefined && this.contactLstFromAsset !== null && this.contactLstFromAsset !== '' && this.contactLstFromAsset !== '()') {
                queryWhereClause1Str += ' AND Id IN ' + this.contactLstFromAsset;
            }
        }
        this.lookupQueryStringContact = querySeleteStr + queryFieldsStr + queryFromObjStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr;
        this.lookupCountQueryStringContact = querySeleteStr + ' count() ' + queryFromObjStr + queryWhereClause1Str;
        console.log('this.lookupQueryStringContact ::: ' + this.lookupQueryStringContact);
        this.isLookupQueryPresentContact = true;*/
        /* SOSL Query */
        console.log('inside formCaseContactLookupQuery');
        let soslQuery = ' FIND :key IN ALL FIELDS RETURNING CONTACT ';
        //this.contactFieldSet = ' FirstName, LastName, Account.Name, AccountId, Account.ownerId, Core_IPS_Intel_Support_Owner__c, Core_MINDS__c, Core_Country_Region__c,  ' 
        let queryFieldsStr = this.contactFieldSet + ' Id, AccountId, Account.ownerId, Core_IPS_Intel_Support_Owner__c, Core_MINDS__c, Core_Country_Region__c, Core_IPS_Embargoed_State__c  ';
        let queryWhereClause1Str = ' WHERE Core_IPS_Active__c=true ';
        let queryOrderByClauseStr = ' ORDER BY Name ASC ';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
        if (this.accountList !== undefined && this.accountList !== null && this.accountList !== '' && this.accountList !== '()') {
            queryWhereClause1Str += ' AND AccountId IN ' + this.accountList;
        }
        if (this.caseProjectId !== undefined && this.caseProjectId !== null && this.caseProjectId !== '') {
            if (this.contactLstFromProject !== undefined && this.contactLstFromProject !== null && this.contactLstFromProject !== '' && this.contactLstFromProject !== '()') {
                queryWhereClause1Str += ' AND Id IN ' + this.contactLstFromProject;
            }
        } else if (this.caseProductId !== undefined && this.caseProductId !== null && this.caseProductId !== '') {
            if (this.contactLstFromAsset !== undefined && this.contactLstFromAsset !== null && this.contactLstFromAsset !== '' && this.contactLstFromAsset !== '()') {
                queryWhereClause1Str += ' AND Id IN ' + this.contactLstFromAsset;
            }
        }
        this.lookupQueryStringContact = soslQuery + '( ' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr + ')';
        this.lookupCountQueryStringContact = soslQuery + '( ' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + ')';
        this.isLookupQueryPresentContact = true;
        console.log('ppContLK--'+this.lookupQueryStringContact);
    }

    formCaseProjectLookupQuery() {
        /* SOQL Query
        let querySeleteStr = 'SELECT ';
        this.projectFieldSet = ' Core_IPS_Project_ID__c, Name, ';
        let queryFieldsStr = this.projectFieldSet + ' Id ';

        let queryFromObjStr = ' FROM core_ips_project__c ';
        let queryWhereClause1Str = '  WHERE core_status__c=\'Active\' AND Name LIKE :key ';
        if(this.mode === 'copy' || this.mode === 'edit') {
            queryWhereClause1Str += ' AND Core_IPS_Private__c=false ';   
        }
        let queryOrderByClauseStr = ' ORDER BY Core_IPS_Project_ID__c DESC';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
        if(this.caseContactId !== undefined && this.caseContactId !== null && this.caseContactId !== '') {
            if(this.projectList !== undefined && this.projectList !== null && this.projectList !== '' && this.projectList !== '()') {
                queryWhereClause1Str != ' AND Id IN ' + this.projectList;
            }
        }
        if(this.caseProductId !== undefined && this.caseProductId !== null && this.caseProductId !== ''  
            && (this.caseContactId === undefined || this.caseContactId === null || this.caseContactId === '')){
                if(this.projectLstFromAsset !== undefined && this.projectLstFromAsset !== null && this.projectLstFromAsset !== '' && this.projectLstFromAsset !== '()') {
                    queryWhereClause1Str != ' AND Id IN ' + this.projectLstFromAsset;
                }
        }
        this.lookupQueryStringProject = querySeleteStr + queryFieldsStr + queryFromObjStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr;
        this.lookupCountQueryStringProject = querySeleteStr + ' count() ' + queryFromObjStr + queryWhereClause1Str;
        console.log('this.lookupQueryStringProject ::: ' + this.lookupQueryStringProject);
        this.isLookupQueryPresentProject = true;
        */
        /* SOSL Query */
        let soslQuery = ' FIND :key IN ALL FIELDS RETURNING core_ips_project__c ';
        //this.projectFieldSet = ' Core_IPS_Project_ID__c, Name, ';
        console.log('Anil projectFieldSet', this.projectFieldSet);
        let queryFieldsStr = this.projectFieldSet + ' Id ';
        let queryWhereClause1Str = '  WHERE core_status__c=\'Active\' ';
        if(this.mode === 'copy' || this.mode === 'edit') {
            queryWhereClause1Str += ' AND Core_IPS_Private__c=false ';   
        }
        
        let queryOrderByClauseStr = ' ORDER BY Core_IPS_Project_ID__c DESC';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
        if (this.caseContactId !== undefined && this.caseContactId !== null && this.caseContactId !== '') {
            if (this.projectList !== undefined && this.projectList !== null && this.projectList !== '' && this.projectList !== '()') {
                console.log('1');
                queryWhereClause1Str += ' AND Id IN ' + this.projectList;
            }
            else{
                queryWhereClause1Str += ' AND Id IN (\'\')' ;
            }
        }
        if (this.caseProductId !== undefined && this.caseProductId !== null && this.caseProductId !== '' && this.productid != null && this.productid != undefined &&
            (this.caseContactId === undefined || this.caseContactId === null || this.caseContactId === '')) {
            if (this.projectLstFromAsset !== undefined && this.projectLstFromAsset !== null && this.projectLstFromAsset !== '' && this.projectLstFromAsset !== '()') {
                console.log('2');
                queryWhereClause1Str += ' AND Id IN ' + this.projectLstFromAsset;
            }
        }
        
        this.lookupQueryStringProject = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr + ')';
        this.lookupCountQueryStringProject = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + ')';
        this.isLookupQueryPresentProject = true;
        console.log('shobhit con id--- '+this.caseContactId+'  projectList  '+this.projectList+'  casecontact  '+this.caseProductId);
        console.log('ANil lookupQueryStringProject-- ', this.lookupQueryStringProject);
        console.log('ANil lookupCountQueryStringProject-- ', this.lookupCountQueryStringProject);
    }

    formCaseProductLookupQuery() {
        /* SOQL Query
        let querySeleteStr = 'SELECT ';
        this.assetFieldSet = 'Product2.Name, core_Product_Application__c, Core_IPS_Project_Name__c, AccountId, Core_Code_Name__c, core_ips_project__c,  ';
        let queryFieldsStr = this.assetFieldSet + ' Id, Name ';
        let queryFromObjStr = ' FROM Asset ';
        let queryWhereClause1Str = '  WHERE Status!=\'Inactive\' AND (Name LIKE :key OR Core_Alias__c LIKE :key) ';
        let queryOrderByClauseStr = ' ORDER BY Core_IPS_Support_License__c, Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last,Name ASC';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
        console.log('this.projectList '+this.projectList  );    
        if (this.caseProjectId !== undefined && this.caseProjectId !== null && this.caseProjectId !== '') { //Project ID
            queryWhereClause1Str += ' AND core_ips_project__c = \'' + this.caseProjectId + '\' ';
        } else if (this.caseProjectId === undefined || this.caseProjectId === null || this.caseProjectId === '') {
            let contactAccountProjListfilter = '';
            if (this.caseContactId !== undefined && this.caseContactId !== null && this.caseAccountId !== undefined && this.caseAccountId !== null) {
                contactAccountProjListfilter = ' AND (ContactId = \'' + this.caseContactId + '\' OR AccountId = \'' + this.caseAccountId + '\'';
               if (this.projectList !== undefined && this.projectList !== null && this.projectList !== ''  && this.projectList.length !== 0 && this.projectList !== '()') {
                    contactAccountProjListfilter += ' OR Core_IPS_Project__c  IN ' + this.projectList + ')';
                }
            } 
            queryWhereClause1Str = ' WHERE (Status!=\'Inactive\'' + contactAccountProjListfilter + ' AND (Name LIKE :key OR Core_Alias__c LIKE :key) AND (Core_IPS_Project__c!=null OR RecordType.DeveloperName=\'' + this.publicProductRecTypeName + '\')) OR (Status!=\'Inactive\' ' + contactAccountProjListfilter + ' AND (Name LIKE :key OR Core_Alias__c LIKE :key) AND AccountId !=null AND Core_Supported_Product__r.Core_Flag_Status__c != \'Par Hidden\')';
        }

        this.lookupQueryStringProduct = querySeleteStr + queryFieldsStr + queryFromObjStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr;
        this.lookupCountQueryStringProduct = querySeleteStr + ' count() ' + queryFromObjStr + queryWhereClause1Str;
        console.log('this.lookupQueryStringProduct ::: ' + this.lookupQueryStringProduct);
        this.isLookupQueryPresentProduct = true;
        */
        /* SOSL Query */
        
        if ((this.caseProjectId === undefined || this.caseProjectId === null || this.caseProjectId === '') && this.caseContactId !== undefined && this.caseContactId !== null && 
            this.caseAccountId !== undefined && this.caseAccountId !== null && this.cnt ==1 ) {
                getProductQuery({
                    selectedProjId : this.caseProjectId,
                    selectedAccountId : this.caseAccountId
                })
                    .then(result => {
                       // this.temp = JSON.stringify(result);
                       //let pData = JSON.parse(JSON.stringify(result));
                       if(result!=null){
                           this.currentProductData = JSON.stringify(result);

                       }
                        
                        this.currentProductData = this.currentProductData.replace("[", "(");
                        this.currentProductData = this.currentProductData.replace("]", ")");
                        this.currentProductData = this.currentProductData.replace(/"/g, "'");
                        
                        this.flag = true;
                        this.cnt = this.cnt + 1;
                        if(this.currentProductData!='[]' && this.currentProductData!='()' && this.currentProductData!=''){
                            this.formCaseProductLookupQuery();
                         }
                        
                    })
                    .catch(error => {
                        this.error = error;
                        console.log("this.error" + JSON.stringify(this.error));
                    });
                    
        }   
        let queryWhereClause2Str = '';     
        let soslQuery = ' FIND :key IN ALL FIELDS RETURNING Asset ';
        //this.assetFieldSet = 'Product2.Name, core_Product_Application__c, Core_IPS_Project_Name__c, AccountId, Core_Code_Name__c, core_ips_project__c,  ';
        console.log('Anil assetFieldSet', this.assetFieldSet);
        let queryFieldsStr = this.assetFieldSet + ' Id, Name, core_ips_project__c, Core_Supported_Product__c ';
        let queryWhereClause1Str = '  WHERE Status!=\'Inactive\' ';
        let queryOrderByClauseStr = ' ORDER BY Core_IPS_Support_License__c, Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last,Name ASC';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
        if (this.caseProjectId !== undefined && this.caseProjectId !== null && this.caseProjectId !== '') { //Project ID
            queryWhereClause1Str += ' AND core_ips_project__c = \'' + this.caseProjectId + '\' ';
        } else if (this.caseProjectId === undefined || this.caseProjectId === null || this.caseProjectId === '') {
            let contactAccountProjListfilter = '';
            
            if(this.mode=='edit'||this.mode=='copy'){
            	contactAccountProjListfilter += ' AND Core_IPS_Project__r.Core_IPS_Private__c=false';   
            }
            if (this.caseContactId !== undefined && this.caseContactId !== null && this.caseAccountId !== undefined && this.caseAccountId !== null) {
                //contactAccountProjListfilter = ' AND (ContactId = \'' + this.caseContactId + '\' OR AccountId = \'' + this.caseAccountId + '\'';
                contactAccountProjListfilter += ' AND (RecordType.DeveloperName=\'' + this.publicProductRecTypeName + '\' OR ContactId = \'' + this.caseContactId + '\' OR AccountId = \'' + this.caseAccountId + '\'';
                if (this.projectList !== undefined && this.projectList !== null && this.projectList !== '' && this.projectList.length !== 0 && this.projectList !== '()') {
                    contactAccountProjListfilter += ' OR Core_IPS_Project__c  IN ' + this.projectList + ')';
                } else {
                    contactAccountProjListfilter += ')';
                }
                if(this.currentProductData!='[]' && this.currentProductData!='()' && this.currentProductData!='' && this.flag == true) {
                //if(this.currentProductData!='' && this.flag == true) {    
                    console.log('Inner flag'+this.currentProductData);
                    queryWhereClause2Str = ' AND ID IN ' + this.currentProductData; 
                }
            }
            
            //queryWhereClause1Str = ' WHERE (Status!=\'Inactive\'' + contactAccountProjListfilter + ' AND (Core_IPS_Project__c!=null OR RecordType.DeveloperName=\'' + this.publicProductRecTypeName + '\')) OR (Status!=\'Inactive\' ' + contactAccountProjListfilter + ' AND AccountId !=null AND Core_Supported_Product__r.Core_Flag_Status__c != \'Par Hidden\')';
            queryWhereClause1Str = ' WHERE (Status!=\'Inactive\'' + contactAccountProjListfilter + ' AND (Core_IPS_Project__c!=null OR RecordType.DeveloperName=\'' + this.publicProductRecTypeName + '\')) OR (Status!=\'Inactive\' ' + contactAccountProjListfilter + queryWhereClause2Str + ')';
            //queryWhereClause1Str = ' WHERE (Status!=\'Inactive\'' + contactAccountProjListfilter + ' AND (Core_IPS_Project__c!=null OR RecordType.DeveloperName=\'' + this.publicProductRecTypeName + '\')) OR (Status!=\'Inactive\' ' + contactAccountProjListfilter ;
           // queryWhereClause1Str = ' WHERE (Status!=\'Inactive\'' + contactAccountProjListfilter + ' AND (Core_IPS_Project__c!=null OR RecordType.DeveloperName=\'' + this.publicProductRecTypeName + '\')) OR (Status!=\'Inactive\' ' + contactAccountProjListfilter + queryWhereClause2Str + ')';
            
        }
        this.lookupQueryStringProduct = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr + ')';
        this.lookupCountQueryStringProduct = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + ')';
        this.productFocusAreaLabel = "core_Product_Application__c";
        this.isLookupQueryPresentProduct = true;
        console.log('ppProductLK-'+this.lookupQueryStringProduct);
    }
    formCaseSupportedProdLookupQuery(){
        let soslQuery = 'FIND :key IN ALL FIELDS RETURNING Core_IPS_Supported_Product__c ';
        let queryFieldsStr =  this.supportedProductFieldSet;
        let queryWhereClause1Str ='Core_Supported_Product_Name__c, Id WHERE Core_EOIS__c != True AND Core_Flag_Status__c != \'Par Hidden\'';
        let queryOrderByClauseStr = ' ORDER BY Name ASC ';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
        this.lookupQueryStringProduct = soslQuery + '( ' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr + ')';
        this.lookupCountQueryStringProduct = soslQuery + '( ' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + ')';
        //this.SAPisLookupQueryPresent = true;
        if(this.mode=='create'){
             this.lookupSearchFieldNameProduct = "Core_Supported_Product_Name__c";
        }
        this.productFocusAreaLabel = "Core_Product_Application__c";
        this.isLookupQueryPresentProduct = true;
        console.log('ppSuPProductLK-'+this.lookupQueryStringProduct);
    }
    // platform change
    handleChangeplatform(event) {
        this.platformValue = event.detail.value3;
        //  console.log('platformValue>>' + this.platformValue);
    }

    // on PSO Change 
    @track casePSOId;
    
    handlePSOChange(event) {
        this.spinnerOn = true;
        this.casePSOId = event.detail.recordId;
        this.PSOSelected = event.detail.record;
        this.PSOSelected={
            Id: this.casePSOId 
        }
        if(this.casePSOId==undefined){
            this.PSOSelected = null;
        }
        this.PSOQuery=1; 
        this.formCasePSOLookupQuery(); 
        this.getPSAOptions();       
        this.spinnerOn = false;
    }
    @track userData;
    formCasePSOLookupQuery(){
        let soslQuery = 'FIND :key IN ALL FIELDS RETURNING USER ';
        let queryFieldsStr =  ' Id, Name, FirstName, LastName, Email ';
        let queryWhereClause1Str ='';
        let queryOrderByClauseStr = ' ORDER BY Name ASC ';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
          
        let contactid = null;
        let projectid = null;
        if(this.selectedContactRecord!=null && this.selectedContactRecord!=undefined) {
            contactid = this.selectedContactRecord.Id;
        }
        if(this.projectid!=null && this.projectid!=undefined){
            projectid = this.projectid;
        }
        
        if(this.PSOQuery==1){        
        getProductSupportOwner({
            selectedcontId: contactid,
            selectedprojId: projectid,

        })
            .then(result => {
                if(result!=null){
                    this.userData = JSON.stringify(result);
                }
                else{
                    this.userData = '('+ '\''+ '\'' +')'; 
                }
                
                 this.userData = this.userData.replace("[", "(");
                 this.userData = this.userData.replace("]", ")");
                 this.userData = this.userData.replace(/"/g, "'");
                 if(this.userData!=null && this.userData!=undefined && this.userData !='()'){
                    this.PSOQuery+=1;
                    this.formCasePSOLookupQuery();
                 }
                
            })
            .catch(error => {
                this.error = error;
                console.log("this.error" + JSON.stringify(this.error));
            });
        }
        queryWhereClause1Str = ' WHERE Id IN ' + this.userData;
        this.PSOlookupQueryString = soslQuery + '( ' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr + ')';
        this.PSOlookupCountQueryStringUser = soslQuery + '( ' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + ')';
        this.PSOisLookupQueryPresent = true;
        console.log('ppPSOQuery--'+this.PSOlookupQueryString);
    }
    handlePSAChange(event) {
         this.PSASelected = event.target.value;
        if(this.PSASelected == '--None--'){
            this.PSASelected = null;
        }
    }
    getPSAOptions(){  
              
        let contactid= null;
        let projectid= null;
        let PSOId = null;
        /*if(this.caseContactId==null && this.caseContactId==undefined) {
            contactid = this.tempCon;
        }
        else{
            contactid = this.caseContactId;
        }
        if(this.projectid==null && this.projectid==undefined) {
            projectid = this.tempProj;
        }
        else{
            projectid = this.projectid;
        }
        if(this.casePSAId == null || this.casePSAId == undefined){
            PASId = this.tempPSO;
        }
        else{
            PASId = this.casePSAId;
        }*/
        if(this.selectedContactRecord!=null && this.selectedContactRecord!=undefined) {
            contactid = this.selectedContactRecord.Id;
        }
        if(this.projectid!=null && this.projectid!=undefined){
            projectid = this.projectid;
        }
        if(this.PSOSelected!=null && this.PSOSelected!=undefined) {   
            PSOId = this.PSOSelected.Id;
        }
            getPartnerSupportAccount({
                selectedcontId: contactid,
                selectedprojId: projectid,
                selectedPSOId: PSOId
            })
                .then(result => {
                    if (result !== undefined || result !== null) {
                        console.log("this.PSAOptions" + JSON.stringify(result));
                        this.PSAOptions = result;
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.log("this.error" + JSON.stringify(this.error));
                });
    }

    // on contact change
    handleContactChange(event) {
        this.spinnerOn = true;
        this.conid = event.detail.recordId;
        //  console.log('Conid' + JSON.stringify(this.conid));
        this.conid = JSON.stringify(this.conid);
        console.log('Con sho id-- '+this.conid);
        this.selectedContactRecord = event.detail.record;
        this.caseContactId = event.detail.recordId;
        if (this.caseContactId !== undefined && this.caseContactId !== null && this.caseContactId !== '') {
            this.caseAccountId = event.detail.record.AccountId;
        }
        console.log('Contact change-'+this.isLookupQueryPresentContact);
        /*if( contactRecord !== undefined && contactRecord !== null ) {
            if(contactRecord.Core_IPS_Intel_Support_Owner__c !== undefined && contactRecord.Core_IPS_Intel_Support_Owner__c !== null) {
                this.ipsSupportedContact = contactRecord.Core_IPS_Intel_Support_Owner__c;
            }
            
        }*/


        //const returnValue = this.template.querySelector('c-ips-mind-section').getcontactdata('test');
        if (this.conid != null) {
            this.showMindSection = true;
        }
        if (this.conid === undefined) {
            this.showMindSection = false;
        }
        this.cnt = 1;
        
        this.formCaseProjectLookupQuery();
        this.formCaseProductLookupQuery();
        if(this.mode!=null && this.mode!=undefined && this.mode=='edit'){
            this.PSOQuery=1;
            this.formCasePSOLookupQuery();
            //this.getPSAOptions();
        }
        this.spinnerOn = false;
    }

    //on project change
    handleChangeProject(event) {
            this.spinnerOn = true;

            this.projectid = event.detail.recordId;
            this.caseProjectId = event.detail.recordId;
            let projectRecord = event.detail.record;
            if(this.caseProjectId==null || this.caseProjectId == undefined || this.caseProjectId == ''){
                this.caseProjectId = null;
                this.projectid = null;
                this.isSelectedProjectPresent = false;
            }
            //  console.log('projectid' + JSON.stringify(this.projectid));
            //console.log('productid' + this.productid.id);
            if (event.detail.record !== undefined && event.detail.record !== null) {
                this.isPrivateProject = event.detail.record.Core_IPS_Private__c;
            }
            /*
                    getContactSOQL({
                        projectId: this.projectid,
                        assetId: this.productid !== undefined  ? this.productid.id : '',

                    })
                        .then(result => {
                            //  console.log("this.records inside varaints");
                            console.log("this.error" + JSON.stringify(result));
                            if (result !== undefined || result !== null) {
                                this.lookupQueryString = result;
                                console.log(this.lookupQueryString);
                            }
                        })
                        .catch(error => {
                            //this.showToast('ERROR', error.body.message, 'error');
                            this.error = error;
                            console.log("this.error" + JSON.stringify(this.error));
                        });*/
            if (!this.nacRecType) {
                this.formCaseContactLookupQuery();
            }
            if(this.recordTypeName !== undefined && this.recordTypeName !== null && this.recordTypeName == 'Core_IPS_Case_Create_Self_Assigned' && (this.caseProjectId==null || this.caseProjectId == undefined)) {
                this.lookupSearchFieldNameProduct = "Core_Supported_Product_Name__c";
                //this.lookupSearchFieldNameProduct = "Name";
                this.isSAP = true;
                
		if((this.caseProjectId==null || this.caseProjectId == undefined || this.caseProjectId == '') && this.selectedProductRecord!=null && this.selectedProductRecord!=undefined && this.isAssetId){
                    
                    this.projectid = null;
                    this.isAssetId = false;
                    let tempSelectedProductRecord = this.selectedProductRecord;
                    this.selectedProductRecord = null;
                    if(this.mode!=undefined && this.mode!=null && this.mode!='copy' && this.mode!='edit'){
                        this.selectedProductRecord = {
                            Id: tempSelectedProductRecord.Core_Supported_Product__c,
                            Name: tempSelectedProductRecord.Product2.Name
                        }
                    }
                    else{
                        this.selectedProductRecord = {
                            Id: this.passSupportedProductID,
                            Name: tempSelectedProductRecord.Name
                        }
                    }
		        }
                this.formCaseSupportedProdLookupQuery();
            }
            else{    
                this.lookupSearchFieldNameProduct = "Name";
                this.isSAP = false
                this.formCaseProductLookupQuery();
            }   
            if(this.productid!=null && this.productid!=undefined && this.productid!='' &&
                   this.caseContactId!=null && this.caseContactId!=undefined && this.caseContactId!=''){
                this.skipProductChange = false;
                this.showProductInfoDialog = false;
                if(this.caseProjectId==null || this.caseProjectId==undefined || this.caseProjectId==''){
                    this.caseProjectId = null;
                    this.projectid = null;
                    this.isSelectedProjectPresent = false;
                }
                if(this.caseProjectId!=null && this.caseProjectId!=undefined && this.caseProjectId!=''){
                    //this.tempProjectId = this.caseProjectId;
                    this.tempProjectId = projectRecord.Id;
                    this.tempProjectName = projectRecord.Name;
                }
                
		if(this.caseProjectId != null || this.caseProjectId == ' '|| this.caseProjectId == null){
                    
		    getAssetOnProjectChange({
                        selectedProjId: this.caseProjectId,
                        selectedProdId: this.caseProductId,
                        selectedConId: this.caseContactId
                    })
                        .then(result => {
                            if(result=='false'){
                                this.skipProductChange = false;
                                this.showProductInfoDialog = true;
                            }
                            else{
                                this.skipProductChange = true;
                                this.selectedProductRecord = {
                                    Id: result
                                }
                            }
                            
                        })
                        .catch(error => {
                            this.error = error;
                            console.log("this.error" + JSON.stringify(this.error));
                        });
                }
                
            }  
            if(this.mode!=null && this.mode!=undefined && this.mode=='edit'){
                this.PSOQuery=1;
                this.formCasePSOLookupQuery();
                this.getPSAOptions();
            }
            this.spinnerOn = false;
        }
        //on product change
    handleChangeProduct(event) {
        console.log('inside handle change product');
        if(this.isSAP==true){
            this.lookupSearchFieldNameProduct = "Core_Supported_Product_Name__c";
        }
        else{
           this.lookupSearchFieldNameProduct = "Name"; 
        }
        //console.log('PBSFieldName Handle Prod--'+this.lookupSearchFieldNameProduct);
        //this.isLoaded = true;
        this.productid = event.detail.record; // duplicate for now
        this.selectedProductRecord = event.detail.record;
        
        if(this.project!=undefined || this.project!=null)
        console.log('Change FFFProd - projectid' + JSON.stringify(this.project.Id));
        //this.productid = JSON.stringify(this.conid);
        //const returnValue = this.template.querySelector('c-ips-mind-section').getcontactdata('test');
        if (this.productid === undefined || this.productid === null) {
            this.showProductSection = false;
            this.renderProductVariant = false;
            this.renderProductCategory = false;
            this.renderProductSubCategory = false;
            this.capedqsize = '';
            this.platformoptions = '';
            this.categoryoptions = '';
            this.subsCatedqi = [];
            this.savealldataedq = '';
            this.caseCategory = '';
            this.showplatform = false;
            this.productid = undefined;
            this.showProductEDQ = false;
            this.showSubCatEDQ = false;
            this.recordsedq = [];  
            this.caseProductId = null;
        }
        
        if (this.productid != null) {
            
            if(this.isSAP == true){
                this.isAssetId = false;
                this.passSupportedProductID = this.productid.Id;
            }
            else{
               this.isAssetId = true;
               this.passSupportedProductID = this.productid.Core_Supported_Product__c;
            }  
            //console.log('Supported ProdJ - '+ this.productid.Id + this.productid.Core_Supported_Product__c);
            //console.log('Supported Prod - '+this.passSupportedProductID + 'SAP-' + this.isSAP );
            //console.log('Supported Prod Proj--'+ this.productid.Core_IPS_Project__c + this.projectid)
            if (this.passSupportedProductID != null) {
                //console.log("this.passSupportedProductID" + this.passSupportedProductID + this.productid.Core_IPS_Project__c);
                this.showProductSection = true;
            }
            //if(this.productid.core_ips_project__c  !== undefined && this.productid.core_ips_project__c  !== null && this.productid.core_ips_project__c  !== '') {
            //console.log('handleChangeProduct called line 557');
            
            this.project = {
                Id: this.productid.Core_IPS_Project__c,
                Name: this.productid.Core_IPS_Project_Name__c
            }
            this.caseProductId = this.productid.Id;
            if (this.project.Id === undefined || this.project.Id === null || this.project.Id === '') {
                this.isSelectedProjectPresent = false;
            } else {
                this.projectid = this.productid.Core_IPS_Project__c;
                this.isSelectedProjectPresent = true;
                this.tempProjectId = this.productid.Core_IPS_Project__c;
                this.tempProjectName = this.productid.Core_IPS_Project_Name__c;
                this.caseProjectId = this.productid.Core_IPS_Project__c;
            }

            //} else {
            //  this.isSelectedProjectPresent = false;
            //}



            // show variant based on product id
            /* commented by Ganapati
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
                */
               //console.log('shoProductID---'+this.productid.Id);
               //console.log('RECTYPENAME---'+this.recordTypeName);
               if(this.recordTypeName === 'Core_IPS_Case_Create_Self_Assigned'){
                   //console.log('RECTYPENAME-self');
                   //this.displayProdVariant(this.productid.Core_Supported_Product__c, this.recordTypeName);this.productid.Id
                    this.displayProdVariant(this.productid.Id, this.recordTypeName);
               }
                 else{
                     //console.log('RECTYPENAME-case');
                    this.displayProdVariant(this.productid.Id, this.recordTypeName); 
                 }
            // show plaform    
            getPlatfrm({
                    productsId: this.productid.Id,
                    // this.productid.Core_Supported_Product__c,a2E3F0000009LOBUA2 a2E3F0000009LQRUA2

                })
                .then(result => {
                          console.log("inside platform ");
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
                });
            // console.log("Category" + JSON.stringify(this.productid.Core_Supported_Product__c));
            //show category based on supported product/product id
            //console.log('suportShobId--'+this.passSupportedProductID);
            //this.showCaseCategory(this.productid.Core_Supported_Product__c);
            this.showCaseCategory(this.passSupportedProductID);
            /*showCategory({
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
                }); */
                //console.log('ShobhitProductID-- '+this.passSupportedProductID);
            getProductEdqs({
                    //supportedProductId: this.productid.Core_Supported_Product__c,
                    supportedProductId: this.passSupportedProductID,
                    subCategoryid: null,
                    isAgent: this.agentTrack,
                    //  this.productid.Core_Supported_Product__c,a2Eo00000019aP8EAI,a2E3F0000009AVzUAM,a2E3F0000000nnUUAQ
                    // this.productid.Core_Supported_Product__c,a2E3F0000009LOBUA2 a2E3F0000009LQRUA2

                })
                .then(result => {
                    if (result !== undefined || result !== null) {
                        this.recordsedq = result; 
                        console.log('product edq data -->' + JSON.stringify(this.recordsedq));
                        if (this.recordsedq.length > 0) {
                            this.showProductEDQ = true;
                            //this.isLoaded = false;
                            // this.showEDQ = true;

                            //  const haveedq = new CustomEvent("ihaveedq", {
                            //    bubbles: true,
                            //  composed: true,
                            //detail : selectedRecordId
                            //detail: {
                            //  edqsize: this.recordsedq

                            //  }
                            //});
                            //this.dispatchEvent(haveedq);
                        }
                    }
                })
                .catch(error1 => {
                    this.error = error1;
                    if (error1 !== undefined) {
                        console.log("this.edq" + JSON.stringify(error1));
                    }
                });
        }
        if (!this.nacRecType) {
            this.formCaseContactLookupQuery();
        }
        this.formCaseProjectLookupQuery();
        this.spinnerOn = false;
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
        this.setReasonVisibility();
    }
    handleChangecaseSeverityReason(event) {
        this.caseSeverityReason = event.target.value;
    }
    setReasonVisibility() {
            if (this.caseSeverity === 'Critical') {
                this.showPriority = true;
            } else {
                this.showPriority = false;
            }
        }
        //on product variant change
    handleChangeProductVariant(event) {
            //this.value = event.detail.value;
            this.productVariant = event.detail.value;
            // console.log("varaintvalue:" + JSON.stringify(this.value));
        }
        //on  category change
    handleChangeSubCategory(event) {
        // for type head picklist
        this.caseCategory = event.target.value;


        // console.log("label>>>" + event.detail.label);
        // console.log("sub category:" + JSON.stringify(this.caseCategory));
        if (this.caseCategory !== null) {
            this.caseSubCategory = '';
            this.showCaseSubCategory(this.caseCategory);
            /*showsubCategory({
                categorySelected: this.caseCategory,


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
                });*/
        }
    }

    handleChangeRenderSubCategoryedq(event) {
        console.log('prod edq check dcs ', JSON.stringify(this.recordsedq));
        this.caseSubCategory = event.target.value;
        this.showSubCatEDQ = false;
        if (this.caseSubCategory !== null) {
            //this.showSubCatEDQ = false;
            //this.subCatIdPass = this.caseSubCategory;
            //render sub category based edq
            getSubCategoryDetails({
                    supportedProductId: null,
                    subCategoryid: this.caseSubCategory,
                    //'a263F0000003YKoQAM',
                    //this.previousID,
                    isAgent: this.agentTrack,
                    //  this.productid.Core_Supported_Product__c,
                    // this.productid.Core_Supported_Product__c,a2E3F0000009LOBUA2 a2E3F0000009LQRUA2

                })
                .then(result => {
                    if (result !== undefined || result !== null) {
                        console.log('string data '+ JSON.stringify(result));
                        console.log('normal data ', result);
                        // console.log("EDO1" + JSON.stringify(result[0].label));
                        // console.log("EDO2" + result[0].type);
                        this.subsCatedqi = result;
                        let subCateboryEDQ = new Set();
                        let eDQSet = new Set();

                        var i;
                        for (i = 0; i < result.length; i++) {
                            subCateboryEDQ.add(result[i].id);
                        }
                        for (i = 0; i < this.recordsedq.length; i++) {
                            eDQSet.add(this.recordsedq[i].id);
                        }

                        i = 0;
                        var categoryEDQ = [];
                        result.forEach(edq => {
                            if (eDQSet.has(edq.id)) {} else {
                                categoryEDQ.push(result[i]);
                            }
                            i++;
                        });
                        this.subsCatedqi = categoryEDQ;
                        console.log('Anil this.subsCatedqi----' + this.subsCatedqi);
                        if (this.subsCatedqi.length > 0) {
                            this.showSubCatEDQ = true;
                            
                            //this.showProductSection = true;
                            //  this.showcatEDQ = true;
                        }
                        console.log('prod edq data '+JSON.stringify(this.recordsedq));
                        // this.showProductSection = true;
                        // this.error = undefined;
                        /*console.log('inside change sub cat ');
                        let subCatEdq = [];
                        for(let i =0; i<data.length; i++){
                            subCatEdq.push(data[i].id);
                        }
                        let prodEdq = [];
                        for(let j=0; j<this.recordsedq.length; j++){
                            prodEdq.push(this.recordsedq[j].id);
                        }
                        let finalEdqSet = [];
                        for(let k =0; k<data.length; k++){
                            if(prodEdq.includes(data[k].id)){} else {
                                finalEdqSet.push(data[k]);
                            }
                        }
                        console.log('final edq ', finalEdqSet);
                        this.subsCatedqi = finalEdqSet;
                        if(this.subcatrecedqs.length > 0){
                            console.log('inside if condition');
                            this.showSubCatEDQ = true;
                            this.showProductSection = true;
                        }*/
                    }
                })
                .catch(error1 => {
                    this.error = error1;
                    if (error1 !== undefined) {
                        //this.showToast('ERROR', error1.body.message, 'error');
                    }

                });


        }
    }

    /*checkproductedqsize(event) {
        console.log("edqsize event _ " + event);
        this.capedqsize = event.detail.edqsize;
        console.log(this.apedqsize);


    }*/

    handleChangeChild(event) {
        console.log('inside handleChangeChild---');
        var s, c;
        var obj = {};
        var vb;
        //if ((event.detail.vvalue.length === 0 || event.detail.vvalue === null) && (event.detail.rrequired === true)) {
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

        obj.edq = [];
        obj.edq.question = [event.detail.qquestion];
        obj.edq.label = [event.detail.llabel];
        obj.edq.value = [event.detail.vvalue];
        obj.edq.require = [event.detail.rrequired];
        obj.edq.type = [event.detail.ttype];
        //obj.edq.push(event.detail.qquestion, event.detail.llabel, event.detail.vvalue, event.detail.rrequired, event.detail.ttype);
        // var obj = JSON.parse(s);
        //console.log("222>>>" + JSON.stringify(obj.edq.length));
        // console.log("s length" + s.length);

        //if (s.length > 0) {

        this.savealldataedq.push(s);
        //}

        //  this.valCheck = true;



        // if (obj.length > 0) {
        this.myobjectdata.push(obj);
        // }

        console.log('inside this.savealldataedq---' + this.savealldataedq);
        console.log('stringify inside this.savealldataedq---' + JSON.stringify(this.savealldataedq));
        console.log('inside this.myobjectdata---' + this.myobjectdata);


        // ["qquestion".concat(":".concat("'" + event.detail.qquestion + "'")), "llabel".concat(":".concat("'" + event.detail.llabel + "'")), "vvalue".concat(":".concat("'" + event.detail.vvalue + "'")), "rrequired".concat(":".concat("'" + event.detail.rrequired + "'"))]

        //console.log('parse>>parent' + JSON.parse(this.savealldataedq));
        //for (let i = 0; i < this.savealldataedq.length; i++) {
        //    console.log('this.data' + JSON.stringify(this.savealldataedq[i]));
        // }

        // }
    }

    validateedq() {

        //  console.log('val1' + JSON.stringify(this.savealldataedq));
        //  this.trackvalidation = this.savealldataedq.filter(item => item.edq.val === false);

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

    handleIsMinds(event) {
        this.isMindsCase = event.detail.isMinds;
    }
    handleMindsValue(event){
        let selectedValue = event.detail;
        if(selectedValue == 'Yes'){
            this.isMindsCase = true;
        }    
        else{
            this.isMindsCase = false;
        }
    }
    handleCountrySelection(event) {
        this.countrySelected = event.detail.countryName;
        
    }
    handleStateSelection(event) {
       this.stateSelected = event.detail.stateName;
    }

    handleDefaultCountrySelection(event) {
    // Added by Chetan As part of Country field issue in copy case scenario
       if(this.countrySelected == undefined){
            this.countrySelected = event.detail;
        }else{
            let selectedValue = event.detail;
                if(selectedValue == 'Yes'){
                   this.isMindsCase = true;
               }else if (selectedValue == 'No') {
              this.isMindsCase = false;
            } 
        }
    }

    assetCaseCreation(){           
        console.log('inside mode asset cs');      
        if(this.caseProductId!=null && this.caseProductId!=''){
            this.getProjectAsset('productId');
            this.getProjectAsset('projectId');
            this.getProjectAsset('supportedProd');
        }   
    }
    getProjectAsset(msg){
        return getProjectAsset({
           productId : this.caseProductId,
           mode : msg,
        })
        .then(data=>{
            if(msg=='productId'){
              this.assetProdName = data;  
              this.productid = this.caseProductId;
              this.selectedProductRecord = {
                Id: this.productid,
               }
                return getAgent({})
                    .then( data=>{
                        if (data) 
                           this.agentTrack = data
                        })
                    .catch(error=>{ 
                        console.error('Error in loading case severity values. Error : ' + error);
                    })
            }        
            else if(msg=='projectId'){ 
              this.assetProjName = data;   
              this.projectid = this.caseProjectId;
            }
            else if(msg=='supportedProd')  {
              this.assetSupportedProdId = data;
              if(this.assetSupportedProdId!=null){
                   this.showCaseCategory(this.assetSupportedProdId);   
                return getProductEdqs({
                    supportedProductId: data,
                    subCategoryid: null,
                    isAgent: this.agentTrack,
                })
                .then(result => {
                    if (result !== undefined || result !== null) {
                        this.recordsedq = result;
                        console.log('pp this.recordsedq----' + JSON.stringify(this.recordsedq));
                        if (this.recordsedq.length > 0) {
                            this.showProductSection = true;
                            this.showProductEDQ = true;       
                        }
                    }
                })
                .catch(error => {
                        console.log("this.edq" + JSON.stringify(error));
                });

               }
            }
            this.newCase = false;        
        })
        .catch(error=>{
           console.log('error in assetCaseCreation '+error);
        })
    }   

    async saveHandler() {
        this.spinnerOn = true;
        var resultsa;
        this.savealldataedq = [];
        // this.trackvalidation = '';

        this.trackvalidation = [];
        // console.log('check edq size', this.capedqsize.length);


        if (this.showProductEDQ === true) {
            this.template.querySelector('c-core_-i-p-s_dynamicformbuilder[data-id="prodEDQ"]').callhandleQuestionAnswer();
        }
        // this.savealldataedq.splice(this.trackchildataa.length, this.savealldataedq.length);
        //subcategory edq
        if (this.showSubCatEDQ === true) {
            this.template.querySelector('c-core_-i-p-s_dynamicformbuilder[data-id="subCatEDQ"]').callhandleQuestionAnswer();
        }
        /*let tempMinds = this.template.querySelector('c-core_-i-p-s_-m-i-n-d_-section').handleMindsValue();
        console.log('MINDSVALUETEMP--'+tempMinds);
        console.log('MINDSVALUETEMP1--'+JSON.stringify(tempMinds));*/
        //this.addEventListener('inselectedquestionanswer', this.handleChangeChild.bind(this));
        //this.template.querySelector('c-show-dynamicedq-section').callhandleQuestionAnswer();
        //  console.log('dat1' + JSON.stringify(dat));
        //  console.log('dat' + dat);
        //callhandleQuestionAnswer();

        await this.validateCaseForm();
        this.validateedq();
        if (this.isValid && this.valCheck) {
            this.isLoaded = true;

            var caseObj = {

                    Core_IPS_Customer_Visible__c: this.customerVisible,
                    Core_IPS_Project_Case__c: this.projectid,
                    ContactId: (this.isPrivateProject) ? null : (this.selectedContactRecord !== undefined && this.selectedContactRecord !== null) ? this.selectedContactRecord.Id : null,
                    AccountId: (this.isPrivateProject) ? null : (this.selectedContactRecord !== undefined && this.selectedContactRecord !== null) ? this.selectedContactRecord.AccountId : null,
                    AssetId: (this.selectedProductRecord !== undefined && this.selectedProductRecord !== null && this.isAssetId==true) ? this.selectedProductRecord.Id : '',
                    Core_IPS_Supported_Product__c: (this.selectedProductRecord !== undefined && this.selectedProductRecord !== null && this.isAssetId==false) ? this.selectedProductRecord.Id : '',
                    Subject: this.caseSubject,
                    Core_Issue_Description__c: this.caseDescription,
                    Core_Severity__c: this.caseSeverity,
                    // Description: '', //to be handled in apex controller cs.Description = Core_Utility.replaceHtmlTags(strDescValue); 
                    Core_IPS_Issue_source__c: this.caseSource,
                    Core_CaseType__c: this.caseType,
                    Core_Severity_Reason__c: this.caseSeverityReason,
                    // invalid cross ref id
                    Core_Case_Issue_Category__c: (this.caseCategory !== undefined && this.caseCategory !== null) ? this.caseCategory : null,
                    Core_Case_Issue_Sub_Category__c: (this.caseSubCategory !== undefined && this.caseSubCategory !== null) ? this.caseSubCategory : null,

                    Core_IPS_Supported_Contact__c: (this.isPrivateProject) ? (this.selectedContactRecord !== undefined && this.selectedContactRecord !== null) ? this.selectedContactRecord.Id : null : null,
                    // edit not working 
                    //Core_Intel_Sup_Owner__c: (this.selectedContactRecord !== undefined && this.selectedContactRecord !== null) ? this.selectedContactRecord.Account.OwnerId : null, // contact.acccount.ownerId
                    Core_Intel_Sup_Owner__c: (this.selectedContactRecord !== undefined && this.selectedContactRecord !== null) ? this.selectedContactRecord.IntelSupportOwner : null,
                    Core_IPS_Country_Region__c: this.countrySelected, // minds country
                    Core_IPS_Embargoed_State__c: this.stateSelected, // minds state
                    
                    Core_IPS_Partner_Sup_Owner__c: (this.PSOSelected !== undefined && this.PSOSelected !== null) ? this.PSOSelected.Id : '',//.PSOSelected.Id,//selectedPSOId, 
                    Core_IPS_Minds__c: this.isMindsCase, // minds options
                    Core_IPS_Self_Assigned__c: this.selfAssigned, //if NAC then true
                    Core_Partner_Supported_Account__c: this.PSASelected, //selected account is not blank
                    Core_Product_Variant__c: this.productVariant,

                    // Core_Partner_Supported_Account__c: '', //selectedPSA,
                    Core_Platform_Name__c: this.platformValue,
                    Core_End_Customer__c: this.endCustomerEdit,
                    Core_Customer_Reference_ID__c: this.customerRefIdEdit
                }
                /*
                if(this.mode!=='edit') {
                    caseObj.Core_Intel_Sup_Owner__c = (this.selectedContactRecord !== undefined && this.selectedContactRecord !== null) ? this.selectedContactRecord.Account.OwnerId : null,
                }*/

            if (this.caseEditData !== undefined && this.caseEditData !== null && this.caseEditData.cs !== null) {
                // only case create
                if (this.mode === 'copy') {
                    //caseObj.Id = '';
                    caseObj.Core_IPS_Classification__c = this.caseEditData.cs.Core_IPS_Classification__c;
                    caseObj.Core_IPS_Partner_Sup_Owner__c = this.caseEditData.cs.Core_IPS_Partner_Sup_Owner__c;
                    caseObj.Core_Partner_Supported_Account__c = this.caseEditData.cs.Core_Partner_Supported_Account__c;
                    if (this.caseEditData.cs.Status === 'Closed') {
                        caseObj.RecordTypeId = this.ipsCreateRecordId;
                    } else {
                        caseObj.RecordTypeId = this.caseEditData.cs.RecordTypeId;
                    }
                    caseObj.ParentId = this.caseEditData.cs.Id;
                    caseObj.Core_IPS_Restricted_Secret_Content__c = this.caseEditData.cs.Core_IPS_Restricted_Secret_Content__c;
                    //caseObj.Priority = this.caseEditData.cs.Priority;
                    //caseObj.Core_IPS_Priority_Reason__c = this.caseEditData.cs.Core_IPS_Priority_Reason__c;
		     /*By Tejaswini H TWC745-6588: Empty Case Origin issue Sept 23, 2024. Case copy Internal*/
                    caseObj.Origin = 'Web';
                    /*End By Tejaswini H TWC745-6588: Empty Case Origin issue Sept 23, 2024. Case copy Internal*/
                } else {
                    caseObj.Id = this.caseEditData.cs.Id;
                }


            } else { // execute when case create 
                caseObj.Origin = 'Web';
                caseObj.Status = 'New';
                caseObj.Core_Sub_Status__c = '';
                caseObj.RecordTypeId = this.recordTypeId;

            }
            var strEdq = JSON.stringify(this.savealldataedq);
            console.log("Handlesave method called--" + strEdq);
            SubmitCaseRecord({ newRecord: caseObj, contactRecord: this.selectedContactRecord, CaseEDQData: strEdq })
                .then(result => {
                    if (result !== undefined || result !== null) {
                        if (this.recordId === null || this.recordId === undefined || this.mode === 'copy') {
                            this.showToast('Success', 'Case has been created.', 'success');
                        } else {
                            this.showToast('Success', 'Case has been updated.', 'success');
                        }
                        this.recordId = result.Id;

                        if (this.mode === 'copy') {
                            copyInterestedParties({ parentCaseId: this.caseEditData.cs.Id, caseId: result.Id })
                                .then(result1 => {
                                    console.log(' InterestedParties Copied successfully.');
                                })
                                .catch(error1 => {
                                    console.error('Error in copying InterestedParties. ', error1);
                                })
                        }

                        this.navigateToViewCase();
                    }
                    this.isLoaded = false;
                })
                .catch(error => {
                    this.isLoaded = false;
                    this.showToast('ERROR', error.body.message, 'error');
                    console.log('Error in SubmitCaseRecord ', error, JSON.stringify(error));

                });
            /*
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
                            caseCategory: this.caseCategory,
                            caseSubCategory: this.caseSubCategory,
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

            */
            /* const fields = {'Core_CaseType__c' : this.caseType,
                 'Core_IPS_Supported_Contact__c' : this.conid,
                'Core_IPS_Project_Case__c' : this.projectid,
                 'Core_IPS_Product__c' : this.productid.Id,
                 'Core_IPS_Issue_source__c' : this.caseSource,
                 'Core_Severity__c' : this.caseSeverity,
                 'Subject' : this.caseSubject,
                 'Core_Issue_Description__c' : this.caseDescription,
                 'Core_Case_Issue_Category__c' : this.caseCategory,
                 'Core_Case_Issue_Sub_Category__c': this.caseSubCategory};
     
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
        this.spinnerOn = false;
    }

    getErrMessage(errCode) {
        getErrorMessage({ errorCode: errCode })
            .then(res => {
                //return res;
                this.showToast('ERROR', res, 'error');
            }).catch(err => {
                console.error('Error in loading error message');
            })
    }

   async validateCaseForm() {
        //alert(' this.productid  '+this.productid );
        console.log('ShoCategory-->'+this.caseCategory);
        console.log('ShobCaseSubCategory-->'+this.caseSubCategory);
        console.log('shobsubcategorylength-->'+this.subcategoryoptions.length);
        if (this.conid === undefined && !this.nacRecType) {
            this.getErrMessage('I103');
            //this.showToast('ERROR', contectErrorMessage, 'error');
            this.isValid = false;
        } else if (this.productid === undefined) {
            this.getErrMessage('I102');
            //this.showToast('ERROR', productErrorMessage, 'error');
            this.isValid = false;
        } else if ((this.conid !== null && this.conid === '') && (this.productid !== null && this.productid === '')) {
            this.getErrMessage('I101');
            //this.showToast('ERROR', contAndProdErrorMessage, 'error');
            this.isValid = false;
        } else if ((this.conid !== null && this.conid === '')) {
            //this.getErrMessage('I103');
            this.showToast('ERROR', contactIdErrorMessage, 'error');
            this.isValid = false;
        } else if ((this.productid !== null && this.productid === '')) {
            //this.getErrMessage('I101');
            this.showToast('ERROR', productIdErrorMessage, 'error');
            this.isValid = false;
        } else if(this.countrySelected === undefined || this.countrySelected === '') {
              this.showToast('ERROR', 'Please select country', 'error');
              this.isValid = false;
        
        } else if (this.caseSource === undefined || this.caseSource === '') {
            this.getErrMessage('G120');
            //this.showToast('ERROR', caseErrorMessage, 'error');
            this.isValid = false;
        } else if (this.caseType === undefined || this.caseType === '') {
            this.getErrMessage('G109');
            //this.showToast('ERROR', caseTypeErrorMessage, 'error');
            this.isValid = false;
        } else if (this.caseSubject === undefined || this.caseSubject === '') {
            this.getErrMessage('G102');
            //this.showToast('ERROR', caseSubjectErrorMessage, 'error');
            this.isValid = false;
        } else if (this.caseDescription === undefined || this.caseDescription.trim() === '') {
            this.getErrMessage('G103');
            //this.showToast('ERROR', caseDescErrorMessage, 'error');
            this.isValid = false;
        } else if (this.caseSeverity === undefined || this.caseSeverity === '') {
            this.getErrMessage('G104');
            //this.showToast('ERROR', caseSeverityErrorMessage, 'error');
            this.isValid = false;
        } else if ((this.categoryoptions !== null && this.categoryoptions.length >= 1) && (this.caseCategory === null || (this.caseCategory !== null && this.caseCategory === '') || this.caseCategory == undefined)) {
            this.getErrMessage('G100');
            //this.showToast('ERROR', caseCategoryErrorMessage, 'error');
            this.isValid = false;
        } else if ((this.subcategoryoptions !== null && this.subcategoryoptions.length >= 1) && (this.caseSubCategory === null || this.caseSubCategory === undefined || (this.caseSubCategory !== null && this.caseSubCategory === ''))) {
            this.getErrMessage('G101');
            //this.showToast('ERROR', CaseSubCategoryErrorMessage, 'error');
            this.isValid = false;
        } 
        else if(this.isCustomerVisibleTrue && !this.customerVisible && this.mode!=null && this.mode!= undefined && this.mode == 'edit'){
            this.dispatchEvent(new ShowToastEvent({
                message: 'Cannot hide Case from Customer if already visible',
                variant: 'warning',
            }));
            this.isValid = false;
        } 
        else {
	    try{
            
	        await validateBeforeSubmitCase({
                        selectedProductId: this.selectedProductRecord?.Id, //this.productid.Id,
                        selectedProjectId: this.projectid,
                        selectedContacttId: this.selectedContactRecord?.Id,
                        caseRecordType: this.recordTypeName
                    }).then(result => {
                        if(result === 'true'){
            this.isValid = true;
        }
                        else {
                            this.showToast('ERROR', result, 'error');
                            this.isValid = false;
                        }
                    })
                    .catch(error => {
                        console.log("Error in Validating Lookup... ", error);
                    });
            }catch(e){
                console.error('error in validate before case submit ' + e);
            }
        }

    }
    cancelHandler() {
        this.openConfirmPopup = true;
    }
    handleTrue() {
        this.openConfirmPopup = false;
           
        if (this.mode === 'copy' || this.mode === 'edit') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view'
                }
            });
        } 
        else if(this.mode=='asset'){
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Asset',
                    actionName: 'list'
                },
                state: {
                    filterName: 'Recent'
                },
            });    
        }
        else{
            /*this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Case',
                    actionName: 'list'
                },
                state: {
                    filterName: 'Recent'
                },
            });*/
            window.location.href = navigateToCaseRecentList;
        }
    }
    handleFalse() {
        this.openConfirmPopup = false;
    }
    handleRemoveProject(){
        this.showProductInfoDialog = false;
        if(this.mode != null && this.mode != undefined && this.mode == 'create' &&
            this.tempProjectId != null && this.tempProjectId != undefined && this.tempProjectId != '' ){
                //this.template.querySelector('c-core_-i-p-s_-custom-lookup[data-id="project"]').removeSelected();.
            if(this.projectid !=null && this.projectid != undefined ){
                
                this.projectid = null;
                this.project =null;
                this.template.querySelector('c-core_-i-p-s_-custom-lookup[data-id="project"]').removeSelected();
            }
            else{  
                   
              this.projectid = this.tempProjectId;
            }
           // this.asset.Id = this.selectedProductRecord.Id
            this.isSelectedProjectPresent = true;
            
        }
        else if(this.project.Id !=null && this.project.Id != undefined ){
            
            this.projectid = this.project.Id;
            this.selectedProductRecord.Id = this.asset.Id;
            this.isSelectedProjectPresent = true;
        }
        else{   
             
            this.template.querySelector('c-core_-i-p-s_-custom-lookup[data-id="project"]').removeSelected();
            //this.projectid = null;  
        }
        
    }
    handleRemoveProduct(){
        if(this.mode != null && this.mode != undefined && this.mode == 'create' &&
            this.tempProjectId != null && this.tempProjectId != undefined && this.tempProjectId != '' ){
            //this.template.querySelector('c-core_-i-p-s_-custom-lookup[data-id="project"]').removeSelected();.
            this.projectid = this.tempProjectId;
            this.project = {
                Id: this.tempProjectId,
                Name : this.tempProjectName
            }    
           // this.asset.Id = this.selectedProductRecord.Id
            this.isSelectedProjectPresent = true;
            
        }
        this.showProductInfoDialog = false;
        this.selectedProductRecord = {
            Id: '',
            Name: ''
        }
        //this.caseProductId = null;
        this.template.querySelector('c-core_-i-p-s_-custom-lookup[data-id="product"]').removeSelected();
        this.caseCategory = null;
                this.caseSubCategory = null;
        this.productVariant = null;
                this.showSubCatEDQ = false;
                this.showProductEDQ = false;
        this.savealldataedq = null;
       
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

    displayProdVariant(productId, recordTypeName) {
        console.log('Prod Variant --'+productId);
        this.renderProductVariant = false;
        // Added by Ganapati
        displayProductVariant({
                selectedProductId: productId,
                recordTypeName: recordTypeName
            }).then(prodVarResult => {
                let keys = Object.keys(prodVarResult);
                let options = [];
                for (let i = 1; i < keys.length; i++) {  
                    let option = { label: keys[i], value: prodVarResult[keys[i]] };
                    options = [...options, option];
                    
                }
                this.records = options;
                if (keys !== undefined && keys !== null && keys.length > 0) {
                    if(keys.length ==1 && keys == '--Select--'){
                        this.renderProductVariant = false;
                    }
                    else{
                        this.renderProductVariant = true;
                    }
                }
            })
            .catch(prodVarError => {
                console.log("Error in loading Product variant ... ", prodVarError);
            });
    }

    showCaseCategory(prodId) {
        console.log("cateory-pp1"+ prodId);
        showCategory({
                supportedProductId: prodId,
            })
            .then(result => {
                console.log("cateory-pp2");

                if (result !== undefined || result !== null) {
                    console.log("this.categoryoptions" + JSON.stringify(result));

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
            });
    }

    showCaseSubCategory(caseCategory) {
        showsubCategory({
                categorySelected: caseCategory,


            })
            .then(result => {
                if (result !== undefined || result !== null) {
                    //  console.log("this.subcategoryoptions" + JSON.stringify(result));

                    this.subcategoryoptions = result;

                    // this.error = undefined;
                    if (this.subcategoryoptions.length > 0) {
                        this.renderProductSubCategory = true;
                    } else {
                        this.renderProductSubCategory = false;
                    }


                }
            })
            .catch(error => {
                this.error = error;
                //  this.showToast('ERROR', error.body.message, 'error');
                console.log("this.error" + JSON.stringify(this.error));
            });
    }

    handlecustomerrefidchange(event) {
        this.customerRefIdEdit = event.detail.value;
    }

    handleendcustomerchange(event) {
        this.endCustomerEdit = event.detail.value;
    }
    handleDefaultstateSelection(event){
        console.log('get event',event.detail);
    }
}