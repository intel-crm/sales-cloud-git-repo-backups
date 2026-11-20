import { LightningElement, api, track } from 'lwc';

import displayPointsData from '@salesforce/apex/PRM_AccountActvityOverview.displayPointsData'
//import ispublished from '@salesforce/label/c.PRM_IsPublished';
//import isNotpublished from '@salesforce/label/c.PRM_IsNotPublished';
//import publishedStorefrnt from '@salesforce/label/c.PRM_Published_Storefront'; //IPA2.0 TWC727-3228
import total_PointsBalance from '@salesforce/label/c.PRM_PointsBalance';
import total_PointsExpired from '@salesforce/label/c.PRM_totalPointsExpired';
import total_SalesData from '@salesforce/label/c.PRM_totalSalesData';
import total_TrainingCredits from '@salesforce/label/c.PRM_totalTrainingCredits';
import total_SalesDataPrev from '@salesforce/label/c.PRM_totalSalesDataPrev';
import total_TrainingCreditsPrev from '@salesforce/label/c.PRM_totalTrainingCreditsPrev';
import metric from '@salesforce/label/c.IPA_Metric_lable';
import total_AWR_remaining from '@salesforce/label/c.IPA_totalAWR_remaining';
import total_AWR_allocated from '@salesforce/label/c.IPA_totalAWR_allocated';
import IPAClick from '@salesforce/label/c.IPA_click';
import IPAhere from '@salesforce/label/c.IPA_here';
import IPAInstruction from '@salesforce/label/c.IPA_instruction';
import IPAmetricLink from '@salesforce/label/c.IPA_metric_link';
import IPAHelptextvalue from '@salesforce/label/c.PRM_helptext';
import IPAAWRHelptextvalue from '@salesforce/label/c.PRM_AWR_HelpText';
import IPAAWRHelptextPointsExpiring from '@salesforce/label/c.PRM_HelpText_PointsExpiring';
import IPAHelptextvaluePrevPeriod from '@salesforce/label/c.PRM_helptext_prev';
//import TotalApprovedOffering from '@salesforce/label/c.PRM_Total_Approved_Offering';//IPA2.0 TWC727-3228
import NumberOfEmployees from '@salesforce/label/c.PRM_No_of_Employees';
import PointsCurrentBalance from '@salesforce/label/c.PRM_points_current_balance_info';
//import TotalApprovedSolutions from '@salesforce/label/c.PRM_Total_Approved_Solutions';//IPA2.0 TWC727-3228
import alertMessage from '@salesforce/label/c.PRM_Partner_Performance_Alert';

export default class Prm_salesAndTrainingCmp extends LightningElement {
    @api recordId;
    @track alert_Message =alertMessage
	@track totalPointsBalance= total_PointsBalance;
    @track totalSalesData = total_SalesData;
    @track totalTrainingCredits = total_TrainingCredits;
    @track totalSalesDataPrev = total_SalesDataPrev;
    @track totalTrainingCreditsPrev = total_TrainingCreditsPrev;
    @track totalPointsExpired = total_PointsExpired;
    @track metricLabel = metric;
    @track totalAWRremaining = total_AWR_remaining;
    @track totalAWRallocated = total_AWR_allocated;
    @track IPAhereLabel=IPAhere;
    @track IPAClickLabel=IPAClick;
    @track IPAInstructionLabel=IPAInstruction;
    @track IPAmetricLinkLabel=IPAmetricLink;
    @track IPAHelptextvaluelabel=IPAHelptextvalue;
    @track IPAAWRHelptextvaluelabel=IPAAWRHelptextvalue;
    @track IPAAWRHelptextPointsExpiringLabel=IPAAWRHelptextPointsExpiring;
    @track IPAHelptextvaluePrevPeriod=IPAHelptextvaluePrevPeriod;
    //@track TotalApprovedOffering = TotalApprovedOffering;//IPA2.0 TWC727-3228
    @track NumberOfEmployees = NumberOfEmployees;
    @track IPAHelpTextPointsCurrentBalance = PointsCurrentBalance;
	@track total_PointsBalancenbr = 0;
    @track total_PointsExpirednbr = 0;
    @track total_SalesDatanbr = 0;
    @track total_TrainingCreditsnbr = 0;
    @track total_SalesDatanbrPrev = 0;
    @track total_TrainingCreditsnbrPrev = 0;
    @track total_AWR_allocatednbr = 0;
    @track total_AWR_remainingnbr = 0;
    @track totalTrainedResourcesnbr = 0;
    //@track totalApprovedOffering = 0;//IPA2.0 TWC727-3228
    @track isLoaded = false;
    // IPA2.0 TWC727-3228 starts here
    // @track isPublishedStorefront;
    // @track publishedStorefrontText = publishedStorefrnt;
    // @track isPublishedText;//IPA2.0
    //@track TotalApprovedSolutions = TotalApprovedSolutions;
    //@track totalApprovedSolutions = 0;//IPA2.0 
    // IPA2.0 TWC727-3228 ends here

