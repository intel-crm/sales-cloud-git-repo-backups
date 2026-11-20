/****************************************************************************************************************************************
* Class Name  : Core_MDF_Account_PGM_Sync_ServiceHandler
* Version     : 1.0 
* Created Date: 03/03/2023
* Modification Log :
* Developer                     Date                        Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* JB - Accenture    		03/03/2023                    
* *****************************************************************************************************************************************/
public class Core_MDF_Account_PGM_Sync {
    
    /*****************************************************************************************************                              
    Method Name   :        callAccountAndPgmSyncPlatformEvent                                
    @return       :        void                          
    @parameters   :        List<Requests>
    Description   :        Used to call Account PGM Sync platform event
    Added By      :        JB - Accenture - 03/03/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         03/03/2023      Used to call Account PGM Sync platform event
    ******************************************************************************************************/
    @InvocableMethod
    public static void callAccountAndPgmSyncPlatformEvent(List<Requests> requestList){
        try{
            
            List<Core_MDF_Account_PGM_Sync__e> accountPgmSyncPE = new List<Core_MDF_Account_PGM_Sync__e>();
            if(!requestList.isEmpty()){
                for(Requests req : requestList){
                    accountPgmSyncPE.add(new Core_MDF_Account_PGM_Sync__e(Core_MDF_DML_Operation_Type_txt__c = req.dmlOperationType, Core_MDF_Object_API_Name__c = req.objectApiName, Core_MDF_JSON_Data__c = JSON.serialize(req.recordDetail)));
                }
            }
            
            if(!accountPgmSyncPE.isEmpty()){
                //Publish Platform event(Core_MDF_Account_PGM_Sync__e)
                List<Database.SaveResult> results = EventBus.publish(accountPgmSyncPE);
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    public class Requests{
        
        @InvocableVariable(label = 'Dml Operation Type') 
        public String dmlOperationType;

        @InvocableVariable(label = 'Object API Name') 
        public String objectApiName;
        
        @InvocableVariable(label = 'Record Detail') 
        public SObject recordDetail;
    }
}