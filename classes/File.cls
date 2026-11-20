public abstract class File
    {
        public abstract SObject getRecord();
        public abstract Blob getBody();
        public abstract String getContentType();
    
        public static File make(SObject record)
        {
            if(record instanceof Document){
                return new File.DocumentImpl( (Document) record );
            }else{
                throw new FileException('Unexpected SObject type, only Attachment and Document supported.');
            }                
           /* if(record instanceof Document)
                return new File.DocumentImpl( (Document) record );
            else if(record instanceof Attachment)
                return new File.AttachmentImpl( (Attachment) record );
            throw new FileException('Unexpected SObject type, only Attachment and Document supported.');
			*/
        }
    
        private class DocumentImpl extends File
        {
             private Document document;
             public DocumentImpl(Document document) { this.document = document; }
             public override SObject getRecord() { return document; }
             public override Blob getBody() { return document.body; }
             public override String getContentType() { return document.contentType; }
        }
        /*
        private class AttachmentImpl extends File
        {
             private Attachment attachment;
             public AttachmentImpl(Attachment document) { this.attachment = attachment; }
             public override SObject getRecord() { return attachment; }
             public override Blob getBody() { return attachment.body; }
             public override String getContentType() { return attachment.contentType; }
        }*/
    
        public class FileException extends Exception { }
    }