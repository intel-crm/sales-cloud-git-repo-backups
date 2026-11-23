/***************************************************************************************************
* Apex Class Name : Core_IPS_CreateOpportunityPAR_Controller
* Test Class Name : Core_IPS_OpportunityPAR_Controller_Test
* Description : Creates Opportunity PAR Record and adds supported productsand supported Org Admins to related list of opportunity PAR 
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Tejaswi                  04/09/2020                                                          
****************************************************************************************************/
public without sharing class Core_IPS_CreateOpportunityPAR_Controller { 
     
    @AuraEnabled  
    public Static Id submitRecord(String oppParJsonRecord){
        Boolean result=false;
        List<Core_IPS_Product_Organization_Admin__c> orgAdmins = new List<Core_IPS_Product_Organization_Admin__c>();
        List<Core_IPS_Product_Organization_Admin__c> orgAdminsList = new List<Core_IPS_Product_Organization_Admin__c>();
        List<Core_IPS_Opppar_SuppOrgAdmin__c> oppOrgAdminsList = new List<Core_IPS_Opppar_SuppOrgAdmin__c>();
        List<String> oppTeamMem = new List<String>();
        List<OpportunityTeamMember> oppTeamMemList = new List<OpportunityTeamMember>();
        
        List<String> selectedProd = new List<String>();
        List<Core_IPS_Supported_Product__c> selectedProdList = new List<Core_IPS_Supported_Product__c>();
        List<Core_IPS_Supported_Product__c> supProducts = new List<Core_IPS_Supported_Product__c>();
        List<Core_IPS_Opppar_Supported_Product__c> oppProdList = new List<Core_IPS_Opppar_Supported_Product__c>();
        List<Core_IPS_Product__c> prmrProjProdList = new List<Core_IPS_Product__c>();
        List<String> supProductsName = new List<String>();
        List<Core_IPS_Supported_Product__c> prodIdList = new List<Core_IPS_Supported_Product__c>();
        String commaSepratedProdNameList='';
        
        Core_IPS_Opportunity_PAR__c oppParRecord = new Core_IPS_Opportunity_PAR__c();
       // try{
            WrapOpportunityPAR wrpOppRecord = (WrapOpportunityPAR)JSON.deserialize(oppParJsonRecord, wrapOpportunityPAR.class);
            prodIdList = wrpOppRecord.productList;
            orgAdmins = wrpOppRecord.orgAdminList;
            // adding supported products name for email template
            for(Core_IPS_Supported_Product__c prodNames: prodIdList){
                supProductsName.add(prodNames.Name);
            }
            
            commaSepratedProdNameList= String.join(supProductsName, ', ');
            
            // inserting Opportunity PAR Record
            /*US1038991 - 07/08/2021 - Vishal - FLS Check for security vulnerability --*/
            if (Schema.sObjectType.Core_IPS_Opportunity_PAR__c.fields.Core_IPS_Request_Justification__c.isCreateable()) {
                oppParRecord.Core_IPS_Request_Justification__c = wrpOppRecord.requestJust;
            }
            if (Schema.sObjectType.Core_IPS_Opportunity_PAR__c.fields.Core_IPS_Premier_Support_Project__c.isCreateable()) {
                oppParRecord.Core_IPS_Premier_Support_Project__c = wrpOppRecord.ipsPrjct; 
            }
            if (Schema.sObjectType.Core_IPS_Opportunity_PAR__c.fields.Opportunity__c.isCreateable()) {
                oppParRecord.Opportunity__c = wrpOppRecord.oppId;
            }
            if (Schema.sObjectType.Core_IPS_Opportunity_PAR__c.fields.Core_IPS_AddNewProject__c.isCreateable()) {
                oppParRecord.Core_IPS_AddNewProject__c = wrpOppRecord.createProjCheckbox;
            }
            if (Schema.sObjectType.Core_IPS_Opportunity_PAR__c.fields.Core_IPS_Approval_Status__c.isCreateable()) {
                oppParRecord.Core_IPS_Approval_Status__c=System.Label.Opportunity_PAR_Approval_Status;
            }
            if (Schema.sObjectType.Core_IPS_Opportunity_PAR__c.fields.Core_IPS_Supported_ProductsName__c.isCreateable()) {
                oppParRecord.Core_IPS_Supported_ProductsName__c = commaSepratedProdNameList;
            }
            if (Schema.sObjectType.Core_IPS_Opportunity_PAR__c.fields.Core_IPS_Support_Org__c.isCreateable()) {
                oppParRecord.Core_IPS_Support_Org__c = wrpOppRecord.supportOrgName;
            }            
            insert oppParRecord; 
            
            // Updating Opp Par Supported Products
            for(Core_IPS_Supported_Product__c prodId: prodIdList){
                Core_IPS_Opppar_Supported_Product__c selectedProds = new Core_IPS_Opppar_Supported_Product__c();
                /*US1038991 - 07/08/2021 - Vishal - FLS Check for security vulnerability --*/
                if (Schema.sObjectType.Core_IPS_Opppar_Supported_Product__c.fields.Core_IPS_Opportunity_PAR__c.isCreateable()) {
                    selectedProds.Core_IPS_Opportunity_PAR__c = oppParRecord.Id;
                }
                if (Schema.sObjectType.Core_IPS_Opppar_Supported_Product__c.fields.Core_IPS_Supported_Product__c.isCreateable()) {
                    selectedProds.Core_IPS_Supported_Product__c = prodId.Id;
                }
                oppProdList.add(selectedProds); 
            } 
                        
            // Updating Opp Par Support Org Admins
            for(Core_IPS_Product_Organization_Admin__c orgAdminToUpdate: orgAdmins){
                Core_IPS_Opppar_SuppOrgAdmin__c orgAdmin = new Core_IPS_Opppar_SuppOrgAdmin__c();
                /*US1038991 - 07/08/2021 - Vishal - FLS Check for security vulnerability --*/
                if (Schema.sObjectType.Core_IPS_Opppar_SuppOrgAdmin__c.fields.Core_IPS_Opportunity_Par__c.isCreateable()) {
                    orgAdmin.Core_IPS_Opportunity_Par__c = oppParRecord.Id;
                }
                if (Schema.sObjectType.Core_IPS_Opppar_SuppOrgAdmin__c.fields.Core_IPS_Support_Org_Admin__c.isCreateable()) {
                    orgAdmin.Core_IPS_Support_Org_Admin__c = orgAdminToUpdate.Id;
                }
                oppOrgAdminsList.add(orgAdmin);
            } 
            
            if(oppOrgAdminsList.size()>0){
                insert oppOrgAdminsList; 
            }
            
            if(oppProdList.size()>0){
                insert oppProdList;
            } 
            //added by ranjini
            if(orgAdmins.size()>0){
                for(Core_IPS_Product_Organization_Admin__c oppVar: orgAdmins){                                        
                    OpportunityTeamMember OppTeamMember = new OpportunityTeamMember();
                    /*US1038991 - 07/08/2021 - Vishal - FLS Check for security vulnerability --*/
                    if (Schema.sObjectType.OpportunityTeamMember.fields.UserId.isCreateable()) {
                        OppTeamMember.UserId = oppVar.Core_Admin__c;
                    }
                    if (Schema.sObjectType.OpportunityTeamMember.fields.TeamMemberRole.isCreateable()) {
                        OppTeamMember.TeamMemberRole = System.Label.Core_IPS_OpportunityTeamMemberRole;
                    }
                    if (Schema.sObjectType.OpportunityTeamMember.fields.OpportunityId.isCreateable()) {
                        OppTeamMember.OpportunityId = oppParRecord.Opportunity__c;
                    }
                    if (Schema.sObjectType.OpportunityTeamMember.fields.OpportunityAccessLevel.isCreateable()) {
                        OppTeamMember.OpportunityAccessLevel='Read';
                    }
                    oppTeamMemList.add(OppTeamMember);
                }
                try{
                    if(oppTeamMemList.size()>0){
                        insert oppTeamMemList;  
                    }
                 //modified as a part of TWC3123-5372
                 //start   
                }catch(exception ex){
                    String errorMessage ;
                    if(ex.getMessage() != NULL)
                    {
                        
                       if(ex.getMessage().contains(System.Label.Core_OppoAccessError))
                       {
                           errorMessage= 'One or more users from the Opportunity Team Additions section below is not having access to Opportunity . You cannot create this request at the moment ';
                       }
                        
                        else if(ex.getMessage(). contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
                        {
                            errorMessage= ex.getDmlMessage(0);
                        }
                    }
                    
                    throw new AuraHandledException(errorMessage);
                }
                
            }
            // end  
        return oppParRecord.Id;
    }
    public class WrapOpportunityPAR {
        @AuraEnabled public String supportOrgName{get; set;}
        @AuraEnabled public String requestJust {get; set;}
        @AuraEnabled public Id ipsPrjct {get; set;}
        @AuraEnabled public Id oppId {get; set;}
        @AuraEnabled public List<Core_IPS_Supported_Product__c> productList {get; set;}
        @AuraEnabled public List<Core_IPS_Product_Organization_Admin__c> orgAdminList {get; set;}
        @AuraEnabled public Boolean createProjCheckbox {get; set;}
    }
}