public without sharing class PMP_CompanyArticles extends PMP_SearchWrapperStore {
    
    //Getting Articles and Newspaper from Uberflip
    @AuraEnabled
    public static ArticleData getArticles(String partnerId, String langCode) {
        
        ArticleData artData = new ArticleData();
        
        if(partnerId != NULL) {
            
            langCode = String.isBlank(langCode) ? 'en_US' : langCode;	//Default langCode set as English
            String fieldAPIName = 'PMP_English_Txt__c'; // Set the default value as English
            Map<String, String> langUrlMap = new Map<String, String>();
            
            if(langCode.toUpperCase() == 'JA') {	// Assigning language specific field API Name 
                fieldAPIName = 'PMP_Japanese_Txt__c';
            } else if (langCode.toUpperCase() == 'ZH-CN' || langCode.toUpperCase() == 'ZH_CN'|| langCode.toUpperCase() == 'ZH_HANS_CN') { // langCode.toUpperCase() == 'ZH_HANS_CN' : Added as part of new L3 storefront page
                fieldAPIName = 'PMP_Chinese_Txt__c';
            }
            
            // Form langUrlMap which is using lang specific article URL
            for(PMP_InsightTechFeedUrl__mdt url : [SELECT PMP_Feed_URL__c, PMP_Language_Code__c, PMP_isActive__c FROM PMP_InsightTechFeedUrl__mdt where PMP_isActive__c = true]){
                if(url.PMP_Language_Code__c != null) {
                    langUrlMap.put(url.PMP_Language_Code__c.toUpperCase(), url.PMP_Feed_URL__c);
                }
            }
            
            List<PMP_Company__c> partners = [SELECT Id,Name,PMP_Working_Copy_Id__c,PMP_Published_Copy_Id__c,PMP_Is_Working_Copy_Ind__c FROM PMP_Company__c WHERE Id = :partnerId];
            String workingCopyId = partners.size() > 0 ? (partners[0].PMP_Is_Working_Copy_Ind__c ? partners[0].Id : partners[0].PMP_Working_Copy_Id__c) : partnerId;
                
            String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');	// Get the StreamId name from PMP Static Data
            List<PMP_Company_Translation__c> companyTranslations = [SELECT Id,PMP_English_Txt__c,PMP_Chinese_Txt__c,PMP_Japanese_Txt__c,PMP_Company_Information_Id__r.Name
                                                                    FROM PMP_Company_Translation__c WHERE PMP_Company_Information_Id__c = :workingCopyId
                                                                    AND PMP_Field_Nm__c = :streamIdName];	// Get the StramId storing translation record from Company Translation
            
            String streamId = companyTranslations.size() > 0 ? (String)companyTranslations[0].get(fieldAPIName) : '';
            String partnerName = companyTranslations.size() > 0 ? companyTranslations[0].PMP_Company_Information_Id__r.Name : '';
            String viewAllLabel = langUrlMap.get(langCode.toUpperCase()) + partnerName.replaceAll('[^a-zA-Z0-9\\s]','').replace(',','').replace(' ','-');	// Form the ViewAll Link from Partner name
            
            if(String.isNotBlank(streamId)) {
                Http http = new Http();
                HttpRequest authReq = new HttpRequest();
                RequestBody authReqBody = new RequestBody();
                authReqBody.grant_type = 'client_credentials';
                authReqBody.client_id = PMP_Utility.getValue('PMP_Uberflip_Client_Id');	// Get the Uberflip Client Id from PMP Static Data
                authReqBody.client_secret = PMP_Utility.getValue('PMP_Uberflip_Client_Secret');	// Get the Uberflip Client Secret from PMP Static Data
                String endpointURL = PMP_Utility.getValue('PMP_Uberflip_End_Point');	// Get the Uberflip End Point from PMP Static Data
                authReq.setEndpoint(endpointURL + 'authorize');
                authReq.setMethod('POST');
                authReq.setHeader('Content-Type', 'application/json');
                authReq.setBody(JSON.serialize(authReqBody)); 
                try {
                    //HttpResponse authRes = Test.isRunningTest() ? getAuthResopose() : http.send(authReq);	// Make authentication callout
                    HttpResponse authRes = http.send(authReq);	// Make authentication callout
                    
                    if(authRes.getStatusCode() == 200) {	//Check the callout status
                        
                        ResponseBody authResBody = (ResponseBody)JSON.deserialize(authRes.getBody(), ResponseBody.class);	// Parse the authentication response
                        
                        if(authResBody.access_token != NULL) {	// Check the Access Token value
                            HttpRequest itemsReq = new HttpRequest();
                            itemsReq.setEndpoint(endpointURL + 'streams/' + streamId + '/items?hidden=false&published=true&sort=published_at');	//Form the article and newspaper request URL
                            itemsReq.setMethod('GET');
                            itemsReq.setHeader(PMP_StaticConstants_Offering.Authorization,PMP_StaticConstants_Offering.Bearer + authResBody.access_token);
                            HttpResponse itemsRes = http.send(itemsReq);	// Make the callout for getting article and newspaper
                            
                            if(itemsRes.getStatusCode() == 200) {	//Check the callout status
                                if(itemsRes.getBody() != NULL) {
                                    ArticleResponseData artResData = (ArticleResponseData)JSON.deserialize(itemsRes.getBody(), ArticleResponseData.class); // Parse the ca;;out response
                                    List<Data> dataList = artResData.data;
                                    List<Article> articles = new List<Article>();
                                    
                                    if(dataList != NULL && dataList.size() > 0) {
                                        List<Data> resultData = new List<Data>();
                                        for(Integer i=dataList.size(); i>0; i--) {	// Make published date desc. Because, response come as asc order 
                                            if(resultData.size() < 10) {	// Added 10 records as per previous structure
                                                resultData.add(dataList[i-1]);
                                            }
                                        }
                                        
                                        // Form the Article wrapper structure
                                        for(Data dt : resultData) {
                                            Article art = new Article();
                                            art.title = dt.title;
                                            art.link = dt.url;
                                            if(dt.published_at != NULL) {
                                                DateTime dtTime = Datetime.valueOf(dt.published_at.replace('T',' '));	// Convert String to DateTime value
                                                art.publishedDate = dtTime.format('MMM d, yyyy');	// Make date format to "May 22, 2020"
                                            }
                                            //Added as a part of new L3 storefront page
                                            //Start
                                            art.description = dt.description;
                                            if(dt.created_at != NULL) {
                                                art.createdAt = dt.created_at;
                                                DateTime crtDtTime = Datetime.valueOf(dt.created_at.replace('T',' '));
                                                art.createdDate = crtDtTime.format('MMM d, yyyy');
                                            }
                                            //End
                                            articles.add(art);
                                        }
                                        
                                        String url = articles[0].link != null ? articles[0].link : '';
                                        artData.viewAllLabel = url != '' ? url.substring(0, url.lastIndexOf('/')) : '';	// Assign the viewAllLabel value
                                        artData.articleList = articles;	// Assign the articleList value
                                    }
                                } 
                            }
                        }
                    }
                } catch(System.CalloutException exp) {
                    PMP_Utility.logError(exp,'PMP_CompanyArticles');

                }
            }
        }      
        return artData;	//return the Article data
    }    
    
    public class ResponseBody {
        public String token_type {get;set;} 
        public String expires_in {get;set;} 
        public String access_token {get;set;} 
    }
    
    public class RequestBody {
        public String grant_type {get;set;} 
        public String client_id {get;set;} 
        public String client_secret {get;set;}
    }
    
    public class ArticleResponseData {
        public List<Data> data {get;set;} 
        public Meta meta {get;set;} 
    }
    
    public class Data {
        public Integer id {get;set;} 
        public Integer hub_id {get;set;} 
        public String service {get;set;} 
        public String title {get;set;} 
        public String description {get;set;} 
        public String url {get;set;} 
        public String thumbnail_url {get;set;} 
        public String canonical_url {get;set;} 
        public Boolean canonical_redirect {get;set;} 
        public Boolean published {get;set;} 
        public Boolean hidden {get;set;} 
        public Boolean edited {get;set;} 
        public Boolean deleted {get;set;} 
        public Content content {get;set;} 
        public Author author {get;set;} 
        public Boolean hide_publish_date {get;set;} 
        public String external_created_at {get;set;} 
        public String external_modified_at {get;set;} 
        public String created_at {get;set;} 
        public String modified_at {get;set;} 
        public String published_at {get;set;} 
        public Stream stream {get;set;} 
    }
    
    public class Content {
        public String published {get;set;} 
    }
    
    public class Author {
        public Integer id {get;set;} 
        public String first_name {get;set;} 
        public String last_name {get;set;} 
        public String full_name {get;set;} 
        public String username {get;set;} 
        public String email {get;set;} 
        public String bio {get;set;} 
        public String twitter_id {get;set;} 
        public String avatar_url {get;set;} 
    }
    
    public class Stream {
        public Integer id {get;set;} 
        public String title {get;set;} 
        public Integer ordinal {get;set;} 
        public Boolean featured {get;set;} 
    }
    
    public class Meta {
        public Integer count {get;set;} 
        public Integer total_pages {get;set;} 
        
    }
}