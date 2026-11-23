public class Core_IPS_Comment_Handler {
    private Integer limit_size = null;
    private Integer offset = null;
    private Core_IPS_Comment_Wrapper CaseCommentWrapper = null;
    private static Map<String, String> caseCommentWrp = new Map<String, String>();
    private static List<String> statusValue = new List<String>();
    private String queryCondition = '';
    List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
    List<Core_IPS_Case_Comments__c> commentList1 = new List<Core_IPS_Case_Comments__c>();
    String nextRecordURL = '/services/apexrest/nextcomments/';
    Integer MAX_LIMIT = 5;  
    Integer SOQL_LIMIT = 50000;
    Boolean filterCheck = false;
    private Static String GET_CASE_COMMENTS_SOQL =  'SELECT Id,Core_IPS_Case__r.CaseNumber,Core_IPS_Case__r.core_Account_Name__c, Core_IPS_Case__r.Core_Contact_Name__c,Core_IPS_Case__r.Core_IPS_Product_name__c, Name, Core_IPS_Case_Comment_Source__c,'+ 
            'Core_IPS_Case_Comment_Type__c, Core_IPS_Rich_Comment__c, '+
        //CreatedDate, CreatedBy_Name__c, CreatedById, Core_IPS_Comment_Author_Type__c,Core_IPS_Comment_Authored_By_Email__c,'+
            'Core_IPS_Comment_Authored_By_Name__c, Core_IPS_Comment_Authored_By__c  FROM Core_IPS_Case_Comments__c';
    
    public Core_IPS_Comment_Handler(){
    }    
	public void caseCommentFilter(Core_IPS_Comment_Wrapper ccWrpr){
        RestRequest request = RestContext.request;
        this.CaseCommentWrapper = ccWrpr;
        
        try{
            //String case_number = request.requestURI.substring(request.requestURI.lastIndexof('/')+1);
            //if(case_number==null || case_number == ''){
               if(ccWrpr.limit_size == null){ this.limit_size = null; } else { this.limit_size = ccWrpr.limit_size; filterCheck= true;} 
               if(ccWrpr.offset == null){ this.offset = null; } else { this.offset = ccWrpr.offset; filterCheck= true;}  
               caseCommentWrp.put('contact_name',ccWrpr.contact_name );
               caseCommentWrp.put('contact_email',ccWrpr.contact_email );
               caseCommentWrp.put('case_number',ccWrpr.case_number);
               caseCommentWrp.put('account_name',ccWrpr.account_name);
               caseCommentWrp.put('account_cim_id',ccWrpr.account_cim_id );
               caseCommentWrp.put('product_name',ccWrpr.product_name);
               caseCommentWrp.put('product_epm_id',ccWrpr.product_epm_id );
               caseCommentWrp.put('status',ccWrpr.status );
               caseCommentWrp.put('created_date',ccWrpr.created_date);
               caseCommentWrp.put('backend_system_name',ccWrpr.backend_system_name);
               caseCommentWrp.put('promote_status', ccWrpr.promote_status);
               Boolean flag = false;
               for(String c : caseCommentWrp.KeySet()){
                    if(caseCommentWrp.get(c)!=null && caseCommentWrp.get(c)!=''){
                        queryCondition+=' WHERE '; 
                        filterCheck= true;
                    } 
                }        
                for(String c : caseCommentWrp.KeySet()){
                    if(caseCommentWrp.get(c)!=null && caseCommentWrp.get(c)!=''){
                        if(c == 'contact_name'){
                            if(flag==true){ queryCondition+='and '; }
                            queryCondition+='Core_IPS_Case__r.Core_Contact_Name__c LIKE \'%' + caseCommentWrp.get(c) + '%\' '; flag = true; 
                        } 
                        if(c == 'contact_email'){
                            if(flag==true){ queryCondition+='and '; }
                            queryCondition+='Core_IPS_Case__r.ContactEmail LIKE \'%' + caseCommentWrp.get(c) + '%\' '; flag = true; 
                        }
                        if(c == 'case_number'){
                            if(flag==true){ queryCondition+='and '; }
                            queryCondition+='Core_IPS_Case__r.CaseNumber = \'' + caseCommentWrp.get(c) + '\'' ; flag = true; 
                        }
                        if(c == 'account_name'){
                            if(flag==true){ queryCondition+='and '; }
                            queryCondition+='Core_IPS_Case__r.core_Account_Name__c LIKE \'%' + caseCommentWrp.get(c) + '%\' '; flag = true; 
                        }
                        if(c == 'account_cim_id'){
                            if(flag==true){ queryCondition+='and '; }
                            queryCondition+='Core_IPS_Case__r.Account.Core_CIM_ID__c LIKE \'%' + caseCommentWrp.get(c) + '%\' '; flag = true; 
                        }
                        if(c == 'product_name'){
                            if(flag==true){ queryCondition+='and '; }
                            queryCondition+='Core_IPS_Case__r.Core_IPS_Product_name__c LIKE \'%' + caseCommentWrp.get(c) + '%\' '; flag = true; 
                        }
                        if(c == 'product_epm_id'){
                            if(flag==true){ queryCondition+='and '; }
                            queryCondition+='Core_IPS_Case__r.Product.Core_Product_Name_EPM_ID__c LIKE \'%' + caseCommentWrp.get(c) + '%\' '; flag = true; 
                        }
                        if(c == 'status'){
                            String st= '';
                            statusValue = caseCommentWrp.get(c).split(',');
                            for(Integer i = 0; i < statusValue.size(); i++){
                                   st += '\''+statusValue[i]+'\'';
                                   if(i!=statusValue.size()-1 && statusValue.size() > 1) st+=',';
                            }
                            if(flag==true){ queryCondition+='and '; }
                            queryCondition+='Core_IPS_Case__r.Status IN (' + st + ')'; flag = true; 
                        }
                        if(c == 'created_date'){
                            if(flag==true){ queryCondition+='and '; }
                            queryCondition+='Core_IPS_Case__r.CreatedDate LIKE \'%' + caseCommentWrp.get(c) + '%\' '; flag = true; 
                        }
                        if(c == 'backend_system_name'){
                            if(flag==true){ queryCondition+='and '; }
                            queryCondition+='Core_IPS_Case__r.Core_IPS_Backend_System__r.Name LIKE \'%' + caseCommentWrp.get(c) + '%\' '; flag = true; 
                        }
                        if(c == 'promote_status'){
                            if(flag==true){ queryCondition+='and '; }
                            queryCondition+='Core_IPS_Case__r.Core_Promote_Status__c LIKE \'%' + caseCommentWrp.get(c) + '%\' '; flag = true; 
                        }
                        
                    }
                }
        
            //}
        }
        catch(Exception e){
            System.debug('Error in fetcing CaseNumber--');
        }
        
    }
    public void getCaseComments(String str){
      if(str== 'comments'){
        String query = GET_CASE_COMMENTS_SOQL + queryCondition;
        System.debug('QueryCondition-'+queryCondition);
        String query1= query;
        //Integer MAX_LIMIT = 5;
        this.offset = 0;
        /*if(this.limitSize!=null){
        	query += ' LIMIT '+this.limitSize;
        } 
        if(this.offset!=null && this.offset<=2000){
            query += ' OFFSET '+this.offset;
        }*/
       if(filterCheck== false){
          String query2 = GET_CASE_COMMENTS_SOQL + ' LIMIT '+ SOQL_LIMIT;
          commentList = Database.query(query2); 
          getJSON();
       }
       else{  
        System.debug('Query-'+query1); 
        commentList1 = Database.query(query1);
        System.debug('TotalQuerySize-'+commentList1.size());
          if(commentList1.size()>MAX_LIMIT){
            query+=' LIMIT '+MAX_LIMIT+' OFFSET '+this.offset;
            system.debug('limitquery--'+query);
            commentList = Database.query(query);
            System.debug('limitQuerySize-'+commentList.size());
            Integer off= Integer.valueof(MAX_LIMIT)+Integer.valueof(this.offset); 
            Core_Log_Entry__c le = new Core_Log_Entry__c ();
            le.Core_Details__c = queryCondition +' LIMIT '+MAX_LIMIT+' OFFSET '+off +','+commentList1.size()+','+MAX_LIMIT+','+off;
			le.Core_Origin__c = 'SFDC';
			le.Core_Severity__c= 'commentFilter';
			le.Core_When__c = system.now();
			insert le;
            nextRecordURL += le.Id;
            system.debug('nextRecordURL--'+nextRecordURL);
            getJSON();
           }
          } 
        }
        else{
           /*String query2 = GET_CASE_COMMENTS_SOQL +' '+ str ;
           system.debug('limitqueryElse--'+query2);
           commentList = Database.query(query2);
           System.debug('limitQuerySizeElse-'+commentList.size());*/
           List<String> con3 = new List<String>();
           String condition= '';
           Integer totalSize=0;
           Integer limitSize=0;
           Integer offsetSize=0;
           con3 = str.split(',');
           condition = con3[0];
           totalSize = Integer.valueof(con3[1]);
           limitSize = Integer.valueof(con3[2]);
           offsetSize = Integer.valueof(con3[3]);
           String query2 = GET_CASE_COMMENTS_SOQL + ' ' +condition ;
           system.debug('limitqueryElse--'+query2);
           commentList = Database.query(query2);
           System.debug('limitQuerySizeElse-'+commentList.size());
           Integer off = limitSize + offsetSize;
           List<String> con1= str.split('OFFSET');
            if(totalSize>offsetSize){
                Core_Log_Entry__c le = new Core_Log_Entry__c ();
                le.Core_Details__c = con1[0]+' OFFSET '+off +','+totalSize+','+limitSize+','+off;
			    le.Core_Origin__c = 'SFDC';
			    le.Core_Severity__c= 'commentFilter';
			    le.Core_When__c = system.now();
			    insert le;
                nextRecordURL += le.Id;
                system.debug('nextRecordURL--'+nextRecordURL);
            }
           
           getJSON(); 
        }  
    }
    
    
    
    
    public String getJSON(){
        String jsonData = '';
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
	    jsonGen.writeFieldName('system_details');
    	jsonGen.writeStartObject();
    	jsonGen.writeStringField('source_system','IPS');
    	jsonGen.writeStringField('target_system','ILM');
    	jsonGen.writeStringField('message_type','Comment');
    	jsonGen.writeEndObject();
         
        jsonGen.writeFieldName('next_record_url');
    	jsonGen.writeStartObject();
    	jsonGen.writeStringField('nex_record_url',nextRecordURL);
    	jsonGen.writeEndObject();
        
        
        jsonGen.writeFieldName('case_comments_filter');
		jsonGen.writeStartObject();
        for(String c : caseCommentWrp.KeySet()){
            if(caseCommentWrp.get(c)!=null && caseCommentWrp.get(c)!=''){
                jsonGen.writeStringField(c,caseCommentWrp.get(c));
            }
            else{
                jsonGen.writeStringField(c,'');
            }
        }    
    	jsonGen.writeNumberField('limit_size',MAX_LIMIT);
		jsonGen.writeStringField('offset','0');
		jsonGen.writeEndObject();
		
		if(!commentList.isEmpty()){
			jsonGen.writeFieldName('comment_information');
			jsonGen.writeStartArray();
			for(Core_IPS_Case_Comments__c c : commentList){
				jsonGen.writeStartObject();
                if(c.Core_IPS_Case__r.CaseNumber!=null && c.Core_IPS_Case__r.CaseNumber!='')
				    jsonGen.writeStringField('case_number',c.Core_IPS_Case__r.CaseNumber);
                else
                    jsonGen.writeStringField('case_number','');
                
                if(c.Core_IPS_Case__r.core_Account_Name__c!=null && c.Core_IPS_Case__r.core_Account_Name__c!='')
                	jsonGen.writeStringField('account_name',c.Core_IPS_Case__r.core_Account_Name__c);
                else
                    jsonGen.writeStringField('account_name','');
                
                if(c.Core_IPS_Case__r.Core_Contact_Name__c!=null && c.Core_IPS_Case__r.Core_Contact_Name__c!='')
                	jsonGen.writeStringField('contact_name',c.Core_IPS_Case__r.Core_Contact_Name__c);
                else
                    jsonGen.writeStringField('contact_name','');
                
                if(c.Core_IPS_Case__r.Core_IPS_Product_name__c!=null && c.Core_IPS_Case__r.Core_IPS_Product_name__c!='')
                	jsonGen.writeStringField('product_name',c.Core_IPS_Case__r.Core_IPS_Product_name__c);
                else
                    jsonGen.writeStringField('product_name','');
                
                if(c.Name!=null && c.Name!='')
					jsonGen.writeStringField('comment_name',c.Name);
                else
                    jsonGen.writeStringField('comment_name','');
                
                
                if(c.Core_IPS_Rich_Comment__c!=null && c.Core_IPS_Rich_Comment__c!='')
				   jsonGen.writeStringField('comment_text',c.Core_IPS_Rich_Comment__c);
                else
                   jsonGen.writeStringField('comment_text',''); 
                
                if(c.Core_IPS_Case_Comment_Type__c!=null && c.Core_IPS_Case_Comment_Type__c!='')
					jsonGen.writeStringField('comment_type',c.Core_IPS_Case_Comment_Type__c);
                else
                    jsonGen.writeStringField('comment_type','');
                
                if(c.Core_IPS_Case_Comment_Source__c!=null && c.Core_IPS_Case_Comment_Source__c!='')
					jsonGen.writeStringField('case_comment_source',c.Core_IPS_Case_Comment_Source__c);
                else
                    jsonGen.writeStringField('case_comment_source','');
                
                /*if(c.CreatedById!=null && c.CreatedById!='')
					jsonGen.writeStringField('created_by_id',c.CreatedById);
                else
                    jsonGen.writeStringField('created_by_id','');
                
                if(c.CreatedBy_Name__c!=null && c.CreatedBy_Name__c!='')
					jsonGen.writeStringField('created_by_name',c.CreatedBy_Name__c);
                else
                    jsonGen.writeStringField('created_by_name','');*/
                
				//jsonGen.writeStringField('created_date',c.CreatedDate);
				/*if(c.Core_IPS_Comment_Authored_By__c!=null && c.Core_IPS_Comment_Authored_By__c!='')
					jsonGen.writeStringField('author_by_id',c.Core_IPS_Comment_Authored_By__c);
                else
                    jsonGen.writeStringField('author_by_id','');
                
                if(c.Core_IPS_Comment_Authored_By_Name__c!=null && c.Core_IPS_Comment_Authored_By_Name__c!='')
					jsonGen.writeStringField('author_by_name',c.Core_IPS_Comment_Authored_By_Name__c);
                else
                    jsonGen.writeStringField('author_by_name','');
                
               if(c.Core_IPS_Comment_Authored_By_Email__c!=null && c.Core_IPS_Comment_Authored_By_Email__c!='')
					jsonGen.writeStringField('author_by_email',c.Core_IPS_Comment_Authored_By_Email__c);
                else
                    jsonGen.writeStringField('author_by_email','');
                
                if(c.Core_IPS_Comment_Author_Type__c!=null && c.Core_IPS_Comment_Author_Type__c!='')
					jsonGen.writeStringField('author_type',c.Core_IPS_Comment_Author_Type__c);
                else
                    jsonGen.writeStringField('author_type','');*/
                
				jsonGen.writeEndObject();
			}
        	jsonGen.writeEndArray();
    	}
        
    	jsonGen.writeEndObject();
    	jsonData = jsonGen.getAsString();
            
        System.debug('Json Data - ' + jsonData);
    	return jsonData;  
                                        
    }    

}