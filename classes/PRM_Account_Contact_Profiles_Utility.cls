@SuppressWarnings('PMD')

public without sharing class PRM_Account_Contact_Profiles_Utility {
    
    public static String UNIFIEDID='UNIFIEDID';// TWC729-6955 : CIM Prime EOL –  Get Profile API - CIM EOL Activities
    public static Long responceTime;
    public static Long startTime;
    public static Boolean checksysAcc;
    public static Boolean isProgBased;
    public static String inpValue;
    public static String countryValue;
    //public static Boolean IPARefresh2 =  Boolean.valueOf(label.PRM_ipaRefresh); // IPA Switch Removal
    //public static Boolean ipaRefresh =  Boolean.valueOf(label.PRM_ipaRefresh);  // IPA2.0 - TWC727-2861 // IPA Switch Removal
    
    public static PRM_Account_Contact_Profiles_Model.Profiles GetAccountResults(String inputvalue, String addtlInputValue) {
        String AcctSFID = '';
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
        profiles.AccountResults = new PRM_Account_Contact_Profiles_Model.AccountResultWrapper();
        try{ 
            AcctSFID = getMatchingAccountSFID(inputvalue, addtlInputValue);  
            
            if(AcctSFID!=''){
                List<Account> accounts = [SELECT Id,Core_CIM_ID__c,core_business_party_id__c,
                                          (SELECT Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,Core_ERPM_Account_Number__c FROM Account_ERPM_Engagements__r) 
                                          //,Core_Account_Id__r.Name,Core_ERPM_Engagement_Id__r.Name,Core_ERPM_Engagement_Id__r.Core_Technical_Tier_Code__c 
                                          FROM Account WHERE Id= :AcctSFID];
                
                if(accounts.size() > 0){
                    profiles.AccountResults.Status = 'Success';
                    profiles.AccountResults.Responsecode = 200;
                    profiles.AccountResults.ErrorResponse = '';
                    
                    List<PRM_Account_Contact_Profiles_Model.AccountResult> acctResults = new List<PRM_Account_Contact_Profiles_Model.AccountResult>();
                    for(Core_Account_ERPM_Engagement__c ae:accounts[0].Account_ERPM_Engagements__r ){
                        PRM_Account_Contact_Profiles_Model.AccountResult acctRes = new PRM_Account_Contact_Profiles_Model.AccountResult();
                        acctRes.UNIFIEDID=accounts[0].core_business_party_id__c;// TWC729-6955 : CIM Prime EOL –  Get Profile API - CIM EOL Activities
                        acctRes.SalesforceId = String.valueOf(accounts[0].Id);
                        acctRes.ERPMAccountNumber = ae.Core_ERPM_Account_Number__c;
                        acctRes.ERPMEngagementCode = ae.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c;
                        acctResults.add(acctRes);
                    }
                    profiles.AccountResults.Results = acctResults;
                    
                    profiles.ResponseTimeMS = responseTimeCalc();
                    return profiles;
                }else{
                    return generateAccountResultError('No records found.');
                }
            }else{                
                return generateAccountResultError('No matching account found.');
            }
        }catch(Exception ex){
            return generateAccountResultError(ex.getMessage()+'###'+ex.getStackTraceString());            
        }
    }
        
    public static PRM_Account_Contact_Profiles_Model.Profiles GetRegRequestAccountProfile(String key, String param) {  
        boolean errorInDecryption = false;
        List<String> regReqEmailsList  =new List<String>();
        Map<String,Boolean> isSysAccMap = new Map<String,Boolean>();
        try{
            param = (key=='WECHATUNIONID') ?  EncryptDecryptHelper.DecryptData(param) : param;
            if(String.isEmpty(param)){
                errorInDecryption = true;
            }
        }catch(Exception ex) {
            errorInDecryption = true;           
        }
        if(errorInDecryption){
            return generateError('Error in decrypting WeChat Unioin Id. Please pass valid input.');
        }
        
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
        //profiles.RegRequestAccountProfile = new PRM_Account_Contact_Profiles_Model.RegRequestAccountProfile();
        //Jambert - System Account Check
        if(key != null && (key == 'EMAILID' || key == 'LOGINID') && param != null){
            regReqEmailsList.add(param);
        }
        if(regReqEmailsList.size()>0 && isProgBased == true && inpValue == 'IPA'){
            isSysAccMap= PRM_IPA_Utility.systemAccountDetails(regReqEmailsList);
            if(isSysAccMap.containsKey(param)){
                checksysAcc = true;
                profiles.SystemAccount = true;
            }else{
                checksysAcc = false;
                profiles.SystemAccount = false;
            }
        }
        

        PRM_Account_Contact_Profiles_Model.ContactAccountWrapper contAcct = getPersonAccountObj(buildCriteria(key,param,false));
       
        if(contAcct != null)
        {
            //if(contAcct != null /*&& contAcct.ContactBasicProfile.ContactBasicInformation.LoginStatus != 'Deleted'*/){

            //PRM_Account_Contact_Profiles_Model.AccountRequestWrapper acctReq = getAccountRequestDetailsObj(param,true);
            PRM_Account_Contact_Profiles_Model.AccountRequestWrapper acctReq = getAccountRequestDetailsObj(buildCriteria(key,param,true));
            profiles.ContactAccount = contAcct;
            profiles.AccountRequest = acctReq;
            profiles.ResponseTimeMS = responseTimeCalc();                                
            return profiles;
        }
        else 
        {

            PRM_Account_Contact_Profiles_Model.AccountRequestWrapper acctReq = getAccountRequestDetailsObj(buildCriteria(key,param,true));

            //Agate: Added as part of TWC729-4244: Search for an account within salesforce matching email domain and country and return
            if(isProgBased == true && inpValue == 'IPA'){
                PRM_CIMAccountSearchNew.billingCountryForAPI = getCountryCodeNameMapping(acctReq?.AccountRequestInformation?.ContactCountry);
                if(String.isBlank(PRM_CIMAccountSearchNew.billingCountryForAPI)){                    
                    PRM_CIMAccountSearchNew.billingCountryForAPI=getCountryCodeNameMapping(countryValue);
                }
                profiles.SearchResults = PRM_CIMAccountSearchNew.performStep1Search(param)?.SearchResults;
                
                //If account found in the configuration, update the registration request with the account id for allowing auto approval
               /* if(profiles.SearchResults != null && !profiles.SearchResults.isEmpty() 
                   && String.IsNotBlank(profiles.SearchResults[0].AccountID) && acctReq != null && acctReq.AccountRequestInformation != null 
                   && String.isNotBlank(acctReq.AccountRequestInformation.AccountRequestId)){
                           PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
                        regRequest.id = acctReq.AccountRequestInformation.AccountRequestId;
                        regRequest.PRM_Matching_Top_Account__c = profiles.SearchResults[0].AccountID;
                        update regRequest;  
                }  */
            }
            if(acctReq != null){      
                
                profiles.AccountRequest = acctReq;
                profiles.ResponseTimeMS = responseTimeCalc();    
                return profiles;             
            }else if(profiles.SearchResults !=null && profiles.SearchResults.size()>0){
                
        return profiles;
            } 
            else if(isProgBased == true && inpValue == 'IQR')
            {
                
                PRM_Account_Contact_Profiles_Model.AccountRequestWrapper acctReqIQR = getAcctIdBasedOnEmailDomain(param,inpValue);
                if(acctReqIQR != null)
                {
                    profiles.AccountRequest = acctReqIQR;
                    profiles.ResponseTimeMS = responseTimeCalc();  
                }
                
                return profiles;
            }
            else
            {
                
                return generateError('No records found');
            }
        }
        
    }
    
    public static PRM_Account_Contact_Profiles_Model.Profiles GetRegistrationRequestProfile(String key,String param){
        
        String query = 'SELECT id,Name,PRM_Status__c,PRM_Partner_Role__c,PRM_Email_ID__c,PRM_Enterprise_ID__c FROM PRM_Registration_Request__c WHERE '+buildCriteria(key,param,true);
        List<PRM_Registration_Request__c> newRegs = Database.query(query);
        /*List<PRM_Registration_Request__c> newRegs = [SELECT id,Name,PRM_Status__c,PRM_Partner_Role__c,PRM_Email_ID__c,PRM_Enterprise_ID__c
FROM PRM_Registration_Request__c WHERE Id= :param OR PRM_Enterprise_ID__c= :param OR PRM_Contact_Login_ID__c= :param OR PRM_Email_ID__c= :param];*/
        if(newRegs.size() > 0){
            PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
            profiles.RegistrationRequestProfile = new PRM_Account_Contact_Profiles_Model.RegistrationRequestProfileWrapper();
            //regReq.RegistrationRequest = new PRM_Account_Contact_Profiles_Model.RegistrationRequestProfileWrapper();
            profiles.RegistrationRequestProfile.RequestId = newRegs[0].Id;
            profiles.RegistrationRequestProfile.Status = newRegs[0].PRM_Status__c;
            profiles.RegistrationRequestProfile.PartnerRole = newRegs[0].PRM_Partner_Role__c;
            
            //regReq.RegistrationRequest.AccountInformation = 
            
            if(!String.isEmpty(newRegs[0].PRM_Email_ID__c)){
                //Check if the Contact/Accoutn is created
                List<Contact> contacts = [SELECT AccountId From Contact WHERE Email= :newRegs[0].PRM_Email_ID__c];
                if(contacts.size() > 0 && !String.isEmpty(contacts[0].AccountId)){
                    List<Account> accts = [SELECT id,Name,BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,
                                           BillingCountryCode,BillingPostalCode,ShippingStreet,ShippingCity,ShippingState,ShippingStateCode,
                                           ShippingCountry,ShippingCountryCode,ShippingPostalCode,
                                           (SELECT PRM_Account_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c,PRM_Relationship_Id__r.Name,PRM_InActive_Ind__c FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false AND PRM_Contact_Id__c= :contacts[0].Id),
                                           (SELECT PRM_Channel_Program_Id__r.Name,PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Status_Nm__c,PRM_Channel_Program_Level_Id__r.PRM_Partner_Tier_Name__c FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c!='Inactive')     
                                           From Account WHERE Id= :contacts[0].AccountId];
                    if(accts.size() > 0){
                        profiles.RegistrationRequestProfile.AccountInformation = getRegReqAccountDetails(accts[0]);
                    } 
                }
            }
            //return JSON.serialize(profiles);
            profiles.ResponseTimeMS = responseTimeCalc();
            return profiles;
        }else{
            return generateError('No records found');
        }  
    }
    
    
    

    
    private static PRM_Account_Contact_Profiles_Model.RegRequestAccountWrapper getRegReqAccountDetails(Account acct){
        PRM_Account_Contact_Profiles_Model.RegRequestAccountWrapper acctInfo = new PRM_Account_Contact_Profiles_Model.RegRequestAccountWrapper();
        acctInfo.Name = acct.Name;
        acctInfo.Address = new PRM_Account_Contact_Profiles_Model.AccountAddress();
        acctInfo.Address.PrimaryAddress = getAccountPrimaryAddress(acct);
        acctInfo.Address.SecondaryAddress = getAccountSecondaryAddress(acct);
        acctInfo.AccountContactRelationships = getAccountContactRelationships(acct);
        acctInfo.AccountChannelMemberships = getAccountChannelMemberships(acct);
        return acctInfo;
    }    
    
    public static PRM_Account_Contact_Profiles_Model.Profiles GetOnePartnerIDGroupMembers(String inputfield, String inputvalue){
        
        String AcctSFID = '';       
        if( inputfield == UNIFIEDID){ //Added UNIFIEDID TWC729-6955 : CIM Prime EOL –  Get Profile API - CIM EOL Activities           
            AcctSFID = getMatchingAccountSFID(inputvalue, null);            
        }else{
            AcctSFID = inputvalue; 
        }
        if(!String.isEmpty(AcctSFID)){        
            List<Account> accounts = [SELECT id,name, 
                                      (SELECT Name,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Name,Core_Partner_Account_Id__c,Core_Partner_Account_Id__r.Name,Core_Inactive_Ind__c,Core_MDA_Ind__c FROM Partner_Account_Group_Members1__r Where Core_Inactive_Ind__c=false )
                                      FROM Account WHERE Id= :AcctSFID];
            if(accounts.size()>0){
                PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
                profiles.OnePartnerIDGroupMembers = new PRM_Account_Contact_Profiles_Model.OnePartnerIDGroupMembersWrapper();
                profiles.OnePartnerIDGroupMembers.AccountId = accounts[0].Id;
                profiles.OnePartnerIDGroupMembers.AccountName =  accounts[0].Name;
                profiles.OnePartnerIDGroupMembers.OnePartnerIDGroupMembers = getOnePartnerIDGroupMembers(accounts[0]);
                //return JSON.serialize(profiles);
                profiles.ResponseTimeMS = responseTimeCalc();
                return profiles;
            }else{
                return generateError('No records found');
            }
        }else{
            return generateError('No records found');
        }
    }
    
    public static PRM_Account_Contact_Profiles_Model.Profiles GetAccountRequestDetails(String key,String param){
        
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
        profiles.AccountRequest = new PRM_Account_Contact_Profiles_Model.AccountRequestWrapper();
        profiles.AccountRequest = getAccountRequestDetailsObj(buildCriteria(key,param,true));
        //if( profiles.AccountRequest.AccountRequestInformation != null){
        if( profiles.AccountRequest != null){
            //return JSON.serialize(profiles);
            profiles.ResponseTimeMS = responseTimeCalc();
            return profiles;
        }else {
            return generateError('No records found');
        }
    }
    private static PRM_Account_Contact_Profiles_Model.AccountRequestWrapper getAccountRequestDetailsObj(String param){
        system.debug('getAccountRequestDetailsObj 1 param');
        
        String query = '';
            query = 'SELECT PRM_CIM_ID__c,PRM_Salesforce_ID__c,PRM_Address_Line_1__c,PRM_Address_Line_2__c,PRM_Alt_CompanyNameLang__c,PRM_Tax_Number__c ,PRM_Partner_Type__c,PRM_CIMStatusDetails__c,PRM_City__c,PRM_Email_ID__c,PRM_Company_Email_Domain__c,PRM_Account_Name__c,PRM_Company_National_ID__c,PRM_Enterprise_ID__c,PRM_EV_flag__c,PRM_First_Name__c,PRM_Profession__c,PRM_Last_Name__c,PRM_Person_Phone_Number__c,PRM_Country__c, PRM_Contact_Country__c, PRM_DeDup_Criteria__c,PRM_Dup_Status__c,PRM_Matching_Contact__c,PRM_Email_Domain_Check__c,PRM_Email_Log__c,PRM_EV_Expired_vs_Pending__c,PRM_isLocked__c,PRM_isSubmitted__c,PRM_Legal_Agreement_Criteria__c,PRM_Legal_Agreements__c,PRM_manualRecordCheck__c,PRM_Channel_Program__c,PRM_Channel_Program__r.Name,PRM_Channel_Program__r.PRM_programCode__c,PRM_Partner_Role__c,PRM_Partner_Segment__c,PRM_Channel_Program_Level__c,PRM_Phy_Address_Line_2__c,PRM_Phy_City__c,PRM_Phy_Country__c,PRM_Phy_State_Province__c,PRM_Phy_Zip_Postal_Code__c,PRM_Preferred_Language__c,PRM_Profile_Response__c,PRM_State_Province__c,PRM_Status__c,PRM_Status_Reason__c,PRM_Subscriptions__c,PRM_Tax_ID_Registration__c,PRM_Company_Size__c,PRM_Account_Phone__c,PRM_Account_URL__c,PRM_Zip_Postal_Code__c,PRM_Wechat_Union_Id__c,Entitlement_Details__r.Name,Job_Title__c,PRM_Channel_Program_Level__r.Name,PRM_Channel_Program_Level__r.PRM_Partner_Tier_Name__c,PRM_Company_Nm_Eng__c FROM PRM_Registration_Request__c WHERE '+param+ 'ORDER BY CreatedDate DESC';
        
        System.debug('query : '+query);
        List<PRM_Registration_Request__c> newRegs = Database.query(query);
        
        PRM_Account_Contact_Profiles_Model.AccountRequestWrapper acctReqWrapper = new  PRM_Account_Contact_Profiles_Model.AccountRequestWrapper();
        PRM_Account_Contact_Profiles_Model.AccountRequest acctReq = new PRM_Account_Contact_Profiles_Model.AccountRequest();
        if(newRegs.size()>0){            
            //acctReq.AccountRequest = new PRM_Account_Contact_Profiles_Model.AccountRequestWrapper();
            acctReqWrapper.AccountRequestInformation = getAccountRequestInformation(newRegs[0]);
            acctReqWrapper.subscriptions = new List<PRM_Account_Contact_Profiles_Model.AccountReqSubscription>();
            acctReqWrapper.TermsAndConditions = new List<PRM_Account_Contact_Profiles_Model.AccountReqTermsCondition>();
            //acctReqWrapper.CIMSearchResults = getAccountReqCIMSearchResults(newRegs[0]);  
            return acctReqWrapper;
        }else {
            return null;
        }
    }
/*    
    private static PRM_Account_Contact_Profiles_Model.AccountRequestWrapper getAccountRequestDetailsObj(String param,boolean getPending){
        PRM_Account_Contact_Profiles_Model.AccountRequestWrapper acctReqWrapper = new  PRM_Account_Contact_Profiles_Model.AccountRequestWrapper();
        PRM_Account_Contact_Profiles_Model.AccountRequest acctReq = new PRM_Account_Contact_Profiles_Model.AccountRequest();
        //String status = (getPending) ? 'New':'Approved';
        system.debug('getAccountRequestDetailsObj 2 params');
        List<String> status = (getPending) ? new List<String> {'New','Rejected'}:new List<String> {'Approved'};
             List<PRM_Registration_Request__c> newRegs = [SELECT PRM_CIM_ID__c,PRM_Salesforce_ID__c,PRM_Address_Line_1__c,PRM_Address_Line_2__c,
                                                         PRM_Partner_Type__c,PRM_CIMStatusDetails__c,PRM_City__c,PRM_Email_ID__c,PRM_Company_Email_Domain__c,
                                                         PRM_Account_Name__c,PRM_Company_National_ID__c,PRM_Enterprise_ID__c,PRM_EV_flag__c,
                                                         PRM_EV_Token__c,PRM_First_Name__c,PRM_Profession__c,PRM_Last_Name__c,
                                                         PRM_Contact_Login_ID__c,PRM_Person_Phone_Number__c,PRM_Country__c, PRM_Contact_Country__c, PRM_DeDup_Criteria__c,
                                                         PRM_Dup_Status__c,PRM_Matching_Contact__c,PRM_Email_Domain_Check__c,PRM_Email_Log__c,
                                                         PRM_EmailVerifiedDateTime__c,PRM_EV_Expired_vs_Pending__c,PRM_isLocked__c,PRM_isSubmitted__c,
                                                         PRM_Legal_Agreement_Criteria__c,PRM_Legal_Agreements__c,PRM_manualRecordCheck__c,PRM_Channel_Program__c,PRM_Channel_Program__r.Name,PRM_Channel_Program__r.PRM_programCode__c,
                                                         PRM_Partner_Role__c,PRM_Partner_Segment__c,PRM_Channel_Program_Level__c,PRM_Phy_Address_Line_2__c,
                                                         PRM_Phy_City__c,PRM_Phy_Country__c,PRM_Phy_State_Province__c,PRM_Phy_Zip_Postal_Code__c,
                                                         PRM_Preferred_Language__c,PRM_Profile_Response__c,PRM_State_Province__c,
                                                         PRM_Status__c,PRM_Status_Reason__c,PRM_Subscriptions__c,PRM_Tax_ID_Registration__c,
                                                         PRM_Company_Size__c,PRM_Account_Phone__c,PRM_Account_URL__c,PRM_Zip_Postal_Code__c,
                                                         PRM_Wechat_Union_Id__c,Entitlement_Details__r.Name,Job_Title__c//PRM_Wechat_Open_Id__c,PRM_Wechat_Union_Id__c, PRM_Registration_Source_txt__c,
                                                         //(SELECT Name,PRM_Partner_Subscription__r.Name,PRM_Partner_Subscription__r.PRM_Subscription_Cd__c FROM Subscriptions__r),
                                                         //(SELECT Name,PRM_Agreement_Signed_Date__c,PRM_Partner_Agreement__r.Name,PRM_Partner_Agreement__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement__r.PRM_Agreement_Category_Nm__c FROM Terms_and_Conditions__r),
                                                         //(SELECT PRM_Account_Nm__c,PRM_AddressLine1_Txt__c,PRM_AddressLoc_Nm__c,PRM_AddressType_Nm__c,PRM_CIM_Id__c,Name,PRM_SearchScore_Nbr__c,PRM_City_Nm__c,PRM_Country_Cd__c,PRM_Country_Nm__c,PRM_Subdiv_Cd__c,PRM_Subdiv_Nm__c,PRM_Postal_Cd__c,PRM_Account_Id__c FROM CIM_Search_Results__r)
                                                         FROM PRM_Registration_Request__c WHERE PRM_Status__c IN :status AND (Id= :param OR PRM_Enterprise_ID__c= :param OR PRM_Contact_Login_ID__c= :param OR PRM_Email_ID__c= :param OR PRM_Wechat_Union_Id__c= :param )];
       

        
        system.debug('newRegs.size() ==>'+newRegs.size());
        if(newRegs.size()>0){            
            //acctReq.AccountRequest = new PRM_Account_Contact_Profiles_Model.AccountRequestWrapper();
            acctReqWrapper.AccountRequestInformation = getAccountRequestInformation(newRegs[0]);
            acctReqWrapper.subscriptions = new List<PRM_Account_Contact_Profiles_Model.AccountReqSubscription>();
            acctReqWrapper.TermsAndConditions = new List<PRM_Account_Contact_Profiles_Model.AccountReqTermsCondition>();
            //acctReqWrapper.CIMSearchResults = getAccountReqCIMSearchResults(newRegs[0]);  
            return acctReqWrapper;
        }else {
            return null;
        }
    }
 */   
    /*
private static List<PRM_Account_Contact_Profiles_Model.AccountReqTermsCondition> getAccountReqTermsConditions(PRM_Registration_Request__c newReg){
List<PRM_Account_Contact_Profiles_Model.AccountReqTermsCondition> termsConditions = new List<PRM_Account_Contact_Profiles_Model.AccountReqTermsCondition>();
for(Terms_and_Conditions__c tc: newReg.Terms_and_Conditions__r){
PRM_Account_Contact_Profiles_Model.AccountReqTermsCondition termsCondition = new PRM_Account_Contact_Profiles_Model.AccountReqTermsCondition();
termsCondition.Name = tc.Name;
termsCondition.SignedDate = tc.PRM_Agreement_Signed_Date__c;
termsCondition.PartnerAgreementName = tc.PRM_Partner_Agreement__r.Name;
termsCondition.PartnerAgreementCode = tc.PRM_Partner_Agreement__r.PRM_Agreement_Cd__c;
termsCondition.PartnerAgreementCategory = tc.PRM_Partner_Agreement__r.PRM_Agreement_Category_Nm__c;
termsConditions.add(termsCondition);
}
return termsConditions;
}
private static List<PRM_Account_Contact_Profiles_Model.AccountReqSubscription> getAccountReqSubscriptions(PRM_Registration_Request__c newReg){
List<PRM_Account_Contact_Profiles_Model.AccountReqSubscription> acctReqSubs = new List<PRM_Account_Contact_Profiles_Model.AccountReqSubscription>();
for(Subscription__c ps : newReg.Subscriptions__r){
PRM_Account_Contact_Profiles_Model.AccountReqSubscription acctReqSub = new PRM_Account_Contact_Profiles_Model.AccountReqSubscription();
acctReqSub.name = ps.Name;
acctReqSub.SubscriptionName = ps.PRM_Partner_Subscription__r.Name;
acctReqSub.SubscriptionCode =  ps.PRM_Partner_Subscription__r.PRM_Subscription_Cd__c;
acctReqSubs.add(acctReqSub);
}
return acctReqSubs;
}
*/
    private static PRM_Account_Contact_Profiles_Model.AccountRequestInformationWrapper getAccountRequestInformation(PRM_Registration_Request__c newReg){
        PRM_Account_Contact_Profiles_Model.AccountRequestInformationWrapper acctReqInfo = new PRM_Account_Contact_Profiles_Model.AccountRequestInformationWrapper();
        acctReqInfo = getAcctIdBasedOnEmailDomain(newReg);
        acctReqInfo.AccountRequestId = newReg.Id;
        //Updated By Naresh as part of IQR Registration enablement
        //acctReqInfo.AccountSalesforceID = newReg.PRM_Salesforce_ID__c;
        
        //if(newReg.PRM_Channel_Program__r.Name==Label.Pricing_Tender_PGM_Channel){
        //acctReqInfo.AccountSalesforceID = getAccountId(newReg);           
        //getAcctIdBasedOnEmailDomain(newReg, acctReqInfo);
        //}else{
        //   acctReqInfo.AccountSalesforceID = newReg.PRM_Salesforce_ID__c; 
        // }
        
        acctReqInfo.AddressLine1 = newReg.PRM_Address_Line_1__c;
        acctReqInfo.AddressLine2 = newReg.PRM_Address_Line_2__c;
        acctReqInfo.BizOrgType = newReg.PRM_Partner_Type__c;
        acctReqInfo.CIMStatusDetails = newReg.PRM_CIMStatusDetails__c;
        acctReqInfo.City = newReg.PRM_City__c;
        acctReqInfo.CompanyEmailDomain = newReg.PRM_Company_Email_Domain__c;
        acctReqInfo.CompanyName = newReg.PRM_Account_Name__c;
        acctReqInfo.CompanyNationalID = newReg.PRM_Company_National_ID__c;
        acctReqInfo.ContactEnterpriseID = newReg.PRM_Enterprise_ID__c;
        acctReqInfo.ContactEVflag = newReg.PRM_EV_flag__c;
        acctReqInfo.ContactFirstName = newReg.PRM_First_Name__c;
        //acctReqInfo.ContactJobFunction = newReg.PRM_Job_Function__c;
        acctReqInfo.ContactProfession = newReg.PRM_Profession__c;
        acctReqInfo.ContactLastName = newReg.PRM_Last_Name__c;
        acctReqInfo.ContactPhoneNumber = newReg.PRM_Person_Phone_Number__c;
        acctReqInfo.Country = newReg.PRM_Country__c;
        acctReqInfo.ContactCountry = newReg.PRM_Contact_Country__c;
        acctReqInfo.CompanyNameEng = newReg.PRM_Company_Nm_Eng__c;
        acctReqInfo.AltCompanyNameEng  = newReg.PRM_Alt_CompanyNameLang__c;
        acctReqInfo.DuplicateAccountCheck = newReg.PRM_DeDup_Criteria__c;
        acctReqInfo.DuplicateAccountStatus = newReg.PRM_Dup_Status__c;
        acctReqInfo.DuplicateContact = newReg.PRM_Matching_Contact__c;
        acctReqInfo.Email = newReg.PRM_Email_ID__c;
        acctReqInfo.EmailDomainCheck = newReg.PRM_Email_Domain_Check__c;
        acctReqInfo.EmailLog = newReg.PRM_Email_Log__c;
        acctReqInfo.EVExpiredvsPending = newReg.PRM_EV_Expired_vs_Pending__c;
        acctReqInfo.EntitlementDetails = newReg.Entitlement_Details__r.Name;
        acctReqInfo.isLocked = newReg.PRM_isLocked__c;
        acctReqInfo.isSubmitted = newReg.PRM_isSubmitted__c;
        acctReqInfo.LegalAgreementCheck = newReg.PRM_Legal_Agreement_Criteria__c;
        acctReqInfo.LegalAgreements = newReg.PRM_Legal_Agreements__c;
        acctReqInfo.manualRecordCheck = newReg.PRM_manualRecordCheck__c;
        acctReqInfo.PartnerProgram = newReg.PRM_Channel_Program__c;
        acctReqInfo.PartnerProgramCode = newReg.PRM_Channel_Program__r.PRM_programCode__c;
        acctReqInfo.PartnerRole = newReg.PRM_Partner_Role__c;
        acctReqInfo.TaxNumber = newReg.PRM_Tax_Number__c;
        //acctReqInfo.PartnerRoleLabel = 
        if(!String.isEmpty(newReg.PRM_Partner_Role__c) /*&& (ipaRefresh||Test.isRunningTest())*/){
            List<Schema.PicklistEntry> pickListValues = PRM_Registration_Request__c.PRM_Partner_Role__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry picklistval : pickListValues) {
                if (picklistval.getValue() == newReg.PRM_Partner_Role__c) {
                    acctReqInfo.PartnerRoleLabel = picklistval.getLabel();
                    break;
                }
            }
        }
        //acctReqInfo.PartnerSegment = newReg.PRM_Partner_Segment__c;
        acctReqInfo.PartnerSegment = null; // IPA2.0 - TWC727-2861 // IPA Switch Removal
        acctReqInfo.PartnerTier = newReg.PRM_Channel_Program_Level__r.Name;
        //if(ipaRefresh||Test.isRunningTest()){
            acctReqInfo.PartnerTierLabel = newReg.PRM_Channel_Program_Level__r.PRM_Partner_Tier_Name__c;
        //} // IPA2.0 - TWC727-2861 // IPA Switch Removal
        acctReqInfo.PhysicalAddressLine2 = newReg.PRM_Phy_Address_Line_2__c;
        acctReqInfo.PhysicalCity = newReg.PRM_Phy_City__c;
        acctReqInfo.PhysicalCountry = newReg.PRM_Phy_Country__c;
        acctReqInfo.PhysicalStateProvince = newReg.PRM_Phy_State_Province__c;
        acctReqInfo.PhysicalZipCode = newReg.PRM_Phy_Zip_Postal_Code__c;
        acctReqInfo.PreferredLanguage = newReg.PRM_Preferred_Language__c;
        acctReqInfo.ProfileResponses = newReg.PRM_Profile_Response__c;
        acctReqInfo.StateProvince = newReg.PRM_State_Province__c;
        acctReqInfo.Status = newReg.PRM_Status__c;
        acctReqInfo.StatusReason = newReg.PRM_Status_Reason__c;
        acctReqInfo.Subscriptions = newReg.PRM_Subscriptions__c;
        acctReqInfo.TaxIDRegistrationNumber  = newReg.PRM_Tax_ID_Registration__c;  
        acctReqInfo.Userdefinedcompanysize = newReg.PRM_Company_Size__c;
        acctReqInfo.UserdefinedPhonenumber = newReg.PRM_Account_Phone__c;
        acctReqInfo.UserdefinedWebsite = newReg.PRM_Account_URL__c;
        acctReqInfo.ZipPostalCode = newReg.PRM_Zip_Postal_Code__c;
        acctReqInfo.WeChatUnionId = newReg.PRM_Wechat_Union_Id__c != null ? EncryptDecryptHelper.EncryptData(newReg.PRM_Wechat_Union_Id__c) : '';
        acctReqInfo.JobTitle=newReg.Job_Title__c;     
        
        //-----------------------------We chat-----------------------------
        /*
acctReqInfo.WechatOpenId = newReg.PRM_Wechat_Open_Id__c;
acctReqInfo.WechatUnionId = newReg.PRM_Wechat_Union_Id__c;
acctReqInfo.RegistrationSource = newReg.PRM_Registration_Source_txt__c;
*/
        //-----------------------------We chat-----------------------------
        
        return acctReqInfo;
    }   
    
    private static PRM_Account_Contact_Profiles_Model.AccountRequestWrapper getAcctIdBasedOnEmailDomain(string emailID,string inpVal)
    {
        PRM_Account_Contact_Profiles_Model.AccountRequestWrapper acctReqWrapper = new  PRM_Account_Contact_Profiles_Model.AccountRequestWrapper();
        PRM_Account_Contact_Profiles_Model.AccountRequest acctReq = new PRM_Account_Contact_Profiles_Model.AccountRequest();
        
        PRM_Account_Contact_Profiles_Model.AccountRequestInformationWrapper acctReqInfo = new PRM_Account_Contact_Profiles_Model.AccountRequestInformationWrapper();
        System.debug('EmailID--> '+ emailID + ' inpVal : ' +inpVal);
        System.debug(Label.Email_domain_account_mapping.split(','));
        if(Label.Email_domain_account_mapping.split(',').contains(inpVal) && String.isNotBlank(emailID))
        {        
            String domain = emailID.right(emailID.length()-emailID.indexOf('@')-1).toLowerCase();
            List<Core_Account_Whitelisted_Domains__c> accountDomainMapping =  [SELECT id,Name, Account__r.Id, Account__r.Name,Account__r.Core_User_Defined_Website__c FROM Core_Account_Whitelisted_Domains__c 
                                                                               WHERE Partner_Program__r.PRM_programCode__c =: inpVal
                                                                               AND Name =: domain ORDER BY CreatedDate ASC limit 1];
        System.debug('accountDomainMapping.size()--> ' + accountDomainMapping.size());
            if(accountDomainMapping.size() > 0)
            {
                acctReqInfo.AccountSalesforceID = accountDomainMapping[0].Account__r.Id;
                acctReqInfo.AccountName = accountDomainMapping[0].Account__r.Name;
                acctReqWrapper.AccountRequestInformation = acctReqInfo;
                acctReqWrapper.subscriptions = new List<PRM_Account_Contact_Profiles_Model.AccountReqSubscription>();
                acctReqWrapper.TermsAndConditions = new List<PRM_Account_Contact_Profiles_Model.AccountReqTermsCondition>();
            }
            else 
            {
                return null;
            }
        }
        return acctReqWrapper;
    }
  
    private static PRM_Account_Contact_Profiles_Model.AccountRequestInformationWrapper getAcctIdBasedOnEmailDomain(PRM_Registration_Request__c newReg){
        PRM_Account_Contact_Profiles_Model.AccountRequestInformationWrapper acctReqInfo = new PRM_Account_Contact_Profiles_Model.AccountRequestInformationWrapper();
        if(Label.Email_domain_account_mapping.split(',').contains(newReg.PRM_Channel_Program__r.Name) &&
           !String.isEmpty(newReg.PRM_Email_ID__c) && String.isEmpty(newReg.PRM_Salesforce_ID__c)){
               String email = newReg.PRM_Email_ID__c;        
               String domain = email.right(email.length()-email.indexOf('@')-1).toLowerCase();              
               //List<Pricing_Account_Domain_Mapping__mdt> accountDomainMapping = [SELECT MasterLabel,Pricing_Account_ID__c,Pricing_Account_Nm__c,Pricing_Account_Website_Txt__c
               //                                                                  FROM Pricing_Account_Domain_Mapping__mdt WHERE MasterLabel=:domain];
               
               List<Core_Account_Whitelisted_Domains__c> accountDomainMapping =  [SELECT id,Name, Account__r.Id, Account__r.Name,Account__r.Core_User_Defined_Website__c FROM Core_Account_Whitelisted_Domains__c 
                                                                                  WHERE Partner_Program__r.Name =: newReg.PRM_Channel_Program__r.Name
                                                                                  AND Name =: domain ORDER BY CreatedDate ASC limit 1];
               
               if(accountDomainMapping.size() > 0){
                   acctReqInfo.AccountSalesforceID = accountDomainMapping[0].Account__r.Id;
                   acctReqInfo.AccountName = accountDomainMapping[0].Account__r.Name;
                   //acctReqInfo.AccountWebsite = accountDomainMapping[0].Account__r.Core_User_Defined_Website__c;
               }
               //else{
               //    acctReqInfo.AccountSalesforceID = newReg.PRM_Salesforce_ID__c;
               //}
               //return (accountDomainMapping.size()>0 ?accountDomainMapping[0].Pricing_Account_ID__c: newReg.PRM_Salesforce_ID__c);
           }else{
               acctReqInfo.AccountSalesforceID = newReg.PRM_Salesforce_ID__c;
           }
        return acctReqInfo;
    }
    
    public static PRM_Account_Contact_Profiles_Model.Profiles GetAccountProfile(String inputfield, String inputvalue, String addtlInputValue){
        
        String AcctSFID = '';
        //system.debug('inside GetAccountProfile ===>'+inputfield);
        if( inputfield == UNIFIEDID){            
            AcctSFID = getMatchingAccountSFID(inputvalue, addtlInputValue);  // TWC729-6955 : CIM Prime EOL –  Get Profile API - CIM EOL Activities        
        }else{
            AcctSFID = inputvalue; 
        }
        System.debug('Listttttstring'+AcctSFID);
        if(!String.isEmpty(AcctSFID)){
            //Core_Alt_Address_1__c,Core_Alt_Address_2__c,Core_Alt_Language_City__c,Core_Alt_Language_State_Province__c,Core_Alt_Language_country__c,Core_Alt_Language_Postal_Code__c,
            List<Account> accounts = [SELECT name,Parent.Name,Core_Alternate_Language_Name__c,Core_Account_Type__c,Core_Geo__c,Core_Sub_Geo__c,
                                      Core_IPA_Partner_Role__c,Core_Account_Legal_Name__c,Core_Prime_Account_Name__c,
                                      Core_Covered_Account__c,Core_CNDA_Number__c,Core_Sales_Groups__c,Core_Account_BU_Focus__c,
                                      Core_Account_Tier__c,Industry,Core_CIM_ID__c,Core_IPS_Active__c,Core_Business_ID__c,
                                      Core_Business_Partner_Id__c,BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,
                                      BillingCountryCode,BillingPostalCode,ShippingStreet,ShippingCity,ShippingState,ShippingStateCode,Core_IPA_Badge_Tier__c,AccountNumber,
                                      ShippingCountry,ShippingCountryCode,ShippingPostalCode,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_User_Defined_Website__c,Core_User_Defined_Number_of_Employees__c,Core_User_Defined_Phone_Number__c,
                                      Core_Partner_Alliance_Program__c, Core_IPA_Partner_Segment__c, Core_English_Only_Name__c,
                                      Core_Deactivated__c,Core_Deactivation_Reason__c,Core_B2B_Entitlement__c,Core_B2B_ERPM_Account_Number__c,RecordType.Name,
                                      Core_Business_Party_Id__c,core_data_simplified_account_nm__c,core_data_simplified_local_language_nm__c,core_customer_aggregation_type__c,Unified_Hierarchy_View__c,core_data_country_nm__c,Core_Account_Record_Type__c,Core_IPA_One_Partner_Id__c,
                                      Owner.Name,Core_Account_Owner_Email__c,   
                                      //Core_IPA_Partner_Prog_Application__c, (SELECT id,Name,Email From Contacts),
                                      (SELECT PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_Relationship_Id__r.Name,PRM_Status_Nm__c,PRM_InActive_Ind__c FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false),
                                      (SELECT Core_Account_Id__r.Name,Core_ERPM_Engagement_Id__r.Name,Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,Core_ERPM_Engagement_Id__r.Core_Technical_Tier_Code__c FROM Account_ERPM_Engagements__r),
                                      (SELECT PRM_Channel_Program_Id__r.Name,PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Status_Nm__c,PRM_Channel_Program_Level_Id__r.PRM_Partner_Tier_Name__c FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c!='Inactive'),
                                      (SELECT PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Status_Nm__c FROM AccountBenefitAssociations__r WHERE PRM_Status_Nm__c='Active'),
                                      //PRM_Start_Date_Dt__c,PRM_End_Date_Dt__c,
                                      (SELECT Name,PRM_InActive_Ind__c,PRM_Specialty_Type__c,PRM_Specialty_Id__r.Name,PRM_Specialty_Id__r.PRM_Role_Nm__c,PRM_Specialty_Id__r.PRM_Tier_Nm__c FROM Account_Specialty_Associations__r WHERE PRM_InActive_Ind__c=false),
                                      (SELECT Name,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Name,Core_Partner_Account_Id__c,Core_Partner_Account_Id__r.Name,Core_Inactive_Ind__c,Core_MDA_Ind__c FROM Partner_Account_Group_Members1__r WHERE Core_Inactive_Ind__c=false),
                                      //Step 4
                                      (SELECT  Account__r.Name, Business_Types__r.Name,Business_Types__r.Business_Type_Code__c ,Status__c,Effective_End_Date__c,Effective_Start_Date__c,Status_Reason__c FROM Account_Business_Types__r),
                                      (SELECT Name,PRM_Agreement_Sign_Dt__c,PRM_Signed_By_Email__c,PRM_Signed_By_Name__c,PRM_Partner_Agreement_Id__r.Name,PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name FROM AccountLegalAgreementAssociations__r),
                                      (SELECT Name,Core_Type__c,Core_Effective_Start_Date__c,Core_Effective_End_Date__c FROM Core_Account_Id__r)
                                      FROM Account WHERE Id= :AcctSFID];
            System.debug('Listtttt'+accounts);
            list<PRM_AccountBenefitAssociation__c> opidbenefits = new list<PRM_AccountBenefitAssociation__c>();
            if (!accounts.isEmpty() && accounts[0].Core_Account_Record_Type__c == 'Intel Account'  && accounts[0].Core_IPA_One_Partner_Id__c!=null/*&& (ipaRefresh||Test.isRunningTest())*/){
                opidbenefits = [SELECT PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Status_Nm__c FROM PRM_AccountBenefitAssociation__c WHERE PRM_Account_Id__c =: accounts[0].Core_IPA_One_Partner_Id__c and PRM_Status_Nm__c='Active'];
            } //varun
            //OR Core_CIM_ID__c= :param Limit 1
            if(accounts.size()>0){
                PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
                profiles.AccountProfile = new  PRM_Account_Contact_Profiles_Model.AccountProfileWrapper();    
                //acctProfile.AccountProfile = new PRM_Account_Contact_Profiles_Model.AccountProfileWrapper();
                profiles.AccountProfile.AccountInformation = getAccountInformation(accounts[0]);
                profiles.AccountProfile.AccountChannelMemberships = getAccountChannelMemberships(accounts[0]);
                profiles.AccountProfile.AccountContactRelationships = getAccountContactRelationships(accounts[0]);
                profiles.AccountProfile.AccountEngagements = getAccountERPMEngagements(accounts[0]);
                //acctProfile.AccountProfile.Contacts = getAccountContacts(accounts[0]);
                profiles.AccountProfile.AccoutBenefitAssociations = (accounts[0].Core_Account_Record_Type__c == 'Intel Account' /*&& (ipaRefresh||Test.isRunningTest())*/ )? (getAccoutBenefitAssociations(opidbenefits)):(getAccoutBenefitAssociations(accounts[0].AccountBenefitAssociations__r)); //varun
                //profiles.AccountProfile.AccoutBenefitAssociations = getAccoutBenefitAssociations(accounts[0]);
                //profiles.AccountProfile.AccountSpecialityAssociations = getAccountSpecialityAssociations(accounts[0]);
                profiles.AccountProfile.AccountSpecialityAssociations = new List<PRM_Account_Contact_Profiles_Model.AccountSpecialityAssociation>(); // IPA2.0 - TWC727-2861 // IPA Switch Removal
                //acctProfile.AccountProfile.OnePartnerIDGroupMembers = getOnePartnerIDGroupMembers(accounts[0]);
                profiles.AccountProfile.AccountLegalAgreements = getAccountLegalAgreements(accounts[0]);
                profiles.AccountProfile.AccountBusinessTypes = getAccountBusinessType(accounts[0]);   //step 5
                //profiles.AccountProfile.ComplianceWatchLists=getAccountComplianceWatchLists(accounts[0]);  //Commenting as part of TWC729-8872
                //return JSON.serialize(profiles);
                profiles.ResponseTimeMS = responseTimeCalc();
                return profiles;
            }else{
                return generateError('No records found');
            }
        }else{
            return generateError('No records found');
        }
        
    }
    private static List<PRM_Account_Contact_Profiles_Model.AccountLegalAgreement> getAccountLegalAgreements(Account acct){
        //(SELECT Name,PRM_Agreement_Sign_Dt__c,PRM_Contact__r.Name,PRM_Partner_Agreement_Id__r.Name,PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name FROM AccountLegalAgreementAssociations__r)
        List<PRM_Account_Contact_Profiles_Model.AccountLegalAgreement> legalAgreements = new List<PRM_Account_Contact_Profiles_Model.AccountLegalAgreement>();
        for(PRM_AccountLegalAgreemntAssociation__c agreement : acct.AccountLegalAgreementAssociations__r){
            PRM_Account_Contact_Profiles_Model.AccountLegalAgreement legalAgreement = new PRM_Account_Contact_Profiles_Model.AccountLegalAgreement();
            legalAgreement.LeagalAgreementName = agreement.Name;
            legalAgreement.AgreementSignedDate = agreement.PRM_Agreement_Sign_Dt__c;
            //IPA Refresh 2.0 - TWC729-7874-start
            legalAgreement.AgreementSignedBy = agreement.PRM_Signed_By_Name__c;
            //IPA Refresh 2.0 - TWC729-7874-end
            legalAgreement.IsInActive = agreement.PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c;
            legalAgreement.PartnerAgreementName = agreement.PRM_Partner_Agreement_Id__r.Name;
            legalAgreement.PartnerAgreementCode = agreement.PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c;
            legalAgreement.PartnerProgramName = agreement.PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name;
            legalAgreements.add(legalAgreement);  
        }
        return legalAgreements;
    }
    
    ///////////////////////////////////////US///////////////////////////////
    //For AccountBT part 6
    private static List<PRM_Account_Contact_Profiles_Model.AccountBusinessType>  getAccountBusinessType(Account acct){
       
        List<PRM_Account_Contact_Profiles_Model.AccountBusinessType> accBTs = new List<PRM_Account_Contact_Profiles_Model.AccountBusinessType>();       
        
        for(Account_Business_Types__c businessType : acct.Account_Business_Types__r){
            PRM_Account_Contact_Profiles_Model.AccountBusinessType accBT = new PRM_Account_Contact_Profiles_Model.AccountBusinessType();
    
            accBT.BusinessTypeCode = businessType.Business_Types__r.Business_Type_Code__c;
            accBT.BusinessTypeName =  businessType.Business_Types__r.Name;
            accBT.Status = businessType.Status__c ;
            accBT.AccountName = businessType.Account__r.Name;   
            //start add for TWC722-186
            accBT.EffectiveEndDate = businessType.Effective_End_Date__c;
            accBT.EffectiveStartDate = businessType.Effective_Start_Date__c;
            //accBT.StatusReason = businessType.Status_Reason__c;
            //end add for TWC722-186
            accBTs.add(accBT);  
        }
        System.debug('Acclist'+accBTs);
        return accBTs;
        
    }
   /* private static List<PRM_Account_Contact_Profiles_Model.ComplianceWatchList> getAccountComplianceWatchLists(Account acct){
        List<PRM_Account_Contact_Profiles_Model.ComplianceWatchList> acctWatchList = new List<PRM_Account_Contact_Profiles_Model.ComplianceWatchList>();
         for(Core_Account_Compliance_Watch_List__c watchList : acct.Core_Account_Id__r){
            PRM_Account_Contact_Profiles_Model.ComplianceWatchList accWL = new PRM_Account_Contact_Profiles_Model.ComplianceWatchList();
        accWL.ComplianceName=watchList.Name;  
            accWL.ComplianceType = watchList.Core_Type__c;
            accWL.EffectiveStartDate =  watchList.Core_Effective_Start_Date__c;
            accWL.EffectiveEndDate = watchList.Core_Effective_End_Date__c;         
            acctWatchList.add(accWL);  
        }
        return acctWatchList;
    }  */  //Commenting as part of TWC729-8872
    
     //For Contact BT
   private static List<PRM_Account_Contact_Profiles_Model.ContactBusinessType>  getContactBusinessType(Contact con){
      
       List<PRM_Account_Contact_Profiles_Model.ContactBusinessType> conBTs = new List<PRM_Account_Contact_Profiles_Model.ContactBusinessType>();       
        
        for(Contact_Business_Types__c businessType : con.Contact_Business_Types__r){
            PRM_Account_Contact_Profiles_Model.ContactBusinessType conBT = new PRM_Account_Contact_Profiles_Model.ContactBusinessType();
           
            conBT.BusinessTypeName =  businessType.Business_Types__r.Name;
            conBT.BusinessTypeCode =  businessType.Business_Types__r.Business_Type_Code__c;
            conBT.Status = businessType.Status__c ;
            conBT.Email = businessType.Contact__r.Email;
            //start add for TWC722-186
            //conBT.ContactName =  businessType.Contact__r.Name;
            //ConBt.StatusReason = businessType.Status_Reason__c;
            //end add for TWC722-186
            conBTs.add(conBT);  
        }
        
        return conBTs;
       
    }
    ///////////////////////////////////////US END////////////////////////////
    
    ////////////////////us end/////////////////////////////
    
    private static List<PRM_Account_Contact_Profiles_Model.OnePartnerIDGroupMember> getOnePartnerIDGroupMembers(Account acct){
        List<PRM_Account_Contact_Profiles_Model.OnePartnerIDGroupMember> opidms = new List<PRM_Account_Contact_Profiles_Model.OnePartnerIDGroupMember>();
        //system.debug('OnePartnerIDGroupMembers ==>'+ acct.Partner_Account_Group_Members1__r);
        for(Core_Account_Group_Member__c onePartnerGM: acct.Partner_Account_Group_Members1__r){
            PRM_Account_Contact_Profiles_Model.OnePartnerIDGroupMember opidm = new PRM_Account_Contact_Profiles_Model.OnePartnerIDGroupMember();
            opidm.OnePartnerGroupMemberName = onePartnerGM.Name;
            opidm.IntelAccountId = onePartnerGM.Core_Intel_Account_Id__c;
            opidm.IntelAccountName = onePartnerGM.Core_Intel_Account_Id__r.Name;
            opidm.OnePartnerAccountId = onePartnerGM.Core_Partner_Account_Id__c;
            opidm.OnePartnerAccountName = onePartnerGM.Core_Partner_Account_Id__r.Name;
            opidm.isInactive = onePartnerGM.Core_Inactive_Ind__c;
            opidm.MDAIndicator = onePartnerGM.Core_MDA_Ind__c;
            opidms.add(opidm);            
        }
        return opidms;
    }
    //this method below can be removed as part of IPA 2.0
    @testvisible
    private static List<PRM_Account_Contact_Profiles_Model.AccountSpecialityAssociation> getAccountSpecialityAssociations(Account acct){
        List<PRM_Account_Contact_Profiles_Model.AccountSpecialityAssociation> asas = new List<PRM_Account_Contact_Profiles_Model.AccountSpecialityAssociation>();
        for(PRM_Account_Specialty_Association__c acctSpecialityAssoc : acct.Account_Specialty_Associations__r){
            PRM_Account_Contact_Profiles_Model.AccountSpecialityAssociation asa = new PRM_Account_Contact_Profiles_Model.AccountSpecialityAssociation();
            //,PRM_End_Date_Dt__c,PRM_InActive_Ind__c,PRM_Status_Nm__c,PRM_Specialty_Id__r.Name,PRM_Specialty_Id__r.PRM_Role_Nm__c,PRM_Specialty_Id__r.PRM_Tier_Nm__c 
            asa.Name = acctSpecialityAssoc.Name;
            asa.IsInactive = acctSpecialityAssoc.PRM_InActive_Ind__c;
            //asa.Status = acctSpecialityAssoc.PRM_Status_Nm__c;
            asa.SpecialityName = acctSpecialityAssoc.PRM_Specialty_Id__r.Name;
            asa.SpecialityRole = (String.isEmpty(acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Role_Nm__c))?null: ((String) acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Role_Nm__c).replace('<br>', ',');
            asa.SpecialityTier = (String.isEmpty(acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Tier_Nm__c))?null: ((String) acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Tier_Nm__c).replace('<br>', ',');
            asa.SpecialityType = acctSpecialityAssoc.PRM_Specialty_Type__c;
            
            List<String> PRLabelList = new List<String>();
            if(!String.isEmpty(acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Role_Nm__c)){
                List<Schema.PicklistEntry> pickListValues = PRM_Specialty__c.PRM_Role_Nm__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry picklistval : pickListValues) {
                    if (acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Role_Nm__c.Contains(picklistval.getValue())) {
                        PRLabelList.add(picklistval.getLabel());
                    }
                }
            }
            
            asa.SpecialityRoleLabel =  String.join(PRLabelList, ';');           
            asas.add(asa);
        }
        return asas;
    }
    @TestVisible
    private static List<PRM_Account_Contact_Profiles_Model.AccoutBenefitAssociation> getAccoutBenefitAssociations( List<PRM_AccountBenefitAssociation__c> abarecords){
        //(SELECT PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Status_Nm__c FROM AccountBenefitAssociations__r)
        List<PRM_Account_Contact_Profiles_Model.AccoutBenefitAssociation> abas = new List<PRM_Account_Contact_Profiles_Model.AccoutBenefitAssociation>();
        for(PRM_AccountBenefitAssociation__c acctBenefitAssoc : abarecords){
            PRM_Account_Contact_Profiles_Model.AccoutBenefitAssociation aba = new PRM_Account_Contact_Profiles_Model.AccoutBenefitAssociation();
            aba.BenefitName = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.Name;
            aba.BenefitCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c;
            aba.BenefitType = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c;
            //PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Status_Nm__c
            aba.PartnerProgamName = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name;
            aba.PartnerProgamCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c;
            aba.Status = acctBenefitAssoc.PRM_Status_Nm__c;
            abas.add(aba);
        }
        return abas;
    } //varun
    
    /*@TestVisible
    private static List<PRM_Account_Contact_Profiles_Model.AccoutBenefitAssociation> getAccoutBenefitAssociations(Account acct){
        //(SELECT PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Status_Nm__c FROM AccountBenefitAssociations__r)
        List<PRM_Account_Contact_Profiles_Model.AccoutBenefitAssociation> abas = new List<PRM_Account_Contact_Profiles_Model.AccoutBenefitAssociation>();
        for(PRM_AccountBenefitAssociation__c acctBenefitAssoc : acct.AccountBenefitAssociations__r){
            PRM_Account_Contact_Profiles_Model.AccoutBenefitAssociation aba = new PRM_Account_Contact_Profiles_Model.AccoutBenefitAssociation();
            aba.BenefitName = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.Name;
            aba.BenefitCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c;
            aba.BenefitType = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c;
            //PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Status_Nm__c
            aba.PartnerProgamName = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name;
            aba.PartnerProgamCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c;
            aba.Status = acctBenefitAssoc.PRM_Status_Nm__c;
            abas.add(aba);
        }
        return abas;
    }*/
    private static List<PRM_Account_Contact_Profiles_Model.AccountChannelMembership> getAccountChannelMemberships(Account acct){
        List<PRM_Account_Contact_Profiles_Model.AccountChannelMembership> acms = new List<PRM_Account_Contact_Profiles_Model.AccountChannelMembership>();
        for(PRM_AccountChannelMembership__c channelMembership: acct.Channel_Memberships1__r ){
            PRM_Account_Contact_Profiles_Model.AccountChannelMembership acm = new PRM_Account_Contact_Profiles_Model.AccountChannelMembership();
            acm.PartnerProgramName = channelMembership.PRM_Channel_Program_Id__r.Name;
            acm.PartnerProgramCode = channelMembership.PRM_Channel_Program_Id__r.PRM_programCode__c;
            acm.PartnerTier = channelMembership.PRM_Channel_Program_Level_Id__r.Name;
            //if(ipaRefresh||Test.isRunningTest()){
                acm.PartnerTierLabel = channelMembership.PRM_Channel_Program_Level_Id__r.PRM_Partner_Tier_Name__c;
            //}    // IPA2.0 - TWC727-2861     // IPA Switch Removal    
            acm.PartnerRole = (String.isEmpty(channelMembership.PRM_Partner_Role__c))?null:((String) channelMembership.PRM_Partner_Role__c).replace('<br>',',');
            acm.Status = channelMembership.PRM_Status_Nm__c;
            acm.createdDate=channelMembership.createdDate;
            if(!String.isEmpty(channelMembership.PRM_Partner_Role__c)){
                List<Schema.PicklistEntry> pickListValues = PRM_AccountChannelMembership__c.PRM_Partner_Role__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry picklistval : pickListValues) {
                    if (picklistval.getValue() == channelMembership.PRM_Partner_Role__c) {
                        acm.PartnerRoleLabel = picklistval.getLabel();
                        break;
                    }
                }
            }
            
            acms.add(acm);
        }
        return acms;
    }
    
    public static PRM_Account_Contact_Profiles_Model.Profiles GetPersonAccount(String key,String value) {
        
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
        profiles.ContactAccount = new PRM_Account_Contact_Profiles_Model.ContactAccountWrapper();
        profiles.ContactAccount = getPersonAccountObj(buildCriteria(key,value,false));
        if(profiles.ContactAccount!=null){   
            profiles.ResponseTimeMS = responseTimeCalc();
            return profiles;
        }else{
            return generateError('No records found');
        }       
        
    }
    public static PRM_Account_Contact_Profiles_Model.Profiles getCMfDetails(String key,String value) {
        List<ER_CMFGroupAssociation__c> records;
        List<Contact> contactrecList;
        Map<String,List<ER_CMFGroupAssociation__c>> cmfDataMap = new Map<String,List<ER_CMFGroupAssociation__c>>();
        for(ER_CMFGroupAssociation__c associationRec : [SELECT id,ER_Customer_Master_File__r.Name,ER_Customer_Master_File__r.ER_CMF_Name__c,ER_Customer_Master_File_Group__r.Name,ER_Customer_Master_File_Group__r.ER_Active__c,ER_Customer_Master_File__r.ER_Central_Block__c,ER_Customer_Master_File__r.ER_SalesAreaOrderBlockCd__c,ER_Customer_Master_File_Group__r.ER_Description__c,ER_Customer_Master_File_Group__r.ER_Count_of_Contacts__c, ER_Customer_Master_File_Group__r.ER_Inactive_Contacts__c, ER_Customer_Master_File_Group__r.ER_Count_of_Customer_Master_Files__c, ER_Customer_Master_File_Group__r.ER_Inactive_Customer_Master_Files__c, ER_Customer_Master_File__r.ER_Account_Group__c,ER_Customer_Master_File__r.ER_CMF_Address__c, ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Code__c,ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Name__c,ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Code__c, ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Name__c, ER_Customer_Master_File__r.ER_Sales_Org_Code__c, ER_Customer_Master_File__r.ER_Sales_Org_Name__c FROM ER_CMFGroupAssociation__c WHERE ER_Customer_Master_File_Group__c IN (SELECT Er_Customer_Master_File_Group__c from ER_ContactGroupAssociation__c WHERE ER_Active__c = true AND (ER_Contact__r.Email =:key OR ER_Contact__r.Core_Enterprise_Id__c =:key))]){
            if(cmfDataMap.containsKey(associationRec.ER_Customer_Master_File_Group__r.Name)){
                List<ER_CMFGroupAssociation__c> idsOfCmfGroup = cmfDataMap.get(associationRec.ER_Customer_Master_File_Group__r.Name);
                idsOfCmfGroup.add(associationRec);
                cmfDataMap.put(associationRec.ER_Customer_Master_File_Group__r.Name,idsOfCmfGroup);
            }
            else{
                cmfDataMap.put(associationRec.ER_Customer_Master_File_Group__r.Name,new List<ER_CMFGroupAssociation__c>{associationRec});
            }
        }
        List<PRM_Account_Contact_Profiles_Model.cmfWrapper> cmfWrapperDataList = new List<PRM_Account_Contact_Profiles_Model.cmfWrapper>();
        PRM_Account_Contact_Profiles_Model.cmfWrapperNew returnWrapper = new PRM_Account_Contact_Profiles_Model.cmfWrapperNew();
        for(String GroupName : cmfDataMap.keySet()){
            PRM_Account_Contact_Profiles_Model.cmfWrapper cmfWrapperData = new PRM_Account_Contact_Profiles_Model.cmfWrapper();
            cmfWrapperData.GroupName = GroupName; 
            cmfWrapperData.Active = cmfDataMap.get(GroupName)[0].ER_Customer_Master_File_Group__r.ER_Active__c;
            cmfWrapperData.Description= cmfDataMap.get(GroupName)[0].ER_Customer_Master_File_Group__r.ER_Description__c;
            cmfWrapperData.ActiveCMFcount= String.valueof(cmfDataMap.get(GroupName)[0].ER_Customer_Master_File_Group__r.ER_Count_of_Customer_Master_Files__c);
            cmfWrapperData.InActiveCMFcount= String.valueof(cmfDataMap.get(GroupName)[0].ER_Customer_Master_File_Group__r.ER_Inactive_Customer_Master_Files__c);
            cmfWrapperData.ActiveContactCount= String.valueof(cmfDataMap.get(GroupName)[0].ER_Customer_Master_File_Group__r.ER_Count_of_Contacts__c);
            cmfWrapperData.InActiveContactCount= String.valueof(cmfDataMap.get(GroupName)[0].ER_Customer_Master_File_Group__r.ER_Inactive_Contacts__c);
            List<PRM_Account_Contact_Profiles_Model.cmfData> cmfdetails = new List<PRM_Account_Contact_Profiles_Model.cmfData> ();
            for(ER_CMFGroupAssociation__c rec :cmfDataMap.get(GroupName)){
                PRM_Account_Contact_Profiles_Model.cmfData cmf = new PRM_Account_Contact_Profiles_Model.cmfData();
                cmf.CMFID = rec.ER_Customer_Master_File__r.Name;
                cmf.name=  rec.ER_Customer_Master_File__r.ER_CMF_Name__c;
                cmf.DirectCustomerRoleName=rec.ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Name__c ;
                cmf.SalesOrgCode=rec.ER_Customer_Master_File__r.ER_Sales_Org_Code__c ;
                cmf.SalesOrgName=rec.ER_Customer_Master_File__r.ER_Sales_Org_Name__c ;
                cmf.SalesDistiChannelCode=rec.ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Code__c ;
                cmf.SalesDistiChannelName=rec.ER_Customer_Master_File__r.ER_Sales_Disti_Chnl_Name__c ;
                cmf.Address=rec.ER_Customer_Master_File__r.ER_CMF_Address__c ;
                cmf.AccountGroup=rec.ER_Customer_Master_File__r.ER_Account_Group__c ;
                cmf.DirectCustomerRoleCode=rec.ER_Customer_Master_File__r.ER_Direct_Customer_Relationship_Code__c ;
                cmf.CentralBlock=rec.ER_Customer_Master_File__r.ER_Central_Block__c;
                cmf.SalesAreaOrderBlockCd=rec.ER_Customer_Master_File__r.ER_SalesAreaOrderBlockCd__c;
                cmfdetails.add(cmf);
             }
            cmfWrapperData.CMFs=cmfdetails;
            cmfWrapperDataList.add(cmfWrapperData);
        }
        for(Contact contactRec : [SELECT id,name,FirstName,LastName,Core_Enterprise_Id__c,Email,Account.Core_IsODM__c, Account.Name,account.IsDeleted,Account.Core_Business_Party_Id__c,account.Core_Account_ID__c, account.Core_Deactivated__c,IsDeleted, Core_Deactivated__c  from Contact WHERE Email =:key OR Core_Enterprise_Id__c =:key LIMIT 1]){
            returnWrapper.FirstName=contactRec.FirstName;
            returnWrapper.LastName=contactRec.LastName;
            returnWrapper.EnterpriseId=contactRec.Core_Enterprise_Id__c;
            returnWrapper.Email=contactRec.Email;
            returnWrapper.AccountName=contactRec.Account.Name;
            returnWrapper.AccountID=contactRec.account.Core_Account_ID__c;
            returnWrapper.AccountStatus=contactRec.account.Core_Deactivated__c;
            returnWrapper.UCDID=contactRec.Account.Core_Business_Party_Id__c;//APi name is diffrent in devipa
            returnWrapper.AccountIsdeleted=contactRec.Account.IsDeleted;
            returnWrapper.Deactivated=contactRec.Core_Deactivated__c;
            returnWrapper.IsDeleted=contactRec.IsDeleted;
            returnWrapper.IsODMAccount=contactRec.Account.Core_IsODM__c;
            returnWrapper.CMFGroups=cmfWrapperDataList;
        }
         PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
         profiles.ContactGroupResults=returnWrapper;
         profiles.ResponseTimeMS = responseTimeCalc();
         return profiles;
    }

    
    
    private static String buildCriteria(String key,String value,boolean isRegReq)
    {
        Map<String,String> paramList;
        List<ChannelProgram> channelProg = new List<ChannelProgram>();
        List<Core_Entitlement__c> entitlementDetail = new List<Core_Entitlement__c>();
        List<String> status =  new List<String> {'New','Rejected'};
        string output = '';
        System.debug('key : '+key+' value: '+value+' isRegReq :'+isRegReq);
        if(isRegReq)
        {
            
            paramList = new Map<String,String>{'EMAILID' => 'PRM_Email_ID__c','ENTERPRISEID'=>'PRM_Enterprise_ID__c', /*'LOGINID'=>'PRM_Contact_Login_ID__c',*/ 'WECHATUNIONID'=>'PRM_Wechat_Union_Id__c','REQUESTID'=>'Id'}; 
                
                if(isProgBased != null && Inpvalue != null){
                    //commented for TWC722-325
                    //output = isProgBased ? ' PRM_Channel_Program__r.Name ='+'\''+Inpvalue+'\'' : ' Entitlement_Details__r.Name ='+'\''+Inpvalue+'\'';
                    //Added for TWC722-325
                    output = isProgBased ? ' PRM_Channel_Program__r.PRM_programCode__c ='+'\''+Inpvalue+'\'' : ' Entitlement_Details__r.Name ='+'\''+Inpvalue+'\'';
                    output=output+' AND '+ 'PRM_Status__c IN ('+'\'New'+'\','+'\'Rejected'+'\','+'\'Pending'+'\','+'\'Approved'+'\','+'\'PendingwithPartner'+'\')';
                }
        }
        else
        {
            
            paramList = new Map<String,String>{'EMAILID' => 'Email','ENTERPRISEID'=>'Core_Enterprise_Id__c',/*'LOGINID'=>'Core_Login_Id__c',*/'WECHATUNIONID'=>'PRM_Wechat_Union_Id__c','CONTACTID'=>'Id'};        
                
                }
        output = String.isBlank(output) ?  paramList.get(key) + '= '+'\''+value+'\'' : output + ' AND '+ paramList.get(key) + '= '+'\''+value+'\'';        
        return output;
    }
    
    private static PRM_Account_Contact_Profiles_Model.ContactAccountWrapper getPersonAccountObj(String param){
        PRM_Account_Contact_Profiles_Model.ContactAccountWrapper ContAcct = new PRM_Account_Contact_Profiles_Model.ContactAccountWrapper();
        //String query = 'SELECT id,AccountId,Account.Name,FirstName, LastName, Title,Name,Core_Local_First_Name__c,Core_Local_Last_Name__c,Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c,Core_Job_Function__c,Core_IPA_Email_Verification_Date__c, Core_Job_Function_Code__c,phone,MobilePhone,email,Core_Preferred_Communication__c,Core_Preferred_Language__c, Core_IPA_PartnerRole__c,Core_IPA_Contact_Segment__c,Core_Login_Id__c,Core_eRPM_Person_Id__c,Core_Enterprise_Id__c, MailingStreet,MailingCity,MailingState,MailingStateCode,MailingCountry,MailingCountryCode,MailingPostalCode,PRM_Wechat_Union_Id__c,Core_Login_Status__c,Core_IPA_Partner_Community__c,(SELECT PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c, PRM_Status_Nm__c FROM Contact_Subscription_Associations__r),(SELECT Contact__r.Email,Contact__r.Name, Business_Types__r.Name,Business_Types__r.Business_Type_Code__c,Status__c,Status_Reason__c FROM Contact_Business_Types__r),(SELECT Core_Entitlement_Id__r.Name,Core_Type__c,Core_Status__c,Core_Ops_Status__c,Core_Selected__c FROM Contact_Entitlements__r) FROM Contact WHERE ' +param+' LIMIT 1';
        //List<Contact> conts = Database.query(query);
        String query = '';       
        query = 'SELECT id,AccountId,Account.Name,FirstName, LastName, Title,Name,Core_Local_First_Name__c,Core_Local_Last_Name__c,Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c,Core_Profession__c, Core_Job_Function_Code__c,phone,MobilePhone,email,Core_Preferred_Communication__c,Core_Preferred_Language__c, Core_IPA_PartnerRole__c,Core_IPA_Contact_Segment__c,Core_eRPM_Person_Id__c,Core_Enterprise_Id__c, MailingStreet,MailingCity,MailingState,MailingStateCode,MailingCountry,MailingCountryCode,MailingPostalCode,PRM_Wechat_Union_Id__c,Core_Login_Status__c,Core_IPA_Partner_Community__c, External_User_State__c,External_User_State_Change_Date_Times__c,Account.Core_Geo__c,Account.Core_Sub_Geo__c,(SELECT PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c, PRM_Status_Nm__c FROM Contact_Subscription_Associations__r),(SELECT Contact__r.Email,Contact__r.Name, Business_Types__r.Name,Business_Types__r.Business_Type_Code__c,Status__c,Status_Reason__c FROM Contact_Business_Types__r),(SELECT Core_Entitlement_Id__r.Name,Core_Type__c,Core_Status__c,Core_Ops_Status__c,Core_Selected__c FROM Contact_Entitlements__r) FROM Contact WHERE ' +param+' ORDER BY CreatedDate LIMIT 1';
        
        List<Contact> conts = Database.query(query);
        /*List<Contact> conts = [SELECT id,AccountId,Account.Name,FirstName, LastName, Title,Name,Core_Local_First_Name__c,Core_Local_Last_Name__c,
Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c,Core_Job_Function__c,Core_IPA_Email_Verification_Date__c,
Core_Job_Function_Code__c,phone,MobilePhone,email,Core_Preferred_Communication__c,Core_Preferred_Language__c,
Core_IPA_PartnerRole__c,Core_IPA_Contact_Segment__c,Core_Login_Id__c,Core_eRPM_Person_Id__c,Core_Enterprise_Id__c,
MailingStreet,MailingCity,MailingState,MailingStateCode,MailingCountry,MailingCountryCode,MailingPostalCode,  
PRM_Wechat_Union_Id__c,Core_Login_Status__c,Core_IPA_Partner_Community__c,
(SELECT PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c, PRM_Status_Nm__c FROM Contact_Subscription_Associations__r WHERE PRM_Status_Nm__c='Active'),
(SELECT Core_Entitlement_Id__r.Name,Core_Type__c,Core_Status__c,Core_Ops_Status__c,Core_Selected__c FROM Contact_Entitlements__r)
FROM Contact WHERE id= :param OR Email= :param OR Core_Enterprise_Id__c= :param OR Core_Login_Id__c= :param OR PRM_Wechat_Union_Id__c= :param LIMIT 1];*/
        //OR Core_eRPM_Person_Id__c= :param
        if(conts.size()>0){
            String accId=conts[0].AccountId;
            String ConId=conts[0].Id;
            String ConEmail=conts[0].Email;
            Set<Id> systemAccIds = new Set<Id>();
            for(Core_Intel_System_Accounts__mdt sysAcc : [select 
                                                          id,
                                                          AccountId__c 
                                                          from 
                                                          Core_Intel_System_Accounts__mdt])
            {
                systemAccIds.add(sysAcc.AccountId__c);
            }
            String param1 = '';
            if(systemAccIds.contains(conts[0].AccountId)){
                param1 = 'where PRM_Signed_By_Email__c =: ConEmail'; // IPA Refresh 2.0 - TWC729-7874
            }           
            String queryVar ='SELECT name,Parent.Name,Core_Alternate_Language_Name__c,Core_Account_Type__c,AccountNumber,'+
                          'Core_IPA_Partner_Role__c,Core_Account_Legal_Name__c,Core_Account_Record_Type__c,Core_IPA_One_Partner_Id__c,Core_Prime_Account_Name__c,'+
                          'Core_Covered_Account__c,Core_CNDA_Number__c,Core_Sales_Groups__c,Core_Account_BU_Focus__c,'+
                          'Core_Account_Tier__c,Industry,Core_Alt_Address_1__c,Core_Alt_Address_2__c,Core_Alt_Language_City__c,'+
                          'Core_Alt_Language_State_Province__c,Core_Alt_Language_country__c,Core_Alt_Language_Postal_Code__c,'+
                          'Core_CIM_ID__c,Core_IPS_Active__c,Core_Business_ID__c,Core_Business_Partner_Id__c,Core_IPA_Badge_Tier__c,Core_Geo__c,Core_Sub_Geo__c,'+
                          'BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,BillingCountryCode,'+
                          'BillingPostalCode,ShippingStreet,ShippingCity,ShippingState,ShippingStateCode,ShippingCountry,'+
                          'ShippingCountryCode,ShippingPostalCode,'+'Core_Intel_Partner_Alliance_PartnerGroup__c,Core_User_Defined_Website__c,Core_User_Defined_Number_of_Employees__c,Core_User_Defined_Phone_Number__c,'+
                          'Core_Partner_Alliance_Program__c,Core_IPA_Partner_Segment__c, Core_English_Only_Name__c,'+
                          'Core_Deactivated__c,Core_Deactivation_Reason__c,Core_B2B_Entitlement__c,Core_B2B_ERPM_Account_Number__c,RecordType.Name,'+
                          'Core_Business_Party_Id__c,core_data_simplified_account_nm__c,core_data_simplified_local_language_nm__c,core_customer_aggregation_type__c,Unified_Hierarchy_View__c,core_data_country_nm__c,'+
                          'Owner.Name,'+ 'Core_Account_Owner_Email__c,'+      
                          '(SELECT PRM_Channel_Program_Id__r.Name,PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Status_Nm__c,CreatedDate,PRM_Channel_Program_Level_Id__r.PRM_Partner_Tier_Name__c FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c!=\'Inactive\'),'+
                          '(SELECT PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Status_Nm__c FROM AccountBenefitAssociations__r WHERE PRM_Status_Nm__c=\'Active\'),'+
                          '(SELECT PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_Relationship_Id__r.Name,PRM_Status_Nm__c,PRM_InActive_Ind__c FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false AND PRM_Contact_Id__c= :ConId),'+
                          '(SELECT Core_Account_Id__r.Name,Core_ERPM_Engagement_Id__r.Name,Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,Core_ERPM_Engagement_Id__r.Core_Technical_Tier_Code__c From Account_ERPM_Engagements__r),'+
                          '(SELECT Name,PRM_InActive_Ind__c,PRM_Specialty_Id__r.Name,PRM_Specialty_Id__r.PRM_Role_Nm__c,PRM_Specialty_Id__r.PRM_Tier_Nm__c,PRM_Specialty_Type__c FROM Account_Specialty_Associations__r WHERE PRM_InActive_Ind__c=false),'+
                          '(SELECT Name,PRM_Agreement_Sign_Dt__c,PRM_Signed_By_Email__c,PRM_Signed_By_Name__c,PRM_Partner_Agreement_Id__r.Name,PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name FROM AccountLegalAgreementAssociations__r '+ param1+'),'+
                          '(SELECT Name,Partner_Program__r.name,Effective_End_Date_Time__c,Inactive_Indicator__c FROM Account_Whitelisted_Domains__r),'+
                          '(SELECT  Account__r.Name, Business_Types__r.Name,Business_Types__r.Business_Type_Code__c ,Status__c,Effective_End_Date__c,Effective_Start_Date__c,Status_Reason__c FROM Account_Business_Types__r),'+
                          '(SELECT PRM_Distributor_Id__r.Name,PRM_Choice_Nm__c,PRM_Consent_Provided_By_Id__r.Name,PRM_Consent_Provided_Date_Dt__c,PRM_Start_Date_Dt__c,PRM_End_Date_Dt__c,PRM_Consent_Provided_Ind__c FROM Partner_Assist_Consent__r), '+
                          '(SELECT  Name, Core_Type__c,Core_Effective_Start_Date__c ,Core_Effective_End_Date__c FROM Core_Account_Id__r)'+
                          'FROM Account WHERE Id=: accId';
            List<Account> accounts = New List<Account>();
            accounts=Database.query(queryVar);
            list<PRM_AccountBenefitAssociation__c> opidbenefitrecords = new list<PRM_AccountBenefitAssociation__c>();
            if (!accounts.isEmpty() && accounts[0].Core_Account_Record_Type__c == 'Intel Account' && accounts[0].Core_IPA_One_Partner_Id__c!=null/* && (ipaRefresh||Test.isRunningTest())*/){
                opidbenefitrecords = [SELECT PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Status_Nm__c FROM PRM_AccountBenefitAssociation__c WHERE PRM_Account_Id__c =: accounts[0].Core_IPA_One_Partner_Id__c and PRM_Status_Nm__c='Active'];
            }            
            if(accounts.size()>0){
                
                //ContAcct.ContactAccount = new PRM_Account_Contact_Profiles_Model.ContactAccountWrapper();
                ContAcct.AccountInformation = getAccountInformation(accounts[0]);
                ContAcct.AccountInformation.AccountContactRelationships = getAccountContactRelationships(accounts[0]);
                ContAcct.AccountInformation.AccountEngagements = getAccountERPMEngagements(accounts[0]);
                //ContAcct.AccountInformation.AccoutBenefitAssociations = getAccoutBenefitAssociations(accounts[0]);
                ContAcct.AccountInformation.AccoutBenefitAssociations = (accounts[0].Core_Account_Record_Type__c == 'Intel Account' /*&& (ipaRefresh||Test.isRunningTest())*/)? (getAccoutBenefitAssociations(opidbenefitrecords)):(getAccoutBenefitAssociations(accounts[0].AccountBenefitAssociations__r));
                ContAcct.AccountInformation.AccountChannelMemberships = getAccountChannelMemberships(accounts[0]);  
                ContAcct.AccountInformation.ProfileResponses = getProfileResponseFromMembership(accounts[0].id); //(!ipaRefresh||Test.isRunningTest())?getProfileResponses(accounts[0].Id):getProfileResponseFromMembership(accounts[0].id); // IPA Switch Removal
                //ContAcct.AccountInformation.AccountSpecialityAssociations = getAccountSpecialityAssociations(accounts[0]);
                ContAcct.AccountInformation.AccountSpecialityAssociations = new List<PRM_Account_Contact_Profiles_Model.AccountSpecialityAssociation>(); // IPA2.0 - TWC727-2861 // IPA Switch Removal
                ContAcct.AccountInformation.AccountLegalAgreements = getAccountLegalAgreements(accounts[0]);
                ContAcct.AccountInformation.AccountBusinessTypes = getAccountBusinessType(accounts[0]);
                ContAcct.AccountInformation.WhitelistedDomains = getWhiteListedDomains(accounts[0]);
                ContAcct.AccountInformation.PartnerAssist = getPartnerAssist(accounts[0]);
                ContAcct.ContactBasicProfile = new PRM_Account_Contact_Profiles_Model.ContactBasicProfileDetailsWrapper();
                ContAcct.ContactBasicProfile.ContactBasicInformation = getContactBasicDetails(conts[0],accounts[0].Core_Account_Type__c); 
                ContAcct.ContactBasicProfile.ContactSubscriptions = getPersonSubscriptions(conts[0]);
                ContAcct.ContactBasicProfile.ContactBusinessTypes = getContactBusinessType(conts[0]);
                ContAcct.ContactBasicProfile.ContactEntitlements = getPersonEntitlements(conts[0]);
                ContAcct.RegReqConsolidated = getRegistrationRequestDetails(accounts[0],conts[0]);//new method for consolidated regrequestpayload
                //ContAcct.AccountInformation.ComplianceWatchLists = getAccountComplianceWatchLists(accounts[0]);  //Commenting as part of TWC729-8872
                return ContAcct;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }

    /*@NJ new method for consolidated regrequestpayload start*/
    private static PRM_Account_Contact_Profiles_Model.RegistrationRequestDetails getRegistrationRequestDetails( Account acc,Contact con){
        PRM_Account_Contact_Profiles_Model.RegistrationRequestDetails regReqPayload = new PRM_Account_Contact_Profiles_Model.RegistrationRequestDetails();
        regReqPayload.FirstName = con.FirstName;
        regReqPayload.LastName = con.LastName;
        regReqPayload.Email = con.Email;
        regReqPayload.PartnerRole = String.isEmpty(acc.Core_IPA_Partner_Role__c)?null:((String) acc.Core_IPA_Partner_Role__c).replace('<br>',',');
        regReqPayload.EnterpriseId = con.Core_Enterprise_Id__c;
        regReqPayload.AddressLine1 = acc.BillingStreet;
        regReqPayload.City = acc.BillingCity;
        regReqPayload.Country = acc.BillingCountry;
        regReqPayload.StateProvince = acc.BillingState;
        regReqPayload.ZipPostalCode = acc.BillingPostalCode;
        regReqPayload.AccountName = acc.Name;
        regReqPayload.AccountUrl = acc.Core_User_Defined_Website__c;
        regReqPayload.PreferredLanguage = con.Core_Preferred_Language__c;
        regReqPayload.Profession = con.Core_Profession__c;
        regReqPayload.AccountPhone = acc.Core_User_Defined_Phone_Number__c;
        regReqPayload.ContactCountry = con.MailingCountry;
        regReqPayload.LoginStatus = con.Core_Login_Status__c;
        regReqPayload.SalesforceId = acc.id;
        return regReqPayload;
        
    }

    /*@NJ new method for consolidated regrequestpayload end*/

    private static List<PRM_Account_Contact_Profiles_Model.PartnerAssist> getPartnerAssist(Account acct){
        List<PRM_Account_Contact_Profiles_Model.PartnerAssist> PartnerAssist = new List<PRM_Account_Contact_Profiles_Model.PartnerAssist>();
        for(PRM_Partner_Assist_Consent__c partnerConsent : acct.Partner_Assist_Consent__r) {
            PRM_Account_Contact_Profiles_Model.PartnerAssist pa = new PRM_Account_Contact_Profiles_Model.PartnerAssist();          
            pa.DistributorName = partnerConsent.PRM_Distributor_Id__r.Name;
            pa.choice = partnerConsent.PRM_Choice_Nm__c;
            pa.ConsentProvidedBy = partnerConsent.PRM_Consent_Provided_By_Id__r.Name;
            pa.ConsentProvidedDate = partnerConsent.PRM_Consent_Provided_Date_Dt__c;
            pa.StartDate = partnerConsent.PRM_Start_Date_Dt__c;
            pa.EndDate = partnerConsent.PRM_End_Date_Dt__c;
            pa.ConsentProvidedIndicator = partnerConsent.PRM_Consent_Provided_Ind__c;
            PartnerAssist.add(pa);
        }
        return PartnerAssist;
    }
    private static List<PRM_Account_Contact_Profiles_Model.WhiteListedDomain> getWhiteListedDomains(Account acct){
        List<PRM_Account_Contact_Profiles_Model.WhiteListedDomain> WhiteListedDomains = new List<PRM_Account_Contact_Profiles_Model.WhiteListedDomain>();
        for(Core_Account_Whitelisted_Domains__c whiteListedDomain : acct.Account_Whitelisted_Domains__r) {
            PRM_Account_Contact_Profiles_Model.WhiteListedDomain wDomain = new PRM_Account_Contact_Profiles_Model.WhiteListedDomain();
            wDomain.DomainName = whiteListedDomain.Name;
            wDomain.PartnerProgramName = whiteListedDomain.Partner_Program__r.name;
            wDomain.EndDate = whiteListedDomain.Effective_End_Date_Time__c;
            wDomain.IsInactive = whiteListedDomain.Inactive_Indicator__c;
            WhiteListedDomains.add(wDomain);
        }
        return WhiteListedDomains;
    }
    /*private static List<PRM_Account_Contact_Profiles_Model.ContactAccountWrapper> getPersonAccountsObj(String param){
List<PRM_Account_Contact_Profiles_Model.ContactAccountWrapper> ContAccounts = new List<PRM_Account_Contact_Profiles_Model.ContactAccountWrapper>();
//PRM_Account_Contact_Profiles_Model.ContactAccountWrapper ContAcct = new PRM_Account_Contact_Profiles_Model.ContactAccountWrapper();
List<Contact> conts = [SELECT id,AccountId,Account.Name,FirstName, LastName, Title,Name,Core_Local_First_Name__c,Core_Local_Last_Name__c,
Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c,Core_Job_Function__c,Core_IPA_Email_Verification_Date__c,
Core_Job_Function_Code__c,phone,MobilePhone,email,Core_Preferred_Communication__c,Core_Preferred_Language__c,
Core_IPA_Partner_Role__c,Core_IPA_Contact_Segment__c,Core_Login_Id__c,Core_eRPM_Person_Id__c,Core_Enterprise_Id__c,
MailingStreet,MailingCity,MailingState,MailingStateCode,MailingCountry,MailingCountryCode,MailingPostalCode,  
(SELECT PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c, PRM_Status_Nm__c FROM Contact_Subscription_Associations__r WHERE PRM_Status_Nm__c='Active'),
(SELECT Core_Entitlement_Id__r.Name,Core_Type__c,Core_Status__c,Core_Ops_Status__c,Core_Selected__c FROM Contact_Entitlements__r)
FROM Contact WHERE id= :param OR Email= :param OR Core_Enterprise_Id__c= :param OR Core_Login_Id__c= :param LIMIT 1];
//OR Core_eRPM_Person_Id__c= :param
if(conts.size()>0){
Set<Id> acctIds= new Set<Id>();
for(Contact cont : conts)
{
acctIds.add(cont.AccountId);
}
if(acctIds.size() == 0)
{ 
return null;
}
Map<Id,Account> accounts = new Map<Id,Account>([SELECT name,Parent.Name,Core_Alternate_Language_Name__c,Core_Account_Type__c,
Core_IPA_Partner_Role__c,Core_Account_Legal_Name__c,Core_Prime_Account_Name__c,
Core_Covered_Account__c,Core_CNDA_Number__c,Core_Sales_Groups__c,Core_Account_BU_Focus__c,
Core_Account_Tier__c,Industry,Core_Alt_Address_1__c,Core_Alt_Address_2__c,Core_Alt_Language_City__c,
Core_Alt_Language_State_Province__c,Core_Alt_Language_country__c,Core_Alt_Language_Postal_Code__c,
Core_CIM_ID__c,Core_IPS_Active__c,Core_Business_ID__c,Core_Business_Partner_Id__c,
BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,BillingCountryCode,
BillingPostalCode,ShippingStreet,ShippingCity,ShippingState,ShippingStateCode,ShippingCountry,
ShippingCountryCode,ShippingPostalCode,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_User_Defined_Website__c,Core_User_Defined_Number_of_Employees__c,

(SELECT PRM_Channel_Program_Id__r.Name,PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Status_Nm__c FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c!='Inactive'),
(SELECT PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Status_Nm__c FROM AccountBenefitAssociations__r WHERE PRM_Status_Nm__c='Active'),
(SELECT PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_Relationship_Id__r.Name,PRM_Status_Nm__c,PRM_InActive_Ind__c FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false AND PRM_Contact_Id__c= :conts[0].Id),
(SELECT Core_Account_Id__r.Name,Core_ERPM_Engagement_Id__r.Name,Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,Core_ERPM_Engagement_Id__r.Core_Technical_Tier_Code__c From Account_ERPM_Engagements__r)
FROM Account WHERE Id IN : acctIds]);   
if(accounts.size()>0){
for(Contact cont : conts)
{
if(accounts.containsKey(cont.AccountId))
{
PRM_Account_Contact_Profiles_Model.ContactAccountWrapper ContAcct = new PRM_Account_Contact_Profiles_Model.ContactAccountWrapper();
Account acct = accounts.get(cont.AccountId);
ContAcct.AccountInformation = getAccountInformation(acct);
ContAcct.AccountInformation.AccountContactRelationships = getAccountContactRelationships(acct);
ContAcct.AccountInformation.AccountEngagements = getAccountERPMEngagements(acct);
ContAcct.AccountInformation.AccoutBenefitAssociations = getAccoutBenefitAssociations(acct);
ContAcct.AccountInformation.AccountChannelMemberships = getAccountChannelMemberships(acct);  
ContAcct.AccountInformation.ProfileResponses = getProfileResponses(acct.Id);
ContAcct.ContactBasicProfile = new PRM_Account_Contact_Profiles_Model.ContactBasicProfileDetailsWrapper();
ContAcct.ContactBasicProfile.ContactBasicInformation = getContactBasicDetails(cont); 
ContAcct.ContactBasicProfile.ContactSubscriptions = getPersonSubscriptions(cont);
ContAcct.ContactBasicProfile.ContactEntitlements = getPersonEntitlements(cont);
ContAccounts.add(ContAcct);
}

}
return ContAccounts;
}else{
return null;
}
}else{
return null;
}
}*/
    
    private static PRM_Account_Contact_Profiles_Model.AccountInformationWrapper getAccountInformation(Account acct){     
        PRM_Account_Contact_Profiles_Model.AccountInformationWrapper accountInfo = new PRM_Account_Contact_Profiles_Model.AccountInformationWrapper();        
        accountInfo.AccountId = acct.Id;
        accountInfo.Name = acct.Name;
        accountInfo.BadgeTier = acct.Core_IPA_Badge_Tier__c;
        List<Schema.PicklistEntry> pickListValuesIPA = Account.Core_IPA_Badge_Tier__c.getDescribe().getPicklistValues();
        String tierLabel;
        for (Schema.PicklistEntry picklistval : pickListValuesIPA) {
            if (acct.Core_IPA_Badge_Tier__c == picklistval.getValue()) {
                tierLabel= picklistval.getLabel();
            }
        }
        
        //if(ipaRefresh||Test.isRunningTest()){
            accountInfo.BadgeTierLabel = tierLabel;
        //} // IPA2.0 - New attribute in payload // IPA2.0 - TWC727-2861 // IPA Switch Removal
        accountInfo.ParentAccount = acct.Parent.Name;
        accountInfo.AlternateLanguageName = acct.Core_Alternate_Language_Name__c;
        accountInfo.BizOrgType = acct.Core_Account_Type__c;
        accountInfo.PartnerRole = String.isEmpty(acct.Core_IPA_Partner_Role__c)?null:((String) acct.Core_IPA_Partner_Role__c).replace('<br>',',');
        accountInfo.CoveredAccount = acct.Core_Covered_Account__c;
        accountInfo.CNDANumber = acct.Core_CNDA_Number__c;
        accountInfo.SalesGroup = acct.Core_Sales_Groups__c;
        accountInfo.AccountBUFocus = acct.Core_Account_BU_Focus__c;
        accountInfo.AccountTier = acct.Core_Account_Tier__c;
        accountInfo.Industry = acct.Industry;
        accountInfo.CompanySize = acct.Core_User_Defined_Number_of_Employees__c;
        accountInfo.CompanyWebsite = acct.Core_User_Defined_Website__c;
        accountInfo.CompanyPhoneNumber = acct.Core_User_Defined_Phone_Number__c;
        accountInfo.AccountNumber = acct.AccountNumber;
        
        /*
accountInfo.AltLanguageAddress1 = acct.Core_Alt_Address_1__c;
accountInfo.AltLanguageAddress2 = acct.Core_Alt_Address_2__c;
accountInfo.AltLanguageCity = acct.Core_Alt_Language_City__c;
accountInfo.AltLanguageState = acct.Core_Alt_Language_State_Province__c;
accountInfo.AltLanguageCountry = acct.Core_Alt_Language_country__c;
accountInfo.AltLanguagePostalCode = acct.Core_Alt_Language_Postal_Code__c;
*/
        accountInfo.UNIFIEDID=acct.core_business_party_id__c ;// TWC729-6955 : CIM Prime EOL –  Get Profile API - CIM EOL Activities
        accountInfo.IPSActive = acct.Core_IPS_Active__c;
        accountInfo.BusinessPartnerId = acct.Core_Business_Partner_Id__c;
        accountInfo.IsIPA = acct.Core_Intel_Partner_Alliance_PartnerGroup__c;
        
        accountInfo.EnglishOnlyName = acct.Core_English_Only_Name__c;
        accountInfo.IsDeactivated = acct.Core_Deactivated__c;
        accountInfo.DeactivationReason = acct.Core_Deactivation_Reason__c;
        accountInfo.B2BEntitlement = acct.Core_B2B_Entitlement__c;
        accountInfo.PartnerProgram = acct.Core_Partner_Alliance_Program__c;
        //accountInfo.PartnerSegment = acct.Core_IPA_Partner_Segment__c;
        accountInfo.PartnerSegment = null; //(!ipaRefresh||Test.isRunningTest())?acct.Core_IPA_Partner_Segment__c:null; // IPA2.0 - TWC727-2861
       //accountInfo.PartnerSpeciality = acct.Core_IPA_Partner_Speciality__c;
        accountInfo.RecordTypeName = acct.RecordType.Name;
        
        List<String> PRLabelList = new List<String>();
        if(!String.isEmpty(acct.Core_IPA_Partner_Role__c)){
            List<String> partnerRoles = acct.Core_IPA_Partner_Role__c.split(';');
            List<Schema.PicklistEntry> pickListValues = Account.Core_IPA_Partner_Role__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry picklistval : pickListValues) {
                if (partnerRoles.Contains(picklistval.getValue())) {
                    PRLabelList.add(picklistval.getLabel());
                }
            }
        } 
       /* List<String> AcctSpecialityLabelList = new List<String>();
        if(!String.isEmpty(acct.Core_IPA_Partner_Speciality__c)){
            List<Schema.PicklistEntry> pickListValues = Account.Core_IPA_Partner_Speciality__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry picklistval : pickListValues) {
                if (acct.Core_IPA_Partner_Speciality__c.Contains(picklistval.getValue())) {
                    AcctSpecialityLabelList.add(picklistval.getLabel());
                }
            }
        } */
                
        accountInfo.PartnerRoleLabel = String.join(PRLabelList, ';');
       // accountInfo.PartnerSpecialityLabel = String.join(AcctSpecialityLabelList, ';');
        accountInfo.ProfileResponses = getProfileResponseFromMembership(acct.id); //(!ipaRefresh||Test.isRunningTest())?getProfileResponses(acct.Id):getProfileResponseFromMembership(acct.id);
        /*accountInfo.PartnerSegment = acct.Core_IPA_Partner_Segment__c;
accountInfo.PartnerSpeciality = acct.Core_IPA_Partner_Speciality__c;
accountInfo.PartnerApplication = acct.Core_IPA_Partner_Prog_Application__c;*/
        
        accountInfo.Address = new PRM_Account_Contact_Profiles_Model.AccountAddress();
        accountInfo.Address.PrimaryAddress = getAccountPrimaryAddress(acct); 
        accountInfo.Address.SecondaryAddress = getAccountSecondaryAddress(acct);
        
        //UCD changes
        accountInfo.UnifiedId=acct.Core_Business_Party_Id__c;
        accountInfo.SimplifiedAccountName=acct.core_data_simplified_account_nm__c;
        accountInfo.SimplifiedLocalLanguageName=acct.core_data_simplified_local_language_nm__c;
        accountInfo.CustomerAggregationType=acct.core_customer_aggregation_type__c;
        accountInfo.UnifiedHierarchy=acct.Unified_Hierarchy_View__c;
        accountInfo.UnifiedCountryName=acct.core_data_country_nm__c;
        accountInfo.UnifiedCountryCode=null;
            //ContAcct.ContactAccount = new ContactAccountWrapper();
        //ContAcct.ContactAccount.AccountInformation = accountInfo;
        accountInfo.OwnerName = acct.Owner.Name; //TWC729-9198
        accountInfo.OwnerEmail = acct.Core_Account_Owner_Email__c;//TWC729-9198
        return accountInfo;
    }
    private Static PRM_Account_Contact_Profiles_Model.Address getAccountPrimaryAddress(Account acct){
        PRM_Account_Contact_Profiles_Model.Address primaryAddress = new PRM_Account_Contact_Profiles_Model.Address();
        boolean isAddressEmpty = false;
        isAddressEmpty = (String.isEmpty(acct.BillingStreet) && String.isEmpty(acct.Billingcity) 
                          && String.isEmpty(acct.BillingState) && String.isEmpty(acct.BillingCountry) 
                          && String.isEmpty(acct.BillingPostalCode) ) ? true: false;
        if(!isAddressEmpty){
            primaryAddress.Street = acct.BillingStreet;
            primaryAddress.City = acct.Billingcity;
            primaryAddress.State = acct.BillingState;
            primaryAddress.StateCode = acct.BillingStateCode;
            primaryAddress.Country = acct.BillingCountry;
            primaryAddress.CountryCode = acct.BillingCountryCode;
            if(!String.isEmpty(acct.BillingCountry)){ 
                primaryAddress.CountryCodeShort =  getCountryCodeMapping(acct.BillingCountry);
            }
            primaryAddress.PostalCode = acct.BillingPostalCode;
            primaryAddress.Geo = acct.Core_Geo__c;
            primaryAddress.SubGeo = acct.Core_Sub_Geo__c;   
            return primaryAddress;
        }else{
            return null;
        }
    }
    private Static PRM_Account_Contact_Profiles_Model.Address getAccountSecondaryAddress(Account acct){       
        boolean isAddressEmpty = false;
        PRM_Account_Contact_Profiles_Model.Address secondaryAddress = new PRM_Account_Contact_Profiles_Model.Address();
        isAddressEmpty = (String.isEmpty(acct.ShippingStreet) && String.isEmpty(acct.Shippingcity) && String.isEmpty(acct.ShippingState) && String.isEmpty(acct.ShippingCountry) && String.isEmpty(acct.ShippingPostalCode) ) ? true: false;
        if(!isAddressEmpty){
            secondaryAddress.Street = acct.ShippingStreet;
            secondaryAddress.City = acct.Shippingcity;
            secondaryAddress.State = acct.ShippingState;
            secondaryAddress.StateCode = acct.ShippingStateCode;
            secondaryAddress.Country = acct.ShippingCountry;
            secondaryAddress.CountryCode = acct.ShippingCountryCode;
            if(!String.isEmpty(acct.ShippingCountry)){ 
                secondaryAddress.CountryCodeShort =  getCountryCodeMapping(acct.ShippingCountry);
            }
            secondaryAddress.PostalCode = acct.ShippingPostalCode;
            secondaryAddress.Geo = acct.Core_Geo__c;
            secondaryAddress.SubGeo = acct.Core_Sub_Geo__c;
            return secondaryAddress;
        }else{
            return null; 
        }
    }
    private static List<PRM_Account_Contact_Profiles_Model.AccountContactRelationship> getAccountContactRelationships(Account acct){ 
        List<PRM_Account_Contact_Profiles_Model.AccountContactRelationship> acrs = new List<PRM_Account_Contact_Profiles_Model.AccountContactRelationship>();
        for(PRM_Account_Contact_Relationship__c acr: acct.Account_Contact_Relationships__r){
            PRM_Account_Contact_Profiles_Model.AccountContactRelationship accContRel = new PRM_Account_Contact_Profiles_Model.AccountContactRelationship();
            accContRel.accountName=acr.PRM_Account_Id__r.Name;
            //accContRel.partnerRole= String.isEmpty(acr.PRM_Partner_Role__c)?null:((String) acr.PRM_Partner_Role__c).replace('<br>', ',');
            String PartnerRoles= String.isEmpty(acr.PRM_Partner_Role__c)?null: ((String) acr.PRM_Partner_Role__c).replace('<br>',';');
            if(PartnerRoles!=null && (PartnerRoles.length()-PartnerRoles.lastIndexOf(';'))==1){
                PartnerRoles = PartnerRoles.left(PartnerRoles.lastIndexOf(';'));
            }
            accContRel.partnerRole = PartnerRoles;
            accContRel.relationship = acr.PRM_Relationship_Id__r.Name;
            accContRel.inactiveIndicator = acr.PRM_InActive_Ind__c;  
            accContRel.Status = acr.PRM_Status_Nm__c;
            
            if(!String.isEmpty(acr.PRM_Partner_Role__c)){
                List<Schema.PicklistEntry> pickListValues = Contact.Core_IPA_PartnerRole__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry picklistval : pickListValues) {
                    if (picklistval.getValue() == acr.PRM_Partner_Role__c) {
                        accContRel.PartnerRoleLabel = picklistval.getLabel();
                        break;
                    }
                }
            }
            
            acrs.add(accContRel);
        }
        return acrs;      
    }
    private static List<PRM_Account_Contact_Profiles_Model.AccountERPMEngagement> getAccountERPMEngagements(Account acct){
        // (Select Core_Account_Id__r.Name,Core_ERPM_Engagement_Id__r.Name,Core_ERPM_Engagement_Id__r.Core_Technical_Tier_Code__c From Account_ERPM_Engagements__r)
        //system.debug('Engagements===>'+acct.Account_ERPM_Engagements__r);
        List<PRM_Account_Contact_Profiles_Model.AccountERPMEngagement> aes = new List<PRM_Account_Contact_Profiles_Model.AccountERPMEngagement>();
        for(Core_Account_ERPM_Engagement__c ae: acct.Account_ERPM_Engagements__r){
            PRM_Account_Contact_Profiles_Model.AccountERPMEngagement accEngagement = new PRM_Account_Contact_Profiles_Model.AccountERPMEngagement();
            accEngagement.AccountName = ae.Core_Account_Id__r.Name;
            accEngagement.EngagementName = ae.Core_ERPM_Engagement_Id__r.Name;
            accEngagement.EngagementCode = ae.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c;
            accEngagement.Tier = ae.Core_ERPM_Engagement_Id__r.Core_Technical_Tier_Code__c; 
            aes.add(accEngagement);
        }
        return aes;      
    }
    @testvisible
    private static List<PRM_Account_Contact_Profiles_Model.ProfileResponse> getProfileResponses(Id recordId){
        
        String channelProg = 'Intel Partner Alliance';
        String objectName = 'Account';
        Map<Id,PRM_Profile_Questions__c> QuestionIdMap = new Map<Id,PRM_Profile_Questions__c>();       
        //Map<Id,List<String>> mapQuesToResp = new Map<Id,List<String>>();
        Map<Id,List<PRM_Account_Contact_Profiles_Model.Response>> mapQuesToResp = new  Map<Id,List<PRM_Account_Contact_Profiles_Model.Response>>();
        List<String> channelProgramNames = new List<String>();
        Set<Id> channelProgId = new Set<Id>();  
        
        if(channelProg != null){
            if(channelProg.contains(',')){
                channelProgramNames = channelProg.split(',');
            }else{
                channelProgramNames.add(channelProg);
            }
        }
        for(ChannelProgram cp :[select id from channelProgram where name in : channelProgramNames]){
            channelProgId.add(cp.id);
        }
        if(!channelProgId.isEmpty()){
            QuestionIdMap = new Map<Id,PRM_Profile_Questions__c>([SELECT Id,PRM_Question_Display_Txt__c, PRM_Question_Cd__c  FROM PRM_Profile_Questions__c WHERE PRM_Question_Display_Txt__c!=null AND PRM_Channel_Program_Id__c in : channelProgId order by PRM_Display_Order_Nbr__c ASC]);
        }
        //system.debug('QuestionIdMap ==>'+QuestionIdMap);
        //system.debug('AccountID ==>'+recordId);
        if(!QuestionIdMap.isEmpty() && recordId != null){ 
            for(PRM_Profile_Responses__c objResp : [SELECT PRM_Profile_Questions_Id__c,PRM_Response_Txt__c,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c FROM PRM_Profile_Responses__c WHERE PRM_InActive_Ind__c=false AND PRM_Account_Id__c =:recordId AND PRM_Profile_Questions_Id__c in :QuestionIdMap.keySet()] ){
                if(mapQuesToResp.containsKey(objResp.PRM_Profile_Questions_Id__c)) {   
                    PRM_Account_Contact_Profiles_Model.Response resp = new PRM_Account_Contact_Profiles_Model.Response();
                    resp.ResponseText=objResp.PRM_Response_Txt__c;
                    resp.ResponseCode=objResp.PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c;
                    mapQuesToResp.get(objResp.PRM_Profile_Questions_Id__c).add(resp);
                }else {
                    List<PRM_Account_Contact_Profiles_Model.Response> resps = new List<PRM_Account_Contact_Profiles_Model.Response>();
                    PRM_Account_Contact_Profiles_Model.Response resp = new PRM_Account_Contact_Profiles_Model.Response();
                    resp.ResponseText=objResp.PRM_Response_Txt__c;
                    resp.ResponseCode=objResp.PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c;
                    resps.add(resp);
                    mapQuesToResp.put(objResp.PRM_Profile_Questions_Id__c, resps);
                }
            }
        }
        List<PRM_Account_Contact_Profiles_Model.ProfileResponse> ProfileResponses = new List<PRM_Account_Contact_Profiles_Model.ProfileResponse>();        
        for(Id questionId: QuestionIdMap.keySet() ){
            PRM_Account_Contact_Profiles_Model.ProfileResponse resp = new PRM_Account_Contact_Profiles_Model.ProfileResponse();
            resp.QuestionText = QuestionIdMap.get(questionId).PRM_Question_Display_Txt__c;
            resp.QuestionCode = QuestionIdMap.get(questionId).PRM_Question_Cd__c;
            resp.Responses = new List<PRM_Account_Contact_Profiles_Model.Response>();
            if(mapQuesToResp.containsKey(questionId)){
                resp.Responses = mapQuesToResp.get(questionId);
            }
            if(resp.Responses.size() > 0) {
                ProfileResponses.add(resp); 
            }            
        }
        //profileRespsWrapper.ProfileResponses = responses;
        return ProfileResponses;
    }
    

   
    
    public static List<PRM_Account_Contact_Profiles_Model.ProfileResponse> getProfileResponseFromMembership(Id acct) {
        system.debug('Inside membership get profile');
        Map<string,Core_CustomMetadata_Object__c> qstnCodeRecMap = new Map<String,Core_CustomMetadata_Object__c>();
        Set<String> mdtAPISet = new Set<String>();
        //collect all required metadata for Get Profile API
    	List<Core_CustomMetadata_Object__c> selectedFields = [
        SELECT Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_6__c, Field_7__c
        FROM Core_CustomMetadata_Object__c
        WHERE Field_7__c = 'TRUE' and Metadata_Name__c='PRM_IPAMembership_Mapping__mdt'
    ];
       
         //Build key - Unique key - APIName|Answer
        for (Core_CustomMetadata_Object__c record : selectedFields) {
            String key = record.Field_6__c + '|' + record.Field_3__c;
            qstnCodeRecMap.put(key, record);
          
        }
        //Get Membership record
        List<PRM_IPAMembership_Attributes__c> membershipRecords = new List<PRM_IPAMembership_Attributes__c>();
        Map<String, PRM_IPAMembership_Attributes__c> attributesMap = new Map<String, PRM_IPAMembership_Attributes__c>();
        Account acc = [select id,Core_IPA_One_Partner_Id__c from Account where id=:acct limit 1]; 
        String accOPID = acc.Core_IPA_One_Partner_Id__c;
        membershipRecords = [
            SELECT PRM_Points_Opt_in_Ind__c, PRM_Points_Not_Eligible_Ind__c,PRM_Points_Opt_in_Dt__c,PRM_Points_Not_Eligible_Dt__c, PRM_Point_Status_Txt__c,PRM_Point_Status_Reason_Txt__c, PRM_Point_Status_Dt__c
            FROM PRM_IPAMembership_Attributes__c
            //WHERE PRM_Account_Id__c =:acct
            WHERE PRM_Account_Id__c =:accOPID AND PRM_Inactive_ind__c = false
        ];
        
        system.debug('membershipRecords---'+membershipRecords);
        List<PRM_Account_Contact_Profiles_Model.ProfileResponse> profileResponses = new List<PRM_Account_Contact_Profiles_Model.ProfileResponse>();
        if (membershipRecords.size()>0) {
            PRM_IPAMembership_Attributes__c record = membershipRecords[0];
            
            for (String key : qstnCodeRecMap.keySet()) {
                Core_CustomMetadata_Object__c metadata = qstnCodeRecMap.get(key);
                system.debug('response--1436--'+metadata.Field_6__c);
                PRM_Account_Contact_Profiles_Model.ProfileResponse response = new PRM_Account_Contact_Profiles_Model.ProfileResponse();
                response.QuestionText = metadata.Field_1__c;
                response.QuestionCode = metadata.Field_2__c; 
                response.Responses = new List<PRM_Account_Contact_Profiles_Model.Response>();
    			system.debug('response--1441--'+response);
                // Create response object
                PRM_Account_Contact_Profiles_Model.Response resp = new PRM_Account_Contact_Profiles_Model.Response();
                String answerVal='';
                String recordVal='';
                if(record.get(metadata.Field_6__c)!=null){
                    system.debug('1447---'+metadata.Field_6__c);
                	system.debug('1448---'+record.get(metadata.Field_6__c));
                     recordVal = string.valueOf(record.get(metadata.Field_6__c)).toUpperCase();
                }
               
                if(metadata.Field_3__c!=null){
                   answerVal = metadata.Field_3__c.toUpperCase();
                    system.debug('answerVal----'+answerVal);
                }
                //metadata gives values two times for boolean - TRUE/FALSE in a loop
                if((answerVal=='TRUE' || answerVal=='FALSE' || answerVal=='Eligible' || answerVal=='Not Eligible' || answerVal=='Active')&& (recordVal!=answerVal)){
                    system.debug('Inside if--');
                    continue;
                }else{
                    system.debug('Inside else--');
                    if(string.valueOf(record.get(metadata.Field_6__c))!=null && string.valueOf(record.get(metadata.Field_6__c)).contains('00:00:00')){
                        resp.ResponseText=string.valueOf(record.get(metadata.Field_6__c)).removeEnd(' 00:00:00');
                    }else{
                    	resp.ResponseText =string.valueOf(record.get(metadata.Field_6__c));
                    }
                	resp.ResponseCode = null;
                	response.Responses.add(resp);
                }
                // Add to profile responses list
            	profileResponses.add(response);
            	
                System.debug('ResponseText: ' + resp.ResponseText);
                System.debug('ResponseCode: ' + resp.ResponseCode);
                System.debug('QuestionText: ' + response.QuestionText);
                System.debug('QuestionCode: ' + response.QuestionCode);
        }
            
        }
        system.debug('profileResponses---'+profileResponses);
        return profileResponses;
    }

    
    public static PRM_Account_Contact_Profiles_Model.Profiles GetPersonBasicProfile(String key, String param){
        system.debug('<===== GetPersonBasicProfile ====>');
        //String query = 'SELECT id,AccountId,Account.Name,Account.Core_Account_Type__c,FirstName, LastName, Title,Name,Core_Local_First_Name__c,Core_Local_Last_Name__c, Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c,Core_Job_Function__c,Core_IPA_Email_Verification_Date__c, Core_Job_Function_Code__c,phone,MobilePhone,email,Core_Preferred_Communication__c,Core_Preferred_Language__c, Core_IPA_PartnerRole__c,Core_IPA_Contact_Segment__c,Core_Login_Status__c,Core_Login_Id__c,Core_eRPM_Person_Id__c,Core_Enterprise_Id__c, MailingStreet,MailingCity,MailingState,MailingStateCode,MailingCountry,MailingCountryCode,MailingPostalCode,PRM_Wechat_Union_Id__c,Core_IPA_Partner_Community__c,(SELECT PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c, PRM_Status_Nm__c FROM Contact_Subscription_Associations__r ),(SELECT Core_Entitlement_Id__r.Name,Core_Type__c,Core_Status__c,Core_Ops_Status__c,Core_Selected__c FROM Contact_Entitlements__r) FROM Contact WHERE '+buildCriteria(key,param,false)+' LIMIT 1';
        String query = '';  
        
        query = 'SELECT id,AccountId,Account.Name,Account.Core_Account_Type__c,FirstName, LastName, Title,Name,Core_Local_First_Name__c,Core_Local_Last_Name__c, Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c,Core_Profession__c, Core_Job_Function_Code__c,phone,MobilePhone,email,Core_Preferred_Communication__c,Core_Preferred_Language__c, Core_IPA_PartnerRole__c,Core_IPA_Contact_Segment__c,Core_Login_Status__c,Core_eRPM_Person_Id__c,Core_Enterprise_Id__c, MailingStreet,MailingCity,MailingState,MailingStateCode,MailingCountry,MailingCountryCode,MailingPostalCode,PRM_Wechat_Union_Id__c,Core_IPA_Partner_Community__c,External_User_State__c,External_User_State_Change_Date_Times__c,Account.Core_Geo__c,Account.Core_Sub_Geo__c,(SELECT PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c, PRM_Status_Nm__c FROM Contact_Subscription_Associations__r ),(SELECT Core_Entitlement_Id__r.Name,Core_Type__c,Core_Status__c,Core_Ops_Status__c,Core_Selected__c FROM Contact_Entitlements__r) FROM Contact WHERE '+buildCriteria(key,param,false)+' ORDER BY CreatedDate LIMIT 1';
        
        List<Contact> conts = Database.query(query);
        /*List<Contact> conts = [SELECT id,AccountId,Account.Name,Account.Core_Account_Type__c,FirstName, LastName, Title,Name,Core_Local_First_Name__c,Core_Local_Last_Name__c,
Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c,Core_Job_Function__c,Core_IPA_Email_Verification_Date__c,
Core_Job_Function_Code__c,phone,MobilePhone,email,Core_Preferred_Communication__c,Core_Preferred_Language__c,
Core_IPA_PartnerRole__c,Core_IPA_Contact_Segment__c,Core_Login_Status__c,Core_Login_Id__c,Core_eRPM_Person_Id__c,Core_Enterprise_Id__c,
MailingStreet,MailingCity,MailingState,MailingStateCode,MailingCountry,MailingCountryCode,MailingPostalCode,
PRM_Wechat_Union_Id__c,Core_IPA_Partner_Community__c,
(SELECT PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c, PRM_Status_Nm__c FROM Contact_Subscription_Associations__r WHERE PRM_Status_Nm__c='Active'),
(SELECT Core_Entitlement_Id__r.Name,Core_Type__c,Core_Status__c,Core_Ops_Status__c,Core_Selected__c FROM Contact_Entitlements__r)
FROM Contact WHERE id= :param OR Email= :param OR Core_Enterprise_Id__c= :param OR Core_Login_Id__c= :param OR PRM_Wechat_Union_Id__c=:param LIMIT 1];*/
        //   OR Core_eRPM_Person_Id__c= :param 
        //  (SELECT PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_Relationship_Id__r.Name,PRM_InActive_Ind__c FROM Account_Contact_Relationships__r), 
        
        if(conts.size()>0){  
            System.debug('inside conts if');
            PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
            profiles.ContactBasicProfile = new PRM_Account_Contact_Profiles_Model.ContactBasicProfileDetailsWrapper();
            profiles.ContactBasicProfile.ContactBasicInformation = getContactBasicDetails(conts[0],conts[0].Account.Core_Account_Type__c);            
            profiles.ContactBasicProfile.ContactEntitlements = getPersonEntitlements(conts[0]);  
            profiles.ContactBasicProfile.ContactBusinessTypes = getContactBusinessType(conts[0]);
            profiles.ContactBasicProfile.ContactSubscriptions = getPersonSubscriptions(conts[0]);
            //return JSON.serialize(profiles); 
            profiles.ResponseTimeMS = responseTimeCalc();
            return profiles;     
        }else{
            return generateError('No records found');
        }        
    }    
    
    @TestVisible
    private static List<PRM_Account_Contact_Profiles_Model.ContactEntitlement> getPersonEntitlements(Contact cont){
        
        List<PRM_Account_Contact_Profiles_Model.ContactEntitlement> ContactEntitlements = new List<PRM_Account_Contact_Profiles_Model.ContactEntitlement>();
        for(Core_Contact_Entitlement__c ce: cont.Contact_Entitlements__r){
            PRM_Account_Contact_Profiles_Model.ContactEntitlement ContEntitlement = new PRM_Account_Contact_Profiles_Model.ContactEntitlement();
            ContEntitlement.Name = ce.Core_Entitlement_Id__r.Name;
            ContEntitlement.Type = ce.Core_Type__c;
            ContEntitlement.Status = ce.Core_Status__c;
            ContEntitlement.IsSelected = ce.Core_Selected__c;
            ContactEntitlements.add(ContEntitlement);
        }    
        return ContactEntitlements;
    }
    
   
    private static List<PRM_Account_Contact_Profiles_Model.ContactSubscription> getPersonSubscriptions(Contact cont){
        system.debug(cont);
        List<PRM_Account_Contact_Profiles_Model.ContactSubscription> subscriptions = new List<PRM_Account_Contact_Profiles_Model.ContactSubscription>();
        for(PRM_ContactSubscriptionAssociation__c pcsa: cont.Contact_Subscription_Associations__r){
            PRM_Account_Contact_Profiles_Model.ContactSubscription cs = new PRM_Account_Contact_Profiles_Model.ContactSubscription();
            cs.Name = pcsa.PRM_Partner_Subscription_Id__r.Name;
            cs.Status = pcsa.PRM_Status_Nm__c;
            cs.Code = pcsa.PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c;
            subscriptions.add(cs);
        }
        return subscriptions;
    }    
    private static PRM_Account_Contact_Profiles_Model.ContactBasicInformationWrapper getContactBasicDetails(Contact cont, String acctBizOrgTypes){
        System.debug('getContactBasicDetails');
        PRM_Account_Contact_Profiles_Model.ContactBasicInformationWrapper ContactDetails = new PRM_Account_Contact_Profiles_Model.ContactBasicInformationWrapper();
        ContactDetails.ContactId = cont.Id;
        ContactDetails.AccountId = cont.AccountId;
        ContactDetails.AccountName = cont.Account.Name;
        ContactDetails.Title = cont.Title;
        ContactDetails.FullName = cont.Name;
        ContactDetails.LocalFirstName = cont.Core_Local_First_Name__c;
        ContactDetails.LocalLastName = cont.Core_Local_Last_Name__c;
        ContactDetails.EnglishFirstName = cont.Core_English_Only_First_Name__c;
        ContactDetails.EnglishLastName = cont.Core_English_Only_Last_Name__c;
        ContactDetails.FirstName = cont.FirstName;
        ContactDetails.LastName = cont.LastName;
        //ContactDetails.JobFunction = cont.Core_Job_Function__c;
        //ContactDetails.JobFunctionCode = cont.Core_Job_Function_Code__c;
        ContactDetails.Profession = cont.Core_Profession__c;
        ContactDetails.Phone = cont.phone;
        ContactDetails.Mobile = cont.MobilePhone;
        ContactDetails.Email = cont.email;
        ContactDetails.PreferredCommunication = cont.Core_Preferred_Communication__c;
        ContactDetails.PreferredLanguage = cont.Core_Preferred_Language__c;
        ContactDetails.PartnerRole = (String.isEmpty(cont.Core_IPA_PartnerRole__c))?null:((String) cont.Core_IPA_PartnerRole__c).replace('<br>',',');
        //ContactDetails.Segment = cont.Core_IPA_Contact_Segment__c;
        ContactDetails.Segment =null;// (!ipaRefresh||Test.isRunningTest())?cont.Core_IPA_Contact_Segment__c:null; // IPA2.0 - TWC727-2861
        ContactDetails.eRPMPersonId = cont.Core_eRPM_Person_Id__c;
        ContactDetails.EnterpriseId = cont.Core_Enterprise_Id__c;
        ContactDetails.MailingAddress = getPersonMailingAddress(cont);
        ContactDetails.LoginStatus = cont.Core_Login_Status__c;
        //ContactDetails.Communities = cont.Core_IPA_Partner_Community__c;
        ContactDetails.Communities =null; // (!ipaRefresh||Test.isRunningTest())?cont.Core_IPA_Partner_Community__c:null; // IPA2.0 - TWC727-2861
        
    //For Guest redemption
       ContactDetails.ExternalUserState=cont.External_User_State__c;
       ContactDetails.ExternalUserStateDtm= cont.External_User_State_Change_Date_Times__c;

        System.debug('getContactBasicDetails 2');     
        //This BizOrgType attribute is used by AEM forms to identify the BizOrg Type of teh contact in Overlap scenarios
        ContactDetails.BizOrgType = String.isEmpty(cont.Core_IPA_PartnerRole__c)?null:getBizOrgTypeForPartnerRole(cont.Core_IPA_PartnerRole__c, acctBizOrgTypes);
        ContactDetails.WeChatUnionId = cont.PRM_Wechat_Union_Id__c != null ? EncryptDecryptHelper.EncryptData(cont.PRM_Wechat_Union_Id__c) : '';
        
        if(!String.isEmpty(cont.Core_IPA_PartnerRole__c)){
            List<Schema.PicklistEntry> pickListValues = Contact.Core_IPA_PartnerRole__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry picklistval : pickListValues) {
                if (picklistval.getValue() == cont.Core_IPA_PartnerRole__c) {
                    ContactDetails.PartnerRoleLabel = picklistval.getLabel();
                    break;
                }
            }
        } 
        
        
        //-----------------------------We chat-----------------------------
        /*
ContactDetails.WechatOpenId = cont.PRM_Wechat_Open_Id__c;
ContactDetails.WechatUnionId = cont.PRM_Wechat_Union_Id__c;
ContactDetails.RegistrationSource = cont.PRM_Registration_Source_txt__c;
*/
        //-----------------------------We chat-----------------------------
        System.debug('getContactBasicDetails 3'+ContactDetails);
        return ContactDetails;
    }
    private static String getBizOrgTypeForPartnerRole(String partnerRole, String acctBizOrgTypes){
        system.debug('getBizOrgTypeForPartnerRole ==>'+acctBizOrgTypes);
       // List<String> bizOrgTypes = acctBizOrgTypes.split(';');
       List<String> bizOrgTypes = acctBizOrgTypes != null ? acctBizOrgTypes.split(';') : new List<String>();
        String defaultBizOrgType = null;
        String bizOrgType;  //check for checkmarx
        String resBizOrgType = null;
        Set<String> mappingBizOrgTypes = new Set<String>();
        List<PRM_PartnerRoleTypeMappings__mdt> partnerRoleMappngs = [SELECT PRM_Biz_Org_Type__c,isDefault__c FROM PRM_PartnerRoleTypeMappings__mdt WHERE PRM_Partner_Role__c=:partnerRole];
        for(PRM_PartnerRoleTypeMappings__mdt prMapping : partnerRoleMappngs ){
            mappingBizOrgTypes.add(prMapping.PRM_Biz_Org_Type__c);
            if(prMapping.isDefault__c){
                defaultBizOrgType = prMapping.PRM_Biz_Org_Type__c;
                //break;
            }
        }

        if(bizOrgTypes.size() == 0) {
            bizOrgType = defaultBizOrgType;  //If Account has no BizOrg Type
        }else if(partnerRoleMappngs.size() > 1){
            boolean hasDefaultBizOrgType = false;
            for(String bOrgType : bizOrgTypes){
                if(mappingBizOrgTypes.contains(bOrgType)){
                    if(defaultBizOrgType == bOrgType){
                        hasDefaultBizOrgType = true; 
                    }
                    resBizOrgType = bOrgType;
                }
            }
            if(hasDefaultBizOrgType || String.isEmpty(resBizOrgType)){
                bizOrgType = defaultBizOrgType;
            }else{
                bizOrgType = resBizOrgType;   
            }
        }else if(partnerRoleMappngs.size()==1){
            bizOrgType = partnerRoleMappngs[0].PRM_Biz_Org_Type__c; //check for checkmarx
        }  
        return bizOrgType;
        }
        
    private static PRM_Account_Contact_Profiles_Model.Address getPersonMailingAddress(Contact cont){
        PRM_Account_Contact_Profiles_Model.Address mailingAddr = new PRM_Account_Contact_Profiles_Model.Address();
        boolean isAddressEmpty = (String.isEmpty(cont.MailingStreet) && String.isEmpty(cont.MailingCity) 
                                  && String.isEmpty(cont.MailingState) && String.isEmpty(cont.MailingCountry) 
                                  && String.isEmpty(cont.MailingPostalCode) ) ? true: false;
        if(!isAddressEmpty){
            mailingAddr.Street = cont.MailingStreet;
            mailingAddr.City = cont.MailingCity;
            mailingAddr.State = cont.MailingState;
            mailingAddr.StateCode = cont.MailingStateCode;
            mailingAddr.Country = cont.MailingCountry;
            mailingAddr.CountryCode = cont.MailingCountryCode;
            if(!String.isEmpty(cont.MailingCountry)){ 
                mailingAddr.CountryCodeShort =  getCountryCodeMapping(cont.MailingCountry);
            }
            mailingAddr.PostalCode = cont.MailingPostalCode; 
            mailingAddr.Geo = cont.Account.Core_Geo__c;
            mailingAddr.SubGeo = cont.Account.Core_Sub_Geo__c;
            return mailingAddr;
        }else{
            return null;
        }      
        
    }
    @TestVisible
    private static String getCountryCodeMapping(String country){      
        List<Core_Country_Code_Mapping__c> configCountryCodes = [SELECT ISO_Code__c,Country_Code__c FROM Core_Country_Code_Mapping__c WHERE Name= :country OR ISO_Code__c= :country];
        return (configCountryCodes.size() > 0 ? configCountryCodes[0].Country_Code__c : null );      
    }
    
    @TestVisible
    private static String getCountryCodeNameMapping(String country){      
        List<Core_Country_Code_Mapping__c> configCountryCodes = [SELECT Name, ISO_Code__c,Country_Code__c FROM Core_Country_Code_Mapping__c WHERE ISO_Code__c= :country OR Country_Code__c = :country];
        return (configCountryCodes.size() > 0 ? configCountryCodes[0].Name : null );      
    }
    
    public static String getMatchingAccountSFID(String cimid, String eRPMAccountNumber){
        String AcctSFID = '';
        set<String> acctCIMIds = new set<String>();
        set<String> eRPMAcctNumbers = new set<String>();            
        List<Account> accts = [SELECT Id,Core_CIM_ID__c,AccountNumber,core_business_party_id__c,
                               (SELECT Core_ERPM_Account_Number__c FROM Account_ERPM_Engagements__r)
                               FROM Account WHERE core_business_party_id__c= :cimid ];
        //system.debug('accts.size() ===>'+accts.size());
        if(accts.size()>0){
            if(accts.size() == 1){
                AcctSFID = accts[0].Id;
            }else{
                acctCIMIds.add(cimid);
                if(!String.isEmpty(eRPMAccountNumber)){
                    eRPMAcctNumbers.add(eRPMAccountNumber); 
                }else{
                    for(Account acct: accts){                    
                        for(Core_Account_ERPM_Engagement__c ae : acct.Account_ERPM_Engagements__r ) {
                            eRPMAcctNumbers.add(ae.Core_ERPM_Account_Number__c);
                        }                   
                    }
                }                
                AcctSFID = Core_IntegrationOptimization.GetMatchingAccountSFIDfromCIMID(acctCIMIds, eRPMAcctNumbers);  
            }            
        }
        return AcctSFID;
    }    
    public static PRM_Account_Contact_Profiles_Model.Profiles generateError(String errorMsg){
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
        profiles.ErrorMsg = new PRM_Account_Contact_Profiles_Model.ErrorMsg();
        profiles.ErrorMsg.error = true;
        profiles.ErrorMsg.msg = errorMsg;        
        //return JSON.serialize(profiles);
        profiles.ResponseTimeMS = responseTimeCalc();
        return profiles;
    }  
    
    public static PRM_Account_Contact_Profiles_Model.Profiles generateAccountResultError(String errorMsg){
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
        profiles.AccountResults = new PRM_Account_Contact_Profiles_Model.AccountResultWrapper();
        profiles.AccountResults.Status = 'Error';
        profiles.AccountResults.Responsecode = 400;
        profiles.AccountResults.ErrorResponse = errorMsg;
        profiles.ResponseTimeMS = responseTimeCalc(); 
        return profiles;
    } 
    
    public static PRM_Account_Contact_Profiles_Model.Profiles generateException(Exception e){
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new  PRM_Account_Contact_Profiles_Model.Profiles();
        PRM_Account_Contact_Profiles_Model.ExceptionWrapper ew = new PRM_Account_Contact_Profiles_Model.ExceptionWrapper();
        ew.Status = 'ERROR';
        ew.StatusCode = 400;
        ew.Message = e.getMessage();
        ew.StackTrace = e.getStackTraceString();
        profiles.ExceptionDetails = ew;
        profiles.ResponseTimeMS = responseTimeCalc();
        return profiles;
    }   
    
    public static Long responseTimeCalc(){
        return system.now().getTime()-startTime;
    }
        
    //If the email id is part of system account, SF will send blank response
    public static Boolean ChecksystemAccounts(String EmailId){
        Set<Id>SysAccIdSet = new Set<Id>();
        Boolean isSysAcc = false;
        Map<String,Core_Intel_System_Accounts__mdt> mapSysAcc = Core_Intel_System_Accounts__mdt.getAll();
        for(String keySetString : mapSysAcc.keySet()){
            SysAccIdSet.add(mapSysAcc.get(keySetString).AccountId__c);
        }
        for(Contact con: [SELECT Id, AccountId, Email FROM Contact WHERE email =: EmailId]){
            if(SysAccIdSet.contains(con.AccountId)){
                isSysAcc = true;
            }
        }
        return isSysAcc;
    }
    //Sending Blank Response
    public static PRM_Account_Contact_Profiles_Model.Profiles systemAccountMethod(){
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new  PRM_Account_Contact_Profiles_Model.Profiles();
        return profiles;
    }
}