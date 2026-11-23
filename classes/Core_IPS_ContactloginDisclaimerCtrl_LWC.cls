public with sharing class Core_IPS_ContactloginDisclaimerCtrl_LWC {// Changed by tushar because for vanuability changes
    public static List<Document> doc;
    public static  User u;
    @AuraEnabled
    public static string getDocData(){
        String docBody;
        try {
            if (Schema.sObjectType.Document.isAccessible()) {
                // Venrublity Fix - Refering query to service class
                doc = [select id,body from Document where name='NDAConfidential' limit 1];
            }
            if(doc.size()>0){ 
                docBody = doc[0].Body.toString(); 
            }
            return docBody;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static string getRedirected(){
        try {
            // Venrublity Fix - Refering query to service class
            List<User> userList = [select Id, ContactId,userType from User where Id = :UserInfo.getUserId()];
            if(!userList.isEmpty()){
                u = userList[0];
            }
            // Venrublity Fix - Refering query to service class
            List<Contact> con = [select id, Core_IPS_NDA_Acceptance_Date__c from Contact where id=:u.ContactId limit 1];

            if(u.userType=='PowerCustomerSuccess' || u.userType=='PowerPartner'){   
                if (Schema.sObjectType.Contact.fields.Core_IPS_NDA_Acceptance_Date__c.isUpdateable()) {
                    con[0].Core_IPS_NDA_Acceptance_Date__c = System.today();
                }
                // Venrublity Fix - Refering query to service class
                // update con;
                con = (List<Contact>) Core_IPS_QueryService.updateRecords((List<SObject>) con);
            } 
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string redirectAutomate(){
        try {
            Boolean flag=true; 
             /*kalyani - Commented List<Contact> con query, just added extra field for below query i.e., Core_IPS_NDA_Acceptance_Date__c; this is part of code optimization.*/
            // Venrublity Fix - Refering query to service class
            // List<User> u = [select Id, ContactId,userType, Contact.Core_IPS_NDA_Acceptance_Date__c from User where Id = :UserInfo.getUserId()];   
            List<User> u = (List<User>) Core_IPS_QueryService.queryRecords(
                'select Id, ContactId,userType, Contact.Core_IPS_NDA_Acceptance_Date__c from User where Id = :userId',
                new Map<String, Object>{ 'userId' => UserInfo.getUserId() }
            );
            // List<Contact> con = [select id, Core_IPS_NDA_Acceptance_Date__c from Contact where id=:u[0].ContactId limit 1];
            /*kalyani - Commented below for loop, it is not in use; this is part of code optimization.*/
            // for(user us : u){
            // }
            /*kalyani - replaced con[0].Core_IPS_NDA_Acceptance_Date__c with u[0].Contact.Core_IPS_NDA_Acceptance_Date__c.*/
            if(u[0].userType=='PowerCustomerSuccess' || u[0].userType=='PowerPartner'){            
                if(u[0].Contact.Core_IPS_NDA_Acceptance_Date__c != null){
                    if(u[0].Contact.Core_IPS_NDA_Acceptance_Date__c >= System.today().adddays(-Integer.valueOf(System.Label.NDA_Acceptance_Time)) ){
                        flag = true;  
                    }else{
                        flag = false;            
                    }   
                }else{
                    flag = false;
                }
            }       
            if(flag==false){
                return 'fail';
            }else{
                return 'success';
            }    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}