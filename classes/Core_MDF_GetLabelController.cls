public class Core_MDF_GetLabelController {
public String mylabel{get; set;}

    public Core_MDF_GetLabelController()
    {
         mylabel='labelname';   
    }
    public static String getLabel(String myLabel ){
    Component.Apex.OutputText output = new Component.Apex.OutputText();
    output.expressions.value = '{!$Label.'+ myLabel + '}';
    return String.valueOf(output.value);
}
}