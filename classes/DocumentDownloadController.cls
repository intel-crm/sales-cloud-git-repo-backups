public class DocumentDownloadController {
    public String recordId { get; set; }
 
    public DocumentDownloadController() {
        // Get the recordId from the URL parameters
        recordId = ApexPages.currentPage().getParameters().get('id');
    }
 
    public PageReference generatePDF() {
        // Fetch the Account record or any other object you're interested in
        Accountplan accountplanRecord = [select id,account.name,owner.name from accountplan];
 
        // Generate the Visualforce page content as a PDF
        PageReference myPage = Page.DownloadFILE;  // Replace MyPDFPage with the actual Visualforce page name
        myPage.getParameters().put('id', recordId);  // Pass the record ID to the page
        return myPage;
    }
}