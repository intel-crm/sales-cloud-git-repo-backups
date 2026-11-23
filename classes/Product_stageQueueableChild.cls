public class Product_stageQueueableChild implements Queueable,Database.AllowsCallouts { 
    public Integer BatchSize = 100;
    public Product_stageQueueableChild followupJob;    
    public Map<String,string> l5_l4Map = new Map<String,string>();
    public String accessToken;
    public List<String> recordList = new List<String>();

    public Product_stageQueueableChild(list<String> recordList,Map<String,string> l5_l4Map,String accessToken) {
        this.recordList = recordList;
        this.l5_l4Map = l5_l4Map;
        this.accessToken = accessToken;
        
    }    
    // Process the records
    public void execute(QueueableContext context) {    
        Set<String> L5ProductEPMIdSet= new Set<String>();     
        System.debug('------------------- inside child queueable -----------------------');
        if(recordList == null || recordList.isEmpty()){
            return; 
        }        
        Integer listSize = this.recordList.size();      
        List<String> currentBatch = new List<String>();        
        if(listSize > BatchSize){
            // take the last <BatchSize> records from the top and put the rest in the next queueable
            for (Integer i = listSize-1; i >= listSize-BatchSize; i--) {
                currentBatch.add(this.recordList.remove(i));
            }
            followupJob = new Product_stageQueueableChild(this.recordList,l5_l4Map,accessToken);            
        }else{
            currentBatch = this.recordList;
            System.debug('currentBatch Size --- '+recordList.size());
        } 
        if(currentBatch.size()>0 && !currentBatch.isEmpty()){

            System.debug('Processing ' + currentBatch.size() + ' l4Ids');
            System.debug('currentBatch --- '+currentBatch);
            for(String L4ProductCategoryId: currentBatch){
                Http http = new Http();
                HttpRequest requestL5 = new HttpRequest();
                HttpResponse responseL5;                        
                requestL5.setEndpoint((Product3_Endpoints__c.getValues('products_id').Endpoint__c)+L4ProductCategoryId+'?localeGeoId=en-US');                        
                requestL5.setHeader('Authorization', 'Bearer '+accessToken);
                requestL5.setMethod('GET');
                requestL5.setTimeout(60000);
                responseL5 = http.send(requestL5);
                if(responseL5.getStatusCode() == 200) {                            
                    Map<String, Object> L5ProductResults = (Map<String, Object>) JSON.deserializeUntyped(responseL5.getBody());
                    //L5ProductCategoryIdList.add((String)L5ProductResults.get('id'));
                    //system.debug('L5ProductResults::'+L5ProductResults.get('id'));
                    //List<Object> orderingInfoList = new List<Object>();
                    if(((Object)L5ProductResults.get('orderingInfo'))!=null ){
                        List<Object> orderingInfoList = (List<Object>)L5ProductResults.get('orderingInfo');
                        for(Object orderingInfo :orderingInfoList){
                            Map<String, Object> orderInfoAttributeMap = (Map<String, Object>)orderingInfo; 
                            List<Object> orderInfoAttributeList = (List<Object>)orderInfoAttributeMap.get('attributes');
                            for(Object orderInfoAttribute:orderInfoAttributeList){
                                Map<String, Object> orderInfoAttributeDetailsMap = (Map<String, Object>)orderInfoAttribute;
                                if(((String)orderInfoAttributeDetailsMap.get('label'))=='EPM ID'){
                                    L5ProductEPMIdSet.add((String)orderInfoAttributeDetailsMap.get('value'));
                                    l5_l4Map.put((String)orderInfoAttributeDetailsMap.get('value'),L4ProductCategoryId);
                                }
                            }    
                        }
                    }  
                }                
            }            
            System.debug('L5ProductEPMIdSet ---- '+L5ProductEPMIdSet);
            System.debug('L5ProductEPMIdSet size ---- '+L5ProductEPMIdSet.size());
            System.debug('l5_l4Map ---- '+l5_l4Map);
            System.debug('l5_l4Map size ---- '+l5_l4Map.size());
        }
        if(followupJob != null){
            if(!Test.isRunningTest()){
                System.enqueueJob(followupJob);
            }
        }else{
            List<String> csvRowValues = new List<String>();
            String csvColumnHeader;
            csvColumnHeader='level 4 EPM Id'+','+'Level 5 EPM Id';
            System.debug('csvColumnHeader ---- '+csvColumnHeader);
            for(String str : l5_l4Map.keyset()){
                String csvRowVal= l5_l4Map.get(str) + ','+str;
                csvRowValues.add(csvRowVal);
            }
            System.debug('csvRowValues --- '+csvRowValues);
            System.debug('csvRowValues size--- '+csvRowValues.size());   
            String csvFile = csvColumnHeader+'\n'+ String.join(csvRowValues,'\n');
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            MetadataService.StaticResource  staticResource= new MetadataService.StaticResource();
            staticResource.fullName = 'L4_L5_PIM_Data';
            staticResource.contentType = 'text/csv';
            staticResource.cacheControl = 'public';
            staticResource.Content = EncodingUtil.base64Encode(Blob.valueOf(csvFile));
            service.createMetadata(new List<MetadataService.Metadata> { staticResource });
        }
    }
}