// This class will be used for handling business logic of partner assist
public without sharing class PRM_Partner_Assist_Utility {
    //Method to return the Partner Assist for Terms and Conditions
    @AuraEnabled (cacheable=true)
    Public static PartnerAssitTextWrapper fetchFormText(){
        String userLanguage ='ENG';
        String tempUpperText = '';
        String tempLowerText = '';

        //New Attributes for access 
        Boolean isIpaAccount = false;
        Boolean isDesiredRole = True;
        Boolean isEntitlmentCorrect = false;
        String  userRole = '';
        list<Core_Contact_Entitlement__c> lstOfConEnt = new list<Core_Contact_Entitlement__c>();
        list<PRM_Partner_Assist_Consent__c> lstOfPartnerAssitConsent = new list<PRM_Partner_Assist_Consent__c>(); 
        list<PRM_Partner_Terms_and_Conditions__c> lstOfPartnerTermsAndCondition = new list<PRM_Partner_Terms_and_Conditions__c>(); 
        Boolean displayTempFirstErrorMssg = true;
        Boolean displayTempSecondErrorMssg = false;

        Id accountId=[SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()].AccountId;
        Id contactId = [Select contactid from User where id =: Userinfo.getUserid()].contactId;
        
        if(accountId != null){
        lstOfPartnerAssitConsent = [select id,PRM_Account_Id__c,PRM_Consent_Provided_Ind__c,PRM_InActive_Ind__c from PRM_Partner_Assist_Consent__c where PRM_Account_Id__c =:accountId AND PRM_Consent_Provided_Ind__c =True AND PRM_InActive_Ind__c = false];
        }

        if(lstOfPartnerAssitConsent != null && !lstOfPartnerAssitConsent.isEmpty()){
            displayTempSecondErrorMssg = true;
        }

        if(contactId != null){
        for(Contact conObj:[select id,name,Core_Preferred_Language__c,Core_IPA_PartnerRole__c,Account.Core_Intel_Partner_Alliance_PartnerGroup__c from contact where Id =: contactId Limit 1]){
            if(conObj.Core_Preferred_Language__c != null && conObj.Core_Preferred_Language__c !=''){
                userLanguage = conObj.Core_Preferred_Language__c;
            }
            isIpaAccount = conObj.Account.Core_Intel_Partner_Alliance_PartnerGroup__c;
            userRole = conObj.Core_IPA_PartnerRole__c;
        } 
        }
    
        if(userRole != null && (userRole == System.label.PRM_Distributor || userRole == System.label.PRM_Guest )){
            isDesiredRole = False;
        }

        Set<String> setOfEnitlment = new Set<String>();
        setOfEnitlment.add(System.label.PRM_Partner_Admin);
        setOfEnitlment.add(System.label.PRM_Admin_Delegate);

        if(contactId != null){
        lstOfConEnt = [select id,name,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Selected__c,Core_Status__c from Core_Contact_Entitlement__c where Core_Contact_Id__c =:contactId AND Core_Selected__c = true AND Core_Status__c =: System.label.PRM_Partner_Complete AND Core_Entitlement_Id__r.name IN :setOfEnitlment];
        }
        
        if(lstOfConEnt != null && !lstOfConEnt.isEmpty()){
            isEntitlmentCorrect = True;
        }

        if(isIpaAccount && isDesiredRole && isEntitlmentCorrect){
            displayTempFirstErrorMssg = false;
        }
        
        //System.debug('userLanguage :- '+userLanguage);
        if(userLanguage != null){
            lstOfPartnerTermsAndCondition = [Select id,name,PRM_Content_Code_Txt__c,PRM_Content_Message_Txt__c,PRM_Content_Language_Nm__c,PRM_InActive_Ind__c,PRM_Terms_and_Conditions_Type_Nm__c from PRM_Partner_Terms_and_Conditions__c where PRM_InActive_Ind__c = False AND PRM_Content_Language_Nm__c =:userLanguage AND PRM_Terms_and_Conditions_Type_Nm__c =:System.label.PRM_Consent];
        }

        if(lstOfPartnerTermsAndCondition != null && !lstOfPartnerTermsAndCondition.isEmpty()){
            for(PRM_Partner_Terms_and_Conditions__c ptcObj: [Select id,name,PRM_Content_Code_Txt__c,PRM_Content_Message_Txt__c,PRM_Content_Language_Nm__c,PRM_InActive_Ind__c,PRM_Terms_and_Conditions_Type_Nm__c from PRM_Partner_Terms_and_Conditions__c where PRM_InActive_Ind__c = False AND PRM_Content_Language_Nm__c =:userLanguage AND PRM_Terms_and_Conditions_Type_Nm__c =:System.label.PRM_Consent]){
                if(ptcObj.PRM_Content_Code_Txt__c == System.label.PRM_Upper_Text_Code && ptcObj.PRM_Content_Message_Txt__c != null){
                    tempUpperText =  ptcObj.PRM_Content_Message_Txt__c;
                }else if(ptcObj.PRM_Content_Code_Txt__c == System.label.PRM_Lower_Text_Code && ptcObj.PRM_Content_Message_Txt__c != null){
                    tempLowerText= ptcObj.PRM_Content_Message_Txt__c;
                }
            }
        }else{
            for(PRM_Partner_Terms_and_Conditions__c ptcObj: [Select id,name,PRM_Content_Code_Txt__c,PRM_Content_Message_Txt__c,PRM_Content_Language_Nm__c,PRM_InActive_Ind__c,PRM_Terms_and_Conditions_Type_Nm__c from PRM_Partner_Terms_and_Conditions__c where PRM_InActive_Ind__c = False AND PRM_Content_Language_Nm__c =: System.label.PRM_ENG AND PRM_Terms_and_Conditions_Type_Nm__c =:System.label.PRM_Consent]){
                if(ptcObj.PRM_Content_Code_Txt__c == System.label.PRM_Upper_Text_Code && ptcObj.PRM_Content_Message_Txt__c != null){
                    tempUpperText =  ptcObj.PRM_Content_Message_Txt__c;
                }else if(ptcObj.PRM_Content_Code_Txt__c == System.label.PRM_Lower_Text_Code && ptcObj.PRM_Content_Message_Txt__c != null){
                    tempLowerText= ptcObj.PRM_Content_Message_Txt__c;
                }
            }
        }

    /* if(userLanguage != null){
            for(PRM_Partner_Terms_and_Conditions__c ptcObj: [Select id,name,PRM_Content_Code_Txt__c,PRM_Content_Message_Txt__c,PRM_Content_Language_Nm__c,PRM_InActive_Ind__c,PRM_Terms_and_Conditions_Type_Nm__c from PRM_Partner_Terms_and_Conditions__c where PRM_InActive_Ind__c = False AND PRM_Content_Language_Nm__c =:userLanguage AND PRM_Terms_and_Conditions_Type_Nm__c =:System.label.PRM_Consent]){
                if(ptcObj.PRM_Content_Code_Txt__c == System.label.PRM_Upper_Text_Code && ptcObj.PRM_Content_Message_Txt__c != null){
                    tempUpperText =  ptcObj.PRM_Content_Message_Txt__c;
                }else if(ptcObj.PRM_Content_Code_Txt__c == System.label.PRM_Lower_Text_Code && ptcObj.PRM_Content_Message_Txt__c != null){
                    tempLowerText= ptcObj.PRM_Content_Message_Txt__c;
                }
            }
        }*/
    /*//System.debug('isIpaAccount :- '+isIpaAccount);
        //System.debug('userRole :- '+userRole);
        //System.debug('isDesiredRole :- '+isDesiredRole);
        //System.debug('lstOfConEnt :- '+lstOfConEnt);
        //System.debug('isEntitlmentCorrect :- '+isEntitlmentCorrect);
        //System.debug('displayTempFirstErrorMssg :- '+displayTempFirstErrorMssg);
        //System.debug('lstOfPartnerAssitConsent :- '+lstOfPartnerAssitConsent);
        //System.debug('displayTempSecondErrorMssg :- '+displayTempSecondErrorMssg);*/

        PartnerAssitTextWrapper pobj = new PartnerAssitTextWrapper();
        pobj.upperText = tempUpperText;
        pobj.lowerText = tempLowerText;
        pobj.displayFirstErrorMssg = displayTempFirstErrorMssg;
        pobj.displaySecondErrorMssg = displayTempSecondErrorMssg;


        return pobj; 
    }

    //Method will return the Distributor List
    @AuraEnabled(cacheable=true)
    public static List<DistributorListWrapper> getDistributorList(){
    String userCountry ='';
    List<String> userGeoList = new List<String>();
    String userSubGeo ='';
    List<PRM_Partner_Consent_Distributor__c> lstOfConsentDistributor = new List<PRM_Partner_Consent_Distributor__c>();
    List<PRM_Partner_Consent_Distributor__c> filteredLstOfConsentDistributor = new List<PRM_Partner_Consent_Distributor__c>();

    List<DistributorListWrapper> distrubutorList = new List<DistributorListWrapper>();
    List<string> geoList = LabelConfiguration__mdt.getInstance('PRM_Geo').Value__c.split(',');

    //Id loggedUserId = UserInfo.getUserId();
    Id accountId=[SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()].AccountId; 
    Id contactId = [Select contactid from User where id =: Userinfo.getUserid()].contactId;
    //TWC729-7726 : Cim Prime EOL
    Map<string,string> countryMap = new map<string,string>();
    for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
        countryMap.put(allCountries.ISO_Code__c, allCountries.Name);
    }

    if(contactId != null){
            // Query on account to fetch details
            for(Account accObj: [select id,/*name,*/BillingCountry,Core_Geo__c,Core_Sub_Geo__c from Account where Id =: accountId Limit 1]){//ATHR Fix - TWC729-9556
                
                if(geoList.contains(accObj.Core_Geo__c)){
                    userGeoList.addall(geoList);
                }
                else{
                    userGeoList.add(accObj.Core_Geo__c);
                    userSubGeo = accObj.Core_Sub_Geo__c;
                    userCountry = countryMap.get(accObj.BillingCountry) ;//billing address
                }
            }
        }

        //new logic added

        if(userGeoList != null){
            lstOfConsentDistributor = [Select Id,name,PRM_Country_Name__c,PRM_Geo_Nm__c,PRM_Sub_Region_Nm__c,PRM_Distributor_Name_Txt__c from PRM_Partner_Consent_Distributor__c Where PRM_Geo_Nm__c in:userGeoList AND PRM_Distributor_Name_Txt__c != null];
        }

        if(lstOfConsentDistributor != null && !lstOfConsentDistributor.isEmpty()){
        for(PRM_Partner_Consent_Distributor__c pcdObj: lstOfConsentDistributor){
        if((( (String.isBlank(pcdObj.PRM_Sub_Region_Nm__c)) || ((!String.isBlank(pcdObj.PRM_Sub_Region_Nm__c)) &&  (pcdObj.PRM_Sub_Region_Nm__c == userSubGeo)) ) && ((String.isBlank(pcdObj.PRM_Country_Name__c)) || ((!String.isBlank(pcdObj.PRM_Country_Name__c)) && (pcdObj.PRM_Country_Name__c.equalsIgnoreCase(userCountry)) ) )) || geoList.contains(pcdObj.PRM_Geo_Nm__c)) 
        {
            filteredLstOfConsentDistributor.add(pcdObj);
        }
        }
        }

        if(filteredLstOfConsentDistributor != null && !filteredLstOfConsentDistributor.isEmpty()){
        for(PRM_Partner_Consent_Distributor__c filterdPcd: filteredLstOfConsentDistributor){
            DistributorListWrapper dl = new DistributorListWrapper();
            dl.label = filterdPcd.PRM_Distributor_Name_Txt__c;
            dl.value = filterdPcd.Id;
            distrubutorList.add(dl);
        }
        }

    /* if(userCountry != null && userGeo != null && userSubGeo != null){
            for(PRM_Partner_Consent_Distributor__c pcd: [Select Id,name,PRM_Country_Name__c,PRM_Geo_Nm__c,PRM_Sub_Region_Nm__c,PRM_Distributor_Name_Txt__c from PRM_Partner_Consent_Distributor__c Where PRM_Country_Name__c =:userCountry AND PRM_Geo_Nm__c =:userGeo AND PRM_Sub_Region_Nm__c =:userSubGeo AND PRM_Distributor_Name_Txt__c != null]){
                DistributorListWrapper dl = new DistributorListWrapper();
                dl.label = pcd.PRM_Distributor_Name_Txt__c;
                dl.value = pcd.Id;
                distrubutorList.add(dl);
            }
        }*/
        
        return distrubutorList;
    }

    @AuraEnabled
    public static Boolean insertPartnerConsentRecs(Id firstDistributorId,Id secondDistributorId,Boolean isChecked){
        Integer successCount = 0;
        Integer failureCount = 0;
        List<PRM_Partner_Assist_Consent__c> toInsertPartnerAssistConsentRecList = new List<PRM_Partner_Assist_Consent__c>();
        User us = [Select Id,Name,ContactId,AccountId from User where Id = :Userinfo.getUserid() LIMIT 1];
    
        //Sheetal Changes Start
        Map<string,string> mapOfDistIdToChoice = new Map<string,string>();
        if(firstDistributorId != null){
            mapOfDistIdToChoice.put('Partner Assist Choice 1',firstDistributorId);
        }
        if(secondDistributorId != null){
            mapOfDistIdToChoice.put('Partner Assist Choice 2',secondDistributorId);
        }

        if(mapOfDistIdToChoice.keySet() != null && !mapOfDistIdToChoice.keyset().isEmpty()){
        for(string partAssistObj: mapOfDistIdToChoice.keySet()){
            PRM_Partner_Assist_Consent__c pac = new PRM_Partner_Assist_Consent__c();
            pac.PRM_Consent_Provided_Ind__c = isChecked;
            pac.PRM_Account_Id__c = us.AccountId;
            pac.PRM_Consent_Provided_By_Id__c = us.ContactId;
            pac.PRM_Consent_Provided_Date_Dt__c = System.now();
            pac.PRM_Distributor_Id__c = mapOfDistIdToChoice.get(partAssistObj);
            pac.PRM_Start_Date_Dt__c = System.now();
            pac.PRM_Choice_Nm__c =partAssistObj;
            toInsertPartnerAssistConsentRecList.add(pac);
        }
        }
    
    // Sheetal Changes End 
    /*
        if(secondDistributorId == null && firstDistributorId != null && isChecked == true){
            PRM_Partner_Assist_Consent__c pac = new PRM_Partner_Assist_Consent__c();
            pac.PRM_Consent_Provided_Ind__c = isChecked;
            pac.PRM_Account_Id__c = us.AccountId;
            pac.PRM_Consent_Provided_By_Id__c = us.ContactId;
            pac.PRM_Consent_Provided_Date_Dt__c = System.today();
            pac.PRM_Distributor_Id__c = firstDistributorId;
            pac.PRM_Start_Date_Dt__c = System.today();
            pac.PRM_Choice_Nm__c ='Partner Assist Choice 1';
            toInsertPartnerAssistConsentRecList.add(pac);
        }else if(secondDistributorId != null && firstDistributorId != null && isChecked == true){
            PRM_Partner_Assist_Consent__c pac = new PRM_Partner_Assist_Consent__c();
            pac.PRM_Consent_Provided_Ind__c = isChecked;
            pac.PRM_Account_Id__c = us.AccountId;
            pac.PRM_Consent_Provided_By_Id__c = us.ContactId;
            pac.PRM_Consent_Provided_Date_Dt__c = System.today();
            pac.PRM_Distributor_Id__c = firstDistributorId;
            pac.PRM_Start_Date_Dt__c = System.today();
            pac.PRM_Choice_Nm__c ='Partner Assist Choice 1';
            toInsertPartnerAssistConsentRecList.add(pac);
        
            PRM_Partner_Assist_Consent__c pac1 = new PRM_Partner_Assist_Consent__c();
            pac1.PRM_Consent_Provided_Ind__c = isChecked;
            pac1.PRM_Account_Id__c = us.AccountId;
            pac1.PRM_Consent_Provided_By_Id__c = us.ContactId;
            pac1.PRM_Consent_Provided_Date_Dt__c = System.today();
            pac1.PRM_Distributor_Id__c = secondDistributorId;
            pac1.PRM_Start_Date_Dt__c = System.today();
            pac1.PRM_Choice_Nm__c ='Partner Assist Choice 2';
            toInsertPartnerAssistConsentRecList.add(pac1);   
        }*/
    
        try{
            if(!toInsertPartnerAssistConsentRecList.isEmpty() && toInsertPartnerAssistConsentRecList.size() > 0){
                Database.SaveResult[] result = Database.insert(toInsertPartnerAssistConsentRecList,false);
                for(Database.SaveResult sr:result){
                if(sr.isSuccess()){
                    successCount++;
                }else{
                    Database.Error[] errors =sr.getErrors();
                    for(Database.Error er :errors){
                        failureCount++;
                    }
                }
            }  
        }
        }catch(Exception e){
            System.debug('Inside Catch: '+e.getMessage());
        }  
        if((failureCount <= 0) && (successCount > 0)){
            return true;
        }else{
            return false;
        } 
    }
        
    public class PartnerAssitTextWrapper{
    @AuraEnabled public String upperText { get; set;}
    @AuraEnabled public String lowerText  { get; set;}
    @AuraEnabled public boolean displayFirstErrorMssg  { get; set;}
    @AuraEnabled public boolean displaySecondErrorMssg  { get; set;}
    }
    public class DistributorListWrapper{
    @AuraEnabled public String label {set;get;}
    @AuraEnabled public String value {set;get;}
    }
}