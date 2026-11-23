public with sharing class Core_Case_ActionEditController {
    private ApexPages.StandardController controller;
    public String retURL {get; set;}
    public String saveNewURL {get; set;}
    public String rType {get; set;}
    public String cancelURL {get; set;}
    public String ent {get; set;}
    public String confirmationToken {get; set;}
    public String accountID {get; set;}
    public String contactID {get; set;}  
    public String mode {get; set;}  
    public Case caseEdit{get;set;}
    public List<StandardActionRedirection__c> sCaseActionList{get;set;}
    public Core_Case_ActionEditController(ApexPages.StandardController controller) {
    this.controller = controller;
    retURL = ApexPages.currentPage().getParameters().get('retURL');
    caseEdit = [select id,Casenumber,RecordtypeId,RecordType.developerName from case where id =:this.controller.getID()];
    if(retURL == null || retURL == '')
    {
       retURL = '/' + caseEdit.id ;
    }
    
    rType = caseEdit.RecordtypeId;
    cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
    ent = ApexPages.currentPage().getParameters().get('ent');
    confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
    saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
    accountID = ApexPages.currentPage().getParameters().get('def_account_id');
    contactID = ApexPages.currentPage().getParameters().get('def_contact_id');  
    getCaseActionList();
    }
    public pagereference redirect(){
      User u = [select Id, username,userType,profile.name from User where Id = :UserInfo.getUserId()];
      if(u.userType=='PowerCustomerSuccess')
      {
       rtype=null;
      }
      Map<String, Id> recordTypesByName = new Map<String, Id>();
      List<RecordType> rtList = [SELECT id,developerName FROM RecordType where SobjectType='Case'];
      Pagereference ref;
      for(RecordType rt: rtList){
          recordTypesByName.put(rt.developerName, rt.Id);
      }   
      system.debug(u.profile.name);
      
      for(StandardActionRedirection__c action: sCaseActionList){
      system.debug(action.Profile_del__c);
          if(action.Profile_del__c <> null && action.Profile_del__c==u.profile.name){
                  ref = new PageReference(action.URI__c + string.valueof(caseedit.ID)+'&retURL='+retURL);   
                  ref.setRedirect(true);
                  return ref;
          }
      }
      for(StandardActionRedirection__c action: sCaseActionList){
      system.debug('Action RT: '+action.Record_Type__c+' rType????: '+rType+' rType: '+recordTypesByName.get(action.Record_Type__c));
          if(action.Record_Type__c!=null && rType!=null && rType==recordTypesByName.get(action.Record_Type__c)){ 
                if(action.URI__c.indexOF('Caseid') > -1)
                {
                    ref = new PageReference(action.URI__c.replaceAll('Caseid',string.valueof(caseedit.ID)) + retURL);   
                    ref.setRedirect(true);
                    return ref;  
                }
                else
                {               
                    ref = new PageReference(action.URI__c + string.valueof(caseedit.ID)+'&retURL='+retURL);   
                    ref.setRedirect(true);
                    return ref;        
                }
          }/*else{
              if(action.Profile_del__c==u.profile.name){
                  ref= new PageReference(action.URI__c);   
                  ref.setRedirect(true);
                  return ref;
              }
          }*/
      }
      
     /* if(rType=='012q0000000Chvn'){
          if(u.profile.name=='IPS External Contact' || u.profile.name=='IPS Agent' || u.profile.name=='Sales Rep-BB'){
              ref = new PageReference('/apex/Core_IPS_Case_Creation');
               ref.setRedirect(true);
          }else{
              ref = new PageReference('/500/e?nooverride=1');
          }
          
      }else if(u.profile.name=='IPS External Contact' || u.profile.name=='IPS Agent' || u.profile.name=='Sales Rep-BB'){
          ref = new PageReference('/apex/Core_IPS_Case_Creation');
          ref.setRedirect(true);
      }else{
          ref = new PageReference('/500/e?nooverride=1');
      }
      /*else if(u.profile.name=='IPS External Contact'){
          ref= new PageReference('/apex/Core_IPS_Customer_CreateCase');
            ref.setRedirect(true);
      }*/
      string defPageReference = '/' + caseEdit.id + '/e?nooverride=1&retURL=' + retURL;
      if(accountID!=null && accountId!=''){
        defPageReference=defPageReference+'&def_account_id='+accountId;
      }
      else if(contactId!=null && contactId!=''){
        defPageReference=defPageReference+'&def_contact_id='+contactId;
      }
      return new PageReference(defPageReference);
  }
    private void getCaseActionList(){
      List<StandardActionRedirection__C> sActionList = new List<StandardActionRedirection__C>();
      sCaseActionList = new List<StandardActionRedirection__C>();
      sActionList=StandardActionRedirection__C.getAll().values();
      for(StandardActionRedirection__C sAction: sActionList){
          if(sAction.Object__c.equalsIgnoreCase('Case') && sAction.Action__c.equalsIgnoreCase('EDIT')){
              sCaseActionList.add(sAction);
          }
      }      
  }
}