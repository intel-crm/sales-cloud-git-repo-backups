/****************************************************************************************************************************************
* Class Name  : Core_MDF_Create_Budget 
* Version     : 1.0 
* Created Date: 05-07-2020
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         05/07/2020                    This class is used for Automated Budget Creation on Approval of Proposal for IPA   
*****************************************************************************************************************************************/

public without sharing class Core_MDF_Create_Budget {

    //to store IPA Record Type ID
    public static Id ipaRecordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get(Label.Core_MDF_IPA_Record_Type_Developer_Name).getRecordTypeId();  
    //to store Channel MDF Proposal Based Record Type ID
   // public static Id channelMDFProposalBasedRT = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get(Label.Core_MDF_CMDF_Proposal_Based_RT).getRecordTypeId();  
    //to store IPA Allocation record Type ID
    public static Id ipaPFARecordtype = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get(Label.Core_MDF_IPA_RecordType).getRecordTypeId();
    //Core_MDF_Channel_MDF
   // public static Id channelMDFPFARecordtype = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get(Label.Core_MDF_Channel_MDF).getRecordTypeId();
/***************************************************************************************************** 
Method Name:        manageBudget
@return  :          Map<Campaign,PartnerMarketingBudget>
@parameters:        List<Campaign>
Description:        This is a Method to create/update a budget when a proposal is approved
Added By:           Intel - SM - 07/07/2020
******************************************************************************************************/  
    public static Map<Campaign,PartnerMarketingBudget> manageBudget(List<Campaign> campList){
        Map<Campaign,PartnerMarketingBudget> campBudgetMap = new Map<Campaign,PartnerMarketingBudget>();
        //map to store camp budget if camp.account != budget.account
        Map<Campaign,PartnerMarketingBudget> campBudgetMapForNewPFA = new Map<Campaign,PartnerMarketingBudget>();
        try
        {
            //Map to store campaign and budget association
            List<Campaign> campToUpdate = new List<Campaign>();
            //to loop thro the incoming campaign list and decide whether to create/update a budget
            for(Campaign camp : campList)
            {
                if(camp.Core_MDF_Budget__c == null)
                {
                    //prepare data for new budget based on the campaign
                    PartnerMarketingBudget pmb = createBudgetForCampaigns(camp);
                    //creating map of campagin and budget if their associate accounts are different
                    if(camp.Core_MDF_Account__c != pmb.Core_MDF_Budget_Partner__c){
                        campBudgetMapForNewPFA.put(camp,pmb);
                    }
                    campBudgetMap.put(camp,pmb);
                }
                else
                {
                    //List to hold campaigns whose budget has to be updated
                    campToUpdate.add(camp);
                }
            }
            
            if(campBudgetMap != NULL && campBudgetMap.size() > 0)
            {                
                //insert new budgets in case of first time approval of a proposal
                database.insert(campBudgetMap.values());
                
                if(campBudgetMapForNewPFA != NULL && campBudgetMapForNewPFA.size() > 0){
                    
                     createAlloactionForCampaigns(campBudgetMapForNewPFA);
                }
            }

            if(campToUpdate != NULL && campToUpdate.size() > 0)
            {
                //update budgets in case of re-approval of proposals
                updateBudget(campToUpdate);
            }
        }  
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
     
        
        return campBudgetMap;
    }
    
/***************************************************************************************************** 
Method Name:        createBudgetForCampaigns
@return  :          void
@parameters:        Campaign
Description:        This is a Method to prepare a new budget based on the Campaign values
Added By:           Intel - SM      - 07/07/2020
Modified By:        Intel - Areefa  - 08/09/2020 - Updating(Amount=camp.Core_MDF_Total_Campaign_Cost_Amt__c) with new campaign Amount field(Core_MDF_Reimbursement_Amount_Amt__c)
******************************************************************************************************/      
    public static PartnerMarketingBudget createBudgetForCampaigns(Campaign camp){
        //Id recordType= camp.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') ? ipaRecordtype : channelMDFProposalBasedRT;
	Id recordType ;	
        if(camp.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')){
         	 recordType = ipaRecordtype;
	}
        //to get IPA Program Name
        String IPAProgramName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name');
        //to store Campaign Account Id
        id campAccId = camp.Core_MDF_Account__c;
        //to store virtual Corp Account's Id
        //initially keeping it as campaign's account id
        id VCAccID = campAccId;
        //to get Account associated with the Campaign
        Account acc = [Select id,Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Parent_Fund_Account__c from Account where id =: campAccId];
        //creating an variable for VirtualCorp Account 
        Account virtualCorpAcc;
        //if Account's ultimate Account not equals to the Account's Parent Fund Account
        //updating VC as That account's VC
        //getting an active Account whose Parent Fund Account is equal to that Account's Ultimate Account with a IPA specific Program
        if(acc.Core_MDF_CoMarketing_Ultimate_Account__c != acc.Core_MDF_Parent_Fund_Account__c){
        	virtualCorpAcc = [Select id from Account where Core_MDF_Parent_Fund_Account__c =: acc.Core_MDF_CoMarketing_Ultimate_Account__c and Core_MDF_Channel_Program__r.Name =: camp.Core_MDF_Program__c and Core_MDF_Active_Ind__c =: true ];
        	VCAccID = virtualCorpAcc.id;
        }
        
        //returning a new Budget with VirtualCorp Account for the Campaign
        return new PartnerMarketingBudget(Title=camp.Name + ' Budget',/*Description=camp.Description,*/StartDate=camp.StartDate,EndDate=camp.EndDate,
        Core_MDF_Budget_Partner__c=VCAccID,Core_MDF_Program__c=camp.Core_MDF_Channel_Program__c,Core_MDF_Budget_Type_Txt__c=camp.Core_MDF_Budget_Type_txt__c,
        Amount=camp.Core_MDF_Reimbursement_Amt__c, RecordTypeId = recordType,Core_MDF_Budget_Status__c ='Released');
    }

    
    
/***************************************************************************************************** 
Method Name:        createAlloactionForCampaigns
@return  :          void
@parameters:        Map<Campaign,PartnerMarketingBudget>
Description:        This is a Method to New Allocations With respect to the Budget and (Campaign's Account)
Added By:           Ak      - 11/11/2022
Modified By:        
******************************************************************************************************/ 
    
    public static void createAlloactionForCampaigns(Map<Campaign,PartnerMarketingBudget> campBudgetMapForNewPFA){
        try
        {	
           
            //create new list for new Allcotions and pass it to insert
            List<PartnerFundAllocation> newAllocations = new List<PartnerFundAllocation>();
            //create new list for previous Alloction and pass it to update
        	List<PartnerFundAllocation> oldAllocations = new List<PartnerFundAllocation>();
            
            //to store budget id and allocation record mapping
            Map<Id,PartnerFundAllocation> allocMap = new Map<Id,PartnerFundAllocation>();
            for(PartnerFundAllocation pfa: [Select BudgetId, Amount from PartnerFundAllocation Where BudgetId IN :campBudgetMapForNewPFA.values()])
            {
                allocMap.put(pfa.BudgetId, pfa);
            }

            if(campBudgetMapForNewPFA != NULL && campBudgetMapForNewPFA.size() > 0 && allocMap != null && allocMap.size() > 0)
            {
                //to loop thro the each campaign
                for(Campaign camp : campBudgetMapForNewPFA.keySet())
                {	
                    //Id PFARecordType = camp.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') ? ipaPFARecordtype : channelMDFPFARecordtype;
                Id PFARecordType ; 
                if(camp.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name')){
			 PFARecordType = ipaPFARecordtype;
		}	
					//from the map for this camp we'll get budget
                    PartnerMarketingBudget budget = campBudgetMapForNewPFA.get(camp);
                    //Creating new Allocation with that budget and Campaign's Account and Campaign's Amount
                    ////make it generic record type
                    PartnerFundAllocation newAllocation = new PartnerFundAllocation(Title = budget.title, BudgetId = budget.Id, ChannelPartnerId = camp.Core_MDF_Account__c, Amount = budget.Amount, RecordTypeId = PFARecordType);
        			PartnerFundAllocation allocation = new PartnerFundAllocation();
                    allocation.id = allocMap.get(budget.id).id;
                    //After Creation of new Allocation, Previous Allocation Amount to be 0
                    allocation.Amount = 0;
                    oldAllocations.add(allocation);
                    newAllocations.add(newAllocation);
                    
                }
                //updating previous Allocation Amount Field
                Database.update(oldAllocations);
                //Inserting new Allcoation Records
                Database.insert(newAllocations);
                
            }
        }  
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); throw e;}
        
    }
    
    
