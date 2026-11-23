import { LightningElement, track, api, wire } from 'lwc';
import returnSegments from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.returnSegments';
import Core_MDF_SelectedProductColumn from "@salesforce/label/c.Core_MDF_SelectedProductColumn";
import Core_MDF_SPIFHeader from "@salesforce/label/c.Core_MDF_SPIFHeader";
import Core_MDF_Estimated_Share_of_SPIF from "@salesforce/label/c.Core_MDF_Estimated_Share_of_SPIF";
import Core_MDF_Maximum_Bundled_Volume from "@salesforce/label/c.Core_MDF_Maximum_Bundled_Volume";
import Core_MDF_Maximum_Cost_of_Bundle from "@salesforce/label/c.Core_MDF_Maximum_Cost_of_Bundle";
import Core_MDF_Minimum_Forecast_Volume from "@salesforce/label/c.Core_MDF_Minimum_Forecast_Volume";
import Core_MDF_SPIF_Amount from "@salesforce/label/c.Core_MDF_SPIF_Amount";
import Core_MDF_SPIF_Notes from "@salesforce/label/c.Core_MDF_SPIF_Notes";
import Core_MDF_PartnerCommunityIdentifier from "@salesforce/label/c.Core_MDF_PartnerCommunityIdentifier";
import Core_MDF_IPA_Program_Name from "@salesforce/label/c.Core_MDF_IPA_Program_Name";

import Core_MDF_SegmentLabel from "@salesforce/label/c.Core_MDF_SegmentLabel";
import Core_MDF_ProductFamilyStr from "@salesforce/label/c.Core_MDF_ProductFamilyStr";
import Core_MDF_ProductsStr from "@salesforce/label/c.Core_MDF_ProductsStr";
import Core_MDF_SPIFMetrics from "@salesforce/label/c.Core_MDF_SPIFMetrics";

//import Core_MDF_Num_of_Potential_Winners from "@salesforce/label/c.Core_MDF_Num_of_Potential_Winners";
//import Core_MDF_Num_of_Expected_Participants from "@salesforce/label/c.Core_MDF_Num_of_Expected_Participants";

const SELECTED_PRODUCT_COLUMNS = [{
    type: 'text',
    fieldName: 'Core_MDF_Product_Name_txt__c',
    label: Core_MDF_SelectedProductColumn,
    title: Core_MDF_SelectedProductColumn,
}];

export default class displayProducts_clone extends LightningElement {

    @api recordId;
    @api isCommunity;
    @api hideHeader = false;

    @track segmentList;
    @track fieldsToDisplay;
    @track segmentWithValuesMap = [];
    @track tableColumns = SELECTED_PRODUCT_COLUMNS;
    @track segmentAndProduct = [];
    @track productMap = [];
    @track loadTemplate = false;
    @track visibilityObj = {};
    //@track segmentFieldValue = {};

    /* Assigning Custom Label values to variables */
    spifSectionHeader = Core_MDF_SPIFHeader;

    estimatedShareOfSPIF = Core_MDF_Estimated_Share_of_SPIF;
    maximumBundledVolume = Core_MDF_Maximum_Bundled_Volume;
    maximumCostOfBundle = Core_MDF_Maximum_Cost_of_Bundle;
    minimumForecastVolume = Core_MDF_Minimum_Forecast_Volume;
    spifAmount = Core_MDF_SPIF_Amount;
    spifNotesStr = Core_MDF_SPIF_Notes;
    partnercenterStr = Core_MDF_PartnerCommunityIdentifier;
    ipaProgramNameStr = Core_MDF_IPA_Program_Name;

    segmentStr = Core_MDF_SegmentLabel;
    productFamilyStr = Core_MDF_ProductFamilyStr;
    productsStr = Core_MDF_ProductsStr;
    spifMetrics = Core_MDF_SPIFMetrics;

    get className() {
        return this.hideHeader ? 'class1' : 'class2';
    }
    //numberPotential = Core_MDF_Num_of_Potential_Winners;
    //numberExpected = Core_MDF_Num_of_Expected_Participants;
    connectedCallback() {
        if (this.isCommunity === undefined || this.isCommunity === null || this.isCommunity === '') {
            this.isCommunity = false;
            var sPageURL = decodeURIComponent(window.location.href);
            if (sPageURL.includes('Partnercenter') || sPageURL.includes('partnercenter')) {
                this.isCommunity = true;
            }
        }
        console.log('header->' + this.hideHeader);
        this.loadForm();
    }

