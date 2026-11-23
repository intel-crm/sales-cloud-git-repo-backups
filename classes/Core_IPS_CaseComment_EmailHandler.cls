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
* Amritesh                     22/01/2017              Modified - Improved matching pattern
* Karthick                     02/02/2018              Modified - Handled exception
* Karthick                     24/02/2018              Modified - Handled PlainTextVersion
* Amritesh                     08/03/2018              Modified - Included Skip Criteria
* Karthick                     28/03/2018              Modified - Handled email reply with auto cc
* Sumukh                       06/06/2018              Modified - Handled for comment source field I-12, R-4.3, US-105428 
* Aayushi					   23/10/2018			   Modified - Moved Skip Email Keywords to Custom Setting US198844
****************************************************************************************************/

global class Core_IPS_CaseComment_EmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
       // System.debug('----------------------------------->>> email.htmlBody:'+email.htmlBody); 
        String temp_comment_htmlBody = email.htmlBody;
        String temp_comment_plainBody = email.plainTextBody;
        String mailSubj = email.subject;
        String caseId='';
        //String extUserProfileName = System.Label.Core_IPS_Profile_Name; 
        String caseCommentType='';
        String authorType=''; 
        //Boolean isNoteFromCustomer = false; 
        Boolean isSkipEmail = false;
        //Commented below line as SkipEmail Keywords moved from Label to Custom Setting US198844
        //String skipEmail_Keywords = System.Label.Core_IPS_SkipEmail_Keywords;
        temp_comment_plainBody=(String.isNotBlank(temp_comment_plainBody))?temp_comment_plainBody.replaceAll('(\\r|\\n)', '<br/>'):''; 
        
        if(String.isBlank(temp_comment_htmlBody)){
            temp_comment_htmlBody = temp_comment_plainBody;
        }            
        
        String fromAdd = email.fromAddress;
        String[] ccAddr = email.ccAddresses;
        
        
       // System.debug('----------------------------------->>> temp_comment_htmlBody:'+temp_comment_htmlBody); 
        
        //Commented below lines as SkipEmail Keywords moved from Label to Custom Setting US198844
       // if(String.isNotBlank(skipEmail_Keywords) && String.isNotBlank(mailSubj)) {
            //List<String> lstEmailSkipKeywords = skipEmail_Keywords.split('\n');
            //start added by Aayushi US198844
            List<String> lstEmailSkipKeywords=new List<String>();
        for(Core_IPS_SkipEmail_Keywords__c skipKeyword: Core_IPS_SkipEmail_Keywords__c.getall().values()){
           lstEmailSkipKeywords.add(skipKeyword.Value__c); 
        }	//end
            if(lstEmailSkipKeywords!=null && lstEmailSkipKeywords.size() > 0) {
                for(String strKeyWord : lstEmailSkipKeywords) {
                    if(String.isBlank(strKeyWord)) continue;
                    mailSubj = mailSubj.trim();
                    strKeyWord = strKeyWord.trim();
                   // System.debug('------After trim strKeyWord:::'+strKeyWord);
                    if(mailSubj.startsWith(strKeyWord)) {
                        isSkipEmail = true;
                        result.success=true;       
                        return result;
                    }
                }
            }
        //}
        
        //Handled Auto Copy themeselves on Email Reply - US99017 - I9- R4.2
        //System.debug('----------------------------------->>> Cc addresses:'+ccAddr); 
        //System.debug('----------------------------------->>> fromAdd:'+fromAdd); 
        if(ccAddr!=null && ccAddr.size()==1 && fromAdd.equals(ccAddr[0]))
            ccAddr = null;
        
        //System.debug('------------After clearing ccAddr----------->>> Cc addresses:'+ccAddr);
        
        User usr = null;
        User[] userList= [Select Id, Name, ProfileId, Profile.Name,isActive from User where Email=:fromAdd ORDER BY isActive DESC] ;
        //System.debug('----------------->>>>Email sender userList:'+userList); 
        if(userList!=null && userList.size() <> 0) {
            //To fetch firstuser if more than one users   
            usr = userList[0];    
            //System.debug('----------------->>>>Email sender user details=:{UserId:'+usr.Id+'; Name:'+usr.Name+'; User Profile:'+usr.Profile.Name+'; ProfileId:'+usr.ProfileId+'}');     
        } else {            
            User[] portalUsrList= [Select Id, Name, ProfileId, Profile.Name,isActive from User where Contact.Email=:fromAdd ORDER BY isActive DESC] ;
            //System.debug('----------------->>>>portalUsrList:'+portalUsrList);
            if(portalUsrList!=null && portalUsrList.size() <> 0){
                //To fetch first portal user if more than one users   
                usr = portalUsrList[0];    
                //System.debug('----------------->>>>Email sender user details=:{UserId:'+usr.Id+'; Name:'+usr.Name+'; User Profile:'+usr.Profile.Name+'; ProfileId:'+usr.ProfileId+'}');     
            }
        }
         
        
        //Case Number and Id extract from email subject
        String caseRefId ='';
        String commentType=''; 
        if(String.isNotBlank(mailSubj) && mailSubj !=NULL){
            pattern myPattern = pattern.compile('(\\[500[a-zA-Z0-9]+[\\s]?\\])'); //pattern.compile('(\\[500[a-zA-Z0-9]+[\\s]?x[x0-9]\\])'); 
            matcher myMatcher = myPattern.matcher(mailSubj);
            //system.debug('==============+++=========>mailSubj:'+mailSubj); 
            if(myMatcher.find()) {
                String refTag = myMatcher.group(myMatcher.groupCount()-1);
                //system.debug('==============+++=========>refTag:'+refTag); 
                if(refTag.contains(' ')) refTag = refTag.remove(' ');
                caseRefId = refTag.substring(1, 16);
                commentType = refTag.substring(refTag.length()-3, refTag.length()-1);
            }             
            /*
            if(mailSubj.contains('[500') && mailSubj.endsWith(']')){ 
            List<String> splitmailSubj = mailSubj.split(' ');
            caseRefId = splitmailSubj.size()>3 ? splitmailSubj.get(splitmailSubj.size()-2).substring(1):''; 
            commentType=splitmailSubj.size()>3 ? splitmailSubj.get(splitmailSubj.size()-1).substring(0,2):''; 
            }     
            */
        }
                
        //system.debug('==============+++=========>CaseRef id:'+caseRefId); 
        //system.debug('==============+++=========>Type:'+commentType); 
        
        if(commentType=='x0') caseCommentType=Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
        else if (commentType=='x1') caseCommentType=Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;
        else if (commentType=='x2') caseCommentType=Core_IPS_Labels__c.getValues('PRIVATE_TO_AGENTS').value__c;
        //Private to partner is part of release 4.
        else if (commentType=='x3') caseCommentType=Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS').value__c;
        else if (commentType=='xx') caseCommentType=Core_IPS_Labels__c.getValues('NO_PROCESSING').value__c; 
        
        Case[] mailCase = [Select Id,CaseNumber, isClosed,ContactId from Case where Id =:caseRefId ]; 
        Core_IPS_Case_Comments__c comment = new Core_IPS_Case_Comments__c();
        
        //if(fromAdd.contains('intel.com'))
        if(String.isNotBlank(temp_comment_htmlBody)) {
            if(temp_comment_htmlBody.contains('From:')){
                temp_comment_htmlBody = temp_comment_htmlBody.substringBefore('From:');   
            } else if(temp_comment_htmlBody.contains('wrote:')){
                temp_comment_htmlBody = temp_comment_htmlBody.substringBefore('wrote:');            
                temp_comment_htmlBody = temp_comment_htmlBody.substringBeforeLast('On');
            } 
        }
        
        //Calling method to encrypt rich comment text for updating comment
        /*
        if(Core_IPS_Feature_Toggle__c.getValues('SkyHighCommentEncryption').Core_Feature_Enabled__c)    
        temp_comment_htmlBody = Core_IPS_CaseComment_EmailHandlerService.encryptCaseComment(temp_comment_htmlBody);
        */         
                
        //system.debug('====+++========== email ToAddresses size=:'+email.toAddresses.size()+'; mailCase.size()='+mailCase.size()+'; temp_comment_htmlBody:'+temp_comment_htmlBody);  
        
        
        if(email.toAddresses!=null && email.toAddresses.size()==1 && ccAddr==null && mailCase.size()>0 && !mailCase.get(0).isClosed && 
        usr<>null && usr.IsActive && String.isNotBlank(caseCommentType) && caseCommentType!=Core_IPS_Labels__c.getValues('NO_PROCESSING').value__c &&
           String.isNotBlank(caseRefId) && temp_comment_htmlBody !='Encryption Failed') 
        {  
            //system.debug('==++++============= Processing Email service for Case Comment ==++++=========='); 
            
            
            /********************************************************************************************
            Logic to implement case comment type and Author Type based on email sender's Profile 
            * ******************************************************************************************/   
            //Set<string> prflNameSet = new Set<string>();
            //prflNameSet.addAll(Label.Core_IPS_NotetoCustomer_ProfileSet.split(';'));
            
            
            // Added for US83446 comment author type
            String userprofileid = usr.ProfileId;
            String userId = usr.Id;
            //System.debug('login user profileId1--------------->'+userprofileid);
            //System.debug('Sales Profile'+Label.Core_IPS_SalesRep_ProfileIds);
            
            authorType = getAuthr(userprofileid,userId);
            //System.debug('----authorType :::'+authorType);
            
            /*
            if(String.valueOf(userprofileid).length()==18){
                userprofileid =String.valueOf(userprofileid).substring(0,15);
            }
            //System.debug('email sender profileId--------------->'+userprofileid);
            if(Label.Core_IPS_External_Customer_Profile_Id.contains(userprofileid)){
                authorType=Core_IPS_Labels__c.getValues('Customer').value__c; 
            }
            else if(Label.Core_IPS_SalesRep_ProfileIds.contains(userprofileid)){
                authorType=Core_IPS_Labels__c.getValues('FAE').value__c;
            }
            else if(Label.Core_IPS_Agent_Profiles.contains(userprofileid)){
                authorType=Core_IPS_Labels__c.getValues('Agent').value__c;
            } 
            // Label for Partner profile - Release 4
            else if(Label.Core_IPS_Partner_Profile_Id.contains(userprofileid)){
                authorType=Core_IPS_Labels__c.getValues('Partner').value__c;
            }   */

            
            
            //System.debug('email sender caseCommentType--------------->'+authorType);    
            comment = Core_IPS_CaseComment_EmailHandlerService.createCaseComment(temp_comment_htmlBody, caseCommentType, authorType, usr, caseRefId);
            
            //Processing inline image attachments and updating the rich text field with image
            if(email.binaryAttachments != null){
                //system.debug('=============================================------------->binaryAttachments.size()='+email.binaryAttachments.size());
                Core_IPS_CaseComment_EmailHandlerService.processBinaryAttachment(email, comment) ; 
            } 
            
            result.success=true;       
            return result;
            
        }
        
        else {
            System.debug('--------Block the multi recipients email processing------------');              
            
            Core_IPS_CaseComment_EmailHandlerService.sendExceptionEmailUpdate(fromAdd, (mailCase!=null && mailCase.size()>0) ? mailCase.get(0) : new Case());
            
            result.success = false;
            
            //result.message='This email can not be processed as there are multiple recipients of this email!';
            return result;   
        }
    }
    
    //Identifies and Maps the logged in User with Author Type
    public static String getAuthr(String loggedUserId,String userId){
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
            partnerAuthrType  = Core_Utility.getPartnerUserType(userId);
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