/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : CRM_PdfGeneratorQueueable
 * Author          : <YourName>
 * Created Date    : May 8, 2026
 * Last Modified By: <YourName>
 * Last Modified On: May 8, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  May 8, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public class CRM_PdfGeneratorQueueable implements Queueable, Database.AllowsCallouts {
    private Id recordId;

    public CRM_PdfGeneratorQueueable(Id recordId) {
        this.recordId = recordId;
    }

    public void execute(QueueableContext context) {
        // 1. Generate PDF
        PageReference pg = Page.CRM_GeneratePDF_EMB; // Replace with your VF page
        pg.getParameters().put('id', recordId);
        
        Blob pdfBlob;
        if (Test.isRunningTest()) {
            pdfBlob = Blob.valueOf('Test');
        } else {
            pdfBlob = pg.getContentAsPDF();
        }
		String base64 = EncodingUtil.base64Encode(pdfBlob);
        // 2. Attach to Record
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Executive_Meeting_Brief_PDF';
        cv.PathOnClient = 'Executive_Brief.pdf';
        cv.VersionData = pdfBlob;
        cv.FirstPublishLocationId = recordId;
        insert cv;
    }
}