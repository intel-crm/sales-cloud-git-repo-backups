public without sharing class Core_MDF_PFR_Approval_Admin {
    
    @future
    public static void recallApprovalReq(List<String> pfrIds){

        Set<Id> processIds = new Set<Id>();
        Map<Id,Id> piList = new Map<Id,Id>();

        //system.debug('##Recall Reached');
        //system.debug('##pfrIds' + pfrIds);
        for(ProcessInstanceWorkItem piwitm : [SELECT ProcessInstance.TargetObjectId, Id FROM ProcessInstanceWorkItem 
                                        WHERE ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId IN : pfrIds])
        {   
            piList.put(piwitm.ProcessInstance.TargetObjectId, piwitm.Id);
            processIds.add(piwitm.id);
        }

        //system.debug('piList->' + piList);
        //system.debug('processIds->' + processIds);

        if (piList.size() > 0){
            List<Approval.ProcessWorkitemRequest> processRquests = new List<Approval.ProcessWorkitemRequest>();

            for (Id pwid : piList.values()){

                Approval.ProcessWorkitemRequest aprReq = new Approval.ProcessWorkitemRequest();
                aprReq.setComments('More info Needed');
                aprReq.setAction('Removed');
                aprReq.setWorkitemId(pwid);
                system.debug('<-aprReq->' + aprReq);
                processRquests.add(aprReq);
            }

            Approval.process(processRquests,true);
        }

        if (processIds.size()>0){
           
            List<ProcessInstance> processInstances = [select id from ProcessInstance where id in : processIds];
            
            if (processInstances.size() > 0){
                Database.delete(processInstances);
            }
        }

    }

    // public static void recallApproval(PartnerFundRequest oldPfr, PartnerFundRequest newPfr){

    //     Set<Id> processIds = new Set<Id>();
    //     Map<Id,Id> piList = new Map<Id,Id>();

    //     system.debug('##Recall Reached');
    //     if (oldPfr.Core_MDF_Approval_Step_Completed__c == 0 && newPfr.Core_MDF_Fund_Request_Status__c == 'Pending Review'
    //             && oldPfr.Core_MDF_Fund_Request_Status__c == 'Revision Required')
    //     {
    //         for(ProcessInstanceWorkItem piwitm : [SELECT ProcessInstance.TargetObjectId, Id FROM ProcessInstanceWorkItem 
    //                                     WHERE ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId =: newPfr.Id])
    //         {   
    //             piList.put(piwitm.ProcessInstance.TargetObjectId, piwitm.Id);
    //             processIds.add(piwitm.id);
    //         }
    //     }

    //     system.debug('piList->' + piList);
    //     system.debug('processIds->' + processIds);

    //     if (piList.size() > 0){
    //         List<Approval.ProcessWorkitemRequest> processRquests = new List<Approval.ProcessWorkitemRequest>();

    //         for (Id pwid : piList.values()){

    //             Approval.ProcessWorkitemRequest aprReq = new Approval.ProcessWorkitemRequest();
    //             aprReq.setComments('More info Needed');
    //             aprReq.setAction('Removed');
    //             aprReq.setWorkitemId(pwid);
    //             system.debug('<-aprReq->' + aprReq);
    //             processRquests.add(aprReq);
    //         }

    //         Approval.process(processRquests,true);
    //     }

    //     if (processIds.size()>0){
           
    //         List<ProcessInstance> processInstances = [select id from ProcessInstance where id in : processIds];
            
    //         if (processInstances.size() > 0){
    //             Database.delete(processInstances);
    //         }
    //     }
        
    // }

    // public static void recallApprovalBulk(Map<Id,PartnerFundRequest> oldMap, Map<Id,PartnerFundRequest> newMap){

    //     List<Id> pfrIds = new List<Id>();
    //     Map<Id,Id>  piList = new Map<Id,Id>();
    //     Set<Id> processIds = new Set<Id>();

    //     for (PartnerFundRequest pfr : newMap.values()){
    //         PartnerFundRequest oldPFR = oldMap.get(pfr.Id);

    //         if (pfr.Core_MDF_Approval_Step_Completed__c == 0 && pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review'
    //             && oldPFR.Core_MDF_Fund_Request_Status__c == 'Revision Required')
    //         {
    //             pfrIds.add(pfr.id);
    //             break;
    //         }
    //     }

    //     for(ProcessInstanceWorkItem piwitm : [SELECT ProcessInstance.TargetObjectId, Id FROM ProcessInstanceWorkItem 
    //                                     WHERE ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId IN:pfrIds])
    //     {   
    //         piList.put(piwitm.ProcessInstance.TargetObjectId, piwitm.Id);
    //         processIds.add(piwitm.id);
    //     }

    //     system.debug('piList->' + piList);

    //     if (piList.size() > 0){
    //         List<Approval.ProcessWorkitemRequest> processRquests = new List<Approval.ProcessWorkitemRequest>();

    //         for (Id pwid : piList.values()){

    //             Approval.ProcessWorkitemRequest aprReq = new Approval.ProcessWorkitemRequest();
    //             aprReq.setComments('More info Needed');
    //             aprReq.setAction('Removed');
    //             aprReq.setWorkitemId(pwid);
    //             system.debug('<-aprReq->' + aprReq);
    //             processRquests.add(aprReq);
    //         }

    //         Approval.process(processRquests,true);
    //     }

    //     if (processIds.size()>0){
           
    //         List<ProcessInstance> processInstances = [select id from ProcessInstance where id in : processIds];
            
    //         if (processInstances.size() > 0){
    //             Database.delete(processInstances);
    //         }
    //     }
        
    // }
}