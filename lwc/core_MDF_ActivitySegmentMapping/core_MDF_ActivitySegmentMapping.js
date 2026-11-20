import { LightningElement, track,api } from 'lwc'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { utilityModule} from 'c/core_MDF_utilityModule';
import getSegmentValues from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.getSegmentValues'; 
import getProductMappingForSegment from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.getProductMappingForSegment';
import getFieldsToDisplay from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.getFieldsToDisplay';
import Core_MDF_BTN_Add_Details from "@salesforce/label/c.Core_MDF_BTN_Add_Details";
import Core_MDF_SegPiclistPlaceholder from "@salesforce/label/c.Core_MDF_SegPiclistPlaceholder";
import Core_MDF_SelectedProductColumn from "@salesforce/label/c.Core_MDF_SelectedProductColumn";
import Core_MDF_Cancel from "@salesforce/label/c.Core_MDF_Cancel";
import Core_MDF_Save from "@salesforce/label/c.Core_MDF_Save";
import Core_MDF_BTN_Add from "@salesforce/label/c.Core_MDF_BTN_Add";
import Core_MDF_addBtn_Sales_HelpText from "@salesforce/label/c.Core_MDF_addBtn_Sales_HelpText";
import Core_MDF_addBtn_Purchase_HelpText from "@salesforce/label/c.Core_MDF_addBtn_Purchase_HelpText";
import Core_MDF_addBtn_Seller_HelpText from "@salesforce/label/c.Core_MDF_addBtn_Seller_HelpText";
import Core_MDF_addBtn_Buyer_HelpText from "@salesforce/label/c.Core_MDF_addBtn_Buyer_HelpText";
import Core_MDF_ErrOnNoProductSelection from "@salesforce/label/c.Core_MDF_ErrOnNoProductSelection";
import Core_MDF_SegmentLabel from "@salesforce/label/c.Core_MDF_SegmentLabel";

import Core_MDF_Estimated_Share_of_SPIF from "@salesforce/label/c.Core_MDF_Estimated_Share_of_SPIF";
import Core_MDF_Estimated_Share_of_SPIF_amt_c_Sales_HelpText from "@salesforce/label/c.Core_MDF_Estimated_Share_of_SPIF_amt_c_Sales_HelpText";
import Core_MDF_Estimated_Share_of_SPIF_amt_c_Purchase_HelpText from "@salesforce/label/c.Core_MDF_Estimated_Share_of_SPIF_amt_c_Purchase_HelpText";
import Core_MDF_Estimated_Share_of_SPIF_amt_c_Seller_HelpText from "@salesforce/label/c.Core_MDF_Estimated_Share_of_SPIF_amt_c_Seller_HelpText";	
import Core_MDF_Maximum_Bundled_Volume from "@salesforce/label/c.Core_MDF_Maximum_Bundled_Volume";
import Core_MDF_Volume_HelpText from "@salesforce/label/c.Core_MDF_Volume_HelpText";
import Core_MDF_Maximum_Cost_of_Bundle from "@salesforce/label/c.Core_MDF_Maximum_Cost_of_Bundle";
import Core_MDF_Maximum_Cost_of_Bundle_HelpText from "@salesforce/label/c.Core_MDF_Maximum_Cost_of_Bundle_HelpText";
import Core_MDF_Maximum_Cost_of_Bundle_Buyer_HelpText from "@salesforce/label/c.Core_MDF_Maximum_Cost_of_Bundle_Buyer_HelpText";
import Core_MDF_Minimum_Forecast_Volume from "@salesforce/label/c.Core_MDF_Minimum_Forecast_Volume";
import Core_MDF_SPIF_Amount from "@salesforce/label/c.Core_MDF_SPIF_Amount";
import Core_MDF_SPIF_Amount_HelpText from "@salesforce/label/c.Core_MDF_SPIF_Amount_HelpText";
//import Core_MDF_Num_of_Potential_Winners from "@salesforce/label/c.Core_MDF_Num_of_Potential_Winners";
//import Core_MDF_Num_of_Expected_Participants from "@salesforce/label/c.Core_MDF_Num_of_Expected_Participants";
import Core_MDF_SPIF_Notes from "@salesforce/label/c.Core_MDF_SPIF_Notes";
import Core_MDF_PartnerCommunityIdentifier from "@salesforce/label/c.Core_MDF_PartnerCommunityIdentifier";
import Core_MDF_ValueTooLargeMsg from "@salesforce/label/c.Core_MDF_ValueTooLargeMsg";
import Core_MDF_EstimatedShareOfSPIFMaxFieldValue from "@salesforce/label/c.Core_MDF_EstimatedShareOfSPIFMaxFieldValue";
import Core_MDF_EstimatedShareOfSPIFMaxFieldLength from "@salesforce/label/c.Core_MDF_EstimatedShareOfSPIFMaxFieldLength";
import Core_MDF_NoProductsErrorMsg from "@salesforce/label/c.Core_MDF_NoProductsErrorMsg";
import Core_MDF_ProdsAlreadySelMsg from "@salesforce/label/c.Core_MDF_ProdsAlreadySelMsg";
import Core_MDF_NegativeInputWarningMsg from "@salesforce/label/c.Core_MDF_NegativeInputWarningMsg";
import Core_MDF_Incentive_NegativeInput_Error_Msg from "@salesforce/label/c.Core_MDF_Incentive_NegativeInput_Error_Msg";
import Core_MDF_Search from '@salesforce/label/c.Core_MDF_Search';
import Core_MDF_Estimated_Share_of_SPIF_Offer_Target_helptext from "@salesforce/label/c.Core_MDF_Estimated_Share_of_SPIF_Offer_Target_helptext";
import Core_MDF_Spif_Amount_Offer_Target_helptext from "@salesforce/label/c.Core_MDF_Spif_Amount_Offer_Target_helptext";

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
    //label: 'Selected Products',
    //title: 'Selected Products',
}];
    
