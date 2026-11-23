public class Core_IPS_Interested_Party_Controller {
    public Id CaseId {get;set;} 
   
    public Core_IPS_Interested_Party_Controller(ApexPages.StandardSetController controller){
        CaseId = ApexPages.currentPage().getParameters().get('id');//'5003F000005wnU7';//
    }
}