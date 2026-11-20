/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_OpportunityJSON
Version     : 1.0 
Created Date: 11 DEC 2020
Function    : Utility methods to create JSONs
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             12/11/2020              Original Version
* Gaurav Kurwade             19/10/2022              Updated with the Solution Area
* Shijas                     14/04/2023              Updated JSON OPTY Line Item - TWC4767-385
* Areefa                    29/02/2024               Adding Opportunity_Focus__c fields as part of TWC4767-1679
*****************************************************************************************************************************************************************************************************/

public class Core_OpportunityJSON implements Queueable,Database.AllowsCallouts{
    private List<String> OppIdList;
    
    public Core_OpportunityJSON(List<String> records){
        this.OppIdList = records;    
    }
    
    public class OpportunityLineItemWr {
        public string id;
        public string name;
        public string core_status;
        public string core_code_name;
        public string core_bu_shortname;
        public string core_producttype;
        public string core_product2id;
        public boolean core_intel_vpro_platform_eligibility;
        public string core_inf_kpi_prodgroup;
        public string core_advancedtechnology;
        public string core_bu_product_segment;
        public string core_approved_bu_product_segment;
        public string core_approved_bu_shortname;
        public datetime core_kpi_date;
        public double core_totalprice;
        public double core_quantity;
        public double core_approved_quantity;
        public double core_approved_total_price;
        public string core_approved_kpi_product_group;
        public datetime core_production_claim_date;
        public string core_approved_commissionable;
        public string core_approved_opportunity_product_app;        
        // code changes for TWC4767-385
        public double Core_PW_Quantity;
        public double Core_PW_Approved_Quantity;
        public double Core_PW_Approved_Total_Price;
        public double Core_Production_Win_Total_Price;
        public string Core_PW_Approved_Commissionable;
        public string Core_PW_Approved_KPI_Product_Group;
        public string Core_PW_Approved_BU_Short_Name;
        public string Core_PW_Approved_BU_Product_Segment;
    
        
    }
    public class returnWr{
        public List<Core_Log_Entry__c> ListlogEntry; 
        public List<Core_Log_Entry__c> logEntryupdateList = new List<Core_Log_Entry__c>();   
    }
    
    public class OpportunityWr {
        public string id;
        public string core_stage;
        public string core_consumption_market;
        public string core_opportunity_type;        
        public string core_commissionable;
        public date core_first_customer_ship_date;
        public string core_product_segment;
        public string core_product_application;
        public string core_opp_Unified_Global_Customer_Name;
        public string core_opp_prime_account_name;
        public string core_opportunity_products;        
        public string core_athena_candidate;
        public string core_accindustry;
        public string core_acc_bu_focus;
        public string core_country_label;
        public boolean core_architecture_conversion;
        public boolean core_exclude_from_KPIs;
        public datetime lastmodifieddate;
        public datetime systemmodstamp;
        public datetime kpilastupdate;
        public double core_volume;
        public string core_partner_type;
        public List<OpportunityLineItemWr> opportunitylineitem;
        //SA Change
        public List<solutionAreaWr> solution_Area;
        public string Core_Opportunity_Coverage_Nm;
        public string Core_Coverage_Type_Nm;
        public string Core_Account_Primary_Coverage;
        //Adding Opportunity_Focus__c fields as part of TWC4767-1679
        public string Core_Opportunity_Focus;
        
    }
    
    //Wrapper for Solution Area
    public class solutionAreaWr{
        public string Id;   
        public string Core_Industry_Use_Case;
        public string Core_Application_Workload;
        public string Core_Technology_Enabled;
        public string Core_Version;
    }
    
