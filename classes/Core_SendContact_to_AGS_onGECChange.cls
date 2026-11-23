/**************************************************************************************
Apex Class Name:  Core_SendContact_to_AGS_onGECChange
Version     : 1.0 
Created Date: 27 Sep 2021
Function    : To send Contact GEC information to AGS
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda             27/09/2020             Original Version
*************************************************************************************/
public class Core_SendContact_to_AGS_onGECChange {
    
    
    public static String accessToken = '';
    public static String AGSEndpointURL = '';
    public static List<Core_Log_Entry__c> Logentries= new List<Core_Log_Entry__c> ();
    public static List<Core_Contact_GEC_Staging__c> ContactGECStaging= new List<Core_Contact_GEC_Staging__c> ();
	 public static List<Core_Contact_GEC_Staging__c> CntGECStagingFailed= new List<Core_Contact_GEC_Staging__c> ();
	public static List<Contact> FailedGECContacts= new List<Contact> ();
	public static boolean BypassContactSharingMethod=false;
	 /*
    * Method name  : ContactGECBlock
    * Description  : Method to call from trigger with Trigger.new and Trigger.oldMap of Contacts
    * Return Type  : None
    * Parameter    : Trigger.new,Trigger.oldMap
    */
    Public static void ContactGECBlock(List<Contact>newContactList,Map<Id,Contact>OldContactMap){
        
        List<Contact>ContactGECChange = new List<Contact>();
        
        Set<Id>ContactGECChangeIds = new Set<Id>();
        for(Contact con : newContactList){
            if(con.Core_Contact_Export_Compliance_Block__c <>OldContactMap.get(con.id).Core_Contact_Export_Compliance_Block__c && con.Core_Enterprise_Id__c !=null){
                //ContactGECChangeIds.add(con.id);
                ContactGECChange.add(Con);
            }
        }
        
        //Calling the Queueble class to send the GEC Information to AGS
        if(ContactGECChange.size()>0){
            Core_ContactGECQueueable obj= new Core_ContactGECQueueable(ContactGECChange);
            system.enqueuejob(obj);
        }
        
        
    }
    
	 /*
    * Method name  : SendGECInfoTOAGS
    * Description  : Method to call from Queueable class by passing the Contact Information to send it to AGS
    * Return Type  : None
    * Parameter    : List of contacts
    */
    