export default class Core_MDF_ActivitySegmentMapping extends LightningElement {

    @api program;
    @api activityCategory;
    @api activityType;
    @api selectedSegment;
    @api segmentNameList;
    @api isEdit;
    @api isLoaded = false;              // if isLoaded is true then spinner is shown
    @api isCommunity;
    @api allSelectedProductIds;
    @api counter;
    @api accountId;
    @api name;

    @track selectedRecords;
    @track showSegmentForm = false;     // if showSegmentForm is true then segment create form is shown
    @track selectedPicklist;    
    @track productData = [];
    @track isproductDataAvailable = false;
    @track isproductDataNotAvailable = false;
    @track gridColumns = PRODUCT_COLUMNS;
    @track tableColumns = SELECTED_PRODUCT_COLUMNS;
    @track segmentPicVals = [];
    @track segmentPicklistOptions = [];
    @track segmentFieldList = [];
    //@track selectedProductsIds = [];    
    @track dataForTable;
    @track productIdSet = [];
    @track productsNameStr;
    @track productsFamilyNameStr;
    @track showTableHeader = false; // if showTableHeader is true then for custom tree grid column header will be available
    @track showCheckbox = true;     // if showCheckbox is true then in custom tree grid checkbox will be available for all rows
    @track addDetailsDisabled = false;  // if addDetailsDisabled is true then Add Details button will be disabled

    Utility = new utilityModule();
    // to hold the visibility of extra fields
    @track visibilityObj = {
        Core_MDF_SPIF_Notes_internal_only_txt__c : false,
        Core_MDF_Maximum_Bundled_Volume_nbr__c  : false,
        Core_MDF_Maximum_Cost_of_Bundle_nbr__c  : false,
        Core_MDF_Estimated_Share_of_SPIF_amt__c  : false,
        Core_MDF_Minimum_Forecast_Volume_nbr__c  : false,
        Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c  : false                        
    };

    // to hold the values of extra fields
    @track inputValueObject = {
        Core_MDF_SPIF_Notes_internal_only_txt__c : '',
        Core_MDF_Maximum_Bundled_Volume_nbr__c  : null,
        Core_MDF_Maximum_Cost_of_Bundle_nbr__c  : null,
        Core_MDF_Estimated_Share_of_SPIF_amt__c  : null,
        Core_MDF_Minimum_Forecast_Volume_nbr__c  : null,
        Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c  : null                        
    };

    @track noProductsErrFlag = false;

    /* Assigning Custom Label values to variables */
    addDetailBtnLabel = Core_MDF_BTN_Add_Details;
    segmentPicklistPlaceholder = Core_MDF_SegPiclistPlaceholder;
    cancelBtnLabel = Core_MDF_Cancel;
    saveBtnLabel = Core_MDF_Save;
    addBtnLabel = Core_MDF_BTN_Add;
    addBtnLabelSales = Core_MDF_addBtn_Sales_HelpText;
    addBtnLabelPurchase = Core_MDF_addBtn_Purchase_HelpText;
    addBtnLabelSales=Core_MDF_addBtn_Seller_HelpText;
    addBtnLabelSales=Core_MDF_addBtn_Buyer_HelpText;
    errOnNoProdSelection = Core_MDF_ErrOnNoProductSelection;
    segmentLabel = Core_MDF_SegmentLabel;

