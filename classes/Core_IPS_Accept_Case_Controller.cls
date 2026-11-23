public with sharing class Core_IPS_Accept_Case_Controller {
    public String caseId{get;set;}
    public Case cs{get;set;}
    Public String errorMessage{get;set;}
    public Core_IPS_Accept_Case_Controller(ApexPages.StandardController controller) {
        cs=(Case)controller.getRecord();
        caseId=cs.id;
        errorMessage='Case Owner updated successfully.';
    }
    public PageReference goBack(){
        PageReference requestPage= new pagereference('/'+cs.id);
        requestPage.setRedirect(true);
        return requestPage;
    }
    public PageReference updateCaseOwner(){
        PageReference requestPage=null;
        try{
             cs.OwnerId=userinfo.getuserId();
             update cs;
             ApexPages.currentPage().getParameters().put('id',cs.id);
          }catch(Exception ex){
              ApexPages.currentPage().getParameters().put('id',cs.id);
              errorMessage='You dont have access to this functionality.';
          }
         // end  
        return requestPage;
    }

}