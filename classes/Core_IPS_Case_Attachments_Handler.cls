/******************************************************************************************************************************************
Class Name  : Core IPS Case Attachments Handler 
Version     : 1.0 
Created Date: 09 APR 2017
Function    : Handler Class for IPS Case Attachment. 
This class defines all the methods which are used for IPS Case Attachment logic.
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------    
* Varun Gupta               04/09/2017             Original version
* Sumukh                    12/12/2017              Attachment comments(insertCaseComment) 
* Ajay                      2/15/2018              as per US96026
* Sumukh                    4/04/2018              US94127/US94125 for updation for attachments related comments
* Aparna                    17/5/2018              Added logic for US97707-B2B Api implementation
* Aparna                    22/6/2018              Modified for DE40279
* Sumukh                    26/6/2018              Added logic for US108595 Iteration 13 , release 4.3
* Ranjini					27/8/2018			   Added new method updateCase for DE26263
*****************************************************************************************************************************************/
public without sharing class Core_IPS_Case_Attachments_Handler {
    
    static Boolean isrec = false; //Added to void recursion.
    public static Map<Id,user>userMap = new Map<Id,user>();
    
    //****************User Story-US61012*****************************************************************
    //Method-This method validates for an IPS External Customer to not able to delete IPS Agent Attachments.
    // This is main method which is called from Case Object trigger dispatcher: 
    //  Core_IPS_Case_Attachments_Dispatcher
    //************************************************************************************/
    
    public static void validateAttachmentfromdeleting(List<Core_IPS_Case_Attachments__c> lstips, Map<id,Core_IPS_Case_Attachments__c> oldCaseAttachments)
    {
        
        Id profileId=userinfo.getProfileId();    
        
        userMap = returnUserMaps(lstips);
        
        for(Core_IPS_Case_Attachments__c cs:lstips){
            if(userMap != null && userMap.size()>0 && (userMap.get(cs.Core_FileUploadedBy__c).profileid  != null || userMap.get(cs.Core_FileUploadedBy__c).profileid !='')){
                if((system.label.IPS_Portal_Profile_ID==profileId) && userMap.get(cs.Core_FileUploadedBy__c).profileid != label.IPS_Portal_Profile_ID)
                { 
                    if(!trigger.isdelete) cs.addError(label.IPS_Case_Attachment_Delete_Error); else  cs.addError(label.IPS_Case_Attachment_Update_Error);
                }
            }
        }
    }
    
    //Ajay- US96026- fill Backend user if FUB is null.
    public static void updateFUBIfBlank(List<Core_IPS_Case_Attachments__c> newList){
        for(Core_IPS_Case_Attachments__c attObj :newList){
            if(String.isBlank(attObj.Core_FileUploadedby__c) || attObj.Core_FileUploadedby__c==null){
                attObj.Core_FileUploadedby__c=label.Backend_IntegrationUser;
            }
        }
    }
    
    //Added for B2B Api Implementation;US97707 on 17/5/2018 by Aparna
    public static void upadtevaluesB2B(Map<id,Core_IPS_Case_Attachments__c> newMap)
    {
        
        
        try{
            
            set<ID>UserIds = new set<ID>();
            
            for(Core_IPS_Case_Attachments__c attFub : newMap.Values())
            {
                
                UserIds.add(attFub.Core_FileUploadedBy__c);
            }
            
            map<id,user>userInfm;
            
            if(UserIds !=null)
            {
                //Added profile in query for US105986 on 29/5/2018 by Aparna
                userInfm = new map<id,user>([select IsActive,Email,Name,FirstName,Profile.Name,Profile.Id from User where id IN: UserIds]);
            }
            
            if(userInfm.Values()!=null)
            {
                
                list<Core_IPS_Case_Attachments__c> b2bAtt = new list<Core_IPS_Case_Attachments__c>();
                
                for(Core_IPS_Case_Attachments__c attObj :newMap.values())
                {  
                    
                    Core_IPS_Case_Attachments__c att = new Core_IPS_Case_Attachments__c();
                    att.id = attObj.id;
                    //Modified for US105986 R4.3 by Aparna on 29/5/2018
                    
                    if(string.valueOf(attObj.Core_FileUploadedby__c).substring(0,15) != label.Backend_IntegrationUser && UserInfm.get(attObj.Core_FileUploadedBy__c).IsActive)
                    {
                        att.Core_IPS_Uploaded_By_Email__c = userInfm.get(attObj.Core_FileUploadedBy__c).Email;
                        att.Core_IPS_Uploaded_By_FirstName__c = userInfm.get(attObj.Core_FileUploadedBy__c).FirstName;
                        att.Core_IPS_Uploaded_By_Name__c = userInfm.get(attObj.Core_FileUploadedBy__c).Name;
                        
                    }
                   
                    if(attObj.Core_IPS_Attachment_Source__c  !=  LABEL.Core_RestAPI_Attachment_Source){ 
                        if(string.valueOf(attObj.Core_FileUploadedby__c).substring(0,15) == label.Backend_IntegrationUser)
                        {
                            att.Core_IPS_Attachment_Source__c = Core_IPS_Labels__c.getValues('Backend System').value__c;
                        }
                        
                        //Modified for DE40279 by Aparna
                        //Added OR condition below for DE40832 by Aparna 18/7/2018
                        else if((label.Core_IPS_B2BExternal_Profile_Names.contains(UserInfm.get(attObj.Core_FileUploadedBy__c).Profile.Name)|| UserInfm.get(attObj.Core_FileUploadedBy__c).Profile.Name == label.Core_IPS_Partner_AE_ProfileName))
                        {
                            att.Core_IPS_Attachment_Source__c = Core_IPS_Labels__c.getValues('Customer Portal').value__c;
                        }
                        else if(label.Core_IPS_B2B_Attachment_Profiles.contains(UserInfm.get(attObj.Core_FileUploadedBy__c).Profile.Name))
                        {
                            att.Core_IPS_Attachment_Source__c = Core_IPS_Labels__c.getValues('Internal Portal').value__c;
                        }
                        
                        else if(Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(UserInfm.get(attObj.Core_FileUploadedBy__c).Id) == true) //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
                        {
                            att.Core_IPS_Attachment_Source__c = Core_IPS_Labels__c.getValues('Data Migration').value__c;
                        }
                        
                        else
                            att.Core_IPS_Attachment_Source__c = Core_IPS_Labels__c.getValues('Attachment Source-N/A').value__c;
                        
                    }
                    b2bAtt.add(att);
                }    
                if(b2bAtt.size()>0)
                    update b2bAtt;
            }
        } 
        Catch(Exception e){
    	}
    }
    //end
    
    public static map<id,User> returnUserMaps(List<Core_IPS_Case_Attachments__c> newList){
        set<id> userids= new set<id>();
        for(Core_IPS_Case_Attachments__c cs:newList){
            userids.add(cs.Core_FileUploadedBy__c);
        }
        Id profileId=userinfo.getProfileId();
        Map<Id,user> retuserMap = new Map<Id,user>();
        if(!userids.isempty()){
            retuserMap=new map<id,User>([select id, profileid from user where id in: userids]);
            
        }
        
        return retuserMap;
    }
    
    //This method is used to insert a case comment when an atachment is made on the case by sumukh for US72547
    Public static void insertCaseComment(List<Core_IPS_Case_Attachments__c> newList,Map<id,Core_IPS_Case_Attachments__c> newMap,Map<id,Core_IPS_Case_Attachments__c> oldMap)
    {
        
        Core_IPS_Case_Attachments__c ca = new Core_IPS_Case_Attachments__c();                     
        list<Core_IPS_Case_Comments__c> commentlist = new list<Core_IPS_Case_Comments__c>();
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
        
        userMap = returnUserMaps(newList);     
        
         
        if((newList != null && newList.size() > 0) && !isrec && Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(userInfo.getUserId()) == false){   //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access 
            for(Core_IPS_Case_Attachments__c attachObj: newList)
            { 
                
                if((Trigger.isInsert && attachObj.Core_Upload_Status__c.equalsIgnoreCase(Core_IPS_Labels__c.getValues('COMPLETE').value__c)) || (Trigger.isUpdate && newMap.get(attachObj.id).Core_Upload_Status__c!=oldMap.get(attachObj.id).Core_Upload_Status__c && attachObj.Core_Upload_Status__c.equalsIgnoreCase(Core_IPS_Labels__c.getValues('COMPLETE').value__c))){
                    if(!String.isBlank(attachObj.Core_FileUploadedby__c) && attachObj.Core_FileUploadedby__c!=null){
                        newComment.Core_IPS_Comment_Author_Type__c=Core_IPS_AddCommentController.getAuthr(String.valueOf(userMap.get(attachObj.Core_FileUploadedby__c).ProfileId).substring(0,15),attachObj.Core_FileUploadedby__c);
                        newComment.Core_IPS_Comment_Authored_By__c = attachObj.Core_FileUploadedby__c;
            }                              
                    
                    String fileDescriptn;
                    if(attachObj.Core_File_Description__c!=null){                                  
                        fileDescriptn = attachObj.Core_File_Description__c.replaceAll('>','&gt;');
                        fileDescriptn = attachObj.Core_File_Description__c.replaceAll('<','&lt;');
                    }
                    if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case__c.isCreateable()) { //Fix added -Aditya
                        newComment.Core_IPS_Case__c = attachObj.Core_Case__c;
                    }
                    newComment.Core_IPS_Case_Comment_Type__c = attachObj.Core_IPS_Attachment_Visibility__c; 
                    newComment.CreatedById = attachObj.Core_FileUploadedby__c; 
                    newComment.Core_IPS_Rich_Comment__c = ' New Case Attachment uploaded: ' + '<br/>' + '<a href='+attachObj.Core_File_URL__c+' target="Self">Download link</a>'      + '      &nbsp; &nbsp;     '    + attachObj.Core_File_Name__c   +     '     &nbsp; &nbsp;      '     +   fileDescriptn    ;                                     
                    newComment.Core_IPS_Comment_Attachment_Id__c = attachObj.id;  
                    if(attachObj.Core_IPS_Attachment_Source__c ==   LABEL.Core_RestAPI_Attachment_Source){
                        newComment.Core_IPS_Case_Comment_Source__c = attachObj.Core_IPS_Attachment_Source__c;
                    }
                    
                    // Added by Sumukh for US108595   
                    if(newComment.Core_IPS_Comment_Author_Type__c ==Core_IPS_Labels__c.getValues('Backend Integration').value__c){
                        
                        //pk  newComment.Core_IPS_Comment_Authored_By__c = newComment.createdbyid;
                        //if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Authored_By__c.isCreateable()) {
                        newComment.Core_IPS_Comment_Authored_By__c = attachObj.Core_FileUploadedby__c;
                        //}
                        //if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Authored_By_Name__c.isCreateable()) {
                        newComment.Core_IPS_Comment_Authored_By_Name__c = attachObj.Core_IPS_Uploaded_By_Name__c;
                        newComment.Core_IPS_Comment_Authored_By_FirstName__c = attachObj.Core_IPS_Uploaded_By_FirstName__c;
                        newComment.Core_IPS_Comment_Authored_By_Email__c = attachObj.Core_IPS_Uploaded_By_Email__c;
                    }  
                    // end for US108595                               
                    commentlist.add(newComment);                               
                }
            }
        }  
        if(commentlist!=null && commentlist.size()>0){
            try{
                insert commentlist;
            }
            Catch(Exception e){
            }
            
        }
        isrec=true;
    }  
    
    // Added by sumukh for updation of attachment case comments for US94125/US94127 
    Public static void deleteAttachmentCaseComment(List<Core_IPS_Case_Attachments__c> oldList){
        
        Core_IPS_Case_Attachments__c Att = new Core_IPS_Case_Attachments__c();                     
        list<Core_IPS_Case_Comments__c> commentlist = new list<Core_IPS_Case_Comments__c>();
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();       
        
        if(oldList!=null && oldList.size()>0){ 
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){ //FLS Check added - Aditya         
                commentlist = [Select id,Core_IPS_Case__c,Core_IPS_Case_Comment_ID__c,Core_IPS_Comment_Attachment_Id__c,Core_IPS_Rich_Comment__c,Core_IPS_Comment__c from Core_IPS_Case_Comments__c where Core_IPS_Comment_Attachment_Id__c IN:oldList];         
            }
        }
        
        for(Core_IPS_Case_Comments__c caseCommentObj : commentlist){
            
            if(commentlist.size()>0){            
                if(caseCommentObj.Core_IPS_Comment_Attachment_Id__c != null){          
                    caseCommentObj.Core_IPS_Rich_Comment__c = caseCommentObj.Core_IPS_Comment__c ;
                }
            }
        }
        if(commentlist!=null && commentlist.size()>0){
            try{
                database.update(commentlist);
            }Catch(Exception e){
            }                       
        }                          
    }      
    
    Public static void updateAttachmentCaseComment(List<Core_IPS_Case_Attachments__c> newList, Map<Id,Core_IPS_Case_Attachments__c> oldMap){
        
        
        list<Core_IPS_Case_Comments__c> commentlist = new list<Core_IPS_Case_Comments__c>();
        Map<Id,Core_IPS_Case_Attachments__c> mapAtt = new Map<Id,Core_IPS_Case_Attachments__c>(newList);
        Set<Id> setFileDescripChangedAttachment = new Set<Id>();
        
        for(Core_IPS_Case_Attachments__c att : newList) {
            if(oldMap.get(att.Id).Core_File_Description__c != Att.Core_File_Description__c)
                setFileDescripChangedAttachment.add(att.Id);
            
        }
        
        if(setFileDescripChangedAttachment!=null && setFileDescripChangedAttachment.size()>0){ 
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){  //FLS check added - Aditya        
                commentlist = [Select Core_IPS_Case__c,Core_IPS_Case_Comment_ID__c,Core_IPS_Comment_Attachment_Id__c,Core_IPS_Rich_Comment__c,Core_IPS_Comment__c from Core_IPS_Case_Comments__c where Core_IPS_Comment_Attachment_Id__c in: setFileDescripChangedAttachment];           
            }
        }
        
        if(commentlist.size()>0){
            for(Core_IPS_Case_Comments__c caseCommentObj : commentlist) {
                
                Core_IPS_Case_Attachments__c Att = mapAtt.get(caseCommentObj.Core_IPS_Comment_Attachment_Id__c);  
                
                String fileDescriptn = att.Core_File_Description__c==null ? '' : att.Core_File_Description__c;
                if(String.isNotBlank(fileDescriptn)) {                                  
                    fileDescriptn = fileDescriptn.replaceAll('>','&gt;');
                    fileDescriptn = fileDescriptn.replaceAll('<','&lt;');
                }
                caseCommentObj.Core_IPS_Rich_Comment__c = ' New Case Attachment uploaded: ' + '<br/>' + '<a href='+att.Core_File_URL__c+' target="Self">Download link</a>'      + '      &nbsp; &nbsp;     '    + att.Core_File_Name__c   +     '     &nbsp; &nbsp;      '     +   fileDescriptn    ; 
                
            }
        }
        if(commentlist!=null && commentlist.size()>0){
            try{
                update commentlist;
            }Catch(Exception e){
            }                       
        }
        
    }
    // END by sumukh 
     /***************************************************************************************************
    Method Name:  updateCase
    Method Type: IPS Utility Method 
    Version     : 1.0 
    Created Date: 28 Aug 2019
    Function    : This method will update Core_Last_Case_Comment_Submitter__c field in Case as per atatchment
    Input Parameters: List of Core_IPS_Case_Attachments__c
    Description:  This method will update Core_Last_Case_Comment_Submitter__c field in Case as per atatchment
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0 
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Ranjini             28/8/2019              Created
    ****************************************************************************************************/   
    Public static void updateCase(List<Core_IPS_Case_Attachments__c> newList){

        if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateCase'))
        return; 

        list<case>caseToupdate = new list<case>();
        Map<id,Core_IPS_Case_Attachments__c>caseIdMap = new Map<id,Core_IPS_Case_Attachments__c>();
        for(Core_IPS_Case_Attachments__c attach: newList){
            caseIdMap.put(attach.Core_Case__c,attach);
        }
        
        for(Core_IPS_Case_Attachments__c attVar:caseIdMap.values()){
            if(caseIdMap.containskey(attvar.Core_Case__c)) {
                   case c= new case();
                    c.id = attVar.Core_Case__c;
                   if (Schema.sObjectType.Case.fields.Core_Last_Case_Comment_Submitter__c.isUpdateable()) { //TWC745-5592-FLS update added -Gangadhar -29/02/2024
            	   c.Core_Last_Case_Comment_Submitter__c = attVar.Core_FileUploadedBy__c;
                   }
				   caseToupdate.add(c);
                }
        }
        try{
            update caseToupdate;}catch(exception e){}
    }
