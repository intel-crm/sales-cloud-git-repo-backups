/**************************************************************************************
Apex Class Name:  Core_POP_Handler
Version     : 1.0 
Created Date: 16/1/2019
Description : This is to check the POP of an Opportunity and throws error message.
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            16/1/2019               Original Version
* Pratik Padwal             21/2/2023               TWC3123-3686 - Added new method for PW approval POP check. 
*************************************************************************************/

public without sharing class Core_POP_Handler {
    
    public static void popCheckOnApproval(List<Opportunity> opportunityList, Map<Id, Opportunity> oldOppMap){
        
        String POP = '%'+Label.Core_Performance_indicator+'%';
        String POP1 = '%'+Label.Core_Performance_indicator1+'%';
        String POP2 = '%'+Label.Core_Performance_indicator2+'%';
        List<Attachment> attachsize = new List<Attachment>();
        List<Note> Notesize = new List<Note>();
        List<ContentDocumentLink> contentdocSize = new List<ContentDocumentLink>();
        List<Task> taskList = new List<Task>();
        List<Opportunity> approvedOppList = new List<Opportunity>();
        Map<String,String> finalOppMap = new Map<String,String>();
        List<Id> approvedOppIdList  = new List<Id>(); 
        for(Opportunity opp : opportunityList){
            if(opp.Core_Approval_Status__c <> null && opp.Core_Approval_Status__c.equalsIgnoreCase('approved') && oldOppMap.get(opp.Id).Core_Approval_Status__c <> 'Approved'){
                approvedOppList.add(opp);
                approvedOppIdList.add(opp.Id);
            }
        }
        
        if(approvedOppList.size() > 0){
            attachsize=[select id, Name, parentId from Attachment where parentId IN: approvedOppIdList AND (Name LIKE :POP OR Name LIKE :POP1)];
            if(attachsize.size() > 0){
                for(Attachment att : attachsize){
                    finalOppMap.put(att.parentId, att.parentId);
                }
            }
            Notesize=[select id, Title, parentId from Note where parentId IN: approvedOppIdList AND (Title Like:POP OR Title Like:POP1)];
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
            
            for(Opportunity opp : approvedOppList){
                if((!finalOppMap.containsKey(opp.Id) && opp.Core_Commissionable__c.equalsIgnoreCase('Yes')) || (!finalOppMap.containsKey(opp.Id) && opp.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && opp.Core_Coverage_Type_Nm__c == 'Deal Registration')){
                    opp.addError(Label.Core_POP_Error, false);
                }
            }
        }
    }
    //Start - TWC3123-3686- Added code block to check POP for PW(Production Win) approval.
    public static void popCheckOnPWApproval(List<Opportunity> opportunityList, Map<Id, Opportunity> oldOppMap){             
       

        //String POP3 = '%'+Label.Core_Performance_indicator3+'%';//Commented for TWC3123-3904 
        //Start - TWC3123-3904 Added some new fileName formats.
        List<String> POPFileNames = new List<String>();
        if(Label.Core_Performance_indicator3.contains(',')){
            POPFileNames = Label.Core_Performance_indicator3.split(',');
        }else{
            POPFileNames.add(Label.Core_Performance_indicator3); 
        }
        //End - TWC3123-3904
        List<Attachment> attachsize = new List<Attachment>();
        List<Note> Notesize = new List<Note>();
        List<ContentDocumentLink> contentdocSize = new List<ContentDocumentLink>();
        List<Task> taskList = new List<Task>();
        List<Opportunity> approvedOppList = new List<Opportunity>();
        Map<String,String> finalOppMap = new Map<String,String>();
        List<Id> approvedOppIdList  = new List<ID>();
        for(Opportunity opp : opportunityList){
            if(opp.StageName <> null && opp.StageName.equalsIgnoreCase('Production Win') && oldOppMap.get(opp.Id).StageName <> 'Production Win'){
                approvedOppList.add(opp);
                approvedOppIdList.add(opp.Id);	
            }
        }
        if(approvedOppList.size() > 0){
            attachsize=[select id, Name, parentId from Attachment where parentId IN: approvedOppIdList AND Name LIKE :POPFileNames];//TWC3123-3904 -Changed the like filter variable.
            if(attachsize.size() > 0){
                for(Attachment att : attachsize){
                    finalOppMap.put(att.parentId, att.parentId);
                }
            }
            
            Notesize=[select id, Title, parentId from Note where parentId IN: approvedOppIdList AND Title Like:POPFileNames];//TWC3123-3904 -Changed the like filter variable.
            if(Notesize.size() > 0){
                for(Note notes : Notesize){
                    finalOppMap.put(notes.parentId, notes.parentId);
                }
            }
            
            Set<Id> oppSet = new Set<Id>();
            for(Opportunity opp : approvedOppList){
                oppSet.add(opp.Id);
            }
            contentdocSize=[SELECT ContentDocumentId, ContentDocument.Title, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: oppSet AND ContentDocument.Title Like:POPFileNames];//TWC3123-3904 -Changed the like filter variable.
            if(contentdocSize.size() > 0){
                for(ContentDocumentLink contdoc : contentdocSize){
                    finalOppMap.put(contdoc.LinkedEntityId, contdoc.LinkedEntityId);
                }
            }
            
            taskList = [SELECT id, Subject, Core_Task_Type__c, WhatId FROM Task WHERE Subject LIKE :POPFileNames AND WhatId IN: approvedOppIdList];//TWC3123-3904 -Changed the like filter variable.
            if(taskList.size() > 0){
                for(Task tasks : taskList){
                    finalOppMap.put(tasks.WhatId, tasks.WhatId);
                }
            }
            
            for(Opportunity opp : approvedOppList){
                if((!finalOppMap.containsKey(opp.Id) && opp.Core_Commissionable__c.equalsIgnoreCase('Yes') && opp.Core_Opportunity_Type__c.CONTAINS('Design')) ||
                  (!finalOppMap.containsKey(opp.Id) && opp.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && opp.Core_Coverage_Type_Nm__c == 'Deal Registration')){
                    //Vijay 3/9/24 :  reverting back to soft error for Commissionable flag (TWC4767-2794)
                      opp.addError(Label.Core_PWPOP_Error, false);// Commented temporarily for Low Touch Design 
                }
            }
        }
    }
    //End - TWC3123-3686
    
    public static void TechOwnerCIMIdValidation(List<Opportunity> opportunityList, Map<Id, Opportunity> oldOppMap) { 
        boolean ucdSwitch = Core_CRM_Utility.isUCDSwitchOn(); //TWC4767-3431 - implementation of UCD and CIM logic switch
        
        List<Opportunity> approvedOppList = new List<Opportunity>();
        //String InactiveRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Inactive Account').getRecordTypeId();
        for(Opportunity opp : opportunityList){
            if(opp.Core_Approval_Status__c <> null && opp.Core_Approval_Status__c.equalsIgnoreCase('approved') && oldOppMap.get(opp.Id).Core_Approval_Status__c <> 'Approved'){
                approvedOppList.add(opp);
            }
        }
        
        if(approvedOppList.isEmpty())
            return;
        
        List<opportunitylineitem> oliList = [select id, core_vendor__c,opportunityid from opportunitylineitem where opportunityid in:approvedOppList and core_vendor__r.recordtype.name = 'Inactive Account' and Core_Status__c in('Win Submitted','Pending','On Hold')];
        for(Opportunity opp : approvedOppList ){
            
            if(Opp.Core_Technical_Owner__c == null && opp.Core_Opportunity_Type__c.containsIgnoreCase('Design')){
                opp.addError(Label.Core_Tech_Owner_Validation, false);
                
            }/*else if(ucdSwitch == true && Opp.Core_Account_UCD_ID__c == null){ //TWC4767-3431
                opp.addError(Core_CRM_Utility.getCRMLabel('CRM_Unified_Id_Validation'), false);
            }
            else if(ucdSwitch == false && Opp.Core_Account_CIM_Id__c == null){ //TWC4767-3431
                opp.addError(Label.Core_CIM_Id_Validation, false);
            }*/ //commented as part of TWC4767-3983
            else if(opp.Core_Account_Record_type__c == 'Inactive Account'){
                opp.addError(Label.Core_VendorAccountInactive);
            }else if(oliList.size()>0){
                opp.addError(Label.Core_VendorAccountInactive);
            }
            
        }
    }
}