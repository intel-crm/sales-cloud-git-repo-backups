public class POCControllerClass {
    PageReference pageRef;
    /*public static object queryContentVersion(){
        System.debug('1st');
		ContentVersion cnv = new ContentVersion();
        ContentDistribution cd1 = new ContentDistribution();
	//	cnv = [SELECT Id,Title, VersionData FROM ContentVersion where ContentDocumentId = '069g0000001Y6sVAAS'];
        cd1 = [Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl from ContentDistribution where ContentDocumentId='069g0000001XuJPAA0'];
        //String data1 = EncodingUtil.base64Encode(cnv.VersionData);
        Attachment attachment = new Attachment();
        attachment.ContentType = 'pdf';
        attachment.Name = 'pdfdocfjsdf.pdf';
        attachment.Body = Blob.valueOf(cd1.DistributionPublicUrl);
        attachment.ParentId = 'a58g00000000eTQ';
        insert attachment;
//        System.debug('pageReference2'+pageReference2);
        return null;
        /*ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.Origin = 'C';
        PageReference pdf = new PageReference('');
        pdf = new PageReference('/apex/POCDoctoPDFV2');
        pdf.getParameters().put('Id', String.valueOf(cnv.Id)); //params
        pdf.setRedirect(true);
        Blob pdfPageBlob = pdf.getContentAsPDF();
        System.debug('pdfPageBlob'+pdfPageBlob);
        cVersion.VersionData = pdfPageBlob;	
        cVersion.Title = 'Title';
        cVersion.PathOnClient = 'POCPDF.pdf';
        Insert cVersion;/*
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('FileName');
        efa.setBody(pdfPageBlob);*/
   // }
    public PageReference saveNextResponse(){
        /*Attachment attachment = new Attachment();
        attachment = [SELECT Id, Name,body FROM Attachment where Id = '00Pg000000Az3NN'];
		String body1 = String.valueOf(attachment.body);	*/	
        //doing a DML as well
        pageRef = new PageReference('/apex/POCDoctoPDFV2');
                                   //?FileId='+attachment.Id
        pageRef.setRedirect(true);
        fetchContentDataFromPage(pageRef.getUrl());
        return pageRef;
    }
    public String[] getStrings() {
        List<String> publicLinks = new List<String>();
        List<ContentDistribution> cdList = new List<ContentDistribution>();        
        cdList = [Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl from ContentDistribution where ContentDocumentId IN ('069g0000001YDj1AAG')];
        for(ContentDistribution cd : cdList){
        	publicLinks.add(cd.DistributionPublicUrl);
        }
        return publicLinks;
    }
    public String[] getvats(){
        //List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        List<String> ClaimTitles = new List<String>();
        /*claimList = [Select Title from PartnerFundClaim Limit 3];
        for(PartnerFundClaim claim : claimList){
            ClaimTitles.add(claim.Title);
        }*/
        ClaimTitles.add('Vat Claim 1');
        ClaimTitles.add('Vat Claim 2');
        ClaimTitles.add('Vat Claim 3');
        return ClaimTitles;
    }
    
    @Future(Callout=true)
    public static void fetchContentDataFromPage(String pageURL){
        System.debug('InsideMail');
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName('Test.pdf');
        attach.setInline(false);
        attach.setBody(new PageReference(pageURL).getContent());
        email.setSubject('Test Email');
        List<String> lStrings = new List<String>();
        lStrings.add('bishalx.singh@intel.com');
        lStrings.add('pranavx.singh@intel.com');
        email.setToAddresses(lStrings);
        email.setPlainTextBody('Thank You .');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{
                attach
        });
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                email
        });
        System.debug('EndOfFuture');
    }
}