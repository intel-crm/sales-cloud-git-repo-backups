import { LightningElement, track, api, wire } from 'lwc';
import returnSegments from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.returnSegments';
 //import getInitialDetailWrapper from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.getInitialDetailWrapper';
import Core_MDF_SelectedProductColumn from "@salesforce/label/c.Core_MDF_SelectedProductColumn";
import Core_MDF_SPIFHeader from "@salesforce/label/c.Core_MDF_SPIFHeader";
import Core_MDF_Estimated_Share_of_SPIF from "@salesforce/label/c.Core_MDF_Estimated_Share_of_SPIF";
import Core_MDF_Estimated_Share_of_SPIF_amt_c_Sales_HelpText from "@salesforce/label/c.Core_MDF_Estimated_Share_of_SPIF_amt_c_Sales_HelpText";
import Core_MDF_Estimated_Share_of_SPIF_amt_c_Purchase_HelpText from "@salesforce/label/c.Core_MDF_Estimated_Share_of_SPIF_amt_c_Purchase_HelpText";
import Core_MDF_Estimated_Share_of_SPIF_amt_c_Seller_HelpText from "@salesforce/label/c.Core_MDF_Estimated_Share_of_SPIF_amt_c_Seller_HelpText";	
import Core_MDF_Maximum_Bundled_Volume from "@salesforce/label/c.Core_MDF_Maximum_Bundled_Volume";
import Core_MDF_Maximum_Cost_of_Bundle from "@salesforce/label/c.Core_MDF_Maximum_Cost_of_Bundle";
import Core_MDF_Maximum_Cost_of_Bundle_HelpText from "@salesforce/label/c.Core_MDF_Maximum_Cost_of_Bundle_HelpText";
import Core_MDF_Maximum_Cost_of_Bundle_Buyer_HelpText from "@salesforce/label/c.Core_MDF_Maximum_Cost_of_Bundle_Buyer_HelpText";
import Core_MDF_Minimum_Forecast_Volume from "@salesforce/label/c.Core_MDF_Minimum_Forecast_Volume";
import Core_MDF_Volume_HelpText from "@salesforce/label/c.Core_MDF_Volume_HelpText";
import Core_MDF_SPIF_Amount from "@salesforce/label/c.Core_MDF_SPIF_Amount";
import Core_MDF_SPIF_Amount_HelpText from "@salesforce/label/c.Core_MDF_SPIF_Amount_HelpText";
import Core_MDF_SPIF_Notes from "@salesforce/label/c.Core_MDF_SPIF_Notes";
import Core_MDF_PartnerCommunityIdentifier from "@salesforce/label/c.Core_MDF_PartnerCommunityIdentifier";
import Core_MDF_IPA_Program_Name from "@salesforce/label/c.Core_MDF_IPA_Program_Name";

import Core_MDF_SegmentLabel from "@salesforce/label/c.Core_MDF_SegmentLabel";
import Core_MDF_ProductFamilyStr from "@salesforce/label/c.Core_MDF_ProductFamilyStr";
import Core_MDF_ProductsStr from "@salesforce/label/c.Core_MDF_ProductsStr";
import Core_MDF_SPIFMetrics from "@salesforce/label/c.Core_MDF_SPIFMetrics";
import Core_MDF_Estimated_Share_of_SPIF_Offer_Target_helptext from "@salesforce/label/c.Core_MDF_Estimated_Share_of_SPIF_Offer_Target_helptext";
import Core_MDF_Spif_Amount_Offer_Target_helptext from "@salesforce/label/c.Core_MDF_Spif_Amount_Offer_Target_helptext";
import Core_MDF_SPIF_Amount_ErrMsg from "@salesforce/label/c.Core_MDF_SPIF_Amount_ErrMsg";

const SELECTED_PRODUCT_COLUMNS = [{ 
    type: 'text',
    fieldName: 'Core_MDF_Product_Name_txt__c',
    label: Core_MDF_SelectedProductColumn,
    title: Core_MDF_SelectedProductColumn,
}];

export default class Core_MDF_DisplayProducts extends LightningElement {

    @api recordId;
    @api isCommunity;
    @api hideHeader = false;
    @api activityAmount;
    
    

    @track segmentList;
    @track fieldsToDisplay;
    @track segmentWithValuesMap = [];
    @track tableColumns = SELECTED_PRODUCT_COLUMNS;
    @track segmentAndProduct = [];
    @track productMap = [];
    @track loadTemplate = false;
    @track visibilityObj = {};
    @track fieldInstGlobal = [];
    @track showSPIFErrorMsg = false;

    /* Assigning Custom Label values to variables */
    spifSectionHeader = Core_MDF_SPIFHeader;   
    
