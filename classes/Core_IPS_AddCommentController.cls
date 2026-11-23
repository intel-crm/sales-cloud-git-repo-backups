/***************************************************************************************************
Version     : 1.0 
Modified Date: 11 NOV 2017
Function    : This method adds  
Input Parameters: List<User>
Output Parameters: None
Transactions: 
Description: THis controller is responsible for Displaying case comment in recent section in Comment Creation page.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sumukh                   11/08/2017              MODIFIED as part of - US67444,US67633,US83446,US83924
* Sugandha                 02/04/2018              Modified(User story# US99039 Iteration# 9)
* Aparna                    30/3/2018              Modified for US101113
* Ajay                     30/3/2018               Modified for US101118
* Aayushi                  21/06/2018              Modified for DE40236
* Prem Ranjan              17/07/2018              Modified for US108037 
* Sumukh                   22/10/2018              Added Logic for US193654  
* Sumukh                   14/01/2019              Added logic for US244578 
* Aparna                   22/5/2019               Modified for US340937
* Ganapati                 27/06/2019              Modified for US336530
* Ganapati                 17/10/2019              Modified for DE55770 - Core_Last_Case_Comment__c not updating properly on Case 00214161
****************************************************************************************************/ 
public with sharing class Core_IPS_AddCommentController{
    
    public Case newcase{get;set;}
    public id urlid;
    public String profileName = System.Label.Core_IPS_Profile_Name;
    public List<String> selectedVisibilityOption{get;set;}
    public List<SelectOption> visibilityOptions{get;set;}
    public Boolean internalColumn{get;set;}
    public Boolean externalColumn{get;set;}
    public Boolean ShowRadioButton{get;set;}
    public boolean disableAccess{get;set;}
    
    //added for search 
    public boolean searched{get;set;}   
    public List<Core_IPS_Case_Comments__c> cmtResults {get;set;}
    public string searchText {get;set;}
    public List<Core_IPS_Case_Comments__c> searchCmt {get;set;}
    
    //US336530 : addded by Ganapati for US336530
    private static String EXPORT_PDF_PAGENAME = '/apex/Core_IPS_Case_ExportPDF';
    private static String publicToCust = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
    private static String privateToPartner = Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;
    private static String privateToIntel = Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;
    
    //end
    
    //Added for US340937
    public string gecSystemUser{get;set;}
    {
        gecSystemUser= Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_USAMindsComment_Author');
    }
    //end
    
    // Added for Partner Changes by sumukh for I-7 Release 4
    
    public String partnerProf{get;set;}{partnerProf  = System.Label.Core_IPS_Partner_Profile_Id;}
    public String extprof{get;set;}{extprof =  System.Label.Core_IPS_External_Customer_Profile_Ids;}
    public boolean ExtUser{get;set;}
    public Boolean partnerAgentUser{get;set;}
    public String partnerAgent{get;set;}{partnerAgent= System.Label.Core_IPS_Agent_Partner_Profile_id;}  
    Public String prtDFAE = System.Label.Core_IPS_Partner_DFAE_Permission_Set;     
    public List<PermissionSetAssignment> partDFAEUser{get;set;} 
    Public Boolean isNACCase{get;set;}                                                  // Added by sumukh for US193654
    public String SOAPermSetID = System.Label.Core_IPS_SupportOrgAdmin_Permission_Set;  // added by sumukh for US244578
    public static List<PermissionSetAssignment> SOAUser{get;set;}                       // added by sumukh for US244578
    
    //{ User story# : US67444 ; Iteration# : PSG Release-2 ; Developer Name : Sumukh }
    
    public Profile loggedInUserProf{get;set;}
    public Boolean userHasAccess{get;set;}
    
    public Boolean partnerUser{get;set;}
    public static string PRIVATE_TO_AGENTS{get;set;}{PRIVATE_TO_AGENTS= Core_IPS_Labels__c.getValues('PRIVATE_TO_AGENTS').value__c;}
    public static string PUBLIC_TO_CUSTOMERS{get;set;}{PUBLIC_TO_CUSTOMERS=Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;}
    public static string PRIVATE_TO_INTEL{get;set;}{PRIVATE_TO_INTEL=Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;}
    public static string PRIVATE_TO_PARTNER{get;set;}{PRIVATE_TO_PARTNER=Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;}
    public String loginuserprofilename{get;set;}
    public boolean externalUser{get;set;}{externalUser=Network.getNetWorkid()!= null? True:false;}
    
    public boolean getexLoginedUser(){       
        return Network.getNetworkId() != null;
    }
    //*********** stat added by venki for pagination as per DEF:23171 6/4/2017****
    
    public integer count{get;set;}
    public integer counter{get;set;}{counter=0;}  //keeps track of the offset
    public integer list_size{get;set;} //sets the page size or number of rows
    public integer total_size{get;set;} //used to show user the total size of the list
    public String partnerType{get;set;}
    /*---------end-----------*/
    
    //{ User story# :US67444 / US83924 ; Iteration# : PSG Release 2 / Release 4 (Partner changes) ; Developer Name : Sumukh} 
    
    public String selectedRadioButton {get;set;}
    {        
        if(extprof.contains(String.valueOf(userinfo.getProfileId()).substring(0,15))){           
            selectedRadioButton = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;       
        }                     
        else if(partnerProf.contains(String.valueOf(userinfo.getProfileId()).substring(0,15))){                      
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
        else if(!externalUser) {            
            selectedRadioButton = Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;             
        }               
    }
    
    //Number of records to be displayed per page- US101118
    List<String> commentPages;
    public list<selectOption> records{get;set;}{
        commentPages = String.valueOf(System.label.Core_IPS_CaseComment_Pages).split(';');
        records=new List<selectOption>();
        for(Integer i=0;i<commentPages.size();i++){
            records.add(new selectoption(commentPages[i],commentPages[i]));                    
        } 
    }
    public integer numberLimit{get;set;}{
        if(commentPages.size()>0){
            numberLimit=Integer.valueOf(commentPages[5]);//US704558: Change default # of Case Comments to current max of 60
        }else {
            numberLimit=60;  //US704558: Change default # of Case Comments to current max of 60
        }
        
    }
    
    
    public Core_IPS_AddCommentController(ApexPages.StandardController controller) { 
        List<AccountShare> acctShare;
        //added for search
        searched=false;
        isNACCase=false;                // added by sumukh for US193654
        disableAccess = false;       
        urlid = apexpages.currentpage().getparameters().get('id');
        if(urlid !=null){
            //FLS Check Added - Madhuri
            if(Case.SObjectType.getDescribe().isAccessible()){
            newCase=[select id,subject,Core_IPS_Comment__c,RecordType.Name,AccountId,Core_Sub_Status__c,status,CreatedBy.Email,contactid,Core_IPS_Date_Time_Close_Pending__c from Case where id =:urlid ];               
            }
        }
        loggedInUserProf =[select id,name from Profile where id=:userInfo.getProfileId()]; 
        
        // Added by sumukh for US193654         

        
        if(newCase.RecordType.Name == Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact')){         
            isNACCase=true;
        }          
        // end by sumukh for US193654
        
        try{                 
            partDFAEUser  = [Select id,AssigneeId  from PermissionSetAssignment where AssigneeId =: userInfo.getUserId() and PermissionSetId =:prtDFAE LIMIT 1];
            SOAUser = [Select id,AssigneeId  from PermissionSetAssignment where AssigneeId =: userInfo.getUserId() and PermissionSetId =:SOAPermSetID LIMIT 1];    // added by sumukh for US244578
            
        }
        Catch(Exception e){
        }  
        
        partnerUser       =  Label.Core_Partner_Profile_Id.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));       
        partnerAgentUser  =  Label.Core_IPS_Agent_Partner_Profile_id.contains(String.valueOf(userInfo.getProfileId().substring(0, 15))); 
        ExtUser      =  extprof.contains(String.valueOf(userInfo.getProfileId().substring(0,15)));                              
        userHasAccess =  Label.Core_IPS_Agent_Profiles.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));       
        
        if(userHasAccess == false && SOAUser !=null && SOAUser.size()>0){ // added by sumukh for US244578
            userHasAccess = true; }
        internalColumn= false;
        externalColumn= false;
        
        /*if(loggedInUserProf.name!= ProfileName || !(externalUser))    // Added by Prem "externalUser" to check for partner profile too where we are checking for "IPS External Customer".
        InternalOnlyOptions = true;
        else
        InternalOnlyOptions = false;
        */    
        /*Code to prevent form Adding Commments if case is GEC*/
        /*START*/
        if(( !(externalUser))&& newCase.RecordType.Name == System.Label.Core_IPS_GECRecordTypeName){         
            ShowRadioButton = false;           
        }          
        else{
            ShowRadioButton = true;
        }
        if(partnerAgentUser){
            selectedRadioButton = Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;
        }
        
        /*Account Association Read Access Check*/
        if(loggedInUserProf.name!= profileName && !(externalUser)){
            List<String> caseAccessLevel = new List<String>();
            caseAccessLevel.add(Core_IPS_Helper_Utility.getIPSLabel('AccessLevel_Read'));
            caseAccessLevel.add(Core_IPS_Helper_Utility.getIPSLabel('AccessLevel_Edit'));
            Set<Id> userIdSet = new Set<id>();
            
            if(newCase.AccountId!=null){
                //FLS Check Added - Madhuri
             //   if(accountshare.SObjectType.getDescribe().isAccessible()){
                    acctShare = [select accountId, caseaccesslevel, userOrGroupId from accountshare where caseAccessLevel IN: caseAccessLevel and accountId =: newCase.AccountId and userOrGroupId =: userInfo.getUserId()];
              //  }
                if(acctShare.size()!=0) {
                    for(AccountShare share: acctShare){ String userId = share.userOrGroupId;
                                                       if(userId <> null && userId.startsWith('005')){ userIdSet.add(share.userOrGroupId);
                                                                                                      
                                                                                                     }
                                                      }
                    if(userIdSet == null && userIdSet.isEmpty()){ disableAccess = true;
                                                                   
                                                                  }
                }
            }
        }
        /*************** added by venki for  DEF:23171 6/4/2017******************/
        
        /*************** added By Prem for External Pagination US92252 ******************/
        // Total_size is seperated for internal and external user 
        if(!(ExternalUser) || (partnerAgentUser)){
            total_size=[select count() from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id];// added by venki for displaying totapages
            
            // Partner Profile seperated with PTOC and PTOP for FAE as per US108037
        }else if(partnerProf.contains(String.valueOf(userinfo.getProfileId()).substring(0,15)) && partnerType != 'Partner'){
            total_size=[select count() from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id and (Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c 
                                                                                                              OR Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c )];
            // End                        
        }else{
            total_size=[select count() from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id and Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c];
        }
        
        //---------------end-----------------------//
        
        String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        if(pageName.contains('Core_IPS_AddComment')){
            numberLimit =Integer.valueOf(Label.Core_IPS_Comments_List_Size) > 0 ? Integer.valueOf(Label.Core_IPS_Comments_List_Size) : 20;  
        }
        
        //---------------end-----------------------//
     
    }
    
    
    
    
    //{user stpry#:US67444 Iteration#:PSG Release 2 Developer Name:Sumukh}
    
    public PageReference saveComment(){
        //added by sugandha for US99039
        Case cs = new Case();
        //If condition modified by Aayushi DE40236
         if(newCase != null && newcase.Core_Sub_Status__c != Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Close_Pending_SubStatus') && newCase.Core_IPS_Date_Time_Close_Pending__c != null && selectedRadioButton == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c && (System.Label.Core_IPS_Agent_Profile_Ids.Contains(String.valueOf(userInfo.getprofileId()).substring(0, 15)) || System.Label.Core_IPS_DataOps.contains(String.valueOf(userInfo.getprofileId()).substring(0, 15)))){
            /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
            // Added by chetan as part of ATHR
            if (Schema.sObjectType.Case.fields.Core_IPS_Date_Time_Close_Pending__c.isUpdateable()) {
                cs.Core_IPS_Date_Time_Close_Pending__c = null;
            }
            cs.Id = newCase.Id;
        }
        //end 
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
        Core_IPS_Case_Attachments__c newAttachment = new Core_IPS_Case_Attachments__c();              
        if(partnerType =='Partner'){               
            selectedRadioButton = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;     
        }
        if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case__c.isCreateable()) {
        	newComment.Core_IPS_Case__c=newCase.id;
        }
        // Added by chetan as part of ATHR
        if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Rich_Comment__c.isCreateable()) {
        newComment.Core_IPS_Rich_Comment__c=newCase.Core_IPS_Comment__c; 
        }      
        
        if( selectedRadioButton!=null ){         
            if(partnerUser){
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
                // Added by chetan as part of ATHR
               if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case_Comment_Type__c.isCreateable()) {
                     newComment.Core_IPS_Case_Comment_Type__c = selectedRadioButton;  
                }
            }
            else if(!(ExternalUser) || (partnerAgentUser)){  
                newComment.Core_IPS_Case_Comment_Type__c = selectedRadioButton; 
                 }
            else {
					newComment.Core_IPS_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
                 }
            // Added by chetan as part of ATHR
            if(newComment.Core_IPS_Comment_Attachment_Id__c!=null && Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Comment_Author_Type__c.isCreateable()){
            	newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId() ,newAttachment.Core_FileUploadedBy__c);
            }
            else if(newComment.Core_IPS_Comment_Attachment_Id__c==null){
                newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId(),userinfo.getuserid());
            }
            
            try{
                if(newComment!=null){  
                    insert newComment;
                    //added by sugandha for US99039
                    // Modified for DE55770 - added curly braces to if
                    if(cs.Id != null ){  
                        update cs;
                    }
                        
                }
                
            }
            catch(Exception e){
            }
        } 
        return new PageReference('/'+newCase.id);        
    }
    
    
    //Identifies and Maps the logged in User with Author Type
    public static String getAuthr(String loggedUserId,String Userid){
        String authroTyp='';
        
        if(Label.Core_IPS_External_Customer_Profile_Ids.contains(loggedUserId.substring(0,15))){
            return authroTyp=Core_IPS_Labels__c.getValues('Customer').value__c;         
        } 
        else if(label.Core_IPS_DataOps.contains(loggedUserId.substring(0,15))){            // added by sumukh for US244578
            String dataOpsAuthrType = '';                     
            dataOpsAuthrType = Core_Utility.isSupOrgAdmPermUser(Userid.substring(0,15));         
            if(dataOpsAuthrType !=null && String.isNotBlank(dataOpsAuthrType )){           
                return authroTyp = dataOpsAuthrType ; }                               // end for US244578
        }    
        else if(Label.Core_IPS_SalesRep_ProfileIds.contains(loggedUserId.substring(0,15))){
            return authroTyp=Core_IPS_Labels__c.getValues('FAE').value__c;
        }
        else if(Label.Core_IPS_Agent_Profiles.contains(loggedUserId.substring(0,15) )){
            return authroTyp=Core_IPS_Labels__c.getValues('Agent').value__c;
        }
        
        else if(Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(userInfo.getUserId()) == true){ //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
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
    
    /* Modified by Ganapati for US336530
     * Description : modified complete function to make dynamic query to return all comments when click on 
     * export pdf button on case, previously this function was retuning only limited comments 
     */
    public List<Core_IPS_Case_Comments__c> getcaseComments() {
        String query = 'select id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Name,Core_IPS_Comment__c,CreatedBy.Account.Name,Core_IPS_Rich_Comment__c,CreatedBy.Contact.Account.name,CreatedBy.Profile.Name,CreatedBy.Firstname,CreatedBy.Profileid, CreatedDate,Core_IPS_BgColor__c,Core_IPS_NickName__c,CreatedBy_Name__c, Core_IPS_Case_Comment_Type__c ,CreatedBy.Email,Core_IPS_Comment_Author_Type__c,Core_IPS_Comment_Authored_By__r.Name,Core_IPS_Comment_Authored_By__r.Account.name,Core_IPS_Comment_Authored_By_Email__c,Core_IPS_Comment_Authored_By_FirstName__c,Core_IPS_Comment_Authored_By_Name__c from Core_IPS_Case_Comments__c ';   
        String pageURL = ApexPages.currentPage().getURL();
        String caseId = newCase.Id;
        if(partnerAgentUser || userhasAccess) {
            internalColumn= true;
            if(String.isNotBlank(pageURL) && pageURL.containsIgnoreCase(EXPORT_PDF_PAGENAME)) {
                query = query  + 'where Core_IPS_Case__c=\''+String.escapeSingleQuotes(caseId)+'\' ORDER BY CreatedDate DESC NULLS LAST';      // removed limit & offset
            } else {
                query = query  + 'where Core_IPS_Case__c=\''+String.escapeSingleQuotes(caseId)+'\' ORDER BY CreatedDate DESC NULLS LAST limit :numberLimit offset :counter';
            }
        } else if(!(externalUser) || (partnerAgentUser)) {
            internalColumn= true;         
            if(String.isNotBlank(pageURL) && pageURL.containsIgnoreCase(EXPORT_PDF_PAGENAME)) {
                query = query  + 'where Core_IPS_Case__c=\''+String.escapeSingleQuotes(caseId)+'\' AND (Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(publicToCust)+'\' OR Core_IPS_Case_Comment_Type__c= \''+String.escapeSingleQuotes(privateToPartner)+'\' OR Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(privateToIntel)+'\') ORDER BY CreatedDate DESC NULLS LAST';  // removed limit & offset
            } else {
                query = query  + 'where Core_IPS_Case__c=\''+String.escapeSingleQuotes(caseId)+'\' AND (Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(publicToCust)+'\' OR Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(privateToPartner)+'\' OR Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(privateToIntel)+'\') ORDER BY CreatedDate DESC NULLS LAST limit :numberLimit offset :counter';    // limit and offset was aded by venki for pagination        
            }
        } else if(ExtUser) {            externalColumn = true; 
            if(String.isNotBlank(pageURL) && pageURL.containsIgnoreCase(EXPORT_PDF_PAGENAME)) {
                query = query  + 'where Core_IPS_Case__c=\''+String.escapeSingleQuotes(caseId)+'\' and Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(publicToCust)+'\' ORDER BY CreatedDate DESC NULLS LAST';   // removed limit & offset
            } else {
                query = query  + 'where Core_IPS_Case__c=\''+String.escapeSingleQuotes(caseId)+'\' and Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(publicToCust)+'\' ORDER BY CreatedDate DESC NULLS LAST limit :numberLimit offset :counter';    // limit and offset was aded by venki for pagination];      // Added by Prem CreatedBy.Email to this query because we are accessing email from visualforce page  
            }
        } else if(partnerProf.contains(String.valueOf(userinfo.getProfileId()).substring(0,15))&& partnerType != 'Partner') {
            if(String.isNotBlank(pageURL) && pageURL.containsIgnoreCase(EXPORT_PDF_PAGENAME)) {
                query = query  + 'where Core_IPS_Case__c=\''+String.escapeSingleQuotes(caseId)+'\' and (Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(publicToCust)+'\' OR Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(privateToPartner)+'\') ORDER BY CreatedDate DESC NULLS LAST';       // removed limit & offset
            } else {
                query = query  + 'where Core_IPS_Case__c=\''+String.escapeSingleQuotes(caseId)+'\' and (Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(publicToCust)+'\' OR Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(privateToPartner)+'\') ORDER BY CreatedDate DESC NULLS LAST limit :numberLimit offset :counter';                        
            }
        } else {
            if(String.isNotBlank(pageURL) && pageURL.containsIgnoreCase(EXPORT_PDF_PAGENAME)) {
                query = query  +  'where Core_IPS_Case__c=\''+String.escapeSingleQuotes(caseId)+'\' and Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(publicToCust)+'\' ORDER BY CreatedDate DESC NULLS LAST';       // removed limit & offset
            } else {
                query = query  +  'where Core_IPS_Case__c=\''+String.escapeSingleQuotes(caseId)+'\' and Core_IPS_Case_Comment_Type__c=\''+String.escapeSingleQuotes(publicToCust)+'\' ORDER BY CreatedDate DESC NULLS LAST limit :numberLimit offset :counter';       
            }
        }
        return Database.query(query);
    }
    //Authored by fields end for US108037
    /***********  added by venki for pagination as per DEF:23171 6/4/2017 ****/
    
    public Boolean getdisableprevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0){ return true; }
        else{ return false;}
    }
    public Boolean getdisbaleNext() { //this will disable the next and end buttons
        if (counter + numberLimit < total_size){ return true; }
        else{ return false;} 
    }
    public Integer getTotal_size() {
        return total_size;
    }
    public Integer getPageNumber() {
        return counter/numberLimit + 1;
    }
    
    public Integer getTotalPages() {
        if (math.mod(total_size, numberLimit) > 0) {
            return total_size/numberLimit + 1;
        }else {
            return (total_size/numberLimit);
        }       
    }
    public void next(){  
        Counter += numberLimit;
        
        // init();    
    }
    public void Previous(){
        counter -= numberLimit;
        //init();
    }
    
    public void showRecords() {  
        counter=0;
    }
    
    //*********** edn added by venki******/ 
    /***************************************************************************************************************************************************************
@ Author: Venki
@ Purpose: US60988
@ Description: for displaying the case attachment, if no records foun displayed message in UI as No Reocrds
@ Refered: in page
****************************************************************************************************************************************************************/
    public boolean getcaseattDisable(){   
        integer caseatt=[select count() from Core_IPS_Case_Attachments__c where Core_Case__c=: newcase.id];       
        return caseatt>0? true:false;
    }
    /********************************************************************************************************************************************************************************************************
@Author: Venki
@Purpose: US60988
@Description: for displaying the case intetersted Parties, if no records foun displayed message in UI as No Reocrds
@Refered: in Page
***********************************************************************************************************************************************************************************************************/
    
    public boolean  getcaseintDisable(){       
        integer caseatt=[select count() from Core_IPS_Case_Interested_Party__c where Case__c=: NewCase.id];         
        return caseatt>0? true:false;
    }   
    
    
    /***************************************************************************************************
Method Name    :  search()
US no          :  US101113
Version        :  1.0 
Created Date   :  30/3/2018
Function       :  Returns list of comment records based on the search string
Modification Log :
*Developer                 Date                    Description
* ----------------------------------------------------------------------------                 
* Aparna                 4/4/2018               Created
****************************************************************************************************/
    // fired when the search button is clicked
    public void search() {
        
        cmtResults=new List<Core_IPS_Case_Comments__c>();
        
        if(partnerAgentUser || userhasAccess){   
            //FLS Check Added - Madhuri
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){
            cmtResults= [select id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Name,Core_IPS_Comment__c,CreatedBy.Account.Name,Core_IPS_Rich_Comment__c,CreatedBy.Contact.Account.name,CreatedBy.Profile.Name,CreatedBy.Firstname,CreatedBy.Profileid,
                         CreatedDate,Core_IPS_BgColor__c,Core_IPS_NickName__c,CreatedBy_Name__c,
                         Core_IPS_Case_Comment_Type__c ,CreatedBy.Email,Core_IPS_Comment_Author_Type__c,Core_IPS_Comment_Authored_By__r.Name,Core_IPS_Comment_Authored_By__r.Account.name,Core_IPS_Comment_Authored_By_Email__c,Core_IPS_Comment_Authored_By_FirstName__c,Core_IPS_Comment_Authored_By_Name__c
                         from Core_IPS_Case_Comments__c 
                         where Core_IPS_Case__c=:newCase.id 
                         ORDER BY CreatedDate DESC NULLS LAST ];  
            }
        }        
        else if(!(ExternalUser) || (partnerAgentUser)){  
            //FLS Check Added - Madhuri
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){
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
            //FLS Check Added - Madhuri
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){
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
            //FLS Check Added - Madhuri
            if(Core_IPS_Case_Comments__c.SObjectType.getDescribe().isAccessible()){
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
            if(cmtResults!=null && cmtResults.size()>0 && !String.isBlank(searchText))
            {
                for(Core_IPS_Case_Comments__c objCmt : cmtResults)
                {
                    if(objCmt.Core_IPS_Comment__c != Null && objCmt.Core_IPS_Comment__c.containsIgnoreCase(searchText)){
                        searchCmt.add(objCmt);
                      }
                }
            }
            searched=true;
            
        }catch(Exception ex){
        }
    } 
    
    /***************************************************************************************************
Method Name    :  clear()
US no          :  US101113
Version        :  1.0 
Created Date   :  30/3/2018
Function       :  Returns list of all comment records 
Modification Log :
*Developer                 Date                    Description
* ----------------------------------------------------------------------------                 
* Aparna                 4/4/2018                   Created
****************************************************************************************************/
    //fired when reset button is clicked 
    public void clearSearch(){
        
        try{
            if(searchCmt != null)
            {
                searchCmt.clear();
                searched = false;
                searchText = '';
                Counter = 0;
            }
        }catch(Exception ex){}
    } 
}