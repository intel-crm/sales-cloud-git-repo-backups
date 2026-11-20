public with sharing  class PMP_SearchCompanyArticles extends PMP_SearchWrapperStore {
            
        @AuraEnabled(cacheable=true)
        public static ArticleData getPartnerArticles(String partnerId, String langCode){
            Map<String,String> langUrlMap = new Map<String,String>();
            
            List<PMP_InsightTechFeedUrl__mdt> urlList = [SELECT PMP_Feed_URL__c, PMP_Language_Code__c, PMP_isActive__c
                                                          from PMP_InsightTechFeedUrl__mdt where PMP_isActive__c = true];
            
            for(PMP_InsightTechFeedUrl__mdt url : urlList){
                langUrlMap.put(url.PMP_Language_Code__c, url.PMP_Feed_URL__c);
            }
            
            PMP_Company__c partner;
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                partner = [SELECT Id ,Name from PMP_Company__c where Id =:partnerId];
            }
            
            String lang = '';
            if(PMP_StaticConstants_Partner.languagesSupported.contains(langCode)){
                lang = langCode;
            }else{
                lang = PMP_StaticConstants_Partner.EN_US;
            }
            
            
            
            String partnerName = partner.Name;
            String urlPartnerName = partnerName.replaceAll('[^a-zA-Z0-9\\s]','').replace(',','').replace(' ','-');
            String rssURL = langUrlMap.get(langCode) + urlPartnerName + '.rss';
            
            
            
            
            ArticleData articleData=new ArticleData();
            articleData.viewAllLabel=langUrlMap.get(langCode) + urlPartnerName;
            
            List<Dom.XMLNode> rssList = getRssFeed(rssURL);
            //system.debug('ARTICLES :');
            //system.debug(rssList);
            List<Article> companyArticles = new List<Article>();
            List<Article> resultList = new List<Article>();
            
            for(Dom.XMLNode article : rssList){
                Article art = new Article();
                for(Dom.XMLNode attribute : article.getChildren()){
                    if(attribute.getName() == 'title')
                        art.title = attribute.getText();
                    if(attribute.getName() == 'link')
                        art.link = attribute.getText();
                    if(attribute.getName() == 'pubDate'){
                        String temp = attribute.getText();
                        List<String> tempSplit = temp.split(' ');
                        
                        //system.debug(tempSplit);
                        String dt = tempSplit[2]+ ' '+tempSplit[1] + ', '+ tempSplit[3];
                        art.publishedDate = dt;
                    }
                    
                }
                companyArticles.add(art);
                
            }
            
            Integer len = companyArticles.size();
            if(len > 10){
                for(Integer i =0 ; i<10; i++){
                    resultList.add(companyArticles[i]);
                }
            }else{
                resultList = companyArticles;
            }
            
            articleData.articleList=resultList;
            
            return articleData;
        }
    
    static public List<Dom.XMLNode> getRSSFeed(string URL) {
        List<Dom.XMLNode> rssList = new List<Dom.XMLNode>();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        // url that returns the XML in the response body  
        
        req.setEndpoint(URL);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        
        Dom.Document doc = new Dom.Document();
        if(res.getStatusCode()!=404){
            doc = res.getBodyDocument();
            
            Dom.XMLNode rss = doc.getRootElement();
            //System.debug('@@' + rss.getName());
            
            
            for(Dom.XMLNode child : rss.getChildren()) {
                //System.debug('@@@' + child.getName());
                for(Dom.XMLNode channel : child.getChildren()) {
                    //System.debug('@@@@' + channel.getName());
                    
                    if(channel.getName() == 'item') {
                        rssList.add(channel);
                    }
                }
            }
        }
        
        
        
        return rssList;
        
        
        
    }
    
    
}