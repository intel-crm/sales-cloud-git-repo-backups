public with sharing class AccountBriefSummaryController {
    // Method to strip HTML tags from a string
  
public List<Account_Brief_Summary_POC__c> childRecordsvf { get; set; }
    public String parentId { get; set; }

    // Default constructor
    public AccountBriefSummaryController() {
        // Get the parentId from the page parameters
        parentId = ApexPages.currentPage().getParameters().get('parentId');
        system.debug('line9'+parentId);
        if (parentId != null) {
            // Fetch child records related to the parent record
            childRecordsvf = [SELECT Account_Brief_Summary__c, Meeting_Invite__c, Attendees__c 
                            FROM Account_Brief_Summary_POC__c 
                            WHERE Account_Brief_Summary_Row__c = :parentId];
        }
        system.debug('line10'+childRecordsvf);
    }

// Property to store child records
    public static List<Account_Brief_Summary_POC__c> childRecords { get; set; }
    
    @AuraEnabled(cacheable=true)
    public static List<Account_Brief_Summary_POC__c> getChildRecords(Id parentId) {
        // Fetch child records related to the parent
        childRecords = [SELECT Account_Brief_Summary__c, Meeting_Invite__c, Attendees__c
                        FROM Account_Brief_Summary_POC__c 
                        WHERE Account_Brief_Summary_Row__c = :parentId];
        return childRecords;
    }

     

   @AuraEnabled
public static void saveChildRecords(Id parentId, List<Account_Brief_Summary_POC__c> rows) {
    if (rows == null || rows.isEmpty()) {
            //throw('No rows to save');
        }
        
        List<Account_Brief_Summary_POC__c> recordsToInsert = new List<Account_Brief_Summary_POC__c>();
        
        try {
            for (Account_Brief_Summary_POC__c row : rows) {
                // Validate that all necessary fields are populated before inserting
                if (String.isEmpty(row.Account_Brief_Summary__c) || String.isEmpty(row.Meeting_Invite__c) || String.isEmpty(row.Attendees__c)) {
                   // throw ('All fields must be filled out');
                }

                // Remove HTML tags from rich text fields
                row.Account_Brief_Summary__c = stripHtmlTags(row.Account_Brief_Summary__c);
                row.Meeting_Invite__c = stripHtmlTags(row.Meeting_Invite__c);
                row.Attendees__c = stripHtmlTags(row.Attendees__c);

                // Create new child record and add to the list
                Account_Brief_Summary_POC__c newRow = new Account_Brief_Summary_POC__c(
                    Account_Brief_Summary_Row__c = parentId,
                    Account_Brief_Summary__c = row.Account_Brief_Summary__c,
                    Meeting_Invite__c = row.Meeting_Invite__c,
                    Attendees__c = row.Attendees__c
                );
                recordsToInsert.add(newRow);
            }

            // Insert the new child records
            insert recordsToInsert;

        } catch (Exception e) {
            // Log the exception for troubleshooting
            System.debug('Error in saving child records: ' + e.getMessage());
            //throw new('Error saving child records: ' + e.getMessage());
        }
}
   @AuraEnabled
    public static String generatePDF(Id parentId) {
       // Fetch the child records using the provided parentId
        List<Account_Brief_Summary_POC__c> childRecords = [SELECT Account_Brief_Summary__c, 
                                                            Meeting_Invite__c, Attendees__c
                                                           FROM Account_Brief_Summary_POC__c 
                                                           WHERE Account_Brief_Summary_Row__c = :parentId];

        // Create a Visualforce page to render as PDF
        PageReference pdfPage = Page.AccountBriefSummaryPDFPage; // Visualforce page name is 'ChildRecordsPDF'
        
        // Passing the child records to the VF page
        pdfPage.getParameters().put('childRecords', JSON.serialize(childRecords)); // Serialize the child records as JSON
        pdfPage.getParameters().put('parentId', parentId); // Pass the parentId to the VF page
        
        // Set the content type as PDF
        pdfPage.getParameters().put('renderAs', 'pdf');
        
        // Return the URL for the PDF page to be used in LWC
        return pdfPage.getUrl();
    }
      private static String stripHtmlTags(String richTextContent) {
        if (String.isEmpty(richTextContent)) {
            return richTextContent;
        }
        
        // Remove <p> and </p> tags
        String cleanedContent = richTextContent.replaceAll('<p>', '').replaceAll('</p>', '');
        
        // Optionally, remove the line breaks from the paragraphs if required
        // cleanedContent = cleanedContent.replaceAll('<br/>', ' '); // To remove line breaks
        
        return cleanedContent;
    }

    @AuraEnabled(cacheable=true)
    public static List<SObject> searchRecords(String searchTerm) {
        // Replace 'RelatedObject__c' with your actual object API name
        String query = 'SELECT Id, Name FROM Users WHERE Name LIKE :searchTerm LIMIT 10';
        return Database.query(query);
    }

}