public with sharing class ClassFactory 
{
    // Class Factory template
    public interface IClassFactory
    {
        void processWork();
    }
   
    // Class Factory base class
    public virtual class ClassFactoryBase
    {
        // ... Shared methods go here
    }


    // Process work 
    public static void processAllWork()
    {
        ClassFactoryManager cfm = new ClassFactoryManager();
        cfm.newClassInstance('ClassFactory.Class1').processWork();
    }

    // Class1
    public class Class1 extends ClassFactoryBase implements IClassFactory
    {
 	public string CAMPAIGN_APPROVAL_HISTORY_JSON ='[ {"record":[{"step_Name": "Price Reviewer","comments_masked": "true","comments_desc":"Comments masked through JSON"}],"ps_name":"Core_MDF_CCP_External_IPA_Proposal_Manager"}]'; //Core_MDF_CCP_External_IPA_Proposal_Manager,{"step_Name": "L1 Approval","comments_masked": "true","comments_desc":"Comments masked through JSON"},{"step_Name": "L2 Approval","comments_masked": "true","comments_desc":"Comments masked through JSON"}
    public string CUSTOM_APPROVAL_HISTORY_PFR_IPA_ACCOUNTBASED_JSON = '[{"record":[{"step_Name": "Price Reviewer","comments_masked": "true","comments_desc":"Comments masked through JSON"}],"ps_name":"Core_MDF_CCP_External_IPA_Activity_Manager"}]';
    public void processWork()
        {
           
        }
     
    public Object getValue(String variableName) {
        String jsonString = toJSON();
        Map<String, Object> untyped_instance;
        untyped_instance = 
            (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        return untyped_instance.get(variableName);
    }
    
    public string toJSON() {
        return JSON.serialize(this);
    }
    }

   
}