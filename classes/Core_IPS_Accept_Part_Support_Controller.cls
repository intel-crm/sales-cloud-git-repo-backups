public with sharing class Core_IPS_Accept_Part_Support_Controller {
    public String caseId{get;set;}
    public Case cs{get;set;}
    Public String errorMessage{get;set;}
    public Core_IPS_Accept_Part_Support_Controller(ApexPages.StandardController controller) {
        cs=(Case)controller.getRecord();
        caseId=cs.id;
        errorMessage='Partner Support Owner updated successfully.';
    }
    public PageReference goBack(){
        PageReference requestPage= new pagereference('/'+cs.id);
        requestPage.setRedirect(true);
        return requestPage;
    }
    
    public PageReference updateOwner(){
        PageReference requestPage=null;
        //Added for testing Start
        PermissionSet  pset=[select id,label from PermissionSet where Label = 'IPS Partner FAE Permission Set']; //IPS Permission Set  //'DDR Permission Set'
         List<PermissionSetAssignment> lpermission=[select id,PermissionSetId from PermissionSetAssignment where AssigneeId =:userinfo.getuserId()  and PermissionSetId =:pset.id];//0PSo0000000JnTP  //'0PS3F0000004ENc'
         if(lpermission.size()>0){
             cs.Core_IPS_Partner_Sup_Owner__c =userinfo.getuserId();
             update cs;
             ApexPages.currentPage().getParameters().put('id',cs.id);
          }
          else{
              ApexPages.currentPage().getParameters().put('id',cs.id);
              errorMessage='You dont have access to this functionality.';
          }
         // end  
        return requestPage;
    }
}