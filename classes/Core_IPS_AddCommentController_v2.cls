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
    * Sumukh                        11/08/2017              MODIFIED as part of - US67444,US67633,US83446,US83924
    ****************************************************************************************************/ 
public class Core_IPS_AddCommentController_v2{
    
    public Case newcase{get;set;}
    public id urlid;
    public String ProfileName = System.Label.Core_IPS_Profile_Name;
    public String profId {get;set;}
    public List<String> selectedVisibilityOption{get;set;}
    public List<SelectOption> VisibilityOptions{get;set;}
    //public Boolean InternalOnlyOptions{get;set;}
    public Boolean InternalColumn{get;set;}
    public Boolean ExternalColumn{get;set;}
    public Boolean ShowRadioButton{get;set;}
    public boolean disableAccess{get;set;}
  
  // Added for Partner Changes by sumukh for I-7 Release 4
    
    public String PartnerProf{get;set;}{PartnerProf  = System.Label.Core_IPS_Partner_Profile_Id;}
    public String Extprof{get;set;}{Extprof =  System.Label.Core_IPS_External_Customer_Profile_Ids;}
    public boolean ExtUser{get;set;}
    public String partnerAgent{get;set;}{partnerAgent= System.Label.Core_IPS_Agent_Partner_Profile_id;}  
    Public String prtCust = System.Label.Core_IPS_Partner_Customer_Permission_Set;
    Public String prtDFAE = System.Label.Core_IPS_Partner_DFAE_Permission_Set; 
    public Boolean partnerAgentUser{get;set;}
    public PermissionSetAssignment partDFAEUser{get;set;}
    public PermissionSetAssignment partCustUser{get;set;}

    //{user stpry#:US67444 Iteration#:PSG Release 2 Developer Name:Sumukh}
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
     private integer counter=0;  //keeps track of the offset
     public integer list_size{get;set;} //sets the page size or number of rows
     public integer total_size{get;set;} //used to show user the total size of the list
     public String partnerType{get;set;}
     /*---------end-----------*/
     
    //Number of records to be displayed per page
    public integer numberLimit{get;set;}{numberLimit=5;}
    public list<selectOption> records{get;set;}{
    
        records=new List<selectOption>();
        records.add(new selectoption('5','5'));
        records.add(new selectoption('10','10'));        
        records.add(new selectoption('20','20'));
        records.add(new selectoption('30','30'));
        records.add(new selectoption('40','40'));
   
    }
    
    
    //public String selectedRadioButton {get;set;}{selectedRadioButton = 'Public to Customers';}
    
    //{user stpry#:US67444 / US83924 , Iteration#:PSG Release 2 / Release 4 (Partner changes) ,Developer Name:Sumukh} 
    public String selectedRadioButton {get;set;}
    {   
        // Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();    
         if(Extprof.contains(String.valueOf(userinfo.getProfileId()).substring(0,15))){
            
            selectedRadioButton = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
            
         
         }                    
        
        else if(PartnerProf.contains(String.valueOf(userinfo.getProfileId()).substring(0,15))){
                       
            String authrPartnerType= Core_Utility.getPartnerUserType(userinfo.getuserid()); 
             if(authrPartnerType.length()>0){
               partnerType = authrPartnerType.split(';')[0];
             }          
              system.debug('partner-author type'+ partnerType );                                   
            if(partnerType !=null && String.isNotBlank(partnerType)){
                
                if(partnerType == 'Partner - DFAE'){
                   selectedRadioButton = Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;
                   
                  }
                else if(partnerType == 'Partner'){
                 selectedRadioButton = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
                 system.debug(' radio btn '+ selectedRadioButton );
                
                }
              }
            }
        else if(!externalUser) {
            selectedRadioButton = Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;
          }       
     }
    
    public pageReference showRecords(){
        return null;
    }
    
