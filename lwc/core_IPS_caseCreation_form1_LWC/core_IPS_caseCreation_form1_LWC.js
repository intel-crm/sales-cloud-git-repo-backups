import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';
import getProductVariants from '@salesforce/apex/Core_IPS_AdminUtility.getProductVariants';
import getCategoryOptions from '@salesforce/apex/core_IPS_caseCreate_LEX.getCaseCategories';
import getSubCategoryOptions from '@salesforce/apex/core_IPS_caseCreate_LEX.getCaseSubCategories';
import getProdEdq from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getProductEDQ";
import getSubCatEdq from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getSubCatProductEDQ";
import projectNote from '@salesforce/label/c.Core_IPS_Project_Note_Portal';
import showsubCategory from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getSubCategoryDetail";
import getLoggedInContacts from "@salesforce/apex/core_IPS_caseCreate_LEX.getContactDetails";
import getCustomSettingLogs from '@salesforce/apex/Core_IPS_CaseCreateMode_CTRL.getCustomSettingLogs'; //added by Anil as part of MOde SSLC
import getContactRecords from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getContactRecords";
import { loadStyle } from 'lightning/platformResourceLoader';
import COLORS from '@salesforce/resourceUrl/portalDataTableColors';
import getcurrentuserprofile from '@salesforce/apex/Core_IPS_TestAllRecords.getcurrentuserprofile';
import Core_Country_Region__c from '@salesforce/schema/Contact.Core_Country_Region__c';
import STATE from '@salesforce/schema/Contact.Core_IPS_State__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Contact from '@salesforce/schema/Contact';
import Core_IPS_CommEmailOptController from '@salesforce/apex/Core_IPS_PrefPage_CTRL.Core_IPS_CommEmailOptController';
import getcountryfields from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getcountryfields";
import getSupportedProd from "@salesforce/apex/core_IPS_caseCreate_LEX.getSupportedProd";
import EdqAlign from '@salesforce/resourceUrl/EdqAlignment';
import Core_IPS_Required from '@salesforce/label/c.Core_IPS_Required';
import validateProduct from "@salesforce/apex/Core_IPS_BugAssistController.validateProductOrg"; // Added by Siddardha Soma as part of BugAssist
import bugAssistSupportedProducts from '@salesforce/label/c.Core_IPS_Bug_Assist_Supported_Products'; // Added by Deepaksai as part of BugAssist
import validateBugAssistProd from '@salesforce/apex/Core_IPS_BugAssistController.validateBugAssistProd';  // Added by Deepaksai as part of BugAssist
import getProductOrgName from '@salesforce/apex/Core_IPS_BugAssistController.getProductOrgName';


