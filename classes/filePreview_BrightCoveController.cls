public class filePreview_BrightCoveController {
    @AuraEnabled(cacheable=true)
    public static string getFileUrl(){
        return 'https://intel--crmdevipa.my.salesforce.com/sfc/p/8A0000005uU8/a/8A000000CqgC/iYIz4vnxrux_OHYds051wBWnCssP6bjsPdrHEEySDHs';
        /*try
        {
            List<PMP_Company_Resource__c> files=[SELECT  Video_File_URL__c,Video_File_Name__c FROM PMP_Company_Resource__c 
                                      where Id=:record];
            PMP_Company_Resource__c file=files[0];
            return file.Video_File_URL__c;
        }
        catch(Exception ex)
        {
            system.debug('ex:'+ex.getMessage());
            return '';
        }*/
    }
}