    estimatedShareOfSPIF = Core_MDF_Estimated_Share_of_SPIF;
    maximumBundledVolume = Core_MDF_Maximum_Bundled_Volume;
    VolumeHelpText = Core_MDF_Volume_HelpText;
    spifAmountHelpText = Core_MDF_SPIF_Amount_HelpText;
    maximumCostOfBundleHelpText = Core_MDF_Maximum_Cost_of_Bundle_HelpText;
    maximumCostOfBundleBuyerHelpText= Core_MDF_Maximum_Cost_of_Bundle_Buyer_HelpText;
    estimatedShareOfSPIFSalesHelpText  = Core_MDF_Estimated_Share_of_SPIF_amt_c_Sales_HelpText;
    estimatedShareOfSPIFPurchaseHelpText = Core_MDF_Estimated_Share_of_SPIF_amt_c_Purchase_HelpText;
    estimatedShareOfSPIFSellerHelpText =Core_MDF_Estimated_Share_of_SPIF_amt_c_Seller_HelpText;
    maximumCostOfBundle = Core_MDF_Maximum_Cost_of_Bundle;
    minimumForecastVolume = Core_MDF_Minimum_Forecast_Volume;
    spifAmount = Core_MDF_SPIF_Amount;
    spifNotesStr = Core_MDF_SPIF_Notes;
    partnercenterStr = Core_MDF_PartnerCommunityIdentifier;
    lengthErrMsg = Core_MDF_ValueTooLargeMsg;
    estimatedShareOfSPIFMaxFieldValue = parseFloat(Core_MDF_EstimatedShareOfSPIFMaxFieldValue);
    estimatedShareOfSPIFMaxFieldLength = parseInt(Core_MDF_EstimatedShareOfSPIFMaxFieldLength);
    noProductsErrorMsg = Core_MDF_NoProductsErrorMsg;
    prodsAlreadySelMsg = Core_MDF_ProdsAlreadySelMsg;
    negativeInputWarningMsg = Core_MDF_NegativeInputWarningMsg;
    decimalNegativeEntryMsg = Core_MDF_Incentive_NegativeInput_Error_Msg;

    search = Core_MDF_Search;


    //Product Search Selection
    searchEnabled;
    showHelpText;
    
    connectedCallback() {
        /*This is for initialisation purpose*/
        let isCommunity = true;
        if(this.segmentNameList === undefined || this.segmentNameList === null || this.segmentNameList === '') {
            this.segmentNameList = [];
        }
        if(this.isEdit === undefined || this.isEdit === null || this.isEdit === '') {
            this.isEdit = false;
        }

        // if activity type = 'Buyer - Other' OR 'Seller - Other' OR 'Seller - Target SPIF' then Core_MDF_Estimated_Share_of_SPIF_amt__c field will not be disabled
        if(this.activityType == 'Buyer - Other' || this.activityType =='Seller - Other' || this.activityType =='SPIF - Other' || 
            this.activityType =='Offer - Other' || this.activityType == 'Outcome-Based'){
            this.disableInput = false;
        }else{
            this.disableInput = true;
        }

        if(this.activityType == 'Seller - Per Unit SPIF' || this.activityType =='Seller - Other'  ){
            this.btnHelptxtActCat = Core_MDF_addBtn_Sales_HelpText;
            this.estimatedShareOfSPIFActCat = Core_MDF_Estimated_Share_of_SPIF_amt_c_Sales_HelpText;
        }else if (this.activityType == 'SPIF - Target' || this.activityType =='SPIF - Volume' || this.activityType =='SPIF - Other' || this.activityType == 'Outcome-Based'){
            this.btnHelptxtActCat = Core_MDF_addBtn_Seller_HelpText;
            this.estimatedShareOfSPIFActCat = Core_MDF_Estimated_Share_of_SPIF_amt_c_Seller_HelpText;
        }else if(this.activityType == 'Offer - Bundle' || this.activityType =='Offer - Other' ){
            this.btnHelptxtActCat = Core_MDF_addBtn_Buyer_HelpText;
            this.maximumCostOfBundleHelpText = Core_MDF_Maximum_Cost_of_Bundle_Buyer_HelpText;
        }else if(this.activityType == 'Offer - Target'){
            this.btnHelptxtActCat = Core_MDF_addBtn_Buyer_HelpText;
            this.estimatedShareOfSPIFActCat = Core_MDF_Estimated_Share_of_SPIF_Offer_Target_helptext;
            this.spifAmountHelpText = Core_MDF_Spif_Amount_Offer_Target_helptext;
        }
        else{
            this.btnHelptxtActCat = Core_MDF_addBtn_Purchase_HelpText;
            this.estimatedShareOfSPIFActCat = Core_MDF_Estimated_Share_of_SPIF_amt_c_Purchase_HelpText;
            this.maximumCostOfBundleHelpText =Core_MDF_Maximum_Cost_of_Bundle_HelpText;
        }
        
        this.getSegmentPicklistValues();

        // Assugning values to elements in edit mode
        if(this.selectedSegment !== undefined && this.selectedSegment !== null) {
            this.selectedPicklist = this.selectedSegment.Core_MDF_Segment_Name_nm__c;
            //this.selectedProductsIds = this.selectedSegment.productIdSet;  
            this.productIdSet = this.selectedSegment.productIdSet;
            //Akanksha
            //this.dataForTable = this.selectedSegment.selectedRecords;
            this.productsFamilyNameStr = this.selectedSegment.productsFamilyNameStr;
            this.productsNameStr = this.selectedSegment.productsNameStr;
            this.selectedRecords = this.selectedSegment.selectedRecords;
            this.segmentCreateForm();
            this.getProducts(this.selectedPicklist);
        }
    }

