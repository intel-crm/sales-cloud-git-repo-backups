public with sharing class Core_MDF_BulkPaymentStatusService implements Queueable {

    public static final String PENDING_STATUS = 'Pending Payment';
    public static final String PAID_STATUS = 'Paid';
    public static final String CHUNK_SIZE_KEY = 'BULK_PAYMENT_CHUNK_SIZE';
    public static final String EMAIL_TEMPLATE = 'Core_MDF_Bulk_Payment_Update_Completed';
    private static final Integer DEFAULT_CHUNK_SIZE = 100;
    private static final Integer MAX_CHUNK_SIZE = 200;
    private static final Integer MAX_VERIFY_ATTEMPTS = 120;
    private static final Integer REQUIRED_CLEAN_CHECKS = 2;
    private static final Integer COUNT_QUERY_SLICE = 1000;
    private static final Integer MAX_LOGGED_FAILURES = 10;
    private static final Integer MAX_CONFIG_DIGITS = 9;
    private static final Set<String> CLAIM_JOB_CLASSES = new Set<String>{'Core_MDF_Batch_UpdateClaimstoPaid','Core_MDF_Batch_RollbackPaidPaymentClaims'};
    private static final List<String> ACTIVE_JOB_STATUSES = new List<String>{'Holding', 'Queued', 'Preparing', 'Processing'};
	public class BulkPaymentException extends Exception {}

    public class Request {
        @InvocableVariable(label='Payments' required=true)
        public List<Core_MDF_Payment__c> payments;
        @InvocableVariable(label='Payment Run Id' required=true)
        public Id paymentRunId;
    }

    public class PaymentInput {
        public Id paymentId;
        public Date paymentMadeDate;
        public String eftNumber;
    }

    public class JobState {
        public Id submitterId;
        public Id paymentRunId;
        public Datetime startTime;
        public List<PaymentInput> inputs;
        public Integer nextIndex = 0;
        public Integer chunkSize;
        public Integer verifyAttempts = 0;
        public Integer cleanChecks = 0;
    }

    // Public so JSON.serialize keeps them when scheduled via Core_MDF_CustomSchedulerUtility
    public JobState state;
    public Boolean verifyMode;

    public Core_MDF_BulkPaymentStatusService(JobState state, Boolean verifyMode) {
        this.state = state;
        this.verifyMode = verifyMode;
    }

    // Flow entry point
    @InvocableMethod
    public static void submit(List<Request> requests) {
        List<Core_MDF_Batch_Scheduler__c> schedulerRecords = new List<Core_MDF_Batch_Scheduler__c>();
        for (Request req : requests) {
            JobState jobState = new JobState();
            jobState.submitterId = UserInfo.getUserId();
            jobState.paymentRunId = req.paymentRunId;
            jobState.startTime = Datetime.now();
            jobState.chunkSize = chunkSize();
            jobState.inputs = new List<PaymentInput>();

            for (Core_MDF_Payment__c payment : req.payments) {
                jobState.inputs.add(new PaymentInput());
                PaymentInput input = jobState.inputs[jobState.inputs.size() - 1];
                input.paymentId = payment.Id;
                input.paymentMadeDate = payment.Core_MDF_Payment_Made_Dt__c;
                input.eftNumber = payment.Core_MDF_EFT_Nbr__c;
            }
            // Picked up later by Core_MDF_BatchSchedulerUtility, so a full async queue cannot fail the flow
            Core_MDF_BulkPaymentStatusService service = new Core_MDF_BulkPaymentStatusService(jobState, false);
            Core_MDF_Batch_Scheduler__c schedulerRecord = new Core_MDF_Batch_Scheduler__c();
            schedulerRecord.Core_MDF_Object_JSON_Txt__c = JSON.serialize(service);
            schedulerRecord.Core_MDF_Batch_Class_Name_Txt__c = String.valueOf(service).split(':')[0];
            schedulerRecord.Core_MDF_Batch_Size_Nbr__c = 1;
            // Validation rule rejects a Once schedule earlier than NOW() at insert time
            Datetime runTime = Datetime.now().addMinutes(1);
            schedulerRecord.Core_MDF_Effective_Start_Time_Dt__c = runTime;
            schedulerRecord.Scheduled_Time_Dt__c = runTime;
            schedulerRecord.Core_MDF_Job_Frequency__c = 'Once';
            schedulerRecord.Core_MDF_Priority__c = 'High';
            schedulerRecord.Core_MDF_Program_Txt__c = 'CCP';
            schedulerRecords.add(schedulerRecord);
        }
        insert schedulerRecords;
    }

    public void execute(QueueableContext ctx) {
        System.attachFinalizer(new FailureFinalizer(state));
        if (verifyMode) {
            verify(state);
        } else {
            processNextChunk(state);
        }
    }

    // Processes the next payment chunk
    public static void processNextChunk(JobState state) {

        Integer endIndex = Math.min(state.nextIndex + state.chunkSize, state.inputs.size());
        Set<Id> paymentIds = new Set<Id>();
        Map<Id, Core_MDF_Payment__c> updatesById = new Map<Id, Core_MDF_Payment__c>();
        for (Integer i = state.nextIndex; i < endIndex; i++) {
            PaymentInput input = state.inputs[i];
            paymentIds.add(input.paymentId);
        }

        // Only update payments that are still pending
        Set<Id> pendingIds = new Map<Id, Core_MDF_Payment__c>([SELECT Id FROM Core_MDF_Payment__c WHERE Id IN :paymentIds AND Core_MDF_Payment_Status_Txt__c = :PENDING_STATUS]).keySet();

        // Build unique payment updates
        for (Integer i = state.nextIndex; i < endIndex; i++) {
            PaymentInput input = state.inputs[i];
            if (pendingIds.contains(input.paymentId) && !updatesById.containsKey(input.paymentId)) {
                updatesById.put(input.paymentId, new Core_MDF_Payment__c(
                    Id = input.paymentId,
                    Core_MDF_Payment_Status_Txt__c = PAID_STATUS,
                    Core_MDF_Payment_Made_Dt__c = input.paymentMadeDate,
                    Core_MDF_EFT_Nbr__c = input.eftNumber
                ));
            }
        }

        // Update records with partial success
        if (!updatesById.isEmpty()) {
            List<Core_MDF_Payment__c> records = updatesById.values();
            List<Database.SaveResult> results = Database.update(records, false);
            List<String> failures = new List<String>();
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    failures.add(records[i].Id + ': ' + results[i].getErrors()[0].getMessage());
                }
            }
            if (!failures.isEmpty()) {
                List<String> shownFailures = new List<String>();
                for (Integer i = 0; i < Math.min(failures.size(), MAX_LOGGED_FAILURES); i++) {
                    shownFailures.add(failures[i]);
                }
                Core_MDF_CCP_UtilityClass.logError(new DmlException(failures.size() + ' payment update(s) failed. First ' + shownFailures.size() + ': ' + String.join(shownFailures, ';')));
            }
        }
        state.nextIndex = endIndex;
        if (state.nextIndex < state.inputs.size()) {
            chain(state, false, 0);
        } else {
            state.cleanChecks = 0;
            chain(state, true, 1);
        }
    }

    // Checks completion of claim and rollback batches
    public static void verify(JobState state) {
        state.verifyAttempts++;
        Integer activeJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name IN :CLAIM_JOB_CLASSES AND Status IN :ACTIVE_JOB_STATUSES AND CreatedDate >= :state.startTime];
        state.cleanChecks = activeJobs == 0 ? state.cleanChecks + 1 : 0;
        if (state.cleanChecks < REQUIRED_CLEAN_CHECKS && state.verifyAttempts < MAX_VERIFY_ATTEMPTS) {
            chain(state, true, 1);
            return;
        }
        sendCompletionEmail(state, countPaid(state));
    }

    // Schedules the next Queueable execution
    private static void chain(JobState state, Boolean verifyMode, Integer delayMinutes) {
        Core_MDF_BulkPaymentStatusService nextJob = new Core_MDF_BulkPaymentStatusService(state, verifyMode);
        if (delayMinutes > 0) {
            System.enqueueJob(nextJob, delayMinutes);
        } else {
            System.enqueueJob(nextJob);
        }
    }

    // Counts successfully paid payments
    private static Integer countPaid(JobState state) {
        Integer paidCount = 0;
        List<Id> paymentIds = new List<Id>();
        for (PaymentInput input : state.inputs) {
            paymentIds.add(input.paymentId);
        }
        for (Integer i = 0; i < paymentIds.size(); i += COUNT_QUERY_SLICE) {
            List<Id> ids = new List<Id>();
            for (Integer j = i; j < Math.min(i + COUNT_QUERY_SLICE, paymentIds.size()); j++) {
                ids.add(paymentIds[j]);
            }
            paidCount += [SELECT COUNT() FROM Core_MDF_Payment__c WHERE Id IN :ids AND Core_MDF_Payment_Status_Txt__c = :PAID_STATUS];
        }
        return paidCount;
    }

    // Sends completion email to the submitter
    public static void sendCompletionEmail(JobState state, Integer successCount) {

        Integer totalCount = state.inputs.size();
        String runName = String.valueOf(state.paymentRunId);
        List<Core_MDF_Payment_Run__c> runs = [SELECT Name FROM Core_MDF_Payment_Run__c WHERE Id = :state.paymentRunId LIMIT 1];
        if (!runs.isEmpty()) {
            runName = runs[0].Name;
        }
        String runUrl = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Core_MDF_Payment_Run__c/' + state.paymentRunId + '/view';
        List<EmailTemplate> templates = [SELECT Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :EMAIL_TEMPLATE LIMIT 1];
        EmailTemplate template = templates[0];
        String body = String.isNotBlank(template.HtmlValue) ? template.HtmlValue : template.Body;
        body = body
            .replace('{{PAYMENT_RUN}}', runName.escapeHtml4())
            .replace('{{PAYMENT_RUN_URL}}', runUrl)
            .replace('{{TOTAL_COUNT}}', String.valueOf(totalCount))
            .replace('{{SUCCESS_COUNT}}', String.valueOf(successCount))
            .replace('{{FAILED_COUNT}}', String.valueOf(totalCount - successCount));

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(state.submitterId);
        email.setSaveAsActivity(false);
        email.setSubject(template.Subject);
        email.setHtmlBody(body);

        // Use org-wide email address when configured
        for (OrgWideEmailAddress address : [SELECT Id FROM OrgWideEmailAddress WHERE Id = :Label.Core_MDF_OrgWideId LIMIT 1]) {
            email.setOrgWideEmailAddressId(address.Id);
        }
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email }, false);
        if (!results[0].isSuccess()) {
            Core_MDF_CCP_UtilityClass.logError(new BulkPaymentException('Bulk payment completion email failed: ' + results[0].getErrors()[0].getMessage()));
        }
    }

    // Retrieves and validates configurable chunk size
    public static Integer chunkSize() {
        String rawValue;
		Core_MDF_Custom_Label_Configration__mdt config = Core_MDF_Custom_Label_Configration__mdt.getInstance(CHUNK_SIZE_KEY);
        rawValue = config == null ? null : config.Core_MDF_Value_Txt__c;
        String value = String.isBlank(rawValue) ? '' : rawValue.trim();
        Integer configuredSize = DEFAULT_CHUNK_SIZE;
        if (value.isNumeric() && value.length() <= MAX_CONFIG_DIGITS && Integer.valueOf(value) > 0) {
            configuredSize = Integer.valueOf(value);
        }
        return Math.min(configuredSize, MAX_CHUNK_SIZE);
    }

    // Handles unexpected Queueable failures
    public class FailureFinalizer implements Finalizer {
        private JobState state;
        public FailureFinalizer(JobState state) {
            this.state = state;
        }
        public void execute(FinalizerContext ctx) {
            if (ctx.getResult() == ParentJobResult.UNHANDLED_EXCEPTION) {
                Core_MDF_CCP_UtilityClass.logError(ctx.getException());
                sendCompletionEmail(state, countPaid(state));
            }
        }
    }
}