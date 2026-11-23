global class Core_IPS_BES_Delete_All_Old_Logs_Batch implements Database.Batchable<sObject>{ 
	global String objectName;
    global Boolean isSingleObject;
    global List<sObject> scope = new List<sObject>();
    public Core_IPS_BES_Delete_All_Old_Logs_Batch(){
        this.isSingleObject = false;
    }    
    public Core_IPS_BES_Delete_All_Old_Logs_Batch(String objectName,Boolean isSingleObject){
        this.objectName = objectName;
        this.isSingleObject = isSingleObject;
    }    

    global List<sObject> start(Database.BatchableContext bc) {
        if(isSingleObject== false){
            getObjectRecords('BES Error Log');
            getObjectRecords('Log Entry');
            getObjectRecords('BES Inbound');
            getObjectRecords('BES Outbound');
        }
        else{
        	getObjectRecords(objectName);
        }
        
        //return Database.getQueryLocator(query);
        	return scope;
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            if(!scope.isEmpty()){
            	delete scope;
            	DataBase.emptyRecycleBin(scope);
            }
        }catch(Exception e){
            
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
    public void getObjectRecords(String objectName){
        String query = '';
        List<sObject> recList = new List<sObject>();
        try{
            	List<String> whereParts = new List<String>();
            	Core_IPS_BES_Batch_Delete__c deleteBatch = Core_IPS_BES_Batch_Delete__c.getValues(objectName);
            
                query = 'Select Id from '+deleteBatch.Core_IPS_BES_ObjectName__c+' ';
                if(deleteBatch.Core_IPS_BES_No_of_Days__c != null){
                    whereParts.add('CreatedDate < LAST_N_DAYS:'+Integer.valueOf(deleteBatch.Core_IPS_BES_No_of_Days__c));
                }   
                if(!String.isBlank(deleteBatch.Core_IPS_BES_Where_Condition__c)){
                    whereParts.add(deleteBatch.Core_IPS_BES_Where_Condition__c);
                }
                if(whereParts.size() > 0){
                    query += 'where '+ String.join(whereParts, ' and ');
                }
           /* if(Test.isRunningTest()){
                query = 'Select Id from '+deleteBatch.Core_IPS_BES_ObjectName__c;
            }*/
           // System.debug('query'+query);
            recList = Database.query(query);
			if(!recList.isEmpty()){
            	scope.addAll(recList);
        	}
            
        }catch(Exception e){
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null , null);
        }
        
    }
    
}