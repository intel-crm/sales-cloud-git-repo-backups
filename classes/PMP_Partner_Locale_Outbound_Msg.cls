/****************************************************************************************************************************************
* Class Name  : PMP_Partner_Locale_Outbound_Msg 
* Version     : 1.0 
* Created Date: 16-Jan-2020
* Modification Log :
* Created By : Tanzanite Team Infosys
* * Developer                 Date         Description
* ----------------------------------------------------------------------------
* Prabuddh          16/01/2020             Created V 1.0   
*****************************************************************************************************************************************/

public with sharing class PMP_Partner_Locale_Outbound_Msg {
//IPA2.0 - As part of TWC729-7977 commented the entire class
/*    
    //Static list of partners
    public static List<PMP_Company__c> partners = new List<PMP_Company__c>();
    
    public static String programForTrans = 'Internet of Things and Embedded'; //ISA replaced with IOT Partner Segment as part of US704420
    
    //Method to insert outbound messages into the Integration object
//   public static Boolean insertPartnerOutboundMsg(List<PMP_Partner_Languages__mdt> languages){
     public static Boolean insertPartnerOutboundMsg(){
        
        String outboundMsg = null;
        Boolean isSuccess = false;       
        try{
            Map<id, String> outboundMsgMap = new Map<id, String>();
            List<Core_Integration_Outbound_Message__c> oBMsgList = new List<Core_Integration_Outbound_Message__c>();
            for(PMP_Partner_Languages__mdt langSupported : [select Locale_Name__c,Language_Code__c,PMP_Target_Locale_Nm__c from PMP_Partner_Languages__mdt where Locale_Name__c != null]){
 //         for(PMP_Partner_Languages__mdt langSupported : languages){
                
                outboundMsg = getLocaleOutboundMsg(langSupported.Language_Code__c, langSupported.Locale_Name__c, langSupported.PMP_Target_Locale_Nm__c);
                outboundMsgMap.put(langSupported.id,outboundMsg);
                //System.debug(':::outboundMsg:::' + outboundMsg);
                
                if(outboundMsg!= null){
                    Core_Integration_Outbound_Message__c oBMsg = new Core_Integration_Outbound_Message__c();
                    oBMsg.Core_MessageType__c = 'Marketplace Translation - Partner';
                 // oBMsg.Core_MessageType__c = 'Marketplace Translation';
                    oBMsg.Core_Payload__c = outboundMsg;
                    oBMsg.Core_Tags__c = 'Marketplace, Translation, Partner';
                    oBMsgList.add(oBMsg);
                    //Insert oBMsg; -- commented As part of PMD fix
                    // System.debug('inserted obsg'+oBMsg);
                }
       //         if (oBMsgList.size()>0){
        //               insert oBMsgList;                   
       //           }  
                if(partners.size() > 0){
                    update partners;
                }
                
                isSuccess = true;
            }
            //database.insert(oBMsgList);
            //System.debug(':::oBMsgList:::' + oBMsgList);
            if (oBMsgList.size()>0){
                insert oBMsgList;
            }
            
            if(partners.size() > 0){
                update partners;
            }
            
            
        }catch(Exception e){
            //system.debug('Error in outbound message generation for partner translation : ' + e.getMessage());
            PMP_Utility.logError(e,'PMP_CompanyOBTranslation');
        }
        return isSuccess;
    }
    
    //Method to build the outbound message depending upong the language parameters
    public static String getLocaleOutboundMsg(String sourcelangCode, String sourceLangName, String targetLanguage){
        
        String outBoundJson = null;
        List<PartnerWrapper> partnerList = new List<PartnerWrapper>();
        PartnerWrapMain partnerWrappedMain = new PartnerWrapMain();
        partnerWrappedMain.SourceLanguage = sourcelangCode;
        List<PMP_Company__c> partList = new List<PMP_Company__c>();
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
        partList = [SELECT Id, Name, PMP_Company_Lifecycle_Status_Nm__c,PMP_Working_Copy_Id__c,PMP_Account_Dsc__c,
                                      PMP_Translation_Lifecycle_Status_nm__c,PMP_Partner_Program_nm__c, PMP_Partner_Segment_Nm__c,LastModifiedDate,PMP_Account_Tag_Line__c,
                                      PMP_Company_Information_Language_Nm__c FROM PMP_Company__c
                                      WHERE PMP_Partner_Segment_Nm__c includes (:programForTrans)
                                      AND PMP_Translation_Lifecycle_Status_nm__c = 'Pending' AND PMP_Working_Copy_Id__c=null                                                                            
                                      AND (PMP_Company_Information_Language_Nm__c =: sourceLangName and PMP_Company_Information_Language_Nm__c!= null)
                                      AND ((PMP_Company_Information_Language_Nm__c!='English' and PMP_Company_Lifecycle_Status_Nm__c  IN('Admin Review','Approved'))
                                           or (PMP_Company_Information_Language_Nm__c ='English' and PMP_Company_Lifecycle_Status_Nm__c IN ('Approved')))                                     
                                      LIMIT 100];
        }
        Map<String, List<PMP_Company_Translation__c>> translationsMap = new Map<String, List<PMP_Company_Translation__c>>();
        String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
        if(Schema.sObjectType.PMP_Company_Translation__c.isAccessible()){
        for(PMP_Company_Translation__c trans : [SELECT Id,PMP_Company_Information_Id__c,PMP_Chinese_Txt__c,
                                                        PMP_English_Txt__c,PMP_Japanese_Txt__c,PMP_Field_Nm__c FROM PMP_Company_Translation__c
                                                        WHERE PMP_Company_Information_Id__c = :partList AND PMP_Field_Nm__c != :streamIdName]) {
                                                            
            if(translationsMap.get(trans.PMP_Company_Information_Id__c) == NULL) {
                translationsMap.put(trans.PMP_Company_Information_Id__c, new List<PMP_Company_Translation__c>());
            }
            translationsMap.get(trans.PMP_Company_Information_Id__c).add(trans);
        }
        }
        
        for(PMP_Company__c partner : partList)                                                                                                                                           
        {   
            
            PartnerWrapper wrappedPartner = new PartnerWrapper();
            wrappedPartner.partnerId = partner.Id;   
            wrappedPartner.TargetLanguage = targetLanguage;
            DateTime sentDate = partner.LastModifiedDate;
            wrappedPartner.modifiedDate = date.newinstance(sentDate.year(),sentDate.month(),sentDate.day());
            
            
            //Fetching the tanslated description and tagline from PMP_Company_Information_Id__c
            if(partner.PMP_Company_Information_Language_Nm__c!=null && partner.PMP_Company_Information_Language_Nm__c!=''){
                if(translationsMap.get(partner.Id) != null){
                for(PMP_Company_Translation__c trans : translationsMap.get(partner.Id))
                {
                    
                    if(sourcelangCode == 'en-US'){
                        switch on trans.PMP_Field_Nm__c{
                            when 'PMP_Account_Dsc__c'{ wrappedPartner.partnerDescription = trans.PMP_English_Txt__c; } 
                            when 'PMP_Account_Tag_Line__c'{ wrappedPartner.partnerTagline = trans.PMP_English_Txt__c; }
                        }
                    }else if(sourcelangCode == 'JA'){
                        switch on trans.PMP_Field_Nm__c{
                            when 'PMP_Account_Dsc__c'{ wrappedPartner.partnerDescription = trans.PMP_Japanese_Txt__c; }
                            when 'PMP_Account_Tag_Line__c'{ wrappedPartner.partnerTagline = trans.PMP_Japanese_Txt__c; }
                        }
                        // system.debug('japanese desc is updated'+trans.PMP_Japanese_Txt__c);
                    }else if(sourcelangCode == 'zh-CN'){
                         switch on trans.PMP_Field_Nm__c{
                            when 'PMP_Account_Dsc__c'{ wrappedPartner.partnerDescription = trans.PMP_Chinese_Txt__c; }
                             when 'PMP_Account_Tag_Line__c'{ wrappedPartner.partnerTagline = trans.PMP_Chinese_Txt__c; }
                        }
                        // system.debug('chinese desc is updated'+trans.PMP_Chinese_Txt__c);
                    }
                    
                }// Loop on translations end.
              }
            } 
          
            partnerList.add(wrappedPartner);   
            partner.PMP_Translation_Lifecycle_Status_nm__c = 'In Progress';
            partners.add(partner);  
            
        }// Loop on partners end.
        
        partnerWrappedMain.partners = partnerList;
        if(partnerList.size() > 0){
            outBoundJson = JSON.serialize(partnerWrappedMain);
            outBoundJson = '<![CDATA[' +  outBoundJson + ']]>';
        }
         //System.debug('returned json'+outBoundJson);
      return outBoundJson;
    }
       
    
    //Main wrapper which turns into JSON
    public class PartnerWrapMain{
        public String SourceLanguage {get; set;}
        public List<PartnerWrapper> partners {get; set;}
    }
    
    //Wrapper for partner containing relevant fields for translation
    public class PartnerWrapper{
        public String partnerId {get; set;}
        public String partnerDescription {get; set;}
        public String partnerTagline {get; set;}
        public String TargetLanguage {get; set;}
        public Date modifiedDate {get; set;}
    }
*/
}