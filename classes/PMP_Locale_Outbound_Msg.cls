public with sharing class PMP_Locale_Outbound_Msg{ 
    public static Boolean isWorking() {
        return true;
    }
//IPA2.0 - As part of TWC729-7977 commented the entire class
/*

    public static list<PMP_Partner_Offering__c> offerings = new list<PMP_Partner_Offering__c>();
    
    Public static boolean InsertOutboundMsg()
    {
        string outboundmsg = null;
        boolean isSuccess = false;

            
        try
        {
            List<Core_Integration_Outbound_Message__c> oBMsgList = new List<Core_Integration_Outbound_Message__c>();
            //Generate Outbound messages for different source languages
            for (PMP_Languages__mdt lngsSupported : [select Locale_Nm__c,Language_Code__c,PMP_Target_Locale_Nm__c from PMP_Languages__mdt where Locale_Nm__c != null])
            {

                outboundmsg = GetLocaleOutboundMsg(lngsSupported.Language_Code__c, lngsSupported.Locale_Nm__c, lngsSupported.PMP_Target_Locale_Nm__c);
                
                // system.debug('###outboundmsg:-'+outboundmsg);
                if (outboundmsg != null)
                {
                    Core_Integration_Outbound_Message__c oBMsg = new Core_Integration_Outbound_Message__c();
                    //US671216:Gireesh changed Message Type from "Marketplace Translation" to "Marketplace_Translation"
                    oBMsg.Core_MessageType__c = 'Marketplace_Translation';
                    oBMsg.Core_Payload__c = outboundmsg;
                    oBMsg.Core_Tags__c = 'Marketplace, Translation, offering';
                    oBMsgList.add(oBMsg);
                    //Insert oBMsg; //commented by US614314:Gireesh
                }
            }
            
            //US614314:Gireesh 
            if (oBMsgList.size()>0){
                //system.debug('###oBMsgList:->'+oBMsgList);
                insert oBMsgList;    
            }            
            
            if (offerings.size()>0)
            {
                update offerings;
            }
            isSuccess = true;
            
            
        }
        catch(Exception e){
            //system.debug('###exception:->'+e);
            PMP_Utility.logError(e,'PMP_OfferingOutBoundTranslation');
        }
        
        return isSuccess;
    }
    
    public static String GetLocaleOutboundMsg(string sourceLanguageCode, string sourceLanguageName, string targetLanguage) {
        List<WrapOfferings> offeringsList = new List<WrapOfferings>();
        WrapOfferingMain offeringMain = prepareOfferingMain(sourceLanguageCode);
        Map<Id, List<PMP_Partner_Offering_Translation__c>> mapPOfferTransList = fetchOfferingTranslations(sourceLanguageName);
        Map<Id, PMP_Partner_Offering__c> mapOfferingList = fetchOfferings(sourceLanguageName);

        populateOfferingsWithTranslations(sourceLanguageCode, mapPOfferTransList, mapOfferingList, offeringsList, targetLanguage);
        
        return serializeOfferingMain(offeringsList, offeringMain);
    }

    private static WrapOfferingMain prepareOfferingMain(string sourceLanguageCode) {
        WrapOfferingMain offeringMain = new WrapOfferingMain();
        offeringMain.SourceLanguage = sourceLanguageCode;
        return offeringMain;
    }

    private static Map<Id, List<PMP_Partner_Offering_Translation__c>> fetchOfferingTranslations(string sourceLanguageName) {
        Map<Id, List<PMP_Partner_Offering_Translation__c>> mapPOfferTransList = new Map<Id, List<PMP_Partner_Offering_Translation__c>>();
        
        List<PMP_Partner_Offering_Translation__c> pOfferTransList = [SELECT Id, PMP_Partner_Offering_Id__c, PMP_Chinese_Txt__c, 
                                                                    PMP_Japanese_Txt__c, PMP_English_Txt__c, PMP_Field_Nm__c 
                                                                    FROM PMP_Partner_Offering_Translation__c 
                                                                    WHERE PMP_Partner_Offering_Id__c IN (
                                                                        SELECT Id FROM PMP_Partner_Offering__c 
                                                                        WHERE PMP_Translation_Lifecycle_Status_nm__c = 'Pending' 
                                                                        AND ((PMP_Offering_Language_Nm__c = :sourceLanguageName AND PMP_Edit_Language_Cd__c = null) 
                                                                            OR (PMP_Edit_Language_Cd__c = :sourceLanguageName AND PMP_Edit_Language_Cd__c != null)) 
                                                                        AND ((PMP_Offering_Language_Nm__c != 'English' AND PMP_Partner_Offering_Lifecycle_Status_Nm__c IN ('Admin Review', 'Approved')) 
                                                                            OR (PMP_Offering_Language_Nm__c = 'English' AND PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved'))
                                                                    )
                                                                    LIMIT 100];

        for(PMP_Partner_Offering_Translation__c pOfferTrans : pOfferTransList) {
            List<PMP_Partner_Offering_Translation__c> newPOfferTransList = new List<PMP_Partner_Offering_Translation__c>();
            
            if(mapPOfferTransList.containsKey(pOfferTrans.PMP_Partner_Offering_Id__c)){
                newPOfferTransList = mapPOfferTransList.get(pOfferTrans.PMP_Partner_Offering_Id__c); 
            }
            newPOfferTransList.add(pOfferTrans);            
            mapPOfferTransList.put(pOfferTrans.PMP_Partner_Offering_Id__c, newPOfferTransList);
        }
        
        return mapPOfferTransList;
    }

    private static Map<Id, PMP_Partner_Offering__c> fetchOfferings(string sourceLanguageName) {
        return new Map<Id, PMP_Partner_Offering__c>([
            SELECT Id, Name, PMP_Partner_Offering_Nm__c, PMP_Partner_Offering_Dsc__c, 
                PMP_Partner_Offering_Tag_Line_Txt__c, PMP_Partner_Offering_Lifecycle_Status_Nm__c, 
                PMP_Translation_Lifecycle_Status_nm__c, PMP_Offering_Language_Nm__c, PMP_Edit_Language_Cd__c,
                LastModifiedDate
            FROM PMP_Partner_Offering__c 
            WHERE PMP_Translation_Lifecycle_Status_nm__c = 'Pending' 
            AND ((PMP_Offering_Language_Nm__c = :sourceLanguageName AND PMP_Edit_Language_Cd__c = null) 
                OR (PMP_Edit_Language_Cd__c = :sourceLanguageName AND PMP_Edit_Language_Cd__c != null)) 
            AND ((PMP_Offering_Language_Nm__c != 'English' AND PMP_Partner_Offering_Lifecycle_Status_Nm__c IN ('Admin Review', 'Approved')) 
                OR (PMP_Offering_Language_Nm__c = 'English' AND PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved'))
            LIMIT 100
        ]);
    }

    private static void populateOfferingsWithTranslations(string sourceLanguageCode, Map<Id, List<PMP_Partner_Offering_Translation__c>> mapPOfferTransList,
                                                      Map<Id, PMP_Partner_Offering__c> mapOfferingList, List<WrapOfferings> offeringsList,
                                                      string targetLanguage) {
        for (PMP_Partner_Offering__c offering : mapOfferingList.values()) {
            if (shouldUpdateOffering(sourceLanguageCode, offering, mapPOfferTransList)) {
                updateOfferingTranslations(sourceLanguageCode, offering, mapPOfferTransList);
            }
            offeringsList.add(BuildOffering(sourceLanguageCode, offering, targetLanguage));
            offering.PMP_Translation_Lifecycle_Status_nm__c = 'In Progress';
            offerings.add(offering);
        }
    }

    private static boolean shouldUpdateOffering(string sourceLanguageCode, PMP_Partner_Offering__c offering, Map<Id, List<PMP_Partner_Offering_Translation__c>> mapPOfferTransList) {
        return offering.PMP_Edit_Language_Cd__c != null && offering.PMP_Edit_Language_Cd__c != '' &&
            offering.PMP_Offering_Language_Nm__c != offering.PMP_Edit_Language_Cd__c &&
            mapPOfferTransList.containsKey(offering.Id);
    }

    private static void updateOfferingTranslations(string sourceLanguageCode, PMP_Partner_Offering__c offering, Map<Id, List<PMP_Partner_Offering_Translation__c>> mapPOfferTransList) {
        List<PMP_Partner_Offering_Translation__c> pOfferTransListForOffering = mapPOfferTransList.get(offering.Id);
        for (PMP_Partner_Offering_Translation__c pOfferTrans : pOfferTransListForOffering) {
            switch on (sourceLanguageCode) {
                when 'en-US' {
                    offering.PMP_Partner_Offering_Dsc__c = pOfferTrans.PMP_English_Txt__c;
                    offering.PMP_Partner_Offering_Nm__c = pOfferTrans.PMP_English_Txt__c;
                    offering.PMP_Partner_Offering_Tag_Line_Txt__c = pOfferTrans.PMP_English_Txt__c;
                }
                when 'JA' {
                    offering.PMP_Partner_Offering_Dsc__c = pOfferTrans.PMP_Japanese_Txt__c;
                    offering.PMP_Partner_Offering_Nm__c = pOfferTrans.PMP_Japanese_Txt__c;
                    offering.PMP_Partner_Offering_Tag_Line_Txt__c = pOfferTrans.PMP_Japanese_Txt__c;
                }
                when 'zh-CN' {
                    offering.PMP_Partner_Offering_Dsc__c = pOfferTrans.PMP_Chinese_Txt__c;
                    offering.PMP_Partner_Offering_Nm__c = pOfferTrans.PMP_Chinese_Txt__c;
                    offering.PMP_Partner_Offering_Tag_Line_Txt__c = pOfferTrans.PMP_Chinese_Txt__c;
                }
            }
        }
    }

    private static string serializeOfferingMain(List<WrapOfferings> offeringsList, WrapOfferingMain offeringMain) {
        String outBoundJson = null;
        
        if (!offeringsList.isEmpty()) {
            offeringMain.Offerings = offeringsList;
            outBoundJson = JSON.serialize(offeringMain);
            outBoundJson = '<![CDATA[' + outBoundJson + ']]>';
        }
        
        return outBoundJson;
    }
    
    
    private static WrapOfferings BuildOffering(string sourcelangcode, PMP_Partner_Offering__c offering,string targetLanguage)
    {
       
        WrapOfferings wrapOffering;
        
       
        wrapOffering = new WrapOfferings();    
        wrapOffering.OfferingId = offering.Id;
        wrapOffering.OfferingName = offering.PMP_Partner_Offering_Nm__c;
        wrapOffering.OfferingDescription = offering.PMP_Partner_Offering_Dsc__c;
        wrapOffering.TagLine = offering.PMP_Partner_Offering_Tag_Line_Txt__c;
        wrapOffering.TargetLanguage = targetLanguage;
        datetime sentDate = offering.lastmodifieddate;
        wrapOffering.ModifiedDate = date.newinstance(sentDate.year(),sentDate.month(),sentDate.day());
     
       
        return wrapOffering;
    }
    
    public class WrapOfferingMain 
    {
        public String SourceLanguage {get; set;}
        public List<WrapOfferings> Offerings {get; set;}
    }   
    
    public class WrapOfferings
    {
        public String OfferingId {get; set;}
        public String OfferingName {get; set;}
        public String OfferingDescription {get; set;}
        public String TagLine {get; set;}
        public String TargetLanguage {get; set;}
        public Date ModifiedDate {get; set;}
    }
   */ 
}