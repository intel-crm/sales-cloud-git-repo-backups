public class Core_IPS_Detail_Comments{
    
      public Static Case newcase = new Case();
    public Static List<Core_IPS_Case_Comments__c> commentRecords;
    public Static Integer CommentsLimit = Integer.valueof(system.label.Core_IPS_CaseComments_Limit);   
    public string contentType{get;set;}
   // public String LogUserCon{get;set;}
    
    public Map<Id,User> UserMap{get;set;} //Added By Manoj

    Public boolean externalUser{get;set;}    
    public Boolean userHasAccess{get;set;}
    public static string PRIVATE_TO_AGENTS{get;set;}{PRIVATE_TO_AGENTS= Core_IPS_Labels__c.getValues('PRIVATE_TO_AGENTS').value__c;}
    public static string PUBLIC_TO_CUSTOMERS{get;set;}{PUBLIC_TO_CUSTOMERS=Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;}
    public static string PRIVATE_TO_INTEL{get;set;}{PRIVATE_TO_INTEL=Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;}
    
     //*********** stat added by venki for pagination as per DEF:23171 6/4/2017****
    
     public integer count{get;set;}
     private integer counter=0;  //keeps track of the offset
     private integer list_size; //sets the page size or number of rows
     public integer total_size; //used to show user the total size of the list
     
     
     
    public Core_IPS_Detail_Comments(ApexPages.StandardController controller) {        
        newCase=(Case)controller.getRecord();
               
        externalUser=Network.getNetworkId() != null? true:false; // added by venki for identifying customer user 2/8/17

        userHasAccess = Label.Core_IPS_Agent_Profiles.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));
        
         // Total_size is seperated for internal and external user 
        if(!(externalUser)){
                total_size=[select count() from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id];// added by venki for displaying totapages
        }else{
            total_size=[select count() from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id and Core_IPS_Case_Comment_Type__c=:Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c];
        }
         
         //---------------end-----------------------//

         list_size =Integer.valueOf(Label.Core_IPS_Comments_List_Size) > 0 ? Integer.valueOf(Label.Core_IPS_Comments_List_Size) : 20;  
         
         //---------------end-----------------------//
         
        getcaseComments();       
        
    }     
    public List<Core_IPS_Case_Comments__c> getcaseComments(){
    try{
            if(!externalUser){
                commentRecords = [select id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Account.Name,CreatedBy.Name,Core_IPS_Comment__c,Core_IPS_Rich_Comment__c,createdbyId,CreatedBy.Profileid,CreatedBy.FirstName,
                        CreatedBy_FirstName__c,CreatedBy_Name__c,CreatedDate,Core_IPS_BgColor__c,Core_IPS_Comment_Author_Type__c,Core_IPS_NickName__c,Core_IPS_Migrated_Note_Type__c,CreatedBy.Email,Core_IPS_Case_Comment_Type__c 
                        from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id ORDER BY CreatedDate DESC NULLS LAST Limit :CommentsLimit  offset :counter];      
            }
            else{
                commentRecords = [select id,CreatedBy_Name__c, name,Core_IPS_Comment__c,CreatedBy.Accountid,CreatedBy.Account.Name,Core_IPS_Rich_Comment__c,createdbyId,CreatedBy.ContactId,CreatedBy.Profileid,CreatedBy.FirstName,
                        CreatedDate,CreatedBy_FirstName__c,Core_IPS_Comment_Author_Type__c,Core_IPS_BgColor__c,Core_IPS_Migrated_Note_Type__c,Core_IPS_NickName__c,CreatedBy.Email,CreatedBy.Contact.Account.Name,Core_IPS_Case_Comment_Type__c
                        from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id and Core_IPS_Case_Comment_Type__c=:PUBLIC_TO_CUSTOMERS ORDER BY CreatedDate DESC NULLS LAST Limit :CommentsLimit  offset :counter];        
            }
            return commentRecords;
        }
        catch(exception ex){ Core_IPS_ExceptionHandling.logEntryWithException(ex,'Core_IPS_CommentScreenController.getcaseComments','Case');   return null;}
   }   
       
       
     
    /***********  added by venki for pagination as per DEF:23171 6/4/2017 ****/
     
    public List<Core_IPS_Case_Comments__c> init(){
            return getcaseComments();
            
            
    } 
    
    
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
       init();
      
   }
   public void Previous(){
        counter -= list_size;
        init();
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