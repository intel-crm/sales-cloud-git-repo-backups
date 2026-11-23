public with sharing  class Core_IPS_CaseNotification_Controller{
    public string message{get;set;}
    public Case cs{get;set;}
    
    public Core_IPS_CaseNotification_Controller(ApexPages.standardController controller){
        cs=[select id, createddate,createdbyid from case where id=:controller.getId()];
        if(Userinfo.getUserId()==cs.createdById && (timeutils.diffMinutes(System.now(),cs.createdDate)*60)<Integer.valueof(Core_IPS_Helper_Utility.getIPSLabel('TimeOfAlertMessageInSeconds')))
            message = System.label.Core_IPS_Case_Creation_Alert_Message;
        else
            message=null;
    }
    
}