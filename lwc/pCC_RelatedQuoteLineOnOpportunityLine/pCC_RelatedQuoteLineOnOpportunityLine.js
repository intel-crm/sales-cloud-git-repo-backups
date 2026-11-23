import { LightningElement,wire,api } from 'lwc';
import getQLIFromOLI from '@salesforce/apex/PCC_OpportunityLine_Controller.getQuoteLineIdFromOpportunityLineId';
import getOpportunityLineItemsWithFieldSet from '@salesforce/apex/CRM_QuoteRequestController.getOpportunityLineItemsWithFieldSet';


import QUOTE_LINE_Name_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Name';
import QUOTE_LINE_Additional_Comments_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Additional_Comments_Txt__c';
import QUOTE_LINE_Total_Volume_Qty_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Total_Volume_Qty__c';
import QUOTE_LINE_Pricing_Competetor_Product_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Competetor_Product__c';
import QUOTE_LINE_Pricing_FI_OEM_Name_Nm__FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_FI_OEM_Name_Nm__c';
import QUOTE_LINE_Pricing_FI_Write_In_OEM_Name_Txt_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_FI_Write_In_OEM_Name_Txt__c';
import QUOTE_LINE_Pricing_Fl_Competitor_OEM_Name_Nm_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Fl_Competitor_OEM_Name_Nm__c';
import QUOTE_LINE_Pricing_Competitor_OEM_Nm_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Competitor_OEM_Nm__c';
import QUOTE_LINE_Pricing_OEM_System_Model_Nm_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_OEM_System_Model_Nm__c';
import QUOTE_LINE_Pricing_Product_Nm_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Product_Nm__c';
import QUOTE_LINE_Pricing_Form_Factor_Nm_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Form_Factor_Nm__c';
import QUOTE_LINE_Pricing_Competitor_System_Model_Nm_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Competitor_System_Model_Nm__c';
import QUOTE_LINE_Pricing_Approved_Start_Date_Dt_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Approved_Start_Date_Dt__c';
import QUOTE_LINE_Pricing_Approved_End_Date_Dt_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Approved_End_Date_Dt__c';
import QUOTE_LINE_Pricing_Start_Date_dt_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_Start_Date_dt__c';
import QUOTE_LINE_Pricing_End_Date_dt_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_End_Date_dt__c';
import QUOTE_LINE_Pricing_FI_Net_RPU_Amt_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Pricing_FI_Net_RPU_Amt__c';


export default class PCC_RelatedQuoteLineOnOpportunityLine extends LightningElement {
    @api recordId; // This will automatically receive the recordId of the current record
    relatedQuoteLineId;
    fields = [ QUOTE_LINE_Name_FIELD, QUOTE_LINE_Additional_Comments_FIELD, QUOTE_LINE_Total_Volume_Qty_FIELD, QUOTE_LINE_Pricing_Competetor_Product_FIELD, QUOTE_LINE_Pricing_FI_OEM_Name_Nm__FIELD, QUOTE_LINE_Pricing_FI_Write_In_OEM_Name_Txt_FIELD, QUOTE_LINE_Pricing_Fl_Competitor_OEM_Name_Nm_FIELD, QUOTE_LINE_Pricing_Competitor_OEM_Nm_FIELD, QUOTE_LINE_Pricing_OEM_System_Model_Nm_FIELD, QUOTE_LINE_Pricing_Product_Nm_FIELD, QUOTE_LINE_Pricing_Form_Factor_Nm_FIELD, QUOTE_LINE_Pricing_Competitor_System_Model_Nm_FIELD, QUOTE_LINE_Pricing_Approved_Start_Date_Dt_FIELD, QUOTE_LINE_Pricing_Approved_End_Date_Dt_FIELD, QUOTE_LINE_Pricing_Start_Date_dt_FIELD, QUOTE_LINE_Pricing_End_Date_dt_FIELD, QUOTE_LINE_Pricing_FI_Net_RPU_Amt_FIELD];
    
    @wire(getQLIFromOLI, { recordId: '$recordId' })
    wiredRecord({ error, data }) {
        if (data) {
            this.relatedQuoteLineId = data;
        } else if (error) {
            // Handle error
        }
    }

    columns1 = [];
    opportunityLineItems = [];
    error;
    // Wire method to fetch Opportunity Line Items and field set information
    @wire(getOpportunityLineItemsWithFieldSet, { recordId: '$recordId' }) // Pass record Id to Apex method
    getOpportunityLineItemsWithFieldSet({ error, data }) {
        if (data) {
            this.opportunityLineItems = data.opportunityLineItems;
           // this.columns1 = this.parseFieldSet(data.fieldSetMap);
        } else if (error) {
            this.error = error;
            console.error('Error fetching Opportunity Line Items with field set: ', error);
        }
    }
}