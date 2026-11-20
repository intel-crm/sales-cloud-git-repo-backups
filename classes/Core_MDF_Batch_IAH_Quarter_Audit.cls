// Validates the IAH data for current quarter and sends one email with the results
// checks Recovery Dashboard PS/PSD links and amounts and PSD carry-over from the previous quarter
// Database.executeBatch(new Core_MDF_Batch_IAH_Quarter_Audit('Q4 2026'), 100);
// Test class: Core_MDF_Batch_IAH_Quarter_Audit_Test

global without sharing class Core_MDF_Batch_IAH_Quarter_Audit implements Database.Batchable<SObject>, Database.Stateful {

    public String quarter;
    public String previousQuarter;

    public Integer exceptionScorecardCount = 0;
    public Integer processingErrorCount = 0;
    public List<AuditRow> auditRows = new List<AuditRow>();

    global Core_MDF_Batch_IAH_Quarter_Audit() { this(null); }

    // Default to the previous Intel fiscal quarter when no quarter is passed
    global Core_MDF_Batch_IAH_Quarter_Audit(String quarter) {
        if (String.isBlank(quarter)) {
            Date today = Date.today();
            Period currentFiscalQuarter = [SELECT Number, FiscalYearSettings.Name FROM Period WHERE FiscalYearSettings.YearType = 'Custom' AND Type = 'Quarter' AND StartDate <= :today AND EndDate >= :today LIMIT 1];
            Integer currentQuarterNumber = currentFiscalQuarter.Number;
            Integer fiscalYear = Integer.valueOf(currentFiscalQuarter.FiscalYearSettings.Name);
            this.quarter = currentQuarterNumber == 1 ? 'Q4 ' + (fiscalYear - 1): 'Q' + (currentQuarterNumber - 1) + ' ' + fiscalYear;
        } else { this.quarter = quarter.trim().toUpperCase(); }
        Integer quarterNumber = Integer.valueOf(this.quarter.substring(1, 2));
        Integer year = Integer.valueOf(this.quarter.substring(3));
        this.previousQuarter = quarterNumber == 1 ? 'Q4 ' + (year - 1) : 'Q' + (quarterNumber - 1) + ' ' + year;
        Decimal actualWeightedPvAmount;
        String details;
    }

    global Database.QueryLocator start(Database.BatchableContext context) {
        String rsaBudget = Core_MDF_CCP_ConstantClass.RMF_RSA_MD_BUDGET_TYPE;
        Date rsaExclusionDate = Date.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Exclude_RSA_MD'));

        // existing query taken from Core_MDF_PartnerShipScore_to_Detail.getScoreCardData().
        return Database.getQueryLocator([SELECT Id, Core_MDF_Virtual_Corp_Account_Id__c, Core_MDF_Claim_Amt__c, Core_MDF_Manual_Recovery_Amount_USD_Amt__c, Core_MDF_Max_Possible_Amt__c,
                                            Core_MDF_Weighted_PV_Amt__c, Core_MDF_Case_Id__r.AccountId,  Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c, 
                                            Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c, 
                                            Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c, Core_MDF_Case_Id__r.Core_MDF_Region_SubRegion_txt__c, Core_MDF_Case_Id__r.Core_MDF_Claim_Lookup_Id__c 
                                            FROM Core_MDF_Scorecard__c WHERE Core_MDF_Quarter__c = :quarter
                                            AND Core_MDF_Case_Id__r.Core_MDF_Status__c = 'Review Completed' AND Core_MDF_Score_Nbr__c != null
                                            AND (Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c != :rsaBudget 
                                            OR (Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c = :rsaBudget AND DAY_ONLY(Core_MDF_Case_Id__r.ClosedDate) <= :rsaExclusionDate))]);
    }

    global void execute(Database.BatchableContext context, List<SObject> scope) {
        if (scope.isEmpty()) { return; }

        List<Core_MDF_Scorecard__c> scorecards = (List<Core_MDF_Scorecard__c>)scope;
        try {
            Set<Id> channelProgramIds = new Set<Id>();
            Set<Id> virtualCorpAccountIds = new Set<Id>();
            Set<Id> scorecardIds = new Set<Id>();

            Set<String> relevantQuarters = new Set<String>{quarter, previousQuarter};

            for (Core_MDF_Scorecard__c scorecard : scorecards) {
                scorecardIds.add(scorecard.Id);
                if (scorecard.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c != null) { 
                    channelProgramIds.add(scorecard.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c); 
                }
                Id virtualCorpAccountId = String.isBlank(scorecard.Core_MDF_Virtual_Corp_Account_Id__c) ? null : Id.valueOf(scorecard.Core_MDF_Virtual_Corp_Account_Id__c.trim());
                if (virtualCorpAccountId != null) { 
                    virtualCorpAccountIds.add(virtualCorpAccountId); 
                }
            }

            Map<String, List<Core_MDF_Partnership_Score__c>> currentPartnershipScoresByKey = new Map<String, List<Core_MDF_Partnership_Score__c>>();
            Map<String, List<Core_MDF_Partnership_Score_Detail__c>> partnershipScoreDetailsByKey = new Map<String, List<Core_MDF_Partnership_Score_Detail__c>>();
            
            if (!channelProgramIds.isEmpty() && !virtualCorpAccountIds.isEmpty()) {
                for (Core_MDF_Partnership_Score__c partnershipScore : [SELECT Id, Core_MDF_Channel_Program_Id__c, Core_MDF_Virtual_Corp_Account_Id__c
                                                                        FROM Core_MDF_Partnership_Score__c WHERE Core_MDF_Channel_Program_Id__c IN :channelProgramIds 
                                                                        AND Core_MDF_Virtual_Corp_Account_Id__c IN :virtualCorpAccountIds
                                                                        AND Core_MDF_Quarter_Year_Nm__c = :quarter]) {
                    String psKey = String.valueOf(partnershipScore.Core_MDF_Channel_Program_Id__c) + String.valueOf(partnershipScore.Core_MDF_Virtual_Corp_Account_Id__c);
                    if (!currentPartnershipScoresByKey.containsKey(psKey)) {
                        currentPartnershipScoresByKey.put(psKey, new List<Core_MDF_Partnership_Score__c>());
                    }
                    currentPartnershipScoresByKey.get(psKey).add(partnershipScore);
                }

                for (Core_MDF_Partnership_Score_Detail__c partnershipScoreDetail : [SELECT Id, Core_MDF_Quarter_Year_Nm__c, Core_MDF_Node_Account_Id__c, Core_MDF_Budget_Type_Nm__c,
                                                                                        Core_MDF_Region_Cd__c, Core_MDF_Carry_Over_Amt__c, Core_MDF_Balance_Amount_Amt__c, 
                                                                                        Core_MDF_Partnership_Score_Id__c, Core_MDF_Partnership_Score_Detail_Id__c, 
                                                                                        Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c, 
                                                                                        Core_MDF_Partnership_Score_Id__r.Core_MDF_Virtual_Corp_Account_Id__c
                                                                                        FROM Core_MDF_Partnership_Score_Detail__c 
                                                                                        WHERE Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c IN :channelProgramIds
                                                                                        AND Core_MDF_Partnership_Score_Id__r.Core_MDF_Virtual_Corp_Account_Id__c IN :virtualCorpAccountIds
                                                                                        AND Core_MDF_Quarter_Year_Nm__c IN :relevantQuarters]) {
                    String psdKey = buildPartnershipScoreDetailKey(partnershipScoreDetail.Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c, partnershipScoreDetail.Core_MDF_Partnership_Score_Id__r.Core_MDF_Virtual_Corp_Account_Id__c, partnershipScoreDetail.Core_MDF_Quarter_Year_Nm__c, partnershipScoreDetail.Core_MDF_Node_Account_Id__c, partnershipScoreDetail.Core_MDF_Budget_Type_Nm__c, partnershipScoreDetail.Core_MDF_Region_Cd__c);
                    if (!partnershipScoreDetailsByKey.containsKey(psdKey)) {
                        partnershipScoreDetailsByKey.put(psdKey, new List<Core_MDF_Partnership_Score_Detail__c>());
                    }
                    partnershipScoreDetailsByKey.get(psdKey).add(partnershipScoreDetail);
                }
            }

            Map<Id, List<Core_MDF_Recovery_Dashboard__c>> recoveryDashboardByScorecardId = new Map<Id, List<Core_MDF_Recovery_Dashboard__c>>();
            for (Core_MDF_Recovery_Dashboard__c recoveryDashboard : [SELECT Id, Core_MDF_Scorecard_Id__c, Core_MDF_Partnership_Score_Id__c, Core_MDF_Partnership_Score_Detail_Id__c,
                                                                        Core_MDF_Claim_Amt__c, Core_MDF_Manual_Recovery_Amount_USD_Amt__c, Core_MDF_Max_Possible_Amt__c, Core_MDF_Weighted_PV_Amt__c 
                                                                        FROM Core_MDF_Recovery_Dashboard__c WHERE Core_MDF_Scorecard_Id__c IN :scorecardIds AND Core_MDF_Is_Active_Ind__c = true]) {
                if (!recoveryDashboardByScorecardId.containsKey(recoveryDashboard.Core_MDF_Scorecard_Id__c)) {
                    recoveryDashboardByScorecardId.put(recoveryDashboard.Core_MDF_Scorecard_Id__c, new List<Core_MDF_Recovery_Dashboard__c>());
                }
                recoveryDashboardByScorecardId.get(recoveryDashboard.Core_MDF_Scorecard_Id__c).add(recoveryDashboard);
            }

            for (Core_MDF_Scorecard__c scorecard : scorecards) {
                try {
                    // Integer num = 1/0;
                    auditScorecard(scorecard, currentPartnershipScoresByKey, partnershipScoreDetailsByKey, recoveryDashboardByScorecardId);
                } catch (Exception ex) {
                    processingErrorCount++;
                    Core_MDF_CCP_UtilityClass.logError(ex);
                    addProcessingError(scorecard, ex.getMessage());
                }
            }

        } catch (Exception ex) {
            processingErrorCount++;
            Core_MDF_CCP_UtilityClass.logError(ex);

            for (Core_MDF_Scorecard__c scorecard : scorecards) {
                addProcessingError(scorecard, ex.getMessage());
            }
        }
    }

    public void auditScorecard(Core_MDF_Scorecard__c scorecard, Map<String, List<Core_MDF_Partnership_Score__c>> currentPartnershipScoresByKey, Map<String, List<Core_MDF_Partnership_Score_Detail__c>> partnershipScoreDetailsByKey, Map<Id, List<Core_MDF_Recovery_Dashboard__c>> recoveryDashboardByScorecardId) {

        List<String> issues = new List<String>();

        Id channelProgramId = scorecard.Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__c;
        Id virtualCorpAccountId = String.isBlank(scorecard.Core_MDF_Virtual_Corp_Account_Id__c) ? null : Id.valueOf(scorecard.Core_MDF_Virtual_Corp_Account_Id__c.trim());
        String programName = scorecard.Core_MDF_Case_Id__r.Core_MDF_Channel_Program_txt__c;
        String budgetType = scorecard.Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c;
        Id nodeAccountId = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account.contains(programName) ? scorecard.Core_MDF_Case_Id__r.AccountId : null;  //RMF/IPA
        String regionSubregion = scorecard.Core_MDF_Case_Id__r.Core_MDF_Region_SubRegion_txt__c;
        String region = String.isBlank(regionSubregion) ? null : regionSubregion.split('-')[0].trim();

        Core_MDF_Partnership_Score__c currentPartnershipScore;
        Core_MDF_Partnership_Score_Detail__c currentPartnershipScoreDetail;
        Core_MDF_Partnership_Score_Detail__c previousPartnershipScoreDetail;

        if (channelProgramId != null && virtualCorpAccountId != null) {
            List<Core_MDF_Partnership_Score__c> matchingPSRecordsByKey = currentPartnershipScoresByKey.get(String.valueOf(channelProgramId) + String.valueOf(virtualCorpAccountId));
            if (matchingPSRecordsByKey == null) {
                issues.add('No PS record exists for ' + quarter + '.');
            } else {
                if (matchingPSRecordsByKey.size() > 1) {
                    issues.add('Multiple PS records exists for ' + quarter + '.');
                }
                currentPartnershipScore = matchingPSRecordsByKey[0];  // used to check previous quarter PS and current quarter PSD linkage
            }
            if (!String.isBlank(budgetType) && !String.isBlank(region)) {
                String currentPsdKey = buildPartnershipScoreDetailKey(channelProgramId, virtualCorpAccountId, quarter, nodeAccountId, budgetType, region);
                String previousPsdKey = buildPartnershipScoreDetailKey(channelProgramId, virtualCorpAccountId, previousQuarter, nodeAccountId, budgetType, region);

                List<Core_MDF_Partnership_Score_Detail__c> currentPsdMatches = partnershipScoreDetailsByKey.get(currentPsdKey);
                List<Core_MDF_Partnership_Score_Detail__c> previousPsdMatches = partnershipScoreDetailsByKey.get(previousPsdKey);

                // check for current and previous PSD records
                currentPartnershipScoreDetail = selectPartnershipScoreDetail(currentPsdMatches, '\'' + quarter + '\'', true, issues);
                previousPartnershipScoreDetail = selectPartnershipScoreDetail(previousPsdMatches, '\'' + previousQuarter + '\'', false, issues);
            }
        }

        Decimal expectedCarryOverAmount = previousPartnershipScoreDetail == null ? null : (previousPartnershipScoreDetail.Core_MDF_Balance_Amount_Amt__c == null ? 0 : previousPartnershipScoreDetail.Core_MDF_Balance_Amount_Amt__c).setScale(2);
        Decimal actualCarryOverAmount = currentPartnershipScoreDetail == null ? null : (currentPartnershipScoreDetail.Core_MDF_Carry_Over_Amt__c == null ? 0 : currentPartnershipScoreDetail.Core_MDF_Carry_Over_Amt__c).setScale(2);

        if (currentPartnershipScoreDetail != null) {
            // validate the linkage between current PSD and previous PSD record
            if (/*currentPartnershipScore == null ||*/ currentPartnershipScoreDetail.Core_MDF_Partnership_Score_Id__c != currentPartnershipScore.Id) {
                issues.add('The ' + quarter + ' PSD is linked to the wrong PS record.');
            }

            // validate the carry-over amount between current and previous PSD records
            if (previousPartnershipScoreDetail == null) {
                if (currentPartnershipScoreDetail.Core_MDF_Partnership_Score_Detail_Id__c != null) {
                    issues.add('The ' + quarter + ' PSD links to a record, but no matching ' + previousQuarter + ' PSD exists.');
                }
                if (actualCarryOverAmount != 0) {
                    issues.add('The ' + quarter + ' PSD has a non-zero carry-over but no matching ' + previousQuarter + ' PSD exists.');
                }
            } else {
                if (currentPartnershipScoreDetail.Core_MDF_Partnership_Score_Detail_Id__c != previousPartnershipScoreDetail.Id) {
                    issues.add('The ' + quarter + ' PSD is not linked to the matching ' + previousQuarter + ' PSD.');
                }
                if (actualCarryOverAmount != expectedCarryOverAmount) {
                    issues.add('The ' + quarter + ' PSD carry-over does not equal the ' + previousQuarter + ' PSD balance.');
                }
            }
        }

        List<Core_MDF_Recovery_Dashboard__c> recoveryDashboardRecords = recoveryDashboardByScorecardId.get(scorecard.Id);
        Core_MDF_Recovery_Dashboard__c recoveryDashboard;
        if (recoveryDashboardRecords == null) {
            issues.add('Scorecard is missing an active Recovery Dashboard record.');
        } else {
            if (recoveryDashboardRecords.size() > 1) {
                issues.add('Scorecard has multiple active Recovery Dashboard records.');
            }

            // validate whether the recovery dashboard links to the expected current quarter PS and PSD records
            if (currentPartnershipScore != null && currentPartnershipScoreDetail != null) {
                for (Core_MDF_Recovery_Dashboard__c dashboardRecord : recoveryDashboardRecords) {
                    if (dashboardRecord.Core_MDF_Partnership_Score_Id__c == currentPartnershipScore.Id && dashboardRecord.Core_MDF_Partnership_Score_Detail_Id__c == currentPartnershipScoreDetail.Id) {
                        recoveryDashboard = dashboardRecord;
                        break;
                    }
                }
                if (recoveryDashboard == null) {
                    issues.add('Active Recovery Dashboard is not linked to the expected ' + quarter + ' PS and PSD record.');
                }
            }

            // validating the amount fields even though the recovery dashboard is not linked to the current quarter PS and PSD records
            if (recoveryDashboard == null) {
                recoveryDashboard = recoveryDashboardRecords[0];
            }

            if (scorecard.Core_MDF_Claim_Amt__c != recoveryDashboard.Core_MDF_Claim_Amt__c) {
                issues.add('Recovery Dashboard claim amount does not match the case closure scorecard.');
            }
            if (scorecard.Core_MDF_Manual_Recovery_Amount_USD_Amt__c != recoveryDashboard.Core_MDF_Manual_Recovery_Amount_USD_Amt__c) {
                issues.add('Recovery Dashboard manual recovery amount does not match the case closure scorecard.');
            }
            if (scorecard.Core_MDF_Max_Possible_Amt__c != recoveryDashboard.Core_MDF_Max_Possible_Amt__c) {
                issues.add('Recovery Dashboard maximum possible amount does not match the case closure scorecard.');
            }
            if (scorecard.Core_MDF_Weighted_PV_Amt__c != recoveryDashboard.Core_MDF_Weighted_PV_Amt__c) {
                issues.add('Recovery Dashboard weighted PV amount does not match the case closure scorecard.');
            }
        }

        AuditRow result = new AuditRow();
        result.scorecardId = scorecard.Id;
        result.claimId = scorecard.Core_MDF_Case_Id__r.Core_MDF_Claim_Lookup_Id__c;
        result.programName = programName;
        result.virtualCorpAccountId = scorecard.Core_MDF_Virtual_Corp_Account_Id__c;
        result.budgetType = budgetType;
        result.region = region;
        result.currentPartnershipScoreId = currentPartnershipScore?.Id;
        result.currentScoreDetailId = currentPartnershipScoreDetail?.Id;
        result.previousScoreDetailId = previousPartnershipScoreDetail?.Id;
        result.actualPreviousScoreDetailId = currentPartnershipScoreDetail?.Core_MDF_Partnership_Score_Detail_Id__c;
        result.recoveryDashboardId = recoveryDashboard?.Id;
        result.expectedCarryOverAmount = expectedCarryOverAmount;
        result.actualCarryOverAmount = actualCarryOverAmount;
        result.expectedClaimAmount = scorecard.Core_MDF_Claim_Amt__c;
        result.actualClaimAmount = recoveryDashboard?.Core_MDF_Claim_Amt__c;
        result.expectedManualRecoveryAmount = scorecard.Core_MDF_Manual_Recovery_Amount_USD_Amt__c;
        result.actualManualRecoveryAmount = recoveryDashboard?.Core_MDF_Manual_Recovery_Amount_USD_Amt__c;
        result.expectedMaxPossibleAmount = scorecard.Core_MDF_Max_Possible_Amt__c;
        result.actualMaxPossibleAmount = recoveryDashboard?.Core_MDF_Max_Possible_Amt__c;
        result.expectedWeightedPvAmount = scorecard.Core_MDF_Weighted_PV_Amt__c;
        result.actualWeightedPvAmount = recoveryDashboard?.Core_MDF_Weighted_PV_Amt__c;
        result.status = issues.isEmpty() ? 'Passed' : 'Exception';
        result.details = issues.isEmpty() ? 'Valid data' : String.join(issues, ' ');

        auditRows.add(result);
        if (!issues.isEmpty()) {
            exceptionScorecardCount++;
        }
    }

    // helper method to select the appropriate PSD record record based on the given criteria
    public static Core_MDF_Partnership_Score_Detail__c selectPartnershipScoreDetail(List<Core_MDF_Partnership_Score_Detail__c> matches, String period, Boolean required, List<String> issues) {
        if (matches == null) {
            if (required) {
                issues.add('No ' + period + ' PSD record exists.');
            }
            return null;
        }
        if (matches.size() > 1) {
            issues.add('Multiple ' + period + ' PSD records exist.');
        }
        return matches[0];
    }

    // helper method to add a processing error for a given scorecard
    public void addProcessingError(Core_MDF_Scorecard__c scorecard, String message) {
        AuditRow result = new AuditRow();
        result.status = 'Exception';
        result.scorecardId = scorecard.Id;
        result.claimId = scorecard.Core_MDF_Case_Id__r.Core_MDF_Claim_Lookup_Id__c;
        result.details = 'Audit processing failed: ' + message;
        auditRows.add(result);
        exceptionScorecardCount++;
    }

    public static String buildPartnershipScoreDetailKey(Id channelProgramId, Id virtualCorpAccountId, String scoreQuarter, Id nodeAccountId, String budgetType, String region) {
        return String.valueOf(channelProgramId) + String.valueOf(virtualCorpAccountId) + scoreQuarter + String.valueOf(nodeAccountId) + budgetType + region;
    }

    global void finish(Database.BatchableContext context) {
        try {
            Boolean passed = exceptionScorecardCount == 0 && processingErrorCount == 0;
            String body = '<html><body style="font-family:Arial,sans-serif;font-size:13px;">'
                + '<h2>IAH Quarter Audit - ' + escapeHtmlValue(quarter) + '</h2>'
                + '<p>Status: ' + (passed ? 'Passed' : 'Completed with mismatches') + '</p>'
                + '<p>Total scorecards processed: ' + auditRows.size() + '</p>'
                + '<p>Scorecards with exceptions: ' + exceptionScorecardCount + '</p>'
                + '<p>Batch processing errors: ' + processingErrorCount + '</p>'
                + '</body></html>';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{'sushma.hamom@intel.com'});
            mail.setSubject(Label.Core_MDF_SFDC_Environment + ': IAH Pull audit for ' + quarter + ' - ' + (passed ? 'Passed' : exceptionScorecardCount + ' scorecards with exceptions'));
            mail.setHtmlBody(body);
            mail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
            mail.setSaveAsActivity(false);

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('IAH_Quarter_Audit_' + quarter.replace(' ', '_') + '_' + Datetime.now().format('yyyy-MM-dd_HH-mm-ss') + '.csv');
            attachment.setContentType('text/csv');
            List<String> lines = new List<String>{
                'Program Name,Virtual Corp Account Id,Budget Type,Region,IAH Data Quarter,ScorecardId,PartnerFundClaimId,Current Quarter PS Id,Current Quarter PSD Id,Expected Previous Quarter PSD Id,Actual Previous PSD Link,Recovery Dashboard Id,Previous PSD Balance Amount,Current PSD Carry Over Amount,Scorecard Claim Amount,Recovery Dashboard Claim Amount,Scorecard Manual Recovery Amount,Recovery Dashboard Manual Recovery Amount,Scorecard Max Possible,Recovery Dashboard Max Possible Amount,Scorecard Weighted PV Amount,Recovery Dashboard Weighted PV Amount,Status,Details'
            };
            for (AuditRow result : auditRows) {
                lines.add(String.join(new List<String>{escapeCsvValue(result.programName), escapeCsvValue(result.virtualCorpAccountId),
                    escapeCsvValue(result.budgetType), escapeCsvValue(result.region), escapeCsvValue(quarter), escapeCsvValue(result.scorecardId),
                    escapeCsvValue(result.claimId), escapeCsvValue(result.currentPartnershipScoreId), escapeCsvValue(result.currentScoreDetailId),
                    escapeCsvValue(result.previousScoreDetailId), escapeCsvValue(result.actualPreviousScoreDetailId),
                    escapeCsvValue(result.recoveryDashboardId), escapeCsvValue(result.expectedCarryOverAmount), escapeCsvValue(result.actualCarryOverAmount),
                    escapeCsvValue(result.expectedClaimAmount), escapeCsvValue(result.actualClaimAmount),
                    escapeCsvValue(result.expectedManualRecoveryAmount), escapeCsvValue(result.actualManualRecoveryAmount),
                    escapeCsvValue(result.expectedMaxPossibleAmount), escapeCsvValue(result.actualMaxPossibleAmount),
                    escapeCsvValue(result.expectedWeightedPvAmount), escapeCsvValue(result.actualWeightedPvAmount),
                    escapeCsvValue(result.status), escapeCsvValue(result.details)
                }, ','));
            }
            attachment.setBody(Blob.valueOf(String.join(lines, '\n')));
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});

            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }

    // helper method to escape CSV values for proper formatting
    public static String escapeCsvValue(Object value) {
        String text = value == null ? '' : String.valueOf(value);
        return '"' + text.replace('"', '""').replace('\r', ' ').replace('\n', ' ') + '"';
    }

    // helper method to escape HTML values for proper formatting
    public static String escapeHtmlValue(String value) {
        return value.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('"', '&quot;').replace('\'', '&#39;');
    }

    public class AuditRow {
        String status;
        Id scorecardId;
        Id claimId;
        String programName;
        String virtualCorpAccountId;
        String budgetType;
        String region;
        Id currentPartnershipScoreId;
        Id currentScoreDetailId;
        Id previousScoreDetailId;
        Id actualPreviousScoreDetailId;
        Id recoveryDashboardId;
        Decimal expectedCarryOverAmount;
        Decimal actualCarryOverAmount;
        Decimal expectedClaimAmount;
        Decimal actualClaimAmount;
        Decimal expectedManualRecoveryAmount;
        Decimal actualManualRecoveryAmount;
        Decimal expectedMaxPossibleAmount;
        Decimal actualMaxPossibleAmount;
        Decimal expectedWeightedPvAmount;
        Decimal actualWeightedPvAmount;
        String details;
    }
}