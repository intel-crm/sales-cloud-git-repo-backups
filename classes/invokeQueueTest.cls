public class invokeQueueTest {    

    public static String ipaasId;
    public static Integer totalRcdCount = 0;
    public static Integer maxCount = 0;
    public static Integer offSetLimit = 5000;
    public static Integer OffSet = 0;
    public static Decimal minStgNum = 0;
    public static Decimal maxStgNum = 0;
    public static Map<Integer,String> countMinMaxMap = new Map<Integer,String>();
    public static Integer IntialCount = 1;   //Intially set to 1. The count will increase on completion of each queueble job.

    
    public static void invokeQueueables(String ipaasId){
        if(ipaasId != null ){
            List<AggregateResult> agrList = [select count(Id)cnt,min(Staging_Number__c)minStgNum,max(Staging_Number__c)maxStgNum  from Core_Products_Staging__c where iPaaS_Load_ID__c ='24680'];
            system.debug('agrList --- '+agrList);
            if(!agrList.isEmpty()){
                totalRcdCount = (Integer)agrList[0].get('cnt');
                minStgNum = (Decimal)agrList[0].get('minStgNum');
                maxStgNum = (Decimal)agrList[0].get('maxStgNum');
                system.debug('minStgNum--- '+minStgNum); 
                system.debug('maxStgNum--- '+maxStgNum);
                maxCount = totalRcdCount/offSetLimit;
            }  
            if(maxCount > 0){
                for(integer i=1; i <= maxCount+1; i++){
                    if(i != maxCount+1){
                        countMinMaxMap.put(i,(String)(minStgNum+';'+(Integer)(minStgNum+offSetLimit)));
                        minStgNum+=offSetLimit;
                    }
                    else{
                        countMinMaxMap.put(i,(String)(minStgNum+';'+(Integer)(maxStgNum)));
                    }            
                }
            }                
            system.debug('totalRcdCount--- '+totalRcdCount);      
        }
        system.debug('countMinMaxMap--- '+countMinMaxMap);
        system.debug('countMinMaxMap size--- '+countMinMaxMap.size());
        //for debugging
        for(Integer k:countMinMaxMap.keyset()){
            system.debug('key --- '+k+' value-- '+countMinMaxMap.get(k));
            List<String> l = countMinMaxMap.get(k).split(';');
            Integer min = Integer.valueOf(l[0]);
            Integer max = Integer.valueOf(l[1]);
            system.debug(k+' diff count --- '+(max-min));
            List<AggregateResult> agrList =[select count(id)cnt from Core_Products_Staging__c  where Staging_Number__c>=:min and Staging_Number__c<= :max];
            system.debug('count --- '+(Integer)agrList[0].get('cnt'));
        }
                    
        if (countMinMaxMap.size() > 0){                
            System.enqueueJob(new queueTest(IntialCount,ipaasId,countMinMaxMap));
        }   
    }
}