/****************************************************************************************************************************************
* Class Name        : Core_MDF_SendPaidPaymentEmailToAdmin
* Created Date      : 02-28-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AS       02-28-2019          It is batch class which updates claim status and send emails to account budget admins.
*****************************************************************************************************************************************/

global class Core_MDF_SendPaidPaymentEmailToAdmin implements Database.Batchable<sObject>, Database.Stateful {
    
    //wrapper class for userObj
    public class WrapClass{
    
        public Id userId;
        
        public String localeKey;
    }
    
    //Will be used in the query
    global static String singleQuoteStr = '\'';
    
    //Create map to store paymentdata and its respective channel partners
    global Map<Id,Set<Id>> paymentIdToCPIdListMap;
    
    //Create map to store paymentId to paymentprogram
    global Map<Id,String> paymentIdToProgramMap;
    
    //Create map to store channel partner Ids with UserData which has Budget Admin Access
    global Map<Id,Set<WrapClass>> cPIdToUserDataListMap;
    
    //Create map to store payment data with list of related users extracted from upper 2 maps
    global Map<Id,Set<WrapClass>> paymentIdToUserListMap;
    
    //Create a set of program to filter metadata accordingly
    global Set<String> paymentProgSet;
    
    //Create a set of localeKey to filter metadata accordingly
    global Set<String> localeKeySet = new Set<String>();
    
    //Create a set to store Channel Partner Ids to filter Pnum results
    global Set<String> cPIdSet = new Set<String>();
    
    //Set to retain pnum mapping key
    global Set<String> userIdSet;
    
    //Boolean value to stop batch if not records left
    global Boolean flag;
    
    //Create map of paymentIdTouserListOld
    global Map<Id,Set<Id>> paymentIdToCPListOldMap;
    
    //Create map of map to retain older values
    global Map<Id,Map<String,Set<Id>>> paymentToUserOldMapofMap;
	
	//create a list to store paymentIds which has changed to paid
	global Set<Id> paymentIdSet;
	
	//create a claimList to store failed claim ids
    global Set<Id> failedClaimSet;
	
	//create set for storing paymentIds whos claims has failed
	global Map<Id,List<Id>> failedPaymentIdToFailClaimMap;
    
    //create count of batches run
    global Integer batchCount;
    
	//default constructor
	public Core_MDF_SendPaidPaymentEmailToAdmin(){
        paymentIdToCPIdListMap = new Map<Id,Set<Id>>();
        paymentIdToProgramMap = new Map<Id,String>();
        cPIdToUserDataListMap = new Map<Id,Set<WrapClass>>();
        paymentIdToUserListMap = new Map<Id,Set<WrapClass>>();
        paymentProgSet = new Set<String>();
        userIdSet = new Set<String>();		
		paymentIdSet = new Set<Id>();
		failedClaimSet = new Set<Id>();
		failedPaymentIdToFailClaimMap = new Map<Id,List<Id>>();
        flag = false;
        batchCount = 1;
    }
	
	//parameterized constructor which takes paymentIds as argument
	public Core_MDF_SendPaidPaymentEmailToAdmin(Set<Id> paymentIdparamList){
		this();
		paymentIdSet.addAll(paymentIdparamList);
	}
	
    //parameterised constructor to take maps,sets as parameter
    public Core_MDF_SendPaidPaymentEmailToAdmin(Map<Id,Set<Id>> paymentIdToCPParamMap,Map<Id,Map<String,Set<Id>>> paymentToUserParamMapofMap,
                                                Map<Id,String> paymentToProgramParamMap,Set<String> localeKeyParamSet,Set<String> programParamSet,
												Set<Id> paymentIdsParamList,Set<Id> failedClaimParamSet,Map<Id,List<Id>> failedPaymentIdToFailClaimParamMap,Integer countParam){
        this();
        paymentIdToCPListOldMap = new Map<Id,Set<Id>>();
        paymentToUserOldMapofMap = new Map<Id,Map<String,Set<Id>>>();
        paymentIdToCPListOldMap.putAll(paymentIdToCPParamMap);
        paymentToUserOldMapofMap.putAll(paymentToUserParamMapofMap);
        paymentIdToProgramMap.putAll(paymentToProgramParamMap);                                            
		paymentProgSet.addAll(programParamSet);
		localeKeySet.addAll(localeKeyParamSet);
		paymentIdSet.addAll(paymentIdsParamList);
		failedClaimSet.addAll(failedClaimParamSet);
		failedPaymentIdToFailClaimMap.putAll(failedPaymentIdToFailClaimParamMap);
        batchCount = countParam;                                            
    }
    
   
    /***************************************************************************************************** 
    Method Name :   start
    @return     :   List of payment object records
    @parameters :   Database.BatchableContext
    Description :   It fetches all object data of payment 
    Added By    :   Accenture - AS                  Date:02-28-2019                     Changes:None                               
    ******************************************************************************************************/  
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        try{
            //create a list to store claim status
            List<String> claimPendingPaymentStatusList = Label.Core_MDF_Status_Pending_Payment.split(',');
            
            //create a list to store payment status
            List<String> paymentStatusList = Label.Core_MDF_PaymentStatus.split(',');
			
            //String to store query 
            String query = '';
            
				query = 'SELECT Id, Core_MDF_Status__c,ChannelPartnerId,Core_MDF_Payment_Id__c,Core_MDF_Payment_Id__r.Core_MDF_Payment_Status_Txt__c'+
                        ',Core_MDF_Payment_Id__r.Core_MDF_Program_Txt__c'+' FROM PartnerFundClaim WHERE Core_MDF_Status__c IN :claimPendingPaymentStatusList' + 
                        ' AND Core_MDF_Type_Txt__c = \''+ String.escapeSingleQuotes(System.Label.Core_MDF_Claim_Type)+
                        '\' AND Core_MDF_Payment_Id__r.Core_MDF_Payment_Status_Txt__c IN :paymentStatusList AND Core_MDF_Payment_Id__c IN :paymentIdSet' +
					    ' AND Id NOT IN :failedClaimSet' + ' LIMIT '+Label.Core_MDF_ClaimSearchLimit;           
			  
            return Database.getQueryLocator(query);
        }catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);Core_MDF_UpdateBankDetails.logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_Payment_OriginName);
        return NULL;}
    }

    /******************************************************************************************************** 
    Method Name :   execute
    @return     :   void
    @parameters :   Database.BatchableContext,
    Description :   Creates a paymentId to users mapofmap 
    Added By    :   Accenture - AS          Date:02-28-2019     Changes:None  
    **********************************************************************************************************/ 
    
    global void execute(Database.BatchableContext bc, List<PartnerFundClaim> scope){
        
        try{
            //flag is used to know which is the last batch run
            flag = true;
			
            //create a flag for test class
            Boolean testFlag = true;
            
            //create a claim List to update claims
            List<PartnerFundClaim> claimListToUpdate = new List<PartnerFundClaim>();
        
            for(PartnerFundClaim claimRecord : scope){    
                //changing claim standard status to Paid 
                claimRecord.Status = Label.Core_MDF_ClaimStatus;
                
                //changing claim custom status to Paid
                claimRecord.Core_MDF_Status__c = Label.Core_MDF_ClaimStatus;
                
                if (Test.isRunningTest() && testFlag) { 
                	//update record with wrong value to test exception handling [REMOVE BELOW ELEMENT THIS IS ONLY FOR TESTING]
                    claimRecord.Core_MDF_Invoice_Number__c = '';
                    testFlag = false;
                }
                
                //populate cpIdSet to use it as a filter in Account User Query
                if(!(cPIdToUserDataListMap != NULL && cPIdToUserDataListMap.keySet().contains(claimRecord.ChannelPartnerId))){
                    cPIdSet.add(claimRecord.ChannelPartnerId);
                }
                
           		//adding changed value to a claim List of objects
                claimListToUpdate.add(claimRecord);   
                
                //initially adding claims to failClaimSet
                failedClaimSet.add(claimRecord.Id);
                
                //creating payment program set to filter the translation metadata 
                paymentProgSet.add(claimRecord.Core_MDF_Payment_Id__r.Core_MDF_Program_Txt__c);
                
                //populating paymentIdToCPIdListMap
                if(!(paymentIdToCPListOldMap != NULL && paymentIdToCPListOldMap.get(claimRecord.Core_MDF_Payment_Id__c) != NULL && 
                   paymentIdToCPListOldMap.get(claimRecord.Core_MDF_Payment_Id__c).contains(claimRecord.ChannelPartnerId))){    
                    
                       if(paymentIdToCPIdListMap.containsKey(claimRecord.Core_MDF_Payment_Id__c)){
                           paymentIdToCPIdListMap.get(claimRecord.Core_MDF_Payment_Id__c).add(claimRecord.ChannelPartnerId);
                       }
                       else{
                           paymentIdToCPIdListMap.put(claimRecord.Core_MDF_Payment_Id__c, new Set<Id>{claimRecord.ChannelPartnerId});
                       }
                }
                
                //populating paymentIdToProgramMap if payment id record doesn't exists
                if(!paymentIdToProgramMap.containsKey(claimRecord.Core_MDF_Payment_Id__c)){
                    paymentIdToProgramMap.put(claimRecord.Core_MDF_Payment_Id__c,claimRecord.Core_MDF_Payment_Id__r.Core_MDF_Program_Txt__c);
                }
            }
            
            //updating claims to Paid status
            if(claimListToUpdate.size()>0){
                List<Database.SaveResult> updateResults = Database.update(claimListToUpdate, false);
				
                //this is used to iterate through the database results
                Integer count = 0;
                
                for(Database.SaveResult sr:updateResults)
				{
					if (sr.isSuccess()){
                        //remove successful claim Ids from the failedClaimSet
						failedClaimSet.remove(claimListToUpdate.get(count).Id);
					}
                    else{
						// Operation failed, so get all errors
                        if(failedPaymentIdToFailClaimMap.keySet().contains(claimListToUpdate.get(count).Core_MDF_Payment_Id__c)){
                            failedPaymentIdToFailClaimMap.get(claimListToUpdate.get(count).Core_MDF_Payment_Id__c).add(claimListToUpdate.get(count).Id);
                        }
						else{
							failedPaymentIdToFailClaimMap.put(claimListToUpdate.get(count).Core_MDF_Payment_Id__c, new List<Id>{claimListToUpdate.get(count).Id});
						}
                    }
                    count++;
				}
            }   
            
            //remove the payment Id associated with failed claim to stop sending notification
			for(Id paymentId : failedPaymentIdToFailClaimMap.keySet()){	
				paymentIdToCPIdListMap.remove(paymentId);
			}			
            
            //populating cPIdToUserDataListMap by looping in pnum records whose user has AccountBudgetAdmin Access
            for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id,Core_MDF_User__c,Core_MDF_Account__c,Core_MDF_User__r.languageLocalekey 
                                                              FROM Core_MDF_Partner_Node_User_Mapping__c
                                                              WHERE Core_MDF_Account__c IN :cPIdSet
                                                              AND   Core_MDF_User__c <> NULL
                                                              AND   Core_MDF_User__r.ContactId <> NULL 
                                                              AND   Core_MDF_User__r.Contact.Core_Audience__c 
                                                              Like '%Account Budget Administrator%']){                                                        
                
                //concateId will help to check if the mapping pre-exists or not
                String concateId = (String) pnum.Core_MDF_Account__c + pnum.Core_MDF_User__c;
                
                //new wrap class instance to save userid and localekey                                                  
                WrapClass userObj = new WrapClass();
                userObj.userId = pnum.Core_MDF_User__c;
                userObj.localeKey = pnum.Core_MDF_User__r.languageLocalekey; 
                                                                  
                if(cPIdToUserDataListMap.containsKey(pnum.Core_MDF_Account__c)){
                    if(!userIdSet.contains(concateId)){
                        cPIdToUserDataListMap.get(pnum.Core_MDF_Account__c).add(userObj);
                    }    
                }
                else{
                    cPIdToUserDataListMap.put(pnum.Core_MDF_Account__c, new Set<WrapClass>{userObj});
                }
                
                //add already existing mapids to set                                                  
                userIdSet.add(concateId);                                                  
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
        }catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);Core_MDF_UpdateBankDetails.logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_Payment_OriginName);}
    }
    
    /***************************************************************************************************** 
    Method Name :   finish
    @return     :   void
    @parameters :   Database.BatchableContext
    Description :   
    Added By    :   Accenture - AS
    Modified By :                        Date:11/30/2018                     Changes:None                         
    ******************************************************************************************************/

    global void finish(Database.BatchableContext bc){
         
        //Creating localeKeyToTranslationMap
        Map<String,Core_MDF_CCP_EmailContentTranslationMap__mdt> localeAndProgToMetaDataObjectMap = new Map<String,Core_MDF_CCP_EmailContentTranslationMap__mdt>();
        
        //Creating List of Email Instance
        List<Messaging.SingleEmailMessage> emaiList = new List<Messaging.SingleEmailMessage>();
        
        //Create map of map which has payment data mapped to localeKeyToUserListMap
        Map<Id,Map<String,Set<Id>>> paymentIdToUserMapOfMap = new Map<Id,Map<String,Set<Id>>>();
        
        try{
            //populating paymentIdToUserMapOfMap with help of paymentIdToUserListMap
            for(Id paymentId : paymentIdToUserListMap.keySet()){
                system.debug('Here--->'+paymentId);
                //Create map of localeKey with set of Users
                Map<String,Set<Id>> localeKeyToUserListMap = new Map<String,Set<Id>>();
                
                for(WrapClass user : paymentIdToUserListMap.get(paymentId)){
                	system.debug('Here1--->'+user);
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
            
            //put all previous values of paymentId to CpId List map values
            if(paymentIdToCPListOldMap != NULL){
            	paymentIdToCPIdListMap.putAll(paymentIdToCPListOldMap);	    
            }
            
            //put all previous values of paymentId to user List map of map values
            if(paymentToUserOldMapofMap != NULL){
                paymentIdToUserMapOfMap.putAll(paymentToUserOldMapofMap);
            }
            
            //Calling batch again for left claim records
            if(flag == true && Integer.valueOf(Label.Core_MDF_BatchSafeLimit) > batchCount){
                //increament batch count
                batchCount++;
                
                Core_MDF_SendPaidPaymentEmailToAdmin batchObj = new Core_MDF_SendPaidPaymentEmailToAdmin(paymentIdToCPIdListMap,paymentIdToUserMapOfMap,
                                                                                                         paymentIdToProgramMap,localeKeySet,paymentProgSet,
																										 paymentIdSet,failedClaimSet,failedPaymentIdToFailClaimMap,
																										 batchCount);
                database.executeBatch(batchObj,Integer.valueOf(Label.Core_MDF_BatchSize));
            }    
            
            //Send Claims only in the last batch call
            if(flag == false || Integer.valueOf(Label.Core_MDF_BatchSafeLimit) <= batchCount){
                
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
                                                        
                    String metaKey = metaDataObj.Core_MDF_LocaleKey__c 	+ metaDataObj.Core_MDF_Program__c;
                    localeAndProgToMetaDataObjectMap.put(metaKey, metaDataObj);                                                                                      
                }
                
                //Preparing Email Object
                for(Id paymentId : paymentIdToUserMapOfMap.keySet()){
                    if(paymentIdToProgramMap.get(paymentId) != NULL){
                        for(String langCode : paymentIdToUserMapOfMap.get(paymentId).keySet()){
                            
                            Set<Id> userId = paymentIdToUserMapOfMap.get(paymentId).get(langCode);
                            
                            String metaKey = langCode + paymentIdToProgramMap.get(paymentId);
                            
                            //if localeKey translation not present then set default language
                            if(!localeAndProgToMetaDataObjectMap.containsKey(metaKey)){
                                
                                metaKey = 'en_US' + paymentIdToProgramMap.get(paymentId);
                            }   
                            
                            for(Id u : userId){ 
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
                                String emailBody = '<html><head><meta charset="UTF-8"></head><body>' + mailBody9 + '</br></br>' +mailBody1 + '</br></br>' + 
                                                   mailBody2 + ' ' + program + ' ' + mailBody3 +' '+ mailBody4 +' <a href="' + Label.Core_MDF_PFRCommunityLink + 
                                                   paymentId + '">' + mailBody5 + '</a> ' + mailBody6 + '</br></br>' + mailBody7 +  mailBody8 + ' '+program + ' ' + 
                                                   mailBody8a + '</br></br>';
                                
                                //Creating footer for Email
                                String emailFooter = '<div style="font-size:11px;font-family:Calibri"><p>' + 
                                                     mailFooter1 + '</br>' +                 
                                                    '<a href="' + Label.Core_MDF_IntelCorpLink + '">' + mailFooter2 + '</a>' + ' | ' +
                                                    '<a href="' + Label.Core_MDF_TradeMarkLink + '">' + mailFooter3 + '</a>' + ' | ' +
                                                    '<a href="' + Label.Core_MDF_PrivacyPolicyLink + '">' + mailFooter4 + '</a>' + ' | ' +
                                                    '<a href="' + Label.Core_MDF_CookiesLink + '">' + mailFooter5 + '</a></p></div></br></br></body></html>';
                                
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
                }
                //Send Emails only if emaiList has values
                if(emaiList.size()>0){
                    Messaging.sendEmail(emaiList);
                }
        
				//if failed claim exists then make a log entry
                if(failedPaymentIdToFailClaimMap.keySet().size() > 0){
					//create list of log entry objects
                    List<Core_Log_Entry__c> paymentLogList = new List<Core_Log_Entry__c>();
					
                    //it will store the size of data stored in detail
                    Integer detailLength = 0;
                    
                    //String to store all claimIds with its payment Ids
					String detail = '';
                    
                    //iteration count over the paymentIds
                    Integer count = 0;
                    
                    //create a flag to check if the control went in else condition or not
                    Boolean checkFlag;
                    
                    //loop through the failedPaymentIdToFailClaimMap keySet to generate log object
					for(Id paymentId : failedPaymentIdToFailClaimMap.keySet()){
                    	checkFlag = false;
                        count++;
						String payId = (String) paymentId;
						
                        //converting list to string and calculating its length
                        detailLength += (String.join(failedPaymentIdToFailClaimMap.get(paymentId),',')).length();
						 
                        //Creating data for testclass
                        if (Test.isRunningTest()){
                            for(Integer i=0;i<600;i++){
                                detail += 'detaildetaildetaildetaildetaildetaildetaildetaildetaildetail';
                            }
                            detailLength = detail.length();
                        }
                        
                        //keep on concatinating the paymentIds along with claimIds until it reaches 30000 limit
                        if(detailLength <= 30000){
							detail += paymentId+'->(' + String.join(failedPaymentIdToFailClaimMap.get(paymentId),',') + '); ';
						}
						
                        //if limit reaches then create a log entry object
                        else{
                            checkFlag = true;
							
							//if incoming paymentId has claims which is crossing the limit then break and 
							//create multiple log entry objects
                            if((String.join(failedPaymentIdToFailClaimMap.get(paymentId),',')).length() > 30000){
								String claimIds = String.join(failedPaymentIdToFailClaimMap.get(paymentId),',') + ',,';
								
                                //i will be kept at the initial point of substring
                                Integer i = 0;
                                
                                //index will be kept at the ending point of substring
                                Integer index = 30000;
                                
                                //break claimIds string and create log entry objects 
								While( i < claimIds.length() ){
									
									if(index > claimIds.length()){index = claimIds.length();}
									
                                    //getting the nearest location of ',' from end point of string
									index = claimIds.lastIndexOf(',' , index);
                                    
									String subDetail = paymentId + '->('+claimIds.substring(i,index-1)+'); ';
									paymentLogList.add(createLogObject(subDetail));
                                    
                                    //change the value of i and index to handle next substring
									i = index+1;index = 2 * index;									
								}
                                //reset detailLength
                                detailLength = 0;                                                                                 
							}
                            
                            //if detail is not empty then create log entry for that as well
                            if(detail != ''){
                                paymentLogList.add(createLogObject(detail));
                                
                                //populate detail and detailLength with current value if it is not exceding limits
                                if((String.join(failedPaymentIdToFailClaimMap.get(paymentId),',')).length() <= 30000){
                                    detail += paymentId+'->(' + String.join(failedPaymentIdToFailClaimMap.get(paymentId),',') + '); ';
                                    detailLength = detail.length();
                                }	
                            }
						}
                        
                        //for left over paymentids 
                        if(!checkFlag && count == failedPaymentIdToFailClaimMap.keySet().size()){
							paymentLogList.add(createLogObject(detail));
                        }					
					}
                    
					insert(paymentLogList);
				}
            }        
        }catch(Exception e){String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);Core_MDF_UpdateBankDetails.logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_Payment_OriginName);}       
    }
    
    /***************************************************************************************************** 
    Method Name :   create log object
    @return     :   Core_Log_Entry__c
    @parameters :   void
    Description :   It creates and add value to log entry object
    Added By    :   Accenture - AS 
    Modified By :                      Date:03/27/2019                     Changes:None                               
    ******************************************************************************************************/
    
    public Core_Log_Entry__c createLogObject(String detail)
    { 						
        Core_Log_Entry__c paymentLogObject = new Core_Log_Entry__c();
        paymentLogObject.Core_Origin__c = Label.Core_MDF_FailClaimOrigin;
        paymentLogObject.Core_Project__c = Label.Core_MDF_Program_Name;
        paymentLogObject.Core_Scope__c = Label.Core_MDF_FailClaimOrigin;
        paymentLogObject.Core_Severity__c = Label.Core_MDF_Normal_Severity;
        paymentLogObject.Core_Support_Email__c = Label.Core_MDF_CCP_Support_Email;
        paymentLogObject.Core_Support_Link__c = Label.Core_MDF_CCP_Support_Link;
        paymentLogObject.Core_Tags__c = Label.Core_MDF_FailClaimTag;
        paymentLogObject.Core_When__c = datetime.now();
        paymentLogObject.Core_Message__c = Label.Core_MDF_FailClaimMessage;
        paymentLogObject.Core_Details__c = detail;
        return paymentLogObject;
    }
}