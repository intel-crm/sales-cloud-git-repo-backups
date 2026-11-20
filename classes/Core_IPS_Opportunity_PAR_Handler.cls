/***************************************************************************************************
* Apex Class Name : Core_IPS_Opportunity_PAR_Handler
* Test Class Name : Core_IPS_OpportunityPAR_Controller_Test
* Description : after request gets approved, IPS project gets associated to Supported Products, IPS opportunity
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Tejaswi                  04/09/2020                                                          
****************************************************************************************************/
public without sharing class Core_IPS_Opportunity_PAR_Handler {
    
    public static void initApprovalProcess(Map<Id,Core_IPS_Opportunity_PAR__c> oppParIdMap) {
        List<Id> queueIds = new List<Id>();
        
        if(Core_IPS_Opportunity_PAR__c.SObjectType.getDescribe().isQueryable() && ProcessInstanceHistory.SObjectType.getDescribe().isAccessible() ){
            List<Core_IPS_Opportunity_PAR__c> oppParApprovalList = [Select Id, Core_IPS_Approval_Status__c,(Select TargetObjectId, SystemModstamp, StepStatus, RemindersSent, ProcessInstanceId, OriginalActorId, IsPending, IsDeleted, Id, CreatedDate,
                                                                                                            CreatedById, Comments, ActorId From ProcessSteps order by SystemModstamp desc) from 
                                                                    Core_IPS_Opportunity_PAR__c where Id = :oppParIdMap.keySet() WITH SECURITY_ENFORCED];
            
            Map<Id,String> approverMap = new Map<Id,String>();
            
            for(Core_IPS_Opportunity_PAR__c oppParApproval :oppParApprovalList){
                ProcessInstanceHistory  processStep = oppParApproval.ProcessSteps[0];
                if(processStep!=null && oppParIdMap.get(oppParApproval.Id).Core_IPS_Approval_Status__c == 'Approved'){
                    queueIds.add(processStep.OriginalActorId);
                    oppParIdMap.get(oppParApproval.Id).Approved_By__c = processStep.ActorId;
                    
                }    
            }
            
            
        }  
        deleteGroup(queueIds);
    } 
    @future
    public static void deleteGroup(List<Id> queueIds){
        List<Group> groupList = new List<Group>();
        for(Id queueId: queueIds){
            if(!Test.isRunningTest()){
                groupList.add(new Group(Id=queueId));
            }
        }
        if(groupList.size()>0){
            
            if(Group.SObjectType.getDescribe().isDeletable()){ 
                delete groupList;
            }
        }
    }
    public static void mappingProject(Map<Id,Core_IPS_Opportunity_PAR__c> oldMap,Map<Id,Core_IPS_Opportunity_PAR__c> newMap) {
        List<Id> oppParIdList =  new List<Id>();
        List<Core_IPS_Product__c> prmrProjProdList = new List<Core_IPS_Product__c>();
        List<Core_IPS_Opportunity__c> ipsOppList = new List<Core_IPS_Opportunity__c>();
        List<Core_IPS_Project__c> nwIpsProjList = new List<Core_IPS_Project__c>();
        Map<Id,Core_IPS_Project__c> parProjectMap = new Map<Id,Core_IPS_Project__c>();
        List<Core_IPS_Opportunity_PAR__c> updateOppParList = new List<Core_IPS_Opportunity_PAR__c>();
        List<Core_IPS_Product__c> newProjProdList = new List<Core_IPS_Product__c>();
        List<Core_IPS_Opportunity__c> newPrjIpsOppList = new List<Core_IPS_Opportunity__c>();
        List<Core_IPS_Account__c> ipsAccountList = new List<Core_IPS_Account__c>();
        List<Core_IPS_Opportunity_PAR__c> oppParProdList;
        List<Core_IPS_Opportunity_PAR__c> prodList;
        String prodId;
        List<String> supProdIds;
        String orgAdminId;
        List<String> supOrgAdminIds;
        try{
            for(Id oppParId:newMap.keyset()){
                if(oldMap.get(oppParId).Core_IPS_Approval_Status__c == 'In Progress' && newMap.get(oppParId).Core_IPS_Approval_Status__c =='Approved'){
                    oppParIdList.add(oppParId);
                }
            }
            if(Core_IPS_Opportunity_PAR__c.SObjectType.getDescribe().isQueryable()){
                String queryString = 'SELECT Id,Core_IPS_Premier_Support_Project__c,Opportunity__c,Opportunity__r.Name,Core_IPS_AddNewProject__c,(SELECT Id,Core_IPS_Supported_Product__c FROM Opportunity_Par_Supported_Products__r) FROM Core_IPS_Opportunity_PAR__c WHERE Id IN : oppParIdList';
                prodList = Database.query(queryString);
            }
            for(Core_IPS_Opportunity_PAR__c oppPar: prodList){
                
                if(oppPar.Core_IPS_Premier_Support_Project__c != null && oppPar.Core_IPS_AddNewProject__c == false ){
                    for(Core_IPS_Opppar_Supported_Product__c prod: oppPar.Opportunity_Par_Supported_Products__r){
                        Core_IPS_Product__c selectedProds = new Core_IPS_Product__c();
                        if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Project__c.isCreateable() || Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Project__c.isUpdateable()) {
                        selectedProds.Core_IPS_Project__c = oppPar.Core_IPS_Premier_Support_Project__c;
                        }
                        selectedProds.Core_Supported_Product__c = prod.Core_IPS_Supported_Product__c;
                        prmrProjProdList.add(selectedProds);   
                    }
                    Core_IPS_Opportunity__c ipsOpportunity = new Core_IPS_Opportunity__c();
                    if (Schema.sObjectType.Core_IPS_Opportunity__c.fields.Core_IPS_Project__c.isCreateable()) {
                    ipsOpportunity.Core_IPS_Project__c = oppPar.Core_IPS_Premier_Support_Project__c;
                    }
                    ipsOpportunity.Core_Opportunity__c = oppPar.Opportunity__c;
                    ipsOppList.add(ipsOpportunity); 
                }
                
                else if(oppPar.Core_IPS_AddNewProject__c == true && oppPar.Core_IPS_Premier_Support_Project__c == null){ 
                    Core_IPS_Project__c nwIpsProj = new Core_IPS_Project__c();
                    if (Schema.sObjectType.Core_IPS_Project__c.fields.Name.isCreateable() || Schema.sObjectType.Core_IPS_Project__c.fields.Name.isUpdateable()) {
                    nwIpsProj.Name = oppPar.Opportunity__r.Name;
                    }
                    if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_Status__c.isCreateable() || Schema.sObjectType.Core_IPS_Project__c.fields.Core_Status__c.isUpdateable()) {
                    nwIpsProj.Core_Status__c = 'Draft';
                    }
                    nwIpsProjList.add(nwIpsProj); 
                    parProjectMap.put(oppPar.id,nwIpsProj);
                }
            }
            if(prmrProjProdList.size() > 0){
                database.insert(prmrProjProdList,false); 
            }
            if(ipsOppList.size() > 0){    
                database.insert(ipsOppList,false); 
            }
            if(parProjectMap.values().size() > 0){
                
                database.insert(parProjectMap.values(),false); 
            }
            if(Core_IPS_Opportunity_PAR__c.SObjectType.getDescribe().isQueryable()){
                Set<Id> parProjectIdSet = parProjectMap.keySet();
                String queryString = 'SELECT Id,Core_IPS_AddNewProject__c,Core_IPS_Premier_Support_Project__c,Opportunity__c,Opportunity__r.Name,Opportunity__r.AccountId,(SELECT Id,Core_IPS_Supported_Product__c FROM Opportunity_Par_Supported_Products__r) FROM Core_IPS_Opportunity_PAR__c WHERE Id IN : parProjectIdSet';
                oppParProdList = Database.query(queryString);
            }
            for(Core_IPS_Opportunity_PAR__c oppPar: oppParProdList){
                if (Schema.sObjectType.Core_IPS_Opportunity_PAR__c.fields.Core_IPS_Premier_Support_Project__c.isUpdateable()) { /*--US1038641--06/24/2021--Haritha--FLS Check for security vulnerability--*/
                oppPar.Core_IPS_Premier_Support_Project__c = parProjectMap.get(oppPar.Id).Id;
                }
                updateOppParList.add(oppPar);
                Core_IPS_Account__c ipsAccount = new Core_IPS_Account__c();
                ipsAccount.Core_Account__c= oppPar.Opportunity__r.AccountId;
                if (Schema.sObjectType.Core_IPS_Account__c.fields.Core_Status__c.isCreateable()) { /*--US1038641--06/24/2021--Haritha--FLS Check for security vulnerability--*/
                ipsAccount.Core_Status__c='Active';
                }
                if (Schema.sObjectType.Core_IPS_Account__c.fields.Core_IPS_Project__c.isCreateable()) { /*--US1038641--06/24/2021--Haritha--FLS Check for security vulnerability--*/
                    ipsAccount.Core_IPS_Project__c = parProjectMap.get(oppPar.Id).Id;
                }
                ipsAccountList.add(ipsAccount);
                for(Core_IPS_Opppar_Supported_Product__c prod: oppPar.Opportunity_Par_Supported_Products__r){
                    Core_IPS_Product__c selectedProds = new Core_IPS_Product__c();
                    if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Project__c.isCreateable()) { /*--US1038641--06/24/2021--Haritha--FLS Check for security vulnerability--*/
                    selectedProds.Core_IPS_Project__c =  parProjectMap.get(oppPar.Id).Id;
                    }
                    selectedProds.Core_Supported_Product__c = prod.Core_IPS_Supported_Product__c;
                    newProjProdList.add(selectedProds);   
                }
                Core_IPS_Opportunity__c ipsOpportunity = new Core_IPS_Opportunity__c();
                ipsOpportunity.Core_IPS_Project__c =  parProjectMap.get(oppPar.Id).Id;
                ipsOpportunity.Core_Opportunity__c = oppPar.Opportunity__c;
                newPrjIpsOppList.add(ipsOpportunity);
            }
            if(updateOppParList.size() > 0){
                database.update(updateOppParList,true); 
            }
            if(ipsAccountList.size() > 0){
                database.insert(ipsAccountList,true); 
            }
            if(newProjProdList.size() > 0){
                database.insert(newProjProdList,true); 
            }
            if(newPrjIpsOppList.size() > 0){
                database.insert(newPrjIpsOppList,false); 
            }
            
        }
        catch(exception ex){
        }
    }
}