@istest
public class Core_MDF_CustLayout_ServiceHandler_Test{
    @testSetup
    public static void createTestData(){
        List<Core_MDF_Custom_Layout_Section__c> sections= new List<Core_MDF_Custom_Layout_Section__c>();
        //Added "Core_MDF_Field_View_nm__c" required field by AN
        Core_MDF_Custom_Layout_Section__c sec1=new Core_MDF_Custom_Layout_Section__c(Core_MDF_Section_Name_txt__c='Section 8',Core_MDF_Object_Name_txt__c='Campaign',Core_MDF_No_Of_Columns_nm__c= '1', Core_MDF_Sequence_No_nbr__c= 8.0,Core_MDF_Field_View_nm__c='Compact Layout');
        Core_MDF_Custom_Layout_Section__c sec2=new Core_MDF_Custom_Layout_Section__c(Core_MDF_Section_Name_txt__c='Section 9',Core_MDF_Object_Name_txt__c='PartnerFundRequest',Core_MDF_No_Of_Columns_nm__c= '1', Core_MDF_Sequence_No_nbr__c=9.0,Core_MDF_Field_View_nm__c='Compact Layout');
        sections.add(sec1);
        sections.add(sec2);
        database.insert(sections);
        
        List<Core_MDF_Custom_Layout_Configurations__c> customLayoutGoodData =new List<Core_MDF_Custom_Layout_Configurations__c>();
        customLayoutgooddata.add(new Core_MDF_Custom_Layout_Configurations__c(Core_MDF_Field_API_Name_txt__c='Core_Campaign_Priority__c',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_Object_API_Name_txt__c='Campaign',Core_MDF_Section_id__c=sections[0].id, Core_MDF_User_Type_nm__c= 'Internal User'));
        customLayoutgooddata.add(new Core_MDF_Custom_Layout_Configurations__c(Core_MDF_Field_API_Name_txt__c='Core_MDF_Activity_SubType_nm__c',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_Object_API_Name_txt__c='PartnerFundRequest',Core_MDF_Section_id__c=sections[1].id, Core_MDF_User_Type_nm__c= 'Internal User'));
        database.insert(customLayoutGoodData);
    }
    @isTest
    public static void checkInsertBadData(){ 
        Test.startTest();
        Core_MDF_Custom_Layout_Section__c sec1=[select Id,Core_MDF_Section_Name_txt__c,Core_MDF_No_Of_Columns_nm__c, Core_MDF_Sequence_No_nbr__c from Core_MDF_Custom_Layout_Section__c where Core_MDF_Object_Name_txt__c='Campaign'];
        Core_MDF_Custom_Layout_Section__c sec2=[select Id,Core_MDF_Section_Name_txt__c,Core_MDF_No_Of_Columns_nm__c, Core_MDF_Sequence_No_nbr__c from Core_MDF_Custom_Layout_Section__c where Core_MDF_Object_Name_txt__c='PartnerFundRequest'];
        Try{
            database.insert(new Core_MDF_Custom_Layout_Configurations__c(Core_MDF_Field_API_Name_txt__c='EndDate',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_Object_API_Name_txt__c='Campaign',Core_MDF_Section_id__c=sec1.id,Core_MDF_User_Type_nm__c='Internal User') );
        }catch(Exception ex){
            System.assert(ex.getMessage().contains('Please Enter'));
        }       
        Try{
            database.insert(new Core_MDF_Custom_Layout_Configurations__c(Core_MDF_Field_API_Name_txt__c='CoreMDFActivityTypes',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_Object_API_Name_txt__c='PartnerFundRequest',Core_MDF_Section_id__c=sec2.id) );
        }catch(Exception e){
            System.assert(e.getMessage().contains('Please Enter Valid Field API Name'));
        }
        Try{
            database.insert(new Core_MDF_Custom_Layout_Configurations__c(Core_MDF_Field_API_Name_txt__c='Core_MDF_Campaign_Scoring_txt__c',Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance',Core_MDF_Object_API_Name_txt__c='camapaign',Core_MDF_Section_id__c=sec1.id) );
        }catch(Exception e){
            System.assert(e.getMessage().contains('Please Enter Valid Object API Name'));
        }
        Test.stopTest();
    }
    @istest
    public static void checkUpdateBadData(){
        List<Core_MDF_Custom_Layout_Configurations__c> record1=[select Core_MDF_Field_API_Name_txt__c,Core_MDF_Record_Type_Name_txt__c,Core_MDF_Section_id__c from Core_MDF_Custom_Layout_Configurations__c where Core_MDF_Object_API_Name_txt__c='Campaign'or Core_MDF_Object_API_Name_txt__c='PartnerFundRequest' ];
        record1[0].Core_MDF_Field_API_Name_txt__c='	CoreMDFCampaignStatus';
        record1[1].Core_MDF_Record_Type_Name_txt__c='Intel Partner Alliance';
        Test.startTest();
        Try{database.update(record1[0]);}
        catch(Exception ex){
            System.assert(ex.getMessage().contains('Please Enter Valid Field API Name'));
        } 
        Try{database.update(record1[1]);}
        catch(Exception ex1){
            System.assert(ex1.getMessage().contains('Please Enter Valid Record Type Name'));
        }   
        Test.stopTest();   
    }
}