   // @track published = ispublished;
   // @track notPublished = isNotpublished;
   
    // label = {
    //     ispublished,
    //     isNotpublished
    // };//IPA2.0 TWC727-3228

    resetAttributes() {
		this.total_PointsBalance= 0;
        this.total_PointsExpirednbr = 0;
        this.total_SalesDatanbr = 0;
        this.total_TrainingCreditsnbr = 0;
        this.total_TrainingCreditsnbrPrev = 0;
        this.total_SalesDatanbrPrev = 0;
        this.total_AWR_allocatednbr = 0;
        this.total_AWR_remainingnbr = 0;
        this.totalTrainedResourcesnbr = 0;
        // this.totalApprovedOffering = 0;
        // this.totalApprovedSolutions=0;//IPA2.0 TWC727-3228
    }
    refreshAction() {
        this.isLoaded = false;
        this.resetAttributes();
        this.displayMethod();
    }

    displayMethod() {
        displayPointsData({ accID: this.recordId }).then(result => {
           // console.log("Record Id here -->" + this.recordId);
            if (result != null) {
                this.isLoaded = true;
                console.log('result -->' + JSON.stringify(result));
				this.total_PointsBalancenbr = this.convertNumber(result.totalPointsBalance, false);
                this.total_SalesDatanbr = this.convertNumber(result.totalSalesData, false,2);//utkarsh - passed false as a parameter while calling convertNumber method because we need to show actual sales data.
                this.total_TrainingCreditsnbr = this.convertNumber(result.totalTrainingCredits, false);//utkarsh - passed false as a parameter while calling convertNumber method because we need to show actual training data.
                this.total_PointsExpirednbr = this.convertNumber(result.totalPointsExpired, false);
                this.total_AWR_allocatednbr = this.convertNumber(result.totalAWRallocated, true);
                this.total_AWR_remainingnbr = this.convertNumber(result.totalAWRremaining, true);
                this.total_SalesDatanbrPrev=this.convertNumber(result.totalSalesDataPrevPeriod, false,2);//utkarsh - passed false as a parameter while calling convertNumber method because we need to show actual sales data.
                this.total_TrainingCreditsnbrPrev=this.convertNumber(result.totalTrainingCreditsPrevPeriod, false);//utkarsh - passed false as a parameter while calling convertNumber method because we need to show actual training data.
                this.totalTrainedResourcesnbr = this.convertNumber(result.totalTrainedResources, true);
                //IPA2.0 TWC727-3228 starts here
                //this.totalApprovedOffering = this.convertNumber(result.totalApprovedOffering, true);
                //this.isPublishedStorefront = result.publishedStorefront;
                //this.totalApprovedSolutions=this.convertNumber(result.totalApprovedSolutions, true);
                //console.log('here'+this.isPublishedStorefront );
                // IPA2.0 TWC727-3228 ends here
                
            } else {
                this.isLoaded = true;
                this.resetAttributes();
                console.log('received null');
            }
        })
        .catch(error => {
            this.isLoaded = true;
            console.log('displayPointsData.error -->' + JSON.stringify(error));
        });
    }


    /**
     * Returns an object that has properties used to render number values. Numbers greater than
     * 1000 and less than a million are converted to "xxx K" and numbers greater than a million
     * are converted to "xxx M". 
     *
     * @param {number | string} value  The value to convert.
     * @param {boolean} convert  Indicates if the value should be converted.
     * @returns {object} The number data object returning properties for how decimal points should be
     * displayed, if a "K" or "M" should be displayed, and the actual value to display.
     */
    convertNumber(value, convert, decimalPrecision = 0) {//Utkarsh - Added extra default parameter to display decimal value only for sales data.
      // Default is no conversion
      const converted = {
        decimals: decimalPrecision,//utkarsh - added to display decimal value for sales data
        text: '',
        value,
      };

      if (convert) {
        if (value >= 1000 && value < 1000000) {
          // Convert the number to the "xxx K" format
          converted.decimals = 0;
          converted.text = 'K';
          converted.value = value / 1000;
        } else if (value >= 1000000 && value < 1000000000) {
            // Convert the number to the "xxx M" format
            converted.decimals = 0;
            converted.text = 'M';
            converted.value = value / 1000000;
          } else if (value >= 1000000000){
            // Convert the number to the "xxx M" format
            converted.decimals = 0;
            converted.text = 'B';
            converted.value = value / 1000000000;  
          }
      }
      return converted;
    }


    connectedCallback() {
        this.displayMethod();
    }
}