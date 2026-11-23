/******************************************************************************************************************************************
Class Name:  Core_InactiveAccountonOpp
Version     : 1.0 
Created Date: 20 APR 2022
Function    : Controller class Core_InactiveAccount Lightning Component
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             20/04/2022              Original Version
* Jerin Thomas S             23/08/2022              when vendors accounts are inactive display toast message only for "Pending","Win Submitted" and "On Hold"- Product Status
* Jerin Thomas S             30/08/2022              when vendors accounts are inactive display toast message only for "Pending" and "On Hold"- Product Status
*****************************************************************************************************************************************/
public without sharing class Core_InactiveAccountonOpp {//TWC3123-5299 added without sharing keyword
    /*************************************************************************************************************
    * Method name  : getData
    * Description  : Query to get the opportunity details
    * Return Type  : InactiveWrapper
    * Parameter    : String oppId 
    **************************************************************************************************************/

    @auraEnabled
    public static InactiveWrapper getData(Id oppId) {
        InactiveWrapper wrp = new InactiveWrapper();
        //Opportunity oppObj = new Opportunity();
        //oppObj.id = oppId;
        wrp.isOppInactive = false;
        wrp.isVendorInactive = false;
        wrp.isOppPartnerInactive = false;
        List<Opportunity> opplist = [select id, Account.RecordType.name from Opportunity where id =:oppId WITH SECURITY_ENFORCED];//TWC3123-5299 added WITH SECURITY_ENFORCED
        //system.debug('opplist-'+opplist);
        if(opplist[0].Account.RecordType.name =='Inactive Account') {
            wrp.isOppInactive = true;
            //oppObj.Core_Is_Opportunity_Account_Inactive__c = true;
        }
        List<OpportunityLineItem> opptyLineItemsList= [SELECT id, Name, Core_Vendor__r.RecordType.name FROM OpportunityLineItem WHERE OpportunityId = :oppId AND Core_Status__c IN ('Pending','On Hold') WITH SECURITY_ENFORCED];//TWC3123-5299 added WITH SECURITY_ENFORCED
        if(opptyLineItemsList.size()>0) {
            for(OpportunityLineItem oli : opptyLineItemsList) {
                if(oli.Core_Vendor__r.RecordType.name =='Inactive Account') {
                    wrp.isVendorInactive = true; 
                    //oppObj.Core_Is_Product_Vendor_Inactive__c = true;
                    break;
                }
                else {
                    //oppObj.Core_Is_Product_Vendor_Inactive__c = false;
                }
            }
        }
        
        
        return wrp;
    }
    
     /*Added By Hira as part of TWC3123-5561
* Method name  : get6QPSData
* Description  : It checks whether the 6QPS's First Quarter is aligned with First Customer Ship Date
* Return Type  : Boolean
* Parameter    : Id
*/
    @AuraEnabled
    public static Boolean get6QPSData(Id oppId) {
        Boolean errorflag=false;
        Boolean ApprOrSubmittedQtr=false;
        Set<String> OppStages = new Set<String> {'Design','Design Win','Production Win','Production Lost','Production Cancelled'};   
        Set<String> QtrStatus = new Set<String> {'Approved','Submitted'};   
                
        Opportunity opp=[select Id,StageName,Core_First_Customer_Ship_Date__c,RecordTypeId from Opportunity where Id =:oppId];
        Id designRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Design Opportunity').getRecordTypeId();
        Boolean StageRecTypeCheck=OppStages.contains(opp.StageName) && opp.RecordTypeId==designRecordTypeId;
        Date FirstQtrDate;
        if(StageRecTypeCheck) {
            //Getting Forecast Record
            List<Core_Opp_FC_Prod_Schedule__c> fc = [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c,
                                                     Core_Opp_FC_Quarter__c,Core_Opp_FC_Approval_Status__c 
                                                     FROM Core_Opp_FC_Prod_Schedule__c 
                                                     WHERE Core_Opp_FC_Opportunity__c = :oppId 
                                                     AND Core_Opp_FC_isdeleted__c = false 
                                                     ORDER BY Core_Opp_FC_Product__r.Name,Core_Opp_FC_Quarter_Date__c];
            
            if(!fc.isEmpty()){
                for(Core_Opp_FC_Prod_Schedule__c f:fc){
                    System.debug('*FC'+f);
                    if(QtrStatus.contains(f.Core_Opp_FC_Approval_Status__c)){
                        ApprOrSubmittedQtr=true;
                        break;
                    }
                }
            }
            
            if(!ApprOrSubmittedQtr && !fc.isEmpty()){
                FirstQtrDate=fc[0].Core_Opp_FC_Quarter_Date__c;
            }
            
            Decimal qtr = 0.00;
            Date FirstCustShipDate=opp.Core_First_Customer_Ship_Date__c;
            
            if(FirstQtrDate != null) {
                //Getting Quarter of Forecast Record
                qtr = (Decimal)(FirstQtrDate.month())/3;
                
                //Getting Quarter of First Customer Ship Date
                Decimal FCSDqtr = (Decimal)(FirstCustShipDate.month())/3;
                
                //Checking if the Quarters comes in same year
                if(FirstCustShipDate.year() == FirstQtrDate.year()) {
                    if(!(Math.ceil(FCSDqtr)-Math.ceil(qtr)==1)) {
                        errorflag=true;
                    }
                }//Checking if the Quarters has 1 year difference
                else if(FirstCustShipDate.year() - FirstQtrDate.year()==1) {
                    Boolean flag=Math.ceil(FCSDqtr) == 1 && Math.ceil(qtr)==4;
                    if(!flag) {
                        errorflag=true;
                    }
                }//If Quarters have more than 1 year difference
                else {
                    errorflag=true;
                }
            }
        }
        return errorflag;
    }
    
    public class InactiveWrapper {
        @auraEnabled
        public boolean isOppInactive {get;set;}
        @auraEnabled
        public boolean isVendorInactive {get;set;}
        @auraEnabled
        public boolean isOppPartnerInactive {get;set;}
        
    }
}