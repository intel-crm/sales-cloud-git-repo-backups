/****************************************************************************************************
Apex Class Name : SWS_6SenseIntegrationBatch
Version         : 1.0 
Created Date    : 2024-12-22
Function        : Batch job to share the 6Sense Enabled Account Opportunities to 6Senese Integration User.
User Story      : TWC5945-1428
Test Class      : SWS_6SenseIntegrationBatchTest
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bishal Singh              2024-12-22                 Created
*****************************************************************************************************/
public without sharing class SWS_6SenseIntegrationBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String SWS_UserOrGroupId;
   	public List<String> accountIds = new List<String>();
    
    /************************************************************************************************************
    *Method Name : SWS_6SenseIntegration (Invocable Method)
    *Created Date: 2024-12-24
    *Author: Bishal Singh
    *Description : Share Related Opportunity an invocable method to share related opportunuties with 6Sense User.
    ************************************************************************************************************/
    @InvocableMethod(label='Share Related Opportunity' description='Use to share related Opportunities with 6Sense Integration User' category='Opportunity')
    public static void SWS_6SenseIntegration(List<IntegrationWrapper> wrapper){
        Database.executeBatch(new SWS_6SenseIntegrationBatch(new List<String> {wrapper[0].accountId}),500);    
    }
    
    /************************************************************************************************************
    *Method Name : SWS_6SenseIntegrationBatch (Constructor)
    *Created Date: 2024-12-24
    *Author: Bishal Singh
    *Description : To set account Id on global level.
    ************************************************************************************************************/
    public SWS_6SenseIntegrationBatch(List<String> accountIds){
        this.accountIds = accountIds;
    }
    
	public Database.queryLocator start(Database.BatchableContext bc){        
        SWS_UserOrGroupId = [SELECT Id FROM Group WHERE DeveloperName ='SWS_6Sense_Admin_Group']?.Id;
    	String query = 'SELECT Id FROM Opportunity WHERE Account.Core_Export_Compliance_Block__c = false AND Account.Is_6Sense_Integration_Enabled__c = true AND Core_Military_Aerospace_Govmt_End_Use__c = \'No\' AND Core_Design_Registration_Id__c = null AND Core_Consumption_Market__c <> \'Government\' AND Core_Opportunity_Coverage_Nm__c = \'Intel-Led Opportunity\' AND Account.Id IN :accountIds';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> opportunityList){       
       
        List<OpportunityShare> opportunityShared = new List<OpportunityShare>([SELECT Id,OpportunityId,UserOrGroup.Name,RowCause,Opportunity.Account.Is_6Sense_Integration_Enabled__c FROM OpportunityShare WHERE UserOrGroupId =:SWS_UserOrGroupId AND OpportunityId IN :opportunityList]);
        Map<Id, List<OpportunityShare>> opportunityShareMap = createMapOfOpptyShare(opportunityShared);
        List<OpportunityShare> opportunitySharingList = getSharingRecords(opportunityList,opportunityShareMap);
        if(!opportunitySharingList.isEmpty()){
            Database.insert(opportunitySharingList,true);
        }
		List<Core_Oppty_KPI_New__c> opportunityKPIList = new List<Core_Oppty_KPI_New__c>([select Id, Core_KPI_Opportunity__c from Core_Oppty_KPI_New__c WHERE Core_IsActive__c =true and Core_KPI_Opportunity__c IN :opportunityList]);
		
		List<Core_Oppty_KPI_New__Share> opportunityKPIShared = new List<Core_Oppty_KPI_New__Share>([SELECT Id,ParentId,UserOrGroup.Name,RowCause,Parent.Core_KPI_Opportunity__r.Account.Is_6Sense_Integration_Enabled__c FROM Core_Oppty_KPI_New__Share WHERE UserOrGroupId =:SWS_UserOrGroupId AND ParentId IN :opportunityKPIList]);
		
		Map<Id, List<Core_Oppty_KPI_New__Share>> opportunityKPIShareMap = createMapOfOpptyKPIShare(opportunityKPIShared);
		List<Core_Oppty_KPI_New__Share> opportunityKPISharingList = getKPISharingRecords(opportunityKPIList,opportunityKPIShareMap);
        if(!opportunityKPISharingList.isEmpty()){
            Database.insert(opportunityKPISharingList,true);
        }  
    }
    
    public void finish(Database.BatchableContext bc) {
        List<OpportunityShare> opportunityShared = new List<OpportunityShare>([SELECT Id,OpportunityId,UserOrGroup.Name,RowCause,Opportunity.Account.Is_6Sense_Integration_Enabled__c FROM OpportunityShare WHERE UserOrGroupId = :SWS_UserOrGroupId AND Opportunity.AccountId IN :accountIds AND Opportunity.Account.Is_6Sense_Integration_Enabled__c = false]);
        if(!opportunityShared.isEmpty()){
            Database.delete(opportunityShared,true);
        }
         
    }
    
    /************************************************************************************************************
    *Method Name : getSharingRecords
    *Created Date: 2024-12-24
    *Author: Bishal Singh
    *Description : Method to get opportunity that has not been shared with Integration user.
    ************************************************************************************************************/
    private List<OpportunityShare> getSharingRecords(List<Opportunity> opportunityList,Map<Id, List<OpportunityShare>> opportunityShareMap){
        List<OpportunityShare> opportunityShared = new List<OpportunityShare>();
        for(Opportunity oppty : opportunityList){
            if(opportunityShareMap.containsKey(oppty.Id)){
                continue;
            }else{
                OpportunityShare opptyShare = new OpportunityShare();
                opptyShare.OpportunityId = oppty.Id;
                opptyShare.RowCause = Schema.OpportunityShare.RowCause.Manual;
                opptyShare.UserOrGroupId = SWS_UserOrGroupId;
                opptyShare.OpportunityAccessLevel = 'Read';
                opportunityShared.add(opptyShare);
            }
        }
        return opportunityShared;
    }
	
	
	
	  /************************************************************************************************************
    *Method Name : getKPISharingRecords
    *Created Date: 2025-03-03
    *Author: Shijas KM
    *Description : Method to get opportunity KPI that has not been shared with Integration user.
    ************************************************************************************************************/
    private List<Core_Oppty_KPI_New__Share> getKPISharingRecords(List<Core_Oppty_KPI_New__c> opportunityKPIList,Map<Id, List<Core_Oppty_KPI_New__Share>> opportunityKPIShareMap){
        List<Core_Oppty_KPI_New__Share> opportunityKPIShared = new List<Core_Oppty_KPI_New__Share>();
        for(Core_Oppty_KPI_New__c opptyKpi : opportunityKPIList){
            if(opportunityKPIShareMap.containsKey(opptyKpi.Id)){	    	
                continue;
            }else{
                Core_Oppty_KPI_New__Share opptyKPIShare = new Core_Oppty_KPI_New__Share();
                opptyKPIShare.ParentId = opptyKpi.Id;
                opptyKPIShare.RowCause = Schema.Core_Oppty_KPI_New__Share.RowCause.Manual;
                opptyKPIShare.UserOrGroupId = SWS_UserOrGroupId;
                opptyKPIShare.AccessLevel = 'Read';
                opportunityKPIShared.add(opptyKPIShare);
            }
        }
        
        return opportunityKPIShared;
    }
    
    /************************************************************************************************************
    *Method Name : createMapOfOpptyShare
    *Created Date: 2024-12-24
    *Author: Bishal Singh
    *Description : Helper method to convert OpportunityShare List into Map of Opportunity Id & OpportunityShare.
    ************************************************************************************************************/
    private Map<Id, List<OpportunityShare>> createMapOfOpptyShare(List<OpportunityShare> opportunityShared){
        Map<Id, List<OpportunityShare>> opportunityShareMap = new Map<Id, List<OpportunityShare>>();
        for (OpportunityShare opportunityShare : opportunityShared) {
            if (!opportunityShareMap.containsKey(opportunityShare.OpportunityId)) {
               opportunityShareMap.put(opportunityShare.OpportunityId, new List<OpportunityShare>());
            }
            opportunityShareMap.get(opportunityShare.OpportunityId).add(opportunityShare);
        }
        return opportunityShareMap;
    }
	
	
	 /************************************************************************************************************
    *Method Name : createMapOfOpptyKPIShare
    *Created Date: 2025-02-28
    *Author: Shijas KM
    *Description : Helper method to convert OpportunityKPIShare List into Map 
    ************************************************************************************************************/
    private Map<Id, List<Core_Oppty_KPI_New__Share>> createMapOfOpptyKPIShare(List<Core_Oppty_KPI_New__Share> opportunityKPIShared){
        Map<Id, List<Core_Oppty_KPI_New__Share>> opportunityKPIShareMap = new Map<Id, List<Core_Oppty_KPI_New__Share>>();
        for (Core_Oppty_KPI_New__Share opportunityKPIShare : opportunityKPIShared) {
            if (!opportunityKPIShareMap.containsKey(opportunityKPIShare.ParentId)) {
               opportunityKPIShareMap.put(opportunityKPIShare.ParentId, new List<Core_Oppty_KPI_New__Share>());
            }
            opportunityKPIShareMap.get(opportunityKPIShare.ParentId).add(opportunityKPIShare);
        }
        return opportunityKPIShareMap;
    }
    
    /************************************************************************************************************
    *Method Name : IntegrationWrapper
    *Created Date: 2024-12-24
    *Author: Bishal Singh
    *Description : Wrapper class to store the Invocable Variable.
    ************************************************************************************************************/
    public class IntegrationWrapper {
        @InvocableVariable
        public String accountId;
    }
}