    public Core_IPS_AddCommentController_v2(ApexPages.StandardController controller) {  
                 
         system.debug('radio btn 1'+ selectedRadioButton );
                 
        disableAccess = false;       
        urlid = apexpages.currentpage().getparameters().get('id');
        profId = String.valueOf(userInfo.getProfileId().substring(0,15));
        if(urlid !=null)
        newCase=[select id,subject,Core_IPS_Comment__c,RecordType.Name,AccountId,Core_Sub_Status__c,status,CreatedBy.Email,contactid from Case where id =:urlid ];        
        
        loggedInUserProf =[select id,name from Profile where id=:userInfo.getProfileId()]; 
        
        //Added by sumukh for partner comments I-7 R4.
        system.debug(' Partner cust permissin set '+ prtCust+prtDFAE  );
        
        try{             
            partCustUser  = [Select id,AssigneeId  from PermissionSetAssignment where AssigneeId =: userInfo.getUserId() and PermissionSetId =:prtCust LIMIT 1];                       
            system.debug(' Partner customer user '+ partCustUser );
           }
        Catch(Exception e){
             system.debug('exception @'+e.getLineNumber()+'\n msg:'+e.getMessage());       
          }
        
       try{       
            partDFAEUser  = [Select id,AssigneeId  from PermissionSetAssignment where AssigneeId =: userInfo.getUserId() and PermissionSetId =:prtDFAE LIMIT 1]; 
            system.debug(' Partner DFAE user '+ partDFAEUser  );                  
          }
        Catch(Exception e){
            system.debug('exception11 @'+e.getLineNumber()+'\n msg:'+e.getMessage());       
          }
        
        partnerUser       =  Label.Core_Partner_Profile_Id.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));       
        partnerAgentUser  =  Label.Core_IPS_Agent_Partner_Profile_id.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));   
        
        //system.debug( 'Partner user'+  partnersCustUser  );    
        
        ExtUser      =  Extprof.contains(profId);               
        userHasAccess =  Label.Core_IPS_Agent_Profiles.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));
             
        InternalColumn= false;
        ExternalColumn= false;
        
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
        if(loggedInUserProf.name!= ProfileName && !(externalUser)){
            List<String> caseAccessLevel = new List<String>();
            caseAccessLevel.add(Core_IPS_Helper_Utility.getIPSLabel('AccessLevel_Read'));
            caseAccessLevel.add(Core_IPS_Helper_Utility.getIPSLabel('AccessLevel_Edit'));
            Set<Id> userIdSet = new Set<id>();
            
            if(newCase.AccountId!=null){
            List<AccountShare> acctShare = [select accountId, caseaccesslevel, userOrGroupId from accountshare where caseAccessLevel IN: caseAccessLevel and accountId =: newCase.AccountId and userOrGroupId =: userInfo.getUserId()];
           if(acctShare.size()!=0) {
            for(AccountShare share: acctShare){ String userId = share.userOrGroupId;

                if(userId <> null && userId.startsWith('005')){ userIdSet.add(share.userOrGroupId);

                }
            }
            if(userIdSet == null && userIdSet.size() == 0){ disableAccess = true;
               
            }
        }
      }
   }
        /*************** added by venki for  DEF:23171 6/4/2017******************/
        
        /*************** added By Prem for External Pagination US92252 ******************/
        // Total_size is seperated for internal and external user 
        
        if(!(externalUser)){
                total_size=[select count() from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id];// added by venki for displaying totapages
               
        }else if(PartnerProf.contains(String.valueOf(userinfo.getProfileId()).substring(0,15))){
            total_size=[select count() from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id and (Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c OR Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c )];
        }else{
         total_size=[select count() from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id and Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c];
        }
         //---------------end-----------------------//
         String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
         if(pageName.contains('Core_IPS_AddComment')){
         list_size =Integer.valueOf(Label.Core_IPS_Comments_List_Size) > 0 ? Integer.valueOf(Label.Core_IPS_Comments_List_Size) : 20;  
         }else{
         list_size = numberLimit;
         }
         
         //---------------end-----------------------//
         system.debug('radio btn 2'+ selectedRadioButton );
    }
    
    
    
  
  //{user stpry#:US67444 Iteration#:PSG Release 2 Developer Name:Sumukh}
     
    public PageReference saveComment(){
    
            system.debug(' Partner type value'+ partnerType  );
             Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();  
             
            if(partnerType =='Partner'){
                
                selectedRadioButton = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;     
            }
          
          
       
        newComment.Core_IPS_Case__c=newCase.id;        
        newComment.Core_IPS_Rich_Comment__c=newCase.Core_IPS_Comment__c;
                
        system.debug(' entry point #####################' + selectedRadioButton);
        
        if( selectedRadioButton!=null )
        {          
         if(partnerUser){
             system.debug('is partner user ?'+partnerUser);
             newComment.Core_IPS_Case_Comment_Type__c = selectedRadioButton; 
           }
         else if(!externalUser){
          newComment.Core_IPS_Case_Comment_Type__c = selectedRadioButton;        
         }
         else {
          newComment.Core_IPS_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
         }
        newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId());
       
         
        try{
            if(newComment!=null){
            insert newComment;
            system.debug('new Comment'+newComment);
            }
          }
        catch(Exception e){
            system.debug('exception @'+e.getLineNumber()+'\n msg:'+e.getMessage());
          }
        } 
        return new PageReference('/'+newCase.id);
        
     }
    
    
    //Identifies and Maps the logged in User with Author Type
    public static String getAuthr(String loggedUserId){
        String authroTyp='';
        if(Label.Core_IPS_External_Customer_Profile_Ids.contains(loggedUserId.substring(0,15))){
           return authroTyp=Core_IPS_Labels__c.getValues('Customer').value__c; 
        }
        else if(Label.Core_IPS_SalesRep_ProfileIds.contains(loggedUserId.substring(0,15))){
           return authroTyp=Core_IPS_Labels__c.getValues('FAE').value__c;
        }
        else if(Label.Core_IPS_Agent_Profiles.contains(loggedUserId.substring(0,15))){
           return authroTyp=Core_IPS_Labels__c.getValues('Agent').value__c;
        }
        else if(Label.Core_IPS_Data_Migration_ProfileId.contains(loggedUserId.substring(0,15))){
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
            partnerAuthrType  = Core_Utility.getPartnerUserType(userinfo.getuserid());
             if(partnerAuthrType!=null){
                if(partnerAuthrType.split(';').size()>0)
                partnerType1 = partnerAuthrType.split(';')[0];
             }
            if(partnerType1 !=null && String.isNotBlank(partnerType1 )){
                return authroTyp= partnerType1 ;
            }else{
                return authroTyp=Core_IPS_Labels__c.getValues('Partner').value__c;
            }
        }
        
             
        
        return null;        
    }

    public List<Core_IPS_Case_Comments__c> getcaseComments(){
    
        //Profile p =[select id,name from Profile where id=:userInfo.getProfileId()];
        if(!(ExternalUser) || (partnerAgentUser)){           
            InternalColumn = true;
            return [select id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Name,Core_IPS_Comment__c,CreatedBy.Account.Name,Core_IPS_Rich_Comment__c,CreatedBy.Contact.Account.name,CreatedBy.Profile.Name,CreatedBy.Firstname,CreatedBy.Profileid,
                    CreatedDate,Core_IPS_BgColor__c,Core_IPS_NickName__c,CreatedBy_Name__c,
                    Core_IPS_Case_Comment_Type__c ,CreatedBy.Email,Core_IPS_Comment_Author_Type__c
                    from Core_IPS_Case_Comments__c 
                    where Core_IPS_Case__c=:newCase.id
                    ORDER BY CreatedDate DESC NULLS LAST
                    limit :numberLimit
                    offset :counter ];    // limit and offset was aded by venki for pagination        
        }        
             
        else if(ExtUser){
            ExternalColumn = true;
            return [select id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Name,CreatedBy.Account.Name,Core_IPS_Comment__c,Core_IPS_Rich_Comment__c,CreatedBy.Profile.Name,CreatedDate,CreatedBy.Firstname,CreatedBy.Profileid,
                    Core_IPS_BgColor__c,Core_IPS_NickName__c,CreatedBy.Email, CreatedBy.Contact.Account.Name,CreatedBy_Name__c,
                    Core_IPS_Case_Comment_Type__c,Core_IPS_Comment_Author_Type__c,Core_IPS_Case__r.Contact.Account.name 
                    from Core_IPS_Case_Comments__c 
                    where Core_IPS_Case__c=:newCase.id and Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c 
                    ORDER BY CreatedDate DESC NULLS LAST
                    limit :numberLimit 
                    offset :counter ];    // limit and offset was aded by venki for pagination];      // Added by Prem CreatedBy.Email to this query because we are accessing email from visualforce page  
        }
        else if(PartnerProf.contains(String.valueOf(userinfo.getProfileId()).substring(0,15))){
            return [select id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Name,CreatedBy.Account.Name,Core_IPS_Comment__c,Core_IPS_Rich_Comment__c,CreatedBy.Profile.Name,CreatedDate,CreatedBy.Firstname,CreatedBy.Profileid,
                    Core_IPS_BgColor__c,Core_IPS_NickName__c,CreatedBy.Email, CreatedBy.Contact.Account.Name,CreatedBy_Name__c,
                    Core_IPS_Case_Comment_Type__c,Core_IPS_Comment_Author_Type__c,Core_IPS_Case__r.Contact.Account.name 
                    from Core_IPS_Case_Comments__c 
                    where Core_IPS_Case__c=:newCase.id and (Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c OR Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c ) 
                    ORDER BY CreatedDate DESC NULLS LAST
                    limit :numberLimit 
                    offset :counter ];                 
        }
        else {
         return [select id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Name,CreatedBy.Account.Name,Core_IPS_Comment__c,Core_IPS_Rich_Comment__c,CreatedBy.Profile.Name,CreatedDate,CreatedBy.Firstname,CreatedBy.Profileid,
                    Core_IPS_BgColor__c,Core_IPS_NickName__c,CreatedBy.Email, CreatedBy.Contact.Account.Name,CreatedBy_Name__c,
                    Core_IPS_Case_Comment_Type__c,Core_IPS_Comment_Author_Type__c,Core_IPS_Case__r.Contact.Account.name 
                    from Core_IPS_Case_Comments__c 
                    where Core_IPS_Case__c=:newCase.id and Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c 
                    ORDER BY CreatedDate DESC NULLS LAST
                    limit :numberLimit 
                    offset :counter ];
        
        }
    }
    
     
     
    /***********  added by venki for pagination as per DEF:23171 6/4/2017 ****/
     
     
    
    
    public Boolean getdisableprevious() { 
      //this will disable the previous and beginning buttons
      if (counter>0) return true; else return false;
    }
    public Boolean getdisbaleNext() { //this will disable the next and end buttons
      if (counter + list_size < total_size) return true; else return false;
    }
    public Integer getTotal_size() {
      return total_size;
    }
    public Integer getPageNumber() {
      return counter/list_size + 1;
    }
    
    public Integer getTotalPages() {
      if (math.mod(total_size, list_size) > 0) {
         return total_size/list_size + 1;
      } else {
         return (total_size/list_size);
      }
      
         
   }
   public void next(){
   
       Counter += list_size;
      // init();
      
   }
   public void Previous(){
        counter -= list_size;
        //init();
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
    
}