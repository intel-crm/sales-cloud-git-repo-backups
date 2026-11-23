/***************************************************************************************************
Class Name:  Core_IPS_Case_Comments_Handler
Class Type: Handler Class 
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
* Sneha  					 04/04/2019              Defect fix for DE35586 Milestone is getting satisfied for customer's comment and next milestone is getting triggered
****************************************************************************************************/   
public class Core_IPS_Case_Comments_Handler{
    
    static final String LAST_COMMENT_TO_CASE_TEXT   = 'LastCommentToCase';
    static final String INVESTIGATING_TEXT          = 'Investigating';
    static final String POWER_CUSTOMER_SUCCESS_TEXT = 'PowerCustomerSuccess';
    static final String REQUESTING_TEXT             = 'Requesting';
    static final String WAITING_FOR_TEXT            = 'Waiting for';
    static final String CLOSE_PENDING_TEXT         = 'Close-Pending';
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
            for(Core_IPS_Case_Comments__c RTF: newList){
                if(RTF.Core_IPS_Rich_Comment__c <> null){
                    system.debug('Rich Desc*****'+RTF.Core_IPS_Rich_Comment__c );
                    RTF.Core_IPS_Comment__c = Core_Utility.substituteHTMLTags(RTF.Core_IPS_Rich_Comment__c);//replaceHtmlTags
                    if(RTF.Core_IPS_Comment__c <> null)
                        RTF.Core_IPS_Comment__c = Core_Utility.stripandunescapeHtmlTags(RTF.Core_IPS_Comment__c);//replaceSpecialChar
                    system.debug('Plain Desc*****'+RTF.Core_IPS_Comment__c);
                }
                
            }
        }
    }
    
    
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
    public static void RerenderRTF(List<Core_IPS_Case_Comments__c> newList){
        if(newList <> null && newList.size()>0){
            List<Core_IPS_Case_Comments__c> CaseRTFs = new List<Core_IPS_Case_Comments__c>();
            List<Core_IPS_Case_Comments__c> CaseRTFList = [Select id,Core_IPS_Rich_Comment__c from Core_IPS_Case_Comments__c where id IN: newList];
            for(Core_IPS_Case_Comments__c RTF: CaseRTFList){
                if(RTF.Core_IPS_Rich_Comment__c <> null){
                    RTF.Core_IPS_Rich_Comment__c = Core_Utility.addBreaktags(RTF.Core_IPS_Rich_Comment__c);
                    CaseRTFs.add(RTF);
                }
            }
            if(CaseRTFs <> null && CaseRTFs.size()>0)
                Core_IPS_Case_Comments_Dispatcher.isUpdated = true;
            update CaseRTFs;
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
****************************************************************************************************/
    //This method might not be needed during data load.
    public static void UpdateCaseField(List<Core_IPS_Case_Comments__c> newList){
        
        if(newList == null || newList.size() == 0)
            return;
        
        
        System.debug('#01 UpdateCaseField - newList: ' + newList);
        
        SET<Id> setCases = new SET<Id>();        
        for(Core_IPS_Case_Comments__c cc: newList) {
            if (setCases.contains(cc.Core_IPS_Case__c) == False)
                setCases.add(cc.Core_IPS_Case__c);
        }
        
        if (setCases.size() == 0) 
            return;
        
        
        // Need BusinessHoursId so that "milestoneutils.getSetNextResponseDueDate(cs)" can function properly.
        //
        Map<Id, Case> mapCases = new Map<Id, Case>([SELECT id, BusinessHoursId, Core_First_Response_Completed__c, Core_Next_Response_Due_Date__c, Status, Core_Sub_Status__c,
                                                    Core_Last_Case_Comment__c,Core_Last_Agent_Case_Comment__c,Core_Last_Agent_Case_Comment_Submitter__c,Core_Last_Agent_Comment_Time_Stamp__c, Core_Last_Case_Comment_Submitter__c, Core_Last_Case_Comment_Timestamp__c,
                                                    Core_Last_Private_Case_Comment__c, Core_Last_Private_Case_Comment_Submitter__c, Core_Last_Private_Case_Comment_Timestamp__c  ,
                                                    Core_Latest_Case_Comment_Type__c, Core_Latest_Comment_Time_Stamp__c , Core_Latest_Case_Comment__c, Core_Latest_Comment_Submitter__c ,RecordType.Name,Core_IPS_Customer_Visible__c                                                       
                                                    FROM Case 
                                                    WHERE id IN :setCases]);
        
        if (mapCases == null || mapCases.size() == 0) 
            return;            
        
        
        List<Case> lstCasesToUpdate = new List<Case>();
        
        Profile pfrl = [SELECT name 
                        FROM Profile 
                        WHERE id=:userInfo.getProfileId()];
        
        Set<string> profileNameSet = new Set<String>();        
        profileNameSet.addAll(Label.Core_IPS_Agent_Admin_Profile_Names.split(','));
        System.debug('#01 profileNameSet: ' + profileNameSet);    
        
        //Added by Prem US80224 case sub status to investigating
        Set<string> ExternalprofileNameSet = new Set<String>();        
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
        
        if(authoredByUser.size()>0 || setCreatedByIds.size()>0){            
            userMap= new Map<id,User>([select id,profile.name, profileid, name ,Firstname,Email from user where id in :authoredByUser OR id in :setCreatedByIds]);
        }
        
        // end by Sumukh for B2B API comments 
        
        Map<ID,String> userProfile=new Map<Id,String>();
        List<User> listUser=[select id,profile.name from user where id in :setCreatedByIds];
        system.debug('listUser :: '+listUser);
        for(User usr: listUser){ 
            userProfile.put(usr.id,usr.profile.name);           
        }
        
        //End
        Set<string> subStatusSet = new Set<String>();
        
        subStatusSet.addAll(Label.Core_IPS_Substatus_Set.split(','));
        system.debug('test @@@@@'+subStatusSet);
        
        Map<String, Core_IPS_Feature_Toggle__c> mapFeatureEnabled = Core_IPS_Feature_Toggle__c.getAll();                
        System.debug('#01 mapFeatureEnabled: ' +  mapFeatureEnabled);
        
        //[04/25/2016 : Abhishek Arya : START : Added null check before assigning the value.]
        Boolean commentToCaseEnabled = false;
        if(mapFeatureEnabled <> null && mapFeatureEnabled.size() > 0 && mapFeatureEnabled.get(LAST_COMMENT_TO_CASE_TEXT) <> null && mapFeatureEnabled.get(LAST_COMMENT_TO_CASE_TEXT).Core_Feature_Enabled__c <> null)
            commentToCaseEnabled = mapFeatureEnabled.get(LAST_COMMENT_TO_CASE_TEXT).Core_Feature_Enabled__c;
        //[04/25/2016 : Abhishek Arya : END]
        
        SET<Id> setUpdateCases = new SET<Id>();    
        
        Boolean isPortalUser = isCurrentUserPortalUser();
        
        Case cs;
        for(Core_IPS_Case_Comments__c caseComment : newlist) {
            
            cs = mapCases.get(caseComment.Core_IPS_Case__c); 
            system.debug(cs.Core_IPS_Customer_Visible__c +  ' IS cusomer visible $$$$$$$$$');                   
            if (cs == NULL)
                continue;
            
            
            
            // Added by sumukh for US97567 - B2B API 
            
            List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();             
            commentList = [select id, CreatedBy_FirstName__c, name,Core_IPS_Comment_Authored_By__c,Core_IPS_Comment_Attachment_Id__c ,Core_IPS_Comment_Attachment_Id__r.Core_IPS_Attachment_Source__c,Core_IPS_Comment_Author_Type__c ,Core_IPS_Comment_Authored_By_Email__c  , Core_IPS_Comment_Authored_By_FirstName__c  , Core_IPS_Comment_Authored_By_Name__c , CreatedByid, Core_IPS_Case_Comment_ID__c, CreatedBy_Name__c, CreatedBy.Email, Core_IPS_Case_Comment_Source__c from Core_IPS_Case_Comments__c where id in :newList ];
            
            
            if(commentList!=null || commentList .size()>0){
                
                for(Core_IPS_Case_Comments__c caseCmnt : commentList ){        
                    if(caseCmnt.Core_IPS_Comment_Authored_By__c==null && caseCmnt.Core_IPS_Comment_Author_Type__c !=Core_IPS_Labels__c.getValues('Backend Integration').value__c || caseCmnt.Core_IPS_Comment_Authored_By__c==null && caseCmnt.Core_IPS_Comment_Author_Type__c ==Core_IPS_Labels__c.getValues('Backend Integration').value__c){
                        caseCmnt.Core_IPS_Comment_Authored_By__c = caseCmnt.createdbyid;        
                    }
                    
                    if(caseCmnt.Core_IPS_Comment_Authored_By__c!=null && userMap.get(caseCmnt.Core_IPS_Comment_Authored_By__c)!=null && caseCmnt.Core_IPS_Comment_Author_Type__c !=Core_IPS_Labels__c.getValues('Backend Integration').value__c){
                        
                        caseCmnt.Core_IPS_Comment_Authored_By_Email__c = userMap.get(caseCmnt.Core_IPS_Comment_Authored_By__c).Email;
                        caseCmnt.Core_IPS_Comment_Authored_By_FirstName__c = userMap.get(caseCmnt.Core_IPS_Comment_Authored_By__c).FirstName;
                        caseCmnt.Core_IPS_Comment_Authored_By_Name__c = userMap.get(caseCmnt.Core_IPS_Comment_Authored_By__c).name;
                        
                        if(Label.Core_IPS_External_Lenovo_Customer_Profile_Id.contains(userMap.get(caseCmnt.Core_IPS_Comment_Authored_By__c).profileid)){
                            caseCmnt.Core_IPS_Comment_Author_Type__c = Core_IPS_Labels__c.getValues('Customer').value__c;                     
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
            try{
                update commentList; 
                
            }
            Catch(Exception e){
                system.debug('exception @'+e.getLineNumber()+'\n msg:'+e.getMessage()); 
            }  
            // End for US97657 by sumukh
            
            
            
            if (caseComment.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c) {
                
                if (commentToCaseEnabled){
                    assignPublicComment(cs, caseComment);
                    assignLatestComment(cs, caseComment);                  
                    cs.Core_Latest_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
                }
                
                System.debug('#41 cs: ' + cs);
                System.debug('#42 isPortalUser: ' + isPortalUser);
                
                // Added for SLA Management
                // Required step to trigger next response after first response.
                //
                // -Comment is public
                // -Comment did not come from the community
                
                // Defect-DE36888 fix for Attachments case comment 3/9/18
                
                if (caseComment.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c  && caseComment.Core_IPS_Comment_Attachment_Id__c ==null &&
                    (caseComment.Core_IPS_Comment_Author_Type__c!='Customer' && caseComment.Core_IPS_Comment_Author_Type__c!='Partner' && caseComment.Core_IPS_Comment_Author_Type__c!='Backend Integration'))                  
                {   
                    if(!cs.Core_First_Response_Completed__c && userInfo.getUserType() != POWER_CUSTOMER_SUCCESS_TEXT)
                        cs.Core_First_Response_Completed__c=true;                
                    
                    cs.Core_Next_Response_Due_Date__c = milestoneutils.getSetNextResponseDueDate(cs);
                    System.debug('#04 cs.Core_Next_Response_Due_Date__c: ' + cs.Core_Next_Response_Due_Date__c);
                }
                // Start Added By Prem US80224 case sub status to investigating.
                
                system.debug('caseComment ::'+caseComment.createdbyid);
                system.debug('caseComment.CreatedByid'+userProfile);
                system.debug('ExternalprofileNameSet :: '+ExternalprofileNameSet +'pfrl.Name :: '+pfrl.Name);
                /*if (cs.Core_Sub_Status__c == CLOSE_PENDING_TEXT && (ExternalprofileNameSet.contains(pfrl.Name) || ExternalprofileNameSet.contains(userProfile.get(caseComment.createdbyid)))){
cs.Core_Sub_Status__c = INVESTIGATING_TEXT;
}*/
                // -Comment came from the community
                // End
                
                if (isPortalUser && !String.isBlank(cs.Core_Sub_Status__c) && (cs.Core_Sub_Status__c.contains(WAITING_FOR_TEXT))) {
                    cs.Core_Next_Response_Due_Date__c = milestoneutils.getSetNextResponseDueDate(cs);
                    System.debug('#05 cs.Core_Next_Response_Due_Date__c: ' + cs.Core_Next_Response_Due_Date__c);    
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
                //}                       
            } 
            
            
            // added fr case comment for US67633 by sumukh
            else if(caseComment.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c){
                if (commentToCaseEnabled) 
                    assignPrivateComment(cs, caseComment);
                assignLatestComment(cs, caseComment);
                cs.Core_Latest_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;                 
                
                // Start added by sumukh for US188756      
                if( cs.Core_IPS_Customer_Visible__c == false && caseComment.Core_IPS_Comment_Attachment_Id__c == null && (caseComment.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Agent').value__c || caseComment.Core_IPS_Comment_Author_Type__c ==Core_IPS_Labels__c.getValues('Partner - Agent').value__c) ||
                   (cs.RecordType.Name == Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact' ) && caseComment.Core_IPS_Comment_Attachment_Id__c == null && (caseComment.Core_IPS_Comment_Author_Type__c == Core_IPS_Labels__c.getValues('Agent').value__c || caseComment.Core_IPS_Comment_Author_Type__c ==Core_IPS_Labels__c.getValues('Partner - Agent').value__c))) // added logic for IS193654 by Sumukh
                {                       
                    if(!cs.Core_First_Response_Completed__c && userInfo.getUserType() != POWER_CUSTOMER_SUCCESS_TEXT)
                        cs.Core_First_Response_Completed__c=true;                
                    
                    cs.Core_Next_Response_Due_Date__c = milestoneutils.getSetNextResponseDueDate(cs);
                }
                // End by sumukh for US188756 
                
                //Change Added by sumukh for US209204
                
                if (cs.Status == 'New' && (cs.RecordType.Name == Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact' ) ||  cs.Core_IPS_Customer_Visible__c == false) && caseComment.Core_IPS_Comment_Attachment_Id__c == null && (caseComment.Core_IPS_Comment_Author_Type__c == Core_IPS_Helper_Utility.getIPSLabel('Agent') ||  caseComment.Core_IPS_Comment_Author_Type__c ==Core_IPS_Labels__c.getValues('Partner - Agent').value__c) ){ 
                    cs.Status = 'Open';
                    cs.Core_Sub_Status__c = INVESTIGATING_TEXT;
                } 
                //End by sumukh for US209204
                
            } 
            else if(caseComment.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PRIVATE_TO_AGENTS').value__c){
                if (commentToCaseEnabled) 
                    assignLatestComment(cs, caseComment);
                cs.Core_Latest_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PRIVATE_TO_AGENTS').value__c;
            }
            
            // Added by sumukh for partner comments changes R4 - I8
            
            else if(caseComment.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c){
                if (commentToCaseEnabled) 
                    assignLatestComment(cs, caseComment);
                cs.Core_Latest_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;
            } 
            
            
            if (setUpdateCases.contains(cs.Id) == False) {
                setUpdateCases.add(cs.Id);
                lstCasesToUpdate.add(cs);
            }    
        }
        
        if (lstCasesToUpdate.size() > 0) {
            
            //Aparna-US309857-i06-Commented update statement and included logic in future method
            //update lstCasesToUpdate;
            string caserecords=JSON.serialize(lstCasesToUpdate);
            if(!string.isblank(caserecords)){
                updateCaseinFuture(caserecords);
            }
            //end for US309857-i06
            
            // System.debug('#21 update on lstCasesToUpdate: ' + lstCasesToUpdate);                  
        }            
    }
    
    
    private static void assignPublicComment(Case soCase, Core_IPS_Case_Comments__c caseComment) {
        
        if (soCase.Core_Last_Case_Comment_Timestamp__c == NULL || caseComment.LastModifiedDate == NULL ||
            (soCase.Core_Last_Case_Comment_Timestamp__c < caseComment.LastModifiedDate)) {
                
                //added the removeimagetag on the public case comment field on 5/18 related to the defect# DE19814 
                if (caseComment.Core_IPS_Rich_Comment__c != NULL)
                    system.debug('>>>before update public rich comment: ' + Core_Utility.removeImageTag(caseComment.Core_IPS_Rich_Comment__c));
                
                
                soCase.Core_Last_Case_Comment__c           = Core_Utility.removeImageTag(caseComment.Core_IPS_Rich_Comment__c);
                soCase.Core_Last_Case_Comment_Submitter__c = caseComment.LastModifiedById;
                soCase.Core_Last_Case_Comment_Timestamp__c = Datetime.Now();
            }
    }
    
    
    private static void assignPrivateComment(Case soCase, Core_IPS_Case_Comments__c caseComment) {
        if (soCase.Core_Last_Private_Case_Comment_Timestamp__c == NULL || caseComment.LastModifiedDate == NULL ||
            (soCase.Core_Last_Private_Case_Comment_Timestamp__c < caseComment.LastModifiedDate)) {
                
                //added the removeimagetag on the public case comment field on 5/18 related to the defect# DE19814 
                soCase.Core_Last_Private_Case_Comment__c           = Core_Utility.removeImageTag(caseComment.Core_IPS_Rich_Comment__c);
                soCase.Core_Last_Private_Case_Comment_Submitter__c = caseComment.LastModifiedById;
                soCase.Core_Last_Private_Case_Comment_Timestamp__c = Datetime.Now();
            }
    }
    
    
    
    
    // added by sumukh for case comment email notofication comment fields
    
    private static void assignLatestComment(Case soCase, Core_IPS_Case_Comments__c caseComment1) {
        if (soCase.Core_Latest_Comment_Time_Stamp__c== NULL || caseComment1.LastModifiedDate == NULL ||
            (soCase.Core_Latest_Comment_Time_Stamp__c < caseComment1.LastModifiedDate)) {
                
                
                soCase.Core_Latest_Case_Comment__c= Core_Utility.removeImageTag(caseComment1.Core_IPS_Rich_Comment__c);
                soCase.Core_Latest_Comment_Submitter__c= caseComment1.LastModifiedById;
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
    public static string Userid;
    public static List<Profile> LstProfile;
    
    
    
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
        Id uId = UserInfo.getUserId();
        User u = [select Id, IsPortalEnabled from user where id = :uId limit 1];
        return u.IsPortalEnabled;
    } 
    
    public static void completeActiveMileStone(List<Core_IPS_Case_Comments__c> newList) {
        
        set<Id> csSetids = new set<id>();     // added by sumukh for US188756
        
        // added by sumukh for US193654       
        SET<Id> setCases = new SET<Id>();        
        for(Core_IPS_Case_Comments__c ccm: newList) {        
            setCases.add(ccm.Core_IPS_Case__c);
        }               
        if (setCases.size() == 0)
            return;           
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
            
            // END by sumukh for US188756      
           
            // START added by Sneha for DE35586
            if((cc.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c && cc.Core_IPS_Comment_Attachment_Id__c == null && cc.Core_IPS_Comment_Author_Type__c != Core_IPS_Labels__c.getValues('Customer').value__c && cc.Core_IPS_Comment_Author_Type__c != Core_IPS_Labels__c.getValues('Partner').value__c) || (mapCases.get(cc.Core_IPS_Case__c).RecordType.Name == Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact')  && cc.Core_IPS_Case_Comment_Type__c == Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c) && (cc.Core_IPS_Comment_Attachment_Id__c == null)) // added logic for IS193654 by Sumukh
                caseIds.add(cc.Core_IPS_Case__c);
        }
        // END added by Sneha for DE35586
        
        if (caseIds.isEmpty() && csSetids.isEmpty() ) 
            return;
        
        caseList = [SELECT Id, ContactId, Contact.Email, OwnerId, Core_Trigger_Next_Response__c, Status, EntitlementId, 
                    Core_Next_Response_Due_Date__c, Core_First_Response_Completed__c, SlaStartDate, SlaExitDate
                    FROM Case   
                    WHERE Id IN :caseIds OR ( Id IN :csSetids AND Core_IPS_Customer_Visible__c = false )]; // Added changes by sumukh for US188756
        
        
        DateTime completionDate = System.now();
        
        Set<Id> updateCaseIds = new Set<Id>();
        for(Case cs:caseList) { 
            if (milestoneUtils.isCaseMilestoneUpdateRequired(cs, completionDate)){
                if (!updateCaseIds.contains(cs.id))
                    updateCaseIds.add(cs.id);
            }
        }
        
        List<CaseMilestone> activeMilestoneList = [SELECT Id, completionDate
                                                   FROM CaseMilestone 
                                                   WHERE caseId IN :updateCaseIds
                                                   AND completionDate = NULL];
        
        for(CaseMilestone cm : activeMilestoneList) 
            cm.completionDate = completionDate;
        
        Database.update(activeMilestoneList, false);
        
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
}