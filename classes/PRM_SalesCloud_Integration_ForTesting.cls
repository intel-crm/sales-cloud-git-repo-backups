public class PRM_SalesCloud_Integration_ForTesting {
    
    public static final String ACCOUNT_MESSAGE_TYPE = Label.PRM_SalesCloudInt_Account_Message_Type;
    public static final String CONTACT_MESSAGE_TYPE = Label.PRM_SalesCloudInt_Contact_Message_Type;
    
 /*   public static void GenerateAccountOBM (set<Id> IPAAccountIds){
        
        // This method is called from PRM_SalesCloud_AccountPayload_Batch class.
        system.debug('inside GenerateAccountOBM');
        if(IPAAccountIds.size() > 0){
            List<Account> accountsToBeUpdated = new List<Account>();
            
            
            Map<Id,Account> PAGAccountsMap = new Map<Id,Account>();
            List<PRM_VXBnftMatrix__c> benefitMatrix = new List<PRM_VXBnftMatrix__c>();  
            set<String> benefitCodes = new set<String>();        
            Map<String,Integer> warrantyQtyMap = new Map<String,Integer>();
            Set<String> benefitKeys = new Set<String>();  
            
            Map<Id,PRM_SalesCloud_Warranty__mdt> warrantyMdtMap = new Map<Id,PRM_SalesCloud_Warranty__mdt>([SELECT Id,MasterLabel,PRM_Partner_Role__c,PRM_Partner_Tier__c FROM PRM_SalesCloud_Warranty__mdt]);
            if(warrantyMdtMap.size() > 0 ) {
                
                for(Id mdtId : warrantyMdtMap.keySet() ){
                    system.debug('PartnerRoleKey==>'+warrantyMdtMap.get(mdtId).get('MasterLabel') +'~~'+warrantyMdtMap.get(mdtId).get('PRM_Partner_Role__c')+'~~'+warrantyMdtMap.get(mdtId).get('PRM_Partner_Tier__c'));
                    benefitKeys.add(warrantyMdtMap.get(mdtId).get('MasterLabel') +'~~'+warrantyMdtMap.get(mdtId).get('PRM_Partner_Role__c')+'~~'+warrantyMdtMap.get(mdtId).get('PRM_Partner_Tier__c'));
                    benefitCodes.add((String) warrantyMdtMap.get(mdtId).get('MasterLabel'));
                }
                system.debug('benefitCodes==>'+benefitCodes);
                Map<Id,PRM_PartnerBenefit__c> warrantyBenefitsMap = new Map<Id,PRM_PartnerBenefit__c>([Select Id FROM PRM_PartnerBenefit__c WHERE PRM_Benefit_Cd__c IN :benefitCodes AND PRM_Channel_Program_Id__r.PRM_programCode__c = : Label.PRM_IPAEngagement ]);
                if(warrantyBenefitsMap.size() > 0){                
                    for(PRM_VXBnftMatrix__c benefitMatrixRec : [SELECT Id,Name,PRM_Partner_Role_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,
                                                                PRM_Channel_Program_Level_Id__r.Name,PRM_Total_Quantity_Nbr__c From PRM_VXBnftMatrix__c 
                                                                WHERE PRM_Partner_Benefit_Id__c IN :warrantyBenefitsMap.keySet()] ){
                                                                    system.debug('Find==>'+benefitMatrixRec.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c+'~~'+
                                                                                            benefitMatrixRec.PRM_Partner_Role_Nm__c+'~~'+
                                                                                            benefitMatrixRec.PRM_Channel_Program_Level_Id__r.Name);
                                                                    if(benefitKeys.contains(benefitMatrixRec.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c+'~~'+
                                                                                            benefitMatrixRec.PRM_Partner_Role_Nm__c+'~~'+
                                                                                            benefitMatrixRec.PRM_Channel_Program_Level_Id__r.Name)){
                                                                                                warrantyQtyMap.put(benefitMatrixRec.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c+'~~'+benefitMatrixRec.PRM_Partner_Role_Nm__c+'~~'+
                                                                                                                   benefitMatrixRec.PRM_Channel_Program_Level_Id__r.Name,  (String.isEmpty(String.valueOf(benefitMatrixRec.PRM_Total_Quantity_Nbr__c)) ? 0 : (Integer) benefitMatrixRec.PRM_Total_Quantity_Nbr__c ));
                                                                                            }
                                                                }
                }
            } 
            /*
            for(String key : benefitKeys) {
            system.debug('Key ===>'+key);
            }
            for(String key : warrantyQtyMap.keySet()) {
            system.debug('Key ===>'+key + ';;;'+ warrantyQtyMap.get(key) );
            }
            //List<String> SLABenefitCodes = new List<String>{'BNFTCS48S','BNFTCS24S','BNFTCS4S'};
            List<String> SLABenefitCodes = Label.PRM_SLAHours_BenefitCodes.split(',');
            Map<String,Integer> warrantyQtyMapSLA = new Map<String,Integer>();
            for(PRM_VXBnftMatrix__c benefitMatrixRec : [SELECT Id,Name,PRM_Partner_Role_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,
                                                        PRM_Channel_Program_Level_Id__r.Name,PRM_Total_Quantity_Nbr__c From PRM_VXBnftMatrix__c 
                                                        WHERE PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c IN :SLABenefitCodes] ){
                                                            warrantyQtyMapSLA.put(benefitMatrixRec.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c.toUpperCase(), String.isEmpty(String.valueOf(benefitMatrixRec.PRM_Total_Quantity_Nbr__c)) ? 0 : Integer.valueOf(benefitMatrixRec.PRM_Total_Quantity_Nbr__c) );                           
                                                        }
            system.debug('warrantyQtyMapSLA ==>'+warrantyQtyMapSLA);
            Id PAGRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
            
            List<Account> accts = [SELECT Name,AccountNumber,Core_Prime_Account_Name__c,Core_Sales_Groups__c,Industry,Core_Covered_Account__c,Core_CNDA_Number__c,
                                   Core_CIM_ID__c, Core_Business_Partner_Id__c,Core_Business_ID__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,
                                   Core_Geo__c,Core_Sub_Geo__c,Core_User_Defined_Phone_Number__c,Core_User_Defined_Website__c,
                                   Core_English_Only_Name__c,Core_IPA_Partner_Segment__c,RecordTypeId,Core_IPA_Badge_Tier__c,
                                   Core_Account_Legal_Name__c,Core_Account_BU_Focus__c,LastModifiedDate,
                                   OwnerId,Owner.Email,Owner.FirstName,Owner.LastName,RecordType.Name,Core_Intel_Partner_Alliance_PartnerGroup__c,                               
                                   BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,BillingCountryCode,BillingPostalCode,
                                   ShippingStreet,ShippingCity,ShippingState,ShippingStateCode,ShippingCountry,ShippingCountryCode,ShippingPostalCode,                                   
                                   //PRM_IPA_Integration_Status__c,PRM_IPA_Integration_Queue_Text__c,
                                   // Account ERPM Engagements
                                   (SELECT Core_Account_Id__r.Name,Core_ERPM_Engagement_Id__r.Name,Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,Core_ERPM_Engagement_Id__r.Core_Technical_Tier_Code__c FROM Account_ERPM_Engagements__r),
                                   // Account Channel Memberships
                                   (SELECT Id, PRM_Status_Change_Dt__c,PRM_Channel_Program_Id__r.Name,PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Status_Nm__c FROM Channel_Memberships1__r),
                                   // Account Benefit Associations     
                                   (SELECT PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name, PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Status_Nm__c/*,PRM_Quantity__c FROM AccountBenefitAssociations__r),
                                   // Account Specialty Assciations       
                                   (SELECT Name,PRM_Start_Date_Dt__c,PRM_InActive_Ind__c,PRM_Specialty_Id__r.Name,PRM_Specialty_Id__r.PRM_Role_Nm__c,PRM_Specialty_Id__r.PRM_Tier_Nm__c,PRM_Specialty_Type__c FROM Account_Specialty_Associations__r),
                                   // Account ONE PARTNER ID GROUP MEMEBRS       
                                   (SELECT Name,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Name,Core_Partner_Account_Id__c,Core_Partner_Account_Id__r.Name,Core_Inactive_Ind__c,Core_MDA_Ind__c FROM Partner_Account_Group_Members1__r WHERE Core_Inactive_Ind__c=false),
                                   //Partner Group Members                                   
                                   (SELECT Name,Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Core_CIM_ID__c,Core_Intel_Account_Id__r.Name,Core_Partner_Account_Id__c,Core_Partner_Account_Id__r.Name,Core_Inactive_Ind__c,Core_MDA_Ind__c FROM Partner_Account_Group_Members__r),                                   
                                   // Account Legal Agreements       
                                   (SELECT Name,PRM_Agreement_Sign_Dt__c,PRM_Contact__r.Name,PRM_Partner_Agreement_Id__r.Name,PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name FROM AccountLegalAgreementAssociations__r),
                                   (SELECT Name,Partner_Program__r.name,Effective_End_Date_Time__c,Inactive_Indicator__c FROM Account_Whitelisted_Domains__r),
                                   (SELECT PRM_Distributor_Id__r.Name,PRM_Choice_Nm__c,PRM_Consent_Provided_By_Id__r.Name,PRM_Consent_Provided_Date_Dt__c,PRM_Start_Date_Dt__c,PRM_End_Date_Dt__c,PRM_Consent_Provided_Ind__c FROM Partner_Assist_Consent__r)
                                   FROM Account WHERE Id IN :IPAAccountIds];
            
            
            if(accts.size() > 0) {
                List<Core_Integration_Outbound_Message__c> outboundMsgs = new List<Core_Integration_Outbound_Message__c>();                                        
                for(Account acct: accts){  
                    String tags = '';
                    PRM_SalesCloud_Integration_Model.AccountPayload payload = new PRM_SalesCloud_Integration_Model.AccountPayload();
                    payload.MessageType = ACCOUNT_MESSAGE_TYPE; // Adding account message type to the payload
                    payload.WarrantyBenefits = new PRM_SalesCloud_Integration_Model.WarrantyBenefit();
                    payload.WarrantyBenefits = getWarrantyInformation(acct, warrantyQtyMap, warrantyQtyMapSLA, PAGRecordTypeId);
                    //WarrantyBenefits.SLAHours =  getSLAHours(acct, warrantyQtyMapSLA, PAGRecordTypeId);          
                    payload.AccountId = acct.Id;
                    payload.CIMId = acct.Core_CIM_ID__c;
                    payload.LastModifiedDate = acct.LastModifiedDate;
                    payload.AccountInformation = getAccountInformation(acct, PAGRecordTypeId);
                    //--------------------------------------------------------------------------------
                    payload.AccountSpecialities = getAccountSpecialityAssociations(acct);
                    payload.AccountChannelMemberships = getAccountChannelMemberships(acct);
                    payload.AccoutBenefits = getAccoutBenefitAssociations(acct);
                    //payload.OnePartnerIDGroupMembers = (acct.RecordTypeId == PAGRecordTypeId) ? getOnePartnerIDGroupMembers(acct.Partner_Account_Group_Members__r) : getOnePartnerIDGroupMembers(acct.Partner_Account_Group_Members1__r) ;
                    payload.OnePartnerIDGroupMembers = (acct.RecordTypeId == PAGRecordTypeId) ? getOnePartnerIDGroupMembers(acct.Partner_Account_Group_Members__r) : new List<PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember>() ;
                    
                    //--------------------------------------------------------------------------------
                    tags = acct.Id+';'+acct.Name;
                    outboundMsgs.add(createAndGetOBM(ACCOUNT_MESSAGE_TYPE, JSON.serialize(payload) , tags));
                    acct.PRM_IPA_Integration_Status__c = 'Successful';
                    accountsToBeUpdated.add(acct);
                }
                system.debug('outboundMsgs size ==>'+outboundMsgs.size());
                if(outboundMsgs.size() > 0){
                    insert outboundMsgs;
                    //update accountsToBeUpdated;
                    List<Database.SaveResult> list_save=Database.Update(accountsToBeUpdated, FALSE);
                    for (Database.SaveResult sr: list_save) {
                        if (!sr.isSuccess()) {
                            String errorMsg = 'Id - '+sr.getId();
                            for (Database.Error err: sr.getErrors()) {
                                errorMsg = errorMsg +' **** '+ err.getStatusCode()+'- '+err.getMessage()+ 'Fields- '+err.getFields();                               
                            }
                            System.debug(LoggingLevel.Error, errorMsg);
                        }
                    }
                    //system.debug(outboundMsgs.size() +' accounts updated');
                    for(Core_Integration_Outbound_Message__c OBM : outboundMsgs ){
                        system.debug('OBM Id ==>'+OBM.Id);
                     }
                }                
            } 
        }
    }   
    /*
private static Integer getSLAHours(Account acct, Map<String,Integer> warrantyQtyMap, Id PAGRecordTypeId){  
PRM_SalesCloud_Integration_Model.WarrantyBenefit warrantyBenefit = new PRM_SalesCloud_Integration_Model.WarrantyBenefit();
for(PRM_AccountBenefitAssociation__c acctBenefitAssoc : acct.AccountBenefitAssociations__r){  
String benefitCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c.toUpperCase();
if(warrantyQtyMap.containsKey(benefitCode)){
warrantyBenefit.SLAHours = warrantyQtyMap.get(benefitCode);
break;
}
}        
return warrantyBenefit;
}
    
    private static PRM_SalesCloud_Integration_Model.WarrantyBenefit getWarrantyInformation(Account acct, Map<String,Integer> warrantyQtyMap, Map<String,Integer> warrantyQtyMapSLA, Id PAGRecordTypeId){   
        
        PRM_SalesCloud_Integration_Model.WarrantyBenefit warrantyBenefit = new PRM_SalesCloud_Integration_Model.WarrantyBenefit();
        List<String> benifitCodeList = new List<String>();
        //List<String> configTierCodes = new List<String>{'GOLD', 'TITANIUM'};
        List<String> configTierCodes = Label.PRM_SalesCloud_TierCodes.split(',');
        
        Integer awrCount = 0;
        Integer swrCount = 0;
        //String tierCode = acct.Channel_Memberships1__r[0].PRM_Channel_Program_Level_Id__r.Name.toUpperCase();
        
        warrantyBenefit.SLAHours = 0;
        for(PRM_AccountBenefitAssociation__c acctBenefitAssoc : acct.AccountBenefitAssociations__r){  
            String benefitCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c.toUpperCase();
            //system.debug('SLA BenefitCode ==>'+benefitCode);
            if(warrantyQtyMapSLA.containsKey(benefitCode)){
                system.debug('SLA BenefitCode Value ==>'+warrantyQtyMapSLA.get(benefitCode));
                warrantyBenefit.SLAHours = warrantyQtyMapSLA.get(benefitCode);
                break;
            }
        }  
        if(!String.isEmpty(acct.Core_IPA_Badge_Tier__c)){
            system.debug('acct.Core_IPA_Badge_Tier__c ==>'+acct.Core_IPA_Badge_Tier__c);
            set<String> badgeTierPartnerRoleKeys = new Set<String>();
            for(PRM_AccountChannelMembership__c acm : acct.Channel_Memberships1__r) {
                String tierCode = acm.PRM_Channel_Program_Level_Id__r.Name;
                if(!String.isEmpty(tierCode) && configTierCodes.contains(tierCode.toUpperCase()) && tierCode == acct.Core_IPA_Badge_Tier__c ){
                    badgeTierPartnerRoleKeys.add(acm.PRM_Partner_Role__c+'~~'+tierCode);                    
                    //awrCount = warrantyQtyMap.containsKey('AWR~~'+acm.PRM_Partner_Role__c+'~~'+tierCode) ? warrantyQtyMap.get('AWR~~'+acm.PRM_Partner_Role__c+'~~'+tierCode) : 0;
                }
            }
            system.debug('badgeTierPartnerRoleKeys ==>'+badgeTierPartnerRoleKeys);
            
            for(PRM_AccountBenefitAssociation__c acctBenefitAssoc : acct.AccountBenefitAssociations__r){
                String benefitCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c;
                if(benefitCode == 'BFTAWR'){
                    for(String key: badgeTierPartnerRoleKeys){
                        system.debug('AWR Key ==>'+benefitCode+'~~'+key);
                        if(awrCount==0){
                            awrCount = warrantyQtyMap.containsKey(benefitCode+'~~'+key) ? warrantyQtyMap.get(benefitCode+'~~'+key) : 0;
                        }                        
                    }
                }else if(benefitCode == 'SWR'){
                    for(String key: badgeTierPartnerRoleKeys){
                        system.debug('SWR Key ==>'+benefitCode+'~~'+key);
                        if(swrCount==0){
                            swrCount = warrantyQtyMap.containsKey(benefitCode+'~~'+key) ? warrantyQtyMap.get(benefitCode+'~~'+key) : 0;
                        }                        
                    }
                }
            }
        }
        
        /**** commented out as we are fetching the quantity from Benefit matrix
if(acct.Channel_Memberships1__r.size() > 0 && configTierCodes.contains(tierCode)){
Integer quantity = 0;

for(PRM_AccountBenefitAssociation__c acctBenefitAssoc : acct.AccountBenefitAssociations__r){
String benefitCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c;
//quantity = String.isEmpty(String.valueOf(acctBenefitAssoc.PRM_Quantity__c))? 0 : (Integer) acctBenefitAssoc.PRM_Quantity__c ;
if(benefitCode == 'AWR'){
if(quantity > awrCount){
awrCount = quantity;
}
//warrantyBenefit.AWRQuantity = String.isEmpty(String.valueOf(acctBenefitAssoc.PRM_Quantity__c))? 0 : (Integer) acctBenefitAssoc.PRM_Quantity__c ;
}else if(benefitCode == 'SWR'){
if(quantity > swrCount){
swrCount = quantity;
}
//warrantyBenefit.SWRQuantity = String.isEmpty(String.valueOf(acctBenefitAssoc.PRM_Quantity__c))? 0 : (Integer) acctBenefitAssoc.PRM_Quantity__c ;
}
}  
}

        warrantyBenefit.AWRQuantity = awrCount;
        warrantyBenefit.SWRQuantity = swrCount;
        //-------------revisit later
        //if(acct.RecordTypeId != PAGRecordTypeId){
        // warrantyBenefit.AWRQuantity = 0;
        //}
        return warrantyBenefit;
    }
    
    private static PRM_SalesCloud_Integration_Model.AccountInformation getAccountInformation(Account acct, Id PAGRecordTypeId){
        PRM_SalesCloud_Integration_Model.AccountInformation acctInfo = new PRM_SalesCloud_Integration_Model.AccountInformation();       
        acctInfo.Name = acct.Name;
        acctInfo.AccountNo = acct.AccountNumber;
        acctInfo.PrimeAccountName = acct.Core_Prime_Account_Name__c;
        acctInfo.SalesGroup = acct.Core_Sales_Groups__c;
        acctInfo.Industry = acct.Industry;
        acctInfo.CoveredAccount = acct.Core_Covered_Account__c;
        acctInfo.CNDANumber = acct.Core_CNDA_Number__c;
        acctInfo.BusinessPartnerId = acct.Core_Business_Partner_Id__c;
        acctInfo.BusinessId = acct.Core_Business_ID__c;
        acctInfo.BizOrgType = acct.Core_Account_Type__c;
        acctInfo.PartnerRole = acct.Core_IPA_Partner_Role__c;        
        acctInfo.Region = acct.Core_Geo__c;
        acctInfo.SubRegion = acct.Core_Sub_Geo__c;
        acctInfo.UserDefinedPhoneNumber = acct.Core_User_Defined_Phone_Number__c;
        acctInfo.UserDefinedWebsite = acct.Core_User_Defined_Website__c;        
        acctInfo.EnglishNameOnly = acct.Core_English_Only_Name__c;        
        acctInfo.PartnerProgramSegment = acct.Core_IPA_Partner_Segment__c; 
        acctInfo.AccountLegalName = acct.Core_Account_Legal_Name__c;
        acctInfo.AccountBUFocus = acct.Core_Account_BU_Focus__c;       
        acctInfo.RecordType = acct.RecordType.Name;        
        acctInfo.IsIPA = acct.Core_Intel_Partner_Alliance_PartnerGroup__c;
        acctInfo.AccountOwner = new PRM_SalesCloud_Integration_Model.RecordOwner(acct.Owner.Email, acct.Owner.FirstName, acct.Owner.LastName);
        acctInfo.BadgeTier = acct.Core_IPA_Badge_Tier__c;
        
        if(acct.RecordTypeId != PAGRecordTypeId && acct.Partner_Account_Group_Members1__r.size() > 0 ) {
            //system.debug('Parent Account ==>'+acct.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__r.Name);
            //acctInfo.OnePartnerIdAccountName = acct.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__r.Name;
            acctInfo.PAGAccountId = acct.Partner_Account_Group_Members1__r[0].Core_Partner_Account_Id__c;
        }        
        acctInfo.address = new PRM_SalesCloud_Integration_Model.AccountAddress();
        acctInfo.address.PrimaryAddress = getAccountPrimaryAddress(acct);   
        acctInfo.address.SecondaryAddress = getAccountSecondaryAddress(acct);
        acctInfo.WhitelistedDomains = getWhiteListedDomains(acct);
        acctInfo.PartnerAssist = getPartnerAssist(acct);
        
        return acctInfo; 
    }
    
    // Partner Assist and WhiteListed domain Method  
    private static List<PRM_SalesCloud_Integration_Model.PartnerAssist> getPartnerAssist(Account acct){
        List<PRM_SalesCloud_Integration_Model.PartnerAssist> PartnerAssist = new List<PRM_SalesCloud_Integration_Model.PartnerAssist>();
        for(PRM_Partner_Assist_Consent__c partnerConsent : acct.Partner_Assist_Consent__r) {
            PRM_SalesCloud_Integration_Model.PartnerAssist pa = new PRM_SalesCloud_Integration_Model.PartnerAssist();          
            pa.DistributorName = partnerConsent.PRM_Distributor_Id__r.Name;
            pa.choice = partnerConsent.PRM_Choice_Nm__c;
            pa.ConsentProvidedBy = partnerConsent.PRM_Consent_Provided_By_Id__r.Name;
            pa.ConsentProvidedDate = partnerConsent.PRM_Consent_Provided_Date_Dt__c;
            pa.StartDate = partnerConsent.PRM_Start_Date_Dt__c;
            pa.EndDate = partnerConsent.PRM_End_Date_Dt__c;
            pa.ConsentProvidedIndicator = partnerConsent.PRM_Consent_Provided_Ind__c;
            PartnerAssist.add(pa);
        }
        System.debug('PartnerAssist'+PartnerAssist);
        return PartnerAssist;
    }
    private static List<PRM_SalesCloud_Integration_Model.WhiteListedDomain> getWhiteListedDomains(Account acct){
        List<PRM_SalesCloud_Integration_Model.WhiteListedDomain> WhiteListedDomains = new List<PRM_SalesCloud_Integration_Model.WhiteListedDomain>();
        for(Core_Account_Whitelisted_Domains__c whiteListedDomain : acct.Account_Whitelisted_Domains__r) {
            PRM_SalesCloud_Integration_Model.WhiteListedDomain wDomain = new PRM_SalesCloud_Integration_Model.WhiteListedDomain();
            wDomain.DomainName = whiteListedDomain.Name;
            wDomain.PartnerProgramName = whiteListedDomain.Partner_Program__r.name;
            wDomain.EndDate = whiteListedDomain.Effective_End_Date_Time__c;
            wDomain.IsInactive = whiteListedDomain.Inactive_Indicator__c;
            WhiteListedDomains.add(wDomain);
        }
        System.debug('WhiteListedDomain'+WhiteListedDomains);
        return WhiteListedDomains;
    }
    
    // End Partner and WhiteListed Domain
    private Static PRM_SalesCloud_Integration_Model.Address getAccountPrimaryAddress(Account acct){
        PRM_SalesCloud_Integration_Model.Address primaryAddress = new PRM_SalesCloud_Integration_Model.Address();
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
            primaryAddress.PostalCode = acct.BillingPostalCode;   
            return primaryAddress;
        }else{
            return null;
        }
    }
    
    private Static PRM_SalesCloud_Integration_Model.Address getAccountSecondaryAddress(Account acct){       
        boolean isAddressEmpty = false;
        PRM_SalesCloud_Integration_Model.Address secondaryAddress = new PRM_SalesCloud_Integration_Model.Address();
        isAddressEmpty = (String.isEmpty(acct.ShippingStreet) && String.isEmpty(acct.Shippingcity) && String.isEmpty(acct.ShippingState) && String.isEmpty(acct.ShippingCountry) && String.isEmpty(acct.ShippingPostalCode) ) ? true: false;
        if(!isAddressEmpty){
            secondaryAddress.Street = acct.ShippingStreet;
            secondaryAddress.City = acct.Shippingcity;
            secondaryAddress.State = acct.ShippingState;
            secondaryAddress.StateCode = acct.ShippingStateCode;
            secondaryAddress.Country = acct.ShippingCountry;
            secondaryAddress.CountryCode = acct.ShippingCountryCode;
            secondaryAddress.PostalCode = acct.ShippingPostalCode;
            return secondaryAddress;
        }else{
            return null;
        }
    }
    
    //-----------------------------------------------------------------------------------------------------------------------------       
    private static List<PRM_SalesCloud_Integration_Model.AccountSpecialityAssociation> getAccountSpecialityAssociations(Account acct){
        List<PRM_SalesCloud_Integration_Model.AccountSpecialityAssociation> asas = new List<PRM_SalesCloud_Integration_Model.AccountSpecialityAssociation>();
        for(PRM_Account_Specialty_Association__c acctSpecialityAssoc : acct.Account_Specialty_Associations__r){
            PRM_SalesCloud_Integration_Model.AccountSpecialityAssociation asa = new PRM_SalesCloud_Integration_Model.AccountSpecialityAssociation();            
            asa.Name = acctSpecialityAssoc.Name;
            //asa.SalescloudId = acctSpecialityAssoc.Id;
            asa.IsInactive = acctSpecialityAssoc.PRM_InActive_Ind__c;            
            //asa.SpecialityId = acctSpecialityAssoc.PRM_Specialty_Id__c;
            asa.SpecialityName = acctSpecialityAssoc.PRM_Specialty_Id__r.Name;
            asa.SpecialityType = acctSpecialityAssoc.PRM_Specialty_Type__c;
            asa.SpecialityRole = (String.isEmpty(acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Role_Nm__c))?null: ((String) acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Role_Nm__c).replace('<br>', ',');
            asa.SpecialityTier = (String.isEmpty(acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Tier_Nm__c))?null: ((String) acctSpecialityAssoc.PRM_Specialty_Id__r.PRM_Tier_Nm__c).replace('<br>', ',');
            asa.StartDateUtc = acctSpecialityAssoc.PRM_Start_Date_Dt__c;
            asas.add(asa);
        }
        return asas;
    }
    
    private static List<PRM_SalesCloud_Integration_Model.AccountChannelMembership> getAccountChannelMemberships(Account acct){
        List<PRM_SalesCloud_Integration_Model.AccountChannelMembership> acms = new List<PRM_SalesCloud_Integration_Model.AccountChannelMembership>();
        for(PRM_AccountChannelMembership__c channelMembership: acct.Channel_Memberships1__r ){
            PRM_SalesCloud_Integration_Model.AccountChannelMembership acm = new PRM_SalesCloud_Integration_Model.AccountChannelMembership();
            acm.PartnerProgramName = channelMembership.PRM_Channel_Program_Id__r.Name;
            acm.PartnerProgramCode = channelMembership.PRM_Channel_Program_Id__r.PRM_programCode__c;
            acm.PartnerTier = channelMembership.PRM_Channel_Program_Level_Id__r.Name;            
            acm.PartnerRole = (String.isEmpty(channelMembership.PRM_Partner_Role__c))?null:((String) channelMembership.PRM_Partner_Role__c).replace('<br>',',');
            acm.Status = channelMembership.PRM_Status_Nm__c;
            //acm.AccountChannelMembershipId = channelMembership.Id;
            //acm.AccountId = acct.Id;
            acm.StatusChangeDateUtc = channelMembership.PRM_Status_Change_Dt__c;
            acms.add(acm);
        } 
        return acms;
    }
    
    /*private static List<PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember> getOnePartnerIDGroupMembers(List<Core_Account_Group_Member__c> onePartnerGMs){
List<PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember> opidms = new List<PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember>();
for(Core_Account_Group_Member__c onePartnerGM: onePartnerGMs){
PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember opidm = new PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember();
opidm.OnePartnerGroupMemberName = onePartnerGM.Name;
opidm.IntelAccountId = onePartnerGM.Core_Intel_Account_Id__c;
opidm.IntelAccountName = onePartnerGM.Core_Intel_Account_Id__r.Name;
opidm.OnePartnerAccountId = onePartnerGM.Core_Partner_Account_Id__c;
opidm.OnePartnerAccountName = onePartnerGM.Core_Partner_Account_Id__r.Name;
opidm.isInactive = onePartnerGM.Core_Inactive_Ind__c;
opidm.MDAIndicator = onePartnerGM.Core_MDA_Ind__c;
opidm.CIMId = onePartnerGM.Core_Intel_Account_Id__r.Core_CIM_ID__c;
opidms.add(opidm);            
}
return opidms;
}
    
    private static List<PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember> getOnePartnerIDGroupMembers(List<Core_Account_Group_Member__c> onePartnerGMs){
        List<PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember> opidms = new List<PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember>();
        for(Core_Account_Group_Member__c onePartnerGM: onePartnerGMs){
            PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember opidm = new PRM_SalesCloud_Integration_Model.OnePartnerIDGroupMember();
            //opidm.OnePartnerGroupMemberName = onePartnerGM.Name;
            opidm.AccountId = onePartnerGM.Core_Intel_Account_Id__c;
            //opidm.IntelAccountName = onePartnerGM.Core_Intel_Account_Id__r.Name;
            //opidm.AccountId = onePartnerGM.Core_Partner_Account_Id__c;
            //opidm.OnePartnerAccountName = onePartnerGM.Core_Partner_Account_Id__r.Name;
            opidm.isInactive = onePartnerGM.Core_Inactive_Ind__c;
            //opidm.MDAIndicator = onePartnerGM.Core_MDA_Ind__c;
            opidm.CIMId = onePartnerGM.Core_Intel_Account_Id__r.Core_CIM_ID__c;
            opidms.add(opidm);            
        }
        return opidms;
    }
    
    private static List<PRM_SalesCloud_Integration_Model.AccoutBenefitAssociation> getAccoutBenefitAssociations(Account acct){
        
        List<PRM_SalesCloud_Integration_Model.AccoutBenefitAssociation> abas = new List<PRM_SalesCloud_Integration_Model.AccoutBenefitAssociation>();
        for(PRM_AccountBenefitAssociation__c acctBenefitAssoc : acct.AccountBenefitAssociations__r){
            PRM_SalesCloud_Integration_Model.AccoutBenefitAssociation aba = new PRM_SalesCloud_Integration_Model.AccoutBenefitAssociation();
            aba.BenefitName = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.Name;
            aba.BenefitCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c;
            aba.BenefitType = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Benefit_Type_Nm__c;
            aba.PartnerProgamName = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.Name;
            aba.PartnerProgamCode = acctBenefitAssoc.PRM_Partner_Benefit_Id__r.PRM_Channel_Program_Id__r.PRM_programCode__c;
            aba.Status = acctBenefitAssoc.PRM_Status_Nm__c;
            abas.add(aba);
        }
        return abas;
    }
    //-----------------------------------------------------------------------------------------------------------------------------
    public static void GenerateContactOBM(Set<Id> contactIds){
        Map<Id,Account> accountsMap = new Map<Id,Account>();
        Set<Id> accountIdSet = new Set<Id>();
        List<Contact> contactsToBeUpdated=new List<Contact>();
        
        List<Contact> conts = [SELECT id,Salutation,Name,FirstName,LastName,AccountId,Account.Name,Account.Core_CIM_ID__c, Title,Core_IPA_Contact_Segment__c,Core_Preferred_Language__c,Core_Preferred_Communication__c,Phone,Fax,MobilePhone,Email,
                               Core_IPA_PartnerRole__c,Core_IPS_Region__c,Core_IPS_Sub_Region__c,Core_Login_Id__c,Core_Local_First_Name__c,Core_Local_Last_Name__c,Core_Do_Not_Contact__c,
                               Core_English_Only_First_Name__c,Core_English_Only_Last_Name__c,Core_Job_Function__c,Core_Job_Function_Code__c,Core_IPA_Email_Verification_Date__c,Core_eRPM_Person_Id__c,Core_Enterprise_Id__c,                         
                               MailingStreet,MailingCity,MailingState,MailingStateCode,MailingCountry,MailingCountryCode,MailingPostalCode,LastModifiedDate,  
                               PRM_Wechat_Union_Id__c,Core_IPA_Partner_Community__c,//PRM_Registration_Source_txt__c,PRM_Wechat_Open_Id__c,PRM_Wechat_Union_Id__c, PRM_Registration_Source_txt__c,
                               // Account Contact Relationships
                               (SELECT Id,PRM_Status_Nm__c,PRM_Contact_Id__c,PRM_Relationship_Id__c,PRM_Relationship_Id__r.Name,PRM_Account_Id__r.Name,PRM_Partner_Role__c,PRM_InActive_Ind__c FROM Account_Contact_Relationships__r),
                               // Contact Subscriptions
                               (SELECT PRM_Partner_Subscription_Id__r.Name,PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c,PRM_Status_Nm__c FROM Contact_Subscription_Associations__r),
                               //Contact Entitlements
                               (SELECT Core_Entitlement_Id__r.Name,Core_Type__c,Core_Status__c,Core_Selected__c,Core_Status_Change_Date_Time__c FROM Contact_Entitlements__r)
                               FROM Contact WHERE id IN :contactIds];
        
        
        if(conts.size() > 0){ 
            Map<String,String> pRoleLabelValueMap = new Map<String,String>();
            List<Schema.PicklistEntry> pickListValues = Contact.Core_IPA_PartnerRole__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry v : pickListValues) {
                pRoleLabelValueMap.put(v.getValue(), v.getLabel());                
            }
            List<Core_Integration_Outbound_Message__c> outboundMsgs = new List<Core_Integration_Outbound_Message__c>();
            for(Contact con: conts){
                accountIdSet.add(con.AccountId);
            }        
            //To fetch Account with Account Id in Contact        
            if(!accountIdSet.isEmpty()){
                accountsMap = new Map<Id, Account>([SELECT name,Core_Sales_Groups__c,Industry,Core_Account_Type__c,Core_IPA_Partner_Role__c,                               
                                                    BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,BillingCountryCode,BillingPostalCode FROM Account WHERE Id IN :accountIdSet]);
            }
            
            for(Contact cont: conts){
                String tags = '';
                PRM_SalesCloud_Integration_Model.ContactPayload payload = new PRM_SalesCloud_Integration_Model.ContactPayload();
                payload.AccountId = cont.AccountId;
                payload.MessageType = CONTACT_MESSAGE_TYPE; // Adding contact message type to the payload
                payload.ContactId = cont.Id;
                payload.CIMID = cont.Account.Core_CIM_ID__c;
                //payload.ContactBasicProfile = new PRM_SalesCloud_Integration_Model.ContactBasicProfile();         
                payload.ContactBasicInformation = getContactBasicDetails(cont,pRoleLabelValueMap);
                payload.ContactEntitlements = getContactEntitlements(cont);
                payload.ContactSubscriptions = getContactSubscriptions(cont);
                payload.AccountContactRelationships = getAccountContactRelationships(cont);
                payload.LastModifiedDate = cont.LastModifiedDate;
                //Updated for US612331 (As an IPA admin I would like Contact to Contact integration to be established for all related contact attributes that are synced from Sales cloud to service cloud.)
                if(accountsMap.containsKey(cont.AccountId)){              
                    //payload.ContactBasicProfile.AccountInformation = getContactAccountInformation(accountsMap.get(cont.AccountId));
                }
                //Updated for US612331 (As an IPA admin I would like Contact to Contact integration to be established for all related contact attributes that are synced from Sales cloud to service cloud.)
                tags = cont.Id+';'+cont.Email+';'+cont.Name;
                System.debug('cont.Id+cont.Name'+cont.Id+','+cont.Name);
                outboundMsgs.add(createAndGetOBM(CONTACT_MESSAGE_TYPE, JSON.serialize(payload) , tags));
                cont.PRM_IPA_Integration_Status__c = 'Successful';
                contactsToBeUpdated.add(cont);
            }   
            System.debug('outboundMsgs.size()'+outboundMsgs.size());
            if(outboundMsgs.size() > 0){
                insert outboundMsgs;
                //update contactsToBeUpdated;
                List<Database.SaveResult> list_save=Database.Update(contactsToBeUpdated, FALSE);
                for (Database.SaveResult sr: list_save) {
                    if (!sr.isSuccess()) {
                        String errorMsg = 'Id - '+sr.getId();
                        for (Database.Error err: sr.getErrors()) {
                            errorMsg = errorMsg +' **** '+ err.getStatusCode()+'- '+err.getMessage()+ 'Fields- '+err.getFields();                               
                        }
                        System.debug(LoggingLevel.Error, errorMsg);
                    }
                }
                system.debug(outboundMsgs.size() +' contacts updated');
                //for(Core_Integration_Outbound_Message__c OBM : outboundMsgs ){
                //    system.debug('OBM Id ==>'+OBM.Id);
                //}
            }                
        }
    }    
    private static PRM_SalesCloud_Integration_Model.ContactBasicInformation getContactBasicDetails(Contact cont, Map<String,String> pRoleLabelValueMap){
        //ContactBasicProfileWrapper ContactProfile
        PRM_SalesCloud_Integration_Model.ContactBasicInformation ContactDetails = new PRM_SalesCloud_Integration_Model.ContactBasicInformation();
        ContactDetails.AccountName = cont.Account.Name;
        //ContactDetails.Title = cont.Title;
        //updated as part of
        ContactDetails.Title = cont.Salutation;        
        ContactDetails.FullName = cont.Name;
        ContactDetails.FirstName = cont.FirstName;
        ContactDetails.LastName = cont.LastName;
        ContactDetails.LocalFirstName = cont.Core_Local_First_Name__c;
        ContactDetails.LocalLastName = cont.Core_Local_Last_Name__c;
        ContactDetails.EnglishFirstName = cont.Core_English_Only_First_Name__c;
        ContactDetails.EnglishLastName = cont.Core_English_Only_Last_Name__c;
        ContactDetails.EmailVerificationDate = cont.Core_IPA_Email_Verification_Date__c;
        ContactDetails.JobFunction = cont.Core_Job_Function__c;
        ContactDetails.JobFunctionCode = cont.Core_Job_Function_Code__c;
        ContactDetails.Phone = cont.phone;
        ContactDetails.Fax = cont.Fax;
        ContactDetails.Mobile = cont.MobilePhone;
        ContactDetails.Email = cont.email;
        ContactDetails.PreferredCommunication = cont.Core_Preferred_Communication__c;
        ContactDetails.PreferredLanguage = cont.Core_Preferred_Language__c;
        ContactDetails.PartnerRole = cont.Core_IPA_PartnerRole__c;
        ContactDetails.PartnerRoleLabel = String.isEmpty(cont.Core_IPA_PartnerRole__c)?null:(pRoleLabelValueMap.containsKey(cont.Core_IPA_PartnerRole__c)?pRoleLabelValueMap.get(cont.Core_IPA_PartnerRole__c):cont.Core_IPA_PartnerRole__c);
        ContactDetails.Segment = cont.Core_IPA_Contact_Segment__c;
        ContactDetails.Loginid = cont.Core_Login_Id__c;
        ContactDetails.eRPMPersonId = cont.Core_eRPM_Person_Id__c;
        ContactDetails.EnterpriseId = cont.Core_Enterprise_Id__c;
        ContactDetails.Region = cont.Core_IPS_Region__c;
        ContactDetails.SubRegion = cont.Core_IPS_Sub_Region__c;
        ContactDetails.DNC = cont.Core_Do_Not_Contact__c;
        ContactDetails.Communities = cont.Core_IPA_Partner_Community__c; // Rohit
        ContactDetails.MailingAddress = getContactMailingAddress(cont);
        //ContactDetails.WeChatUnionId = String.IsEmpty(cont.PRM_Wechat_Union_Id__c) ? null :EncryptDecryptHelper.EncryptData(cont.PRM_Wechat_Union_Id__c);
        ContactDetails.WeChatUnionId = cont.PRM_Wechat_Union_Id__c;
        //ContactDetails.RegistrationSource = cont.PRM_Registration_Source_txt__c;
        //-----------------------------We chat-----------------------------
        /*
ContactDetails.WechatOpenId = cont.PRM_Wechat_Open_Id__c;
ContactDetails.WechatUnionId = cont.PRM_Wechat_Union_Id__c;
ContactDetails.RegistrationSource = cont.PRM_Registration_Source_txt__c;

        //-----------------------------We chat-----------------------------
        
        //Updated for US604638 (As an IPA admin I would like Contact to Contact integration to be established for all core contact attributes that are synced from Sales cloud to service cloud.)
        
        return ContactDetails;
    }
    private static PRM_SalesCloud_Integration_Model.Address getContactMailingAddress(Contact cont){
        PRM_SalesCloud_Integration_Model.Address mailingAddr = new PRM_SalesCloud_Integration_Model.Address();
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
            mailingAddr.PostalCode = cont.MailingPostalCode; 
            return mailingAddr;
        }else{
            return null;
        }      
        
    }
    private static List<PRM_SalesCloud_Integration_Model.AccountContactRelationship> getAccountContactRelationships(Contact cont){ 
        List<PRM_SalesCloud_Integration_Model.AccountContactRelationship> acrs = new List<PRM_SalesCloud_Integration_Model.AccountContactRelationship>();
        for(PRM_Account_Contact_Relationship__c acr: cont.Account_Contact_Relationships__r){
            PRM_SalesCloud_Integration_Model.AccountContactRelationship accContRel = new PRM_SalesCloud_Integration_Model.AccountContactRelationship();
            //accContRel.AccountName=acr.PRM_Account_Id__r.Name;            
            accContRel.Relationship=acr.PRM_Relationship_Id__r.Name;
            accContRel.InactiveIndicator=acr.PRM_InActive_Ind__c;  
            accContRel.Status = acr.PRM_Status_Nm__c;   
            //accContRel.PartnerRole= String.isEmpty(acr.PRM_Partner_Role__c)?null: ((String) acr.PRM_Partner_Role__c).replace('<br>',';');
            String PartnerRoles= String.isEmpty(acr.PRM_Partner_Role__c)?null: ((String) acr.PRM_Partner_Role__c).replace('<br>',';');
            if(PartnerRoles!=null && (PartnerRoles.length()-PartnerRoles.lastIndexOf(';'))==1){
                PartnerRoles = PartnerRoles.left(PartnerRoles.lastIndexOf(';'));
            }
            accContRel.PartnerRole = PartnerRoles;  
            //accContRel.ContactInfo = new PRM_SalesCloud_Integration_Model.ACRContact(cont.Email, cont.FirstName, cont.LastName, cont.Core_Login_Id__c, cont.Core_eRPM_Person_Id__c);
            acrs.add(accContRel);
        }
        return acrs;      
    }
    private static List<PRM_SalesCloud_Integration_Model.ContactEntitlement> getContactEntitlements(Contact cont){
        
        List<PRM_SalesCloud_Integration_Model.ContactEntitlement> ContactEntitlements = new List<PRM_SalesCloud_Integration_Model.ContactEntitlement>();
        for(Core_Contact_Entitlement__c ce: cont.Contact_Entitlements__r){
            PRM_SalesCloud_Integration_Model.ContactEntitlement ContEntitlement = new PRM_SalesCloud_Integration_Model.ContactEntitlement();
            ContEntitlement.Name = ce.Core_Entitlement_Id__r.Name;
            ContEntitlement.Type = ce.Core_Type__c;
            ContEntitlement.Status = ce.Core_Status__c;
            ContEntitlement.IsSelected = ce.Core_Selected__c;
            ContEntitlement.StatusChangeDateUtc = ce.Core_Status_Change_Date_Time__c;
            ContactEntitlements.add(ContEntitlement);
        }    
        return ContactEntitlements;
    }
    private static List<PRM_SalesCloud_Integration_Model.ContactSubscription> getContactSubscriptions(Contact cont){
        
        List<PRM_SalesCloud_Integration_Model.ContactSubscription> subscriptions = new List<PRM_SalesCloud_Integration_Model.ContactSubscription>();
        for(PRM_ContactSubscriptionAssociation__c pcsa: cont.Contact_Subscription_Associations__r){
            PRM_SalesCloud_Integration_Model.ContactSubscription cs = new PRM_SalesCloud_Integration_Model.ContactSubscription();
            cs.Name = pcsa.PRM_Partner_Subscription_Id__r.Name;
            cs.Status = pcsa.PRM_Status_Nm__c;
            cs.Code = pcsa.PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c;
            subscriptions.add(cs);
        }
        return subscriptions;
    }  
    private static Core_Integration_Outbound_Message__c createAndGetOBM (String MessageType, String payload, String tags){
        Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();
        outboundMsg.Core_MessageType__c = MessageType;
        outboundMsg.Core_Payload__c ='<![CDATA[' +  payload + ']]>';
        outboundMsg.Core_Tags__c = tags == null || tags.length() <= 255 ? tags : tags.substring(0, 255);
        return outboundMsg;
    }
        //Updated for US612331 (As an IPA admin I would like Contact to Contact integration to be established for all related contact attributes that are synced from Sales cloud to service cloud.)
        /** private static PRM_SalesCloud_Integration_Model.ContactAccountInformation getContactAccountInformation(Account acct){
            PRM_SalesCloud_Integration_Model.ContactAccountInformation acctInfo = new PRM_SalesCloud_Integration_Model.ContactAccountInformation();       
        acctInfo.Name = acct.Name;
        acctInfo.SalesGroup = acct.Core_Sales_Groups__c;
        acctInfo.Industry = acct.Industry;
        acctInfo.BizOrgType = acct.Core_Account_Type__c;
        acctInfo.PartnerRole = acct.Core_IPA_Partner_Role__c;
        acctInfo.address = new PRM_SalesCloud_Integration_Model.ContactAccountAddress();
        acctInfo.address.PrimaryAddress = getAccountPrimaryAddress(acct);

        return acctInfo;
        } 
        **/
    //Updated for US612331 (As an IPA admin I would like Contact to Contact integration to be established for all related contact attributes that are synced from Sales cloud to service cloud.)
    
}