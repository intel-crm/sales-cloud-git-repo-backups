public class SalesFeedbackControllerPDF {
   public class MeetingRow {
        public String intelObjective { get; set; }
        public String otherPartyObjective { get; set; }
        public String criticalMessage { get; set; }
    }

    // List to store dynamic rows
    public List<MeetingRow> meetingRows { get; set; }

    // Constructor
    public SalesFeedbackControllerPDF() {
        meetingRows = new List<MeetingRow>();
        addRow(); // Add the first row by default
    }

    // Method to add a new row
    public void addRow() {
        meetingRows.add(new MeetingRow());
    }

    // Save rows to Salesforce
    public void saveRows() {
        List<Sales_Feedback__c> feedbackRecords = new List<Sales_Feedback__c>();

        for (MeetingRow row : meetingRows) {
            Sales_Feedback__c feedback = new Sales_Feedback__c();
            feedback.Intel_Meeting_Brief__c = row.intelObjective;
            feedback.Other_Party_Meeting__c = row.otherPartyObjective;
         //   feedback.Critical_Message__c = row.criticalMessage;
            feedbackRecords.add(feedback);
        }

        // Save all records to Salesforce
        if (!feedbackRecords.isEmpty()) {
            insert feedbackRecords;
        }

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Rows saved successfully.'));
    }

    // Method to handle PDF generation
    public void generatePDF() {
        // Visualforce will automatically handle the PDF rendering due to renderAs="pdf"
        // No additional code needed for this method, as the data is already in the controller.
    }
}