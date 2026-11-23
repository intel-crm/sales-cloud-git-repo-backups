public with sharing class Core_Case_ActionController{
    private ApexPages.StandardController controller;
    public String retURL {get; set;}
    public String saveNewURL {get; set;}
    public String rType {get; set;}
    public String cancelURL {get; set;}
    public String ent {get; set;}
    public String confirmationToken {get; set;}
    public String accountID {get; set;}
    public String contactID {get; set;}  
    public boolean isMasterRecordType{get;set;}
    //public String mode {get; set;}  
    public List<StandardActionRedirection__c> sCaseActionList{get;set;}
    
  public Core_Case_ActionController(ApexPages.StandardController controller){
      this.controller = controller;
    retURL = ApexPages.currentPage().getParameters().get('retURL');
    if(retURL == null || retURL == '')
    {
       retURL = '/500/o';
    }
    rType = ApexPages.currentPage().getParameters().get('RecordType');
    cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
    ent = ApexPages.currentPage().getParameters().get('ent');
    confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
    saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
    accountID = ApexPages.currentPage().getParameters().get('def_account_id');
    contactID = ApexPages.currentPage().getParameters().get('def_contact_id');
    isMasterRecordType=false;
    //[Jan/21/2016 - Abhishek Arya - Added below code to get the default recordtype in case rtype is null above.]
    // in case it's null, the user has only one record type available.
    
    if(ApexPages.currentPage().getParameters().get('RecordType') == null) {
        //String usrProfileName = [select Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;
        String userType = UserInfo.getUserType();
        if(!userType.equalsIgnoreCase('PowerCustomerSuccess')){
            Schema.DescribeSObjectResult dsr = case.SObjectType.getDescribe();
            Schema.RecordTypeInfo defaultRecordType;
            for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
                if(rti.isDefaultRecordTypeMapping()) {
                    defaultRecordType = rti;
                    break;
                }
            }
            rType = defaultRecordType.recordTypeId;
            isMasterRecordType = true;
        }
    }
    //[Jan/21/2016 - Abhishek Arya - END]
    getCaseActionList();
  }
  
  public pagereference redirect2(){
      User u = [select Id, username,userType,profile.name from User where Id = :UserInfo.getUserId()];
      Map<String, Id> recordTypesByName = new Map<String, Id>();
      List<RecordType> rtList = [SELECT id,developerName FROM RecordType where SobjectType='Case'];
      Pagereference ref;
      for(RecordType rt: rtList){
          recordTypesByName.put(rt.developerName, rt.Id);
      }
      
      for(StandardActionRedirection__c action: sCaseActionList){
          if(action.Profile_del__c <> null && action.Profile_del__c==u.profile.name){
                   ref= new PageReference(action.URI__c + retURL );    
                  ref.setRedirect(true);
                  return ref;
          }
      }
      for(StandardActionRedirection__c action: sCaseActionList){
          if(action.Record_Type__c!=null && rType!=null && rType==recordTypesByName.get(action.Record_Type__c)){
                ref= new PageReference(action.URI__c + retURL );   
                ref.setRedirect(true);
                
                return ref;        
          }
      }
      String defPageReference;
      if(isMasterRecordType)
          defPageReference = '/500/e?nooverride=1&retURL=' + retURL;
      else
          defPageReference = '/500/e?nooverride=1&RecordType=' + rType  + '&retURL=' + retURL;
      if(accountID!=null && accountId!=''){
        defPageReference=defPageReference+'&def_account_id='+accountId;
      }
      else if(contactId!=null && contactId!=''){
        defPageReference=defPageReference+'&def_contact_id='+contactId;
      }
           system.debug('defPageReference:: 3'+defPageReference);
      return new PageReference(defPageReference);
  }
  
  private void getCaseActionList(){
      List<StandardActionRedirection__C> sActionList = new List<StandardActionRedirection__C>();
      sCaseActionList = new List<StandardActionRedirection__C>();
      sActionList=StandardActionRedirection__C.getAll().values();
      for(StandardActionRedirection__C sAction: sActionList){
          if(sAction.Object__c.equalsIgnoreCase('Case') && sAction.Action__c.equalsIgnoreCase('new')){
              sCaseActionList.add(sAction);
          }
      }
      system.debug('sCaseActionList::'+sCaseActionList);      
  }
}