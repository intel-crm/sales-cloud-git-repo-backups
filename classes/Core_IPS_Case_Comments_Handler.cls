/***************************************************************************************************
Class Name:  Core_IPS_Case_Comments_Handler
Class Type: Handler Class 
Test Class : Core_IPS_Case_Comments_Test
Version     : 1.0 
Created Date: 17 Nov 2015
Function    : This class contains utility 
Input Parameters: None 
Output Parameters: None
Description:   Used in case RTF(Comments) creation
Used in     : Case RTF Creation
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        11/17/2015              Created
* Brian Matthews             04/21/2016              Updated "UpdateCaseField" for public / private comments
* Brian Matthews             07/22/2016              Customer sub status in Waiting For updates NRDD
* Sumukh                     21/09/2017              Modifeid- Added for New Latest Case Comment fields for comments email notification 
* Sumukh                     15/09/2018              Defect fix for SLA DE36888 
* Sumukh                     23/18/2018              Added logic for US188756  
* Sumukh                     22/11/2018              Added logic for US209204 - Iteration I- 21 
* Aparna           26/3/2019         Added future method for US309857-i06
* Sneha                      04/04/2019              Defect fix for DE35586 Milestone is getting satisfied for customer's comment and next milestone is getting triggered
* Ranjini                   27/8/2019               Modified assignPublicComment method for DE26263
* Ganapati                  12/11/2019              Modified for DE59265 - IPS - Name of the commenter does not show up in the IPS notification
* Sumukh                    08/10/2020              Modified for US782446 - Case 'Last Comment Submitter' should match the actual Comment Author
****************************************************************************************************/   
public without sharing class Core_IPS_Case_Comments_Handler{
    
    static final String LAST_COMMENT_TO_CASE_TEXT   = 'LastCommentToCase';
    static final String INVESTIGATING_TEXT          = 'Investigating';
    static final String POWER_CUSTOMER_SUCCESS_TEXT = 'PowerCustomerSuccess';
    static final String REQUESTING_TEXT             = 'Requesting';
    static final String WAITING_FOR_TEXT            = 'Waiting for';
    static final String CLOSE_PENDING_TEXT         = 'Close-Pending';
    /* Start -- DE111600 --- 16-06-21 --- Prem Ranjan --- code fix for Case closure issue */ 
    static final String CLOSED_TEXT                 = 'Closed';
    /* End -- DE111600 --- 16-06-21 --- Prem Ranjan --- code fix for Case closure issue */ 
    //public Static String Extprof =  System.Label.Core_IPS_External_Customer_Profile_Ids;
    //public Static String PartnerProf = System.Label.Core_IPS_Partner_Profile_Id;
    //public Static boolean ExtUser = String.valueOf(System.Label.Core_IPS_External_Customer_Profile_Ids).contains(String.valueOf(userInfo.getProfileId().substring(0,15)));              
    //public Static boolean PartUser = PartnerProf.contains(String.valueOf(userInfo.getProfileId().substring(0,15)));
    
    /***************************************************************************************************
Method Name:  replaceFormatting
Method Type: Case RTF Handler Method 
Version     : 1.0 
Created Date: 17 Nov 2015
Function    : This method is used to populate the Plain Text field by removing 
formatting and replacing the same with Plain text.
Input Parameters: Trigger.New List
Output Parameters: None
Description:   This method takes a list of records in Trigger.New and each records Plain Text field 
and is updated by passing the rich Text data to Helper Utility methods
Used in: Case RTF Rich to Plain Text Conversion
Number of Queries Within this Method: 0
Number of Queries in Loop: 0 
Number of Queries from Called methods:  0
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK              11/17/2015              Created
****************************************************************************************************/  
    public static void replaceFormatting(List<Core_IPS_Case_Comments__c> newList){
        if(newList <> null && newList.size()>0){
            for(Core_IPS_Case_Comments__c rtf: newList){
                if(rtf.Core_IPS_Rich_Comment__c <> null ){
                    
                    rtf.Core_IPS_Comment__c = Core_Utility.substituteHTMLTags(rtf.Core_IPS_Rich_Comment__c);//replaceHtmlTags
                    if(rtf.Core_IPS_Comment__c <> null){
                        rtf.Core_IPS_Comment__c = Core_Utility.stripandunescapeHtmlTags(rtf.Core_IPS_Comment__c);//replaceSpecialChar
                    }
                }
                
            }
        }
    }
    
    
    /***************************************************************************************************
Method Name:  sendComment
Method Type: 
Version     : 1.0 
Created Date: 14 Aug 2020
Function    : This method is used to send the JSON to backend system
Input Parameters: Trigger.New List  */
    
    public static void sendComment(List<Core_IPS_Case_Comments__c> caseComments){
        //Added by farooq
        try{
            List<Core_IPS_Case_Comments__c> caseCommentsList =new List<Core_IPS_Case_Comments__c>();
            List<Core_IPS_Case_Comments__c> caseCommentsListDisconnect =new List<Core_IPS_Case_Comments__c>();
            List<Id> caseIds = new List<Id>();
            for(Core_IPS_Case_Comments__c commentVar: caseComments){
                caseIds.add(commentVar.Core_IPS_Case__c);
            }
            //FLS Check Added - Madhuri
            List<Case> cases;
            Core_IPS_Backend_System2__c backendData;
            string backendSystemId;
           Boolean isBackendSystemActive;
            Map<Id,Boolean> backendCaseMap = new Map<Id, Boolean>();
            if(Case.SObjectType.getDescribe().isAccessible()){
                cases = [SELECT Id,Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c,Core_IPS_BackendID__c, Core_IPS_BES_Promote_Status__c,Core_IPS_New_Backend_System__c from case WHERE Id IN:caseIds];
            }
            for(Core_IPS_Case_Comments__c commentVar : caseComments) {
               // if(commentVar.core_IPS_Comment_Authored_By_Name__c != 'Backend Integration User IPS'  && !commentVar.Core_IPS_Rich_Comment__c.contains('Customer Closed in IPS') && !commentVar.Core_IPS_Rich_Comment__c.contains(Label.Core_IPS_BES_Private_Comment)) {
               //if(commentVar.Core_IPS_Comment_Author_Type__c != 'Backend Integration'  && !commentVar.Core_IPS_Rich_Comment__c.contains('Customer Closed in IPS') && !commentVar.Core_IPS_Rich_Comment__c.contains(Label.Core_IPS_BES_Private_Comment)) { //Pavani 06-03-2024 TWC745-5671
                if((commentVar.Core_IPS_Comment_Author_Type__c != 'Backend Integration' || (commentVar.Core_IPS_Comment_Author_Type__c == 'Backend Integration' && commentVar.Core_IPS_Comment_Attachment_Id__c!=null))  && !commentVar.Core_IPS_Rich_Comment__c.contains('Customer Closed in IPS') && !commentVar.Core_IPS_Rich_Comment__c.contains(Label.Core_IPS_BES_Private_Comment)) { //Pavani 31-07-2024
                    for(case caseId: cases){
                        //Ajith added this logic to restrict to create Outbound messages, when Backend system is deactivated
                        if(caseId.Core_IPS_BackendID__c!=null && caseId.Core_IPS_New_Backend_System__c!=null && caseId.Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c==false){
                            caseCommentsList.add(commentVar);
                        }
                        //backendCaseMap.put(caseId.Id,caseId.Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c);
                    }
                }
                //Ajith added this logic to restrict to create Outbound messages, when Backend system is deactivated
                //if(commentVar.Core_IPS_Rich_Comment__c.contains(Label.Core_IPS_BES_Private_Comment) && backendCaseMap.get(commentVar.Core_IPS_Case__c) == false){
                if(commentVar.Core_IPS_Rich_Comment__c.contains(Label.Core_IPS_BES_Private_Comment)){   
                caseCommentsListDisconnect.add(commentVar);
                }
            }
            if(caseCommentsList.size()>0){
                Core_IPS_BES_OutboundMessage.createPlatformEventHSD(caseCommentsList, false); 
            }
            if(caseCommentsListDisconnect.size()>0){
                Core_IPS_BES_OutboundMessage.createPlatformEventHSD(caseCommentsListDisconnect, true); 
            }
        }catch(Exception e){
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join(caseComments,','));
        }
    } 
    /**************************************************************************************************
Method Name:  replaceFormatting
Method Type: Case RTF Handler Method 
Version     : 1.0 
Created Date: 17 Nov 2015
Function    : This method is used to populate the Plain Text field by removing 
formatting and replacing the same with Plain text.
Input Parameters: Trigger.New List
Output Parameters: None
Description:   This method takes a list of records in Trigger.New and each records Plain Text field 
and is updated by passing the rich Text data to Helper Utility methods
Used in: Case RTF Rich to Plain Text Conversion

Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:  0
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK              11/17/2015              Created
****************************************************************************************************/
   
    public static void rerenderRTF(List<Core_IPS_Case_Comments__c> newList){
       
            if(newList <> null && newList.size()>0){
                List<Core_IPS_Case_Comments__c> caseRTFList=new List<Core_IPS_Case_Comments__c>();
                List<Core_IPS_Case_Comments__c> caseRTFs = new List<Core_IPS_Case_Comments__c>();
                if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isQueryable()){
                 //  Added by Chiru - 20-08-24 - APEX GURU - SOQL FIX
		          Map<Id, Core_IPS_Case_Comments__c> newListMap = new Map<Id, Core_IPS_Case_Comments__c>(newList);
                    //FLS Added as Part of code refactor
                    if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){
                    caseRTFList = [Select id,Core_IPS_Rich_Comment__c from Core_IPS_Case_Comments__c where id IN: newListMap.keySet()];
                    }
                        for(Core_IPS_Case_Comments__c rtf: CaseRTFList){
                        if(RTF.Core_IPS_Rich_Comment__c <> null){
                            RTF.Core_IPS_Rich_Comment__c = Core_Utility.addBreaktags(RTF.Core_IPS_Rich_Comment__c);
                            CaseRTFs.add(RTF);
                        }
                    }
                }
                if(CaseRTFs <> null && CaseRTFs.size()>0){
                    Core_IPS_Case_Comments_Dispatcher.isUpdated = true;
                }    
                //FLS Added as Part of code refactor
                if(Schema.sObjectType.Core_IPS_Case_Comments__c.isUpdateable()){
                update CaseRTFs;
                }
            }
        
    }
    
    
    /***************************************************************************************************
Method Name:  UpdateCaseField
Method Type: Case RTF Handler Method 
Version     : 1.0 
Created Date: 18 Nov 2015
Function    : This method is used to update the RTF field on Case to send email updates to the respective Case Team Members
Input Parameters: Trigger.New List
Output Parameters: None
Description:   This method takes a list of records in Trigger.New and copies the Rich Text field content to the RTF field on Case
Used in     : Case and Case RTF
Number of Queries Within this Method: 3
Number of Queries in Loop: 0
Number of Queries from Called methods:  0
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        11/18/2015              Created
* JRK                        11/25/2015              Modified- Added logic to update case field when public is true
* Brian Matthews             04/21/2016              Modified- Added logic for public and private comment updates
* Abhishek Arya              04/25/2016              Modified- Added null check before assigning the value @ Line 158,171.
* Sumukh                     21/09/2017              Modifeid- Added for New Latest Case Comment fields for comments email notification 
* Sumukh                     15/09/2018              Defect fix for SLA DE36888
* Sumukh                     20/05/2018              Modified by Sumukh added logic for B2B API Comments . US - 97657, I-11, PSG Release 4.3 
* Sumukh                     01/06/2018              Modified by Sumukh added logic for Comment source . US- 105428, I-12 , PSG Release 4.3
* Sumukh                     09/08/2019              Modefied by sumukh for DE31732 - Milestones gets updated when Sales Reps make 'Private to Intel' Comments
****************************************************************************************************/
    //This method might not be needed during data load.
    
    public static void updateCaseField(List<Core_IPS_Case_Comments__c> newList){
        Profile pfrl;
        Map<Id, Case> mapCases;
        if(newList == null || newList.size() == 0){
            return;
        }    
        // added by chiru
        Set<Id> UserIds = new Set<Id>();
        //END
        SET<Id> setCases = new SET<Id>();        
        for(Core_IPS_Case_Comments__c cc: newList) {
            if (setCases.contains(cc.Core_IPS_Case__c) == False){
                setCases.add(cc.Core_IPS_Case__c);
            }    
            // added by chiru code refactor 1709
            UserIds.add(cc.CreatedById);
            UserIds.add(cc.LastModifiedById);
            if(String.IsNotBlank(cc.Core_IPS_Comment_Authored_By__c)){
               UserIds.add(cc.Core_IPS_Comment_Authored_By__c);
            }
            // END
        }
        
        if (setCases.size() == 0) {
            return;
        }
           // addded by chiru
         Map<Id,User> userInfoMap = new  Map<Id,User>();
         if(UserIds != null && !UserIds.isEmpty()){
      
         userInfoMap = new Map<Id,User>([select id,profile.name, profileid, name ,Firstname,Email from user where id in:UserIds]);
        // END
         }
        // Need BusinessHoursId so that "milestoneutils.getSetNextResponseDueDate(cs)" can function properly.
        //FLS Check Added - Madhuri
        if(Case.SObjectType.getDescribe().isAccessible()){
            mapCases = new Map<Id, Case>([SELECT id, BusinessHoursId, Core_First_Response_Completed__c, Core_Next_Response_Due_Date__c, Status, Core_Sub_Status__c,
                                          Core_Last_Case_Comment__c,Core_Last_Agent_Case_Comment__c,Core_Last_Agent_Case_Comment_Submitter__c,Core_Last_Agent_Comment_Time_Stamp__c, Core_Last_Case_Comment_Submitter__c, Core_Last_Case_Comment_Timestamp__c,
                                          Core_Last_Private_Case_Comment__c, Core_Last_Private_Case_Comment_Submitter__c, Core_Last_Private_Case_Comment_Timestamp__c  ,
                                          Core_Latest_Case_Comment_Type__c, Core_Latest_Comment_Time_Stamp__c , Core_Latest_Case_Comment__c, Core_Latest_Comment_Submitter__c ,RecordType.Name,Core_IPS_Customer_Visible__c, Core_IPS_Product_Org_Number__c, Priority                                                        
                                          FROM Case 
                                          WHERE id IN :setCases]);
        }
        
        if (mapCases == null || mapCases.size() == 0) {
            return;            
        }         
        
        List<Case> lstCasesToUpdate = new List<Case>();
        String queriedCaseData = JSON.serialize(mapCases);
        if(Profile.SObjectType.getDescribe().isQueryable()){
            pfrl = [SELECT name 
                    FROM Profile 
                    WHERE id=:userInfo.getProfileId()];
        }
        
        
        Set<string> profileNameSet = new Set<String>();        
        profileNameSet.addAll(Label.Core_IPS_Agent_Admin_Profile_Names.split(','));
        
        //Added by Prem US80224 case sub status to investigating
        Set<string> externalprofileNameSet = new Set<String>();        
        ExternalprofileNameSet.addAll(Label.Core_IPS_External_Profile_Names.split(', '));
        
        SET<Id> setCreatedByIds = new SET<Id>();        
        
        set<Id> authoredByUser = new Set<Id>();                             // Added by Sumukh for B2B API comments 
        Map<id,User> userMap= new Map<id,User>();                           // Added by Sumukh for B2B API comments    
        
        for(Core_IPS_Case_Comments__c cc: newList) {
            
            setCreatedByIds.add(cc.createdbyid);
            if(cc.Core_IPS_Comment_Authored_By__c!=null){               // Added by Sumukh for B2B API comments 
                authoredByUser.add(cc.Core_IPS_Comment_Authored_By__c); // Added by Sumukh for B2B API comments             
            }                                                            // Added by Sumukh for B2B API comments          
        }
        
        // Added by Sumukh for B2B API comments 
        
            if((authoredByUser.size()>0 || setCreatedByIds.size()>0) &&  userInfoMap != null && userInfoMap.size()>0){            
           // userMap= new Map<id,User>([select id,profile.name, profileid, name ,Firstname,Email from user where id in :authoredByUser OR id in :setCreatedByIds]);
           // Added by chiru
              userMap = userInfoMap;
           // END
            }
        
        
        
        // end by Sumukh for B2B API comments 
        
        Map<ID,String> userProfile=new Map<Id,String>();
       // Commented by chiru       
       /* List<User> listUser=[select id,profile.name from user where id in :setCreatedByIds];
              
        for(User usr: listUser){ 
            userProfile.put(usr.id,usr.profile.name);           
        }*/
        //added by chiru
        for(Id value : setCreatedByIds){
            if(value != null){
            User u = userInfoMap.get(value);
            userProfile.put(u.Id,u.Profile.Name);
            }
        }
          
        //End
        Set<string> subStatusSet = new Set<String>();
        
        subStatusSet.addAll(Label.Core_IPS_Substatus_Set.split(','));
        
        Map<String, Core_IPS_Feature_Toggle__c> mapFeatureEnabled = Core_IPS_Feature_Toggle__c.getAll();                
        
        //[04/25/2016 : Abhishek Arya : START : Added null check before assigning the value.]
        Boolean commentToCaseEnabled = false;
        if(mapFeatureEnabled <> null && mapFeatureEnabled.size() > 0 && mapFeatureEnabled.get(LAST_COMMENT_TO_CASE_TEXT) <> null && mapFeatureEnabled.get(LAST_COMMENT_TO_CASE_TEXT).Core_Feature_Enabled__c <> null){
            commentToCaseEnabled = mapFeatureEnabled.get(LAST_COMMENT_TO_CASE_TEXT).Core_Feature_Enabled__c;
        }   
        //[04/25/2016 : Abhishek Arya : END]
        
        SET<Id> setUpdateCases = new SET<Id>();    
        
        Boolean isPortalUser = isCurrentUserPortalUser();
        
        Case cs;
        //US286852:External email notifications to include submitter of new comments -Ayesha -Start         
        String submitterFname;
        Set<Id> userIdSet = new Set<Id>();
        Map<Id, User> usrFnameMap = new Map<Id, User>();
        for(Core_IPS_Case_Comments__c caseComment : newlist) {
            userIdSet.add(caseComment.LastModifiedById);
        }
        if(!userIdSet.isEmpty()) {
            //commented by Chiru
           // usrFnameMap = new Map<Id, User>([SELECT FirstName FROM User WHERE Id IN :userIdSet]);
           // Added by chiru
           usrFnameMap = UserInfomap;
        }
        //US286852:External email notifications to include submitter of new comments -Ayesha -End    
        
        // Added by sumukh for US97567 - B2B API 
        if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isQueryable()){
            
            
            List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();  
            //FLS Check Added - Madhuri
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){
                // Apex guru Fix
                Map<Id, Core_IPS_Case_Comments__c> newListMap = new Map<Id, Core_IPS_Case_Comments__c>();
                if(newList != null && newList.size()>0){
                   newListMap = new Map<Id, Core_IPS_Case_Comments__c>(newList);
                }
                commentList = [select id, CreatedBy_FirstName__c, name,Core_IPS_Comment_Authored_By__c,Core_IPS_Comment_Attachment_Id__c ,Core_IPS_Comment_Attachment_Id__r.Core_IPS_Attachment_Source__c,Core_IPS_Comment_Author_Type__c ,Core_IPS_Comment_Authored_By_Email__c  , Core_IPS_Comment_Authored_By_FirstName__c  , Core_IPS_Comment_Authored_By_Name__c , CreatedByid, Core_IPS_Case_Comment_ID__c, CreatedBy_Name__c, CreatedBy.Email,CreatedBy.Profileid, Core_IPS_Case_Comment_Source__c from Core_IPS_Case_Comments__c where id in :newListMap.Keyset() ];
            }

            /* Kalyani -- Removed Nested for loop and used seperate loops instead, for better performance */
            /* Start -- DE111600 --- 16-06-21 --- Prem Ranjan --- code fix for Case closure issue */  
            if(commentList!=null && commentList.size()>0){
            /* End -- DE111600 --- 16-06-21 --- Prem Ranjan --- code fix for Case closure issue */      
      
                for(Core_IPS_Case_Comments__c caseCmnt : commentList ){                   
                        if(caseCmnt.Core_IPS_Comment_Authored_By__c==null && caseCmnt.Core_IPS_Comment_Author_Type__c !=Core_IPS_Labels__c.getValues('Backend Integration').value__c || caseCmnt.Core_IPS_Comment_Authored_By__c==null && caseCmnt.Core_IPS_Comment_Author_Type__c ==Core_IPS_Labels__c.getValues('Backend Integration').value__c){
                        if(Schema.SObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Authored_By__c.isUpdateable()){
                            caseCmnt.Core_IPS_Comment_Authored_By__c = caseCmnt.createdbyid;    
                        }
                    }
                    
                    if(caseCmnt.Core_IPS_Comment_Authored_By__c!=null && userMap.get(caseCmnt.Core_IPS_Comment_Authored_By__c)!=null && caseCmnt.Core_IPS_Comment_Author_Type__c !=Core_IPS_Labels__c.getValues('Backend Integration').value__c){
                        if(Schema.SObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Authored_By_Email__c.isUpdateable()){
                            caseCmnt.Core_IPS_Comment_Authored_By_Email__c = userMap.get(caseCmnt.Core_IPS_Comment_Authored_By__c).Email;
                        }
                        
                        //if(Schema.SObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Authored_By_FirstName__c.isUpdateable()){
                            caseCmnt.Core_IPS_Comment_Authored_By_FirstName__c = userMap.get(caseCmnt.Core_IPS_Comment_Authored_By__c).FirstName;
                        //}
                        if(Schema.SObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Authored_By_Name__c.isUpdateable()){
                            caseCmnt.Core_IPS_Comment_Authored_By_Name__c = userMap.get(caseCmnt.Core_IPS_Comment_Authored_By__c).name;
                        }
                        
                        if(Label.Core_IPS_External_Lenovo_Customer_Profile_Id.contains(userMap.get(caseCmnt.Core_IPS_Comment_Authored_By__c).profileid)){
                            if(Schema.SObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Author_Type__c.isUpdateable()){
                                caseCmnt.Core_IPS_Comment_Author_Type__c = Core_IPS_Labels__c.getValues('Customer').value__c;                     
                            }
                        } 
                    }
                    
                    // Added for US-105428 by sumukh 
                    if (caseCmnt.Core_IPS_Case_Comment_Source__c!=Core_IPS_Labels__c.getValues('Comment Source - Email').value__c ){  // && (caseCmnt.Core_IPS_Case_Comment_Source__c!= 'B2B API'
                        if(caseCmnt.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Backend Integration').value__c){
                            caseCmnt.Core_IPS_Case_Comment_Source__c = Core_IPS_Labels__c.getValues('Comment Source - Backend System').value__c;
                        }
                        else if(caseCmnt.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Data Migration').value__c){
                            caseCmnt.Core_IPS_Case_Comment_Source__c = Core_IPS_Labels__c.getValues('Comment Source - Data Migration').value__c;
                        }
                        else if(caseCmnt.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Agent').value__c || caseCmnt.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('FAE').value__c ){
                            caseCmnt.Core_IPS_Case_Comment_Source__c = Core_IPS_Labels__c.getValues('Comment Source - Internal').value__c;
                        }
                        else if(caseCmnt.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Customer').value__c || caseCmnt.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Partner - DFAE').value__c || caseCmnt.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Partner - Agent').value__c || caseCmnt.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Partner').value__c){
                            caseCmnt.Core_IPS_Case_Comment_Source__c = Core_IPS_Labels__c.getValues('Comment Source - Customer').value__c;
                        }
                        else{
                            caseCmnt.Core_IPS_Case_Comment_Source__c = Core_IPS_Labels__c.getValues('Comment Source - N/A').value__c;
                        }
                    } 
                    // End for US-105428 by sumukh                    
                } 
            } 

            for(Core_IPS_Case_Comments__c caseComment : newlist) {
                submitterFname='';
                if(!usrFnameMap.isEmpty() && usrFnameMap.containskey(caseComment.LastModifiedById)){
                    submitterFname = usrFnameMap.get(caseComment.LastModifiedById).FirstName;
                }
                cs = mapCases.get(caseComment.Core_IPS_Case__c); 
                if (cs == NULL){
                    continue;
                }                
                
                if (caseComment.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c) {
                    
                    if (commentToCaseEnabled){
                        assignPublicComment(cs, caseComment, submitterFname);       //US286852
                        assignLatestComment(cs, caseComment, submitterFname);       //US286852 
                        if(Schema.SObjectType.Case.fields.Core_Latest_Case_Comment_Type__c.isUpdateable()){
                        	cs.Core_Latest_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
                        }
                    }
                    
                   // Added for SLA Management
                    // Required step to trigger next response after first response.
                    //
                    // -Comment is public
                    // -Comment did not come from the community
                    
                    // Defect-DE36888 fix for Attachments case comment 3/9/18
                    if (caseComment.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c  && caseComment.Core_IPS_Comment_Attachment_Id__c ==null &&
                        (caseComment.Core_IPS_Comment_Author_Type__c!='Customer' && caseComment.Core_IPS_Comment_Author_Type__c!='Partner' && caseComment.Core_IPS_Comment_Author_Type__c!='Backend Integration'))                  
                    {   
                        if(!cs.Core_First_Response_Completed__c && userInfo.getUserType() != POWER_CUSTOMER_SUCCESS_TEXT){
                        //TWC745-5592-FLS update added -Gangadhar -29/02/2024
                        if(Schema.SObjectType.Case.fields.Core_First_Response_Completed__c.isUpdateable()){  // FLS Added By Chiru - Code Refactor
                            cs.Core_First_Response_Completed__c=true;                
                        }    
                        }    
                      if(Schema.SObjectType.Case.fields.Core_Next_Response_Due_Date__c.isUpdateable()){ 
                        cs.Core_Next_Response_Due_Date__c = milestoneutils.getSetNextResponseDueDate(cs);
                      }
                     }
                    
                    if (Schema.SObjectType.Case.fields.Core_Next_Response_Due_Date__c.isUpdateable() && isPortalUser && !String.isBlank(cs.Core_Sub_Status__c) && (cs.Core_Sub_Status__c.contains(WAITING_FOR_TEXT))) {
                        cs.Core_Next_Response_Due_Date__c = milestoneutils.getSetNextResponseDueDate(cs);
                    }
                    
                    if (cs.Status == 'New' && caseComment.Core_IPS_Comment_Author_Type__c == Core_IPS_Helper_Utility.getIPSLabel('Agent')/*profileNameSet.contains(pfrl.Name)*/){ //modified by amritesh - DE36908 - 3/9/2018
                        cs.Status = 'Open';
                        cs.Core_Sub_Status__c = INVESTIGATING_TEXT;
                    }
                    
                    //for(Core_IPS_Case_Comments__c RTF: newList){
                    if(caseComment.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Customer').value__c || caseComment.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Partner').value__c || caseComment.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Partner - DFAE').value__c){
                        if(subStatusSet.contains(cs.Core_Sub_Status__c) && caseComment.Core_IPS_Comment_Attachment_Id__c == null){
                            cs.Core_Sub_Status__c = INVESTIGATING_TEXT;
                        }
                    }
                    // added by sumukh for US782446 on 08/10/20
                    if(caseComment.Core_IPS_Case_Comment_Source__c == Core_IPS_Labels__c.getValues('Comment Source - Email').value__c){
                        cs.Core_Last_Case_Comment_Submitter__c = caseComment.createdbyid;
                    } 
                    //end by sumukh for US782446                                         
                } 
                
                // added fr case comment for US67633 by sumukh
                else if(caseComment.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c){
                    if (commentToCaseEnabled) {
                        assignPrivateComment(cs, caseComment, submitterFname);      //US286852
                    }    
                    assignLatestComment(cs, caseComment, submitterFname);           //US286852
                    cs.Core_Latest_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;                 
                    
                    // Start added by sumukh for US188756     
                    if( cs.Core_IPS_Customer_Visible__c == false && caseComment.Core_IPS_Comment_Attachment_Id__c == null && (caseComment.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Agent').value__c || caseComment.Core_IPS_Comment_Author_Type__c ==Core_IPS_Labels__c.getValues('Partner - Agent').value__c) ||
                       (cs.RecordType.Name == Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact' ) && caseComment.Core_IPS_Comment_Attachment_Id__c == null && (caseComment.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Agent').value__c || caseComment.Core_IPS_Comment_Author_Type__c ==Core_IPS_Labels__c.getValues('Partner - Agent').value__c))) // added logic for US193654 by Sumukh
                    {                  
                        if(!cs.Core_First_Response_Completed__c && userInfo.getUserType() != POWER_CUSTOMER_SUCCESS_TEXT) {
                            cs.Core_First_Response_Completed__c=true;                
                        }    
                        
                        cs.Core_Next_Response_Due_Date__c = milestoneutils.getSetNextResponseDueDate(cs);
                    }
                    // End by sumukh for US188756 
                    
                    //Change Added by sumukh for US209204
                    
                    if (cs.Status == 'New' && (cs.RecordType.Name == Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact' ) ||  cs.Core_IPS_Customer_Visible__c == false) && caseComment.Core_IPS_Comment_Attachment_Id__c == null && (caseComment.Core_IPS_Comment_Author_Type__c == Core_IPS_Helper_Utility.getIPSLabel('Agent') ||  caseComment.Core_IPS_Comment_Author_Type__c ==Core_IPS_Labels__c.getValues('Partner - Agent').value__c) ){ 
                        //FLS Check Added - Madhuri
                        if(Schema.SObjectType.Case.fields.Status.isUpdateable()){
                        	cs.Status = 'Open';
                        }
                        cs.Core_Sub_Status__c = INVESTIGATING_TEXT;
                    } 
                    //End by sumukh for US209204
                    
                } 
                else if(caseComment.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PRIVATE_TO_AGENTS').value__c){
                    if (commentToCaseEnabled) {
                        assignLatestComment(cs, caseComment, submitterFname);       //US286852
                    }    
                    cs.Core_Latest_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PRIVATE_TO_AGENTS').value__c;
                }
                
                // Added by sumukh for partner comments changes R4 - I8
                
                else if(caseComment.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c){
                    if (commentToCaseEnabled) {
                        assignLatestComment(cs, caseComment, submitterFname);       //US286852
                    }    
                    cs.Core_Latest_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;
                } 
                
                
                if (setUpdateCases.contains(cs.Id) == False) {
                    setUpdateCases.add(cs.Id);
                    lstCasesToUpdate.add(cs);
                }    
            }
            
            //Ended Seperating loops here
            
            try{
                if (Core_IPS_Case_Comments__c.SObjectType.getDescribe().isUpdateable()){
                    update commentList;  
                }
                
            }
            Catch(Exception e){
            }  
            // End for US97657 by sumukh
        }
        if (lstCasesToUpdate.size() > 0) {
            
            //Aparna-US309857-i06-Commented update statement and included logic in future method
            //update lstCasesToUpdate;
            string caserecords=JSON.serialize(lstCasesToUpdate);
            if(!string.isblank(caserecords)){
                //updateCaseinFuture(caserecords);
                if(!System.isFuture() && !System.isBatch()) {
                	updateCaseinFutureChangedDataOnly(caserecords, queriedCaseData);
                }
                //START - Shipra
                else if(System.isBatch()) {
                   System.enqueueJob(new Core_IPS_CaseUpdate_Queueable(caserecords,queriedCaseData));
                }
               // END - Shipra
            }
            //end for US309857-i06
            
        }            
    }
    //US286852: added submitterFirstName - Ayesha
    private static void assignPublicComment(Case soCase, Core_IPS_Case_Comments__c caseComment, String submitterFirstName) {
        if (soCase.Core_Last_Case_Comment_Timestamp__c == NULL || caseComment.LastModifiedDate == NULL ||
            (soCase.Core_Last_Case_Comment_Timestamp__c < caseComment.LastModifiedDate)) {
                
                //added the removeimagetag on the public case comment field on 5/18 related to the defect# DE19814 
                if (caseComment.Core_IPS_Rich_Comment__c != NULL){
                }
                
                soCase.Core_Last_Case_Comment__c= Core_Utility.removeImageTag(caseComment.Core_IPS_Rich_Comment__c);
                //soCase.Core_Last_Case_Comment_Submitter__c = caseComment.LastModifiedById;
                soCase.Core_IPS_Submitter_First_Name__c = submitterFirstName;       //US286852
                soCase.Core_Last_Case_Comment_Timestamp__c = Datetime.Now();
                //Added by ranjini
                if(soCase.Core_Last_Case_Comment_Submitter__c !=null){
                    if(UserInfo.getUserId()!= soCase.Core_Last_Case_Comment_Submitter__c){
                        soCase.Core_Last_Case_Comment_Submitter__c = UserInfo.getUserId();
                    }
                } else {  
                    soCase.Core_Last_Case_Comment_Submitter__c = caseComment.LastModifiedById; // Added by Ganapati for DE59265
                }
            }
    }
    
    //US286852: added submitterFirstName - Ayesha
    private static void assignPrivateComment(Case soCase, Core_IPS_Case_Comments__c caseComment, String submitterFirstName) {
        if (soCase.Core_Last_Private_Case_Comment_Timestamp__c == NULL || caseComment.LastModifiedDate == NULL ||
            (soCase.Core_Last_Private_Case_Comment_Timestamp__c < caseComment.LastModifiedDate)) {
                
                //added the removeimagetag on the public case comment field on 5/18 related to the defect# DE19814 
                soCase.Core_Last_Private_Case_Comment__c           = Core_Utility.removeImageTag(caseComment.Core_IPS_Rich_Comment__c);
                soCase.Core_Last_Private_Case_Comment_Submitter__c = caseComment.LastModifiedById;
                soCase.Core_IPS_Submitter_First_Name__c = submitterFirstName;       //US286852
                soCase.Core_Last_Private_Case_Comment_Timestamp__c = Datetime.Now();
            }
    }     
    // added by sumukh for case comment email notofication comment fields
    //US286852: added submitterFirstName - Ayesha
    private static void assignLatestComment(Case soCase, Core_IPS_Case_Comments__c caseComment1, String submitterFirstName) {
        if (soCase.Core_Latest_Comment_Time_Stamp__c== NULL || caseComment1.LastModifiedDate == NULL ||
            (soCase.Core_Latest_Comment_Time_Stamp__c < caseComment1.LastModifiedDate)) {
                
                
                soCase.Core_Latest_Case_Comment__c= Core_Utility.removeImageTag(caseComment1.Core_IPS_Rich_Comment__c);
                soCase.Core_Latest_Comment_Submitter__c= caseComment1.LastModifiedById;
                soCase.Core_IPS_Submitter_First_Name__c = submitterFirstName;       //US286852
                soCase.Core_Latest_Comment_Time_Stamp__c= Datetime.Now();
            }
    }
    
    // end by sumukh for notification
    
    /***************************************************************************************************
Method Name:  UpdateCaseField
Method Type: Case RTF Handler Method 
Version     : 1.0 
Created Date: 18 Nov 2015
Function    : This method is used to update the RTF field on Case to send email updates to the respective Case Team Members
Input Parameters: Trigger.New List
Output Parameters: None
Description:   This method takes a list of records in Trigger.New and copies the Rich Text field content to the RTF field on Case
Used in     : Case and Case RTF
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods:  0
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                        11/01/2015              Created
*Sumukh                      21/10/2018              Changes done for SLA for comment type
****************************************************************************************************/
    public static string userid;
    public static List<Profile> lstProfile;
    
    
    
    public static Boolean isIntegrationUser(string strUserId){            
        if(Userid==null || UserId !=strUserId ){
            LstProfile =  new List<Profile>([select id,name from Profile where id = : Userinfo.getProfileId() and name =: 'Integration']); 
            UserId = strUserId;
            if( LstProfile.size() > 0 ){
                return true;        
            }        
        }
        else if(UserId == strUserId && LstProfile.size() > 0){
            return true;
        }
        else{
            return false;
        }
        return false;              
    }
    
    
    public static boolean isCurrentUserPortalUser() {
       User u;
        
             Id uId = UserInfo.getUserId();
         if(User.SObjectType.getDescribe().isQueryable()){
             u = [select Id, IsPortalEnabled from user where id = :uId limit 1];
           
        }
         return u.IsPortalEnabled;
    } 
    
    public static void completeActiveMileStone(List<Core_IPS_Case_Comments__c> newList) {
        
        set<Id> csSetids = new set<id>();     // added by sumukh for US188756
        
        // added by sumukh for US193654       
        SET<Id> setCases = new SET<Id>();        
        for(Core_IPS_Case_Comments__c ccm: newList) {        
            setCases.add(ccm.Core_IPS_Case__c);
        }               
        if (setCases.size() == 0){
            return;           
        }    
        Map<Id, Case> mapCases = new Map<Id, Case>([SELECT id,RecordType.Name,Core_IPS_Customer_Visible__c                                                       
                                                    FROM Case 
                                                    WHERE id IN :setCases]); 
        
        // end by sumukh for US193654
        
        List<Case> caseList=  new List<Case>();     
        Set<Id> caseIds = new Set<Id>();             
        for (Core_IPS_Case_Comments__c cc : newList){
            
            // Start added by sumukh for US188756      
            if(cc.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c && (cc.Core_IPS_Comment_Attachment_Id__c == null) && (cc.Core_IPS_Comment_Author_Type__c== Core_IPS_Labels__c.getValues('Agent').value__c || cc.Core_IPS_Comment_Author_Type__c ==Core_IPS_Labels__c.getValues('Partner - Agent').value__c)){                                                 
                csSetids.add(cc.Core_IPS_Case__c);            
            }
            
            // END by sumukh for US188756    // START added by Sneha for DE35586             
            
            // Modefied by sumukh for DE31732 
            if((cc.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c && cc.Core_IPS_Comment_Attachment_Id__c == null && cc.Core_IPS_Comment_Author_Type__c != Core_IPS_Labels__c.getValues('Customer').value__c && cc.Core_IPS_Comment_Author_Type__c != Core_IPS_Labels__c.getValues('Partner').value__c) || (mapCases.get(cc.Core_IPS_Case__c).RecordType.Name == Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact')  && cc.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c && cc.Core_IPS_Comment_Author_Type__c != Core_IPS_Labels__c.getValues('FAE').value__c) && (cc.Core_IPS_Comment_Attachment_Id__c == null)) { // added logic for US193654 by Sumukh
                caseIds.add(cc.Core_IPS_Case__c);
            }     
        }
        // END added by Sneha for DE35586
        
        if (caseIds.isEmpty() && csSetids.isEmpty() ) {
            return;
        }
       
        if(Case.SObjectType.getDescribe().isQueryable()||CaseMilestone.SObjectType.getDescribe().isQueryable()){
              caseList = [SELECT Id, ContactId, Contact.Email, OwnerId, Core_Trigger_Next_Response__c, Status, EntitlementId, 
                    Core_Next_Response_Due_Date__c, Core_First_Response_Completed__c, SlaStartDate, SlaExitDate
                    FROM Case   
                    WHERE Id IN :caseIds OR ( Id IN :csSetids AND Core_IPS_Customer_Visible__c = false )]; // Added changes by sumukh for US188756
            
        
        DateTime completionDate = System.now();
        
        Set<Id> updateCaseIds = new Set<Id>();
        for(Case cs:caseList) { 
            if (milestoneUtils.isCaseMilestoneUpdateRequired(cs, completionDate)){
                if (!updateCaseIds.contains(cs.id)) {
                    updateCaseIds.add(cs.id);
                }    
            }
        }
             List<CaseMilestone> activeMilestoneList = [SELECT Id, completionDate
                                                   FROM CaseMilestone 
                                                   WHERE caseId IN :updateCaseIds
                                                   AND completionDate = NULL];
        
        for(CaseMilestone cm : activeMilestoneList) {
            cm.completionDate = completionDate;
        }    
        
        Database.update(activeMilestoneList, false);
        }
      
        
       
        
    }
    
    /***************************************************************************************************
Method Name:  updateCaseinFuture
Method Type: Future Method 
Version     : 1.0 
Created Date: 26/3/2019
Function    : This method inserts comments on case using a future call.This enables users to add comment even if case team memebers are nil
Input Parameters: Trigger.New List
Output Parameters: None
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:  0
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Aparna           26/3/2019        Added for US309857-i06
****************************************************************************************************/
    @future
    public static void updateCaseinFuture(String strcaseList){
        List<Case> newCaseList = (List<Case>)JSON.deserialize(strcaseList, List<Case>.class);
        if(newCaseList.size()>0){
            database.update(newCaseList); 
        }
    }
    //end--
    //
    /***************************************************************************************************
Method Name:  updateCaseinFutureChangedDataOnly
Method Type: Future Method 
Version     : 1.0 
Created Date: 25/08/2020 
Function    : This method inserts comments on case using a future call.This enables users to add comment even if case team memebers are nil
Input Parameters: Trigger.New List
Output Parameters: None
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:  0
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Prem           25/08/2020        Added for US767216
****************************************************************************************************/
    @future
    public static void updateCaseinFutureChangedDataOnly(String strcaseList, String strcaseMap){
        Map<Id, Case> caseListMap = new Map<Id, Case>((List<case>)JSON.deserialize(strcaseList, List<Case>.class));
        Map<Id, Case> caseMap = (Map<Id, Case>)JSON.deserialize(strcaseMap, Map<Id, Case>.class);
        /* Start -- DE111600 --- 16-06-21 --- Prem Ranjan --- code fix for Case closure issue */ 
        Map<Id, Case> caseMapupdated = new Map<Id, Case> ([Select id,status from case where id In :caseListMap.keyset()]);
        /* End -- DE111600 --- 16-06-21 --- Prem Ranjan --- code fix for Case closure issue */ 
        List<case> finalCasetoUpdate = new List<case>();
        for(Sobject cs : caseListMap.values()){
            Map<String, Object> fieldsToValue = cs.getPopulatedFieldsAsMap();
            case caseSobject = new case();
            caseSobject.put('id', cs.Id);
            for(String queriedField: fieldsToValue.keySet()){
                try{
                 
                    /* Start -- DE111600 --- 16-06-21 --- Prem Ranjan --- code fix for Case closure issue */ 
                    if(cs.get(queriedField) != caseMap.get(cs.id).get(queriedField) ){
                        
                        if( queriedField =='Core_Sub_Status__c' && caseMapupdated.get(cs.id).get('status') ==CLOSED_TEXT){
                            continue;
                        }
                        if( queriedField =='Status' && caseMapupdated.get(cs.id).get('status') ==CLOSED_TEXT){
                            continue;
                        }
                        
                     /* End -- DE111600 --- 16-06-21 --- Prem Ranjan --- code fix for Case closure issue */    
                        caseSobject.put(queriedField, cs.get(queriedField));
                    }
                    
                }catch(Exception e){
                }
            }
           finalCasetoUpdate.add(caseSobject);
            
        } 
        // New FLS Fix Applied - 07/10/24
        if(Case.SObjectType.getDescribe().isUpdateAble()){
        database.update(finalCasetoUpdate);
        }
    }
    //end--
}