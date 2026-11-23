public class SampleBatchForTest2 implements Database.Batchable<sObject>,Core_MDF_BatchSchedulerInterface{
    public Boolean testParam = false;
    public string jsonString='';
    public string testParam2='';
    public SampleBatchForTest2 (){
    }
    

    public static object generateInstance(String jsonText, String classSignature){
        object des_Obj;
        map<String,object> parmValueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
            if(classSignature == 'SampleBatchForTest2(boolean testParam,string testParam2)'){
                boolean flagValue = Boolean.valueOf(parmValueMap.get('testParam'));
                string strValue = string.valueOf(parmValueMap.get('testParam2'));
                des_Obj = new SampleBatchForTest2(flagValue,strValue);
            }
            else if(classSignature == 'SampleBatchForTest2(string testParam2)'){
                string strValue = string.valueOf(parmValueMap.get('testParam2'));
                des_Obj = new SampleBatchForTest2(strValue);
            }
        return des_Obj;
    }
    public SampleBatchForTest2 (boolean testParam,string testParam2){
        this.testParam = testParam;
        this.testParam2 = testParam2;
    }
    public SampleBatchForTest2 (string testParam2){
        this.testParam2 = testParam2;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'select id from Account limit 5';
        return Database.getQueryLocator(query);
    }	
    public void execute(Database.BatchableContext bc, List<Account> accList) {
        system.debug('account'+ accList[2]);
        if(testParam && testParam2 == 'testStr'){
            system.debug('SampleBatchForTest2 boolean & String params passed successfully ' + testParam + ' '+testParam2);
        }
        if(testParam2 != '' && testParam2 == 'testStr'){
            system.debug('SampleBatchForTest2 string param passed successfully ' + testParam2);
        }
        
    }
    public void finish(Database.BatchableContext bc) { 
    }
}