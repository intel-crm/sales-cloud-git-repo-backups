import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Case_OBJECT from '@salesforce/schema/Case';
import Case_Source from '@salesforce/schema/Case.Core_IPS_Issue_source__c';
import Case_Type from '@salesforce/schema/Case.Core_CaseType__c';



//import readFieldSet from "@salesforce/apex/Core_IPS_InternalCaseCreateController.readFieldSet";
import getProjectList from "@salesforce/apex/Core_IPS_InternalCaseCreateController.getProjectList";
import displayProductVariant from "@salesforce/apex/Core_IPS_InternalCaseCreateController.displayProductVariant";
import displayProductVariantNAC from "@salesforce/apex/Core_IPS_InternalCaseCreateController.displayProductVariantNAC";
//import Core_IPS_Global_Asset_RT from '@salesforce/label/c.Core_IPS_Global_Asset_RT';

const Core_IPS_Global_Asset_RT = 'Core_IPS_Public_Product';

export default class Core_IPS_Internal_Case_Creation extends LightningElement {
    @api returnURL;
    @api recordTypeId;

    @track activeSection = ['A', 'B'];

    @api sourceValues = [];
    @api typeValues = [];

    @track productVariantOptions;

    caseContactId; //= '0033F000003IvCmQAK';
    caseAccountId; //= '0013F000004N3vjQAC';
    caseProjectId; //= 'a2B3F0000006Fm8UAE';
    caseProductId;
    //nacCaseProductId;
    publicProductRecTypeName = Core_IPS_Global_Asset_RT;
    
    @track selectedContactRecord;
    @track isContactLookupQueryPresent = false;
    contactLookupIconName = "standard:contact";
    contactlookupSearchFieldName = "Name";
    contactlookupQueryString;
    contactlookupCountQueryString;

    @track selectedProjectRecord;
    @track isProjectLookupQueryPresent = false;
    projectLookupIconName = "standard:product";
    projectlookupSearchFieldName = "Name";
    projectlookupQueryString;
    projectlookupCountQueryString;

    @track selectedProductRecord;
    @track isProductLookupQueryPresent = false;
    productLookupIconName = "standard:product";
    productlookupSearchFieldName = "Name";
    productlookupQueryString;
    productlookupCountQueryString;

    @track selectedProductVariantOption;
    @track isProductVariantAvailable = false;

    @track projectList;
    /*
    @track assetFieldSet;
    @wire(readFieldSet, {fieldSetName : 'AssetFieldSet', ObjectApiName : 'Asset'})
    wiredAssetFieldSet({data, error}){
        if(data) {
            this.assetFieldSet = '';
            for(let i=0; i<data.length; i++ ) {
                this.assetFieldSet += data[i] + ', ';
            }
            console.log('this.assetFieldSet ', this.assetFieldSet);
        }
        if(error) {
            console.error('Error in loading Asset Fild Set', error);
        }
    } */       

