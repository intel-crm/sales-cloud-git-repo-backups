public class Core_IQR_CompareRecordsScheduler {
    @InvocableMethod
    public static void Core_IQR_CompareRecordsScheduler() {  
        
    	try{          
        	Database.executeBatch(new Core_IQR_CompareRecords());  
            
        }
        catch(exception e){
        	system.debug('**exception** -->'+ e);
        }
    }

}