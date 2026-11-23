public class Core_MDF_BatchSchedulerHelper {
    public string className='';
    public string jsonText='';
    public string classSignature='';
    public Core_MDF_BatchSchedulerHelper(String className, String jsonText, String classSignature){
        this.className = className;
        this.jsonText = jsonText;
        this.classSignature = classSignature;
    }
    public object generateInstance(){
        object des_Obj;
        if(className == 'Core_MDF_Batch_IAH_Pull'){            
            map<String,object> flagValueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
            boolean flagValue = Boolean.valueOf(flagValueMap.get('notifyRecoveryAdmin'));  
            des_Obj = new Core_MDF_Batch_IAH_Pull(); 
            //Core_MDF_Batch_IAH_Pull.generateInstance(json);
        }
        else if(className == 'SampleBatchForTest'){
           /* map<String,object> parmValueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
            if(classSignature == 'SampleBatchForTest(boolean testParam)'){
                boolean flagValue = Boolean.valueOf(parmValueMap.get('testParam'));
                des_Obj = new SampleBatchForTest(flagValue);
            }
            else if(classSignature == 'SampleBatchForTest(string testParam2)'){
                string strValue = string.valueOf(parmValueMap.get('testParam2'));
                des_Obj = new SampleBatchForTest(strValue);
            }*/
            des_Obj = SampleBatchForTest.generateInstance(jsonText,classSignature);
           
        }
        return des_Obj;
    }
}