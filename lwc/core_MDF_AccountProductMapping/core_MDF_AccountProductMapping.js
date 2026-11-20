import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNTPRODUCTMAPPING_OBJECT from '@salesforce/schema/Core_MDF_Account_Product_Mapping__c';
import Core_MDF_Program_Account_Map__c from '@salesforce/schema/Core_MDF_Account_Product_Mapping__c.Core_MDF_Program_Account_Map__c';
import Core_MDF_Save from "@salesforce/label/c.Core_MDF_Save";
import Core_MDF_Cancel from "@salesforce/label/c.Core_MDF_Cancel";
import Core_MDF_SelectedProductColumn from "@salesforce/label/c.Core_MDF_SelectedProductColumn";
import getProducts from '@salesforce/apex/Core_MDF_AccountProductMappingController.getProducts';
import saveAccProdMapping from '@salesforce/apex/Core_MDF_AccountProductMappingController.createUpdateAccountAndProductMappingRecords';
import getAccountProductMapping from '@salesforce/apex/Core_MDF_AccountProductMappingController.getAccountProductMapping';
import hasAccessToPriceReviewerMaintanceTab from '@salesforce/apex/Core_MDF_AccountProductMappingController.hasAccessToPriceReviewerMaintanceTab';
import 	Core_MDF_Program from '@salesforce/label/c.Core_MDF_Program';
import hasPermission from "@salesforce/customPermission/Core_MDF_PriceReviewMaintenanceAllAccounts";
import Core_MDF_Search_Accounts_cc from '@salesforce/label/c.Core_MDF_Search_Accounts_cc';


const PRODUCT_COLUMNS = [{
    type: 'text',
    fieldName: 'productName',
    label: 'Product Family',
    title: 'Product Family',
}];

const SELECTED_PRODUCT_COLUMNS = [{
    type: 'text',
    fieldName: 'Name',
    label: Core_MDF_SelectedProductColumn,
    title: Core_MDF_SelectedProductColumn,
}];
export default class Core_MDF_AccountProductMapping extends LightningElement {
    @track selectedAccount;
    @track showProducts = false;
    @track isLoaded = false;
    @track productData = [];
    @track isproductDataAvailable;
    @track showTableHeader = false; // if showTableHeader is true then for custom tree grid column header will be available
    @track showCheckbox = true;     // if showCheckbox is true then in custom tree grid checkbox will be available for all rows
    @track disableAll = true;
    @track gridColumns = PRODUCT_COLUMNS;
    @track tableColumns = SELECTED_PRODUCT_COLUMNS;
    @track dataForTable;
    productsOnLoad = [];
    @track isError = false;
    @track errorMessage;
    @track programFieldValues;
    @track isAllAccountChecked = false;
    @track selectedProducts = [];
    @track isProductError = false;
    searchEnabled = true;
    saveBtnLabelTxt = Core_MDF_Save;
    cancelBtnLabelTxt = Core_MDF_Cancel;
    programFieldLabel = Core_MDF_Program;
    searchAccountsLabel = Core_MDF_Search_Accounts_cc;    
    accountQueryFilter;
    prodDataMap = new Map();
    showAccount = true;

    isAccountlookupDisabled = false;
    connectedCallback() {
        hasAccessToPriceReviewerMaintanceTab()
            .then((data) => {

                console.log('has access '+data)
                this.isError = !data;
                this.errorMessage = 'User does not have access to this page.';
            })
            .catch((error)=> {
                console.log('Core_MDF_AccountProductMapping : Error : ',error.message);
            });
    }
    
    @wire(getObjectInfo, { objectApiName: ACCOUNTPRODUCTMAPPING_OBJECT })
    accProdMapObjInfo;

    @wire(getPicklistValues, { recordTypeId: '$accProdMapObjInfo.data.defaultRecordTypeId', fieldApiName: Core_MDF_Program_Account_Map__c})
    programFields({data,error}){
        if(data){
            this.programFieldValues = data.values;            
        }
        if(error){
            console.log(`Picklist values error ${error}`);
        }
    }

    handleSelectedAccount(event) {
        this.isLoaded = true;
        this.searchEnabled = true;
        this.selectedAccount = event.detail;
        if(event.detail === null) {
            this.showProducts = false;
            this.isLoaded = false;
        } else {
            this.getAccProdMapping();
        }
    }

    handleSelctedProgram(event){
        this.selectedProgram = event.target.value;
        this.selectedProgramLabel = event.target.options.find(opt => opt.value === event.target.value).label;
        if(this.template.querySelector('c-core_-m-d-f_-parent-account-lookup') != null){
        this.template.querySelector('c-core_-m-d-f_-parent-account-lookup').handleRemovePill(event);
        }
        this.accountQueryFilter = ` RecordType.Name='CoMarketing' AND Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketingActive__c = true AND Core_MDF_Channel_Program__r.Name='${this.selectedProgramLabel}' `;
    }

    get allAccountVisible() {
        return hasPermission;
      }