const contactColumns = [
{ label: 'First Name', fieldName: 'FirstName', type: 'text', sortable: 'true' },
{ label: 'Last Name', fieldName: 'LastName', type: 'text', sortable: 'true' },
{ label: 'Email', fieldName: 'Email', type: 'text', sortable: 'true' },
];
export default class Core_IPS_caseCreation_form1_LWC extends NavigationMixin(LightningElement) {
    //START - Added by Deepaksai & Hassan as part of BugAssist
    isBugAssistTrue = false;
    isBugAssistProduct = false;
    isSubjectEntered = false;
    isBugAssistResponseReceived = false;
    bugAssistData;
    subjectForBugAssist='';
    // END - BugAssist

communityCheck = true;
fieldName;
showVariants = false;
showCategories = false;
showSubCategories = false;
showEDQsection = false;
showProdEdqs = false;
showSubCatEdqs = false;
showEdqSection = false;
projectRecords;
productOptions = [];
tempProductOptions = [];
productVariantOptions = [];
caseCategoryOptions = [];
caseSubCategoryOptions = [];
selectedProjectName = '';
selectedProductName = '';
selectedVariantName = '';
prodEdqRecs;
subCatRecEdqs;
isProjSelected = false;
projSelectByProd = false;
isProdSelected = false;
value = 'inProgress';
label = {
     projectNote,
     Core_IPS_Required
 };
@track selectedCountryValue;
@api records;
@api project;
@api productvariant;
@track stateList = [];
@track stateFieldData;
@track showState = false;
@track statedefaultvalue;
@api product;
@api subject;
@api CaseCategory;
@api Language;
@api CaseSubCategory;
@api casedata; // data comes from Parent cmp
@api projectdata; // data comes from Parent cmp
@api premiersupportprojectdata; // data comes from Parent cmp
@api storecaseinfofromParent;
@api CaseSubCategoryId;
@api CaseSubCategoryName;
@api CaseCategoryId;
@api CaseCategoryName;
//for product lookup
@track lookupSearchFieldNameProduct = "Name";
@track error;
@track products = [];
@api contactData;
@api contactCountry;
@api accountId;
@api contactId;
@api mode;
@api createmode = false;
@api sslcmode = false;
value = this.contactCountry;
@api agentCheck;
@api renderProductSubCategory = false;
options = [];
selectedValue;
storeData;
@track selectedValuecountry = '';
@track passSupportedProductID;
@track mindsValue;
@track prodDisable = null;
@track projDisable = null;
isRequiredCountry=false;
isRequiredProject=false;
isRequiredProduct=false;
isRequiredCategory=false;
isRequiredSubcategory=false;
isRequiredSubject=false;
isRequiredState=false;
notApp = { Name: 'Not Applicable' };
@api sstLogValueTF;
connectedCallback() {
    loadStyle(this, EdqAlign);
    if (JSON.stringify(this.casedata) === '{}') {
    } 
    else {
        let tempCaseDataAssign = JSON.parse(JSON.stringify(this.casedata));
        this.selectedValuecountry = tempCaseDataAssign.country;

        this.premiersupportprojectdata = {
            Id: tempCaseDataAssign.project,
            Name: tempCaseDataAssign.projectName
        };
        if(this.premiersupportprojectdata!=undefined || this.premiersupportprojectdata!=null || this.premiersupportprojectdata!=''){
            this.caseProjectId = this.premiersupportprojectdata.Id;  
        }
        this.projectdata = {
            Id: tempCaseDataAssign.Product,
            Name: tempCaseDataAssign.ProductName
        };
        
        this.sendcaseproductvariant = tempCaseDataAssign.productvariantName;
        this.productVariantOptions = tempCaseDataAssign.productVariantOptions;

        this.caseCategory = tempCaseDataAssign.CategoryName;
        this.caseCategoryOptions = tempCaseDataAssign.CategoryOptions;

        this.caseSubCategory = tempCaseDataAssign.SubCategoryName;
        this.subcategoryoptions = tempCaseDataAssign.SubCategoryOptions;
        if (this.caseCategoryOptions) {
            this.renderProductCategory = true;
        }
        if (this.subcategoryoptions) {
            this.renderProductSubCategory = true;
        }
        if (this.productVariantOptions) {
            this.renderProductVariant = true;
        }
        this.sendcasesubject = tempCaseDataAssign.Subject;
        this.CaseCategoryId = tempCaseDataAssign.CategoryId;
        this.projectid = tempCaseDataAssign.project;
        this.selectedProjectName = tempCaseDataAssign.projectName;
        this.productvariant = tempCaseDataAssign.productvariant;
        this.selectedVariantName = tempCaseDataAssign.productvariantName;
        this.product = tempCaseDataAssign.Product;
        this.selectedProductName = tempCaseDataAssign.ProductName;
        this.CaseCategoryName = tempCaseDataAssign.CategoryName;
        this.caseCategoryOptions = tempCaseDataAssign.CategoryOptions;
        this.CaseSubCategoryId = tempCaseDataAssign.SubCategoryId;
        this.CaseSubCategoryName = tempCaseDataAssign.SubCategoryName;
        this.subcategoryoptions = tempCaseDataAssign.SubCategoryOptions;
        this.subject = tempCaseDataAssign.Subject;
        this.Language = tempCaseDataAssign.language;
        this.prodEdqRecs = tempCaseDataAssign.prodEdqRecs;
        this.showProdEdqs = tempCaseDataAssign.showProdEdqs;
        this.showEdqSection = tempCaseDataAssign.showEdqSection;
        this.contactId = tempCaseDataAssign.contactId;
        this.accountId = tempCaseDataAssign.accountId;
        this.passSupportedProductID = tempCaseDataAssign.passSupportedProductID;
        this.agentCheck = tempCaseDataAssign.isAgent;
        this.selectedValuecountry = tempCaseDataAssign.country;
        this.mindsValue = tempCaseDataAssign.mindsValue;
        this.renderProductCategory = tempCaseDataAssign.renderProductCategory;
        this.renderProductSubCategory = tempCaseDataAssign.renderProductSubCategory;
        this.sstLogvalueTF = tempCaseDataAssign.sstLogvalueTF; // Added by Deepaksai as part of BugAssist
        //START Added By Hassan Khan for Bank & Forth logic from different forms as part of BugAssist.
        if(tempCaseDataAssign.sstLogvalueTF === true || (tempCaseDataAssign.sstLogvalueTF === false && (tempCaseDataAssign.selectedReason !== null || tempCaseDataAssign.selectedReason !== undefined || tempCaseDataAssign.selectedReason !== ''))){ // Modified by Deepaksai as part of BugAssist 
            this.isSubjectEntered = tempCaseDataAssign.isSubjectEntered;
            this.isBugAssistProduct = tempCaseDataAssign.isBugAssistProduct;
            this.bugAssistData = {
                "sstLogvalueTF": tempCaseDataAssign.sstLogvalueTF,
                "selectedReason": tempCaseDataAssign.selectedReason,
                "attachedUrl" : tempCaseDataAssign.attachedUrl,
                "uploadedFileName": tempCaseDataAssign.uploadedFileName,
                "bugAssistRecordId": tempCaseDataAssign.bugAssistRecordId,
                "subject":tempCaseDataAssign.subjectForBugAssist
            };
            this.isBugAssistTrue = tempCaseDataAssign.isBugAssitCase;
            this.attachedUrl = tempCaseDataAssign.attachedUrl;
            this.sstLogValueTF = tempCaseDataAssign.sstLogvalueTF;
            this.selectedReason = tempCaseDataAssign.selectedReason;
            this.uploadedFileName = tempCaseDataAssign.uploadedFileName;
            this.bugAssistRecordId = tempCaseDataAssign.bugAssistRecordId;
        } else {
            this.bugAssistData = {
                "subject":tempCaseDataAssign.subjectForBugAssist
            }
        }
        //End - BugAssist

        if (this.product) {
            this.projSelected = true;
        }
            
    }

    let testURL = window.location.href;
    let newURL = new URL(testURL).searchParams;
    this.mode = newURL.get('mode');
    if (this.mode === 'create') {
        this.createmode = true;
        this.sslcmode = false;
        this.projectFieldSet = "name,Core_IPS_Project_ID__c,";
        let testURL = window.location.href;
        let newURL = new URL(testURL).searchParams;
        //----START ---- Added by Siddardha Soma as part of BugAssist
        let productId = newURL.get('assetId');
        validateProduct({
                recordId: productId
            })
                .then((result) => {
                    if (result != '' && result !=null && result === true ){
                    this.isBugAssistProduct = true;
                    }
                    
                }).catch((error) => {
                    this.error = error;
                });
 
        //----End ---- Added by Siddardha Soma as part of BugAssist
        
        if (newURL.get('assetId') != null) {
            this.product = newURL.get('assetId');
            this.projSelected = true;
                this.prodDisable = true;
                if (newURL.get('premiersupprojrojId') != null) {
                } 
                else{
                    this.premiersupportprojectdata = {
                        Id: '',
                        Name: 'Not Applicable'
                    };
                    this.selectedProjectName = 'Not Applicable';
                    this.projDisable = true;
                }
        }
        if (newURL.get('assetName') != null) {
            this.selectedProductName = newURL.get('assetName');
            this.projSelected = true;
        }
        if (newURL.get('premiersupprojrojId') != null) {
            this.projectid = newURL.get('premiersupprojrojId');
            this.projSelected = true;
            this.projDisable = true;
        }
        if (newURL.get('premiersupprojrojName') != null) {
            this.selectedProjectName = newURL.get('premiersupprojrojName');
             this.projSelected = true;
        }
        this.getUserProfile();
        if ((this.product != null || this.product != undefined)){// && (this.projectid != null || this.projectid != undefined)) {
            
            this.sendDataToParent(event);
            this.getProdVariants(this.product);
            getSupportedProd({
                assetID: this.product
            })
                .then((result) => {
                    if (result) {
                        
                        let tempsupportId = result;
                        this.passSupportedProductID = tempsupportId;
                        this.getCatergories(tempsupportId);
                        this.getProductEdqs(tempsupportId);
                    }
                }).catch((error) => {
                    this.error = error;
                });
        }
        
        //this.getUserProfile();
        
        this.formCaseProjectLookupQuery();
        this.formCaseProductLookupQuery();
        

    } else if (this.mode === 'sslc') {
        this.createmode = false;
        this.sslcmode = true;
        this.handleLoad();
    }
    getLoggedInContacts({})
        .then((result) => {
            this.contactData = result;
            this.contactCountry = this.contactData[0].Core_Country_Region__c;
            this.selectedValuecountry = this.contactData[0].Core_Country_Region__c;
            this.contactId = this.contactData[0].Id;
            this.accountId = this.contactData[0].AccountId;
            this.statedefaultvalue = this.contactData[0].Core_IPS_Embargoed_State__c;
            if(this.statedefaultvalue != undefined) {
                this.showState = true;
            }
        })
        .catch((error) => {
            console.log(error);
            this.error = error;
        });

    this.getContacts();
    this.getcountryvalues();

}
isCssLoaded = false;
renderedCallback() {
    if (this.isCssLoaded) return
    this.isCssLoaded = true
    loadStyle(this, COLORS).then(() => {
    }).catch(error => {
        console.error("Error in loading the colors")
    })
}
//--------------------------------------
   @api validateCountryMethod(){
        this.isRequiredCountry=true;
        this.template.querySelector('.validateCountry')?.classList.add('showRequired'); 
        this.template.querySelector('.validateCountry')?.scrollIntoView();
    }
    @api validateStateMethod(){
        this.isRequiredState=true;
        this.template.querySelector('.validateState')?.classList.add('showRequired'); 
        this.template.querySelector('.validateState')?.scrollIntoView();
    }
    @api validateProjectMethod(){
        this.isRequiredProject=true;
        this.template.querySelector('.validateProject')?.classList.add('ProjectShowRequired'); 
        this.template.querySelector('.validateProject')?.scrollIntoView();

    }
    @api validateProductMethod(){
        this.isRequiredProduct=true;
        this.template.querySelector('.validateProduct')?.classList.add('showRequiredProduct'); 
        this.template.querySelector('.validateProduct')?.scrollIntoView();
    }
    // @api validateCountryMethod(){
    //     this.isRequiredCountry=true;
    //     this.template.querySelector('.validateCountry')?.classList.add('showRequired'); 
    //     this.template.querySelector('.validateCountry')?.scrollIntoView();
    // }
    @api validateCategoryMethod(){
        this.isRequiredCategory=true;
        this.template.querySelector('.validateCategory')?.classList.add('showRequired'); 
        this.template.querySelector('.validateCategory')?.scrollIntoView();
    }
    @api validateSubCategoryMethod(){
        this.isRequiredSubcategory=true;
        this.template.querySelector('.validateSubCategory')?.classList.add('showRequired');
        this.template.querySelector('.validateSubCategory')?.scrollIntoView(); 
    }
    @api validateSubjectMethod(){
        this.isRequiredSubject=true;
        this.template.querySelector('.validateSubject')?.classList.add('showRequired'); 
        this.template.querySelector('.validateSubject')?.scrollIntoView();
}
    //START - Created by Deepaksai as part of BugAssist
    @api validateSSTResponseMethod(){
        this.template.querySelector('c-core_-i-p-s_-bug-assist_form1_-l-w-c').validateReasonForNotProvidingLogFile();
    }
    @api validateSSTLogRequired(){
        this.template.querySelector('c-core_-i-p-s_-bug-assist_form1_-l-w-c').validateSSTLogRequired();
    }
    @api bugAssistRecordData(bugAssistRecord){
        this.template.querySelector('c-core_-i-p-s_-bug-assist_form1_-l-w-c').bugAssistAttachmentData(bugAssistRecord);
    }
    // END BugAssist------------------------------------------
get options() {
    return [
        { label: 'New', value: 'new' },
        { label: 'In Progress', value: 'inProgress' },
        { label: 'Finished', value: 'finished' },
    ];
}

get productVariants() {
    return this.productVariantOptions;
}

get categories() {
    return this.caseCategoryOptions;
}

get subCategories() {
    return this.caseSubCategoryOptions;
}

getUserProfile(event) {
    getcurrentuserprofile({})
        .then(data => {
            if (data === 'PartnerAgent') {
                this.agentCheck = true;
            } else {
                this.agentCheck = false;
            }
            
        })
        .catch(error => {

        })
    this.sendDataToParent(event);
}
/*
getProjectData Method
1.Gets called from connectedcallback with Null paramenters when serach happens directly from project Input field
2.Gets called from handleChangeProd method with ProdId as parameters when user selects first products and then next selects Projects
*/
getProjectData(prodId) {
    let tempVar;
    let searchQueryStr;
    if (prodId == null || prodId == undefined || prodId == '') {
        this.fieldName = 'Name';
        searchQueryStr = 'select id, name,Core_IPS_Project_ID__c from core_ips_project__c where core_status__c=\'Active\'  ORDER BY Core_IPS_Project_ID__c  DESC limit 5';
    } else {
        this.projSelectByProd = true;
        this.fieldName = 'Core_IPS_Project_Name__c';
        tempVar = prodId;
        searchQueryStr = 'select Id, Name, Core_IPS_Project_Name__c from asset where Id =\'' + tempVar + '\' limit 5';
    }
    getQueryResult({
        queryString: searchQueryStr
    })
        .then(data => {
            if (data) {
                this.projectRecords = data;
            } else { }
        })
        .catch(error => {
            console.log('error===>' + JSON.stringify(error));
        })
}

handleProjChange(event) {
    let selectProj = event.detail.record;
    if (selectProj == null || selectProj == undefined || selectProj == '') {
        this.selectedProjectName = '';
        this.getProductData();
        this.refreshSelectedProd1();
    } else {
        this.isProjSelected = true;
        if (this.projSelectByProd) {
            this.selectedProjectName = selectProj.Core_IPS_Project_Name__c;
        } else {
            this.selectedProjectName = selectProj.Name;
        }
        if (!this.isProdSelected) {
            this.getProductData(event.detail.record.Id);
        }
    }

    this.project = event.detail.recordId;
    this.sendDataToParent(event);
}
/*
    getProjectData Method
    1.Gets called from connectedcallback with Null paramenters when serach happens directly from product Input field
    2.Gets called from handleProjChange method with ProjId as parameters when user selects first Projects and then next selects Products
    */
getProductData(projId) {
    let tempVar;
    let searchQueryStr;
    if (projId == null || projId == undefined) {
        searchQueryStr = 'select id, Name,Core_Product_Organization__c,core_supported_product__c,Core_IPS_Project__c,Core_Support_Org_Name__c,core_supported_product__r.Core_IPS_Is_Show_Variant__c from asset where core_supported_product__r.Core_IPS_Is_Show_Variant__c = true and Core_IPS_Project__c != null limit 100';
    } else {
        tempVar = projId;
        searchQueryStr = 'select id, Name,Core_Product_Organization__c,core_supported_product__c,Core_IPS_Project__c,Core_Support_Org_Name__c,core_supported_product__r.Core_IPS_Is_Show_Variant__c from asset where core_supported_product__r.Core_IPS_Is_Show_Variant__c = true and Core_IPS_Project__c =\'' + tempVar + '\' limit 100';
    }
    getQueryResult({
        queryString: searchQueryStr
    })
        .then(data => {
            if (data) {
                let options = [];
                data.forEach(eachRecord => {
                    options.push({ value: eachRecord.Id, label: eachRecord.Name, supProdId: eachRecord.Core_Supported_Product__c });
                });
                this.productOptions = options;
                this.tempProductOptions = options;
            }
        })
        .catch(error => {
            console.log('prod error===>' + JSON.stringify(error));
        })
}


refreshSelectedProd1() {
    this.selectedProductName = '';
    this.showProject = false;
    this.showProdVariants = false;
    this.productVariantOptions = [];
    this.showVariants = false;
    this.selectedVariantName = '';
    this.caseCategoryOptions = [];
    this.showCategories = false;
    this.caseSubCategoryOptions = [];
    this.showSubCategories = false;
    this.renderProductCategory = false;
    this.renderProductSubCategory = false;
    this.showEdqSection = false;
    this.CaseCategoryId = '';
    this.CaseCategoryName = '';
    this.caseCategory = '';
    this.CaseSubCategoryId = '';
    this.CaseSubCategoryName = '';
    this.productvariant = '';
    this.formCaseProjectLookupQuery();
}

refreshSelectedProd() {
    this.selectedProductName = '';
    this.productVariantOptions = [];
    this.showVariants = false;
    this.showProdVariants = false;
    this.showProduct = false;
    this.selectedVariantName = '';
    this.caseCategoryOptions = [];
    this.showCategories = false;
    this.caseSubCategoryOptions = [];
    this.showSubCategories = false;
    this.renderProductCategory = false;
    this.renderProductSubCategory = false;
    this.showEdqSection = false;
    this.renderProductVariant = false;
    this.CaseCategoryId = '';
    this.CaseCategoryName = '';
    this.caseCategory = '';
    this.CaseSubCategoryId = '';
    this.CaseSubCategoryName = '';
    this.productvariant = '';
    this.formCaseProductLookupQuery();
    if (this.projSelectByProd) {
        this.template.querySelector("c-core-ips-custom-lookup").removeSelected();
        this.projSelectByProd = false;
    }
}

prodSearchChangeHandler(event) {
    let tempVar = event.detail.value;

    let similarOptions = [];
    this.productOptions.forEach(product => {
        let index = product.label.toLowerCase().indexOf(tempVar.toLowerCase());
        if (index !== -1) {
            similarOptions.push({ value: product.value, label: product.label });
        }
    });
    this.tempProductOptions = similarOptions;
}

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
                    data.forEach(eachRecord => {
                        options.push({ label: eachRecord.Name, value: eachRecord.Id });
                    });
                    this.productVariantOptions = options;
                } else {
                    this.renderProductVariant = false;

                }
            })
            .catch(error => {
                console.log('error in variants==>' + JSON.stringify(error))
            })
    } else {

    }
}

