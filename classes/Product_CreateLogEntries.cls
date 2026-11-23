public class Product_CreateLogEntries {
    
     @InvocableMethod(label='Retrieve IpaasLoadId' description='return list of ipaasLoadId')
    public static void Product_CreateLogEntries(){
        String ipaasLoadId;
        String inbRec = 'select iPaaS_Load_ID__c from Product_Inbound_Staging__c ORDER by Createddate DESC LIMIT 1';
        if(inbRec != null){
            ipaasLoadId=inbRec;
        }
         Database.executeBatch(new Product_CreateLogEntriesBatch(ipaasLoadId),200);
         
    }
    
  
}