/***************************************************************************************************
Apex Class Name:  Core_IPS_CaseComment_EmailHandler
Version     : 1.0 
Created Date: 15 Oct 2017
Function    : Email Handler class for Case Comment creation through email 
Used By     : Core_IPS_AddCaseComment Email service
Test Class  : Core_IPS_CaseComment_EmailHandler_Test 
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------                 
* Gourav Anand                 15/10/2017              Created
****************************************************************************************************/

global class Core_IPS_CaseComment_EmailHandlerv2 implements Messaging.InboundEmailHandler {
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
         
         Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
         String temp_comment_htmlBody = email.htmlBody;
         String temp_comment_plainBody = email.plainTextBody;
         String caseId='';
         String extUserProfileName = System.Label.Core_IPS_Profile_Name; 
         String caseCommentType='';
         String authorType=''; 
         Boolean isNoteFromCustomer = false; 
         //temp_comment_plainBody=temp_comment_plainBody.replaceAll('(\\r|\\n)+', '**'); 
         String fromAdd = envelope.fromAddress;
         String[] ccAddr = email.ccAddresses;
         System.debug('----------------------------------->>> Cc addresses:'+ccAddr); 
          
         User usr = null;
         User[] userList= [Select Id, Name, ProfileId, Profile.Name,isActive from User where Email=:fromAdd ] ;
         System.debug('----------------->>>>Email sender userList:'+userList); 
         if(userList.size() <> 0){
          //To fetch firstuser if more than one users   
          usr = userList[0];    
          System.debug('----------------->>>>Email sender user details=:{UserId:'+usr.Id+'; Name:'+usr.Name+'; User Profile:'+usr.Profile.Name+'; ProfileId:'+usr.ProfileId+'}');     
         } 
         
         //Case Number and Id extract from email subject
         String mailSubj = email.subject;
         String caseRefId ='';
         String commentType=''; 
         if(String.isNotBlank(mailSubj) && mailSubj !=NULL){
             if(mailSubj.contains('[500') && mailSubj.endsWith(']')){ 
                List<String> splitmailSubj = mailSubj.split(' ');
                caseRefId = splitmailSubj.size()>3 ? splitmailSubj.get(splitmailSubj.size()-2).substring(1):''; 
                commentType=splitmailSubj.size()>3 ? splitmailSubj.get(splitmailSubj.size()-1).substring(0,2):''; 
             }     
         }
         
                
         system.debug('==============+++=========>CaseRef id:'+caseRefId); 
         system.debug('==============+++=========>Type:'+commentType); 
         
         if(commentType=='x0') caseCommentType=Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
         else if (commentType=='x1') caseCommentType=Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;
         else if (commentType=='x2') caseCommentType=Core_IPS_Labels__c.getValues('PRIVATE_TO_AGENTS').value__c;
         else if (commentType=='x3') caseCommentType=Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;
         else if (commentType=='xx') caseCommentType=Core_IPS_Labels__c.getValues('NO_PROCESSING').value__c; 
          
         Case[] mailCase = [Select Id,CaseNumber, isClosed,ContactId from Case where Id =:caseRefId ]; 
         Core_IPS_Case_Comments__c comment = new Core_IPS_Case_Comments__c();
         
         temp_comment_htmlBody = temp_comment_htmlBody.substringBefore('From:');   
         if(fromAdd.contains('intel.com'))
            temp_comment_htmlBody = temp_comment_htmlBody.substringBefore('From:');
         else 
            temp_comment_htmlBody = temp_comment_htmlBody.substringBefore('On');
         
         //Calling method to encrypt rich comment text for updating comment
         /*
          if(Core_IPS_Feature_Toggle__c.getValues('SkyHighCommentEncryption').Core_Feature_Enabled__c)    
            temp_comment_htmlBody = Core_IPS_CaseComment_EmailHandlerService.encryptCaseComment(temp_comment_htmlBody);
         */  
         system.debug('====+++========== email ToAddresses size=:'+email.toAddresses.size()+'; mailCase.size()='+mailCase.size()+'; temp_comment_htmlBody:'+temp_comment_htmlBody);  
         if(email.toAddresses != null && email.toAddresses.size()==1 && ccAddr==null && mailCase.size()<>0 && !mailCase[0].IsClosed && usr.IsActive && (caseCommentType!='No Processing' && caseCommentType !='') && temp_comment_htmlBody !='Encryption Failed'){  
          system.debug('==++++============= Processing Email service for Case Comment ==++++=========='); 
          
          
        /********************************************************************************************
           Logic to implement case comment type and Author Type based on email sender's Profile 
        * ******************************************************************************************/   
        Set<string> prflNameSet = new Set<string>();
        prflNameSet.addAll(Label.Core_IPS_NotetoCustomer_ProfileSet.split(';'));
        
        
        // Added for US83446 comment author type
        String userprofileid = usr.ProfileId;
        System.debug('login user profileId1--------------->'+userprofileid);
        System.debug('Sales Profile'+Label.Core_IPS_SalesRep_ProfileIds);
         
         
        if(String.valueOf(userprofileid).length()==18){
              userprofileid =String.valueOf(userprofileid).substring(0,15);
        }
        System.debug('email sender profileId--------------->'+userprofileid);
        if(Label.Core_IPS_External_Customer_Profile_Id.contains(userprofileid)){
           authorType=Core_IPS_Labels__c.getValues('Customer').value__c; 
        }
        else if(Label.Core_IPS_SalesRep_ProfileIds.contains(userprofileid)){
           authorType=Core_IPS_Labels__c.getValues('FAE').value__c;
        }
        else if(Label.Core_IPS_Agent_Profiles.contains(userprofileid)){
           authorType=Core_IPS_Labels__c.getValues('Agent').value__c;
        } 
        //Need to update create Profile Id Label for Partner profile
        else if(Label.Core_IPS_Partner_Profile_Name.contains(userprofileid)){
           authorType=Core_IPS_Labels__c.getValues('Partner').value__c;
        }     
        
        System.debug('email sender caseCommentType--------------->'+authorType);    
        comment = Core_IPS_CaseComment_EmailHandlerService.createCaseComment(temp_comment_htmlBody, caseCommentType, authorType, usr, caseRefId);
                    
        //Processing inline image attachments and updating the rich text field with image
        if(email.binaryAttachments != null){
            system.debug('=============================================------------->binaryAttachments.size()='+email.binaryAttachments.size());
            Core_IPS_CaseComment_EmailHandlerService.processBinaryAttachment(email, comment) ; 
        } 
          
        result.success=true;       
        return result;
       
        }
          
        else {
          System.debug('--------Block the multi recipients email processing------------');  
          
            if(mailCase!=null && mailCase.size()<>0){
                result.success =Core_IPS_CaseComment_EmailHandlerService.sendExceptionEmailUpdate(fromAdd, mailCase[0], usr);
            }else{
                result.success = false;
            }
          
          //result.message='This email can not be processed as there are multiple recipients of this email!';
          return result;   
      }
    }
  }