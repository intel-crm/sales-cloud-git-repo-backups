public with sharing class PMP_Locale_Outbound_Msg 
{
    public static list<PMP_Partner_Offering__c> offerings = new list<PMP_Partner_Offering__c>();
    
    Public static boolean InsertOutboundMsg()
    {
        string outboundmsg = null;
        boolean isSuccess = false;

            
        try
        {
            List<Core_Integration_Outbound_Message__c> oBMsgList = new List<Core_Integration_Outbound_Message__c>();
            //Generate Outbound messages for different source languages
            for (PMP_Languages__mdt lngsSupported : [select Locale_Nm__c,Language_Code__c,PMP_Target_Locale_Nm__c from PMP_Languages__mdt])
            {

                outboundmsg = GetLocaleOutboundMsg(lngsSupported.Language_Code__c, lngsSupported.Locale_Nm__c, lngsSupported.PMP_Target_Locale_Nm__c);
                
                
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
                insert oBMsgList;    
            }            
            
            if (offerings.size()>0)
            {
                update offerings;
            }
            isSuccess = true;
            
            
        }
        catch(Exception e){}
        
        return isSuccess;
    }
    
    public static String GetLocaleOutboundMsg(string sourceLanguageCode, string sourceLanguageName, string targetLanguage)
    {
        String outBoundJson = null;
        List<WrapOfferingMain> offeringMainList = new List<WrapOfferingMain>();
        Map<string,string> languages = new Map<string,string>();
        Map<string,string> targetLanguages = new Map<string,string>();
        List<WrapOfferings> offeringsList=New List<WrapOfferings>();
        
        
        WrapOfferingMain offeringMain = new WrapOfferingMain();
        offeringMain.SourceLanguage = sourceLanguageCode;
       	Map<Id, PMP_Partner_Offering__c> mapOfferingList = new Map<Id, PMP_Partner_Offering__c>([Select Id, Name, PMP_Partner_Offering_Nm__c, PMP_Partner_Offering_Dsc__c, 
                                                 PMP_Partner_Offering_Tag_Line_Txt__c, PMP_Partner_Offering_Lifecycle_Status_Nm__c, 
                                                 PMP_Translation_Lifecycle_Status_nm__c,PMP_Offering_Language_Nm__c,PMP_Edit_Language_Cd__c,
                                                 lastmodifieddate
                                                 FROM PMP_Partner_Offering__c 
                                                 WHERE PMP_Translation_Lifecycle_Status_nm__c = 'Pending' // Should test as "Pending"                                              
                                                 and ((PMP_Offering_Language_Nm__c = :sourceLanguageName and PMP_Edit_Language_Cd__c =null) 
                                                      or (PMP_Edit_Language_Cd__c = :sourceLanguageName and PMP_Edit_Language_Cd__c !=null)) 
                                                 and ((PMP_Offering_Language_Nm__c!='English' and PMP_Partner_Offering_Lifecycle_Status_Nm__c IN ('Admin Review','Approved')) 
                                                      or (PMP_Offering_Language_Nm__c='English' and PMP_Partner_Offering_Lifecycle_Status_Nm__c ='Approved'))
                                                 LIMIT 100]);
        
        
        List<PMP_Partner_Offering_Translation__c> pOfferTransList = new List<PMP_Partner_Offering_Translation__c>();
        pOfferTransList = [SELECT Id,PMP_Partner_Offering_Id__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c, PMP_English_Txt__c,PMP_Field_Nm__c 
                                                                    FROM PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c IN :mapOfferingList.keySet()];
        
        Map<Id, List<PMP_Partner_Offering_Translation__c>> mapPOfferTransList = new Map<Id, List<PMP_Partner_Offering_Translation__c>>();
        List<PMP_Partner_Offering_Translation__c> newPOfferTransList;
        for(PMP_Partner_Offering_Translation__c pOfferTrans: pOfferTransList ){
            newPOfferTransList = new List<PMP_Partner_Offering_Translation__c>();
            
            if(mapPOfferTransList.containsKey(pOfferTrans.PMP_Partner_Offering_Id__c)){
                newPOfferTransList = mapPOfferTransList.get(pOfferTrans.PMP_Partner_Offering_Id__c); 
            }
            newPOfferTransList.add(pOfferTrans);            
            mapPOfferTransList.put(pOfferTrans.PMP_Partner_Offering_Id__c, newPOfferTransList);
        }
        
        // Read all the offering which needs localization
        for (PMP_Partner_Offering__c offering : mapOfferingList.values())
        { 										
            if (offering.PMP_Edit_Language_Cd__c!=null && offering.PMP_Edit_Language_Cd__c!='' && offering.PMP_Offering_Language_Nm__c!=offering.PMP_Edit_Language_Cd__c && mapPOfferTransList.containsKey(offering.Id))
            {
                  for (PMP_Partner_Offering_Translation__c pOfferTrans : mapPOfferTransList.get(offering.Id))
                      
                  {
                      if (sourceLanguageCode == 'en-US'){
                            switch on pOfferTrans.PMP_Field_Nm__c
                            {   when 'PMP_Partner_Offering_Dsc__c' {offering.PMP_Partner_Offering_Dsc__c=pOfferTrans.PMP_English_Txt__c;}
                                when 'PMP_Partner_Offering_Nm__c' {offering.PMP_Partner_Offering_Nm__c=pOfferTrans.PMP_English_Txt__c;}
                                when 'PMP_Partner_Offering_Tag_Line_Txt__c' {offering.PMP_Partner_Offering_Tag_Line_Txt__c=pOfferTrans.PMP_English_Txt__c;}
                            }
                        }
                        else if (sourceLanguageCode == 'JA'){
                            switch on pOfferTrans.PMP_Field_Nm__c
                            {   when 'PMP_Partner_Offering_Dsc__c' {offering.PMP_Partner_Offering_Dsc__c=pOfferTrans.PMP_Japanese_Txt__c;}
                                when 'PMP_Partner_Offering_Nm__c' {offering.PMP_Partner_Offering_Nm__c=pOfferTrans.PMP_Japanese_Txt__c;}
                                when 'PMP_Partner_Offering_Tag_Line_Txt__c' {offering.PMP_Partner_Offering_Tag_Line_Txt__c=pOfferTrans.PMP_Japanese_Txt__c;}
                            }
                        }
                        else if (sourceLanguageCode == 'zh-CN'){
                            switch on pOfferTrans.PMP_Field_Nm__c
                            {   when 'PMP_Partner_Offering_Dsc__c' {offering.PMP_Partner_Offering_Dsc__c=pOfferTrans.PMP_Chinese_Txt__c;}
                                when 'PMP_Partner_Offering_Nm__c' {offering.PMP_Partner_Offering_Nm__c=pOfferTrans.PMP_Chinese_Txt__c;}
                                when 'PMP_Partner_Offering_Tag_Line_Txt__c' {offering.PMP_Partner_Offering_Tag_Line_Txt__c=pOfferTrans.PMP_Chinese_Txt__c;}
                            }
                  }   
                  }
            }
            offeringsList.add(BuildOffering(sourceLanguageCode,offering,targetLanguage));
            offering.PMP_Translation_Lifecycle_Status_nm__c = 'In Progress';
            offerings.add(offering);
        }
       
        offeringMain.Offerings=offeringsList;
        if (offeringsList.size()>0)
        {
            outBoundJson = JSON.serialize(offeringMain);
            outBoundJson = '<![CDATA[' +  outBoundJson + ']]>';    
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
    
}