handleVariantChange(event) {
    let selectedProdVariant = event.detail.value;
    this.productVariantOptions.forEach(option => {
        if (option.value == selectedProdVariant) {
            this.selectedVariantName = option.label;
            this.productvariant = option.value;
        }
    });

    this.sendDataToParent(event);
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
                this.sendDataToParent();
                }
                console.log('CategoryData--'+this.caseCategoryOptions);
            })
            .catch(error => {
                console.log('error in categories==>' + JSON.stringify(error));
            })
    }
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
                    this.caseSubCategoryOptions = options;
                    for (let i = 0; i < options.length; i++) {
                        if (options[i].value != undefined) {
                            this.CaseCategory = options[i].value;
                        }
                    }

                }
                console.log('CategoryDataSUB--'+this.caseSubCategoryOptions);
            })
            .catch(error => {
                console.log('some error occured in getting sub categoeis' + JSON.stringify(error));
            })
    }
}

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
                }else{
                    
                    this.prodEdqRecs = [];
                    this.getSubCategoryEdqs(this.CaseSubCategoryId);
                    this.showEdqSection = false;
                    this.showProdEdqs = false;
                   
                    this.sendDataToParent(event);
                }

            }
        })
        .catch(error => {
            console.log('error in fetching product edqs==>' + JSON.stringify(error));
        })
}
getSubCategoryEdqs(subcategoryId) {
    let tempVar = subcategoryId;
    getSubCatEdq({
        supportedProductId: null,
        subCategoryid: tempVar,
        isAgent: this.agentCheck
    })
        .then(data => {
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
                if (eDQSet.has(edq.id)) { } else {
                    categoryEDQ.push(data[i]);
                }
                i++;
            });
            this.subCatRecEdqs = categoryEDQ;
            for (let i = 0; i < categoryEDQ.length; i++) {
                if (categoryEDQ[i].id != undefined) {
                    this.CaseSubCategory = categoryEDQ[i].id;
                }
            }

            if (this.subCatRecEdqs.length > 0) {
                this.showEdqSection = true;
                this.showSubCatEdqs = true;
            }
            const childEvent = new CustomEvent('getcatrecedqs', {
                detail: {
                    firstParam: this.subCatRecEdqs,
                    secondParam: this.showSubCatEdqs
                }
            });
            this.dispatchEvent(childEvent);
        })
        .catch(error => {
            console.log('error in sub cat edq ' + error);
        })
}
handleNavigateBack() {

}

