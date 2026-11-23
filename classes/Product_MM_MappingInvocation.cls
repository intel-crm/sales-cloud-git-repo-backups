public class Product_MM_MappingInvocation {

    public static String ipaasId;  
    
    @InvocableMethod(label = 'Product MM Mapping Invocation' description = 'Product_MM_Mapping_Process_Invocation')
    public static void processMMAttributeMapping(list<string> Ids){ 
    
    	Database.executeBatch(new Product_MM_Attribute_MappingBatch(),1000);
        
    }
}