    public static List<Core_GEC_Contact_wrapper> SendGECInfoTOAGS(List<Contact> conlist){
          List<Core_GEC_Contact_wrapper> warpperlst = new List<Core_GEC_Contact_wrapper>();

        Core_GEC_Contact_wrapper Conwrap= new Core_GEC_Contact_wrapper();
        try{
            String AGSAccessToken=generateAccessToken('SendContact_to_AGS');
            system.debug('***access token'+AGSAccessToken);
            
                
                for(Contact Con : conlist){
                    warpperlst = new List<Core_GEC_Contact_wrapper>();
                    system.debug('***WWIf'+Con.LastModifiedBy.Core_WWID__c);
                    system.debug('***EIDdd'+Con.Core_Enterprise_Id__c);
                    
                    String ContactJSONRes= ContactGECJSON(Con.LastModifiedBy.Core_WWID__c,Con.Core_Con_Export_Compliance_Block_Reason__c,
                                                          Con.Core_Contact_Export_Compliance_Block__c,Con.Core_Enterprise_Id__c);
                    system.debug('***JSONCon'+ContactJSONRes);
                    Http callout = new Http();
                    HttpRequest postRequest = new HttpRequest();
                    postRequest.setMethod('PATCH');
					if(Con.Core_Enterprise_Id__c != null && Con.Core_Contact_Export_Compliance_Block__c ==true){
                    postRequest.setEndpoint(AGSEndpointURL+Con.Core_Enterprise_Id__c+'?action=disable');
					}else if(Con.Core_Enterprise_Id__c != null && Con.Core_Contact_Export_Compliance_Block__c ==false){
			        postRequest.setEndpoint(AGSEndpointURL+Con.Core_Enterprise_Id__c+'?action=enable');
					}
                    postRequest.setHeader('content-type', 'application/json');               
                    postRequest.setHeader('Authorization', 'Bearer ' + AGSAccessToken);
                    system.debug('ContactJSONRes'+ContactJSONRes);
                    postRequest.setBody(ContactJSONRes);
                    postRequest.setTimeout(12000);
                    HttpResponse response = callout.send(postRequest); 
                    system.debug('***responsebody'+response.getBody());
                    if(response.getStatusCode() == 200){
                        ContactGECStaging.add(new Core_Contact_GEC_Staging__c(Core_Status__c='Successful',Core_Payload__c=ContactJSONRes,
						Core_Contact_Rec_Id__c=Con.Id,Core_Contact_Name__c=Con.FirstName+' '+Con.LastName,
						Core_Account_Id__c=Con.AccountId,Core_GEC_Blocked__c=Con.Core_Contact_Export_Compliance_Block__c,
                        Core_Contact_ID__c=Con.Core_Enterprise_Id__c,Core_Response__c=response.getBody())); 
                    }else{
                        
						Conwrap.FailedConLst =new List<Contact>();
			            Conwrap.FailedConLst.add(Con);
                      
				CntGECStagingFailed.add(new Core_Contact_GEC_Staging__c(Core_Status__c='Failed',Core_GEC_Retry_Counter__c=1,
				Core_Contact_Rec_Id__c=Con.Id,Core_Contact_Name__c=Con.FirstName+' '+Con.LastName,Core_Account_Id__c=Con.AccountId,
				Core_GEC_Blocked__c=Con.Core_Contact_Export_Compliance_Block__c,
				Core_Payload__c=ContactJSONRes,Core_Contact_ID__c=Con.Core_Enterprise_Id__c,Core_Response__c=response.getBody()));
				  
						Conwrap.FailedGECStagingrec=new List<Core_Contact_GEC_Staging__c>();
						Conwrap.FailedGECStagingrec.addAll(CntGECStagingFailed);  
                        warpperlst.add(Conwrap);
					}
              }
		if(ContactGECStaging.size()>0){
                  insert ContactGECStaging;
				}
		 }catch(Exception e) { 
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = 'Error',Core_Details__c = e.getMessage(), Core_Origin__c='Core_SendContact_to_AGS_onGECChange.SendGECInfoTOAGS', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
        }
        if(logEntries.size()>0 && !Test.isRunningTest()){
            insert logEntries;
        }
       return warpperlst;
   	}
	
