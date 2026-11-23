public without sharing  class Core_IPS_ViewCase_Controller1 {
    public Boolean dataNotFoundCheck{get;set;}
    public Core_IPS_ViewCase_Controller1(ApexPages.StandardController controller) {  
        dataNotFoundCheck=false;
        try{
         system.debug('message===>>>'+controller.getId());
            case c=[select id from case where id=:controller.getId()];
            system.debug('c===>>>'+c);
        }catch(Exception e){
            system.debug('message===>>>'+e.getmessage());
            dataNotFoundCheck=true;           
        }
   }
}