    getAccProdMapping() {
        let accIds = [];
        accIds = [...accIds, this.selectedAccount];
        getAccountProductMapping({accountIds : accIds, program : this.selectedProgram})
            .then((result) => {
                let oldProdIdSet = [];
                this.selectedProducts = result;
                result = result[this.selectedAccount];
                if(result !== undefined && result !== null && result !== '') {
                    for(let m=0;m<result.length;m++) {
                        if(!oldProdIdSet.includes(result[m].Core_MDF_Product__c)) {
                            oldProdIdSet = [...oldProdIdSet, result[m].Core_MDF_Product__c];
                        }
                    }
                }
                //let prodIdSet = new Set(oldProdIdSet);
                getProducts()
                    .then(data => {
                        if(data) {
                            let dataWrapper = [];
			    let childDataWrapper = [];
                            let selectedProds = [];
                            let prooductDataMap = new Map();
                            let prodIdSet = new Set(oldProdIdSet);
                            let productFamilyProdsMap = new Map();
                            let prodFamilyisCheckedMap = new Map();
                            var parentCheckedFlag;
                            console.time("spif");
                            if(this.allSelectedProductIds == undefined || this.allSelectedProductIds == null || this.allSelectedProductIds == ''){
                                this.allSelectedProductIds = [];
                            }
                            data.forEach(item =>{
                                let childObj = {};
                                childObj.isChecked = false;
                                childObj = Object.assign(childObj,item);                      
                                let prodInSet = prodIdSet.has(childObj.Id);
                                if(prodInSet){
                                    childObj.isChecked = true; 
                                    selectedProds = [...selectedProds, childObj];
                                    if(prodFamilyisCheckedMap.has(childObj.Core_Product_Family__c)){
                                        prodFamilyisCheckedMap.get(childObj.Core_Product_Family__c).push(childObj.Id);
                                    }else{
                                        var selectedChildIds = new Array();
                                        selectedChildIds.push(childObj.Id);
                                        prodFamilyisCheckedMap.set(childObj.Core_Product_Family__c,selectedChildIds);
                                    }
                                }
                                if(productFamilyProdsMap.has(childObj.Core_Product_Family__c)){
                                    productFamilyProdsMap.get(childObj.Core_Product_Family__c).push(childObj);
                                }else{
                                    var childArr = new Array();
                                    childArr.push(childObj);
                                    productFamilyProdsMap.set(childObj.Core_Product_Family__c,childArr);
                                }
                            });
                            productFamilyProdsMap.forEach((value,key) =>{
                                if((value?.length == prodFamilyisCheckedMap.get(key)?.length)){
                                    parentCheckedFlag = true;
                                }else{parentCheckedFlag = false; }
                                let obj = {};
                                obj.name = `${key}`;
                                obj.productName = `${key}`;
                                obj.productFamily = `${key}`;
                                obj.parentRow = `${key}`;
                                obj.isChecked = parentCheckedFlag;
                                obj._children = value;

                                if(obj._children != null && obj._children.length > 0) {
                                    dataWrapper = [...dataWrapper, obj];
                                }
                            });
                            console.timeEnd("spif");
                            this.dataForTable = selectedProds;
			    this.selectedRecords = selectedProds;
                            this.productsOnLoad = selectedProds;
                            this.productData = dataWrapper;
                            this.isproductDataAvailable = true;
                            this.showProducts = true;
                            this.isLoaded = false;
                        }
                    })
                    .catch(e => {
                        console.log('Core_MDF_AccountProductMapping : Error : ',e.message);
                    });
                //}                        
            //}
        })
        .catch((error) => {
            console.log('Core_MDF_AccountProductMapping : Error : ', error.message);
        });
    }

    customSave() {
        let selectedProdIds = [];
        this.isLoaded = true;
        this.showProducts = false;
        let uncheckedProducts = [];
        let uncheckedProdIds = [];
        if(this.selectedRecords){
            for(let i=0; i< this.selectedRecords.length; i++) {
                selectedProdIds = [...selectedProdIds, this.selectedRecords[i].Id ];
            }
        }

        if(this.productsOnLoad != null && this.productsOnLoad.length > 0){
            uncheckedProducts = this.productsOnLoad.filter(value => !selectedProdIds.includes(value.Id));
            uncheckedProducts.forEach(element => {
                uncheckedProdIds.push(element.Id);
            });
        }
        if(this.isProductError == false){
            let obj={};
            obj.accountId = this.selectedAccount != null ? this.selectedAccount : '';
            obj.selectedProdIds = selectedProdIds;
            obj.program = this.selectedProgram;
            obj.isAllAccount = this.isAllAccountChecked;
            obj.uncheckedProdIds = uncheckedProdIds;
            obj = JSON.parse(JSON.stringify(obj));
            console.log('obj-->',JSON.stringify(obj));
            saveAccProdMapping({details: JSON.stringify(obj)})
                .then((result) => {
                    console.log('test');
                    this.getAccProdMapping();
                    this.handleEdit();
                    var msg = this.isAllAccountChecked ? 'The request is being processed. You will be notified on completion.' :
                                                          'Account Product Mappings are saved';
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: msg,
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);


                })
                .catch((error) => {
                    console.log('Core_MDF_AccountProductMapping : Error : ', error.message);
                    this.showProducts = true;
                    this.isLoaded = false;
                });
            }
    }

    handleCancel() {
        window.location.reload();
    }

    handleEdit() {
        if(this.disableAll === true) {
            this.disableAll = false;
            this.isProductError = false;
        } else {
            this.disableAll = true;
        }
    }

    getSelectedRecords(event) {
        this.selectedRecords = event.detail.selectedRows;        
        this.dataForTable = this.selectedRecords;
    }

    //method called on change of All Account checkbox
    handleAllAccount(event){
        let isChecked = event.target.checked;
        this.showProducts = false;
        if(isChecked == true && this.selectedProgram != null){
            this.isLoaded = true;
            if(this.selectedAccount != null){
                this.selectedAccount = null;
            }
            this.showAccount = false;
            this.getAccProdMapping();
            this.searchEnabled = true;
            this.isAllAccountChecked = true;
        }
        else{
            isChecked= false;
            this.showAccount = true;
            this.isLoaded = false;
            this.isAllAccountChecked = false;
        }
    }
    
}