	 /*
    * Method name  : generateAccessToken
    * Description  : This Method is used to generate the Accesstoken for AGS Integration
    * Return Type  : None
    * Parameter    : Name of the Custom Setting record where we stored the AGS integration information
    */
    
    
    public static String generateAccessToken(String integrationSettingname){
        Core_Apigee_Cred_Contact_GEC__c integrationSetting = Core_Apigee_Cred_Contact_GEC__c.getValues(integrationSettingname);
        String accessTokenURL = integrationSetting?.Core_Token_EndPoint_URL__c;
        String clientId = integrationSetting?.Core_Client_Id__c;
        String clientSecret = integrationSetting?.Core_Client_Secret__c;
        String grantType = integrationSetting?.Core_Grant_Type__c;
        AGSEndpointURL=integrationSetting?.Core_EndPoint_Url__c;
        
        HttpRequest accessTokenRequest = new HttpRequest();
        accessTokenRequest.setEndpoint(accessTokenURL);
        system.debug('TokenUrl'+accessTokenURL);
        accessTokenRequest.setMethod('POST');
        accessTokenRequest.setBody('grant_type='+grantType+'&client_id='+clientId+'&client_secret='+clientSecret);
        accessTokenRequest.setTimeout(12000);
        Http tokenCallout = new Http(); 
        HTTPResponse tokenResponse = tokenCallout.send(accessTokenRequest);
        system.debug('***tokenbody'+tokenResponse.getBody());
        
        //  return accessToken;
        if(tokenResponse.getStatusCode() == 200){
            Map<string,Object> resultMap = (Map<string,Object>)JSON.deserializeUntyped(tokenResponse.getBody());
            accessToken = (String) resultMap.get('access_token');
            return accessToken;
        } else {
            String strDetails=  'Call out Service Name : '+'Core_IPS_MyIntel_Utility'+'\n Trace Information : '+'STATUS:'+ tokenResponse.getStatus() + '\nSTATUS_CODE:' + tokenResponse.getStatusCode() + '\n Message:' + tokenResponse.toString();
            
            logEntries.add(new Core_Log_Entry__c(Core_Message__c =strDetails , Core_Origin__c='Core_SendContact_to_AGS_onGECChange.generateAccessToken', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
            
            return null;
        }
        
        
    }
	
	 /*
    * Method name  : ContactGECJSON
    * Description  : This Method is used to prepare the Contact JSON body to send it to AGS
    * Return Type  : None
    * Parameter    : String DisableBy,String DisableReason,Boolean GECFlag,String EnterpriseID
    */
    
    
    public static String ContactGECJSON(String DisableBy,String DisableReason,Boolean GECFlag,String EnterpriseID){
        system.debug('$$$$$$GECflag'+GECFlag);
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
		if(GECFlag !=null && GECFlag ==true){
        jsonGen.writeFieldName('urn:scim:schemas:extension:inteluser:1.0');
        jsonGen.writeStartObject(); 
        
        if(DisableBy!='' && DisableBy!=null){
            jsonGen.writeStringField('disabledBy',Label.Core_GEC_DisabledBy);
        }
        else{
            jsonGen.writeStringField('disabledBy',Label.Core_GEC_DisabledBy);
        }
		
        if(DisableReason!='' && DisableReason!=null){
            jsonGen.writeStringField('disableReason',Label.Core_GEC_Disabled_Reason);
        }else{
            jsonGen.writeStringField('disableReason',Label.Core_GEC_Disabled_Reason);
        }
        jsonGen.writeEndObject();
		}
        jsonGen.writeStringField('Active',String.valueOf(!GECFlag));
        //jsonGen.writeStringField('Active','false');
        String Urn='['+'urn:scim:schemas:core:1.0,'+'urn:scim:schemas:extension:inteluser:1.0'+']';
        jsonGen.writeStringField('Schemas',Urn);
		 if(EnterpriseID!='' && EnterpriseID!=null){
        jsonGen.writeStringField('Id',EnterpriseID);
		 }else{
		 jsonGen.writeStringField('Id','');
		 }
		
        system.debug('DisableBy'+DisableBy);
        system.debug('DisableReason'+DisableReason); 
        
        system.debug('GECFlag'+GECFlag);
        system.debug('EnterpriseID'+EnterpriseID);	    
        jsonGen.writeEndObject();
        String jsonData = jsonGen.getAsString();
        System.debug('Json Data - ' + jsonData);
        return jsonData;       
          
    }
    
     
     /*
     * Method name  : SendUpdatedContactsDatatoLicence
     * Description  : Method to Call PSG License related functions on change of contact name and email
     * Return Type  : void
     * Parameter    : List<Contact> newContactList, Map<Id, Contact> oldMap
     */   
    
        public static void SendUpdatedContactsDatatoLicence(List<Contact> newContactList, Map<Id, Contact> oldMap){
		    List<Contact> ConLst= new List<Contact>();
            Set<Id> ContactIdSet =new  Set<Id>();
		    for(Contact conRec : newContactList){
                if(conRec.FirstName != oldMap.get(conRec.Id).FirstName ||conRec.LastName != oldMap.get(conRec.Id).LastName || conRec.Email != oldMap.get(conRec.Id).Email){            
                  ConLst.add(conRec);              
            }   
                //Added By dnyanada To call PSG Method for Retriggering Sharing Logic
                if(conRec.Core_Account__c!=oldMap.get(conRec.Id).Core_Account__c){
                    ContactIdSet.add(conRec.id);
                }
        }
            
            if(ConLst.size() >0){
                system.debug('****ConLst'+ConLst);
                Sales_UpdateContactDetails.updateContactDetails_LicenseHost(ConLst);
                Sales_UpdateContactDetails.updateContactDetails_LicenseAdminDelegate (ConLst);

            }
            //Added By dnyanada To call PSG Method for Retriggering Sharing Logic
            if(ContactIdSet.size()>0){
                //Sales_LicenseAdminDelegateUtility.shareLicenseAndHostRecordsForAccountChange(ContactIdSet);
                Sales_UpdateSharingonAccountChange.updateSharingOn_LicenseHost(ContactIdSet);
            }
        }

}