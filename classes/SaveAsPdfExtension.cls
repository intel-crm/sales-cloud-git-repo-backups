public class SaveAsPdfExtension {
    public List<Blob> blobList{get;set;}
    void SaveAsPdfExtension(){
        List<case> cs = [select id from case where Id='5003F000007Qj6x'];
        blobList = new List<Blob>();
        for(case c:cs){
            PageReference ref = Page.Core_IPS_Case_ExportPDF;
            ref.getParameters().put('id',c.id);
            blobList.add(ref.getContentAsPDF());
        }
    }
    
}