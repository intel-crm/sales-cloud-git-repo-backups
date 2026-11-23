/**
* @description       : Making the class name with the object type and extends it with fflib_SObjectSelector
* @author            : Rakshitha BR
* @group             : Gravity
* @last modified on  : 03-28-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public class Pricing_QuoteLines_Selector extends fflib_SObjectSelector {
    /**
* Creates a new instance of the selector via the application class. This is here to allow unit tests to override
* and inject a mock instead of this class or to switch out this class for a new version.
*
*/
    public static Pricing_QuoteLines_Selector newInstance() {
        
        
        return (Pricing_QuoteLines_Selector) Pricing_IQR_Application.selector.newInstance(SBQQ__QuoteLine__c.SObjectType);
    }
    
    /**
* @description getSObjectType to know the type of object
* @author Rakshitha BR | 03-28-2022 
* @return Schema.SObjectType 
**/
    public Schema.SObjectType getSObjectType(){
        return SBQQ__QuoteLine__c.sObjectType;
    }
    
    /**
* @description getSObjectFieldList to get the list of feilds
* @author Rakshitha BR | 03-28-2022 
* @return List<Schema.SObjectField> 
**/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    /**
* @description Add the Method type and its parameter
* @author Rakshitha BR| 03-28-2022 
* @param quoteIds 
* @return List<SBQQ__QuoteLine__c> 
**/
    public List <SBQQ__QuoteLine__c> selectByQuoteIds(set<Id> quoteIds){
        return [Select Id , SBQQ__Quote__c,price_brokencost_amt__c,price_suggested_resale_amt__c,SBQQ__Product__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN: quoteIds ];
    }
    
    public List<SBQQ__QuoteLine__c> selectAndOrderByQuoteIds (List<Id> quoteIds){
        return [Select Id,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__PriceBook__r.Name,SBQQ__Product__c,price_brokencost_amt__c,price_requested_resale_amt__c,price_suggested_resale_amt__c,price_disty_cost_nbr__c,SBQQ__ListPrice__c
                from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:quoteIds order by SBQQ__Quote__c];
    }
    public List<SBQQ__QuoteLine__c> selectByQuoteLineIds(Set<Id> quoteLineIds){
        return [SELECT Id, Pricing_Product_Nm__r.Name,Pricing_Other_Product_Nm__c, Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c,
                Pricing_FSE_Recommended_Price_Nm__c, Pricing_ECAP_Price_Amt__c,Pricing_Integration_Status_Nm__c,Pricing_Deal_RFQ_Status_Nm__c,RecordTypeId,
                Pricing_Approved_End_Date_Dt__c, Pricing_Approved_Unit_Qty__c,SBQQ__ProductName__c, Pricing_Other_Competitor_Product_Nm__c, Pricing_Competetor_Product__c,
                Pricing_Approved_Start_Date_Dt__c, Pricing_Meet_Comp_Price_Amt__c, Pricing_Deal_RFQ_Id__c, Pricing_Program_Type_Nm__c,
                Pricing_Status_Nm__c, SBQQ__Quote__r.SBQQ__Status__c, Pricing_Sales_Rep__c,CreatedById, Pricing_Primary_Contact_Nm__c, SBQQ__Quote__r.OwnerId, SBQQ__Quote__r.CreatedById, 
                Pricing_Change_Request_cb__c,Pricing_Reference_Quote_Line_Nbr__c,SBQQ__Quote__r.SBQQ__Account__c,Name,Pricing_pm_approval_comments_nm__c 	, Pricing_Rejection_Comments_nm__c,SBQQ__Quote__c,
                Pricing_Sales_Rep_Approver__c,Pricing_Last_Submitted_By_Id__c,Pricing_Ready_for_Review_cb__c,Customer_Revision_Count_Cnt__c,Field_Revision_Count_Cnt__c, 
                SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id,Pricing_Sales_Rep_Approver__r.Id,SBQQ__Quote__r.Id,SBQQ__Quote__r.Name,Pricing_Won_Lost_Comments_Txt__c,Pricing_Last_Approved_Date_dt__c,Pricing_Original_Submitted_Date_dt__c,Pricing_Last_Submitted_Date_dt__c
                From SBQQ__QuoteLine__c WHERE Id In : quoteLineIds];  
    }
    
    public List<SBQQ__QuoteLine__c> selectByIdAndStatus(Id quoteLineId, String qliStatus) {
        return [SELECT Id, Name, SBQQ__ProductName__c, Pricing_Other_Product_Nm__c, Pricing_Quote_Line_Number__c, Pricing_Status_Nm__c,Pricing_Integration_Status_Nm__c, Pricing_Error_Messages__c,Pricing_Program_Type_Nm__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = : quoteLineId and Pricing_Status_Nm__c !=: qliStatus  ORDER BY Pricing_Quote_Line_Number__c ASC];
    } 
    
    public List<SBQQ__QuoteLine__c> selectByIdAndPM(Id parentId) {
        return [SELECT Id, SBQQ__Quote__c,SBQQ__Quote__r.Pricing_My_Deals_Folio_Name_Nm__c,SBQQ__Quote__r.Id, 
                SBQQ__Quote__r.Name, Pricing_EndCustomer_Nm__c, SBQQ__Quote__r.Pricing_Folio_ID_Nm__c,SBQQ__Quote__r.Pricing_Deal_Type_Nm__c,
                Pricing_Reference_Quote_Line_Nbr__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c,SBQQ__Quote__r.Pricing_Customer_Nm__c,SBQQ__Quote__r.Pricing_Project_Name_Nm__c,
                SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Other_Competitor_Product_Nm__c,SBQQ__Quote__r.Pricing_ShipmentEndDate_Dt__c,
                SBQQ__Quote__r.Pricing_Server_Deal_Type_Nm__c,SBQQ__Quote__r.Pricing_Region_Nm__c,Pricing_Other_Product_Nm__c,Pricing_Manager__c,
                Pricing_Manager__r.Core_WWID__c,SBQQ__Quote__r.SBQQ__Account__r.Id,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__Account__r.Core_CIM_ID__c,
                Name,Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_Group_Type_nm__c,Pricing_Billing_Start_Date_Dt__c,
                Pricing_Billing_End_Date_Dt__c,Pricing_Backdate_Reason_Txt__c,Pricing_Market_Segment_Nm__c,Pricing_ECAP_Price_Amt__c,
                Pricing_Meet_Comp_Price_Amt__c,Pricing_Unit_Qty__c,Pricing_Deal_RFQ_Id__c,Pricing_Status_Nm__c,SBQQ__Quote__r.Pricing_End_Customer_Country_Nm__c,
                Pricing_Approved_Start_Date_Dt__c,Pricing_Approved_End_Date_Dt__c,Pricing_Project_Nm__c,Pricing_Approved_Unit_Qty__c,Pricing_Deal_RFQ_Status_Nm__c, 
                Pricing_Quote_Line_Number__c,Pricing_Market_Segment_values_Nm__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,
                Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,
                SBQQ__Product__r.Id,SBQQ__Product__r.Name,SBQQ__Product__r.Core_Product_Name_EPM_ID__c,SBQQ__Product__r.Core_Family_Nm__c,SBQQ__Product__r.Core_Forecast_Product_Name__c,SBQQ__Product__r.Core_Processor_Number_Nm__c,Pricing_Product_Nm__r.Name,Pricing_Competetor_Product__r.Id,Pricing_Integration_Status_Nm__c,
                Pricing_Additional_T_C_s_Txt__c,Pricng_Exclude_from_Price_Approval_Rules__c,Pricing_RegionQL_Nm__c,Pricing_Deal_Description__c,Pricing_Competetor_Product__r.Name,
                SBQQ__Quote__r.Pricing_End_Customer__r.Name,SBQQ__Quote__r.Pricing_End_Customer__c,SBQQ__Quote__r.Pricing_End_Customer__r.Pricing_Unified_EndCustomer_Id__c,
                SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Unified_Country_EndCustomer_Id__c,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name,SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__c,SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c,SBQQ__Quote__r.Pricing_End_Customer_Name__c,Pricing_Program_Type_Nm__c,
                SBQQ__Quote__r.Pricing_Is_Sanctioned__c,Pricing_Account_Division_Nm__c,Pricing_Comp_Product_Txt__c,
                (SELECT Id,Name,Pricing_Weighting_Pct__c,Pricing_Quote_Line__r.Name,Pricing_Comp_SKU_Performance_Nbr__c,Pricing_Intel_SKU_Performance_Nbr__c,
                 Pricing_Performance_Metric_Nm__c FROM Performance_Metrics__r order by Pricing_Weighting_Pct__c desc limit 1) 
                FROM SBQQ__QuoteLine__c WHERE Id IN : (new Set<Id>{parentId})];
        
    } 
    
    public List<SBQQ__QuoteLine__c> overLapQuery(Map<Id,SBQQ__QuoteLine__c> quoteLineMap,Id parentId) {
        return [SELECT Id, Pricing_Quote_Line_Number__c, SBQQ__Quote__r.Pricing_Customer_Nm__c, SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Name, SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__c, SBQQ__Quote__r.Pricing_End_Customer__r.Name FROM SBQQ__QuoteLine__c 
                WHERE SBQQ__Quote__r.SBQQ__Account__c =: quoteLineMap.get(parentId).SBQQ__Quote__r.SBQQ__Account__c 
                AND Id !=: quoteLineMap.get(parentId).Id  
                AND Pricing_Project_Nm__c =: (quoteLineMap.get(parentId).Pricing_Project_Nm__c).trim() 
                AND Pricing_Product_Nm__r.Name =: (quoteLineMap.get(parentId).Pricing_Product_Nm__r.Name).trim() 
                AND ((Pricing_Approved_Start_Date_Dt__c <= :quoteLineMap.get(parentId).Pricing_Approved_Start_Date_Dt__c AND Pricing_Approved_End_Date_Dt__c >= :quoteLineMap.get(parentId).Pricing_Approved_Start_Date_Dt__c) OR
                     (Pricing_Approved_Start_Date_Dt__c <= :quoteLineMap.get(parentId).Pricing_Approved_End_Date_Dt__c AND Pricing_Approved_End_Date_Dt__c >= :quoteLineMap.get(parentId).Pricing_Approved_End_Date_Dt__c) OR 
                     (Pricing_Approved_Start_Date_Dt__c >= :quoteLineMap.get(parentId).Pricing_Approved_Start_Date_Dt__c AND Pricing_Approved_End_Date_Dt__c <= :quoteLineMap.get(parentId).Pricing_Approved_End_Date_Dt__c)) 
                AND Pricing_Quote_Line_Number__c !=: quoteLineMap.get(parentId).Pricing_Reference_Quote_Line_Nbr__r.Pricing_Quote_Line_Number__c 
                AND (Pricing_Deal_RFQ_Id__c != null OR Pricing_Integration_Status_Nm__c =: Label.Pricing_Tender_MyDeal_Integration_Status_Pending) 
                AND Pricing_Status_Nm__c IN : Label.Pricing_QL_Overlap_Deal_Statuses_Label.split(',')];
    }
    
    public List<SBQQ__QuoteLine__c> selectByIdAndProduct(Set<Id> quoteLineId) {
        return [SELECT Id, SBQQ__Product__r.Name, SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c, SBQQ__Quote__r.Pricing_Is_Sanctioned__c, 
                SBQQ__Quote__r.Pricing_Unified_Global_End_Customer_Nm__r.Pricing_Compliance_Watch_List__c, Pricing_Quote_Line_Number__c FROM SBQQ__QuoteLine__c 
                WHERE SBQQ__Product__r.Name !=: Label.Pricing_Write_In_Product AND Id IN: quoteLineId];
    }
    
    public List<SBQQ__QuoteLine__c> selectByRefQLIIdAndStatus(Id quoteLineId,String Status) {
        return [SELECT Id, Pricing_Quote_Line_Number__c FROM SBQQ__QuoteLine__c WHERE Pricing_Reference_Quote_Line_Nbr__c = : quoteLineId AND Pricing_Status_Nm__c !=: status];
    }
    
    public List<SBQQ__QuoteLine__c> selectByRefQLIIdsAndStatus(Set<Id> recIds,String Status) {
        return [SELECT Pricing_Reference_Quote_Line_Nbr__c FROM SBQQ__QuoteLine__c where Pricing_Reference_Quote_Line_Nbr__c IN: recIds and Pricing_Status_Nm__c !=: status];
    }
    
    public List<SBQQ__QuoteLine__c> selectByIdsAndPM(Set<Id> quoteLineIds) {
        return [SELECT Id,Pricing_Program_Type_Nm__c,(SELECT Id,Name,Pricing_Quote_Line__c FROM Performance_Metrics__r)
                FROM SBQQ__QuoteLine__c where Id IN :quoteLineIds];
    }
    
    public List<SBQQ__QuoteLine__c> selectByRefQlis(Set<Id> quoteLineIds) {
        return [SELECT Id,SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c,
                Pricing_Reference_Quote_Line_Nbr__r.Pricing_Request_Discount_Unit_Price_qty__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_End_Date_Dt__c,
                Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Unit_Qty__c,Pricing_Reference_Quote_Line_Nbr__r.Pricing_ECAP_Price_Amt__c,
                Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c,
                Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c,
                Pricing_Reference_Quote_Line_Nbr__r.Pricing_Won_Lost_Comments_Txt__c
                from SBQQ__QuoteLine__c where Id IN: quoteLineIds];
    }
    
    public List<SBQQ__QuoteLine__c> selectByQuoteIdAndRefQlisNull(Set<Id> quoteIds) {
        return [SELECT Id, SBQQ__Quote__c, SBQQ__Quote__r.Name, Pricing_Quote_Line_Number__c FROM SBQQ__QuoteLine__c
             WHERE SBQQ__Quote__c IN: quoteIds AND Pricing_Reference_Quote_Line_Nbr__c = null
            ];
    }
}