global class Core_DelegateApproverRoleUpdateBatch  {
    /*implements Database.Batchable<sObject>, Database.Stateful {
    List<Id> uId;
    global  Core_DelegateApproverRoleUpdateBatch(List<ID> userId){
        uId=new List<ID>();
        uId= userId;
        System.debug('user Id'+uId);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,Core_user__c,Core_isActive__c,Core_oldRole__c,Core_newRole__c from Core_DelegateApproverDetails__c where Core_user__c In :uId ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Core_DelegateApproverDetails__c> scope){
        
        System.debug('Scope--'+scope);
        Map<Id,User> delegatedUser=new Map<Id,User>([select  id ,name, DelegatedApproverId, UserRoleId, UserRole.name,UserRole.ParentRoleId 
                                                     from User where id In : uId]);
         List<User> userObj=new List<User>();
        if(!scope.isEmpty()){
            for(Core_DelegateApproverDetails__c det : scope ){
                System.debug('details--'+det);
                User u =new User();
                //u.id=det.Core_user__c;
                if(delegatedUser.keySet().contains(det.Core_user__c)){
                 	u=delegatedUser.get(det.Core_user__c);
                    System.debug('Active--'+det.Core_isActive__c);
                        if(det.Core_isActive__c==true){
                            u.UserRoleId=det.Core_newRole__c;
                         userObj.add(u);}
                    else if(det.Core_isActive__c==false){
                        u.UserRoleId=det.Core_oldRole__c;
                     userObj.add(u);}
                 
                }
              
            }
        }
        if(!userObj.isEmpty()){
            update userObj;
        }
    }
    global void finish(Database.BatchableContext BC){}
*/
}