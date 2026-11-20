/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-07-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class core_updateOpptyLineItemLWC { //TWC3123-5759 Added without sharing keyword to fix code scan issue
    @AuraEnabled
    public static OpportunityLineItem updateOpptyLineItemRecord(ID recordId, String wipname, String groupname, String status, Decimal qty, Decimal pwqty, Decimal unitprice, Decimal pwsalesprice, String losscancelreason, String losscanceldetails, ID vendor, /*String advtech,*/ String competitor, String compprodval, String othercompprod, ID bumappingrec,Boolean isUserChangedNull , Boolean isUserChangedNullPW){
        
        
        OpportunityLineItem oli = [Select Id,OpportunityId, Product2Id, ProductCode, Name, Quantity, TotalPrice, UnitPrice, ListPrice, ServiceDate, Description, Core_At_Risk_Status__c, Core_Claim_Date__c, Core_Competitor_Product__c, Core_Competitor__c, Core_Division__c, Core_Group__c, Core_Lost_Sales_Price__c, Core_Lost_Total_Price__c, Core_Lost_to_Open_Flag__c, Core_OEM_LOEM_Other__c, Core_OEM_LOEM__c, Core_Product_Type__c, Core_Status__c, Core_Write_In_Product_Name__c, Core_Loss_Cancel_Reason__c, Core_Approved_Commissionable__c, Core_System_Commissionable__c, Core_System_Competitor_Empty_Flag__c, Core_Production_Claim_Date__c,  Core_Production_Cancelled_Sales_Price__c, Core_Production_Lost_Sales_Price__c, Core_Approved_User_Id__c, Core_SPG_Planning_Segment_Legacy__c, Core_BU_Mapping_record__c, Core_Opportunity_Product_ID__c, Core_Product2_Division__c, Core_Write_In_Product_Flag__c, Core_Opp_Approved_Oppty_Coverage__c, Core_Opp_Approved_Sales_Group__c, Core_Design_Registration_Product_Id__c, Core_Technical_Owner_Email_Txt__c, Core_Available_for_New_Designs__c, Core_Approved_KPI_Product_Group__c, CRM_DW_App_UCD_Customer_Name__c, Core_Vendor__c, Core_Vendor_Group__c, Core_Opp_OpportunityType__c, Core_Design_Product_Category__c, Core_Approved_BU_Product_Segment__c, Core_Approved_BU_Short_Name__c, Core_Account_Name__c, Core_Product_Application__c, Core_Product_Segment__c, Core_Software_Stack__c, Core_Vertical_Market__c, Core_UCD_Global_Account_Name__c, Core_Approved_Opp_Product_Segment__c, Core_Opp_Product_Segment__c, /*Core_Advanced_Technology__c,*/ Core_At_Risk__c, Core_Risk_Category__c, Core_Risk_Priority__c, Core_Risk_Reason1__c, Core_Risk_Reason2__c, Core_OtherCompetitor_Product_Txt__c, Core_UCD_Opportunity_Product_Vendor__c, Core_Intel_vPro_Platform_Eligibility__c, Core_Product_Risk_Owner__c, Core_Loss_Cancel_Details__c, Core_Approved_Opportunity_Product_App__c, Core_Is_Product_EOL__c, Core_Owning_BU_ShortName__c, Core_BU_Short_Name__c, Core_BU_Product_Segment__c, Core_Vendor_InActive__c, Core_Owning_BU_Short_Name_New__c, Core_BypassFlow__c, Failed_DDR_RecordID__c, Core_PW_Quantity__c, Core_PW_Sales_Price__c, Core_PW_Approved_By__c, Core_PW_Manager_Approved_Date__c, Core_PW_Approved_Quantity__c, Core_PW_Approved_Sales_Price__c, Core_PW_Approved_Total_Price__c, Core_Production_Win_Total_Price__c, Core_PW_Lost_Price__c, Core_PW_Approved_BU_Short_Name__c, Core_PW_Approved_Sales_Group__c, Core_PW_Approved_BU_Product_Segment__c, Core_PW_Approved_KPI_Product_Group__c, CRM_PW_App_UCD_Customer_Name__c, Core_PW_Approved_Commissionable__c
                                   FROM OpportunityLineItem 
                                   WHERE ID =: recordId 
                                   LIMIT 1
                                  ];
        
        Boolean isFieldUpdated= false;
        
        if(wipname!=null)
        {
            oli.Core_Write_In_Product_Name__c = wipname;
        }
        if(groupname!=null)
        {
            oli.Core_Group__c = groupname;
        }
        if(status!=null)
        {
            oli.Core_Status__c = status;
        }
        if(qty!=null)
        {
            oli.Quantity = qty;
        }
        if(qty==null && isUserChangedNull)
        {
            oli.Quantity = null;
        }
        if(pwqty!=null)
        {
            oli.Core_PW_Quantity__c = pwqty;
        }
        //Fix for value provided is invalid for action parameter 'pwqty' of decimal
        if(pwqty==null && isUserChangedNullPW)
        {
            oli.Core_PW_Quantity__c = null;
        }
        //Fix end
        if(unitprice!=null)
        {
            oli.UnitPrice = unitprice;
        }
        if(unitprice==null && isUserChangedNull)
        {
            oli.UnitPrice = null;
        }
        if(pwsalesprice!=null)
        {
            oli.Core_PW_Sales_Price__c = pwsalesprice;
        }
        //Fix for value provided is invalid for action parameter 'unitprice' of decimal
        if(pwsalesprice==null && isUserChangedNullPW)
        {
            oli.Core_PW_Sales_Price__c = null;
        }
        //Fix end
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
	// Commenting as part of TWC4767-4412
        /*if(advtech!=null)
        {
            oli.Core_Advanced_Technology__c = advtech;
        }*/
        if(competitor!=null)
        {
            oli.Core_Competitor__c = competitor;
        }
        if(compprodval!=null)
        {
            oli.Core_Competitor_Product__c = compprodval;
        }
        if(othercompprod!=null)
        {
            oli.Core_OtherCompetitor_Product_Txt__c = othercompprod;
        }
        if(bumappingrec!=null)
        {
            oli.Core_BU_Mapping_record__c = bumappingrec;
        }
        update oli;
        return oli;
    }
    
    @AuraEnabled
    public static String getLoggedInUserType()
    {
        String LoggedInUserType = UserInfo.getUserType();
        return LoggedInUserType;
    }
    
    @AuraEnabled(cacheable=true)
    public static OpportunityLineItem getRecords(String recordId) {        
        OpportunityLineItem oli = [Select Id, OpportunityId, core_status__c, SBQQ__QuoteLine__c, Core_IsPCCOpportunity_cb__c, SBQQ__QuoteLine__r.Pricing_Status_Nm__c, Opportunity.Core_Coverage_Type_Nm__c, Opportunity.Core_Opportunity_Coverage_Nm__c,Opportunity.RecordType.DeveloperName FROM OpportunityLineItem WHERE ID =: recordId ];
        return oli;       
    }
}