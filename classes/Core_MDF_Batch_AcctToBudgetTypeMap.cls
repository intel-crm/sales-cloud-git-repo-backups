global class Core_MDF_Batch_AcctToBudgetTypeMap implements Database.Batchable<sObject>, Database.Stateful{

global String queryActive;
        
global Database.QueryLocator start(Database.BatchableContext batchableContext)
    {   
    	return Database.getQueryLocator(queryActive);
    } 

    
    public static Map<Id,Set<Id>> insertApplicableMDFBudgetType(List<Account> acctList){
        
		/*
		INITIALIZATIONS:
		applicableBenefitsFromMdt : gets the benefit to budget type mapping from metadata.
		benefitsToBudgetTypeMap : stores the benefit to budget type mapping from metadata.
		allAcctsList : list containing all accounts in the PAG hierarchy for which the benefits can be assigned.
		pagAcctToComktIdMap : map of PAG account id to comarketing acct id.
		intelAcctToCoMktAcctMap : map of intel acct id to comarketing acct id.
		IPAIdToAccountList : mapof PAG acct id to all associated intel acct ids.
		intelAcctToPAGAcctMap : map of intel acct to PAG acct id.
		comktAcctToIntelAcctMap : map of comarketing acct id to ultimate intel acct id.
		acctIdToBenefitsMap : map of acct id to benefit associated.
		acctIdToBudgetTypeMap : map of acct id to budget type for the benefit associated. 
		pagIdToBudgetTypeMap : map of pag acct id to all the budget types associated with the intel accts in the hierachy.
		coMktAcctToBudgetTypesMap : map of comarketing acct id to the budget types applicable.
		toBeInsertedList : list of new comarketing acct budget type assiciation to be inserted.
		toBeUpdatedList : list of old comarketing to budget type associations to be deleted.
		*/
        //Map<String,Set<String>> applicableBenefitsFromMdt = new Map<String,Set<String>>{}; 
        Map<String,String> benefitsToBudgetTypeMap = new Map<String,String>{}; 
        Set<Id> allAcctsList=new Set<Id>{};
        Map<Id,Id> pagAcctToComktIdMap = new Map<Id,Id>{};
        Map<Id,Id> intelAcctToCoMktAcctMap = new Map<Id,Id>{};
        Map<Id,Set<Id>> IPAIdToAccountList = new Map<Id,Set<Id>>{};   
        Map<Id,Id> intelAcctToPAGAcctMap = new Map<Id,Id>();  
        Map<Id,Id> comktAcctToIntelAcctMap = new Map<Id,Id>();
		Map<Id,Set<String>> acctIdToBenefitsMap = new Map<Id,Set<String>>{};
        Map<Id,Set<String>> acctIdToBudgetTypeMap = new Map<Id,Set<String>>{};
        Map<Id,Set<String>> pagIdToBudgetTypeMap = new Map<Id,Set<String>>{};
		Map<Id,List<String>> coMktAcctToBudgetTypesMap = new Map<Id,List<String>>();
		List<Core_MDF_Acct_to_Benefit_Mapping__c> toBeInsertedList = new List<Core_MDF_Acct_to_Benefit_Mapping__c>();
        List<Core_MDF_Acct_to_Benefit_Mapping__c> toBeUpdatedList = new List<Core_MDF_Acct_to_Benefit_Mapping__c>();
        
        Map<Id,Set<Id>> recToBeShared = new Map<Id,Set<Id>>();
        //get the benefit to budget type mapping from metadata.    		
        for(Core_MDF_BudgetType_Benefit_Mappings__c budToBenMdt:[select Core_MDF_Budget_Type__c,Core_MDF_Partner_Benefit__c 
                                                                      from Core_MDF_BudgetType_Benefit_Mappings__c]){
                benefitsToBudgetTypeMap.put(budToBenMdt.Core_MDF_Partner_Benefit__c.toUpperCase(),budToBenMdt.Core_MDF_Budget_Type__c);
            }    
            
        //for each input acct, get the intel accts and form maps. Also add the intel acct to all acct list.
        for(Account acc:acctList){
            comktAcctToIntelAcctMap.put(acc.Id,acc.Core_MDF_CoMarketing_Ultimate_Account__c);
            intelAcctToCoMktAcctMap.put(acc.Core_MDF_CoMarketing_Ultimate_Account__c,acc.Id);
            allAcctsList.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
        }
        
        //Get the pag acct for all intel accts.
        for(Core_Account_Group_Member__c IPAAcct : [SELECT Core_Intel_Account_Id__c,Core_Partner_Account_Id__c FROM Core_Account_Group_Member__c
                               WHERE Core_Intel_Account_Id__c in : comktAcctToIntelAcctMap.values()]){
            //store virtual acct id:ipa acct id
            pagAcctToComktIdMap.put(IPAAcct.Core_Partner_Account_Id__c,intelAcctToCoMktAcctMap.get(IPAAcct.Core_Intel_Account_Id__c));
            //add pag acct to the all acct list
			allAcctsList.add(IPAAcct.Core_Partner_Account_Id__c);
                            
        }
        
        if(allAcctsList.size() > 0){
            
        //store ipa acct id:list of all related acct ids
        for(Core_Account_Group_Member__c acctGrpList : [SELECT Core_Intel_Account_Id__c,Core_Partner_Account_Id__c 
                                                        FROM Core_Account_Group_Member__c
                                                        WHERE Core_Partner_Account_Id__c IN: allAcctsList AND 
                                                        Core_Inactive_Ind__c = FALSE]){
            Set<Id> existingAcct=new Set<Id>{};
                //store list of all acct ids for which benefit needs to be derieved and add all the associated intel accts to all acct list.  
                if(IPAIdToAccountList.containsKey(acctGrpList.Core_Partner_Account_Id__c)){
                    existingAcct =  IPAIdToAccountList.get(acctGrpList.Core_Partner_Account_Id__c);
                    existingAcct.add(acctGrpList.Core_Intel_Account_Id__c); 
                    allAcctsList.add(acctGrpList.Core_Intel_Account_Id__c);
                }else{
                    existingAcct.add(acctGrpList.Core_Intel_Account_Id__c); 
                    allAcctsList.add(acctGrpList.Core_Intel_Account_Id__c);
                }
            //form intel acct to pag acct map                                                
            intelAcctToPAGAcctMap.put(acctGrpList.Core_Intel_Account_Id__c,acctGrpList.Core_Partner_Account_Id__c);
			//form map of pag acct to all associated intel accts                                                   
            IPAIdToAccountList.put(acctGrpList.Core_Partner_Account_Id__c,existingAcct);
        }
    
        system.debug('intelAcctToPAGAcctMap:'+intelAcctToPAGAcctMap);    
        system.debug('allAcctsList:'+allAcctsList); 
		
            
        acctIdToBudgetTypeMap = getApplicableBudgetTypesForAllAccts(allAcctsList,benefitsToBudgetTypeMap);
        system.debug('acctIdToBudgetTypeMap:'+acctIdToBudgetTypeMap); 

		   //form pag acct to budget type map
	    pagIdToBudgetTypeMap = getPAGAcctToBudgetType(acctIdToBudgetTypeMap,intelAcctToPAGAcctMap);
        system.debug('pagIdToBudgetTypeMap:'+pagIdToBudgetTypeMap);
		   
		   //for all input accts for the comarketing acct to budget type applicable map
		coMktAcctToBudgetTypesMap = getCoMktAcctToBudgetType(acctList,acctIdToBudgetTypeMap,pagIdToBudgetTypeMap,comktAcctToIntelAcctMap,intelAcctToPAGAcctMap);
        system.debug('coMktAcctToBudgetTypesMap:'+coMktAcctToBudgetTypesMap);
           
          
          //get the existing records from object
            Map<Id,Core_MDF_Acct_to_Benefit_Mapping__c> existingRecMap = new Map<Id,Core_MDF_Acct_to_Benefit_Mapping__c>();
            for (Core_MDF_Acct_to_Benefit_Mapping__c rec : [select id,Core_MDF_CoMarketing_Account_Id__c,Core_MDF_Budget_Type_Nm__c,
                                                                Core_MDF_Active_Ind__c,Name
                                                                       FROM Core_MDF_Acct_to_Benefit_Mapping__c
                 
                                                                WHERE Core_MDF_CoMarketing_Account_Id__c IN: coMktAcctToBudgetTypesMap.keySet()]){
                existingRecMap.put(rec.Id,rec);}
          
            //remove/inactivate the budget type entries if already present cause no action required. Form the tobedeleted list if budget type not applicable anymore.
            
            
            for(Id recId:existingRecMap.keySet()){
                
                if(coMktAcctToBudgetTypesMap.containsKey(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c)
                   && (coMktAcctToBudgetTypesMap.get(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c) != null
                   && coMktAcctToBudgetTypesMap.get(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c).contains(existingRecMap.get(recId).Name)
                   && existingRecMap.get(recId).Core_MDF_Active_Ind__c == true)){
                    //remove the id from map if already added to the obj.
                    List<String> bt = coMktAcctToBudgetTypesMap.get(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c);
                      Integer index = bt.indexOf(existingRecMap.get(recId).Name);
                      bt.remove(index);
                       if(bt.size()>0){
                           coMktAcctToBudgetTypesMap.put(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c,bt);
                      }
                       else{
                           coMktAcctToBudgetTypesMap.put(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c,null);
                      }
                      existingRecMap.remove(recId);
                    
                }
                else if(coMktAcctToBudgetTypesMap.containsKey(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c)
                  && (coMktAcctToBudgetTypesMap.get(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c) != null
                  && coMktAcctToBudgetTypesMap.get(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c).contains(existingRecMap.get(recId).Name)
                  && existingRecMap.get(recId).Core_MDF_Active_Ind__c == false)){
                    Core_MDF_Acct_to_Benefit_Mapping__c acctToBudgetTypeToBeUpd = new Core_MDF_Acct_to_Benefit_Mapping__c();
                    acctToBudgetTypeToBeUpd.Id=existingRecMap.get(recId).Id;
                    acctToBudgetTypeToBeUpd.Core_MDF_Active_Ind__c=true;
                    toBeUpdatedList.add(acctToBudgetTypeToBeUpd);
                      List<String> bt1 = coMktAcctToBudgetTypesMap.get(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c);
                      Integer index1 = bt1.indexOf(existingRecMap.get(recId).Name);
                      bt1.remove(index1);
                      if(bt1.size()>0){
                           coMktAcctToBudgetTypesMap.put(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c,bt1);
                      }
                       else{
                           coMktAcctToBudgetTypesMap.put(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c,null);
                      }
                      existingRecMap.remove(recId);
                }
                else if(coMktAcctToBudgetTypesMap.containsKey(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c)
                       && (coMktAcctToBudgetTypesMap.get(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c) == null
                       || !coMktAcctToBudgetTypesMap.get(existingRecMap.get(recId).Core_MDF_CoMarketing_Account_Id__c).contains(existingRecMap.get(recId).Name))){
                    //need to delete record
                    Core_MDF_Acct_to_Benefit_Mapping__c acctToBudgetTypeToBeUpd1 = new Core_MDF_Acct_to_Benefit_Mapping__c();
                    acctToBudgetTypeToBeUpd1.Id=existingRecMap.get(recId).Id;
                    acctToBudgetTypeToBeUpd1.Core_MDF_Active_Ind__c=false;
                    toBeUpdatedList.add(acctToBudgetTypeToBeUpd1);
   
                }
            }
            
            system.debug('toBeUpdatedList:'+toBeUpdatedList);
            system.debug('coMktAcctToBudgetTypesMap:'+coMktAcctToBudgetTypesMap);
			
			//for each leftover budget types that are new form the to be inserted list.
            for(Id acctId: coMktAcctToBudgetTypesMap.keySet()){
                
                List<String> bt = coMktAcctToBudgetTypesMap.get(acctId);
                if(bt != null){
                for(String b:bt){
                    Core_MDF_Acct_to_Benefit_Mapping__c acctToBudgetType = new Core_MDF_Acct_to_Benefit_Mapping__c();
                    acctToBudgetType.Name=b;
                    acctToBudgetType.Core_MDF_CoMarketing_Account_Id__c=acctId;
                    acctToBudgetType.Core_MDF_Active_Ind__c = true;
                    acctToBudgetType.Core_MDF_Budget_Type_Nm__c = b;
                    toBeInsertedList.add(acctToBudgetType);
                }
                }
            }
            
            system.debug('toBeInsertedList:'+toBeInsertedList);
			
			//check if list not null, insert new records
            if(toBeInsertedList != null){
                insert toBeInsertedList;
            }
			//get record after insertion for sharing
			for(Core_MDF_Acct_to_Benefit_Mapping__c rec:[Select Id,Core_MDF_CoMarketing_Account_Id__c from Core_MDF_Acct_to_Benefit_Mapping__c
                                                      where Core_MDF_CoMarketing_Account_Id__c in :acctList]){
                    Set<Id> existingRecToBeShared=new Set<Id>{};
                    if(recToBeShared.containsKey(rec.Core_MDF_CoMarketing_Account_Id__c)){
                    existingRecToBeShared =  recToBeShared.get(rec.Core_MDF_CoMarketing_Account_Id__c);
                    }
                      else{
                    existingRecToBeShared.add(rec.Id);
                    }
                  recToBeShared.put(rec.Core_MDF_CoMarketing_Account_Id__c,existingRecToBeShared);
                                                      }
			
			//check if list not null, delete the unnecessary records.
            if(toBeUpdatedList != null){
                update toBeUpdatedList;
            }
            
            
        }
        return recToBeShared;
    }
    
            public static Map<Id,Set<String>> getApplicableBudgetTypesForAllAccts(Set<Id> allAcctsList,Map<String,String> benefitsToBudgetTypeMap){
        Map<Id,Set<String>> acctIdToBudgetTypeMap = new Map<Id,Set<String>>();
                Map<Id,Set<String>> acctIdToBenefitsMap = new Map<Id,Set<String>>();
            //Get the budget types and benefits for all accts: PAG accts as well as all the related accts
        for(PRM_AccountBenefitAssociation__c benefit : [SELECT Id,PRM_Partner_Benefit_Id__r.name, PRM_Account_Id__c,PRM_Account_Id__r.name 
                                                        FROM PRM_AccountBenefitAssociation__c 
                                                        WHERE PRM_Account_Id__c in : allAcctsList 
                                                        AND PRM_Status_Nm__c='Active' 
                                                        AND PRM_Partner_Benefit_Id__r.name LIKE '%MDF%']){
            
                Set<String> budgetType = new Set<String>{};
                Set<String> benefits = new Set<String>{};
                if(acctIdToBudgetTypeMap.containsKey(benefit.PRM_Account_Id__c) && acctIdToBenefitsMap.containsKey(benefit.PRM_Account_Id__c)){
                    budgetType =  acctIdToBudgetTypeMap.get(benefit.PRM_Account_Id__c);
                    benefits = acctIdToBenefitsMap.get(benefit.PRM_Account_Id__c);
                    budgetType.add(benefitsToBudgetTypeMap.get(benefit.PRM_Partner_Benefit_Id__r.name.toUpperCase())); 
                    benefits.add(benefit.PRM_Partner_Benefit_Id__r.name.toUpperCase());
                }else{
                    budgetType.add(benefitsToBudgetTypeMap.get(benefit.PRM_Partner_Benefit_Id__r.name.toUpperCase()));
                    benefits.add(benefit.PRM_Partner_Benefit_Id__r.name.toUpperCase());
                    }
			//form acct id to benefit and budget type map		
            acctIdToBudgetTypeMap.put(benefit.PRM_Account_Id__c,budgetType);                                                
            acctIdToBenefitsMap.put(benefit.PRM_Account_Id__c,benefits); 
         }
          return acctIdToBudgetTypeMap;
        }
    
    public static Map<Id,Set<String>> getPAGAcctToBudgetType(Map<Id,Set<String>> acctIdToBudgetTypeMap,Map<Id,Id> intelAcctToPAGAcctMap){
        Map<Id,Set<String>> pagIdToBudgetTypeMap = new Map<Id,Set<String>>();
        for(Id intelAcc:acctIdToBudgetTypeMap.keySet()){
                Set<String> btypes = new Set<String>();
            if(intelAcctToPAGAcctMap.containsKey(intelAcc)){
                if(pagIdToBudgetTypeMap.containsKey(intelAcctToPAGAcctMap.get(intelAcc))){
                    btypes = pagIdToBudgetTypeMap.get(intelAcctToPAGAcctMap.get(intelAcc));
                    btypes.addAll(acctIdToBudgetTypeMap.get(intelAcc));
                    pagIdToBudgetTypeMap.put(intelAcctToPAGAcctMap.get(intelAcc),btypes);
                }
                else{
                    btypes = acctIdToBudgetTypeMap.get(intelAcc);
                    pagIdToBudgetTypeMap.put(intelAcctToPAGAcctMap.get(intelAcc),btypes);
                }
                
            }
            }
        return pagIdToBudgetTypeMap;
    }
    
    public static Map<Id,List<String>> getCoMktAcctToBudgetType(List<Account> acctList,Map<Id,Set<String>> acctIdToBudgetTypeMap,Map<Id,Set<String>> pagIdToBudgetTypeMap,Map<Id,Id> comktAcctToIntelAcctMap, Map<Id,Id> intelAcctToPAGAcctMap){
        Map<Id,List<String>> coMktAcctToBudgetTypesMap = new Map<Id,List<String>>();
        
       
        
        
        
        for(Account acc:acctList){
            system.debug('acc:'+acc);
            system.debug('comktAcctToIntelAcctMap:'+comktAcctToIntelAcctMap);
            coMktAcctToBudgetTypesMap.put(acc.Id,null);
            //if(acctIdToBudgetTypeMap.containsKey(comktAcctToIntelAcctMap.get(acc.Id))){
                     
                     Set<String> setBt = pagIdToBudgetTypeMap.get(intelAcctToPAGAcctMap.get(comktAcctToIntelAcctMap.get(acc.Id)));
                     system.debug('setBt:'+setBt);
                     List<String> val = new List<String>();
                     //Set<String> setBt = acctIdToBudgetTypeMap.get(comktAcctToIntelAcctMap.get(acc.Id));
            if(setBt != null) {
            for(String s:setBt){
                         if(s!=null && !val.contains(s)){
                             val.add(s);
                         }
                         coMktAcctToBudgetTypesMap.put(acc.Id,val);
            }
            }
                    
            //}
            
        }
        return coMktAcctToBudgetTypesMap;
    }    
    
    
global void execute(Database.BatchableContext batchableContext, List<Account> acctList)
    {
        try
        {
            
            
          Map<Id,Set<Id>> recToBeShared = insertApplicableMDFBudgetType(acctList); 
          Map<Id,Set<Id>> accIdPnumUsrIdMap = new Map<Id,Set<Id>>();
            //Prepare Map of Account and Account User
        for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id,Core_MDF_Account__c, Core_MDF_User__c 
                                                          FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                          WHERE Core_MDF_Account__c IN : acctList AND
                                                          Core_MDF_User__r.IsActive = TRUE]){
            //Map with AccountId and Account UserId
           if(accIdPnumUsrIdMap.containsKey(pnum.Core_MDF_Account__c)){
                accIdPnumUsrIdMap.get(pnum.Core_MDF_Account__c).add(pnum.Core_MDF_User__c);
            }else{
                accIdPnumUsrIdMap.put(pnum.Core_MDF_Account__c, new Set<Id> {pnum.Core_MDF_User__c});
            }
        }
        
            Map<Id, List<Id>> recIdUserIdMap = new Map<Id,List<Id>>();
             //To get the pnumUser associated with an Account on Campaign
        for(Id acc: recToBeShared.keySet()){
            
            Set<Id> recIds = recToBeShared.get(acc);
                if(accIdPnumUsrIdMap.containsKey(acc)){
                    List<Id> userIdSet = new List<Id>();
                    userIdSet.addAll(accIdPnumUsrIdMap.get(acc));
                    For(Id rec:recIds){
                         recIdUserIdMap.put(rec, userIdSet);
                    }
                   
                    
                }
            
        }
        //For Ext Sharing
        if(recIdUserIdMap.size() > 0){
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass extShare = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Acct_to_Benefit_Mapping__c',recIdUserIdMap, 'Edit');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(extShare);
        }
                    }  
        	
        	catch(Exception ex)
                {
                	System.debug('***Exception occurred while ReProcessing' + ex.getmessage()); 
                }   
    }     

