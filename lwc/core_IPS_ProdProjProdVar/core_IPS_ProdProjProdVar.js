import { LightningElement,track,api } from 'lwc';
import readFieldSet from "@salesforce/apex/Core_IPS_CaseCreateLWCController.readFieldSet";
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';
import displayProductVariant from "@salesforce/apex/Core_IPS_CaseCreateLWCController.displayProductVariant";
import getProductVariants from '@salesforce/apex/core_IPS_caseCreate_LEX.getProductVariants';
import getCategoryOptions from '@salesforce/apex/core_IPS_caseCreate_LEX.getCaseCategories'
import showsubCategory from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getSubCategoryDetail";
import getProdEdq from "@salesforce/apex/Core_IPS_CaseCreateLWCController.getProductEDQ";
export default class Core_IPS_ProdProjProdVar extends LightningElement {
    @track activeSection = ['A', 'B'];
    @track isSelectedProjectPresent = false;
    //for project
    @track lookupIconNameProject = "standard:account";
    @track lookupSearchFieldNameProject = "Name";
    @track lookupQueryStringProject;
    @track isLookupQueryPresentProject = false;
    @track lookupCountQueryStringProject;
    @api projectFieldSet;
    @api projectid;
    @api caseProjectId;
    //FOR PRODUCT 
    @api productid;
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
    //Category
    @track renderProductCategory = false;
    @api caseCategory;
    @api caseCategoryOptions;
    //SubCategory
    @track renderProductSubCategory = false;
    @api subcategoryoptions;
    @api caseSubCategory;
    //edq
    @track showProductSection = false;
    @api showEdqSection;
    @api showProdEdqs;
    connectedCallback(){
        
        //id, name,Core_IPS_Project_ID__c
        this.projectFieldSet = "name,Core_IPS_Project_ID__c,";
        console.log('ANil Project FieldSet-- ', this.projectFieldSet); 
        this.formCaseProjectLookupQuery();
        this.formCaseProductLookupQuery();
       /* readFieldSet({fieldSetName : 'IpsProjectFieldSet', ObjectApiName : 'core_ips_project__c'})
        .then(res=>{
            this.projectFieldSet = res;
            console.log('ANil Project FieldSet-- ', err, JSON.stringify(this.projectFieldSet));
            this.formCaseProjectLookupQuery();
        })
        .catch(err=>{
            //console.error('Error in loading project field set ', err, JSON.stringify(err));
        }); */
    }
    formCaseProjectLookupQuery(){
        let soslQuery = ' FIND :key IN ALL FIELDS RETURNING core_ips_project__c ';
        let queryFieldsStr = this.projectFieldSet + ' Id ';
        let queryWhereClause1Str = '  WHERE core_status__c=\'Active\' ';
        let queryOrderByClauseStr = ' ORDER BY Core_IPS_Project_ID__c DESC';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';

        this.lookupQueryStringProject = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr + ')';
        this.lookupCountQueryStringProject = soslQuery + '(' + queryFieldsStr + queryWhereClause1Str + queryOrderByClauseStr + ')';
        this.isLookupQueryPresentProject = true;
        console.log('ANil lookupQueryStringProject-- ', this.lookupQueryStringProject);
        console.log('ANil lookupCountQueryStringProject-- ', this.lookupCountQueryStringProject);
    }
    formCaseProductLookupQuery(){
        let soslQuery = ' FIND :key IN ALL FIELDS RETURNING Asset ';
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
        this.isLookupQueryPresentProduct = true;
        console.log('ANil lookupQueryStringProduct-- ', this.lookupQueryStringProduct);
        console.log('ANil isLookupQueryPresentProduct-- ', this.isLookupQueryPresentProduct);
    }
    handleChangeProject(event) {
        console.log('ANil recordidproject-- ', event.detail.recordId);
        console.log('ANil record project-- ',  JSON.stringify(event.detail.record));
        this.projectid = event.detail.recordId;
        this.caseProjectId = event.detail.recordId;
        this.formCaseProductLookupQuery();
    }
    handleChangeProduct(event) {
        console.log('ANil recordid prod assetId-- ', event.detail.recordId);
        console.log('ANil record asset-- ',  JSON.stringify(event.detail.record));
        this.assetid = event.detail.recordId;
        this.caseassetId = event.detail.recordId;
        this.productid = event.detail.record;
        this.formCaseProjectLookupQuery();
        for(let key in event.detail.record){
            console.log(`${key} workload ---> ${event.detail.record[key]}`);
        }
        this.getProdVariants(this.assetid);
        console.log('ANil Core_Supported_Product-- ',this.productid.Core_Supported_Product__c);
        if(this.productid.Core_Supported_Product__c!=null){
            this.getCatergories(this.productid.Core_Supported_Product__c);
            this.showProductSection = true;
            this.getProductEdqs(this.productid.Core_Supported_Product__c);
        } 
    }
    getProdVariants(prodIdStr){
        console.log("getProdVariants called--> ", prodIdStr);
        let tempVar;
        /* if(prodIdStr != null) {
            //tempVar = JSON.stringify(prodIdStr);
            tempVar = prodIdStr;
        } else {
            tempVar = undefined;
        } */
        if(prodIdStr !=null || prodIdStr != undefined){
            //console.log("tempVar");
            getProductVariants({
                prodId : prodIdStr
            })
            .then(data => {
                if(data){
                    console.log("apex called");
                    //this.showVariants= true;
                    this.renderProductVariant = true;
                    console.log('variants data==>'+JSON.stringify(data))
                    let options= [];
                    data.forEach(eachRecord => {
                        options.push({ label: eachRecord.Name, value: eachRecord.Id });
                    });
                    this.productVariantOptions = options;
                }
            })
            .catch(error => {
                console.log('error in variants==>'+JSON.stringify(error))
            })
        }
    }
    getCatergories(prodId){
        console.log('inside get categories and prodid===>'+prodId)
        let tempVar;
        if(prodId != null) {
            tempVar = prodId;
        } else {
            tempVar = undefined;
        }
        if(tempVar !=null || tempVar != undefined){
            getCategoryOptions({
                prodId : tempVar
            })
            .then(data=>{
                if(data){
                    this.renderProductCategory = true;
                   console.log('inside categories==>'+JSON.stringify(data));
                    let options= [];
                    data.forEach(eachRecord => {
                        options.push({ label: eachRecord.Core_Issue_Category_Name__r.Name, value: eachRecord.Id });
                    });
                    this.caseCategoryOptions = options;
                    console.log('final categories==>'+JSON.stringify(this.caseCategoryOptions));
                }
            })
            .catch(error=>{
                console.log('error in categories==>'+JSON.stringify(error));
            })
        }
    }
    getProductEdqs(supportedId){
        let tempVar = supportedId;
        console.log('inside prod edq method and id is==>'+tempVar);
        getProdEdq({
            supportedProductId: tempVar,
            subCategoryid: null,
            isAgent: null
        })
        .then(data=>{
            if(data){
                this.prodEdqRecs = data;
                if(this.prodEdqRecs.length > 0){
                    this.showEdqSection = true;
                    this.showProdEdqs = true;
                }
                console.log('final prodEdqRecs data==>'+JSON.stringify(this.prodEdqRecs));
            }
        })
        .catch(error=>{
            console.log('error in fetching product edqs==>'+JSON.stringify(error));
        })
    }
    //on product variant change
    handleChangeProductVariant(event) {
        //this.value = event.detail.value;
        this.productVariant = event.detail.value;
         console.log("this.productVariant:" + this.productVariant);
    }
    //on  category change
    handleChangeSubCategory(event) {
        // for type head picklist
        this.caseCategory = event.target.value;
         console.log("label>>>" + event.detail.label);
         console.log("sub category:" + JSON.stringify(this.caseCategory));
        if (this.caseCategory !== null) {
            this.showCaseSubCategory(this.caseCategory);
        }
    }
    showCaseSubCategory(caseCategory){
        showsubCategory({
            categorySelected: caseCategory,
        }).then(result => {
            if (result !== undefined || result !== null) {
                  console.log("this.subcategoryoptions" + JSON.stringify(result));
                this.subcategoryoptions = result;
                 this.error = undefined;
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
    handleChangeRenderSubCategoryedq(event) {
        this.caseSubCategory = event.target.value;
      //  this.showSubCatEDQ = false;
      if (this.caseSubCategory !== null){

      }
    }
}