    /*
    * Method name  : createOpportunityJSON
    * Description  : 
    * Return Type  : VOID
    * Parameter    : List<String> OppIdListCore_
    * Modifer c hanges
    * Areefa    Adding Opportunity_Focus__c fields as part of TWC4767-1679

    */
    //public static void createOpportunityJSON(List<String> OppIdList){
    public void execute(QueueableContext context){
        List<OpportunityWr> opWrList= new List<OpportunityWr>();
        //List<Core_Log_Entry__c> logList = new List<Core_Log_Entry__c>();
        Map<id,List<OpportunityLineItem>> OppMap = new Map<id,List<OpportunityLineItem>>();
        map<id,List<id>> optySolAMap = new map<id,List<id>>();
        Map<id,Set<String>> OppPartnerMap = new Map<id,Set<String>>();
        Map<id,String> OppPartnerTypeMap = new Map<id,String>();
        Set<String> oppPartnerset = new Set<String> ();
       String partnerType;
        boolean ucdSwitch = Core_CRM_Utility.isUCDSwitchOn(); //TWC4767-3431 - implementation of UCD and CIM logic switch
        
        //Solution Area 
        List<Core_Solution_Areas__c> solutionArea = new List<Core_Solution_Areas__c>();

        List<string> allJsons = new List<string>();
        returnWr retwr= new returnWr();
     
        try{
        List<Opportunity> oplist = [select id,StageName,Core_Consumption_Market__c,Core_Product_Application__c,Core_Opp_Prime_Account_Name__c,CRM_Unified_Global_Customer_Name__c,Core_Opportunity_Type__c,core_architecture_conversion__c,Core_Solution_Area__c,
                                    Core_Solution_Type__c,core_commissionable__c, Core_First_Customer_Ship_Date__c, Core_Product_Segment__c,core_opportunity_products__c,
                                    core_solution_detail_dcg_ccg__c, core_solution_detail_iotg__c,lastmodifieddate,systemmodstamp,Core_Athena_Candidate__c,
                                    Core_Exclude_From_KPIs__c , account.industry,Core_Volume__c,accountId, Account.BillingCountry,account.core_account_bu_focus__c ,Account.Core_Account_Primary_Coverage__c, Core_Coverage_Type_Nm__c,Core_Opportunity_Coverage_Nm__c,Opportunity_Focus__c,(select id,Core_Advanced_Technology__c,Core_BU_Short_Name__c,Core_KPI_Date__c,
                                    lastmodifieddate,systemmodstamp, core_approved_quantity__c, core_approved_total_price__c,core_status__c,
                                    core_approved_bu_product_segment__c,Core_BU_Product_Segment__c, product2.name,product2.CORE_CODE_NAME__C,product2.Core_Intel_vPro_Platform_Eligibility__c,
                                    product2.core_inf_kpi_prodgroup__c,Core_Product_Type__c,product2id,Core_Approved_BU_Short_Name__c,
                                    TotalPrice,Quantity,Core_Approved_KPI_Product_Group__c,Core_Approved_Opportunity_Product_App__c,Core_Approved_Commissionable__c,Core_Production_Claim_Date__c
                                    ,Core_PW_Quantity__c   , Core_PW_Approved_Quantity__c  , 
                                     Core_PW_Approved_Total_Price__c  , Core_Production_Win_Total_Price__c ,
                                     Core_PW_Approved_Commissionable__c, Core_PW_Approved_KPI_Product_Group__c  , Core_PW_Approved_BU_Short_Name__c, Core_PW_Approved_BU_Product_Segment__c 
                                    from OpportunityLineItems where core_status__c !=: System.Label.Core_LineItem_Status) from opportunity where id IN:OppIdList];
                                    
            
       
        /* Solution Area Changes */
         solutionArea = [Select Id, tolabel( Core_Industry_Use_Case__c) , tolabel(Core_Application_Workload__c) , tolabel(Core_Technology_Enabled__c), Core_Version__c from Core_Solution_Areas__c Where id IN (select Core_Solution_Areas__c from Opportunity_Solution_Area__c where Core_Opportunity__c IN:OppIdList)]; 
            for(Opportunity_Solution_Area__c oSla : [Select Id,Core_Opportunity__c,Core_Solution_Areas__c from Opportunity_Solution_Area__c where Core_Opportunity__c IN:OppIdList]){
                List <Id> saId = new List<Id>();
                if(optySolAMap.containsKey(oSla.Core_Opportunity__c)){
                    saId = optySolAMap.get(oSla.Core_Opportunity__c);
                }
                saId.add(oSla.Core_Solution_Areas__c);
                optySolAMap.put(oSla.Core_Opportunity__c,saId);
            }         
            
        /* Solution Area Changes */
            
            if(oplist.size() > 0){
            for(Opportunity op: oplist){
                for(OpportunityLineItem oli : op.OpportunityLineItems){
                    if(!OppMap.containskey(op.id)){
                        OppMap.put(op.id, new List<OpportunityLineItem>{oli});
                    }
                    else{
                        OppMap.get(op.id).add(oli);
                    }  
                }
            }
        }
          //populating the partner types   
        List<Opportunity> oList = [SELECT Id,(SELECT Id, Name, Core_Partner_Type__c, Core_Opportunity__c FROM Opportunity_Partners__r)from opportunity
                                       where id IN:OppIdList];            
        if(oList.size() > 0){
            for(Opportunity op: oList){
                partnerType = '';
                if(op.Opportunity_Partners__r.size() > 0 && !op.Opportunity_Partners__r.isEmpty()){
                for(Core_Opportunity_Partner__c oppPartner : op.Opportunity_Partners__r){
                    if(!OppPartnerMap.containskey(op.id)){
                        OppPartnerMap.put(op.id, new Set<String>{oppPartner.Core_Partner_Type__c});
                    }
                    else{
                        OppPartnerMap.get(op.id).add(oppPartner.Core_Partner_Type__c);
                    }  
                }
                for(String oppPartnerType : OppPartnerMap.get(op.id)){
                    partnerType = partnerType + oppPartnerType + ';';
                }
                OppPartnerTypeMap.put(op.id, partnerType.removeEnd(';'));
                }
            }
        }
      
      
        for(Opportunity op: oplist){
            OpportunityWr opWr= new OpportunityWr();
            //populating the opportunity fields.
            opWr.id = op.id;
            opWr.core_stage = op.StageName;
            opWr.core_product_application = op.core_product_application__c;
            opWr.core_consumption_market = op.Core_Consumption_Market__c;
            opWr.core_opportunity_type = op.Core_Opportunity_Type__c;
            opWr.core_architecture_conversion = op.core_architecture_conversion__c;            
            opWr.core_commissionable = op.core_commissionable__c;
            opWr.core_first_customer_ship_date = op.core_first_customer_ship_date__c;
            opWr.core_product_segment = op.Core_Product_Segment__c;
            opWr.core_opportunity_products= op.core_opportunity_products__c;            
            opWr.systemmodstamp = datetime.valueOfGmt(string.valueof(System.now()));
            opWr.core_athena_candidate = op.Core_Athena_Candidate__c;
            opWr.core_exclude_from_KPIs = op.Core_Exclude_From_KPIs__c;
            opWr.core_accindustry = op.account.industry; 
            opWr.core_country_label = op.account.billingcountry;
            opWr.core_acc_bu_focus = op.account.core_account_bu_focus__c;
            opWr.core_volume = op.Core_Volume__c;
            opWr.Core_Coverage_Type_Nm = op.Core_Coverage_Type_Nm__c;
            opWr.Core_Opportunity_Coverage_Nm = op.Core_Opportunity_Coverage_Nm__c;
            opWr.Core_Account_Primary_Coverage = op.account.Core_Account_Primary_Coverage__c;
            
            if(ucdSwitch==true) {
                opWr.core_opp_Unified_Global_Customer_Name =  op.CRM_Unified_Global_Customer_Name__c ;//TWC4767-3431
            } 
            else{
                opWr.core_opp_prime_account_name = op.Core_Opp_Prime_Account_Name__c;//TWC4767-3431
            }
            
            //Adding Opportunity_Focus__c fields as part of TWC4767-1679
             opWr.Core_Opportunity_Focus = op.Opportunity_Focus__c;

            if(OppPartnerTypeMap.get(op.id) != Null){
            opWr.core_partner_type = OppPartnerTypeMap.get(op.id);
            }
             
            //populating the opportunity line item fields.
            List<opportunitylineitem> oplineitem = new List<opportunitylineitem>();
            if(OppMap.get(op.id) != null){
                oplineitem = OppMap.get(op.id);
            }
            List<OpportunityLineItemWr> OplineitemWrList= new List<OpportunityLineItemWr>();
            if(oplineitem.size()>0){
                for(opportunitylineitem oo : oplineitem){
                    
                    OpportunityLineItemWr OplineitemWr = new OpportunityLineItemWr();
                    
                    OplineitemWr.id= oo.id;
                    OplineitemWr.name = oo.product2.name;
                    OplineitemWr.core_code_name = oo.product2.CORE_CODE_NAME__C;
                    OplineitemWr.core_intel_vpro_platform_eligibility = oo.product2.Core_Intel_vPro_Platform_Eligibility__c;
                    OplineitemWr.core_inf_kpi_prodgroup = oo.product2.core_inf_kpi_prodgroup__c;
                    OplineitemWr.core_advancedtechnology = oo.CORE_ADVANCED_TECHNOLOGY__C;
                    OplineitemWr.core_bu_shortname = oo.Core_BU_Short_Name__c;
                    OplineitemWr.core_kpi_date = oo.Core_KPI_Date__c;
                    OplineitemWr.core_approved_quantity = oo.core_approved_quantity__c;
                    OplineitemWr.core_approved_total_price = oo.core_approved_total_price__c;
                    OplineitemWr.core_status = oo.core_status__c;
                    OplineitemWr.core_approved_bu_product_segment = oo.core_approved_bu_product_segment__c;
                    OplineitemWr.core_bu_product_segment = oo.Core_BU_Product_Segment__c;
                    OplineitemWr.core_producttype = oo.Core_Product_Type__c;
                    OplineitemWr.core_product2id = oo.product2id;
                    OplineitemWr.core_approved_bu_shortname = oo.Core_Approved_BU_Short_Name__c;
                    OplineitemWr.core_totalprice = oo.TotalPrice;
                    OplineitemWr.core_quantity = oo.Quantity;
                    OplineitemWr.core_approved_kpi_product_group = oo.Core_Approved_KPI_Product_Group__c;
                    OplineitemWr.core_production_claim_date = oo.Core_Production_Claim_Date__c;
                    OplineitemWr.core_approved_commissionable = oo.Core_Approved_Commissionable__c;
                    OplineitemWr.core_approved_opportunity_product_app = oo.Core_Approved_Opportunity_Product_App__c;
                    // code changes for TWC4767-385
                    OplineitemWr.Core_PW_Quantity = oo.Core_PW_Quantity__c;
                    OplineitemWr.Core_PW_Approved_Quantity = oo.Core_PW_Approved_Quantity__c;
                    OplineitemWr.Core_PW_Approved_Total_Price = oo.Core_PW_Approved_Total_Price__c;
                    OplineitemWr.Core_Production_Win_Total_Price = oo.Core_Production_Win_Total_Price__c;
                    OplineitemWr.Core_PW_Approved_Commissionable = oo.Core_PW_Approved_Commissionable__c;
                    OplineitemWr.Core_PW_Approved_KPI_Product_Group = oo.Core_PW_Approved_KPI_Product_Group__c;
                    OplineitemWr.Core_PW_Approved_BU_Short_Name = oo.Core_PW_Approved_BU_Short_Name__c;
                    OplineitemWr.Core_PW_Approved_BU_Product_Segment = oo.Core_PW_Approved_BU_Product_Segment__c;
                    OplineitemWrList.add(OplineitemWr);
                }
                //Core_OpportunityKPICallout.AuthCallout(JSON.serialize(opWr)); 
            }
            
            /****SOlution Area ***/
            List<solutionAreaWr> solutionWrapperList = new List<solutionAreaWr>();
            if(solutionArea.size()>0){
                for(Core_Solution_Areas__c sa : solutionArea){
                    if(optySolAMap.get(op.id).contains(sa.id)){
                        solutionAreaWr saWrap = new solutionAreaWr();
                        saWrap.Id = sa.Id;
                        saWrap.Core_Industry_Use_Case = sa.Core_Industry_Use_Case__c;
                        saWrap.Core_Application_Workload = sa.Core_Application_Workload__c;
                        saWrap.Core_Technology_Enabled = sa.Core_Technology_Enabled__c;
                        saWrap.Core_Version = sa.Core_Version__c;
                        solutionWrapperList.add(saWrap);
                    }    
                }
            }
            
            /****SOlution Area ***/
            
            
            if(OplineitemWrList.size()>0){  
                if(solutionWrapperList.size()>0){
                opWr.solution_Area = solutionWrapperList;
                    }
                opWr.opportunitylineitem = OplineitemWrList;
                retwr = Core_OpportunityKPICallout.AuthCallout(JSON.serialize(opWr),op.id,retWr);
                retwr.logEntryupdateList.addAll(retwr.ListlogEntry);
            }
            
          
        }
            
          
        
        }
        catch(exception e){            
            
             Core_Log_Entry__c logEntry = new Core_Log_Entry__c();                
                logEntry.Core_sObjectType__c = 'Opportunity';
                logEntry.Core_Origin__c = 'createOpportunityJSON';
                logEntry.Core_Severity__c = 'High';
                logEntry.Core_When__c = system.now();
                logEntry.Core_Project__c = 'Sales';              
                logEntry.Core_Message__c = 'Failed line number '+e.getLineNumber() ;
                logEntry.Core_Details__c =  'Error Message '+e.getStackTraceString();
                retwr.logEntryupdateList.add(logEntry );
               
        }
        finally
        {
              if(retwr.logEntryupdateList.size()>0){
                insert retwr.logEntryupdateList;
            }
        }
    }   
}