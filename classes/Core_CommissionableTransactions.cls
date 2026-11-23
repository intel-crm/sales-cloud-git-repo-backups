public without sharing class Core_CommissionableTransactions {
    public static Boolean alreadyAddedCommissionableTransactions = false;

    // Commission processing was paused in 2025; only approvals/transactions on or after this cutoff are processed.
    public static DateTime getCommissionCutoff() {
        return DateTime.newInstance(Date.valueOf(System.Label.Core_Commission_Start_Date), Time.newInstance(0, 0, 0, 0));
    }

    private static Boolean isEligibleForCommission(Opportunity opp, DateTime cutoff) {
        return opp.Core_Approved_Date__c != null && opp.Core_Approved_Date__c >= cutoff;
    }

    public static List < Database.SaveResult > addCommissionableTransactionsFromKPI(Map < Id, CORE_OPPTY_KPI_NEW__C > oldOPKPIMap,
        List < CORE_OPPTY_KPI_NEW__C > newOPKPIList, Boolean isInsert, Boolean isUpdate) {
        List < Database.SaveResult > srList = new List < Database.SaveResult > ();
        try {
            if (!alreadyAddedCommissionableTransactions) {
                Boolean commSwitchForNOKPIOTM = TriggerHandler.isActive('Core_Commission_NO_KPI_OTM_Changes');
                Boolean commSwitchForPartialChange = TriggerHandler.isActive('Core_Commission_Partial_Change');
                List < CORE_OPPTY_KPI_NEW__C > recordsToUpdate = new List < CORE_OPPTY_KPI_NEW__C > ();
                List < Core_Log_Entry__c > logEntries = new List < Core_Log_Entry__c > ();
                //KPI Mapping from Custom Setting      
                Date startvalue = Date.valueOf(System.Label.Core_Commission_Start_Date);
                DateTime commissionCutoff = getCommissionCutoff();
                DateTime transactionTimeStamp = System.now();
                DateTime transactionTimeStampWithDelay = System.now().addSeconds(Integer.ValueOf(System.Label.Core_Commission_Delay_Time));
                List < Core_Commission_KPI_Mappings__c > listFunctionalityNameKPIMappings = Core_Commission_KPI_Mappings__c.getAll().values();
                Map < String, Core_Commission_KPI_Mappings__c > mapActiveFunctionalityNameKPIMappings = new Map < String, Core_Commission_KPI_Mappings__c > ();
                Map < String, Core_Commission_KPI_Mappings__c > prodWinKPIMap = new Map < String, Core_Commission_KPI_Mappings__c > ();
                for (Core_Commission_KPI_Mappings__c kpiMap: listFunctionalityNameKPIMappings) {
                    if (kpiMap.Core_IsActive__c) {
                        mapActiveFunctionalityNameKPIMappings.put(kpiMap.Core_KPI_Name_Nm__c, kpiMap);
                        //TWC4767-542: Processing PW KPI for Opportunities which were submitted earlier to 2023
                        if (kpiMap.Core_KPI_Type__c == 'Production') {
                            prodWinKPIMap.put(kpiMap.Core_KPI_Name_Nm__c, kpiMap); //Name=NEX Design $,Custom setting record
                        }
                    }
                }

                List < Core_Commissionable_Transaction__c > newTxns = new List < Core_Commissionable_Transaction__c > ();
                Map < ID, List < CORE_OPPTY_KPI_NEW__C >> opportunityKPIs = new Map < ID, List < CORE_OPPTY_KPI_NEW__C > > ();
                Set < ID > userIDs = new Set < ID > ();
                Map < ID, OpportunityTeamMember > opportunityTeamMembers = new Map < ID, OpportunityTeamMember > ();
                Map < String, Core_Commissionable_Transaction__c > existingTxnsMap = new Map < String, Core_Commissionable_Transaction__c > ();
                Map < String, Core_Commissionable_Transaction__c > rejectExistingTxnsMap = new Map < String, Core_Commissionable_Transaction__c > ();
                Map < ID, List < String >> existingOppKPIMap = new Map < ID, List < String >> ();
                Map < ID, Opportunity > opportunities = new Map < ID, Opportunity > ();
                Set < CORE_OPPTY_KPI_NEW__C > approvedOPKPIs = new Set < CORE_OPPTY_KPI_NEW__C > ();
                Set < String > rejectedOPKPIs = new Set < String > ();
                Set < ID > approvedOPPs = new Set < ID > ();
                Map < ID, Opportunity > rejectedOPPs = new Map < ID, Opportunity > ();
                Set < ID > oppIdSet = new Set < ID > ();
                Map < ID, Map < String, Integer > > distinctKPIs = new Map < ID, Map < String, Integer > > ();
                Map < ID, Map < String, Integer > > distinctApprovedKPIs = new Map < ID, Map < String, Integer > > ();
                Map < String, Map < String, Double >> latestCommTransMap = new Map < String, Map < String, Double >> ();
                Boolean partialProductChange = false;
                Set<Id> parentIdsToRemove = new Set<Id>();
                List<Opportunity> updatedOppList = new List<Opportunity>();
                Map < ID, Map < String, Core_Opportunity_KPI_Batch_Detail__c > > distinctOppKPIBatch = new Map < ID, Map < String, Core_Opportunity_KPI_Batch_Detail__c > > ();
                List<Core_Opportunity_KPI_Batch_Detail__c> oppKPIBatchToDelete = new List<Core_Opportunity_KPI_Batch_Detail__c>();

                for (CORE_OPPTY_KPI_NEW__C opKPI: newOPKPIList) {
                    oppIdSet.add(opKPI.CORE_KPI_OPPORTUNITY__c);
                }

                List<Opportunity> queriedOpps = [select Id,Name,Core_Commissionable__c,core_approval_status__c,StageName,Core_Date_Submitted_for_Approval__c,Core_ProductionWin_KPI_Txt__c,Core_DesignWin_KPI_Txt__c,
                                             AccountId,Core_Opportunity_Type__c,Core_Approved_Date__c,Account.Name,CRM_Audit_Status__c,CRM_Audit_Close_Date__c,Core_Sales_Groups__c
                                             from Opportunity where Id IN: oppIdSet];
                // Pre-cutoff opportunities are excluded from all processing and updates; their KPIs are still flagged processed below.
                List<Opportunity> allOpps = new List<Opportunity>();
                for (Opportunity op : queriedOpps) {
                    if (isEligibleForCommission(op, commissionCutoff)) {
                        allOpps.add(op);
                    }
                }
                for (Core_Opportunity_KPI_Batch_Detail__c allOppKPIBatch: [SELECT ID,Core_Opportunity_ID_Txt__c,Core_Opportunity_Stage_Txt__c,Core_Opportunity_KPI_Batch_ID_Txt__c FROM Core_Opportunity_KPI_Batch_Detail__c WHERE Core_Opportunity_ID_Txt__c IN :oppIdSet
                                                                           ORDER BY Core_Opportunity_ID_Txt__c
                                                                          ]) {
                                                                              if (distinctOppKPIBatch.containsKey(allOppKPIBatch.Core_Opportunity_ID_Txt__c)) {
                                                                                  if (!distinctOppKPIBatch.get(allOppKPIBatch.Core_Opportunity_ID_Txt__c).containsKey(allOppKPIBatch.Core_Opportunity_Stage_Txt__c)) {
                                                                                      distinctOppKPIBatch.get(allOppKPIBatch.Core_Opportunity_ID_Txt__c).put(allOppKPIBatch.Core_Opportunity_Stage_Txt__c, allOppKPIBatch);
                                                                                  }
                                                                              } else {
                                                                                  distinctOppKPIBatch.put(allOppKPIBatch.Core_Opportunity_ID_Txt__c, new map < string, Core_Opportunity_KPI_Batch_Detail__c > {
                                                                                      String.valueOf(allOppKPIBatch.Core_Opportunity_Stage_Txt__c) => allOppKPIBatch
                                                                                          });
                                                                              }
                                                                          }
                for (CORE_OPPTY_KPI_NEW__C opKPI: newOPKPIList) {
                    for (Opportunity op: allOpps) {
                        if (op.Id == opKPI.CORE_KPI_OPPORTUNITY__c) {
                            if (mapActiveFunctionalityNameKPIMappings.containsKey(opKPI.Name)) {
                                if (distinctKPIs.containsKey(op.Id)) {
                                    if (distinctKPIs.get(op.Id).containsKey(opKPI.Name)) { // Key :Opp Id<NewKPI Name,Value=KPI Count
                                        Integer tempNum = distinctKPIs.get(op.Id).get(opKPI.Name);
                                        distinctKPIs.get(op.Id).put(opKPI.Name, tempNum + 1);
                                    } else {
                                        distinctKPIs.get(op.Id).put(opKPI.Name, 1);
                                    }
                                } else {
                                    distinctKPIs.put(op.Id, new map < string, Integer > {
                                        String.valueOf(opKPI.Name) => 1
                                    });
                                }

                                if ((isUpdate && opKPI.CORE_KPI_ACHIEVED__C == oldOPKPIMap.get(opKPI.Id).CORE_KPI_ACHIEVED__C &&
                                        opKPI.Core_IsActive__c == oldOPKPIMap.get(opKPI.Id).Core_IsActive__c) ||
                                    (isInsert && !opKPI.CORE_KPI_ACHIEVED__C && !opKPI.Core_IsActive__c)) {
                                    continue;
                                }
                                if ((op.Core_Commissionable__c).equalsIgnoreCase('Yes') &&
                                    ((isUpdate && (opKPI.CORE_KPI_ACHIEVED__C != oldOPKPIMap.get(opKPI.Id).CORE_KPI_ACHIEVED__C) && opKPI.CORE_KPI_ACHIEVED__C == TRUE && opKPI.Core_IsActive__c) ||
                                        (isInsert && opKPI.CORE_KPI_ACHIEVED__C && opKPI.Core_IsActive__c))) {
                                    approvedOPKPIs.add(opKPI);
                                    approvedOPPs.add(opKPI.CORE_KPI_OPPORTUNITY__c);
                                    if (distinctApprovedKPIs.containsKey(op.Id)) {
                                        if (distinctApprovedKPIs.get(op.Id).containsKey(opKPI.Name)) {
                                            Integer tempNum = distinctApprovedKPIs.get(op.Id).get(opKPI.Name);
                                            distinctApprovedKPIs.get(op.Id).put(opKPI.Name, tempNum + 1);
                                        } else {
                                            distinctApprovedKPIs.get(op.Id).put(opKPI.Name, 1);
                                        }
                                    } else {
                                        distinctApprovedKPIs.put(op.Id, new map < string, Integer > {
                                            String.valueOf(opKPI.Name) => 1
                                        });
                                    }
                                }
                            }
                            if (!opportunities.containsKey(op.Id)) {
                                opportunities.put(op.Id, op);
                            }
                        }
                    }
                    // Update the processed flag on CORE_OPPTY_KPI_NEW__C object
                    CORE_OPPTY_KPI_NEW__C processedOppKPI = new CORE_OPPTY_KPI_NEW__C(
                        Id = opKPI.Id,
                        Core_IsKPI_Processed__c = true,
                        CORE_KPI_OPPORTUNITY__c = opKPI.CORE_KPI_OPPORTUNITY__c
                    );
                    recordsToUpdate.add(processedOppKPI);
                }

                //To get not achieved and active KPI
                if (approvedOPKPIs.isEmpty()) {
                    for (CORE_OPPTY_KPI_NEW__C opKPI: newOPKPIList) {
                        for (Opportunity op: allOpps) {
                            if (op.Id == opKPI.CORE_KPI_OPPORTUNITY__c) {
                                if (isInsert && opKPI.CORE_KPI_ACHIEVED__C == FALSE && opKPI.Core_IsActive__c == TRUE &&
                                    mapActiveFunctionalityNameKPIMappings.containsKey(opKPI.Name)) {
                                    rejectedOPKPIs.add(opKPI.Name);
                                    if (!rejectedOPPs.containsKey(op.Id)) {
                                        rejectedOPPs.put(op.Id, op);
                                    }
                                }
                            }
                        }
                    }
                }

                //If we do not get any Production KPI and Design KPI on Production Lost or Production Cancelled
                if (approvedOPKPIs.isEmpty() && rejectedOPKPIs.isEmpty()) {
                    for (CORE_OPPTY_KPI_NEW__C opKPI: newOPKPIList) {
                        for (Opportunity op: allOpps) {
                            if (op.Id == opKPI.CORE_KPI_OPPORTUNITY__c) {
                                if (isInsert && opKPI.CORE_KPI_ACHIEVED__C == TRUE && opKPI.Core_IsActive__c == TRUE &&
                                    !mapActiveFunctionalityNameKPIMappings.containsKey(opKPI.Name)) {
                                    approvedOPKPIs.add(opKPI);
                                    approvedOPPs.add(opKPI.CORE_KPI_OPPORTUNITY__c);
                                }
                            }
                        }
                    }
                }

                if (!rejectedOPKPIs.isEmpty()) {
                    for (Core_Commissionable_Transaction__c txnList: [
                            SELECT Id, Core_Account_ID__c, Core_Account_Name__c, Core_Approved_Total_Price__c, Core_Claim_Date__c,
                            Core_Employee_ID__c, Core_Employee_Name__c, CRM_Last_Approved_DateTime__c, Core_Milestone_Area__c, Core_Opportunity_Name__c,
                            Core_Opportunity_Team_Member_Role__c, Core_Opportunity_Type__c, Core_Opportunity__c, Core_Percent_Contribution__c,
                            Core_Source_ID__c, Core_Status__c, Core_Transaction_Timestamp__c, Core_Transaction_Type__c, Core_WWID__c,  Core_KPI_Id__c,
                            Core_Opportunity__r.Core_DesignWin_KPI_Txt__c, Core_Opportunity__r.Core_ProductionWin_KPI_Txt__c,Core_Approved_Sales_Group__c,CRM_Team_Member_Addition_Date__c
                            FROM Core_Commissionable_Transaction__c
                            WHERE Core_Source_ID__c in: rejectedOPPs.keySet() AND Core_Milestone_Area__c in: rejectedOPKPIs AND CreatedDate >= :commissionCutoff
                            order by Core_Opportunity__c desc, createdDate desc, Core_Milestone_Area__c desc, Core_Employee_ID__c desc, Core_Status__c asc
                        ]) {
						String KPIType = mapActiveFunctionalityNameKPIMappings.get(txnList.Core_Milestone_Area__c).Core_KPI_Type__c;
                        Boolean KPIBlank = KPIType == 'Production' && txnList.Core_Opportunity__r.Core_ProductionWin_KPI_Txt__c == null ? true : KPIType != 'Production' && txnList.Core_Opportunity__r.Core_DesignWin_KPI_Txt__c == null ? true : false;
                        Boolean latestTransComm = false;
                        //distinct combination of commission records
                        String rejKPIDtls = txnList.Core_Opportunity__c + '~' + txnList.Core_Milestone_Area__c + '~' + txnList.Core_Employee_ID__c;
                        if (latestCommTransMap.get(rejKPIDtls) == null) {
                            latestCommTransMap.put(rejKPIDtls, new map < string, Double > {
                                String.valueOf(txnList.Core_Status__c) => txnList.Core_Approved_Total_Price__c
                            });
                        }
                        if (latestCommTransMap.get(rejKPIDtls) != null) {
                            if (latestCommTransMap.get(rejKPIDtls).containsKey('Approved'))
                                latestTransComm = true;
                        }
                        if (!rejectExistingTxnsMap.containsKey(rejKPIDtls) && txnList.Core_Status__c == 'Approved' &&
                            latestTransComm && KPIBlank) {
                            rejectExistingTxnsMap.put(rejKPIDtls, txnList);
                            txnList.Core_Transaction_Timestamp__c = transactionTimeStamp;
                            txnList.Core_Status__c = 'Pending';
                            txnList.Core_Approved_Transaction_Id__c = txnList.Id;
                            txnList.Id = null;
                            //Add the modified transaction to newTxn
                            newTxns.add(txnList);
                                
                                if(distinctOppKPIBatch.get(txnList.Core_Opportunity__c) != null){
                                    String KPITyp = KPIType == 'Production' ? 'Production Win' : 'Design Win';
                                    if(distinctOppKPIBatch.get(txnList.Core_Opportunity__c).containsKey(KPITyp) && !oppKPIBatchToDelete.contains(distinctOppKPIBatch.get(txnList.Core_Opportunity__c).get(KPITyp))){
                                        oppKPIBatchToDelete.add(distinctOppKPIBatch.get(txnList.Core_Opportunity__c).get(KPITyp));
                                    }
                                }
                        }
                    }
                }

                if (!approvedOPKPIs.isEmpty()) {
                    //New Opportunity KPI Records
                    for (CORE_OPPTY_KPI_NEW__C okpi: [SELECT ID, CORE_KPI_OPPORTUNITY__C, NAME, CORE_OPP_KPI_PRODUCT__R.CORE_INF_KPI_PRODGROUP__C,CORE_ISACTIVE__C,CORE_KPI_ACHIEVED__C,Core_Opportunity_KPI_Batch_ID__c,
                            CORE_KPI_TOTAL_PRICE__C, Core_KPI_Quantity__c, Core_Opportunity_Product__r.Core_Claim_Date__c, Core_Opportunity_Product__r.Core_Production_Claim_Date__c
                            FROM CORE_OPPTY_KPI_NEW__C WHERE CORE_KPI_ACHIEVED__C = TRUE
                            AND CORE_ISACTIVE__C = TRUE AND
                            //TWC4767-542: Processing PW KPI for Opportunities which were submitted earlier to 2023
                            ((Core_Opportunity_Product__r.Core_Claim_Date__c >=: startvalue AND Core_KPI_Opportunity__r.StageName = 'Design Win') OR NAME in: prodWinKPIMap.keyset())
                            AND Core_KPI_Opportunity__c in: approvedOPPs AND NAME in: mapActiveFunctionalityNameKPIMappings.keySet()
                            ORDER BY CORE_KPI_OPPORTUNITY__C
                        ]) {
                        if (opportunityKPIs.get(okpi.CORE_KPI_OPPORTUNITY__C) != null) {
                            List < CORE_OPPTY_KPI_NEW__C > existingKPIThisOpp = opportunityKPIs.get(okpi.CORE_KPI_OPPORTUNITY__C);
                            existingKPIThisOpp.add(okpi);
                            opportunityKPIs.put(okpi.CORE_KPI_OPPORTUNITY__C, existingKPIThisOpp);
                            List < String > existingOppThisKPI = existingOppKPIMap.get(okpi.CORE_KPI_OPPORTUNITY__C);
                            if (!existingOppThisKPI.contains(okpi.Name)) {
                                existingOppThisKPI.add(okpi.Name);
                                existingOppKPIMap.put(okpi.CORE_KPI_OPPORTUNITY__C, existingOppThisKPI);
                            }
                        } else {
                            opportunityKPIs.put(okpi.CORE_KPI_OPPORTUNITY__C, new List < CORE_OPPTY_KPI_NEW__C > {
                                okpi
                            });
                            existingOppKPIMap.put(okpi.CORE_KPI_OPPORTUNITY__C, new List < String > {
                                okpi.Name
                            });
                        }
                    }

                    //Generate an Opportunity Team Member map based on keys of the Opportunity map                   
                    for (OpportunityTeamMember otm: [SELECT o.ID, o.TeamMemberRole, o.Core_Production_Win_Member_Role__c, o.UserId, o.OpportunityId, o.CreatedDate,o.User.Core_Employee_Type_Code__c,o.User.IsActive,o.User.Name,o.User.Core_WWID__c  
                                                     FROM OpportunityTeamMember o WHERE o.OpportunityId in: approvedOPPs]) {
                        opportunityTeamMembers.put(otm.ID, otm);
                    }

                    //Existing Commission records
                    for (Core_Commissionable_Transaction__c commTxn: [SELECT Id, Core_Account_ID__c, Core_Account_Name__c, Core_Approved_Total_Price__c, Core_Claim_Date__c,
                            Core_Employee_ID__c, Core_Employee_Name__c, CRM_Last_Approved_DateTime__c, Core_Milestone_Area__c, Core_Opportunity_Name__c,
                            Core_Opportunity_Team_Member_Role__c, Core_Opportunity_Type__c, Core_Opportunity__c, Core_Percent_Contribution__c,
                            Core_Source_ID__c, Core_Status__c, Core_Transaction_Timestamp__c,
                            Core_Transaction_Type__c, Core_WWID__c, Core_KPI_Id__c,Core_Approved_Sales_Group__c,CRM_Team_Member_Addition_Date__c
                            FROM Core_Commissionable_Transaction__c WHERE Core_Opportunity__c in: approvedOPPs AND(Core_Opportunity__r.Core_Date_Submitted_for_Approval__c >=: startvalue OR(Core_Opportunity__r.Core_Date_Submitted_for_Approval__c <=: startvalue AND Core_Opportunity__r.StageName = 'Production Win'))
                            AND Core_Milestone_Area__c in: mapActiveFunctionalityNameKPIMappings.keySet()
                            AND CreatedDate >= :commissionCutoff
                            ORDER BY Core_Opportunity__c desc, createdDate desc, Core_Milestone_Area__c desc, Core_Employee_ID__c desc, Core_Status__c asc
                        ]) {
                            Boolean KPIExists = true;
                            Boolean latestPendingTransComm = false;
                            String KPIDtls = commTxn.Core_Opportunity__c + '~' + commTxn.Core_Milestone_Area__c + '~' + commTxn.Core_Employee_ID__c;
                            if (latestCommTransMap.get(KPIDtls) == null) {
                                latestCommTransMap.put(KPIDtls, new map < string, Double > {
                                    String.valueOf(commTxn.Core_Status__c) => commTxn.Core_Approved_Total_Price__c
                                        });
                            }
                            if (latestCommTransMap.get(KPIDtls) != null) {
                                if (latestCommTransMap.get(KPIDtls).containsKey('Approved'))
                                    latestPendingTransComm = true;
                            }
                            if(commSwitchForNOKPIOTM){                                
                                String KPIType = mapActiveFunctionalityNameKPIMappings.get(commTxn.Core_Milestone_Area__c).Core_KPI_Type__c;
                                Boolean isProdKPIForNoKPI = opportunities.get(commTxn.Core_Opportunity__c).StageName != 'Production Win' && KPIType == 'Production';
                                List<String> stringPWKPIList = opportunities.get(commTxn.Core_Opportunity__c).Core_ProductionWin_KPI_Txt__c != null ? opportunities.get(commTxn.Core_Opportunity__c).Core_ProductionWin_KPI_Txt__c.split(',') : null;
                                if (!existingTxnsMap.containsKey(KPIDtls) && commTxn.Core_Status__c == 'Approved' && latestPendingTransComm) {
                                    existingTxnsMap.put(KPIDtls, commTxn);
                                    //if already approved commission KPI is not coming as part of latest batch then update it to Pending
                                    if (existingOppKPIMap.get(commTxn.Core_Opportunity__c) == null) {
                                        KPIExists = false;
                                    } else if (!existingOppKPIMap.get(commTxn.Core_Opportunity__c).contains(commTxn.Core_Milestone_Area__c)) {
                                        KPIExists = false;
                                    }
                                    if (!KPIExists && isProdKPIForNoKPI) {
                                        commTxn.Core_Transaction_Timestamp__c = transactionTimeStamp;
                                        commTxn.Core_Status__c = 'Pending';
                                        commTxn.Core_Approved_Transaction_Id__c = commTxn.Id;
                                        commTxn.Id = null;
                                        //Add the modified transaction to newTxn
                                        newTxns.add(commTxn);
                                        
                                        if(distinctOppKPIBatch.get(commTxn.Core_Opportunity__c) != null){
                                            String KPITyp = KPIType == 'Production' ? 'Production Win' : 'Design Win';
                                            if(distinctOppKPIBatch.get(commTxn.Core_Opportunity__c).containsKey(KPITyp) && !oppKPIBatchToDelete.contains(distinctOppKPIBatch.get(commTxn.Core_Opportunity__c).get(KPITyp))){
                                                oppKPIBatchToDelete.add(distinctOppKPIBatch.get(commTxn.Core_Opportunity__c).get(KPITyp));
                                            }
                                        }
                                    }
                                }
                                if(!KPIExists && isProdKPIForNoKPI && stringPWKPIList != null){
                                    List<String> newListKPI = new List<String>();
                                    if(stringPWKPIList.contains(commTxn.Core_Milestone_Area__c)){                                    
                                        for (String strPW : stringPWKPIList) {
                                            if (strPW != commTxn.Core_Milestone_Area__c) {
                                                newListKPI.add(strPW);
                                            }
                                        }
                                        opportunities.get(commTxn.Core_Opportunity__c).Core_ProductionWin_KPI_Txt__c = String.join(newListKPI, ',');
                                    }
                                }
                            }
                            
                    }

                    Map < Id, Map < String, Double >> MapKPIValues = new Map < Id, Map < String, Double >> ();
                    Map < Id, Map < String, DateTime >> MapKPIClaimDateValues = new Map < Id, Map < String, DateTime >> ();
                    Map < Id, Map < String, DateTime >> MapDWKPIClaimDateValues = new Map < Id, Map < String, DateTime >> ();
                    Core_Commissionable_Transaction__c txn;
                    for (Id approvedOP: opportunities.keySet()) {
                        List < String > allDesignKPIForOpp = new List < String > ();
                        List < String > allProdKPIForOpp = new List < String > ();
                        MapKPIValues.put(approvedOP, new map < string, Double > ());
                        MapKPIClaimDateValues.put(approvedOP, new map < string, DateTime > ());
                        MapDWKPIClaimDateValues.put(approvedOP, new map < string, DateTime > ());
                        Map < String, Set < String > > MapProdGroup = new Map < String, Set < String > > ();
                        if (opportunityKPIs.get(approvedOP) != null) {
                            if(opportunities.get(approvedOP).Core_Commissionable__c == 'Yes'){
                                String stringDesignWinKPIList = opportunities.get(approvedOP).Core_DesignWin_KPI_Txt__c;
                                String stringProdWinKPIList = opportunities.get(approvedOP).Core_ProductionWin_KPI_Txt__c;
                                for (CORE_OPPTY_KPI_NEW__C kpi: opportunityKPIs.get(approvedOP)) {
                                    Boolean validKPIBatch = false;
                                    if(distinctOppKPIBatch.get(approvedOP) != null){
                                        if(distinctOppKPIBatch.get(approvedOP).get(opportunities.get(approvedOP).StageName) != null){
                                            if(distinctOppKPIBatch.get(approvedOP).get(opportunities.get(approvedOP).StageName).Core_Opportunity_KPI_Batch_ID_Txt__c == kpi.Core_Opportunity_KPI_Batch_ID__c){
                                                validKPIBatch = true;
                                            }
                                        }else if(distinctOppKPIBatch.get(approvedOP).get(opportunities.get(approvedOP).StageName) == null && (opportunities.get(approvedOP).StageName == 'Production Win' || opportunities.get(approvedOP).StageName == 'Design Win')){
                                            validKPIBatch = true;
                                        }
                                    }else{
                                        validKPIBatch = true;
                                    }
                                    if (mapActiveFunctionalityNameKPIMappings.get(kpi.Name) != null && validKPIBatch) {
                                        if (opportunities.get(approvedOP).StageName == 'Production Win' && mapActiveFunctionalityNameKPIMappings.get(kpi.Name).Core_KPI_Type__c == 'Production') {
                                            if (MapKPIClaimDateValues.get(approvedOP).containsKey(kpi.Name)) {
                                                DateTime prodClaimDate = kpi.Core_Opportunity_Product__r.Core_Production_Claim_Date__c;
                                                if (MapKPIClaimDateValues.get(approvedOP).get(kpi.Name) != null && prodClaimDate > MapKPIClaimDateValues.get(approvedOP).get(kpi.Name)) {
                                                    MapKPIClaimDateValues.get(approvedOP).put(kpi.Name, prodClaimDate);
                                                }
                                            } else {
                                                MapKPIClaimDateValues.get(approvedOP).put(kpi.Name, kpi.Core_Opportunity_Product__r.Core_Production_Claim_Date__c);
                                            }
                                        } else {
                                            if (MapDWKPIClaimDateValues.get(approvedOP).containsKey(kpi.Name)) {
                                                DateTime dwClaimDate = kpi.Core_Opportunity_Product__r.Core_Claim_Date__c;
                                                if (MapDWKPIClaimDateValues.get(approvedOP).get(kpi.Name) != null && dwClaimDate > MapDWKPIClaimDateValues.get(approvedOP).get(kpi.Name)) {
                                                    MapDWKPIClaimDateValues.get(approvedOP).put(kpi.Name, dwClaimDate);
                                                }
                                            } else {
                                                MapDWKPIClaimDateValues.get(approvedOP).put(kpi.Name, kpi.Core_Opportunity_Product__r.Core_Claim_Date__c);
                                            }
                                        }
                                        if (mapActiveFunctionalityNameKPIMappings.get(kpi.Name).Core_Aggregate_Type__c == 'SUM') {
                                            String kpi_field_val = mapActiveFunctionalityNameKPIMappings.get(kpi.Name).Core_KPI_Field__c;
                                            if (MapKPIValues.get(approvedOP).containsKey(kpi.Name)) {
                                                Double tempRevenue = MapKPIValues.get(approvedOP).get(kpi.Name);
                                                MapKPIValues.get(approvedOP).put(kpi.Name, tempRevenue + (double) kpi.get(kpi_field_val));
                                            } else {
                                                
                                                MapKPIValues.get(approvedOP).put(kpi.Name, (double) kpi.get(kpi_field_val));
                                            }
                                        } else if (mapActiveFunctionalityNameKPIMappings.get(kpi.Name).Core_Aggregate_Type__c == 'Unique' &&
                                                   kpi.CORE_OPP_KPI_PRODUCT__R.CORE_INF_KPI_PRODGROUP__C != 'Not Applicable' &&
                                                   kpi.CORE_OPP_KPI_PRODUCT__R.CORE_INF_KPI_PRODGROUP__C != null) {
                                                       if (MapKPIValues.get(approvedOP).containsKey(kpi.Name)) {
                                                           if (!MapProdGroup.get(kpi.Name).contains(kpi.CORE_OPP_KPI_PRODUCT__R.CORE_INF_KPI_PRODGROUP__C)) {
                                                               MapProdGroup.get(kpi.Name).add(kpi.CORE_OPP_KPI_PRODUCT__R.CORE_INF_KPI_PRODGROUP__C);
                                                               Double tempRevenue = MapKPIValues.get(approvedOP).get(kpi.Name);
                                                               MapKPIValues.get(approvedOP).put(kpi.Name, tempRevenue + 1);
                                                           }
                                                       } else {
                                                           MapProdGroup.put(kpi.Name, new Set < String > {
                                                               kpi.CORE_OPP_KPI_PRODUCT__R.CORE_INF_KPI_PRODGROUP__C
                                                                   });
                                                           MapKPIValues.get(approvedOP).put(kpi.Name, 1);
                                                       }
                                                   } else if (mapActiveFunctionalityNameKPIMappings.get(kpi.Name).Core_Aggregate_Type__c == 'Count') {
                                                       if (!MapKPIValues.get(approvedOP).containsKey(kpi.Name)) {
                                                           MapKPIValues.get(approvedOP).put(kpi.name, 1);
                                                       }
                                                   }
                                    }
                                }                            
                                for (ID otmID: opportunityTeamMembers.keySet()) {
                                    OpportunityTeamMember otm = opportunityTeamMembers.get(otmId);
                                    if (otm.OpportunityId == approvedOP &&
                                        otm.User.Core_Employee_Type_Code__c == 'EMP' ) {
                                            Map < String, Double > MapTempKPI = MapKPIValues.get(approvedOP);
                                            Map < String, DateTime > MapTempKPIClaimDate = MapKPIClaimDateValues.get(approvedOP);
                                            Map < String, DateTime > MapTempDWKPIClaimDate = MapDWKPIClaimDateValues.get(approvedOP);
                                            for (String k: MapTempKPI.keySet()) {
                                                Boolean isProdKPI = opportunities.get(approvedOP).StageName == 'Production Win' && mapActiveFunctionalityNameKPIMappings.get(k).Core_KPI_Type__c == 'Production';
                                                if((!isProdKPI && Core_Commissions_Percent_Contribution__c.getInstance(otm.TeamMemberRole) != null) ||
                                                   (isProdKPI && Core_Commissions_Percent_Contribution__c.getInstance(otm.Core_Production_Win_Member_Role__c) != null)){
                                                       Boolean kpiExist = false;
                                                       Boolean isBlankKPI = true;                                            
                                                       if(mapActiveFunctionalityNameKPIMappings.get(k).Core_KPI_Type__c != 'Production' && String.isNotBlank(stringDesignWinKPIList)){
                                                           if(stringDesignWinKPIList.contains(k)){
                                                               kpiExist = true;
                                                           }
                                                       } else if(mapActiveFunctionalityNameKPIMappings.get(k).Core_KPI_Type__c == 'Production' && String.isNotBlank(stringProdWinKPIList)){
                                                           if(stringProdWinKPIList.contains(k)){
                                                               kpiExist = true;
                                                           }
                                                       }                                           
                                                       partialProductChange = false;
                                                       Boolean latestTransComm = false;
                                                       txn = new Core_Commissionable_Transaction__c();
                                                       Double value = Decimal.valueOf(MapTempKPI.get(k)).setScale(2, System.RoundingMode.HALF_UP);
                                                       
                                                       String KPIName = mapActiveFunctionalityNameKPIMappings.get(k).Core_KPI_Name_Nm__c;
                                                       String extKPI = approvedOP + '~' + KPIName + '~' + otm.UserId;
                                                       Boolean validOTMByDate = isProdKPI && MapTempKPIClaimDate.get(k) >= otm.CreatedDate ? true : !isProdKPI && MapTempDWKPIClaimDate.get(k) >= otm.CreatedDate ? true : false;
                                                       if( (isProdKPI && String.isNotBlank(stringProdWinKPIList)) || (!isProdKPI && String.isNotBlank(stringDesignWinKPIList)) ){
                                                           isBlankKPI = false;
                                                       }
                                                       if (((distinctApprovedKPIs.get(approvedOP).get(KPIName) < distinctKPIs.get(approvedOP).get(KPIName)) ||
                                                            (distinctApprovedKPIs.get(approvedOP).get(KPIName) == distinctKPIs.get(approvedOP).get(KPIName))) &&
                                                           existingTxnsMap.containsKey(extKPI) && existingTxnsMap.get(extKPI).Core_Approved_Total_Price__c.setScale(2, System.RoundingMode.HALF_UP) != value) {
                                                               partialProductChange = true;
                                                           }
                                                       if (latestCommTransMap.get(extKPI) != null) {
                                                           if (latestCommTransMap.get(extKPI).containsKey('Approved'))
                                                               latestTransComm = true;
                                                       }
                                                      
                                                       if (commSwitchForPartialChange && existingTxnsMap.containsKey(extKPI) &&
                                                           existingTxnsMap.get(extKPI).Core_Approved_Total_Price__c.setScale(2, System.RoundingMode.HALF_UP) != value && partialProductChange && latestTransComm) {
                                                               if (Decimal.valueOf(latestCommTransMap.get(extKPI).get('Approved')).setScale(2, System.RoundingMode.HALF_UP) != value && kpiExist) {
                                                                   Core_Commissionable_Transaction__c txn1 = new Core_Commissionable_Transaction__c();
                                                                   txn1 = existingTxnsMap.get(extKPI).clone(false, true, false, false);
                                                                   txn1.Core_Transaction_Timestamp__c = transactionTimeStamp;
                                                                   txn1.Core_Status__c = 'Pending';
                                                                   txn1.Core_Approved_Transaction_Id__c = existingTxnsMap.get(extKPI).Id;
                                                                   txn1.Id = null;
                                                                   newTxns.add(txn1);
                                                                   
                                                                   if (value > 0 && validOTMByDate) {
                                                                       Core_Commissionable_Transaction__c txn2 = new Core_Commissionable_Transaction__c();
                                                                       txn2 = existingTxnsMap.get(extKPI).clone(false, true, false, false);
                                                                       txn2.Core_Transaction_Timestamp__c = transactionTimeStampWithDelay;
                                                                       txn2.Core_Status__c = 'Approved';
                                                                       txn2.Core_Approved_Total_Price__c = value;
                                                                       txn2.Core_Claim_Date__c = isProdKPI ? MapTempKPIClaimDate.get(k).date() : MapTempDWKPIClaimDate.get(k).date();
                                                                       txn2.Id = null;
                                                                       newTxns.add(txn2);
                                                                   }
                                                               }
                                                           } else if (!partialProductChange && value > 0 && !latestTransComm && !kpiExist && isBlankKPI && validOTMByDate) {
                                                               txn.Core_Employee_ID__c = otm.UserId;
                                                               txn.Core_Employee_Name__c = otm.User.Name;
                                                               txn.Core_WWID__c = otm.User.Core_WWID__c;
                                                               if(isProdKPI){
                                                                   txn.Core_Opportunity_Team_Member_Role__c = Core_Commissions_Percent_Contribution__c.getInstance(otm.Core_Production_Win_Member_Role__c).API_Value__c;
                                                                   txn.Core_Percent_Contribution__c = Core_Commissions_Percent_Contribution__c.getInstance(otm.Core_Production_Win_Member_Role__c).Core_Percent_Contribution__c;
                                                               }
                                                               else{
                                                                   txn.Core_Opportunity_Team_Member_Role__c = Core_Commissions_Percent_Contribution__c.getInstance(otm.TeamMemberRole).API_Value__c;
                                                                   txn.Core_Percent_Contribution__c = Core_Commissions_Percent_Contribution__c.getInstance(otm.TeamMemberRole).Core_Percent_Contribution__c;
                                                               }
                                                               
                                                               txn.Core_Source_ID__c = approvedOP;
                                                               txn.Core_Transaction_Timestamp__c = transactionTimeStampWithDelay;
                                                               txn.Core_Account_ID__c = opportunities.get(approvedOP).AccountId;
                                                               txn.Core_Account_Name__c = opportunities.get(approvedOP).Account.Name;
                                                              // txn.Core_CIM_ID__c = opportunities.get(approvedOP).Account.Core_CIM_ID__c;
                                                               txn.Core_Claim_Date__c = isProdKPI ? MapTempKPIClaimDate.get(k).date() : MapTempDWKPIClaimDate.get(k).date();
                                                               if (opportunities.get(approvedOP).Core_Approved_Date__c == null) {
                                                                   //in production, we always expect this code to run -- when a product is newly approved, the approved date usually gets populated after this
                                                                   txn.CRM_Last_Approved_DateTime__c = transactionTimeStamp;
                                                               } else {
                                                                   //in case of manual data updates, this code may need to run instead
                                                                   txn.CRM_Last_Approved_DateTime__c = opportunities.get(approvedOP).Core_Approved_Date__c;
                                                               }
                                                               txn.Core_Status__c = Label.Core_Commissionable_Transaction_Approved_Status;
                                                               txn.Core_Opportunity__c = approvedOP;
                                                               txn.Core_Opportunity_Name__c = opportunities.get(approvedOP).Name;
                                                               txn.Core_Opportunity_Type__c = opportunities.get(approvedOP).Core_Opportunity_Type__c;
                                                              /*if (opportunities.get(approvedOP).CRM_Unified_Global_Customer_Name__c!= null) {
                                                                   txn.Core_Approved_Prime_AccountName__c = opportunities.get(approvedOP).CRM_Unified_Global_Customer_Name__c;
                                                               }*/
                                                               txn.Core_Milestone_Area__c = KPIName;
                                                               txn.Core_KPI_Id__c = mapActiveFunctionalityNameKPIMappings.get(k).Core_KPI_Id__c;
                                                               txn.Core_Approved_Total_Price__c = value;
                                                               txn.Core_Transaction_Type__c = mapActiveFunctionalityNameKPIMappings.get(k).Core_Event_Type__c;
                                                               txn.CRM_Audit_Status_Txt__c = opportunities.get(approvedOP).CRM_Audit_Status__c;
                                                               txn.CRM_Audit_Close_Date__c = opportunities.get(approvedOP).CRM_Audit_Close_Date__c;
                                                               txn.Core_Approved_Sales_Group__c = opportunities.get(approvedOP).Core_Sales_Groups__c;
                                                               txn.CRM_Team_Member_Addition_Date__c = otm.CreatedDate;
                                                               newTxns.add(txn);
                                                               if (isProdKPI && !allProdKPIForOpp.contains(KPIName)) {
                                                                   allProdKPIForOpp.add(KPIName);
                                                               } else if(!isProdKPI && !allDesignKPIForOpp.contains(KPIName)){
                                                                   allDesignKPIForOpp.add(KPIName);
                                                               }
                                                           }
                                                   }
                                            }
                                        }//371
                                } //359
                                opportunities.get(approvedOP).Core_DesignWin_KPI_Txt__c = stringDesignWinKPIList == null ? String.join(allDesignKPIForOpp, ',') : stringDesignWinKPIList; 
                                opportunities.get(approvedOP).Core_ProductionWin_KPI_Txt__c = stringProdWinKPIList == null ? String.join(allProdKPIForOpp, ',') : stringProdWinKPIList;  
                            }//320
                            
                        } //319
                    } //312
                }//206


                if (newTxns.size() > 0) {
                    alreadyAddedCommissionableTransactions = true;
                    srList = Database.insert(newTxns, /*allorNone*/ false);
                }
                if (oppKPIBatchToDelete.size() > 0) {
                    Database.delete(oppKPIBatchToDelete, /*allorNone*/ false);
                }
                //insert into log table for failed records and remove from recordsToUpdate list
                if (!srList.isEmpty()) {
                    // Iterate through the results
                    for (Integer i = 0; i < srList.size(); i++) {
                        // Check if there was an error for the current record
                        if (!srList[i].isSuccess() || Test.isRunningTest()) {
                            for (Database.Error err: srList[i].getErrors()) {
                                logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = 'CommissionCreation', Core_Severity__c = 'Info', Core_When__c = System.Now(), Core_Project__c = 'Sales'));
                            }
                            for (Integer j = recordsToUpdate.size() - 1; j >= 0; j--) {
                                Id oppId = newTxns[i].Core_Opportunity__c;
                                if (recordsToUpdate[j].CORE_KPI_OPPORTUNITY__c == oppId) {
                                    recordsToUpdate.remove(j);
                                    parentIdsToRemove.add(oppId);
                                }                                
                            }
                        }
                    }
                }

                if (!allOpps.isEmpty()) {
                    for (Opportunity parent : allOpps) {
                        if (!parentIdsToRemove.contains(parent.Id)) {
                            updatedOppList.add(parent);
                        }
                    }
                    Database.update(updatedOppList, /*allorNone*/ false);
                }
                
                if (!logEntries.isEmpty()) {
                    Database.insert(logEntries, /*allorNone*/ false);
                }

                if (!recordsToUpdate.isEmpty()) {
                    Database.update(recordsToUpdate, /*allorNone*/ false);
                }
            }
            return srList;
        }
        Catch(Exception ex) {
            Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = ex.getMessage(), Core_Origin__c = 'CommissionCreation', Core_Severity__c = 'Info', Core_When__c = System.Now(), Core_Project__c = 'Sales', Core_Details__c = 'Line number:' + ex.getLineNumber() + ', Stack trace: ' + ex.getStackTraceString());
            insert ExcepLog; return new List < Database.SaveResult > ();
        }
    }

    public static void updateKPIProcessFlag(List < Core_Oppty_KPI_New__c > kPIList) {
        List < Core_Oppty_KPI_New__c > toBeUpdated = new List < Core_Oppty_KPI_New__c > ();
        try {
            if (kPIList.size() > 0) {
                for (Core_Oppty_KPI_New__c kpi: kPIList) {
                    Core_Oppty_KPI_New__c kpiRec = new Core_Oppty_KPI_New__c(Id = kpi.id, Core_IsKPI_Processed__c = true);
                    toBeUpdated.add(kpiRec);
                }
                if (toBeUpdated.size() > 0) {
                    List < Database.SaveResult > srList = Database.update(toBeUpdated, false);
                }
            }
        }
        Catch(Exception ex) {
            PMP_Utility.logError(ex, 'Core_CommissionableTransactions.updateKPIProcessFlag');
        }
    }

    public static void processOpportunityWithNoKPI(Set < Id > OppIdList) {
        try {
            List < Database.SaveResult > srList = new List < Database.SaveResult > ();
            List < Core_Log_Entry__c > logEntries = new List < Core_Log_Entry__c > ();
            List < Core_Commission_KPI_Mappings__c > listFunctionalityNameKPIMappings = Core_Commission_KPI_Mappings__c.getAll().values();
            Map < String, Core_Commission_KPI_Mappings__c > mapActiveFunctionalityNameKPIMappings = new Map < String, Core_Commission_KPI_Mappings__c > ();
            Map < String, Map < String, Double >> latestCommTransMap = new Map < String, Map < String, Double >> ();
            Map < String, Core_Commissionable_Transaction__c > rejectExistingTxnsMap = new Map < String, Core_Commissionable_Transaction__c > ();
            List < Core_Commissionable_Transaction__c > newTxns = new List < Core_Commissionable_Transaction__c > ();
            Map < ID, Map < String, Core_Opportunity_KPI_Batch_Detail__c > > distinctOppKPIBatch = new Map < ID, Map < String, Core_Opportunity_KPI_Batch_Detail__c > > ();
            List<Core_Opportunity_KPI_Batch_Detail__c> oppKPIBatchToDelete = new List<Core_Opportunity_KPI_Batch_Detail__c>();
            for (Core_Commission_KPI_Mappings__c kpiMap: listFunctionalityNameKPIMappings) {
                if (kpiMap.Core_IsActive__c) {
                    mapActiveFunctionalityNameKPIMappings.put(kpiMap.Core_KPI_Name_Nm__c, kpiMap);
                }
            }

            // Approved date is blanked on reversal, so gate on transaction CreatedDate instead.
            DateTime commissionCutoff = getCommissionCutoff();
            if (!OppIdList.isEmpty()) {
                for (Core_Opportunity_KPI_Batch_Detail__c allOppKPIBatch: [SELECT ID,Core_Opportunity_ID_Txt__c,Core_Opportunity_Stage_Txt__c,Core_Opportunity_KPI_Batch_ID_Txt__c FROM Core_Opportunity_KPI_Batch_Detail__c WHERE Core_Opportunity_ID_Txt__c IN :OppIdList
                                                                           ORDER BY Core_Opportunity_ID_Txt__c
                                                                          ]) {
                                                                              if (distinctOppKPIBatch.containsKey(allOppKPIBatch.Core_Opportunity_ID_Txt__c)) {
                                                                                  if (!distinctOppKPIBatch.get(allOppKPIBatch.Core_Opportunity_ID_Txt__c).containsKey(allOppKPIBatch.Core_Opportunity_Stage_Txt__c)) {
                                                                                      distinctOppKPIBatch.get(allOppKPIBatch.Core_Opportunity_ID_Txt__c).put(allOppKPIBatch.Core_Opportunity_Stage_Txt__c, allOppKPIBatch);
                                                                                  }
                                                                              } else {
                                                                                  distinctOppKPIBatch.put(allOppKPIBatch.Core_Opportunity_ID_Txt__c, new map < string, Core_Opportunity_KPI_Batch_Detail__c > {
                                                                                      String.valueOf(allOppKPIBatch.Core_Opportunity_Stage_Txt__c) => allOppKPIBatch
                                                                                          });
                                                                              }
                                                                          }
                for (Core_Commissionable_Transaction__c txnList: [
                        SELECT Id, Core_Account_ID__c, Core_Account_Name__c, Core_Approved_Total_Price__c, Core_Claim_Date__c,
                        Core_Employee_ID__c, Core_Employee_Name__c, CRM_Last_Approved_DateTime__c, Core_Milestone_Area__c, Core_Opportunity_Name__c,
                        Core_Opportunity_Team_Member_Role__c, Core_Opportunity_Type__c, Core_Opportunity__c, Core_Percent_Contribution__c,
                        Core_Source_ID__c, Core_Status__c, Core_Transaction_Timestamp__c, Core_Transaction_Type__c, Core_WWID__c, Core_KPI_Id__c,
                        Core_Opportunity__r.Core_DesignWin_KPI_Txt__c, Core_Opportunity__r.Core_ProductionWin_KPI_Txt__c,Core_Approved_Sales_Group__c,CRM_Team_Member_Addition_Date__c
                        FROM Core_Commissionable_Transaction__c
                        WHERE Core_Source_ID__c in: OppIdList AND Core_Milestone_Area__c in: mapActiveFunctionalityNameKPIMappings.keySet() AND CreatedDate >= :commissionCutoff
                        order by Core_Opportunity__c desc, createdDate desc, Core_Milestone_Area__c desc, Core_Employee_ID__c desc, Core_Status__c asc
                    ]) {
                        String KPIType = mapActiveFunctionalityNameKPIMappings.get(txnList.Core_Milestone_Area__c).Core_KPI_Type__c;
                        Boolean KPIBlank = KPIType == 'Production' && txnList.Core_Opportunity__r.Core_ProductionWin_KPI_Txt__c == null ? true : KPIType != 'Production' && txnList.Core_Opportunity__r.Core_DesignWin_KPI_Txt__c == null ? true : false;
                    Boolean latestTransComm = false;
                    //distinct combination of commission records
                    String rejKPIDtls = txnList.Core_Opportunity__c + '~' + txnList.Core_Milestone_Area__c + '~' + txnList.Core_Employee_ID__c;
                    if (latestCommTransMap.get(rejKPIDtls) == null) {
                        latestCommTransMap.put(rejKPIDtls, new map < string, Double > {
                            String.valueOf(txnList.Core_Status__c) => txnList.Core_Approved_Total_Price__c
                        });
                    }
                    if (latestCommTransMap.get(rejKPIDtls) != null) {
                        if (latestCommTransMap.get(rejKPIDtls).containsKey('Approved'))
                            latestTransComm = true;
                    }
                    if (!rejectExistingTxnsMap.containsKey(rejKPIDtls) && txnList.Core_Status__c == 'Approved' &&
                        latestTransComm && KPIBlank) {
                        rejectExistingTxnsMap.put(rejKPIDtls, txnList);
                        txnList.Core_Transaction_Timestamp__c = System.now();
                        txnList.Core_Status__c = 'Pending';
                        txnList.Core_Approved_Transaction_Id__c = txnList.Id;
                        txnList.Id = null;
                        //Add the modified transaction to newTxn
                        newTxns.add(txnList);
                            
                            if(distinctOppKPIBatch.get(txnList.Core_Opportunity__c) != null){
                                String KPITyp = KPIType == 'Production' ? 'Production Win' : 'Design Win';
                                if(distinctOppKPIBatch.get(txnList.Core_Opportunity__c).containsKey(KPITyp) && !oppKPIBatchToDelete.contains(distinctOppKPIBatch.get(txnList.Core_Opportunity__c).get(KPITyp))){
                                    oppKPIBatchToDelete.add(distinctOppKPIBatch.get(txnList.Core_Opportunity__c).get(KPITyp));
                                }
                            }
                    }
                }
            }
            if (newTxns.size() > 0) {
                srList = Database.insert(newTxns, /*allorNone*/ false);
            }
            if (oppKPIBatchToDelete.size() > 0) {
                Database.delete(oppKPIBatchToDelete, /*allorNone*/ false);
            }
            //insert into log table for failed records
            if (!srList.isEmpty()) {
                // Iterate through the results
                for (Integer i = 0; i < srList.size(); i++) {
                    // Check if there was an error for the current record
                    if (!srList[i].isSuccess() || Test.isRunningTest()) {
                        for (Database.Error err: srList[i].getErrors()) {
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(), Core_Origin__c = 'CommissionCreationNoKPI', Core_Severity__c = 'Info', Core_When__c = System.Now(), Core_Project__c = 'Sales'));
                        }
                    }
                }
            }

            if (!logEntries.isEmpty()) {
                insert logEntries;
            }

        }
        Catch(Exception ex) {
            Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = ex.getMessage(), Core_Origin__c = 'CommissionCreationNoKPI', Core_Severity__c = 'Info', Core_When__c = System.Now(), Core_Project__c = 'Sales', Core_Details__c = 'Line number:' + ex.getLineNumber() + ', Stack trace: ' + ex.getStackTraceString());
            insert ExcepLog;
        }
    }

    @InvocableMethod(label = 'processOppOnReversal' description = 'Create Pending Commssion records on Reversal')
    public static void processOpportunityOnReversal(List < Id > OppIdList) {
        if (OppIdList.size() > 0) {
            Set < Id > oppSet = new Set < Id > (OppIdList);
            processOpportunityWithNoKPI(oppSet);
        }
    }
    
    private static Set<Id> auditStatusProcessedOppIds = new Set<Id>();

    //Clones the latest Approved set per Opportunity x Milestone with refreshed audit fields; duplicates of existing Approved rows are intended.
    public static void generateApprovedCommissionOnAuditStatusChange(Set<Id> oppIds) {
        if (oppIds == null || oppIds.isEmpty()) {
            return;
        }
        Set<Id> pendingOppIds = oppIds.clone();
        pendingOppIds.removeAll(auditStatusProcessedOppIds);
        if (pendingOppIds.isEmpty()) {
            return;
        }
        auditStatusProcessedOppIds.addAll(pendingOppIds);
    
        List<Core_Commissionable_Transaction__c> newTxns = new List<Core_Commissionable_Transaction__c>();
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
    
        try {
            DateTime transactionTimeStamp = System.now();
            DateTime commissionCutoff = getCommissionCutoff();
    
            Set<String> activeMilestones = new Set<String>();
            for (Core_Commission_KPI_Mappings__c kpiMap : Core_Commission_KPI_Mappings__c.getAll().values()) {
                if (kpiMap.Core_IsActive__c) {
                    activeMilestones.add(kpiMap.Core_KPI_Name_Nm__c);
                }
            }
            if (activeMilestones.isEmpty()) {
                return;
            }
    
            Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([
                SELECT Id, CRM_Audit_Status__c, CRM_Audit_Close_Date__c
                FROM Opportunity
                WHERE Id IN :pendingOppIds AND Core_Commissionable__c = 'Yes' AND Core_Approved_Date__c >= :commissionCutoff
            ]);
            if (opportunities.isEmpty()) {
                return;
            }
    
            //Transactions carry no batch id; rows written by one call share one Core_Transaction_Timestamp__c.
            Map<String, DateTime> latestTs = new Map<String, DateTime>();
            Set<String> skipSetKeys = new Set<String>();
            List<Core_Commissionable_Transaction__c> latestSetRows = new List<Core_Commissionable_Transaction__c>();
            for (Core_Commissionable_Transaction__c src : [
                    SELECT Id, Core_Account_ID__c, Core_Account_Name__c, Core_Approved_Total_Price__c, Core_Claim_Date__c,
                           Core_Employee_ID__c, Core_Employee_Name__c, CRM_Last_Approved_DateTime__c, Core_Milestone_Area__c, Core_Opportunity_Name__c,
                           Core_Opportunity_Team_Member_Role__c, Core_Opportunity_Type__c, Core_Opportunity__c, Core_Percent_Contribution__c,
                           Core_Source_ID__c, Core_Status__c, Core_Transaction_Timestamp__c, Core_Transaction_Type__c, Core_WWID__c, Core_KPI_Id__c,
                           Core_Approved_Sales_Group__c, CRM_Team_Member_Addition_Date__c, CRM_Audit_Status_Txt__c, CRM_Audit_Close_Date__c
                    FROM Core_Commissionable_Transaction__c
                    WHERE Core_Opportunity__c IN :opportunities.keySet()
                      AND Core_Milestone_Area__c IN :activeMilestones
                      AND CreatedDate >= :commissionCutoff
                    ORDER BY Core_Opportunity__c, Core_Milestone_Area__c, Core_Transaction_Timestamp__c DESC, CreatedDate DESC
                ]) {
                String setKey = src.Core_Opportunity__c + '~' + src.Core_Milestone_Area__c;
                if (!latestTs.containsKey(setKey)) {
                    latestTs.put(setKey, src.Core_Transaction_Timestamp__c);
                    if (src.Core_Status__c != 'Approved') {
                        skipSetKeys.add(setKey);
                    }
                }
                if (!skipSetKeys.contains(setKey) && src.Core_Status__c == 'Approved'
                    && src.Core_Transaction_Timestamp__c == latestTs.get(setKey)) {
                    latestSetRows.add(src);
                }
            }
    
            Set<String> clonedKeys = new Set<String>();
            for (Core_Commissionable_Transaction__c src : latestSetRows) {
                String setKey = src.Core_Opportunity__c + '~' + src.Core_Milestone_Area__c;
                if (!clonedKeys.add(setKey + '~' + src.Core_Employee_ID__c)) {
                    continue;
                }
                Opportunity opp = opportunities.get(src.Core_Opportunity__c);
                Core_Commissionable_Transaction__c txn = src.clone(false, true, false, false);
                txn.Core_Status__c = Label.Core_Commissionable_Transaction_Approved_Status;
                txn.Core_Transaction_Timestamp__c = transactionTimeStamp;
                txn.CRM_Audit_Status_Txt__c = opp.CRM_Audit_Status__c;
                txn.CRM_Audit_Close_Date__c = opp.CRM_Audit_Close_Date__c;
                newTxns.add(txn);
            }
    
            if (!newTxns.isEmpty()) {
                List<Database.SaveResult> srList = Database.insert(newTxns, false);
                for (Integer i = 0; i < srList.size(); i++) {
                    if (!srList[i].isSuccess()) {
                        for (Database.Error err : srList[i].getErrors()) {
                            logEntries.add(new Core_Log_Entry__c(
                                Core_Message__c = err.getMessage(),
                                Core_Origin__c = 'CommissionCreationAuditStatusChange',
                                Core_Severity__c = 'Info',
                                Core_When__c = System.now(),
                                Core_Project__c = 'Sales',
                                Core_sObjectId__c = String.valueOf(newTxns[i].Core_Opportunity__c)));
                        }
                    }
                }
                if (!logEntries.isEmpty()) {
                    insert logEntries;
                }
            }
        } catch (Exception ex) {
            insert new Core_Log_Entry__c(
                Core_Message__c = ex.getMessage(),
                Core_Origin__c = 'CommissionCreationAuditStatusChange',
                Core_Severity__c = 'Info',
                Core_When__c = System.now(),
                Core_Project__c = 'Sales',
                Core_Details__c = 'Line number:' + ex.getLineNumber() + ', Stack trace: ' + ex.getStackTraceString());
        }
    }
}