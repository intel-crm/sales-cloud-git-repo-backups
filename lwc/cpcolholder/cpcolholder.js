import { LightningElement } from 'lwc';
import tmp from './cptemplate.html';
import LightningDatatable  from 'lightning/datatable';

export default class Cpcolholder extends LightningDatatable {
    static customTypes={
        cpnumber:{
            template:tmp,
            typeAttributes:[ 'cpnumber','recordId']
        },
    }
}