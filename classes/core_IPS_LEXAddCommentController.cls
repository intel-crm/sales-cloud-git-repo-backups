public with sharing class core_IPS_LEXAddCommentController {
     
    public static Case newCase;
    public static Boolean userHasAccess = Label.Core_IPS_Agent_Profiles.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));
    public static List<Core_IPS_Case_Comments__c> cmtResults {get;set;}
    public static List<Core_IPS_Case_Comments__c> searchCmt {get;set;}
    public static String partnerType;
    public static String prtDFAE = System.Label.Core_IPS_Partner_DFAE_Permission_Set;
    public static String sOAPermSetID = System.Label.Core_IPS_SupportOrgAdmin_Permission_Set;
    public static List<PermissionSetAssignment> partDFAEUser; 
    public static string selectedRadioButton;  
    public static String extprof = System.Label.Core_IPS_External_Customer_Profile_Ids;
    public static Boolean partnerUser = Label.Core_Partner_Profile_Id.contains(String.valueOf(userInfo.getProfileId().substring(0, 15))); 
    public static Boolean partnerAgentUser  =  Label.Core_IPS_Agent_Partner_Profile_id.contains(String.valueOf(userInfo.getProfileId().substring(0, 15))); 
    public static List<PermissionSetAssignment> sOAUser;
    public static Boolean isNACCase = false;
    public static Boolean extUser = extprof.contains(String.valueOf(userInfo.getProfileId().substring(0,15)));
    public static String profileName = System.Label.Core_IPS_Profile_Name;
    public static String userid = system.UserInfo.getUserId();
    public static String partnerProf  = System.Label.Core_IPS_Partner_Profile_Id;
    public static boolean externalUser = Network.getNetWorkid()!= null? true:false;
    
    public core_IPS_LEXAddCommentController(String recordId) {
        try{       
            //if(PermissionSetAssignment.SObjectType.getDescribe().isQueryable()){          
                partDFAEUser  = [Select id,AssigneeId  from PermissionSetAssignment where AssigneeId =: userInfo.getUserId() and PermissionSetId =:prtDFAE LIMIT 1]; 
            //}
            //if(PermissionSetAssignment.SObjectType.getDescribe().isQueryable()){          
                sOAUser = [Select id,AssigneeId  from PermissionSetAssignment where AssigneeId =: userInfo.getUserId() and PermissionSetId =:SOAPermSetID LIMIT 1];
            //}
        } catch(Exception e) {
        }
        if(recordId !=null){
            if(Case.SObjectType.getDescribe().isQueryable()){          
                newCase=[select id,subject,Core_IPS_Comment__c,RecordType.Name,AccountId,Core_Sub_Status__c,status,CreatedBy.Email,contactid,Core_IPS_Date_Time_Close_Pending__c from Case where id =:recordId ];       
            }        
        }
        if(newCase.RecordType.Name == Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact')){         
            isNACCase=true;
        }    
        if(userHasAccess != null && userHasAccess == false && sOAUser !=null && sOAUser.size()>0) { 
            userHasAccess = true; 
        }  
    }
    //START - US943880 - 4/12/21 - Chandrashekar  - Used to return values to component based on which case comment options are rendered.
    public class OptionsWrapper {
        @AuraEnabled public Boolean extUser;
        @AuraEnabled public String partnerType;
        @AuraEnabled public List<PermissionSetAssignment> partDFAEUser; 
        @AuraEnabled public Boolean externalUser;
        @AuraEnabled public Boolean partnerAgentUser;
        @AuraEnabled public Boolean userHasAccess;
        @AuraEnabled public Boolean isNACCase;
    }
    @AuraEnabled(cacheable = true)
    public static String getRequiredValues(String recordId){
         core_IPS_LEXAddCommentController obj1 = new core_IPS_LEXAddCommentController(recordId);
         OptionsWrapper obj = new OptionsWrapper();
         obj.extUser = extUser;
         obj.partnerType = partnerType;
         obj.partDFAEUser = partDFAEUser;
         obj.externalUser = externalUser;
         obj.partnerAgentUser = partnerAgentUser;
         obj.userHasAccess = userHasAccess;
         obj.isNACCase = isNACCase;
         return JSON.serialize(obj); 
    }
    //END - US943880

    //determine partnerType
    public static String getPartnerType(){
        if(partnerProf.contains(String.valueOf(userinfo.getProfileId()).substring(0,15))){                      
            String authrPartnerType= Core_Utility.getPartnerUserType(userinfo.getuserid());           
            
            
            if(authrPartnerType != null){
                if(authrPartnerType.split(';').size()>0) {               
                    partnerType = authrPartnerType.split(';')[0];  
                }               
            }    
            if(partnerType !=null && String.isNotBlank(partnerType)){                
                if(partnerType == 'Partner - DFAE'){
                    selectedRadioButton = Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;                  
                }
                else if(partnerType == 'Partner'){
                    selectedRadioButton = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
                }
            }
        }
        return selectedRadioButton;
    }
    //Identifies and Maps the logged in User with Author Type
    public static String getAuthr(String loggedUserId,String userid){
        String authroTyp='';
        
        if(Label.Core_IPS_External_Customer_Profile_Ids.contains(loggedUserId.substring(0,15))){
            return authroTyp=Core_IPS_Labels__c.getValues('Customer').value__c;         
        } 
        else if(label.Core_IPS_DataOps.contains(loggedUserId.substring(0,15))){           
            String dataOpsAuthrType = '';                     
            dataOpsAuthrType = Core_Utility.isSupOrgAdmPermUser(Userid.substring(0,15));         
            if(dataOpsAuthrType !=null && String.isNotBlank(dataOpsAuthrType )){           
                return authroTyp = dataOpsAuthrType ; }                               
        }    
        else if(Label.Core_IPS_SalesRep_ProfileIds.contains(loggedUserId.substring(0,15))){
            return authroTyp=Core_IPS_Labels__c.getValues('FAE').value__c;
        }
        else if(Label.Core_IPS_Agent_Profiles.contains(loggedUserId.substring(0,15) )){
            return authroTyp=Core_IPS_Labels__c.getValues('Agent').value__c;
        }
        else if(Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(userid) == true){ //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
            return authroTyp=Core_IPS_Labels__c.getValues('Data Migration').value__c;
        }
        else if(Label.Core_Integration_Profile_Id.contains(loggedUserId.substring(0,15))){
            return authroTyp=Core_IPS_Labels__c.getValues('Backend Integration').value__c;
        }
        else if(Label.Core_IPS_Agent_Partner_Profile_id.contains(loggedUserId.substring(0,15))){
            return authroTyp=Core_IPS_Labels__c.getValues('Partner - Agent').value__c;
        }        
        else if(Label.Core_Partner_Profile_Id.contains(loggedUserId.substring(0,15))){
            
            String partnerAuthrType = '';
            String partnerType1;                      
            partnerAuthrType  = Core_Utility.getPartnerUserType(Userid.substring(0,15));
            
            if(partnerAuthrType!=null){
                if(partnerAuthrType.split(';').size()>0){
                    partnerType1 = partnerAuthrType.split(';')[0];
                }
            }
            if(partnerType1 !=null && String.isNotBlank(partnerType1 )){
                return authroTyp= partnerType1 ;
            }else{
                return authroTyp=Core_IPS_Labels__c.getValues('Partner').value__c;
            }
        } 
        return null;        
    }
    
    @AuraEnabled
    public static List<Id> saveComment(String newcaseJSON ){
        list<id> newCommentId = new list<id>();
        CaseWrapper caseWrapperObj = (CaseWrapper) JSON.deserialize(newcaseJSON, CaseWrapper.class);
        case newCase = new case();
        if( caseWrapperObj.closedPending !=''&& caseWrapperObj.closedPending !=null){
            newCase.Core_IPS_Date_Time_Close_Pending__c = date.valueOf(caseWrapperObj.closedPending); 
        }
        if(caseWrapperObj.caseComment!=''&& caseWrapperObj.caseComment!=null){
            newCase.Core_IPS_Comment__c = caseWrapperObj.caseComment;
        }
        if(caseWrapperObj.casesubststus!=''&& caseWrapperObj.casesubststus!=null){
            newCase.Core_Sub_Status__c = caseWrapperObj.casesubststus;
        }
        if(caseWrapperObj.caseid!=''&& caseWrapperObj.caseid!=null){
            newCase.id = caseWrapperObj.caseid;
        }
        caseWrapperObj.selectedRadioButton = (getPartnerType()!=null && getPartnerType()!='') ? getPartnerType() : caseWrapperObj.selectedRadioButton;
        Case cs = new Case();
        if(newCase != null && newcase.Core_Sub_Status__c != Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Close_Pending_SubStatus') && newCase.Core_IPS_Date_Time_Close_Pending__c != null
            && caseWrapperObj.selectedRadioButton == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c && (System.Label.Core_IPS_Agent_Profile_Ids.Contains(String.valueOf(userInfo.getprofileId()).substring(0, 15)) 
            || System.Label.Core_IPS_DataOps.contains(String.valueOf(userInfo.getprofileId()).substring(0, 15)))) {
                if(Schema.sObjectType.Case.fields.Core_IPS_Date_Time_Close_Pending__c.isUpdateable()){
                    cs.Core_IPS_Date_Time_Close_Pending__c = null;
                }
            cs.Id = newCase.Id;
        }
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
        Core_IPS_Case_Attachments__c newAttachment = new Core_IPS_Case_Attachments__c();              
        if(partnerType =='Partner'){               
            caseWrapperObj.selectedRadioButton = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;     
        } 
        //if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case__c.isCreateable()) {
            newComment.Core_IPS_Case__c = newCase.id; 
        //}
        //FLS Check for security vulnerability -Gangadhar- 14-09-2022
        if(Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Rich_Comment__c.isCreateable()) {
        	newComment.Core_IPS_Rich_Comment__c = newCase.Core_IPS_Comment__c;   
        }    
        if( caseWrapperObj.selectedRadioButton!=null ){         
            if(partnerUser){
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
               /*Start -- Tushar -- 12/05/2026 --- CRUD Added as part of vulnerability fix. */ 
                if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case_Comment_Type__c.isCreateable()) {
                    newComment.Core_IPS_Case_Comment_Type__c = caseWrapperObj.selectedRadioButton;   
                }
                /*End -- Tushar -- 12/05/2026 --- added as part of vulnerability fix. */
            } else if(!(externalUser) || (partnerAgentUser)){   
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
               // if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case_Comment_Type__c.isCreateable()) {
                    newComment.Core_IPS_Case_Comment_Type__c = caseWrapperObj.selectedRadioButton; 
               // }
            }
            else {
                newComment.Core_IPS_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
            }
            if(newComment.Core_IPS_Comment_Attachment_Id__c!=null){
                newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId(), newAttachment.Core_FileUploadedBy__c);
            }
            else if(newComment.Core_IPS_Comment_Attachment_Id__c==null){
                newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId(), userinfo.getuserid());
            }
            try{
                if(newComment!=null){       
                    insert newComment;
                    newCommentId.add(newComment.id);
                    if(cs.Id != null){  
                        update cs; 
                    }
                    return newCommentId;
                }
            }
            catch(Exception e){
                return null;
            }
        } 
        return newCommentId;
    }
    public class CaseWrapper{
        public String casesubststus{get;set;}
        public String caseComment{get;set;}
        public String closedPending{get;set;}
        public String caseid{get;set;}
        public String selectedRadioButton{get;set;}
    }
    @AuraEnabled
    public static List<Core_IPS_Case_Comments__c> search(String str, Id caseRec) {
        //userhasAccess = true;
        String temp = str.trim();
        //if(Case.SObjectType.getDescribe().isQueryable()){
            newCase=[select id,subject,Core_IPS_Comment__c,RecordType.Name,AccountId,Core_Sub_Status__c,status,CreatedBy.Email,contactid,Core_IPS_Date_Time_Close_Pending__c from Case where id =: caseRec ];
        //}
        cmtResults=new List<Core_IPS_Case_Comments__c>();
        
        if(partnerAgentUser || userhasAccess) { 
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isQueryable()){        
                cmtResults= [select id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Name,Core_IPS_Comment__c,CreatedBy.Account.Name,Core_IPS_Rich_Comment__c,CreatedBy.Contact.Account.name,CreatedBy.Profile.Name,CreatedBy.Firstname,CreatedBy.Profileid,
                         CreatedDate,Core_IPS_BgColor__c,Core_IPS_NickName__c,CreatedBy_Name__c,
                         Core_IPS_Case_Comment_Type__c ,CreatedBy.Email,Core_IPS_Comment_Author_Type__c,Core_IPS_Comment_Authored_By__r.Name,Core_IPS_Comment_Authored_By__r.Account.name,Core_IPS_Comment_Authored_By_Email__c,Core_IPS_Comment_Authored_By_FirstName__c,Core_IPS_Comment_Authored_By_Name__c
                         from Core_IPS_Case_Comments__c 
                         where Core_IPS_Case__c=:newCase.id 
                         ORDER BY CreatedDate DESC NULLS LAST ];  
            }       
        }        
        else if(!(ExternalUser) || (partnerAgentUser)){  
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isQueryable()){        
             cmtResults = [select id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Name,CreatedBy.Account.Name,Core_IPS_Comment__c,
                          Core_IPS_Rich_Comment__c,CreatedBy.Profile.Name,CreatedDate,CreatedBy.Firstname,CreatedBy.Profileid,
                          Core_IPS_BgColor__c,CreatedBy.Email, CreatedBy.Contact.Account.Name,CreatedBy_Name__c,
                          Core_IPS_Case_Comment_Type__c,Core_IPS_Comment_Author_Type__c,Core_IPS_Case__r.Contact.Account.name,Core_IPS_Comment_Authored_By__c,
                          Core_IPS_Comment_Authored_By_Email__c,Core_IPS_Comment_Authored_By_FirstName__c,Core_IPS_Comment_Authored_By_Name__c,Core_IPS_Comment_Authored_By__r.Account.name   
                          from Core_IPS_Case_Comments__c 
                          where Core_IPS_Case__c=:newCase.id  AND (Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c OR Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c OR Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c)
                          ORDER BY CreatedDate DESC NULLS LAST ];
            }
        } else if(partnerProf.contains(String.valueOf(userinfo.getProfileId()).substring(0,15))&& partnerType != 'Partner'){
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isQueryable()){        
             cmtResults = [select id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Name,CreatedBy.Account.Name,Core_IPS_Comment__c,
                          Core_IPS_Rich_Comment__c,CreatedBy.Profile.Name,CreatedDate,CreatedBy.Firstname,CreatedBy.Profileid,
                          Core_IPS_BgColor__c,CreatedBy.Email, CreatedBy.Contact.Account.Name,CreatedBy_Name__c,
                          Core_IPS_Case_Comment_Type__c,Core_IPS_Comment_Author_Type__c,Core_IPS_Case__r.Contact.Account.name,Core_IPS_Comment_Authored_By__c,
                          Core_IPS_Comment_Authored_By_Email__c,Core_IPS_Comment_Authored_By_FirstName__c,Core_IPS_Comment_Authored_By_Name__c,Core_IPS_Comment_Authored_By__r.Account.name   
                          from Core_IPS_Case_Comments__c 
                          where Core_IPS_Case__c=:newCase.id and (Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c OR Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c)  
                          ORDER BY CreatedDate DESC NULLS LAST
                         ];
            }
        }else{
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isQueryable()){        
             cmtResults = [select id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Name,CreatedBy.Account.Name,Core_IPS_Comment__c,
                          Core_IPS_Rich_Comment__c,CreatedBy.Profile.Name,CreatedDate,CreatedBy.Firstname,CreatedBy.Profileid,
                          Core_IPS_BgColor__c,CreatedBy.Email, CreatedBy.Contact.Account.Name,CreatedBy_Name__c,
                          Core_IPS_Case_Comment_Type__c,Core_IPS_Comment_Author_Type__c,Core_IPS_Case__r.Contact.Account.name,Core_IPS_Comment_Authored_By__c,
                          Core_IPS_Comment_Authored_By_Email__c,Core_IPS_Comment_Authored_By_FirstName__c,Core_IPS_Comment_Authored_By_Name__c,Core_IPS_Comment_Authored_By__r.Account.name   
                          from Core_IPS_Case_Comments__c 
                          where Core_IPS_Case__c=:newCase.id and Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c 
                          ORDER BY CreatedDate DESC NULLS LAST
                         ];
            }
        }  
        searchCmt = new List<Core_IPS_Case_Comments__c>();
        try{
            if(cmtResults!=null && cmtResults.size()>0 && !String.isBlank(str))
            {
                for(Core_IPS_Case_Comments__c objCmt : cmtResults)
                {
                    if(objCmt.Core_IPS_Comment__c != Null && objCmt.Core_IPS_Comment__c.containsIgnoreCase(temp)){
                        searchCmt.add(objCmt);
                    }
                }
            }
            //searched=true;
        }catch(Exception ex){
        }
        return searchCmt;
    }
    @AuraEnabled
    public static void clear() {
        try{ 
            if(searchCmt != null) {
                searchCmt.clear();
            }
        } catch(Exception e) {
        }
    }
    // == To display fieldset in case details
      @AuraEnabled(cacheable = true)
    public static List<FieldSetField> getFieldSetFieldsByFieldSetName(String objectApiName, String fieldSetName, String recordId)
    {
        List<Schema.FieldSetMember> fieldSetMembers = ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
        //Equal to: 
        List<FieldSetField> fields = new List<FieldSetField>();
        List<fieldSetMember> fieldApiList = new List<fieldSetMember>();
        List<String> fieldString = new List<String>();
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers){
            fieldApiList.add(fieldSetMember);
            fieldString.add(fieldSetMember.getFieldPath()); 
        }
        String query = 'SELECT '+String.escapeSingleQuotes(String.join(fieldString,','))+ ' From ' +String.escapeSingleQuotes(objectApiName)+ ' WHERE ID =:recordId';
        List<sObject> caseList = Database.query(query);
        for(fieldSetMember feildName: fieldApiList){
           
            fields.add(new FieldSetField(feildName.getLabel(), caseList[0].get(feildName.getFieldPath())));
           
        }
        
        return fields;
    } 
    public class FieldSetField
    {
       
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public Object value{get;set;}
        
        public FieldSetField(String label, Object value)
        {

            this.label = label;
            this.value = value;
            
        }
    }
    /*Start -- Tushar -- 12/05/2026 --- CRUD Added as part of vulnerability fix. */
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Case_Comments__c> getCaseCommentsForLWC(String caseId) {
        
        if (String.isBlank(caseId)) {
            return new List<Core_IPS_Case_Comments__c>();
        }
        
        if (!Schema.sObjectType.Core_IPS_Case_Comments__c.isAccessible()) {
            return new List<Core_IPS_Case_Comments__c>();
        }
        List<Core_IPS_Case_Comments__c> lstComment = [
            SELECT Id,
            CreatedBy.Name,
            CreatedBy.Email,
            Core_IPS_Case__c,
            Core_IPS_Comment_Authored_By_Email__c,
            Core_IPS_Comment__c,
            Core_IPS_Rich_Comment__c,
            Core_IPS_Comment_Authored_By_Name__c,
            Core_IPS_Case_Comment_Type__c,
            Core_IPS_Comment_Author_Type__c,
            CreatedDate
            FROM Core_IPS_Case_Comments__c
            WHERE Core_IPS_Case__c = :caseId
            ORDER BY CreatedDate DESC
            
        ];
        return lstComment;
    }
	/*END -- Tushar -- 12/05/2026 --- CRUD Added as part of vulnerability fix. */
}