    /*
     * on load - to get segment picklist values
     */
    getSegmentPicklistValues() {
        getSegmentValues({})
            .then(result => {
                this.segmentPicVals = result;
            })
            .catch(e => {
                console.log('Error in getSegmentValues. Error - ' + e.message);
            })
    }

    /*
     * on click of Add Details button - to open create form
     */
    segmentCreateForm() {    
        this.showSegmentForm = true;
        this.isLoaded = true;
         //Localization fix changes
        if(this.segmentPicVals!== undefined && this.segmentPicVals !== null) {
            let optionsUpdated = []
            for (var i = 0; i < this.segmentPicVals.length; i++) {
                //Localization fix changes
              //if(!this.segmentNameList.includes(this.segmentPicVals[i].segmentApi)) {
                    optionsUpdated.push({
                        class: "optionClass",
                        label: this.segmentPicVals[i].segmentLabel,
                        value: this.segmentPicVals[i].segmentApi
                    });
                //}
            }
            this.segmentPicklistOptions = optionsUpdated;   
        }

        getFieldsToDisplay({ program: this.program, activityType: this.activityType })
            .then(result => {

                this.segmentFieldList = result.SegmentFields;
               this.isCommunity = result.UserType === 'PowerPartner' ? true :false;
                if(this.activityType == 'Buyer - Other' || this.activityType =='Seller - Other' || this.activityType =='SPIF - Other'
                     || this.activityType =='Offer - Other' || this.activityType == 'Outcome-Based'){
                    this.disableInput = false;
                }else{
                    this.disableInput = true;
                }

                if(this.activityType == 'Seller - Per Unit SPIF' || this.activityType =='Seller - Other'  ){
                    this.btnHelptxtActCat = Core_MDF_addBtn_Sales_HelpText;
                    this.estimatedShareOfSPIFActCat = Core_MDF_Estimated_Share_of_SPIF_amt_c_Sales_HelpText;
                }else if (this.activityType == 'SPIF - Target' || this.activityType =='SPIF - Volume' || this.activityType =='SPIF - Other' || this.activityType == 'Outcome-Based'){
                    this.btnHelptxtActCat = Core_MDF_addBtn_Seller_HelpText;
                    this.estimatedShareOfSPIFActCat = Core_MDF_Estimated_Share_of_SPIF_amt_c_Seller_HelpText;
                }else if(this.activityType == 'Offer - Bundle' || this.activityType =='Offer - Other' ){
                    this.btnHelptxtActCat = Core_MDF_addBtn_Buyer_HelpText;
                    this.maximumCostOfBundleHelpText = Core_MDF_Maximum_Cost_of_Bundle_Buyer_HelpText;
                    this.estimatedShareOfSPIFActCat = Core_MDF_Estimated_Share_of_SPIF_amt_c_Purchase_HelpText;
                }else if(this.activityType == 'Offer - Target'){
                    this.btnHelptxtActCat = Core_MDF_addBtn_Buyer_HelpText;
                    this.estimatedShareOfSPIFActCat = Core_MDF_Estimated_Share_of_SPIF_Offer_Target_helptext;
                    this.spifAmountHelpText = Core_MDF_Spif_Amount_Offer_Target_helptext;
                }
                else{
                    this.btnHelptxtActCat = Core_MDF_addBtn_Purchase_HelpText;
                    this.estimatedShareOfSPIFActCat = Core_MDF_Estimated_Share_of_SPIF_amt_c_Purchase_HelpText;
                    this.maximumCostOfBundleHelpText =Core_MDF_Maximum_Cost_of_Bundle_HelpText;
                }

                this.visibilityObj = {
                    Core_MDF_SPIF_Notes_internal_only_txt__c : false,
                    Core_MDF_Maximum_Bundled_Volume_nbr__c  : false,
                    Core_MDF_Maximum_Cost_of_Bundle_nbr__c  : false,
                    Core_MDF_Estimated_Share_of_SPIF_amt__c  : false,
                    Core_MDF_Minimum_Forecast_Volume_nbr__c  : false,
                    Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c  : false,
                    Core_MDF_SPIF_Notes_txt__c : false                        
                };
            
                this.inputValueObject = {
                    Core_MDF_SPIF_Notes_internal_only_txt__c : '',
                    Core_MDF_Maximum_Bundled_Volume_nbr__c  : null,
                    Core_MDF_Maximum_Cost_of_Bundle_nbr__c  : null,
                    Core_MDF_Estimated_Share_of_SPIF_amt__c  : null,
                    Core_MDF_Minimum_Forecast_Volume_nbr__c  : null,
                    Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c  : null,
                    Core_MDF_SPIF_Notes_txt__c : ''                        
                };

                let oldValues;                
                if(this.selectedSegment !== null && this.selectedSegment !== undefined) {
                    oldValues = this.selectedSegment.extraFieldsObj;    
                }   
                for(let i=0; i<this.segmentFieldList.length; i++) {
                    if(!this.isCommunity && this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_internal_only_txt__c'){
                        this.visibilityObj.Core_MDF_SPIF_Notes_internal_only_txt__c = true;
                    }
                    if(this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_txt__c'){ //this.isCommunity &&
                        this.visibilityObj.Core_MDF_SPIF_Notes_txt__c = true;
                    }
                    if(this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Maximum_Bundled_Volume_nbr__c'){
                        this.visibilityObj.Core_MDF_Maximum_Bundled_Volume_nbr__c = true;
                    }
                    if(this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Maximum_Cost_of_Bundle_nbr__c'){
                        this.visibilityObj.Core_MDF_Maximum_Cost_of_Bundle_nbr__c = true;
                    }
                    if(this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Estimated_Share_of_SPIF_amt__c'){
                        this.visibilityObj.Core_MDF_Estimated_Share_of_SPIF_amt__c = true;
                    }
                    if(this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Minimum_Forecast_Volume_nbr__c'){
                        this.visibilityObj.Core_MDF_Minimum_Forecast_Volume_nbr__c = true;
                    }
                    if(this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c'){
                        this.visibilityObj.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = true;
                    }
                    if(this.isEdit) {
                        if(this.isCommunity && this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_internal_only_txt__c') {
                            continue;
                        }
                       this.inputValueObject[this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c] = oldValues[this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c]
                    }                                     
                }
                this.isLoaded = false;          
            })
            .catch(e => {
                console.log('Error in getFieldsToDisplay. Error - ' + e.message);
            })
    }

