@isTest
public class PMP_Locale_JSONParser_Test {

    static testMethod void parse(){
        
        PMP_Locale_JSONParser.parse('{}');
        PMP_Locale_JSONParser.WrapOfferingMain wom=new PMP_Locale_JSONParser.WrapOfferingMain();
        wom.SourceLanguage='dasdasd';
        
        List<PMP_Locale_JSONParser.WrapOfferings> wos=new List<PMP_Locale_JSONParser.WrapOfferings>();
        PMP_Locale_JSONParser.WrapOfferings wo=new PMP_Locale_JSONParser.WrapOfferings();
        wo.OfferingId='testId';
        wo.ModifiedDate=System.today();
        wo.OfferingDescription='test';
        wo.OfferingName='test Offering';
        wo.TagLine='tagline';
        wo.TargetLanguage='English';
        wos.add(wo);
        
        wom.Offerings=wos;
    }
}