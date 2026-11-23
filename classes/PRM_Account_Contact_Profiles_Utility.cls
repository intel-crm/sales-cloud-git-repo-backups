@SuppressWarnings('PMD')

public class PRM_Account_Contact_Profiles_Utility {
    
    public static String CIMID = 'CIMID';
    public static Long responceTime;
    public static Long startTime;
    public static PRM_Account_Contact_Profiles_Model.Profiles GetAccountResults(String inputvalue, String addtlInputValue) {
        String AcctSFID = '';
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
        profiles.AccountResults = new PRM_Account_Contact_Profiles_Model.AccountResultWrapper();
        try{ 
            AcctSFID = getMatchingAccountSFID(inputvalue, addtlInputValue);  
            system.debug('AcctSFID ==>'+AcctSFID);
            if(AcctSFID!=''){
                List<Account> accounts = [SELECT Id,Core_CIM_ID__c,
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
                        acctRes.CIMId = accounts[0].Core_CIM_ID__c;
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

    /*public static PRM_Account_Contact_Profiles_Model.Profiles GetRegRequestAccountProfiles(String param) {
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
        List<PRM_Account_Contact_Profiles_Model.ContactAccountWrapper> contAccts = getPersonAccountsObj(param);
        List<PRM_Account_Contact_Profiles_Model.AccountRequestWrapper> acctReqs = getAccountRequestsDetailsObj(param);
        if(contAccts !=null && contAccts.size() > 0)
        {
            profiles.ContactAccounts = contAccts;
        }
        if(acctReqs != null && acctReqs.size() > 0)
        {
            profiles.AccountRequests = acctReqs;
        }
        if((contAccts == null || contAccts.size() == 0) && (acctReqs == null && acctReqs.size() == 0))
        {
            return generateError('No records found');
        }
        return profiles;
    }*/

    public static PRM_Account_Contact_Profiles_Model.Profiles GetRegRequestAccountProfile(String param) {  
        //system.debug('GetRegRequestAccountProfile ===> param ===>'+param);
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
        //profiles.RegRequestAccountProfile = new PRM_Account_Contact_Profiles_Model.RegRequestAccountProfile();
        PRM_Account_Contact_Profiles_Model.ContactAccountWrapper contAcct = getPersonAccountObj(param);
        
        if(contAcct != null){ 
            profiles.ContactAccount = contAcct;
            profiles.ResponseTimeMS = responseTimeCalc();
            return profiles;      
        }else {
            PRM_Account_Contact_Profiles_Model.AccountRequestWrapper acctReq = getAccountRequestDetailsObj(param);
            if(acctReq != null){                
                profiles.AccountRequest = acctReq;
                profiles.ResponseTimeMS = responseTimeCalc();
                return profiles;
            }else{
                return generateError('No records found');
            }
        }
        
    }
    
    public static PRM_Account_Contact_Profiles_Model.Profiles GetRegistrationRequestProfile(String param){
       
        List<PRM_Registration_Request__c> newRegs = [SELECT id,Name,PRM_Status__c,PRM_Partner_Role__c,PRM_Email_ID__c,PRM_Enterprise_ID__c
                                                     FROM PRM_Registration_Request__c WHERE Id= :param OR PRM_Enterprise_ID__c= :param OR PRM_Contact_Login_ID__c= :param OR PRM_Email_ID__c= :param ];
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
                                           (SELECT PRM_Channel_Program_Id__r.Name,PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Status_Nm__c FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c!='Inactive')     
                                           From Account WHERE Id= :contacts[0].AccountId];
                    if(accts.size() > 0){
                        profiles.RegistrationRequestProfile.AccountInformation = getRegReqAccountDetails(accts[0]);
                    } 
                }
            }
            //system.debug('JSON ==>'+JSON.serialize(regReq));
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
        if(inputfield == CIMID){            
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
    
    public static PRM_Account_Contact_Profiles_Model.Profiles GetAccountRequestDetails(String param){
        
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
        profiles.AccountRequest = new PRM_Account_Contact_Profiles_Model.AccountRequestWrapper();
        profiles.AccountRequest = getAccountRequestDetailsObj(param);
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
        PRM_Account_Contact_Profiles_Model.AccountRequestWrapper acctReqWrapper = new  PRM_Account_Contact_Profiles_Model.AccountRequestWrapper();
        PRM_Account_Contact_Profiles_Model.AccountRequest acctReq = new PRM_Account_Contact_Profiles_Model.AccountRequest();
        List<PRM_Registration_Request__c> newRegs = [SELECT PRM_CIM_ID__c,PRM_Salesforce_ID__c,PRM_Address_Line_1__c,PRM_Address_Line_2__c,
                                                     PRM_Partner_Type__c,PRM_CIMStatusDetails__c,PRM_City__c,PRM_Email_ID__c,PRM_Company_Email_Domain__c,
                                                     PRM_Account_Name__c,PRM_Company_National_ID__c,PRM_Enterprise_ID__c,PRM_EV_flag__c,
                                                     PRM_EV_Token__c,PRM_First_Name__c,PRM_Job_Function__c,PRM_Last_Name__c,
                                                     PRM_Contact_Login_ID__c,PRM_Person_Phone_Number__c,PRM_Country__c, PRM_Contact_Country__c, PRM_DeDup_Criteria__c,
                                                     PRM_Dup_Status__c,PRM_Matching_Contact__c,PRM_Email_Domain_Check__c,PRM_Email_Log__c,
                                                     PRM_EmailVerifiedDateTime__c,PRM_EV_Expired_vs_Pending__c,PRM_isLocked__c,PRM_isSubmitted__c,
                                                     PRM_Legal_Agreement_Criteria__c,PRM_Legal_Agreements__c,PRM_manualRecordCheck__c,PRM_Channel_Program__c,
                                                     PRM_Partner_Role__c,PRM_Partner_Segment__c,PRM_Channel_Program_Level__c,PRM_Phy_Address_Line_2__c,
                                                     PRM_Phy_City__c,PRM_Phy_Country__c,PRM_Phy_State_Province__c,PRM_Phy_Zip_Postal_Code__c,
                                                     PRM_Preferred_Language__c,PRM_Profile_Response__c,PRM_State_Province__c,
                                                     PRM_Status__c,PRM_Status_Reason__c,PRM_Subscriptions__c,PRM_Tax_ID_Registration__c,
                                                     PRM_Company_Size__c,PRM_Account_Phone__c,PRM_Account_URL__c,PRM_Zip_Postal_Code__c
                                                     //PRM_Wechat_Union_Id__c,//PRM_Wechat_Open_Id__c,PRM_Wechat_Union_Id__c, PRM_Registration_Source_txt__c,
                                                     //(SELECT Name,PRM_Partner_Subscription__r.Name,PRM_Partner_Subscription__r.PRM_Subscription_Cd__c FROM Subscriptions__r),
                                                     //(SELECT Name,PRM_Agreement_Signed_Date__c,PRM_Partner_Agreement__r.Name,PRM_Partner_Agreement__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement__r.PRM_Agreement_Category_Nm__c FROM Terms_and_Conditions__r),
                                                     //(SELECT PRM_Account_Nm__c,PRM_AddressLine1_Txt__c,PRM_AddressLoc_Nm__c,PRM_AddressType_Nm__c,PRM_CIM_Id__c,Name,PRM_SearchScore_Nbr__c,PRM_City_Nm__c,PRM_Country_Cd__c,PRM_Country_Nm__c,PRM_Subdiv_Cd__c,PRM_Subdiv_Nm__c,PRM_Postal_Cd__c,PRM_Account_Id__c FROM CIM_Search_Results__r)
                                                     FROM PRM_Registration_Request__c WHERE Id= :param OR PRM_Enterprise_ID__c= :param OR PRM_Contact_Login_ID__c= :param OR PRM_Email_ID__c= :param ];
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
        acctReqInfo.AccountRequestId = newReg.Id;
        acctReqInfo.AccountCIMID = newReg.PRM_CIM_ID__c;
        acctReqInfo.AccountSalesforceID = newReg.PRM_Salesforce_ID__c;
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
        acctReqInfo.ContactEVToken = newReg.PRM_EV_Token__c;
        acctReqInfo.ContactFirstName = newReg.PRM_First_Name__c;
        acctReqInfo.ContactJobFunction = newReg.PRM_Job_Function__c;
        acctReqInfo.ContactLastName = newReg.PRM_Last_Name__c;
        acctReqInfo.ContactLoginID = newReg.PRM_Contact_Login_ID__c;
        acctReqInfo.ContactPhoneNumber = newReg.PRM_Person_Phone_Number__c;
        acctReqInfo.Country = newReg.PRM_Country__c;
        acctReqInfo.ContactCountry = newReg.PRM_Contact_Country__c;
        acctReqInfo.DuplicateAccountCheck = newReg.PRM_DeDup_Criteria__c;
        acctReqInfo.DuplicateAccountStatus = newReg.PRM_Dup_Status__c;
        acctReqInfo.DuplicateContact = newReg.PRM_Matching_Contact__c;
        acctReqInfo.Email = newReg.PRM_Email_ID__c;
        acctReqInfo.EmailDomainCheck = newReg.PRM_Email_Domain_Check__c;
        acctReqInfo.EmailLog = newReg.PRM_Email_Log__c;
        acctReqInfo.EmailVerifiedDateTime = newReg.PRM_EmailVerifiedDateTime__c;
        acctReqInfo.EVExpiredvsPending = newReg.PRM_EV_Expired_vs_Pending__c;
        acctReqInfo.isLocked = newReg.PRM_isLocked__c;
        acctReqInfo.isSubmitted = newReg.PRM_isSubmitted__c;
        acctReqInfo.LegalAgreementCheck = newReg.PRM_Legal_Agreement_Criteria__c;
        acctReqInfo.LegalAgreements = newReg.PRM_Legal_Agreements__c;
        acctReqInfo.manualRecordCheck = newReg.PRM_manualRecordCheck__c;
        acctReqInfo.PartnerProgram = newReg.PRM_Channel_Program__c;
        acctReqInfo.PartnerRole = newReg.PRM_Partner_Role__c;
        acctReqInfo.PartnerSegment = newReg.PRM_Partner_Segment__c;
        acctReqInfo.PartnerTier = newReg.PRM_Channel_Program_Level__c;
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
        //acctReqInfo.WeChatUnionId = newReg.PRM_Wechat_Union_Id__c;
        //-----------------------------We chat-----------------------------
        /*
        acctReqInfo.WechatOpenId = newReg.PRM_Wechat_Open_Id__c;
        acctReqInfo.WechatUnionId = newReg.PRM_Wechat_Union_Id__c;
        acctReqInfo.RegistrationSource = newReg.PRM_Registration_Source_txt__c;
		*/
        //-----------------------------We chat-----------------------------
        
        return acctReqInfo;
    }
    
    public static PRM_Account_Contact_Profiles_Model.Profiles GetAccountProfile(String inputfield, String inputvalue, String addtlInputValue){
        
        String AcctSFID = '';
        //system.debug('inside GetAccountProfile ===>'+inputfield);
        if(inputfield == CIMID){            
            AcctSFID = getMatchingAccountSFID(inputvalue, addtlInputValue);            
        }else{
            AcctSFID = inputvalue; 
        }
        if(!String.isEmpty(AcctSFID)){
            //Core_Alt_Address_1__c,Core_Alt_Address_2__c,Core_Alt_Language_City__c,Core_Alt_Language_State_Province__c,Core_Alt_Language_country__c,Core_Alt_Language_Postal_Code__c,
            List<Account> accounts = [SELECT name,Parent.Name,Core_Alternate_Language_Name__c,Core_Account_Type__c,
                                      Core_IPA_Partner_Role__c,Core_Account_Legal_Name__c,Core_Prime_Account_Name__c,
                                      Core_Covered_Account__c,Core_CNDA_Number__c,Core_Sales_Groups__c,Core_Account_BU_Focus__c,
                                      Core_Account_Tier__c,Industry,Core_CIM_ID__c,Core_IPS_Active__c,Core_Business_ID__c,
                                      Core_Business_Partner_Id__c,BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,
                                      BillingCountryCode,BillingPostalCode,ShippingStreet,ShippingCity,ShippingState,ShippingStateCode,
                                      ShippingCountry,ShippingCountryCode,ShippingPostalCode,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_User_Defined_Website__c,Core_User_Defined_Number_of_Employees__c,
                                      // (SELECT id,Name,Email From Contacts),
                                      (SELECT PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_Relationship_Id__r.Name,PRM_Status_Nm__c,PRM_InActive_Ind__c FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c=false),
                                      (SELECT Core_Account_Id__r.Name,Core_ERPM_Engagement_Id__r.Name,Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,Core_ERPM_Engagement_Id__r.Core_Technical_Tier_Code__c FROM Account_ERPM_Engagements__r),
                                      (SELECT PRM_Channel_Program_Id__r.Name,PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Status_Nm__c FROM Channel_Memberships1__r WHERE PRM_Status_Nm__c!='Inactive'),
                                      (SELECT PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Status_Nm__c FROM AccountBenefitAssociations__r WHERE PRM_Status_Nm__c='Active'),
                                      //PRM_Start_Date_Dt__c,PRM_End_Date_Dt__c,
                                      (SELECT Name,PRM_InActive_Ind__c,PRM_Specialty_Id__r.Name,PRM_Specialty_Id__r.PRM_Role_Nm__c,PRM_Specialty_Id__r.PRM_Tier_Nm__c FROM Account_Specialty_Associations__r WHERE PRM_InActive_Ind__c=false),
                                      (SELECT Name,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Name,Core_Partner_Account_Id__c,Core_Partner_Account_Id__r.Name,Core_Inactive_Ind__c,Core_MDA_Ind__c FROM Partner_Account_Group_Members1__r WHERE Core_Inactive_Ind__c=false),                                  
                                      (SELECT Name,PRM_Agreement_Sign_Dt__c,PRM_Contact__r.Name,PRM_Partner_Agreement_Id__r.Name,PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name FROM AccountLegalAgreementAssociations__r)
                                      FROM Account WHERE Id= :AcctSFID];
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
                profiles.AccountProfile.AccoutBenefitAssociations = getAccoutBenefitAssociations(accounts[0]);
                profiles.AccountProfile.AccountSpecialityAssociations = getAccountSpecialityAssociations(accounts[0]);
                //acctProfile.AccountProfile.OnePartnerIDGroupMembers = getOnePartnerIDGroupMembers(accounts[0]);
                profiles.AccountProfile.AccountLegalAgreements = getAccountLegalAgreements(accounts[0]);
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
            legalAgreement.AgreementSignedBy =  agreement.PRM_Contact__r.Name;
            legalAgreement.IsPartnerAgreementActive = agreement.PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c;
            legalAgreement.PartnerAgreementName = agreement.PRM_Partner_Agreement_Id__r.Name;
            legalAgreement.PartnerAgreementCode = agreement.PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c;
            legalAgreement.PartnerProgramName = agreement.PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name;
            legalAgreements.add(legalAgreement);  
        }
        return legalAgreements;
    }
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
            asas.add(asa);
        }
        return asas;
    }
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
    }
    private static List<PRM_Account_Contact_Profiles_Model.AccountChannelMembership> getAccountChannelMemberships(Account acct){
        List<PRM_Account_Contact_Profiles_Model.AccountChannelMembership> acms = new List<PRM_Account_Contact_Profiles_Model.AccountChannelMembership>();
        for(PRM_AccountChannelMembership__c channelMembership: acct.Channel_Memberships1__r ){
            PRM_Account_Contact_Profiles_Model.AccountChannelMembership acm = new PRM_Account_Contact_Profiles_Model.AccountChannelMembership();
            acm.PartnerProgramName = channelMembership.PRM_Channel_Program_Id__r.Name;
            acm.PartnerProgramCode = channelMembership.PRM_Channel_Program_Id__r.PRM_programCode__c;
            acm.PartnerTier = channelMembership.PRM_Channel_Program_Level_Id__r.Name;            
            acm.PartnerRole = (String.isEmpty(channelMembership.PRM_Partner_Role__c))?null:((String) channelMembership.PRM_Partner_Role__c).replace('<br>',',');
            acm.Status = channelMembership.PRM_Status_Nm__c;
            acms.add(acm);
        }
        return acms;
    }
    
