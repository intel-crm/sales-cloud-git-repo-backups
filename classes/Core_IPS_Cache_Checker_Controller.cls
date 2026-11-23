public with sharing class Core_IPS_Cache_Checker_Controller {
    public static Set<String> sessionkey{get;set;}    
    public static Set<String> otherMethodkey{get;set;}
    public static Double capacity{get;set;}
    public static Long maxTime{get;set;}
    public static Map<String,String> cacheData{get;set;}
    public static Map<String,String> otherCacheMethod{get;set;}
    public static  Core_IPS_Deflected_Object__c deflectedObj{get;set;}
    public static Id deflectedId{get;set;}
    public static String deflectedName{get;set;}
     private static final String PARTITION_NAME = system.label.Core_IPS_Platform_Cache_Name;
   
    public static Cache.Partition partition;
    public Core_IPS_Cache_Checker_Controller(){
         Cache.Partition partition = Cache.Session.getPartition(PARTITION_NAME);
       
       sessionkey=partition.getKeys();
        capacity=partition.getcapacity();
        maxTime=partition.getMaxGetTime();
        cacheData=new Map<String,String>();
        for(String str:sessionkey){
            cacheData.put(str,(String)partition.get(str));
        }
        otherCacheMethod=new Map<String,String>();
        //Returns the average time taken to get a key from the session cache, in nanoseconds.
        otherCacheMethod.put('getAvgGetTime',String.valueOf((Long)partition.getAvgGetTime()));  
        
        //Returns the average item size for keys in the session cache, in bytes.
        otherCacheMethod.put('getAvgValueSize',String.valueOf((Long)partition.getAvgValueSize()));
        
        //Returns the percentage of session cache capacity that has been used.
        otherCacheMethod.put('getCapacity',String.valueOf((Long)partition.getCapacity()));
        
        //Returns the maximum time taken to get a key from the session cache, in nanoseconds.
        otherCacheMethod.put('getMaxGetTime',String.valueOf((Long)partition.getMaxGetTime()));
        
        //Returns the maximum item size for keys in the session cache, in bytes.
        otherCacheMethod.put('getMaxValueSize',String.valueOf((Long)partition.getMaxValueSize()));
        
        //Returns the miss rate in the session cache.
        otherCacheMethod.put('getMissRate',String.valueOf((Long)partition.getMissRate()));
        
        //Returns the name of the default cache partition.        
        otherCacheMethod.put('getName',String.valueOf(partition.getName()));
        
        //Returns the total number of keys in the session cache.
         otherCacheMethod.put('getNumKeys',String.valueOf(partition.getNumKeys()));
        
        //Returns true if the session cache is available for use. The session cache isn’t available when an active session isn’t present, such as in asynchronous Apex or code called by asynchronous Apex. For example, if batch Apex causes an Apex trigger to execute, the session cache isn’t available in the trigger because the trigger runs in asynchronous context.
        otherCacheMethod.put('isAvailable',String.valueOf(partition.isAvailable()));
        
        // Returns a partition from the session cache that corresponds to the specified partition name.
        //otherCacheMethod.put('getPartition',String.valueOf(partition.getPartition('local.B2BAPI')));
        
        /*
        getPartition(partitionName)
        Returns a partition from the session cache that corresponds to the specified partition name.
        isAvailable()
        Returns true if the session cache is available for use. The session cache isn’t available when an active session isn’t present, such as in asynchronous Apex or code called by asynchronous Apex. For example, if batch Apex causes an Apex trigger to execute, the session cache isn’t available in the trigger because the trigger runs in asynchronous context.
        put(key, value)
        Stores the specified key/value pair as a cached entry in the session cache. The put method can write only to the cache in your org’s namespace.
        put(key, value, visibility)
        Stores the specified key/value pair as a cached entry in the session cache and sets the cached value’s visibility.
        put(key, value, ttlSecs)
        Stores the specified key/value pair as a cached entry in the session cache and sets the cached value’s lifetime.
        put(key, value, ttlSecs, visibility, immutable)
        Stores the specified key/value pair as a cached entry in the session cache. This method also sets the cached value’s lifetime, visibility, and whether it can be overwritten by another namespace.
        remove(key)
        Deletes the cached value corresponding to the specified key from the session cache.
        remove(cacheBuilder, key)
        */
        otherMethodkey=otherCacheMethod.keySet();
    }
    public static void createDeflected(){
      List<Core_IPS_Deflected_Object__c> lstdeflectedObj;
        deflectedObj=new Core_IPS_Deflected_Object__c();
        deflectedObj.Core_IPS_Status__c='Deflected';
       deflectedObj.ownerId = '00G3F000000P12C';
       insert deflectedObj;
        deflectedId = deflectedObj.id;
        system.debug('deflectedObj::'+deflectedObj.id);
         system.debug('deflectedObj::'+deflectedObj.name);
         lstdeflectedObj = [select Id, name, core_IPS_status__c,owner.name from Core_IPS_Deflected_Object__c where id ='a3U3F0000004TXV'];
         for(Core_IPS_Deflected_Object__c obj:lstdeflectedObj ){
         deflectedName = obj.name;
         }
         deflectedName = 'pooja';
         putCache();
    }
   // private static final String PARTITION_NAME = system.label.Core_IPS_Platform_Cache_Name;
    private static final String KEY = 'STAGE';
    private static final String VALUE = 'Some Data';
      
    @RemoteAction
    public static String putCache() {
 
        Cache.Partition partition = Cache.Session.getPartition(PARTITION_NAME);
        partition.put(KEY, VALUE,300);
        
       // Cache.Session.put(KEY, VALUE,300);
        return 'ok';
    }
 
    @RemoteAction
    public static String getCache(String tentative) {
        String found = '';
        //sessionkey=partition.getKeys();
        
        Cache.Partition partition = Cache.Session.getPartition(PARTITION_NAME);
       /* for(String str:sessionkey){
            cacheValue += (String)partition.get(KEY);
        }*/
        
         //   String cacheValue = (String)partition.get(KEY);
         String cacheValue = (String)partition.get(KEY);
        if (cacheValue == null) {
            found = 'Seesion Expired: ' + tentative;
        }else{
            found = 'Found:' +cacheValue +'::'+ tentative;
        }
        return found;
    }
}