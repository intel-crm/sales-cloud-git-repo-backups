/******************************************************************************************************************************************
Class Name  : Core_AddSolutionArea
Version     : 1.0 
Function    : Addition of solution area to record
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade        07/07/2022   Original version
*****************************************************************************************************************************************/

public with sharing class Core_AddSolutionArea {
    Public Static List<Core_Solution_Areas__c> solListSP {get;set;}
    Public Static List<Core_Solution_Areas__c> solList {get;set;}
    @AuraEnabled(cacheable=true)  
   public static List<Core_Solution_Areas__c> searchSolutionStorage (String SaStrTE, String SaStrIUC, String SaStrAWL, String SaStrDescp, String SaStrType, String SaStrTitle, String SaStrSP, String oppoIds){
    List<Core_Solution_Areas__c> sol_final = new List<Core_Solution_Areas__c>();
        String keyNameString = SaStrType + '*';
        String keySPString = SaStrSP + '*';
        String keySPTextString;
        if(!String.isBlank(SaStrType) && !String.isBlank(SaStrSP)){
            keySPTextString = keyNameString + ' OR ' + keySPString;
        }


        List<String> strList = SaStrType.split(';');
        List<Opportunity> oppo = new List<Opportunity>();
        List<Core_Solution_Areas__c> sol = new List<Core_Solution_Areas__c>();
        List<Core_Solution_Areas__c> sol_Null = new List<Core_Solution_Areas__c>();
        List<List<Core_Solution_Areas__c>> searchList = new List<List<Core_Solution_Areas__c>>();
        String recType;
        String program_Nm;
                
        String recEOL = 'EOL';
        String query = 'Select Id,Name,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Solution_Type__c,Core_Version__c,Core_Solution_owner_email__c,Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c,tolabel(Core_Application_Workload__c),Core_Content_Link__c,Core_Region_of_availability__c,tolabel(Core_Technology_Enabled__c),tolabel(Core_Industry_Use_Case__c), Core_Solution_Description__c, Core_Solution_Long__c, Core_Concatenated_Solution_Partners__c From Core_Solution_Areas__c where ';
                
                If(!String.isBlank(SaStrAWL))
                { 
                    query = query + ' tolabel(Core_Application_Workload__c) includes (: SaStrAWL ) ';
                }
                If(!String.isBlank(SaStrIUC) && !String.isBlank(SaStrAWL))
                {
                    query = query + ' AND tolabel(Core_Industry_Use_Case__c) includes (: SaStrIUC ) ';
                }
                else  If(!String.isBlank(SaStrIUC) && String.isBlank(SaStrAWL))
                {
                    query = query + ' tolabel(Core_Industry_Use_Case__c) includes (: SaStrIUC ) ';
                }
               If(!String.isBlank(SaStrTE) && (!String.isBlank(SaStrIUC) || !String.isBlank(SaStrAWL)))
                {
                    query = query + ' AND tolabel(Core_Technology_Enabled__c) includes (:  SaStrTE ) ';
                }
                else If(!String.isBlank(SaStrTE) && String.isBlank(SaStrIUC) && String.isBlank(SaStrAWL))
                {
                    query = query + ' tolabel(Core_Technology_Enabled__c) includes (:SaStrTE) ';
                }
                If(!String.isBlank(SaStrTE) || !String.isBlank(SaStrIUC) || !String.isBlank(SaStrAWL))
                {
                    query = query + ' and ';
                }
       
        
        if(oppoIds!= null){
            oppo = [Select Id, Name, Core_Opportunity_Type__c from Opportunity where Id=:oppoIds];
            if(oppo.size()>0){
                for(Opportunity Opp:oppo){
                    recType =  Opp.Core_Opportunity_Type__c;
                }
            }
        }
       if(recType != null && recType.contains(Label.Core_Design_Visible)){
                query = query + ' Core_Status__c!= :recEOL and Core_Design_Visible__c = true ';
                
            }else if(recType != null && recType.contains(Label.Core_Deal_Visible)){
                 query = query + ' Core_Status__c!= :recEOL ';
                 query = query + 'and Core_Deal_Visible__c = true ';
            }
       
       // Initial page load with 100 records without any condition
       if (String.isBlank(SaStrIUC) && String.isBlank(SaStrAWL) && String.isBlank(SaStrTE) && String.isBlank(SaStrType) && String.isBlank(SaStrSP))
             { // default 100 records 
                 if(Test.isRunningTest()){
                  sol = Database.query('Select Id,Name,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Solution_Type__c,Core_Version__c,Core_Solution_owner_email__c,Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c,tolabel(Core_Application_Workload__c),Core_Content_Link__c,Core_Region_of_availability__c,tolabel(Core_Technology_Enabled__c),tolabel(Core_Industry_Use_Case__c), Core_Solution_Description__c, Core_Solution_Long__c, Core_Concatenated_Solution_Partners__c From Core_Solution_Areas__c where   Core_Status__c!= :recEOL  limit 100 ');
                 }
                 else
                 {              
                  query = query + ' limit 100 ';
                 sol = Database.query(query);
                 
                 }
                 
             }
             //any of the picklist is not blank
            else if ((!String.isBlank(SaStrIUC) || !String.isBlank(SaStrAWL) || !String.isBlank(SaStrTE)) && ((String.isBlank(SaStrType)) && String.isBlank(SaStrSP)))
             { 
                 sol = Database.query(query);
            }
             
             //search based only on SP search
           else  if (String.isBlank(SaStrIUC) && String.isBlank(SaStrAWL) && String.isBlank(SaStrTE) && !String.isBlank(SaStrSP) && String.isBlank(SaStrType))
           { 
                     solList = new List<Core_Solution_Areas__c>();
                          if(recType != null && recType.contains(Label.Core_Design_Visible)){ 
                              searchList   =  [FIND :keySPString IN ALL FIELDS Returning Core_Solution_Areas__c(Id,Name,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Solution_Type__c,Core_Version__c,Core_Solution_owner_email__c,Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c,tolabel(Core_Application_Workload__c),Core_Content_Link__c,Core_Region_of_availability__c,tolabel(Core_Technology_Enabled__c),tolabel(Core_Industry_Use_Case__c), Core_Solution_Long__c, Core_Solution_Description__c, Core_Concatenated_Solution_Partners__c where Core_Design_Visible__c = true and Core_Status__c!= 'EOL')];                               
                              solListSP = ((List<Core_Solution_Areas__c>)searchList[0]);
                              for(Core_Solution_Areas__c sa:solListSP){
                                if(sa.Core_Concatenated_Solution_Partners__c != null && !String.isBlank(sa.Core_Concatenated_Solution_Partners__c) && sa.Core_Concatenated_Solution_Partners__c.containsIgnoreCase(SaStrSP)){
                                    solList.add(sa);
                                }
                              }
                              Return solList;
                          }else if((recType != null && recType.contains(Label.Core_Deal_Visible))){
                              solList = new List<Core_Solution_Areas__c>();
                              searchList   =  [FIND :keySPString IN ALL FIELDS Returning Core_Solution_Areas__c(Id,Name,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Solution_Type__c,Core_Version__c,Core_Solution_owner_email__c,Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c,tolabel(Core_Application_Workload__c),Core_Content_Link__c,Core_Region_of_availability__c,tolabel(Core_Technology_Enabled__c),tolabel(Core_Industry_Use_Case__c),Core_Solution_Long__c, Core_Solution_Description__c, Core_Concatenated_Solution_Partners__c Where Core_Deal_Visible__c = true  and Core_Status__c!= 'EOL')];
                              solListSP = ((List<Core_Solution_Areas__c>)searchList[0]);
                              for(Core_Solution_Areas__c sa:solListSP){
                                if(sa.Core_Concatenated_Solution_Partners__c != null && !String.isBlank(sa.Core_Concatenated_Solution_Partners__c) && sa.Core_Concatenated_Solution_Partners__c.containsIgnoreCase(SaStrSP)){
                                    solList.add(sa);
                                }
                              }
                              Return solList;
                          }else
                          solList = new List<Core_Solution_Areas__c>();
                              searchList = [FIND :keySPString IN ALL FIELDS Returning Core_Solution_Areas__c(Id,Name,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Solution_Type__c,Core_Version__c,Core_Solution_owner_email__c,Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c,tolabel(Core_Application_Workload__c),Core_Content_Link__c,Core_Region_of_availability__c,tolabel(Core_Technology_Enabled__c),tolabel(Core_Industry_Use_Case__c), Core_Solution_Description__c, Core_Concatenated_Solution_Partners__c where  Core_Status__c!= 'EOL')];
                          solListSP = ((List<Core_Solution_Areas__c>)searchList[0]);
                          for(Core_Solution_Areas__c sa:solListSP){
                            if(sa.Core_Concatenated_Solution_Partners__c != null && !String.isBlank(sa.Core_Concatenated_Solution_Partners__c) && sa.Core_Concatenated_Solution_Partners__c.containsIgnoreCase(SaStrSP)){
                                solList.add(sa);
                            }
                          }
                          Return solList;
            }
     // search based on SP search and drop down values
      else  if ((!String.isBlank(SaStrIUC) || !String.isBlank(SaStrAWL) || !String.isBlank(SaStrTE)) && (!String.isBlank(SaStrSP)) && (String.isBlank(SaStrType)))
           {
            solList = new List<Core_Solution_Areas__c>();
                      String search_query = 'FIND :keySPString IN ALL FIELDS Returning Core_Solution_Areas__c( ' + query.toUpperCase().substringBefore('FROM') ;
                      search_query = search_query.toUpperCase().replace('SELECT', '');
                      search_query =  search_query + query.toUpperCase().substringAfter('CORE_SOLUTION_AREAS__C') + ')';
                      
                      List<List<sObject>> searchSolns = search.query(search_query);
                      solListSP = ((List<Core_Solution_Areas__c>)searchSolns[0]);
                      for(Core_Solution_Areas__c sa:solListSP){
                      
                        if(sa.Core_Concatenated_Solution_Partners__c != null && !String.isBlank(sa.Core_Concatenated_Solution_Partners__c) && sa.Core_Concatenated_Solution_Partners__c.containsIgnoreCase(SaStrSP)){
                            solList.add(sa);
                        }
                      }
                      Return solList;
            }
            //search based only on text search
           else  if (String.isBlank(SaStrIUC) && String.isBlank(SaStrAWL) && String.isBlank(SaStrTE) && String.isBlank(SaStrSP) && !String.isBlank(SaStrType))
             { 
                       if(recType != null && recType.contains(Label.Core_Design_Visible)){ 
                                searchList   =  [FIND :keyNameString IN ALL FIELDS Returning Core_Solution_Areas__c(Id,Name,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Solution_Type__c,Core_Version__c,Core_Solution_owner_email__c,Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c,tolabel(Core_Application_Workload__c),Core_Content_Link__c,Core_Region_of_availability__c,tolabel(Core_Technology_Enabled__c),tolabel(Core_Industry_Use_Case__c), Core_Solution_Long__c, Core_Solution_Description__c, Core_Concatenated_Solution_Partners__c where Core_Design_Visible__c = true and Core_Status__c!= 'EOL')];                               
                                solList = ((List<Core_Solution_Areas__c>)searchList[0]);
                                Return ((List<Core_Solution_Areas__c>)searchList[0]);
                            }else if((recType != null && recType.contains(Label.Core_Deal_Visible))){
                                searchList   =  [FIND :keyNameString IN ALL FIELDS Returning Core_Solution_Areas__c(Id,Name,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Solution_Type__c,Core_Version__c,Core_Solution_owner_email__c,Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c,tolabel(Core_Application_Workload__c),Core_Content_Link__c,Core_Region_of_availability__c,tolabel(Core_Technology_Enabled__c),tolabel(Core_Industry_Use_Case__c),Core_Solution_Long__c, Core_Solution_Description__c, Core_Concatenated_Solution_Partners__c Where Core_Deal_Visible__c = true  and Core_Status__c!= 'EOL')];
                                solList = ((List<Core_Solution_Areas__c>)searchList[0]);
                                Return ((List<Core_Solution_Areas__c>)searchList[0]);
                            }else
                                searchList = [FIND :keyNameString IN ALL FIELDS Returning Core_Solution_Areas__c(Id,Name,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Solution_Type__c,Core_Version__c,Core_Solution_owner_email__c,Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c,tolabel(Core_Application_Workload__c),Core_Content_Link__c,Core_Region_of_availability__c,tolabel(Core_Technology_Enabled__c),tolabel(Core_Industry_Use_Case__c), Core_Solution_Description__c, Core_Concatenated_Solution_Partners__c where  Core_Status__c!= 'EOL')];
                            solList = ((List<Core_Solution_Areas__c>)searchList[0]);
                            Return ((List<Core_Solution_Areas__c>)searchList[0]);
              }

              //search based on dropdown and text 
              else  if ((!String.isBlank(SaStrIUC) || !String.isBlank(SaStrAWL) || !String.isBlank(SaStrTE)) && String.isBlank(SaStrSP) && !String.isBlank(SaStrType)){
                String search_query = 'FIND :keyNameString IN ALL FIELDS Returning Core_Solution_Areas__c( ' + query.toUpperCase().substringBefore('FROM') ;
                search_query = search_query.toUpperCase().replace('SELECT', '');
                search_query =  search_query + query.toUpperCase().substringAfter('CORE_SOLUTION_AREAS__C') + ')';
                List<List<sObject>> searchSolns = search.query(search_query);
                solList = ((List<Core_Solution_Areas__c>)searchSolns[0]);
                Return ((List<Core_Solution_Areas__c>)searchSolns[0]);
              }

              //search based on sp and text
              else  if (String.isBlank(SaStrIUC) && String.isBlank(SaStrAWL) && String.isBlank(SaStrTE) && !String.isBlank(SaStrSP) && !String.isBlank(SaStrType)){
                solList = new List<Core_Solution_Areas__c>();
                          if(recType != null && recType.contains(Label.Core_Design_Visible)){ 
                              searchList   =  [FIND :keySPTextString IN ALL FIELDS Returning Core_Solution_Areas__c(Id,Name,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Solution_Type__c,Core_Version__c,Core_Solution_owner_email__c,Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c,tolabel(Core_Application_Workload__c),Core_Content_Link__c,Core_Region_of_availability__c,tolabel(Core_Technology_Enabled__c),tolabel(Core_Industry_Use_Case__c), Core_Solution_Long__c, Core_Solution_Description__c, Core_Concatenated_Solution_Partners__c where Core_Design_Visible__c = true and Core_Status__c!= 'EOL')];                               
                              solListSP = ((List<Core_Solution_Areas__c>)searchList[0]);
                              for(Core_Solution_Areas__c sa:solListSP){
                                if(sa.Core_Concatenated_Solution_Partners__c != null && !String.isBlank(sa.Core_Concatenated_Solution_Partners__c) && sa.Core_Concatenated_Solution_Partners__c.containsIgnoreCase(SaStrSP)){
                                    solList.add(sa);
                                }
                              }
                              Return solList;
                          }else if((recType != null && recType.contains(Label.Core_Deal_Visible))){
                              solList = new List<Core_Solution_Areas__c>();
                              searchList   =  [FIND :keySPTextString IN ALL FIELDS Returning Core_Solution_Areas__c(Id,Name,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Solution_Type__c,Core_Version__c,Core_Solution_owner_email__c,Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c,tolabel(Core_Application_Workload__c),Core_Content_Link__c,Core_Region_of_availability__c,tolabel(Core_Technology_Enabled__c),tolabel(Core_Industry_Use_Case__c),Core_Solution_Long__c, Core_Solution_Description__c, Core_Concatenated_Solution_Partners__c Where Core_Deal_Visible__c = true  and Core_Status__c!= 'EOL')];
                              solListSP = ((List<Core_Solution_Areas__c>)searchList[0]);
                              for(Core_Solution_Areas__c sa:solListSP){
                                if(sa.Core_Concatenated_Solution_Partners__c != null && !String.isBlank(sa.Core_Concatenated_Solution_Partners__c) && sa.Core_Concatenated_Solution_Partners__c.containsIgnoreCase(SaStrSP)){
                                    solList.add(sa);
                                }
                              }
                              Return solList;
                          }else
                          solList = new List<Core_Solution_Areas__c>();
                              searchList = [FIND :keySPTextString IN ALL FIELDS Returning Core_Solution_Areas__c(Id,Name,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Solution_Type__c,Core_Version__c,Core_Solution_owner_email__c,Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c,tolabel(Core_Application_Workload__c),Core_Content_Link__c,Core_Region_of_availability__c,tolabel(Core_Technology_Enabled__c),tolabel(Core_Industry_Use_Case__c), Core_Solution_Description__c, Core_Concatenated_Solution_Partners__c where  Core_Status__c!= 'EOL')];
                          solListSP = ((List<Core_Solution_Areas__c>)searchList[0]);
                          for(Core_Solution_Areas__c sa:solListSP){
                            if(sa.Core_Concatenated_Solution_Partners__c != null && !String.isBlank(sa.Core_Concatenated_Solution_Partners__c) && sa.Core_Concatenated_Solution_Partners__c.containsIgnoreCase(SaStrSP)){
                                solList.add(sa);
                            }
                          }
                          Return solList;
              }
       // search based on text search, sp seach and drop down values
        else  if ((!String.isBlank(SaStrIUC) || !String.isBlank(SaStrAWL) || !String.isBlank(SaStrTE) || !String.isBlank(SaStrSP)) && !String.isBlank(SaStrType))
             {
                solList = new List<Core_Solution_Areas__c>();
                        String search_query = 'FIND :keySPTextString IN ALL FIELDS Returning Core_Solution_Areas__c( ' + query.toUpperCase().substringBefore('FROM') ;
                        search_query = search_query.toUpperCase().replace('SELECT', '');
                        search_query =  search_query + query.toUpperCase().substringAfter('CORE_SOLUTION_AREAS__C') + ')';
                        List<List<sObject>> searchSolns = search.query(search_query);
                        solListSP = ((List<Core_Solution_Areas__c>)searchSolns[0]);
                        for(Core_Solution_Areas__c sa:solListSP){
                            if(sa.Core_Concatenated_Solution_Partners__c != null && !String.isBlank(sa.Core_Concatenated_Solution_Partners__c) && sa.Core_Concatenated_Solution_Partners__c.containsIgnoreCase(SaStrSP)){
                                solList.add(sa);
                            }
                          }
                        
                        Return solList;
              }
           else{sol =  [Select Id,Name,Core_Deal_Visible__c,Core_Design_Visible__c,Core_Solution_Type__c,Core_Version__c,Core_Solution_owner_email__c,Core_End_Customer_Solution__c, isDeleted__c, Core_Industry__c,tolabel(Core_Application_Workload__c),Core_Content_Link__c,Core_Region_of_availability__c,tolabel(Core_Technology_Enabled__c),tolabel(Core_Industry_Use_Case__c), Core_Solution_Description__c, Core_Solution_Long__c, Core_Concatenated_Solution_Partners__c From Core_Solution_Areas__c where Core_Status__c!= 'EOL' limit 100 ];   }
           return sol;
    }
    
    @AuraEnabled
    public static String createOppSolution(String OppId, List<String> solAreaIds){
        set< String> setSolSelector = new set<String>();
        List<Opportunity_Solution_Area__c> solList = new List<Opportunity_Solution_Area__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        
        try{
            
            List<Opportunity_Solution_Area__c> csList = [Select Id, Core_Solution_Areas__c,Core_Opportunity__c from Opportunity_Solution_Area__c where Core_Solution_Areas__c IN : solAreaIds AND Core_Opportunity__c  =: OppId ];
            for(Opportunity_Solution_Area__c os: csList){
                setSolSelector.add(os.Core_Solution_Areas__c);
            }
                List<Core_Solution_Areas__c> SolnArea= new List<Core_Solution_Areas__c>();
                SolnArea = [Select Id, Core_Solution_Areas__c, tolabel( Core_Technology_Enabled__c), tolabel(Core_Region_of_availability__c) ,tolabel(Core_Industry_Use_Case__c),  tolabel(Core_Industry__c), tolabel( Core_Application_Workload__c) from Core_Solution_Areas__c where Id in :solAreaIds]; 
                    
           // for(String solArea: solAreaIds){
             for(Core_Solution_Areas__c Sol : SolnArea){    
                if(!setSolSelector.contains(Sol.Id)){
                    Opportunity_Solution_Area__c oppDetails = new Opportunity_Solution_Area__c();
                    oppDetails.Core_Solution_Areas__c = Sol.Id;
                    oppDetails.Core_Opportunity__c = OppId;
                    oppDetails.Core_Technology_Enabled__c = Sol.Core_Technology_Enabled__c;
                    oppDetails.Core_Region_of_availability__c = Sol.Core_Region_of_availability__c;
                    oppDetails.Core_Industry_Use_Case_s__c = Sol.Core_Industry_Use_Case__c;
                    oppDetails.Core_Industry__c = Sol.Core_Industry__c;
                    oppDetails.Core_Application_Workload__c = Sol.Core_Application_Workload__c;
                    solList.add(oppDetails);
                }
            }
            
            upsert solList;
            if(OppId!=null){
                oppList = [Select Id, Core_has_Solution__c from Opportunity where Id =: OppId];
                for(Opportunity opp: oppList){
                    if(opp.Core_has_Solution__c == false){
                        opp.Core_has_Solution__c = true;
                    }   
                    //oppList.add(opp);
                }
                Update oppList;
            }
            return 'Solution Area records added Successfully';
        }
        Catch(Exception e){
            String errorMsg = e.getMessage();String pureErrorMsg;
            if (errorMsg.toUpperCase().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){pureErrorMsg = errorMsg.toUpperCase().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION');}
            else if (errorMsg.toUpperCase().contains('EXCEPTION')){pureErrorMsg = errorMsg.toUpperCase().substringAfter('EXCEPTION');}
            throw new AuraHandledException(pureErrorMsg);
            
        }
            
    }
    
    public static void addOppPartner(List<Opportunity_Solution_Area__c> oppSolArea){
        
        List<Core_Solution_Area_Partner__c> solPartner = new List<Core_Solution_Area_Partner__c>();
        List<Core_Opportunity_Partner__c> oppPartner = new List<Core_Opportunity_Partner__c>();
        List<Opportunity_Solution_Area__c> oppSA = new List<Opportunity_Solution_Area__c>();   
        List<ID> solArea = new List<ID>();
        List<String> opp = new List<String>();
        Map<Id, Id> oppId = new Map<Id, Id>();
        try{
            for(Opportunity_Solution_Area__c oppPart : oppSolArea){
                oppId.put(oppPart.Core_Solution_Areas__c, oppPart.Core_Opportunity__c);
                solArea.add(oppPart.Core_Solution_Areas__c);
            }
            
            if(solArea.size()>0){
                solPartner = [Select Id, Core_Solution_Partner__c, Core_Solution_Area__c, Core_Solution_Partner_Role__c, Solution_Partner_Type__c from Core_Solution_Area_Partner__c where Core_Solution_Area__c =: solArea]; 
                for(Core_Solution_Area_Partner__c oppPart : solPartner){
                    Core_Opportunity_Partner__c oppPa = new Core_Opportunity_Partner__c();
                    oppPa.Core_Partner__c = oppPart.Core_Solution_Partner__c;
                    oppPa.Core_Opportunity__c = oppId.get(oppPart.Core_Solution_Area__c);
                    oppPa.Core_Partner_Role__c = oppPart.Core_Solution_Partner_Role__c;
                    oppPa.Core_Partner_Type__c = oppPart.Solution_Partner_Type__c;
                    oppPartner.add(oppPa);
                }
                if(oppPartner.size()>0){
                    upsert oppPartner;                   
                }
                
            }
        }Catch(Exception ex){}        
    }
    public static void checkSolutions(List<Opportunity_Solution_Area__c> oppSolutionArea){
        List<String> oppId = new List<String>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity_Solution_Area__c> checkSol = new List<Opportunity_Solution_Area__c>();
        try{ 
            for(Opportunity_Solution_Area__c OppSA: oppSolutionArea){
                oppId.add(OppSA.Core_Opportunity__c); 
            }
            if(oppId.size()>0){
                oppList = [Select Id, Core_has_Solution__c from Opportunity where Id =: OppId];
                if(oppList.size()>0){
                    checkSol = [Select Id,Core_Opportunity__c from Opportunity_Solution_Area__c where Core_Opportunity__c =:OppId];
                    if(checkSol.size()<=1){
                        for(Opportunity opp: oppList){
                            opp.Core_has_Solution__c = false;
                        }
                        Update oppList;
                    }
                }
            }
            
        }Catch(Exception ex){}
    }
    
       @AuraEnabled(cacheable=true)
    public static List<String> Get_Types_Application_Workload(){
       
      List<String>  Application_Workload = new List<String>();
        try {
            List<Map<String,String>> selectOpt = new List<Map<String,String>>();
            List<selectOption> options = new List<selectOption>();
            List<sObject> l_Types = new List<sObject>();
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Application_Workload__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                Application_Workload.add(picklistValue.getLabel()+'|'+ picklistValue.getLabel());
            } 
            
            return Application_Workload;
        } catch (Exception e) {return null;}
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> Get_Types_TechnologyEnabled(){
       
      List<String>  TechnologyEnabled = new List<String>();
        try {
            List<Map<String,String>> selectOpt = new List<Map<String,String>>();
            List<selectOption> options = new List<selectOption>();
            List<sObject> l_Types = new List<sObject>();
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Technology_Enabled__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                TechnologyEnabled.add(picklistValue.getLabel()+'|'+ picklistValue.getLabel());
            } 
            
            return TechnologyEnabled;
        } catch (Exception e) {
        //System.debug('Exception: '+e.getMessage());
        return null;}
    }

     @AuraEnabled(cacheable=true)
    public static List<String> Get_Types_Industry_UseCase(){
       
      List<String>  Industry_UseCase = new List<String>();
        try {
            List<Map<String,String>> selectOpt = new List<Map<String,String>>();
            List<selectOption> options = new List<selectOption>();
            List<sObject> l_Types = new List<sObject>();
            // Get the describe information for the Account object
            Schema.DescribeSObjectResult Describe = Schema.sObjectType.Core_Solution_Areas__c;
            Schema.DescribeFieldResult FieldDescribe = Describe.fields.getMap().get('Core_Industry_Use_Case__c').getDescribe();
            List<Schema.PicklistEntry> PicklistValues = FieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry picklistValue : PicklistValues) {
                Industry_UseCase.add(picklistValue.getLabel()+'|'+ picklistValue.getLabel());
            } 
            
            return Industry_UseCase;
        } catch (Exception e) {return null;}
    }
    
    /*
    * TWC3123-5794
    * Method to return boolean value; false if PCC DEAL REG have FI Products, True for Intel-Led and PCC design and deal REG if atleast one product is non-FI
    */
    @AuraEnabled
    public static boolean showOpptySolution(Id recordId){
        return Core_CRM_Utility.PCCDealReg_showTab(recordId);
    }
}