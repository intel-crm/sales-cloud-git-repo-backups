@RestResource(urlMapping='/caching')
global class SKPOC_Caching {
    public static Integer initTime {get;set;}
    public static  Map<String, String> headers = RestContext.request.headers;
    
    @HttpGet
    global static CaseResponse getCases(){
        Long apiEntryTime = System.currentTimeMillis();
        CaseResponse response = new CaseResponse();
        SKPOC_Caching handler = new SKPOC_Caching();
        
        System.debug(' >>>>> enable Cache ? '+headers.get('enableCache'));
        if('True'.equalsIgnoreCase(headers.get('enableCache')) ){
            Long initStart = System.currentTimeMillis();
            ApexPages.StandardSetController scFromCache = (ApexPages.StandardSetController)Cache.Session.get('CASES1'); 
            Long initEnd = System.currentTimeMillis();
            if( scFromCache != null){
                System.debug(' +++++++++++++ >>>>>>>>>>.. Set Controller From cache  '+ scFromCache);   
                System.debug(' Session FOUND ..'+scFromCache+ '===== '+scFromCache+ '===== getPageNumber '+scFromCache.getPageNumber()+ '===== Page Size '+scFromCache.getPageSize() );
                
            }else{
                System.debug(' Session NOT FOUND ..');
                initStart = System.currentTimeMillis();
                scFromCache = handler.setCntrlr;
                Cache.Session.put('CASES1', scFromCache);   
                initEnd = System.currentTimeMillis();
                
            }
            initTime = (Integer.valueOf(initEnd - initStart));
            
            System.debug(' +++++++++++++ >>>>>>>>>>..calling get  records started ');
            Long fetchRecordsStartTime = System.currentTimeMillis();
            response.mycases = scFromCache.getRecords();            
            Long fetchRecordsEndTime = System.currentTimeMillis();
            response.z_getRecordsExecutionTime = (Integer.valueOf(fetchRecordsEndTime - fetchRecordsStartTime));
            System.debug(' +++++++++++++ >>>>>>>>>>..calling get  records Ended ');      
            
            response.z_setCntrlrInitializationTime = initTime;
            response.z_totalRecords = scFromCache.getResultSize();
            response.z_numberOfPages = response.z_totalRecords / scFromCache.getPageSize();
            response.z_currentPage = scFromCache.getPageNumber();
            
            Long apiExitTime = System.currentTimeMillis();
            response.z_totalProcessingTime = Integer.valueOf(apiExitTime - apiEntryTime);        
            System.debug(' +++++++++++++ >>>>>>>>>>.. '+ response.z_totalProcessingTime );
            
            
            
        }else{
            System.debug(' +++++++++++++ >>>>>>>>>>..calling get  records started ');
            Long fetchRecordsStartTime = System.currentTimeMillis();
            response.mycases = handler.setCntrlr.getRecords();         
            Long fetchRecordsEndTime = System.currentTimeMillis();
            response.z_getRecordsExecutionTime = (Integer.valueOf(fetchRecordsEndTime - fetchRecordsStartTime));
            System.debug(' +++++++++++++ >>>>>>>>>>..calling get  records Ended ');
            
            response.z_setCntrlrInitializationTime = initTime;
            response.z_totalRecords = handler.setCntrlr.getResultSize();
            response.z_numberOfPages = response.z_totalRecords / handler.setCntrlr.getPageSize();
            response.z_currentPage = handler.setCntrlr.getPageNumber();
            
            Long apiExitTime = System.currentTimeMillis();
            response.z_totalProcessingTime = Integer.valueOf(apiExitTime - apiEntryTime);        
            System.debug(' +++++++++++++ >>>>>>>>>>.. '+ response.z_totalProcessingTime );
            
        }
        
        
        return response;
        
    }
    
    global class CaseResponse{
        public List<case> myCases {get;set;}
        public Integer z_totalProcessingTime {get;set;}
        public Integer z_setCntrlrInitializationTime {get;set;}
        public Integer z_getRecordsExecutionTime {get;set;}
        public Integer z_numberOfPages{get;set;}
        public Integer z_totalRecords{get;set;}
        public Integer z_currentPage{get;set;}
        
    }
    
    public  ApexPages.StandardSetController setCntrlr {
        get {
            System.debug(' +++++++++++++ TRUETRUTRUE setCntrlr '+setCntrlr);
            if(setCntrlr == null) {
                Long initStart = System.currentTimeMillis();
                this.setCntrlr = new ApexPages.StandardSetController(Database.getQueryLocator('Select Id, CaseNumber FROM Case limit 10000'));
                this.setCntrlr.setPageSize(Integer.valueOf(headers.get('pageSize')));
                this.setCntrlr.setPageNumber(Integer.valueOf(headers.get('pageNumber')));    
                
                Long initEnd = System.currentTimeMillis();
                initTime = (Integer.valueOf(initEnd - initStart));
                System.debug(' +++++++++++++ >>>>>>>>>>.. Initalizing  Time  '+ initTime+' Set controller '+this.setCntrlr);
            }
            return setCntrlr;
        }
        set;
    } 
    
}