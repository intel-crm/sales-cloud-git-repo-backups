public class Core_FeedbackController {
    @AuraEnabled
    public static initWrapper getQuestions (){
        initWrapper iW = new initWrapper();
        iw.objs = new List<String>();
        try{
            iW.aaq = [Select Name, Core_Profile_Url__c,Core_Active__c, Core_Description__c,Core_Description2__c,Core_Profile_Image__c,Core_Order__c FROM Core_AAQ_Profile_Handler__c where Core_Active__c=true ORDER BY Core_Order__c ];
            List<Core_Custom_Feedback_MD__mdt> cfMD = [select Core_Process_Name__c, Core_Object_Name__c from Core_Custom_Feedback_MD__mdt where Core_Active__c = true ];
            for(Core_Custom_Feedback_MD__mdt md :cfMD){
                iW.objs.add(md.Core_Process_Name__c);
            }
        }
        catch(exception e){
            system.debug('exception'+e);
            System.debug('I am at line ' + String.valueOf(e.getLineNumber())); 
            
        }
        system.debug('wrappr-->'+iW);
    	return iW;
    }
    
    @AuraEnabled
    public static void saveFeedbackUtil (String rating,String areaOfFeedback, String comments) {
        try{
            Core_Custom_Feedback__c cf = new Core_Custom_Feedback__c();
            cf.Core_Comments__c = comments;
            cf.Core_Area_Of_Feedback__c = areaOfFeedback;
            cf.Core_Rating__c = rating;
            cf.Core_User__c = userinfo.getuserID();
        	insert cf;
        }
        catch(exception e){
            system.debug('exception'+e);
            System.debug('I am at line ' + String.valueOf(e.getLineNumber())); 
            
        }
        
    }
    
    @AuraEnabled
    public static void saveFeedbackPopUp (Id recordId,String rating, String comments) {
        try{
            Core_Custom_Feedback__c cf = new Core_Custom_Feedback__c();
            cf.Core_Comments__c = comments;
            cf.Core_Area_Of_Feedback__c = recordId.getSObjectType().getDescribe().getName()+' Management';
            cf.Core_Rating__c = rating;
            cf.Core_User__c = userinfo.getuserID();
            cf.Core_Feedback_Record_Id__c = recordId;
            cf.Core_Skipped_Feedback__c = false;
            
            insert cf;
    	}
        catch(exception e){
            system.debug('exception'+e);
            System.debug('I am at line ' + String.valueOf(e.getLineNumber())); 
            
        }
    }
    
    
    @AuraEnabled (cacheable=true)
    public static innerWrapper saveFeedbackFromRecordLevel(Id recordId) {
        innerWrapper inWr = new innerWrapper();
        inWr.check= false;
        system.debug('recordID-->'+recordId);
        try{
            String filter ='';
            boolean isconverted = false;
            //DateTime dt = System.now(); 
            //DateTime adjustedDt = dt.addSeconds(-10);
            String sObjName = recordId.getSObjectType().getDescribe().getName();
            //query md
            List<Core_Custom_Feedback_MD__mdt> cfMD = [select MasterLabel, Core_Skipped_Feedback_Elapsed_Days__c, Core_Header_Message_Positive__c, Core_Header_Message_Negative__c, Core_Elapsed_Days__c, Core_Filtering_Field__c, Core_Object_Name__c, Core_Value__c from Core_Custom_Feedback_MD__mdt where Core_Object_Name__c =:sObjName and Core_Active__c = true ];
        	
            String query = 'Select id, LastModifiedByid,'+cfMD[0].Core_Filtering_Field__c + ' from '+cfMD[0].Core_Object_Name__c+' where id =:recordId limit 1';
            sobject sobj = database.query(query);
            //String queryHistory = 'Select id,OldValue, NewValue from '+cfMD[0].Core_Object_Name__c+'History'+' where '+cfMD[0].Core_Object_Name__c+'id =:recordId Order by createddate desc limit 1';
			//sobject sobjHistory = database.query(queryHistory);
            //if(sobjHistory != null){
            string [] value = cfMD[0].Core_Value__c.split(',');
            if(value.contains(String.valueof(sobj.get(cfMD[0].Core_Filtering_Field__c)))){
                //if(value.contains(String.valueof(sobjHistory.get('NewValue')))){
                    system.debug('inside filter if');
                    String userId = String.valueOf(userinfo.getuserid()).substring(0, 15);
                    system.debug('userId-'+userId);
                    List<Core_Custom_Feedback__c> customFeedbackList = [select id,Core_Skipped_Feedback__c, Core_Elapsed_Days__c from Core_Custom_Feedback__c where Core_User__c =:userId order by createddate desc limit 1];
                    system.debug('fd-'+customFeedbackList);
                    if(customFeedbackList.size()>0){
                        if(customFeedbackList[0].Core_Elapsed_Days__c > cfMD[0].Core_Elapsed_Days__c){
                            inWr.check = true;
                            inWr.objName = sObjName;
                            inWr.userValue = userId;
                            inWr.feedbackrecId = recordId;
                            inWr.headerMessage = cfMD[0].Core_Header_Message_Positive__c;
                        }
                        system.debug('check--'+customFeedbackList[0].Core_Skipped_Feedback__c);
                        system.debug('el days--'+customFeedbackList[0].Core_Elapsed_Days__c);
                        system.debug('metadata days--'+cfMD[0].Core_Skipped_Feedback_Elapsed_Days__c);
                        if(customFeedbackList[0].Core_Skipped_Feedback__c && customFeedbackList[0].Core_Elapsed_Days__c > cfMD[0].Core_Skipped_Feedback_Elapsed_Days__c){
                            system.debug('negative scene');
                            inWr.check = true;
                            inWr.objName = sObjName;
                            inWr.userValue = userId;
                            inWr.feedbackrecId = recordId;
                            inWr.headerMessage = cfMD[0].Core_Header_Message_Positive__c;
                        }
                    }
                    else if(sobj.get('LastModifiedByid') == userId){
                        system.debug('same user');
                        inWr.check = true;
                        inWr.objName = sObjName;
                        inWr.userValue = userId;
                        inWr.feedbackrecId = recordId;
                        inWr.headerMessage = cfMD[0].Core_Header_Message_Positive__c;
                    }
            	//}
            }
        //}
        
        }
        catch(exception e){
            system.debug('exception'+e);
            System.debug('I am at line ' + String.valueOf(e.getLineNumber())); 
            
        }
        system.debug('return wrapper'+inwr);
        return inWr;
            
    }
    
    @AuraEnabled
    public static void skipFeedback(Id recordId) {
        try{
			Core_Custom_Feedback__c cf = new Core_Custom_Feedback__c();
            cf.Core_Comments__c = '';
            cf.Core_Area_Of_Feedback__c = recordId.getSObjectType().getDescribe().getName();
            cf.Core_Rating__c = '';
            cf.Core_User__c = userinfo.getuserID();
            cf.Core_Feedback_Record_Id__c = recordId;
            cf.Core_Skipped_Feedback__c = true;
            
            insert cf;
        }
        catch(exception e){
            system.debug('exception'+e);
            System.debug('I am at line ' + String.valueOf(e.getLineNumber())); 
            
        }
    }
    
    
    public class initWrapper{
        @AuraEnabled
        public List<Core_AAQ_Profile_Handler__c> aaq{get;set;}
        
        @AuraEnabled
        public List<String> objs{get;set;}
    }
    public class innerWrapper{
        @AuraEnabled
        public boolean check{get;set;}
        
        @AuraEnabled
        public String objName{get;set;}
        
        @AuraEnabled
        public String userValue{get;set;}
        
        @AuraEnabled
        public String feedbackrecId{get;set;}
        
        @AuraEnabled
        public String headerMessage{get;set;}
    }
}