    public static PRM_Account_Contact_Profiles_Model.Profiles GetPersonAccount(String param) {
        
        PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
        profiles.ContactAccount = new PRM_Account_Contact_Profiles_Model.ContactAccountWrapper();
        profiles.ContactAccount = getPersonAccountObj(param);
        if(profiles.ContactAccount!=null){   
            profiles.ResponseTimeMS = responseTimeCalc();
            return profiles;
        }else{
            return generateError('No records found');
        }       
        
    }
    private static PRM_Account_Contact_Profiles_Model.ContactAccountWrapper getPersonAccountObj(String param){
        PRM_Account_Contact_Profiles_Model.ContactAccountWrapper ContAcct = new PRM_Account_Contact_Profiles_Model.ContactAccountWrapper();
        List<Contact> conts = [SELECT id,AccountId,Account.Name,FirstName, LastName, Title,Name,Core_Local_First_Name__c,Core_Local_Last_Name__c,
                               Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c,Core_Job_Function__c,Core_IPA_Email_Verification_Date__c,
                               Core_Job_Function_Code__c,phone,MobilePhone,email,Core_Preferred_Communication__c,Core_Preferred_Language__c,
                               Core_IPA_Partner_Role__c,Core_IPA_Contact_Segment__c,Core_Login_Id__c,Core_eRPM_Person_Id__c,Core_Enterprise_Id__c,
                               MailingStreet,MailingCity,MailingState,MailingStateCode,MailingCountry,MailingCountryCode,MailingPostalCode,  
                               //PRM_Wechat_Union_Id__c,
                               (SELECT PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c, PRM_Status_Nm__c FROM Contact_Subscription_Associations__r WHERE PRM_Status_Nm__c='Active'),
                               (SELECT Core_Entitlement_Id__r.Name,Core_Type__c,Core_Status__c,Core_Ops_Status__c,Core_Selected__c FROM Contact_Entitlements__r)
                               FROM Contact WHERE id= :param OR Email= :param OR Core_Enterprise_Id__c= :param OR Core_Login_Id__c= :param LIMIT 1];
        //OR Core_eRPM_Person_Id__c= :param
        if(conts.size()>0){
            List<Account> accounts = [SELECT name,Parent.Name,Core_Alternate_Language_Name__c,Core_Account_Type__c,
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
                                      FROM Account WHERE Id= :conts[0].AccountId];	
            if(accounts.size()>0){
                
                //ContAcct.ContactAccount = new PRM_Account_Contact_Profiles_Model.ContactAccountWrapper();
                ContAcct.AccountInformation = getAccountInformation(accounts[0]);
                ContAcct.AccountInformation.AccountContactRelationships = getAccountContactRelationships(accounts[0]);
                ContAcct.AccountInformation.AccountEngagements = getAccountERPMEngagements(accounts[0]);
                ContAcct.AccountInformation.AccoutBenefitAssociations = getAccoutBenefitAssociations(accounts[0]);
                ContAcct.AccountInformation.AccountChannelMemberships = getAccountChannelMemberships(accounts[0]);  
                ContAcct.AccountInformation.ProfileResponses = getProfileResponses(accounts[0].Id);
                ContAcct.ContactBasicProfile = new PRM_Account_Contact_Profiles_Model.ContactBasicProfileDetailsWrapper();
                ContAcct.ContactBasicProfile.ContactBasicInformation = getContactBasicDetails(conts[0]); 
                ContAcct.ContactBasicProfile.ContactSubscriptions = getPersonSubscriptions(conts[0]);
                ContAcct.ContactBasicProfile.ContactEntitlements = getPersonEntitlements(conts[0]);
                return ContAcct;
            }else{
                return null;
            }
        }else{
            return null;
        }
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
        accountInfo.ParentAccount = acct.Parent.Name;
        accountInfo.AlternateLanguageName = acct.Core_Alternate_Language_Name__c;
        accountInfo.BizOrgType = acct.Core_Account_Type__c;
        accountInfo.PartnerRole = String.isEmpty(acct.Core_IPA_Partner_Role__c)?null:((String) acct.Core_IPA_Partner_Role__c).replace('<br>',',');
        accountInfo.AccountLegalName = acct.Core_Account_Legal_Name__c;
        accountInfo.PrimeAccountName = acct.Core_Prime_Account_Name__c;
        accountInfo.CoveredAccount = acct.Core_Covered_Account__c;
        accountInfo.CNDANumber = acct.Core_CNDA_Number__c;
        accountInfo.SalesGroup = acct.Core_Sales_Groups__c;
        accountInfo.AccountBUFocus = acct.Core_Account_BU_Focus__c;
        accountInfo.AccountTier = acct.Core_Account_Tier__c;
        accountInfo.Industry = acct.Industry;
        accountInfo.CompanySize = acct.Core_User_Defined_Number_of_Employees__c;
        accountInfo.CompanyWebsite = acct.Core_User_Defined_Website__c;
        /*
accountInfo.AltLanguageAddress1 = acct.Core_Alt_Address_1__c;
accountInfo.AltLanguageAddress2 = acct.Core_Alt_Address_2__c;
accountInfo.AltLanguageCity = acct.Core_Alt_Language_City__c;
accountInfo.AltLanguageState = acct.Core_Alt_Language_State_Province__c;
accountInfo.AltLanguageCountry = acct.Core_Alt_Language_country__c;
accountInfo.AltLanguagePostalCode = acct.Core_Alt_Language_Postal_Code__c;
*/
        accountInfo.CIMId = acct.Core_CIM_ID__c;
        accountInfo.IPSActive = acct.Core_IPS_Active__c;
        accountInfo.BusinessId = acct.Core_Business_ID__c;
        accountInfo.BusinessPartnerId = acct.Core_Business_Partner_Id__c;
        accountInfo.IsIPA = acct.Core_Intel_Partner_Alliance_PartnerGroup__c;
        
        accountInfo.Address = new PRM_Account_Contact_Profiles_Model.AccountAddress();
        accountInfo.Address.PrimaryAddress = getAccountPrimaryAddress(acct); 
        accountInfo.Address.SecondaryAddress = getAccountSecondaryAddress(acct);
        
        //ContAcct.ContactAccount = new ContactAccountWrapper();
        //ContAcct.ContactAccount.AccountInformation = accountInfo;
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
    private static List<PRM_Account_Contact_Profiles_Model.ProfileResponse> getProfileResponses(Id recordId){
        
        String channelProg = 'Intel Partner Alliance';
        String objectName = 'Account';
        Map<Id,PRM_Profile_Questions__c> QuestionIdMap = new Map<Id,PRM_Profile_Questions__c>();       
        Map<Id,List<String>> mapQuesToResp = new Map<Id,List<String>>();
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
            for(PRM_Profile_Responses__c objResp : [SELECT PRM_Profile_Questions_Id__c,PRM_Response_Txt__c FROM PRM_Profile_Responses__c WHERE PRM_InActive_Ind__c=false AND PRM_Account_Id__c =:recordId AND PRM_Profile_Questions_Id__c in :QuestionIdMap.keySet()] ){
                if(mapQuesToResp.containsKey(objResp.PRM_Profile_Questions_Id__c)) {                    
                    mapQuesToResp.get(objResp.PRM_Profile_Questions_Id__c).add(objResp.PRM_Response_Txt__c);
                }else {
                    mapQuesToResp.put(objResp.PRM_Profile_Questions_Id__c, new List<String> { objResp.PRM_Response_Txt__c});
                }
            }
        }
        List<PRM_Account_Contact_Profiles_Model.ProfileResponse> ProfileResponses = new List<PRM_Account_Contact_Profiles_Model.ProfileResponse>();        
        for(Id questionId: QuestionIdMap.keySet() ){
            PRM_Account_Contact_Profiles_Model.ProfileResponse resp = new PRM_Account_Contact_Profiles_Model.ProfileResponse();
            resp.QuestionText = QuestionIdMap.get(questionId).PRM_Question_Display_Txt__c;
            resp.QuestionCode = QuestionIdMap.get(questionId).PRM_Question_Cd__c;
            resp.Responses = new List<String>();
            if(mapQuesToResp.containsKey(questionId)){
                resp.Responses = mapQuesToResp.get(questionId);
            }
            ProfileResponses.add(resp);
        }
        //profileRespsWrapper.ProfileResponses = responses;
        return ProfileResponses;
    } 
    
