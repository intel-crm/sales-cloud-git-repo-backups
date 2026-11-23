import { LightningElement, track, api, wire } from 'lwc';
import returnSegments from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.returnSegments';
import getProductMappingForAccount from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.getProductMappingForAccount';
import getUltimateAccountId from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.getUltimateAccountId';
import getSegmentValues from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.getSegmentValues'; 
import getFieldsToDisplay from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.getFieldsToDisplay';
import getLabelValueMap from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.getLabelValueMap';
import getProgramName from '@salesforce/apex/Core_MDF_ActivitySegmentMapping.getRecordTypeLabelByName';
import Core_MDF_SPIFHeader from "@salesforce/label/c.Core_MDF_SPIFHeader";
import Core_MDF_Estimated_Share_of_SPIF from "@salesforce/label/c.Core_MDF_Estimated_Share_of_SPIF";
import Core_MDF_Maximum_Bundled_Volume from "@salesforce/label/c.Core_MDF_Maximum_Bundled_Volume";
import Core_MDF_Maximum_Cost_of_Bundle from "@salesforce/label/c.Core_MDF_Maximum_Cost_of_Bundle";
import Core_MDF_Minimum_Forecast_Volume from "@salesforce/label/c.Core_MDF_Minimum_Forecast_Volume";
import Core_MDF_SPIF_Amount from "@salesforce/label/c.Core_MDF_SPIF_Amount";
import Core_MDF_SPIF_Notes from "@salesforce/label/c.Core_MDF_SPIF_Notes";
import Core_MDF_SegmentLabel from "@salesforce/label/c.Core_MDF_SegmentLabel";
import Core_MDF_ProductFamilyStr from "@salesforce/label/c.Core_MDF_ProductFamilyStr";
import Core_MDF_ProductsStr from "@salesforce/label/c.Core_MDF_ProductsStr";
import Core_MDF_SPIFMetrics from "@salesforce/label/c.Core_MDF_SPIFMetrics";
import Core_MDF_IPA_Program_Name from "@salesforce/label/c.Core_MDF_IPA_Program_Name";
import Core_MDF_ErrIfNoSegment from "@salesforce/label/c.Core_MDF_ErrIfNoSegment";
import Core_MDF_SPIF_Amount_ErrMsg from "@salesforce/label/c.Core_MDF_SPIF_Amount_ErrMsg";
import Core_MDF_OutcomeBased_SPIF_Amount_ErrMsg from "@salesforce/label/c.Core_MDF_OutcomeBased_SPIF_Amount_ErrMsg";

export default class Core_MDF_ActivitySegments extends LightningElement {

    
    @api segmentList = [];
    @api activityProgram;
    //Added new attribute to fix localisation issues
    @api recTypeDevName;
    @api activityType;
    @api mode;
    @api accountId;
    @api recordId;
    @api activityAmount;
    @api isCommunity;
    @api isOutcomeBased=false; // atribute to control which error message to show for SPIF amount validation

    @track selectedSegment;
    @track segmentNameList = [];
    @track isEdit = true;
    @track activeSection;
    @track segments;
    @track segmentWithValuesMap = [];
    @track segmentChanged = false;
    @track segmentsOnPageLoad = [];
    @track segmentPicVals = [];
    isValid = true;                     //if isValid is false Core_MDF_ErrIfNoSegment error message is shown
    /* Assigning Custom Label values to variables */
    spifSectionHeader = Core_MDF_SPIFHeader;
    @track sagmentNameItemsMap = [];
    @track allSelectedProductIds = [];
    @track counter=0;
    @track showTable = false;
    @track visibilityObj = {};    
    @track ultimateAccountId;
    @track approvedProdIdSet = new Set();
    @track showSPIFErrorMsg = false;
     
