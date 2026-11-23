public class Prod3_Core_IQR_IntelProductDataScheduler {
	@InvocableMethod
    public static void Prod3_Core_IQR_IntelProductDataScheduler() {  
        
    	try{          
        	Database.executeBatch(new Product3_Core_IQR_IntelProductData());  
            
        }
        catch(exception e){
        	system.debug('**exception** -->'+ e);
        }
    }
}