    public static PRM_Account_Contact_Profiles_Model.Profiles GetPersonBasicProfile(String param){
        //system.debug('<===== GetPersonBasicProfile ====>');
        List<Contact> conts = [SELECT id,AccountId,Account.Name, FirstName, LastName, Title,Name,Core_Local_First_Name__c,Core_Local_Last_Name__c,
                               Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c,Core_Job_Function__c,Core_IPA_Email_Verification_Date__c,
                               Core_Job_Function_Code__c,phone,MobilePhone,email,Core_Preferred_Communication__c,Core_Preferred_Language__c,
                               Core_IPA_Partner_Role__c,Core_IPA_Contact_Segment__c,Core_Login_Id__c,Core_eRPM_Person_Id__c,Core_Enterprise_Id__c,
                               MailingStreet,MailingCity,MailingState,MailingStateCode,MailingCountry,MailingCountryCode,MailingPostalCode,
                               //PRM_Wechat_Union_Id__c,
                               (SELECT PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c, PRM_Status_Nm__c FROM Contact_Subscription_Associations__r WHERE PRM_Status_Nm__c='Active'),
                               (SELECT Core_Entitlement_Id__r.Name,Core_Type__c,Core_Status__c,Core_Ops_Status__c,Core_Selected__c FROM Contact_Entitlements__r)
                               FROM Contact WHERE id= :param OR Email= :param OR Core_Enterprise_Id__c= :param OR Core_Login_Id__c= :param LIMIT 1];
        //   OR Core_eRPM_Person_Id__c= :param 
        //  (SELECT PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_Relationship_Id__r.Name,PRM_InActive_Ind__c FROM Account_Contact_Relationships__r), 
        
        if(conts.size()>0){            
            PRM_Account_Contact_Profiles_Model.Profiles profiles = new PRM_Account_Contact_Profiles_Model.Profiles();
            profiles.ContactBasicProfile = new PRM_Account_Contact_Profiles_Model.ContactBasicProfileDetailsWrapper();
            profiles.ContactBasicProfile.ContactBasicInformation = getContactBasicDetails(conts[0]);            
            profiles.ContactBasicProfile.ContactEntitlements = getPersonEntitlements(conts[0]);                             
            profiles.ContactBasicProfile.ContactSubscriptions = getPersonSubscriptions(conts[0]);
            //return JSON.serialize(profiles); 
            profiles.ResponseTimeMS = responseTimeCalc();
            return profiles;     
        }else{
            return generateError('No records found');
        }        
    }    
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
    private static PRM_Account_Contact_Profiles_Model.ContactBasicInformationWrapper getContactBasicDetails(Contact cont ){
        //ContactBasicProfileWrapper ContactProfile
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
        ContactDetails.EmailVerificationDate = cont.Core_IPA_Email_Verification_Date__c;
        ContactDetails.JobFunction = cont.Core_Job_Function__c;
        ContactDetails.JobFunctionCode = cont.Core_Job_Function_Code__c;
        ContactDetails.Phone = cont.phone;
        ContactDetails.Mobile = cont.MobilePhone;
        ContactDetails.Email = cont.email;
        ContactDetails.PreferredCommunication = cont.Core_Preferred_Communication__c;
        ContactDetails.PreferredLanguage = cont.Core_Preferred_Language__c;
        ContactDetails.PartnerRole = (String.isEmpty(cont.Core_IPA_Partner_Role__c))?null:((String) cont.Core_IPA_Partner_Role__c).replace('<br>',',');
        ContactDetails.Segment = cont.Core_IPA_Contact_Segment__c;
        ContactDetails.Loginid = cont.Core_Login_Id__c;
        ContactDetails.eRPMPersonId = cont.Core_eRPM_Person_Id__c;
        ContactDetails.EnterpriseId = cont.Core_Enterprise_Id__c;
        ContactDetails.MailingAddress = getPersonMailingAddress(cont);  
        //ContactDetails.WeChatUnionId = cont.PRM_Wechat_Union_Id__c;
        //-----------------------------We chat-----------------------------
        /*
        ContactDetails.WechatOpenId = cont.PRM_Wechat_Open_Id__c;
        ContactDetails.WechatUnionId = cont.PRM_Wechat_Union_Id__c;
        ContactDetails.RegistrationSource = cont.PRM_Registration_Source_txt__c;
		*/
        //-----------------------------We chat-----------------------------
        
        return ContactDetails;
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
            return mailingAddr;
        }else{
            return null;
        }      
        
    }
    
    private static String getCountryCodeMapping(String country){      
        List<Core_Country_Code_Mapping__c> configCountryCodes = [SELECT ISO_Code__c,Country_Code__c FROM Core_Country_Code_Mapping__c WHERE Name= :country OR ISO_Code__c= :country];
        return (configCountryCodes.size() > 0 ? configCountryCodes[0].Country_Code__c : null );      
    }
    public static String getMatchingAccountSFID(String cimid, String eRPMAccountNumber){
        String AcctSFID = '';
        set<String> acctCIMIds = new set<String>();
        set<String> eRPMAcctNumbers = new set<String>();            
        List<Account> accts = [SELECT Id,Core_CIM_ID__c,AccountNumber,
                               (SELECT Core_ERPM_Account_Number__c FROM Account_ERPM_Engagements__r)
                               FROM Account WHERE Core_CIM_ID__c= :cimid];
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
                //system.debug('eRPM Account Numbers ===>'+eRPMAcctNumbers);
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
        system.debug('Exception Cause ==>'+e.getCause());
        profiles.ExceptionDetails = ew;
        profiles.ResponseTimeMS = responseTimeCalc();
        return profiles;
    }   

    public static Long responseTimeCalc(){
        return system.now().getTime()-startTime;
    }
}