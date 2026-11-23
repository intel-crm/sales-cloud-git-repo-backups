/****************************************************************************************************************************************
* Class Name  : PMP_Chipsets_Attribute_Japanese_Proc 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team                      05/10/2019                    Class for Processing Chipsets_Attribute_Chinese Static Resource
* ****************************************************************************************************************************************/

public class PMP_Chipsets_Attribute_Japanese implements PMP_ProcessTaxonomyJSON {

    public List<Database.UpsertResult> processData(String fileName)
   {
       return PMP_ParseChipSet_JSON.parseChipSetJSON(fileName);
   }
}