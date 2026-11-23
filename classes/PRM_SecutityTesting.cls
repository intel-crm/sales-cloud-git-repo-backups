public with sharing class PRM_SecutityTesting {
    @auraEnabled
	public static list<PRM_Security_Test__c> returnData(){
        
        PRM_Security_Test__c p = new PRM_Security_Test__c();
        p.PRM_Name__c = 'Test';
        //if(PRM_Security_Test__c.sObjectType.getDescribe().isCreateable()){
            //insert p;
        //}
        
        List<PRM_Security_Test__c> testData = PRM_ChildSecurity.getRecords();
        return testData;
        
    }
    
    public static void updateSource(list<PRM_Security_Test__c> listOfData){
      /* for(PRM_Security_Test__c st : listOfData){
           List<PRM_Child_Security_Testing__c> lstOfData = [Select id, PRM_Test__c from PRM_Child_Security_Testing__c where id = 'a9R8A0000003OzeUAE' limit 1 ];
            PRM_Child_Security_Testing__c cp = lstOfData[0];
            cp.PRM_Ch_Source_Txt__c = 'Trigger';
            //if(PRM_Child_Security_Testing__c.sObjectType.getDescribe().isCreateable()){
           try{
                upsert cp;
            }catch(exception ex){
                st.addError('You do not have access to insert child record'+ex.getMessage()+ex.getStackTraceString());
            }
        }*/
        
        
    }
}