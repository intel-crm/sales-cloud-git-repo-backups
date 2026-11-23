global class Core_MDF_ATFReportBatch implements Database.Batchable<SObject>,Database.Stateful,Core_MDF_BatchSchedulerInterface {
    
    //custom batch scheduler- pass the parameters & utilize it here
    //Record tracking insertion- sending email
    //String csvHeader = 'Program,ATF Flag,Ultimate Account Name,Activity Number,Budget Type,Activity Status,Intel Contribution Old,Intel Contribution New,Intel Contribution Difference,Created Date\n'; // CSV header
    Public Id recordTrackingId;
    Public List<String> csvDataList = new List<String>();
    Public List<ContentVersion> contentVersionListToBeInserted = new List<ContentVersion>();
    //String startDatePfr;
    //String endDatePfr;
	String createdDatePfr;
    global Core_MDF_ATFReportBatch(){}
    
    public static object generateInstance(String jsonText, String classSignature){
        object des_Obj;
        map<String,object> parmValueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
        if(classSignature == 'Core_MDF_ATFReportBatch(String createdDatePfr)'){
            //String startDate = String.valueOf(parmValueMap.get('startDatePfr'));
            //String endDate = String.valueOf(parmValueMap.get('endDatePfr'));
			String createdDate = String.valueOf(parmValueMap.get('createdDatePfr'));
            des_Obj = new Core_MDF_ATFReportBatch(createdDate);
        }
        return des_Obj;
    }
    
    global Core_MDF_ATFReportBatch(String createdDatePfr){
        /*this.startDatePfr = startDatePfr;
        this.endDatePfr = endDatePfr;*/
		this.createdDatePfr = createdDatePfr;
    }
    
    // This method is called at the beginning of the batch job.
    global Database.QueryLocator start(Database.BatchableContext bcontext) {
        // Return the query locator for the records you want to process.
        String query = 
            'Select id,Core_MDF_Program__c, Core_MDF_ATF_Flag_nm__c,Title, '+
            'Core_MDF_Ultimate_Account_Name__c, Core_MDF_Activity_Number__c, '+
            'Core_MDF_Budget_Type_nm__c,Core_MDF_Reimbursement_Rate_txt__c, Core_MDF_Fund_Request_Status__c, '+
            'Core_MDF_Budget_Amount_Local_amt__c, RequestedAmount, '+
            'Core_MDF_Activity_Reimbursement_Amt_nbr__c, Core_MDF_Reimbursement_Rate__c, '+
            'Core_MDF_MDFReimbursement_Amt__c, Core_MDF_Exchange_Rate_ptc__c, '+
            'Core_MDF_Budget_Currency_cd__c, CreatedDate, CreatedById '+
            'from PartnerFundRequest where Core_MDF_Fund_Request_Status__c != \'Cancelled\'';
            /*and Core_MDF_Start_Date__c=: var and Core_MDF_End_Date__c=: var */ 
        
        /*if(startDatePfr != null){
            //query += ' AND '+ Core_MDF_Start_Date__c + '='+ startDatePfr;
            query += ' AND Core_MDF_Start_Date__c >='+ startDatePfr;
        }
        if(endDatePfr != null){
            query += ' AND Core_MDF_End_Date__c <='+ endDatePfr;
        }*/
		if(createdDatePfr != null){
			query += ' AND CreatedDate ='+ createdDatePfr;
		}
        
        query += ' ORDER BY CreatedDate DESC';
        return Database.getQueryLocator(query);
    }
    
    // This method is called for each batch of records.
    global void execute(Database.BatchableContext bcontext, List<PartnerFundRequest> pfrList) {
        
        Map<Id,string> mapOfProgram = new Map<Id, string>();
        Map<Id,string> mapOfATFFlag = new Map<Id, string>();
        Map<Id,string> mapOfUltimateAcc = new Map<Id, string>();
        Map<Id,string> mapOfPFRNumber = new Map<Id, string>();
        Map<Id,string> mapOfBudgetType = new Map<Id, string>();
        Map<Id,string> mapOfStatus = new Map<Id, string>();
        Map<Id,Decimal> mapOfExchangeRate = new Map<Id,Decimal>();
        Map<Id,Datetime> mapOfCreatedDate = new Map<Id, Datetime>();
        Map<Id, String> mapOfCurrencyValues = new Map<Id, String>();
        Map<Id, Id> mapOfCreatedById = new Map<Id, Id>();
        String  oldRRValue, newRRValue;
        String oldAmtValue;
        Map<Id,String> titleName = new Map<Id,String>();
        Decimal newAmtValue=0;
        Decimal intelContributionOld=0;
        Decimal intelContributionNew=0;
        Decimal intelContributionDifference=0;
        Map<Id,String> mapOfNewRR = new Map<Id,String>();
        Map<Id,Decimal> mapOfNewAmt = new Map<Id,Decimal>();
        Map<Id,Decimal> mapOfAmt = new Map<Id,Decimal>();
        Map<Id,Decimal> mapOfICValue = new Map<Id,Decimal>();
        Map<Id, Decimal> mapOfMDFReimbursement = new Map<Id, Decimal>();//added
        
        Map<Id, List<PartnerFundRequestHistory>> pfrIdToHistoriesMap = new Map<Id, List<PartnerFundRequestHistory>>();
        Map<Id, List<PartnerFundRequestHistory>> mapOfPfrIdToOldRRHistory = new Map<Id, List<PartnerFundRequestHistory>>();
        Map<Id, List<PartnerFundRequestHistory>> mapOfPfrIdToOldAmtHistory = new Map<Id, List<PartnerFundRequestHistory>>();
        List<PartnerFundRequest> newPfrList = new List<PartnerFundRequest>();
        try{
            for(PartnerFundRequest pfr : pfrList){
                newPfrList.add(pfr);
                //mapOfNewRR.put(pfr.Id, pfr.Core_MDF_Reimbursement_Rate_txt__c);
                mapOfNewRR.put(pfr.Id, pfr.Core_MDF_Reimbursement_Rate__c);
                mapOfAmt.put(pfr.Id, pfr.RequestedAmount);
                titleName.put(pfr.Id,pfr.Title);
                mapOfNewAmt.put(pfr.Id,pfr.Core_MDF_Budget_Amount_Local_amt__c);
                mapOfICValue.put(pfr.id,pfr.Core_MDF_Activity_Reimbursement_Amt_nbr__c);
                mapOfProgram.put(pfr.id,pfr.Core_MDF_Program__c);
                mapOfATFFlag.put(pfr.id,pfr.Core_MDF_ATF_Flag_nm__c);
                mapOfUltimateAcc.put(pfr.id,pfr.Core_MDF_Ultimate_Account_Name__c);
                mapOfPFRNumber.put(pfr.id,pfr.Core_MDF_Activity_Number__c);
                mapOfBudgetType.put(pfr.id,pfr.Core_MDF_Budget_Type_nm__c);
                mapOfStatus.put(pfr.id,pfr.Core_MDF_Fund_Request_Status__c);
                mapOfCreatedDate.put(pfr.id,pfr.CreatedDate);
                mapOfCreatedById.put(pfr.Id, pfr.CreatedById);
                mapOfCurrencyValues.put(pfr.Id, pfr.Core_MDF_Budget_Currency_cd__c);
                mapOfMDFReimbursement.put(pfr.id, pfr.Core_MDF_MDFReimbursement_Amt__c);//added
                mapOfExchangeRate.put(pfr.id, pfr.Core_MDF_Exchange_Rate_ptc__c);
                //exchange rate
            }    
            for(PartnerFundRequestHistory pfrHistoryrecord : [select id, PartnerFundRequestId,Field, 
                                                              OldValue,NewValue, CreatedDate, CreatedBy.name
                                                              from PartnerFundRequestHistory where 
                                                              Field IN ('Core_MDF_Budget_Amount_Local_amt__c','Core_MDF_Reimbursement_Rate_txt__c') 
                                                              and PartnerFundRequestId IN:pfrList 
                                                              order by CreatedDate asc]){
                                                                  if(!pfrIdToHistoriesMap.containsKey(pfrHistoryrecord.PartnerFundRequestId)){
                                                                      pfrIdToHistoriesMap.put(pfrHistoryrecord.PartnerFundRequestId,new List<PartnerFundRequestHistory>{pfrHistoryrecord});
                                                                  } else{
                                                                      pfrIdToHistoriesMap.get(pfrHistoryrecord.PartnerFundRequestId).add(pfrHistoryrecord);
                                                                  }
                                                                  
                                                                  if(pfrHistoryrecord.Field == 'Core_MDF_Reimbursement_Rate_txt__c'){
                                                                      if(!mapOfPfrIdToOldRRHistory.containsKey(pfrHistoryrecord.PartnerFundRequestId)){
                                                                          mapOfPfrIdToOldRRHistory.put(pfrHistoryrecord.PartnerFundRequestId,new List<PartnerFundRequestHistory>{pfrHistoryrecord});
                                                                      } else{
                                                                          mapOfPfrIdToOldRRHistory.get(pfrHistoryrecord.PartnerFundRequestId).add(pfrHistoryrecord);
                                                                      }
                                                                  }
                                                                  
                                                                  if(pfrHistoryrecord.Field == 'Core_MDF_Budget_Amount_Local_amt__c'){
                                                                      if(!mapOfPfrIdToOldAmtHistory.containsKey(pfrHistoryrecord.PartnerFundRequestId)){
                                                                          mapOfPfrIdToOldAmtHistory.put(pfrHistoryrecord.PartnerFundRequestId,new List<PartnerFundRequestHistory>{pfrHistoryrecord});
                                                                      } else{
                                                                          mapOfPfrIdToOldAmtHistory.get(pfrHistoryrecord.PartnerFundRequestId).add(pfrHistoryrecord);
                                                                      }
                                                                  }
                                                                  
                                                                  //containskey check & other history records to the same map
                                                                  
                                                              }
            Core_MDF_ATFReportWrapper reportWrap;
            List<Core_MDF_ATFReportWrapper> reportWrapList = new List<Core_MDF_ATFReportWrapper>();
            
            for(Id pfrId : pfrIdToHistoriesMap.keyset()){
                String budgetType = mapOfBudgetType.get(pfrId);//added
                //RR
                List<PartnerFundRequestHistory> pfrHistoryListRR =  mapOfPfrIdToOldRRHistory!=null ? mapOfPfrIdToOldRRHistory.get(pfrId) : new List<PartnerFundRequestHistory>();
                if(pfrHistoryListRR!=null ){
        			
                    if(pfrHistoryListRR[0].Field == 'Core_MDF_Reimbursement_Rate_txt__c'){
                        oldRRValue = String.valueOf(pfrHistoryListRR[0].OldValue);
                    }//pfrHistoryListRR.size()-1 = last entry
                }
                
                
                //Amount
                List<PartnerFundRequestHistory> pfrHistoryListAmt =  mapOfPfrIdToOldRRHistory!=null ? mapOfPfrIdToOldAmtHistory.get(pfrId) : new List<PartnerFundRequestHistory>();
                if(pfrHistoryListAmt!=null){
                    
                    if(pfrHistoryListAmt[0].Field == 'Core_MDF_Budget_Amount_Local_amt__c'){
                        oldAmtValue = String.valueOf(pfrHistoryListAmt[0].OldValue);
                    }//pfrHistoryListAmt.size()-1 = last entry
                }
                
                //needs to be uncommented
                if(oldRRValue!=null && oldAmtValue!=null){
                    //intelContributionOld = ((decimal.valueOf(oldAmtValue) * decimal.valueOf(oldRRValue.removeEnd('%')))/100).setScale(2,RoundingMode.HALF_UP) ;
                	intelContributionOld = ((Decimal.valueOf(oldAmtValue) * Decimal.valueOf(oldRRValue.removeEnd('%')) / 100) * mapOfExchangeRate.get(pfrId)).setScale(2, RoundingMode.HALF_UP);
                }else{
                    intelContributionOld = 0;
                }
               
                if(mapOfNewAmt.get(pfrId)!=null && mapOfNewRR.get(pfrId)!=null){
                    //intelContributionNew = ((mapOfNewAmt.get(pfrId) * decimal.valueOf(mapOfNewRR.get(pfrId).removeEnd('%')))/100).setScale(2,RoundingMode.HALF_UP);
                    intelContributionNew = ((mapOfNewAmt.get(pfrId) * decimal.valueOf(mapOfNewRR.get(pfrId).removeEnd('%'))/100) * mapOfExchangeRate.get(pfrId)).setScale(2,RoundingMode.HALF_UP); 
                } else{
                    intelContributionNew = 0;
                }              
                // Calculate Intel Contribution Difference based on budget type--Added
                if ((budgetType == 'MDF' || budgetType == 'MDF+') && mapOfMDFReimbursement.get(pfrId) != null) {
                    // Use MDF Reimbursement field value if present
                    intelContributionDifference = mapOfMDFReimbursement.get(pfrId);
                } else {
    				// For other budget types, calculate the difference using intelContributionOld
    				intelContributionDifference = intelContributionNew - mapOfICValue.get(pfrId);
                } 
                
               reportWrap = new Core_MDF_ATFReportWrapper(
                   pfrId, 
                   mapOfProgram.get(pfrId), 
                   //mapOfATFFlag.get(pfrId), 
                   mapOfATFFlag.get(pfrId) != null ? mapOfATFFlag.get(pfrId) : '',
                    titleName.get(pfrId),
                   mapOfUltimateAcc.get(pfrId),
                    mapOfPFRNumber.get(pfrId), 
                   mapOfBudgetType.get(pfrId), 
                   mapOfStatus.get(pfrId),
                    mapOfNewAmt.get(pfrId) != null ? mapOfNewAmt.get(pfrId) : 0,
                   mapOfAmt.get(pfrId) != null ? mapOfAmt.get(pfrId) : 0,
                   mapOfICValue.get(pfrId) != null ? mapOfICValue.get(pfrId) : 0,
                   mapOfNewRR.get(pfrId),
                   mapOfMDFReimbursement.get(pfrId) != null ? mapOfMDFReimbursement.get(pfrId) : 0,
                   mapOfExchangeRate.get(pfrId) != null ? mapOfExchangeRate.get(pfrId) : 0,
                   mapOfCurrencyValues.get(pfrId), 
                   /*mapOfNewRR.get(pfrId),*/ oldRRValue != null ? oldRRValue :'0',
                   /*newRRValue!= null ? newRRValue : '0',*/ mapOfNewRR.get(pfrId),
                   oldAmtValue != null ? oldAmtValue : '0', 
                   mapOfNewAmt.get(pfrId) != null ? mapOfNewAmt.get(pfrId) : 0,
                   intelContributionOld, 
                   intelContributionNew,
                   intelContributionDifference, 
                   mapOfCreatedDate.get(pfrId),
                   mapOfCreatedById.get(pfrId));
                reportWrapList.add(reportWrap);
            }
            csvDataList.addAll(generateCSV(reportWrapList));
        }catch(Exception ex){
        }
    }
    
    
    // This method is called after all batches are processed.
    global void finish(Database.BatchableContext bcontext) {
        // Perform any final operations after all batches are processed.
        
        if(recordTrackingId == null){
            Core_MDF_Record_Tracking__c rt = new Core_MDF_Record_Tracking__c();
            rt.Core_MDF_Scope_nm__c = 'ATF Report'; 
            Database.SaveResult insertedRecord = Database.insert(rt);
            
            if(insertedRecord != null && insertedRecord.isSuccess()){
                recordTrackingId = insertedRecord.getId();
            }  
        }
        
        if(csvDataList != null && !csvDataList.isEmpty()){
            String csvHeader = 'Activity Id,Program,ATF Flag,Activity Name,Ultimate Account Name,Activity Number,Budget Type,Activity Status,Activity Spending Limit Local(SF),Activity SPending Limit(SF),Intel Contribution(SF),Reimburesement Rate(SF),MDF Reimburesement Amount(USD),Exchange Rate,Currency,Reimburesement Rate(Old),Reimburesement Rate(New),Activity Spending Limit Local(Old),Activity Spending Limit Local(New),Intel Contribution(Old),Intel Contribution(New),Intel Contribution Difference,CreatedDate,CreatedById';
            csvDataList.add(0, csvHeader);
            contentVersionListToBeInserted.add(createContentVersion(csvDataList));
            Database.insert(contentVersionListToBeInserted);
            
            saveAttachment(contentVersionListToBeInserted);
        }
        
        if(csvDataList != null && !csvDataList.isEmpty()){ 
            List<String> userIdsList = new List<String>();
            List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
            String templateName =  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ATFReportEmailTemp'); 
            String iupgmGroupName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ATFReportRecipients'); 
            List<EmailTemplate> templateList = [SELECT Id, HtmlValue, Subject 
                                                FROM EmailTemplate 
                                                WHERE DeveloperName = :templateName LIMIT 1];
            
            if(iupgmGroupName != null){                          
                for(GroupMember grpMember : [SELECT Id, GroupId, UserOrGroupId, Group.DeveloperName 
                                             FROM GroupMember 
                                             WHERE Group.DeveloperName =:iupgmGroupName]){
                                                 userIdsList.add(grpMember.UserOrGroupId);
                                             }
            }
            
            if(!templateList.isEmpty() && recordTrackingId != null)                           
                for( User usr : [SELECT Id FROM user WHERE Id in: userIdsList]){
                    Messaging.SingleEmailMessage sendEmail =new Messaging.SingleEmailMessage();
                    sendEmail.setWhatId(recordTrackingId);
                    sendEmail.setTemplateId(templateList[0].id);
                    sendEmail.setTargetObjectId(usr.id);
                    sendEmail.setSaveAsActivity(false);
                    sendEmail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                    emailsToBeSent.add(sendEmail);
                }
            
            
            if(!emailsToBeSent.isEmpty()){
                Core_MDF_GenericClassToSendMail.sendEmails(emailsToBeSent);
            }
        }
        
    }
    
    public ContentVersion createContentVersion(List<String> csvDataList){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'ATFReports.csv';
        String base64 = EncodingUtil.base64Encode(Blob.valueOf(String.join(csvDataList,'\n')));
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.PathOnClient = 'ATFReports' + '.csv';
        return cv;
    }
    
    // this method will be called in finish
    public void saveAttachment(List<ContentVersion> contentVersionListToBeInserted){
        
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
        
        if(recordTrackingId != null){
            for(ContentDocument contentDoc : [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVersionListToBeInserted]){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDoc.Id; 
                cdl.LinkedEntityId = recordTrackingId;
                cdl.ShareType = 'V'; // V stands for "Viewer Access". You can also use E for "Edit Access"
                cdl.Visibility = 'InternalUsers';// set the visibility of the file. Other options are InternalUsers or SharedUsers
                contentDocLinkList.add(cdl);
            }
            insert contentDocLinkList;
        }
        
    }
    
    public static List<String> generateCSV(List<Core_MDF_ATFReportWrapper> reportWrapList) {
        String csvContent = '';
        //String csvHeader = 'Activity Id,Program,ATF Flag,Ultimate Account Name,Activity Number,Budget Type,Activity Status,Activity Spending Limit Local(SF),Activity SPending Limit(SF),Intel Contribution(SF),Reimburesement Rate(SF),MDF Reimburesement Rate(USD),Exchange Rate,Currency,Reimburesement Rate(Old),Reimburesement Rate(New),Activity Spending Limit Local(Old),Activity Spending Limit Local(New),Intel Contribution(Old),Intel Contribution(New),Intel Contribution Difference,CreatedDate,CreatedById'; // CSV header
        List<String> csvList = new List<String>();
            try{
                //comma separated values- issue (ultimate account name)
                for (Core_MDF_ATFReportWrapper wrapper : reportWrapList) {
                     csvContent = '"'+ wrapper.activityId + '","' + wrapper.program + '","' + wrapper.ATFFlag + '","'+wrapper.ActivityName+  '","' + wrapper.ultimateAccountName +  '","' +
                    wrapper.activityNumber +  '","' + wrapper.budgetType +  '","' + wrapper.activityStatus +  '","'+wrapper.activitySpendingLimitLocal + '","'+wrapper.activitySpendingLimit+ '","'
                        + wrapper.intelContribution + '","'  + wrapper.reimburesementRate +  '","' +
                    wrapper.mdfReimburesementRate +  '","' + wrapper.exchangeRate +  '","' + wrapper.currencyValue + '","' + wrapper.reimburesementRateOld + '","' + wrapper.reimburesementRateNew + '","' + wrapper.activitySpendingOld +  '","' + wrapper.activitySpendingNew +  '","' + wrapper.intelContributionOld +  '","' + wrapper.intelContributionNew + '","' +wrapper.intelContributionDifference + '","' +wrapper.createdDate + '","' +wrapper.createdById+ '"';

                    
                    csvList.add(csvContent);
                }
            }catch(Exception ex){
            }
        
        return csvList;
    }
}