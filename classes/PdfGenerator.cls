public with sharing class PdfGenerator {
    public static String generate(String htmlContent) {
        PageReference page = new PageReference('/apex/HTMLtoPDF');
        page.getParameters().put('content', htmlContent);

        // Return the URL to the generated PDF
        return page.getUrl();
    }
}