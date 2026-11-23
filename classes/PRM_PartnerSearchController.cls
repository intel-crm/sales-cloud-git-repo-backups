/******************************************************************************************************************************
Apex Class Name:  PRM_PartnerSearchController
Version     : 1.0 
Created Date: 11 June 2022
Function    : Controller for IPA lookup for partner search.
****************************************************************************************************************************************/
public without sharing class PRM_PartnerSearchController {

    //public static String ipaRefresh = System.label.PRM_IPARefresh;//IPA 2.0 
    
    /**
    *   @desc:To search for active Distributors in the specific region for IPA accounts
    *   @param: input serach string, county to be searched in, Tier to be searched for.
    *   @return: searched accounts
    **/
        @AuraEnabled
        public static List<PRM_PartnerSearchResultWrapper> getDistributors(String searchInput, String country, String tier){
            try{
            List<PRM_PartnerSearchResultWrapper> result = new  List<PRM_PartnerSearchResultWrapper>();
            //system.debug('searchInput-->'+searchInput+'\n'+'tier--->'+tier+'country-->'+country);
    
            User ur = [
                SELECT 
                    Id,
                    AccountId 
                FROM User
                WHERE Id =:UserInfo.getUserId()];
            System.debug('userId=>>>>>>'+ur);
            Account ac = [
                SELECT 
                    Id,
                    Core_Geo__c
                FROM Account 
                WHERE ID =: ur.AccountId];
            
            String userRegion = ac.Core_Geo__c;
            //System.debug('userRegion=>>>>'+userRegion);
            String tempInput = '%' + searchInput + '%';
            String query = 'SELECT'+
            ' Id,'+
            ' Name,'+
            ' Core_Geo__c,'+
            ' AccountNumber,'+
            ' toLabel(BillingCountryCode),'+
            ' BillingStreet,'+
            ' toLabel(BillingStateCode),'+
            ' BillingCountry,'+
            ' BillingPostalcode,'+
            ' toLabel(Core_IPA_Partner_Role__c),'+
            ' Core_IPA_Badge_Tier__c,'+
            ' Core_Intel_Partner_Alliance_PartnerGroup__c'+
            ' FROM Account'+
            ' WHERE (AccountNumber like:tempInput OR Name like:tempInput)'+
            ' AND (Core_IPA_Partner_Role__c EXCLUDES(\'Distributor\'))'+
            ' AND (Core_Geo__c =:userRegion)'+
            ' AND Core_Intel_Partner_Alliance_PartnerGroup__c= true'+
            ' AND Core_Deactivated__c = false';       
            //System.debug(query);
    
            if(String.isNotBlank(country) && country != System.Label.PRM_DefaultValue_Picklist){
                query+= ' AND toLabel(BillingCountryCode) =:country';
            }
            if(String.isNotBlank(tier) && tier != System.Label.PRM_DefaultValue_Picklist){
                query+= ' AND Core_IPA_Badge_Tier__c =:tier';
            }
    

            //calling
            result = processAccountAndContacts(query, searchInput, tempInput, userRegion, country, tier);
            /*Integer accountIndex =0;
            List<Account> accFirstSeachrec = new List<Account>();
            List<Account> accounts = Database.query(query);
            for(Account accRecords :accounts){

                if(accRecords.Name.equals(searchInput) || accRecords.AccountNumber == searchInput){
                    accFirstSeachrec.add(accRecords) ;
                    //system.debug('accFirstSeachrec'+accFirstSeachrec);
                    accountIndex++;
                }
            }
            accFirstSeachrec.addall(accounts);
            Set<Account> accStrings = new Set<Account>(accFirstSeachrec);
            List<Account> accounts1 = new List<Account>(accStrings);
            List<Contact> contacts1=new list<Contact>();
            if (accounts1.isEmpty()) {
              /*  List<Contact> contacts = [SELECT 
                                            Id,
                                            AccountId 
                                          FROM Contact 
                                          WHERE Email like:tempInput ];
                if(!contacts.isEmpty()){
                    String accId = contacts[0].AccountId;*/

                   
                    /*query = 'SELECT'+ 
                    ' Id,'+
                    ' Account.Name,'+
                    ' Account.AccountNumber,'+
                    ' toLabel(Account.BillingCountryCode),'+
                    ' Account.BillingStreet,'+
                    ' toLabel(Account.BillingStateCode),'+
                    ' Account.BillingState,'+
                    ' Account.BillingCountry,'+
                    ' Account.BillingPostalcode,'+
                    'toLabel(Account.Core_IPA_Partner_Role__c),'+
                    ' Account.Core_IPA_Badge_Tier__c'+ 
                    ' FROM Contact'+
                    ' WHERE Email Like: tempInput'+
                    ' AND (Account.Core_IPA_Partner_Role__c EXCLUDES(\'Distributor\'))'+
                    ' AND (Account.Core_Geo__c =:userRegion)'+
                    ' AND Account.Core_Intel_Partner_Alliance_PartnerGroup__c= true'+
                    ' AND Account.Core_Deactivated__c = false';
                    if(String.isNotBlank(country) && country != System.Label.PRM_DefaultValue_Picklist){
                        query+= ' AND toLabel(Account.BillingCountryCode) =:country';
                    }
                    if(String.isNotBlank(tier) && tier != System.Label.PRM_DefaultValue_Picklist){
                        query+= ' AND Account.Core_IPA_Badge_Tier__c =:tier';
                    }
                    contacts1 = Database.query(query);
               // }
               for(contact con: contacts1){

                PRM_PartnerSearchResultWrapper wrp = new PRM_PartnerSearchResultWrapper();
                wrp.accountId = con.account.Id;
                wrp.accountName = con.account.Name;
                wrp.accountNumber = con.account.AccountNumber;
                wrp.partnerRole = con.account.Core_IPA_Partner_Role__c;
                wrp.partnerTier = con.account.Core_IPA_Badge_Tier__c;
                wrp.billingAddress = con.account.BillingStreet;
                wrp.billingState=con.account.BillingStateCode;
                wrp.billingCountry = con.account.BillingCountryCode;
                wrp.billingZipcode = con.account.BillingPostalcode;
                result.add(wrp);
            }
            }
            else{
                for(Account acc: accounts1){

                    PRM_PartnerSearchResultWrapper wrp = new PRM_PartnerSearchResultWrapper();
                    wrp.accountId = acc.Id;
                    wrp.accountName = acc.Name;
                    wrp.accountNumber = acc.AccountNumber;
                    wrp.partnerRole = acc.Core_IPA_Partner_Role__c;
                    wrp.partnerTier = acc.Core_IPA_Badge_Tier__c;
                    wrp.billingAddress = acc.BillingStreet;
                    wrp.billingState= acc.BillingStateCode;
                    wrp.billingCountry = acc.BillingCountryCode;
                    wrp.billingZipcode = acc.BillingPostalcode;
                    result.add(wrp);
                }
            }*/
    
            
            
    
            return result;
            }catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            } 
        }


        public static List<PRM_PartnerSearchResultWrapper> processAccountAndContacts(String query, String searchInput, String tempInput, String userRegion, String country, String tier) {
            Integer accountIndex = 0;
            List<Account> accFirstSeachrec = new List<Account>();
            List<Account> accounts = Database.query(query);
        
            for (Account accRecords : accounts) {
                if (accRecords.Name.equals(searchInput) || accRecords.AccountNumber == searchInput) {
                    accFirstSeachrec.add(accRecords);
                    System.debug('accFirstSeachrec: ' + accFirstSeachrec);
                    accountIndex++;
                }
            }
        
            accFirstSeachrec.addAll(accounts);
            Set<Account> accStrings = new Set<Account>(accFirstSeachrec);
            List<Account> accounts1 = new List<Account>(accStrings);
            List<Contact> contacts1 = new List<Contact>();
            List<PRM_PartnerSearchResultWrapper> result = new List<PRM_PartnerSearchResultWrapper>();
        
            if (accounts1.isEmpty()) {
                query = 'SELECT' +
                        ' Id,' +
                        ' Account.Name,' +
                        ' Account.AccountNumber,' +
                        ' toLabel(Account.BillingCountryCode),' +
                        ' Account.BillingStreet,' +
                        ' toLabel(Account.BillingStateCode),' +
                        ' Account.BillingState,' +
                        ' Account.BillingCountry,' +
                        ' Account.BillingPostalcode,' +
                        ' toLabel(Account.Core_IPA_Partner_Role__c),' +
                        ' Account.Core_IPA_Badge_Tier__c' +
                        ' FROM Contact' +
                        ' WHERE Email LIKE :tempInput' +
                        ' AND (Account.Core_IPA_Partner_Role__c EXCLUDES (\'Distributor\'))' +
                        ' AND (Account.Core_Geo__c = :userRegion)' +
                        ' AND Account.Core_Intel_Partner_Alliance_PartnerGroup__c = true' +
                        ' AND Account.Core_Deactivated__c = false';
                            
                if (String.isNotBlank(country) && country != System.Label.PRM_DefaultValue_Picklist) {
                    query += ' AND toLabel(Account.BillingCountryCode) = :country';
                }
                if (String.isNotBlank(tier) && tier != System.Label.PRM_DefaultValue_Picklist) {
                    query += ' AND Account.Core_IPA_Badge_Tier__c = :tier';
                }
        
                contacts1 = Database.query(query);
        
                for (Contact con : contacts1) {
                    PRM_PartnerSearchResultWrapper wrp = new PRM_PartnerSearchResultWrapper();
                    wrp.accountId = con.Account.Id;
                    wrp.accountName = con.Account.Name;
                    wrp.accountNumber = con.Account.AccountNumber;
                    wrp.partnerRole = con.Account.Core_IPA_Partner_Role__c;
                    wrp.partnerTier = con.Account.Core_IPA_Badge_Tier__c;
                    wrp.billingAddress = con.Account.BillingStreet;
                    wrp.billingState = con.Account.BillingStateCode;
                    wrp.billingCountry = con.Account.BillingCountryCode;
                    wrp.billingZipcode = con.Account.BillingPostalcode;
                    result.add(wrp);
                }
            } else {
                for (Account acc : accounts1) {
                    PRM_PartnerSearchResultWrapper wrp = new PRM_PartnerSearchResultWrapper();
                    wrp.accountId = acc.Id;
                    wrp.accountName = acc.Name;
                    wrp.accountNumber = acc.AccountNumber;
                    wrp.partnerRole = acc.Core_IPA_Partner_Role__c;
                    wrp.partnerTier = acc.Core_IPA_Badge_Tier__c;
                    wrp.billingAddress = acc.BillingStreet;
                    wrp.billingState = acc.BillingStateCode;
                    wrp.billingCountry = acc.BillingCountryCode;
                    wrp.billingZipcode = acc.BillingPostalcode;
                    result.add(wrp);
                }
            }        
            return result;
        }
        
        


    /**
    *   @dsec: to get the list of countries that being searched.
    *   @param: wrapper vaialble of type PRM_PartnerSearchResultWrapper
    *   @return: List<String>  Counties.
    **/
        @AuraEnabled
        public static List<String> getCountryList(List<PRM_PartnerSearchResultWrapper> accountDetails){
            try{
                //System.debug('Account details apex=>>>>'+accountDetails);
                List<String> countries = new List<String>();
                for(PRM_PartnerSearchResultWrapper acc: accountDetails){
                    countries.add(acc.billingCountry);
                }
                System.debug('Country list apex=>>>>>>>>'+countries);
                return countries;
    
            }catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            } 
        }

    /**
    *   @dsec: to get the account details.
    *   @param: recordid of the clicked account
    *   @return: account details and fields
    **/    
    
        @AuraEnabled
        public static PRM_PartnerAccountDetailWrapper getAccountDetails(String recordId){
            try {
                Decimal trainingData = 0;
                Decimal trainingDataLoc = 0;
                Decimal sum=0;
                map<Id,Decimal> trainingCurMap=new map<Id,Decimal>();
                Account OPIDAcc;
                List<Account> account = new List<Account>();
                /*if(ipaRefresh!='TRUE'||Test.isRunningTest()){
                    account = [SELECT Id,AccountNumber,Name,Core_Geo__c,toLabel(BillingCountryCode),BillingCity,BillingPostalCode,toLabel(Core_IPA_Partner_Role__c),Core_IPA_Badge_Tier__c,BillingCountry,BillingStreet,Core_User_Defined_Website__c,Core_IPA_One_Partner_Id__c,Core_CNDA_Number__c,
                    (SELECT Id, Name FROM IPA_Affiliations__r where PRM_Builder_Strategy__r.name = 'MOA Pre-Launch Partner' and PRM_Active__c = true),
                    (Select Id,PRM_Contact_Id__r.FirstName,PRM_Contact_Id__r.LastName,PRM_Contact_Id__r.Email FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c = false AND PRM_Status_Nm__c = 'Complete' AND PRM_Relationship_Id__r.Name = 'Partner Admin'),
                    (select Id, PRM_Agreement_Sign_Dt__c, PRM_InActive_Ind__c,PRM_Account_Id__c from AccountLegalAgreementAssociations__r where PRM_InActive_Ind__c=false and PRM_Agreement_Sign_Dt__c<>null),
                    (select id,PRM_Response_Txt__c from Profile_Responses__r where PRM_Question_Display_Text__c  =: System.Label.PRM_Point_Status and PRM_Response_Txt__c!=null order by LastModifiedDate desc,CreatedDate desc,Id desc)
                    FROM Account WHERE Id=:recordId ];  
                }else{*/ //Switch Removal
                    account = [SELECT Id,AccountNumber,Name,Core_Geo__c,toLabel(BillingCountryCode),BillingCity,BillingPostalCode,toLabel(Core_IPA_Partner_Role__c),Core_IPA_Badge_Tier__c,BillingCountry,BillingStreet,Core_User_Defined_Website__c,Core_IPA_One_Partner_Id__c,Core_CNDA_Number__c,
                    (SELECT Id, Name FROM IPA_Affiliations__r where PRM_Builder_Strategy__r.name = 'MOA Pre-Launch Partner' and PRM_Active__c = true),
                    (Select Id,PRM_Contact_Id__r.FirstName,PRM_Contact_Id__r.LastName,PRM_Contact_Id__r.Email FROM Account_Contact_Relationships__r WHERE PRM_InActive_Ind__c = false AND PRM_Status_Nm__c = 'Complete' AND PRM_Relationship_Id__r.Name = 'Partner Admin'),
                    (select Id, PRM_Agreement_Sign_Dt__c, PRM_InActive_Ind__c,PRM_Account_Id__c from AccountLegalAgreementAssociations__r where PRM_InActive_Ind__c=false and PRM_Agreement_Sign_Dt__c<>null),
                    (select id,PRM_Point_Status_Txt__c, PRM_Point_Status_Dt__c,PRM_Point_Status_Reason_Txt__c FROM PRM_IPAMembership_Attributes__r)
                    FROM Account WHERE Id=:recordId ];
                //}
              
            List<AggregateResult> vexList = new List<AggregateResult>();
            List<PRM_Profile_Responses__c> profResp = new List<PRM_Profile_Responses__c>();
            List<PRM_IPAMembership_Attributes__c> ipaMemAtt = new List<PRM_IPAMembership_Attributes__c>();
            
            if(account[0].Core_IPA_One_Partner_Id__c!=null){
                OPIDAcc = [SELECT id,(SELECT Id, PRM_Partner_Benefit_Id__c FROM AccountBenefitAssociations__r where PRM_Status_Nm__c = 'Active' and PRM_Partner_Benefit_Id__r.Name = 'Developer Zone Premier Entitlement') from account where id =: account[0].Core_IPA_One_Partner_Id__c limit 1];
                /*if(ipaRefresh!='TRUE'||Test.isRunningTest()){
                    profResp =[select id,PRM_Response_Txt__c from PRM_Profile_Responses__c where PRM_Question_Display_Text__c  =: System.Label.PRM_Point_Status and PRM_Response_Txt__c!=null and PRM_Account_Id__c=:account[0].Core_IPA_One_Partner_Id__c order by LastModifiedDate desc,CreatedDate desc,Id desc];             
                }
                if(ipaRefresh =='TRUE' || Test.isRunningTest()) {*/ //Switch Removal
                    ipaMemAtt =[select id,PRM_Point_Status_Txt__c, PRM_Point_Status_Dt__c,PRM_Point_Status_Reason_Txt__c FROM PRM_IPAMembership_Attributes__c WHERE PRM_Account_Id__c =:account[0].Core_IPA_One_Partner_Id__c];
                //}
                
                
                for(PRM_Value_Exchange_Data__c vxData:[select PRM_Training_Credit_Points_Count_Nbr__c ,PRM_Account_Id__c
                                                           from PRM_Value_Exchange_Data__c 
                                                           where PRM_One_Partner_Id__c =:account[0].Core_IPA_One_Partner_Id__c 
                                                           AND PRM_TimePeriod_Nm__c =: System.Label.PRM_Current_measurement_period order by PRM_Training_Credit_Points_Count_Nbr__c]){
                        
                             trainingCurMap.put(vxData.PRM_Account_Id__c,vxData.PRM_Training_Credit_Points_Count_Nbr__c);                                                       
                    }
                    
                    for(Decimal i:trainingCurMap?.values()){
                            sum+=i;
                    } 
                trainingData=sum;
            }else{
                vexList = [select MAX(PRM_Training_Credit_Points_Count_Nbr__c) trainingDashCrediLoc from PRM_Value_Exchange_Data__c where PRM_TimePeriod_Nm__c =: System.Label.PRM_Current_measurement_period and PRM_Account_Id__c=:recordId ];
                for(AggregateResult vx: vexList){
                    trainingDataLoc =(Decimal)vx.get('trainingDashCrediLoc');
                }
            }
            
            //calling
            //createPartnerAccountDetailWrapper(account, profResp, trainingData, trainingDataLoc, OPIDAcc);

            //PRM_PartnerAccountDetailWrapper result = new PRM_PartnerAccountDetailWrapper();
            PRM_PartnerAccountDetailWrapper result = createPartnerAccountDetailWrapper(account, profResp,ipaMemAtt, trainingData, trainingDataLoc, OPIDAcc);
            result.partnerDetails = new List<PRM_PartnerAccountDetailWrapper.PartnerAdminWrapper>();
            /*result.accountName = account[0].Name;
            result.accountNumber = account[0].AccountNumber==null ? ' ' : account[0].AccountNumber ;
            result.partnerRole=account[0].Core_IPA_Partner_Role__c==null ? ' ':
                                    account[0].Core_IPA_Partner_Role__c;
            result.partnerTier=account[0].Core_IPA_Badge_Tier__c==null ? ' ':
                                    account[0].Core_IPA_Badge_Tier__c;
            result.website=account[0].Core_User_Defined_Website__c==null ? ' ':
                                    account[0].Core_User_Defined_Website__c;
            result.ipaTCAccepted= account[0].AccountLegalAgreementAssociations__r.isEmpty() ? false:true;
            result.trainingCreditCurPeriod=account[0].Core_IPA_One_Partner_Id__c!=null?(trainingData == null ? 0.0 :trainingData) :
                                           trainingDataLoc == null ? 0.0 : trainingDataLoc;
            result.pointStatus = account[0].Core_IPA_One_Partner_Id__c!=null?(profResp.isEmpty() ? 'NA':profResp[0].PRM_Response_Txt__c) :
            account[0].Profile_Responses__r.isEmpty()? 'NA':account[0].Profile_Responses__r[0].PRM_Response_Txt__c;
            result.isValidRegion = System.Label.PRM_IPALookup_All_Info_Region.split(';').contains(account[0].Core_Geo__c) ? true:false;
            result.cndaNumber = account[0].Core_CNDA_Number__c != null ? 'Yes' : 'No';
            result.affiliation = (account[0].IPA_Affiliations__r != null && !account[0].IPA_Affiliations__r.isEmpty()) ? 'Yes' : 'No';
            result.dzpBenefit = (OPIDAcc != null && OPIDAcc.AccountBenefitAssociations__r != null) ? 'Yes' : 'No';
            
                result.contacts = new List<PRM_PartnerAccountDetailWrapper.ContactDetailWrapper>();
                result.partnerDetails = new List<PRM_PartnerAccountDetailWrapper.PartnerAdminWrapper>();
    
                List<String> paAddress = new List<String>();
                paAddress.add(account[0].BillingStreet);
                paAddress.add(account[0].BillingCity);
                paAddress.add(account[0].BillingCountryCode);
                paAddress.add(account[0].BillingPostalCode);
                result.primaryAddress = paAddress;*/
     
                for(Contact con : account[0].contacts){
    
                    PRM_PartnerAccountDetailWrapper.ContactDetailWrapper contact = new PRM_PartnerAccountDetailWrapper.ContactDetailWrapper();
                    contact.firstName = con.FirstName;
                    contact.lastName = con.LastName;
                    contact.contactId = con.Id;
                    contact.email = con.Email;
                    result.contacts.add(contact);
                }
               
                for( PRM_Account_Contact_Relationship__c acr : account[0].Account_Contact_Relationships__r){
    
                    PRM_PartnerAccountDetailWrapper.PartnerAdminWrapper acrDetails = new PRM_PartnerAccountDetailWrapper.PartnerAdminWrapper();
                    acrDetails.partnerAdminId = acr.PRM_Contact_Id__r.Id ;
                    acrDetails.partnerAdminFirstName = acr.PRM_Contact_Id__r.FirstName ;
                    acrDetails.partnerAdminLastName = acr.PRM_Contact_Id__r.LastName ;
                    acrDetails.partnerAdminEmail = acr.PRM_Contact_Id__r.Email ;
                    result.partnerDetails.add(acrDetails);
                }
                return result;
    
            }catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        public static PRM_PartnerAccountDetailWrapper createPartnerAccountDetailWrapper(List<Account> account, List<PRM_Profile_Responses__c> profResp, List<PRM_IPAMembership_Attributes__c> ipaMemAtt,Decimal trainingData, Decimal trainingDataLoc, Account OPIDAcc) {
            PRM_PartnerAccountDetailWrapper result = new PRM_PartnerAccountDetailWrapper();
            
                result.accountName = account[0].Name;
                result.accountNumber = account[0].AccountNumber==null ? ' ' : account[0].AccountNumber ;
                result.partnerRole=account[0].Core_IPA_Partner_Role__c==null ? ' ':
                                        account[0].Core_IPA_Partner_Role__c;
                result.partnerTier=account[0].Core_IPA_Badge_Tier__c==null ? ' ':
                                        account[0].Core_IPA_Badge_Tier__c;
                result.website=account[0].Core_User_Defined_Website__c==null ? ' ':
                                        account[0].Core_User_Defined_Website__c;
                result.ipaTCAccepted= account[0].AccountLegalAgreementAssociations__r.isEmpty() ? false:true;
                result.trainingCreditCurPeriod=account[0].Core_IPA_One_Partner_Id__c!=null?(trainingData == null ? 0.0 :trainingData) :
                                               trainingDataLoc == null ? 0.0 : trainingDataLoc;
                /*if(ipaRefresh !='TRUE' || Test.isRunningTest()){                                               
                result.pointStatus = account[0].Core_IPA_One_Partner_Id__c!=null?(profResp.isEmpty() ? 'NA':profResp[0].PRM_Response_Txt__c) :
                account[0].Profile_Responses__r.isEmpty()? 'NA':account[0].Profile_Responses__r[0].PRM_Response_Txt__c;
                }
                if(ipaRefresh =='TRUE'|| Test.isRunningTest()){*/ //Swicth Removal
                    result.pointStatus = account[0].Core_IPA_One_Partner_Id__c!=null?(ipaMemAtt.isEmpty() ? 'NA':ipaMemAtt[0].PRM_Point_Status_Txt__c) :
                    account[0].PRM_IPAMembership_Attributes__r.isEmpty()? 'NA':account[0].PRM_IPAMembership_Attributes__r[0].PRM_Point_Status_Txt__c;
                //}
                result.isValidRegion = System.Label.PRM_IPALookup_All_Info_Region.split(';').contains(account[0].Core_Geo__c) ? true:false;
                result.cndaNumber = account[0].Core_CNDA_Number__c != null ? 'Yes' : 'No';
                result.affiliation = (account[0].IPA_Affiliations__r != null && !account[0].IPA_Affiliations__r.isEmpty()) ? 'Yes' : 'No';
                result.dzpBenefit = (OPIDAcc != null && OPIDAcc.AccountBenefitAssociations__r != null) ? 'Yes' : 'No';
                
            result.contacts = new List<PRM_PartnerAccountDetailWrapper.ContactDetailWrapper>();
            //result.partnerDetails = new List<PRM_PartnerAccountDetailWrapper.PartnerAdminWrapper>();
    
            List<String> paAddress = new List<String>();
                    paAddress.add(account[0].BillingStreet);
                    paAddress.add(account[0].BillingCity);
                    paAddress.add(account[0].BillingCountryCode);
                    paAddress.add(account[0].BillingPostalCode);
                    result.primaryAddress = paAddress;
    
            return result;
        }

    /**
    *   @dsec: To check if the user navigating to the Partner Search Page is Authorized or not.
    *   @return: return boolean value based on user is authorized or not
    **/    
    
        @AuraEnabled
        public static PRM_PartnerAccountDetailWrapper getAuth(){
            try{
    
                PRM_PartnerAccountDetailWrapper authResult = new PRM_PartnerAccountDetailWrapper();
                List<contact> conEmail=[SELECT 
                                            Id 
                                        FROM contact 
                                        WHERE Core_IPA_PartnerRole__c ='Distributor' 
                                        AND account.Core_Geo__c IN :System.Label.PRM_IPALookup_Region_Check.split(';') 
                                        AND email=:UserInfo.getUserEmail()];
    
                // converted to ternary operation 
                authResult.isAuthorised = conEmail.isEmpty() ? false : true;
                return authResult;
    
            }catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    }