    estimatedShareOfSPIF = Core_MDF_Estimated_Share_of_SPIF;
    maximumBundledVolume = Core_MDF_Maximum_Bundled_Volume;
    maximumCostOfBundle = Core_MDF_Maximum_Cost_of_Bundle;
    minimumForecastVolume = Core_MDF_Minimum_Forecast_Volume;
    volumeHelpText = Core_MDF_Volume_HelpText;
    spifAmountHelpText = Core_MDF_SPIF_Amount_HelpText;
    maximumCostOfBundleHelpText = Core_MDF_Maximum_Cost_of_Bundle_HelpText;
    estimatedShareOfSPIFSellerHelpText =Core_MDF_Estimated_Share_of_SPIF_amt_c_Seller_HelpText;
    maximumCostOfBundleBuyerHelpText= Core_MDF_Maximum_Cost_of_Bundle_Buyer_HelpText;
    spifAmount = Core_MDF_SPIF_Amount;
    spifNotesStr = Core_MDF_SPIF_Notes;
    partnercenterStr = Core_MDF_PartnerCommunityIdentifier;
    ipaProgramNameStr = Core_MDF_IPA_Program_Name;
    spifAmountErrMsg = Core_MDF_SPIF_Amount_ErrMsg;

    segmentStr = Core_MDF_SegmentLabel;
    productFamilyStr = Core_MDF_ProductFamilyStr;
    productsStr = Core_MDF_ProductsStr;
		spifMetrics = Core_MDF_SPIFMetrics;

   	
    connectedCallback() {
        /*This is for initialisation purpose*/
        let isCommunity = true;
        this.loadForm();
        
    }


