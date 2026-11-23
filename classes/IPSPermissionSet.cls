Public class IPSPermissionSet{
public List<PermissionSetAssignment> query;
public boolean isHavingAccess{get;set;}
public final Case cs;

public IPSPermissionSet(ApexPages.StandardController stdController) {
        this.cs= (Case)stdController.getRecord();
       
    }

Public void assignment(){
//0PS3F0000004ENc
   query= [SELECT Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() and PermissionSetId='0PS3F0000004ENc' limit 1];//0PS3F0000004ENc
   if(query.size()>0){
       isHavingAccess=true;
      // User u = [SELECT Id, IsActive FROM User ];
       
        //cs =new Case();
        //cs.Core_IPS_Partner_Sup_Owner__c=u.id;
        //update cs;
       }else{
       isHavingAccess=false;
       }
  }

}