//=========================================================================================================
/* Method Name: sendCaseAttachment
 * Input Params: List of Core_IPS_Case_Attachments__c
 * Function: This method will Create the outbound for case attachment whenever the upload status of case attachment 
 *           is changed to 'Complete' by scft.
 * Author: Chandra Shekar
 */
    public static void sendCaseAttachment(List<Core_IPS_Case_Attachments__c> newList){
        List<Case> cases = new List<Case>();
        try{
        List<Id> caseIds = new List<Id>();
        for(Core_IPS_Case_Attachments__c attachmentVar: newList){
            caseIds.add(attachmentVar.Core_Case__c);
        }
            if(Case.SObjectType.getDescribe().isAccessible()){ //FLS already added - Aditya
             	cases = [select id,Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c,Core_IPS_BackendID__c, Core_IPS_BES_Promote_Status__c,Core_IPS_New_Backend_System__c from case WHERE Id IN:caseIds];
            }
        List<Core_IPS_Case_Attachments__c> caseAttachmentsList =new List<Core_IPS_Case_Attachments__c>();
            for(Core_IPS_Case_Attachments__c caseAttachmentVar: newList){
                if(caseAttachmentVar.Core_Upload_Status__c == 'Complete') {
                    for(case caseId: cases) {
                        //Ajith added this logic to restrict to create Outbound messages, when Backend system is deactivated
                        if(caseId.Core_IPS_BackendID__c!=null && caseId.Core_IPS_New_Backend_System__c!=null && caseAttachmentVar.Core_Case__c == caseId.Id && caseId.Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c == false) {
                            caseAttachmentsList.add(caseAttachmentVar);
                        }
                    }
                }
            } 
        if(caseAttachmentsList.size()>0){
            Core_IPS_BES_OutboundMessage.createPlatformEventHSD(caseAttachmentsList); 
        }
        }catch(Exception e){
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null , String.join(newList,','));
                }
    }   
}