handlesubject(event) {
    this.subject = event.target.value;
    this.subjectForBugAssist = event.target.value;
    const subjectrec=this.subject.trim();
    //START - Added by Deepaksai as part of BugAssist
    if (this.subject !== null && this.subject !== undefined && subjectrec.length > 0) {
        this.isSubjectEntered = true;
    } else if(this.subject === null || this.subject === undefined || this.subject ==='' || subjectrec.length == 0) {
        this.isSubjectEntered = false;
    }
    this.checkBugAssistEligibility();
    //END - BugAssist
    this.sendDataToParent(event);
    
    if(subjectrec!=''){
    this.template.querySelector('.validateSubject')?.classList.remove('showRequired');
    this.isRequiredSubject=false;
    }
    this.template.querySelector("c-core_-i-p-s_-bug-assist_form1_-l-w-c").resetCheckBoxValues(); // Added by Deepaksai as part of BugAssist
}
handlelanguage(event) {
    this.Language = event.target.value;
    this.sendDataToParent(event);
}

sendDataToParent(event) {
    const sendEvent = new CustomEvent(
        'caseinfodata', {
        detail: {
            project: this.projectid,
            projectName: this.selectedProjectName,
            productvariant: this.productvariant,
            productvariantName: this.selectedVariantName,
            Product: this.product,
            ProductName: this.selectedProductName,
            CategoryId: this.CaseCategoryId,
            CategoryName: this.CaseCategoryName,
            CategoryOptions: this.caseCategoryOptions,
            SubCategoryId: this.CaseSubCategoryId,
            SubCategoryName: this.CaseSubCategoryName,
            SubCategoryOptions: this.subcategoryoptions,
            Subject: this.subject,
            language: this.Language,
            prodEdqRecs: this.prodEdqRecs,
            showProdEdqs: this.showProdEdqs,
            showEdqSection: this.showEdqSection,
            contactId: this.contactId,
            accountId: this.accountId,
            passSupportedProductID: this.passSupportedProductID,
            isAgent: this.agentCheck,
            country: this.selectedValuecountry,
            state: this.statedefaultvalue,
            mindsValue: this.mindsValue,
            renderProductCategory: this.renderProductCategory,
            renderProductSubCategory: this.renderProductSubCategory,
            productVariantOptions: this.productVariantOptions,
            showState: this.showState,
            sstLogvalueTF: this.sstLogValueTF,  // New Added by Hassan for BugAssist 
            selectedReason : this.selectedReason, // New Added by Hassan for BugAssist
            attachedUrl : this.attachedUrl, // New Added by Hassan for BugAssist
            isBugAssitCase : this.isBugAssistTrue, // Added by Deepaksai as part of BugAssist
            bugAssistRecordId : this.bugAssistRecordId, // Added by Deepaksai as part of BugAssist
            isSubjectEntered : this.isSubjectEntered, // Added by Deepaksai as part of BugAssist
            isBugAssistProduct : this.isBugAssistProduct, // Added by Deepaksai as part of BugAssist
            uploadedFileName : this.uploadedFileName, // Added by Deepaksai as part of BugAssist
            subjectForBugAssist : this.subjectForBugAssist  // Added by Deepaksai as part of BugAssist
        }
    });
    this.dispatchEvent(sendEvent);
}
get sendcaseProject() {
    return this.casedata.projectName;
}

