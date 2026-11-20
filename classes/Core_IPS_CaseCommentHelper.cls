public with sharing class Core_IPS_CaseCommentHelper {
    public Core_IPS_CaseCommentHelper() {
        
    }
    
    public boolean isNACCase(case currentcase) {
        boolean isNACCase;
        if(currentcase.RecordType.Name == Core_IPS_Helper_Utility.getIPSLabel('Case_RT_Name_IPS_NoAssignedContact')){         
            isNACCase = true;
        }    
        else{ 
            isNACCase = false ;
        }     
        return isNACCase;
        
    }        
    
    public string saveComments(Case currentcase, String visibility, String comment){
        String status = 'Success';
        //added by sugandha for US99039
        Case cs = new Case();
        //If condition modified by Aayushi DE40236
        
        if(currentCase != null && currentCase.Core_Sub_Status__c != Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Close_Pending_SubStatus') && currentCase.Core_IPS_Date_Time_Close_Pending__c != null && Visibility == Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c 
           && (System.Label.Core_IPS_Agent_Profile_Ids.Contains(String.valueOf(userInfo.getprofileId()).substring(0, 15)) || System.Label.Core_IPS_DataOps.contains(String.valueOf(userInfo.getprofileId()).substring(0, 15)))){
               
               cs.Core_IPS_Date_Time_Close_Pending__c = null;
               cs.Id = currentCase.Id;
           }
        //end 
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
        
        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
        Core_IPS_Case_Attachments__c newAttachment = new Core_IPS_Case_Attachments__c();
        if (Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case__c.isCreateable()) {
            newComment.Core_IPS_Case__c = currentCase.id;
        }
        
        newComment.Core_IPS_Rich_Comment__c = comment;     
        newComment.Core_IPS_Case_Comment_Type__c = getVisibility(visibility);
        newComment.Core_IPS_Comment_Authored_By_Name__c = userInfo.getName();
        newComment.Core_IPS_Comment_Authored_By_FirstName__c = userInfo.getFirstName();
        newComment.Core_IPS_Comment_Authored_By_Email__c = userEmail;
        
        if(newComment.Core_IPS_Comment_Attachment_Id__c != null)
            newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId(), newAttachment.Core_FileUploadedBy__c);
        else if(newComment.Core_IPS_Comment_Attachment_Id__c == null)
            newComment.Core_IPS_Comment_Author_Type__c = getAuthr(userInfo.getprofileId(), userinfo.getuserid());
        
        try{
            if(newComment!=null){  
                insert newComment;
                //added by sugandha for US99039
                // Modified for DE55770 - added curly braces to if
                if(cs.Id != null ){  
                    update cs; 
                }
            }
        }catch(Exception e){
            status = 'Error'+e.getMessage()+'';
        }
        return status;
    } 
    
    
    
    public string getUserType(){
        String usertype = '';
        boolean partnerUser = Label.Core_Partner_Profile_Id.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));       
        boolean partnerAgentUser = Label.Core_IPS_Agent_Partner_Profile_id.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));     
        boolean externalUser = Network.getNetWorkid() != null? True:false;
        
        if(partnerUser)
            usertype = 'Partner';
        else if(partnerAgentUser)
            usertype = 'Partner Agent';
        else if(externalUser)
            usertype = 'External User';    
        
        return usertype;
    } 
    
    public string getPartnerType(){
        String partnerType = '';
        String authrPartnerType = Core_Utility.getPartnerUserType(userinfo.getuserid()); 
        if(authrPartnerType != null){
            if(authrPartnerType.split(';').size()>0)                
                partnerType = authrPartnerType.split(';')[0];                 
        }
        return partnerType;
    }
    public string getVisibility(string defiendVisibility){
        string visibility ;
        UserProperties UP = new UserProperties();
        if( up.partnerType =='Partner'){               
            visibility = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;   
        }    
        if( defiendVisibility != null ){         
            if(UP.partnerUser ){
                Visibility = defiendVisibility; 
            }
            else if(!( UP.externalUser) || (UP.partnerAgentUser)){      
                Visibility = defiendVisibility;           
            }
            else {
                Visibility = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
            }
            
        }
        return visibility;
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
        
        else if(Core_IPS_DataMigrationUser_Validation.isIPSDatamigrationUser(Userid) == true){ //TWC745-6044 -Merging IPS Data Migration Profile to generic profile -CCP Core Access
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
    
    
}