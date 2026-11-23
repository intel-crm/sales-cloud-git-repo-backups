public class SampleBatchForTest implements Database.Batchable<sObject> {
    public Boolean testParam = false;
    public string jsonString='';
    public string testParam2='';
    public SampleBatchForTest (){
    }
    

    public static object generateInstance(String jsonText, String classSignature){
        object des_Obj;
        map<String,object> parmValueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
            if(classSignature == 'SampleBatchForTest(boolean testParam)'){
                boolean flagValue = Boolean.valueOf(parmValueMap.get('testParam'));
                des_Obj = new SampleBatchForTest(flagValue);
            }
            else if(classSignature == 'SampleBatchForTest(string testParam2)'){
                string strValue = string.valueOf(parmValueMap.get('testParam2'));
                des_Obj = new SampleBatchForTest(strValue);
            }
        return des_Obj;
    }
    public SampleBatchForTest (boolean testParam){
        this.testParam = testParam;
    }
    public SampleBatchForTest (string testParam2){
        this.testParam2 = 'testStr';
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'select id from Account limit 5';
        return Database.getQueryLocator(query);
    }	
    public void execute(Database.BatchableContext bc, List<Account> accList) {
        system.debug('account'+ accList[2]);
        if(testParam){
            system.debug('boolean param passed successfully' + testParam);
        }
        if(testParam2 != '' && testParam2 == 'testStr'){
            system.debug('string param passed successfully' + testParam2);
        }
        if(testParam2 != '' && testParam2 == 'testStr1'){
            system.debug('string param1 passed successfully' + testParam2);
        }
        
    }
    public void finish(Database.BatchableContext bc) { 
    }
}