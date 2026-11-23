public class Prod3_Core_IQR_CompareRecordsScheduler {
    @InvocableMethod
    public static void Prod3_Core_IQR_CompareRecordsScheduler() {  
        
    	try{          
        	Database.executeBatch(new Product3_Core_IQR_CompareRecords());  
            
        }
        catch(exception e){
        	system.debug('**exception** -->'+ e);
        }
    }

}