    estimatedShareOfSPIF = Core_MDF_Estimated_Share_of_SPIF;
    maximumBundledVolume = Core_MDF_Maximum_Bundled_Volume;
    maximumCostOfBundle = Core_MDF_Maximum_Cost_of_Bundle;
    minimumForecastVolume = Core_MDF_Minimum_Forecast_Volume;
    spifAmount = Core_MDF_SPIF_Amount;
    spifNotesStr = Core_MDF_SPIF_Notes;
    segmentStr = Core_MDF_SegmentLabel;
    productFamilyStr = Core_MDF_ProductFamilyStr;
    productsStr = Core_MDF_ProductsStr;
    spifMetrics = Core_MDF_SPIFMetrics;
    ipaProgramNameStr = Core_MDF_IPA_Program_Name;
    noSPIFErrorMsg = Core_MDF_ErrIfNoSegment;
    
    get spifAmountErrMsg() {
        return this.isOutcomeBased ? Core_MDF_OutcomeBased_SPIF_Amount_ErrMsg : Core_MDF_SPIF_Amount_ErrMsg;
    }

    customLabelValueMap = new Map();

    connectedCallback() {   
       /*This is for initialisation purpose*/
       let isCommunity = true;
         if(this.recTypeDevName !== null && this.recTypeDevName !== undefined && this.recTypeDevName !== ''){
            console.log("this.recTypeDevName"+this.recTypeDevName);
            getProgramName({recTypeName : this.recTypeDevName})
            .then((result) => {
                this.activityProgram = result;
                console.log('Result fetched from Record Type =>'+result);
            })
            .catch((error) => {
                console.log('Error in fetching Record Type Label => '+error.message);
            });
        }

        getLabelValueMap()
            .then((result) => {
                this.customLabelValueMap = result;
                const programs = this.customLabelValueMap['Core_MDF_SPIF_Programs'];
                if(programs.includes(this.recTypeDevName)) {
                    getUltimateAccountId({accountId:this.accountId})
                    .then((result) => {
                        this.ultimateAccountId = result;
                    })
                    .catch((error) => {
                        console.log('Error in getUltimateAccountId. Error - ' + error.message);
                    });
                } else {
                    this.ultimateAccountId = null;
                }
            })
            .catch((error) => {
                console.log('Error in customLabelValueMap. Error - ' + error.message);
            });
        if(this.mode !== undefined && this.mode !== null && (this.mode == 'edit' || this.mode == 'clone') && this.recordId !== undefined && this.recordId !== null) {
            this.prog = this.activityProgram.replace(/[-]/g, "");
            getProductMappingForAccount({accountId: this.accountId, program: this.prog})
                .then((result) => {
                    if(result) {
                        let prodIds = [];
                        for(let i=0;i<result.length;i++) {
                            if(result[i].Id != null && result[i].Id != undefined && result[i].Id != ''){
                                prodIds = [...prodIds, result[i].Id];
                            }
                        }
                        this.approvedProdIdSet = new Set(prodIds);
                    }
                })
                .catch(e => {
                    console.log('Error in getSegmentValues. Error - ' + e.message);
                });
            getSegmentValues({})
                .then(result => {
                    this.segmentPicVals = result;
                })
                .catch(e => {
                    console.log('Error in getSegmentValues. Error - ' + e.message);
                });
		
                getFieldsToDisplay({ program: this.activityProgram, activityType: this.activityType })
                    .then((initialWrapper) => {
                    this.segmentFieldList = initialWrapper.SegmentFields;
                    this.isCommunity = initialWrapper.UserType === 'PowerPartner' ? true :false;
                    this.visibilityObj = {
                        Core_MDF_SPIF_Notes_internal_only_txt__c : false,
                        Core_MDF_Maximum_Bundled_Volume_nbr__c  : false,
                        Core_MDF_Maximum_Cost_of_Bundle_nbr__c  : false,
                        Core_MDF_Estimated_Share_of_SPIF_amt__c  : false,
                        Core_MDF_Minimum_Forecast_Volume_nbr__c  : false,
                        Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c  : false,
                        Core_MDF_SPIF_Notes_txt__c : false,
                    };
                    //console.log('this.segmentFieldList'+JSON.stringify(this.segmentFieldList));
                    for(let i=0; i<this.segmentFieldList.length; i++) {
                        /*if(!this.isCommunity && this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_internal_only_txt__c'){
                            this.visibilityObj.Core_MDF_SPIF_Notes_internal_only_txt__c = true;
                        }*/
												if((this.isCommunity && this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_internal_only_txt__c') || (this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_txt__c' && this.segmentFieldList[i].Core_MDF_Program_nm__c != this.ipaProgramNameStr)) { 
                            continue;
                        }
                        if(this.segmentFieldList[i].Core_MDF_Field_API_Name_txt__c == 'Core_MDF_SPIF_Notes_txt__c'){
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
                    }
            returnSegments({recordId : this.recordId})
                        .then((result) => {
                            if(result !== undefined){
                    this.segments = result.segmentList;
                    this.fieldsToDisplay = result.fieldsToDisplay;
                    this.productMap = result.segmentProductMap;
                }            
               
                let existingSegments = [];
                for(let segment of this.segments){ 
                    console.log(segment.Core_MDF_SPIF_Notes_internal_only_txt__c);
                    if(this.mode == 'clone'){
                        if(segment.Core_MDF_SPIF_Notes_internal_only_txt__c != ''){
                            segment.Core_MDF_SPIF_Notes_internal_only_txt__c='';
                        }
                        if(segment.Core_MDF_SPIF_Notes_txt__c != ''){
                            segment.Core_MDF_SPIF_Notes_txt__c='';
                        }
                    }
                    console.log(segment.Core_MDF_SPIF_Notes_internal_only_txt__c);
                    if(this.activityType != segment.Core_MDF_Activity_Type_txt__c) {
                        continue;
                    }
                    /*if(!this.segmentNameList.includes(segment.Core_MDF_Segment_Name_nm__c)) {
                                    this.segmentNameList = [...this.segmentNameList, segment.Core_MDF_Segment_Name_nm__c];
                    }*/
		    //Localization fix changes
			let obj = {
				segmentId : segment.Id,
				Core_MDF_Segment_Name_nm__c : segment.Core_MDF_Segment_Name_nm__c,
				Segment_Label : segment.Core_MDF_Segment_Name //Localization fix changes
			}
                    
                    let fieldInst = [];   
                    let extraFieldsObj = {};                 
                    for(let i=0;i<this.fieldsToDisplay.length;i++) {                        
                        extraFieldsObj[this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c] = segment[this.fieldsToDisplay[i].Core_MDF_Field_API_Name_txt__c];
                    }   
                    obj["extraFieldsObj"] = extraFieldsObj;
                                //Localization fix                    
                                //let products = this.productMap[segment.Core_MDF_Segment_Name_nm__c];
                                let products = this.productMap[segment.Id];
                    let selectedRecords = [];
                    let productIdSet = [];
                        let productsNameStr='';
                        let productsFamilyNameStr = '';
                    for(let j=0;j<products.length;j++) {

                                    if(this.approvedProdIdSet !== undefined && this.approvedProdIdSet !== null && this.approvedProdIdSet !== '' && this.approvedProdIdSet.size > 0 && !this.approvedProdIdSet.has( products[j].Core_MDF_Product_id__c) ) {
                                        continue;
                                    }
                        let prod = {};
                                    /*if(segment.Core_MDF_Segment_Name_nm__c == 'Processors' && products[j].Core_Processor_Number_Nm__c !== undefined) {
                                        prod = {
                                            name: products[j].Core_Processor_Number_Nm__c,
                                            productName: products[j].Core_Processor_Number_Nm__c,
                                            productId: products[j].Core_MDF_Product_id__c,
                                            isChecked: true
                                        };
                                    } else {*/
                            prod = {
                                name: products[j].Core_MDF_Product_id__c,
                                productName: products[j].Core_MDF_Product_Name_txt__c,
                                productId: products[j].Core_MDF_Product_id__c,
                                isChecked: true
                                        };
                                    //}
                        selectedRecords = [...selectedRecords, prod];
                        productIdSet = [...productIdSet, products[j].Core_MDF_Product_id__c];
                                    productsNameStr += products[j].Core_MDF_Product_Name_txt__c + '\n';
                                    if(!productsFamilyNameStr.includes(products[j].Core_MDF_Product_Family__c)) {
                                        productsFamilyNameStr += products[j].Core_MDF_Product_Family__c + '\n';
                                    }
                                }
                                if(productIdSet.length > 0 ) {
                                    obj["selectedRecords"] = selectedRecords;
                                    obj["productIdSet"] = productIdSet;
                                    obj['productsNameStr'] = productsNameStr;
                                    obj['productsFamilyNameStr'] = productsFamilyNameStr;
                                    existingSegments = [...existingSegments, obj];
                                    this.allSelectedProductIds = this.allSelectedProductIds.concat(productIdSet);
                                    this.segmentWithValuesMap.push({id: segment.Id, key:obj.Core_MDF_Segment_Name_nm__c, segmentRec:obj,
                                        value : '', products : obj.productsNameStr, segmentFieldVal:obj.extraFieldsObj,
                                    productFamily: obj.productsFamilyNameStr, isEdit : false});
                                    console.log('this.segmentWithValuesMap '+JSON.stringify(this.segmentWithValuesMap));
                                }
                            }
                            this.segmentList = existingSegments;
                            if(this.segmentWithValuesMap !== undefined && this.segmentWithValuesMap !== null && this.segmentWithValuesMap !== '' && this.segmentWithValuesMap.length > 0) {
                                this.showTable = true;
                            } else {
                                this.showTable = false;
                            }
                            this.segmentsOnPageLoad = this.getSegmentValues();
				//Disable Add Details button on Page Load when all segments are selected
                            /*if(this.segmentPicVals != undefined && this.segmentPicVals != null && this.segmentList != undefined && this.segmentList != null &&  this.segmentPicVals.length == this.segmentList.length  ) {
                                this.template.querySelector("c-core_-m-d-f_-activity-segment-mapping").disableAddDetailsBtnInEdit();
                            }*/
            })
            .catch(e => {
                console.log('Error in loading existing segments. Error - ' + e.message);
                        });
                    this.isLoaded = false;
                })
                .catch((e) => {
                    console.log('Error in getFieldsToDisplay. Error - ' + e.message);
                });
        }

        
    
    }
    renderedCallback(){
        if(this.mode === 'edit'){
            this.checkSPIFAmountExceedsActivityAmount();
        }
    }

    addSegment(event) {
	/*
        let itemIndex = this.segmentList.findIndex((item) => item.Core_MDF_Segment_Name_nm__c == event.detail.obj.Core_MDF_Segment_Name_nm__c);
        
        if(itemIndex < 0) {
            this.segmentList = [...this.segmentList, event.detail.obj];
        } else {
            this.segmentList.splice(itemIndex, 1, event.detail.obj);
        }
        
        
        if(!this.segmentNameList.includes(event.detail.obj.Core_MDF_Segment_Name_nm__c)) {
            this.segmentNameList = [...this.segmentNameList, event.detail.obj.Core_MDF_Segment_Name_nm__c];
            this.template.querySelector("c-core_-m-d-f_-activity-segment-mapping").disableAddDetailsBtn(this.segmentNameList.length);
        }    */   
	const newSegment = event.detail.obj;
        const itemIndex = this.segmentList.findIndex((item) => item.segmentId === newSegment.segmentId);
        const selectedProdIdSet = newSegment.productIdSet;
        /*for(let i=0;i<selectedProdIdSet.length;i++) {
            if(!this.allSelectedProductIds.includes(selectedProdIdSet[i])) {
                this.allSelectedProductIds = [...this.allSelectedProductIds, selectedProdIdSet[i]];
            }
        }*/
        this.visibilityObj = {
            Core_MDF_SPIF_Notes_internal_only_txt__c : false,
            Core_MDF_Maximum_Bundled_Volume_nbr__c  : false,
            Core_MDF_Maximum_Cost_of_Bundle_nbr__c  : false,
            Core_MDF_Estimated_Share_of_SPIF_amt__c  : false,
            Core_MDF_Minimum_Forecast_Volume_nbr__c  : false,
            Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr__c  : false,
            Core_MDF_SPIF_Notes_txt__c : false,
        };
        if(itemIndex < 0) {
            this.counter = this.counter + 1;
            this.segmentList = [...this.segmentList, newSegment];
            this.visibilityObj = newSegment.visibilityObj;
            this.segmentWithValuesMap.push({id: newSegment.segmentId, key:newSegment.Core_MDF_Segment_Name_nm__c, segmentRec:newSegment,
                                            value : '', products : newSegment.productsNameStr, segmentFieldVal:newSegment.extraFieldsObj,
                                            productFamily: newSegment.productsFamilyNameStr, isEdit : false});
            this.showTable = true;
        } else {
            this.segmentList.splice(itemIndex, 1, newSegment);

            const updatedObj = {id: newSegment.segmentId, key:newSegment.Core_MDF_Segment_Name_nm__c, segmentRec:newSegment, value : '',
                                products : newSegment.productsNameStr, segmentFieldVal:newSegment.extraFieldsObj,
                                productFamily: newSegment.productsFamilyNameStr, isEdit : false};
            const itemIndex1 = this.segmentWithValuesMap.findIndex((item) => item.id === newSegment.segmentId);
            this.visibilityObj = newSegment.visibilityObj;
            this.segmentWithValuesMap.splice(itemIndex1, 1, updatedObj);
        }
	this.allSelectedProductIds = [];
        for(let i=0;i<this.segmentList.length;i++) {
            this.allSelectedProductIds = this.allSelectedProductIds.concat(this.segmentList[i].productIdSet);
        }
	this.isValid = true;
	this.checkSPIFAmountExceedsActivityAmount();
    }

    removeSegment(event) {
        const segmentToRemove = event.target.name;
        const segmentToremoveObj = this.segmentList.find((item) => item.segmentId === segmentToRemove);
        this.segmentList = this.segmentList.filter((item) => item.segmentId !== segmentToRemove);
        this.segmentWithValuesMap = this.segmentWithValuesMap.filter((item) => item.id !== segmentToRemove);
        if(this.segmentWithValuesMap !== undefined && this.segmentWithValuesMap !== null && this.segmentWithValuesMap !== '' && this.segmentWithValuesMap.length > 0 ) {
            this.showTable = true;
        } else {
            this.showTable = false;
        }
        if(this.allSelectedProductIds !== undefined && this.allSelectedProductIds !== null && this.allSelectedProductIds !== '' && segmentToremoveObj !== undefined) {
            console.log('before this.allSelectedProductIds '+this.allSelectedProductIds);

            this.allSelectedProductIds = this.allSelectedProductIds.filter((item) => !(segmentToremoveObj.productIdSet.indexOf(item) > -1) );
            console.log('after this.allSelectedProductIds '+this.allSelectedProductIds);
        }
        if(this.segmentList === null || this.segmentList === undefined || this.segmentList === '' || this.segmentList.length === 0){
            this.isValid = false;
        }
        
        //this.template.querySelector("c-core_-m-d-f_-activity-segment-mapping").disableAddDetailsBtn(this.segmentNameList.length);
        this.template.querySelector("c-core_-m-d-f_-activity-segment-mapping").closeModal();
        this.checkSPIFAmountExceedsActivityAmount();
    }

    closeSection(event) {
        this.activeSection = [];
        //this.showEditSegmentCmp(event);
				this.showEditSegmentRow(event)
    }

    @api getSegmentValues() {
        let segments = [];
        if(this.segmentList !== undefined && this.segmentList !== null) {
            for(let i=0;i<this.segmentList.length;i++) {
                let obj = {
                    Core_MDF_Segment_Name_nm : this.segmentList[i].Core_MDF_Segment_Name_nm__c,
                    productIdSet : this.segmentList[i].productIdSet,
                    segmentId : this.segmentList[i].segmentId
                }
                let keys = Object.keys(this.segmentList[i].extraFieldsObj);                
                for(let j=0;j<keys.length;j++) {
                    obj[keys[j].replace('__c','')] = this.segmentList[i].extraFieldsObj[keys[j]];
                }
                segments = [...segments, obj];                
            }
        }
        return segments;       
    }

    //US842041 - Method will be invoked in the PFR cmp to check if SPIF Section is modified or not 
    @api isSegmentModified() {
        let isSegmentChanged = false;
        let currentSegements =[];
        let currentSegmentsMap = new Map();
        currentSegements = this.getSegmentValues();
        
        if(currentSegements != null && currentSegements.length > 0 ){
            for(let a=0;a<currentSegements.length;a++){
                currentSegmentsMap.set(currentSegements[a].segmentId, currentSegements[a]);  
            }
        }

        if(this.segmentsOnPageLoad != null && currentSegements != null && this.segmentsOnPageLoad.length != currentSegements.length ) {
            isSegmentChanged = true;
        } else {
            if(this.segmentsOnPageLoad != null && currentSegmentsMap != null && this.segmentsOnPageLoad.length > 0 && currentSegmentsMap.size > 0){
                for(let i=0;i<this.segmentsOnPageLoad.length;i++) {
                    //If Map contains the Segment then comparing Products and other fields with old values if there is any difference considering segment as modified
                    if(this.segmentsOnPageLoad[i].Core_MDF_Segment_Name_nm != null && currentSegmentsMap.has(this.segmentsOnPageLoad[i].segmentId)){
                        //If there is difference in existing and current Product length(If added/removed products)
                        if(this.segmentsOnPageLoad[i].productIdSet.length !== currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).productIdSet.length ) {
                            isSegmentChanged = true;
                            break;
                        }else{
                            //if the existing and current products length is same and Product Ids are different
                            let productIds = [];
                            productIds = currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).productIdSet;
                            if(productIds != null && productIds.length > 0){
                                for(let k=0;k<productIds.length;k++){
                                    if(!this.segmentsOnPageLoad[i].productIdSet.includes(productIds[k])){
                                        isSegmentChanged = true;
                                        break;
                                    }
                                }
                            }
                        }
                        //if any of the input(text/Number) fields are modified then considering segment section as modified
                        if((this.segmentsOnPageLoad[i].Core_MDF_SPIF_Notes_internal_only_txt != undefined && this.segmentsOnPageLoad[i].Core_MDF_SPIF_Notes_internal_only_txt != currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).Core_MDF_SPIF_Notes_internal_only_txt) 
                            || (this.segmentsOnPageLoad[i].Core_MDF_SPIF_Notes_internal_only_txt == undefined && currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).Core_MDF_SPIF_Notes_internal_only_txt != "" && currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).Core_MDF_SPIF_Notes_internal_only_txt != undefined)
                            || (this.segmentsOnPageLoad[i].Core_MDF_Estimated_Share_of_SPIF_amt != undefined && this.segmentsOnPageLoad[i].Core_MDF_Estimated_Share_of_SPIF_amt != currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).Core_MDF_Estimated_Share_of_SPIF_amt)  
                            || (this.segmentsOnPageLoad[i].Core_MDF_Maximum_Bundled_Volume_nbr != undefined && this.segmentsOnPageLoad[i].Core_MDF_Maximum_Bundled_Volume_nbr != currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).Core_MDF_Maximum_Bundled_Volume_nbr)  
                            || (this.segmentsOnPageLoad[i].Core_MDF_Maximum_Cost_of_Bundle_nbr != undefined && this.segmentsOnPageLoad[i].Core_MDF_Maximum_Cost_of_Bundle_nbr != currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).Core_MDF_Maximum_Cost_of_Bundle_nbr)  
                            || (this.segmentsOnPageLoad[i].Core_MDF_Minimum_Forecast_Volume_nbr != undefined && this.segmentsOnPageLoad[i].Core_MDF_Minimum_Forecast_Volume_nbr != currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).Core_MDF_Minimum_Forecast_Volume_nbr) 
                            || (this.segmentsOnPageLoad[i].Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr != undefined && this.segmentsOnPageLoad[i].Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr != currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).Core_MDF_SPIF_Amount_Dollar_Per_Unit_nbr)  
                            || (this.segmentsOnPageLoad[i].Core_MDF_SPIF_Notes_txt != undefined && this.segmentsOnPageLoad[i].Core_MDF_SPIF_Notes_txt != currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).Core_MDF_SPIF_Notes_txt)  
                            || (this.segmentsOnPageLoad[i].Core_MDF_SPIF_Notes_txt == undefined && currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).Core_MDF_SPIF_Notes_txt != "" && currentSegmentsMap.get(this.segmentsOnPageLoad[i].segmentId).Core_MDF_SPIF_Notes_txt != undefined)
                        ) {
                            isSegmentChanged = true;
                            break;
                        }
                    }else{
                        //If Map does not contain existing Segment then there is a change in segments and considered as segment modified
                        isSegmentChanged = true;
                        break;
                    }
                }
            }
        }
        return isSegmentChanged;
    }

    @api isFormValid() {
        this.isValid = false;
        return this.template.querySelector("c-core_-m-d-f_-activity-segment-mapping").isFormValid();
    }

    showEditSegmentCmp(event) {
        let rowElementSelectorId = '[data-id="'+event.target.name+'"]';
        let rowElement = this.template.querySelector(rowElementSelectorId);
        //let childRowSelectorId = '[data-id="'+event.target.accessKey+'"]';
        //let childRow = this.template.querySelector(childRowSelectorId);
        if(rowElement){
            if(rowElement.className == "slds-hint-parent slds-show") {
                //iconElement.className = "slds-icon-utility-switch slds-section__title-action-icon slds-button__icon_left slds-icon_container";
                rowElement.className='slds-hint-parent slds-hide';
            } else {
                //iconElement.className = "slds-button__icon_left";
                rowElement.className='slds-hint-parent slds-show';
            }
        } 
    }
    
    showEditSegmentRow(event) {
       const sengmentRowId = event.target.name;
       let selectedRow = this.segmentWithValuesMap.find((item) => item.id === sengmentRowId);
       if(selectedRow.isEdit) {
        selectedRow.isEdit = false;
       } else {
        selectedRow.isEdit = true;
       }
    }

    hideEditSection(event) {
        const sengmentRowId = event.target.name;
        let selectedRow = this.segmentWithValuesMap.find((item) => item.id === sengmentRowId);
        selectedRow.isEdit = false;
    }
    @api
    fetchSPIFAmount(){
        let selectedSegments = this.getSegmentValues();
        let totalSPIFAmount = 0;
        if(selectedSegments !== undefined && selectedSegments !== null && selectedSegments !== ''){
            for(let i=0; i < selectedSegments.length; i++){ 
                if(selectedSegments[i].Core_MDF_Estimated_Share_of_SPIF_amt !== undefined && selectedSegments[i].Core_MDF_Estimated_Share_of_SPIF_amt !== null && selectedSegments[i].Core_MDF_Estimated_Share_of_SPIF_amt !== ''){
                    totalSPIFAmount  = totalSPIFAmount + parseFloat(selectedSegments[i].Core_MDF_Estimated_Share_of_SPIF_amt);
                }
            }
        }
        return totalSPIFAmount;
    }
        @api
        checkSPIFAmountExceedsActivityAmount(){
        //let activityAmount = 100;
        let spifAmount = this.fetchSPIFAmount();
        if(this.activityAmount !== undefined && this.activityAmount !== null && this.activityAmount < spifAmount){          
            this.showSPIFErrorMsg = true;
        }else{            
            this.showSPIFErrorMsg = false;
        }
    }
}