get sendcaselanguage() {
    return this.casedata.Language;
}
get sendcaseproducts() {
    return this.casedata.ProductName;
}

    @track isSelectedProjectPresent = false;
    @api showProject = false;
    @track lookupIconNameProject = "standard:account";
    @track lookupSearchFieldNameProject = "Name";
    @track lookupQueryStringProject;
    @track isLookupQueryPresentProject = false;
    @track lookupCountQueryStringProject;
    @api projectFieldSet;
    @api projectid;
    @api caseProjectId;
    @api showProdVariants = false;
    @api showProduct = false;
    @track isLookupQueryPresentProduct = false;
    @api assetFieldSet;
    @track lookupSearchFieldNameProduct = "Name";
    @track lookupQueryStringProduct;
    @track lookupIconNameProduct = "standard:product";
    @track lookupCountQueryStringProduct;
    @api assetid;
    @api caseassetId;
    @track renderProductVariant = false;
    @api recordTypeName = 'IPS_Case_Create';
    @track productVariant = '';
    @api productVariantOptions = [];
    @track renderProductCategory = false;
    @api caseCategory;
    @api caseCategoryOptions;
    @api productid;
    @api subcategoryoptions;
    @api error;
    @api caseSubCategory;
    @track projSelected = false;
    @track lookupTempQueryStringProduct;
    @track lookupTempQueryStringProject;
    formCaseProjectLookupQuery() {
        /*let soslQuery = ' FIND :key IN ALL FIELDS RETURNING core_ips_project__c ';
        let queryFieldsStr = this.projectFieldSet + ' Id ';
        let queryWhereClause1Str = '  WHERE core_status__c=\'Active\' ';
        let queryOrderByClauseStr = ' ORDER BY Core_IPS_Project_ID__c DESC';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
        this.lookupQueryStringProject = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr + ')';
        this.lookupCountQueryStringProject = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + ')';
        this.isLookupQueryPresentProject = true;*/
        let soqlQuery = ' SELECT '+ this.projectFieldSet + ' Id FROM core_ips_project__c ';
        let queryWhereClause1Str = '  WHERE core_status__c=\'Active\' ';
        let queryOrderByClauseStr = ' ORDER BY Name ASC';
        this.lookupQueryStringProject = soqlQuery + queryWhereClause1Str + queryOrderByClauseStr;
        this.lookupTempQueryStringProject = soqlQuery + queryWhereClause1Str ;
        this.isLookupQueryPresentProject = true;
        console.log('OUTPUT :  this.lookupQueryStringProject', this.lookupQueryStringProject);
        
    }
    formCaseProductLookupQuery() {
        /*let soslQuery = ' FIND :key IN ALL FIELDS RETURNING Asset ';
        this.assetFieldSet = 'Product2.Name, core_Product_Application__c, Core_IPS_Project_Name__c, AccountId, Core_Code_Name__c, core_ips_project__c,Core_Supported_Product__c,';
        let queryFieldsStr = this.assetFieldSet + ' Id, Name ';
        let queryWhereClause1Str = '  WHERE Status!=\'Inactive\' ';
        let queryOrderByClauseStr = ' ORDER BY Core_IPS_Support_License__c, Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last,Name ASC';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
        if (this.caseProjectId !== undefined && this.caseProjectId !== null && this.caseProjectId !== '') { //Project ID
            queryWhereClause1Str += ' AND core_ips_project__c = \'' + this.caseProjectId + '\' ';
        }
        this.lookupQueryStringProduct = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr + ')';
        this.lookupCountQueryStringProduct = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + ')';
        this.isLookupQueryPresentProduct = true;*/

        //added Core_Product_Organization__r.Name to below query by Deepaksai
        let soqlQuery = ' SELECT Product2.Name, core_Product_Application__c, Core_IPS_Project_Name__c, AccountId, Core_Code_Name__c, core_ips_project__c,Core_Supported_Product__c, Id,Name,Core_Alias__c, Core_Product_Organization__r.Name FROM Asset ';
        
	    let queryOrderByClauseStr = ' ORDER BY Name ASC, Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last';
        let queryWhereClauseStr='';
        if(this.caseProjectId!=null && this.caseProjectId!=undefined && this.caseProjectId!=''){
            queryWhereClauseStr = '  WHERE Status!=\'Inactive\' AND core_ips_project__c = \'' + this.caseProjectId + '\'';
        }
        else{
            queryWhereClauseStr = '  WHERE Status!=\'Inactive\' AND core_ips_project__c = \'\'';
        }           
        this.lookupQueryStringProduct = soqlQuery + queryWhereClauseStr + queryOrderByClauseStr;
        this.lookupTempQueryStringProduct = soqlQuery + queryWhereClauseStr ;
        this.isLookupQueryPresentProduct = true;
        
    }


