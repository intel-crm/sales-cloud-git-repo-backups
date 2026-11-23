public without sharing class Core_IPS_ContactloginDisclaimerCtrl_LWC {
    public static List<Document> doc;
    public static  User u;
    @AuraEnabled
    public static string getDocData(){
        String docBody;
        try {
            if (Schema.sObjectType.Document.isAccessible()) {
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
            u = [select Id, ContactId,userType from User where Id = :UserInfo.getUserId()];
            List<Contact> con = [select id, Core_IPS_NDA_Acceptance_Date__c from Contact where id=:u.ContactId limit 1];
            if(u.userType=='PowerCustomerSuccess' || u.userType=='PowerPartner'){   
                if (Schema.sObjectType.Contact.fields.Core_IPS_NDA_Acceptance_Date__c.isUpdateable()) {
                    con[0].Core_IPS_NDA_Acceptance_Date__c = System.today();
                }
                update con;
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
            List<User> u = [select Id, ContactId,userType from User where Id = :UserInfo.getUserId()];        
            List<Contact> con = [select id, Core_IPS_NDA_Acceptance_Date__c from Contact where id=:u[0].ContactId limit 1];
            for(user us : u){
                
            }
            if(u[0].userType=='PowerCustomerSuccess' || u[0].userType=='PowerPartner'){            
                if(con[0].Core_IPS_NDA_Acceptance_Date__c != null){
                    if(con[0].Core_IPS_NDA_Acceptance_Date__c >= System.today().adddays(-Integer.valueOf(System.Label.NDA_Acceptance_Time)) ){
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