/****************************************************************************************************************************************
* Class Name  : Core_MDF_SendPaidPaymentEmail 
* Version     : 1.0 
* Created Date: 02-06-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AS              02/06/2019                    Used in Proces Builder to send email to Budget Admins.
*****************************************************************************************************************************************/
public with sharing class Core_MDF_SendPaidPaymentEmail{
    
    
    /***************************************************************************************************** 
    Method Name :   sendPaidPaymentEmail
    @return     :   NULL
    @parameters :   EmailParameter list of objects
    Description :   It sends the email to specified emails when payment status is paid.
    Added By    :   Accenture - AS
    Created Date: 	02-06-2019	
    Modified By :                      Date:                     Changes:None                               
    ******************************************************************************************************/  
    
    public static void sendPaidPaymentEmail(List<EmailParameter> sendEmailParams){
        
        //Create map to store paymentdata and its respective channel partners
		Map<Id,List<Id>> paymentIdToCPIdListMap = new Map<Id,List<Id>>();
		
		//Create map to store paymentId to paymentprogram
		Map<Id,String> paymentIdToProgramMap = new Map<Id,String>();
		
		//Create map to store channel partner Ids with UserData which has Budget Admin Access
		Map<Id,List<WrapClass>> cPIdToUserDataListMap = new Map<Id,List<WrapClass>>();
		
		//Create map to store payment data with list of related users extracted from upper 2 maps
		Map<Id,List<WrapClass>> paymentIdToUserListMap = new Map<Id,List<WrapClass>>();
		
		//Create map of map which has payment data mapped to localeKeyToUserListMap
		Map<Id,Map<String,Set<Id>>> paymentIdToUserMapOfMap = new Map<Id,Map<String,Set<Id>>>();
		
		//Create a set of program to filter metadata accordingly
		Set<String> programSet = new Set<String>();
		
		//Create a set of localeKey to filter metadata accordingly
		Set<String> localeKeySet = new Set<String>();
        
        //Create a set to store Channel Partner Ids to filter Pnum results
        Set<String> cPIdSet = new Set<String>();
        
		//Create a set to store paymentIds 
		Set<Id> paymentIdSet = new Set<Id>();
		
		//Populating paymentIdSet
		for(EmailParameter emailDataObj : sendEmailParams){
			paymentIdSet.add(emailDataObj.paymentId);
        }
		//Update Claim Status to paid
		List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
		List<EmailParameter> epList = new List<EmailParameter>();
        List<String> claimPendingPaymentStatusList = Label.Core_MDF_Status_Pending_Payment.split(',');
        if(claimPendingPaymentStatusList != NULL && claimPendingPaymentStatusList.size() > 0){
            for(Core_MDF_Payment__c paymentRecord : [SELECT Id, Core_MDF_Program_Txt__c,(SELECT Id, Core_MDF_Status__c,ChannelPartnerId 
                                                                                         FROM Partner_Fund_Claims__r
                                                                                         WHERE Core_MDF_Status__c IN :claimPendingPaymentStatusList)
                                                     FROM Core_MDF_Payment__c
                                                     WHERE Id IN :paymentIdSet]){
                if(paymentRecord.Partner_Fund_Claims__r != NULL){
                    EmailParameter ep = new EmailParameter();
                    
                    for(PartnerFundClaim pfc: paymentRecord.Partner_Fund_Claims__r){
                        ep.claimCPIds.add(pfc.ChannelPartnerId);
                        //changing status
                        pfc.Status = 'Paid';
                        pfc.Core_MDF_Status__c = 'Paid';
                        pfcList.add(pfc);                  
                    }
                    if(pfcList.size() > 0){
                        ep.paymentId = paymentRecord.Id;
                        ep.paymentProg = paymentRecord.Core_MDF_Program_Txt__c;
                        epList.add(ep);
                    }
                }
            }
        }
        if(pfcList.size() > 0){
			update pfcList;
        }
        
		//populating paymentIdToCPIdListMap and paymentIdToProgramMap by looping in EmailParameter Object
		for(EmailParameter emailDataObj : epList){			
			//Populating programSet
			programSet.add(emailDataObj.paymentProg);
            cPIdSet.addAll(emailDataObj.claimCPIds);
			paymentIdToCPIdListMap.put(emailDataObj.paymentId,emailDataObj.claimCPIds);
			paymentIdToProgramMap.put(emailDataObj.paymentId,emailDataObj.paymentProg);
		}
		
		//populating cPIdToUserDataListMap by looping in pnum records whose user has AccountBudgetAdmin Access
		for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id,Core_MDF_User__c,Core_MDF_Account__c,Core_MDF_User__r.languageLocalekey 
                                                          FROM Core_MDF_Partner_Node_User_Mapping__c
                                                          WHERE Core_MDF_Account__c IN :cPIdSet
                                                          AND   Core_MDF_User__c <> NULL
                                                          AND   Core_MDF_User__r.ContactId <> NULL 
                                                          AND   Core_MDF_User__r.Contact.Core_Audience__c 
                                                          Like '%Account Budget Administrator%']){														  
			WrapClass userObj = new WrapClass();
			userObj.userId = pnum.Core_MDF_User__c;
			userObj.localeKey = pnum.Core_MDF_User__r.languageLocalekey;
			if(cPIdToUserDataListMap.containsKey(pnum.Core_MDF_Account__c)){
				cPIdToUserDataListMap.get(pnum.Core_MDF_Account__c).add(userObj);
            }
			else{
                cPIdToUserDataListMap.put(pnum.Core_MDF_Account__c, new List<WrapClass>{userObj});
            }
		}
		
		//populating paymentIdToUserListMap by using paymentIdToCPIdListMap and cPIdToUserDataListMap
		for(Id paymentId : paymentIdToCPIdListMap.keySet()){
			
			for(Id cPId : cPIdToUserDataListMap.keySet()){
			
				if(paymentIdToCPIdListMap.get(paymentId).contains(cPId)){
					
					if(paymentIdToUserListMap.containsKey(paymentId)){
						paymentIdToUserListMap.get(paymentId).addAll(cPIdToUserDataListMap.get(cPId));
					}
					else{
						paymentIdToUserListMap.put(paymentId, cPIdToUserDataListMap.get(cPId));
					}
				}
			}
		}
		
		//populating paymentIdToUserMapOfMap with help of paymentIdToUserListMap
		for(Id paymentId : paymentIdToUserListMap.keySet()){
            //Create map of localeKey with set of Users
            Map<String,Set<Id>> localeKeyToUserListMap = new Map<String,Set<Id>>();
			for(WrapClass user : paymentIdToUserListMap.get(paymentId)){
			
				localeKeySet.add(user.localeKey);
				if(localeKeyToUserListMap.containsKey(user.localeKey)){
					localeKeyToUserListMap.get(user.localeKey).add(user.userId);
				}
				else{
                    localeKeyToUserListMap.put(user.localeKey, new Set<Id>{user.userId});
				}
			}
			if(localeKeyToUserListMap != NULL){
				paymentIdToUserMapOfMap.put(paymentId,localeKeyToUserListMap);
			}	
		}
        if(paymentIdToUserMapOfMap != NULL){
        	sendEmail(paymentIdToUserMapOfMap,programSet,localeKeySet,paymentIdToProgramMap);
        }
        
    }	
    
    /***************************************************************************************************** 
    Method Name :   sendEmail
    @return     :   NULL
    @parameters :   Map<WrapClass,Map<String,Set<Id>>>
    Description :   It sends the email to specified users when payment status is paid.
    Added By    :   Accenture - AS
    Created Date: 	02-06-2019	
    Modified By :                      Date:                     Changes:None                               
    ******************************************************************************************************/  	
    public static void sendEmail(Map<Id,Map<String,Set<Id>>> paymentIdToUserMapOfMap,Set<String> paymentProgSet, Set<String> localeKeySet,
	                             Map<Id,String> paymentIdToProgramMap){
        
        //Creating localeKeyToTranslationMap
        Map<String,Core_MDF_CCP_EmailContentTranslationMap__mdt> localeAndProgToMetaDataObjectMap = new Map<String,Core_MDF_CCP_EmailContentTranslationMap__mdt>();
        
        //Creating List of Email Instance
        List<Messaging.SingleEmailMessage> emaiList = new List<Messaging.SingleEmailMessage>();
        
        //Populating localeAndProgToMetaDataObjectMap
        for(Core_MDF_CCP_EmailContentTranslationMap__mdt metaDataObj : [SELECT Id, Core_MDF_MailSubject__c, Core_MDF_MailBody1__c, 
                                                                        Core_MDF_MailBody2__c,Core_MDF_MailBody3__c, Core_MDF_MailBody4__c, 
                                                                        Core_MDF_MailBody5__c, Core_MDF_MailBody6__c,  Core_MDF_MailBody7__c,
                                                                        Core_MDF_MailFooter1__c, Core_MDF_MailFooter2__c, Core_MDF_MailFooter3__c, 
                                                                        Core_MDF_MailFooter4__c, Core_MDF_MailFooter5__c, Core_MDF_Program__c,  
                                                                        Core_MDF_MailBody8__c,Core_MDF_MailBody9__c, Core_MDF_LocaleKey__c,
                                                                        Core_MDF_Translated_Program__c,Core_MDF_MailBody8_1__c
                                                                        FROM   Core_MDF_CCP_EmailContentTranslationMap__mdt
                                                                        WHERE  Core_MDF_Program__c IN :paymentProgSet AND
                                                                       		   (Core_MDF_LocaleKey__c = 'en_US'   OR
                                                                                Core_MDF_LocaleKey__c IN :localeKeySet)]){																				
												
			String metaKey = metaDataObj.Core_MDF_LocaleKey__c + metaDataObj.Core_MDF_Program__c;
			localeAndProgToMetaDataObjectMap.put(metaKey, metaDataObj);	
        }
        
        //Preparing Email Object
		for(Id paymentId : paymentIdToUserMapOfMap.keySet()){
        
			for(String langCode : paymentIdToUserMapOfMap.get(paymentId).keySet()){
				
				Set<Id> UserId = paymentIdToUserMapOfMap.get(paymentId).get(langCode);
				
				String metaKey = langCode + paymentIdToProgramMap.get(paymentId);
				if(!localeAndProgToMetaDataObjectMap.containsKey(metaKey)){
					
					metaKey = 'en_US' + paymentIdToProgramMap.get(paymentId);
				}	
				
				for(Id u : UserId){ 
					String mailSubject  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailSubject__c;
					String mailBody1  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailBody1__c;
					String mailBody2  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailBody2__c;
					String mailBody3  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailBody3__c;
					String mailBody4  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailBody4__c;
					String mailBody5  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailBody5__c;
					String mailBody6  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailBody6__c;
					String mailBody7  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailBody7__c;
					String mailBody8  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailBody8__c;
					String mailBody8a  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailBody8_1__c;
					String mailBody9  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailBody9__c;
					String mailFooter1  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailFooter1__c;
					String mailFooter2  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailFooter2__c;
					String mailFooter3  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailFooter3__c;
					String mailFooter4  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailFooter4__c;
					String mailFooter5  = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_MailFooter5__c;
                    String program = localeAndProgToMetaDataObjectMap.get(metaKey).Core_MDF_Translated_Program__c;
					
					//Creating body of Email
					String emailBody = mailBody9 + '</br></br>' +mailBody1 + '</br></br>' + mailBody2 + ' ' + program + ' ' +
						mailBody3 +' '+ mailBody4 +' <a href="' + Label.Core_MDF_PFRCommunityLink + paymentId + '">' +
						mailBody5 + '</a> ' + mailBody6 + '</br></br>' +
						mailBody7 +  mailBody8 + ' '+program + ' ' + mailBody8a + '</br></br>';
					
					//Creating footer for Email
					String emailFooter = '<div style="font-size:11px;font-family:Calibri"><p>' + 
                                         mailFooter1 + '</br>' + 				 
                                        '<a href="' + Label.Core_MDF_IntelCorpLink + '">' + mailFooter2 + '</a>' + ' | ' +
                                        '<a href="' + Label.Core_MDF_TradeMarkLink + '">' + mailFooter3 + '</a>' + ' | ' +
                                        '<a href="' + Label.Core_MDF_PrivacyPolicyLink + '">' + mailFooter4 + '</a>' + ' | ' +
                                        '<a href="' + Label.Core_MDF_CookiesLink + '">' + mailFooter5 + '</a></p></div></br></br>';
					
					Messaging.SingleEmailMessage emailObj = new Messaging.SingleEmailMessage();
					emailObj.setTargetObjectId(u);
					emailObj.setSaveAsActivity(false);
					emailObj.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
					emailObj.setSubject(mailSubject); 
					emailObj.setHTMLBody(emailBody + emailFooter); 
					emaiList.add(emailObj);
				}
			}
		}
        if(emaiList != NULL){
        	Messaging.sendEmail(emaiList);
        }    
    }
    
    /***************************************************************************************************** 
    Method Name :   invokeEmailIds
    @return     :   void
    @parameters :        
    Description :   This is an Invocable Method for Notification
    Added By    :   Accenture - AS 
    Created Date: 	02-06-2019	
    Modified By :                   Date:                          Changes:None 
    ******************************************************************************************************/
    
    @InvocableMethod
    public static void invokeEmailIds(List<EmailParameter> sendEmailParams)
    {
        //try{
        	sendPaidPaymentEmail(sendEmailParams);
        //}catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);Core_MDF_UpdateBankDetails.logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_Payment_OriginName);}    
    }
    
    
    /***************************************************************************************************** 
    Class Name :   EmailParameter
    @parameters :   
    Description :   This is a wrapper class for flow.
    Added By    :   Accenture - AS
    Created Date: 	02-06-2019	
    Modified By :                      Date:                     Changes:None                               
    ******************************************************************************************************/  
    
    public class EmailParameter{
        public List<String> claimCPIds = new List<String>();
        
        @InvocableVariable(label = 'PaymentId' required = true)
        public String paymentId;
        
        @InvocableVariable(label = 'Payment Program' required = true)
        public String paymentProg;
        
    }
	
	/***************************************************************************************************** 
    Class Name :   WrapClass
    @parameters :   
    Description :   This is a wrapper class for User obj.
    Added By    :   Accenture - AS
    Created Date: 	02-06-2019	
    Modified By :                      Date:                     Changes:None                               
    ******************************************************************************************************/  
	public class WrapClass{
	
        public Id userId;
        
        public String localeKey;
	}
	
}