global void finish (Database.BatchableContext batchableContext)
    {
        /*System.debug('*** Campaigns updated : '+campaignsUpdated);
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchableContext.getJobId()];
        String message = 'The batch Apex job with JObId: '+ a.Id +' processed. <br><br>';
       
        //Fetching Email Address details from Custom setting.
        String sendEmailAddress = Label.Core_MDF_CCP_Support_Email;
        //String sendEmailAddress = 'ealisha.chatterjee@intel.com';
        Boolean sendemail = false;
        // Send an email to the Apex job's ;submitter notifying of job completion only if Custom Setting 'toAddress' data is available
        if(Test.isRunningTest())
            {
                sendEmailAddress = 'ealisha.chatterjee@intel.com';
                sendemail = true;
            }
         
        if((campaignsUpdated != null && !campaignsUpdated.isEmpty()) || errorMessage != '')
        	{
                sendemail = true;
            }        
        
        
        if( sendemail == true && (sendEmailAddress != null && sendEmailAddress != ''))        
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {sendEmailAddress};
                mail.setToAddresses(toAddresses);
                mail.setSubject(Label.Core_MDF_SFDC_Environment + ': Salesforce BatchUpdateCampaignField ' + a.Status);
                String messageBody = '';
                if(!campaignsUpdated.isEmpty() || Test.isRunningTest()){
                messageBody += '\nCampaigns Processed:\n\n';
                messageBody += '<table style="width:100%"><tr><th>Program</th><th>Campaign Reference Number</th><th>Campaign Id</th><th>Campaign Name</th><th>Status</th><th>StartDate</th><th>EndDate</th></tr>';
                for(campaign c:campaignsUpdated)
                    {
                      messageBody += '<tr><td>'+c.Core_mdf_program__c+'</td> <td>'+c.Core_MDF_Campaign_Reference_Number__c+'</td><td>'+c.Id+'</td><td>'+c.Name+'</td><td>'+c.Status+'</td><td>'+c.StartDate+'</td><td>'+c.EndDate+'</td></tr>';
                    }
                messageBody += '</table><br>';
                }
                
                if(errorMessage != '' || Test.isRunningTest())
                    {
                        
                        messageBody += '\nFollowing campaigns have failed during the update:\n\n';
                        messageBody += '<table style="width:100%"><tr><th>Program</th><th>Campaign Reference Number</th><th>Campaign Id</th><th>Campaign Name</th><th>Error Message</th></tr>';                                                                
                        messageBody +=  errorMessage;
                    }
                mail.setHtmlBody(message + '\n' + '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style>' + messageBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
             }*/
    }
}