    /*
     * on click of cancel button - to close create form
     */
    @api closeModal() {       
        this.showSegmentForm = false;
        this.clearForm();
    }

    /*
     * on change of segment picklist - to call getProducts method
     */
    handleChange(event) {
        this.isLoaded = true;
        this.dataForTable = undefined;
        this.selectedRecords = undefined;
        this.selectedPicklist = event.target.value;
        this.noProductsErrFlag = false;
        this.getProducts(this.selectedPicklist);
    }

    /*
     * To get products after selecting segment
     */
     getProducts(selectedSegment) {
        this.productData = [];
        this.isproductDataAvailable = false;
        this.isproductDataNotAvailable = false;
        this.selSegment = selectedSegment;
        this.activityProgram = this.program.replace(/[-]/g, "");
        this.searchEnabled = true;
        this.showHelpText = true;
        getProductMappingForSegment({ segment : this.selSegment, accountId: this.accountId, program: this.activityProgram})
            .then(data => {                
                if(data) {
                    if(data.length > 0) {
                        this.noProductsErrFlag = false;
                    } else {
                        this.noProductsErrFlag = true;
                    }
                    let dataWrapper = [];
                    let childDataWrapper = [];
                    let selectedProds = [];
                    let prooductDataMap = new Map();
                    let prodIdSet = new Set(this.productIdSet);
                    let productFamilyProdsMap = new Map();
                    let prodFamilyisCheckedMap = new Map();
                    var parentCheckedFlag;
                    if(this.allSelectedProductIds == undefined || this.allSelectedProductIds == null || this.allSelectedProductIds == ''){
                        this.allSelectedProductIds = [];
                    }
                    data.forEach(item =>{
                        let childObj = {};
                        childObj.isChecked = false;
                        childObj = Object.assign(childObj,item);                      
                        let prodInSet = prodIdSet.has(childObj.Id);
                        if(this.isEdit && prodInSet){
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
                        if((this.isEdit && prodInSet) || !(this.allSelectedProductIds.indexOf(childObj.Id) > -1)){ 
                            if(productFamilyProdsMap.has(childObj.Core_Product_Family__c)){
                                productFamilyProdsMap.get(childObj.Core_Product_Family__c).push(childObj);
                            }else{
                                var childArr = new Array();
                                childArr.push(childObj);
                                productFamilyProdsMap.set(childObj.Core_Product_Family__c,childArr);
                            }
                        }                        
                    });
                    productFamilyProdsMap.forEach((value,key) =>{
                        if(this.isEdit && (value?.length == prodFamilyisCheckedMap.get(key)?.length)){
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
                    this.dataForTable = selectedProds;
                    this.productData = dataWrapper;
                    if(this.productData !== undefined && this.productData !== null && this.productData !== '' && this.productData.length > 0) {
                        this.isproductDataAvailable = true;
                        this.isproductDataNotAvailable = false;
                    } else {
                        this.isproductDataNotAvailable = true;
                        this.isproductDataAvailable = false;
                    }
                    this.isLoaded = false;
                }
            })
            .catch(e => {
                console.error('Error in fetching products. Error - ',e.message);
            })
    }
    
    /*
     * On click checkbox in custom tree grid - to get selected records
     */
    getSelectedRecords(event) {      
        this.selectedRecords = event.detail.selectedRows;        
        let selectedProducts = [];
        this.productIdSet = [];
        this.productsNameStr = '';
        this.productsFamilyNameStr = '';
        if(this.selectedRecords != undefined && this.selectedRecords != null) {
            for(let i=0;i<this.selectedRecords.length;i++) {
                this.productIdSet = [...this.productIdSet, this.selectedRecords[i].Id];
                if(!this.productsNameStr.includes(this.selectedRecords[i].Name)) {
                    this.productsNameStr +=  this.selectedRecords[i].Name + '\n';
                }
                if(!this.productsFamilyNameStr.includes(this.selectedRecords[i].Core_Product_Family__c)) {
                    this.productsFamilyNameStr += this.selectedRecords[i].Core_Product_Family__c + '\n';
                }
            }
        }
        this.dataForTable = this.selectedRecords;        
    }
    @api
    isFormValid() {
        this.isValid = false;
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true); 

        const isPickValSelected = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (isInputsCorrect && isPickValSelected){
           this.isValid = true;
        }

        return this.isValid;

    }
    /*
     * On click of Save or Add button preparing segment object and passing to parent component to add into segment list
     */
    addSegment() {           
         const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true); 
        
        const isPickValSelected = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true); 

        if (isInputsCorrect && isPickValSelected){  
	    //Localization fix changes
	    let selectedSegmentLabel;
            for(let i=0; i< this.segmentPicVals.length; i++) {
                if(this.segmentPicVals[i].segmentApi == this.selectedPicklist) {
                    selectedSegmentLabel = this.segmentPicVals[i].segmentLabel;
                    break;
                }
            }
            let obj = {
                Core_MDF_Segment_Name_nm__c : this.selectedPicklist,
                selectedRecords : this.selectedRecords,
                Segment_Label : selectedSegmentLabel
            };
            if(this.selectedSegment !== undefined && this.selectedSegment !== null && this.selectedSegment !== '' && this.selectedSegment.segmentId ) {
                obj.segmentId = this.selectedSegment.segmentId;
            } else {
                obj.segmentId = this.selectedPicklist+'$'+this.counter;
            }
            let extraFieldsObj = {
                Core_MDF_Estimated_Share_of_SPIF_amt__c:null,
                Core_MDF_Maximum_Bundled_Volume_nbr__c:null,
                Core_MDF_Maximum_Cost_of_Bundle_nbr__c:null,
                Core_MDF_Minimum_Forecast_Volume_nbr__c:null,
                Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c:null,
                Core_MDF_SPIF_Notes_internal_only_txt__c:'',
                Core_MDF_SPIF_Notes_txt__c:''
            };
            let inputElements = this.template.querySelectorAll("lightning-input");
            inputElements.forEach(element => {
                if (element != null) {
                    extraFieldsObj[element.name] = element.value;
                }
            });
            obj["extraFieldsObj"] = extraFieldsObj;         

            if(this.selectedRecords == undefined || this.selectedRecords == null || this.selectedRecords.length == 0) {
                this.showToast('ERROR', this.errOnNoProdSelection, 'error');      
                console.log('Error : ', this.errOnNoProdSelection);          
                return;
            }            
            if(((extraFieldsObj != undefined && extraFieldsObj != null && extraFieldsObj["Core_MDF_Estimated_Share_of_SPIF_amt__c"] != null && extraFieldsObj["Core_MDF_Estimated_Share_of_SPIF_amt__c"] != undefined ) && (extraFieldsObj["Core_MDF_Estimated_Share_of_SPIF_amt__c"].length > this.estimatedShareOfSPIFMaxFieldLength || extraFieldsObj["Core_MDF_Estimated_Share_of_SPIF_amt__c"].includes('e') || extraFieldsObj["Core_MDF_Estimated_Share_of_SPIF_amt__c"].includes('E') || extraFieldsObj["Core_MDF_Estimated_Share_of_SPIF_amt__c"] > this.estimatedShareOfSPIFMaxFieldValue))) {
                this.showToast('ERROR', this.estimatedShareOfSPIF + ' ' + this.lengthErrMsg, 'error');      
                console.log('Error : Length > 16  ');          
                return;
            }    
            obj["productIdSet"] = this.productIdSet;    
            obj['productsNameStr'] = this.productsNameStr;
            obj['productsFamilyNameStr'] = this.productsFamilyNameStr;
            obj['visibilityObj'] = this.visibilityObj;
            const addsegmentEvent = new CustomEvent('addsegment', { detail: { obj } });
            this.dispatchEvent(addsegmentEvent);
            if(this.isEdit) {
                //this.closeEditSection();
                this.segmentCreateForm();
                this.getProducts(this.selectedPicklist);
                /*const closesectionEvent = new CustomEvent('collapsesection');
                this.dispatchEvent(closesectionEvent);*/
								const closesectionEvent = new CustomEvent('hideeditsection');
                this.dispatchEvent(closesectionEvent);
            } else {
                this.closeModal();
            }
        }
    }

    /*
     * On click of cancel button load old values into form and collapse current section
     */
    closeEditSection() {        
        this.selectedPicklist = this.selectedSegment.Core_MDF_Segment_Name_nm__c;      
        this.productIdSet = this.selectedSegment.productIdSet;  
        this.dataForTable = this.selectedSegment.selectedRecords;
        this.selectedRecords = this.selectedSegment.selectedRecords;
        this.segmentCreateForm();
        this.getProducts(this.selectedPicklist);
        const closesectionEvent = new CustomEvent('collapsesection');
        this.dispatchEvent(closesectionEvent);
    }

    /*
     * To clear variable values
     */
    clearForm() {
        this.selectedPicklist = '';  
        this.productData = [];
        this.isproductDataAvailable = false;     
        this.isproductDataNotAvailable = false;
        this.selectedRecords = undefined;
        this.dataForTable = undefined;
    }

    /*
     * To show toast message
     */
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    /*
     * To assign the element value to inputValueObject and calculate values for dependant fields
     */
    calculateValue(event) {        
        let inputElements = this.template.querySelectorAll("lightning-input");
        inputElements.forEach(element => {
            if(element != null){
               const result = this.Utility.sanitize(element.value);
                let fieldValue = element.name;
                    this.template.querySelectorAll('[data-id="' + fieldValue + '"]').forEach(each => {
                        each.value = result;
                    });
                    this.inputValueObject[fieldValue] = result;
            }
        }); 
       
        this.inputValueObject = JSON.parse(JSON.stringify(this.inputValueObject));
        
        if((this.activityType == 'Seller - Per Unit SPIF' || this.activityType == 'Seller - Target SPIF' || this.activityType =='Seller - Per Instance SPIF' 
            || this.activityType =='SPIF - Volume' || this.activityType =='SPIF - Target' || this.activityType == 'Offer - Target')
            && (event.target.name == 'Core_MDF_Minimum_Forecast_Volume_nbr__c' || event.target.name == 'Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c')){            
            let forecastVolume = '';
            let spifAmount = '';

            if(event.target.name == 'Core_MDF_Minimum_Forecast_Volume_nbr__c') {
                forecastVolume = event.target.value;
            }else if(this.inputValueObject.Core_MDF_Minimum_Forecast_Volume_nbr__c !== null && this.inputValueObject.Core_MDF_Minimum_Forecast_Volume_nbr__c !== undefined){
                forecastVolume = this.inputValueObject.Core_MDF_Minimum_Forecast_Volume_nbr__c;
            }

            if(event.target.name == 'Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c') {
                spifAmount = event.target.value;
            } else if(this.inputValueObject.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c !== null && this.inputValueObject.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c !== undefined){
                spifAmount = this.inputValueObject.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c;
            }
            
            if(forecastVolume !== '' && spifAmount !== '') {
                //this.inputValueObject.Core_MDF_Estimated_Share_of_SPIF_amt__c =  forecastVolume*spifAmount; 
                // start - DE123324 - WW35 | DevINT3 | System is throwing an error when user enters decimal values in SPIF section                  
                let value = forecastVolume*spifAmount; 
                this.inputValueObject.Core_MDF_Estimated_Share_of_SPIF_amt__c =  parseFloat(value).toFixed(2);
                // end - DE123324 - WW35 | DevINT3 | System is throwing an error when user enters decimal values in SPIF section
            } else {
                this.inputValueObject.Core_MDF_Estimated_Share_of_SPIF_amt__c = null;
            }
        }
        
        if((this.activityType == 'Buyer - Bundle Offer' || this.activityType =='Offer - Bundle' ) && (event.target.name == 'Core_MDF_Maximum_Bundled_Volume_nbr__c' || event.target.name == 'Core_MDF_Maximum_Cost_of_Bundle_nbr__c')) {
            let maxBundledVolume = ''
            let maxCostOfBundle = ''
            
            if(event.target.name == 'Core_MDF_Maximum_Bundled_Volume_nbr__c') {
                maxBundledVolume = event.target.value;
            } else if(this.inputValueObject.Core_MDF_Maximum_Bundled_Volume_nbr__c !== null && this.inputValueObject.Core_MDF_Maximum_Bundled_Volume_nbr__c !== undefined) {
                maxBundledVolume = this.inputValueObject.Core_MDF_Maximum_Bundled_Volume_nbr__c;
            }

            if(event.target.name == 'Core_MDF_Maximum_Cost_of_Bundle_nbr__c') {
                maxCostOfBundle = event.target.value;
            } else if(this.inputValueObject.Core_MDF_Maximum_Cost_of_Bundle_nbr__c !== null && this.inputValueObject.Core_MDF_Maximum_Cost_of_Bundle_nbr__c !== undefined){
                maxCostOfBundle = this.inputValueObject.Core_MDF_Maximum_Cost_of_Bundle_nbr__c;
            }
            
            if(maxBundledVolume !== '' && maxCostOfBundle !== '') {
                //this.inputValueObject.Core_MDF_Estimated_Share_of_SPIF_amt__c = maxBundledVolume*maxCostOfBundle;  
                // start - DE123324 - WW35 | DevINT3 | System is throwing an error when user enters decimal values in SPIF section   
                let value = maxBundledVolume*maxCostOfBundle;
                this.inputValueObject.Core_MDF_Estimated_Share_of_SPIF_amt__c = parseFloat(value).toFixed(2);
                // end - DE123324 - WW35 | DevINT3 | System is throwing an error when user enters decimal values in SPIF section 
            } else {
                this.inputValueObject.Core_MDF_Estimated_Share_of_SPIF_amt__c = null;
            }
        }
    }

    /* To disable the Add Details Button when all segments are added to Activity.c/accessReviewTool
     * this.segmentPicVals - this variable holds all values of segment picklist
     * this.segmentNameList - this variable holds the segments which are added to activity
     * if all segments are added then we are disabling the Add Details button so user cannot click to add more
     */
    @api disableAddDetailsBtn(segmentNameLstLen) {
        if(this.segmentPicVals !== undefined && this.segmentPicVals !== null && segmentNameLstLen !== undefined  && segmentNameLstLen !== null) {
            this.addDetailsDisabled = false;
            if(this.segmentPicVals.length == segmentNameLstLen ) {
                this.addDetailsDisabled = true;
            }
        }
    }
    
    @api disableAddDetailsBtnInEdit() {
        this.addDetailsDisabled = true;
    }
}