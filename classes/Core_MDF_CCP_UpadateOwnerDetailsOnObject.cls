/****************************************************************************************************************************************
 * Class Name  : Core_MDF_CCP_UpadateOwnerDetailsOnObject
 * Version     : 1.0
 * Created Date: 04-22-2022
 * Modification Log :
 * Developer:Chaithanya Lakshman       Date:04-22-2022               Description:Batch to update CCP-ownership transfer
 * ---------------------------------------------------------------------------------------------------------------------------------------
 *****************************************************************************************************************************************/
global class Core_MDF_CCP_UpadateOwnerDetailsOnObject implements Database.Batchable<sObject>, Database.Stateful{

    private String objectSelected ;
        private String oldOwner;
        private String newOwner;
        private String errorMsg;
        private String recordId;
        public Core_MDF_CCP_UpadateOwnerDetailsOnObject(String objectSelected,String oldOwner,String newOwner,String errorMsg,String recordId ){
            this.objectSelected=objectSelected;
            this.oldOwner=oldOwner;
            this.newOwner=newOwner;
            this.errorMsg=errorMsg;
            this.recordId=recordId;
       
        }
      
    global Database.QueryLocator start(Database.BatchableContext BC) {       
        String queryString= 'SELECT Id,OwnerId FROM '+objectSelected+' where OwnerId =\''+oldOwner+'\'';
        system.debug('query'+queryString);
        return Database.getQueryLocator(queryString); 
    }

    global void execute(Database.BatchableContext BC, List< sObject > scope) {   
            List<SObject> sobjectValue=new List<SObject>();
			sobjectValue=scope;
            String queryString='';
            System.debug('object name'+objectSelected);
            if(sobjectValue.size()>0){
            switch on objectSelected {
               
             when 'Account' {
                 List <Account> updateList=new List<Account>();
                
                 try{
                     for(SObject objectnew:sobjectValue)
                 {
                     Account acc=(Account)objectnew;
                     acc.OwnerId=newOwner;
                     updateList.add(acc);
                 }
                     database.SaveResult[] saveResult=database.update(updateList,false);
                     System.debug('account'+updateList);
                     for(Database.SaveResult saveResultNew:saveResult){
						if(!(saveResultNew.isSuccess())){
                              recordId=saveResultNew.getId();
                              errorMsg+=recordId+':'+saveResultNew.getErrors()[0].getMessage()+'<br/>';
                              System.debug('errormsg'+errorMsg);
						 }
                     }
                     system.debug('saveResult size'+saveResult.size());
                    
                 }
                 catch (Exception e){
                     System.debug('An exception occurred :Account ' + e.getMessage()); 
                      Core_Log_Entry.logEntryWithDetails(Core_MDF_CCP_OwnerTransfer.ORIGIN, Core_MDF_CCP_OwnerTransfer.PROJECT,'',Core_MDF_CCP_OwnerTransfer.INFOSEVERITY,'','Error Occurred while updating Owner on Object: '+objectSelected+' from user:'+newOwner+' to user:'+oldOwner+'Error:'+errorMsg,'', '', '');
                     }
                }
               when 'Contact' {
                 List <Contact> updateList=new List<Contact>();
              try{
                for(SObject objectnew:sobjectValue)
                 {
                     Contact acc=(Contact)objectnew;
                     acc.OwnerId=newOwner;
                     updateList.add(acc);
                 }
                database.SaveResult[] saveResult=database.update(updateList,false);
                     System.debug('contact'+updateList);
                     for(Database.SaveResult saveResultNew:saveResult){
						if(!(saveResultNew.isSuccess())){
                              recordId=saveResultNew.getId();
                              errorMsg+=recordId+':'+saveResultNew.getErrors()[0].getMessage()+'<br/>';
                            System.debug('errormsg'+errorMsg);
						 }
                     }
					
                     system.debug('saveResult size'+saveResult.size());
                    
                 }
                 catch (Exception e){
                     System.debug('An exception occurred :Contact ' + e.getMessage()); 
                    Core_Log_Entry.logEntryWithDetails(Core_MDF_CCP_OwnerTransfer.ORIGIN, Core_MDF_CCP_OwnerTransfer.PROJECT,'',Core_MDF_CCP_OwnerTransfer.INFOSEVERITY,'','Error Occurred while updating Owner on Object: '+objectSelected+' from user:'+newOwner+' to user:'+oldOwner+'Error:'+errorMsg,'', '', '');
                     }
            }

            when 'PartnerFundClaim' {
                 List <PartnerFundClaim> updateList=new List<PartnerFundClaim>();
               try{
                 for(SObject objectnew:sobjectValue)
                 {
                     PartnerFundClaim acc=(PartnerFundClaim)objectnew;
                     acc.OwnerId=newOwner;
                     updateList.add(acc);
                 }
                database.SaveResult[] saveResult=database.update(updateList,false);
                     System.debug('claim'+updateList);
                     for(Database.SaveResult saveResultNew:saveResult){
						if(!(saveResultNew.isSuccess())){
                              recordId=saveResultNew.getId();
                              errorMsg+=recordId+':'+saveResultNew.getErrors()[0].getMessage()+'<br/>';
                              System.debug('errormsg'+errorMsg);
						 }
                     }
					
                     system.debug('saveResult size'+saveResult.size());
                 }
                 catch (Exception e){
                     System.debug('An exception occurred :Claim ' + e.getMessage()); 
                    Core_Log_Entry.logEntryWithDetails(Core_MDF_CCP_OwnerTransfer.ORIGIN, Core_MDF_CCP_OwnerTransfer.PROJECT,'',Core_MDF_CCP_OwnerTransfer.INFOSEVERITY,'','Error Occurred while updating Owner on Object: '+objectSelected+' from user:'+newOwner+' to user:'+oldOwner+'Error:'+errorMsg,'', '', '');
                    }
            }
                when 'Campaign' {
                 List <Campaign> updateList=new List<Campaign>();
                 try{
                 for(SObject objectnew:sobjectValue)
                 {
                     Campaign acc=(Campaign)objectnew;
                     acc.OwnerId=newOwner;
                     updateList.add(acc);
                 }
                 database.SaveResult[] saveResult=database.update(updateList,false);
                     System.debug('campaign'+updateList);
                     for(Database.SaveResult saveResultNew:saveResult){
						if(!(saveResultNew.isSuccess())){
                              recordId=saveResultNew.getId();
                              errorMsg+=recordId+':'+saveResultNew.getErrors()[0].getMessage()+'<br/>';
                              System.debug('errormsg'+errorMsg);
						 }
                     }
			  }	  
             
            catch (Exception e){
                     System.debug('An exception occurred :Campaign ' + e.getMessage()); 
                     Core_Log_Entry.logEntryWithDetails(Core_MDF_CCP_OwnerTransfer.ORIGIN, Core_MDF_CCP_OwnerTransfer.PROJECT,'',Core_MDF_CCP_OwnerTransfer.INFOSEVERITY,'','Error Occurred while updating Owner on Object: '+objectSelected+' from user:'+newOwner+' to user:'+oldOwner+'Error:'+errorMsg,'', '', '');
                     } 
             }
                
              when 'PartnerFundRequest' {
                 List <PartnerFundRequest> updateList=new List<PartnerFundRequest>();
                 try{
                 for(SObject objectnew:sobjectValue)
                 {
                     PartnerFundRequest acc=(PartnerFundRequest)objectnew;
                     acc.OwnerId=newOwner;
                     updateList.add(acc);
                 }
                     database.SaveResult[] saveResult=database.update(updateList,false);
                     System.debug('co-marketing'+updateList);
                     for(Database.SaveResult saveResultNew:saveResult){
		               if(!(saveResultNew.isSuccess())){
                              recordId=saveResultNew.getId();
                              errorMsg+=recordId+':'+saveResultNew.getErrors()[0].getMessage()+'<br/>';
                              System.debug('errormsg'+errorMsg);
					     
						 }
                     }
					 
            }  
            catch (Exception e){
                     System.debug('An exception occurred :Co-Marketing Activities ' + e.getMessage()); 
                     Core_Log_Entry.logEntryWithDetails(Core_MDF_CCP_OwnerTransfer.ORIGIN, Core_MDF_CCP_OwnerTransfer.PROJECT,'',Core_MDF_CCP_OwnerTransfer.INFOSEVERITY,'','Error Occurred while updating Owner on Object: '+objectSelected+' from user:'+newOwner+' to user:'+oldOwner+'Error:'+errorMsg,'', '', '');
                     } 
             }   
            when 'PartnerMarketingBudget' {
                 List <PartnerMarketingBudget> updateList=new List<PartnerMarketingBudget>();
                 try{
                 for(SObject objectnew:sobjectValue)
                 {
                     PartnerMarketingBudget acc=(PartnerMarketingBudget)objectnew;
                     acc.OwnerId=newOwner;
                     updateList.add(acc);
                 }
                     database.SaveResult[] saveResult=database.update(updateList,false);
                     System.debug('budget'+updateList);
                     for(Database.SaveResult saveResultNew:saveResult){
						if(!(saveResultNew.isSuccess())){
                            recordId=saveResultNew.getId();
                            errorMsg+=recordId+':'+saveResultNew.getErrors()[0].getMessage()+'<br/>';
                            System.debug('errormsg'+errorMsg);
					       
						 }
                     }
					 system.debug('saveResult size'+saveResult.size());
               
            }  
            catch (Exception e){
                     System.debug('An exception occurred :Budget ' + e.getMessage()); 
                    Core_Log_Entry.logEntryWithDetails(Core_MDF_CCP_OwnerTransfer.ORIGIN, Core_MDF_CCP_OwnerTransfer.PROJECT,'',Core_MDF_CCP_OwnerTransfer.INFOSEVERITY,'','Error Occurred while updating Owner on Object: '+objectSelected+' from user:'+newOwner+' to user:'+oldOwner+'Error:'+errorMsg,'', '', '');
                  } 
             } 
           when 'Case' {
                 List <Case> updateList=new List<Case>();
                 try{
                 for(SObject objectnew:sobjectValue)
                 {
                     Case acc=(Case)objectnew;
                     acc.OwnerId=newOwner;
                     updateList.add(acc);
                 }
                     database.SaveResult[] saveResult=database.update(updateList,false);
                     System.debug('case'+updateList);
                     for(Database.SaveResult saveResultNew:saveResult){
						if(!(saveResultNew.isSuccess())){
                              recordId=saveResultNew.getId();
                              errorMsg+=recordId+':'+saveResultNew.getErrors()[0].getMessage()+'<br/>';
                              System.debug('errormsg'+errorMsg);
					      
						 }
                     }
              }
            
            catch (Exception e){
                     System.debug('An exception occurred :Case ' + e.getMessage()); 
                    Core_Log_Entry.logEntryWithDetails(Core_MDF_CCP_OwnerTransfer.ORIGIN, Core_MDF_CCP_OwnerTransfer.PROJECT,'',Core_MDF_CCP_OwnerTransfer.INFOSEVERITY,'','Error Occurred while updating Owner on Object: '+objectSelected+' from user:'+newOwner+' to user:'+oldOwner+'Error:'+errorMsg,'', '', '');
                    } 
             } 
                
             }
            
      
                                      
            }
     }
	

    global void finish(Database.BatchableContext BC) {
        try{
           system.debug('Finish::');            
           if(errorMsg!='')
            {   //error while updating
               system.debug('user email'+UserInfo.getUserEmail()+'object'+objectSelected);
               Core_MDF_CCP_OwnerTransfer.sendEmailOnExcpetion(UserInfo.getUserEmail(),objectSelected,errorMsg); 
               Core_Log_Entry.logEntryWithDetails(Core_MDF_CCP_OwnerTransfer.ORIGIN, Core_MDF_CCP_OwnerTransfer.PROJECT,'',Core_MDF_CCP_OwnerTransfer.INFOSEVERITY,'','Error Occurred while updating Owner on Object: '+objectSelected+' from user:'+newOwner+' to user:'+oldOwner+'Error:'+errorMsg,'', '', '');

            }
            else
            {   //success 
                errorMsg='Sucess:All records are transferred to new owner successfully';
                Core_MDF_CCP_OwnerTransfer.sendEmailOnExcpetion(UserInfo.getUserEmail(),objectSelected,errorMsg);   
            }
        }
		catch(Exception e) 
		{
          if(e!=null)
		    {  //log for email failure scenario
	          Core_Log_Entry.logEntryWithDetails(Core_MDF_CCP_OwnerTransfer.ORIGIN, Core_MDF_CCP_OwnerTransfer.PROJECT,'',Core_MDF_CCP_OwnerTransfer.INFOSEVERITY,'','Error Occurred While sending email to User Email : '+ UserInfo.getUserEmail()+'while updating ownership of Object:'+objectSelected+' from user:'+newOwner+' to user:'+oldOwner+'Error:'+ e.getMessage()+ ', Stack trace: '+e.getStackTraceString(),'', '', '');
		    }
		}
    }
    
}