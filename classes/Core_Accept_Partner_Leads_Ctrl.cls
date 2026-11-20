/*
**************************************************************************************
Vf page Name: Core_Accept_Partner_Leads_Ctrl
Version     : 1.0 
Created Date: 5/6/2018
Description :This Class is used  in classic and lightning page for accept partner lead on listview button.
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            5/6/2018               Initial Revision

*/
public class  Core_Accept_Partner_Leads_Ctrl {
    
    public ApexPages.StandardSetController setCtrl;
    public String alertMessage{get;set;}
    public String retUrl{get;set;}
    
    public Core_Accept_Partner_Leads_Ctrl(ApexPages.StandardSetController stdSetCtrl){
        setCtrl = stdSetCtrl;
    }
    
    public PageReference acceptPartnerLeads(){
        if(UserInfo.getUiThemeDisplayed() == 'Theme3')
            retUrl = apexpages.currentpage().getParameters().get('retURL');
        else
            retUrl = apexpages.currentpage().getParameters().get('vfRetURLInSFX'); 
                       
      //  String profileName = [select Id, Name from Profile where Id =: UserInfo.getProfileId()].Name;      
       Boolean profileName = [select Id, IsPortalEnabled from User where Id =:UserInfo.getUserId()].IsPortalEnabled;  
       // if(!profileName.contains('partner'))      
        if(profileName==false){
            alertMessage = 'This capability is available for Partner Leads only.';
        }else if(setCtrl.getResultSize() == 0){
            alertMessage = 'Please select one or more Leads.';
        }else{
            alertMessage = 'You have successfully accepted the leads.';
            List<Lead> leadList = (List<Lead>)setCtrl.getSelected();
            List<Lead> updateleadList = new List<Lead>();
            for(Lead led : leadList){
                Lead updateLead = new Lead();
                updateLead.Id = led.Id;
                updateLead.Status = 'Partner Qualified Lead'; 
                updateLead.Core_Lead_State__c = 'Accepted'; 
                updateLead.Core_Partner_Lead_Owner__c = UserInfo.getUserId(); 
                updateLead.Core_Rejection_Comments__c = null; 
                updateLead.Core_Rejection__c = null;
                updateleadList.add(updateLead);
            }
            try{
                 if(updateleadList.size()>0){
                   update updateleadList;
                   alertMessage= updateleadList.size() + ' ' + 'Leads Accepted successfully.';               
                }
              }catch(Exception e){ alertMessage='An error has occurred! Error:'+e.getMessage();}
                
   
        }
        return null;
    }
}