/****************************************************************************************************************************************
* Class Name  : Core_IPS_ProjectDetailPrint_Ctrl 
* Version     : 1.0 
* Created Date:  17/04/2022 
* Modification Log :
* Developer: Minhaj Ameen                     Date                          Description: 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps           17/04/2022                Main Controller for Core_IPS_ProjectDetailPrint_page.vfp
*****************************************************************************************************************************************/


public with sharing class Core_IPS_ProjectDetailPrint_Ctrl {
    
    public String currentProjRecordId{get; set;}
    public Core_IPS_Project__c projRecord{get; set;} 
    public List<Case> caseList;
    public List<Core_IPS_Project__c> childIpsProducts;
    
    public Core_IPS_ProjectDetailPrint_Ctrl(){
            // Unencoded Formulas in Script Tags XSS Fix - TWC745-7251
        currentProjRecordId = ApexPages.CurrentPage().getparameters().get('recordId').escapeHtml4();

        projRecord = [SELECT Id,Name,Core_MPNDA__c,Core_Project_Description__c,
                      Core_Status__c,Core_IPS_EnableMemberasInterestedParties__c,
                      Core_IPS_Enable_ISTasInterested_Parties__c,Core_IPS_Project_ID__c    
                      FROM Core_IPS_Project__c where id=:currentProjRecordId];
        
    }
    
    public List<Case> getAllCaseRecordsUnderProject(){
        caseList = [SELECT Id,Core_IPS_Project_Case__c,
                    CaseNumber,
                    Status,
                    Subject,
                    CreatedDate,
                    LastModifiedDate 
                    FROM Case where Core_IPS_Project_Case__c =: currentProjRecordId  ORDER BY CreatedDate];
        return caseList;
    }
    
    public  list<Core_IPS_Product__c> getChildIpsProductsToProject(){
        childIpsProducts = [select id, (select id,Core_Supported_Product_Name__c,Core_Intel_Product__c,Core_IPS_Product_Status__c,Product_Application__c from IPS_Products__r) from Core_IPS_Project__c where id =: currentProjRecordId LIMIT 10];
        List<Core_IPS_Product__c> lstProducts = new List<Core_IPS_Product__c>();
        for(integer i=0; i<childIpsProducts[0].IPS_Products__r.size(); i++){
            lstProducts.add(childIpsProducts[0].IPS_Products__r[i]);
        }
        return lstProducts;
    }
    
    
    public List<Core_IPS_Project_Member__c> getExistingProjectMembers(){
        
        List<Core_IPS_Project_Member__c> sobjListPM;
        try {
            Core_IPS_Project__c  ipsProject = new Core_IPS_Project__c();
            User loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
            String loggedInUserAcctId = loggedInUser.Contact.AccountId;
            String loggedInUserContId = loggedInUser.ContactId ;
            
            String query = null;
            
           // SOQL Injection Fix - Start -  Shipra
           Map<String, Object> bindMap = new Map<String, Object>{ 'CurrentProjRecordId' => currentProjRecordId };

           query = 'Select Id,Name,Core_IPS_Contact__c,Add_as_Case_Interested_Party__c,Core_Status__c,Core_IPS_Contact__r.FirstName,Core_IPS_Contact_Account__c, Core_IPS_Contact__r.LastName,CreatedBy.Contact.Name,CreatedDate, Core_IPS_Contact__r.Email,Core_IPS_ContactName__c, Core_IPS_Contact__r.Account.Name ' + 
                   ' FROM Core_IPS_Project_Member__c WHERE  Core_IPS_Project__c = :CurrentProjRecordId';

           sobjListPM = Database.queryWithBinds(query, bindMap, AccessLevel.USER_MODE);
           // SOQL Injection Fix - End -  Shipra
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return sobjListPM;
    }
    
}