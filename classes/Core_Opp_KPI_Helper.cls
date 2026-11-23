/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_KPI_Helper
Version     : 1.0 
Created Date: 4th Jan 2024
Function    : Trigger handler method for Opportunity KPI
Modification Log :
* Developer                   Date             Description
* ----------------------------------------------------------------------------                 
* Shijas                4 Jan 2024              Code scan issue fix related code refactor
*****************************************************************************************************************************************************************************************************/

public class Core_Opp_KPI_Helper {
    
    public static List<Opportunity> Get_opplistForJSON (List<String> OppIdList){        
        
      return  [select id,Core_Consumption_Market__c,Core_Product_Application__c,CRM_Unified_Global_Customer_Name__c,Core_Opportunity_Type__c,core_architecture_conversion__c,Core_Solution_Area__c,
                                    Core_Solution_Type__c,core_commissionable__c, Core_First_Customer_Ship_Date__c, Core_Product_Segment__c,core_opportunity_products__c,
                                    core_solution_detail_dcg_ccg__c, core_solution_detail_iotg__c,lastmodifieddate,systemmodstamp,Core_Athena_Candidate__c,
                                    Core_Exclude_From_KPIs__c , account.industry,Core_Volume__c,accountId, Account.BillingCountry,account.core_account_bu_focus__c ,Account.Core_Account_Primary_Coverage__c, Core_Coverage_Type_Nm__c,Core_Opportunity_Coverage_Nm__c,(select id,Core_Advanced_Technology__c,Core_BU_Short_Name__c,Core_KPI_Date__c,
                                    lastmodifieddate,systemmodstamp, core_approved_quantity__c, core_approved_total_price__c,core_status__c,
                                    core_approved_bu_product_segment__c,Core_BU_Product_Segment__c, product2.name,product2.CORE_CODE_NAME__C,product2.Core_Intel_vPro_Platform_Eligibility__c,
                                    product2.core_inf_kpi_prodgroup__c,Core_Product_Type__c,product2id,Core_Approved_BU_Short_Name__c,
                                    TotalPrice,Quantity,Core_Approved_KPI_Product_Group__c,Core_Approved_Opportunity_Product_App__c,Core_Approved_Commissionable__c,Core_Production_Claim_Date__c
                                    ,Core_PW_Quantity__c   , Core_PW_Approved_Quantity__c  , 
                                     Core_PW_Approved_Total_Price__c  , Core_Production_Win_Total_Price__c ,
                                     Core_PW_Approved_Commissionable__c, Core_PW_Approved_KPI_Product_Group__c  , Core_PW_Approved_BU_Short_Name__c, Core_PW_Approved_BU_Product_Segment__c 
                                    from OpportunityLineItems where core_status__c !=: System.Label.Core_LineItem_Status) from opportunity where id IN:OppIdList];
        
    }
    
     public static List<Core_Solution_Areas__c> Get_solutionAreaForJSON (List<String> OppIdList){
         
       return [Select Id, tolabel( Core_Industry_Use_Case__c) , tolabel(Core_Application_Workload__c) , tolabel(Core_Technology_Enabled__c), Core_Version__c from Core_Solution_Areas__c Where id IN (select Core_Solution_Areas__c from Opportunity_Solution_Area__c where Core_Opportunity__c IN:OppIdList)]; 
         
     }
    
     public static List<Opportunity> Get_PartnerTypesForJSON (List<String> OppIdList){  
        return [SELECT Id,(SELECT Id, Name, Core_Partner_Type__c, Core_Opportunity__c FROM Opportunity_Partners__r)from opportunity where id IN:OppIdList]; 
     }

}