    loadForm() {
        returnSegments({recordId : this.recordId})
            .then(result => {                                
                if(result != undefined){
                    this.segmentList = result.segmentList;
                    this.fieldsToDisplay = result.fieldsToDisplay;
                    this.productMap = result.segmentProductMap;
                    this.isCommunity = result.userType === 'PowerPartner' ? true :false;
                }
                console.log('<<community>>'+this.isCommunity);
                let isSPIFApplicable = false;
                let activityType = this.fieldsToDisplay[0].Core_MDF_Activity_Type_txt__c;
                if(activityType == 'Seller - Per Unit SPIF' || activityType =='Seller - Other' || activityType =='Seller - Target SPIF' ){
                    this.estimatedShareOfSPIFHelpText = Core_MDF_Estimated_Share_of_SPIF_amt_c_Sales_HelpText;
                }else if(activityType == 'SPIF - Target' || activityType =='SPIF - Volume' || activityType =='SPIF - Other' || activityType =='Outcome-Based'){
                    this.estimatedShareOfSPIFHelpText = Core_MDF_Estimated_Share_of_SPIF_amt_c_Seller_HelpText;
                }
                else if(activityType == 'Offer - Bundle' || activityType =='Offer - Other' ){
                    this.maximumCostOfBundleHelpText = Core_MDF_Maximum_Cost_of_Bundle_Buyer_HelpText;
                    this.estimatedShareOfSPIFHelpText = Core_MDF_Estimated_Share_of_SPIF_amt_c_Purchase_HelpText;
                }else if(activityType == 'Offer - Target' ){
                    this.estimatedShareOfSPIFHelpText = Core_MDF_Estimated_Share_of_SPIF_Offer_Target_helptext;
                    this.spifAmountHelpText = Core_MDF_Spif_Amount_Offer_Target_helptext;
                }
                else{
                    this.estimatedShareOfSPIFHelpText = Core_MDF_Estimated_Share_of_SPIF_amt_c_Purchase_HelpText;
                    this.maximumCostOfBundleHelpText = Core_MDF_Maximum_Cost_of_Bundle_HelpText;
                }

                
                
                if(this.segmentList != null && this.segmentList.length > 0 && this.fieldsToDisplay != null && this.fieldsToDisplay.length > 0){
                    this.loadTemplate = true;
                    isSPIFApplicable = true;
                }                               
                const spifEvent = new CustomEvent('spifcompvisibilityevent', { detail: { isSPIFApplicable:isSPIFApplicable } });
                this.dispatchEvent(spifEvent);
                this.visibilityObj = {
                    Core_MDF_SPIF_Notes_internal_only_txt__c : false,
                    Core_MDF_Maximum_Bundled_Volume_nbr__c  : false,
                    Core_MDF_Maximum_Cost_of_Bundle_nbr__c  : false,
                    Core_MDF_Estimated_Share_of_SPIF_amt__c  : false,
                    Core_MDF_Minimum_Forecast_Volume_nbr__c  : false,
                    Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c  : false,
                    Core_MDF_SPIF_Notes_txt__c : false,
                };
                for(let segment of this.segmentList){
                    let fieldInst = [];
                    let segmentFieldValue = {
                        Core_MDF_SPIF_Notes_internal_only_txt__c : '',
                        Core_MDF_Maximum_Bundled_Volume_nbr__c  : 0,
                        Core_MDF_Maximum_Cost_of_Bundle_nbr__c  : 0,
                        Core_MDF_Estimated_Share_of_SPIF_amt__c  : 0,
                        Core_MDF_Minimum_Forecast_Volume_nbr__c  : 0,
                        Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c  : 0,
                        Core_MDF_SPIF_Notes_txt__c : '',
                    };
                    for(let i=0; i<this.fieldsToDisplay.length; i++) {
                        this.fieldsToDisplay[i].value = segment[this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c]; 
                        // For external user on community SPIF Notes field is not visible OR External SPIF notes are visible to only IPA program
                        if((this.isCommunity && this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_internal_only_txt__c') || (this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_txt__c' && this.fieldsToDisplay[i].Core_MDF_Program_nm__c != this.ipaProgramNameStr)) { 
                            continue;
                        }
                        let newObj = {};
                        newObj["Core_MDF_Field_API_Name_txt__c"] = this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c;
                        newObj["value"] = segment[this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c];
                        segmentFieldValue[this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c] = segment[this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c];
                        //newObj["Core_MDF_Field_Label_Name_txt__c"] = this.fieldsToDisplay[i].Core_MDF_Field_Label_Name_txt__c;
                        newObj["Core_MDF_Data_Type_txt__c"] = this.fieldsToDisplay[i].Core_MDF_Data_Type_txt__c;

                        if(this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_internal_only_txt__c'){     
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.fieldsToDisplay[i].Core_MDF_Field_Label_Name_txt__c;                                                   
                            this.visibilityObj.Core_MDF_SPIF_Notes_internal_only_txt__c = true;
                        }
                        if(this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_txt__c'){     
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.spifNotesStr;                                                   
                            this.visibilityObj.Core_MDF_SPIF_Notes_txt__c = true;
                        }
                        if(this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Maximum_Bundled_Volume_nbr__c'){
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.maximumBundledVolume;                            
                            this.visibilityObj.Core_MDF_Maximum_Bundled_Volume_nbr__c = true;
                        }
                        if(this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Maximum_Cost_of_Bundle_nbr__c'){
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.maximumCostOfBundle;                            
                            this.visibilityObj.Core_MDF_Maximum_Cost_of_Bundle_nbr__c = true;
                        }
                        if(this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Estimated_Share_of_SPIF_amt__c'){
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.estimatedShareOfSPIF;                            
                            this.visibilityObj.Core_MDF_Estimated_Share_of_SPIF_amt__c = true;
                        }
                        if(this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Minimum_Forecast_Volume_nbr__c'){                                                        
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.minimumForecastVolume;                            
                            this.visibilityObj.Core_MDF_Minimum_Forecast_Volume_nbr__c = true;
                        }
                        if(this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c'){
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.spifAmount;                            
                            this.visibilityObj.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = true;
                        } 
                        
                        fieldInst = [...fieldInst,newObj];
                    }                     

                    //let prods = this.productMap[segment.Core_MDF_Segment_Name_nm__c];
                    let prods = this.productMap[segment.Id];
                    let prodsStr='';
                    let prodFamilySet =  [];
                    let prodFamilyStr = '';
                    for(let p=0;p<prods.length;p++) {
                        prodsStr += prods[p].Core_MDF_Product_Name_txt__c + '\n';
                        if(!prodFamilySet.includes(prods[p].Core_MDF_Product_Family__c)) {
                            prodFamilySet = [...prodFamilySet, prods[p].Core_MDF_Product_Family__c];
                            prodFamilyStr += prods[p].Core_MDF_Product_Family__c + '\n';
                        }
                    }
                    this.fieldInstGlobal = [...fieldInst];
                    //this.segmentWithValuesMap.push({key:segment.Core_MDF_Segment_Name, value : fieldInst, products : this.productMap[segment.Core_MDF_Segment_Name_nm__c], segmentFieldVal:segmentFieldValue, productFamily: prodFamilyStr});                        
                    this.segmentWithValuesMap.push({key:segment.Core_MDF_Segment_Name, value : fieldInst, products : prodsStr, segmentFieldVal:segmentFieldValue, productFamily: prodFamilyStr});                        
                }                
            })
            .catch(e => {
                console.log('Error in loading Segments. Error - ' + e.message);
            });
    }

    renderedCallback(){
           this.checkSPIFAmountExceedsActivityAmount();
    
    }

    @api
    fetchSpifAmount(){
        let totalEstSpifAmt = 0;
        let segFields = [...this.fieldInstGlobal];
        if(segFields != null && segFields!=undefined && segFields.length>0){
        for(let i=0; i<segFields.length; i++){
            if(segFields[i].Core_MDF_Field_API_Name_txt__c != null && segFields[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Estimated_Share_of_SPIF_amt__c'){
                totalEstSpifAmt = totalEstSpifAmt + parseFloat(segFields[i].value);
                console.log('Amount- ' + totalEstSpifAmt);
                return totalEstSpifAmt;
            }
        }
        } 
    }
    @api
    checkSPIFAmountExceedsActivityAmount(){
        //let activityAmount = 100;
        let spifAmountCalc = this.fetchSpifAmount();
        if(this.activityAmount !== undefined && this.activityAmount !== null && this.activityAmount < spifAmountCalc){          
            this.showSPIFErrorMsg = true;
        }else{            
            this.showSPIFErrorMsg = false;
        }
    }
}