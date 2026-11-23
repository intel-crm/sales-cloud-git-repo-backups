public class queueTest implements Queueable{ 

    public Map<Integer,String> minMaxMap = new Map<Integer,String>();
    public Integer count;
    public string query;
    public String IpaasLoadId;
    public Integer minStgNum;
    public Integer maxStgNum; 

    public queueTest(Integer i, String ipaasId, Map<Integer,String> inpMap) {
        this.IpaasLoadId = ipaasId;
        this.count = i;
        this.minMaxMap = inpMap;
    }    
    // Process the records
    public void execute(QueueableContext context) {    
        System.debug('------------------- inside queueable -----------------------');
        List<String> minMaxList = new List<String>();
        if(minMaxList.size() > 0){
            minMaxList = minMaxMap.get(count).split(';');
            minStgNum = Integer.valueOf(minMaxList[0]);
            maxStgNum = Integer.valueOf(minMaxList[1]);
        }
        if(String.isNotBlank(IpaasLoadId)){
            query = 'SELECT '+String.join(Product_Utility.getObjectFields('Core_Products_Staging__c'),',')+' FROM Core_Products_Staging__c WHERE iPaaS_Load_ID__c =: IpaasLoadId AND Staging_Number__c >= :minStgNum AND Staging_Number__c <= :maxStgNum ';
        }        
        System.debug('queueable no --- '+count+' rec list size --- '+Database.query(query).size());


        count++;
        if(count <=  minMaxMap.keySet().size()){  
            if(!Test.isRunningTest()){
                System.enqueueJob(new queueTest(count,IpaasLoadId,minMaxMap));
            }            
        }
        else if(count >  minMaxMap.keySet().size()){
            //further call
            system.debug('------------ end of queueables ------------');
        }
    }
}