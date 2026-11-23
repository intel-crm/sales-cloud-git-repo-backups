/****************************************************************************************************************************************
* Class Name        : PMP_Locale_Inbound_Msg
* Created Date      : 08-03-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sridhar       08-03-2019          This class will get called from inbound message trigger to update the locale information.
*****************************************************************************************************************************************/

public with sharing class PMP_Locale_Inbound_Msg {
    public static String targetLanguage{public get; public set;}
    public PMP_Locale_Inbound_Msg(){}
    
    // Pasre the json string and update the respective local details in offering translation object
    public static void updateLocaleDetails(Map<Id,Core_Integration_Inbound_Message__c> inboundMap)
    {
        
        //Store the parsed rows in this list
        PMP_Locale_JSONParser.wrapOfferingMain parmain;
        String targetLanguageName='';
        List<Core_Integration_Inbound_Message__c> inboundMessages = new List<Core_Integration_Inbound_Message__c>();
        List<Core_Integration_Inbound_Message__c> failedMessages = new List<Core_Integration_Inbound_Message__c>();
        List<PMP_Languages__mdt> languageList = new List<PMP_Languages__mdt>();
        if(inboundMap != null && inboundMap.size() > 0){
            for(Core_Integration_Inbound_Message__c ciim : inboundMap.values()){
                system.debug('ciim:'+ciim.Core_Payload__c);
                String payLoad = ciim.Core_Payload__c;
                targetLanguage=ciim.Core_Payload1__c;
                //Fetch the Target language Name
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
                
                
                try{
                    
                    if (ciim.Core_Processing_Status__c=='Failed')
                    {
                        failedMessages.add(ciim);
                    }
                    else
                    {
                        parmain = PMP_Locale_JSONParser.parse(payLoad);
                        inboundMessages.add(ciim);
                    }
                }catch(Exception e){system.debug('Error occured in parsing the JSON PMP_Locale_Inbound_Msg updateLocaleDetails method due to '+ e.getMessage() + '-' + e.getLineNumber());}
                
            }
        }
        
        if (inboundMessages.size()<=0)
        {
            if (failedMessages.size()>0)
            {
                rePublish(failedMessages);
            }
            return;
            
        }
        
        List<PMP_Partner_Offering_Translation__c> offeringTrans = new List<PMP_Partner_Offering_Translation__c>(); 
        List<PMP_Partner_Offering__c> offerings = new List<PMP_Partner_Offering__c>();
        List<Id> pOfferingId = new List<Id>();
        Map<Id,List<PMP_Locale_JSONParser.WrapOfferings>> pOfferingsWrapper = new Map<Id,List<PMP_Locale_JSONParser.WrapOfferings>>();
        
        try {
            
            //Get list of offering ids and locale offerings.wrapMain will get only one row in general cases but it wont fail even if multiple rows as its in loop
            
            for(PMP_Locale_JSONParser.WrapOfferings wrapOffering : parmain.Offerings){
                
                if (!pOfferingId.contains(wrapOffering.OfferingId)){
                    pOfferingId.add(wrapOffering.OfferingId);
                }
                
                if (pOfferingsWrapper.containsKey(wrapOffering.OfferingId)){
                    pOfferingsWrapper.get(wrapOffering.OfferingId).add(wrapOffering);
                }
                else{
                    pOfferingsWrapper.put(wrapOffering.OfferingId, new List<PMP_Locale_JSONParser.WrapOfferings> {wrapOffering});
                }
            }
            
            
            
            //Build the offering translation list with translated values
            for (PMP_Partner_Offering_Translation__c pOfferTrans : [SELECT Id,PMP_Partner_Offering_Id__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c, PMP_English_Txt__c,PMP_Field_Nm__c 
                                                                    FROM PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c IN:pOfferingId])
            {
                Boolean isTransAvbl = false;
                
                for(PMP_Locale_JSONParser.WrapOfferings wrapOffering : pOfferingsWrapper.get(pOfferTrans.PMP_Partner_Offering_Id__c)){
                    
                    if (targetLanguage == 'EN-US'){
                        switch on pOfferTrans.PMP_Field_Nm__c
                        {   when 'PMP_Partner_Offering_Dsc__c' {pOfferTrans.PMP_English_Txt__c = wrapOffering.OfferingDescription;isTransAvbl = true;}
                         when 'PMP_Partner_Offering_Nm__c' {pOfferTrans.PMP_English_Txt__c = wrapOffering.OfferingName;isTransAvbl = true;}
                         when 'PMP_Partner_Offering_Tag_Line_Txt__c' {pOfferTrans.PMP_English_Txt__c = wrapOffering.TagLine;isTransAvbl = true;}
                        }
                    }
                    else if (targetLanguage == 'JA'){
                        switch on pOfferTrans.PMP_Field_Nm__c
                        {   when 'PMP_Partner_Offering_Dsc__c' {pOfferTrans.PMP_Japanese_Txt__c = wrapOffering.OfferingDescription;isTransAvbl = true;}
                         when 'PMP_Partner_Offering_Nm__c' {pOfferTrans.PMP_Japanese_Txt__c = wrapOffering.OfferingName;isTransAvbl = true;}
                         when 'PMP_Partner_Offering_Tag_Line_Txt__c' {pOfferTrans.PMP_Japanese_Txt__c = wrapOffering.TagLine;isTransAvbl = true;}
                        }
                    }
                    else if (targetLanguage == 'ZH-CN'){
                        switch on pOfferTrans.PMP_Field_Nm__c
                        {   when 'PMP_Partner_Offering_Dsc__c' {pOfferTrans.PMP_Chinese_Txt__c = wrapOffering.OfferingDescription;isTransAvbl = true;}
                         when 'PMP_Partner_Offering_Nm__c' {pOfferTrans.PMP_Chinese_Txt__c = wrapOffering.OfferingName;isTransAvbl = true;}
                         when 'PMP_Partner_Offering_Tag_Line_Txt__c' {pOfferTrans.PMP_Chinese_Txt__c = wrapOffering.TagLine;isTransAvbl = true;}
                        }
                    }
                }
                
                if (isTransAvbl){
                    offeringTrans.add(pOfferTrans);
                }
            }
            
            List<Id> publishedOfferingIds = New List<Id>();
            //Build the list of offerings with translated multi select values
            for ( PMP_Partner_Offering__c offering : [SELECT Id, Name, PMP_Translated_Languages__c, PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Offering_Language_Nm__c,PMP_Partner_Offering_Start_Dt__c
                                                      FROM PMP_Partner_Offering__c where Id IN:pOfferingId])
            {
                
                
                List<String> multiValue = new List<String>();
                if (offering.PMP_Translated_Languages__c != null){
                    multiValue = offering.PMP_Translated_Languages__c.split(';');
                }
                
                if (offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c=='Approved' && offering.PMP_Partner_Offering_Start_Dt__c<=system.today())
                {
                    publishedOfferingIds.add(offering.Id);
                }
                
                for (PMP_Partner_Offering_Translation__c offerTrans : offeringTrans){
                    if (offering.Id == offerTrans.PMP_Partner_Offering_Id__c){
                        if (String.isNotBlank(offerTrans.PMP_English_Txt__c) && !multiValue.contains('English')){
                            multiValue.add('English');
                        }
                        if (String.isNotBlank(offerTrans.PMP_Japanese_Txt__c) && !multiValue.contains('Japanese')){
                            multiValue.add('Japanese');
                        }
                        if (String.isNotBlank(offerTrans.PMP_Chinese_Txt__c) && !multiValue.contains('Simplified Chinese')){
                            multiValue.add('Simplified Chinese');
                        }
                        
                        //For non-english offering, the name field should have english offering name 
                        if (offering.PMP_Offering_Language_Nm__c!='English' && offerTrans.PMP_Field_Nm__c=='PMP_Partner_Offering_Nm__c' && offerTrans.PMP_English_Txt__c !=null)
                        {
                            if (offerTrans.PMP_English_Txt__c.length() > 80)
                                offering.Name=offerTrans.PMP_English_Txt__c.substring(0,80);
                            else
                                offering.Name=offerTrans.PMP_English_Txt__c;
                        }
                    }
                }
                
                //Update offering data if input language is same as target language
                if (offering.PMP_Offering_Language_Nm__c==targetLanguageName)
                {
                    for(PMP_Locale_JSONParser.WrapOfferings inboundOffering : pOfferingsWrapper.get(offering.Id)){
                        offering.PMP_Partner_Offering_Nm__c=inboundOffering.OfferingName;
                        offering.PMP_Partner_Offering_Dsc__c=inboundOffering.OfferingDescription;
                        offering.PMP_Partner_Offering_Tag_Line_Txt__c=inboundOffering.Tagline;
                        if (offering.Name.length() > 80)
                            offering.Name=inboundOffering.OfferingName.substring(0,80);
                        else
                            offering.Name=inboundOffering.OfferingName;
                    }
                }  
                
                if (multiValue.size()>0){
                    offering.PMP_Translated_Languages__c = String.join(multiValue, ';');
                    //Update the status as complete if all 3 languages are completed
                    if (multiValue.size() == 3){
                        offering.PMP_Translation_Lifecycle_Status_nm__c = 'Complete';
                    }
                }
                
                offerings.add(offering);
            }
            
            if (offeringTrans.size() > 0 && offerings.size() > 0){
                Database.update(offeringTrans, true);
                Database.update(offerings, true);
            }
            
            if (publishedOfferingIds.size() > 0)
            {
                publishTranslations(publishedOfferingIds, targetLanguageName);
            }
            
            
        } catch (Exception e) {
            system.debug('Error occured in processing JSON PMP_Locale_Inbound_Msg updateLocaleDetails method due to '+ e.getMessage() + '- @LineNo' + e.getLineNumber()); 
            
        }
        
    }
    @TestVisible
    private static void publishTranslations(List<Id> OfferingIds, String targetLanguageName){
        //Fetch the publish copy Ids
        
        Map<Id,Id> offeringIdMap=new Map<Id,Id>();
        List<Id> publishedOfferingIds = New List<Id>();
        
        //US614314:Gireesh: removing SOQL from loop
        List<PMP_Partner_Offering__c> publishedofferingList = New List<PMP_Partner_Offering__c>([Select Id, PMP_Working_Copy_Id__c from PMP_Partner_Offering__c Where PMP_Working_Copy_Id__c IN :OfferingIds]);
        Map<Id, PMP_Partner_Offering__c> publishedofferingMap = New Map<Id, PMP_Partner_Offering__c>();
        for(PMP_Partner_Offering__c publishedoffering:publishedofferingList){
            publishedofferingMap.put(publishedoffering.PMP_Working_Copy_Id__c, publishedoffering);
        }
        //
        system.debug('publishedofferingMap'+publishedofferingMap);
        system.debug('OfferingIds'+OfferingIds);
        For (Id offeringId:OfferingIds)
        {
            if (publishedofferingMap.size()>0 && publishedofferingMap.containsKey(offeringId))
            {
                publishedOfferingIds.add(publishedofferingMap.get(offeringId).Id);
                offeringIdMap.put(offeringId,publishedofferingMap.get(offeringId).Id);               
            }
        }
        system.debug('publishedOfferingIds'+publishedOfferingIds);
        system.debug('offeringIdMap'+offeringIdMap);
        List<PMP_Partner_Offering_Translation__c> publishedTrans =[SELECT Id,PMP_Partner_Offering_Id__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c, PMP_English_Txt__c,PMP_Field_Nm__c 
                                                                   FROM PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c IN:publishedOfferingIds];
        
        List<PMP_Partner_Offering_Translation__c> clonedTranslations = New  List<PMP_Partner_Offering_Translation__c>();        
        
        //clone the working copy of offering Translations and create publish copy
        for (PMP_Partner_Offering_Translation__c workingCopyTrans : [SELECT Id,PMP_Partner_Offering_Id__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c, PMP_English_Txt__c,PMP_Field_Nm__c 
                                                                     FROM PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c IN:OfferingIds])
            
        {
            PMP_Partner_Offering_Translation__c clonedTrans = workingCopyTrans.clone();
            clonedTrans.PMP_Partner_Offering_Id__c=offeringIdMap.get(workingCopyTrans.PMP_Partner_Offering_Id__c);
            clonedTranslations.add(clonedTrans);
            system.debug('cloned:'+clonedTrans.PMP_Partner_Offering_Id__c);
            
        }
        if(publishedTrans.size()>0)
        {
            delete publishedTrans;
            system.debug('published translations deleted');
        }
        if (clonedTranslations.size()>0)
        {
            insert clonedTranslations;  
            system.debug('published Translations inserted');
            try{
                if(publishedOfferingIds.size()>0){
                    
                    //Gireesh:US542699:publish the translated offering to PIM
                    List<String> pimProductids= new List<String>();
                    List<PMP_Languages__mdt> languageList= new List<PMP_Languages__mdt>();
                    
                    Map<String,PMP_Languages__mdt> languageMap = new Map<String,PMP_Languages__mdt>();                    
                    for(PMP_Languages__mdt lang:[select PIM_Language_Code__c,PIM_Locale_Name__c, Locale_Nm__c from PMP_Languages__mdt]){
                        languageMap.put(lang.Locale_Nm__c,lang);
                    }
                    
                    for (PMP_Partner_Offering__c workingCopyOffering : [SELECT Id,PMP_Partner_Offering_Id__c,PMP_Offering_Language_Nm__c from PMP_Partner_Offering__c Where id IN:publishedOfferingIds])    
                    {
                        
                        
                        pimProductids.add( workingCopyOffering.PMP_Partner_Offering_Id__c);
                        languageList.add(languageMap.get(targetLanguageName));
                    }
                    //Publish to PIM
                    PMP_PIMProduct.generatePIMProduct(publishedOfferingIds, languageList, True, True);
                    //end:Gireesh:US542699
                }
            }catch (Exception e) {
                system.debug('Error occured in Gireesh:US542699 due to '+ e.getMessage() + '- @LineNo' + e.getLineNumber()); 
                
            }
            
        }        
    }
    
    @TestVisible
    private static void rePublish(List<Core_Integration_Inbound_Message__c> failedMessages ){
        List<Core_Integration_Outbound_Message__c> outboundMessages = New List<Core_Integration_Outbound_Message__c>();
        
        //US614314:Gireesh:US614314:Gireesh: removing SOQL from loop
        List<Id>  failedMessageIdList = new List<Id>();
        for(Core_Integration_Inbound_Message__c faildMessage: failedMessages){
            failedMessageIdList.add(faildMessage.Core_Outbound_Message__c);
        }
        
        Map<Id, Core_Integration_Outbound_Message__c> outboundMsgMap = new Map<Id, Core_Integration_Outbound_Message__c>([Select Id,Core_MessageType__c,Core_Payload__c,Core_Tags__c From Core_Integration_Outbound_Message__c where Id IN :failedMessageIdList]);
        //
        try {
            for (Core_Integration_Inbound_Message__c inboundMsg : failedMessages)
            {
                if(inboundMsg.Core_Outbound_Message__c!=null){
                    if(outboundMsgMap.containsKey(inboundMsg.Core_Outbound_Message__c)){
                        Core_Integration_Outbound_Message__c outboundMsg=outboundMsgMap.get(inboundMsg.Core_Outbound_Message__c);
                    Core_Integration_Outbound_Message__c newOutboundMsg=outboundMsg.clone();
                    outboundMessages.add(newOutboundMsg);
                }
            }
            }
            insert outboundMessages;
        } catch (Exception e) {
            system.debug('Error occured in processing JSON PMP_Locale_Inbound_Msg updateLocaleDetails method due to '+ e.getMessage() + '- @LineNo' + e.getLineNumber()); 
            
        }
    }
}