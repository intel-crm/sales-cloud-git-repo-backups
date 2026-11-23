/******************************************************************************************************************************************************************************************************
* Class Name  : PMP_NUC_Attribute_Japanese
* Version     : 1.0 
* Created Date: 4th Feb, 2019
* Modification Log :
* Developer                             Date                    Description
* -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Raj Yadav                            02/04/2019               Created for processing NUC_Attribute_Japanese static resource.
******************************************************************************************************************************************************************************************************/
public class PMP_NUC_Attribute_Japanese implements PMP_ProcessTaxonomyJSON{

    public List<Database.UpsertResult> processData(String fileName){
        return PMP_ParseNUCJSON.ParseNUCJSON(fileName);
    }
}