    @wire(getProjectList, {relatedId : '$caseContactId'})
    wiredProjectList({data, error}){
        console.log('getProjectList called caseContactId ', this.caseContactId);
        if(data){
            this.projectList = JSON.stringify(data);
            this.projectList = this.projectList.replace("[", "(");
            this.projectList = this.projectList.replace("]", ")");
            this.projectList = this.projectList.replace(/"/g, "'");
            console.log("this.projectList ", this.projectList);
            console.log("this.projectList length ", this.projectList.length);
            this.formCaseProductLookupQuery();
        }
        if(error){
            console.error('Error in loading project id list');
        }
    }

    @wire(getObjectInfo, { objectApiName: Case_OBJECT })
        objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Case_Source })
    wiredsourceField({ data, error }) {
        if (data) {
            this.sourceValues = data.values;
        }
        if (error) {
            console.log('error: ' + error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Case_Type })
    wiredtypeField({ data, error }) {
        if (data) {
            this.typeValues = data.values;
        }
        if (error) {
            console.log('error: ' + error);
        }
    }

    @wire(displayProductVariant, {selectedProductId : '$caseProductId'}) //"02i3F000003sCnK" 
    wiredProductVariantsList({data, error}) {
        if(data) {
            console.log("Product Variants ::: ", JSON.stringify(data));
            //this.productVariantOptions = data;
            let keys = Object.keys(data);
            let options = [];
            for(let i=0; i< keys.length; i++) {
                let option = { label :  keys[i], value: data[keys[i]]  } ;
                console.log('keys[i] ', keys[i]);
                console.log('keys[i] ', data[keys[i]]);
                options = [...options, option];
            }
            console.log('options ', options);
            console.log("Product Variants ::: ", JSON.stringify(options));
            this.productVariantOptions = options;
            console.log('keys.length ', keys.length);
            if(keys !== undefined && keys !== null && keys.length>0) {
                this.isProductVariantAvailable = true;
            }
            
        }
        if(error) {
            console.error('Error in loading product variants', error);
        }
    }

    @wire(displayProductVariantNAC, {selectedProductId : "$nacCaseProductId"}) 
    wiredNacProductVariantsList({data, error}) {
        if(data) {
            console.log("Product Variants ::: ", JSON.stringify(data));
            //this.productVariantOptions = data;
            let keys = Object.keys(data);
            let options = [];
            for(let i=0; i< keys.length; i++) {
                let option = { label :  keys[i], value: data[keys[i]]  } ;
                console.log('keys[i] ', keys[i]);
                console.log('keys[i] ', data[keys[i]]);
                options = [...options, option];
            }
            console.log('options ', options);
            console.log("Product Variants ::: ", JSON.stringify(options));
            this.productVariantOptions = options;
            console.log('keys.length ', keys.length);
            if(keys !== undefined && keys !== null && keys.length>0) {
                this.isProductVariantAvailable = true;
            }
        }
        if(error) {
            console.error('Error in loading product variants', error);
        }
    }
    

    connectedCallback() {
        console.log('In LWC returnURL ' + this.returnURL);
        console.log('In LWC recordTypeId ' + this.recordTypeId);
        this.contactlookupQueryString = 'SELECT Id, Name, AccountId FROM Contact WHERE Core_IPS_Active__c=true AND Name LIKE :key LIMIT :recordLimit';
        this.contactlookupCountQueryString = 'SELECT count() FROM Contact WHERE Core_IPS_Active__c=true AND Name LIKE :key';
        this.isContactLookupQueryPresent = true;

        this.projectlookupQueryString = 'SELECT Id, Name FROM core_ips_project__c WHERE Name LIKE :key LIMIT :recordLimit';
        this.projectlookupCountQueryString = 'SELECT count() FROM core_ips_project__c WHERE Name LIKE :key';
        this.isProjectLookupQueryPresent = true;

        //this.productlookupQueryString = 'SELECT Id, Name FROM Asset WHERE Name LIKE :key LIMIT :recordLimit';
        //this.productlookupCountQueryString = 'SELECT count() FROM Asset WHERE Name LIKE :key';
        //this.isProductLookupQueryPresent = true;
        this.formCaseProductLookupQuery();
    }

    renderedCallback() {
        
    }

    formCaseProductLookupQuery() {
        let querySeleteStr = 'SELECT ';
        this.assetFieldSet = 'Product2.Name, core_Product_Application__c, Core_IPS_Project_Name__c, AccountId, Core_Code_Name__c,';
        let queryFieldsStr = this.assetFieldSet + ' Id, Name ';
        let queryFromObjStr = ' FROM Asset ';
        let queryWhereClause1Str = '  WHERE Status!=\'Inactive\' AND (Name LIKE :key OR Core_Alias__c LIKE :key) '; 
        let queryOrderByClauseStr = ' ORDER BY Core_IPS_Support_License__c, Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last,Name ASC';
        let queryLimitClauseStr = ' LIMIT :recordLimit ';
        
        if(this.caseProjectId !== undefined && this.caseProjectId !== null && this.caseProjectId !== ''){ //Project ID
            queryWhereClause1Str +=' AND core_ips_project__c = \'' + this.caseProjectId + '\' ' ;
        } else if(this.caseProjectId === undefined || this.caseProjectId === null || this.caseProjectId === '') {
            let contactAccountProjListfilter = '';
            if( this.caseContactId !== undefined && this.caseContactId !== null && this.caseAccountId !== undefined && this.caseAccountId !== null ) {
                contactAccountProjListfilter = ' AND (ContactId = \'' + this.caseContactId + '\' OR AccountId = \'' + this.caseAccountId + '\''; 
                if(this.projectList !== undefined && this.projectList !==null) {
                    contactAccountProjListfilter += ' OR Core_IPS_Project__c IN ' + this.projectList + ')'
                }
            } else if(this.projectList !== undefined && this.projectList !==null) {
                contactAccountProjListfilter += ' AND Core_IPS_Project__c IN ' + this.projectList;
            }
            queryWhereClause1Str = ' WHERE (Status!=\'Inactive\'' + contactAccountProjListfilter + ' AND (Name LIKE :key OR Core_Alias__c LIKE :key) AND (Core_IPS_Project__c!=null OR RecordType.DeveloperName=\''+ this.publicProductRecTypeName + '\')) OR (Status!=\'Inactive\' ' + contactAccountProjListfilter + ' AND (Name LIKE :key OR Core_Alias__c LIKE :key) AND AccountId !=null AND Core_Supported_Product__r.Core_Flag_Status__c != \'Par Hidden\')';
        }
        this.productlookupQueryString = querySeleteStr + queryFieldsStr + queryFromObjStr + queryWhereClause1Str + queryOrderByClauseStr + queryLimitClauseStr;
        this.productlookupCountQueryString = querySeleteStr + ' count() ' + queryFromObjStr + queryWhereClause1Str;
        console.log('this.productlookupQueryString ::: ' + this.productlookupQueryString);
        this.isProductLookupQueryPresent = true;
    }

    handleSelectedContact(event) {
        this.selectedContactRecord = event.detail.record;
        if(this.selectedContactRecord) {
            this.caseContactId = event.detail.recordId;
            this.caseAccountId = event.detail.record.AccountId;
        } else {
            this.caseContactId = undefined;
            this.caseAccountId = undefined;
        }
    }

    handleSelectedProject(event) {
        this.selectedProjectRecord = event.detail.record;
    }

    handleSelectedProduct(event) {
        this.isProductVariantAvailable = false;
        this.selectedProductRecord = event.detail.record;
        this.caseProductId = event.detail.recordId;
    }

    handleChangeproductvariant(event) {
        console.log('handleChangeproductvariant', event.target.value);
        console.log('handleChangeproductvariant', event.target);
    }

    handleChangecaseSource() {
        console.log('handleChangecaseSource called');
    }

    handleChangecaseType() {
        console.log('handleChangecaseType called');
    }

    handleChangeDescription() {
        console.log('handleChangeDescription called');
    }

    handleCancel() {
        console.log('Handle cancel called');
    }

    handleSave() {
        console.log('Handle Save called');
    }
}