public without sharing class Core_IPS_RemovePSO_Batch_Handler_LEX {
   
   @AuraEnabled
 public static Boolean runBatchfromLWC(string ContactIdVar){
    List<user> portalUserlst ;
    set<id>caseId=New set<id>();
    boolean caseCount=true;
    string batchSize = System.Label.Remove_PSO_From_Case_Batch_Size;
    set<id>userIds =New set<id>();
      List<case> cslst;
     
      if(ContactIdVar!=null){
            
            // portalUserlsit =new  List<Contact>();
            portalUserlst=  [SELECT ID, ContactId, Contact.Firstname, Contact.Lastname,
             ProfileId, Profile.Name FROM User WHERE ContactID =: ContactIdVar];
           
            for(user u :portalUserlst ){
                userIds.add(u.id);
            }
           if(Schema.sObjectType.case.isAccessible()){ 
           cslst= [select id,status,CaseNumber,Core_IPS_Partner_Sup_Owner__c from case where Core_IPS_Partner_Sup_Owner__c =:userIds AND status IN ('OPEN','NEW')];
            }
          
            if(cslst.size()>0){
            for(case csId : cslst){
                
                caseId.add(csId.id);
             
                caseCount=true;
            }
                }
            else{
                 caseCount=False;
            } 
            
        }
        if(caseCount){ 
        Database.executeBatch(new Core_IPS_RemovePSO_Batch(caseId), Integer.ValueOf( batchSize ));    //Keep this in label batch size 
         
        }
     
     //   return (caseCount) ? 'Success' : 'error';
          return (caseCount) ? TRUE : False;
     
 }
   
}