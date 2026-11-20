public with sharing class Core_IPS_RemovePSO_Batch_Handler {
    // public List<String> ids; 
    List<user> portalUserlst ;
    set<id>userIds =New set<id>();
    List<case> cslst;
    set<id>caseId=New set<id>();
    public id idVar{get;set;}
    String message;
    string batchSize = System.Label.Remove_PSO_From_Case_Batch_Size;
   public static boolean caseCount{get;set;}
    public Boolean dispPopup {get;set;}
    public Boolean removePop {get;set;}
    public Boolean errorPOP {get;set;}
     public Boolean successPOP {get;set;}
    
    public Core_IPS_RemovePSO_Batch_Handler() {
        //  this.ids = new List<String>();
        idVar= ApexPages.currentPage().getParameters().get('id');
        dispPopup = true;
        removePop = true;
        // message = '' + ApexPages.CurrentPage().GetParameters().Get('message');
    } 
 
    
    public PageReference runBatch() {
       PageReference ref = null;
       if(idVar!=null){
            
            // portalUserlsit =new  List<Contact>();
            portalUserlst=  [SELECT ID, ContactId, Contact.Firstname, Contact.Lastname, ProfileId, Profile.Name FROM User WHERE ContactID =: idVar];
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
                removePop = false;
            }
                }
            else{
                 caseCount=False;
                removePop = false;
            } 
            
        }
        if(caseCount){ 
        Database.executeBatch(new Core_IPS_RemovePSO_Batch(caseId), Integer.ValueOf( batchSize ));    //Keep this in label batch size 
       
      //  PageReference pg = new PageReference('/'+idVar);     
       // pg.setRedirect(true);
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,System.Label.Remove_PSO_Success_Alert));
        successPOP=true;
            return null;    
        }
        else{
            errorPOP=true;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Remove_PSO_Failure_Alert));
         return null;
        }
      // ref= new PageReference('/'+idVar);
      // return ref;
    } 
     public PageReference finished(){
        return (new PageReference ('/' + idVar ));
    }
    
}