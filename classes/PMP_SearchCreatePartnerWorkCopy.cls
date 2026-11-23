public class PMP_SearchCreatePartnerWorkCopy implements Queueable{
    List<PMP_Company__c> newcompanies;
    List<PMP_Company__c> createworkcopies = new List<PMP_Company__c>();
    List<PMP_Company__c> updatepublished = new List<PMP_Company__c>();    
    public PMP_SearchCreatePartnerWorkCopy(List<PMP_Company__c> newcompanies) {
        this.newcompanies = newcompanies;
        this.createworkcopies = new List<PMP_Company__c>();
        this.updatepublished = new List<PMP_Company__c>(); 
    }
    public void execute(QueueableContext context) {
        for(PMP_Company__c partner : newcompanies){
            PMP_Company__c partner_wc                      		= new PMP_Company__c();
            partner_wc.Name                                		= partner.Name;
            partner_wc.PMP_Account_Id__c                   		= partner.PMP_Account_Id__c;
            partner_wc.PMP_Company_Lifecycle_Status_Nm__c  		= PMP_StaticConstants_Partner.Draft;            
            partner_wc.PMP_Account_Website__c              		= partner.PMP_Account_Website__c;
            partner_wc.PMP_Account_Program_Membership__c		= partner.PMP_Account_Program_Membership__c;
            partner_wc.PMP_Partner_Program_nm__c 				= partner.PMP_Partner_Program_nm__c;                
            partner_wc.PMP_Account_Specialty__c 				= partner.PMP_Account_Specialty__c;		
            partner_wc.PMP_Is_Published_Ind__c             		= false;                        
            partner_wc.PMP_Is_Working_Copy_Ind__c          		= true;            
            partner_wc.PMP_Company_Status_Update_Dt__c     		= Date.today();
            partner_wc.PMP_Published_Copy_Id__c					= partner.Id;
            //Added by nikhil to update One partner id in working copy as well 28-Nov-2019
            partner_wc.PMP_One_Partner_ID__c 					= partner.PMP_One_Partner_ID__c;
            createworkcopies.add(partner_wc);
            
        }
        if(!createworkcopies.isEmpty()){
            Insert(createworkcopies);
            
            Set<Id> partnerIdsCreated = new Set<Id>();
            for(PMP_Company__c wc : createworkcopies) {
                PMP_Company__c pc = new PMP_Company__c();
                pc.Id = wc.PMP_Published_Copy_Id__c;
                pc.PMP_Working_Copy_Id__c = wc.Id;
                updatepublished.add(pc);
            }
            if(!updatepublished.isEmpty()){
                update(updatepublished);
            }                    
        }
    }
}