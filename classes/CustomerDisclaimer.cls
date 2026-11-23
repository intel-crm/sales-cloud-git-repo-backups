/****************************************************************************************************************************************
* Class Name  : CustomerDisclaimer 
* Created Date: 13-07-2020
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ealisha/Sneha        13-07-2020         Controller class to present Disclaimer to External User.
*****************************************************************************************************************************************/
public without sharing class CustomerDisclaimer {
    public static String logEntryMsg = '';  
  
    public class DisclaimerDetails{
        @AuraEnabled public String tncId {get; set;}
        @AuraEnabled public String docBody {get; set;}    
        @AuraEnabled public String communityUrl {get; set;} 
    
    }    
    public static Map<String,Terms_and_Conditions__c> tncMap = new Map<String,Terms_and_Conditions__c>{};
        
        //Reading from custom object
        @AuraEnabled
        public static String redirect(String siteUrl){
            System.debug('Here in redirect!!');
            String toBeRedirectedToNDA = 'false';
            String query;
            Map<String,String> contentLangToValueMap = new Map<String,String>{};
                Map<String,Terms_and_Conditions__c> custPermToTAndCMap = new Map<String,Terms_and_Conditions__c>{};
                    Map<String,Terms_and_Conditions__c> tncLangToTAndCMap = new Map<String,Terms_and_Conditions__c>{};
                        Map<Id,Datetime> tncToAcceptedDate = new Map<Id,Datetime>{}; 
                            try{
                                //fetching Community URL from Network ID 
                                // To resolve issue: by Editing Community URL Customers are able to access Community.
                                ID communityId = Network.getNetworkId();
                                String baseUrl='';
                                system.debug('**communityId**'+communityId);
                                if(communityId  != null){baseUrl = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :communityId].UrlPathPrefix;}
                                
                                baseUrl ='%'+baseUrl+'%';
                                system.debug('**baseUrl**'+baseUrl);
                                String userId = UserInfo.getUserId();
                                Schema.DescribeFieldResult lang = Terms_and_Conditions__c.Content_Language_nm__c.getDescribe();
                                List<Schema.PicklistEntry> langValues = lang.getPicklistValues();
                                if(langValues != null){
                                    for (Schema.PicklistEntry a : langValues){
                                        String[] langToTrans = a.getValue().split(':');
                                        contentLangToValueMap.put(langToTrans[1],a.getValue()); 
                                    }  
                                }        
                            
                                //Get the user language.
                                String userLang = UserInfo.getLanguage();
                                if(String.isBlank(userLang)){userLang = 'en_US';}
                                
                                /* SR Commenting as Userinfo was being called twice */
                                //String userLang = (UserInfo.getLanguage() != null) ? UserInfo.getLanguage() : 'en_US';
                                
                                
                                String engTrans = contentLangToValueMap.get('en_US');
                                String contentTrans = contentLangToValueMap.get(userLang)==null ? contentLangToValueMap.get('en_US') : contentLangToValueMap.get(userLang);
                                query = 'Select Site_URL_txt__c,Id,Name,Active_Indicator_ind__c,Channel_Program_id__c,Program_Name_txt__c,Custom_Permission_txt__c,Validity_in_mnths_nbr__c,NDA_Updated_Date_dt__c,Content_Language_nm__c'+
                                    ' from Terms_and_Conditions__c where Content_Language_nm__c in (\''+String.escapeSingleQuotes(contentTrans)+'\',\''+String.escapeSingleQuotes(engTrans)+'\') and Site_URL_txt__c LIKE \''+baseUrl+'\' and Active_Indicator_ind__c=true';
                                system.debug('query:'+query);
                            
                                List<Terms_and_Conditions__c> tAndConRecds = Database.query(query);
                                /* SR Added null checks */
                              
                                Map<String,Terms_and_Conditions__c> userLangcpToTAndCMap = new Map<String,Terms_and_Conditions__c>{};
                                    Map<String,Terms_and_Conditions__c> engLangcpToTAndCMap = new Map<String,Terms_and_Conditions__c>{};
                                        if(tAndConRecds != null && !tAndConRecds.isEmpty()){
                                            for(Terms_and_Conditions__c tc : tAndConRecds){
                                                if(tc.Content_Language_nm__c.split(':')[1] == userLang){
                                                    userLangcpToTAndCMap.put(tc.Custom_Permission_txt__c,tc);
                                                }
                                                else if(tc.Content_Language_nm__c.split(':')[1] == 'en_US'){
                                                    engLangcpToTAndCMap.put(tc.Custom_Permission_txt__c,tc);
                                                }
                                                
                                            }
                                        }
                                if(userLangcpToTAndCMap != null && !userLangcpToTAndCMap.isEmpty()){
                                    custPermToTAndCMap = userLangcpToTAndCMap;
                                }
                                else{
                                    custPermToTAndCMap = engLangcpToTAndCMap;
                                }
                            
                                system.debug('custPermToTAndCMap:'+custPermToTAndCMap);
                                //check if user has already accepted
                                /*SR : Updated variable name */
                                List<Customer_Disclaimer__c> discAcceptanceDetails = Database.query('Select User_id__c,Program_txt__c,Terms_and_Conditions_id__c,NDA_Acceptance_Date_dtm__c,Site_URL_txt__c from Customer_Disclaimer__c where User_id__c=:userId and Site_URL_txt__c LIKE \''+baseUrl+'\'');
                                //List<Customer_Disclaimer__c> discAcceptanceDetails = Database.query('Select User_id__c,Program_txt__c,Terms_and_Conditions_id__c,NDA_Acceptance_Date_dtm__c,Site_URL_txt__c from Customer_Disclaimer__c where User_id__c=:userId and Site_URL_txt__c =:siteUrl');
                                Map<Id,Customer_Disclaimer__c> userIdToDisRec = new Map<Id,Customer_Disclaimer__c>{};
                                    system.debug('**discAcceptanceDetails**'+discAcceptanceDetails);
                                    if(discAcceptanceDetails != null && !discAcceptanceDetails.isEmpty()){
                                        for(Customer_Disclaimer__c cd:discAcceptanceDetails){
                                            tncToAcceptedDate.put(cd.Terms_and_Conditions_id__c,cd.NDA_Acceptance_Date_dtm__c);
                                        }            
                                    }
                                system.debug(' :'+tncToAcceptedDate);
                            	system.debug(' yyyyyyyyyyy:'+custPermToTAndCMap);
                                if(custPermToTAndCMap != null && !custPermToTAndCMap.isEmpty()){
                                    for(String custPerm:custPermToTAndCMap.keySet()){
                                        system.debug('xxxxxxxx'+custPerm);
                                        if(FeatureManagement.checkPermission(custPerm)){
                                            Boolean toBeRedirected = checkNDAValidity(discAcceptanceDetails,custPermToTAndCMap.get(custPerm),tncToAcceptedDate);
                                            if(toBeRedirected){
                                                toBeRedirectedToNDA = 'true';
                                                tncMap.put(custPermToTAndCMap.get(custPerm).Id,custPermToTAndCMap.get(custPerm));
                                            }
                                        }            
                                    }
                                }
                                system.debug('tncMap:'+tncMap);
                        }
            catch(exception ex){toBeRedirectedToNDA='';logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Redirect error from Customer Disclaimer');
                           }        
        return toBeRedirectedToNDA;
    }
    
    public static Boolean checkNDAValidity(List<Customer_Disclaimer__c> accdt,Terms_and_Conditions__c tc,Map<Id,Datetime> tncToAcceptedDate){
        Boolean toBeRedirected = false;        
        
        //system.now().dateGMT():Return the Date component of a Datetime in the GMT time zone.
        //if user has never logged in and disclaimer updated date is past date or
        //user has logged in before but nda accepted date is less than latest nda date or
        //user has logged in before but nda accepted date has crossed nda validity date 
        if((tc.NDA_Updated_Date_dt__c == null || String.valueOf(tc.NDA_Updated_Date_dt__c) =='')&&
           (accdt == null || accdt.size()==0 ||
            (!tncToAcceptedDate.containsKey(tc.Id))||
            (tncToAcceptedDate.containsKey(tc.Id) && tncToAcceptedDate.get(tc.Id).date().addMonths(Integer.valueOf(tc.Validity_in_mnths_nbr__c)) < system.now().dateGMT())
           )
          ){
              toBeRedirected = true;  
          }
        else if((accdt == null || accdt.size()==0 && system.now().dateGMT() >= Date.valueOf(tc.NDA_Updated_Date_dt__c)) || 
                (!tncToAcceptedDate.containsKey(tc.Id) && system.now().dateGMT() >= Date.valueOf(tc.NDA_Updated_Date_dt__c))||
                ((tncToAcceptedDate.containsKey(tc.Id) && tncToAcceptedDate.get(tc.Id).date() > Date.valueOf(tc.NDA_Updated_Date_dt__c)) &&
                 tncToAcceptedDate.get(tc.Id).date().addMonths(Integer.valueOf(tc.Validity_in_mnths_nbr__c)) < system.now().dateGMT())||
                (tncToAcceptedDate.containsKey(tc.Id) && tncToAcceptedDate.get(tc.Id).date() < Date.valueOf(tc.NDA_Updated_Date_dt__c) &&
                 system.now().dateGMT() > Date.valueOf(tc.NDA_Updated_Date_dt__c))
               ){
                   toBeRedirected = true;
               }
        return toBeRedirected;
    }
    
    private static String getNDAContent(String contentVersionId){
        String docBody ='';
        HttpRequest req = new HttpRequest();
        String endpointUrl = '';
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');        
        req.setClientCertificateName(Label.Core_Self_Signed_Cert);
        String domainUrl = Url.getOrgDomainUrl().toExternalForm();   //URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('#07 domainUrl:' + domainUrl);
        domainUrl = (domainUrl.lastIndexOf('/') == domainUrl.length()-1) ? domainUrl : domainUrl+'/';
        system.debug('#07 domainUrl after edit:' + domainUrl);
        endpointUrl = domainUrl+Label.CustomerDisclaimerApi+contentversionId+'/VersionData';
        req.setEndpoint(endpointUrl);
        req.setMethod('GET'); 
        system.debug('**req**'+req);
        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug('#09 res: ' + res.getBody());              
        if(res != null && res.getStatusCode() == 200){
            docBody = res.getBody();
        }
        return docBody;
    }
    
    @AuraEnabled
    public static List<DisclaimerDetails> getResourceName(String siteUrl) 
    {
        String nDAtoBeDisplayed='false';
        List<DisclaimerDetails> ddList = new List<DisclaimerDetails>{};
            Map<String,Id> progToRecId = new Map<String,Id>();
        try{
            system.debug('**siteUrl**'+siteUrl);
            nDAtoBeDisplayed = redirect(siteUrl);
            if(nDAtoBeDisplayed == 'true'){
                system.debug('Redirect called');
                if(tncMap != null && !tncMap.isEmpty()){                    
                    Map<String,String> disclaimerContent = loadNDABody(tncMap.keySet());   
                    System.debug(' disc '+disclaimerContent);
                    for(Terms_and_Conditions__c tnc : tncMap.values())  {
                        DisclaimerDetails dd = new DisclaimerDetails();
                        dd.docBody='';
                        dd.tncId = tnc.Id;
                        dd.communityUrl = tnc.Site_URL_txt__c;
                        if(disclaimerContent != null && !disclaimerContent.isEmpty()){
                            dd.docBody = getNDAContent(disclaimerContent.get(tnc.Id));
                        }                        
                        ddList.add(dd);
                    }       
                }
                
            }
            system.debug('ddList:'+ddList);
        }
        catch(exception ex){
            ddList=null; 
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Error from GetResource');
        }
        return ddList;   
    }
    
    public static Map<String,String> loadNDABody(Set<String> linkedEntitySet){
        Map<String,String> cvToLeMap = new Map<String,String>();
        try{
            Map<String,String> contentLinkToContentVersion = new Map<String,String>();
            if(linkedEntitySet != null && !linkedEntitySet.isEmpty()){
                for(ContentDocumentLink cdl : [SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId IN: linkedEntitySet]){
                    if(cdl.ContentDocumentId != null){
                        contentLinkToContentVersion.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
                    }
                }
                if(contentLinkToContentVersion != null){
                    for(contentversion cv : [select id,ContentDocumentId from contentversion where ContentDocumentId IN:contentLinkToContentVersion.keySet()]){                 
                        if(contentLinkToContentVersion.containsKey(cv.ContentDocumentId)){
                            cvToLeMap.put(contentLinkToContentVersion.get(cv.ContentDocumentId),cv.ID);
                        }                   
                    }
                }
            }
            system.debug(' ##cvToLeMap '+cvToLeMap);
        }
        catch(exception ex){ logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Error from LoadNDABody');
                           }
        return cvToLeMap;
    }
    
    
    @AuraEnabled
    public static Map<Id,Boolean> agreementSave(Map<Id,String>tncToUrlMapToStore){
        Boolean success=false;
        Map<Id,Boolean> outputMap = new Map<Id,Boolean>{};
            List<Customer_Disclaimer__c> disclaimerListToUpsert=new List<Customer_Disclaimer__c>{};
                Map<String,Customer_Disclaimer__c> tncIdTondisMap = new Map<String,Customer_Disclaimer__c>{}; 
                    Map<Id,String>inputMap = new Map<ID,String>();
        try{
            Id userId = UserInfo.getUserId(); 
            system.debug('cdMtd from save:'+JSON.serialize(tncToUrlMapToStore));
            if(tncToUrlMapToStore != null && !tncToUrlMapToStore.isEmpty()){
                for(Customer_Disclaimer__c disRec : [select id,Terms_and_Conditions_id__c,
                                                     NDA_Acceptance_Date_dtm__c,
                                                     Program_txt__c,Site_URL_txt__c,
                                                     User_id__c 
                                                     from Customer_Disclaimer__c 
                                                     where Terms_and_Conditions_id__c in: tncToUrlMapToStore.keySet()
                                                     and User_id__c =: userId]){
                                                         String key = disRec.Terms_and_Conditions_id__c+':'+disRec.User_id__c+':'+disRec.Site_URL_txt__c;                                     
                                                         tncIdTondisMap.put(key,disRec);                   
                                                     } 
                inputMap = tncToUrlMapToStore;
            } 
            system.debug('tncIdTondisMap:'+tncIdTondisMap);
            
            for(Id tncId:inputMap.keySet()){
                if(inputMap.get(tncId) != null){
                    String keyToBeChecked = tncId+':'+userId+':'+inputMap.get(tncId);
                    Customer_Disclaimer__c cdToUpd = new Customer_Disclaimer__c();
                    cdToUpd.NDA_Acceptance_Date_dtm__c = system.now();//Returns the current date and time in the GMT time zone.
                    cdToUpd.User_id__c=userId;
                    cdToUpd.Terms_and_Conditions_id__c=tncId;
                    cdToUpd.Site_URL_txt__c = inputMap.get(tncId); 
                    
                    if(tncIdTondisMap.containsKey(keyToBeChecked)){
                        cdToUpd.Id = tncIdTondisMap.get(keyToBeChecked).Id;
                    }
                    disclaimerListToUpsert.add(cdToUpd);
                    
                    outputMap.put(tncId,true);
                }
                else{
                    outputMap.put(tncId,false);
                }
            }
            
            system.debug('disclaimerListToUpsert:'+disclaimerListToUpsert);
            if(disclaimerListToUpsert != null){
                upsert disclaimerListToUpsert;
            }
        }
        catch(exception ex){
            outputMap = null;
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Error from save NDA Acceptance');
        }
        return outputMap;
    }
}