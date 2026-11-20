public without sharing class CRM_OpportunityHandler {
    public static Id recordtypeSolunGrpID, recordtypenewSolnGrpID, recordtypeNewOptyId, recordtypeOptyId;
    public static map <Id, list<OpportunityLineItem>> opplineItemmap = new map<Id, list<OpportunityLineItem>>(); 
    //public static PriceBook2 rectypestdpriceID = [select Id from PriceBook2 where IsStandard=True LIMIT 1];
    public static Set<String> prodStatusChk = new Set<String>{'Lost', 'Cancelled','Production Lost','Production Cancelled'};
    public static list<OpportunityLineItem> upopplineItem = new list<OpportunityLineItem>();
    public static set<OpportunityLineItem> upopplineItemset = new set<OpportunityLineItem>();
    public static Boolean afterInsert = false;
    public static Boolean afterUpdate = false;
    public static Boolean capPrioropty = false;
    public static Boolean beforeUpdate = false;
    public static Boolean beforeInsert = false;
    public static void BeforeOptyFieldUpdate(List<Opportunity> newList, Map<Id,Opportunity> newMap,
                                                       List<Opportunity> oldList, Map<Id,Opportunity> oldMap,
                                                       Boolean isInsert, Boolean isUpdate){
                                                           recordtypeSolunGrpID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Core_Solution_Group').getRecordTypeId();//012o0000000Gn19AAC
                                                           recordtypenewSolnGrpID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Core_New_Solution_Group').getRecordTypeId();//012o0000000Gn17AAC
                                                           recordtypeNewOptyId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Core_New_Opportunity').getRecordTypeId();//012o0000000Gn16AAC
                                                           recordtypeOptyId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Core_Opportunity').getRecordTypeId();//012o0000000Gn18AAC
                                                          if ((isInsert && !beforeInsert) || (isUpdate && !beforeUpdate)){
                                                              for(Opportunity opp: newList){
                                                                  if(isInsert){
                                                                      defaultStageValueUserCoverage(opp);
                                                                      recordTypeNewOppSolGroup(opp);
                                                                      clearAmount(opp);
                                                                      decisionDateonConversion(opp);
                                                                      beforeInsert = true;
                                                                       
                                                                  }
                                                                  bypassFieldValidationReset(opp);//commented for checking defect
                                                                  if(isUpdate  ){//Update
                                                                      pastDueUpdate(opp,oldMap.get(opp.id));
                                                                      clearLossCancelDetails(opp,oldMap.get(opp.id));
                                                                      updatePushCounterFlow(opp,oldMap.get(opp.id));
                                                                      //allProductsPending(opp,oldMap.get(opp.id));
                                                                      capturePriorOpportunityforLostOpptys(opp,oldMap.get(opp.id));
                                                                      //atRiskCreatedDate(opp,oldMap.get(opp.id));
                                                                     // activityDateUncvrAccNotifDecinDateLeadNotes(opp,oldMap.get(opp.id));
                                                                      beforeUpdate = true;
                                                                  }
                                                              }
                                                              
                                                              
                                                           }

                                                       }
    public static void AfterOptyFieldUpdate(List<Opportunity> newList, Map<Id,Opportunity> newMap,
                                                       List<Opportunity> oldList, Map<Id,Opportunity> oldMap,
                                            Boolean isInsert, Boolean isUpdate){
                                                set<Id> oppId = new set<Id>();
                                                opplineItemmap.clear();
                                                upopplineItem.clear();
                                                for(Opportunity opp: newList){
                                                    oppId.add(opp.Id);
                                                }
                                                if ((isInsert && !afterInsert) || (isUpdate && !afterUpdate)){
                                                    oppLineItemData(oppId);
                                                    for(Opportunity opp: newList){
                                                        if(isInsert){
                                                            //cloneUpdatesFlow(opp);
                                                            //EntryStageValue(opp);
                                                           afterInsert = true;
                                                        }
                                                        if(isUpdate){
                                                            clearPWApprovedFields(opp,oldMap.get(opp.id),opplineItemmap);
                                                            afterUpdate = true;
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                    if(upopplineItemset.size() > 0){upopplineItem.addAll(upopplineItemset);}
                                                    update upopplineItem;   
                                                }
                                            }
     @TestVisible
     private static void defaultStageValueUserCoverage(Opportunity opp){
            if(opp.RecordTypeId != null){//Core Opp Default Stage Value & User Coverage
                if((opp.CreatedDate != null ) &&  (opp.RecordTypeId == recordtypenewSolnGrpID || opp.RecordTypeId == recordtypeSolunGrpID )){//To Assign Opp Default Value
                    opp.StageName = 'Group Open';
                }
                if(opp.RecordTypeId == recordtypeNewOptyId || opp.RecordTypeId == recordtypeOptyId){//Stamp User Coverage
                    opp.Core_Opportunity_Created_Coverage_New__c =  opp.CreatedBy.Core_User_Coverage__c;
                }
            }
        
    }
    @TestVisible
    private static void recordTypeNewOppSolGroup(Opportunity opp){
            if(opp.RecordTypeId ==  recordtypenewSolnGrpID || opp.RecordTypeId == recordtypeNewOptyId){//Core Opp RecordType New Opp & Sol. Group
                if(opp.RecordTypeId == recordtypenewSolnGrpID ){//is New Solution Group?
                    opp.RecordTypeId = recordtypeSolunGrpID;
                }
                if(opp.RecordTypeId == recordtypeNewOptyId){//is New Opportunity?------ Not Required
                    opp.RecordTypeId = recordtypeOptyId;
                }
            }
        
    }
    @TestVisible
    private static void clearAmount(Opportunity opp){
        if(opp.Core_Product_Count__c == 0){//Core_Opp_Clear_Amount
            opp.Amount = null;
        }
    }
    @TestVisible
    private static void bypassFieldValidationReset(Opportunity opp){
        if(opp.Core_Bypass_Field_Validation__c == true){//Core_Opp_Bypass_Field_Validation_Reset-----/create/
            opp.Core_Bypass_Field_Validation__c = false ;
        }
    }
    @TestVisible
    private static void pastDueUpdate(Opportunity opp , Opportunity oldOpp){
        if(opp.Core_Approval_Status__c == 'Submitted' && (opp.Core_Approval_Status__c != oldOpp.Core_Approval_Status__c )){//Core_Opp_PastDueUpdate
            opp.Core_PastDue_FlowUpdate__c = oldOpp.Core_Past_Due__c;
        }
    }
    private static void clearLossCancelDetails(Opportunity opp , Opportunity oldOpp){
        if( prodStatusChk.contains(oldOpp.StageName)
           && !prodStatusChk.contains(opp.StageName)){//Core_Opp_Clear_Loss_Cancel_Details /*---checks if status is lost/cancelled/production lost/Production cancelled---*/
               opp.Core_Loss_Cancel_Reason__c = '';
               opp.Core_Loss_Cancel_Details__c = '';
           }
    }
    @TestVisible
    private static void updatePushCounterFlow(Opportunity opp , Opportunity oldOpp){
        if( !(opp.Core_Coverage_Type_Nm__c == 'Deal Registration' && opp.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity') 
           && (opp.StageName == 'Develop' || opp.StageName == 'Design') 
           && (opp.CloseDate > oldOpp.CloseDate)
           && (opp.CloseDate.month() != oldOpp.CloseDate.month() || opp.CloseDate.year() != oldOpp.CloseDate.year() )){//Core_Opp_UpdatePushCounterFlow
               if(opp.Core_Push_Counter__c == null){
                   opp.Core_Push_Counter__c = 0;
               }
               opp.Core_Push_Counter__c = opp.Core_Push_Counter__c == 0 ? 1:(opp.Core_Push_Counter__c + 1);
                   }
    }
    /*@TestVisible
    private static void allProductsPending(Opportunity opp , Opportunity oldOpp){
        if( !(opp.StageName == 'Design' || opp.StageName == 'Qualify') && oldOpp.Core_Won_Product_Count__c > 0  && opp.Core_Won_Product_Count__c == 0 ){//Core_Opp_All_Products_Pending
            opp.StageName = 'Design';
        }
    }*/
    @TestVisible
    private static void decisionDateonConversion(Opportunity opp){
        if(opp.Core_Lead_Conversion_Flag__c == true){//Core_Decision_Date_on_Conversion
            opp.CloseDate = System.today() + 120;
        }
    }
    @TestVisible
    private static void capturePriorOpportunityforLostOpptys(Opportunity opp,Opportunity oldOpp){
        if( prodStatusChk.contains(opp.StageName) && capPrioropty == false){//Core_Opp_Capture_Prior_Opportunity_for_Lost_Opptys  /*---checks if status is lost/cancelled/production lost/Production cancelled---*/
           opp.Core_Prior_Lost_Opportunity_Stage__c = oldOpp.StageName;
           capPrioropty = true;
        }
    }
   /* @TestVisible
    private static void atRiskCreatedDate(Opportunity opp,Opportunity oldOpp){//Core_Oppty_At_Risk_Created_Date
        if(opp.Core_Risk_Reason__c != oldOpp.Core_Risk_Reason__c){
            opp.Core_At_Risk_Created_Date__c = System.today();
        }
    }*/
    @TestVisible
    private static void clearPWApprovedFields(Opportunity opp,Opportunity oldOpp, map<Id,list<OpportunityLineItem>> opplineItemmap){
        list<OpportunityLineItem> oppli = new list<OpportunityLineItem>();
        
        
        if(opplineItemmap.containsKey(opp.id)){
            oppli = opplineItemmap.get(opp.id);
            for(OpportunityLineItem opplitem : oppli){
                if(opp.StageName == 'Design Win' && opp.StageName != oldOpp.StageName && opp.Core_PW_Approval_Status__c == 'Recalled' && 
                   (opplitem.Core_Status__c == 'Production Win Approved' ||opplitem.Core_Status__c == 'Production Lost' ||opplitem.Core_Status__c == 'Production Cancelled')){//Core_Clear_PW_Approved_Fields
                       opplitem.CRM_PW_App_UCD_Customer_Name__c = '';
                       opplitem.Core_PW_Approved_Prime_Account_Name__c = '';
                       opplitem.Core_PW_Approved_BU_Product_Segment__c = '';
                       opplitem.Core_PW_Approved_BU_Short_Name__c = '';
                       opplitem.Core_PW_Approved_By__c = '';
                       opplitem.Core_PW_Approved_Commissionable__c = '';
                       opplitem.Core_PW_Approved_KPI_Product_Group__c = '';
                       opplitem.Core_PW_Approved_Quantity__c = null;
                       opplitem.Core_PW_Approved_Sales_Group__c = '';
                       opplitem.Core_PW_Approved_Sales_Price__c = null;
                       opplitem.Core_PW_Approved_Total_Price__c = null;
                       opplitem.Core_PW_Manager_Approved_Date__c = null;
                       opplitem.Core_Production_Claim_Date__c = null ;
                       upopplineItemset.add(opplitem);
                }
              //upopplineItemset.add(opplitem);  
            }
        }
        
         
    }
    /*@TestVisible
    private static void cloneUpdatesFlow(Opportunity opp){
        if(opp.StageName == 'Design Win' || opp.StageName == 'Production Win' || opp.StageName == 'Production Lost' || opp.StageName == 'Production Cancelled'){//Core_Opp_Clone_Updates_Flow
            opp.Core_Approval_Status__c = 'Not Submitted';
            opp.StageName = 'Qualify';
        }
    }*/
    /*@TestVisible
    private static void EntryStageValue(Opportunity opp){
        if(opp.StageName != null){//Core_Opp_EntryStageValue_2
            opp.Core_Converted_Created_Date__c = opp.CreatedDate.date();
            opp.Core_Opportunity_Entry_Stage__c = opp.StageName;
        }
    }*/
   /* @TestVisible
    private static void activityDateUncvrAccNotifDecinDateLeadNotes(Opportunity opp, Opportunity oldOpp){//Core_Opp_ActivityDate_UncoveredAccountNotification_DecisionDate_LeadNotes
        closeDateDescription(opp);
        if(lastActivityDatevalue( opp, oldOpp) == true || lastActivityDatevaluepart( opp, oldOpp) == true || lastActivityDatevaluesubpart( opp, oldOpp) == true){
                 opp.Core_Last_Activity_Date__c = System.today();
             }
    }
    @TestVisible
    private static boolean lastActivityDatevalue(Opportunity opp, Opportunity oldOpp){
        if(opp.StageName != oldOpp.StageName || opp.CloseDate != oldOpp.CloseDate ||  opp.Core_Volume__c != oldOpp.Core_Volume__c 
             || opp.Description != oldOpp.Description || opp.Amount != oldOpp.Amount || opp.Core_Status_Update__c != oldOpp.Core_Status_Update__c 
           ||opp.Core_Product_Segment__c != oldOpp.Core_Product_Segment__c){
               return true;
           } 
        else{
            return false;
        }
        
    }
    @TestVisible
    private static boolean lastActivityDatevaluepart(Opportunity opp, Opportunity oldOpp){
        if(opp.Core_Product_Application__c != oldOpp.Core_Product_Application__c ||opp.Core_Consumption_Market__c != oldOpp.Core_Consumption_Market__c ||opp.Core_Solution_Area__c != oldOpp.Core_Solution_Area__c 
             ||opp.Core_Solution_Type__c != oldOpp.Core_Solution_Type__c ){
            return true;
        }
        else{
            return false;
        }
    }
    @TestVisible
    private static boolean lastActivityDatevaluesubpart(Opportunity opp, Opportunity oldOpp){
        if(opp.Core_Combined_Solution_Detail__c != oldOpp.Core_Combined_Solution_Detail__c ||opp.Core_First_Customer_Ship_Date__c != oldOpp.Core_First_Customer_Ship_Date__c ||opp.Core_Manufacturing_Geo__c != oldOpp.Core_Manufacturing_Geo__c){
            return true;
        }
        else{
            return false;
        }
    }
    
    @TestVisible
    private static void closeDateDescription(Opportunity opp){
        if(opp.StageName == 'Lost' || opp.StageName == 'Cancelled'){
            opp.CloseDate = System.today();
        }
        if(opp.Core_Lead_Notes__c != null){
            opp.Description = opp.Core_Lead_Notes__c;
        }
    }*/
    @TestVisible
    private static void oppLineItemData(set<Id> oppId){
        for(OpportunityLineItem opplineItem : [select id,OpportunityId,Core_Status__c,CRM_PW_App_UCD_Customer_Name__c,Core_PW_Approved_BU_Product_Segment__c,Core_PW_Approved_BU_Short_Name__c,Core_PW_Approved_By__c,Core_PW_Approved_Commissionable__c,Core_PW_Approved_KPI_Product_Group__c,Core_PW_Approved_Quantity__c,Core_PW_Approved_Sales_Group__c,Core_PW_Approved_Sales_Price__c,Core_PW_Approved_Total_Price__c,Core_PW_Manager_Approved_Date__c,Core_Production_Claim_Date__c
                                                                                       ,Core_Loss_Cancel_Details__c,Core_Loss_Cancel_Reason__c,Core_PW_Approved_Prime_Account_Name__c
                                                                                       from OpportunityLineItem
                                                                                       where OpportunityId IN: oppId ]){
                                                                                           list<OpportunityLineItem> oppli = new list<OpportunityLineItem>();
                                                                                           if(opplineItemmap.containsKey(opplineItem.OpportunityId)){
                                                                                               oppli = opplineItemmap.get(opplineItem.OpportunityId);
                                                                                           }
                                                                                           oppli.add(opplineItem);
                                                                                           opplineItemmap.put(opplineItem.OpportunityId,oppli);
                                                                                       }
    }
}