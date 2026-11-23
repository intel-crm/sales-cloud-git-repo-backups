public without sharing class Core_IPS_Outbound_Message_Handler {
    public static void updateCaseStatus(List<Core_IPS_BES_Outbound_Message__c> oldList, List<Core_IPS_BES_Outbound_Message__c> newList, 
                                        Map<Id,Core_IPS_BES_Outbound_Message__c> oldMap,Map<Id,Core_IPS_BES_Outbound_Message__c> newMap){
        Set<String> caseId = new Set<String>();
        Set<String> commentId = new Set<String>();
        Set<String> attachmentId = new Set<String>();
        Set<Case> caseSet = new Set<Case>();
         List<Case> csList = new List<Case>();
        Set<Core_IPS_Case_Comments__c> commentSet = new Set<Core_IPS_Case_Comments__c>();
        Set<Core_IPS_Case_Attachments__c> attachmentSet = new Set<Core_IPS_Case_Attachments__c>();
        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        List<Core_IPS_Case_Attachments__c> attachmentList = new List<Core_IPS_Case_Attachments__c>();                                    
        try{
            for(Core_IPS_BES_Outbound_Message__c outbound: newList){
                if(String.isBlank(outbound.Comment_Id__c) && String.isBlank(outbound.Core_IPS_Attachment_ID__c)){
                    caseId.add(outbound.Core_IPS_Case_ID__c);  
                }
                if(!String.isBlank(outbound.Comment_Id__c) && String.isBlank(outbound.Core_IPS_Attachment_ID__c)){
                    commentId.add(outbound.Comment_Id__c);
                    caseId.add(outbound.Core_IPS_Case_ID__c);
                }
                
                if(!String.isBlank(outbound.Core_IPS_Attachment_ID__c) && String.isBlank(outbound.Comment_Id__c)){
                    attachmentId.add(outbound.Core_IPS_Attachment_ID__c);
                    caseId.add(outbound.Core_IPS_Case_ID__c);
                }
            }
            Map<Id,Case> caseMap = new Map<id, Case>([SELECT id,Core_IPS_BackendID__c,Core_IPS_BES_Promote_Status__c,Core_IPS_New_Backend_System__c FROM case WHERE Id IN: caseId]);
            Map<Id,Core_IPS_Case_Comments__c> commentMap = new Map<id, Core_IPS_Case_Comments__c>([SELECT id,Core_IPS_BES_Promote_Status__c,Core_IPS_BES_ExtCommentID__c FROM Core_IPS_Case_Comments__c WHERE Id IN: commentId]);
            Map<Id,Core_IPS_Case_Attachments__c> attMap = new Map<Id, Core_IPS_Case_Attachments__c>([SELECT Id,Core_IPS_BES_Promote_Status__c FROM Core_IPS_Case_Attachments__c WHERE Id IN: attachmentId]);
            Case cs = new Case();
            for(Core_IPS_BES_Outbound_Message__c outbound: newList){
                
                cs = caseMap.get(outbound.Core_IPS_Case_ID__c);
                if(cs!=null){
                    csList.add(cs);
                }
                Core_IPS_Case_Comments__c comment = commentMap.get(outbound.Comment_Id__c);
                
                Core_IPS_Case_Attachments__c attachmentRec = attMap.get(outbound.Core_IPS_Attachment_ID__c);
                if(!String.isBlank(outbound.Core_IPS_Case_ID__c) && String.isBlank(outbound.Comment_Id__c) && String.isBlank(outbound.Core_IPS_Attachment_ID__c) && 
                   cs.Core_IPS_New_Backend_System__c != null && String.isBlank(cs.Core_IPS_BackendID__c) && String.isBlank(outbound.Core_IPS_BES_Depromote_Id__c)){
                       //All case conditions====
                       if(outbound.Status__c == 'Apigee Success') {
                           cs.Core_IPS_BES_Promote_Status__c = 'Sent Successfully';
                       }else if(outbound.Status__c == 'Apigee Failed'){
                           cs.Core_IPS_BES_Promote_Status__c = 'Failed'; 
                           //Minhaj
                           cs.Core_IPS_Backend_Rev__c = '';
                       }else if(outbound.Status__c == 'IPass Failed'){
                           cs.Core_IPS_BES_Promote_Status__c = 'Failed'; 
                           //minhaj
                           cs.Core_IPS_Backend_Rev__c = '';
                       }
                       else if(outbound.Status__c == 'IPS Failed'){
                           cs.Core_IPS_BES_Promote_Status__c = 'Failed'; 
                           //minhaj
                           cs.Core_IPS_Backend_Rev__c = '';
                       }
		        Database.DMLOptions dmo = new Database.DMLOptions();
                      // dmo.assignmentRuleHeader.useDefaultRule= false;
                      dmo.assignmentRuleHeader.assignmentRuleId= System.Label.Core_IPS_BES_AssignmentRuleId ; //'01Qo0000000AgYx'; 
                       cs.setOptions(dmo);
                       caseSet.add(cs);
                   }
                else if(!String.isBlank(outbound.Core_IPS_Case_ID__c) && !String.isBlank(outbound.Comment_Id__c) && String.isBlank(outbound.Core_IPS_Attachment_ID__c) && 
                   cs.Core_IPS_New_Backend_System__c != null && !String.isBlank(cs.Core_IPS_BackendID__c) && String.isBlank(outbound.Core_IPS_BES_Depromote_Id__c)){
                       
                    //   if(outbound.Status__c == 'Apigee Success') {
                    /* Tejaswini : Added comment.Core_IPS_BES_Promote_Status__c != 'Done' condition as part of fix for TWC745-6976 */
                       if(outbound.Status__c == 'Apigee Success' && comment.Core_IPS_BES_Promote_Status__c != 'Done') { 
                           if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_BES_Promote_Status__c.isCreateable() || Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_BES_Promote_Status__c.isUpdateable()) {
                           	comment.Core_IPS_BES_Promote_Status__c = 'Sent Successfully';
                           }
                       }else if(outbound.Status__c == 'Apigee Failed'){
                           comment.Core_IPS_BES_Promote_Status__c = 'Failed'; 
                       }else if(outbound.Status__c == 'IPass Failed'){
                           comment.Core_IPS_BES_Promote_Status__c = 'Failed'; 
                       }
                       else if(outbound.Status__c == 'IPass Success'){
                           comment.Core_IPS_BES_Promote_Status__c = 'Done'; 
                       }
                       else if(outbound.Status__c == 'IPS Failed'){
                           comment.Core_IPS_BES_Promote_Status__c = 'Failed'; 
                       }
                       commentSet.add(comment);
                   }
                   /* Fix by Tejaswini for comment status issue*/
                   else if(!String.isBlank(outbound.Core_IPS_Case_ID__c) && !String.isBlank(outbound.Comment_Id__c) && String.isBlank(outbound.Core_IPS_Attachment_ID__c) && 
                   String.isBlank(cs.Core_IPS_BackendID__c) && !String.isBlank(outbound.Core_IPS_BES_Depromote_Id__c)){
                      // if(outbound.Status__c == 'Apigee Success') {
                    /* Tejaswini : Added comment.Core_IPS_BES_Promote_Status__c != 'Done' condition as part of fix for TWC745-6976 */
                       if(outbound.Status__c == 'Apigee Success' && comment.Core_IPS_BES_Promote_Status__c != 'Done') {     
                           if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_BES_Promote_Status__c.isCreateable() || Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_BES_Promote_Status__c.isUpdateable()) {
                           	comment.Core_IPS_BES_Promote_Status__c = 'Sent Successfully';
                           }
                       }else if(outbound.Status__c == 'Apigee Failed'){
                           comment.Core_IPS_BES_Promote_Status__c = 'Failed'; 
                       }else if(outbound.Status__c == 'IPass Failed'){
                           comment.Core_IPS_BES_Promote_Status__c = 'Failed'; 
                       }
                       else if(outbound.Status__c == 'IPass Success'){
                           comment.Core_IPS_BES_Promote_Status__c = 'Done'; 
                       }
                       else if(outbound.Status__c == 'IPS Failed'){
                           comment.Core_IPS_BES_Promote_Status__c = 'Failed'; 
                       }
                       commentSet.add(comment);
                   } /* End Fix by Tejaswini for comment status issue*/
                else if(!String.isBlank(outbound.Core_IPS_Case_ID__c) && String.isBlank(outbound.Comment_Id__c) && !String.isBlank(outbound.Core_IPS_Attachment_ID__c) && 
                   cs.Core_IPS_New_Backend_System__c != null && !String.isBlank(cs.Core_IPS_BackendID__c) && String.isBlank(outbound.Core_IPS_BES_Depromote_Id__c) && attachmentRec!=null){//6-9-23
                       //All attachment conditions====
                       if(outbound.Status__c == 'Apigee Success') {
                          if (Schema.sObjectType.Core_IPS_Case_Attachments__c.fields.Core_IPS_BES_Promote_Status__c.isUpdateable()){
                           		attachmentRec.Core_IPS_BES_Promote_Status__c = 'Sent Successfully';
                          }
                       }else if(outbound.Status__c == 'Apigee Failed'){
                           attachmentRec.Core_IPS_BES_Promote_Status__c = 'Failed'; 
                       }else if(outbound.Status__c == 'IPass Failed'){
                           attachmentRec.Core_IPS_BES_Promote_Status__c = 'Failed'; 
                       }else if(outbound.Status__c == 'IPS Failed'){
                           cs.Core_IPS_BES_Promote_Status__c = 'Failed'; 
                       }
                       attachmentSet.add(attachmentRec);
                   }
            
            }
            commentList = new List<Core_IPS_Case_Comments__c>(commentSet);
            attachmentList = new List<Core_IPS_Case_Attachments__c>(attachmentSet);
            update new List<Case>(caseSet);
            update commentList;
            if(!attachmentList.isEmpty()){ //6-9-23
            	update attachmentList;
            }
            } catch(Exception e) {
                String IDs = (csList.size()>0) ? String.Join(csList,',') : ''+ 'Comment'+((commentList.size()>0) ? String.Join(commentList,',') : '')+((attachmentList.size()>0) ? String.Join(attachmentList   ,',') : '');
                Core_IPS_BES_LogEntry_Utility.insertLog(e,null,null,null,IDs);
            }
    }
}