/**************************************************************************************
Apex Class Name:  Core_POP_Handler
Version     : 1.0 
Created Date: 16/1/2019
Description : This is to check the POP of an Opportunity and throws error message.
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            16/1/2019               Original Version
*************************************************************************************/

public class Core_POP_Handler {

    public static void popCheckOnApproval(List<Opportunity> opportunityList, Map<Id, Opportunity> oldOppMap){
        system.debug('Test Entry'+opportunityList);
        String POP = '%'+Label.Core_Performance_indicator+'%';
        String POP1 = '%'+Label.Core_Performance_indicator1+'%';
        String POP2 = '%'+Label.Core_Performance_indicator2+'%';
        List<Attachment> attachsize = new List<Attachment>();
        List<Note> Notesize = new List<Note>();
        List<ContentDocumentLink> contentdocSize = new List<ContentDocumentLink>();
        List<Task> taskList = new List<Task>();
        List<Opportunity> approvedOppList = new List<Opportunity>();
        Map<String,String> finalOppMap = new Map<String,String>();
        for(Opportunity opp : opportunityList){
            if(opp.Core_Approval_Status__c <> null && opp.Core_Approval_Status__c.equalsIgnoreCase('approved') && oldOppMap.get(opp.Id).Core_Approval_Status__c <> 'Approved'){
                approvedOppList.add(opp);
            }
        }
        if(approvedOppList.size() > 0){
            attachsize=[select id, Name, parentId from Attachment where parentId IN: approvedOppList AND (Name LIKE :POP OR Name LIKE :POP1)];
            if(attachsize.size() > 0){
                for(Attachment att : attachsize){
                    finalOppMap.put(att.parentId, att.parentId);
                }
            }
            
            Notesize=[select id, Title, parentId from Note where parentId IN: approvedOppList AND (Title Like:POP OR Title Like:POP1)];
            if(Notesize.size() > 0){
                for(Note notes : Notesize){
                    finalOppMap.put(notes.parentId, notes.parentId);
                }
            }
            
            Set<Id> oppSet = new Set<Id>();
            for(Opportunity opp : approvedOppList){
                oppSet.add(opp.Id);
            }
            contentdocSize=[SELECT ContentDocumentId, ContentDocument.Title, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: oppSet AND (ContentDocument.Title Like:POP OR ContentDocument.Title Like:POP1)];
            if(contentdocSize.size() > 0){
                for(ContentDocumentLink contdoc : contentdocSize){
                    finalOppMap.put(contdoc.LinkedEntityId, contdoc.LinkedEntityId);
                }
            }
            
            taskList = [SELECT id, Subject, Core_Task_Type__c, WhatId FROM Task WHERE (Subject LIKE :POP OR Subject LIKE:POP1 OR Core_Task_Type__c LIKE:POP2) AND WhatId IN: approvedOppList];
            if(taskList.size() > 0){
                for(Task tasks : taskList){
                    finalOppMap.put(tasks.WhatId, tasks.WhatId);
                }
            }
            system.debug('finalOppMap '+finalOppMap);
            for(Opportunity opp : approvedOppList){
                if(!finalOppMap.containsKey(opp.Id) && opp.Core_Commissionable__c.equalsIgnoreCase('Yes')){
                    opp.addError(Label.Core_POP_Error, false);
                }
            }
        }
    }
}