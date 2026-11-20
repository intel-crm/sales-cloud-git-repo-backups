/************
* Name : Core_AAQC_Case_Ask_Commissions_Handler
* Date Created : 10-November-2018
* Description : Handles sharing and un-sharing case when user wants manager to have access.
* Version Updates : 
*   
* Date          By                    User-Story    Details 
* 10-Nob-18     Rob Robertson         US110979		Created	
********************/
public  class Core_AAQC_Case_Ask_Commissions_Handler {

    public static Id GetAskCommissionsRecordTypeId(){
        return Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ask Commissions Case').getRecordTypeId();
    }
    
    /*
    public static void ShareWithOBOField(List<Case> newList){
        system.debug('newList' + newList);
        system.debug('inside ShareWithOBOField');
        
        
        for(Case newCase : newList){
            if((newCase.RecordTypeId == GetAskCommissionsRecordTypeId()) && newCase.Core_AAQC_On_Behalf_Of__c != null 
                        && newCase.Core_AAQC_Owner_Updated__c != null && newCase.Core_AAQC_Owner_Updated__c){
                    system.debug('inside share with OBO Field all consition satisfied');
                    CaseShare cShare = new CaseShare();
                    cShare.CaseId = newCase.Id;
                    cShare.UserOrGroupId = newCase.Core_AAQC_On_Behalf_Of__c;
                    cShare.CaseAccessLevel = 'edit';
                    Database.SaveResult sr = Database.insert(cShare, false);
                    system.debug('cShare' + cShare);
                    
                    List<Core_AAQC_Commissions_Case__c> lstCaseInquiry =[select id from Core_AAQC_Commissions_Case__c where Core_AAQC_Case__c =: newCase.Id ];
                    
                    if(lstCaseInquiry != null && lstCaseInquiry.size() > 0 ){
                        Core_AAQC_Commissions_Case__share cInquiryShare = new Core_AAQC_Commissions_Case__share();
                        cInquiryShare.ParentId = lstCaseInquiry[0].Id;
                        cInquiryShare.UserOrGroupId = newCase.Core_AAQC_On_Behalf_Of__c;
                        cInquiryShare.AccessLevel='edit';
                        Database.SaveResult sr1 = Database.insert(cInquiryShare, false);
                        system.debug('cInquiryShare' + cInquiryShare);  
                    }
            }
        }
    }
    
    
    public static void UpdateCreatedByManagerEmail(List<Case> newList,Map<Id,Case> oldMap){
        system.debug('newList' + newList);
        system.debug('inside UpdateCreatedByManagerEmail');
        system.debug('oldMap' + oldMap);
        
        
        for(Case newCase : newList){
            if((newCase.RecordTypeId == GetAskCommissionsRecordTypeId()) ){
                if((newCase.Core_AAQC_Allow_My_Manager_to_See__c != null && newCase.Core_AAQC_Allow_My_Manager_to_See__c == true)){
                    system.debug('inside UpdateCreatedByManagerEmail');
                    List<user> lstUser = [select id,Manager.Email from user where id =: UserInfo.getUserId()];
                    system.debug('lstUser' + lstUser);
                    if(lstUser != null && lstUser.size()>0){
                        newCase.Core_AAQC_Created_by_s_Manager_Email__c = lstUser[0].Manager.Email;
                    }
                }
                else if((newCase.Core_AAQC_Allow_My_Manager_to_See__c != null && newCase.Core_AAQC_Allow_My_Manager_to_See__c == false)){
                    newCase.Core_AAQC_Created_by_s_Manager_Email__c = '';
                }
            }
        }
    }
    
    /*
    public static void ShareWithMyManager(List<Case> newList, Map<Id,Case> oldMap)
    {

        for(Case newCase : newList)
        {
            //Only operate on Ask Commissions Record Types
            system.debug('Core_AAQC_Case_Ask_Commissions_Handler - ShareWithMyManager: newCase ' + newCase);
            if((newCase.RecordTypeId == GetAskCommissionsRecordTypeId()) 
                        && newCase.Core_AAQC_Owner_Updated__c != null && newCase.Core_AAQC_Owner_Updated__c){
                
                system.debug('Core_AAQC_Case_Ask_Commissions_Handler - ShareWithMyManager: newCase ' + newCase);
                Case oldCase = (oldMap == null) ? null : oldMap.get(newCase.Id);
                system.debug('Core_AAQC_Case_Ask_Commissions_Handler - ShareWithMyManager: oldCase ' + oldCase);
    
                if (newCase.Core_AAQC_Allow_My_Manager_to_See__c){
                    ShareCaseWithManager(newCase);
                }
                else if (!(newCase.Core_AAQC_Allow_My_Manager_to_See__c)){
                    UnShareCaseWithManager(newCase);
                }
           }
        }
    }

    public static boolean ShareCaseWithManager(Case myCase){
		return ShareUnshareCaseWithManager(myCase,true);
    }
    
    public static boolean UnShareCaseWithManager(Case myCase){
		return ShareUnshareCaseWithManager(myCase,false);
    }
    
    public static boolean ShareUnshareCaseWithManager(Case myCase,boolean isShare){
        if(myCase == null){
        	system.debug('Core_AAQC_Case_Ask_Commissions_Handler ShareUnshareCaseWithManager: myCase is null');
            return false;
        }
        
        List<User> managers = new List<user>();
        system.debug('myCase.CreatedBy.Id' + myCase.CreatedById);
        managers = [SELECT ManagerId FROM USER WHERE Id = :myCase.CreatedById];
        system.debug('managers' + managers);
        
        if(managers == null || managers.size() != 1){
        	system.debug('Core_AAQC_Case_Ask_Commissions_Handler ShareUnshareCaseWithManager: Manager Not Found.  Manager: ' + managers);
            return false;
        }
        else{
	       	system.debug('Core_AAQC_Case_Ask_Commissions_Handler ShareUnshareCaseWithManager: ManagerId: ' + managers[0].ManagerId);
        }
        
        if(isShare)
			return ShareCase(myCase.Id, managers[0].ManagerId);     
        else
            return UnShareCase(myCase.Id, managers[0].ManagerId);     
    }
    
    public static boolean ShareCase(Id caseId, Id shareWithId)
    {
        system.debug('Core_AAQC_Case_Ask_Commissions_Handler ShareCase caseId ' + caseId + ' ShareWithId ' + shareWithId);

        if (caseId == null){
	        system.debug('Core_AAQC_Case_Ask_Commissions_Handler ShareCase caseId is null');
            return false;
        }
        
        if (shareWithId == null){
	        system.debug('Core_AAQC_Case_Ask_Commissions_Handler ShareCase shareWithId is null');
            return false;
        }
        
        try{
            
            CaseShare cShare = new CaseShare();
            cShare.CaseId = caseId;
            cShare.UserOrGroupId = shareWithId;
            cShare.CaseAccessLevel = 'edit';
            
            Database.SaveResult sr = Database.insert(cShare, false);
    
            system.debug('cShare' + cShare);
            
            List<Core_AAQC_Commissions_Case__c> lstCaseInquiry =[select id from Core_AAQC_Commissions_Case__c where Core_AAQC_Case__c =: caseId ];
                    
            if(lstCaseInquiry != null && lstCaseInquiry.size() > 0 ){
                Core_AAQC_Commissions_Case__share cInquiryShare = new Core_AAQC_Commissions_Case__share();
                cInquiryShare.ParentId = lstCaseInquiry[0].Id;
                cInquiryShare.UserOrGroupId = shareWithId;
                cInquiryShare.AccessLevel='edit';
                Database.SaveResult sr1 = Database.insert(cInquiryShare, false);
                system.debug('cInquiryShare' + cInquiryShare);  
            }
            return sr.isSuccess();
            
        }
        catch(Exception e){
            system.debug('==Error while saving the record=='+e);
            return false;
        }

    }
    
    public static boolean UnShareCase(Id caseId, Id shareWithId)
    {
        system.debug('Core_AAQC_Case_Ask_Commissions_Handler UnShareCase caseId ' + caseId + ' ShareWithId ' + shareWithId);

        if (caseId == null){
	        system.debug('Core_AAQC_Case_Ask_Commissions_Handler UnShareCase caseId is null');
            return false;
        }
        
        if (shareWithId == null){
	        system.debug('Core_AAQC_Case_Ask_Commissions_Handler UnShareCase shareWithId is null');
            return false;
        }
        
        // Query case sharing records.
        List<CaseShare> caseShares = [SELECT Id, UserOrGroupId, 
            RowCause FROM CaseShare WHERE CaseId = :caseId AND UserOrGroupId= :shareWithId];
            
        List<Core_AAQC_Commissions_Case__c> lstCaseInquiry =[select id from Core_AAQC_Commissions_Case__c where Core_AAQC_Case__c =: caseId ];
        
        if(lstCaseInquiry != null && lstCaseInquiry.size() > 0 ){
            List<Core_AAQC_Commissions_Case__share> cInquiryShare = [SELECT Id, UserOrGroupId, 
                    RowCause FROM Core_AAQC_Commissions_Case__share WHERE ParentId = :lstCaseInquiry[0].Id AND UserOrGroupId= :shareWithId]; 
            if(cInquiryShare != null && cInquiryShare.size() >0){
              Database.DeleteResult delResult = Database.delete(cInquiryShare[0]);  
            }
        }
            
        

        if (caseShares == null || caseShares.size() != 1){
	        system.debug('Core_AAQC_Case_Ask_Commissions_Handler UnShareCase caseShares not found ' + caseShares);
            return false;
        }
        
        Database.DeleteResult delResult = Database.delete(caseShares[0]);
        return delResult.isSuccess();
    }
    
    */
}