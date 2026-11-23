/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-21-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class getOpptyLineItemQtyUnitPrice {
    @AuraEnabled
    public static OpportunityLineItem updateOpptyLineItemRecord(ID recordId, String wipname, String groupname, String bushortname, String status, Double qty, Double pwqty, Decimal unitprice, Decimal pwsalesprice, String losscancelreason, String losscanceldetails, String vendor, String advtech, String competitor, String comprod, String bumappingrec){
         OpportunityLineItem oli = [Select Id, OpportunityId, Product2Id, ProductCode, Name, Quantity, TotalPrice, UnitPrice, ListPrice, ServiceDate, Description, Core_At_Risk_Status__c, Core_Claim_Date__c, Core_Competitor_Product__c, Core_Competitor__c, Core_Division__c, Core_Group__c, Core_KPI_Date__c, Core_KPI_Quantity__c, Core_KPI_Total_Price__c, Core_Lost_Sales_Price__c, Core_Lost_Total_Price__c, Core_Lost_to_Open_Flag__c, Core_OEM_LOEM_Other__c, Core_OEM_LOEM__c, Core_Product_Type__c, Core_Status__c, Core_Write_In_Product_Name__c, Core_Loss_Cancel_Reason__c, Core_KPI_SPG_Target_U__c, Core_KPI_SPG_U__c, Core_KPI_CPU_Price__c, Core_KPI_Business_Industry_Function__c, Core_KPI_CPU_Units__c, Core_KPI_Non_CPU_Price__c, Core_Approved_Commissionable__c, Core_System_Commissionable__c, Core_System_Competitor_Empty_Flag__c, Core_Production_Claim_Date__c, Core_KPI_Days_DesignWin_to_ProductionWin__c, Core_KPI_Production_Date__c, Core_Production_Cancelled_Sales_Price__c, Core_Production_Lost_Sales_Price__c, Core_Approved_User_Id__c, Core_SPG_Planning_Segment_Legacy__c, Core_BU_Mapping_record__c, Core_Opportunity_Product_ID__c, Core_Product2_Division__c, Core_Write_In_Product_Flag__c, Core_KPI_Product_Group__c, Core_Opp_Approved_Oppty_Coverage__c, Core_Opp_Approved_Sales_Group__c, Core_Design_Registration_Product_Id__c, Core_Technical_Owner_Email_Txt__c, Core_Available_for_New_Designs__c, Core_Approved_KPI_Product_Group__c, CRM_DW_App_UCD_Customer_Name__c, Core_Vendor__c, Core_Vendor_Group__c, Core_Opp_OpportunityType__c, Core_Design_Product_Category__c, Core_Approved_BU_Product_Segment__c, Core_Approved_BU_Short_Name__c, Core_Account_Name__c, Core_Form_Factor__c, Core_Operating_Systems__c, Core_Product_Application__c, Core_Product_Segment__c, Core_Software_Stack__c, Core_Vertical_Market__c, Core_UCD_Global_Account_Name__c, Core_Approved_Opp_Product_Segment__c, Core_Opp_Product_Segment__c, Core_Advanced_Technology__c, Core_At_Risk__c, Core_Risk_Category__c, Core_Risk_Priority__c, Core_Risk_Reason1__c, Core_Risk_Reason2__c, Core_Support_Granted_Not_Entrance_Date__c, Core_Support_Provided_Not_Entrance_Date__c, Core_OtherCompetitor_Product_Txt__c, Core_UCD_Opportunity_Product_Vendor__c, sbaa__ApprovalStatus__c, Core_Is_Renewal_Amend_PSG_Quote__c, Core_Intel_vPro_Platform_Eligibility__c, Core_Created_from_CPQ__c, Core_Risk_Detail__c, Core_Risk_Create_Date__c, Core_Risk_End_Date__c, Core_Product_Risk_Owner__c, Core_BU_Mapping_Key__c, Core_Loss_Cancel_Details__c, Core_Approved_Opportunity_Product_App__c, Core_Is_Product_EOL__c, Core_Owning_BU_ShortName__c, Core_BU_Short_Name__c, Core_BU_Product_Segment__c, Core_Vendor_InActive__c, Core_Owning_BU_Short_Name_New__c, Core_BypassFlow__c, Core_Support_Not_Provided_Date__c, Core_Opportunity_Type_RecordId__c, Failed_DDR_RecordID__c, Core_Solution_Area_Product_Id__c, Core_PW_Quantity__c, Core_PW_Sales_Price__c, Core_PW_Approved_By__c, Core_PW_Manager_Approved_Date__c, Core_PW_Approved_Quantity__c, Core_PW_Approved_Sales_Price__c, Core_PW_Approved_Total_Price__c, Core_Production_Win_Total_Price__c, Core_PW_Lost_Price__c, Core_PW_Approved_BU_Short_Name__c, Core_PW_Approved_Sales_Group__c, Core_PW_Approved_BU_Product_Segment__c, Core_PW_Approved_KPI_Product_Group__c,CRM_PW_App_UCD_Customer_Name__c, Core_PW_Approved_Commissionable__c
             FROM OpportunityLineItem 
             WHERE ID =: recordId 
             LIMIT 1
            ];
            System.debug('field Value is --> '+recordId+ ''+wipname+ ''+groupname + ''+bushortname + ''+status + ''+qty + ''+pwqty + ''+unitprice + ''+pwsalesprice);
            if(wipname!=null)
            {
                oli.Core_Write_In_Product_Name__c = wipname;
            }
            if(groupname!=null)
            {
                oli.Core_Group__c = groupname;
            }
            if(bushortname!=null)
            {
                oli.Core_Owning_BU_ShortName__c = bushortname;
            }
            if(status!=null)
            {
                oli.Core_Status__c = status;
            }
            if(qty!=null)
            {
                oli.Quantity = qty;
            }
            if(pwqty!=null)
            {
                oli.Core_PW_Quantity__c = pwqty;
            }
            if(unitprice!=null)
            {
                oli.UnitPrice = unitprice;
            }
            if(pwsalesprice!=null)
            {
                oli.Core_PW_Sales_Price__c = pwsalesprice;
            }
            if(losscancelreason!=null)
            {
                oli.Core_Loss_Cancel_Reason__c = losscancelreason;
            }
            if(losscanceldetails!=null)
            {
                oli.Core_Loss_Cancel_Details__c = losscanceldetails;
            }
            if(vendor!=null)
            {
                oli.Core_Vendor__c = vendor;
            }
            if(advtech!=null)
            {
                oli.Core_Advanced_Technology__c = advtech;
            }
            if(competitor!=null)
            {
                oli.Core_Competitor__c = competitor;
            }
            if(comprod!=null)
            {
                oli.Core_OtherCompetitor_Product_Txt__c = comprod;
            }
            if(bumappingrec!=null)
            {
                oli.Core_BU_Mapping_record__c = bumappingrec;
            }
            
        update oli;
        System.debug('from apex'+oli);
        return oli;
        }  

}