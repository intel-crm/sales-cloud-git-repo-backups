public class Core_MDF_BatchExecution_Controller {
    @AuraEnabled(cacheable = true)
    public static List<String> getBatchJobs(){
    String Query = System.Label.Core_MDF_Batch_Executor_Query;
    list<ApexClass> lstApexClasses = Database.Query(Query);
    list<String> batchClassList = new List<String>();
    for(ApexClass iterator : lstApexClasses) {
        if(iterator.Body.contains('Database.Batchable') && !(iterator.Body.contains('@isTest')) ) {
            system.debug('Batch Class Name ====> '+iterator.Name+' Api Version ====> '+iterator.ApiVersion);
            batchClassList.add(iterator.Name);
        }
        // if(iterator.Body.contains('Database.Batchable') && !(iterator.Body.contains('@isTest')) ) {
        //     system.debug('Batch Class Name ====> '+iterator.Name+' Api Version ====> '+iterator.ApiVersion);
        //     batchClassList.add(iterator.Name);
        // }
        System.debug('All Batch classes'+batchClassList);
    }
    return batchClassList;
    }
    @AuraEnabled(cacheable = true)
    public static ID runBatchClass(String name,Integer batchSize,List<BatchInput> paramInput){  
        Id batchprocessid;
        system.debug('paramInput:'+paramInput);
         
        try{
            Type t = Type.forName(name);
            system.debug('T:'+ t);
            Database.Batchable<sObject> instance ;

            if(paramInput.size() == 0 || paramInput == null){
                instance = (Database.Batchable<sObject>)t.newInstance();
            }
            else{
                instance = (Database.Batchable<sObject>)JSON.deserialize(
                    JSON.serialize(new Map<String, Object>{paramInput[0].key => paramInput[0].value}),t);
            }
            system.debug('reached 32!');
            batchprocessid = Database.executeBatch(instance,batchSize);
        }
        catch(Exception ex){
            system.debug('Exception:'+ex.getMessage());
        }
       
        return batchprocessid;
    
      }
        
      @AuraEnabled
      public static List<BatchRunDetails> checkBatchStatus(Id batchJobId){   
       AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,CompletedDate,
              TotalJobItems, CreatedBy.Email, ExtendedStatus
              from AsyncApexJob where Id = :batchJobId];
          List<BatchRunDetails> brd = new List<BatchRunDetails>();

          BatchRunDetails b = new BatchRunDetails();

          b.batchId = String.valueOf(a.Id);
          b.batchStatus = a.Status;
          b.batchCompletedDate = String.valueOf(a.CompletedDate);
          brd.add(b);

          return brd;
      }
    
      @AuraEnabled(cacheable = true)
      public static BatchParams checkParameterForSelectedBatch(String batchName){  
        BatchParams bp = new BatchParams();
        List<String> paramName = new List<String>();
        List<String> paramType = new List<String>(); 
    
        Core_MDF_CCP_Batch_Maintenance__mdt batchMdt = [SELECT Core_MDF_Batch_Params_txt__c,Core_MDF_Batch_Param_Type_txt__c from Core_MDF_CCP_Batch_Maintenance__mdt
        WHERE Core_MDF_Batch_Name_nm__c =: batchName LIMIT 1];
    
        paramName = batchMdt.Core_MDF_Batch_Params_txt__c.split(';');
        paramType = batchMdt.Core_MDF_Batch_Param_Type_txt__c.split(';');
        bp.batchParamName = paramName;
        bp.batchParamType = paramType;
    
        return bp;
      
        } 

        public class BatchRunDetails{
            @AuraEnabled public String batchId { get; set; }
            @AuraEnabled public String batchStatus { get; set; }
            @AuraEnabled public String batchCompletedDate { get; set; }
        }
    
        public class BatchParams{
            @AuraEnabled public List<String> batchParamName { get; set; }
            @AuraEnabled public List<String> batchParamType { get; set; }
        }
    
        public class BatchInput{
            @AuraEnabled public String key { get; set; }
            @AuraEnabled public String value { get; set; }
        }
    
    
      
    
        @AuraEnabled(cacheable=true)
        public static List<String> getBatch(String batchName){
            system.debug('string passed is '+batchName);
         
           List<String> sObjectResultList = new List<String>();
           String Query = System.Label.Core_MDF_Batch_Executor_Query;
            list<ApexClass> lstApexClasses = Database.Query(Query);
            list<String> batchClassList = new List<String>();
            for(ApexClass iterator : lstApexClasses) {
                if(iterator.Body.contains('Database.Batchable') && !(iterator.Body.contains('@isTest')) ) {
                    system.debug('Batch Class Name ====> '+iterator.Name+' Api Version ====> '+iterator.ApiVersion);
                    batchClassList.add(iterator.Name);
                }
              
                
            }
            System.debug('All Batch classes line 98'+batchClassList);
        
             
               if(String.isNotEmpty(batchName)) {
                // String query = 'Select Id,Name ';
                
                    // for(String batchlist1 : batchClassList) 
                    // {
        
                    //     if(BatchName.indexOf(batchlist1) != -1)
                    //     {
                    //         System.debug('batchlist 1 is'+batchlist1);
                    //         sObjectResultList.add(batchlist1);
                    //     }
                    // }ss
                    for(Integer i=0;i<batchClassList.size();i++)
                    {
                        if(batchClassList[i].contains(batchName))
                        sObjectResultList.add(batchClassList[i]);
                    }
                    system.debug('finali list is'+sObjectResultList);
                   
             
               }
            return sObjectResultList;
        }
    }