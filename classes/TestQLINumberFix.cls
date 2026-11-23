public class TestQLINumberFix {
    //TestQLINumberFix.createQLIs(new Set<Id>{Id.valueOf('a9Y2D000000ClBcUAK'), Id.valueOf('a9Y2D000000CmxnUAC')});    
    public static void createQLIs(Set<Id> quoteIds){
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();       
        for(Id quoteId : quoteIds){ 
            Integer i=1;
            while(i<=3){   
                SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
                newQuoteLine.SBQQ__Quote__c = quoteId; //set parent ref
                newQuoteLine.Pricing_Status_Nm__c = Label.Pricing_Tender_QuoteLine_Status_Draft;
                newQuoteLine.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__QuoteLine__c', Label.Pricing_Tender_QuoteLine_RecordType_Create);
                newQuoteLine.Pricing_Manager__c = null;
                newQuoteLine.Pricing_Meet_Comp_Price_Amt__c = null;
                newQuoteLine.Pricing_ECAP_Price_Amt__c = null;
                newQuoteLine.Pricing_ECAP_Price_Dup_Amt__c = null; //Duplicate Field
                newQuoteLine.Pricing_MMBP_System_Nm__c = null;
                newQuoteLine.Pricing_Deal_RFQ_Id__c = null;
                newQuoteLine.Pricing_Deal_RFQ_Dup_Id__c = null; //Duplicate Field
                newQuoteLine.Pricing_Deal_RFQ_Status_Nm__c = null;
                newQuoteLine.Pricing_Won_Lost_Comments_Txt__c = null;
                newQuoteLine.Pricing_pm_approval_comments_nm__c = null;
                newQuoteLine.Pricing_Additional_Comments_Txt__c = null;
                newQuoteLine.Pricing_Previous_Status_Nm__c = 'Pending';
                newQuoteLine.Pricing_End_Date_dt__c = system.Today()+1;
                newQuoteLine.Pricing_FSE_Recommended_Price_Nm__c = null;
                newQuoteLine.Pricing_Approved_Start_Date_Dt__c = null;
                newQuoteLine.Pricing_Approved_Start_Date_Dup_Dt__c = null; //Duplicate Field
                newQuoteLine.Pricing_Approved_End_Date_Dt__c = null;
                newQuoteLine.Pricing_Approved_End_Date_Dup_Dt__c = null; //Duplicate Field
                newQuoteLine.Pricing_Approved_Unit_Qty__c = 5;
                newQuoteLine.Pricing_Approved_Unit_Dup_Qty__c = null; //Duplicate Field
                newQuoteLine.Pricing_Quote_Line_Number__c = null;
                newQuoteLine.Pricing_Reference_Quote_Line_Nbr__c = null;
                newQuoteLine.Pricing_Change_Request_cb__c = false;
                newQuoteLine.Pricing_Sales_Rep_Approver__c = null;
                newQuoteLine.Pricing_New_Quantity_qty__c = null;
                newQuoteLine.Pricing_Ready_for_Review_cb__c = false;
                newQuoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = null;
                newQuoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = null;
                newQuoteLine.Pricing_Deal_Description__c = null;
                newQuoteLine.Pricing_Billing_Start_Date_Dt__c = null;
                newQuoteLine.Pricing_Billing_End_Date_Dt__c = null;
                newQuoteLine.Pricing_Quote_Line_Won_Lost_Status__c = null;
                
                //TPT
                newQuoteLine.Pricing_Original_Submitted_By_Id__c = null;
                newQuoteLine.Pricing_Original_Submitted_Date_dt__c = null;
                newQuoteLine.Pricing_Last_Approved_Date_dt__c = null;
                newQuoteLine.Customer_Revision_Count_Cnt__c = null;
                newQuoteLine.Field_Revision_Count_Cnt__c = null;
                newQuoteLine.Pricing_Last_Submitted_By_Id__c = null;
                newQuoteLine.Pricing_Last_Submitted_Date_dt__c = null;
                //TPT
                //walk story updates US544539
                newQuoteLine.Pricing_Integration_Status_Nm__c = null;
                newQuoteLine.Pricing_Deal_RFQ_Status_Nm__c = null;
                newQuoteLine.Pricing_Error_Messages__c = null;
                //walk story updates US544539
                
                newQuoteLine.Pricing_Additional_T_C_s_Txt__c = null;
                newQuoteLine.Pricing_Is_Additional_T_C_Not_Blank_cb__c = false;
                newQuoteLine.Pricing_Backdate_Reason_Txt__c = null;
                newQuoteLine.Pricng_Exclude_from_Price_Approval_Rules__c = false;
                newQuoteLine.Pricing_Group_Type_nm__c = 'Mutually Exclusive';
                newQuoteLine.Pricng_Exclude_from_Price_Approval_Rules__c = false;
                
                newQuoteLine.Pricing_Request_Discount_Unit_Price_qty__c = null;
                newQuoteLine.Pricing_Revised_Pricing_Start_Date_dt__c = null;
                newQuoteLine.Pricing_Revised_Pricing_Start_Date_D_dt__c = null;
                newQuoteLine.Pricing_Market_Segment_Nm__c = Label.Pricing_Tender_Market_Segment_Default;
                newQuoteLine.Pricing_Market_Segment_values_Nm__c = Label.Pricing_Tender_Market_Segment_Values_Default;
                newQuoteLine.Pricing_RegionQL_Nm__c = Label.Pricing_Tender_Default_Region_Worldwide;
                
                newQuoteLine.Pricing_Quote_Line_Status_Number__c = null;
                newQuoteLine.Pricing_Integration_Time_Stamp__c = null;
                newQuoteLine.Pricing_Previous_MyDeal_Action_Nm__c = null;
                newQuoteLine.Pricing_Create_Deal_Actor_Id__c = null;
                newQuoteLine.Pricing_Update_Status_to_Rejected_cb__c = false;
                newQuoteLine.Pricing_Previous_Inbound_Msg_Number__c = null;
                newQuoteLine.core_cpq_dollar_change_flag_cb__c = false;
                //insert newQuoteLine;
                quoteLineList.add(newQuoteLine);
                i++;
            }
        }
        if(quoteLineList.size() > 0){
            insert quoteLineList;
        }
    }
}