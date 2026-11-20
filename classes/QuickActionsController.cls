public class QuickActionsController {
    @AuraEnabled 
    public static List<StandardActionRedirection__c> sCaseActionList{get;set;}
    @AuraEnabled 
    public static String retURL {get; set;}
    @AuraEnabled 
    public static Case caseEdit{get;set;}
    @AuraEnabled 
    public static String rType {get; set;}
   // public static String saveNewURL {get; set;}
   // public static String cancelURL {get; set;}
   // public static String ent {get; set;}
   // public static String confirmationToken {get; set;}
    public static String accountID {get; set;}
    public static  String contactID {get; set;}  
   // public static String mode {get; set;}  
    
    @AuraEnabled        
    public static String getCaseRecordTypeID(String recId) {
        // Id CaseRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RTYPENAME').getRecordTypeId();
        // System.debug('minhaj ' + Schema.SObjectType.Case.getRecordTypeInfosByName());
        System.debug('minhaj id' + recId);
        return [select id, RecordType.Name, RecordType.DeveloperName from Case where id = :recId ][0].RecordType.DeveloperName;
        //  return null;
    } 
    
 
    
     @AuraEnabled 
    public static String navigateEdit(String recId){
        System.debug('minhaj navigateURl');
        //getCaseActionList();
        //
        List<StandardActionRedirection__C> sActionList = new List<StandardActionRedirection__C>();
        sCaseActionList = new List<StandardActionRedirection__C>();
        sActionList=StandardActionRedirection__C.getAll().values();
        for(StandardActionRedirection__C sAction: sActionList){
            if(sAction.Object__c.equalsIgnoreCase('Case') && sAction.Action__c.equalsIgnoreCase('EDIT')){
                sCaseActionList.add(sAction);
            }
        }
        System.debug(sCaseActionList);
        
        retURL = ApexPages.currentPage()?.getParameters()?.get('retURL');
        //cancelURL = ApexPages.currentPage().getParameters()?.get('cancelURL');
        //ent = ApexPages.currentPage().getParameters()?.get('ent');
       // confirmationToken = ApexPages.currentPage().getParameters()?.get('_CONFIRMATIONTOKEN');
        //saveNewURL = ApexPages.currentPage().getParameters()?.get('save_new_url');
        accountID = ApexPages.currentPage()?.getParameters()?.get('def_account_id');
        contactID = ApexPages.currentPage()?.getParameters()?.get('def_contact_id');  
        caseEdit = [select id,Casenumber,RecordtypeId,RecordType.developerName from case where id = :recId];
        System.debug(caseEdit);
        if(retURL == null || retURL == '')
        {
            retURL = '/' + caseEdit.id ;
        }
        
        rType = caseEdit.RecordtypeId;
        
        User u = [select Id, username,userType,profile.name from User where Id = :UserInfo.getUserId()];
        System.debug(u);
      if(u.userType=='PowerCustomerSuccess')
      {
       rtype=null;
      }
        
        Map<String, Id> recordTypesByName = new Map<String, Id>();
        List<RecordType> rtList = [SELECT id,developerName FROM RecordType where SobjectType='Case'];
        String ref;
        for(RecordType rt: rtList){
            recordTypesByName.put(rt.developerName, rt.Id);
        }   
        system.debug(u.profile.name);
        System.debug(recordTypesByName);
        for(StandardActionRedirection__c action: sCaseActionList){
            system.debug(action.Profile_del__c);
            if(action.Profile_del__c <> null && action.Profile_del__c==u.profile.name){
                ref = action.URI__c + string.valueof(caseedit.ID)+'&retURL='+retURL;   
                //ref.setRedirect(true);
                return String.valueOf(ref);
            }
        }
        for(StandardActionRedirection__c action: sCaseActionList){
            system.debug('Action RT: '+action.Record_Type__c+' rType????: '+rType+' rType: '+recordTypesByName.get(action.Record_Type__c));
            if(action.Record_Type__c!=null && rType!=null && rType==recordTypesByName.get(action.Record_Type__c)){ 
                if(action.URI__c.indexOF('Caseid') > -1)
                {
                    ref = action.URI__c.replaceAll('Caseid',string.valueof(caseedit.ID)) + retURL;   
                   // ref.setRedirect(true);
                    return String.valueOf(ref);  
                }
                else
                {               
                    ref = action.URI__c + string.valueof(caseedit.ID)+'&retURL='+retURL;   
                    //ref.setRedirect(true);
                    return String.valueOf(ref);        
                }
            }
        }
        string defPageReference = '/' + caseEdit.id + '/e?nooverride=1&retURL=' + retURL.escapeHtml4();
        if(accountID!=null && accountId!=''){
            defPageReference=defPageReference+'&def_account_id='+accountId.escapeHtml4();
        }
        else if(contactId!=null && contactId!=''){
            defPageReference=defPageReference+'&def_contact_id='+contactId.escapeHtml4();
        }
        return defPageReference;
        
    }
    
    @AuraEnabled  
    public static void getCaseActionList(){
        List<StandardActionRedirection__C> sActionList = new List<StandardActionRedirection__C>();
        sCaseActionList = new List<StandardActionRedirection__C>();
        sActionList=StandardActionRedirection__C.getAll().values();
        for(StandardActionRedirection__C sAction: sActionList){
            if(sAction.Object__c.equalsIgnoreCase('Case') && sAction.Action__c.equalsIgnoreCase('EDIT')){
                sCaseActionList.add(sAction);
            }
        }
         System.debug(sCaseActionList);
    }
}