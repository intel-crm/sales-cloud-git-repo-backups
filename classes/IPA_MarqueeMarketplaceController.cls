/******************************************************************************************************************************************************************************************************
* Class Name  : IPA_MarqueeMarketplaceController
* Version     : 1.0 
* Created Date: 18th Jul, 2019
* Modification Log :
* Developer                             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Raj Yadav                            07/18/2019               Controller for ipaMarqueeMarketplace component.
******************************************************************************************************************************************************************************************************/
public with sharing class IPA_MarqueeMarketplaceController{
 public static void dummyMethod() {}

   /* @AuraEnabled
    public static String getBaseUrlForLaunguageCode(String cookieLangCode, String urlLangCode){

        List<PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt> baseUrlRecords = new List<PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt>();
        String language;
        Boolean isCookieCodeAvailable = false;
        System.debug('!!!!Cookie code'+cookieLangCode);
        System.debug('!!!!urlLangCode '+urlLangCode);
        if(String.isNotBlank(cookieLangCode)){
            System.debug('!!!!Inside cookie code lang');
            System.debug('Cookie code'+cookieLangCode);
            language = cookieLangCode;
            isCookieCodeAvailable = true;
        }

        else if(String.isNotBlank(urlLangCode)){
            System.debug('!!!!Inside url code lang');
            language = urlLangCode;
        }
        
        else{
            System.debug('!!!!Inside user code lang');
            language = userInfo.getLanguage();
        }

        //If cookie code is present then fetch records using that code.
        if(isCookieCodeAvailable){
            System.debug('!!!!Inside first If');
            baseUrlRecords = [SELECT BaseURL__c, LanguageCode__c, Tab__c FROM PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt WHERE LanguageCode__c =: language];
        }
        //Fetching records based on salesforce URL Code when cookie code is not present.
        else{
            System.debug('!!!!Inside first Else');
            language = language=='ja'? 'ja_JP': language;
            baseUrlRecords = [SELECT BaseURL__c, LanguageCode__c, Tab__c FROM PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt WHERE SFDCLanguageCode__c =: language];
        }
        
        //Fetching data for English language in case 'baseUrlRecords' comes empty i.e Language code not found in metadata.
        if(baseUrlRecords.isEmpty()){
            System.debug('!!!!Inside Second If');
            baseUrlRecords = [SELECT BaseURL__c, LanguageCode__c, Tab__c FROM PMP_Coveo_Intel_Lang_Code_to_URL_Mapping__mdt WHERE SFDCLanguageCode__c = 'En_us'];
        }

        return JSON.serialize(baseUrlRecords);
    }*/
//IPA 2.0-US-TWC729-7981 
 /*   @AuraEnabled(cacheable=true)
    public static list<PMP_CallOut_Details__mdt> getCallOutDetails() {
        list<PMP_CallOut_Details__mdt> callOutList = new List<PMP_CallOut_Details__mdt>();
        callOutList = [SELECT DeveloperName, MasterLabel,PMP_CallOut_BearerKey_Txt__c,
                PMP_CallOut_MarketPlace_TailURL_Txt__c,PMP_CallOut_Method_Txt__c,PMP_CallOut_Name_Txt__c,PMP_CallOut_Offerings_TailURL_Txt__c,
                PMP_CallOut_Organization_Id_Value_Txt__c,PMP_CallOut_Partner_TailURL_Txt__c,PMP_CallOut_Result_Count_Txt__c,
                PMP_CallOut_SearchHub_Txt__c,PMP_CallOut_URL_Txt__c FROM PMP_CallOut_Details__mdt WHERE DeveloperName Like 'Coveo%'];
        System.debug('Callout List Data :'+callOutList);
        return callOutList;
    }*/
}