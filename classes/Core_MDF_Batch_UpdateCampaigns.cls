/****************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_UpdateCampaigns 
* Version     : 1.0   
* Created Date: 4/06/2021 
* Modification Log :
* Developer                 Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Pranav     		4/06/2021                    This Batch Updates the campaigns with the appropriate budget caps for IPA program
*****************************************************************************************************************************************/
public class Core_MDF_Batch_UpdateCampaigns implements Database.Batchable<sObject>,Database.Stateful{
    
    // List of campaigns to be iterated in execute
    public List<Campaign> listOfCampaigns = new List<Campaign>();
    // Budget Caps Ids for which campaigns updation got failed
	public Set<Id> failedBudgetCapIds = new Set<Id>(); 
    // contructor to define campaign list that will be iterated in start method
    public Core_MDF_Batch_UpdateCampaigns(List<Campaign> campaignList){
        listOfCampaigns = campaignList;        
    }
    public Iterable<sObject> start(Database.BatchableContext bc) {
        return listOfCampaigns;
    }	
    public void execute(Database.BatchableContext bc, List<Campaign> campaignList) {
        List<Id> campIds = new List<Id>();
        try{
            // List of campaigns that are unlocked temporarily for updation; It will be locked after dml
            List<Campaign> listOfLockedCampaigns = new List<Campaign>();
            Map<Id,Campaign> campIdtoCampMap = new  Map<Id,Campaign>();
            // Looping over the List of campaigns in the method scope
            for(Campaign campaign : campaignList){
                campIds.add(campaign.Id);
                campIdtoCampMap.put(campaign.Id,campaign);
                // Add the locked records in a list which needs to be unlocked and locked again after dml
               /* if(Approval.isLocked(campaign)){                    
                    listOfLockedCampaigns.add(campaign);
                }*/
            }
            if(!campIds.isEmpty()) {
                Map<Id,boolean> campApprovalResult = Approval.isLocked(campIds);
                if(campApprovalResult != null && !campApprovalResult.isEmpty()) {
                    for(Id campId : campApprovalResult.keySet()){
                        if(campApprovalResult.get(campId)){
                            listOfLockedCampaigns.add(campIdtoCampMap.get(campId));
                        }
                    }
                }
            }
            Approval.unlock(listOfLockedCampaigns, true);
            // Update the campaigns with allorNone as false and return the saveresult list
            Database.SaveResult[] srList = database.update(campaignList,false);
            // lock the appropriate campaigns again
            Approval.lock(listOfLockedCampaigns,true);
            if(srList != NULL && srList.size()>0){
                // looping over the saveresults
                for (Integer index = 0; index < srList.size(); index++) {
                    // if the campaign update got failed ,add the corresponding budget cap Ids in a failed budget caps set
                    if(!srList[index].isSuccess()){failedBudgetCapIds.add(campaignList[index].Core_MDF_Budget_Cap__c);
                    }
                }
            }
        }
        catch(Exception exceptionObj){Core_MDF_CCP_UtilityClass.logError(exceptionObj);}
    }    
    public void finish(Database.BatchableContext bc) { 
        if(failedBudgetCapIds != NULL && failedBudgetCapIds.size()>0){
            setFailedIndicatorOnBudgetCaps();
        }
    }
    /*This method sets failed Indicator to true for which campaigns updation got failed*/
    public void setFailedIndicatorOnBudgetCaps(){
        try{
            // List of budget caps in which failed ind flag will be set to true
            List<Core_MDF_Budget_Cap__c> budgetCapsToBeUpdated = new List<Core_MDF_Budget_Cap__c>();
            // Set the failed Indicator to true
            for(Id budgetCapId : failedBudgetCapIds){
                // Create a new instance of budget cap and set failed indicator to true and add them in a list for update
                Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
                budgetCap.Id = budgetCapId;
                budgetCap.Core_MDF_Campaigns_Link_failed_Ind__c = true;
                budgetCapsToBeUpdated.add(budgetCap);
            }
            // update budget caps
            Database.update(budgetCapsToBeUpdated);
        }
        catch(Exception exceptionObj){ Core_MDF_CCP_UtilityClass.logError(exceptionObj);}
    }
}