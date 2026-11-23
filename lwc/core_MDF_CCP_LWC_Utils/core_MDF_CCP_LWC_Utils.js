import { LightningElement } from 'lwc';

// Import custom labels
import estAddSize from '@salesforce/label/c.Core_MDF_EstimatedAdSizeFieldLabel';
import typeOfPage from '@salesforce/label/c.Core_MDF_TypeOfPageFieldLabel';
import MagNewsPaper from '@salesforce/label/c.Core_MDF_MagazineNewspaperFieldLabel';

export default  class core_MDF_CCP_LWC_Utils extends LightningElement {
    
   getCustomLabels(keys){

        let customLabels = [];

        if (keys != null){
            Object.entries(keys).forEach(val =>{
                if (val === 'estAddSize'){
                    customLabels.push({"label" : 'estAddSize', "value" : estAddSize});
                }else if (val === 'typeOfPage'){
                    customLabels.push({"label" : 'typeOfPage', "value" : typeOfPage});
                }else if (val === 'typeOfPage'){
                    customLabels.push({"label" : 'MagNewsPaper', "value" : MagNewsPaper});
                }
            });
        }

        return customLabels;
    }
}