    loadForm() {
        returnSegments({ recordId: this.recordId })
            .then(result => {
                if (result != undefined) {
                    this.segmentList = result.segmentList;
                    this.fieldsToDisplay = result.fieldsToDisplay;
                    this.productMap = result.segmentProductMap;
                }
                let isSPIFApplicable = false;

                if (this.segmentList != null && this.segmentList.length > 0 && this.fieldsToDisplay != null && this.fieldsToDisplay.length > 0) {
                    this.loadTemplate = true;
                    isSPIFApplicable = true;
                }

                const spifEvent = new CustomEvent('spifCompVisibilityEvent', { detail: { isSPIFApplicable } });
                this.dispatchEvent(spifEvent);


                this.visibilityObj = {
                    Core_MDF_SPIF_Notes_internal_only_txt__c: false,
                    Core_MDF_Maximum_Bundled_Volume_nbr__c: false,
                    Core_MDF_Maximum_Cost_of_Bundle_nbr__c: false,
                    Core_MDF_Estimated_Share_of_SPIF_amt__c: false,
                    Core_MDF_Minimum_Forecast_Volume_nbr__c: false,
                    Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c: false,
                    Core_MDF_SPIF_Notes_txt__c: false,
                };



                let segmentFieldValArr = []
                console.log('Coming here before loop');
                for (let segment of this.segmentList) {
                    console.log('Coming here within loop');
                    let fieldInst = [];
                    let segmentFieldValue = {
                        Core_MDF_SPIF_Notes_internal_only_txt__c: '',
                        Core_MDF_Maximum_Bundled_Volume_nbr__c: 0,
                        Core_MDF_Maximum_Cost_of_Bundle_nbr__c: 0,
                        Core_MDF_Estimated_Share_of_SPIF_amt__c: 0,
                        Core_MDF_Minimum_Forecast_Volume_nbr__c: 0,
                        Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c: 0,
                        Core_MDF_SPIF_Notes_txt__c: '',
                    }
                    for (let i = 0; i < this.fieldsToDisplay.length; i++) {
                        this.fieldsToDisplay[i].value = segment[this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c];
                        // For external user on community SPIF Notes field is not visible OR External SPIF notes are visible to only IPA program
                        if ((this.isCommunity && this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_internal_only_txt__c') || (this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_txt__c' && this.fieldsToDisplay[i].Core_MDF_Program_nm__c != this.ipaProgramNameStr)) {
                            continue;
                        }
                        let newObj = {};
                        newObj["Core_MDF_Field_API_Name_txt__c"] = this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c;
                        newObj["value"] = segment[this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c];
                        segmentFieldValue[this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c] = segment[this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c];
                        //newObj["Core_MDF_Field_Label_Name_txt__c"] = this.fieldsToDisplay[i].Core_MDF_Field_Label_Name_txt__c;
                        newObj["Core_MDF_Data_Type_txt__c"] = this.fieldsToDisplay[i].Core_MDF_Data_Type_txt__c;

                        if (this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_internal_only_txt__c') {
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.fieldsToDisplay[i].Core_MDF_Field_Label_Name_txt__c;
                            this.visibilityObj.Core_MDF_SPIF_Notes_internal_only_txt__c = true;
                        }
                        if (this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_txt__c') {
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.spifNotesStr;
                            this.visibilityObj.Core_MDF_SPIF_Notes_txt__c = true;
                        }
                        if (this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Maximum_Bundled_Volume_nbr__c') {
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.maximumBundledVolume;
                            this.visibilityObj.Core_MDF_Maximum_Bundled_Volume_nbr__c = true;
                        }
                        if (this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Maximum_Cost_of_Bundle_nbr__c') {
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.maximumCostOfBundle;
                            this.visibilityObj.Core_MDF_Maximum_Cost_of_Bundle_nbr__c = true;
                        }
                        if (this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Estimated_Share_of_SPIF_amt__c') {
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.estimatedShareOfSPIF;
                            this.visibilityObj.Core_MDF_Estimated_Share_of_SPIF_amt__c = true;
                        }
                        if (this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_Minimum_Forecast_Volume_nbr__c') {
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.minimumForecastVolume;
                            this.visibilityObj.Core_MDF_Minimum_Forecast_Volume_nbr__c = true;
                        }
                        if (this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c') {
                            newObj["Core_MDF_Field_Label_Name_txt__c"] = this.spifAmount;
                            this.visibilityObj.Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c = true;
                        }

                        fieldInst = [...fieldInst, newObj];
                        //segmentFieldValArr = [...segmentFieldValArr, segmentFieldValue];
                    }

                    //let prods = this.productMap[segment.Core_MDF_Segment_Name_nm__c];
                    let prods = this.productMap[segment.Id];
                    let prodsStr = '';
                    let prodFamilySet = [];
                    let prodFamilyStr = '';
                    for (let p = 0; p < prods.length; p++) {
                        prodsStr += prods[p].Core_MDF_Product_Name_txt__c + '\n';
                        if (!prodFamilySet.includes(prods[p].Core_MDF_Product_Family__c)) {
                            prodFamilySet = [...prodFamilySet, prods[p].Core_MDF_Product_Family__c];
                            prodFamilyStr += prods[p].Core_MDF_Product_Family__c + '\n';
                        }
                    }

                    //this.segmentWithValuesMap.push({key:segment.Core_MDF_Segment_Name, value : fieldInst, products : this.productMap[segment.Core_MDF_Segment_Name_nm__c], segmentFieldVal:segmentFieldValue, productFamily: prodFamilyStr});                        
                    this.segmentWithValuesMap.push({ key: segment.Core_MDF_Segment_Name, value: fieldInst, products: prodsStr, segmentFieldVal: segmentFieldValue, productFamily: prodFamilyStr });
                }
                console.log('this.segmentWithValuesMap ' + this.segmentWithValuesMap);
                console.log('this.segmentWithValuesMap ' + JSON.stringify(this.segmentWithValuesMap));
            })
            .catch(e => {
                console.log('Error in loading Segments. Error - ' + e.message);
            });
    }
}