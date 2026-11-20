/*********************************************
* Name : Core_IPS_BES_BuildCommentJSON 
* Author : Sriranjini J N
* Date Created : 21/08/2020
* Description : This is used in Core_IPS_BES_UpdateComment class to build JSON
* Version Updates :  
*   
************************************************/
public with sharing class Core_IPS_BES_BuildCommentJSON {
    /*Method signature changed by Tejaswini harpanhalli - DCG Custom Logic */
    public static Map<String,JSONGenerator> updateComment(List<String> responseList,Map<String, String> userDetailsMap){
        Map<String, JSONGenerator> commentUpdate = new Map<String,JSONGenerator>();        
        Set<String> caseIdList = new Set<String>();
        List<String> stringList = new List<String>();    
        String caseList='';   
        //Set<String> listIdSId = new Set<String>();
        try{
            Map<String,String> caseMap = new Map<String,String>();
            Map<String,String> commentMap = new Map<String,String>();
            Map<String,String> caseIdMap = new Map<String,String>();
            //Set<String> caseIdList = new Set<String>();
            List<String> case_rev = new List<String>();
            for(String response: responseList){
               // Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);
                Map<String,Object> systemJSONMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(((Map<String, Object>)JSON.deserializeUntyped(response)).get('system_details')));
                //for(String inboundJSON: systemJSONMap.keySet()){
                    caseMap.put((String)systemJSONMap.get('target_id')+','+(String)systemJSONMap.get('backend_rev'), JSON.serialize(((Map<String, Object>)JSON.deserializeUntyped(response)).get('issue_information')));  
                //}
                caseIdList.add((String)systemJSONMap.get('target_id'));
                stringList = new List<String>(caseIdList);
                caseList = String.join(stringList, ',');
                stringList.clear();
            }
		responseList.clear();
           
	   
	   
            if(case.SObjectType.getDescribe().isAccessible()){
		//This is called from batch class with size 1 to process the images containing comment individually
                for(Case cs: [SELECT ID, casenumber, Core_IPS_BackendID__c FROM case WHERE caseNumber IN : caseIdList]){
                    caseIdMap.put((string)cs.casenumber,(string)cs.Id);
                    //commentMap.put((string)cs.Id, caseMap.get(cs.casenumber));
                }
                
            }
            
	        for(String cn: caseMap.keySet()){
                case_rev = cn.split(',');
				commentMap.put(caseIdMap.get(case_rev[0])+','+case_rev[1], caseMap.get(cn));
            }
            
		caseMap.clear();
            for(String caseId: commentMap.keySet()){
               JSONGenerator gen = JSON.createGenerator(true); // added this line after commenting
                Map<String,Object> commentJSONMap = (Map<String,Object>)JSON.deserializeUntyped(commentMap.get(caseId));
                 
                if(commentJSONMap.get('comment_text')!=null){
                    Core_IPS_Comment_JSON__c commentJSON = Core_IPS_Comment_JSON__c.getInstance('Comment JSON');
                    gen.writeStartObject();     
                    gen.writeFieldName('Comments');
                    gen.writeStartObject();
                    gen.writeStringField('comment_text', String.valueof(commentJSONMap.get('comment_text')));
                    gen.writeStringField('comment_type', String.valueof(commentJSONMap.get('comment_type')!=null ? String.valueof(commentJSONMap.get('comment_type')):''));
                    gen.writeStringField('comment_source',commentJSON.Comment_Source__c);
                    gen.writeStringField('comment_authortype', commentJSON.Comment_Author_Type__c);

                    /* Tejaswini 21/02/2024 DCG Custom Logic */
                    if(commentJSONMap.containsKey('comment_author') && commentJSONMap.containsKey('comment_text')){
                        String authIdSId = (String)commentJSONMap.get('comment_author');
                        List<String> authDetails = userDetailsMap.get(authIdSId)?.split(';');
                        if(authDetails != NULL ){
                            String authEmail = (authDetails.size() >= 1 && authDetails[0] !='null') ? authDetails[0] : '';
                            gen.writeStringField('comment_authoremail', authEmail);
                            String authName = (authDetails.size() >= 2 && authDetails[1] !='null') ? authDetails[1] : '';
                            gen.writeStringField('Comment_AuthorName', authName);
                            String authFName = (authDetails.size() > 2 && authDetails[2] !='null') ? authDetails[2] : '';
                            gen.writeStringField('Comment_AuthorFirstName', authFName);
                        }                
                    } else {
                        gen.writeStringField('comment_authoremail', commentJSON.Comment_Author_Email__c);
                        gen.writeStringField('Comment_AuthorName', commentJSON.Comment_Author_Name__c);
                    }

                    gen.writeStringField('comment_authorby', commentJSON.Comment_Author_By__c);
                    
                    gen.writeStringField('Comment_ExtCommentID','');  
                    gen.writeStringField('backend_rev', String.valueof(commentJSONMap.get('backend_rev'))!=null ? String.valueof(commentJSONMap.get('backend_rev')):'');
                    gen.writeStringField('Case',caseId);
                    gen.writeEndObject();
                    gen.writeEndObject();
                    commentUpdate.put(caseId,gen); 
                   
                }
            }
		commentMap.clear();
        }catch(Exception e){
            //Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join((Iterable<String>)responseList,','));
              Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null,caseList);
            
        }
        return commentUpdate; 
    }
}