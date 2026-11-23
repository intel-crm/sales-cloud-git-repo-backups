/****************************************************************************************************************************************
* Class Name        : PMP_Partner_Locale_Inbound_Msg
* Description
* ---------------------------------------------------------------------------------------------------------------------------------------
*This class will get called from inbound message trigger to update the locale information.
*****************************************************************************************************************************************/


public with sharing class PMP_Partner_Locale_Inbound_Msg {
    
    //TranslationEOL
    public static Boolean isWorking() {
        return true;
    }
   /* public class InboundPayload {
        public String SourceLanguage {get; set;}
        public List<PartnerData> Partners {get; set;}
    }  
    
    public class PartnerData{
        public String PartnerId {get; set;}
        // public String PartnerName {get; set;}
        public String PartnerDescription {get; set;}
        public String PartnerTagLine {get; set;}
        public String TargetLanguage {get; set;}
        public Date ModifiedDate {get; set;}
        
    }
    
    public static String targetLanguage{public get; public set;}
    // Parse the json string and update the respective local details in Marketing profile translation object
    // Modified by Nikhil 
    public static void updateLocaleDetails(Map<Id,Core_Integration_Inbound_Message__c> inboundMap){
        
        //Store the parsed rows in this list
       // PMP_Partner_Locale_JSONParser.wrapPartnerMain parmain;
        String targetLanguageName='';
        List<Core_Integration_Inbound_Message__c> inboundMessages = new List<Core_Integration_Inbound_Message__c>();
        List<Core_Integration_Inbound_Message__c> failedMessages = new List<Core_Integration_Inbound_Message__c>();
        //List<PMP_Partner_Languages__mdt> languageList = new List<PMP_Partner_Languages__mdt>();
        
        List<PartnerData> partnersData = new List<PartnerData>();  
        
        if(inboundMap != null && inboundMap.size() > 0){
            for(Core_Integration_Inbound_Message__c ciim : inboundMap.values()){
                InboundPayload inboundPayLoad = new InboundPayload();
                inboundPayLoad.Partners = new List<PartnerData>();
                try{
                    inboundPayLoad = (InboundPayload)JSON.deserialize(ciim.Core_Payload__c, InboundPayload.class);
                }catch(Exception e){
                    //system.debug('Error while parsing JSON Core_Integration_Inbound_Message__c.Core_Payload__c : ' + e);
                    PMP_Utility.logError(e,'PMP_CompanyInboundTranslation');
                } 
              //String payLoad = ciim.Core_Payload__c;
              targetLanguage = ciim.Core_Payload1__c;  
              //  Fetch the Target language Name
                 switch on targetLanguage {
                    when 'JA' {
                        targetLanguageName='Japanese';
                    }
                    when 'ZH-CN' {
                        targetLanguageName='Simplified Chinese';
                    }
                    when else {
                        targetLanguageName='English';
                    }
                } 
                
                if (ciim.Core_Processing_Status__c=='Failed' || ciim.Core_Processing_Status__c=='Terminated'){
                    failedMessages.add(ciim);
                }
                else{
                  partnersData.addAll(inboundPayLoad.Partners); 
           //         parmain=PMP_Partner_Locale_JSONParser.parse(payLoad);
                    inboundMessages.add(ciim);
                }
            }
        }
        if (inboundMessages.size()<=0){
        
        if (failedMessages.size()>0){
            //rePublish(failedMessages);
            PMP_SendTranslationExceptionEmail.sendFailureEmail(failedMessages);
        }
        return;
        
        }
        List<PMP_Company_Translation__c> updatedTransList = new List<PMP_Company_Translation__c>(); 
        Map<String,PMP_Company__c> partners = new Map<String,PMP_Company__c>();
        //List<Id> partnerIds = new List<Id>();
        Map<Id,List<PartnerData>> partnerMap = new Map<Id,List<PartnerData>>();
        List<String> approvedPartnerIds = new List<String>();
        
       
        
   //     try {
              for(PartnerData partner : partnersData){
                if (partnerMap.containsKey(partner.PartnerId)){       
                    partnerMap.get(partner.PartnerId).add(partner);
                }
                else{
                    partnerMap.put(partner.PartnerId, new List<PartnerData> {partner});  
                } 
            } 
              // System.debug('partnerMap'+partnerMap);       
            //Build the partner translation list with translated values
            String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
            List<PMP_Company_Translation__c> transList = [SELECT Id,PMP_Company_Information_Id__c,PMP_Company_Information_Id__r.Name,PMP_Company_Information_Id__r.PMP_Translation_Lifecycle_Status_nm__c, PMP_Company_Information_Id__r.PMP_Translated_Languages_Txt__c, PMP_Company_Information_Id__r.PMP_Company_Lifecycle_Status_Nm__c,  PMP_Chinese_Txt__c, PMP_Japanese_Txt__c, PMP_English_Txt__c,PMP_Field_Nm__c 
                                                         FROM PMP_Company_Translation__c where PMP_Company_Information_Id__c IN :partnerMap.KeySet() AND PMP_Field_Nm__c != :streamIdName];
            
            for (PMP_Company_Translation__c trans : transList){
                Boolean isTransAvbl = false;
              PMP_Company__c partner = (PMP_Company__c)trans.getsObject('PMP_Company_Information_Id__r'); //parsing Partner from translation record
                
                //Logic to update translations
                for(PartnerData partnerData : partnerMap.get(trans.PMP_Company_Information_Id__c)){
                    isTransAvbl = true;
                    String temp = '';
                    if (trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.Description)
                    {
                        temp = partnerData.PartnerDescription;
                    }
                    else if (trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.Tagline)
                    {
                        temp = partnerData.PartnerTagLine;  
                    }
                    
                    if (targetLanguage.toUpperCase() == 'EN-US' || targetLanguage.toUpperCase() == 'EN_US'){
                        trans.PMP_English_Txt__c = temp;
                    }
                    else if (targetLanguage.toUpperCase() == 'JA'){
                        trans.PMP_Japanese_Txt__c = temp;
                    }
                    else if (targetLanguage.toUpperCase() == 'ZH-CN' || targetLanguage.toUpperCase() == 'ZH_CN'){
                        trans.PMP_Chinese_Txt__c = temp;
                    }
                    
                }
                if (isTransAvbl){
                    updatedTransList.add(trans);
                }
                //End(0)
                
                //Logic to updated available translation picklist in Partner object
             
                String multiValue = '';
                if(!String.isEmpty(partner.PMP_Translated_Languages_Txt__c) ){
                    multiValue = partner.PMP_Translated_Languages_Txt__c;
                }
 /*               if(!String.isEmpty(trans.PMP_English_Txt__c) && !multiValue.contains(PMP_StaticConstants_Partner.English)){
                    multiValue += ';' + PMP_StaticConstants_Partner.English;                 
                }
                if(!String.isEmpty(trans.PMP_Chinese_Txt__c) && !multiValue.contains(PMP_StaticConstants_Partner.Chinese)){
                    multiValue += ';' + PMP_StaticConstants_Partner.Chinese;                  
                }
                if(!String.isEmpty(trans.PMP_Japanese_Txt__c) && !multiValue.contains(PMP_StaticConstants_Partner.Japanese)){
                    multiValue += ';' + PMP_StaticConstants_Partner.Japanese;
                  
                } */
                
                //Modified by sooriya             
        /*        if(!multiValue.contains(targetLanguageName)){
                    multiValue += ';' +targetLanguageName;
                }
                
                partner.PMP_Translated_Languages_Txt__c = multiValue;
                //End(1)
                
                //Logic to update translation lifecycle status 
                Set<String> multiValueSet = new Set<String>();
                multiValueSet.addAll(multiValue.split(';'));
                
    //          Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Translation_Lifecycle_Status_nm__c.getDescribe(); 
                Schema.DescribeFieldResult fieldResult = PMP_Company__c.PMP_Translated_Languages_Txt__c.getDescribe();      
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                                                  
                 if (multiValueSet.size() == ple.size()){               
                    partner.PMP_Translation_Lifecycle_Status_nm__c = 'Complete';
                }else{
                    partner.PMP_Translation_Lifecycle_Status_nm__c = 'In Progress';
                }
                
                partners.put(partner.Id,partner);
                //End(2)
                
                //Logic to update published translation directly for already approved storefront
                if(partner.PMP_Company_Lifecycle_Status_Nm__c == PMP_StaticConstants_Partner.Approved){
                    approvedPartnerIds.add(partner.Id);
                }
                //End(3)
            }
            
            if (!updatedTransList.isEmpty()){
                //Database.update(updatedTransList, true);
                Database.SaveResult[] results = Database.update(updatedTransList, true);
            	PMP_Utility.logDmlErrors((Object[]) results, 'PMP_Partner_Locale_Inbound_Msg-updateLocaleDetails');
            }
            if(!partners.isEmpty()){
                //Database.update(partners.values(), true);
                Database.SaveResult[] results = Database.update(partners.values(), true);
            	PMP_Utility.logDmlErrors((Object[]) results, 'PMP_Partner_Locale_Inbound_Msg-updateLocaleDetails');
            }
            if (!approvedPartnerIds.isEmpty()){
                publishTranslations(approvedPartnerIds);
            }
            
        //}catch (Exception e) {
        //    system.debug('Error occured in processing JSON PMP_Partner_Locale_Inbound_Msg updateLocaleDetails method due to '+ e.getMessage() + '- @LineNo' + e.getLineNumber()); 
        //}     
    }     
    
    @TestVisible
    private static void publishTranslations(List<String> approvedPartnerIds){
        
        Map<String,String> workPubIdMap = new Map<String,String>();
        List<PMP_Company_Translation__c> updatedTransList = new List<PMP_Company_Translation__c>();
        
        List<PMP_Company__c> publishedPartners = [SELECT Id,PMP_Working_Copy_Id__c FROM PMP_Company__c WHERE PMP_Working_Copy_Id__c IN :approvedPartnerIds];
        
        for(PMP_Company__c comp: publishedPartners){
            workPubIdMap.put(comp.PMP_Working_Copy_Id__c, comp.Id);
        }
        String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
        List<PMP_Company_Translation__c> existingTrans = [SELECT id FROM PMP_Company_Translation__c WHERE PMP_Company_Information_Id__c IN :workPubIdMap.values() AND PMP_Field_Nm__c != :streamIdName];
        if(!existingTrans.isEmpty()){
            delete existingTrans;
        }
        
        List<PMP_Company_Translation__c> updatedTrans = [SELECT Id,Name,PMP_English_Txt__c,PMP_Chinese_Txt__c,PMP_Japanese_Txt__c,PMP_Field_Nm__c,PMP_Company_Information_Id__c 
                                                         FROM PMP_Company_Translation__c WHERE PMP_Company_Information_Id__c IN :workPubIdMap.KeySet() AND PMP_Field_Nm__c != :streamIdName];
        
        for(PMP_Company_Translation__c trans: updatedTrans){
            PMP_Company_Translation__c clonedTrans = trans.clone();
            clonedTrans.PMP_Company_Information_Id__c = workPubIdMap.get(trans.PMP_Company_Information_Id__c);
            updatedTransList.add(clonedTrans);
        }
        if(!updatedTransList.isEmpty()){
            insert updatedTransList;
        }
    }
    @TestVisible
    private static void rePublish(List<Core_Integration_Inbound_Message__c> failedMessages ){
        List<Core_Integration_Outbound_Message__c> outboundMessages = New List<Core_Integration_Outbound_Message__c>();
        
        //Sooriya: removing SOQL from loop
        List<Id>  failedMessageIdList = new List<Id>();
        for(Core_Integration_Inbound_Message__c faildMessage: failedMessages){
            failedMessageIdList.add(faildMessage.Core_Outbound_Message__c);
        }
        
        Map<Id, Core_Integration_Outbound_Message__c> outboundMsgMap = new Map<Id, Core_Integration_Outbound_Message__c>([Select Id,Core_MessageType__c,Core_Payload__c,Core_Tags__c From Core_Integration_Outbound_Message__c where Id IN :failedMessageIdList]);
        //
        
        try {
            for (Core_Integration_Inbound_Message__c inboundMsg : failedMessages)
            {
                if (inboundMsg.Core_Outbound_Message__c!=null){
                    if(outboundMsgMap.containsKey(inboundMsg.Core_Outbound_Message__c)){
                        //Core_Integration_Outbound_Message__c outboundMsg=[Select Id,Core_MessageType__c,Core_Payload__c,Core_Tags__c From Core_Integration_Outbound_Message__c where Id=:inboundMsg.Core_Outbound_Message__c LIMIT 1];
                        Core_Integration_Outbound_Message__c outboundMsg=outboundMsgMap.get(inboundMsg.Core_Outbound_Message__c);
                    Core_Integration_Outbound_Message__c newOutboundMsg=outboundMsg.clone();
                    outboundMessages.add(newOutboundMsg);
                }
            }
            }
            insert outboundMessages;
        }catch (Exception e) {
            //system.debug('Error occured in processing JSON PMP_Partner_Locale_JSONParser updateLocaleDetails method due to '+ e.getMessage() + '- @LineNo' + e.getLineNumber()); 
            PMP_Utility.logError(e,'PMP_CompanyInboundTranslation');
            
        }
    }  
*/
    
}