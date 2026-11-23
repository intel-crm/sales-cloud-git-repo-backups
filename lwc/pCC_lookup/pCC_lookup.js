import LightningDatatable from "lightning/datatable";

import lookupTemplate from "./PCC_CustomLookupDataType.html";


export default class PCC_Lookup extends LightningDatatable {
    static customTypes = {
        lookup: {
          template: lookupTemplate,
          standardCellLayout: true,
          typeAttributes: ["recordId","disabled","objectName"],
        }
    }
}