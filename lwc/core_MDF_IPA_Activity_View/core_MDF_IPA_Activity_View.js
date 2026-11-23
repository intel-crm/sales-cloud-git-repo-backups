import { LightningElement,api,track } from 'lwc';
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
import Core_MDF_A_description_of_the_activity_to_be_performed from "@salesforce/label/c.Core_MDF_A_description_of_the_activity_to_be_performed";
import Core_MDF_Activity_Type from "@salesforce/label/c.Core_MDF_Activity_Type";
import Core_MDF_Activity_Description from "@salesforce/label/c.Core_MDF_Activity_Description";
import Core_MDF_Start_Date from "@salesforce/label/c.Core_MDF_Start_Date";
import Core_MDF_End_Date from "@salesforce/label/c.Core_MDF_End_Date";
import Core_MDF_Budget_Amount from "@salesforce/label/c.Core_MDF_Budget_Amount";
import Core_MDF_Budget_Currency  from "@salesforce/label/c.Core_MDF_Budget_Currency";
import Core_MDF_Activity_Category from "@salesforce/label/c.Core_MDF_Activity_Category";
import Core_MDF_Reimbursement_Amount_Label from "@salesforce/label/c.Core_MDF_Reimbursement_Amount_Label";
import Core_MDF_Activity_Sub_Type_nm from "@salesforce/label/c.Core_MDF_Activity_Sub_Type_nm";
import Core_MDF_KpiSection_Label from "@salesforce/label/c.Core_MDF_KpiSection_Label";
export default class Core_MDF_IPA_Activity_View extends LightningElement {
    @api rec;
    @api expndetail;
    @track activeSections;
    @api supportedactivityflds;
    @track showActivityDetailFlds;

 

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
    activityName = Core_MDF_A_description_of_the_activity_to_be_performed;
    activityType = Core_MDF_Activity_Type;
    activityDescription = Core_MDF_Activity_Description;
    startDate = Core_MDF_Start_Date;
    endDate = Core_MDF_End_Date;
    budgetAmount = Core_MDF_Budget_Amount;
    currency = Core_MDF_Budget_Currency;
    activityCategory = Core_MDF_Activity_Category;
    reimbAmount = Core_MDF_Reimbursement_Amount_Label;
    activitySubtype = Core_MDF_Activity_Sub_Type_nm;
    metrics = Core_MDF_KpiSection_Label;

    connectedCallback(){
        console.log('expndetail'+this.expndetail); 
        this.activeSections = this.expndetail;

         var fetchRec = this.rec;
        for (var key in fetchRec) {
         
          if(this.supportedactivityflds.includes(key)) {   
            this.showActivityDetailFlds.push( key, fetchRec[key]);
          }
        }
        console.log('showActivityDetailFlds' + JSON.stringify(this.showActivityDetailFlds));
  
}
 handleSectionToggle(event){
        const openSections = event.detail.openSections;
        console.log('open'+event.detail.openSections);

        const expandSection = new CustomEvent('showspif', { detail: event.detail.openSections });
        this.dispatchEvent(expandSection);
    }
    
}