/***************************************************************************************************** 
Method Name:        updateBudget
@return  :          void
@parameters:        List<Campaign>
Description:        This is a Method to update budget in case of re-approval of proposals
Added By:           Intel - SM - 07/07/2020
Modified By:        Intel - Areefa  - 08/09/2020 - Updating(Amount=camp.Core_MDF_Total_Campaign_Cost_Amt__c) with new campaign Amount field(Core_MDF_Reimbursement_Amount_Amt__c)

******************************************************************************************************/      
    public static void updateBudget(List<Campaign> campList)
    {
        try
        {
            Set<Id> budgetId = new Set<Id>();
            Set<Id> campAccId = new Set<Id>();
            Boolean amountIncreased = false;
            //to store all the budget id's of the incoming campaigns
            for(Campaign camp : campList)
            {
                budgetId.add(camp.Core_MDF_Budget__c);
                campAccId.add(camp.Core_MDF_Account__c);
            }
            //to store budget id and budget record
            Map<Id,PartnerMarketingBudget> budgetMap = new Map<Id,PartnerMarketingBudget>([Select Title,Core_MDF_Budget_Type_Txt__c,StartDate, EndDate, Amount,Description 
                                                                                           from PartnerMarketingBudget
                                                                                           Where Id IN :budgetId]);
            //to store budget id and allocation record mapping
            Map<Id,PartnerFundAllocation> allocMap = new Map<Id,PartnerFundAllocation>();
            for(PartnerFundAllocation pfa: [Select Title,BudgetId, Amount, ChannelPartnerId from PartnerFundAllocation Where BudgetId IN :budgetId and ChannelPartnerId IN :campAccId])
            {
                allocMap.put(pfa.BudgetId, pfa);
            }
            if(budgetMap != null && budgetMap.size() > 0 && allocMap != null && allocMap.size() > 0)
            {
                //to loop thro the each campaign and update values on budget incase of any changes on the campaign
                for(Campaign camp : campList)
                {
                    PartnerMarketingBudget budget = budgetMap.get(camp.Core_MDF_Budget__c);
                    PartnerFundAllocation allocation = allocMap.get(camp.Core_MDF_Budget__c);
                    budget.StartDate = budget.StartDate!=camp.StartDate?camp.StartDate:budget.StartDate;
                    budget.EndDate = budget.EndDate!=camp.EndDate?camp.EndDate:budget.EndDate;
                    budget.Core_MDF_Budget_Type_Txt__c = budget.Core_MDF_Budget_Type_Txt__c!=camp.Core_MDF_Budget_Type_txt__c?camp.Core_MDF_Budget_Type_txt__c:budget.Core_MDF_Budget_Type_Txt__c;
                    budget.Title = budget.Title != camp.Name ? (camp.Name+' Budget') : budget.Title;//updating the title of the budget
                    //budget.Description = budget.Description!=camp.Description?camp.Description:budget.Description;
                    amountIncreased=budget.Amount<camp.Core_MDF_Reimbursement_Amt__c?true:false;
                    budget.Amount = budget.Amount!=camp.Core_MDF_Reimbursement_Amt__c?camp.Core_MDF_Reimbursement_Amt__c:budget.Amount;
                    allocation.Amount = budget.Amount!=camp.Core_MDF_Reimbursement_Amt__c?camp.Core_MDF_Reimbursement_Amt__c:budget.Amount;
                    allocation.Title = allocation.Title != camp.Name ? camp.Name : budget.Title;//updating the title of the allocation
                    
                    
                }
                if(amountIncreased)
                {
                    Database.update(budgetMap.values());
                    Database.update(allocMap.values());
                }
                else
                {
                    Database.update(allocMap.values());
                    Database.update(budgetMap.values());
                }
            }
        }  
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); throw e;}
    }

