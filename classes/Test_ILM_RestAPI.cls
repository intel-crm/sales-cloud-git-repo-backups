@RestResource(urlMapping='/comments/*')
global class Test_ILM_RestAPI {
     //public static Integer offsetSize = 0; //RestContext.request.params.get('offset');
  @HttpGet
    global static String getCaseComments(){
        
        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        
        RestRequest request = RestContext.request;
        try{
           System.debug('Inside GET');
           Integer MAX_COMMENT_LIMIT = 20;
           String caseId = request.requestURI.substring(request.requestURI.lastIndexof('/')+1);
           Integer limitSize = Integer.valueOf(request.params.get('limit'));
           Integer offsetSize = Integer.valueOf(request.params.get('offset'));
           String corecaseId = request.params.get('caseId');
           String commentId = request.params.get('commentId');
           String productId = request.params.get('productId');
           String accountId = request.params.get('accountId');
           String contactId = request.params.get('contactId');
           String contactEmail = request.params.get('contactEmail');
           String contactName = request.params.get('contactName');
           String productName = request.params.get('productName');
           String accountName = request.params.get('accountName');
           System.debug('caseId--'+caseId+'\ncorecaseId--'+corecaseId);
           if(limitSize>MAX_COMMENT_LIMIT) limitSize = MAX_COMMENT_LIMIT;
           
           String queryCondition = ' ';
           if(caseId!=null && caseId!=''&& caseId!='comments'){ 
               if(contactId!=null && contactId!='') { queryCondition+='and Core_IPS_Case__r.ContactId =:contactId '; system.debug('cId-'+queryCondition);}    
               if(contactName!=null && contactName!=''){ queryCondition+='and Core_IPS_Case__r.Core_Contact_Name__c LIKE \'%' + contactName + '%\' ';system.debug('cN-'+queryCondition); }      
               if(contactEmail!=null && contactEmail!=''){ queryCondition+='and Core_IPS_Case__r.ContactEmail LIKE \'%' + contactEmail + '%\' ';system.debug('cE-'+queryCondition);}
    
               if(productId!=null && productId!='') {queryCondition+='and Core_IPS_Case__r.Asset.Id =:productId ';system.debug('pID-'+queryCondition);} 
               if(productName!=null && productName!='') { queryCondition+='and Core_IPS_Case__r.Asset.Name LIKE \'%' + productName + '%\' ' ;system.debug('pN-'+queryCondition);} 
               
               if(accountId!=null && accountId!=''){ queryCondition+='and Core_IPS_Case__r.AccountId =:accountId ';system.debug('aId-'+queryCondition);} 
               if(accountName!=null && accountName!='') { queryCondition+='and Core_IPS_Case__r.core_Account_Name__c LIKE \'%' + accountName + '%\' ';system.debug('aN-'+queryCondition);}
               system.debug('Inside If');
           }
           else{
             boolean flag = false;
              if(corecaseId!=null && corecaseId!='') { 
                if(flag==true){ queryCondition+='Core_IPS_Case__r.Id =:corecaseId '; flag = true; }
              }
              if(commentId!=null && commentId!='') { 
                if(flag==true){ queryCondition+='and Id =:commentId '; }
                else{ queryCondition+='Id =:commentId '; flag = true; }
              }
              if(contactId!=null && contactId!='') { 
                if(flag==true){ queryCondition+='and Core_IPS_Case__r.ContactId =:contactId '; }
                else{ queryCondition+='Core_IPS_Case__r.ContactId =:contactId '; flag = true; }
              }    
              if(contactName!=null && contactName!=''){
                if(flag==true){ queryCondition+='and Core_IPS_Case__r.Core_Contact_Name__c LIKE \'%' + contactName + '%\' '; }
                else{ queryCondition+='Core_IPS_Case__r.Core_Contact_Name__c LIKE \'%' + contactName + '%\' '; flag = true; }
              }         
              if(contactEmail!=null && contactEmail!=''){
                if(flag==true){ queryCondition+='and Core_IPS_Case__r.ContactEmail LIKE \'%' + contactEmail + '%\' ';}
                else{ queryCondition+='Core_IPS_Case__r.ContactEmail LIKE \'%' + contactEmail + '%\' '; flag = true; }
              }
            
              if(productId!=null && productId!='') {
                if(flag==true){ queryCondition+='and Core_IPS_Case__r.Asset.Id :productId ';}
                else{ queryCondition+='Core_IPS_Case__r.Asset.Id :productId '; flag = true; }
              }
              if(productName!=null && productName!='') {
                if(flag==true){ queryCondition+='and Core_IPS_Case__r.Asset.Name LIKE \'%' + productName + '%\' ';}
               else{ queryCondition+='Core_IPS_Case__r.Asset.Name LIKE \'%' + productName + '%\' '; flag = true; }
              }
            
              if(accountId!=null && accountId!=''){
                if(flag==true){ queryCondition+='and Core_IPS_Case__r.AccountId :accountId ';}
               else{ queryCondition+='Core_IPS_Case__r.AccountId :accountId '; flag = true; }
              }
              if(accountName!=null && accountName!='') {
                if(flag==true){ queryCondition+='and Core_IPS_Case__r.core_Account_Name__c LIKE \'%' + accountName + '%\' ';}
                else{ queryCondition+='Core_IPS_Case__r.core_Account_Name__c LIKE \'%' + accountName + '%\' '; flag = true; }
              }
           }

           //String query= 'SELECT Id,Name,Core_IPS_Case__r.core_Account_Name__c,Core_IPS_Case__r.Core_Contact_Name__c, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Core_IPS_Case__c, Core_IPS_Comment__c,  Core_IPS_Public__c, Core_IPS_Rich_Comment__c, Core_IPS_Case_Comment_Type__c, Core_IPS_Comment_Author_Type__c,  Core_IPS_Comment_Authored_By_Email__c, Core_IPS_Comment_Authored_By_Name__c, Core_IPS_Authored_By__c  FROM Core_IPS_Case_Comments__c WHERE ';
           String query= 'SELECT Id,Name,Core_IPS_Case__r.CaseNumber,Core_IPS_Case__r.core_Account_Name__c,Core_IPS_Case__r.Core_Contact_Name__c, Core_IPS_Rich_Comment__c, Core_IPS_Case_Comment_Type__c  FROM Core_IPS_Case_Comments__c WHERE '; 
           
            System.debug('CaseId-'+caseId+'\nlimit-'+limitSize+'\noffset-'+offsetSize);
            System.debug('Query----'+query);
            System.debug('QueryCon----'+queryCondition);
           if(caseId!='comments'){
              if(CaseId.length()==8){
                 query+= 'Core_IPS_Case__r.CaseNumber =: caseId '+ queryCondition;// + 'LIMIT :limitSize OFFSET :offsetSize';
                 commentList = Database.query(query);
              }    
              else if(CaseId.startsWith('500') &&  (CaseId.length()==18 || CaseId.length()==15) ){
                 query+= 'Core_IPS_Case__r.Id =: caseId '+ queryCondition;// + 'LIMIT :limitSize OFFSET :offsetSize';
                 commentList = Database.query(query);
              }
              else if(CaseId.startsWith('a1n') &&  (CaseId.length()==18 || CaseId.length()==15)){
                 query+= 'Id =: caseId '+ queryCondition;
                 commentList = Database.query(query);
              } 
           }
           else{
                 query+=  queryCondition;
                 commentList = Database.query(query);
              }  
           
            System.debug('Query----'+query);
          //offsetSize += limitSize;
        }
        catch(Exception e){
            System.debug('Exception--'+e.getMessage());
        }
        system.debug('Comments-->'+commentList);
        system.debug('Comments size-->'+commentList.size());
        //return commentList; 
        String jsonData = '';
        if(!commentList.isEmpty()){
            JSONGenerator jsonGen = JSON.createGenerator(true);
            
            jsonGen.writeStartObject();
            
            jsonGen.writeFieldName('SystemDetails');
            jsonGen.writeStartObject();
            jsonGen.writeStringField('source','IPS');
            jsonGen.writeStringField('target','ILM');
            jsonGen.writeStringField('message_type','Comment');
            jsonGen.writeEndObject();
           
            jsonGen.writeFieldName('FilterCriteria');
            jsonGen.writeStartObject();
            jsonGen.writeStringField('ContactId','0033F00000b4Oqk');
            jsonGen.writeEndObject();
            jsonGen.writeFieldName('CommentInfo');
            jsonGen.writeStartArray();
            for(Core_IPS_Case_Comments__c c : commentList){
                jsonGen.writeStartObject();
                jsonGen.writeStringField('CaseNumber',c.Core_IPS_Case__r.CaseNumber);
                jsonGen.writeStringField('AccountName',c.Core_IPS_Case__r.core_Account_Name__c);
                jsonGen.writeStringField('Contactname',c.Core_IPS_Case__r.Core_Contact_Name__c);
                jsonGen.writeStringField('ID',c.Id);
                jsonGen.writeStringField('Name',c.Name);
                jsonGen.writeStringField('RichComment',c.Core_IPS_Rich_Comment__c);
                jsonGen.writeStringField('CommentType',c.Core_IPS_Case_Comment_Type__c);
                jsonGen.writeEndObject();
            }
            jsonGen.writeEndArray();
            jsonGen.writeEndObject();
            jsonData = jsonGen.getAsString();
            
             
        } 
        System.debug('Json Data - ' + jsonData);
        return jsonData;  
       
    }
    
    @HttpPost
    global static void caseComments(Core_IPS_Comment_Wrapper case_comments_filter) {
        //Core_IPS_Comment_Handler handler = new Core_IPS_Comment_Handler(case_comments_filter);
        Core_IPS_Comment_Handler handler = new Core_IPS_Comment_Handler();
        handler.caseCommentFilter(case_comments_filter);
        handler.getCaseComments('comments');
        System.debug('Response for Post method==>'+case_comments_filter);
        //return response;
         
    }

  
}