/********************************************* 
* Name : Core_IPS_HSD_CreateJSON 
* Author : Sriranjini J N
* Date Created : 20/08/2020
* Description : This is the rest exposed class for ipass comment
* Version Updates : 
*   
************************************************/
public with sharing class Core_IPS_BES_UpdateComment {
   

    public static void core_IPS_BES_Update(List<String> responseList, Map<String, String> userDetailsMap, Map<String,String> sourceDetailsMap){
        List<String> stringCaseList = new List<String>();
        //String caseIdRecList='';
        try{
              
            Map<String,JSONGenerator> commentJSONMap = Core_IPS_BES_BuildCommentJSON.updateComment(responseList, userDetailsMap);
            List<Core_IPS_Case_Comments__c> commentList = new list<Core_IPS_Case_Comments__c>();
            List<Case> caseIdList = new List<Case>();
            List<Id> caseIds= new List<Id>();
           // List<Case> caseDataForBackend = new List<Case>();
            for(String caseId: commentJSONMap.keySet()){
               //Map<String, Object> commentresponseMap = (Map<String, Object>)JSON.deserializeUntyped(commentJSONMap.get(caseId).getAsString()); 
		//List<Object> reqs = (List<Object>) CommentresponseMap.values(); 
               
                
                //for(Object a: ((List<Object>) CommentresponseMap.values())){
                for(Object a: ((List<Object>) (((Map<String, Object>)JSON.deserializeUntyped(commentJSONMap.get(caseId).getAsString())).values()))){
                    Map<String, Object> commentreqMap = (Map<String, Object>)(a);
                    
                    Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();

                    /*US1038991 - 12/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Author_Type__c.isCreateable()){
                        newComment.Core_IPS_Comment_Author_Type__c =  String.valueof(commentreqMap.get('comment_authortype'));
                    }
                    
                    /*US1038991 - 12/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Authored_By_Email__c.isCreateable()){
                        newComment.Core_IPS_Comment_Authored_By_Email__c =  String.valueof(commentreqMap.get('comment_authoremail'));
                    }
                    
                    /*US1038991 - 12/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    //if(Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Authored_By__c.isCreateable()){
                        newComment.Core_IPS_Comment_Authored_By__c =  String.valueof(commentreqMap.get('comment_authorby'));
                    //}
                    
                    /*US1038991 - 12/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case_Comment_Source__c.isCreateable()){
                        newComment.Core_IPS_Case_Comment_Source__c = String.valueof(commentreqMap.get('comment_source'));
                    }
                    
                    /*US1038991 - 12/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case_Comment_Type__c.isCreateable()){
                        newComment.Core_IPS_Case_Comment_Type__c = String.valueof(commentreqMap.get('comment_type'));
                    }
                    
                    /*US1038991 - 12/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    //if(Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Rich_Comment__c.isCreateable()){
                         newComment.Core_IPS_Rich_Comment__c = String.valueof(commentreqMap.get('comment_text')).replace('data:image/jpg','data:image/jpeg');
                    //}
                    
                    /*US1038991 - 12/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    if(Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case__c.isCreateable()){
                        //newComment.Core_IPS_Case__c = caseId;
                        newComment.Core_IPS_Case__c = caseId.subStringBefore(',');
                        caseIds.add(newComment.Core_IPS_Case__c);
                        stringCaseList.add(caseId.subStringBefore(','));
                    }
                    
                    /*US1038991 - 12/07/2021 - Karthik - FLS Check for security vulnerability --*/
                    //if(Schema.sObjectType.Core_IPS_Case_Comments__c.fields.core_IPS_Comment_Authored_By_Name__c.isCreateable()){
                        newComment.core_IPS_Comment_Authored_By_Name__c =  String.valueof(commentreqMap.get('Comment_AuthorName'));
                    //}
                    /* Tejaswini Harpanhalli - DCG custom logic Comment Author firstname update */
                   	 	newComment.Core_IPS_Comment_Authored_By_FirstName__c = String.valueOf(commentreqMap.get('Comment_AuthorFirstName'));
                    
                    if(!String.isBlank(newComment.Core_IPS_Rich_Comment__c)){
                        commentList.add(newComment);
                    }
                    
                    if((String)commentreqMap.get('backend_rev') != ''){
                        //caseIdList.add(new Case(Id=caseId, Core_IPS_Backend_Rev__c = String.valueof(commentreqMap.get('backend_rev'))));
                         caseIdList.add(new Case(Id=caseId.subStringBefore(','), Core_IPS_Backend_Rev__c = String.valueof(commentreqMap.get('backend_rev'))));
                    }       
                }
            }
            commentJSONMap.clear();
            if(Case.SObjectType.getDescribe().isAccessible()){
           // caseDataForBackend=[select id,CaseNumber,Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c,Core_IPS_BackendID__c, Core_IPS_BES_Promote_Status__c,Core_IPS_New_Backend_System__c from case where Id IN: caseIds];
           // }
           //This is called from batch class with size 1 to process the images containing comment individually 
            for(Case caseData :[select id,CaseNumber,Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c,Core_IPS_BackendID__c, Core_IPS_BES_Promote_Status__c,Core_IPS_New_Backend_System__c from case where Id IN: caseIds]){
                //Ajith added this logic to restrict the Case Update, when Backend system is deactivated
                if(caseData.Core_IPS_New_Backend_System__c == null || caseData.Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c ==true || caseData.Core_IPS_BES_Promote_Status__c !='Done' || caseData.Core_IPS_BackendID__c== null || caseData.Core_IPS_BackendID__c !=sourceDetailsMap.get(caseData.CaseNumber)){
                         commentList.clear();
                   }
            }
            }
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isCreateable()){
		//This is called from batch class with size 1 to process the images containing comment individually
                if(commentList!=null &&commentList.size()>0){
                    insert commentList;
                }                    
            }
            commentList.clear();
            if(caseIdList.size() > 0){
                Database.update(caseIdList);    
            }   
        } catch(exception e){
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null,String.join(stringCaseList, ',') );   
        }
       
    }
}