/***************************************************************************************************** 
Method Name:        cancelBudget
@return  :          void
@parameters:        List<Campaign>
Description:        This is a Method to cancel budget in case of propodal cancellation
Added By:           Intel - SM - 07/07/2020
******************************************************************************************************/     
    public static void cancelBudget(List<Campaign> campList)
    {
        try
        {
            Set<Id> budgetId = new Set<Id>();
            //to store all the budget id's of the incoming campaigns
            for(Campaign camp : campList)
            {
                budgetId.add(camp.Core_MDF_Budget__c);
            }
            //to store budget id and budget record
            Map<Id,PartnerMarketingBudget> budgetMap = new Map<Id,PartnerMarketingBudget>([Select Amount, Core_MDF_Budget_Status__c 
                                                       from PartnerMarketingBudget
                                                      Where Id IN :budgetId]);
          
            if(budgetMap != null && budgetMap.size() > 0)
            {
                //to loop thro the each campaign and update budget status to cancelled, Amount on Budget and Allocation to 0
                for(Campaign camp : campList)
                {
                    PartnerMarketingBudget budget = budgetMap.get(camp.Core_MDF_Budget__c);
                    budget.Core_MDF_Budget_Status__c = Label.Core_MDF_Claim_Status_Cancelled;
                }
                Database.update(budgetMap.values());
            }
        }  
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e); throw e;}
    }
}