@wire(getObjectInfo, { objectApiName: Contact })
objectInfo;
@wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Core_Country_Region__c })
wiredData({ error, data }) {
    if (data) {

        let dataOjb = data.values;
        let finalData = [{ label: "--None--", value: "None" }, ...dataOjb];
        this.options = finalData.map(objPL => {
            return {
                label: `${objPL.label}`,
                value: `${objPL.value}`
            };
        });

    } else if (error) {
        console.error(JSON.stringify(error));
    }
}

@wire(getPicklistValues, {
    recordTypeId: '$objectInfo.data.defaultRecordTypeId',
    fieldApiName: STATE
})
wiredstateField({
    data,
    error
}) {
    if (data) {
        this.stateFieldData = data;
         if(this.selectedValuecountry != undefined) {
          let key = this.stateFieldData.controllerValues[this.casecountryselected];
          this.stateList = this.stateFieldData.values.filter(opt => opt.validFor.includes(key));
          if(this.stateList.length != 0) {
               this.showState = true;
          } else {
               this.showState = false;
        }
    }
    }
    if (error) {
        console.log('error: ' + JSON.stringify(error));
    }
}

handlePicklistChange(event) {
    let key = this.stateFieldData.controllerValues[event.target.value];
    this.stateList = this.stateFieldData.values.filter(opt => opt.validFor.includes(key));
    if(this.stateList.length != 0) {
      this.showState = true;
    } else {
      this.showState = false;
      this.statedefaultvalue = '';
    }
    let strCheck = JSON.stringify(event.detail.value);
    this.selectedCountryValue = strCheck.replace(/['"]+/g, '');
    this.selectedValuecountry = this.selectedCountryValue;
    this.value = this.selectedCountryValue;
    this.sendDataToParent(event);
    this.isRequiredCountry=false;
    this.template.querySelector('.validateCountry')?.classList.remove('showRequired'); 

}

handleStateChange(event) {
    this.statedefaultvalue = event.detail.value;
    this.sendDataToParent(event);
    this.isRequiredState=false;
}

handleChangeProject(event) {
    this.caseProjectId = null;
    this.formCaseProductLookupQuery();
    this.projectid = event.detail.recordId;
    this.caseProjectId = event.detail.recordId;
    let selectProj = event.detail.record;
    
    if (selectProj == null || selectProj == undefined || selectProj == '') {
        this.selectedProjectName = '';
        this.product='';
        this.projectdata = '';
        this.projSelected = false;
        //this.refreshSelectedProd();
        this.renderProductVariant = false;
        this.refreshSelectedProd1();
        
    } else {
        
        this.selectedProjectName = selectProj.Name;
        this.showProject = true;
        //this.product='';
        this.projSelected = true;
        this.formCaseProductLookupQuery();

    }
    
this.sendDataToParent(event);
this.isRequiredProject=false;
this.isRequiredProduct=false;
this.template.querySelector('.validateProject')?.classList.remove('ProjectShowRequired'); 

}
bugAssistSupportedProductArr;
//transforming handleChangeProduct to aysnc as part of BugAssist by Deepaksai
// handleChangeProduct(event) {
async handleChangeProduct(event) {
    this.productid = event.detail.record;
    this.assetid = event.detail.recordId;
    this.product = this.assetid;
    this.caseassetId = event.detail.recordId;
    if (this.productid == null || this.productid == undefined || this.productid == '') {
        this.selectedProductName = '';
        this.selectedProductName =undefined;
        this.product='';
        this.refreshSelectedProd();
    } else {

        //START - Added by Deepaksai as part of BugAssist
        // Get Product Org Name from Apex using Core_Product_Organization__c ID
        let productOrgName = null;
        try {
            if (this.productid?.Core_Product_Organization__c) {
                productOrgName = await getProductOrgName({ 
                    recordId: this.productid.Core_Product_Organization__c 
                });
                console.log('OUTPUT : productOrgName',productOrgName);
            }
        } catch (error) {
            this.error = error;
            productOrgName = null;
        }
        this.bugAssistSupportedProductArr = bugAssistSupportedProducts.split(',');
        if (productOrgName && this.bugAssistSupportedProductArr.includes(String(productOrgName)) === true) {
       // if (this.bugAssistSupportedProductArr.includes(String(this.productid?.Core_Product_Organization__r?.Name)) === true) { // Changed by tushar---- vanuability fixes
            await validateBugAssistProd({
                recordId:this.productid.Core_Supported_Product__c
            }).then((result) => {
                if (result !== '' && result !== null && result === true ){
                    this.isBugAssistProduct = true;
                } else {
                    this.isBugAssistProduct = false;
                }
            }).catch((error) => {
                this.error = error;
            });
        } else {
            this.isBugAssistProduct = false;
        }
        this.checkBugAssistEligibility(); 
        // END -  Added by Deepaksai as part of BugAssist
        this.showProduct = true;
        this.selectedProductName = this.productid.Name;
        this.formCaseProjectLookupQuery();
        for (let key in event.detail.record) { }
        this.getProdVariants(this.assetid);
        if (this.productid.Core_Supported_Product__c !== null) {
            this.passSupportedProductID = this.productid.Core_Supported_Product__c;
            this.getCatergories(this.productid.Core_Supported_Product__c);
            this.getProductEdqs(this.productid.Core_Supported_Product__c);
            this.sendDataToParent(event);
        }
        
    }
this.sendDataToParent(event);
this.isRequiredProduct=false;
this.template.querySelector('.validateProduct')?.classList.remove('showRequiredProduct'); 

}

//START - Added by Deepaksai as part of BugAssist
checkBugAssistEligibility() {
    if (this.isBugAssistProduct === true && (this.isSubjectEntered === true || (this.subject !== undefined && this.subject.trim().length>0 )) && this.isBugAssistTrue === false ) {
        this.isBugAssistTrue = true;
    } else if (this.isBugAssistProduct === false || this.isSubjectEntered === false) {
        this.isBugAssistTrue = false;
    }
}
//END - Added by Deepaksai as part of BugAssist

handleChangeProductVariant(event) {

    let selectedProdVariant = event.detail.value;
    let productVariantID = event.detail.recordId;
    this.productVariantOptions.forEach(option => {
        if (option.value == selectedProdVariant) {
            this.showProdVariants = true;
            this.selectedVariantName = option.label;
            this.productvariant = option.value;
        }
    });
    this.sendDataToParent(event);
}


handleChangeSubCategory(event) {

    this.caseCategory = event.target.value;
    this.caseCategoryOptions.forEach(option => {
        if (option.value == this.caseCategory) {
            this.CaseCategoryId = option.value;
            this.CaseCategoryName = option.label;
        }
    });
    if (this.caseCategory !== null) {
        this.CaseSubCategoryId = undefined;
        this.CaseSubCategoryName = undefined;
        this.showCaseSubCategory(this.caseCategory);
    }
    this.sendDataToParent(event);
    this.isRequiredCategory=false;
    this.template.querySelector('.validateCategory')?.classList.remove('showRequired'); 

}
showCaseSubCategory(caseCategory) {
    showsubCategory({
        categorySelected: caseCategory,
    }).then(result => {
        if (result !== undefined || result !== null) {
            this.subcategoryoptions = result;
            this.error = undefined;
            if (this.subcategoryoptions.length > 0) {
                this.renderProductSubCategory = true;
                this.showSubCategories = true;
            }
            else{
                this.renderProductSubCategory = false;
                this.showSubCategories = false;
                this.CaseSubCategoryId = undefined;
                this.CaseSubCategoryName = undefined;
            }
            this.sendDataToParent(event);
        }
    })
        .catch(error => {
            this.error = error;

        });
}
handleChangeRenderSubCategoryedq(event) {
    let subCatId;
    let selectedSubCategory = event.detail.value;
    this.subcategoryoptions.forEach(option => {
        if (option.value == selectedSubCategory) {
            subCatId = option.value;
            this.CaseSubCategoryId = option.value;
            this.CaseSubCategoryName = option.label;

        }
    });
    this.getSubCategoryEdqs(subCatId);
    this.sendDataToParent(event);
    this.isRequiredSubcategory=false;
    this.template.querySelector('.validateSubCategory')?.classList.remove('showRequired'); 

}

@track showboolean1;
@track showboolean2;

handleChangeMINDS(event) {
    if (event.target.name == "yeschecked") {
        if (event.target.checked) {
            this.showboolean1 = true;
            this.showboolean2 = false;
            this.mindsValue = this.showboolean1;
        } else {
            this.showboolean1 = false;
            this.showboolean2 = true;
            this.mindsValue = this.showboolean1;
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
            this.mindsValue = true;
        }
    }
    this.sendDataToParent(event);
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
severityValue = "Low";
get caseSeverityoptions() {
    return [
        { label: "Low", value: "Low" },
        { label: "Medium", value: "Medium" },
        { label: "High", value: "High" },
        { label: "Critical", value: "Critical" },
    ];
}
@api communityCheck;
@api subjectvaluesslc;
@api descriptiondefault;
@api Assetdefault;
@api Projectdefault;

@api CaseTypedefault;
@api CaseSubcategorydefault;
@api Supported_Productdefault;

@api IssueSourcedefault;
@api Case_Categorydefault;
@api CaseSubcategoryDetaildefalut;
@api defaultdatainfo;

@api Supported_ProductdefaultID;
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
                if (key == 2 && key1 == 'Core_IPS_Default_Data__c') {
                    this.Projectdefault = this.defaultdatainfo[key][key1];
                }
                if (key == 3 && key1 == 'Core_IPS_Default_Data__c') {
                    this.CaseTypedefault = this.defaultdatainfo[key][key1];
                }
                if (key == 4 && key1 == 'Core_IPS_Default_Data__c') {
                    this.CaseSubcategorydefault = this.defaultdatainfo[key][key1];
                }
                if (key == 5 && key1 == 'Core_IPS_Default_Data__c') {
                    this.Supported_Productdefault = this.defaultdatainfo[key][key1];
                }
                if (key == 5 && key1 == 'Core_IPS_Default_data_Id__c') {
                    this.Supported_ProductdefaultID = this.defaultdatainfo[key][key1];
                    this.getCatergories(this.Supported_ProductdefaultID);
                    this.getProductEdqs(this.Supported_ProductdefaultID);
                }
                if (key == 6 && key1 == 'Core_IPS_Default_Data__c') {
                    this.IssueSourcedefault = this.defaultdatainfo[key][key1];
                }
                if (key == 7 && key1 == 'Core_IPS_Default_Data__c') {
                    this.Case_Categorydefault = this.defaultdatainfo[key][key1];
                }
                if (key == 8 && key1 == 'Core_IPS_Default_Data__c') {
                    this.CaseSubcategoryDetaildefalut = this.defaultdatainfo[key][key1];
                }
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


//Show contact popup
@track showContacts = true;
@track isModalOpen = false;
@track contactColumns = contactColumns;
conData;
openModal() {
    this.isModalOpen = true;
}
closeModal() {
    this.isModalOpen = false;
}

getContacts() {
    getContactRecords()
        .then(result => {
            if (result) {
                let cData = JSON.parse(JSON.stringify(result));
                this.conData = cData;
            }
        })
        .catch(error => {

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
submitcountryClick() {
    Submitcountryvalue({ countryValue: this.selectedCountryValue || '', radioCheckbox: this.showboolean1 || '' })
        .then((result) => {
            this.contacts = result;
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            this.contacts = undefined;

        });
}
    // START - Hassan Added to get data from BugAssist fields
    sstLogValueTF ='';
    selectedReason ='';
    bugAssistRecordId = '';
    attachedUrl = '';
    uploadedFileName ='';
    handleSendEvent(event){
        this.sstLogValueTF = event.detail.sstLogValueTF;
        this.selectedReason = event.detail.selectedReason;
        this.bugAssistRecordId = event.detail.bugAssistRecId;
        this.attachedUrl = event.detail.bugAssistUrl;
        this.uploadedFileName = event.detail.uploadedFileName;
        this.sendDataToParent(event);
    }
    handleValueReset(event) {
        this.sstLogValueTF = event.detail.sstLogValueTF;
        this.sendDataToParent(event);
    }
    // END - BugAssist
}