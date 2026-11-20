import LightningDatatable from 'lightning/datatable';
/*
    import all supporting components
*/
//import FileUploadTemplate  from        './fileUpload.html';
import lookupTemplate      from        './lwclookup.html';
import picklistTemplate    from        './picklist.html';
import multiselectTemplate from        './multiselectPicklist.html';
//import imageTemplate       from        './image.html';

export default class Core_MDF_CCP_lwcDatatable extends LightningDatatable {
    static customTypes = {
       /* fileUpload: {
            template: FileUploadTemplate,
            typeAttributes: ['acceptedFormats','doUpload']
        },*/
        lookup : {
            template: lookupTemplate,
            typeAttributes: ['objectname', 'icon', 'label', 'placeholder', 'fields', 'displayFields', 'valueId', 'valueName','currentRecordId','parentAPIName'],
        },
        picklist : {
            template: picklistTemplate,
            typeAttributes: ['label','placeholder', 'options','parentrecord','showEdit','fieldnameapi','class'],
        },
        multiselectPicklist :{
            template: multiselectTemplate,
            typeAttributes: ['label','placeholder', 'options','parentrecord','showEdit','fieldnameapi','class'],
        }
     /*   image : {
            template: imageTemplate,
            typeAttributes: ['alttxt','width','height'],
        }*/
    };
}