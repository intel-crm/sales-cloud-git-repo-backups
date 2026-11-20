public class Core_MDF_PaymentXMLGenerator {
    
    /****************************************************************************************************** 
	Method Name:        xmlStringGenerator
	@return  :          String in XML format for payment file generation
	@parameters:        List<list<String>> which contains payment file content
	Description:        This method is used to generate string in XML format for payment file generation
	Added By:           Accenture - BD - 10-MAR-2022
	Modified By:        Date:       Changes: 
	*******************************************************************************************************/
    public static String xmlStringGenerator(list<list<String>> paymentFileContent,String worksheetName)
    {
        
        //File Header
        String xmlString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLVersion') + ' ' + Core_MDF_PaymentUtility.newline +
            Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLProgId') + ' ' + Core_MDF_PaymentUtility.newline+
            Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLWorkbookStart') + ' ' + Core_MDF_PaymentUtility.newline +
            Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLWorksheetStart')+ worksheetName + '"> ' + Core_MDF_PaymentUtility.newline +
            Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLTableStart') + ' ' + Core_MDF_PaymentUtility.newline +
            Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLColumn') + ' ' + Core_MDF_PaymentUtility.newline;
        
        if(!paymentFileContent.isEmpty())
        {
            for(List<String> row: paymentFileContent)
            {
                if(!row.isEmpty())
                {
                    //Row Beginning
                    xmlString += Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLRowStart') + ' ' + Core_MDF_PaymentUtility.newline;
                    for(String cellValue : row)
                    {
                        if(String.isEmpty(cellValue))
                        {
                            xmlString+= Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLCellStart') + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLCellEnd') + ' ' + Core_MDF_PaymentUtility.newline;
                        }
                        else
                        {
                            xmlString+= Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLCellStart')+ cellValue + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLCellEnd') + ' ' + Core_MDF_PaymentUtility.newline;
                        }
                    }
                    //Row End
                    xmlString+= Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLRowEnd') + ' ' + Core_MDF_PaymentUtility.newline;
                }
            }
        }
        //File Footer
        xmlString+= Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLTableEnd') + ' ' + Core_MDF_PaymentUtility.newline + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLWorksheetEnd') + ' ' + Core_MDF_PaymentUtility.newline + Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_XMLWorkbookEnd') + ' ' + Core_MDF_PaymentUtility.newline;        
        
        return xmlString;
        
    }
    
}